/***************************************************************************************************************************************************************
 *  @Class Name: psa_refreshAssignmentHoursJob
 *  @Author: Wasim Akram
 *  @Date: 17 AUG 2022
 *  @Description: PSA-2549 : Batch Class to refresh Total billable hours fields on Assignment.
 ****************************************************************************************************************************************************************
 ChangeHistory
    
ModifiedBy              Date                       Requested By            Description                       Tag   

 ***************************************************************************************************************************************************************/
public class psa_refreshAssignmentHoursJob implements Schedulable, Database.Batchable<SObject>{
    public static globalApexManager GAM = new globalApexManager();
    public psa_refreshAssignmentHoursJob() {
    }
    public Database.queryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id FROM pse__Assignment__c WHERE pse__Project__r.pse__Is_Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(SchedulableContext ctx)
    {
        psa_refreshAssignmentHoursJob batch = new psa_refreshAssignmentHoursJob();
        database.executebatch(batch,1);
    }
    public void execute(Database.BatchableContext bc, List<pse__Assignment__c> scope)
    {  
        for(pse__Assignment__c assgmt : scope){
            assgmt.pse__Action_Refresh_Timecard_Rollups__c = TRUE;
        }
        try{
            if(scope.size() > 0){
                update scope;
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('Error from psa_refreshAssignmentHoursJob batch', e.getMessage(), scope[0].Id);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        if(!Test.isRunningTest()){
        	Database.executeBatch(new psa_refreshMilestoneHoursJob());
        }
    }
}