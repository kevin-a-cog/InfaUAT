@isTest(seeAllData = false)
public with sharing class RiskAssessmentControllerTest {

    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create an Contact record
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Opportunity record
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name','Test Opty');
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        List<Engagement__c> lEngagement = UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Adoption_Factor__c lAdoptionFactor = new Adoption_Factor__c(Plan__c=lPlan[0].Id,Status__c='Waiting for CSM Input');
        lAdoptionFactor.Product__c = 'Good';
        lAdoptionFactor.Project__c = 'Good';
        lAdoptionFactor.Engagement__c = 'Good';
        lAdoptionFactor.Impact__c = 'Low';
        insert lAdoptionFactor;
        
        Risk_Assessment__c lRA1 = new Risk_Assessment__c();
        lRA1.Adoption_Factor__c = lAdoptionFactor.Id;
       	insert lRA1;
        
        Risk_Assessment__c lRA2 = new Risk_Assessment__c();
        lRA2.Engagement__c = lEngagement[0].Id;
       	insert lRA2;
    }

    @isTest
    static void testRiskAssessmentMethod() {
        List<Opportunity> opp = [SELECT ID FROM Opportunity LIMIT 1];
        List<Engagement__c> engage = [SELECT ID FROM Engagement__c LIMIT 1]; 
        List<Plan__c> plan = [SELECT ID FROM Plan__c LIMIT 1];
        List<Adoption_Factor__c> lAF = [SELECT ID FROM Adoption_Factor__c LIMIT 1];
        Risk_Assessment__c lRA = [SELECT ID FROM Risk_Assessment__c LIMIT 1];
        Risk_Assessment_Mapping__mdt mdtRecord = [SELECT ID FROM Risk_Assessment_Mapping__mdt LIMIT 1];
        Map<String,String> jsonInput= new Map<String,String>{'Id' => mdtRecord.Id,'Score' => 'HIGH','Text_Area_Comment__c'=>'test','Text_Area_Action__c'=>'action'};
        List<Map<String,String>> LstJsonInput = new List<Map<String,String>>();
        LstJsonInput.add(jsonInput);
        
     
        test.startTest();
        	RiskAssessmentController.generatePAFRecordData(engage[0].Id,plan[0].Id);
        	RiskAssessmentController.generatePAFRecordData(lAF[0].Id,plan[0].Id);
        	RiskAssessmentController.getParentRecValues(engage[0].Id,plan[0].Id);
        	RiskAssessmentController.getParentRecValues(lAF[0].Id,plan[0].Id);
        	RiskAssessmentController.saveRecords(LstJsonInput,engage[0].Id,true,plan[0].Id);
        	RiskAssessmentController.saveRecords(LstJsonInput,engage[0].Id,false,plan[0].Id);
        	RiskAssessmentController.saveRecords(LstJsonInput,lAF[0].Id,true,plan[0].Id);
        	RiskAssessmentController.saveRecords(LstJsonInput,lAF[0].Id,false,plan[0].Id);
        test.stopTest();
    }
}