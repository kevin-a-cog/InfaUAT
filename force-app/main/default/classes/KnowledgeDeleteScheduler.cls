/*
    @created by       : balajip
    @created on       : 09/07/2020
    @Purpose          : Scheduler class to run the Batch on Knowledge Article Version to delete records.
    @Testclass        : 
    @JIRA             : I2RT-62
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
*/
public class KnowledgeDeleteScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
         KnowledgeUpdateBatch knowledgeUpdateBatch = new KnowledgeUpdateBatch(KnowledgeUpdateBatch.DELETE_STALE_DRAFT_ARTICLES);
        Database.executeBatch(knowledgeUpdateBatch, 1); 
    }
}