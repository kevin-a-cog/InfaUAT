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
public with sharing class CertificationRequestTriggerTest {
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        sObject sObj;       

        Id CustomerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id SupportAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();

        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecordTypeId);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test1 Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecordTypeId);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+110+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        String strProduct = '';
        for(Schema.PicklistEntry objPickList : AccountTeamMember.Product__c.getDescribe().getPickListValues()) {
            strProduct = objPickList.getValue();
            break;
        }

        AccountTeamMember accTeamMember = new AccountTeamMember();
        accTeamMember.AccountId = lNewSupportAccount[0].Id;
        accTeamMember.UserId = UserInfo.getUserId();
        accTeamMember.TeamMemberRole = 'Support SME';
        accTeamMember.Product__c = strProduct;
        insert accTeamMember;

        List<Certification_Request__c> lstCertificationRequests = new List<Certification_Request__c>();
        String strRequestType = '';
        String strCertificationType = '';

        for(Schema.PicklistEntry objPickList : Certification_Request__c.Request_Type__c.getDescribe().getPickListValues()) {
            strRequestType = objPickList.getValue();
            break;
        }

        for(Schema.PicklistEntry objPickList : Certification_Request__c.Certification_Type__c.getDescribe().getPickListValues()) {
            strCertificationType = objPickList.getValue();
            break;
        }

        Certification_Request__c objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = lNewSupportAccount[0].Id;
        objCertificationRequest.Start_Date__c = System.today().addDays(1);
        objCertificationRequest.End_Date__c = System.today().addDays(20);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Submitted for Approval';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);

        objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = lNewSupportAccount[0].Id;
        objCertificationRequest.Start_Date__c = System.today().addDays(1);
        objCertificationRequest.End_Date__c = System.today().addDays(30);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Submitted for Approval';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);
        insert lstCertificationRequests;
    }

    /*
     Method Name : approveCertificationRequestTest
     Description : Testing approving certification request
     Parameters  : None
     Return Type : None
    */
    @isTest
    public static void approveCertificationRequestTest() {
        Test.startTest();
        List<Certification_Request__c> lstCertificationRequests = [Select Id from Certification_Request__c];
        for(Certification_Request__c objCertificationRequest : lstCertificationRequests){
            objCertificationRequest.Status__c = 'Approved';
        }   
        update lstCertificationRequests;
        Test.stopTest();
    }

    /*
     Method Name : muteTriggersTest
     Description : Testing certification request trigger muting.
     Parameters  : None
     Return Type : None
    */
    @isTest
    public static void muteTriggersTest() {

        //Enable muting
        Global_Config__c objSettings = Global_Config__c.getOrgDefaults();
        objSettings.Mute_Triggers__c = true;
        upsert objSettings Global_Config__c.Id;  

        Test.startTest();
        List<Certification_Request__c> lstCertificationRequests = [Select Id from Certification_Request__c];
        for(Certification_Request__c objCertificationRequest : lstCertificationRequests){
            objCertificationRequest.Status__c = 'Approved';
        }   
        update lstCertificationRequests;
        Test.stopTest();
    }
}