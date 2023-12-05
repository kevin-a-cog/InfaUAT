@isTest
public class AccountContactRelationTriggerHandlerTest {
    @testSetup
    static void setupObjectTestData() {
    
    Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();

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
        UtilityTestData.mAccountData.put('Max_Customer_R_W_Contacts__c','3');
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

          
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
        UtilityTestData.mContactData.put('MailingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Timezone__c();
        UtilityTestData.mTimezone.put('Name','GMT–07:00 Pacific Daylight Time (America/Los_Angeles)');
        UtilityTestData.mTimezone.put('TimeZone__c','GMT–07:00 Pacific Daylight Time (America/Los_Angeles)');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimezone);

        SObject sObj1 = new Timezone__c();
        UtilityTestData.mTimezone.put('Name','GMT+05:30 India Standard Time (Asia/Kolkata)');
        UtilityTestData.mTimezone.put('Timezone__c','GMT+05:30 India Standard Time (Asia/Kolkata)');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mTimezone);
        List<Timezone__c> lTimezone = (List<Timezone__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sobj1});

        sObj = new AccountContactRelation();
        UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
        UtilityTestData.mAccContactRelation.put('ContactId',lContact[0].id);
        UtilityTestData.mAccContactRelation.put('IsActive','true');
        UtilityTestData.mAccContactRelation.put('Primary__c','true');
        UtilityTestData.mAccContactRelation.put('Timezone__c','GMT+05:30 India Standard Time (Asia/Kolkata)');
        UtilityTestData.mAccContactRelation.put('Access_Level__c' , 'Read/Write');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
        List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
       

    }


    static testmethod void testAccountContactRelation(){

    Account CustAccount = [Select id ,parentId,recordtype.name from account where recordtype.name ='Customer Account' limit 1 ];
    Account SupportAccount = [Select id ,parentId,recordtype.name from account where recordtype.name ='Support Account' limit 1];
    Contact custcontact =  [Select Id,Name ,AccountId from Contact limit 1];

    system.assert(SupportAccount != null, 'SupportAccount does not exist');

    system.assert(custcontact != null, 'custcontact does not exist');

    /*
    AccountContactRelation  acr = new AccountContactRelation();
    acr.ContactId =custcontact.id;
    acr.AccountId = SupportAccount.Id;
    acr.IsActive = true;
    acr.Primary__c = true;
    acr.Access_Level__c = 'Read/Write';
	acr.TimeZone__c ='GMT–07:00 Pacific Daylight Time (America/Los_Angeles)';
    Insert acr;

    Contact custcontactUpdated =  [Select Id,Name,TimeZone_Lookup__c,TimeZone_Lookup__r.Name,AccountId from Contact limit 1];
    //system.assertEquals('GMT–07:00 Pacific Daylight Time (America/Los_Angeles)',custcontactUpdated.TimeZone_Lookup__r.Name, 'Conctact Timezone is not populated');
    System.debug('custcontactUpdated'+custcontactUpdated);

    */
    AccountContactRelation updateacr = [Select id , TimeZone__c from AccountContactRelation where AccountId = :SupportAccount.Id limit 1];
    System.debug('updateacr'+updateacr);

    updateacr.Timezone__c= 'GMT+05:30 India Standard Time (Asia/Kolkata)';
    update updateacr;
    System.debug('updateacr'+updateacr);


    Contact custcontactUpdated1 =  [Select Id,Name,TimeZone_Lookup__c,TimeZone_Lookup__r.Name,AccountId from Contact limit 1];
   // system.assertEquals('GMT+05:30 India Standard Time (Asia/Kolkata)',custcontactUpdated1.TimeZone_Lookup__r.Name, 'Conctact Timezone is not updated');
    System.debug('custcontactUpdated1'+custcontactUpdated1);

    
    try{
        updateacr.Access_Level__c = 'Read Only';
        update updateacr;
    }
    Catch(Exception e){
        System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Primary contact read write validation ');
    }

    try{
        updateacr.Primary__c = false ;
        update updateacr;
    }
    Catch(Exception e){
        System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'min Primary contact  validation ');
    }


    }
}