/*
@created by       : Aishwarya Badri
@created on       : 02/08/2021
@Purpose          : Case commennt helper class.
@Testclass        : 
@JIRA : 


Change History
****************************************************************************************************************************************************
ModifiedBy      Date        Requested By        Description                                             Jira No.       Tag
****************************************************************************************************************************************************
Aishwarya Badri    08-02-21    Utopia phase2    when there is a external case comment by                   I2RT-575       T01
                                                an engineer , mark IR as completed
Aishwarya Badri    08-02-21   Utopia phase 2    when there is an IR , Change the status to assess          I2RT-577       T02
Aishwarya BadrI    08-02-21   Utopia phase 2    When there is a customer inbound, update the case flag.    I2RT-658       T03
Akhilesh           13-4-21    Utopia phase 2    Rewritten functionality related to processing 
                                                inbound/outbound Case comments
Akhilesh           16-4-21   Utopia phase 2     limit outbound comment processing for only submitted        
                                                case comments 
Deva               05-07-21   Utopia phase 2    Escalation and Attention Request Milestone                 I2RT-2129       T04
Deva               21-07-21   Utopia phase 2    Add Product Manager as EM to the Case Team                 I2RT-3244       T05
Vignesh D          02-09-21   Utopia            Skip processing inbound/outbound case comments for         I2RT-4308       T06
                                                Attention Request & Escalation
Vignesh D          22-09-21   Utopia            Commented external case comments changing case             I2RT-4563       T07
                                                status from New to Assess
Sandeep Duggi      12-08021 Utopia                                                                         I2RT-4790        T09
Amit Garg          03/02/2022    Utopia        status from New to Assess                                    I2RT-5460        T10
balajip            28-03-22     Utopia          to notify Proxy engineer on Inbound comment                I2RT-5485       T11
Vignesh D          04-01-2022                   Only submitted case comments should be considered for      I2RT-5879       T12
                                                emails
balajip            04-18-2022                   to notify tagged users on a comment                        I2RT-5459       T13
Shashikanth        05-22-2023                   Consider Initial response comment as IR completed          I2RT-8386       T14
                                                for Standard/Basic P2/P3 cases.
*/

public class CaseCommentTriggerHelper {
    private static final String ESCALATION_ATTENTION_SETTING='Escalation_And_Attention_Setting';
    public static final String TYPE_CALLBACK = 'Callback';//<T06>
    public static final String TYPE_REVISE_PRIORITY = 'Revise Priority';//<T06>
    public static final String TYPE_ESCALATION = 'Escalation';//<T06>
     public static globalApexManager GAM = new globalApexManager();

    public static final CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notification_Service_Desktop_Mobile' LIMIT 1];

    //<TO2>
    ////Engineer/Manager does an Initial Response (IR) on the New case from the Queue - Status changes to Assess. Case stays in the Queue.
    public void updateCaseInfo(List<Case_Comment__c> caseComments){
        system.debug('Trigger updateCaseStatusToAssess');
        Set<Id> CaseCommentsIds=new Set<Id>();
        Set<id> setCases=new Set<Id>();
        List<Case> casesToUpdate=new List<Case>();
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        
        Id caseTechnicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Id AdministrativeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
        Id fulfillmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();
        Id operationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        
        for(Case_Comment__c cc: caseComments)
        {
            if(cc != null)
            {
                CaseCommentsIds.add(cc.Id);
                setCases.add(cc.Case__c);
            }
        }
        
        for(Case_Comment__c cc: [SELECT Id, Type__c, Case__r.OwnerId, Case__r.Status, Case__r.RecordTypeId, Case__c, Inbound__c, Case__r.Automatic_closure_Date__c, Status__c, Sub_Type__c,Comment__c
                                 FROM Case_Comment__c 
                                 WHERE Id IN : CaseCommentsIds]){
            system.debug('case= '+cc.Case__r);
            //Deva :  I2RT-3582 Changed the logic to prevent Case status is getting updated to ASSESS once Blank internal/external comment is added in draft status
            //By this change it should change case status to Assess only when status of case comment is submitted and comment body is not blank
            //<T07>
            /*if((cc.Case__r.RecordTypeId == operationRecordTypeId || 
                cc.Case__r.RecordTypeId == caseTechnicalRecordTypeId || 
                cc.Case__r.RecordTypeId == AdministrativeRecordTypeId || 
                cc.Case__r.RecordTypeId == fulfillmentRecordTypeId) && 
                cc.Status__c.equalsIgnoreCase('Submitted') && String.isNotBlank(cc.Comment__c) && 
               (String.valueOf(cc.Case__r.OwnerId).startsWith('00G') && cc.Case__r.Status == 'New' && !cc.Inbound__c && cc.Status__c != 'Pre Draft' && cc.Sub_Type__c != 'Initial Response')
              ){
                Case updateCase = new Case();
                updateCase.Id = cc.Case__c;
                updateCase.Status = 'Assess';
                casesToUpdate.add(updateCase);
            }*/ //</T07>
            If(cc.Inbound__c && cc.Case__r.Automatic_closure_Date__c != null && cc.Case__r.Automatic_closure_Date__c > system.now()){
                Case updateCase = new Case();
                updateCase.Id = cc.Case__c;
                updateCase.Automatic_closure_Date__c = null;
                updateCase.Is_Delay_Close__c = false;
                casesToUpdate.add(updateCase);
            }

            //I2RT-4234
            if('Predictive Escalation'.equals(cc.Type__c)){
                Case cse = new Case();
                cse.Id = cc.Case__c;
                cse.IsEscalated = true;
                cse.Escalated__c = true;
                cse.Escalate_Open__c = true;
                cse.Escalation_Attention__c = true;
                cse.Escalated_Date__c = System.today();
                cse.Escalation_Reason__c = 'Predictive Escalation';
                casesToUpdate.add(cse);
            }
        }
        
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
        
        //</TO2>
    }
    
