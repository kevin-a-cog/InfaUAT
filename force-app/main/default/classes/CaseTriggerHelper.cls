/*
@created by       : Venky K
@created on       : 11/01/2020
@Purpose          : Case handler helper class.
@Testclass        : 
@JIRA             : 
Change History
*******************************************************************************************************************
ModifiedBy      Date        Requested By        Description                                       Jira No.      Tag
Aishwarya Badri  12/07/20                       Weight calculation on Case                                      T01
Aishwary Badri   01/08/21   Shilpa              As soon as a Case is assigned to an Engineer,
                                                change the case status  to 'Assess' from 'New'.     I2RT-577    T02
Tejasvi Royal   20 Apr 2021                     Updating Product Case ID (Case Queue ID),
                                                whenever Product Queue is selected from Picklist.   I2RT-1827   T04 
Akhilesh        25 Apr 2021                     Queue ownered case, issue I2RT-1427                 I2RT-1427
Tejasvi Royal   29 Apr 2021                     Everytime a Technical Case is raised,  
                                                'Technical Case Count' field on Account increments. I2RT-2127   T05
Tejasvi Royal   7 May 2021                      Updating Case Owner Manager with Owner 'ManagerId'. I2RT-1966   T06
Akhilesh       18 May 2021                      Rewrite following methods                            I2RT-2760   @Akhilesh
                                                #1. setCaseTimezone
                                                #2. setBusinessHours
                                                #3. CalculateResolutionTargetDate
Akhilesh       03 June 2021                     Rewrite following methods                           I2RT-2993/   @Akhilesh
                                                #1. setBusinessHoursIndicatorFields                 I2RT-3004
Deva M         03 June 2021                     Created a new method which will push the            I2RT-2636    
                                                owner to custom case team table when owner updated                
Deva M         03 June 2021                     update Escalate open to true when case escalted     I2RT-2129    T07
Vignesh D      14 Sept 2021                     Case Support Add-on will refer Entitled Products    I2RT-4451    T08
                                                BCSP/XS 
Vignesh D      30 Sept 2021                     Add owner to CaseTeam only for cases assigned to    I2RT-4673    T09
                                                user on creation.
Venky K        14 Dec 2021                      Trigger weightage recalculation when IR/OGR/eOGR                 T10
                                                are due in 60 minutes.   
Piyush         15 Dec 2021                      update updateAaeEvent method for exception handling and SOQL query. T11

Sandeep duggi  23 jan 2021                      Trigger weightage recalculation when IR/OGR/eOGR                commented code enabled 
                                                are due in 60 minutes.
Vignesh D      04 Feb 2022                      Signature Select support level will take case       I2RT-5185    T12    
                                                timezone as the timezone of case primary contact  
Vignesh D      30-Mar-2022                      Open violated milestones should also be             I2RT-5650    T13
                                                considered while setting Next Milestone Date                     
Vignesh D      27-May-2022                      Populate Segment based on Case Segmentation         I2RT-6153    T14
                                                Criterias             
balajip        11-Jul-2022                      To process the Hypercare Case Creation 
                                                    notifcation subscription                        I2RT-6637    T15
balajip        13-Jul-2022                      To replace GCS_Segment__c field with Segment__c 
                                                    field in the notifications                      I2RT-6153    T16
balajip        22-Aug-2022                      Case Lite related changes                           I2RT-6867    T17 
Sandeep d      9-Sep-2022                       SF_Simple DI case weightages are not calculated     I2RT-7211    T18        
Sandeep Duggi  25-Oct-2022                      Regression_Multiple records fetched for case weightage for same case     I2RT-7288          T19                             
Sandeep Duggi  29-oct-2022                        SALT - Enhancement: Operations Case             I2RT-7260    T20
Vignesh D      08-Jan-2023                      Recalculate segmentation on after update when       I2RT-6778    T21
                                                record type or forecast product is changed
balajip        17-Jan-2023                      method updateCaseTeam - 
                                                  to add/remove Escalation Managers from Case Team  I2RT-7643    T23
balajip        31-Jan-2023                      cleanup and streamlining                            I2RT-7596    T24
balajip        06-Feb-2023                      method updateCaseWeightage - accounted for 
                                                  Record Type change scenario                       I2RT-7674    T25

Isha Bansal   17-Feb-2023                        updateCaseOwnerManager modified as per            I2RT-7747     T26
Shashikanth     07-Jul-2023                     Modified setSegment method to include              I2RT-8524     T27
                                                Case Segment Helper
Vignesh D      20-Sep-2023                      Replaced ServiceAppointmentId with 				 	I2RT-9063    T28
												Service_Appointment_AAE__c
Sandeep Duggi   Oct 17 '23                      P0 Flag - SALT enhancements                          I2RT-9219   T29

*******************************************************************************************************************
*/
public class CaseTriggerHelper {
    //<T01>
    
    public static globalApexManager apexManager = new globalApexManager(); 

    public static final Id RECORDTYPE_ID_TECHNICAL = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    public static final Id RECORDTYPE_ID_ADMIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
    public static final Id RECORDTYPE_ID_FULFILLMENT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();
    public static final Id RECORDTYPE_ID_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
    public static final Id RECORDTYPE_ID_ASKANEXPERT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();
    //T17
    public static final Id RECORDTYPE_ID_CASE_LITE = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Lite').getRecordTypeId();    
    
    public static final Set<String> SET_MILESTONE_NAMES = new Set<String>{
        'Initial Response',
        'Ongoing Response',
        'Engineer Ongoing Response',
        'Attention Request Response',
        'Escalation Response',
        'Target Service Restoration Response'
    };

    public void updateMilestoneFieldsOnCase(Map<Id, Case> triggerOldMap, Map<Id, Case> triggerNewMap){
        if(!system.isfuture()){
            updateCaseFromMilestones(triggerNewMap.keyset());
        }
    }

    //As soon as a Case is assigned to an Engineer, the case status changes to 'Assess' from 'New'.T02
    public void updateCaseStatus(Map<Id, Case> triggerOldMap, List<Case> triggerNew){
        apexManager.CreateLogs('CaseTriggerHelper - updateCaseStatus', 'CaseTriggerHelper - updateCaseStatus method start');
        map<String,String> mapCaseUpdatedStatus = new map<String,String>();

            set<Id> setCaseId = new Set<Id>();
            set<Id>setClosedCaseId = new set<Id>();
            
            for(Case c: triggerNew){
                //</T07> Deva : Start I2RT-2129
                if(triggerOldMap.get(c.id).IsEscalated != c.IsEscalated && c.IsEscalated){
                    c.Escalate_Open__c = true;
                }
                ////</T07> Deva : End  I2RT-2129
                if(c.status=='New' && triggerOldMap.get(c.id).OwnerId!=c.OwnerId)
                {
                    //Owner is changed from queue to user.
                    //T17 included Case Lite cases
                if((c.recordTypeId == RECORDTYPE_ID_OPERATIONS || c.recordTypeId == RECORDTYPE_ID_TECHNICAL || c.recordTypeId == RECORDTYPE_ID_FULFILLMENT || c.recordTypeId == RECORDTYPE_ID_ADMIN || c.recordTypeId == RECORDTYPE_ID_CASE_LITE) && String.valueOf(triggerOldMap.get(c.id).OwnerId).startsWith('00G') &&  String.valueOf(c.OwnerId).startsWith('005')){
                        c.Status='Assess';
                    }   
                } 
            apexManager.CreateLogs('CaseTriggerHelper - updateCaseStatus', 'updateCaseStatus, c.Status :' + c.Status);    
                if(c.Status =='Closed'){
                    setClosedCaseId.add(c.Id);
                }

                //T17 excluded Case Lite cases
                if((c.Status == 'Closed' || c.Status == 'Resolved') && c.status !=  triggerOldMap.get(c.id).status && c.RecordTypeId != RECORDTYPE_ID_CASE_LITE){
                    c.eOGR_in_Mins__c = 0;
                    mapCaseUpdatedStatus.put(c.Id,c.Status);
                    setCaseId.add(c.Id);
                    
                    if(c.IR_Completion_Date__c == null){
                       c.Status = triggerOldMap.get(c.Id).status;
                    }                    
                }

            //for aae 
            if(c.recordTypeId == RECORDTYPE_ID_ASKANEXPERT){
                    if(c.OwnerId != triggerOldMap.get(c.id).ownerId && String.valueof(c.OwnerId).startsWith('005')){
                      if(c.Status == 'Booked'){
                          c.Status = 'Scheduled';
                      }     
                   }
             }
            }
        apexManager.CreateLogs('CaseTriggerHelper - updateCaseStatus', 'updateCaseStatus, setCaseId :' + setCaseId);
        apexManager.CreateLogs('CaseTriggerHelper - updateCaseStatus', 'updateCaseStatus, setClosedCaseId :' + setClosedCaseId);
            closeAllCollabRequests(setClosedCaseId);

            if(setCaseId.size() > 0){
                list<CaseMileStone> lstCaseMS = [SELECT Id,CaseId,MilestoneType.Name 
                                            FROM CaseMilestone
                                        WHERE MilestoneType.Name In :SET_MILESTONE_NAMES
                                            And IsCompleted = false  
                                            And CompletionDate = null
                                            AND CaseId In :setCaseId];
                set<Id> setCaseIdWhereMileStoneFound = new set<Id>();
                for(CaseMileStone cms : lstCaseMS){
                    setCaseIdWhereMileStoneFound.add(cms.CaseId);
                }

                for(Case oCase: triggerNew){
                    if(setCaseId.contains(oCase.Id) && !setCaseIdWhereMileStoneFound.contains(oCase.Id)){
                        if(mapCaseUpdatedStatus.containsKey(oCase.Id)){
                          oCase.status = mapCaseUpdatedStatus.get(oCase.Id);
                        }
                    }
                }

                if(setCaseIdWhereMileStoneFound.size() > 0 ){
                    updateMilestone_Future(setCaseIdWhereMileStoneFound,mapCaseUpdatedStatus);
                }                            
            }
    }//</T02>
    
