/**
* @description       :
* @author            : Sathish Rajalingam
* @group             :
* @last modified on  : 02-10-2021
* @last modified by  : Sathish Rajalingam
* Modifications Log
* Ver   Date         Author               Modification
* 1.0   02-08-2021   Sathish Rajalingam   Initial Version

****************************************************************************************************
|  Tag    |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|   1     |  08-Feb-2021      |   Sathish R               |    I2RT-862       |   Added changes related to Notify Author
****************************************************************************************************


**/

@isTest
public class KnowledgeNotifyDraftArticleToAuthorTest {
      
      @isTest
      static void knowledgeNotifyDraftArticleToAuthorTestSchedule(){
            Test.StartTest();          
            String scheduledtime = '0 30 10 * * ?';
            KnowledgeNotifyDraftArticleToAuthor notifyScheduler = new KnowledgeNotifyDraftArticleToAuthor();
            system.schedule('Notify Draft Articles', scheduledtime, notifyScheduler);           
            Test.StopTest();
      }
      
}