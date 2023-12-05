/**
 * @description       : Test class for WeekendHoliday_SupportCaseTeamTest
 * @author            : Pavithra V
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Pavithra 
**/
@isTest
public class WeekendHoliday_SupportCaseTeamTest {
    
    @isTest
    public static void testOwnerRemoval() {
        sObject sObj;
        
        sObj = new Notification_Criteria__c();
        sObj.put('Name', 'Weekend Support');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        List<Notification_Criteria__c> lNotiCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lNotiCriteria[0].Id);
        sObj.put('User__c', UserInfo.getUserId()+'');
        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Subject', 'TestClass');
        List<Case> lCase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Case_Team__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseTeam);
        sObj.put('User__c', UserInfo.getUserId());
        sObj.put('Case__c', lCase[0].Id);
        List<Case_Team__c> lCaseTeam = (List<Case_Team__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
       
        WeekendHoliday_Support_CaseTeamHandler.caseTeamHandler_OwnerRemoval(lCase);
        Test.stopTest();
    }

}