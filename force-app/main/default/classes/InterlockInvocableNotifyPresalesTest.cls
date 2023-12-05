/*
Class:  InterlockInvocableNotifyPresalesTest
        @Author:        Ambica Pyati
        @Created Date:  7/12/2019
        @Description:   Test Class for InterlockInvocableNotifyPresales Class.
Change History
*************************************************************************************************************************************
ambica                  11/17/20                       Removed ortoo referenes                        <T01>
*************************************************************************************************************************************
*/
@isTest
public class InterlockInvocableNotifyPresalesTest {

    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new Account();
        sObject sObj1 = new Account();
    
    
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
    UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
      
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
    
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 limit 1');


        List<User> lUser = (List<User>) UtilityTest.executeQuery('SELECT id FROM User where IsActive = true  limit 1'); 
    
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    String INT_PRESALES_RT = Label.InterlockRecTypePresales;
        
        sObj = new Opportunity();         
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
    
    
    sObj = new OpportunityTeamMember();
    UtilityTestData.mOpportunityTeamMemberData.put('TeamMemberRole','Sales Consultant');
    UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
    UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId',lOpportunity[0].id);
    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeam = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
    /*<T01>
        sObj = new ortoo_e2a__Business_Unit__c();
        UtilityTestData.mE2aBusinessUnit.put('Name','SMG Handoff');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mE2aBusinessUnit);
        List<ortoo_e2a__Business_Unit__c> lBusinessUnit = (List<ortoo_e2a__Business_Unit__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
      </T01> */   
      
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Technical_Use_Case__c','test Technical case on Plan');
        UtilityTestData.mPlan.put('Business_Case__c ','test Business case on Plan');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
    UtilityTestData.mRelatedopportunityPlan.put('RecordTypeId', Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get(INT_PRESALES_RT).getRecordTypeId());
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
      
        
    }
  
  
  
  static testMethod void testPreSalesNotification(){
    
    test.StartTest();
            
                for(Related_Opportunity_Plan__c OpptyPlan : [select id,name,Count_Of_SMG_Notification__c
                                                                from Related_Opportunity_Plan__c ]){            
                   // system.assertEquals(OpptyPlan.Count_Of_SMG_Notification__c, 1);
                }   
        test.stoptest();
    }
    
  
}