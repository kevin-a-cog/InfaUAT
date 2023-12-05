@isTest
global class CaseCommentEmailStatTest {
    
   
    @isTest
    global static void testPositiveControllerBounced() {
        CaseCommentEmailStat__c acct1 = new CaseCommentEmailStat__c();
        acct1.Delivery__c = 'Bounced';
        acct1.Email__c = 'Test@test.com';
         Test.StartTest();
          insert acct1;
          Test.StopTest();
    }
    @isTest
    global static void testPositiveControllerDropped() {
        CaseCommentEmailStat__c acct1 = new CaseCommentEmailStat__c();
        acct1.Delivery__c = 'Dropped';
        acct1.Email__c = 'Test@test.com';
         Test.StartTest();
          insert acct1;
          Test.StopTest();
    }

}