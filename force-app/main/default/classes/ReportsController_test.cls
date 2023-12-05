@istest
public class ReportsController_test{
    @testSetup
    static void setupObjectTestData() {
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        SObject sObj1;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
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
        
        sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('origin', 'Web');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c', 'Callback');
      //  UtilityTestData.mCase.put('Next_Action_Owner__c', 'Case Owner');
        UtilityTestData.mCase.put('Priority ', 'P1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

    }
    public static testmethod void testMethod1(){
        account acc = [select id from account limit 1];
        string tod=string.valueOf(system.today());
        ReportsController.casesinfo(acc.id,tod ,tod,tod,tod);
        ReportsController.casesinfo(acc.id,null ,null,null,null);
        ReportsController.AverageDaysToClose(acc.id, string.valueOf(system.today()),string.valueOf(system.today()),null,null);
        ReportsController.MonthlyCases(acc.id, null ,null,null,null);
        ReportsController.casesByGroupFilter(acc.id,'Priority', string.valueOf(system.today()),string.valueOf(system.today()),null,null);
   		ReportsController.getMonth(1);
        ReportsController.getMonth(2);
        ReportsController.getMonth(3);
        ReportsController.getMonth(4);
        ReportsController.getMonth(5);
        ReportsController.getMonth(6);
        ReportsController.getMonth(7);
        ReportsController.getMonth(8);
        ReportsController.getMonth(9);
        ReportsController.getMonth(10);
        ReportsController.getMonth(11);
        ReportsController.getMonth(12);
        ReportsController.getMonth(15);
    }
}