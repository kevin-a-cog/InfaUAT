/*********************************************************************************************************
Class Name      : Test_StrikeUtilities
Created By      : Deloitte
Created Date    : June 6, 2018
Modification Log:
--------------------------------------------------------------------------------------------------------------
Developer                   Date                   Description
--------------------------------------------------------------------------------------------------------------
Deloitte                            Initial Version
****************************************************************************************************************/
@isTest
public class Test_StrikeUtilities {
    
    @isTest static void test_getRecentRecords() {
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecentRecords(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        
        System.assertEquals(true, response.get('isSuccess'));
        
        LookupStrikeResponseData responseData = new LookupStrikeResponseData();
        responseData.addError('Error');
    }
    
    @isTest static void test_getRecordLabel() {
        Account a = new Account(Name='Test Account', BillingCountry = 'Test Country');
        insert a;
        
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecordLabel(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        String objectLabel = String.valueOf(results.get('objectLabel'));
        
        System.assertEquals('Account', objectLabel);
    }
    
    @isTest static void test_getData() {
        Account a = new Account(Name='Test Account', BillingCountry = 'Test Country');
        insert a;
        
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecords(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(a.Id, record.get('value'));
    }
    
    @isTest static void test_getData_subtitleField() {
        Account a = new Account(Name='Test Account', BillingCountry = 'Test Country');
        insert a;
        
        String jsonString = '{"searchField":"Name", "subtitleField": "Name", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecords(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(a.Id, record.get('value'));
    }
    
    @isTest static void test_getData_addressField() {
        Account a = new Account(
            Name='Test Account',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code');
        insert a;
        
        String jsonString = '{"searchField":"Name", "subtitleField": "BillingAddress", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecords(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(a.Id, record.get('value'));
    }
    
    @isTest static void test_getData_reference() {
        Account a = new Account(Name='Test Account', BillingCountry = 'Test Country');
        insert a;
        
        Contact c = new Contact(
            LastName='Contact',
            FirstName='Test',
            Phone='1234567890',
            AccountId = a.Id);
        insert c;
        
        String jsonString = '{"searchField":"FirstName", "subtitleField": "Account.Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test"}';
        
        Test.startTest();
        String responseString = StrikeLookupController.getRecords(jsonString);
        Test.stopTest();
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');
        
        System.assertEquals(1, data.size());
        
        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        System.assertEquals(c.Id, record.get('value'));
    }
    
}