/*
@created by       : Ranjan
@created on       : 22/01/2021
@Purpose          : Scheduler class to run the Batch on Knowledge Article Version to notify author when draft article remains untouched.
@Testclass        : 
@JIRA             : I2RT-862


Change History
****************************************************************************************************
|  Tag    |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|         |                   |                           |                   |   
****************************************************************************************************

*/

public with sharing class KnowledgeNotifyDraftArticleToAuthor implements Schedulable {
      public void execute(SchedulableContext sc){
            KnowledgeUpdateBatch knowledgeUpdateBatch = new KnowledgeUpdateBatch(Label.Notify_Author_On_Draft_Article_Deletion);
            Database.executeBatch(knowledgeUpdateBatch); 
      }
}