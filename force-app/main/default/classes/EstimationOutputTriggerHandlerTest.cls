@isTest
public with sharing class EstimationOutputTriggerHandlerTest {
    @testSetup
    static void setupObjectTestData() {

        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account 1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);


        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
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

        List<User> communityUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

        Test.stopTest();
    }

    @isTest
    public static void testAfterInsert(){
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

        Estimation_Output__c outputRec = new Estimation_Output__c(Name = 'Test Output Rec',Estimation_Summary__c = lstEstimatorCollaborator[0].Estimation_Summary__c,User_Value__c = '10');
        insert outputRec;
        
        //To cover the code coverage for EstimationOutputAfterInsert Trigger - inserting again so the trigger returns without any operation due to trigger Muting
        Global_Config__c settings = Global_Config__c.getOrgDefaults();
        settings.Mute_Triggers__c = true;
        upsert settings Global_Config__c.Id;

        outputRec = new Estimation_Output__c(Name = 'Test Output Rec 2',Estimation_Summary__c = lstEstimatorCollaborator[0].Estimation_Summary__c,User_Value__c = '10');
        insert outputRec;   

        Test.stopTest();
    }
}