    //@Akhilesh 13 Apr 2021 -- start
    /*
    //<TO1>
    public  void completeIRMilestones(List<Case_Comment__c> triggerNew){
        System.debug('updateCaseMilestones ENTRY--'+triggerNew);
        
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        Set<Id> setCases=new Set<Id>();
        
        for(Case_Comment__c cc: triggerNew)
        {
            System.debug('cc-->'+cc);
            System.debug('cc.Case__c-->'+cc.Case__c);
            System.debug('cc-Visibility__c->'+cc.Visibility__c);
            System.debug('cc-Inbound__c->'+cc.Inbound__c);
            
            
            if(cc!=null)
            {
                //when there is a external case comment by an engineer , mark IR as completed
                if(cc.Visibility__c!=null && cc.Visibility__c=='External' && !cc.Inbound__c )
                {
                    System.debug('cc.Case__c entry-->');
                    setCases.add(cc.Case__c);
                }
            }
        }
        System.debug('setCases-->'+setCases);
        
        //not completed and ir milestones
        if(!setCases.isEmpty())
        {
            for(CaseMilestone cm:[Select Id,MilestoneTypeId,milestonetype.name 
                                  From CaseMilestone 
                                  Where CaseId in :setCases 
                                  And  milestonetype.name='Initial Response' 
                                  And IsCompleted = false  
                                  And CompletionDate = null])
            {
                cm.CompletionDate = System.now();
                lstCaseMilestones.add(cm);
            }
        }
        System.debug('lstCaseMilestones-->'+lstCaseMilestones);
        if(!lstCaseMilestones.isEmpty())
        {
            update lstCaseMilestones;
        }
    }//</TO1>
    */    
    //@Akhilesh 13 Apr 2021 -- end

    //<TO3>
    //@Akhilesh 13 Apr 2021 -- start
    
