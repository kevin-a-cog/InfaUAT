@isTest
public class KBArchiveAndDeleteSchedulerTest {

    @isTest
    static void KnowledgeArchiveSchedulerTest(){
        Test.startTest();    	
    KnowledgeArchiveScheduler archiveScheduler= new KnowledgeArchiveScheduler();
    String scheduledtime = '0 30 10 * * ?'; 
    system.schedule('Archive Knowledge Articles', scheduledtime, archiveScheduler);
    Test.stopTest();
    }
     @isTest
    static void KnowledgeDeleteSchedulerTest(){
        Test.startTest();    	
    KnowledgeDeleteScheduler deleteScheduler= new KnowledgeDeleteScheduler();
    String scheduledtime = '0 30 10 * * ?'; 
    system.schedule('Delete Draft Articles', scheduledtime, deleteScheduler);
    Test.stopTest();
    }
    
}