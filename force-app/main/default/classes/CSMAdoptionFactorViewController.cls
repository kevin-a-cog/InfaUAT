/*
* Name			:	CSMAdoptionFactorViewController
* Author		:	Deva M
* Created Date	: 	20/09/2021
* Description	:	Class to do the business logic for PAF fucntionlity of plan

Change History
********************************************************************************************************************
Modified By			Date			Jira No.		Description					                         Tag
********************************************************************************************************************
Deva M				20/09/2021		AR-1575			Initial version.			                         N/A
Deva M				20/09/2021		AR-1823			Paff comments and chatter notificaitons		         N/A
Karthi G            20/09/2022      AR-2919         CSM Mamanger updates only trigger Due date changes   <T01>
Karthi G            13/02/2023      AR-3088         Mark the isAutomated  as true for PAF comments       <T02>


*/
public with sharing class CSMAdoptionFactorViewController {
    /*
   Method Name : getAdoptionFactor
   Description : This method will check if the record is in approval process or not
   Parameters	 : String strPlanId, record id from plan                   
   Return Type : boolean return true if plan locked
   */
   @AuraEnabled(cacheable=true)
   public static Boolean checkPlanLocked(String strPlanId) {
       Boolean isPlanLocked = false;
       if(String.isNotBlank(strPlanId)) {
           isPlanLocked = Approval.isLocked(String.escapeSingleQuotes(strPlanId));
       }
       return isPlanLocked;
   }

   /*
   Method Name : getAdoptionFactor
   Description : This method will fetch the adoption record and latest previous record
   Parameters	 : String strPlanId, record id from plan                   
   Return Type : list of queried adoption factor records
   */
   @AuraEnabled(cacheable=true)
   public static List<Adoption_Factor__c> getAdoptionFactor(String strPlanId) {
       String strCleanPlanId;
       List<Adoption_Factor__c> adoptionList = new List<Adoption_Factor__c>();
       //if the method receieve plan id
       if(String.isNotBlank(strPlanId)) {
           strCleanPlanId = String.escapeSingleQuotes(strPlanId);
           adoptionList = getRecords(strCleanPlanId);
       }
       return adoptionList;
   }
   /*
   Method Name : getAdoptionFactor
   Description : This method writted to reuse and to fetch the adoption record and latest previous record
   Parameters	 : String strPlanId, record id from plan                   
   Return Type : list of queried adoption factor records
   */
   public static List<Adoption_Factor__c> getRecords(String strPlanId) {
       return [SELECT Id, Product__c, Project__c, Engagement__c, CSM_Comments__c, Impact__c, Impact_Reason__c, CSM_Manager_Comments__c, Prior_Adoption_Factor__c, Plan__c, Status__c,Plan_Health_Score__c,Health_Color__c, LastModifiedDate,
       Prior_Adoption_Factor__r.Product__c, Prior_Adoption_Factor__r.Project__c, Prior_Adoption_Factor__r.Engagement__c, Prior_Adoption_Factor__r.CSM_Comments__c, Prior_Adoption_Factor__r.Impact__c, Prior_Adoption_Factor__r.Impact_Reason__c, Prior_Adoption_Factor__r.CSM_Manager_Comments__c, Prior_Adoption_Factor__r.Status__c,Prior_Adoption_Factor__r.Plan_Health_Score__c,Prior_Adoption_Factor__r.Health_Color__c, Prior_Adoption_Factor__r.LastModifiedDate FROM Adoption_Factor__c WHERE Plan__c = :strPlanId AND Status__c !='SystemInvalid' ORDER BY Createddate DESC, LastModifiedDate DESC LIMIT 1];
   }
   /*
   Method Name : updatePlanRecord
   Description : This method writted to reuse and to fetch the adoption record and latest previous record
   Parameters	 : String strPlanId, record id from plan   
               String strPlanFrequency, paf frequency value to calcualte next adoption factor value   
               String planHealthValue, health score value calculated based on 9 BOX modal for PAF                 
   Return Type : NA
   */
   @AuraEnabled(cacheable=false)
   public static void updatePlanRecord(String strPlanId,String strPlanFrequency,String planHealthValue,String planHealthReason){
       String strCleanPlanId;
       //<T01>
       CSM_Static_Value__mdt csv = CSM_Static_Value__mdt.getInstance('PAF_Due_Date_Users');
       Boolean isUpdateNextAdoptionDate =false;
       for(PermissionSetAssignment per:[select id, PermissionSetGroup.DeveloperName from PermissionSetAssignment where AssigneeId=:Userinfo.getUserId()]){
            if(per?.PermissionSetGroup?.DeveloperName==csv.Value__c){
                isUpdateNextAdoptionDate = true;
                break;
            }
       }       
       //</T01>
       if(String.isNotBlank(strPlanId)) {
           if(String.isNotBlank(strPlanFrequency)){
               strCleanPlanId = String.escapeSingleQuotes(strPlanId);
               Integer pafFrequence= Integer.valueOf(strPlanFrequency);
               Date nextAdoptionDate = System.today().addDays(pafFrequence);
               Plan__c planRecord = new Plan__c(Id=strCleanPlanId, Plan_status_picklist__c= planHealthValue);
               if(isUpdateNextAdoptionDate){  //<T01>
                    planRecord.Next_Expected_Adoption_Factor_Date__c = nextAdoptionDate;  //<T01>
               }
               if(String.isNotBlank(planHealthReason)){
                   planRecord.Plan_Status_Reason__c = planHealthReason;
               }
               update planRecord;
           }
       }             
   }

   /*
   Method Name : logPafComment
   Description : This method create plan comment on paf updated
   Parameters	: String strPlanId, record id from plan    
                   String planComment, comment value    
                   String chatterComemnt,if it's not blank post chatter to manager               
   Return Type : void
   */
   @AuraEnabled(cacheable=false)
   public static void logPafComment(String strPlanId,String planComment, String strChatterMessageValue) {
       String strCleanPlanId;
       if(String.isNotBlank(strPlanId)) {
           strCleanPlanId = String.escapeSingleQuotes(strPlanId);
           Plan_Comment__c planCommentRecord = CSMUtilities.createPlanComment(strCleanPlanId,planComment,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLANHEALTHREASON,true); //<T02>
           insert planCommentRecord;
           //if(String.isNotBlank(strChatterMessageValue)){
               //createChatterNotificationCSMManager(strCleanPlanId,strChatterMessageValue);
           //}
       }
   }


    /*
    Method Name : getRiskRecord
    Description : This method will fetch risk record
    Parameters	: String strRiskRecordId, record id from risk                  
    Return Type : Risk_Issue__c
    */
    @AuraEnabled(cacheable=false)
    public static Risk_Issue__c getRiskRecord(String strRiskRecordId) {
        String strCleanRecordId;
        Risk_Issue__c objRisk;
        if(String.isNotBlank(strRiskRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(strRiskRecordId);
            objRisk = [SELECT Id,Plan__c  from Risk_Issue__c WHERE Id=:strCleanRecordId];
        }
        return objRisk;
    }
   /*
   Method Name : createChatterNotificationCSMManager
   Description : This method create chatter post to CSM manager after CSM update
   Parameters	: String strPlanId, record id from plan    
               String chatterComemnt,if it's not blank post chatter to manager               
   Return Type : void
   
   public static void createChatterNotificationCSMManager(String strPlanId,String chatterComment) {
       Map<String,Plan_Team__c> planUserMap = new Map<String,Plan_Team__c>();
       planUserMap = CSMUtilities.getCSMUserByRole(new Set<Id>{strPlanId},new Set<String>{CSMUtilities.ROLE_CSM_MANAGER});   
       if(planUserMap.size()>0){
           // Bulk post to the object feeds.
           List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();       
           batchInputs.add(CSMUtilities.postChatBatchInstance(strPlanId,chatterComment,planUserMap.get(strPlanId+'~'+CSMUtilities.ROLE_CSM_MANAGER).User__c));
           if(!Test.isRunningTest() && batchInputs.size()>0){
               ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
           }
       }
   }*/

}