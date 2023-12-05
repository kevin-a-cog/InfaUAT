/*
 * Name      :  CSMPlanCommsInternalCommentHelperTest
 * Author    :  Deva M
 * Created Date  :   31/01/2022
 * Description  :  CSMPlanCommsInternalCommentHelper test class.

 Change History
 **********************************************************************************************************
 Modified By      Date      Jira No.    Description          Tag
 **********************************************************************************************************
 DEva M             31/01/2022    N/A        Initial version.      N/A
 */
@istest
public with sharing class CSMPlanCommsInternalCommentHelperTest {
      /*
   Method Name : setup
   Description : Test setup method.
   Parameters   : None
   Return Type : None
   */
    @testSetup 
    public static void setup() {
    Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
      
      
          SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
      
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;
        
        
  
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';        
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Name', 'test');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('CloseDate', string.valueOf(system.today()));
        UtilityTestData.mOpportunityData.put('StageName', 'Lead');
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

  
        
        //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c',lOpportunity[0].Id);
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});   

   
        
        //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);        
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});

    //Now we create a Risk Product Alias.
    Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
    objRiskProductAlias.Opportunity__c = lOpportunity[0].Id;
    objRiskProductAlias.Risk__c = lRisk[0].Id;
    insert objRiskProductAlias;

    //Now we create a Plan Product Alias.
    Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
    objPlanProductAlias.Plan__c = lPlan[0].Id;
    objPlanProductAlias.Plan_Product__c = lPlanProd2[0].Id;
    insert objPlanProductAlias;
    lPlanProd2[0].Plan_Product_Alias__c = objPlanProductAlias.Id;
    update lPlanProd2[0];
    }

    
      /*
   Method Name : testcreatePafManagerComment
   Description : Testing createPafManagerComment
   Parameters   : None
   Return Type : None
   */
    @isTest
    public static void testcreatePafManagerComment() {
        Adoption_Factor__c obj=[SELECT Id, Plan__c, Project__c, Product__c, Engagement__c, CSM_Comments__c, Impact__c, Impact_Reason__c, CSM_Manager_Comments__c, Status__c, Plan_Health_Score__c FROM Adoption_Factor__c limit 1];
        obj.Impact__c='High';
        obj.Plan_Health_Score__c='3C';
        obj.Status__c='Final';
        obj.CSM_Manager_Comments__c='Comments';
        obj.CSM_Comments__c='Comments';
        obj.Impact_Reason__c='Financial Impact (Renewal)';
        update obj;
        system.debug('obj.Id-->'+obj.Id);
        system.debug('obj.Plan__c-->'+obj.Plan__c);
        CSMPlanCommsInternalCommentHelper.createPafManagerComment(obj.Id,obj.Plan__c);
    }

       /*
   Method Name : testcreateRiskCommentFromPAF
   Description : Testing createRiskCommentFromPAF
   Parameters   : None
   Return Type : None
   */
    @isTest
    public static void testcreateRiskCommentFromPAF() {
        Risk_Issue__c objRisk=[SELECT Id FROM Risk_Issue__c limit 1];
        Risk_Product_Alias__c objRiskProd=[SELECT Id FROM Risk_Product_Alias__c limit 1];
        CSMPlanCommsInternalCommentHelper.createRiskCommentFromPAF(objRisk.Id,objRiskProd.Id);
    }
    
    
    @isTest
    public static void createEngagementInternalComment() {
        Map<Id,Engagement__c> mapengage=new map<Id,Engagement__c>([SELECT Id FROM Engagement__c limit 1]);
        CSMPlanCommsInternalCommentHelper.createEngagementInternalComment(mapengage);
    }
     
    @isTest
    public static void createObjectiveInternalComment() {
        Map<Id,Objective__c> mapobjective=new map<Id,Objective__c>([SELECT Id FROM Objective__c limit 1]);
        CSMPlanCommsInternalCommentHelper.createObjectiveInternalComment(mapobjective);
    }
}