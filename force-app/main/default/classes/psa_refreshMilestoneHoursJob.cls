/***************************************************************************************************************************************************************
 *  @Class Name: psa_refreshMilestoneHoursJob
 *  @Author: Wasim Akram
 *  @Date: 17 AUG 2022
 *  @Description: PSA-2549 : Batch Class to refresh Total billable hours fields on Milestone.
 ****************************************************************************************************************************************************************
ChangeHistory

ModifiedBy              Date                       Requested By            Description                       Tag   

***************************************************************************************************************************************************************/
public class psa_refreshMilestoneHoursJob implements Schedulable, Database.Batchable<SObject>{
    public static globalApexManager GAM = new globalApexManager();
    public psa_refreshMilestoneHoursJob() {
    }
    public Database.queryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id FROM pse__Milestone__c WHERE pse__Project__r.pse__Is_Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(SchedulableContext ctx)
    {
        psa_refreshMilestoneHoursJob batch = new psa_refreshMilestoneHoursJob();
        database.executebatch(batch,1);
    }
    public void execute(Database.BatchableContext bc, List<pse__Milestone__c> scope)
    {  
        String errorMsg = '%'+Label.appLogValidationError+'%';
        for(pse__Milestone__c mil : scope){
            mil.pse__Action_Refresh_Timecard_Rollups__c = TRUE;
        }
        List<appirio_core__App_Log__c> logList = [SELECT Id FROM appirio_core__App_Log__c WHERE appirio_core__Message__c LIKE :errorMsg LIMIT 50000];
        try{
            if(logList.size() > 0){
                delete logList;
            }
            if(scope.size() > 0){
                update scope;
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('Error from psa_refreshMilestoneHoursJob batch', e.getMessage(), scope[0].Id);
        }
    }
    public void finish(Database.BatchableContext bc)
    {

    }
}