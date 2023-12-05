/*
* Name      :  CSMPlanTriggerHelper
* Author    :  Pavithra V
* Created Date  :   08/20/2021
* Description  :  Helper class which implements the logic on Plan Object

Change History
***********************************************************************************************************************************
Modified By             Date        Jira No.             Description                                            Tag
***********************************************************************************************************************************
Deva M              08-10-2021      N/A             Plan Team Automation to add manager
Deva M              12-10-2021      AR-1751         capture the auto pilot approval comments
Pavithra V          12-06-2021      N/A             update logic for Plan Visiblity (Internal/External)
Harshita J          29-06-2022      AR-2791         Handled bulk Plan updation on createPlanTeamMember           <t1>
Karthi              27/07/2022      AR-2812         Added business value to STAGE_CSMSIGNOFF                     <T2>
Harshita J          11/09/2022      AR-2889         Fixed the prod issue                                         <T3>
Karthi G            22/08/2023		AR-3222		    Added changes to handle                                       T4
                                                    Assisted plans.	
***********************************************************************************************************************************
*/
public class CSMPlanTriggerHelper {
    
    private final static Set<String> PRIORSTAGES_ONBOARD = new Set<String>{'Pre-Onboard','On-board'};
    private final static Set<String> CURRENTSTAGES_ONBOARD = new Set<String>{'Design','Development','Technical Value','Business Value','Optimize','Expansion'};
    private final static Set<String> PRIORSTAGES_OUTCOME = new Set<String>{'Pre-Onboard','On-board','Design','Development','Technical Value','Business Value'};
    private final static Set<String> CURRENTSTAGES_OUTCOME = new Set<String>{'Optimize','Expansion'};
    private final static Set<String> STEP_STUTUS = new Set<String>{'Approved','Rejected'};

    private final static Set<String> STAGE_CSMSIGNOFF = new Set<String>{'Business Value','Expansion'}; //<T2>
    public final static String MANAGERSIGNOFF_APPROVAL_PROCESSNAME = 'CSM_Request_CSM_ManagerSign_off';
    public final static String PLANCOMPLETE_APPROVAL_PROCESSNAME ='Request_CSO_to_complete_Plan';

    private final static String AUTOPILOT_STATUS_APPROVED = 'Approved';
    private final static String AUTOPILOT_STATUS_REJECTED = 'Rejected';
    private final static String AUTOPILOT_STATUS_NA = 'NA';
    private final static String AUTOPILOT_STATUS_SUBMITTED_APPROVAL = 'Submitted for Approval';
    public final string ADOPTION_INITIAL_STATUS ='Waiting for CSM Input';

