/*  
@Author:        Anil Sahu  
@Created Date:  3may21
@Description:   Test class for orgOutageBanner_Controller controller.
*/
@isTest
public class orgOutageBanner_ControllerTest {

    //Public variables.
    public static Id ECOMMERCE_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();
    public static Id CUSTOMER_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
    public static Id SUPPORT_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
    public static Id CASE_LITE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();

    static testMethod void testFetchOrgNames() {

        SObject sObj = new Account();

        System.runAs(new User(Id=UserInfo.getUserId())){
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CUSTOMER_ACCOUNT_RECORDTYPEID);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
            UtilityTestData.mAccountData.put('RecordTypeId', SUPPORT_ACCOUNT_RECORDTYPEID);
            UtilityTestData.mAccountData.put('Success_Offering__c', 'Premium Success');        
            
            UtilityTestData.mAccountData.put('Active__c', 'true');
            UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id);
            UtilityTestData.mContactData.put('FirstName','test Con FirstName1');
            UtilityTestData.mContactData.put('LastName','test Con LastName1');
            UtilityTestData.mContactData.put('Email',UserInfo.getUserEmail());
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
            UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
            UtilityTestData.mAccContactRelation.put('IsActive','true');
            UtilityTestData.mAccContactRelation.put('Access_Level__c','Read/Write');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

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
            UtilityTestData.mUserData.put('ContactId',contacts[0].Id+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
            List<User> lNewUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Customer_Community_user']?.Id;

            insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);
            
            sObj = new Entitled_Product__c();
            UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
            UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
            UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mEntitledProduct.put('Active__c', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
            List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Org_Entitled_Product__c objOrgEntitledProduct = new Org_Entitled_Product__c();
            objOrgEntitledProduct.Entitled_Product__c = lEntitledProduct[0].Id;
            objOrgEntitledProduct.Org__c = orgs[0].Id;
            insert objOrgEntitledProduct;
        }

        Test.startTest();
        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1]; 
        Account objSupportAccount = [SELECT Id FROM Account WHERE RecordTypeId =: SUPPORT_ACCOUNT_RECORDTYPEID LIMIT 1];
        Org__c objOrg = [SELECT Id FROM Org__c LIMIT 1]; 

        System.runAs(objUser){
            list<string> lstog = orgOutageBanner_Controller.FetchOrgNames(objSupportAccount.Id);
            orgOutageBanner_Controller.FetchOrgInfo(objOrg.Id, false);
            orgOutageBanner_Controller.checkSupportAccountType(objSupportAccount.Id);
            System.assertEquals(0, lstog.size());
        }
        Test.stopTest();
    }

    @isTest
    public static void fetchOrgInfoTest() {

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
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }

        Test.startTest();

        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1];
        Id orgId = [SELECT Id FROM Org__c LIMIT 1]?.Id;

        System.runAs(objUser){
            orgOutageBanner_Controller.FetchOrgInfo(orgId, true);
        }
        Test.stopTest();
    }
}