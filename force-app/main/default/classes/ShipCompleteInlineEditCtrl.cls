/****************************************************************************************************************
Class:          ShipCompleteInlineEditCtrl
@Author:        vsabbell
@Created Date:  8/7/2019.
@Description:   Controller For ShipCompleteInlineEdit Lightning Component. Retrieves and Updates fulfillment data. 
******************************************************************************************************************
Change History
*******************************************************************************************************************/

public with sharing class ShipCompleteInlineEditCtrl {
    public ShipCompleteInlineEditCtrl() { 
 
    }
    @AuraEnabled 
    public static List<Fulfillment_Line__c> getFulfillmentLines(String fulfillmentId){
       system.debug(LoggingLevel.Error, 'ShipCompleteInlineEditCtrl.getFulfillmentLines');
       return FulfillmentData.getFulfillmentLines(fulfillmentId);
    }

    @AuraEnabled    
    public static List<Fulfillment_Line__c>  updateFulfillments(String fulfillmentLines){
       system.debug(LoggingLevel.Error, 'ShipCompleteInlineEditCtrl.updateFulfillments');

        return FulfillmentData.updateFulfillments(fulfillmentLines);
    }
}