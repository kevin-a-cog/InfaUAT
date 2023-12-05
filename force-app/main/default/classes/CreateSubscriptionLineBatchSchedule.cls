/*
Class:          CreateSubscriptionLineBatchSchedule 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Scheduler class for CreateSubscriptionLineBatch
*/

global class CreateSubscriptionLineBatchSchedule implements Schedulable{
    
    global void execute(SchedulableContext ctx){
        
        database.executebatch(new CreateSubscriptionLineBatch(),200);
    }
}