    public void processCaseComments(List<Case_Comment__c> caseComments,Map<Id,Case_Comment__c> oldCaseComments){
        System.debug('@Developer -->processCaseComments:' );
        
        set<Id>setInboundCase = new set<Id>();
        set<Id>setOutboundCase = new set<Id>();
        //Amarender - I2RT-4781 
        set<Id> inExtCommentCaseIds = new set<Id>();

        list<Case>lstCaseToUpdate = new list<Case>();
        List<CaseMilestone> lstCM = new List<CaseMilestone>();
        
        Map<Id,Id> caseParentCommentMap = new  Map<Id,Id>();//<T05> Deva: to hold parent comment ID and case id

        for(Case_Comment__c cc: caseComments){
            System.debug('@Developer --> cc.Inbound__c :' + cc.Inbound__c);
            System.debug('@Developer --> cc.Visibility__c :' + cc.Visibility__c);
            //Amarender - I2RT-4781 - Start
            //external && submitted - case last activity needs to be updated
            if(cc.Visibility__c == 'External' && cc.Status__c == 'Submitted'){
                inExtCommentCaseIds.add(cc.Case__c);
                //@Akhilesh 2 Dec  2021 -- start
                /*if(cc.Type__c == TYPE_ESCALATION || cc.Type__c == TYPE_CALLBACK || cc.Type__c == TYPE_REVISE_PRIORITY){
                    Case cse = new Case(Id=cc.Case__c,Case_Last_Activity__c = System.now());
                    lstCaseToUpdate.add(cse);
                }
                */
                //@Akhilesh 2 Dec  2021 -- end
            } 
            //Amarender - I2RT-4781 - End
            //<T05> Deva : Start I2RT-3244 : Filter the Child escaltion comments comments which was created when replied                
                if(oldCaseComments==null && cc.Parent_Comment__c != null && 
                    String.isNotBlank(cc.Status__c) && cc.Status__c.equalsIgnoreCase('Submitted') ){
                    caseParentCommentMap.put(cc.Parent_Comment__c,cc.case__c);
                }
            //<T05> Deva: End I2RT-3244
            if(cc.Inbound__c && cc.Visibility__c == 'External' && (cc.Type__c != TYPE_ESCALATION && cc.Type__c != TYPE_CALLBACK && cc.Type__c != TYPE_REVISE_PRIORITY)){ //<T06>
                if(!cc.Is_Replied_To__c){
                    setInboundCase.add(cc.Case__c);
                }
            }
            else{ // outbound comment
                //@Akhilesh 16 Apr 2021 -- start

                /*
                if(cc.Visibility__c == 'External'){
                    setOutboundCase.add(cc.Case__c);
                }
                */

                //there are scenarios where comments are saved in draft status 
                //comment must be processed when submitted only
                if(cc.Status__c == 'Submitted' && (cc.Type__c != TYPE_ESCALATION && cc.Type__c != TYPE_CALLBACK && cc.Type__c != TYPE_REVISE_PRIORITY)){ //<T06>
                    if(cc.Visibility__c == 'External'){
                        //@Akhilesh 1 June 2021 -- start [I2RT-2995]
                        //setOutboundCase.add(cc.Case__c);

                        if(cc.Sub_Type__c  != 'Initial Response'){
                            setOutboundCase.add(cc.Case__c);
                        }
                        //@Akhilesh 1 June 2021 -- end [I2RT-2995]

                    }
                }
                //@Akhilesh 16 Apr 2021 -- end
            }
        }
        //<T05> Deva : Start I2RT-3244 : check the size of collection pass to method to add member to case team
        if(caseParentCommentMap.size()>0){
            checkAndAddManagerToCaseTeam(caseParentCommentMap);
        }

        Set<String> setMilestoneName = new Set<String>();
            setMilestoneName.add('Initial Response');
            setMilestoneName.add('Initial Response Migrated');
            setMilestoneName.add('Ongoing Response');
            setMilestoneName.add('Ongoing Response Migrated');
            setMilestoneName.add('Extended Ongoing Response');
            setMilestoneName.add('Engineer Ongoing Response');
            setMilestoneName.add('Attention Request Response');
            setMilestoneName.add('Escalation Response');
            //setMilestoneName.add('Target Service Restoration Response');

        //<T05> Deva : End I2RT-3244 
        for(Case oCase : [SELECT Id, CaseNumber,recordType.Name,ownerId,Status,
                                Priority, Success_Offering__c, IR_Completion_Date__c,       //</T14>
                          (SELECT Id,CaseId,MilestoneType.Name 
                           FROM CaseMilestones 
                           WHERE MilestoneType.Name In :setMilestoneName
                           And IsCompleted = false  
                           And CompletionDate = null
                          )
                          FROM Case 
                          WHERE (Id IN :setInboundCase OR Id IN :setOutboundCase OR Id in: inExtCommentCaseIds) 
                         ])//<T10>
        {   
           if(oCase.recordType.Name != 'Ask An Expert'){
                //Inbound comment processing
                if(setInboundCase.contains(oCase.Id)){
                    boolean bNonCompleteCMExists = false;
                    boolean bOGReOGRCMExists = false;
                    
                    for(CaseMilestone cm : oCase.CaseMilestones){
                        bNonCompleteCMExists = true;
                        
                        //@Akhilesh 21 Aug 2021 -- start
                        /*if(cm.MilestoneType.Name.toLowerCase() != 'initial response'){
                            bOGReOGRCMExists = true;
                        }*/
                        
                        if(cm.MilestoneType.Name.toLowerCase() == 'ongoing response' ||
                        cm.MilestoneType.Name.toLowerCase() == 'extended ongoing response' ||
                        cm.MilestoneType.Name.toLowerCase() == 'engineer ongoing response'){
                            bOGReOGRCMExists = true;
                        }

                        //@Akhilesh 21 Aug 2021 -- end
                    }
                    
                    //when no IR/OGR/eOGR milestone is running OR only IR is running
                    if(!bNonCompleteCMExists || !bOGReOGRCMExists){
                        lstCaseToUpdate.add(getCase(oCase.Id,true,inExtCommentCaseIds));
                    }else if(inExtCommentCaseIds != null && inExtCommentCaseIds.contains(oCase.Id)){
                        Case cse = new Case(Id=oCase.Id,Case_Last_Activity__c = System.now());
                        lstCaseToUpdate.add(cse);
                    }
                }
                else if(setOutboundCase.contains(oCase.Id)){
                    for(CaseMilestone cm : oCase.CaseMilestones){
                        cm.CompletionDate = System.now();
                        lstCM.add(cm);
                    }
                    //<T10>
                    case c= getCase(oCase.Id,false,inExtCommentCaseIds);
                    if(inExtCommentCaseIds.contains(ocase.Id) && ((string)(oCase.ownerId)).startsWith('00G') && oCase.status == 'New'){
                        c.status = 'ASSESS';
                    }
                    
                    //<T14>
                    if((oCase.Priority == 'P2' || oCase.Priority == 'P3') 
                        && (oCase.Success_Offering__c == 'Basic Success' || oCase.Success_Offering__c == 'Standard') 
                        && oCase.IR_Completion_Date__c == null)
                    {
                       c.IR_Completion_Date__c = System.now();
                    }
                    //</T14>
                    
                    lstCaseToUpdate.add(c);
                    //<T10>
                }
            }
            else {
            //<T10>
                if(inExtCommentCaseIds.contains(ocase.Id) && ((string)(oCase.ownerId)).startsWith('00G') && oCase.status == 'New'){
                    oCase.status = 'ASSESS';
                }
                //<T10>
                oCase.Case_Last_Activity__c = System.now();
                lstCaseToUpdate.add(oCase);
            }
        }
        
        if(lstCM.size() > 0){
            update lstCM;
        }
        //</T04>
        //Deva:Start add the list of records updated to the existing logic :  06 July 2021 for [I2RT-2129]
        if(oldCaseComments!=null && oldCaseComments.size()>0){
            Map<Id,Case> escalatedCaseMap = new  Map<Id,Case> ();
            escalatedCaseMap=updateCaseEscalationAttentionInfo(caseComments,oldCaseComments);
            if(escalatedCaseMap.size()>0){
                for(case c:lstCaseToUpdate){
                    if(escalatedCaseMap.get(c.Id)!=null){ 
                        c.Escalation_Attention__c = true;                     
                        escalatedCaseMap.remove(c.Id);
                    }                
                }
                if(escalatedCaseMap.size()>0){
                    lstCaseToUpdate.addAll(escalatedCaseMap.values());
                }
            }
        }
        //Deva: End
        //</T04>
        if(lstCaseToUpdate.size() > 0){
            System.debug('@Developer --> lstCaseToUpdate :' +lstCaseToUpdate);
            update lstCaseToUpdate;
        }
        
    }
    
