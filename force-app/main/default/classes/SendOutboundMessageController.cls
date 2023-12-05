/*
* Name         :   SendOutboundMessageController
* Author       :   Harshita Joshi
* Created Date :   11/09/2022
* Description  :   Class to send outboundmessage through quick action.
*/
public class SendOutboundMessageController {
    /*
   Method Name : sendOutboundMessage
   Description : This method use to sent email via CAI process.
   Parameters  : RecordId of fulfillment object.
   Return Type : none.
   */
    @AuraEnabled  
    public static void sendOutboundMessage(string recordId) {
        list<fulfillment__c> fulRecord = [SELECT id,Order__c FROM fulfillment__c WHERE Id = :recordId LIMIT 1];
        if(!fulRecord.isempty() && fulRecord.size()<>0 && fulRecord[0].Order__c!=null){ 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Label.Fulfillment_Outbound_Messsage_Link+fulRecord[0].Order__c);
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        }
    }
}