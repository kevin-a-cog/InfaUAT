/*
 * Name         :   CertificationRequestTriggerTest
 * Author       :   Vignesh Divakaran
 * Created Date :   5/27/2022
 * Description  :   Test class for CertificationRequestTrigger, CertificationRequestTriggerHandler,CertificationRequestTriggerHelper.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      5/27/2022       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public class OrgServiceTriggerTest {
      
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        sObject sObj;

        Id CustomerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();

        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecordTypeId);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Org__c();
        UtilityTestData.mOrgData.put('Org_Name__c', 'Test Org');
        UtilityTestData.mOrgData.put('OrgType__c', 'Trial');
        UtilityTestData.mOrgData.put('Pod_Name__c', 'TEST-POD-NAME');
        UtilityTestData.mOrgData.put('OfferCode__c', 'TEST-OFFER-CODE');
        UtilityTestData.mOrgData.put('Pod_Location__c', 'TEST-LOCATION');
        UtilityTestData.mOrgData.put('Account__c', lNewCustomerAccount[0].Id+'');
        UtilityTestData.mOrgData.put('Pod_Location__c', 'XXXXYYYYYZZZZZ-TEST');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
        List<Account> lNewOrg = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    /*
     Method Name : orgServiceInsertTest
     Description : Testing org service creation
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void orgServiceInsertTest() {
        Test.startTest();

        Id orgId = [SELECT Id FROM Org__c LIMIT 1]?.Id;
        System.assertNotEquals(orgId == null, true, 'Org is not created');

        Date dt = System.today().addDays(90);
        sObject sObj = new Org_Service__c();
        UtilityTestData.mOrgServiceData.put('Org_ID__c', orgId+'');
        UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
        UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
        List<Account> lNewOrgService = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Id orgServiceId = [SELECT Id FROM Org_Service__c LIMIT 1]?.Id;
        System.assertNotEquals(orgServiceId == null, true, 'Org Service is not created');

        Org__c objOrg = [SELECT Id,Support_Lite_End_Date__c,Support_Lite__c FROM Org__c LIMIT 1];
        System.assert(objOrg != null && objOrg?.Support_Lite__c, 'Incorrect rollup of Support Lite to Org');
        
        Test.stopTest();
    }

    /*
     Method Name : orgServiceUpdateTest
     Description : Testing org service updation
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void orgServiceUpdateTest() {
        Test.startTest();
        
        Id orgId = [SELECT Id FROM Org__c LIMIT 1]?.Id;
        System.assertNotEquals(orgId == null, true, 'Org is not created');

        Date dt = System.today().addDays(90);
        sObject sObj = new Org_Service__c();
        UtilityTestData.mOrgServiceData.put('Org_ID__c', orgId+'');
        UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
        UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
        List<Account> lNewOrgService = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Id orgServiceId = [SELECT Id FROM Org_Service__c LIMIT 1]?.Id;
        System.assertNotEquals(orgServiceId == null, true, 'Org Service is not created');

        Org__c objOrg = [SELECT Id,Support_Lite_End_Date__c,Support_Lite__c FROM Org__c LIMIT 1];
        System.assert(objOrg != null && objOrg?.Support_Lite__c, 'Org Service created did not rollup correctly for Support Lite');

        dt = System.today().addDays(120);
        Org_Service__c objOrgService = new Org_Service__c(Id = orgServiceId);
        objOrgService.Expiration_Date__c = dt;
        update objOrgService;

        objOrg = [SELECT Id,Support_Lite_End_Date__c,Support_Lite__c FROM Org__c LIMIT 1];
        System.assert(objOrg != null && objOrg?.Support_Lite__c, 'Org Service updated did not rollup correctly for Support Lite');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testservice(){
        Test.startTest();
        
        //Org creation.
		Org__c objOrg = new Org__c();
		objOrg.OrgID__c = 'test' + Datetime.now();
		//objOrg.Account__c = objAccount.Id;
		insert objOrg;
		Org__c objOrg2 = new Org__c();
		objOrg2.OrgID__c = 'test2' + Datetime.now();
		//objOrg2.Account__c = objAccount.Id;
		insert objOrg2;

        //Org service creation.
		Org_Service__c objOrgService = new Org_Service__c();
		List<Org_Service__c> lstOrgServices = new List<Org_Service__c>();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'yiasdooohaosidmaosd';
		objOrgService.Name = 'Data Test Service';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'rasraseaasd';
		objOrgService.Name = 'Data Test';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'yiasdooosassd';
		objOrgService.Name ='test';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg2.Id;
		objOrgService.Service_UUID__c = 'yiasdooosassd';
		objOrgService.Name ='test';
		lstOrgServices.add(objOrgService);
		insert lstOrgServices;
        objOrgService.Number_of_Entitlements_consumed__c = 230;
        update objOrgService;
        Test.stopTest();
    }
}