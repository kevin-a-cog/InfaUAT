@isTest
public with sharing class EngagementCatalogueControllerTest {
    static Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'][0];
    
    @isTest
    public static void testFetchingDataTableFieldLabelAndApi() {
        EngagementCatalogueController.getFieldLabelAndFieldAPI();
    }


    @isTest
    public static void testFetchPreviousEngagements(){
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c', lNewCustomerAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementData);
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        EngagementCatalogueController.getPreviousEngagements(lNewCustomerAccount[0].Id,'CST');
        //EngagementCatalogueController.getUserDetails();
        EC_AEMWrapper ec_AEMWrapper = new EC_AEMWrapper();
        ec_AEMWrapper.url = '/test/TestingCSAEngagementURL';
        EngagementCatalogueController.getECUrl(ec_AEMWrapper);
    }

    @isTest
    public static void testFetchECActions(){
        EC_Action__c ecAction = new EC_Action__c();
        ecAction.put('Action_Label__c', 'Test Action label');
        ecAction.put('Object__c', 'Engagement__c');
        ecAction.put('Record_Type__c', 'CST');
        ecAction.put('AEM_Action_Id__c', 'Test CSA');
        insert ecAction;

        EC_Questions__c ecQuestion = new EC_Questions__c();
        ecQuestion.put('Label__c', 'Test Label');
        ecQuestion.put('Data_Type__c', 'Text');
        ecQuestion.put('Field_API_Name__c', 'CSM_Summary__c');
        ecQuestion.put('Is_Required__c', true);
        ecQuestion.put('Sort_Order__c', 1);
        ecQuestion.put('Placeholder__c', 'text placeholder');
        ecQuestion.put('Tooltip__c', 'text tooltip');
        ecQuestion.put('Action_Engagement_Catalog__c', ecAction.Id);
        ecQuestion.put('AEM_Question_Id__c', 'CSM Summary');
        insert ecQuestion;

        EngagementCatalogueController.getECActions(ecAction.AEM_Action_Id__c);
    }

    @isTest
    public static void testEUPresent(){
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Date dt = System.today();

        Engagement_Unit__c engUnit = new Engagement_Unit__c();
        engUnit.put('Entitled_Units__c', 5);
        engUnit.put('Consumed_Units__c', 1);
        engUnit.put('Awarded_By__c', 'Engagement');
        engUnit.put('Expiry_Date__c', dt);
        engUnit.put('Start_Date__c', dt);
        engUnit.put('Type__c', 'Success');
        engUnit.put('Account__c', lNewCustomerAccount[0].Id);
        insert engUnit;

        EC_AEMWrapper ec_AEMWrapper = new EC_AEMWrapper();
        ec_AEMWrapper.engagementUnit = '1';

        EngagementCatalogueController.isEUPresent(lNewCustomerAccount[0].Id,'Success',ec_AEMWrapper);
    }

    @isTest
    public static void testCreateCSAEngagement(){
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
            
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
        // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});

        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Is_Internal__c','false');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        UtilityTestData.mPlanMilestone.put('Status__c','Yet to Start');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone});

        EC_ActionsWrapper ec_ActionsWrapper = new EC_ActionsWrapper();
        ec_ActionsWrapper.recordType = 'CST';
        ec_ActionsWrapper.ownerQueue = 'INFA_CST';

        EC_AEMWrapper ec_AEMWrapper = new EC_AEMWrapper();
        ec_AEMWrapper.engagementId = 'CSA-123';
        ec_AEMWrapper.infaJourneyId = 'CSA-123';
        ec_AEMWrapper.title = 'Testing CSA Engagement Title';
        ec_AEMWrapper.url = '/test/TestingCSAEngagementURL';
        ec_AEMWrapper.engagementTypeTag = new List<String>{'Best Practices'};
        ec_AEMWrapper.infaJourneyValue = new List<String>{'Customer 360'};
        ec_AEMWrapper.engagementUnit = '1';
        ec_AEMWrapper.isInternalEngagement = 'false';
        ec_AEMWrapper.engagementCategoryTag = new List<String>{'Best Practices'};
        ec_AEMWrapper.tags = new List<String>{'Best Practices'};
        ec_AEMWrapper.adoptionStageTag = new List<String>{'Best Practices'};
        ec_AEMWrapper.engagementProductTag = new List<String>{'Best Practices'};
        ec_AEMWrapper.engagementFocusAreaTag = new List<String>{'Best Practices'};
        ec_AEMWrapper.engagementUseCaseTag = new List<String>{'Best Practices'};

        List<EngagementCatalogueController.EC_AnswerWrapper> ec_AnswerWrapperList = new List<EngagementCatalogueController.EC_AnswerWrapper>();
        
        EngagementCatalogueController.EC_AnswerWrapper ec_AnswerWrapper2 = new EngagementCatalogueController.EC_AnswerWrapper();
        ec_AnswerWrapper2.Name = 'Customer_Name__c';
        ec_AnswerWrapper2.Answer = 'Test Customer Name';
        ec_AnswerWrapper2.Type = 'Text';
        ec_AnswerWrapperList.add(ec_AnswerWrapper2);

        EngagementCatalogueController.EC_AnswerWrapper ec_AnswerWrapper3 = new EngagementCatalogueController.EC_AnswerWrapper();
        ec_AnswerWrapper3.Name = 'Milestone__c';
        ec_AnswerWrapper3.Answer = lMilestone[0].Id;
        ec_AnswerWrapper3.Type = 'Text';
        ec_AnswerWrapperList.add(ec_AnswerWrapper3);

        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob;
        content.origin = 'H';
        insert content;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :content.Id];
        
        List<Id> fileIdList = new List<Id>();
        fileIdList.add(documents[0].Id);

        Date dt = System.today();

        Engagement_Unit__c engUnit = new Engagement_Unit__c();
        engUnit.put('Entitled_Units__c', 5);
        engUnit.put('Consumed_Units__c', 1);
        engUnit.put('Awarded_By__c', 'Engagement');
        engUnit.put('Expiry_Date__c', dt);
        engUnit.put('Start_Date__c', dt);
        engUnit.put('Type__c', 'Success');
        engUnit.put('Account__c', lNewCustomerAccount[0].Id);
        insert engUnit;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAEMFavouriteHttpResponseGenerator());
        EngagementCatalogueController.createCSAEngagement(lNewCustomerAccount[0].Id,lContact[0].Id,lPlan[0].Id,'','',ec_ActionsWrapper,ec_AEMWrapper,ec_AnswerWrapperList,fileIdList);
        Test.stopTest();
    }

    @isTest
    public static void testFetchMileStones(){
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
            
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Is_Success_Community_User__c','true');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
        // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});

        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Is_Internal__c','false');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        UtilityTestData.mPlanMilestone.put('Status__c','Yet to Start');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone});
        List<Milestone__c> objResponse = EngagementCatalogueController.getMilestones(lContact[0].Id,'');
        List<Milestone__c> objResponse1 = EngagementCatalogueController.getMilestones('',lPlan[0].Id);
    }

    @isTest
    public static void testHasActiveExternalPlan(){
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Status__c','Active');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
            
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
        EngagementCatalogueController.hasActiveExternalPlan(lContact[0].Id,'');
        EngagementCatalogueController.hasActiveExternalPlan('',lPlan[0].Id);
    }

    @isTest 
    public static void testAEMCallout() {
        Test.setMock(HttpCalloutMock.class, new MockAEMHttpResponseGenerator());
        EngagementCatalogueController.getAEMParameterDetails('engagements-catalog/data-profiling-for-parquet-and-avro');
    }

    /*@isTest
    public static void testUserDetails() {
        String orgId = UserInfo.getOrganizationId();  
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  

        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        User tempUser = new User(  FirstName = 'test',  
                                LastName = 'test',  
                                email = uniqueName + '@test' + orgId + '.org',  
                                Username = uniqueName + '@test' + orgId + '.org',  
                                EmailEncodingKey = 'ISO-8859-1',  
                                Alias = uniqueName.substring(18, 23),  
                                TimeZoneSidKey = 'America/Los_Angeles',  
                                LocaleSidKey = 'en_US',  
                                LanguageLocaleKey = 'en_US',  
                                ProfileId = partnerProfile.Id);  
        insert tempUser;
        EngagementCatalogueController.getUserDetails();
    }*/
}