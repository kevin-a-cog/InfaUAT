/*
Class:          SupportAccountUpdateBatchSchedulable 
@Author:        Ambica P
@Created Date:  5 may 2021  
@Description:   schdulable class for SupportAccountUpdateBatch
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


global class SupportAccountUpdateBatchSchedulable implements Schedulable
{
  
    global void execute(SchedulableContext sc)
    {       
        //calling the batch class to be scheduled
        SupportAccountUpdateBatch b = new SupportAccountUpdateBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}