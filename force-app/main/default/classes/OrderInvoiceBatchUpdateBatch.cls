/*
Class:          OrderInvoiceBatchUpdateBatch
@Author:        Chandana Gowda
@Created Date:  21 Jun 2021
@Description:   TAX-139 Batch to update Invoice batch on Order

Change History
************************************************************************************************************************************************************
ModifiedBy      Date            Ticket NorderRec.   Requested By    Description																			Tag
Wasim Akram		13/12/2021		TAX-222				Kain Lau		Release the hold on Invoice when Quote tax exemption is updated to "Override"		T1
************************************************************************************************************************************************************
*/
global class OrderInvoiceBatchUpdateBatch implements Database.Batchable<sObject>,Schedulable{
    
    public static globalApexManager GAM = new globalApexManager();

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String invoiceHold = Label.LabelInvoiceHold;

        query = 'SELECT Id,blng__InvoiceBatch__c,CreatedDate,SBQQ__Quote__c, SBQQ__Quote__r.Sold_to_Account_ERP_Site__c,SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exempt_Status__c,SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exemption_On_File__c FROM Order WHERE blng__InvoiceBatch__c=:invoiceHold';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> scope){
        Date todayMinus4Days = System.Today().addDays(-4);
        List<Order> lstOrdertoUpdate = new List<Order>();
        for(Order orderRec:scope){
            //<T1> - Added the Exempt Status = Override in OR condition
            if(orderRec.CreatedDate <= todayMinus4Days || (order.SBQQ__Quote__c != null && orderRec.SBQQ__Quote__r.Sold_to_Account_ERP_Site__c != null && ((orderRec.SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exempt_Status__c == 'Exempt' && orderRec.SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exemption_On_File__c) || orderRec.SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exempt_Status__c == 'Override'))){
                orderRec.blng__InvoiceBatch__c = null;   
                lstOrdertoUpdate.add(orderRec);             
            }
        }
        if(!lstOrdertoUpdate.isEmpty()){
            try{
                update lstOrdertoUpdate;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('OrderInvoiceBatchUpdateBatch','Exception in OrderInvoiceBatchUpdateBatch:  ' , e.getMessage());
            }
        }              
    } 
    
    global void finish(Database.BatchableContext BC){
        GAM.CreateLogs('Invoice Batch updated on Order ','timestamp:' + System.now());
        //Insert debug Logs
        GAM.InsertDebugLogs();        
    }

    global void execute(SchedulableContext ctx){                
        //Create a new Instance of the Class OrderInvoiceBatchUpdateBatch
        OrderInvoiceBatchUpdateBatch exemptStatusBatch = new OrderInvoiceBatchUpdateBatch();
        database.executebatch(exemptStatusBatch,200);
    }     
}