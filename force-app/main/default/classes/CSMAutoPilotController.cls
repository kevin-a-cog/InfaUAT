/*
 * Name			:	CSMAutoPilotContorller
 * Author		:	Deva M
 * Created Date	: 	08/02/2021
 * Description	:	Class to do the business logic for Auto Pilot fucntionlity on plan

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					08/09/2021		N/A				Initial version.			 N/A
 Deva M					13/10/2021		AR-1751			Initial version.			 N/A
 Karthi G               22/08/2023		 AR-3222		Added changes to handle       T1
                                                        Assisted plans.			   
 */
public with sharing class CSMAutoPilotController {
    public final static String AUTOPILOT_APPROVAL_PROCESSNAME = 'CSM_Plan_Auto_Pilot_Approval_Process';
    public final static String CSM_MANAGER_QUEUE_NAME = 'INFA_CSM_Managers';
    
     /*
	 Method Name : createAutoPilotPlanComment
	 Description : This method create a plan comment record when plan is moved auto pilot
	 Parameters	 : String planRecordId, record id from plan quick action auto pilot 
                   String autoPilotComments, string of comments added in autopilot screen                   
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void createAutoPilotPlanComment(String planRecordId,String autoPilotComments, Boolean addInfo, String prevOwner) {        
        String strCleanRecordId;
        //If we have plan record Id
        
        if(String.isNotBlank(planRecordId)) {
            Plan__c plan = [Select Id,Owner.Name,Plan_status_picklist__c, (SELECT Id,Product__c, Project__c, Engagement__c from Adoption_Factor__r order by LastModifiedDate DESC LIMIT 1), (SELECT createddate,OldValue, NewValue FROM Histories where field='CSM_isAutoPilot__c' ORDER BY Createddate DESC LIMIT 2)  from Plan__c Where Id=:planRecordId];
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            if(addInfo){
                autoPilotComments = CSMPlanTriggerHelper.prepareAutoPilotComment(plan, autoPilotComments,false,prevOwner);
            }
            //Cretea Plan comment for Auto Pilot           
            insert CSMUtilities.createPlanComment(strCleanRecordId,autoPilotComments,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE);
        }
    }

    /*
	 Method Name : getPlanRecord
	 Description : This method will fetch the plan record and get the details
	 Parameters	 : String planRecordId, record id from plan quick action auto pilot                   
	 Return Type : Plan__c. plan record
	 */
    @AuraEnabled(cacheable = false)
    public static AutoPilotWrapper getPlanRecord(String planRecordId) {        
        String strCleanRecordId;
        LookupSearchResult[] lkp = new List<LookupSearchResult>();
        String selectedId;
        Plan__c planRecord=null;
        List<CSM_Autopilot_Criteria__mdt> mcs = CSM_Autopilot_Criteria__mdt.getall().values();
        Set<String> fields = new Set<String>();
        for(CSM_Autopilot_Criteria__mdt cac :mcs){
            if(cac.Criteria_Fields__c!='NA'){
                fields.addAll(cac.Criteria_Fields__c?.split(','));
            }
        }

        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId); 
            //T1 -- START --
            String query = 'SELECT Id ';
            if(fields.size()==0 || !fields.contains('OwnerId')){
                query += ',OwnerId, Owner.Name';
            }
            if(fields.size()>0 ){
                query += ', '+String.join(new List<String>(fields),',');
            }
            query +=' ,(SELECT Id, Type__c, Sub_Type__c from Plan_Comments__r WHERE  Type__c=\'Cassini\' AND Sub_Type__c=\'Auto Pilot\' AND Attention_Request_Status__c =\'New\') FROM Plan__c WHERE Id =: planRecordId';
            planRecord=Database.query(query);          
        }          
        
        if(mcs.size()>0){
            String type='';
            string strName ='';
            String defType='';
            string defName ='';
            for(CSM_Autopilot_Criteria__mdt cac :mcs){
                if(cac.DeveloperName != 'Default' && CSMUtilities.evaluateCondition(planRecord,cac.Condition__c)){
                    type = cac.Type__c;
                    strName = cac.Queue__c;
                }
                if(cac.DeveloperName == 'Default'){
                    defType = cac.Type__c;
                    defName = cac.Queue__c;
                }
            }
            if(type==''){
                type = defType;
                strName = defName;
            }
            if(type!=''){
                switch on type {
                    when 'Owner' {		
                        selectedId = planRecord.OwnerId;
                        String icon = String.valueof(planRecord.OwnerId).startsWith('00G')?'standard:orders':'standard:user';
                        lkp.add(new LookupSearchResult(planRecord.OwnerId, 'User', icon, planRecord.Owner.Name, planRecord.Owner.Name));
                    }	
                    when 'Queue' {		
                        Group g = [Select Id, Name from Group where Type='Queue' AND developerName = :strName LIMIT 1];
                        selectedId = g.Id;
                        lkp.add(new LookupSearchResult(g.Id, 'Group','standard:orders', g.Name, ''));
                    }
                    when 'User' {		
                        User u = [Select Id, Name from User where UserType='Standard' AND UserName = :strName LIMIT 1];
                        selectedId = u.Id;
                        lkp.add(new LookupSearchResult(u.Id, 'User', 'standard:user', u.Name, u.Name));
                    }
                }
                
            }
        }
        
        return new AutoPilotWrapper(lkp,selectedId,planRecord);
        // T1  -- END--
    }

     /*
	 Method Name : removeAutoPilot
	 Description : This method will remove the plan from autopilot
	 Parameters	 : String planRecordId, record id from plan quick action to remove auto pilot                 
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void removeAutoPilot(String planRecordId) {    
        List<Plan__c> planList = new List<Plan__c>();    
        String strCleanRecordId;
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            //Query Plan record and iterate over plan to get the selected user queue field
            for(Plan__c planRecord:[SELECT Id, User_Queue_Id__c, CSM_isAutoPilot__c,OwnerId FROM Plan__c WHERE Id =: strCleanRecordId]){
                Id recordOwner = String.isNotBlank(planRecord.User_Queue_Id__c) ? planRecord.User_Queue_Id__c: planRecord.OwnerId;
                //Autopilot = False, Autopilot status = NA. Update Owner based on the value selected prior - OwnerId =    User_Queue_Id__c
                planList.add(new Plan__c(Id=planRecord.Id, CSM_isAutoPilot__c = false, OwnerId=recordOwner,AutoPilot_Status__c='NA'));
            }
            if(planList.size()>0){
                update planList;
                //Create Plan comment when CSO removed the plan from autopilot
                //createAutoPilotPlanComment(planRecordId,'Plan is removed from Autpilot by '+UserInfo.getName());
            }
        }
    }

    /*
	 Method Name : submitAutoPilotRequest
	 Description : This method will submit the request to approval request
	 Parameters	 : String planRecordId, record id from plan quick action auto pilot 
                    String planOwnerId, ownerid of the plan record
                   String autoPilotRequestComments, string of auto pilot comments added in autopilot screen                   
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void submitAutoPilotRequest(String planRecordId, String autoPilotRequestComments) {    
        String strCleanRecordId;
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            Plan__c plan = [SELECT Id, OwnerId,Owner.name FROM Plan__c WHERE Id =: planRecordId];
            // Create an approval request for the plan
            Approval.ProcessSubmitRequest planApproval = new Approval.ProcessSubmitRequest();
            if(String.isNotBlank(autoPilotRequestComments)){
                planApproval.setComments(autoPilotRequestComments.substringAfter('Comments: '));
            }
            planApproval.setObjectId(strCleanRecordId);            
            // Submit on behalf of a plan owner as submitter
            if(String.valueof(plan.OwnerId).startsWith('00G')){
                planApproval.setSubmitterId(UserInfo.getUserId());
            }
            else{                
                planApproval.setSubmitterId(Id.valueOf(plan.OwnerId));
            }
            //Setting the approval process name
            planApproval.setProcessDefinitionNameOrId(AUTOPILOT_APPROVAL_PROCESSNAME);
            //Skipping the entry criteria of approval process
            planApproval.setSkipEntryCriteria(true);           
            // Submit the approval request for the account
            try{
                Approval.ProcessResult result = Approval.process(planApproval);
                // Verify the result and create plan comment
                if(result.isSuccess()){
                    createAutoPilotPlanComment(strCleanRecordId,autoPilotRequestComments,false,Plan.Owner.Name);
                }
            }catch(Exception e){

            }            
        }
    }

    //T1 - START
    public class AutoPilotWrapper{
        @AuraEnabled
        public LookupSearchResult[] selectedOption{get;set;}
        @AuraEnabled
        public String userorQueueId{get;set;}
        @AuraEnabled
        public Plan__c plan{get;set;}

        public AutoPilotWrapper(LookupSearchResult[] selectedOption, String userorQueueId,Plan__c plan){
            this.selectedOption = selectedOption;
            this.userorQueueId = userorQueueId;
            this.plan = plan;
        }
    }
    //T1 - END

    @invocableMethod(Label='Create Comment' description='Create AutoPilot Comment')
    public static void createPlanComment(List<Params> params){
        createAutoPilotPlanComment(params[0].PlanId,params[0].autoPilotComments,params[0].addInfo,params[0].prevOwner);
    }

    public class Params{
        @InvocableVariable
        public String PlanId;
        @InvocableVariable
        public String autoPilotComments;
        @InvocableVariable
        public Boolean addInfo;
        @InvocableVariable
        public String prevOwner;
    }
}