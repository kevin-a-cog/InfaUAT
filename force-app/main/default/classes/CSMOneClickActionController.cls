/*
 * Name			:	CSMOneClickActionController
 * Author		:	Deva M
 * Created Date	: 	10/08/2021
 * Description	:	Class to do the business logic for one click actions fucntionlity on plan

 Change History
 ****************************************************************************************************************************
 Modified By			Date			Jira No.		Description					                                    Tag
 *****************************************************************************************************************************
 Deva M					08/09/2021		N/A				Initial version.			                                    N/A
 Narpavi Prabu          01/03/2023     AR-3113       Display the CSA Resend Survey only when the enagment is active     T01
 Chaitanya T            08/25/2023     AR-3365       New Engagement Type MFA                                            T02
 Chaitanya T            11/27/2023     AR-3413       Survey icon not disappearing after all plan contacts responded     T03
 */
public with sharing class CSMOneClickActionController {
     /*
	 Method Name : getPlanTeamRecord
	 Description : This method get if the current user is part of plan team
	 Parameters	 : String planRecordId, record id from plan quick action on one click actions                
	 Return Type : Plan_Team__c record that has been queried
	 */
    @AuraEnabled(cacheable = false)
    public static Plan_Team__c getPlanTeamRecord(String planRecordId ) {        
        String strCleanRecordId;
        List<Plan_Team__c> planTeamRecords= new List<Plan_Team__c>();
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            planTeamRecords = [SELECT Id,CSM_Receive_Notifications__c, User__c, Plan__c  FROM Plan_Team__c where Plan__c =: strCleanRecordId AND User__c=:UserInfo.getUserId()];
        }
        return (planTeamRecords.size()>0? planTeamRecords[0]:null);
    }

    
    /*
	 Method Name : updatePlanTeamMember
	 Description : This method will update the plant team member with notifications as true
	 Parameters	 : String planRecordId, record id from plan quick action on one click actions                
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void updatePlanTeamMember(String planTeamMemberId,Boolean snoozeNotification) {        
        String strCleanRecordId;
         //If we have plan Team Member record Id
         if(String.isNotBlank(planTeamMemberId)) {
            strCleanRecordId = String.escapeSingleQuotes(planTeamMemberId);
            update (new Plan_Team__c(Id=strCleanRecordId,CSM_Receive_Notifications__c=snoozeNotification));
         }
    }

    /*
	 Method Name : getResendSurveyVisiblity
	 Description : This method is to get the resend Icon visiblity 
	 Parameters	 : String recordId, record id from plan quick action on one click actions                
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static resendSurveyWrapper getResendSurveyVisiblity(String recordId,String engRecordId) {   
        resendSurveyWrapper resendObj = new resendSurveyWrapper();     
        if (recordId <> null && Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Plan__c'){
            Plan__c planRec = [SELECT Id, Sub_Stage__c FROM Plan__c where Id=:recordId];
            String planSubStage = planRec.Sub_Stage__c;
            String strCleanEngRecordId;
            String strCleanPlanRecordId;
            String onboardingSurveyRT= System.label.CSMOnboardingRecordType;
            String outcomeSurveyRT= System.label.CSMOutcomeRecordType;
            String CSTSurveyRT= System.label.CSMCSTRecordType;
            String MFASurveyRT= System.label.CSMMFARecordType;
            String CSTEngagementRT= System.label.CSMCSTEngagementRecordType;
            
            Set<Id> targetOBSet = new Set<Id>();
            Set<Id> targetOutcomeSet = new Set<Id>();
            Set<Id> targetCSTSet = new Set<Id>();
            Set<Id> targetCSASendSurveySet = new Set<Id>();
            Set<Id> targetMFASendSurveySet = new Set<Id>();
            Set<Id> targetMFASet = new Set<Id>();
            
            Set<Id> actualOBSet = new Set<Id>();
            Set<Id> actualOutcomeSet = new Set<Id>();
            Set<Id> actualCSTSet = new Set<Id>();
            Set<Id> actualMFASet = new Set<Id>();
            //Build Dynamic query on engagement 
            String engagementRecordQuery='SELECT Id,RecType__c from Engagement__c where ';
            //<T01>
            Set<String> closedStatusSet = new Set<String>{'Close without Engagement'};
            if(String.isNotBlank(recordId)){
                strCleanPlanRecordId = String.escapeSingleQuotes(recordId);
            //</T01>
                engagementRecordQuery+='Plan__c =:recordId AND RecordType.DeveloperName=:CSTEngagementRT AND Status__c !=:closedStatusSet';
            }
            Engagement__c currentEngRec;//<T03>
            if(String.isNotBlank(engRecordId)){
                strCleanEngRecordId = String.escapeSingleQuotes(engRecordId);
                //engagementRecordQuery+=' AND Id=:strCleanEngRecordId';//<T03>
                currentEngRec = [SELECT Id, CST_Survey_Sent__c, MFA_Survey_Sent__c FROM Engagement__c WHERE Id=:strCleanEngRecordId];//<T03>
            }
           
            
            /**Get the Count of Closed CST Engagements for Button visiblity */
            //List<Engagement__c> closedEngagementList = new List<Engagement__c>([SELECT Id from Engagement__c where Plan__c =:recordId AND RecordType.DeveloperName=:CSTEngagementRT AND Status__c IN('Closed','Completed')]);
            List<Engagement__c> closedEngagementList = new List<Engagement__c>();
            closedEngagementList = Database.query(engagementRecordQuery);
            List<Engagement__c> closedCSAEngagementList = new List<Engagement__c>();
            List<Engagement__c> closedMFAEngagementList = new List<Engagement__c>();
            for(Engagement__c eng:closedEngagementList){//<T02> start
                if(eng.RecType__c == 'CSA'){
                    closedCSAEngagementList.add(eng);
                }else if(eng.RecType__c == 'MFA'){
                    closedMFAEngagementList.add(eng);
                }
            }//<T02> end
            List<String> mfaRolesList = new List<String>();//<T03> start
            mfaRolesList =  System.label.CSMMFASurveyRoles.split(';');
            List<String> csaRolesList = new List<String>();
            csaRolesList =  System.label.CSMCSTSurveyRoles.split(';');//</T03> end
            /**Get the applicable PlanContacts count for each Survey */
            for(Plan_Contact__c pCon :[SELECT Id,Onboarding_Survey_Count__c,Outcome_Survey_Count__c,CST_Survey_Count__c,MFA_Survey_Count__c,Role__c FROM Plan_Contact__c WHERE Plan__c =:recordId]){//<T03> added Role in SOQL
                if(pCon?.Onboarding_Survey_Count__c > 0){
                    targetOBSet.add(pCon.Id);
                }
                if(pCon?.Outcome_Survey_Count__c > 0){
                    targetOutcomeSet.add(pCon.Id);
                }
                //<T01>
                if(csaRolesList.contains(pCon?.Role__c) && (pCon?.CST_Survey_Count__c == null|| pCon?.CST_Survey_Count__c == 0 ))//<T03> condition to check Role
                {
                    targetCSASendSurveySet.add(pCon.Id);
                }

                if(csaRolesList.contains(pCon?.Role__c) && pCon?.CST_Survey_Count__c >0  ){//<T03> condition to check Role
                    targetCSTSet.add(pCon.Id);
                }
                //</T01>
                //<T02> start
                if(mfaRolesList.contains(pCon?.Role__c) && (pCon?.MFA_Survey_Count__c == null|| pCon?.MFA_Survey_Count__c == 0 ))//<T03> condition to check Role
                {
                    targetMFASendSurveySet.add(pCon.Id);
                }

                if(mfaRolesList.contains(pCon?.Role__c) && pCon?.MFA_Survey_Count__c >0  ){//<T03> condition to check Role
                    targetMFASet.add(pCon.Id);
                }
                //</T02> end
            }
            /**Get the Survey Responses Count for each survey */
            Integer csaSurveyResponsesCount = 0;//<T03>
            Integer mfaSurveyResponsesCount = 0;//<T03>
            for(Survey_Response__c respone : [SELECT Id,Plan_Contact__c,Plan__c,RecordType.DeveloperName,Plan_Contact__r.Role__c from Survey_Response__c where Plan__c =:recordId]){
                if(respone.RecordType.DeveloperName == onboardingSurveyRT && respone.Plan_Contact__c <> null){
                    actualOBSet.add(respone.Plan_Contact__c);
                }else if(respone.RecordType.DeveloperName == outcomeSurveyRT  && respone.Plan_Contact__c <> null){
                    actualOutcomeSet.add(respone.Plan_Contact__c);
                }else if(respone.RecordType.DeveloperName == CSTSurveyRT && respone.Plan_Contact__c <> null && csaRolesList.contains(respone.Plan_Contact__r?.Role__c)){//<T03> condition to check Role
                    actualCSTSet.add(respone.Plan_Contact__c);
                    csaSurveyResponsesCount++;//<T03>
                }else if(respone.RecordType.DeveloperName == MFASurveyRT && respone.Plan_Contact__c <> null && mfaRolesList.contains(respone.Plan_Contact__r?.Role__c)){//<T02> start //<T03> condition to check Role
                    actualMFASet.add(respone.Plan_Contact__c);
                    mfaSurveyResponsesCount++;//<T03>
                }//<T02> end
            }
            /**Compare the results to handle the visiblity */
            if(targetOBSet?.size() <> actualOBSet?.size() && (planSubStage == 'Design')){
                resendObj.showResendOnboardSurvey = true;
            }
            if(targetOutcomeSet?.size() <> actualOutcomeSet?.size() && (planSubStage == 'Optimize'|| planSubStage =='Expansion')){
                resendObj.showResendOutcomeSurvey = true;
            }
            if( targetCSASendSurveySet?.size() > 0 && targetCSTSet?.size()==0 && closedCSAEngagementList?.size() >0){//<T03> if condition changed
                resendObj.showSendCSTSurvey = true;
            }
            else if(closedCSAEngagementList?.size() >0 && (((targetCSASendSurveySet?.size()+targetCSTSet?.size())*closedCSAEngagementList?.size()) > csaSurveyResponsesCount)){//<T03> else if block condition changed
                resendObj.showResendCSTSurvey = true;
            }
            //if current engagement survey flag is set to false then display only send survey icon//<T03> start
            if(currentEngRec?.CST_Survey_Sent__c == false && (resendObj.showSendCSTSurvey == true || resendObj.showResendCSTSurvey == true)){
                resendObj.showSendCSTSurvey = true;
                resendObj.showResendCSTSurvey = false;
            }//</T03> end
            //<T02> start
            if(targetMFASendSurveySet?.size() > 0 && targetMFASet?.size()==0 && closedMFAEngagementList?.size()>0){//<T03> if condition changed
                resendObj.showSendMFASurvey = true;
            }
            else if(closedMFAEngagementList?.size() >0 && (((targetMFASendSurveySet?.size()+targetMFASet?.size())*closedMFAEngagementList?.size()) > mfaSurveyResponsesCount)){//<T03> else if block condition changed
                resendObj.showResendMFASurvey = true;
            }
            //if current engagement survey flag is set to false then display only send survey icon//<T03> start
            if(currentEngRec?.MFA_Survey_Sent__c == false && (resendObj.showSendMFASurvey == true || resendObj.showResendMFASurvey == true)){
                resendObj.showSendMFASurvey = true;
                resendObj.showResendMFASurvey = false;
            }//</T03> end
            //<T02> end
        }
        return resendObj;
    }

    @AuraEnabled(cacheable = false)
    public static String getPlanRecordId(String recordId){   
        String planId = '';
        if(recordId<> null){
            Engagement__c cstEngagement = [Select Id,Plan__c,Status__c from Engagement__c where Id =:recordId];
            planId = cstEngagement.Plan__c;
        }
        return planId;        
    }

    @AuraEnabled(cacheable = false)
    public static String getObjectName(String recordId){   
        String objectName = 'Plan__c';
         if(recordId <> null){
            objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
         }   
         return objectName;
    }

    /*
	 Method Name : CheckPlanContactforCSASurvey
	 Description : This method is to get the plan contact record 
	 Parameters	 : String planRecordId, record id from plan quick action on one click actions                
	 Return Type : n/a
	 */
    //<T01>
    @AuraEnabled(cacheable = false)
    public static Boolean CheckPlanContactforCSASurvey(String planRecordId ) { 
        Boolean checkPlanteamCSASurvey = false;    
        String strCleanRecordId;
        List<Plan_Contact__c> planContactRecords= new List<Plan_Contact__c>();
        List<String> rolesList = new List<String>();
        rolesList =  System.label.CSMCSTSurveyRoles.split(';');
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            planContactRecords = [SELECT Id, Role__c, Plan__c  FROM Plan_Contact__c where Plan__c =: strCleanRecordId AND Role__c IN :rolesList ];
        }
        if(planContactRecords.size()>0){
            checkPlanteamCSASurvey = true;

        }
        return  checkPlanteamCSASurvey;
        
    }
    //</T01>

    /*
	 Method Name : CheckPlanContactforMFASurvey
	 Description : This method is to get the plan contact record 
	 Parameters	 : String planRecordId, record id from plan quick action on one click actions                
	 Return Type : n/a
	 */
    //<T02>
    @AuraEnabled(cacheable = false)
    public static Boolean CheckPlanContactforMFASurvey(String planRecordId ) { 
        Boolean checkPlanteamMFASurvey = false;    
        String strCleanRecordId;
        List<Plan_Contact__c> planContactRecords= new List<Plan_Contact__c>();
        List<String> rolesList = new List<String>();
        rolesList =  System.label.CSMMFASurveyRoles.split(';');
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            planContactRecords = [SELECT Id, Role__c, Plan__c  FROM Plan_Contact__c where Plan__c =: strCleanRecordId AND Role__c IN :rolesList ];
        }
        if(planContactRecords.size()>0){
            checkPlanteamMFASurvey = true;
        }
        return  checkPlanteamMFASurvey;
    }
    //</T02>

    /** Wrapper class */
    public class resendSurveyWrapper{
        @AuraEnabled
        public Boolean showResendOnboardSurvey{get; set;}

        @AuraEnabled
        public Boolean showResendOutcomeSurvey{get; set;}

        @AuraEnabled
        public Boolean showResendCSTSurvey{get; set;} 

        @AuraEnabled
        public Boolean showSendCSTSurvey{get; set;}

        @AuraEnabled
        public Boolean showResendMFASurvey{get; set;} 

        @AuraEnabled
        public Boolean showSendMFASurvey{get; set;}

        public resendSurveyWrapper(){
            showResendOnboardSurvey = false;
            showResendOutcomeSurvey = false;
            showResendCSTSurvey = false;
            showSendCSTSurvey = false;
            showResendMFASurvey = false;
            showSendMFASurvey = false;
        }   
    }

}