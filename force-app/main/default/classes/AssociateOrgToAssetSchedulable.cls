global class AssociateOrgToAssetSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc)
    {       
        //calling the batch class to be scheduled
        AssociateOrgToAsset b = new AssociateOrgToAsset();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}