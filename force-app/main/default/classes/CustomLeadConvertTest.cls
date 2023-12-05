/***************************************************************************************************************************************************************
*  @Class Name: CustomLeadConvertTest
*  @Author: Jiju N
*  @Date: 29 AUG 2022
*  @Description: Test class for CustomLeadConvert
****************************************************************************************************************************************************************
*/
@isTest
public class CustomLeadConvertTest {
    
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
    Static Id ProspectAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
    
    static testMethod void testCustomLeadConvertSuccess() {
        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test');
        UtilityTestData.mLeadData.put('Email','test@testr.q');
        UtilityTestData.mLeadData.put('Country','United States');
        UtilityTestData.mLeadData.put('FirstName','test resell');
        
        //create lead
        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        
        List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        
        Test.startTest();
        Map<String,String> responseMap = CustomLeadConvert.convertLead(leadList[0].Id, '', '','', true,'');
        Test.stopTest();
        List<lead> convertedLeadList = [SELECT Id,convertedaccountId,convertedcontactId FROM Lead where Id =:leadList[0].Id];
        system.assertEquals(convertedLeadList[0].convertedaccountId, responseMap.get('accountId'), 'Converted account does not match with actual account on lead');
        system.assertEquals(convertedLeadList[0].convertedcontactId, responseMap.get('contactId'), 'Converted contact does not match with actual contact on lead');
    }
    
    static testMethod void testCustomLeadConvertFail() {
        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test');
        UtilityTestData.mLeadData.put('Email','test@testr.q');
        UtilityTestData.mLeadData.put('Country','');
        UtilityTestData.mLeadData.put('FirstName','test resell');
        
        //create lead
        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        
        List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        
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
        
        
        Test.startTest();
        Map<String,String> responseMap = CustomLeadConvert.convertLead(leadList[0].Id, '', '','', true,'');
        Map<String,String> responseMap1 = CustomLeadConvert.convertLead(leadList[0].Id,lAccount[0].Id,lContact[0].Id,'', true,'');
        Test.stopTest();
        system.assertEquals('failed', responseMap.get('response'), 'lead was converted successfully');
    }
}