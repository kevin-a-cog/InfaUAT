/*
Class:          CreateSupportAccountBatchSchedulable 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Scheudleable class for CreateSupportAccountBatch
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


global class CreateSupportAccountBatchSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc)
    {       
        //calling the batch class to be scheduled
        CreateSupportAccountBatch b = new CreateSupportAccountBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}