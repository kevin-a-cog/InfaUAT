/**
 * @description       : Test class for WeekendHoliday_Support_StartTest
 * @author            : Pavithra V
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Pavithra 

 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/28/2022  I2RT-6740   T01     to pass the Shift Date Id instead of Shift Plan Id

**/
@isTest
public class WeekendHoliday_Support_StartTest {

    @isTest
    public static void testrevokeWeekendSupport() {
        sObject sObj;
        
        sObj = new Shift_Plan__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mshiftPlan);
        sObj.put('Start_Date__c', Date.today().addDays(-2));
        sObj.put('End_Date__c', Date.today().addDays(5));
        List<Shift_Plan__c> lshiftPlan = (List<Shift_Plan__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new ServiceResource();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceResouce);
        sObj.put('Name', 'Test Name');
        sObj.put('RelatedRecordId', UserInfo.getUserId()+'');
        List<ServiceResource> lServiceResources = (List<ServiceResource>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        List<ProfileSkill> lstPf = (List<ProfileSkill>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Shift_Request__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mshiftRequest);
        sObj.put('Shift_Plan__c', lshiftPlan[0].Id);//
        sObj.put('Allocation_Type__c', 'Holiday Support (US)');
        sObj.put('Resource_Count__c', 5);
        sObj.put('Skill__c', lstPf[0].Id);
        List<Shift_Request__c> lshiftRequest = (List<Shift_Request__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_Criteria__c();
        sObj.put('Name', 'W/H Support Notifications Product Specialists');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        List<Notification_Criteria__c> lNotiCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lNotiCriteria[0].Id);
        sObj.put('User__c', UserInfo.getUserId()+'');
        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        sObj = new Shift_Allocation__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mshiftAllocation);
        sObj.put('Start_Date__c', Date.today().addDays(1));
        sObj.put('End_Date__c', Date.today().addDays(1));
        sObj.put('Shift_Request__c', lshiftRequest[0].Id);//
        sObj.put('Service_Resource__c', lServiceResources[0].Id);
        sObj.put('Status__c', 'Approved');
        sObj.put('Location__c', 'WFO');
        List<Shift_Allocation__c> lshiftAllocation = (List<Shift_Allocation__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //T01
        Shift_Date__c shiftDate = new Shift_Date__c();
        shiftDate.Shift_Plan__c = lshiftPlan[0].Id;
        shiftDate.Start_Date_Time__c = Date.today().addDays(1);
        shiftDate.End_Date_Time__c = Date.today().addDays(2);
        insert shiftDate;

        List<Id> shiftDateIds = new  List<Id>{shiftDate.Id};
        Test.setMock(HTTPCalloutMock.class, new CalloutRestMock());
        WeekendHoliday_Support_Start.requestWeekendHolidaySupport(shiftDateIds);
       
        Test.stopTest();

    }
}