    private Case getCase(Id caseId,boolean bInbound,Set<Id> inExtCommentCaseIds){
        System.debug('@Developer --> getCase:' );
        System.debug('@Developer --> bInbound:' + bInbound);
        Case oCase= new Case();
        oCase.Id = caseId;
        oCase.eOGR_in_Mins__c = 0;
        oCase.Inbound_comment__c = bInbound;
        //</T04>
        //@Deva - 05th July 2021 - Start
        //Set the field to false if the Inbound comment field set to false
        if(!bInbound){
            oCase.Escalation_Attention__c = false;
            oCase.Escalate_Open__c = false;
            oCase.Attention_Request__c = '';
            oCase.IR_in_Mins__c = 0;
            oCase.OGR_in_Mins__c = 0;
        } 
        //@Deva 5 July 2021 -- end   
        //</T04>
        //@Akhilesh 5 June 2021 -- start
        //oCase.Next_Action__c = bInbound ? 'Case Owner': 'Customer';
        if(bInbound){
            oCase.Next_Action__c = 'Case Owner';
        }
        
        //@Akhilesh 5 June 2021 -- end    
        //Amarender - I2RT-4781 - Start
        //external && submitted - case last activity needs to be updated
        //Inbound && submitted - case last activity needs to be updated 
        if(inExtCommentCaseIds != null && inExtCommentCaseIds.contains(caseId)){
            oCase.Case_Last_Activity__c = System.now();
        }
        //Amarender - I2RT-4781 - End
        return oCase;
    }
    
