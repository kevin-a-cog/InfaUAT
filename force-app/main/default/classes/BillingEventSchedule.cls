global class BillingEventSchedule implements Schedulable{
 global void execute(SchedulableContext sc) {
   System.debug('@Developer --> BillingEventSchedule --> timestamp:' + system.now());
   BillingEventBatch oBillingEventBatch = new BillingEventBatch();
   Database.executeBatch(oBillingEventBatch);
 }
}