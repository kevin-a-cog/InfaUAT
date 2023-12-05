/**
 * @description       : Test class for WeekendSupport_End
 * @author            : Pavithra V
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Pavithra 
**/
@isTest
public class NotificationSubscriptionControllerTest {
    
    @isTest
    public static void testNotificationModule() {
        List<Notification_Criteria_Object__mdt> lstObjectSetting = [Select Id, MasterLabel, DeveloperName, Object_API_Name__c, Template_Name__c, Template_Folder_Name__c, Extension_Class_Name__c, Applicable_Apps__c
                                                                        From Notification_Criteria_Object__mdt];
		sObject sObj;
		sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Subject', 'TestClass');
        List<Case> lCase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_Criteria__c();
        sObj.put('Name', 'Weekend Support');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        List<Notification_Criteria__c> lNotiCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lNotiCriteria[0].Id);
        sObj.put('User__c', UserInfo.getUserId()+'');
        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
		
        
        Notification_Criteria__c sObj1 = new Notification_Criteria__c();
        sObj1.put('Name', 'Weekend Support');
        
        Notification_User__c sObj2 = new Notification_User__c();
        sObj2.put('Notification_Criteria__c', lNotiCriteria[0].Id);
        sObj2.put('User__c', UserInfo.getUserId()+'');
        
        Notification_Criteria_Detail__c sObj3 = new Notification_Criteria_Detail__c();
        sObj3.put('Notification_Criteria__c', lNotiCriteria[0].Id);
        sObj3.put('Value__c', 'Closed');
        sObj3.put('Operator__c', 'equals');
        sObj3.put('Field_API_Name__c', 'Status');
        
        List<Notification_User__c> lUser = new List<Notification_User__c>();
        lUser.add(sObj2);
        
        List<Notification_Criteria_Detail__c> lDetail = new List<Notification_Criteria_Detail__c>();
        lDetail.add(sObj3);
        
        NotificationSubscriptionController.getTemplates('Case');
        NotificationSubscriptionController.getTemplatePreview('Case_Notification','Case');
        NotificationSubscriptionController.getfilterCriteriaFields('Case');
        NotificationSubscriptionController.getFieldInfo('Case');
        NotificationSubscriptionController.getPicklistValues('Case','Status');
        
        NotificationSubscriptionController.getTargetFields('Case','Status');
        NotificationSubscriptionController.getRecordTypes('Case');
        NotificationSubscriptionController.getQueueNames('Case','OwnerId');
        NotificationSubscriptionController.getUserData(String.valueOf(UserInfo.getUserId()));
        
        NotificationSubscriptionController.getObjectNames();
        NotificationSubscriptionController.getrelatedRecords(lNotiCriteria[0].Id);
        NotificationSubscriptionController.saveNotificationCriteria(sObj1,JSON.serialize(lUser),JSON.serialize(lDetail),false);
        NotificationSubscriptionController.findObjectNameFromRecordIdPrefix(String.valueOf(lCase[0].Id));
        NotificationSubscriptionController.getAccountCaseFields('Case');
        NotificationSubscriptionController.getTargetFields('Case','Support_Account__r.Success_Offering__c');
        
        Test.startTest();
        NotificationSubscriptionController.getfilterCriteriaFields('Case_Comment__c');
        NotificationSubscriptionController.getFieldInfo('Case_Comment__c');
        
        NotificationSubscriptionController.getFieldInfo('Engagement__c');
        Test.stopTest();
        
    }
}