    /*
    
    public void processCaseComments(List<Case_Comment__c> caseComments){
        system.debug('Trigger updateCaseInbound');
        List<Case> lstCasesWithInbCmmnts=new List<Case>();
        Map<Id,String> mapCaseToCommentType=new Map<Id,String>();
        list<Case> updateCaseInbFlag = new List<Case>();
        list<Case> lstInbound = new List<Case>();
        list<Case> lstOutbound = new List<Case>();
        
        
        for(Case_Comment__c cc: caseComments){
            if(cc.Inbound__c)
            {
                System.debug('line 112-->'+cc.Case__c);
                mapCaseToCommentType.put(cc.Case__c,'Inbound');
                
            }
            else if(!cc.Inbound__c)
            {
                System.debug('line 117-->'+cc.Case__c);
                // if(cc.Status__c=='Submitted')
                //{
                if(!cc.Is_eOGR_comment__c)
                {
                    System.debug('not eogr comment');
                    //@Akhilesh 9 Apr 2021 -- start 
                    ////   mapCaseToCommentType.put(cc.Case__c,'Outbound');
                    if(cc.Visibility__c =='External'){
                        mapCaseToCommentType.put(cc.Case__c,'Outbound');
                    }
                    //@Akhilesh 9 Apr 2021 -- end
                }
                //}                
            }
        }
        System.debug('mapCaseToCommentType-->'+mapCaseToCommentType);
        System.debug('mapCaseToCommentType.keySet()-->'+mapCaseToCommentType.keySet());
        if(mapCaseToCommentType.keySet()!=null && !mapCaseToCommentType.keySet().isEmpty())
        {
            for(Id caseID: mapCaseToCommentType.keySet())
            {
                Case c;
                System.debug('mapCaseToCommentType.get(c)--->'+mapCaseToCommentType.get(caseID));
                if(caseID != null && mapCaseToCommentType.get(caseID) != null)
                {
                    if(mapCaseToCommentType.get(caseID)=='Inbound')
                    {
                        c = new Case(Id=caseId);
                        lstInbound.add(c);
                        
                    }
                    else if(mapCaseToCommentType.get(caseID)=='Outbound')
                    {
                        c = new Case(Id=caseId);
                        lstOutbound.add(c);
                    }
                }
            }
            System.debug('lstOutbound-->'+lstOutbound);
            
            if(!lstOutbound.isEmpty())
            {
                processOutboundComments(lstOutbound);
            }
            if(!lstInbound.isEmpty())
            {
                processInboundComments(lstInbound);
            }
        }
    }
    
    public void processInboundComments(List<Case> lstCases)    {
        System.debug('checkForeOGRMilestones-->'+lstCases);
        Set<Id> setCases= new Set<Id>();
        Boolean iseOGRrunning=false;
        Boolean otherMilestones=false;
        List<Case> lstCasesToUpdate= new List<Case>();
        List<Case> lsteOGRCases= new List<Case>();
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        
        for(Case c:lstCases)
        {
            setCases.add(c.Id);
        }
        System.debug('setCases-->'+setCases);
        
        set<Id> setCaseId = new set<Id>();
        if(!setCases.isempty())
        {
            for(CaseMilestone cm:[Select Id,MilestoneTypeId,MilestoneType.Name,CaseId 
                                  From CaseMilestone 
                                  Where CaseId In :setCases 
                                  And (MilestoneType.Name = 'Initial Response' 
                                       Or MilestoneType.Name = 'Ongoing Response' 
                                       Or MilestoneType.Name='Extended Ongoing Response'
                                      ) 
                                  And IsCompleted = false  
                                  And CompletionDate = null])
            {
                if(cm.MilestoneType.Name == 'Extended Ongoing Response')
                {
                    System.debug('eogr is running');
                    iseOGRrunning = true;
                    break;
                }
                else {
                    System.debug('other milestone is running');
                    otherMilestones = true;
                    
                    //@Akhilesh --> 8 Apr 2021 -- start [I2RT-1952]
                    // following lines of code is stoping Initial Response Milestone 
                    ////cm.CompletionDate = System.now();
                    ////lstCaseMilestones.add(cm);
                    //@Akhilesh --> 8 Apr 2021 -- end [I2RT-1952]
                    
                    Case c = new Case(id=cm.CaseId);
                    c.eOGR_in_Mins__c = 0;
                    c.Inbound_comment__c = true;
                    c.Next_Action__c = 'Case Owner';
                    c.Case_Last_Activity__c = System.now();
                    if(!setCaseId.contains(c.Id)){
                        setCaseId.add(c.Id);
                        lstCasesToUpdate.add(c);
                    }
                }
            }
            
            if(!iseOGRrunning && !otherMilestones)
            {
                System.debug('no running milestones. create ogr on inbound ');
                for(Case c:lstCases)
                { 
                    Case cse= new Case(Id = c.Id);
                    cse.eOGR_in_Mins__c = 0;
                    cse.Inbound_comment__c = true;
                    cse.Next_Action__c = 'Case Owner';
                    cse.Case_Last_Activity__c = System.now();
                    if(!setCaseId.contains(c.Id)){
                        setCaseId.add(c.Id);
                        lstCasesToUpdate.add(cse);
                    }
                }
            }
            
            System.debug('lstCasesToUpdate-->'+lstCasesToUpdate);
            System.debug('lstCaseMilestones-->'+lstCaseMilestones);
            
            if(!lstCaseMilestones.isEmpty())
            {
                update lstCaseMilestones;
            }
            
            if(!lstCasesToUpdate.isEmpty())
            {
                update lstCasesToUpdate;
            }
        }
    }

    public void processOutboundComments(List<Case> lstCases){
        
        System.debug('completeOGRMilestones-->'+lstCases);
        Set<Id> setCases= new Set<Id>();
        List<Case> lstCasesToUpdate= new List<Case>();
        List<Case> lsteOGRCases= new List<Case>();
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        
        for(Case c:lstCases)
        {
            setCases.add(c.Id);
        }
        System.debug('setCases-->' + setCases);
        
        if(!setCases.isempty())
        {
            for(CaseMilestone cm:[Select Id,MilestoneTypeId,milestonetype.name,CaseId 
                                  From CaseMilestone 
                                  Where CaseId in :setCases 
                                  And ( milestonetype.name = 'Initial Response' 
                                       Or milestonetype.name = 'Ongoing Response' 
                                       Or milestonetype.name = 'Extended Ongoing Response') 
                                  And IsCompleted = false  
                                  And CompletionDate = null])
            {
                System.debug('not eOGR');
                
                if(!lstCaseMilestones.contains(cm)){
                    cm.CompletionDate = System.now();
                    lstCaseMilestones.add(cm);
                }
                
                Case c = new Case(Id = cm.CaseId);
                c.eOGR_in_Mins__c = 0;
                c.Inbound_comment__c = false;
                c.Next_Action__c = 'Customer';
                c.Case_Last_Activity__c = System.now();
                lstCasesToUpdate.add(c);
            }
            
            System.debug('lstCasesToUpdate-->' + lstCasesToUpdate);
            System.debug('lstCaseMilestones-->' + lstCaseMilestones);
            
            if(!lstCaseMilestones.isEmpty())
            {
                update lstCaseMilestones;
            }
            
            if(!lstCasesToUpdate.isEmpty())
            {
                update lstCasesToUpdate;
            }
        }
    }
    */
    //@Akhilesh 13 Apr 2021 -- end 
    //</TO3>       

    /**
    * @description Method to strip HTML tags from Comment to store it in a field to make the comment searchable in case collaboration
    */
    public void storeSearchableString(List<Case_Comment__c> caseComments) {
        for(Case_Comment__c comment : caseComments) {
            if(String.isNotBlank(comment.Comment__c)) {
                String escapedComment = comment.Comment__c.stripHtmlTags();
                comment.Comment_to_Search__c = escapedComment.length() >= 255 ? escapedComment.substring(0, 254): escapedComment;
            } else { 
                comment.Comment_to_Search__c = '';
            }
        }
    }
    
