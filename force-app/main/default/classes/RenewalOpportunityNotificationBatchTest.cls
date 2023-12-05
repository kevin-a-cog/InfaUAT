/*
@author : Vivek Warrier
@date : 7/31/2019
@purpose : To test the batch class 'RenewalOpportunityNotificationBatch' and 'ScheduleRenewalOptyNotificationBatch'
***********************************************************************************************************************************************
* Modified by       Date            Requested By                    Description                     
***********************************************************************************************************************************************
*
*/  
@isTest
public class RenewalOpportunityNotificationBatchTest{
     
    static testMethod void testMethod_Batch() {
        // Set the Account Name
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) {  

            List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 Limit 1');
            Id CompetitiorRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
            
            UtilityTestData.mAccountData.put('Name', 'BEST BUY');
            UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
            // Initialize a sObject
            sObject sObj = new Account();
            // Call methos and pass sObject and data maps
            // This utility method will populate all the fields data according to the Map passed
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            UtilityTestData.mAccountData.put('Name', 'Test Competitor'); 
            UtilityTestData.mAccountData.put('RecordTypeId', String.valueOf(CompetitiorRTId));      
            sObject sObj1 = new Account();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            system.assertEquals(lAccount.size(),2);
            
            // Set all the required fields and dynamic ids in Map
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Testduplicateemail@test.com');
            sObj1 = new Contact();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
            system.assertEquals(lContact.size(),2);        
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Renewal');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('CloseDate', Date.today().addDays(140).year() + '-' + Date.today().addDays(140).month() + '-' + Date.today().addDays(140).day());
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Test.startTest();

            RenewalOpportunityNotificationBatch b = new RenewalOpportunityNotificationBatch();
            Database.executeBatch(b,200);
            
            Test.stopTest();
        }
    }

    static testMethod void testMethod_sched() {
    // Set the Account Name
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) {  

            List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 Limit 1');
            Id CompetitiorRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
            
            UtilityTestData.mAccountData.put('Name', 'BEST BUY');
            UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
            // Initialize a sObject
            sObject sObj = new Account();
            // Call methos and pass sObject and data maps
            // This utility method will populate all the fields data according to the Map passed
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            UtilityTestData.mAccountData.put('Name', 'Test Competitor'); 
            UtilityTestData.mAccountData.put('RecordTypeId', String.valueOf(CompetitiorRTId));      
            sObject sObj1 = new Account();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            system.assertEquals(lAccount.size(),2);
            
            // Set all the required fields and dynamic ids in Map
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Testduplicateemail@test.com');
            sObj1 = new Contact();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
            system.assertEquals(lContact.size(),2);        
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Renewal');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('CloseDate', Date.today().addDays(140).year() + '-' + Date.today().addDays(140).month() + '-' + Date.today().addDays(140).day());
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Test.startTest();

            ScheduleRenewalOptyNotificationBatch sch = new ScheduleRenewalOptyNotificationBatch();
            String cron = '0 0 23 * * ?';
            System.schedule('Test Renewal Notification Sched', cron, sch);
            
            Test.stopTest();
        }
    }
}