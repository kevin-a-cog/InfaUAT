@istest
public with sharing class CSMCreateOpportunityCommentsQTest {
    @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
        
        Id planRecordTypeId1 = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Outcome Based Success Plan').getRecordTypeId();
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Status__c','Active');
        
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',planRecordTypeId1);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        //Plan2
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan2');
        UtilityTestData.mPlan.put('Status__c','Active');
        
        Id planRecordTypeId = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Outcome Based Success Plan').getRecordTypeId();
        system.debug('planRecordTypeId'+planRecordTypeId);
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',planRecordTypeId);
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 
        String renewalOpptyRecType  =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId(); 
        sObject sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('RecordTypeId',renewalOpptyRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        
        sObject sObj1 = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContractData);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObject planProduct = new Related_Account_Plan__c();
        //UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Status__c','Active');
        
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mRelatedAccountProduct.put('FTR__c','true');
        planProduct = UtilityTest.putFieldRecord(planProduct, UtilityTestData.mRelatedAccountProduct);
        
        sObject planProduct2 = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Status__c','Active');
        UtilityTestData.mRelatedAccountProduct.put('Unassigned_Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mRelatedAccountProduct.put('FTR__c','true');
        planProduct2 = UtilityTest.putFieldRecord(planProduct2, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{planProduct,planProduct2});
        Id InterlockRecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();

        Related_Opportunity_Plan__c interlockRec = new Related_Opportunity_Plan__c();
        interlockRec.Original_Opportunity__c = lOpportunity[0].Id;
        interlockRec.Opportunity__c = lOpportunity[0].Id;
        interlockRec.Account__c = lAccount[0].Id;
        interlockRec.Plan__c = lPlan[0].Id;
        interlockRec.Contract__c=lContract[0].Id;
        interlockRec.RecordTypeId = InterlockRecordTypeId;
        insert interlockRec;

        sObj = new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd[0].Id);
        UtilityTestData.mSubscriptionLine.put('Start_Date__c',System.today()+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSubscriptionLine);
        
        sObj1 = new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd[1].Id);
              UtilityTestData.mSubscriptionLine.put('Start_Date__c',(System.today())+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSubscriptionLine);
        
        sObject    sObj2= new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd[1].Id);
              UtilityTestData.mSubscriptionLine.put('Start_Date__c',(System.today()+10)+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSubscriptionLine);
        List<Subscription_Line__c > SubscriptionLinelst  =  (List<Subscription_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
              
    }


    public static testMethod void testOptyQueue (){
        Set<Id> opty = new set<Id>();
        for(Opportunity opp:[Select Id from Opportunity]){
            opty.add(opp.Id);
        }
        CSMCreateOpportunityCommentsQueueable apc = new CSMCreateOpportunityCommentsQueueable(opty);
        Test.startTest();
          System.enqueueJob(apc);
        Test.stopTest();

    }

}