    public final static String PLAN_STAGE_CHANGED = 'Plan_Stage_Changed';  
    public final static String  PLAN_IS_CLOSED = 'Plan_is_closed';  
    public final static String  PLAN_REMOVE_AUTOPILOT = 'Plan_Remove_Autopilot';  
     /*
    Method Name : processBefoprocessAfterUpdatereUpdate
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Plan__c> newList,Map<Id,Plan__c> oldMap){
    
        List<String> onboardingSurveyPlanIds = new List<String>();
        List<String> outcomeSurveyPlanIds = new List<String>();
        Set<Id> ownerUpdatedPlanSet = new Set<Id>();
        Set<Id> planRecordIdSet = new Set<Id>();
        Map<Id,Id> oldUserIdMap = new Map<Id,Id>();
        Set<Id> managerSignOffPlanIdSet = new Set<Id>();
        Set<Id> reqCompletePlanIdSet = new Set<Id>();
        Map<Id,Plan__c> mapCommentsPlan = new Map<Id,Plan__c>();
        for(Plan__c plan : newList){
            if(CURRENTSTAGES_ONBOARD.contains(plan.Sub_Stage__c)  && PRIORSTAGES_ONBOARD.contains(oldMap.get(plan.Id).Sub_Stage__c)){
              onboardingSurveyPlanIds.add(plan.Id);    
            }
            if(CURRENTSTAGES_OUTCOME.contains(plan.Sub_Stage__c) && PRIORSTAGES_OUTCOME.contains(oldMap.get(plan.Id).Sub_Stage__c)){
                outcomeSurveyPlanIds.add(plan.Id);
            }
            if(plan.OwnerId <> oldMap.get(plan.Id).OwnerId && plan.OwnerID.getsobjecttype() == User.sobjecttype){
                ownerUpdatedPlanSet.add(plan.Id);
            }

            //Pavithra - Send sign off email to CSM Manager
            if(STAGE_CSMSIGNOFF.contains(plan.Sub_Stage__c) && !STAGE_CSMSIGNOFF.contains(oldMap.get(plan.Id).Sub_Stage__c) && plan.Sub_Stage__c <> oldMap.get(plan.Id).Sub_Stage__c && plan.Csm_Manager__c <> null && plan.CSM_Manager_Signoff__c == false){
                managerSignOffPlanIdSet.add(plan.Id);
            }
            
            if(plan.Plan_Completeness_Status__c == 'Submitted for Approval' && plan.Plan_Completeness_Status__c <> oldMap.get(plan.Id).Plan_Completeness_Status__c && (plan.OwnerId == UserInfo.getUserId() || plan.CreatedById == UserInfo.getUserId()) && Approval.isLocked(plan.Id) == false){
                reqCompletePlanIdSet.add(plan.Id);
            }
            //Deva: Check if the auto pilot is approved or not
            if(oldMap.get(plan.Id)!=NULL && oldMap.get(plan.Id).AutoPilot_Status__c != plan.AutoPilot_Status__c && 
                String.isNotBlank(plan.AutoPilot_Status__c) && (plan.AutoPilot_Status__c.equals(AUTOPILOT_STATUS_APPROVED)  || plan.AutoPilot_Status__c.equals(AUTOPILOT_STATUS_NA)) &&
                String.isNotBlank(oldMap.get(plan.Id).AutoPilot_Status__c) && oldMap.get(plan.Id).AutoPilot_Status__c.equals(AUTOPILOT_STATUS_SUBMITTED_APPROVAL)){
                    planRecordIdSet.add(plan.Id);
                    oldUserIdMap.put(plan.Id,oldMap.get(plan.Id).OwnerId);
            }
        }
        
        if(onboardingSurveyPlanIds?.size() >0){
          CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(onboardingSurveyPlanIds, CSMSendSurveyToPlanContacts.ONBOARDING_SURVEY);
        }
        if(outcomeSurveyPlanIds?.size() >0){
            CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(outcomeSurveyPlanIds, CSMSendSurveyToPlanContacts.OUTCOME_SURVEY);
        }
        if(ownerUpdatedPlanSet?.size() >0){
            createPlanTeamMember(ownerUpdatedPlanSet);
        }
        
        if(managerSignOffPlanIdSet?.size() > 0){
            //submitPlanforApproval(managerSignOffPlanIdSet,MANAGERSIGNOFF_APPROVAL_PROCESSNAME);
            sendManagerSignOffEmail(managerSignOffPlanIdSet);
        }
        if(reqCompletePlanIdSet?.size() > 0){
            submitPlanforApproval(reqCompletePlanIdSet,PLANCOMPLETE_APPROVAL_PROCESSNAME);
        }
        //Deva: check if the plan record is submitted for approval process and capture the comments from approval process instance
        if(planRecordIdSet.size()>0){
            captureApprovalComments(planRecordIdSet,oldUserIdMap);
        }
        
         updatePlanVisiblity(newList,oldMap);/**<T03>**/
       
