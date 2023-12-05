/*
@created by       : RANJAN KISHORE
@created on       : 05/28/2021
@Purpose          : Controller class for the aura component PSA_Sync_PO_Numbers.

Change History
**************************************************************************************************************************
ModifiedBy          |  Date       |     Requested By  | Description                            |  Jira No.      | Tag No:
Rohit Niranjanamath |18 Nov '23   | PSA Nov Build 23  | RevOps access Issues                   |  PSA-3240      | <T1>
***************************************************************************************************************************
*/
public without sharing class PSA_Sync_PO_Number_Controller {
    /**    
    * @description - Controller method called on click of Sync PO Number button on project record
    * @param recordId - record ID
    * @throws exception - NA
    */
    @AuraEnabled
    public static String syncPONumbers(String recordId){
        String message;
        if(FeatureManagement.checkPermission('PSA_Operations') || FeatureManagement.checkPermission('PSA_Deal_Desk')){ //<T1>
            
            try {
                List<sObject> sObjectList = new List<sObject>();
                List<pse__Resource_Request__c> resReqList = [Select Id,Opportunity_Product_Assigned__c, PSA_Opportunity_Product__c,
                                                             PSA_OM_PO_Number__c,PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c 
                                                             from pse__Resource_Request__c where pse__Project__c=:recordId 
                                                             and PSA_Opportunity_Product__c!=null and PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c !=null];
            
                List<pse__Milestone__c> milestoneList = [Select Id,PSA_OM_Opportunity_Product_Assigned__c, PSA_Opportunity_Product__c,
                                                         PSA_OM_PO_Number__c, PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c
                                                         from pse__Milestone__c  where pse__Project__c=:recordId 
                                                         and PSA_Opportunity_Product__c!=null and PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c!=null];

                if(!resReqList.isEmpty()){
                    for(pse__Resource_Request__c resReq : resReqList){
                        resReq.PSA_OM_PO_Number__c = resReq.PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c;
                        sObjectList.add(resReq);
                    } 
                }
                if(!milestoneList.isEmpty()){
                    for(pse__Milestone__c milestoneRec : milestoneList){
                        milestoneRec.PSA_OM_PO_Number__c = milestoneRec.PSA_Opportunity_Product__r.Purchase_Order_PO_Number__c;
                        sObjectList.add(milestoneRec);
                    }   
                }
                if(!sObjectList.isEmpty()){
                    Database.SaveResult[] saveResultList = Database.update(sObjectList);
                    message = 'Success:Resource Request/Milestone records under this project are updated with PO numbers.';
                      
                }else{
                    message ='Info:There are no Resource Requests/Milestones associated with an Opportunity product under this Project.';
                }
                
            } catch (Exception e) {
                message = 'Error:'+e.getMessage();
            }
        }else{
            message = 'Info:You do not have the ability to sync PO Numbers to Resource Requests/Milestones.';
        }
        return message;
    } 
}