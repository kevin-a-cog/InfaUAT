@isTest
public class engagementTimerControllerTest {
    
    @testSetup
    public static void testDatasetup(){
        Engagement__c sObj = new Engagement__c(Name='Test Engagement1');
        sObj.status__c = 'Active Engaged';
        sObj.Dev_Active_Engaged_Start_Time__c = DateTime.now();
        Engagement__c sObj1 = new Engagement__c(Name='Test Engagement2');
        insert sObj;
        insert sObj1;
    }

    @isTest
    public static void fetchTimeDurationExceptionTest(){
        try{
            engagementTimerController.fetchTimeDuration('testrecId');
        }catch(Exception e){
            System.debug('Exception ' + e.getMessage());
        }
        
    }
    
    @isTest
    public static void fetchTimeDurationActiveEngagedStatusTest(){
        List<Engagement__c> lEngagements = [Select Id From Engagement__c where status__c='Active Engaged'];
        Test.startTest();
        engagementTimerController.fetchTimeDuration(lEngagements[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchTimeDurationNoStartDate(){
        List<Engagement__c> lEngagements = [Select Id From Engagement__c where status__c!='Active Engaged'];
        Test.startTest();
        engagementTimerController.fetchTimeDuration(lEngagements[0].Id);
        Test.stopTest();
    }
}