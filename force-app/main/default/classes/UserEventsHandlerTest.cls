@isTest
public with sharing class UserEventsHandlerTest {
    public static  Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {
        Test.startTest();
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    //Weekend Support
    static testmethod void userUpcomingWeekEndEventsTest(){
        Account Acc = [SELECT Id FROM Account LIMIT 1];
        Event e = new Event();
        e.WhatId=Acc.id;
        e.Subject='Test Weekend Support';
        e.StartDateTime=system.today().addDays(3);
        e.EndDateTime=system.today().addDays(5);
        Test.startTest();
        insert e;
        Test.stopTest();
        UserEventsHandler.userUpcomingEvents(UserInfo.getUserId());
    }

    //FTO
    static testmethod void userUpcomingFTOEventsTest(){
        Account Acc = [SELECT Id FROM Account LIMIT 1];
        Event e = new Event();
        e.WhatId=Acc.id;
        e.Subject='Test FTO';
        e.StartDateTime=system.today().addDays(3);
        e.EndDateTime=system.today().addDays(5);
        e.IsAllDayEvent__c=true;
        Test.startTest();
        insert e;
        Test.stopTest();
        UserEventsHandler.userUpcomingEvents(UserInfo.getUserId());
    }

    //Holiday Support
    static testmethod void userUpcomingHolidayEventsTest(){
        Account Acc = [SELECT Id FROM Account LIMIT 1];
        Event e = new Event();
        e.WhatId=Acc.id;
        e.Subject='Test Holiday Support';
        e.StartDateTime=system.today().addDays(3);
        e.EndDateTime=system.today().addDays(5);
        Test.startTest();
        insert e;
        Test.stopTest();
        UserEventsHandler.userUpcomingEvents(UserInfo.getUserId());
    }

}