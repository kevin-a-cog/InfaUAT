/*
Class:          convertLeadControllerTest
@Author:        Sreerekha
@Created Date:  9 OCT 2023
@Description:   Test class for convertLeadController

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/

@isTest
Public class convertLeadControllerTest {
    Static Id ProspectAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        @isTest
        static void getconvertLeadController() {
            //Insert Account
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Partner Account');
            UtilityTestData.mAccountData.put('RecordTypeId', ProspectAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert Contact
            SObject con = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','test Con FirstName111');
            UtilityTestData.mContactData.put('LastName','test Con LastName111');
            UtilityTestData.mContactData.put('Email','testconemail11@gmail.com');
            UtilityTestData.mContactData.put('Title','Customer');
            UtilityTestData.mContactData.put('Phone','122222222');            
            con = UtilityTest.putFieldRecord(con, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{con});
            
            //Insert Opportunity
            UtilityTestData.mOpportunityData.put('Name', 'Test Opportunity');
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
            UtilityTestData.mOpportunityData.put('IsClosed', 'false');
            UtilityTestData.mOpportunityData.put('StageName', 'Validate');
            UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
            sObj = new Opportunity();     
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert Lead
            UtilityTestData.mLeadData.put('FirstName','test referral');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@gmail.com');
            UtilityTestData.mLeadData.put('AccountID',lAccount[0].Id);
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','Yes');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            List<Lead> leadList = (list<lead>)UtilityTest.makeInsert(new List<sObject>{lead});
            
            Test.startTest();
            convertLeadController.fetchDefaultValues(lAccount[0].Id, leadList[0].Email);
            convertLeadController.fetchDefaultValues(lAccount[0].Id, 'testconemail11@gmail.com');
            convertLeadController.fetchDefaultValues('', leadList[0].Email);
            convertLeadController.lookupContactSearch('Test','testconemail11@gmail.com');
            convertLeadController.getDefaultContactRecords('testconemail11@gmail.com');
            convertLeadController.lookupOptySearch('Test',lAccount[0].Id);
            convertLeadController.getDefaultOptyRecords(lAccount[0].Id);
            convertLeadController.getContactFieldNames(leadList[0].Id,lContact[0].Id);
            convertLeadController.getContactFieldNames(leadList[0].Id,'');
            Test.stopTest();
        }

        
    }