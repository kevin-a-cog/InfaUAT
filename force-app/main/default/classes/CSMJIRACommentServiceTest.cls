@istest
public class CSMJIRACommentServiceTest {
	   public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static   Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static   Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
       
    @testSetup
    static void setupObjectTestData() {
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');
        
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
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }

    
     @isTest
    static void testAllMethods1(){
        Account acc = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];

       //Now we create a Plan.
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'Test';
            objPlan.Account__c=acc.Id;
            insert objPlan;

        Test.startTest();
        //Create Related Feed Item Record
        FeedItem feedItem = new FeedItem(ParentId = objPlan.Id, Body = 'Test Body');
        insert feedItem;
        Test.stopTest();
    }
}