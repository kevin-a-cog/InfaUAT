/*
    @created by       : balajip
    @created on       : 09/07/2020
    @Purpose          : Scheduler class to run the Batch on Knowledge Article Version to archive records.
    @Testclass        : 
    @JIRA             : I2RT-62
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
*/

 public class KnowledgeArchiveScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
       KnowledgeUpdateBatch knowledgeUpdateBatch = new KnowledgeUpdateBatch(KnowledgeUpdateBatch.ARCHIVE_EXPIRED_ARTICLES);
        Database.executeBatch(knowledgeUpdateBatch, 1); 
    }
}