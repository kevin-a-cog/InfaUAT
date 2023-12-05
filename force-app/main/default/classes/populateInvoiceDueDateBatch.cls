/*
Class:          populateInvoiceDueDateBatch 

@Author:        RamEsh M S
@Created Date:  24 JUNE 2020
@Description:   Batch class for populating Invoice Due Date on Invoices of Orders (with Payment Term = "Other") and Post the Invoice.
*/

/*
Change History
***********************************************************************************************************************************************************************
ModifiedBy                Date                JIRA                Requested By                    Description                                                                       Tag

RamEsh M S                24-JUN-2020         SALESRT-12173       Finance                         Update Invoice Due Date from Payment Term under Order.
***********************************************************************************************************************************************************************
*/

global class populateInvoiceDueDateBatch implements Schedulable, Database.Batchable<sObject>{
   
    public static globalApexManager GAM = new globalApexManager();
    global Set<Id> InvIds = new Set<Id> ();
    global Map<Id,Id> InvOrderIds = new Map<Id,Id> ();
    global Map<Id,blng__Invoice__c> InvMap = new Map<id,blng__Invoice__c> ();
    global List<blng__Invoice__c> InvList = new List<blng__Invoice__c> ();
    global Map<Id,blng__Invoice__c> InvMapUpdate = new Map<Id,blng__Invoice__c> (); 
       
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String InvStatus = Label.InvoiceStatus;
        List<String> InvRunStatus = (Label.InvoiceRunStatus).split(';');
    
        query = 'SELECT Id,blng__InvoiceStatus__c,blng__InvoiceDate__c,blng__DueDate__c,blng__InvoiceRunCreatedBy__c from blng__Invoice__c where blng__DueDate__c = null AND blng__InvoiceStatus__c =: InvStatus AND blng__InvoiceRunCreatedBy__r.blng__PercentageComplete__c = 100 AND blng__InvoiceRunCreatedBy__r.blng__Status__c =: InvRunStatus';
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext ctx)
    {
        populateInvoiceDueDateBatch populateInvoiceDueDate = new populateInvoiceDueDateBatch();
        database.executebatch(populateInvoiceDueDate,1);
    }
    
    /**
* this method is execute method the apex batch
*
* @param Database.BatchableContext BC
* @param List<blng__Invoice__c>
* @return return-Database.QueryLocator
* @throws exception - captures exception in a Exception log record
*/
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope)
    {
        for(blng__Invoice__c INV : scope)
        {
            InvMap.put(INV.Id,INV);
        }
        
        for(blng__InvoiceLine__c InvLine : [Select Id,blng__Invoice__c,blng__OrderProduct__c,blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Order.SBQQ__PaymentTerm__c from blng__InvoiceLine__c where blng__Invoice__c =: InvMap.keyset()])
        {
            if(InvLine.blng__OrderProduct__r.Order.SBQQ__PaymentTerm__c == 'Other')
            {
                InvOrderIds.put(InvLine.blng__OrderProduct__r.OrderId,InvLine.blng__Invoice__c);
            }
        }
        
        for(Payment_Term__c PT : [SELECT CurrencyIsoCode,End_Date__c,Id,Name,Order__c,Payment_Term__c,Quote__c,Start_Date__c FROM Payment_Term__c where Order__c =: InvOrderIds.keyset() ORDER BY CreatedDate ASC])
        {
            if(InvMap.get(InvOrderIds.get(PT.Order__c)).blng__InvoiceDate__c >= PT.Start_Date__c && InvMap.get(InvOrderIds.get(PT.Order__c)).blng__InvoiceDate__c <= PT.End_Date__c)
            {
                blng__Invoice__c Invoice = InvMap.get(InvOrderIds.get(PT.Order__c));
                Invoice.blng__DueDate__c = InvMap.get(InvOrderIds.get(PT.Order__c)).blng__InvoiceDate__c.addDays(PT.Payment_Term__c.intValue());
                //InvList.add(Invoice);
                InvMapUpdate.put(Invoice.Id,Invoice);
            }
        }
        
        if(!(InvMapUpdate.values()).isEmpty())
        {
            try{
                
                //update InvList;
                update InvMapUpdate.values();
                for(blng__Invoice__c InvPost : InvMapUpdate.values())
                {
                    InvPost.blng__InvoiceStatus__c = 'Posted';
                    InvList.add(InvPost);
                }
                update InvList;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('populateInvoiceDueDateBatch','Exception in populateInvoiceDueDateBatch:  ' , e.getMessage());
            }
        }   
        //Insert debug Logs
        GAM.Insertdebuglogs();

           
    }

        /**
* this method is Finish method the apex batch
*
* @param Database.BatchableContext BC
* @return Void
* @throws NA
*/  
    global void finish(Database.BatchableContext BC)
    {
        GAM.CreateLogs('InvoiceUpdated --> finish','timestamp:' + System.now());
        //Insert debug Logs
        GAM.InsertDebugLogs();
    }

}