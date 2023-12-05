@isTest
public with sharing class RelatedListControllerTest {
    public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    

    @isTest public static void testInit(){
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
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
        
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(RelatedListController.FIELDS_PARAM, 'Name, Title, Email, Phone');
        requestMap.put(RelatedListController.RELATED_FIELD_API_NAME_PARAM, 'AccountId');
        requestMap.put(RelatedListController.RECORD_ID_PARAM, lNewSupportAccount[0].Id);
        requestMap.put(RelatedListController.NUMBER_OF_RECORDS_PARAM, 1);
        requestMap.put(RelatedListController.SOBJECT_API_NAME_PARAM, 'Contact');
        requestMap.put(RelatedListController.SORTED_BY_PARAM, 'Name');
        requestMap.put(RelatedListController.SORTED_DIRECTION_PARAM, 'ASC');
                
        String jsonData = RelatedListController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(RelatedListController.RECORDS_PARAM);
        //System.assert(!records.isEmpty());
        String iconName = (String)responseMap.get(RelatedListController.ICON_NAME_PARAM);
        //System.assert(String.isNotBlank(iconName));
    }
}