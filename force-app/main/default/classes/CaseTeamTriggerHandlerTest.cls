@isTest
public class CaseTeamTriggerHandlerTest {
    
    @testSetup
    public static void testDataSetup(){
        //Customer Account
        sObject Account = new Account();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();        
        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
         //Case
        sObject Caserec = new Case();
        UtilityTestData.mCase.put('AccountId',lAccount[0].Id);
        Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
        List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec});  
		 //Case Team
        sObject CaseTeamrec = new Case_Team__c();
        UtilityTestData.mCaseTeam.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseTeam.put('User__c',UserInfo.getUserId());
        CaseTeamrec = UtilityTest.putFieldRecord(CaseTeamrec, UtilityTestData.mCaseTeam);
        List<Case_Team__c> lcaseTeam = (List<Case_Team__c>) UtilityTest.makeInsert(new List<sObject>{CaseTeamrec});  
        lcaseTeam[0].Role__c = 'CoOwner';
        update lcaseTeam[0];
    }

    @isTest
    public static void caseTeamUpdateTest(){
       
        List<Case_Team__c> lcaseTeam = new List<Case_Team__c>();
        Map<Id,Case_Team__c> oldMap = new Map<Id,Case_Team__c>([Select Id,Role__c From Case_Team__c]);
        for(Case_Team__c var:[Select Id,Role__c From Case_Team__c limit 1]){
            var.Role__c = 'CoOwner';
            update var;
        }
        for(Case_Team__c ct : oldMap.values()){
            Case_Team__c uct = new Case_Team__c(Id = ct.Id);
            uct.Role__c = 'CoOwner';
            lcaseTeam.add(uct);
        }
        Test.startTest();
         CaseTeamTriggerHandler.handleAfterUpdate(lcaseTeam, oldMap);
        Test.stopTest();
    }
}