global class AssetCreationSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc)
    {       
        //calling the batch class to be scheduled
        AssetCreationBatch b = new AssetCreationBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1);
    }
   
}