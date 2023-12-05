/*
        Class:        selfServiceQuoteSummaryTriggerHandler
        @Author:        Nishit S
        @Created Date:  7/24/2023
        @Description:    SALESRT-15481
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/
public class selfServiceQuoteSummaryTriggerHandler {
        public static globalApexManager GAM = new globalApexManager();
    public static void selfServiceQuoteSummaryBeforeUpdate(Map<Id,Self_Service_Quote_Summary__c> newMap,Map<Id,Self_Service_Quote_Summary__c> oldMap){
    
    }
    
    public static void selfServiceQuoteSummaryAfterUpdate(Map<Id,Self_Service_Quote_Summary__c> newMap,Map<Id,Self_Service_Quote_Summary__c> oldMap){
        NotificationService.notify(newMap.values(), oldMap.values());
    }
}