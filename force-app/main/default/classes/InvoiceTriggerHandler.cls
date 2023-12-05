/***************************************************************************
*        Name        :        InvoiceTriggerHandler
*        Author      :        Nishit Sardessai
*        Date        :        25 Aug 2021
*        Description :        Trigger Handler class for Invoice 
****************************************************************************
Change History
**********************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                           Tag
**********************************************************************************************************************************************        
Nishit S            08-24-2021  I2C-1336            Allow a way for suppressing specific invoice from bursting to Customer              

*/
public inherited sharing class InvoiceTriggerHandler {
    public static globalApexManager GAM = new globalApexManager();
    public static void InvoiceBeforeInsert(Map <Id, blng__Invoice__c> triggerNewMap, Map <Id, blng__Invoice__c> triggerOldMap){
    }
    public static void InvoiceBeforeUpdate(Map <Id, blng__Invoice__c> triggerNewMap, Map <Id, blng__Invoice__c> triggerOldMap){
    }
    public static void InvoiceBeforeDelete(Map <Id, blng__Invoice__c> triggerNewMap, Map <Id, blng__Invoice__c> triggerOldMap){
    }
    public static void InvoiceAfterInsert(Map <Id, blng__Invoice__c> triggerNewMap, Map <Id, blng__Invoice__c> triggerOldMap){
    }
    
    public static void InvoiceAfterUpdate(Map <Id, blng__Invoice__c> triggerNewMap, Map <Id, blng__Invoice__c> triggerOldMap){
        
        List<Order> orderList = new list<order>();
        Set<Id> invoiceIds = new Set<Id> ();
        for(blng__Invoice__c invoice : [SELECT Id, blng__Order__c, Invoice_Sent__c, External_ID__c, blng__Order__r.Do_Not_Send_Invoices_to_Customer__c,blng__InvoiceStatus__c,
                                        (SELECT blng__OrderProduct__c, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.Do_Not_Send_Invoices_to_Customer__c  FROM blng__InvoiceInvoiceLines__r)
                                        FROM blng__Invoice__c WHERE Id IN :triggerNewMap.keySet()])
        {
            if(invoice.External_ID__c != NULL && invoice.External_ID__c != triggerOldMap.get(invoice.Id).External_ID__c && invoice.Invoice_Sent__c)
            {
                if(invoice.blng__Order__c != NULL && invoice.blng__Order__r.Do_Not_Send_Invoices_to_Customer__c == 'Do Not Send Next Invoice to Customer(P)')
                    orderList.add(new Order(Id = invoice.blng__Order__c, Do_Not_Send_Invoices_to_Customer__c = NULL));
                
            }
            
            if((triggerNewMap.get(invoice.Id).blng__InvoiceStatus__c == 'Rebilled' || triggerNewMap.get(invoice.Id).blng__InvoiceStatus__c == 'Cancelled') && triggerNewMap.get(invoice.Id).blng__InvoiceStatus__c != triggerOldMap.get(invoice.Id).blng__InvoiceStatus__c)
            {
                invoiceIds.add(invoice.Id);   
            }
            
        } 
        
        if(invoiceIds.size() > 0)
            InvoiceTriggerHelper.handleCancelRebill(invoiceIds);
        
        try{
            update orderList;
        }catch(Exception e){
            GAM.CreateLogs('InvoiceTriggerhandler', triggerNewMap.values(), 'invoiceTriggerNewMap');
        }
        
        GAM.InsertDebugLogs();
    }
}