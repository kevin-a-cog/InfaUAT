/*
Class:  consoleNotificationControllerLWCTest
        @Author:        Jiju Dineshan
        @Created Date:  06/09/2021
        @Description:   Test Class for consoleNotificationControllerLWC Class.


*/
/*
Change History:
*/
@isTest
public class consoleNotificationControllerLWCTest {
    @testSetup
    static void setupObjectTestData() {
        QueuesObject gcsQueueObj = new QueuesObject();
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id);
        UtilityTestData.mContactData.put('FirstName','test Con FirstName1');
        UtilityTestData.mContactData.put('LastName','test Con LastName1');
        UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
        UtilityTestData.mContactData.put('Phone','9517536548');
        UtilityTestData.mContactData.put('MailingCountry','India');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create an Entitlement record
        sObj = new Entitlement();
        UtilityTestData.mEntitlement.put('AccountId',lNewCustomerAccount[0].Id);
        UtilityTestData.mEntitlement.put('Status','Active');
        UtilityTestData.mEntitlement.put('StartDate',system.today().addDays(-10)+'');
        UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
        List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Signature Success' and IsActive = true LIMIT 1];
        if (lstEntitlementProcess.size()>0) {
            Entitlement updateEntitlementRec = new Entitlement();
            updateEntitlementRec.Id = lEntitlement[0].Id;
            updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
            update updateEntitlementRec;        
        }
        
        List<BusinessHours> bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];

        Group gcsQueue = new Group(Name='GCS L0 Queue', Type='Queue');
        insert gcsQueue;
        system.runAs(adminUserObj){
            gcsQueueObj = new QueueSObject(QueueID = gcsQueue.id, SObjectType = 'Case');
            insert gcsQueueObj;
        }
        sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('status', 'New');
        UtilityTestData.mCase.put('Priority', 'p1');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
        UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
        UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
        UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
        UtilityTestData.mCase.put('Component__c ', 'Accelerator');
        UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        system.runAs(adminUserObj){
            cases[0].OwnerId = gcsQueue.Id;
            cases[0].Component__c = 'Accelerator';
            update cases;
        }
        List<Case> updatedCaseLst = [Select ID,OwnerId,Owner.Name from case limit 10];
        Custom_Notification_Filter__c customNotif = new Custom_Notification_Filter__c();
        customNotif.Filter_Priority__c = 'P1;P2';
        customNotif.GCS_Team__c = 'APAC-APS';
        customNotif.Filter_Products__c = 'Accelerator';
        customNotif.Queue_Membership__c = 'GCS L0 Queue';
        insert customNotif;
    }
    static testMethod void testGetUserDetails(){
        consoleNotificationControllerLWC.UserDetails userDetailRecord;
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        adminUserObj.GCS_Team__c = 'APAC-APS';
        update adminUserObj;
        system.runAs(adminUserObj){
            userDetailRecord = consoleNotificationControllerLWC.getUserDetails();
        }
        system.assertEquals(true,userDetailRecord.showSettings, 'Admin user doesnt have permission to update settings'); 
    }
    static testMethod void testGetCustomNotifsList(){
        List<consoleNotificationControllerLWC.NotificationDetails> notificationDetailsList = new List<consoleNotificationControllerLWC.NotificationDetails>();
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        adminUserObj.GCS_Team__c = 'APAC-APS';
        update adminUserObj;
        system.runAs(adminUserObj){
            notificationDetailsList = consoleNotificationControllerLWC.getCustomNotifsList();
        }
        system.assertEquals(1, notificationDetailsList.size(), 'No cases where returned');
    }
    static testMethod void testUpdateMuteInfo(){
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        system.runAs(adminUserObj){
            consoleNotificationControllerLWC.updateMuteInfo('Mute');
        }
        User updatedUser = [Select Id,Notification_Sound_Muted__c From User where Id=: adminUserObj.Id];
        system.assertEquals(true,updatedUser.Notification_Sound_Muted__c, 'user sound was not muted');
    }
    static testMethod void testUpdateUnMuteInfo(){
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        system.runAs(adminUserObj){
            consoleNotificationControllerLWC.updateMuteInfo('Unmute');
        }
        User updatedUser = [Select Id,Notification_Sound_Muted__c From User where Id=: adminUserObj.Id];
        system.assertEquals(false,updatedUser.Notification_Sound_Muted__c, 'user sound was not muted');
    }
    static testMethod void testUpdateCaseOwner(){
        String response;
        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        List<Case> caseList = [Select Id from Case Limit 1];
        String param = caseList[0].Id+';GCS L0 Queue';
        system.runAs(adminUserObj){
            response = consoleNotificationControllerLWC.updateCaseOwner(param);
        }
        system.assertEquals(response, 'Success', 'Owner not update successfully');
    }
}