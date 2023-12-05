/*
@created by       : Wasim Akram
@created on       : 20-Feb-2023
@Purpose          : Controller class for the LWC Component psaCreateShadowEngagementController

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public with sharing class psaCreateShadowEngagementController {
    public static globalApexManager GAM = new globalApexManager();
    /**
   * Method invoked to create the Shadow Engagement record
   * @param projId,isPrimary,isHomeLocation,psaMsaCode,state,country,city
   * @return return- String
   * @throws exception - NA
   */
   @AuraEnabled
   public static string createShadowEngagement(Id conId,String shadowObj,String focusArea,String schUrgency,
                                           String training,String comment){
       try {            
           psa_Shadow_Engagement_Request__c shadowEng = new psa_Shadow_Engagement_Request__c(Consultant_name__c = conId,
               Shadow_Objective__c = shadowObj, Shadow_Focus_Area__c = focusArea, Shadow_Scheduling_Urgency__c = schUrgency,
               Training_Certification__c = training, Comments_Details__c = comment, Shadow_Resource_Survey_Status__c = 'Pending',
               Shadow_Assignment_Survey_status__c = 'Pending', Submitted_Date__c = System.today());
           insert shadowEng;
           Contact con = new Contact(Id = conId, Current_Shadow_Resource__c = TRUE, Bypass_DateTime__c = System.now());
           update con;
           return shadowEng.Id;
       } 
       catch (Exception e) {GAM.CreateExceptionRecords('psaCreateShadowEngagementController.createShadowEngagement() -> ' + e.getCause(),e.getmessage(), conId); throw new AuraHandledException(e.getMessage());}
   }
}