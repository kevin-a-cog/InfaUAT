/*
 * Name         :   ManageCasesControllerTest
 * Author       :   Vignesh Divakaran
 * Created Date :   9/26/2022
 * Description  :   Test class for ManageCasesController.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                             Tag
 **********************************************************************************************************
 Vignesh Divakaran      9/26/2022       I2RT-6880       Initial version.                        N/A
 balajip        		1/12/2023		I2RT-7537		Updated the Org Service Name            T01
 */

@isTest
public class ManageCasesControllerTest {

    //Public variables.
    public static Id ECOMMERCE_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();
    public static Id CUSTOMER_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
    public static Id CASE_LITE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();
    
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

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CUSTOMER_ACCOUNT_RECORDTYPEID);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test eCommerce Account');
            UtilityTestData.mAccountData.put('RecordTypeId', ECOMMERCE_ACCOUNT_RECORDTYPEID);
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
            UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration'); //T01
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
            UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
    }

    /*
    Method Name : getCasesTest
    Description : Testing community user access to manage cases in eSupport
    Parameters  : None
    Return Type : None
    */
    @isTest
    public static void getCasesTest() {
        Test.startTest();

        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1];
        Id ecommerceAccountId = [SELECT Id FROM Account WHERE RecordTypeId =: ECOMMERCE_ACCOUNT_RECORDTYPEID LIMIT 1]?.Id;
        Id orgId = [SELECT Id FROM Org__c LIMIT 1]?.Id;

        System.runAs(objUser){
            ManageCasesController.Filter objResponse = ManageCasesController.getFilters();
            System.assert(!objResponse.lstOrgs.isEmpty() && !objResponse.lstStatus.isEmpty(), 'Unable to see filter options');
            ManageCasesController.CasesPageWrapperClass objRequest = new ManageCasesController.CasesPageWrapperClass();
            objRequest.intSearchType = 0; 
            objRequest.strCaseNumberSorting = ''; //T01
            objRequest.intLastViewedRecordCount = 0; //T01
            objRequest.lstOrgs = new List<String>{objResponse.lstOrgs[0].strValue}; 
            objRequest.lstStatus = new List<String>{'New','Assess','Research'};
            ManageCasesController.CasesPageWrapperClass objResult = ManageCasesController.getRecords(objRequest);
            System.assert(!objResult.lstRecords.isEmpty() && !objResult.boolShowExpiredSubscriptionMessage && !objResult.boolShowInvalidAccessMessage, 'Unable to see all cases');

            //Now, we create case as community user
            sObject sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test Case Lite Subject');
            UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
            UtilityTestData.mCase.put('Status', 'New');
            UtilityTestData.mCase.put('Priority', 'P3');
            UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
            UtilityTestData.mCase.put('AccountId', ecommerceAccountId);
            UtilityTestData.mCase.put('Org__c', orgId);
            UtilityTestData.mCase.put('ContactId ', objUser.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

            objRequest.intSearchType = 1;
            objResult = new ManageCasesController.CasesPageWrapperClass();
            objResult = ManageCasesController.getRecords(objRequest);
            //System.assert(!objResult.lstRecords.isEmpty() && !objResult.boolShowExpiredSubscriptionMessage && !objResult.boolShowInvalidAccessMessage, 'Unable to see my cases');
        }
        Test.stopTest();
    }
}