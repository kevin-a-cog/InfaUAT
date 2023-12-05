/*
 * Name         :   SendNotificationActionTest
 * Author       :   Vignesh Divakaran
 * Created Date :   12/2/2022
 * Description  :   Test class for SendNotificationAction.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      12/2/2022       I2RT-7532       Initial version.            N/A
 */

@isTest
public class SendNotificationActionTest {

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

            sObject sObj,sObj1,sObj2;

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
            UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);

            sObj1 = new Case();
            UtilityTestData.mCase.put('Subject', 'Test Case Lite Case');
            UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
            UtilityTestData.mCase.put('Status', 'New');
            UtilityTestData.mCase.put('Priority', 'P2');
            UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCase);

            sObj2 = new Case();
            UtilityTestData.mCase.put('Subject', 'Test Case Lite Case');
            UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
            UtilityTestData.mCase.put('Status', 'New');
            UtilityTestData.mCase.put('Priority', 'P1');
            UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mCase);
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        }

        List<Case> lstCases = [SELECT Id,Status,OwnerId FROM Case];

        for(Case objCase : lstCases){
            objCase.OwnerId = UserInfo.getUserId();
        }
        update lstCases;
    }

    /*
     Method Name : scheduledCaseCommentTest
     Description : Testing scheduled case comments
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void scheduledCaseCommentTest() {

        List<Case> lstCases = [SELECT Id,Status,OwnerId FROM Case];
        List<Case_Comment__c> lstCaseComments = new List<Case_Comment__c>();

        Case_Comment__c objCaseComment1 = new Case_Comment__c();
        objCaseComment1.Comment__c = 'Test case comment';
        objCaseComment1.Inbound__c = false;
        objCaseComment1.Status__c = 'Scheduled';
        objCaseComment1.Visibility__c = 'External';
        objCaseComment1.Case__c = lstCases[0].Id;
        objCaseComment1.Comment_to_Search__c = 'Test case comment';
        objCaseComment1.Type__c = 'Request More Info';
        objCaseComment1.Scheduled_Case_Next_Action__c = 'Customer';
        objCaseComment1.Date_Time_Scheduled__c = System.now();
        lstCaseComments.add(objCaseComment1);

        Case_Comment__c objCaseComment2 = new Case_Comment__c();
        objCaseComment2.Comment__c = 'Test case comment';
        objCaseComment2.Inbound__c = false;
        objCaseComment2.Status__c = 'Scheduled';
        objCaseComment2.Visibility__c = 'External';
        objCaseComment2.Case__c = lstCases[1].Id;
        objCaseComment2.Comment_to_Search__c = 'Test case comment';
        objCaseComment2.Type__c = 'Provide Solution';
        objCaseComment2.Scheduled_Case_Next_Action__c = 'Customer';
        objCaseComment2.Date_Time_Scheduled__c = System.now();
        lstCaseComments.add(objCaseComment2);

        Case_Comment__c objCaseComment3 = new Case_Comment__c();
        objCaseComment3.Comment__c = 'Test case comment';
        objCaseComment3.Inbound__c = false;
        objCaseComment3.Status__c = 'Scheduled';
        objCaseComment3.Visibility__c = 'External';
        objCaseComment3.Case__c = lstCases[2].Id;
        objCaseComment3.Comment_to_Search__c = 'Test case comment';
        objCaseComment3.Type__c = 'Send RCA';
        objCaseComment3.Scheduled_Case_Next_Action__c = 'Customer';
        objCaseComment3.Date_Time_Scheduled__c = System.now();
        lstCaseComments.add(objCaseComment3);

        insert lstCaseComments;

        Map<Id, Case_Comment__c> mapCaseComments = new Map<Id, Case_Comment__c>([SELECT Id FROM Case_Comment__c WHERE Id IN :lstCaseComments]);

        Test.startTest();
        SendNotificationAction.sendNotificationToUser(new List<Id>(mapCaseComments.keySet()));
        Test.stopTest();
    }

}