    public static void closeAllCollabRequests(Set<Id> setClosedCaseId){
        list<Raise_Hand__c> lstRH = [Select Id, Status__c From Raise_Hand__c 
                                        Where Status__c != 'Closed' And Case__c IN :setClosedCaseId];

        if(!lstRH.isEmpty()){
        for(Raise_Hand__c rh : lstRH){
          rh.Status__c = 'Closed';      
        }
    
            Database.SaveResult[] lstSaveResult = Database.update(lstRH, false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {                  
                        apexManager.CreateExceptionRecords('closeAllCollabRequests--> update of Raise Hand failed', err.getMessage(), saveResult.getId());
                    }
                }
        }
        }
    }

    @future
    public static void updateMilestone_Future(Set<Id> setCaseId,map<String,String> mapCaseUpdatedStatus){
        List<case> lstCaseToUpdate = new List<Case>();
        if(setCaseId.size() > 0){
            list<CaseMileStone> lstCaseMS = [SELECT Id,CaseId,MilestoneType.Name 
                                            FROM CaseMilestone
                                            WHERE MilestoneType.Name In :SET_MILESTONE_NAMES
                                            And IsCompleted = false  
                                            And CompletionDate = null
                                            AND CaseId In :setCaseId];
            apexManager.CreateLogs('CaseTriggerHelper - updateMilestone_Future', 'updateMilestone_Future, lstCaseMS :' + lstCaseMS);
            
            for(CaseMilestone cms : lstCaseMS){
                cms.CompletionDate = System.now();
            }
            
            if(lstCaseMS.size() > 0){
                Database.SaveResult[] lstSaveResult = Database.update(lstCaseMS, false);
                for (Database.SaveResult saveResult : lstSaveResult) {
                    if (!saveResult.isSuccess()){               
                        for(Database.Error err : saveResult.getErrors()) {                  
                            apexManager.CreateExceptionRecords('updateMilestone_Future --> update of Case Milestone failed', err.getMessage(), saveResult.getId());
                        }
                    }
                }
            }

            for(Id caseId: setCaseId){
                if(mapCaseUpdatedStatus.containsKey(caseId)){
                    Case oCase = new Case();
                    oCase.Id = caseId;
                    //oCase.IR_Completion_Date__c = system.now();                    
                    oCase.status = mapCaseUpdatedStatus.get(caseId);
                   
                    lstCaseToUpdate.add(oCase);
                }                
            }

            if(!lstCaseToUpdate.isEmpty()){
                Database.SaveResult[] lstSaveResult = Database.update(lstCaseToUpdate, false);
                for (Database.SaveResult saveResult : lstSaveResult) {
                    if (!saveResult.isSuccess()){               
                        for(Database.Error err : saveResult.getErrors()) {                  
                            apexManager.CreateExceptionRecords('updateMilestone_Future --> update of Case failed', err.getMessage(), saveResult.getId());
        }
    }
                }
            }
        }
    }

     @future
    public static void updateCaseFromMilestones(set<Id> caseIds){
        map<id,case> caseMap = new map<id,case>();
        for(CaseMilestone cm: [select id,caseId,TargetDate, MilestoneType.name,case.Attention_Target_Date__c,case.eOGR_Target_Date__c,case.OGR_Target_Date__c, case.Escalation_Target_Date__c, case.IR_Target_Date__c, case.Resolution_Target_DateTime__c, case.TSR_Target_Date__c, completionDate from caseMilestone where caseid in: caseIds and isviolated= false and completiondate = null]){
            if(cm.MilestoneType.name == 'Initial Response' && cm.case.IR_Target_Date__c != cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.IR_Target_Date__c = cm.TargetDate;
                caseMap.put(cm.caseID,c);
            }
            if(cm.MilestoneType.name == 'Ongoing Response' && cm.case.OGR_Target_Date__c!= cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.OGR_Target_Date__c = cm.TargetDate;
                caseMap.put(cm.caseId,c);            
            }
            if(cm.MilestoneType.name == 'Engineer Ongoing Response' && cm.case.eOGR_Target_Date__c != cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.eOGR_Target_Date__c = cm.TargetDate;
                caseMap.put(cm.caseId,c);
            }
            if(cm.MilestoneType.name == 'Attention Request Response' && cm.case.Attention_Target_Date__c != cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.Attention_Target_Date__c= cm.TargetDate;
                caseMap.put(cm.caseId,c);
            }
            if(cm.MilestoneType.name == 'Escalation Response' && cm.case.Escalation_Target_Date__c != cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.Escalation_Target_Date__c = cm.TargetDate;
                caseMap.put(cm.caseId,c);
            }
            if(cm.MilestoneType.name == 'Target Service Restoration Response' && cm.case.TSR_Target_Date__c != cm.TargetDate){
                case c = new case(id = cm.caseId);
                if(caseMap.containsKey(cm.caseId)){
                    c = caseMap.get(cm.caseId);
                }
                c.TSR_Target_Date__c = cm.TargetDate;
                caseMap.put(cm.caseId,c);
            }
        }
        if(caseMap.size() > 0){
            update caseMap.values();
            Database.SaveResult[] lstSaveResult = Database.update(caseMap.values(), false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {                  
                        apexManager.CreateExceptionRecords('updateCaseFromMilestones --> update of Case failed', err.getMessage(), saveResult.getId());
                    }
                }
            }
            //-----------------------------------------------------<T10>-----------------------            
            List<Id> caseidlist = new List<Id>(caseMap.keyset());
            apexManager.CreateLogs('CaseTriggerHelper - updateCaseFromMilestones', 'updateCaseFromMilestones, map values:'+caseMap.keyset());
            CaseWeightageHelper.updateWeightsNonFuture(caseidlist,new List<Id>(),new List<Id>(),'Case');
            //-----------------------------------------------------<End of T10>-----------------------
        }
    }

    public void checkAssignmentRules( List<Case> triggerNew)
    {
            List<Case> lstCases=new List<Case>();
            for(Case c: triggerNew )
            {
                if(c.Is_AssignmentRules__c)
                {
                    lstCases.add(new case(id = c.Id));
                }
            }
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        List<AssignmentRule> lstAssignmentRules = new List<AssignmentRule>();
        lstAssignmentRules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        if(!lstAssignmentRules.isEmpty()){
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = lstAssignmentRules[0].id;

            Database.SaveResult[] lstSaveResult = Database.update(lstCases, dmlOpts);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {                  
                        apexManager.CreateExceptionRecords('checkAssignmentRules --> update of Case failed', err.getMessage(), saveResult.getId());
                    }
                }
            }            
        }                
    }////</T03>
    
    ///Everytime a Technical Case is raised, 'Case Count' field on Support Account increments.
    //T05
    public void incrementTechnicalCaseCount(List<Case> triggerNew) {
        Set<Id> setAccountId = new Set<Id>(); // Set of Support Account IDs

        //T17
        Map<Id, Integer> mapOrgIdToCaseCount = new Map<Id, Integer>();

        for(Case c : triggerNew) {
            // IF: Case is a Technical Case and Support Account field is NOT NULL
            if(c.RecordTypeId == RECORDTYPE_ID_TECHNICAL && c.Support_Account__c <> NULL) { 
                setAccountId.add(c.Support_Account__c); // THEN: Add Support Account IDs to Set
            }
            //T17
            else if(c.RecordTypeId == RECORDTYPE_ID_CASE_LITE){
                Integer caseCount = 0;
                if(c.Org__c != null){
                    if(mapOrgIdToCaseCount.containsKey(c.Org__c)){
                        caseCount = mapOrgIdToCaseCount.get(c.Org__c);
                    }
                    mapOrgIdToCaseCount.put(c.Org__c, ++caseCount);
                }
            }
        }
            
        apexManager.CreateLogs('CaseTriggerHelper - incrementTechnicalCaseCount', 'incrementTechnicalCaseCount, setAccountId' + setAccountId);
        if(!setAccountId.isEmpty()) { // IF: Account IDs Set is NOT Empty
            List<Account> lstAccount = [SELECT Id, Number_of_Cases_Created__c, Success_Offering__c
                                          FROM Account 
                                          WHERE Id IN :setAccountId];  
            apexManager.CreateLogs('CaseTriggerHelper - incrementTechnicalCaseCount', 'incrementTechnicalCaseCount, lstAccount (pre increment) ' + lstAccount);

            if(!lstAccount.isEmpty()) { // IF: Account List (QUERY) NOT Empty
                for(Account a : lstAccount) {
                    a.Number_of_Cases_Created__c = (a.Number_of_Cases_Created__c == NULL) ? 1 : Integer.valueOf(a.Number_of_Cases_Created__c) + 1;
                }
                apexManager.CreateLogs('CaseTriggerHelper - incrementTechnicalCaseCount', 'incrementTechnicalCaseCount, lstAccount (post increment) ' + lstAccount);
            
                Database.SaveResult[] lstSaveResult = Database.update(lstAccount, false);
                for (Database.SaveResult saveResult : lstSaveResult) {
                    if (!saveResult.isSuccess()){               
                        for(Database.Error err : saveResult.getErrors()) {                  
                            apexManager.CreateExceptionRecords('incrementTechnicalCaseCount --> update of Account failed', err.getMessage(), saveResult.getId());
                        }
                    }
                }
            }            
            }
            
        //T17
        if(!mapOrgIdToCaseCount.keyset().isEmpty()){
            List<Org__c> lstOrgToUpdate = [Select Id, Number_of_Cases_Created__c From Org__c Where Id in :mapOrgIdToCaseCount.keyset()];
            for(Org__c org : lstOrgToUpdate){
                if(org.Number_of_Cases_Created__c != null){
                    org.Number_of_Cases_Created__c = org.Number_of_Cases_Created__c + mapOrgIdToCaseCount.get(org.Id);
                }else{
                    org.Number_of_Cases_Created__c = mapOrgIdToCaseCount.get(org.Id);
                }
            }
        
            if(!lstOrgToUpdate.isEmpty()){
                Database.SaveResult[] lstSaveResult = Database.update(lstOrgToUpdate, false);
                for (Database.SaveResult saveResult : lstSaveResult) {
                    if (!saveResult.isSuccess()){               
                        for(Database.Error err : saveResult.getErrors()) {                  
                            apexManager.CreateExceptionRecords('incrementTechnicalCaseCount --> update of Org failed', err.getMessage(), saveResult.getId());
                        }
                    }
                }    
            }
        }
    }//T05
    
    //Updating Case Owner Manager with Owner 'ManagerId'.
    //T06 . Modified via T26
    public void updateCaseOwnerManager(List<Case> triggerNew) { 
        Set<Id> initialCaseOwnerIdSet=new Set<Id>();//T26              
        for(Case c : triggerNew) { //T26
            initialCaseOwnerIdSet.add(c.OwnerId); 
        }       
         Map<Id,User> ownerIdToUserTypeMap=new Map<Id,User>([select Id,UserType ,ManagerId ,Manager.UserType from User where Id IN :initialCaseOwnerIdSet]); //T26       
        for(Case c : triggerNew) {            
            if(String.valueOf(c.OwnerId).startsWith('005') && ownerIdToUserTypeMap.containsKey(c.OwnerId) && ownerIdToUserTypeMap.get(c.OwnerId).UserType=='Standard' && ownerIdToUserTypeMap.get(c.OwnerId).ManagerId!=NULL && ownerIdToUserTypeMap.get(c.OwnerId).Manager.UserType=='Standard') { // T26 - added condition for standard user type to match the field level filter validation
                c.Case_Owner_Manager__c = (Id)ownerIdToUserTypeMap.get(c.OwnerId).ManagerId;                
            }
            else { // ELSE: OwnerId type is Queue
                c.Case_Owner_Manager__c = NULL; // THEN: Make 'Case Owner Manager' as NULL
            }
        } 
    }//T06 [Trigger Events: before insert, before update]
    
    public void setCaseTimezone(List <Case> lstCase) {
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, setCaseTimezone:' );
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, lstCase :' + lstCase);
        
        Set <Id> setSupportAccId = new Set <Id> ();
        Set <Id> setConId = new Set <Id> ();
        
        List <Case> lstBasicSuccessCase = new List <Case> ();
        List <Case> lstSignaturePremiumCase = new List <Case> ();
        
        for(Case c: lstCase) {
            //c.Case_Last_Activity__c = System.now(); //I2RT-4781

            apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, c.Success_Offering__c :' + c.Success_Offering__c);
            
            if(c.Success_Offering__c != null) {
                if(c.Success_Offering__c == 'Premium Success' || c.Success_Offering__c == 'Signature Success' || c.Success_Offering__c == 'Signature Select') { //<T12>
                    lstSignaturePremiumCase.add(c);
                    
                    apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, c.ContactId  :' + c.ContactId );
                }
                else if(c.Success_Offering__c == 'Basic Success' || c.Success_Offering__c == 'Standard') {
                    lstBasicSuccessCase.add(c); 
                }
                //T17
                if(c.ContactId != null) {
                    setConId.add(c.ContactId);
                }
                
                apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, c.Support_Account__c  :' + c.Support_Account__c );
                if(c.Support_Account__c != null) {
                    setSupportAccId.add(c.Support_Account__c);
                } 
            }
        }
        
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, lstBasicSuccessCase-->' + lstBasicSuccessCase);
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, lstSignaturePremiumCase-->' + lstSignaturePremiumCase);
        
        Map <Id, Contact> mapContact = new Map <Id, Contact> ([SELECT Id, TimeZone_Lookup__c 
                                                               FROM Contact 
                                                               WHERE Id IN :setConId 
                                                               AND TimeZone_Lookup__c != null]);
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, mapContact :' + mapContact);
        Map <Id, Account> mapAccount = new Map <Id, Account> ([SELECT Id, Timezone__c 
                                                               FROM Account 
                                                               WHERE Id IN :setSupportAccId 
                                                               AND Timezone__c != null]);
        apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, mapAccount :' + mapAccount);
            for(Case c: lstBasicSuccessCase) {
                if(c.Support_Account__c != null && mapAccount.containsKey(c.Support_Account__c)) {
                    c.Case_Timezone__c = mapAccount.get(c.Support_Account__c).timezone__c;
                //T17 - for Lite Cases, set the Contact Timezone
                }else if(c.RecordTypeId == RECORDTYPE_ID_CASE_LITE){
                    if(mapContact.containsKey(c.ContactId) && mapContact.get(c.ContactId).TimeZone_Lookup__c != null){
                        c.Case_Timezone__c = mapContact.get(c.ContactId).TimeZone_Lookup__c;
                    // set default timezone when Contact Timezone not available.
                    }else{
                        c.Case_Timezone__c = System.Label.Case_Lite_Default_Timezone_Id;
                }
                }else if(c.Is_Internal_Or_External_Case__c != 'Internal'){
                    c.addError('Case timezone is required.');
                }
            }
        
            for(Case c: lstSignaturePremiumCase) {
            apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, c.contactId-->' + c.contactId);
            apexManager.CreateLogs('CaseTriggerHelper - setCaseTimezone', 'setCaseTimezone, c.timezone__-->' + c.contact.TimeZone_Lookup__c);
                
                if(c.contactId != null && mapContact.containsKey(c.contactId)){         
                  c.Case_Timezone__c = mapContact.get(c.contactId).TimeZone_Lookup__c;                    
                }
                else if(c.Support_Account__c != null && mapAccount.containsKey(c.Support_Account__c)) {
                    c.Case_Timezone__c = mapAccount.get(c.Support_Account__c).timezone__c;
                }
                else if(c.Is_Internal_Or_External_Case__c != 'Internal'){
                    c.addError('Case timezone is required.');
                }
            }
        }
    
    public void setBusinessHours(List <Case> lstCase) {
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, lstCase :' + lstCase);
        Set <id> setEntitlementId = new Set <Id> ();
        Map <id, TimeZone__c> mapTimeZone = new Map <id, TimeZone__c> ([SELECT Id, TimeZoneSidKey__c 
                                                                        FROM TimeZone__c 
                                                                        WHERE TimeZoneSidKey__c != null
                                                                       ]); 
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, mapTimeZone :' + mapTimeZone);
        Set <String> setTimeZone = new Set <String> ();
        
        for(Case c: lstCase) {
            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, c.EntitlementId :' + c.EntitlementId);
            if(c.EntitlementId != null) {
                setEntitlementId.add(c.EntitlementId);
            }
            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, c.Case_Timezone__c :' + c.Case_Timezone__c);
            if(c.Case_Timezone__c != null) {
                if(mapTimeZone.containsKey(c.Case_Timezone__c)) {
                    apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, mapTimeZone.get(c.Case_Timezone__c).TimeZoneSidKey__c :' + mapTimeZone.get(c.Case_Timezone__c).TimeZoneSidKey__c);
                    setTimeZone.add(mapTimeZone.get(c.Case_Timezone__c).TimeZoneSidKey__c);
                }
            }
        }
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, setEntitlementId :' + setEntitlementId);
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, setTimeZone :' + setTimeZone);
        Map <Id, Entitlement> mapEntitlement = new Map <Id, Entitlement> ([SELECT Id, SlaProcessId, SlaProcess.Name
                                                                           FROM Entitlement
                                                                           WHERE SlaProcess.Name != null
                                                                           AND SlaProcess.isActive = true
                                                                           AND Id IN: setEntitlementId
                                                                          ]);
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, mapEntitlement :' + mapEntitlement);
        if(setTimeZone.size() > 0) {
            List <BusinessHours> lstBusinessHour = new List <BusinessHours> ();
            Map <String, String> mapBusinessHourTimeZoneKeyWiseId = new Map <String, String> ();
            List <BusinessHours> lstExistingBusinessHour = [SELECT Id, Name, TimeZoneSidKey
                                                            FROM BusinessHours
                                                            WHERE IsActive = TRUE
                                                            AND Name like '08x05%'
                                                            AND TimeZoneSidKey in :setTimeZone
                                                           ];
            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, lstExistingBusinessHour :' + lstExistingBusinessHour);
            
            for(BusinessHours bh: lstExistingBusinessHour) {
                mapBusinessHourTimeZoneKeyWiseId.put(bh.TimeZoneSidKey, bh.Id);
            }
            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, mapBusinessHourTimeZoneKeyWiseId :' + mapBusinessHourTimeZoneKeyWiseId);
            for(Case c: lstCase) {
                apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, c.EntitlementId :' + c.EntitlementId);
                TimeZone__c oTimeZone;
                Id businessHourId;
                if(c.EntitlementId != null || c.Record_Type_Name__c == 'Case Lite') { //T17
                    if(c.Case_Timezone__c != null) {
                        if(mapTimeZone.containsKey(c.Case_Timezone__c)){
                            oTimeZone = mapTimeZone.get(c.Case_Timezone__c);
                            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, oTimeZone :' + oTimeZone);
                            
                            if(mapBusinessHourTimeZoneKeyWiseId.containsKey(oTimeZone.TimeZoneSidKey__c)) {
                                
                                businessHourId = mapBusinessHourTimeZoneKeyWiseId.get(oTimeZone.TimeZoneSidKey__c);
                                apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, businessHourId :' + businessHourId);
                                
                                if(mapEntitlement.containsKey(c.EntitlementId)) {
                                    Entitlement oEntitlement = mapEntitlement.get(c.EntitlementId);
                                    apexManager.CreateLogs('CaseTriggerHelper - setBusinessHours', 'setBusinessHours, oEntitlement :' + oEntitlement);
                                }
                                c.BusinessHoursId = businessHourId;
                            }
                        }
                    }
                }
            }
        }
    }
             
    // NOTE: case.Business_Indicator_Text__c => underlying formula is updated as well
    public void setBusinessHoursIndicatorFields(List<Case> lstNewCases, Map<Id,Case> oldCaseMap, Boolean IsInsert, Boolean IsUpdate ){
        Set<Id> setBHId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        
        for(Case cs : lstNewCases){           
            if(cs.BusinessHoursId != null){
                if(IsUpdate && cs.BusinessHoursId != oldCaseMap.get(cs.Id).BusinessHoursId || IsInsert){
                    setBHId.add(cs.BusinessHoursId);
                    setCaseId.add(cs.Id);
                }
            }
            //set next milestone date
            dateTime nextMilestone = System.now().addDays(365);
            boolean activeMilestone = false;
            if(cs.IR_Target_Date__c != null /*& cs.IR_Target_Date__c > system.now()*/){ //<T13>
                nextMilestone = cs.IR_Target_Date__c;
                activeMilestone = true;
            }
            if(cs.eOGR_Target_Date__c!= null && nextMilestone > cs.eOGR_Target_Date__c ){
                nextMilestone = cs.eOGR_Target_Date__c ;
                activeMilestone = true;
            }
            if(cs.OGR_Target_Date__c != null && nextMilestone > cs.OGR_Target_Date__c){
                activeMilestone = true;
                nextMilestone =  cs.OGR_Target_Date__c;
            }
            if(cs.Attention_Target_Date__c!= null && nextMilestone > cs.Attention_Target_Date__c ){
                nextMilestone = cs.Attention_Target_Date__c ;
                activeMilestone = true;
            }
            if(cs.Escalation_Target_Date__c!= null && nextMilestone > cs.Escalation_Target_Date__c /*&& cs.Escalation_Target_Date__c > System.now()*/){ //<T13>
                nextMilestone = cs.Escalation_Target_Date__c;
                activeMilestone = true;
            }
            if(cs.TSR_Target_Date__c!= null && nextMilestone > cs.TSR_Target_Date__c ){
                nextMilestone = cs.TSR_Target_Date__c ;
                activeMilestone = true;
            }
            if(nextMilestone !=system.Now().addDays(365)){
                cs.next_milestone_date__c = nextMilestone;
            }
            if(activeMilestone == false /*|| cs.next_milestone_date__c < system.now()*/){ //<T13>
                cs.next_milestone_date__c = null;
            }
            apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, nextMilestone--->>>'+nextMilestone + '--cs.next_milestone_date__c-->'+ cs.next_milestone_date__c);
        }
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, setBHId :' + setBHId);
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, setCaseId :' + setCaseId);
        
        Map<Id,BusinessHours> mapBusinessHours = new Map<Id,BusinessHours>([Select Id, TimeZoneSidKey 
                                                            From BusinessHours 
                                                            Where Id IN: setBHId]);
        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, mapBusinessHours :' + mapBusinessHours);
        
        if(!setCaseId.IsEmpty()){
            for(Case cs : lstNewCases){
                if(setCaseId.contains(cs.Id)){          
                    if(mapBusinessHours.containsKey(cs.BusinessHoursId)){
                        BusinessHours bh = mapBusinessHours.get(cs.BusinessHoursId);
                        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, bh.TimeZoneSidKey :' + bh.TimeZoneSidKey);
                        
                        Timezone oTimezone = Timezone.getTimeZone(bh.TimeZoneSidKey);
                        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, oTimezone :' + oTimezone);
                        
                        cs.Hours_Offset__c = oTimezone.getOffset(System.Now())/3600000; // timezone offset hour
                        cs.Minutes_Offset__c = Math.mod(oTimezone.getOffset(System.Now()), 3600000)/60000; // timezone offset min 
                        
                        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, cs.Hours_Offset__c :' + cs.Hours_Offset__c);
                        apexManager.CreateLogs('CaseTriggerHelper - setBusinessHoursIndicatorFields', 'setBusinessHoursIndicatorFields, cs.Minutes_Offset__c :' + cs.Minutes_Offset__c);
                    }
                }                    
            }
        }
    }
    
    public  void calculateResolutionTargetDate(List<Case> lstNewCase,Map<Id, Case> caseNewMap){
        apexManager.CreateLogs('CaseTriggerHelper - calculateResolutionTargetDate', 'calculateResolutionTargetDate');
        
        DateTime caseResolutionDateTime;        
        Integer nDaysP1 = 4;
        Integer nDaysP2 = 8;
        Integer nDaysP3 = 15;       
        Integer nHrs = 8; //for all priorities and all success offering
        list<Case> lstCaseToUpdate = new list<Case>();
        
        for(Case cs : lstNewCase) {
            if(cs.CreatedDate != null ){
                caseResolutionDateTime = cs.CreatedDate;
            }
            else{
                caseResolutionDateTime = System.now();
            }
            apexManager.CreateLogs('CaseTriggerHelper - calculateResolutionTargetDate', 'calculateResolutionTargetDate, caseResolutionDateTime #1 :' + caseResolutionDateTime);
            
            if(cs.Success_Offering__c != null){
                if(cs.BusinessHoursId != null){
                    if(cs.Priority == 'P1') {
                        caseResolutionDateTime = BusinessHours.add(cs.BusinessHoursId,caseResolutionDateTime,(nDaysP1 * nHrs * 60 * 60 * 1000L)); 
                    }
                    else if(cs.Priority == 'P2') {
                        caseResolutionDateTime = BusinessHours.add(cs.BusinessHoursId,caseResolutionDateTime,(nDaysP2 * nHrs * 60 * 60 * 1000L)); 
                    }
                    else if(cs.Priority == 'P3') {
                        caseResolutionDateTime = BusinessHours.add(cs.BusinessHoursId,caseResolutionDateTime,(nDaysP3 * nHrs * 60 * 60 * 1000L)); 
                    }
                }
            }
            apexManager.CreateLogs('CaseTriggerHelper - calculateResolutionTargetDate', 'calculateResolutionTargetDate, caseResolutionDateTime #2 :' + caseResolutionDateTime);
            
            DateTime nextResolutionTargetDateTime = BusinessHours.nextStartDate(cs.BusinessHoursId,caseResolutionDateTime);
            apexManager.CreateLogs('CaseTriggerHelper - calculateResolutionTargetDate', 'calculateResolutionTargetDate, nextResolutionTargetDateTime :' + nextResolutionTargetDateTime);
            
            if(cs.Resolution_Target_DateTime__c != nextResolutionTargetDateTime){
                Case oCase = new Case();
                oCase.Id = cs.Id;
                oCase.Resolution_Target_DateTime__c = nextResolutionTargetDateTime;
                lstCaseToUpdate.add(oCase);
            }
        }
        apexManager.CreateLogs('CaseTriggerHelper - calculateResolutionTargetDate', 'calculateResolutionTargetDate, lstCaseToUpdate :' + lstCaseToUpdate);
        
        if(lstCaseToUpdate.size() > 0){
            Database.SaveResult[] lstSaveResult = Database.update(lstCaseToUpdate, false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {                  
                        apexManager.CreateExceptionRecords('calculateResolutionTargetDate --> update of Case failed', err.getMessage(), saveResult.getId());
                    }
                }
            }   
        }
    }
    
    public void setQueueName(List<Case> lstNewCases){
        apexManager.CreateLogs('CaseTriggerHelper - setQueueName', 'setQueueName, setQueueName entry--' + lstNewCases);
        for(Case cse : lstNewCases){
            apexManager.CreateLogs('CaseTriggerHelper - setQueueName', 'setQueueName, cse.Is_AssignmentRules__c = ' + cse.Is_AssignmentRules__c);
            apexManager.CreateLogs('CaseTriggerHelper - setQueueName', 'setQueueName, cse.OwnerId = ' + cse.OwnerId);
            apexManager.CreateLogs('CaseTriggerHelper - setQueueName', 'setQueueName, cse.status= ' + cse.status);
    
            if(cse.status!=null && cse.status=='New' && String.valueOf(cse.OwnerId).startsWith('00G') && cse.Is_AssignmentRules__c != null && cse.Is_AssignmentRules__c){
                apexManager.CreateLogs('CaseTriggerHelper - setQueueName', 'setQueueName, cse.OwnerId = ' + cse.OwnerId);
                cse.Original_Queue__c= cse.OwnerId;
            }
        }
    }
    
    /*
* @description: Create casecontacts if Case Contact does not exist from contactid on case 
* @date: 10-April-2021
* @param:  newmap
* @returns: N/A
*/
    public void validateCaseContacts(Map<Id, Case> newMap){
        try{
            List<Case_Contact__c> lstCaseContact = new List<Case_Contact__c>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> supportAccIds = new Set<Id>();
            Map<Id, Set<Id>> mapConIdToSetSupAccId = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> primaryContacts = new Map<Id, Set<Id>>();

            for(Case cse: [Select Id,ContactId,Support_Account__c,(Select Id,Contact__c from Case_Contacts__r) FROM Case where Id in :newMap.keyset()]){
                Boolean contactFound = false;
                for(Case_Contact__c caseContact: cse.Case_Contacts__r){
                    if(caseContact.Contact__c == cse.ContactId){
                        contactFound = true;
                    }
                }

                if(!contactFound){
                    Case_Contact__c caseContact = new Case_Contact__c();
                    caseContact.Contact__c = cse.ContactId;
                    caseContact.Case__c = cse.Id;
                    lstCaseContact.add(caseContact);
                    contactIds.add(cse.ContactId);
                    supportAccIds.add(cse.Support_Account__c);

                    if(mapConIdToSetSupAccId.containsKey(cse.ContactId)){
                        Set<Id> setSupAccId = mapConIdToSetSupAccId.get(cse.ContactId);
                        setSupAccId.add(cse.Support_Account__c);
                    }else{
                        mapConIdToSetSupAccId.put(cse.ContactId, new Set<Id>{cse.Support_Account__c});
                    }
                }
            }
            
            for(AccountContactRelation acr : [Select Id,ContactId,AccountId from AccountContactRelation where AccountId IN :supportAccIds and ContactId IN :contactIds and Primary__c = true]){
                if(primaryContacts.containsKey(acr.AccountId)){
                    Set<Id> setContactId = primaryContacts.get(acr.AccountId);
                    setContactId.add(acr.ContactId);
                }else{
                    primaryContacts.put(acr.AccountId, new Set<Id>{acr.ContactId});
                }
            }
            
            for(Case_Contact__c caseContact : lstCaseContact){
                if(mapConIdToSetSupAccId.containsKey(caseContact.Contact__c) && mapConIdToSetSupAccId.get(caseContact.Contact__c).size()>0){
                    for(Id accId : mapConIdToSetSupAccId.get(caseContact.Contact__c)){
                        if(primaryContacts.containsKey(accId)){
                            caseContact.Primary__c = true;
                            break;
                        }
                    }
                }
            }
            
            if(lstCaseContact.size() > 0){
                Database.SaveResult[] lstSaveResult = Database.insert(lstCaseContact, false);
                for (Database.SaveResult saveResult : lstSaveResult) {
                    if (!saveResult.isSuccess()){               
                        for(Database.Error err : saveResult.getErrors()) {
                            apexManager.CreateExceptionRecords('validateCaseContacts --> insert of Case Contact failed', err.getMessage(), saveResult.getId());
            }
        }
                }
            }
        }catch(Exception e){
            apexManager.CreateExceptionRecords('===== Error in validateCaseContacts: ', e.getMessage(), null); 
        }
    }
    
    public void notify(List<Case> newList, Map<Id, Case> oldMap){
        List<Id> lstCaseIdOwnerChange = new List<Id>();
        List<Id> lstCaseIdEngagement = new List<Id>();
        Set<Id> setEngagementId = new Set<Id>();
        for (Case cse : newList){
            Case cseOld;
            if(oldMap != null){
                cseOld = oldMap.get(cse.Id);

                if(cseOld.OwnerId != cse.OwnerId && 'User'.equals(cse.OwnerId.getSobjectType().getDescribe().getName())){
                    lstCaseIdOwnerChange.add(cse.Id);
                }

                if(cseOld.Engagement__c != cse.Engagement__c && cse.Engagement__c != null){
                    lstCaseIdEngagement.add(cse.Id);
                    setEngagementId.add(cse.Engagement__c);
                }
            }
        }

        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([
            Select Id, CaseNumber, Subject, IsEscalated,  Forecast_Product__c, Support_Account__c,
                    AccountId, OwnerId, Owner_Name__c, Engagement__c, Engagement__r.Status__c, Attention_Request__c,
                    Priority, Support_Level__c, Version__c, Segment__c, Acc__c,
                    Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                    Account.Name, Account.New_Org_Account_Number__c 
                From Case 
                Where Id in :lstCaseIdOwnerChange Or Id in :lstCaseIdEngagement
        ]);

        List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
        for (Id caseId : lstCaseIdOwnerChange){
            Case cse = mapCaseIdToCase.get(caseId);
            ConnectApi.FeedItemInput feedItemInput = CaseService.notifyCaseTeamCaseUpdate(cse, 'Case Assignment');
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            lstBatchInput.add(batchInput);
        }

        Map<Id, Engagement__c> mapEngagementIdToEngagement = new Map<Id, Engagement__c>();
        if(!setEngagementId.isEmpty()){
            mapEngagementIdToEngagement = new Map<Id, Engagement__c>([
                Select Id, Name, Engagement_Number__c, Title__c, Severity__c From Engagement__C Where Id in :setEngagementId
            ]);
        }

        List<Case_Escalation__c> lstCaseEscalation = new List<Case_Escalation__c>();
        for (Id caseId : lstCaseIdEngagement){
            Case cse = mapCaseIdToCase.get(caseId);

            Case_Escalation__c caseEscalation = new Case_Escalation__c();
            caseEscalation.Case__c = cse.Id;
            caseEscalation.Escalation__c = cse.Engagement__c;
            lstCaseEscalation.add(caseEscalation);

            ConnectApi.FeedItemInput feedItemInput = EngagementService.notifyCaseTeam(cse, mapEngagementIdToEngagement.get(cse.Engagement__c), 'New Escalation');
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            lstBatchInput.add(batchInput);
        }

        if(!lstCaseEscalation.isEmpty()){
            Database.SaveResult[] lstSaveResult = Database.Insert(lstCaseEscalation, false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {
                        apexManager.CreateExceptionRecords('notify --> insert of Case Escalation failed', err.getMessage(), saveResult.getId());
                    }
                }
            }
        }
        
        if(!Test.isRunningTest()){
            if(!lstBatchInput.isEmpty()){
               ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
            }
        }

        NotificationService.notify(newList, oldMap);
    }

    /*
    * Set Incident Summary from case closing notes
    * @param messagecontent - Message to be sent
    * @return return - void
    * @throws exception - NA
    */
    public  void caseUpdates    (List<Case> newList, Map<Id, Case> oldMap){
     try {  
        String outageid;
        Case c = newList[0];    
         
        if(!string.isblank(c.Closing_Notes__c) && c.Closing_Notes__c != oldMap.get(c.Id).Closing_Notes__c && !system.isBatch() && !system.isFuture()){
            for(Case_Incident__c ci : [Select Id,Incident__r.Incident_Id__c from Case_incident__c where Case__c = :c.Id and primary__c = true]){
                outageid = ci.Incident__r.Incident_Id__c;
            }
            if(!string.isblank(outageid)){
                GetInfoPanoptaAPI.setIncidentSummary(outageid,c.Closing_Notes__c,c.ownerid);
            }
        }
        } catch( System.Exception e) {  
            apexManager.CreateExceptionRecords('Caseupdate', 'Exception in caseUpdates in casetriggerhelper',e.getMessage()+':'+e.getLineNumber()); 
     }  
    }
    
    /*
    * Populate case weightage
    * @param NewMap, OldMap
    * @return return - void
    * @throws exception - NA
    */
    //T25 - rewrote the method and accounted for missing Case Weightage and Record Type change scenarios
    public void updateCaseWeightage(List<Case> triggerNew, Map<Id, Case> triggerOldMap){
        List<Id> setCaseIdForRecalculation = new List<Id>();
        List<Id> setProjectIdForRecalculation = new List<Id>();
        List<Id> setAccountIdForRecalculation = new List<Id>();

        List<Case_Weightage__c> lstCaseWeightageToInsert = new List<Case_Weightage__c>();
 
        Map<Id, Id> mapCaseIdToCaseWeightageId = new Map<Id, Id>();
        for(Case_Weightage__c caseWeightage : [Select Id, Case__c From Case_Weightage__c 
                                                                Where Case__c in :triggerOldMap.keySet()]){
            mapCaseIdToCaseWeightageId.put(caseWeightage.Case__c, caseWeightage.Id);
        }
                
        for(Case cs : triggerNew){
               // ---------------------------------------<T10>----------------------------
                Datetime tempirtime = system.now();  
                Decimal tempdate;
                Boolean recalculatesalt = false;
                
                if(cs.OGR_Target_Date__c != null){                                      
                    tempdate = integer.valueof(system.now().gettime() - cs.OGR_Target_Date__c.gettime())/(1000*60);
                    if(tempdate <= 60){
                    setCaseIdForRecalculation.add(cs.Id);
                    }
                }
                if(cs.IR_Target_Date__c != null){                                      
                    tempdate = integer.valueof(system.now().gettime() - cs.IR_Target_Date__c.gettime())/(1000*60);
                    if(tempdate <= 60){
                    setCaseIdForRecalculation.add(cs.Id);
                    }
                }
                if(cs.eOGR_Target_Date__c != null){                                      
                    tempdate = integer.valueof(system.now().gettime() - cs.eOGR_Target_Date__c.gettime())/(1000*60);
                    if(tempdate <= 60){
                    setCaseIdForRecalculation.add(cs.Id);
                }
            }               
            //---------------------------------------<T10>----------------------------

            Boolean doRecalculation = false;
            if(cs.RecordTypeId == RECORDTYPE_ID_TECHNICAL || cs.RecordTypeId == RECORDTYPE_ID_CASE_LITE || cs.RecordTypeId == RECORDTYPE_ID_OPERATIONS){
                if(cs.Case_Weightage__c == null){
                    doRecalculation = true;

                    if(!mapCaseIdToCaseWeightageId.containsKey(cs.Id)){
                        Case_Weightage__c caseWeightage = new Case_Weightage__c();
                        caseWeightage.Case__c = cs.Id;
                        caseWeightage.Account__c = cs.AccountId;
                        caseWeightage.Name = '0%';
                        caseWeightage.Business_Hours_Total__c = cs.Business_Hours_Total__c;
                        caseWeightage.Business_Hours_Total_2__c = cs.Business_Hours_Total_2__c;
                        caseWeightage.Minutes_Offset__c = cs.Minutes_Offset__c;
                        caseWeightage.Hours_Offset__c = cs.Hours_Offset__c;
                        lstCaseWeightageToInsert.add(caseWeightage);
                    }
                }
                //T29 modified if condition with P0 flag
                if(!System.isFuture() && !System.isScheduled() && !System.isBatch()){
                    doRecalculation = true;
                }else if(triggerOldMap != null && triggerOldMap.containsKey(cs.Id)){
                    Case oldCs = triggerOldMap.get(cs.Id); 
                    if((cs.IsEscalated != oldCs.IsEscalated) ||  
                     (cs.Case_InActive__c != oldCs.Case_InActive__c) || 
                     (cs.Is_Reopened__c != oldCs.Is_Reopened__c) ||                                            
                     (cs.Case_Timezone__c != oldCs.Case_Timezone__c) || 
                     (cs.Next_Action__c != oldCs.Next_Action__c) ||
                     (cs.Case_Support_Add_On__c != oldCs.Case_Support_Add_On__c) ||                     
                     (cs.Priority != oldCs.Priority) ||                     
                     (cs.Business_Hours_Total_2__c != oldCs.Business_Hours_Total_2__c) || 
                     (cs.Business_Hours_Total__c != oldCs.Business_Hours_Total__c) ||
                     (cs.Attention_Request__c != oldCs.Attention_Request__c) || 
                     (cs.Engagement__c != oldCs.Engagement__c) ||                     
                     (cs.OwnerId != oldCs.OwnerId) ||                     
                     (cs.RecordTypeId != oldCs.RecordTypeId) ||
                     (cs.P0_Enabled_By__c !=oldCs.P0_Enabled_By__c)
                        ){

                        doRecalculation = true;
                    }
                }                
            
                if(doRecalculation){
                    setCaseIdForRecalculation.add(cs.Id);
                    If(cs.Support_Account__c != null){
                        setProjectIdForRecalculation.add(cs.Support_Account__c); 
                    }
                    setAccountIdForRecalculation.add(cs.AccountId);    
                }
            }
        } 
        
        if(!lstCaseWeightageToInsert.IsEmpty()){
            Database.SaveResult[] lstSaveResult = Database.Insert(lstCaseWeightageToInsert, false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {
                        apexManager.CreateExceptionRecords('updateCaseWeightage --> insert of Case Weightage failed', err.getMessage(), saveResult.getId());
                    }
                }
            }
        }

        if(!setCaseIdForRecalculation.IsEmpty()){
            if(System.isFuture() || System.isScheduled() || System.isBatch()){
                CaseWeightageHelper.updateWeightsNonFuture(setCaseIdForRecalculation, setProjectIdForRecalculation, setAccountIdForRecalculation, 'Case');
            }else{
                CaseWeightageHelper.updateWeights(setCaseIdForRecalculation, setProjectIdForRecalculation, setAccountIdForRecalculation, 'Case');
            }
        }
    }
    
    //Set case fields before insert
    public void setCaseFields(List<Case> lstCase) {
        Set<Id> supportAccIds = new Set<Id>();
        Set<Id> contactids = new Set<Id>();
        Set<Id> setSourceCaseId = new Set<Id>();//I2RT-3924
        Set<Id> entitledProductIds = new Set<Id>();
        Map<Id, Entitled_Product__c> entitledProducts = new Map<Id, Entitled_Product__c>(); //</T08>

        for(Case c : lstCase){
            if(c.Support_Account__c != null){
                supportAccIds.add(c.Support_Account__c);
            }
            if(c.ContactId != null){
                contactids.add(c.ContactId);
            }
            if(String.isNotEmpty(c?.Entitled_Product__c)){
                entitledProductIds.add(c.Entitled_Product__c);
            }
            //I2RT-3924
            if(c.isClone()){
                setSourceCaseId.add(c.getCloneSourceId());
            }
        }

        apexManager.CreateLogs('CaseTriggerHelper - setCaseFields', 'setCaseFields.. setSourceCaseId = ' + setSourceCaseId);

        Map<Id, Account> supportAccounts = new Map<Id, Account>([Select Id,Support_Add_On__c,Success_Offering__c,Entitlement__c from Account where Id IN :supportAccIds]);
        Map<Id, Contact> casecontacts = new Map<Id, Contact>([Select Id,Salutation from Contact where Id IN :contactids]);  
        if(entitledProductIds.size() > 0){
            entitledProducts = new Map<Id, Entitled_Product__c>([Select Id,Name,Business_Critical_Success_Plan__c,Extended_Support__c from Entitled_Product__c where Id IN :entitledProductIds]);
        }
        //I2RT-3924
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, CaseNumber, Next_Action__c From Case Where Id in :setSourceCaseId]);

        for(Case c : lstCase){
            //I2RT-3924
            if(c.isClone()){
                Case sourceCase = mapCaseIdToCase.get(c.getCloneSourceId());
                apexManager.CreateLogs('CaseTriggerHelper - setCaseFields', 'setCaseFields.. sourceCase = ' + sourceCase);

                Set<Id> setRecordTypeId = new Set<Id>{RECORDTYPE_ID_TECHNICAL, RECORDTYPE_ID_ADMIN, RECORDTYPE_ID_OPERATIONS, RECORDTYPE_ID_FULFILLMENT};
                if(setRecordTypeId.contains(c.RecordTypeId)){
                    c.Status = 'New';
                }
                
                c.Cloned_From__c = sourceCase.Id;
                c.Cloned_From_Case_Number__c = sourceCase.CaseNumber;
                c.Next_Action__c = sourceCase.Next_Action__c;
            }

            if(c.Support_Account__c != null){
                //c.Case_Support_Add_On__c = supportAccounts.get(c.Support_Account__c)?.Support_Add_On__c; //</T08>
                c.Success_Offering__c = supportAccounts.get(c.Support_Account__c)?.Success_Offering__c;
                
                //I2RT-3924
                if(c.EntitlementId == null){
                    c.EntitlementId = supportAccounts.get(c.Support_Account__c)?.Entitlement__c;
                }

                if(c.Origin == null){c.Origin = 'Web';} 
            }
            //T17 for Case Lite cases, set the Success Offering as Basic Success
            else if(c.RecordTypeId == RECORDTYPE_ID_CASE_LITE){
                c.Success_Offering__c = 'Basic Success';
            }
            if(c.ContactId != null){
                c.Contact_Salutation__c = casecontacts.get(c.ContactId).Salutation;
            }
            //<T08>
            if(String.isNotEmpty(c?.Entitled_Product__c)){
                Boolean BCSP = entitledProducts?.get(c.Entitled_Product__c)?.Business_Critical_Success_Plan__C ? true : false;
                Boolean XS = entitledProducts?.get(c.Entitled_Product__c)?.Extended_Support__c ? true : false;
                c.Case_Support_Add_On__c = BCSP ? 'BCSP' : XS ? 'XS' : '';
            }
            //</T08>
        } 
    }

    /*
     * @description : [I2RT-26360] - Push the owner to case team when user accepted the case and this will be called after update
     * @date        : 08-07-2021
     * Author       : Deva
     * @param       : casecomments and old case comment map
     * @returns     : none
     */
    //I2RT-4175 - method rewritten
    public void updateCaseTeam( List<Case> triggerNew, Map<Id, Case> triggerOldMap){
        List<Case_Team__c> lstCaseTeamToUpsert = new List<Case_Team__c>();
        List<Case_Team__c> lstCaseTeamToDelete = new List<Case_Team__c>();

        Set<Id> setEngagementId = new Set<Id>(); //T23
        Set<Id> setCaseIdRemoved = new Set<Id>(); //T23

        //Check if the old map is not null
        for(Case newRec: triggerNew){
            apexManager.CreateLogs('CaseTriggerHelper - updateCaseTeam', 'updateCaseTeam.. new owner = ' + newRec.OwnerId);
            Id oldOwnerId;
            Id oldEngagementId;
            if(triggerOldMap != null){                
                Case oldRec = triggerOldMap.get(newRec.Id);
                oldOwnerId = oldRec.OwnerId;
                apexManager.CreateLogs('CaseTriggerHelper - updateCaseTeam', 'updateCaseTeam.. old owner = ' + oldOwnerId);
                oldEngagementId = oldRec.Engagement__c;
            }                
            if((oldOwnerId == null && !newRec.Is_AssignmentRules__c) || ((newRec.OwnerId != oldOwnerId) && oldOwnerId != null)){ //</T09>
                CaseTeamService.CaseTeam caseTeam = CaseTeamService.changeOwner(newRec.Id, oldOwnerId, newRec.OwnerId);
                lstCaseTeamToUpsert.addAll(caseTeam.lstToUpsert);
                lstCaseTeamToDelete.addAll(caseTeam.lstToDelete);
            }

            //T23 - get the list of Engagement Ids that have been updated.
            if(newRec.Status !='Closed' && oldEngagementId != newRec.Engagement__c){
                if(newRec.Engagement__c == null){
                    setCaseIdRemoved.add(newRec.Id);
                }else{
                setEngagementId.add(newRec.Engagement__c);
            }
        }
        }

        //upsert the records
        if(!lstCaseTeamToUpsert.isEmpty()){
            Database.UpsertResult[] lstUpsertResult = Database.upsert(lstCaseTeamToUpsert, false);
            for (Database.UpsertResult upsertResult : lstUpsertResult) {
                if (!upsertResult.isSuccess()){               
                    for(Database.Error err : upsertResult.getErrors()) {
                        apexManager.CreateExceptionRecords('updateCaseTeam --> upsert of Case Team failed', err.getMessage(), upsertResult.getId());
                    }
                }
            }
        }

        //delete the records
        if(!lstCaseTeamToDelete.isEmpty()){
            Database.DeleteResult[] lstDeleteResult = Database.delete(lstCaseTeamToDelete);
            for (Database.DeleteResult deleteResult : lstDeleteResult) {
                if (!deleteResult.isSuccess()){
                    for(Database.Error err : deleteResult.getErrors()) {          
                        apexManager.CreateExceptionRecords('updateCaseTeam --> delete of Case Team failed', err.getMessage(), deleteResult.getId());
                    }
                }
            }
        }

        //T23 update the Escalation Manager in the Case Team.
        if(!setEngagementId.isEmpty() || !setCaseIdRemoved.isEmpty()){
            List<String> lstClosedStatus = new List<String>{'Closed', 'Closed Duplicate'};
            Map<Id, Engagement__c> mapEngIdToEng = new Map<Id, Engagement__c>([Select Id, OwnerId, Status__c From Engagement__c 
                                                        Where Id in :setEngagementId Or Id in :setCaseIdRemoved]);
            
            Map<Id, Id> mapEngIdToOwnerIdToAdd = new Map<Id, Id>();
            for(Id engId : setEngagementId){
                Engagement__c eng = mapEngIdToEng.get(engId); 
                if(eng.OwnerId.getSObjectType() == User.SObjectType && !lstClosedStatus.contains(eng.Status__c)){
                    mapEngIdToOwnerIdToAdd.put(eng.Id, eng.OwnerId);
                }
            }
            CaseTeamService.updateEscalationManager(mapEngIdToOwnerIdToAdd, new Set<Id>(), setCaseIdRemoved);
        }
    }
     
    /*
     * @description : update Ask an expert case event on owner change [lightning scheduler]
     * @date        : 01-13-2021
     * Author       : Piyush
     * @param       : old and new values 
     * @returns     : none
     */
    public void updateAaeEvent( List<Case> triggerNew, Map<Id, Case> triggerOldMap){
        list<EventRelation> lstEventRelation  = new list<EventRelation>(); 
        list<event> lstEvent = new list<event>(); 
       try{
        list<string> caseIds = new list<string>();
        map<string,string> mapCaseIdWiseOwnerId = new map<string,string>();        
        map<string,string> mapcontactid = new map<string,string>();
        Set<Id> forwardset = new Set<Id>();
        Id ownerid; 
        
        for(case cs : triggerNew){
                if(cs.OwnerId != triggerOldMap.get(cs.id).ownerId && String.valueof(cs.OwnerId).startsWith('005') && cs.recordTypeId == RECORDTYPE_ID_ASKANEXPERT){
                  caseIds.add(cs.id);
                  mapCaseIdWiseOwnerId.put(cs.id, cs.ownerId);
               if(cs.contactId != null){
                   mapcontactid.put(cs.Id,cs.contactId);
               }
               //Add cases to a set if previous owner is user and not queue 
               if(String.valueof(triggerOldMap.get(cs.Id)?.ownerId).startsWith('005')){
                    forwardset.add(cs.Id);
               }
                ownerid = cs.ownerid;
           }
        }
        
        Map<Id,Event> eventmap  = new Map<Id,Event>();
        Map<Id,Event> forwardmap  = new Map<Id,Event>();
        Set<Id> errelationset = new Set<Id>();
        for(event evt : [select id,subject,Description,Service_Appointment_AAE__c,whatId,Location,ownerid,StartDateTime,DurationInMinutes,
                         Zoom_Dial_Information__c,Zoom_Meeting_Id__c,Zoom_H323_Password__c,Zoom_Meeting_Password__c 
                         From event 
                         where whatId IN: caseIds AND 
                         Service_Appointment_AAE__c != null and IsChild = false]){ //<T11> //<T28>
                if(!forwardset.contains(evt.whatId)){
              eventmap.put(evt.Id,evt);   
                }
                else{
              forwardmap.put(evt.Id,evt);
        }
            }
        
        for(EventRelation er: [Select Id,RelationId from EventRelation where eventid in :eventmap.keyset()]){
            errelationset.add(er.RelationId);
        }
        
        for(Event oEvt : eventmap.values()){
            if(mapCaseIdWiseOwnerId.containsKey(oEvt.whatId)){
                /*EventRelation oEventRelation = new EventRelation();
                oEventRelation.RelationId = mapCaseIdWiseOwnerId.get(oEvt.whatId);
                oEventRelation.EventId = oEvt.Id;
                lstEventRelation.add(oEventRelation);*/
                oEvt.Location = '';
                oEvt.Generate_Zoom_Meeting__c = true;
                oEvt.Description = triggerOldMap.get(oEvt.whatId).Description;
                oEvt.ownerid =       mapCaseIdWiseOwnerId.get(oEvt.whatId);      
                oEvt.Subject = triggerOldMap.get(oEvt.whatId).Forecast_Product__c + ':New Ask An Expert Request - ' + triggerOldMap.get(oEvt.whatId).Casenumber;
                lstEvent.add(oEvt);
                if(!errelationset.contains(mapcontactid.get(oEvt.whatId))){
                    EventRelation oEventRelation2 = new EventRelation();
                    oEventRelation2.RelationId = mapcontactid.get(oEvt.whatId);
                    oEventRelation2.EventId = oEvt.Id;
                    lstEventRelation.add(oEventRelation2);    
                }                
            }
        }
        
        for(Event fevent: forwardmap.values()){
            if(ownerid != null){                
                GlobalZoomUtilitiesClass.forwardinvite(fevent,ownerid); 
            }
        }
        
   //<T11>
            if(lstEventRelation.size() > 0){
                insert lstEventRelation; 
            }
            if(lstEvent.size() > 0){
               update lstEvent;
            }          
        }catch(DmlException ex){
        if(lstEventRelation.size() > 0){
            CaseControllerWithoutSharing.updateEventRelation(lstEventRelation); 
        }

        if(lstEvent.size() > 0){
            CaseControllerWithoutSharing.updateEvent(lstEvent); 
        }
        }catch(Exception e){ 
            apexManager.CreateExceptionRecords('CaseTriggerHelper.updateAaeEvent', 'Exception in accepting case: ', e.getMessage());
      }
//</T11>
    }

    //I2RT-4787
    //To close any open FSM Collab Requests when monitoring ends.
    public void monitoringDisabled(List<Case> newList, Map<Id, Case> oldMap){
        List<Case> lstCaseToCloseFSMCollab = new List<Case>();//I2RT-4787
        for (Case cse : newList){
            Case cseOld;
            if(oldMap != null){
                cseOld = oldMap.get(cse.Id);
                if(cseOld.Monitoring_Enabled__c && !cse.Monitoring_Enabled__c){
                    lstCaseToCloseFSMCollab.add(cse);
                }
            }
        }

        if(!lstCaseToCloseFSMCollab.isEmpty()){
            WeekendHoliday_Support_CloseFSMCollabs.collabClosureHandler_FSM(lstCaseToCloseFSMCollab);
        }
    }

    //---------------------------------------<T14>------------------------------
    /**
    * this method populates Segment on Case.
    * @param lstCases
    * @return return-void
    * @throws exception - NA
    */
    public void setSegment(List<Case> lstCases, Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate){ //<T21>
        try{
            List<Case> lstCaseToUpdate = new List<Case>();
            Set<Id> setRecordTypeToRecalculateSegmentation = new Set<Id>{RECORDTYPE_ID_TECHNICAL, RECORDTYPE_ID_OPERATIONS}; //<T21>

            //T15
            List<Case> lstCasesToNotify = new List<Case>();
            Map<Id, Case> newMapToNotify = new Map<Id, Case>();
            CaseSegmentHelper csHelper = null;

            for(Case objCase : lstCases){
                
                Case objCaseUpdated = new Case(Id = objCase.Id);
                Case objCaseOld = oldMap?.get(objCase.Id); //<T21>

                //Populate Segment only for Technical and Operations case
                if(IsAfter && setRecordTypeToRecalculateSegmentation.contains(objCase.RecordTypeId) && (IsInsert || (IsUpdate && (objCaseOld?.RecordTypeId != objCase.RecordTypeId || objCaseOld.Forecast_Product__c != objCase.Forecast_Product__c)))){ //<T21>
                    if(csHelper == null)
                    {
                        csHelper = new CaseSegmentHelper(lstCases);
                    }

                    objCaseUpdated = csHelper.getCaseSegmentDetails(objCase);       //<T27>
                    lstCaseToUpdate.add(objCaseUpdated);
                }
                else if(IsAfter && !setRecordTypeToRecalculateSegmentation.contains(objCase.RecordTypeId) && (IsInsert || (IsUpdate && (objCaseOld?.RecordTypeId != objCase.RecordTypeId || objCaseOld.Forecast_Product__c != objCase.Forecast_Product__c)))){ //<T21>
                    if(String.isNotBlank(objCase.Segment__c)){
                        objCaseUpdated.Segment__c = null;
                        objCaseUpdated.Segment_Period_Flag__c = null;
                        lstCaseToUpdate.add(objCaseUpdated);
                    }
                }

                //T15
                if('Hypercare'.equals(objCaseUpdated.Segment__c) && lstCaseToUpdate.contains(objCaseUpdated)){ //<T21>
                    lstCasesToNotify.add(objCaseUpdated); //<T21>
                    newMapToNotify.put(objCase.Id, objCase);
                }
            }

            if(!lstCaseToUpdate.isEmpty()){
                try{
                    List<Database.SaveResult> lstResult = Database.update(lstCaseToUpdate, false);             
                    //T15 - call the Notification Service specifically to process the Hypercare Case Creation notification
                    if(!lstCasesToNotify.isEmpty()){
                        NotificationService.notify(lstCasesToNotify, newMapToNotify, new List<Id>{System.Label.Notification_Subscription_Id_Hypercare_New_Case});
                    }
                }        
                catch(DmlException e){ apexManager.CreateExceptionRecords('CaseTriggerHelper.setSegment', 'Error while updating Case: ', e.getMessage());
                } 
            }
        }
        catch(Exception e){  apexManager.CreateExceptionRecords('CaseTriggerHelper.setSegment', 'Error while setting Segment: ', e.getMessage());
        }
    }
    
    //---------------------------------------</T14>------------------------------

    /*
     Method Name : removeTagging
     Description : This method removes the tagging from the Case Comment records.
     Parameters  : List, called from removeTagging, lstNewRecords New records.
                   List, called from removeTagging, mapOldRecords Old records.
     Return Type : None
     */
    public void removeTagging(List<Case> lstNewRecords, Map<Id, Case> mapOldRecords) {
        Set<Id> setCaseComments = new Set<Id>();
        Set<Id> setUpdatedCases = new Set<Id>();
        Set<String> setTerms = new Set<String>();
        List<String> lstCaseStatuses = new List<String> {
            'Closed',
            'Resolved',
            'Delivered',
            'Cancelled'
        };
        List<String> lstPriorities = new List<String> {
            'P2',
            'P3'
        };
        List<TopicAssignment> lstTopicAssignmentsToDelete = new List<TopicAssignment>();
        
        //We look for records that meet the criteria.
        for(Case objRecord : lstNewRecords) {
            if((lstCaseStatuses.contains(objRecord.Status) && objRecord.Status != mapOldRecords.get(objRecord.Id).Status) || (lstPriorities.contains(objRecord.Priority) && 
                    objRecord.Priority != mapOldRecords.get(objRecord.Id).Priority)) {
                setUpdatedCases.add(objRecord.Id);
            }
        }
        if(!setUpdatedCases.isEmpty()) {
            for(Case_Comment__c objRecord : [SELECT Id FROM Case_Comment__c WHERE Case__c IN :setUpdatedCases LIMIT 50000]) {
                setCaseComments.add(objRecord.Id);
            }

            //If we have Case Comments to analyze, we look for the terms.
            if(!setCaseComments.isEmpty()) {
                for(Record_Tagging__mdt objRecord : Record_Tagging__mdt.getall().values()) {
                    setTerms.add(objRecord.Term__c);
                }
                for(TopicAssignment objRecord : [SELECT Id FROM TopicAssignment WHERE EntityId IN :setCaseComments AND Topic.Name IN :setTerms LIMIT 50000]) {
                    lstTopicAssignmentsToDelete.add(objRecord);
                }

                //If we have topic assignments to delete, we do it.
                if(!lstTopicAssignmentsToDelete.isEmpty()) {
                    delete lstTopicAssignmentsToDelete;
                }
            }
        }
    }
}