        NotificationService.notify(newList, oldMap);
        createPlanInternalComment(newList, oldMap);
        
    }
    /*
   Method Name : createPlanInternalComment
   Description : This method will create plan comments at different conditions.
   Parameters   : String strComment, merged comment text form email template
                   Id planRecordId, plan record id
   Return Type : Plan_Comment__c, Plan comment instance
  */
    public static void createPlanInternalComment(List<Plan__c> newList,Map<Id,Plan__c> oldMap){
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        String  userTimeZoneName = CSMUtilities.getUserTimeZone();
        Map<String,EmailTemplate> mapEmailTemplates = new Map<String,EmailTemplate>();
        if(UserInfo.getUserType() == 'Standard'){
            mapEmailTemplates = CSMUtilities.getEmailTemplate();
        }
        for(Plan__c objPlan:newList){
            //AR-1734  Create Plan Comments            
            Plan__c objOldPlan = oldMap.get(objPlan.Id);
            //When the plan stage updated
            if(String.isNotBlank(objPlan.Stage__c) && objOldPlan.Stage__c != objPlan.Stage__c  && mapEmailTemplates.get(PLAN_STAGE_CHANGED)!=null ){
                String mergedText = csmPlanQuickActionController.renderTemplate(objPlan.Id, mapEmailTemplates.get(PLAN_STAGE_CHANGED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                lstPlanComments.add(preparePlanPlanComment(mergedText,objPlan.Id));
            }
            //When plan closed
            if(objPlan.Closure_Date__c !=null && objOldPlan.Closure_Date__c  != objPlan.Closure_Date__c  && mapEmailTemplates.get(PLAN_IS_CLOSED)!=null ){
                String mergedText = csmPlanQuickActionController.renderTemplate(objPlan.Id, mapEmailTemplates.get(PLAN_IS_CLOSED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                lstPlanComments.add(preparePlanPlanComment(mergedText,objPlan.Id));
            }
            //When plan completed
            if(String.isNotBlank(objPlan.Closing_Reason__c) && objPlan.Status__c !=null && objOldPlan.Status__c != objPlan.Status__c && objOldPlan.Status__c.equals('Complete')  && mapEmailTemplates.get(PLAN_IS_CLOSED)!=null ){
                String mergedText = csmPlanQuickActionController.renderTemplate(objPlan.Id, mapEmailTemplates.get(PLAN_IS_CLOSED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                lstPlanComments.add(preparePlanPlanComment(mergedText,objPlan.Id));
            }
            
        }
        //<T4>
        for(Plan__c objPlan:[Select Id,Owner.Name,Plan_status_picklist__c,CSM_isAutoPilot__c, (SELECT Id,Product__c, Project__c, Engagement__c from Adoption_Factor__r order by LastModifiedDate DESC LIMIT 1), (SELECT createddate,OldValue, NewValue FROM Histories where field='CSM_isAutoPilot__c' ORDER BY Createddate DESC LIMIT 2)  from Plan__c Where Id IN :newList]){
            Plan__c objOldPlan = oldMap.get(objPlan.Id);
            //When autopilot removed
            if(!objPlan.CSM_isAutoPilot__c && objOldPlan.CSM_isAutoPilot__c  != objPlan.CSM_isAutoPilot__c ){                
                String mergedText = 'Plan is no longer in autopilot mode';
                mergedText = prepareAutoPilotComment(objPlan, mergedText, true,objPlan.Owner.Name);
                lstPlanComments.add(preparePlanPlanComment(mergedText,objPlan.Id));
            } 
        }
        //</T4>

        //AR-1734  
        if(lstPlanComments.size()>0){     
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){     
                System.enqueueJob(new CSMCreatePlanCommentsQueueable(lstPlanComments));
            }
        }
    }

    /*
   Method Name : preparePlanPlanComment
   Description : This method returns the Plan Comment for Plan.
   Parameters   : String strComment, merged comment text form email template
                   Id planRecordId, plan record id
   Return Type : Plan_Comment__c, Plan comment instance
  */
    public static Plan_Comment__c preparePlanPlanComment(String strComment,Id planRecordId){
        return CSMUtilities.createPlanComment(planRecordId,
                                                strComment,
                                                CSMUtilities.STATUS_SUBMITTED,
                                                CSMUtilities.TYPE_INTERNAL,
                                                CSMUtilities.SUBTYPE_PLAN,
                                                true
                                                );
    }
    
    /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterInsert(List<Plan__c> newList,Map<Id, Plan__c> oldMap){
        //Create PAf record on creating of plan record
        List<Adoption_Factor__c> adoptionRecordsToInsert =  new List<Adoption_Factor__c>();
        Adoption_Factor__c objPaf;

        for(Plan__c objPlan:newList){
            objPaf = new Adoption_Factor__c(Plan__c=objPlan.Id,Status__c=ADOPTION_INITIAL_STATUS);
            objPaf.Product__c = 'Good';
            objPaf.Project__c = 'Good';
            objPaf.Engagement__c = 'Good';
            objPaf.Impact__c = 'Low';
            adoptionRecordsToInsert.add(objPaf);
        }
        if(adoptionRecordsToInsert.size()>0){
            insert adoptionRecordsToInsert;
        }
        NotificationService.notify(newList, oldMap);
    }
    
    /**<T03>
    Method Name : updatePlanVisiblity
    Description : This method handles plan visiblity (Internal/External)
    Parameters  : List of new Plan Team instance           
    Return Type : n/a
    */  
    public static void updatePlanVisiblity(List<Plan__c> newList, Map<Id,Plan__c> oldMap){
        Set<Id> internalPlanIdSet = new Set<Id>();
        List<Objective__c> lObjectives = new List<Objective__c>();
        List<Milestone__c> lMilestones = new List<Milestone__c>();
        
        for(Plan__c plan : newList){
            if(plan.Is_Internal__c && plan.Is_Internal__c <> oldMap.get(plan.Id).Is_Internal__c){
                internalPlanIdSet.add(plan.Id);
            }
        }
        if(internalPlanIdSet.size()>0){
            /** Update the related Objectives/Milestones to Internal **/
            for(Objective__c obj : [Select Id,Is_Internal__c from Objective__c where Plan__c in :internalPlanIdSet and Is_Internal__c = false]){
                obj.Is_Internal__c = true;
                lObjectives.add(obj);
            }
            
            for(Milestone__c milestone : [Select Id,Is_Internal__c from Milestone__c where Plan__c in :internalPlanIdSet and Is_Internal__c = false]){
                milestone.Is_Internal__c = true;
                lMilestones.add(milestone);
            }
        }
        
        if(lObjectives?.size()>0){
            update lObjectives;
        }
        if(lMilestones?.size()>0){
            update lMilestones;
        }
    }
    
    
    /*
    Method Name : captureApprovalComments
    Description : This method will create plan comments records under plan from approval comments
    Parameters  : List of new Plan Team instance and old map                
    Return Type : n/a
    Author      : Deva
    */  
    public static void captureApprovalComments(Set<Id> planRecordIdSet, Map<Id,Id> oldUserIdMap){     
        List<Plan_Comment__c> planCommentList = new List<Plan_Comment__c>();
        Map<Id,String> usrMap = new Map<Id,String>();
        for(User u:[Select id, Name from user where Id IN :oldUserIdMap.values()]){
            usrMap.put(u.Id, u.Name);
        }
        for(Group u:[Select id, Name from Group where Type='Queue' AND Id IN :oldUserIdMap.values()]){
            usrMap.put(u.Id, u.Name);
        }
        //Query related process steps to capture the latest approval/Reject comments 
        for(Plan__c plan:[SELECT id,Auto_Pilot_Approver_Name__c,Owner.Name,Plan_status_picklist__c, (SELECT Id,Comments,    ProcessInstanceId,StepStatus FROM ProcessSteps ORDER BY CreatedDate DESC) ,(SELECT Id,Product__c, Project__c, Engagement__c from Adoption_Factor__r order by LastModifiedDate DESC LIMIT 1), (SELECT createddate,OldValue, NewValue FROM Histories where field='CSM_isAutoPilot__c' ORDER BY Createddate DESC LIMIT 2) From Plan__c WHERE Id IN :planRecordIdSet]){
            if(plan.ProcessSteps!=null && plan.ProcessSteps.size()>0){
                String latestApprovalComment ='';
                if(String.isNotBlank(plan.ProcessSteps[0].StepStatus) && plan.ProcessSteps[0].StepStatus.equals(AUTOPILOT_STATUS_APPROVED)){
                    latestApprovalComment = 'Request has been approved by '+plan.Auto_Pilot_Approver_Name__c+', Plan is now in AutoPilot.';
                    latestApprovalComment = prepareAutoPilotComment(plan, latestApprovalComment, false, usrMap?.get(oldUserIdMap?.get(plan.Id)));//<T4>
                }
                if(String.isNotBlank(plan.ProcessSteps[0].StepStatus) && plan.ProcessSteps[0].StepStatus.equals(AUTOPILOT_STATUS_REJECTED)){
                    //If blank comments then generating plan comments as stepstatus
                    String rejectComment = String.isNotBlank(plan.ProcessSteps[0].Comments) ? plan.ProcessSteps[0].Comments:plan.ProcessSteps[0].StepStatus;  
                    latestApprovalComment = 'Request has been Rejected by '+plan.Auto_Pilot_Approver_Name__c+', '+rejectComment;
                }                              
                planCommentList.add(CSMUtilities.createPlanComment(plan.Id,latestApprovalComment,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }
        }
        //Now insert the records
        if(planCommentList.size()>0){
            insert planCommentList;
        }
    }
      /*
    Method Name : processBeforeUpdate
    Description : Methods will be called on before update
    */
    public void processBeforeUpdate(List<Plan__c> newList,Map<Id,Plan__c> oldMap){
        Group g = [Select Id from Group Where Type ='Queue' AND DeveloperName='AutoPilot' LIMIT 1];
        for(Plan__c plan : newList){
            
            if(plan.Plan_Completeness_Status__c == 'Submitted for Approval' && plan.Plan_Completeness_Status__c <> oldMap.get(plan.Id).Plan_Completeness_Status__c && FeatureManagement.checkPermission('CSOUser')){
                plan.Plan_Completeness_Status__c = null;
                plan.Status__c = 'Complete';
            }

            if(plan.Status__c == 'Complete'){
                plan.Closure_Date__c = System.today();
            }
             //AR-2446
            //When CSO/CSM Manager update the freqency update the date accordingly
            if(oldMap.containsKey(plan.Id)){
                Plan__c oldPlan = oldMap.get(plan.Id);
                if(oldPlan.PAF_Frequency__c!= plan.PAF_Frequency__c){
                    Date nextAdoptionDate = System.today().addDays(Integer.valueOf(plan.PAF_Frequency__c));
                    plan.Next_Expected_Adoption_Factor_Date__c = nextAdoptionDate;
                }
            }

            if(oldMap.containsKey(plan.Id) && oldMap.get(plan.Id).CSM_isAutoPilot__c != plan.CSM_isAutoPilot__c && plan.CSM_isAutoPilot__c && g!=null){
                plan.OwnerId = g?.Id;
            }
        }        
    }
    /*
    Method Name : processBeforeInsert
    Description : Methods will be called on before insert
    */
    public void processBeforeInsert(List<Plan__c> newList){
        Integer pafFrequence= Integer.valueOf(Label.CSM_Default_PAF_Next_Adoption_Frequency);  
        for(Plan__c plan : newList){
            Date nextAdoptionDate = System.today().addDays(pafFrequence);
            plan.Next_Expected_Adoption_Factor_Date__c = nextAdoptionDate;
            plan.PAF_Frequency__c = pafFrequence;
        }        
    }

    
    /*
    Method Name : createPlanTeamMember
    Description : Methods to create the Plan Team Members when the Plan owner is changed
    */
    public static void createPlanTeamMember(Set<Id> planIdSet){
        List<Plan_Team__c> planTeamInsertList = new List<Plan_Team__c>();
        Map<String,Plan_Team__c> existingPlanTeamMap = new Map<String,Plan_Team__c>();
        Map<String,String> existingPlanAndPlanTeamMap = new Map<String,String>();
        Map<String,Plan__c> planUserEmailMap = new Map<String,Plan__c>();
        //Map Exisitng Plan Team members based on email
        for(Plan_Team__c pTeam : [SELECT Id,Plan__c,User_Email__c from Plan_Team__c where Plan__c=:planIdSet]){
            existingPlanTeamMap.put(pTeam.User_Email__c+'Plan Id :'+pTeam.Plan__c,pTeam); //<t1></t1>
        }
        //Query Plan Recrods and create/Update planTeam menber with plan team 
        for(Plan__c plan : [SELECT Id, TYPEOF Owner WHEN User THEN Id, Email, ManagerId, Manager.Email END FROM Plan__c where Id in:planIdSet]){
            //Prepare a map for manager instance
            planUserEmailMap.put(plan.Owner.Email,plan);
            User usr;
            if(plan.Owner instanceof User){
                usr = plan.Owner;
            }
            string keyEmailPlan;
            if(usr!=null){
                keyEmailPlan = usr.Email+'Plan Id :'+plan.id; //<t1></t1>
                //Check if the plan team member already there then update team member role
                if(existingPlanTeamMap.containsKey(keyEmailPlan) && existingPlanTeamMap.get(keyEmailPlan)!=null && existingPlanTeamMap.get(keyEmailPlan).Plan__c == plan.id){ //<t1></t1>               
                    Plan_Team__c obj = new Plan_Team__c(Id=existingPlanTeamMap.get(keyEmailPlan).Id,Role__c = CSMUtilities.ROLE_CSM);
                    obj.Primary__c = true; 
                    planTeamInsertList.add(obj);
                }else{//Create plan team member   
                    Plan_Team__c obj = CSMUtilities.createPlanTeamMember(plan.Id,usr.Email,usr.Id,CSMUtilities.ROLE_CSM);
                    obj.Primary__c = true;  
                    planTeamInsertList.add(obj);
                }
            }

            if(usr!=null && usr.ManagerId!=null){
                keyEmailPlan = usr.Manager.Email+'Plan Id :'+plan.id; //<t1></t1>
               //Check if the plan team member already there then update team member role
                if(existingPlanTeamMap.containsKey(keyEmailPlan) && existingPlanTeamMap.get(keyEmailPlan)!=null && existingPlanTeamMap.get(keyEmailPlan).Plan__c == plan.id){ //<t1></t1>               
                    Plan_Team__c obj = new Plan_Team__c(Id=existingPlanTeamMap.get(keyEmailPlan).Id,Role__c = CSMUtilities.ROLE_CSM_MANAGER);
                    obj.Primary__c = true; 
                    planTeamInsertList.add(obj);
                }else{//Create plan team member   
                    Plan_Team__c obj = CSMUtilities.createPlanTeamMember(plan.Id,usr.Manager.Email,usr.ManagerId,CSMUtilities.ROLE_CSM_MANAGER);
                    obj.Primary__c = true;  
                    planTeamInsertList.add(obj);
                }
            }
        } 
       
        //Now upsert plan team member     
        if(planTeamInsertList?.size()>0){
           CSMPlanTeamTriggerCheckRecursive.bypassValidationForupsert = false;//<t3/>
           upsert planTeamInsertList;
        }
    }  

    /*
    Method Name : submitPlanforApproval
    Description : Methods to Submit Plan for CSM Manager Sign off
    */
    public static void submitPlanforApproval(Set<Id> planIdSet , String processDefinitionName){
    
        List<Approval.ProcessSubmitRequest> lApprovalRequests = new List<Approval.ProcessSubmitRequest>();

        for(Id planId : planIdSet){
            // Create an approval request for the plan
            Approval.ProcessSubmitRequest planApproval = new Approval.ProcessSubmitRequest();
            planApproval.setComments('Submitting plan for Approval.');
            planApproval.setObjectId(planId);            
            // Submit on behalf of a specific submitter
            planApproval.setSubmitterId(UserInfo.getUserId());
            //Setting the approval process name
            planApproval.setProcessDefinitionNameOrId(processDefinitionName);
            //Skipping the entry criteria of approval process
            planApproval.setSkipEntryCriteria(true); 

            lApprovalRequests.add(planApproval);
        }

        if(lApprovalRequests?.size()>0){
            // Submit the approval request for the account
            List<Approval.ProcessResult> result = Approval.process(lApprovalRequests);

            //Get the List of plans and unlock the records for CSMs to edit
            List<Plan__c> planList = [Select Id from Plan__c where Id in:planIdSet];
            Approval.UnLockResult[] lrList = Approval.Unlock(planList, false);

            for(Approval.UnlockResult lr : lrList) {
                if (lr.isSuccess()) {
                    System.debug('Successfully Unlocked Plan with ID: ' + lr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Plan fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

    }

    public static void sendManagerSignOffEmail(Set<Id> planIdSet){
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'CSM_Approval_Request_for_CSM_Manager_Signoff'];
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

        for(Plan__c plan : [Select Id, Name, (SELECT User__c,User__r.Email from Plan_Team__r where Role__c = :CSMUtilities.ROLE_CSM_MANAGER AND Primary__c=true AND User__c!=null ORDER BY Lastmodifieddate DESC LIMIT 1) from Plan__c where Id in:planIdSet]){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            Id managerId;
            String email;
            if(plan.Plan_Team__r !=null && plan.Plan_Team__r.size()>0){
                managerId = plan.Plan_Team__r[0].User__c;
                email = plan.Plan_Team__r[0].User__r.Email;
            }

            if(managerId!=null){
                message.setTargetObjectId(managerId); 
                message.setSenderDisplayName(UserInfo.getName());             
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                message.setTemplateID(emailTemplate.Id); 
                message.setSubject('Requesting CSM Manager sign off for plan - '+plan.Name); 
                message.setHtmlBody(Messaging.renderStoredEmailTemplate(emailTemplate.Id,null,plan.Id).gethtmlBody()); //This is for the merge fields in template to work
                message.toAddresses = new String[] {email};
                messages.add(message);
            }
        }

        if(messages?.size()>0 && !Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('CSM Manager Email : '+ results);
        }
    }

    //<T4>
    public static String prepareAutoPilotComment(Plan__c plan, String comment, Boolean isRemoval, String owner){
       // String owner = (isRemoval || oldPlan==null)?plan?.Owner.Name:oldPlan?.Owner.Name;
        comment += '<br> Plan Owner : '+owner;
        if(plan?.Adoption_Factor__r !=null && plan?.Adoption_Factor__r.size()>0){
            Adoption_Factor__c af = plan.Adoption_Factor__r[0];
            comment += '<br> PAF Product : '+af.Product__c;
            comment += '<br> PAF Project : '+af.Project__c;
            comment += '<br> PAF Engagement : '+af.Engagement__c;
        }
        if(plan?.Plan_status_picklist__c!=null && plan?.Plan_status_picklist__c!=''){
            comment += '<br> Health Score : '+plan.Plan_status_picklist__c;
        }
        if(!isRemoval){
            comment += '<br> Auto Pilot start date : '+System.now();
        }
        if(isRemoval && plan?.Histories!=null && plan?.Histories.size()>0){
            for(Plan__History ph : plan.Histories){
                if(ph.OldValue==false && ph.NewValue==true){
                    comment += '<br> Auto Pilot start date : '+ph.CreatedDate;
                    break;
                }
                
            }
            comment += '<br> Auto Pilot End date : '+System.now();
            
        }

        return comment;
    }
    //</T4>
}