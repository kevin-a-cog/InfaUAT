@isTest
public with sharing class OpportunitySubStageProgressionTest {
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    @testSetup
    static void setupObjectTestData() {    
        
        //Insert Account setup data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Inserting an Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + '');    
        UtilityTestData.mOpportunityData.put('Champion__c', 'TEST CHAMPION');   
        UtilityTestData.mOpportunityData.put('Economic_Buyer__c', 'TEST ECO BUYER');   
        UtilityTestData.mOpportunityData.put('BANT_Qualification__c', 'TEST IDENTIFY PAIN');            
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityPrimary1 = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lOpportunityPrimary1.size(), 1);
    }
    @isTest
    static void testmethod1() {

        Test.StartTest();
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, SubStage__c from Opportunity where Primary_or_Secondary__c =\'Primary\' Limit 1');
        system.assertEquals(lOpportunityPrimary.size(),1);
        update new Opportunity(Id = lOpportunityPrimary[0].Id, SubStage__c = 'Evaluation');
        lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, SubStage__c from Opportunity where Id =\''+lOpportunityPrimary[0].Id+'\' Limit 1');
        OpportunitySubStageProgressionController.fetchSubStageMapping(lOpportunityPrimary[0].Id, lOpportunityPrimary[0].SubStage__c);
        OpportunitySubStageProgressionController.fetchSubStageMapping(lOpportunityPrimary[0].Id , '');
        String substagename = OpportunitySubStageProgressionController.fetchSubStageName(lOpportunityPrimary[0].Id);
        System.assertEquals(substagename, 'Evaluation');
        Boolean methodResult = OpportunitySubStageProgressionController.isSubStageChanged(lOpportunityPrimary[0].Id, lOpportunityPrimary[0].SubStage__c);
        System.assertEquals(methodResult, false);
        OpportunitySubStageProgressionController.getSubStagePicklistVals();
        Test.Stoptest();
    }
}