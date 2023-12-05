/*
Class:          iNotifyController
@Author:        Pavithra V
@Created Date:  15-Mar-2021
@Description:   Test class for iNotifyController

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class iNotifyControllerTest {

    public static testmethod void testNotifyController(){
        
        sObject sObj;
        
        //Create an Alert Annoucement
        sObj = new Alerts_Announcements__c();
        sObj.put('Application__c', 'GCS Service Console');
        sObj.put('Description__c', 'Test Description');
        sObj.put('End_Date__c', Date.today()+5);
        sObj.put('Start_Date__c', Date.today()-5);
        sObj.put('Skills__c', '');
        sObj.put('Public_Groups__c', '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAlertannouncements);
        List<Alerts_Announcements__c> lAlertsAnnouncements = (List<Alerts_Announcements__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create an Inspire messages
        sObj = new Inspire_Message__c();
        sObj.put('Activity_Date__c', Date.today()-5);
        sObj.put('Description__c', 'Test description message');
        sObj.put('Has_Been_Viewed__c', 'Yes');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mInspiredMessages);
        List<Inspire_Message__c> lInspireMessages = (List<Inspire_Message__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
              
        Test.startTest();
        iNotifyController.checkAlerts('GCS Service Console', lAlertsAnnouncements);
        iNotifyController.checkUnSubscribe('Test AlertAnnouncement');
        iNotifyController.getAlerts('GCS Service Console', 1);
        iNotifyController.updateUnreadMessages(lInspireMessages);
        iNotifyController.getInspireMessages('GCS Service Console', 1);
        Test.stopTest();
        
    }    
    
}