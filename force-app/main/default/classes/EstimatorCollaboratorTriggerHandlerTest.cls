@isTest
public with sharing class EstimatorCollaboratorTriggerHandlerTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive=true AND UserRoleId != null Limit 1];
        System.runAs(adminUser){
            sObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account 1');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            
            sObject sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account 2');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','Test');
            UtilityTestData.mContactData.put('LastName','Contact');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            sObj1 = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','Test');
            UtilityTestData.mContactData.put('LastName','Contact 1');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            
            sObject sObj2 = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[1].Id);
            UtilityTestData.mContactData.put('FirstName','Test');
            UtilityTestData.mContactData.put('LastName','Contact 2');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);
            
            sObject sObj3 = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[1].Id);
            UtilityTestData.mContactData.put('FirstName','Test');
            UtilityTestData.mContactData.put('LastName','Contact 3');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mContactData);
            
            
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Estimation_Summary__c estimationSummary = IPUE_TestUtils.createEstimationSummary(true, lOpportunity[0].Id);
            estimationSummary.Account__c = lAccount[0].Id;
            update estimationSummary;
            
            Test.startTest();
            
            estimationSummary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];
            
            Estimation_Output__c outputRec = new Estimation_Output__c(Name = 'Test Output Rec',Estimation_Summary__c = estimationSummary.Id,User_Value__c = '10');
            insert outputRec;
            
            List<Estimator_Collaborator__c> lstEstimatorCollaborator = IPUE_TestUtils.createEstimatorCollaborator(true,lContact,estimationSummary);
            
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];
            
            sObj = new User();
            UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest1a@m.t');
            UtilityTestData.mUserData.put('Email','mtest1a@m.t');
            UtilityTestData.mUserData.put('Alias','alias1');
            UtilityTestData.mUserData.put('CommunityNickname','mtest1');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',lContact[0].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');
            UtilityTestData.mUserData.put('LastName','User 1');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
            
            sObj1 = new User();
            UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest2a@m.t');
            UtilityTestData.mUserData.put('Email','mtest2a@m.t');
            UtilityTestData.mUserData.put('Alias','alias2');
            UtilityTestData.mUserData.put('CommunityNickname','mtest2');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',lContact[1].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');
            UtilityTestData.mUserData.put('LastName','User 2');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData);
            
            sObj2 = new User();
            UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest3a@m.t');
            UtilityTestData.mUserData.put('Email','mtest3a@m.t');
            UtilityTestData.mUserData.put('Alias','alias3');
            UtilityTestData.mUserData.put('CommunityNickname','mtest3');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',lContact[2].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');
            UtilityTestData.mUserData.put('LastName','User 3');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mUserData);
            
            sObj3 = new User();
            UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest4a@m.t');
            UtilityTestData.mUserData.put('Email','mtest4a@m.t');
            UtilityTestData.mUserData.put('Alias','alias4');
            UtilityTestData.mUserData.put('CommunityNickname','mtest4');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',lContact[3].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');
            UtilityTestData.mUserData.put('LastName','User 4');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mUserData);
            
            List<User> communityUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testAfterUpdate(){
        Map<Id,Estimator_Collaborator__c> mapEstimatorCollaborator = new Map<Id,Estimator_Collaborator__c>([SELECT Id,Contact__c FROM Estimator_Collaborator__c]);
        
        //Adding contact check to users to filter only the users created in testSetup
        Set<Id> setContactId = new Set<Id>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            setContactId.add(collab.Contact__c);
        }        
        List<User> lstUser = [SELECT Id,ContactId FROM User WHERE ContactId IN :setContactId];
        
        Map<Id,Id> mapContactUserId = new Map<Id,Id>();
        
        for(User userRec:lstUser){
            mapContactUserId.put(userRec.ContactId,userRec.Id);
        }
        
        List<Estimator_Collaborator__c> lstEstimatorCollaborator = new List<Estimator_Collaborator__c>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            collab.Dev_Community_User__c = mapContactUserId.get(collab.Contact__c);
            lstEstimatorCollaborator.add(collab);
        }
        Test.startTest();
        //Activating the user
        update lstEstimatorCollaborator;
        
        List<Estimation_Summary__Share> lstSummaryShare = [SELECT Id FROM Estimation_Summary__Share];
        System.AssertEquals(lstEstimatorCollaborator.size(),lstSummaryShare.size(),'Error Sharing summary records with the users');
        
        //InActivating the user
        globalApexManager.allowRun('EstimatorCollaboratorAfterUpdate');
        lstEstimatorCollaborator = new List<Estimator_Collaborator__c>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            collab.Active__c = false;
            lstEstimatorCollaborator.add(collab);
        }
        update lstEstimatorCollaborator;
        
        lstSummaryShare = [SELECT Id FROM Estimation_Summary__Share];
        System.AssertEquals(0,lstSummaryShare.size(),'Error revoking summary record access from the users');
        
        //To cover the code coverage for EstimatorCollaboratorAfterUpdate Trigger - updating again so the trigger returns without any operation due to recursion
        update lstEstimatorCollaborator;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testAfterInsert1(){
        Test.startTest();
        Map<Id,Estimator_Collaborator__c> mapEstimatorCollaborator = new Map<Id,Estimator_Collaborator__c>([SELECT Id,Contact__c,Estimation_Summary__c FROM Estimator_Collaborator__c]);
        
        //Adding contact check to users to filter only the users created in testSetup
        Set<Id> setContactId = new Set<Id>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            setContactId.add(collab.Contact__c);
        }        
        List<User> lstUser = [SELECT Id,ContactId FROM User WHERE ContactId IN :setContactId];
        
        Map<Id,Id> mapContactUserId = new Map<Id,Id>();
        
        for(User userRec:lstUser){
            mapContactUserId.put(userRec.ContactId,userRec.Id);
        }
        
        List<Estimator_Collaborator__c> lstEstimatorCollaborator = new List<Estimator_Collaborator__c>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            Estimator_Collaborator__c newCollab = new Estimator_Collaborator__c();
            newCollab.Contact__c = collab.Contact__c;
            newCollab.Estimation_Summary__c = collab.Estimation_Summary__c;
            newcollab.Dev_Community_User__c = mapContactUserId.get(collab.Contact__c);
            lstEstimatorCollaborator.add(newcollab);
        }
        
        //Inseting with user reference
        insert lstEstimatorCollaborator;
        
        List<Estimation_Summary__Share> lstSummaryShare = [SELECT Id FROM Estimation_Summary__Share];
        System.AssertEquals(lstEstimatorCollaborator.size(),lstSummaryShare.size(),'Error Sharing summary records with the users');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testAfterInsert2(){
        Test.startTest();
        Map<Id,Estimator_Collaborator__c> mapEstimatorCollaborator = new Map<Id,Estimator_Collaborator__c>([SELECT Id,Contact__c,Estimation_Summary__c FROM Estimator_Collaborator__c]);
        
        //Adding contact check to users to filter only the users created in testSetup
        Set<Id> setContactId = new Set<Id>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            setContactId.add(collab.Contact__c);
        }        
        List<User> lstUser = [SELECT Id,ContactId FROM User WHERE ContactId IN :setContactId];
        
        Map<Id,Id> mapContactUserId = new Map<Id,Id>();
        
        for(User userRec:lstUser){
            mapContactUserId.put(userRec.ContactId,userRec.Id);
        }
        
        List<Estimator_Collaborator__c> lstEstimatorCollaborator = new List<Estimator_Collaborator__c>();
        for(Estimator_Collaborator__c collab:mapEstimatorCollaborator.values()){
            Estimator_Collaborator__c newCollab = new Estimator_Collaborator__c();
            newCollab.Contact__c = collab.Contact__c;
            newCollab.Estimation_Summary__c = collab.Estimation_Summary__c;
            newcollab.Dev_Community_User__c = mapContactUserId.get(collab.Contact__c);
            lstEstimatorCollaborator.add(newcollab);
        }
        
        //To cover the code coverage for EstimatorCollaboratorAfterInsert Trigger - inserting again so the trigger returns without any operation due to trigger Muting
        Global_Config__c settings = Global_Config__c.getOrgDefaults();
        settings.Mute_Triggers__c = true;
        upsert settings Global_Config__c.Id;        
        
        //Inseting with user reference
        insert lstEstimatorCollaborator;
        
        List<Estimation_Summary__Share> lstSummaryShare = [SELECT Id FROM Estimation_Summary__Share];
        System.AssertEquals(0,lstSummaryShare.size(),'Error Sharing summary records with the users');
        
        Test.stopTest();
    } 
}