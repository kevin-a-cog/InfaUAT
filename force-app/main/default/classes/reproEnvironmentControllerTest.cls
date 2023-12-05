@isTest
public class reproEnvironmentControllerTest {

    @testSetup
    public static void testDataSetup(){
        
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();  
        Id supRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();  
        //Customer Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
         //Support Account
        sObject supAccount = new Account();
        UtilityTestData.mAccountData.put('Name','Support Account');
        UtilityTestData.mAccountData.put('BillingCountry','Africa');
        UtilityTestData.mAccountData.put('RecordTypeId',supRecordTypeId1);
        UtilityTestData.mAccountData.put('ParentId',lAccount[0].Id);
        supAccount = UtilityTest.putFieldRecord(supAccount, UtilityTestData.mAccountData);
        List<Account> lSupAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{supAccount});
         
        //Case Owner
        sObject UserRec = new User();
        UtilityTestData.mUserData.put('FirstName','Test');
        UtilityTestData.mUserData.put('LastName','User');
        Id ProfileId = [Select Id, Name From Profile Where Name= 'Employee'].Id;
        UtilityTestData.mUserData.put('ProfileId',ProfileId);    
        UserRec = UtilityTest.putFieldRecord(UserRec, UtilityTestData.mUserData);
        List<User> lcaseOwneruser = (List<User>) UtilityTest.makeInsert(new List<sObject>{UserRec}); 
        
        //Repo User
        sObject UserRepoRec = new User();
        UtilityTestData.mUserData.put('FirstName','Repo');
        UtilityTestData.mUserData.put('LastName','User12');
        UtilityTestData.mUserData.put('Username','repouser1234@domain.com.test');
        UtilityTestData.mUserData.put('Email','repouser1234@domain.com');
        UtilityTestData.mUserData.put('CommunityNickname','repouser123');
        UtilityTestData.mUserData.put('ProfileId',ProfileId);    
        UserRepoRec = UtilityTest.putFieldRecord(UserRepoRec, UtilityTestData.mUserData);
        List<User> lRepoOwneruser = (List<User>) UtilityTest.makeInsert(new List<sObject>{UserRepoRec});
        
        //Case
        sObject Caserec = new Case();
        UtilityTestData.mCase.put('AccountId',lAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c',lSupAccount[0].Id);
        UtilityTestData.mCase.put('OwnerId',lcaseOwneruser[0].Id);
        Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
        List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec}); 
        
        //Repro Environment
        sObject Reprorec = new Repro_Environment__c();
        UtilityTestData.mCaseReproEnvironment.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseReproEnvironment.put('OwnerId',lRepoOwneruser[0].Id);
        Reprorec = UtilityTest.putFieldRecord(Reprorec, UtilityTestData.mCaseReproEnvironment);
        List<Repro_Environment__c> lRepo = (List<Repro_Environment__c>) UtilityTest.makeInsert(new List<sObject>{Reprorec});
        
        //Case Repro Environment
        sObject CaseReprorec = new Case_Repro_Environment__c();
        UtilityTestData.mCaseReproEnvironment.put('Case__c',lcase[0].Id);
        //UtilityTestData.mCaseReproEnvironment.put('Repro_Environment__c',lRepo[0].Id);
        CaseReprorec = UtilityTest.putFieldRecord(CaseReprorec, UtilityTestData.mCaseReproEnvironment);
        List<Case_Repro_Environment__c> lcaseRepo = (List<Case_Repro_Environment__c>) UtilityTest.makeInsert(new List<sObject>{CaseReprorec});

		
        //Case Team
        sObject CaseTeamrec = new Case_Team__c();
        UtilityTestData.mCaseTeam.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseTeam.put('User__c',UserInfo.getUserId());
        UtilityTestData.mCaseTeam.put('Role__c',CaseTeamService.TEAM_ROLE_CO_OWNER);
        CaseTeamrec = UtilityTest.putFieldRecord(CaseTeamrec, UtilityTestData.mCaseTeam);
        List<Case_Team__c> lcaseTeam = (List<Case_Team__c>) UtilityTest.makeInsert(new List<sObject>{CaseTeamrec});  
    }
    
    @isTest
    public static void getCaseReproEnvironmentsTest(){
        List<Case> lcase = [Select Id From Case];
        reproEnvironmentController.getCaseReproEnvironments(lcase[0].Id);
    }
    
    
    @isTest
    public static void attachReproEnvironmentToCaseTest(){
        List<Case> lcase = [Select Id,OwnerId From Case];
        List<Repro_Environment__c> lRepEnv = [Select Id From Repro_Environment__c];
        reproEnvironmentController.attachReproEnvironmentToCase(lcase[0].Id,lRepEnv[0].Id,lcase[0].OwnerId);
    }
    
    @isTest
    public static void attachReproEnvironmentToCaseExceptionTest(){
        List<Case> lcase = [Select Id,OwnerId From Case];
        List<Repro_Environment__c> lRepEnv = [Select Id From Repro_Environment__c];
        try{
            reproEnvironmentController.attachReproEnvironmentToCase(lcase[0].Id,'lRepEnv[0].Id',lcase[0].OwnerId);
        }Catch(Exception ex){
            System.debug('ex : ' + ex.getMessage());
        }
        
    }
    
    @isTest
    public static void detachReproEnvironmentFromCaseTest(){
        List<Case> lcase = [Select Id From Case];
        List<Case_Repro_Environment__c> lCaseRepEnv = [Select Id,Repro_Environment__c From Case_Repro_Environment__c];
        reproEnvironmentController.detachReproEnvironmentFromCase(lcase[0].Id,lCaseRepEnv[0].Id);
    }
    
    @isTest
    public static void getReproEnvironmentsTest(){
        List<Case> lcase = [Select Id From Case];
        reproEnvironmentController.getReproEnvironments(1,lcase[0].Id);
    }

    @isTest
    public static void searchReproEnvironmentsTest(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        Map<String, String> searchFilters = reproEnvironmentController.getSearchFilters();
        
        if(String.isNotEmpty(caseId)){
            String allFilters = '';
            for(String filter : new List<String>(searchFilters.keySet())){
                allFilters = String.isNotEmpty(allFilters) ? allFilters +','+ filter : filter;
            }
            reproEnvironmentController.searchReproEnvironments(caseId, '', '');
            reproEnvironmentController.searchReproEnvironments(caseId, 'Repro', '');
            reproEnvironmentController.searchReproEnvironments(caseId, 'Repro', allFilters);
            reproEnvironmentController.searchReproEnvironments(caseId, 'Repro', searchFilters.get(new List<String>(searchFilters.keySet())[0]));
        }
    }
}