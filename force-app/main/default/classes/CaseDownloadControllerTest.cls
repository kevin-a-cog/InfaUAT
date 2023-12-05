/*
 * Name         :   CaseDownloadControllerTest
 * Author       :   Vignesh Divakaran
 * Created Date :   9/28/2022
 * Description  :   Test class for CaseDownloadController.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      9/28/2022       I2RT-6880       Initial version.            N/A
 Isha Bansal           06/25/2023       I2RT-8503       Status field change         T01
 */

@isTest
public class CaseDownloadControllerTest {
   
    //Public variables.
    public static Id ECOMMERCE_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();    
    public static Id CASE_LITE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();

    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        

        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        system.runAs(adminUser){
                    sObject sObj;

                    sObj = new TimeZone__c();
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
                    List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  

                    sObj = new Account();
                    UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
                    UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
                    UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                    UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');            
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                    List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});   

                    sObj = new Account();
                    UtilityTestData.mAccountData.put('Name', 'Test eCommerce Account');
                    UtilityTestData.mAccountData.put('RecordTypeId', ECOMMERCE_ACCOUNT_RECORDTYPEID);
                    UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                    UtilityTestData.mAccountData.put('End_Date__c', String.valueOf(Date.today()+20));          
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                    List<Account> lNewEcommerceAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);            
                    List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    sObj = new AccountContactRelation();
                    UtilityTestData.mAccContactRelation.put('AccountId', lNewEcommerceAccount[0].Id);
                    UtilityTestData.mAccContactRelation.put('ContactId', contacts[0].Id);
                    UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
                    UtilityTestData.mAccContactRelation.put('IsActive', 'true');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
                    List<AccountContactRelation> lNewAccountContacts = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    sObj = new AccountContactRelation();
                    UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
                    UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
                    UtilityTestData.mAccContactRelation.put('IsActive','true');
                    UtilityTestData.mAccContactRelation.put('favorite__c','true');
                    UtilityTestData.mAccContactRelation.put('Access_Level__c','Read/Write');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
                    List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    sObj = new Org__c();
                    UtilityTestData.mOrgData.put('Org_Name__c', 'Test Org');
                    UtilityTestData.mOrgData.put('OrgType__c', 'Trial');
                    UtilityTestData.mOrgData.put('Pod_Name__c', 'TEST-POD-NAME');
                    UtilityTestData.mOrgData.put('OfferCode__c', 'TEST-OFFER-CODE');
                    UtilityTestData.mOrgData.put('Pod_Location__c', 'TEST-LOCATION');
                    UtilityTestData.mOrgData.put('Account__c', lNewEcommerceAccount[0].Id+''); //ecommerce account
                    UtilityTestData.mOrgData.put('Pod_Location__c', 'XXXXYYYYYZZZZZ-TEST');
                    UtilityTestData.mOrgData.put('OrgId__c', 'ORGTESTZZZXXXYYY');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
                    List<Org__c> lNewOrg = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    Date dt = System.today().addDays(90);
                    sObj = new Org_Service__c();
                    UtilityTestData.mOrgServiceData.put('Org_ID__c', lNewOrg[0].Id+''); //ecommerce account
                    UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
                    UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
                    List<Org_Service__c> lNewOrgService = (List<Org_Service__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    sObj = new Org_User__c();
                    UtilityTestData.mOrgUserData.put('Contact__c', contacts[0].Id);
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
                    UtilityTestData.mUserData.put('ContactId',contacts[0].Id+'');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
                    List<User> lNewUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Support_Lite_Community_User']?.Id;
                    insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);
                    
                    permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Customer_Community_user']?.Id;
                    insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);
                    sObj = new Entitled_Product__c();
                    UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
                    UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
                    UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
                    UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
                    UtilityTestData.mEntitledProduct.put('Active__c', 'True');
                    UtilityTestData.mEntitledProduct.put('End_Date__c', System.today()+2+'');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
                    List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

                
                
                    //create an Entitlement record
                    sObj = new Entitlement();
                    UtilityTestData.mEntitlement.put('AccountId',lNewCustomerAccount[0].Id);
                    UtilityTestData.mEntitlement.put('Status','Active');
                    UtilityTestData.mEntitlement.put('StartDate',system.today().addDays(-10)+'');
                    UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
                    List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    
                    List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Signature Success' and IsActive = true LIMIT 1];
                    system.debug('@@lstEntitlementProcess= '+lstEntitlementProcess);
                    if (lstEntitlementProcess.size()>0)
                    {
                        Entitlement updateEntitlementRec = new Entitlement();
                        updateEntitlementRec.Id = lEntitlement[0].Id;
                        updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
                        update updateEntitlementRec;        
                    } 
                    List<BusinessHours> bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
                    TimeZone tz = UserInfo.getTimeZone();
                    sObj = new Case();
                    UtilityTestData.mCase.put('Subject', 'Test technical Case');
                    UtilityTestData.mCase.put('status', 'New');
                    UtilityTestData.mCase.put('Priority', 'P3');
                    UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
                    UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
                    UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
                    UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
                    UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);           
                    UtilityTestData.mCase.put('ContactId ', contacts[0].Id);       
                    UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
                    UtilityTestData.mCase.put('slaStartDate ', system.now()+'');            
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
                    List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

                    SObject sObjCaselite = new Case();
                    UtilityTestData.mCase.put('Subject', 'Test Case Lite Case');
                    UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
                    UtilityTestData.mCase.put('Status', 'New');
                    UtilityTestData.mCase.put('Priority', 'P3');
                    UtilityTestData.mCase.put('RecordTypeId', CASE_LITE_RECORDTYPEID);
                    UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);    
                    UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);          
                    UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
                    UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
                    sObj = UtilityTest.putFieldRecord(sObjCaselite, UtilityTestData.mCase); 
                
                
                    List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObjCaselite});
                    }
            
         
       
    }

    /*
     Method Name : orgDownloadCasesTest
     Description : Testing community user access to download cases raised against org
     Parameters  : None
     Return Type : None
     */
    
    @isTest
   public static void orgDownloadCasesTest() {
        Test.startTest();

        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1];
        Id ecommerceAccountId = [SELECT Id FROM Account WHERE RecordTypeId =: ECOMMERCE_ACCOUNT_RECORDTYPEID LIMIT 1]?.Id;
        Id orgId = [SELECT Id FROM Org__c LIMIT 1]?.Id;
        String strCaseNumber = [SELECT CaseNumber FROM Case LIMIT 1]?.CaseNumber;

        System.runAs(objUser){
            CaseDownloadController.DownloadFilter objResponse = CaseDownloadController.getFilters(false);
            System.assert(!objResponse.lstOrgs.isEmpty(), 'Unable to see ORG IDs');
            CaseDownloadController.DownloadFilter objRequest = new CaseDownloadController.DownloadFilter();
            objRequest.strCaseNumber = strCaseNumber;
            objRequest.strOrgId = orgId;
            objRequest.strStatus = new List<String>{'New'}; //T01
            objRequest.strPriority = 'P3';
            objRequest.strCaseRecordTypeId = CASE_LITE_RECORDTYPEID;
            objRequest.dtFrom = System.today().addDays(-1);
            objRequest.dtTo = System.today();
            objRequest.boolShowSupportAccount = false;
            List<Case> lstCases = CaseDownloadController.getRecords(objRequest);
            //System.assert(!lstCases.isEmpty(), 'Unable to download cases raised against an ORG');
        }
        Test.stopTest();
    }

    @isTest
    static void testDownloadEsupport(){
        List<User> portalUsers = [SELECT ID FROM User Where Username = 'testOrgEmail@test.com' ];
        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
       /* for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
*/
        Account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType]; 
        Test.startTest();
        system.runAs(portalUsers[0]){
                  
            try{
                CaseDownloadController.DownloadFilter objResponse = CaseDownloadController.getFilters(true);               
                CaseDownloadController.DownloadFilter objRequest = new CaseDownloadController.DownloadFilter();               
                objRequest.strSupportAccountId = acc.Id;
                objRequest.strStatus = new List<String>{'Assess'}; //T01
                objRequest.strPriority = 'P3';
                objRequest.strCaseRecordTypeId = technicalCaseRecType;
                objRequest.dtFrom = System.today().addDays(-2);
                objRequest.dtTo = System.today().addDays(1);
                objRequest.boolShowSupportAccount = true;
                List<Case> lstCases = CaseDownloadController.getRecords(objRequest);
               // System.assertEquals(lstCases.size()>0,true); 
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }
}