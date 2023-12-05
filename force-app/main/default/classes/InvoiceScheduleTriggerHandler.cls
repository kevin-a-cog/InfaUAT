/*
Class:          InvoiceScheduleTriggerHandler
@Author:        Wasim Akram
@Created Date:  20/7/2021
@Description:   handler class for Invoice Schedule triggers

Change History
*********************************************************************************************************************************************************
ModifiedBy          Date            JIRA                Requested By        Description                                                                             Tag

***********************************************************************************************************************************************************
*/
public class InvoiceScheduleTriggerHandler {
    public static CustomPermissionsReader csm = new CustomPermissionsReader();// to check the user permission
    public static Boolean IsExemptUser = (csm.hasPermission('SystemAdmin') || csm.hasPermission('Support_Team'));//Check if the current user has Admin,Support Team permissions
    /**
* this method is invoked from before delete event of Invoice Schedule
* @param lstNew - list of Invoice Schedule
* @return return-void
* @throws exception - NA
*/
    public static void handleBeforeDelete(List<Invoice_Schedule__c> LstOld)
    {        
        if(!IsExemptUser){
            Map<Id,Boolean> mapInvoiceBTBSCreated = checkBillScheduleTransactionsCreated(LstOld);
            for(Invoice_Schedule__c invoiceObj : LstOld){
                if(mapInvoiceBTBSCreated.get(invoiceObj.Id)){
                    invoiceObj.addError(Label.BillPlanDeleteError);                    
                }
            }
        }
    }
    /**
*  /**
* this method is invoked from before update event of Invoice Schedule
* @param lstNew - list of Invoice Schedule
* @return return-void
* @throws exception - NA
*/
    public static void handleBeforeUpdate(map<Id,Invoice_Schedule__c> newMap, map<Id,Invoice_Schedule__c> oldMap)
    {        
        if(!IsExemptUser){
            Map<Id,Boolean> mapInvoiceBTBSCreated = checkBillScheduleTransactionsCreated(newMap.values());
            for(Invoice_Schedule__c invoiceObj : newMap.values()){
                if((oldMap.get(invoiceObj.ID).Invoice_Date__c != invoiceObj.Invoice_Date__c) && mapInvoiceBTBSCreated.get(invoiceObj.Id)){
                    invoiceObj.addError(Label.BillPlanInvoiceDateError);                
                }
            }
        }
    }
    /**
* this method is invoked from handleBeforeDelete and handleBeforeUpdate
* @param lstNew - list of Invoice Schedule
* @return return-void
* @throws exception - NA
*/
    public static Map<Id,Boolean> checkBillScheduleTransactionsCreated(List<Invoice_Schedule__c> invoiceList)
    {
        //Create a Map of Invoice Id and ifBillingTransaction is created
        Map<Id,Boolean> mapInvoiceBTBSCreated = new Map<Id,Boolean>();
                
        //Query to check if any Billing Transactions are present for Bill Plan
        Map<Id,Invoice_Schedule__c> billPlanMap = new Map<Id,Invoice_Schedule__c>([SELECT Id,(SELECT Id FROM Billing_Transactions__r) FROM Invoice_Schedule__c WHERE Id IN :invoiceList ]);
        
        //If Billing Transaction is present for the Bill Plan, assign True
        for(Invoice_Schedule__c invoiceObj : invoiceList){
            if(billPlanMap.get(invoiceObj.Id).Billing_Transactions__r.size() > 0){
                mapInvoiceBTBSCreated.put(invoiceObj.Id,true);
            } 
            else{
                mapInvoiceBTBSCreated.put(invoiceObj.Id,false);
            }
        }
        return mapInvoiceBTBSCreated;
    }
}