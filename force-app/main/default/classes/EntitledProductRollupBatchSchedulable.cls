/*
Class:          EntitledProductRollupBatchSchedulable 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   schdulable class for EntitledProductRollupBatch
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


global class EntitledProductRollupBatchSchedulable implements Schedulable
{
  
    global void execute(SchedulableContext sc)
    {       
        //calling the batch class to be scheduled
        EntitledProductRollupBatch b = new EntitledProductRollupBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}