/*
Class:          PlanProductARRCalculationSchedule 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Scheduler class for PlanProductARRCalculationBatch
*/

global class PlanProductARRCalculationSchedule  implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        if(!Test.isRunningTest()){database.executebatch(new PlanProductARRCalculationBatch(),Integer.valueOf(Label.PlanProductARRCalculationBatchSize));}
    }
}