    /*
     * @description: Call sendgrid api to send emails to customers when a case comment is created with submit status or updated with submit status 
     * @date: 10-April-2021
     * @param:  casecomments
     * @returns: N/A
     */
        
    public void callSendGridService(List<Case_Comment__c> caseComments, Map<Id, Case_Comment__c> oldMap){
        system.debug('*** Enetring main Class'); 
        // T09
         List<Case_Comment__c> CaseCommentsToSendEmail = new List<Case_Comment__c>() ;
         Map<Id, Case_Comment__c> oldMapOfCaseComments ;
        if(oldMap != null){
                oldMapOfCaseComments = new Map<Id, Case_Comment__c>(oldMap);
            }else{
                oldMapOfCaseComments = new Map<Id, Case_Comment__c>();
            }
            
        for(Case_Comment__c cc : caseComments){
            if(cc.Visibility__c == 'External' && !cc.Inbound__c && cc.Status__c == 'Submitted'){ //<T12>
                   //T09
                   CaseCommentsToSendEmail.add(cc);                    
            }
        }  
        // T09
        try{ 
         // start T09
        if(!system.isBatch() && !system.isFuture()){
            ID jobID = System.enqueueJob(new BulkConfigureEmail (CaseCommentsToSendEmail,oldMapOfCaseComments));
            system.debug('**** Job called '+jobID);
            AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
            system.debug(jobInfo.status);
         // End T09
        }
        }catch (Exception e){
            System.debug('Exception in callSendGridService'+e.getMessage());
            //GAM.CreateExceptionRecords('CaseCommentTriggerHelper', 'Exception in callSendGridService',e.getMessage());
        }
    }

    public void notify(List<Case_Comment__c> newList, Map<Id, Case_Comment__c> oldMap){
        //system.debug('**** CaseCommentTriggerHelper, notify, comment text = ' + newList.get(0).Comment_to_Search__c);
        Set<Id> setCaseId = new Set<Id>();
        for (Case_Comment__c caseComment : newList){
            Case_Comment__c caseCommentOld;
            if(oldMap != null){
                caseCommentOld = oldMap.get(caseComment.Id);
            }

            if('External'.equals(caseComment.Visibility__c) && 'Submitted'.equals(caseComment.Status__c)){
                setCaseId.add(caseComment.Case__c);
            }
        }
        //system.debug('**** CaseCommentTriggerHelper, notify, setCaseId = ' + setCaseId);

        //T11 - added fields to the SOQL
        Map<Id, Case> mapIdToCase = new Map<Id, Case>([Select Id, OwnerId, CaseNumber, Subject, Priority, Acc__c, Version__c, 
                                                            Support_Level__c, GCS_Segment__c, Forecast_Product__c, Owner_Name__c,
                                                            AccountId, Account.Name, Account.New_Org_Account_Number__c,
                                                            Support_Account__c, Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c
                                                        From Case Where Id in :setCaseId]);
        
        Map<Id, Set<Id>> mapCaseIdToMemberIds = new Map<Id, Set<Id>>();
        for(Case cse : mapIdToCase.values()){
            Set<Id> setUserId = new Set<Id>();
            //add the case owner
            if('User'.equals(cse.OwnerId.getSobjectType().getDescribe().getName())){
                setUserId.add(cse.OwnerId);
            }
            
            mapCaseIdToMemberIds.put(cse.Id, setUserId);
        }

        List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
        for (Case_Comment__c caseComment : newList){
            Case_Comment__c caseCommentOld;
            if(oldMap != null){
                caseCommentOld = oldMap.get(caseComment.Id);
            }

            if('External'.equals(caseComment.Visibility__c) && 'Submitted'.equals(caseComment.Status__c) 
                    && (caseCommentOld == null || caseComment.Status__c != caseCommentOld.Status__c)){
                //T11 - to notify the proxy engineer on inbound
                if(caseComment.Inbound__c){
                    //system.debug('**** CaseCommentTriggerHelper, notify, inbound Case Comment found');

                    ConnectApi.FeedItemInput feedItemInput = notifyCaseTeamOnInbound(mapIdToCase.get(caseComment.Case__c), caseComment.Comment_to_Search__c);
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                    lstBatchInput.add(batchInput);
                }else{
                    //system.debug('**** CaseCommentTriggerHelper, notify, outbound Case Comment found');

                    postToChatter(caseComment, mapCaseIdToMemberIds.get(caseComment.Case__c));
                }
            }

            //T13 - to notify the tagged users.
            if('Submitted'.equals(caseComment.Status__c) && (caseCommentOld == null || caseComment.Status__c != caseCommentOld.Status__c) && 
                    String.isNotBlank(caseComment.Comment__c) && 
                    (caseComment.Tagged_User_1__c != null || caseComment.Tagged_User_2__c != null || caseComment.Tagged_User_3__c != null || 
                    caseComment.Tagged_User_4__c != null || caseComment.Tagged_User_5__c != null)) {
                Messaging.CustomNotification objBellNotification = new Messaging.CustomNotification();
                Set<String> setTaggedUsers = new Set<String>();

                //We prepare the reciepents.
                if(caseComment.Tagged_User_1__c != null) {
                    setTaggedUsers.add(caseComment.Tagged_User_1__c);
                }
                if(caseComment.Tagged_User_2__c != null) {
                    setTaggedUsers.add(caseComment.Tagged_User_2__c);
                }
                if(caseComment.Tagged_User_3__c != null) {
                    setTaggedUsers.add(caseComment.Tagged_User_3__c);
                }
                if(caseComment.Tagged_User_4__c != null) {
                    setTaggedUsers.add(caseComment.Tagged_User_4__c);
                }
                if(caseComment.Tagged_User_5__c != null) {
                    setTaggedUsers.add(caseComment.Tagged_User_5__c);
                }
                
                //Now we send the notification.
                if(!setTaggedUsers.isEmpty()) {
                    //We prepare the notification.
                    String productContent = '';
                    if(String.isNotEmpty(caseComment.Case_Product__c)){
                        productContent = caseComment.Case_Product__c + ', ';
                    }
            
                    String msgTitle = 'Case Comment Notification: ' + productContent + caseComment.Case_Priority__c 
                                            + ' Case ' + caseComment.Case_Number__c + ' for ' + caseComment.Support_Account_Name__c;
                    objBellNotification.setTitle(msgTitle);
                    objBellNotification.setBody('Comment: ' + caseComment.Comment_to_Search__c);
                    objBellNotification.setTargetId(caseComment.Case__c);
                    objBellNotification.setNotificationTypeId(notificationType.Id);
                    objBellNotification.send(setTaggedUsers);
                }
            }
        }

        //T11 - to post the chatter posts for inbound comment
        if(!Test.isRunningTest()){
            //system.debug('**** CaseCommentTriggerHelper, notify, lstBatchInput = ' + lstBatchInput);
            if(!lstBatchInput.isEmpty()){
                //system.debug('**** CaseCommentTriggerHelper, notify, posting the chatter post');
                ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
                for (ConnectApi.BatchResult batchResult : batchResults) {
                    if (batchResult.isSuccess()) {
                        // Operation was successful. 
                        // Print the header for each feed item.
                        ConnectApi.FeedItem aFeedItem;
                        if(batchResult.getResult() instanceof ConnectApi.FeedItem) {
                           aFeedItem = (ConnectApi.FeedItem) batchResult.getResult();
                        }
                        //System.debug('**** CaseCommentTriggerHelper, notify, SUCCESS');
                        //System.debug(aFeedItem.header.text);
                    }
                    else {
                        // Operation failed. Print errors.
                        System.debug('**** CaseCommentTriggerHelper, notify, FAILURE');
                        System.debug(batchResult.getErrorMessage());
                    }
                }
            }
        }

        NotificationService.notify(newList, oldMap);
    }

