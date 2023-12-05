/*
* Name			:	CSMManagePlanContactsTest
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Test Class for CSMManagePlanContacts

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
@isTest
public class CSMManagePlanContactsTest {
    @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','Lname');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
        
        sObject Contact2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('Email','test145@test.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact2 = UtilityTest.putFieldRecord(Contact2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact, Contact2});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','Business Value');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
    }
    
    @isTest
    public static void getUnassignedTest(){
        Plan__c plan=[SELECT Id, Account__c FROM Plan__c limit 1];
        GlobalDataTableWrapperClass obj=new GlobalDataTableWrapperClass();
        obj=CSMManagePlanContacts.getRecords(plan.Id,false,plan.Account__c);
        if( obj.lstRecords!=null){
            system.assert( obj.lstRecords.size()>0);}
        
    }
    @isTest
    public static void getAssignedTest(){
        Plan__c plan=[SELECT Id, Account__c FROM Plan__c limit 1];    
        GlobalDataTableWrapperClass obj=new GlobalDataTableWrapperClass();
        obj=CSMManagePlanContacts.getRecords(plan.Id,true,plan.Account__c);
        system.assert( obj.lstRecords.size()>0);
    }
    @isTest
    public static void getRecordsRelatedest(){
        Plan__c plan=[SELECT Id, Account__c FROM Plan__c limit 1];
        GlobalDataTableWrapperClass obj=new GlobalDataTableWrapperClass();
        obj=CSMManagePlanContacts.getRecords(plan.Id,false,plan.Account__c);
        if(obj.lstRecords!=null){
            system.assert( obj.lstRecords.size()>0);}
        try{
            CSMManagePlanContacts.getRecordsRelated(plan.Id,[Select Id,Email from Contact limit 1]);
        }catch(Exception e){
            //Check for duplciate error
            system.assert(String.isNotBlank(e.getMessage()));            
        }
    }
    
    @isTest
    public static void getRecordsDeletedTest(){
        List<Plan_Contact__c> lstRecords =  new List<Plan_Contact__c>([Select Id from Plan_Contact__c]);
        CSMManagePlanContacts.getRecordsDeleted(lstRecords);
        List<Plan_Contact__c> checkdeleted =  new List<Plan_Contact__c>([Select Id from Plan_Contact__c]);
        system.assert( checkdeleted.size()<=0);
    }
    @isTest
    public static void getRecordsUpdatedTest(){
        List<Plan_Contact__c> lstRecords =  new List<Plan_Contact__c>([Select Id,Role__c from Plan_Contact__c]);
        for(Plan_Contact__c pc:lstRecords){
            pc.Role__c='Business Owner';
        }      
        CSMManagePlanContacts.getRecordsUpdated(lstRecords);
        List<Plan_Contact__c> checkUpdate =  new List<Plan_Contact__c>([Select Id,Role__c from Plan_Contact__c]);
        system.assert( checkUpdate[0].Role__c == 'Business Owner');
    }
    
}