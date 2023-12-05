/*
Class:          PlanProductTriggerHandlerTest 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Test class for PlanProductTriggerHandler,PlanContractTriggerHandler
*/
@isTest
public class PlanProductTriggerHandlerTest {
    
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
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Status__c','Active');
        
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        //Plan2
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan2');
        UtilityTestData.mPlan.put('Status__c','Active');
        
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        
        sObject Plan3 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan3');
        UtilityTestData.mPlan.put('Status__c','Active');
        
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan3 = UtilityTest.putFieldRecord(Plan3, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2,Plan3}); 
        
        
        Id OpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();

        sObject sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('RecordtypeId',OpptyRecordTypeId+'');
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
       // UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        //UtilityTestData.mRelatedAccountProduct.put('Status__c','Active');
        UtilityTestData.mRelatedAccountProduct.put('Start_Date__c',System.today()+'');
        UtilityTestData.mRelatedAccountProduct.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mRelatedAccountProduct.put('FTR__c','true');
        planProduct = UtilityTest.putFieldRecord(planProduct, UtilityTestData.mRelatedAccountProduct);
        
        sObject planProduct1 = new Related_Account_Plan__c();
       	UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Start_Date__c',System.today()+'');
        UtilityTestData.mRelatedAccountProduct.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Subscription Support');
        UtilityTestData.mRelatedAccountProduct.put('FTR__c','true');
        planProduct1 = UtilityTest.putFieldRecord(planProduct1, UtilityTestData.mRelatedAccountProduct);
        
        sObject planProduct2 = new Related_Account_Plan__c();
       	UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Start_Date__c',System.today()+'');
        UtilityTestData.mRelatedAccountProduct.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mRelatedAccountProduct.put('ROR__c','true');
        planProduct2 = UtilityTest.putFieldRecord(planProduct2, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{planProduct,planProduct1,planProduct2});
            
        sObject planProduct3 = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        //UtilityTestData.mRelatedAccountProduct.put('Status__c','Active');
        UtilityTestData.mRelatedAccountProduct.put('Contract__c',lContract[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Start_Date__c',System.today()+'');
        UtilityTestData.mRelatedAccountProduct.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mRelatedAccountProduct.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mRelatedAccountProduct.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mRelatedAccountProduct.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mRelatedAccountProduct.put('FTR__c','true');
        planProduct3 = UtilityTest.putFieldRecord(planProduct3, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{planProduct3});
        
        System.debug('lPlanProd2 '+ lPlanProd2);
        
        sObj = new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd[0].Id);
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        UtilityTestData.mSubscriptionLine.put('Start_Date__c',System.today()+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSubscriptionLine);
        
        sObj1 = new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd2[0].Id);
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        UtilityTestData.mSubscriptionLine.put('Start_Date__c',System.today()+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSubscriptionLine);
        List<Subscription_Line__c > SubscriptionLinelst  =  (List<Subscription_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
          Sobject  sObjlines = new Subscription_Line__c();
        UtilityTestData.mSubscriptionLine.put('Plan_Product__c',lPlanProd2[0].Id);
        UtilityTestData.mSubscriptionLine.put('Contract__c',lContract[0].Id);
        UtilityTestData.mSubscriptionLine.put('Start_Date__c',System.today()+'');
        UtilityTestData.mSubscriptionLine.put('End_Date__c',(System.today()+100)+'');
        UtilityTestData.mSubscriptionLine.put('ARR__c',10000+'');
        sObjlines = UtilityTest.putFieldRecord(sObjlines,UtilityTestData.mSubscriptionLine);
        globalApexManager.avoidRecursion('SubscriptionLineAfterInsert');
        List<Subscription_Line__c > SubscriptionLinelstreturn  =  (List<Subscription_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObjlines});
        
        
        Id InterlockRecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();

        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
       // UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('RecordTypeId',InterlockRecordTypeId+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lInterlock = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Engagement_Product__c();
        UtilityTestData.mRelatedOpportunityProduct.put('Related_Opportunity_Plan__c',lInterlock[0].Id);
        UtilityTestData.mRelatedOpportunityProduct.put('Plan_Product__c',lPlanProd[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedOpportunityProduct);
        
        sObj1 = new Engagement_Product__c();
        UtilityTestData.mRelatedOpportunityProduct.put('Related_Opportunity_Plan__c',lInterlock[0].Id);
        UtilityTestData.mRelatedOpportunityProduct.put('Plan_Product__c',lPlanProd2[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRelatedOpportunityProduct);
        List<Engagement_Product__c> lInterlockProd = (List<Engagement_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});   
        
       Id riskRecordTypeId = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('Type__c','Adoption');
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRecordTypeId+'');
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
       
        sObject riskproduct = new Related_Risk_Product__c();
        UtilityTestData.mRelatedRiskProduct.put('Plan_Product__c',lPlanProd[0].Id);
        UtilityTestData.mRelatedRiskProduct.put('Risk_Issue__c',lRisk[0].Id);
        riskproduct = UtilityTest.putFieldRecord(riskproduct, UtilityTestData.mRelatedRiskProduct);
        
        sObject riskproduct2 = new Related_Risk_Product__c();
        UtilityTestData.mRelatedRiskProduct.put('Plan_Product__c',lPlanProd2[0].Id);
        UtilityTestData.mRelatedRiskProduct.put('Risk_Issue__c',lRisk[0].Id);
        riskproduct2 = UtilityTest.putFieldRecord(riskproduct2, UtilityTestData.mRelatedRiskProduct);
        List<Risk_Issue__c> lRiskProduct = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{riskproduct,riskproduct2});
        
    }
    static testMethod void testPlanProductforNotAllowedOfferingTypes() {
        globalApexManager.avoidRecursion('handlerAfterUpdate');
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        

        List<Related_Account_Plan__c> lPlanProds = [select id, Status__c, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id,Status__c, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        for(Related_Account_Plan__c rap : lUnasignedPlanProd){
            rap.ROR__c = true;
            rap.End_Date__c = System.today() +10;
            rap.Start_Date__c = System.today();
            rap.Account_Plan__c = lPlan[2].Id;
        }
        
        update lUnasignedPlanProd;
    }
    
    static testMethod void testPlanProductAfterUpdateFTR_ROR() {
        globalApexManager.avoidRecursion('handlerAfterUpdate');
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        

        List<Related_Account_Plan__c> lPlanProds = [select id, Status__c, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id,Status__c, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        for(Related_Account_Plan__c rap : lPlanProds){
            rap.ROR__c = true;
            rap.End_Date__c = System.today() +10;
            rap.Start_Date__c = System.today();
        }
        lPlanProds[1].FTR__c = true;
        lPlanProds[1].ROR__c = false;
        update lPlanProds;
    }

    
    static testMethod void testPlanProductAfterUpdateFTR() {
        globalApexManager.avoidRecursion('handlerAfterUpdate');
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        

        List<Related_Account_Plan__c> lPlanProds = [select id, Status__c, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id,Status__c, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        for(Related_Account_Plan__c rap : lPlanProds){
            rap.ROR__c = true;
            rap.End_Date__c = System.today() +10;
            rap.Start_Date__c = System.today();
        }
        update lPlanProds;
    }
    
    static testMethod void testPlanProductAfterUpdateROR() {
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        

        List<Related_Account_Plan__c> lPlanProds = [select id, Status__c, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id,Status__c, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        for(Related_Account_Plan__c rap : lUnasignedPlanProd){
            rap.End_Date__c = System.today()+5;
            rap.Start_Date__c = System.today();
            rap.Account_Plan__c = lPlan[1].Id;
        }
        update lUnasignedPlanProd;
        

    }
    
    static testMethod void testPlanProductsReturnBeforeInsert() {
        globalApexManager.avoidRecursion('PlanContractBeforeInsert');
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        

        List<Related_Account_Plan__c> lPlanProds = [select id, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        Test.startTest();
        Related_Account_Plan__c assignPP1 = new Related_Account_Plan__c(id=lUnasignedPlanProd[0].id);
        assignPP1.Account_Plan__c= lPlanProds[0].Account_Plan__c;
        assignPP1.Contract__c= lPlanProds[0].Contract__c;
        update assignPP1;
        
        Related_Account_Plan__c FTRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        FTRPP.FTR__c= false;
        FTRPP.ROR__c= true;
        update FTRPP;
        
        Related_Account_Plan__c ARRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        ARRPP.ARR__c= 500;
        ARRPP.Previous_ARR__c= 1000;
        update ARRPP;
        
        Related_Account_Plan__c UpdatePP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        UpdatePP.Account_Plan__c= lPlan[1].id;
        UpdatePP.Contract__c= lContract[1].id;
        update UpdatePP;
        Test.stopTest();        
        
        List<Related_Account_Plan__c> lAssignedPlanProds = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[1].id];
        if(lAssignedPlanProds.size()>0)
        {
        system.assert(lAssignedPlanProds.size()>0, 'PlanProduct doesnt exist');
        
        Related_Account_Plan__c UnassignPP = new Related_Account_Plan__c(id=lAssignedPlanProds[0].id);
        UnassignPP.Account_Plan__c= Null;
        update UnassignPP; 
        }

        List<Plan_Contract__c> lPlanCon = [Select Id from Plan_Contract__c limit 10];
        system.assert(lPlanCon.size()>0, 'Plan Contract doesnt exist');
        
        Plan_Contract__c plancon = new Plan_Contract__c(id=lPlanCon[0].id);
        plancon.Plan__c =lPlan[0].id;
        plancon.Contract__c= lContract[1].id;
        update plancon;
        
        
    }
    
    static testMethod void testPlanProducts() {
        
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        
        List<Related_Account_Plan__c> lPlanProds = [select id, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        Test.startTest();
        Related_Account_Plan__c assignPP1 = new Related_Account_Plan__c(id=lUnasignedPlanProd[0].id);
        assignPP1.Account_Plan__c= lPlanProds[0].Account_Plan__c;
        assignPP1.Contract__c= lPlanProds[0].Contract__c;
        update assignPP1;
        
        
        Related_Account_Plan__c FTRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        FTRPP.FTR__c= false;
        FTRPP.ROR__c= true;
        update FTRPP;
        
        Related_Account_Plan__c ARRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        ARRPP.ARR__c= 500;
        ARRPP.Previous_ARR__c= 1000;
        update ARRPP;
        
        
        Related_Account_Plan__c UpdatePP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        UpdatePP.Account_Plan__c= lPlan[1].id;
        UpdatePP.Contract__c= lContract[1].id;
        update UpdatePP;
        Test.stopTest();
        
        
        List<Related_Account_Plan__c> lAssignedPlanProds = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[1].id];
        if(lAssignedPlanProds.size()>0){
        system.assert(lAssignedPlanProds.size()>0, 'PlanProduct doesnt exist');
        
        Related_Account_Plan__c UnassignPP = new Related_Account_Plan__c(id=lAssignedPlanProds[0].id);
        UnassignPP.Account_Plan__c= Null;
        update UnassignPP; 
        }
        List<Plan_Contract__c> lPlanCon = [Select Id from Plan_Contract__c];
        system.assert(lPlanCon.size()>0, 'Plan Contract doesnt exist');
        system.debug('Test Size lPlanCon'+lPlanCon.size());
        
        Plan_Contract__c plancon = new Plan_Contract__c(id=lPlanCon[0].id);
        plancon.Plan__c =lPlan[0].id;
        plancon.Contract__c= lContract[1].id;
        update plancon;
        
        
    }
    
    static testMethod void testPlanProductsReturnBeforeUpdate() {
        
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        
        
        List<Related_Account_Plan__c> lPlanProds = [select id, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        
        Test.startTest();
        Related_Account_Plan__c assignPP1 = new Related_Account_Plan__c(id=lUnasignedPlanProd[0].id);
        assignPP1.Account_Plan__c= lPlanProds[0].Account_Plan__c;
        assignPP1.Contract__c= lPlanProds[0].Contract__c;
        update assignPP1;
        
        Related_Account_Plan__c FTRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        FTRPP.FTR__c= false;
        FTRPP.ROR__c= true;
        update FTRPP;
        
        Related_Account_Plan__c ARRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        ARRPP.ARR__c= 500;
        ARRPP.Previous_ARR__c= 1000;
        update ARRPP;
        
        Related_Account_Plan__c UpdatePP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        UpdatePP.Account_Plan__c= lPlan[1].id;
        UpdatePP.Contract__c= lContract[1].id;
        update UpdatePP;
        Test.stopTest();
        
        List<Related_Account_Plan__c> lAssignedPlanProds = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[1].id];
        if(lAssignedPlanProds.size()>0)
        {
        system.assert(lAssignedPlanProds.size()>0, 'PlanProduct doesnt exist');
        
        Related_Account_Plan__c UnassignPP = new Related_Account_Plan__c(id=lAssignedPlanProds[0].id);
        UnassignPP.Account_Plan__c= Null;
        update UnassignPP; 
        }
        List<Plan_Contract__c> lPlanCon = [Select Id from Plan_Contract__c];
        system.assert(lPlanCon.size()>0, 'Plan Contract doesnt exist');
        
        Plan_Contract__c plancon = new Plan_Contract__c(id=lPlanCon[0].id);
        plancon.Plan__c =lPlan[0].id;
        plancon.Contract__c= lContract[1].id;
        globalApexManager.avoidRecursion('PlanContractBeforeUpdate');
        update plancon;
        
        
    }
    
    static testMethod void PlanProductInvocableNotifyCSMTest() {
        
        List<Plan__c> lPlan = [Select Id from Plan__c];
        system.assert(lPlan.size()>0, 'Plan doenst exist');
        
        List<Contract> lContract = [select Id from Contract];
        system.assert(lContract.size()>0, 'Contract doenst exist');
        
        
        List<Related_Account_Plan__c> lPlanProds = [select id, Account_Plan__c,Contract__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[0].id];
        system.assert(lPlanProds.size()>0, 'Assigned PlanProduct doesnt exist');
        
        List<Related_Account_Plan__c> lUnasignedPlanProd = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c =Null ];
        system.assert(lUnasignedPlanProd.size()>0, 'Unassigned PlanProduct doenst exist');
        List<Id> RelAcctplanids = new  List<Id>();
        for(Related_Account_Plan__c relAccPlan: lPlanProds) 
        {
            RelAcctplanids.add(relAccPlan.id);
        }
        
        
        PlanProductInvocableNotifyCSM.NotifyUsers(RelAcctplanids);
        
        
        Test.startTest();
        Related_Account_Plan__c assignPP1 = new Related_Account_Plan__c(id=lUnasignedPlanProd[0].id);
        assignPP1.Account_Plan__c= lPlanProds[0].Account_Plan__c;
        assignPP1.Contract__c= lPlanProds[0].Contract__c;
        update assignPP1;
        
        Related_Account_Plan__c FTRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        FTRPP.FTR__c= false;
        FTRPP.ROR__c= true;
        update FTRPP;
        
        Related_Account_Plan__c ARRPP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        ARRPP.ARR__c= 500;
        ARRPP.Previous_ARR__c= 1000;
        update ARRPP;
        
        Related_Account_Plan__c UpdatePP = new Related_Account_Plan__c(id=lPlanProds[0].id);
        UpdatePP.Account_Plan__c= lPlan[1].id;
        UpdatePP.Contract__c= lContract[1].id;
        update UpdatePP;
        
        system.debug('lPlan[1].id'+lPlan[1].id);
        List<Related_Account_Plan__c> lAssignedPlanProds = [select id, Account_Plan__c from Related_Account_Plan__c where Account_Plan__c = : lPlan[1].id];
        if(lAssignedPlanProds.size()>0)
        {
        system.assert(lAssignedPlanProds.size()>0, 'PlanProduct doesnt exist');
        Related_Account_Plan__c UnassignPP = new Related_Account_Plan__c(id=lAssignedPlanProds[0].id);
        UnassignPP.Account_Plan__c= Null;
        update UnassignPP; 
        }
        List<Plan_Contract__c> lPlanCon = [Select Id from Plan_Contract__c];
        system.assert(lPlanCon.size()>0, 'Plan Contract doesnt exist');
        
        Plan_Contract__c plancon = new Plan_Contract__c(id=lPlanCon[0].id);
        plancon.Plan__c =lPlan[0].id;
        plancon.Contract__c= lContract[1].id;
        update plancon;
        
		Test.stopTest();
        
        
    }
    
	/*
	 Method Name : testRecordFetching
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordAliasCreation() {
        System.runAs(createTestUser('System Administrator', true)) {
			Plan__c objPlan = new Plan__c();
			Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
			Account objAccount = [SELECT Id FROM Account LIMIT 1];
			Contract objContract = [SELECT Id FROM Contract LIMIT 1];
			Account_LOB__c objAccountLOB = [SELECT Id FROM Account_LOB__c LIMIT 1];
            Related_Account_Plan__c objPlanProduct = [SELECT Id, Forecast_Product__c, Delivery_Method__c FROM Related_Account_Plan__c WHERE Forecast_Product__c <> NULL AND 
					Delivery_Method__c <> NULL AND Delivery_Method__c <> 'On Premise' LIMIT 1];
			List<Related_Account_Plan__c> lstPlanProducts = new List<Related_Account_Plan__c>();

			//We create the Technical Product Line.
			objTechnicalProductLine.Name = 'Test';
			objTechnicalProductLine.Forecast_Product__c = objPlanProduct.Forecast_Product__c;
			objTechnicalProductLine.Delivery_Method__c = objPlanProduct.Delivery_Method__c;
			insert objTechnicalProductLine;

			//Now we test the method.
			Test.startTest();
			objPlanProduct.Delivery_Method__c = 'On Premise';
			update objPlanProduct;
            System.assertNotEquals([SELECT Id FROM Plan_Product_Alias__c LIMIT 1] == null, true, 'Unable to create record.');
			objPlan.Account__c = objAccount.Id;
			objPlan.Name = 'Test Plan2';
			objPlan.Status__c = 'Active';
			objPlan.Line_of_Business__c = objAccountLOB.Id;
			insert objPlan;
			objPlanProduct = new Related_Account_Plan__c();
			objPlanProduct.Account__c = objAccount.Id;
			objPlanProduct.Start_Date__c = System.today();
			objPlanProduct.End_Date__c = System.today() + 100;
			objPlanProduct.Contract__c = objContract.Id;
			objPlanProduct.Pricing_Business_Model__c = 'Subscription';
			objPlanProduct.Forecast_Product__c = objTechnicalProductLine.Forecast_Product__c;
			objPlanProduct.Delivery_Method__c = objTechnicalProductLine.Delivery_Method__c;
			objPlanProduct.Offering_Type__c = 'Cloud Hosted Subscription';
			objPlanProduct.FTR__c = true;
			objPlanProduct.Account_Plan__c = objPlan.Id;
			insert objPlanProduct;
			objPlanProduct = new Related_Account_Plan__c();
			objPlanProduct.Account__c = objAccount.Id;
			objPlanProduct.Start_Date__c = System.today();
			objPlanProduct.End_Date__c = System.today() + 100;
			objPlanProduct.Contract__c = objContract.Id;
			objPlanProduct.Pricing_Business_Model__c = 'Subscription';
			objPlanProduct.Forecast_Product__c = objTechnicalProductLine.Forecast_Product__c;
			objPlanProduct.Delivery_Method__c = objTechnicalProductLine.Delivery_Method__c;
			objPlanProduct.Offering_Type__c = 'Cloud Hosted Subscription';
			objPlanProduct.FTR__c = true;
			objPlanProduct.Account_Plan__c = objPlan.Id;
			insert objPlanProduct;
			System.assertNotEquals([SELECT Id FROM Plan_Product_Alias__c LIMIT 1] == null, true, 'Unable to create record.');

			//Now we test bulkified code.
			objTechnicalProductLine = new Technical_Product_Line__c();
			objTechnicalProductLine.Name = 'Test 2';
			objTechnicalProductLine.Forecast_Product__c = 'Address Verification';
			objTechnicalProductLine.Delivery_Method__c = 'Hosted Single Tenant';
			insert objTechnicalProductLine;
			objTechnicalProductLine = new Technical_Product_Line__c();
			objTechnicalProductLine.Name = 'Test 2';
			objTechnicalProductLine.Alias__c = 'MDM Users';
			objTechnicalProductLine.Delivery_Method__c = 'Hosted Single Tenant';
			insert objTechnicalProductLine;
			objPlanProduct = new Related_Account_Plan__c();
			objPlanProduct.Account__c = objAccount.Id;
			objPlanProduct.Start_Date__c = System.today();
			objPlanProduct.End_Date__c = System.today() + 100;
			objPlanProduct.Contract__c = objContract.Id;
			objPlanProduct.Pricing_Business_Model__c = 'Subscription';
			objPlanProduct.Forecast_Product__c = 'Address Verification';
			objPlanProduct.Delivery_Method__c = 'Hosted Single Tenant';
			objPlanProduct.Offering_Type__c = 'Cloud Hosted Subscription';
			objPlanProduct.FTR__c = true;
			objPlanProduct.Account_Plan__c = objPlan.Id;
			lstPlanProducts.add(objPlanProduct);
			objPlanProduct = new Related_Account_Plan__c();
			objPlanProduct.Account__c = objAccount.Id;
			objPlanProduct.Start_Date__c = System.today();
			objPlanProduct.End_Date__c = System.today() + 100;
			objPlanProduct.Contract__c = objContract.Id;
			objPlanProduct.Pricing_Business_Model__c = 'Subscription';
			objPlanProduct.Forecast_Product__c = 'MDM Users';
			objPlanProduct.Delivery_Method__c = 'Hosted Single Tenant';
			objPlanProduct.Offering_Type__c = 'Cloud Hosted Subscription';
			objPlanProduct.FTR__c = true;
			objPlanProduct.Account_Plan__c = objPlan.Id;
			lstPlanProducts.add(objPlanProduct);
			insert lstPlanProducts;
			System.assertNotEquals([SELECT Id FROM Plan_Product_Alias__c LIMIT 1] == null, true, 'Unable to create record.');
			Test.stopTest();
        }
    }
      
	/*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
	 			   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
	 Return Type : User record.
	 */
	private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;
		List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

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
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }

		//Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id,type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
            if(objPermissionSet.Type == 'Regular'){
                lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
            }
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }
        
		//Now we return the result.
        return objTestUser;
    }
}