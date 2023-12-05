/*
 * Name         :   SupportLiteSharingTest
 * Author       :   Vignesh Divakaran
 * Created Date :   8/30/2022
 * Description  :   Test class for SupportLiteSharing.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      8/30/2022       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public class SupportLiteSharingTest {
      
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        System.runAs(new User(Id=UserInfo.getUserId())){
            sObject sObj;

            Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
            Id ecommerceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();
            Id caseLiteRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', customerAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test eCommerce Account');
            UtilityTestData.mAccountData.put('RecordTypeId', ecommerceAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewEcommerceAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','TEST CONTACT FIRSTNAME');
            UtilityTestData.mContactData.put('LastName','TEST CONTACT LASTNAME');
            UtilityTestData.mContactData.put('Email','testOrgEmail@test.com');
            UtilityTestData.mContactData.put('Phone','1234567890');
            UtilityTestData.mContactData.put('MailingCountry','USA');
            UtilityTestData.mContactData.put('INFA_Language__c','English');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lNewContacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mAccContactRelation.put('ContactId', lNewContacts[0].Id);
            UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
            UtilityTestData.mAccContactRelation.put('IsActive', 'true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            List<AccountContactRelation> lNewAccountContacts = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Org_Name__c', 'Test Org');
            UtilityTestData.mOrgData.put('OrgType__c', 'Trial');
            UtilityTestData.mOrgData.put('Pod_Name__c', 'TEST-POD-NAME');
            UtilityTestData.mOrgData.put('OfferCode__c', 'TEST-OFFER-CODE');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'TEST-LOCATION');
            UtilityTestData.mOrgData.put('Account__c', lNewEcommerceAccount[0].Id+'');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'XXXXYYYYYZZZZZ-TEST');
            UtilityTestData.mOrgData.put('OrgId__c', 'ORGTESTZZZXXXYYY');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> lNewOrg = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Date dt = System.today().addDays(90);
            sObj = new Org_Service__c();
            UtilityTestData.mOrgServiceData.put('Org_ID__c', lNewOrg[0].Id+'');
            UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
            UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple DI');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
            List<Org_Service__c> lNewOrgService = (List<Org_Service__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org_User__c();
            UtilityTestData.mOrgUserData.put('Contact__c', lNewContacts[0].Id);
            UtilityTestData.mOrgUserData.put('Org__c', lNewOrg[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
            List<Org_User__c> lNewOrgUsers = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Id customerCommunityProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1]?.Id;

            sObj = new User();
            UtilityTestData.mUserData.put('ProfileId',customerCommunityProfileId+'');
            UtilityTestData.mUserData.put('Username','testOrgEmail@test.com');
            UtilityTestData.mUserData.put('Email','testOrgEmail@test.com');
            UtilityTestData.mUserData.put('Alias','talias');
            UtilityTestData.mUserData.put('CommunityNickname','testUserNickname');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('FirstName','Test');
            UtilityTestData.mUserData.put('LastName','User');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('ContactId',lNewContacts[0].Id+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
            List<User> lNewUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Support_Lite_Community_User']?.Id;

            insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);

            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test Case Lite Case');
            UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
            UtilityTestData.mCase.put('Status', 'New');
            UtilityTestData.mCase.put('Priority', 'P3');
            UtilityTestData.mCase.put('RecordTypeId', caseLiteRecordTypeId);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
    }

    /*
     Method Name : validateUserAccessTest
     Description : Testing community user access to case, account & contact
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void validateUserAccessTest() {
        Test.startTest();
        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1];
        String strOrgUUID = [SELECT OrgID__c FROM Org__c LIMIT 1]?.OrgID__c;
        Id ecommerceAccountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'eCommerce']?.Id;
        String strCaseId = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Case_Lite' LIMIT 1]?.Id;
        System.runAs(objUser){
            System.assert(SupportLiteSharing.validateUserAccess('Case','CREATE',strOrgUUID), 'Insufficient access to create case');
            System.assert(SupportLiteSharing.validateUserAccess('Case','READ',strCaseId), 'Insufficient access to view case');
            System.assert(SupportLiteSharing.validateUserAccess('Account','READ',strOrgUUID), 'Insufficient access to view account');
            System.assert(SupportLiteSharing.validateUserAccess('Contact','READ',ecommerceAccountId), 'Insufficient access to view contact');
            System.assert(!SupportLiteSharing.validateUserAccess('Case','',strOrgUUID), 'SECURITY ISSUE: User is able to access case without required permissions');
            System.assert(!SupportLiteSharing.validateUserAccess('Account','',strOrgUUID), 'SECURITY ISSUE: User is able to access account without required permissions');
        }
        Test.stopTest();
    }    
}