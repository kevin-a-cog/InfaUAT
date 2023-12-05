/*
 * Name         :   CSMCreateEngagementCommentsQueueableTest
 * Author       :   Deva M
 * Created Date :   24/01/2022
 * Description  :   Test Class for CSMCreateEngagementCommentsQueueable

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Deva M                 30/11/2021      AR-1734             Initial version.            N/A
 */
@istest
public with sharing class CSMCreateObjectiveCommentsQueueableTest {
    @testSetup
    static void setupObjectTestData() {
        
        Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
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
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('Is_Internal__c','true');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);               
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});

        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Role__c','Business Owner');//
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Business_Outcome_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('Onboarding_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);

        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
        //Now we create Related Plan Product records.
        Related_Account_Plan__c objPlanProduct = new Related_Account_Plan__c();
        objPlanProduct.Account_Plan__c = Plan.Id;
        objPlanProduct.Account__c = Account.Id;
        //Now we create Related Plan Product records.
        Related_Account_Plan__c objPlanProduct2 = new Related_Account_Plan__c();
        objPlanProduct2.Account_Plan__c = Plan.Id;
        objPlanProduct2.Account__c = Account.Id;
        insert new List<Related_Account_Plan__c>{objPlanProduct,objPlanProduct2};
            
            sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});
        
        Objective_Product__c op = new Objective_Product__c();
        op.Objective__c = objective.Id;
        op.Plan_Product__c = objPlanProduct.Id; 
        
        Objective_Product__c op2 = new Objective_Product__c();
        op2.Objective__c = objective.Id;
        op2.Plan_Product__c = objPlanProduct2.Id; 
        insert new List<Objective_Product__c>{op,op2};
            
            sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Status__c','In Progress');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Key_Milestone__c','false');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        
        
        sObject mstone1 = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Status__c','Complete');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Key_Milestone__c','true');
        mstone1 = UtilityTest.putFieldRecord(mstone1, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone,mstone1}); 
        
        Map<String,String> mEngagement = new Map<String,String>{'Name'=>'Test Engagement','CSM_Summary__c' => 'Testing','Customer_Time_Zone__c' => 'GMT–07:00 Pacific Daylight Time (America/Los_Angeles)','CST_Requested_for__c' => 'Rescue','Engagement_Journey__c' => 'Data Governance and Privacy' };
        sObject Engagement = new Engagement__c();
        mEngagement.put('Name','Test');
        mEngagement.put('CSM_Summary__c','Test Plan One');
        mEngagement.put('Plan__c',lPlan[0].Id);
        mEngagement.put('Customer_Time_Zone__c','GMT–07:00 Pacific Daylight Time (America/Los_Angeles)');
        mEngagement.put('CST_Requested_for__c','Rescue');
        mEngagement.put('Engagement_Journey__c','Data Governance and Privacy');
        mEngagement.put('RecordTypeId',CSTEngagementRT);

        Engagement = UtilityTest.putFieldRecord(Engagement, mEngagement);
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{Engagement}); 


    }

    @isTest
    public static void testObjSignoff() {
        Map<Id,Engagement__c> mapEnagement = new Map<Id,Engagement__c>();
        List<Engagement__c> engmnt = [Select Id,RecordTypeId,Plan__c,Name from Engagement__c LIMIT 1];
        mapEnagement.put(engmnt[0].id, engmnt[0]);
            
        List<Objective__c> lObjective = [Select Id from Objective__c limit 1];
        List<Objective__c> lstUpdatedObjectives =new List<Objective__c>();
        List<Plan__c> lPlan = [Select Id from Plan__c LIMIT 1];
        List<Plan_Contact__c> lPlanContact = [Select Id,Contact__c from Plan_Contact__c LIMIT 1];
        for(Objective__c objRec:lObjective){
            lstUpdatedObjectives.add(new Objective__c(Id=objRec.Id, Signed_Off_By__c='Customer',Customer_Sign_off_Contact__c = lPlanContact[0].Contact__c,Sign_Off_Date__c=System.today()));
        }
        
        update lstUpdatedObjectives;
        //Map<Id,Engagement__c> engMap
        CSMCreateEngagementCommentsQueueable cecq = new CSMCreateEngagementCommentsQueueable(mapEnagement);
         Test.startTest();
            System.enqueueJob(cecq);
          Test.stopTest();
       
    }
}