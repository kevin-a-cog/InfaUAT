/*
Trigger:        SetOriginalOrderProductIdBatch
@Author:        Kenrda Claiborne
@Created Date:  30 October 2017
@Description:   Batch class to set Original_Order_Product_Id__c field on OrderItem
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/

global class SetOriginalOrderProductIdBatch implements Database.Batchable<Sobject>, Schedulable{
    public static globalApexManager GAM = new globalApexManager();
    public static DateTime startDate;
    public static DateTime endDate;

    global void execute(SchedulableContext sc){
      SetOriginalOrderProductIdBatch cls = new SetOriginalOrderProductIdBatch(); 
      Database.executebatch(cls);
   }
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String soql = 'SELECT Id, Original_Order_Product_Id__c, Original_Order_Product__c, SBQQ__RevisedOrderProduct__c, SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c FROM OrderItem WHERE SBQQ__RevisedOrderProduct__c = null AND Original_Order_Product_Id__c = null';
        
        if(test.isrunningtest()){
            soql += ' LIMIT 10';
        }
        
        return Database.getQueryLocator(soql);
    }
    
    global void execute(Database.BatchableContext bc, List<OrderItem> scope){
		updateOrderItem(scope);        
    }
    
    public void updateOrderItem(List<OrderItem> scope) {
        for(OrderItem oi : scope){
            if(String.isBlank(oi.SBQQ__RevisedOrderProduct__c) && String.isBlank(oi.Original_Order_Product_id__c)){            
                oi.Original_Order_Product_id__c = oi.Id;
            }
        }
        
        try{
            System.debug('Scope is ' + scope);
            Database.update(scope, false);
        } catch(Exception e){
            GAM.CreateLogs('OriginalOrderProductUpdateBatch --> execute', scope, 'scope: ');
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        GAM.CreateLogs('OriginalOrderProductUpdateBatch --> finish','timestamp: ' + System.now());
        GAM.InsertDebugLogs();
    }
}