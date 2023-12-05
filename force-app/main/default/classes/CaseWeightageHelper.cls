/*
Class:              CaseWeightageHelper
@Author:            Salesforce Developer
@Created Date:      5-June-2021
@Description:       Helper class to calculate case weightages
@TestClass:         
Change History.
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************
Sandeep                   12/14/2021                                                                                                    T01
Sandeep duggi             03/08/2022     I2RT-5537                                                                                      T02
Sandeep duggi             07/31/2022     I2RT-6602                                                                                      T03
Sandeep duggi             09/20/2022     I2RT-6973                                                                                      T04
Sandeep duggi             09/20/2022     I2RT-7289                                   SF_Incorrect case weightages for simple DI cases   T05
Sandeep Duggi             10/22/2022     I2RT-7260                                                                                      T06
Sandeep Duggi             01/15/2022     I2RT-7419                                   Regression_SF_6999_For next action                 T07
Sandeep Duggi             01/15/2022     I2RT-7289                                   SF_Incorrect case weightages for simple DI cases   T08
Sandeep Duggi                            I2RT-7293                                    Regression_6973- Weightage incorrect              T09
Sandeep Duggi            03/29/2023      I2RT-7977                                   SALT_Case is Strategic but weightage is calculated for Non strategic P2/P3             T10
Sandeep Duggi            07/21/2023      I2RT-8648                                   SALT weightage for the Preferred segment             T11
Vignesh Divakaran        10/03/2023      I2RT-9063                                   Replaced standard with custom object Service       T12 
                                                                                     Appointment
Sandeep Duggi            Oct 17 '23      I2RT-9219                                   P0 Flag - SALT enhancements                            T13      
Sandeep Duggi            Oct 20 '23      I2RT-9414                                  incorrect for operation case for field Environment value as Production                           T14                                                            
*/
Public Class CaseWeightageHelper{
    @future
    Public Static Void updateWeights(List<Id> caseIds, List<Id> projectIds, List<Id> accountIds, String OperationLevel){
        //System.debug('updateWeights--Entry');
        updateWeightsNonFuture(caseIds, projectIds, accountIds, OperationLevel);
    }
    Public Static Void updateWeightsNonFuture(List<Id> caseIds, List<Id> projectIds, List<Id> accountIds, String OperationLevel){
        // System.debug('Updating Weights');
        //System.debug('caseIds-->'+caseIds);
        Id OperationsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        Id TechnicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Map<String,SALT_Parameter__mdt> saltmap = new Map<String,SALT_Parameter__mdt>();
        for(SALT_Parameter__mdt smdt : [Select Id,label,Band__c, Base_Band_Weightage__c, Case_Weightage__c, Order__c 
                                        From SALT_Parameter__mdt]){
            saltmap.put(smdt.Label,smdt);
        }
        /*  System.debug('caseIds-->'+caseIds.size());
            System.debug('projectIdss-->'+projectIds);
            System.debug('projectIdss size-->'+projectIds.size());
            System.debug('accountIds-->'+accountIds);
            System.debug('accountIds size-->'+accountIds.size());
            System.debug('OperationLevel-->'+OperationLevel);
            System.debug(LoggingLevel.Info, 'Updating Weights');*/
        Set<Id> uniqueCaseIds = new Set<Id>();
        Map<Id, Id> caseWeightageMap = new Map<Id, Id>();
        Map<Id, Case> projectCaseIds = new Map<Id, Case>();
        Map<Id, Case> accountCaseIds = new Map<Id, Case>();
        Map<Id, Decimal> projectActiveP1 = new Map<Id, Decimal>();
        //Map<Id, Set<Id>> accountEscalationsMap = new Map<Id, Set<Id>>();
        List<CaseMilestone> runningMilestones=new List<CaseMilestone>();
        BusinessHours bh = [SELECT SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, 
                            ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, 
                            MondayEndTime,TuesdayEndTime,WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                            FROM BusinessHours
                            WHERE Name = :Label.GMT_Business_hours ];
        if(OperationLevel == 'Case'){
            uniqueCaseIds.addAll(caseIds);
            System.debug('Unique case ids -->'+uniqueCaseIds);
            System.debug('Unique case ids size before-->'+uniqueCaseIds.size());
            projectCaseIds = new Map<Id, Case>([Select Id, CaseNumber 
                                                From Case 
                                                Where (Support_Account__c IN: projectIds OR AccountId IN: accountIds) 
                                                AND Status NOT IN ('Closed','Resolved')]);
        }
        System.debug('projectCaseIds returned from  query--<'+projectCaseIds.size());
        uniqueCaseIds.addAll(projectCaseIds.keySet());
        //System.debug('uniqueCaseIds-->'+uniqueCaseIds);
        //System.debug('uniqueCaseIds size after -->'+uniqueCaseIds.size());
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Integer upperBound = Math.min(remainingRows, 10000); 
        Map<Id, Case> casesMap = new Map<Id, Case>([Select Id, CaseNumber,
                                                    (SELECT Id, MilestoneTypeId, MilestoneType.Name, CaseId, BusinessHoursId, 
                                                    StartDate, TargetDate,TimeRemainingInMins,CompletionDate,IsCompleted,IsViolated 
                                                    From CaseMilestones),
                                                    Engagement__c,Engagement__r.Source__c,Attention_Request__c,businesshours.name, 
                                                    CreatedDate, Case_Weightage__c, AccountId, Support_Account__c, RecordType.Name,RecordType.DeveloperName, 
                                                    IsEscalated, Priority, Status, Case_InActive__c, Is_Reopened__c, 
                                                    Entitled_Product__r.Pricing_Model__c, Entitled_Product__r.First_Asset_Case_Creation_Date__c, 
                                                    Resolution_Target_DateTime__c, Case_Timezone__c, Next_Action__c, Case_Support_Add_On__c, 
                                                    /*actionFromInformatica__c,*/ Support_Account__r.GCS_Segment__c,ACC__c,
                                                    Is_Internal_Or_External_Case__c,Account_Health_Score__c,Segment__c,Success_Offering__c,
                                                    Activity_Type__c,RCA_Pending_flag__c,Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c,Environment__c,P0_Enabled_By__c //<T12> , T13
                                                    From Case 
                                                    Where Id IN: uniqueCaseIds 
                                                    AND Status NOT IN ('Closed','Resolved') LIMIT :upperBound ]);
        remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        upperBound = Math.min(remainingRows, 10000);
        List<Task> escalationTasks = [Select Id, whatId, Type 
                                      From Task Where whatId IN: uniqueCaseIds 
                                      AND Type IN ('CSM Escalation', 'Predictive Escalation') 
                                      LIMIT :upperBound ];
        Map<Id, Case> casestoBeUpdated = new Map<Id, Case>();
        Set<Id> GEMSEscalations = new Set<Id>();
        Set<Id> emailGEMSEscalations = new Set<Id>();
        Set<Id> csmEscalation = new Set<Id>();
        //Set<Id> predictiveEscalation = new Set<Id>();
        Set<Id> accountGEMSEscalations = new Set<Id>();
        remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        upperBound = Math.min(remainingRows, 10000);
        //List<SR_Escalation__c> escalationsRecords = [Select Id, SR__c, Escalation__c, Escalation__r.Description, SR__r.AccountId from SR_Escalation__c where Escalation__r.Status != 'Closed' AND (SR__c IN: uniqueCaseIds OR Escalation__r.AccountId IN: accountIds) LIMIT :upperBound ];
        remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        upperBound = Math.min(remainingRows, 10000);
        //T03 added BCSP_Case_IR_Missed__c onto query 
        //T04 added Signature_Success__c & HyperCare__c
        Map<Id, Case_Weightage__c> caseWeightages = new Map<Id, Case_Weightage__c>([Select Id, Case__c, BCSP_Within_IR_SLA__c,BCSP_Case_IR_Missed__c, 
                                                                                    Business__c,IR_Violated__c,OGR_Violated__c,
                                                                                    IR_in_30_Mins__c,IR_in_1_Hour__c,
                                                                                    OGR_in_30_Mins__c,OGR_in_1_Hour__c,Signature_Success__c,HyperCare__c,
                                                                                    Activity_Type__c,RCA_Pending_Flag__c,Environment__c,Preferred_window__c
                                                                                    From Case_Weightage__c 
                                                                                    Where Case__c IN: casesMap.keySet() 
                                                                                    LIMIT :upperBound]);
        List<CaseWeightageWrapper> weightagesToBeUpdatedWrapper = new List<CaseWeightageWrapper>();
        Map<Id, Case_Weightage__c> weightagesToBeUpdated = new Map<Id, Case_Weightage__c>();
        for(Case_Weightage__c cw : caseWeightages.values()){
            caseWeightageMap.put(cw.Case__c, cw.Id);
            if(casesMap.get(cw.Case__c).Case_Weightage__c == null){
                Case cs = new Case();
                cs.Id = cw.Case__c;
                cs.Case_Weightage__c = cw.Id;
                casestoBeUpdated.put(cs.Id, cs);
            }
        }
        /*for(Task tsk : escalationTasks){
            if(tsk.Type == 'CSM Escalation')
                csmEscalation.add(tsk.whatId);
            if(tsk.Type == 'Predictive Escalation')
                predictiveEscalation.add(tsk.whatId);
        }*/
        /*for(SR_Escalation__c sr : escalationsRecords){
            System.debug(sr);
            System.debug(sr.Escalation__c);
            System.debug(sr.Escalation__r.Description);
            if(sr.Escalation__r.Description != null && sr.Escalation__r.Description.contains('Call back from Manager')){
                GEMSEscalations.add(sr.SR__c);
            }else{
                emailGEMSEscalations.add(sr.SR__c);
            }
            accountGEMSEscalations.add(sr.SR__r.AccountId);
        }*/
        if(!casestoBeUpdated.IsEmpty()){
            Update casestoBeUpdated.values();
        }
        System.debug('UPDATE DONE RESUME HERE'+casestoBeUpdated);
        for(Case cas : casesMap.values()){
            if(cas.Priority == 'P1'){
                Decimal activeP1 = projectActiveP1.get(cas.Support_Account__c) == null ? 1 : (projectActiveP1.get(cas.Support_Account__c) + 1);
                projectActiveP1.put(cas.Support_Account__c, activeP1);
            }
            //@Akhilesh --start--I2RT-4908
            /*if(cas.RecordType.Name == 'Escalation'){
                Set<Id> accountEscalations = accountEscalationsMap.get(cas.AccountId) == null ? new Set<Id>() : accountEscalationsMap.get(cas.AccountId);
                accountEscalations.add(cas.Id);
                accountEscalationsMap.put(cas.AccountId, accountEscalations);
            }
            */
            //@Akhilesh --end--I2RT-4908
            System.debug('@Developer --> cas.Engagement__c :' + cas.Engagement__c);
            System.debug('@Developer --> cas.Attention_Request__c :' + cas.Attention_Request__c);
            if(cas.Engagement__c != null){
                
                    GEMSEscalations.add(cas.Id);
               
               
                    emailGEMSEscalations.add(cas.Id);
            
                accountGEMSEscalations.add(cas.AccountId);
                if(cas.Engagement__r.Source__c  == 'CSM'){
                    csmEscalation.add(cas.Id);
                }
            }
           //System.debug('@Developer --> GEMSEscalations :' + GEMSEscalations);
        }
         // System.debug('@Developer --> emailGEMSEscalations :' + emailGEMSEscalations);
         //System.debug('@Developer --> csmEscalation :' + csmEscalation);
         // System.debug('casesMap.values()-->'+casesMap.values());
         // System.debug('casesMap.values().size-->'+casesMap.values().size());
        for(Case cas : casesMap.values()){
             //System.debug('cas.CaseNumber-->'+cas.CaseNumber);
            /*  System.debug(cas.IR_Target_End_Time__c >= System.now());
            System.debug('cas.IR_Target_End_Time_c-->'+cas.IR_Target_End_Time__c);
            System.debug('System.now()-->'+System.now());
            System.debug('DateTime  .now()-->'+datetime.now());
            System.debug('caseWeightageMap.get(cas.Id)--<'+caseWeightageMap.get(cas.Id));*/
            if(caseWeightageMap.get(cas.Id) != null){
                CaseWeightageWrapper cww = new CaseWeightageWrapper();
                // System.debug('cas-->'+cas);
                //  System.debug('caseWeightageMap.get(cas.Id);--<'+caseWeightageMap.get(cas.Id));
                cww.cs = cas;
                cww.weightageId = caseWeightageMap.get(cas.Id);
                if(cas.Priority == 'P1'){
                    cww.P1_Priority = saltmap.get('P1 Priority').Case_Weightage__c;
                    cww.P2_Priority = 0;
                    cww.P3_Priority = 0;
                    cww.band = 'S1';
                }
                else if(cas.Priority == 'P2'){   
                    cww.P1_Priority = 0;
                    cww.P2_Priority = saltmap.get('P2 Priority').Case_Weightage__c;
                    cww.P3_Priority = 0;
                    cww.band = 'S3';
                }
                else if(cas.Priority == 'P3'  && cas.Segment__c != 'Hypercare' && cas.Success_Offering__c != 'Signature Success'){   // T04 

                    cww.P1_Priority = 0;
                    cww.P2_Priority = 0;
                    cww.P3_Priority = saltmap.get('P3 Priority').Case_Weightage__c;
                    cww.band = 'S3';
                }
                if(cas.Case_InActive__c){
                    cww.Inactive_case = saltmap.get('Inactive Case').Case_Weightage__c;
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Inactive Case').Band__c;
                    }
                }
                if((cas?.Segment__c == 'HyperCare') &&  (cas.Priority == 'P2' || cas.Priority == 'P3')){                //T04 starts
                    cww.HyperCare = saltmap.get('HyperCare P2/P3').Case_Weightage__c;
                    cww.band = 'S2';
                }
                if(cas?.Segment__c == 'HyperCare' &&  cas.Priority == 'P1'){
                    cww.HyperCare = saltmap.get('HyperCare P1').Case_Weightage__c;
                    cww.band = 'S1';
                }
                if((cas?.Success_Offering__c == 'Signature Success') && (cas.Priority == 'P2' || cas.Priority == 'P3')){
                    cww.Success_Offering = saltmap.get('Signature Success P2/P3').Case_Weightage__c;
                    cww.band = 'S2';
                }
                if(cas?.Success_Offering__c == 'Signature Success' &&  cas.Priority == 'P1'){
                    cww.Success_Offering = saltmap.get('Signature Success P1').Case_Weightage__c;
                    cww.band = 'S1';
                }                                                                                                    //T04 Ends
                if(cas.RecordTypeId == OperationsRecordTypeId) {                //T06 starts
                    if(cas.Activity_Type__c == 'Report a service outage' && cas.Status != 'Solution'){
                        cww.ActivityType = saltmap.get('Activity Type - Outage').Case_Weightage__c;
                        cww.band = saltmap.get('Activity Type - Outage').Band__c;
                        
					}
                    if(cas?.Service_Appointment__r?.Time_Slot_AAE__r.Start_Time__c != null ){ //<T12>
                        DateTime dt = system.now();
                        Integer hours = math.mod(Integer.valueOf((cas.Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c.getTime() - (dt).getTime())/(1000*60*60)),24); //<T12>
                        if(hours < 2 && hours > 0){
                        cww.PrefferedWindow = saltmap.get('Preferred window < 2 Hours').Case_Weightage__c;
                        cww.band = saltmap.get('Preferred window < 2 Hours').Band__c;
                        }
                        
					}
                    if(cas.RCA_Pending_flag__c == 'Yes'){
                        cww.RCAPendingFlag = saltmap.get('RCA Pending Flag Enabled').Case_Weightage__c;
                        cww.band = saltmap.get('RCA Pending Flag Enabled').Band__c;
                        
					}
                    // T14
                    if(cas.Environment__c == 'Production'){
                        cww.Environment = saltmap.get('Environment is Prod').Case_Weightage__c;
                    }else{
                         cww.Environment = 0;
                    }
                } //T06 ends
                //<T13>
                if( cas.P0_Enabled_By__c != null && cas.RecordTypeId == TechnicalRecordTypeId){
                    cww.P0Flag = saltmap.get('P0 Flagged case').Case_Weightage__c;
                    cww.band = saltmap.get('P0 Flagged case').Band__c;
                } else {
                    cww.P0Flag = 0;
                }
                //</T13>
                //-------------------------------------------------<T01>------------------
                /*if(cas.IsEscalated){                    
                    //Check task, gems case
                        cww.Web_Escalation_with_Manager_Callback = saltmap.get('Gems Escalation').Case_Weightage__c;
                        cww.band = 'S1';
                    }
                    if(cas.Attention_Request__c == 'Revise Priority' || cas.Attention_Request__c == 'Callback'){
                        cww.Web_Escalation_other_than_manager_call = saltmap.get('Web Escalation Task').Case_Weightage__c;
                        cww.band = 'S1';
                    }
                    if(emailGEMSEscalations.contains(cas.Id)){
                        cww.GEMS_Escalation = saltmap.get('Gems Escalation').Case_Weightage__c;
                        cww.band = 'S1';
                    }
                }*/
                // T09 added this new if condition for web escaltion ; previously commented out
                if(cas.IsEscalated){                    
                        cww.Web_Escalation_with_Manager_Callback = saltmap.get('Web Escalation With Manager Callback').Case_Weightage__c;
                        cww.band = 'S1';
                    }
                if(cas.Attention_Request__c == 'Callback' || cas.Attention_Request__c == 'Revise Priority' || cas.Attention_Request__c == 'Live Assistance'){
                    cww.Web_Escalation_other_than_manager_call = saltmap.get('Web Escalation Task').Case_Weightage__c;
                    cww.band = 'S1';
                }
                if(cas.Engagement__r?.Source__c == 'CSM' && cas.Engagement__r?.Source__c != null){
                    cww.csmEscalated = saltmap.get('Csm Escalated').Case_Weightage__c;
                    cww.band = 'S1';
                }
                //-------------------------------------------------<End of T01>------------------
                //--------------------------------------------------------<T01 - Ignore weightage after 2 days of Live Handoff>
                BusinessDaysCalculation bdc = new BusinessDaysCalculation(null,false,bh);        
                Date todaydateGMT = date.newinstance(system.now().dateGMT().year(), system.now().dateGMT().month(), system.now().dateGMT().day());            
                /*if(cas.CollabTypeSelected__c == 'Live Handoff' && bdc.addBusinessDays(cas.Handoff_Datetime__c.dateGMT(), 2) >= todaydateGMT){
                    cww.band = 'S1';
                    cww.Live_Handoff = saltmap.get('Live Handoff').Case_Weightage__c;
                }*/
                //-----------------------------------------------------</T01>
                //<T10 Modified if condition 
                if(cas.Segment__c != null && cas.Segment__c == 'Strategic' && caseWeightages.get(caseWeightageMap.get(cas.Id)).Business__c == 'ON'){
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Strategic Same Timezone').Band__c;
                    }
                }
                // T11 starts
                if(cas.Segment__c != null && cas.Segment__c == 'Preferred' && caseWeightages.get(caseWeightageMap.get(cas.Id)).Business__c == 'ON'){
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Preferred Same Timezone').Band__c;
                    }
                }
                // T11 ends 
                if(caseWeightageMap.get(cas.Id) != null && caseWeightages.get(caseWeightageMap.get(cas.Id)) != null){
                    if(caseWeightages.get(caseWeightageMap.get(cas.Id)).Business__c == 'ON'){
                        cww.SameTimeZone = True;
                    }
                    else{
                        cww.SameTimeZone = False;
                    }
                }
                if((cas.Priority == 'P2' || cas.Priority == 'P3') && caseWeightages.get(caseWeightageMap.get(cas.Id)).Business__c == 'OFF'){
                    cww.Non_Customer_Timezone_For_p2_and_p3 = saltmap.get('Non Customer Timezone For P2 And P3').Case_Weightage__c;
                }
                for(CaseMilestone cms : cas.CaseMilestones){
                    if(cms.MilestoneType.name == 'Initial Response'){
                        cww.IR_Target_End_Time =  cms.TargetDate;
                    }
                }                
                if(cas.Case_Support_Add_On__c == 'BCSP'){
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Bcsp, Case Within Ir/Closure Sla').Band__c;
                    }
                    cww.BCSP_Within_IR_SLA = saltmap.get('Bcsp, Case Within Ir/Closure Sla').Case_Weightage__c;
                }
                if(accountGEMSEscalations.contains(cas.AccountId) && !GEMSEscalations.contains(cas.Id) && cas.RecordType.DeveloperName != 'Case_Lite'){
                    cww.GEMS_escalation_on_account = saltmap.get('Gems Escalation On Account').Case_Weightage__c;
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Gems Escalation On Account').Band__c;
                    }
                }
                if(GEMSEscalations.contains(cas.Id)){
                    cww.GEMS_Escalation = saltmap.get('Gems Escalation').Case_Weightage__c;
                    cww.band = 'S1';
                   
                }
                if(cas.Is_Reopened__c){
                    cww.Re_opened_case = saltmap.get('Re-Opened Case').Case_Weightage__c;
                    if(cww.band == 'S3'){
                        cww.band = saltmap.get('Re-Opened Case').Band__c;
                    }
                }
                if(cas.Entitled_Product__r.Pricing_Model__c == 'Subscription' && 
                   cas.Entitled_Product__r.First_Asset_Case_Creation_Date__c != null && 
                   (cas.Entitled_Product__r.First_Asset_Case_Creation_Date__c.daysBetween(System.Today()) > 120)){
                    cww.Subscription_Beyond_120_Days = saltmap.get('Subscription Beyond 120 Days').Case_Weightage__c;
                }
                if(projectActiveP1.get(cas.Support_Account__c) != null && projectActiveP1.get(cas.Support_Account__c) > 1 && cas.RecordType.DeveloperName != 'Case_Lite'){
                    cww.Multiple_active_P1s_on_the_project = saltmap.get('Multiple Active P1S On The Project').Case_Weightage__c;
                    if(cww.band == 'S3'){
                        cww.band =  saltmap.get('Multiple Active P1S On The Project').Band__c;   
                    }     
                }
                if(cas.Next_Action__c =='Customer'){
                    
                    //@Akhilesh --start--I2RT-4908
                    if(saltmap.containskey('Next Action is Customer')){
                        cww.Waiting_on_customer = saltmap.get('Next Action is Customer').Case_Weightage__c;
                        cww.Waiting_on_Third_Party = 0;
                        cww.Waiting_on_Case_Team_R_D = 0;
                        
                    }
                    //@Akhilesh --end--I2RT-4908
                    
                }
                else if(cas.Next_Action__c =='Third Party'){
                    //@Akhilesh --start--I2RT-4908
                    //cww.Waiting_on_Third_Party = saltmap.get('Case Is Waiting On Third Party').Case_Weightage__c;
                    if(saltmap.containskey('Next Action is Consultant, Reviewer or T')){
                        cww.Waiting_on_Third_Party = saltmap.get('Next Action is Consultant, Reviewer or T').Case_Weightage__c;
                        cww.Waiting_on_customer = 0;
                        cww.Waiting_on_Case_Team_R_D = 0;
                    }
                    //@Akhilesh --end--I2RT-4908
                }
                // I2RT-7419 T07 : Modified If clause. 
                else if(cas.Next_Action__c =='Case Team' || cas.Next_Action__c =='INFA R&D' || cas.Next_Action__c =='PS Team' || cas.Next_Action__c =='Operations Team'  || cas.Next_Action__c =='Multi Team'){
                    //@Akhilesh --start--I2RT-4908
                    //cww.Waiting_on_Case_Team_R_D = saltmap.get('Case Is Waiting On Case Team, R&D').Case_Weightage__c;
                    if(saltmap.containskey('Next Action is Infa R&D')){
                        cww.Waiting_on_Case_Team_R_D = saltmap.get('Next Action is Infa R&D').Case_Weightage__c;
                        cww.Waiting_on_Third_Party = 0;
                        cww.Waiting_on_customer = 0;
                    }
                    //@Akhilesh --end--I2RT-4908
                }
                //T06
                if( cas.RCA_Pending_flag__c != null && cas.RCA_Pending_flag__c == 'Yes' && cas.RecordTypeId == OperationsRecordTypeId){
                    cww.Waiting_on_customer = 0 ;
                }
                 //<T10 Modified if condition 
                if(cas.Segment__c != null && (cas.Segment__c != 'Strategic' && cas.Segment__c != 'Preferred') && (cas.Priority == 'P2' || cas.Priority == 'P3')){
                    cww.Non_strategic_P2_And_P3 = saltmap.get('Non-Strategic / Preferred P2 And P3').Case_Weightage__c;
                }
                //@Akhilesh --start--I2RT-4908
                /*if(predictiveEscalation.contains(cas.Id) && cas.Priority == 'P1'){
                    cww.predictiveEscalatedP1 = saltmap.get('Predictive Escalated P1').Case_Weightage__c;
                }
                if(predictiveEscalation.contains(cas.Id) && cas.Priority != 'P1'){
                    cww.predictiveEscalatedNonP1 = saltmap.get('Predictive Escalation (Non-P1)').Case_Weightage__c;
                }
                */
                //@Akhilesh --end--I2RT-4908
                if(csmEscalation.contains(cas.Id)){
                    cww.csmEscalated = saltmap.get('Csm Escalated').Case_Weightage__c;
                    cww.band = 'S1'; //I2RT-7309 bug fix  T05 
                }
                //<TO3> ACC Changes
                if(cas!=null && cas.ACC__c!=null && cas.ACC__c){
                    System.debug('ACC__c-->'+cas.ACC__c);
                    if(saltmap.get('ACC Case')!=null && saltmap.get('ACC Case').Case_Weightage__c!=null){
                        System.debug('ACC Case weightage-->'+saltmap.get('ACC Case').Case_Weightage__c);
                         cww.ACC=saltmap.get('ACC Case').Case_Weightage__c;
                    }
                }
                //</TO3>
                
                //<T02> milestone changes
                Decimal dTimeRemainingInMins;
                runningMilestones=new List<CaseMilestone>();
                /*List<CaseMilestone> runningMilestonesInSortedOrder= new List<CaseMilestone>();
                Map<CaseMilestone,Decimal> sortedRunningMilestones=new Map<CaseMilestone,Decimal>();
                Map<Integer,CaseMilestone> sortedRunningMilestones1=new Map<Integer,CaseMilestone>(); */
                cww.IRViolated=0;
                cww.OGRViolated=0;
                cww.IR30Mins=0;
                cww.OGR30Mins=0;
                cww.IR1Hr=0;
                cww.OGR1Hr=0;
                cww.BCSPCaseIRMissed=0; //T03
                Decimal timeinMins;
                List<MilestoneWrapper> wrapperList=new List<MilestoneWrapper>();
               // System.debug('cas.CaseMilestones-->'+cas.CaseMilestones);
                if(cas.CaseMilestones!=null && !cas.CaseMilestones.isEmpty()){
                    for(CaseMilestone cm: cas.CaseMilestones){
                        //iterate over all the milestones, get the running/violated  milestones(completion date =null) , calculate the weightage for uncompleted ones.and reset the weigtage for rest.
                        if(cm.CompletionDate==null && !cm.IsCompleted ){
                            System.debug('Ongoing/violated milestones');
                            MilestoneWrapper mwrapper=new MilestoneWrapper();
                            mwrapper.name=cm.MilestoneType.Name; 
                            mwrapper.IsViolated=cm.IsViolated;
                            if(cm.TimeRemainingInMins!=null){
                                if(cm.TimeRemainingInMins.contains(':')){
                                    String str=cm.TimeRemainingInMins.replace(':','.');
                                    timeinMins=Decimal.valueOf(str);
                                }
                                else{
                                     timeinMins=Decimal.valueOf(cm.TimeRemainingInMins);
                                }
                            }
                            mwrapper.TimeRemainingInMins=timeinMins;
                            wrapperList.add(mwrapper);
                            runningMilestones.add(cm);
                        }
                    }
                    wrapperList.sort();
                }
                Boolean violatedMilestones=false;
                //To check if any violated milestones are present
                if(wrapperList!=null && !wrapperList.isEmpty()){
                    for(MilestoneWrapper cm: wrapperList){
                        if(cm.IsViolated){
                            violatedMilestones=true;
                        }
                    }
                }
                if(wrapperList!=null && !wrapperList.isEmpty()){
                    for(MilestoneWrapper cm: wrapperList){
                        if(cm.TimeRemainingInMins!=null && cm.TimeRemainingInMins==0.00){
                            System.debug('Line 297');
                            if(cm.name!=null && cm.name=='Initial Response' && cm.IsViolated ){
                                System.debug('IR Violation');
                                if(saltmap.get('IR Violated')!=null && saltmap.get('IR Violated').Case_Weightage__c!=null){
                                    //@Akhilesh --start--I2RT-4908
                                    //cww.IRViolated=saltmap.get('IR Violated').Case_Weightage__c;
                                    if(cas.Case_Support_Add_On__c == 'BCSP'){
                                        if(saltmap.containskey('BCSP Case IR missed')){
                                            cww.band = saltmap.get('BCSP Case IR missed').Band__c;
                                            cww.BCSPCaseIRMissed = saltmap.get('BCSP Case IR missed').Case_Weightage__c;
                                            cww.BCSP_Within_IR_SLA = 0; //T03
                                        }
                                    }
                                    else{
                                        cww.IRViolated=saltmap.get('IR Violated').Case_Weightage__c;
                                    }
                                    //@Akhilesh --end--I2RT-4908
                                    cww.isIRViolated=true;
                                  // T02 cww.OGRViolated=0;
                                    cww.IR30Mins=0;
                                 // T02  cww.OGR30Mins=0;
                                    cww.IR1Hr=0;
                                 //  T02 cww.OGR1Hr=0;
                                }
                            }
                            else if(cm.name!=null && cm.name=='Ongoing Response' || cm.name == 'Engineer Ongoing Response' && cm.IsViolated){
                                System.debug('OGR Violation');
                                if(saltmap.get('OGR Violated')!=null && saltmap.get('OGR Violated').Case_Weightage__c!=null){
                                    cww.OGRViolated=saltmap.get('OGR Violated').Case_Weightage__c;
                                    cww.isOGRViolated=true;
                                  // T02   cww.IRViolated=0;
                                   // T02  cww.IR30Mins=0;
                                    cww.OGR30Mins=0;
                                  // T02   cww.IR1Hr=0;
                                    cww.OGR1Hr=0;
                                }
                            }
                            //@Akhilesh --start--I2RT-4908 
                            else if(cm.name != null && cm.name =='Attention Request Response' && cm.IsViolated ){
                                if(saltmap.containskey('AR milestone violated (new)')){
                                    cww.ARViolated = saltmap.get('AR milestone violated (new)').Case_Weightage__c;
                                }
                            } 
                            //@Akhilesh -- end--I2RT-4908 
                          // T02   break;
                        }
                        else if(cm.TimeRemainingInMins!=null && cm.TimeRemainingInMins > 0 && cm.TimeRemainingInMins <=30){
                            System.debug('dTimeRemainingInMins--line 315--'+cm.TimeRemainingInMins);
                            if(cm.name!=null && cm.name=='Initial Response'){
                                System.debug('IR in 30 mins');
                                if(saltmap.get('IR in 30 Mins') !=null && saltmap.get('IR in 30 Mins').Case_Weightage__c!=null){
                                    cww.IR30Mins=saltmap.get('IR in 30 Mins').Case_Weightage__c;                                    
                                    cww.IRViolated=0;
                                    // T02 cww.OGRViolated=0;
                                   // T02  cww.OGR30Mins=0;
                                    cww.IR1Hr=0;
                                   // T02  cww.OGR1Hr=0;
                                }
                            }
                            else if(cm.name!=null && cm.name=='Ongoing Response' || cm.name=='Engineer Ongoing Response'){
                                System.debug('OGR in 30 mins');
                                if(saltmap.get('OGR in 30 Mins')!=null && saltmap.get('OGR in 30 Mins').Case_Weightage__c!=null){
                                    cww.OGR30Mins=saltmap.get('OGR in 30 Mins').Case_Weightage__c;
                                    // T02 cww.IRViolated=0;
                                    cww.OGRViolated=0;
                                    // T02 cww.IR30Mins=0;
                                    cww.IR1Hr=0;
                                   // T02  cww.OGR1Hr=0;
                                }
                            }
                          /* T02 if(violatedMilestones){
                                continue;
                            }
                            else{
                                break;
                            }  T02 */                         
                        }
                        else if(cm.TimeRemainingInMins!=null && cm.TimeRemainingInMins > 30 && cm.TimeRemainingInMins <=60){
                            System.debug('Line 330');
                            if(cm.name!=null && cm.name=='Initial Response'){
                                System.debug('IR IN  1 HOUR');
                                if(saltmap.get('IR in 1 hour')!=null && saltmap.get('IR in 1 hour').Case_Weightage__c!=null){
                                    cww.IR1Hr=saltmap.get('IR in 1 hour').Case_Weightage__c;
                                    cww.IRViolated=0;
                                  // T02   cww.OGRViolated=0;
                                    cww.IR30Mins=0;
                                   // T02  cww.OGR30Mins=0;
                                   // T02  cww.OGR1Hr=0;
                                }
                            }
                            else if(cm.name!=null && cm.name=='Ongoing Response'  || cm.name=='Engineer Ongoing Response'){
                                System.debug('OGR IN  1 HOUR');
                                if(saltmap.get('OGR in 1 hour')!=null && saltmap.get('OGR in 1 hour').Case_Weightage__c!=null){
                                    cww.OGR1Hr=saltmap.get('OGR in 1 hour').Case_Weightage__c;
                                }
                                // T02 cww.IRViolated=0;
                                cww.OGRViolated=0;
                               // T02  cww.IR30Mins=0;
                                cww.OGR30Mins=0;
                                // T02 cww.IR1Hr=0;
                            }
                        }
                    }
                }
                //</T02>
                //@Akhilesh --start--I2RT-4908
                /////////////
                if(cas.Account_Health_Score__c <= 20 && cas.RecordType.DeveloperName != 'Case_Lite'){ //T05
                    if(saltmap.containskey('Cassini Health - Red')){
                        cww.band = saltmap.get('Cassini Health - Red').Band__c;
                        cww.CassiniHealth_Red = saltmap.get('Cassini Health - Red').Case_Weightage__c;
                    }
                }
                if(cas.Is_Internal_Or_External_Case__c == 'Internal'){
                    if(saltmap.containskey('Internal Case')){
                        cww.InternalCase = saltmap.get('Internal Case').Case_Weightage__c;
                    }
                }
                // T08 Start 
                
                // T08 END
                //@Akhilesh --end--I2RT-4908
                weightagesToBeUpdatedWrapper.add(cww);
            }
        }
        System.debug('weightagesToBeUpdatedWrapper-->'+weightagesToBeUpdatedWrapper);
        System.debug('weightagesToBeUpdatedWrapper size-->'+weightagesToBeUpdatedWrapper.size());
        for(CaseWeightageWrapper cww : weightagesToBeUpdatedWrapper){
            Case_Weightage__c cw = new Case_Weightage__c();
            Decimal weightage = 0;
            cw.Id = cww.weightageId;
            cw.Band__c = cww.band;
            if(cww.band == 'S1'){
                weightage = 75;
            }
            else if(cww.band == 'S2'){
                weightage = 50;
            }
            else{
                weightage = 25;
            }
            cw.Web_Escalation_with_Manager_Callback__c = cww.Web_Escalation_with_Manager_Callback;
            weightage = weightage + cww.Web_Escalation_with_Manager_Callback;
            cw.Web_Escalation_other_than_manager_call__c = cww.Web_Escalation_other_than_manager_call;
            weightage = weightage + cww.Web_Escalation_other_than_manager_call;
            System.debug('@Developer --> cww.GEMS_Escalation :' + cww.GEMS_Escalation);
            cw.GEMS_Escalation__c = cww.GEMS_Escalation;
            //-----------------------------------------<T01 Ignore weigtage if case is already escalated>
            // T08 modified if condition to ignore web escalation weightage if gems escalation exisits on the case 
            weightage = weightage + (cww.Web_Escalation_with_Manager_Callback == 0 ? cww.GEMS_Escalation:0);            
            //-----------------------------------------</T01>
            System.debug('@Developer --> cww.Web_Escalation_other_than_manager_call :' + cww.Web_Escalation_other_than_manager_call);
            /*T08 code repeated above 
            cw.Web_Escalation_other_than_manager_call__c = cww.Web_Escalation_other_than_manager_call;
            weightage = weightage + cww.Web_Escalation_other_than_manager_call;
            */
            cw.P1_Priority__c = cww.P1_Priority;
            weightage = weightage + cww.P1_Priority;
            cw.Live_Handoff__c = cww.Live_Handoff;
            weightage = weightage + cww.Live_Handoff;
            cw.Multiple_active_P1s_on_the_project__c = cww.Multiple_active_P1s_on_the_project;
            weightage = weightage + cww.Multiple_active_P1s_on_the_project;            
            cw.Inactive_case__c = cww.Inactive_case;
            weightage = weightage + cww.Inactive_case;
            cw.Re_opened_case__c = cww.Re_opened_case;
            weightage = weightage + cww.Re_opened_case;
            cw.Strategic_customers_Same_Timezone__c = cww.Strategic_customers_Same_Timezone;
            weightage = weightage + cww.Strategic_customers_Same_Timezone;
            cw.Subscription_Beyond_120_Days__c = cww.Subscription_Beyond_120_Days;
            weightage = weightage + cww.Subscription_Beyond_120_Days;
            cw.P2_Priority__c = cww.P2_Priority;
            weightage = weightage + cww.P2_Priority;
            cw.P3_Priority__c = cww.P3_Priority;
            weightage = weightage + cww.P3_Priority;
            cw.Waiting_on_customer__c = cww.Waiting_on_customer;
            weightage = weightage + cww.Waiting_on_customer;
            cw.Waiting_on_Third_Party__c = cww.Waiting_on_Third_Party;
            weightage = weightage + cww.Waiting_on_Third_Party;
            cw.BCSP_Within_IR_SLA__c = cww.BCSP_Within_IR_SLA;
            weightage = weightage + cww.BCSP_Within_IR_SLA;
            cw.Waiting_on_Case_Team_R_D__c = cww.Waiting_on_Case_Team_R_D;
            weightage = weightage + cww.Waiting_on_Case_Team_R_D;
            cw.Non_Customer_Timezone_For_p2_and_p3__c = cww.Non_Customer_Timezone_For_p2_and_p3;
            weightage = weightage + cww.Non_Customer_Timezone_For_p2_and_p3;
            cw.Non_strategic_P2_And_P3__c = cww.Non_strategic_P2_And_P3; 
            weightage = weightage + cww.Non_strategic_P2_And_P3;
            cw.SameTimeZone__c = cww.SameTimeZone;
            cw.IR_Target_Time__c = cww.IR_Target_End_Time;
            cw.CSM_Escalated__c = cww.csmEscalated;
            weightage = weightage + cww.csmEscalated;
            System.debug('weightage before milestone changes->'+weightage);
            //<T03>ACC Changes
             cw.ACC__c = cww.ACC;
            weightage=weightage+cww.ACC;
            //</T03>
            //MileStone changes
            //<T02>
            cw.IR_Violated__c=cww.IRViolated;
            weightage = weightage + cww.IRViolated;
            System.debug('weightage after IR Violation ->'+weightage);
            cw.OGR_Violated__c=cww.OGRViolated;
            weightage = weightage + cww.OGRViolated;
            System.debug('weightage after ogr Violation ->'+weightage);
            //@Akhilesh --start--16 Sept 2021
            cw.IR_in_30_Mins__c = cww.IR30Mins;
            //weightage = weightage + cww.IR30Mins;
            weightage = weightage + (cww.BCSP_Within_IR_SLA == 0 ? cww.IR30Mins : 0 );
            System.debug('weightage after IR_in_30_Mins__c ->'+weightage);
            //@Akhilesh --end--16 Sept 2021
            cw.OGR_in_30_Mins__c=cww.OGR30Mins;
            weightage = weightage + cww.OGR30Mins;
            System.debug('weightage after  OGR_in_30_Mins__c ->'+weightage);
            cw.IR_in_1_Hour__c=cww.IR1Hr;
            weightage = weightage + cww.IR1Hr;
            System.debug('weightage after IR_in_1_Hour__c ->'+weightage);
            cw.OGR_in_1_Hour__c=cww.OGR1Hr;
            weightage = weightage + cww.OGR1Hr;
            System.debug('weightage after OGR_in_1_Hour__c  ->'+weightage);
            //</T02>
            cw.Predictive_Escalation_P1__c = cww.predictiveEscalatedP1;
            cw.Predictive_Escalation_Non_P1__c = cww.predictiveEscalatedNonP1; 
            //-----------------------------------------<T01 Ignore weigtage if case is already escalated>
            System.debug('@Developer --> cww.Web_Escalation_with_Manager_Callback :' + cww.Web_Escalation_with_Manager_Callback);
            System.debug('@Developer --> cww.GEMS_Escalation :' + cww.GEMS_Escalation);
            if(cww.Web_Escalation_with_Manager_Callback == 0 && cww.GEMS_Escalation == 0){
                weightage = weightage + cww.predictiveEscalatedP1;
                weightage = weightage + cww.predictiveEscalatedNonP1;
            }                       
            System.debug('@Developer --> cww.GEMS_escalation_on_account :' + cww.GEMS_escalation_on_account);
            cw.GEMS_escalation_on_account__c = cww.GEMS_escalation_on_account;            
            System.debug('@Developer --> cww.Web_Escalation_with_Manager_Callback :' + cww.Web_Escalation_with_Manager_Callback);
            System.debug('@Developer --> cww.GEMS_Escalation :' + cww.GEMS_Escalation);
            System.debug('@Developer --> cww.predictiveEscalatedNonP1 :' + cww.predictiveEscalatedNonP1);
            System.debug('@Developer --> cww.predictiveEscalatedP1 :' + cww.predictiveEscalatedP1);      
            if(cww.Web_Escalation_with_Manager_Callback == 0 && cww.GEMS_Escalation == 0 && cww.predictiveEscalatedNonP1 == 0 && cww.predictiveEscalatedP1 == 0){
                weightage = weightage + cww.GEMS_escalation_on_account;
            }
            //-----------------------------------------</T01>
            //@Akhilesh --start--I2RT-4908
            cw.Cassini_Health_Red__c = cww.CassiniHealth_Red; 
            weightage = weightage + (cww.CassiniHealth_Red != null ? cww.CassiniHealth_Red : 0);
            cw.BCSP_Case_IR_Missed__c = cww.BCSPCaseIRMissed;
            weightage = weightage + (cww.BCSPCaseIRMissed != null ? cww.BCSPCaseIRMissed : 0);
            cw.AR_Milestone_Violated_New__c = cww.ARViolated;
            weightage = weightage + (cww.ARViolated != null ? cww.ARViolated : 0);
            cw.Internal_Case__c = cww.InternalCase;
            weightage = weightage + (cww.InternalCase != null ? cww.InternalCase : 0);
            //@Akhilesh --end--I2RT-4908
            //T04 starts
            cw.HyperCare__c = cww.HyperCare ;
            weightage = weightage + (cww.HyperCare != null ? cww.HyperCare : 0);
            cw.Signature_Success__c = cww.Success_Offering ;
            weightage = weightage + (cww.Success_Offering != null ? cww.Success_Offering : 0);
            //t04 ends
            //T05 Starts 
            cw.Activity_Type__c = cww.ActivityType ;
            weightage = weightage + (cww.ActivityType != null ? cww.ActivityType : 0);
            cw.Preferred_window__c = cww.PrefferedWindow ;
            weightage = weightage + (cww.PrefferedWindow != null ? cww.PrefferedWindow : 0);
            cw.RCA_Pending_Flag__c = cww.RCAPendingFlag ;
            weightage = weightage + (cww.RCAPendingFlag != null ? cww.RCAPendingFlag : 0);
             cw.Environment__c = cww.Environment ;
            weightage = weightage + (cww.Environment != null ? cww.Environment : 0);
            //T05 Ends
            cw.P0_Flag__c = cww.P0Flag ; //<T13>
            weightage = weightage + (cww.P0Flag != null ? cww.P0Flag : 0); 
            cw.Full_Case_Weightage__c = weightage;
            cw.Name = weightage > 100 ? '100%' : weightage < 0 ? '0%' : String.valueOf(weightage).replace('.0','')+'%';
            weightagesToBeUpdated.put(cw.Id, cw);
        }
        if(!weightagesToBeUpdated.IsEmpty()){
            Update weightagesToBeUpdated.values();
        }
    }
    Public Class CaseWeightageWrapper{
        Public Case cs {get; set;}
        Public Id weightageId {get; set;}
        Public String band {get; set;}
        Public DateTime IR_Target_End_Time {get; set;}
        Public Decimal Web_Escalation_with_Manager_Callback {get; set;}
        Public Decimal Web_Escalation_other_than_manager_call {get; set;}
        Public Decimal GEMS_Escalation {get; set;}        
        Public Decimal P1_Priority {get; set;}
        Public Decimal Live_Handoff {get; set;}
        Public Decimal Multiple_active_P1s_on_the_project {get; set;}
        Public Decimal GEMS_escalation_on_account {get; set;}
        Public Decimal Inactive_case {get; set;}
        Public Decimal Re_opened_case {get; set;}
        Public Decimal Strategic_customers_Same_Timezone {get; set;}
        Public Decimal Subscription_Beyond_120_Days {get; set;}
        Public Decimal P2_Priority {get; set;}
        Public Decimal P3_Priority {get; set;}
        Public Decimal Waiting_on_customer {get; set;}
        Public Decimal Waiting_on_Third_Party {get; set;}
        Public Decimal Waiting_on_Case_Team_R_D {get; set;}
        Public Decimal Non_Customer_Timezone_For_p2_and_p3 {get; set;}
        Public Decimal Non_strategic_P2_And_P3 {get; set;}       
        Public Boolean SameTimeZone {get; set;}
        Public Decimal BCSP_Within_IR_SLA {get; set;}
        Public Decimal csmEscalated {get; set;}
        Public Decimal predictiveEscalatedP1 {get; set;}
        Public Decimal predictiveEscalatedNonP1 {get; set;}
        public Decimal CassiniHealth_Red {get;set;}
        public Decimal BCSPCaseIRMissed {get;set;}
        public Decimal ARMilestoneviolated_new {get;set;}
        public Decimal InternalCase{get;set;}
        //<T02>
        Public Decimal IRViolated {get; set;}
        Public Decimal OGRViolated {get; set;}
        Public Decimal IR30Mins {get; set;}
        Public Decimal OGR30Mins {get; set;}
        Public Decimal IR1Hr {get; set;}
        Public Decimal OGR1Hr{get; set;}
        Public Boolean isIRViolated{get;set;}
        Public Boolean isOGRViolated{get;set;}
        Public Decimal ARViolated{get; set;}
        Public Decimal HyperCare{get; set;}
        Public Decimal Success_Offering{get; set;}
        Public Decimal ActivityType{get; set;}       //T06
        Public Decimal PrefferedWindow{get; set;}    //T06
        Public Decimal RCAPendingFlag{get; set;}     //T06
        Public Decimal Environment{get; set;}        //T06
        //</T02>
        //<T03>
        Public Decimal ACC{get;set;}
        Public Decimal P0Flag{get;set;}  // <T13> 
        //</T03>
        Public CaseWeightageWrapper(){
            cs = null;
            weightageId = null;
            band = 'S3';
            Web_Escalation_with_Manager_Callback= 0;
            Web_Escalation_other_than_manager_call = 0;
            GEMS_Escalation= 0;
            Web_Escalation_other_than_manager_call= 0;
            P1_Priority= 0;
            Live_Handoff = 0;
            Multiple_active_P1s_on_the_project= 0;
            GEMS_escalation_on_account= 0;
            Inactive_case= 0;
            Re_opened_case= 0;
            Strategic_customers_Same_Timezone= 0;
            Subscription_Beyond_120_Days= 0;
            P2_Priority= 0;
            P3_Priority= 0;
            Waiting_on_customer= 0;
            Waiting_on_Third_Party= 0;
            Waiting_on_Case_Team_R_D= 0;
            Non_Customer_Timezone_For_p2_and_p3= 0;
            Non_strategic_P2_And_P3= 0;     
            SameTimeZone = False;
            BCSP_Within_IR_SLA = 0;
            BCSPCaseIRMissed = 0;
            predictiveEscalatedP1 = 0;
            predictiveEscalatedNonP1 = 0;
            csmEscalated = 0;
            IR_Target_End_Time = null;
            //<T02>
            IRViolated=0;
            OGRViolated=0;
            IR30Mins=0;
            OGR30Mins=0;
            IR1Hr=0;
            OGR1Hr=0;
            ARViolated=0;
            isIRViolated=false;
            isOGRViolated=false;
            HyperCare = 0 ;
            Success_Offering = 0 ;
            ActivityType = 0;       //T06
            PrefferedWindow = 0;    //T06
            RCAPendingFlag = 0;     //T06
            Environment = 0;         //T06
            //</T02>
            //<T03>
            ACC=0;
            //</T03>
            P0Flag = 0;  // <T13>  
        }
    }
    //create  a wrapper with nme and timeremaininginmins
    ////<T02>
    public class MilestoneWrapper implements Comparable
    {
        public String name{get;set;}
        public Decimal TimeRemainingInMins{get;set;}
        public boolean IsViolated{get;set;}
        public Integer compareTo(Object obj) {
            MilestoneWrapper wrapperMilestones = (MilestoneWrapper)(obj);
            if (this.TimeRemainingInMins > wrapperMilestones.TimeRemainingInMins) {
                return 1;
            }
            if (this.TimeRemainingInMins == wrapperMilestones.TimeRemainingInMins) {
                return 0;
            }
            return -1;
        }
    }
    ////</T02>
}