    //T11 - creates and returns a chatter post
    public static ConnectApi.FeedItemInput notifyCaseTeamOnInbound(Case cse, String caseComment){
        system.debug('**** CaseCommentTriggerHelper, notifyCaseTeamOnInbound, Case Comment = ' + caseComment);

        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }

        String content = 'Case Inbound Notification: ' + productContent + cse.Priority 
                                + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                + ', ' + cse.Support_Level__c;
                                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Comment', caseComment));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Owner / Team', cse.Owner_Name__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Summary', cse.Subject));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.GCS_Segment__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
        messageBodyInput.messageSegments.add(ChatterService.inputHyperlink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        Set<Id> setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, false, false, false);
        setUserIdToPost.remove(cse.OwnerId);
        system.debug('**** CaseCommentTriggerHelper, notifyCaseTeamOnInbound, setUserIdToPost = ' + setUserIdToPost);

        for(Id userId : setUserIdToPost){
            messageBodyInput.messageSegments.add(ChatterService.inputSpace());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(userId));    
        }
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = cse.Id;
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        system.debug('**** CaseCommentTriggerHelper, notifyCaseTeamOnInbound, feedItemInput = ' + feedItemInput);
        return feedItemInput;
    }
    
    private void postToChatter(Case_Comment__c caseComment, Set<Id> setUserId){
        
        System.debug('caseComment-->'+caseComment);
        System.debug('setUserId-->'+setUserId);
        
        ConnectApi.TextSegmentInput newLineInput = new ConnectApi.TextSegmentInput();    
        newLineInput.text = '\r\n';

        ConnectApi.TextSegmentInput contentInput = new ConnectApi.TextSegmentInput();
        contentInput.text = 'External communication on the Case ';
        
        ConnectApi.TextSegmentInput commentInput = new ConnectApi.TextSegmentInput();
        //Amarender - Adding Null check to avoid Null pointer exception.
        commentInput.text = caseComment.Comment__c != null ? caseComment.Comment__c.stripHtmlTags() : '';

        ConnectApi.EntityLinkSegmentInput caseLink = new ConnectApi.EntityLinkSegmentInput();
        caseLink.entityId = caseComment.Case__c;
        
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(contentInput);
        messageBodyInput.messageSegments.add(caseLink);
        messageBodyInput.messageSegments.add(newLineInput);
        messageBodyInput.messageSegments.add(newLineInput);
        messageBodyInput.messageSegments.add(commentInput);
        
        try{ 
            for(Id userId : setUserId){
                if(caseComment.LastModifiedById != userId){
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    feedItemInput.subjectId = userId;
                    feedItemInput.body = messageBodyInput;
            
                    ConnectApi.FeedElement feedElement;
                    if(!Test.isRunningTest()){
                        feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
                    }
                }
            }
         }
         catch(Exception e){
             System.debug('Exception in postToChatter method:'+e.getMessage()+':'+e.getLineNumber());
         }  
    }
    /*
     * @description: Post JIRA update if the comment is associated to zIssue 
     * @date: 10-April-2021
     * @param:  casecomments
     * @returns: N/A
     */
    @future(callout=true)
    public static void postJiraUpdate(String caseComments) {
      try{        
        Case_Comment__c cc = (Case_Comment__c)JSON.deserialize(caseComments, Case_Comment__c.class);
        String body = cc.Comment__c + Label.CaseComment_Jira;
        body = body.replaceAll('<[^>]+>',' '); 
        if(cc.Parent_Comment__c != null){
            Case_Comment__c parentcc = [Select Id,ZIssue__c from Case_Comment__c where Id = :cc.Parent_Comment__c];
              if(parentcc.ZIssue__c != null){
                zsfjira__ZIssue__c zc = [Select Id,Name from zsfjira__ZIssue__c  where Id = :parentcc.ZIssue__c LIMIT 1];            
                zsfjira.ZCBeans.IssueCommentResult result = zsfjira.ZC.Issues.createJIRAIssueComment(zc.Name,body);
              }
        } 
      }catch(Exception e){
          System.debug('Exception in postJiraUpdate method:'+e.getMessage()+':'+e.getLineNumber());
      }        
    }
    /*
     * @description: format the case record update list if the type was updated and the relavant condition matches
     * @date: 05-07-2021
     * Author: Deva
     * @param:  casecomments and old case comment map
     * @returns: Case Map
     */
    //</T04>
    public Map<Id,Case> updateCaseEscalationAttentionInfo(List<Case_Comment__c> caseComments,Map<Id,Case_Comment__c> oldCaseComments){
        Map<Id,Case> caseMaptoUpdate = new Map<Id,Case>();      
        Service_Cloud_General_Setting__mdt setObj=CaseCommentUtilities.getServiceCloudSettings(ESCALATION_ATTENTION_SETTING);
        for(Case_Comment__c ccNew: caseComments){
            if(oldCaseComments.get(ccNew.Id)!=null){
                Case_Comment__c ccOld = oldCaseComments.get(ccNew.Id);
                if(ccNew.Type__c  != ccOld.Type__c  && CaseCommentUtilities.evaluateCondition(ccNew, setObj.Filter_Condition__c)){
                    caseMaptoUpdate.put(ccNew.Case__c,new Case(Id=ccNew.Case__c,Escalation_Attention__c=true));
                }
            }            
        }   
        return caseMaptoUpdate;
    }
    //</T04>
     /*
     * @description:ONLY for Escalations when a Manager responds (Using the 'reply'), the Manager is added as the Escalation Manager in the case team
     * @date: 21-07-2021
     * Author: Deva
     * @param:  caseParentCommentMap with Parent Casecomment Id as key and  value wiill be it's corresponding case Id
     * @returns: n/a
     */
    //<T05>
    public void checkAndAddManagerToCaseTeam(Map<Id,Id> caseParentCommentMap){
        //Check if the current user have GCS_Manager permission enabled
        if(CaseCommentUtilities.isGCSManager()){
            //Query the child comments associated to parent 
            List<Case_Comment__c> childCaseComments = new List<Case_Comment__c >([SELECT Id, Is_Replied_To__c, Parent_Comment__c,Parent_Comment__r.Type__c,Type__c,Case__c,Case__r.OwnerId FROM Case_Comment__c where Parent_Comment__c IN :caseParentCommentMap.keySet() AND Case__c IN :caseParentCommentMap.values()]);
            //List to hold the Esacalation manager team member
            List<Case_Team__c> lstCaseTM = new List<Case_Team__c>();
            //This will ensure that manager should add when manager replied for the first time
            if(childCaseComments.size()==1){
                for(Case_Comment__c childCC:childCaseComments){
                    // If the case owner replies to the Escalation Comment, there will be no change in the case team role. 
                    //Case Owner will be still be in 'Case Owner' role in the case team
                    if( String.isnotBlank(childCC.Parent_Comment__r.Type__c) && childCC.Parent_Comment__r.Type__c.equals('Escalation') && childCC.Case__c != null && childCC.Case__r.OwnerId != UserInfo.getUserId()){    
                        //Create caseteammeber instance and add it to list                   
                        lstCaseTM.add(CaseTeamService.createMember(childCC.Case__c, UserInfo.getUserId(), CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER));
                    }                   
                } 
                //Check if the list is not empty and create records
                if(lstCaseTM.size()>0){
                    CaseTeamService.checkAndCreate(lstCaseTM);
                }              
            }            
        }
    }
    //<T05>
}