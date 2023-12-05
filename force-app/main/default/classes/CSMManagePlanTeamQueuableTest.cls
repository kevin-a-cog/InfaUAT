@isTest
private class CSMManagePlanTeamQueuableTest {
    @istest 
    static void managerupdatetest() {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = 'Employee'];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        objTestUser.ManagerId = UserInfo.getUserId();
        
        insert objTestUser;

        User manager = new User();

        //Now we set the user data.
        manager.FirstName = 'manager' + DateTime.now().getTime();
        manager.LastName = 'manager' + DateTime.now().getTime();
        manager.Email = strUniqueName + 'manager' + strOrgId + '@test.com';
        manager.Username = manager.Email;
        manager.EmailEncodingKey = 'ISO-8859-1';
        manager.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        manager.TimeZoneSidKey = 'America/Los_Angeles';
        manager.LocaleSidKey = 'en_US';
        manager.LanguageLocaleKey = manager.LocaleSidKey;
        manager.ProfileId = objProfile.Id;
        manager.ManagerId = UserInfo.getUserId();
        
        insert manager;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Ownerid',objTestUser.id);
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  

        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan2');
        UtilityTestData.mPlan.put('Ownerid',objTestUser.id);
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan2 = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan2});  

        sObject Plan3 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan3');
        UtilityTestData.mPlan.put('Ownerid',objTestUser.id);
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan3, UtilityTestData.mPlan);
        List<Plan__c> lPlan3 = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan3});  

        
        insert new Plan_Team__c(User__c=objTestUser.Id, Plan__c=lPlan[0].Id,Role__c='CSM',Primary__c=true);
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=lPlan[0].Id,Role__c='CSM Manager',Primary__c=true);
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=lPlan2[0].Id,Role__c='CSM Manager',Primary__c=true);
        insert new Plan_Team__c(User__c=objTestUser.Id, Plan__c=lPlan2[0].Id,Role__c='CSM',Primary__c=true);
        insert new Plan_Team__c(User__c=manager.Id, Plan__c=lPlan2[0].Id,Role__c='Account Manager',Primary__c=true);
        insert new Plan_Team__c(User__c=objTestUser.Id, Plan__c=lPlan2[0].Id,Role__c='CSM',Primary__c=true);
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=lPlan2[0].Id,Role__c='CSM Manager',Primary__c=true);
        insert new Plan_Team__c(User__c=manager.Id, Plan__c=lPlan2[0].Id,Role__c='CSM Manager',Primary__c=false);
    
        objTestUser.ManagerId = manager.id;
        update objTestUser;
        Test.startTest();    
        System.enqueueJob(new CSMManagePlanTeamQueuable(new List<Id>{objTestUser.Id}));
        Test.stopTest();
    }
}