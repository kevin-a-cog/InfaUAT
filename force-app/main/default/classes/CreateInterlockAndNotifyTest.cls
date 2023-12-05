/*
Class:          CreateInterlockAndNotifyTest
@Author:        Chandana Gowda 
@Created Date:  24-Jan-2020
@Description:   Test class to test the invocable method for automatic interlock creation 
Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public with sharing class CreateInterlockAndNotifyTest {
    
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    //To setup territory data
    static void NonsetupTestData(){
        
        List<Territory2Model> lstTerritoryModel = 
            [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        sObject terr = new Territory2();
        UtilityTestData.mTerritoryData.put('DeveloperName', 'AP_AS_AS_MAM_TEST'); 
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lstTerritoryModel[0].Id);
        UtilityTestData.mTerritoryData.put('Name', 'AP_AS_AS_MAM_TEST');
        UtilityTestData.mTerritoryData.put('Territory2TypeId', terriType[0].id);
        terr = (Territory2)UtilityTest.putFieldRecord(terr, UtilityTestData.mTerritoryData); 
        List<Territory2>  lTerr = (List<Territory2>) UtilityTest.makeInsert(new List<sObject>{terr});
    }   
    
    //Method to setup test data
    @testSetup
    static void setupObjectTestData() {
       /* 
        //Create TaxConfig Custom Setting
        blng__TaxConfig__c taxConfig = new blng__TaxConfig__c();
        taxConfig.Name = 'Standard';
        taxConfig.blng__ClassName__c = 'blng.StandardTaxCalculation';
        insert taxConfig;
        
        //Create Billing Prefix Custom Setting 
        blng__BillingPrefix__c billingPrefix = new blng__BillingPrefix__c(SetupOwnerId = UserInfo.getUserId());
        billingPrefix.blng__BarPrefix__c = 'blng__' ;
        billingPrefix.blng__DotPrefix__c = 'blng.';
        billingPrefix.blng__RawPrefix__c = 'blng';
        insert billingPrefix;
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObject sObjb = new blng__BillingRule__c();
        sObject sObjc = new blng__BillingRule__c();
        sObject sObjd = new blng__BillingRule__c();
        
        sObjb = new blng__BillingRule__c();        
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__RevenueRecognitionRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__TaxRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        */
        User adminUserObj = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        system.runAs(adminUserObj){
            NonsetupTestData();
        }
        Territory2  terr=[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];        
        
        Profile pr = [select ID,Name from Profile where name='System Administrator'];
        
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser1'); 
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing11');
        UtilityTestData.mUserData.put('Alias', 'usrTemp1');
        UtilityTestData.mUserData.put('Email', 'usr_temp1@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp1@testorg.com');
        sObject sObj1 = new User();
        User userObj1 = (User)UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData); 
        List<User> lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj1});
        
        UtilityTestData.mUserTerritory2AssociationData.put('RoleInTerritory2','CSM');
        if(terr != null)
            UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id',terr.Id);
        UtilityTestData.mUserTerritory2AssociationData.put('UserId',lUser[0].Id);
        UtilityTestData.mUserTerritory2AssociationData.put('IsActive ','true');
        sObject sObj4 = new UserTerritory2Association();
        UserTerritory2Association terrMem1 = (UserTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserTerritory2AssociationData);        
        system.runAs(adminUserObj){
            List<UserTerritory2Association>  lTerrMem = (List<UserTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{terrMem1});
        }
        
        //Account object data
        sObject sObj = new Account();        if(terr != null)
            UtilityTestData.mAccountData.put('Territory_Name__c',(String)terr.Id);
        UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACC_Prospect_Account_Record_Type).getRecordTypeId());
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mObjectTerritory2AssociationData.put('AssociationCause','Territory2Manual');
        UtilityTestData.mObjectTerritory2AssociationData.put('ObjectId',lAccount[0].Id);
        UtilityTestData.mObjectTerritory2AssociationData.put('SobjectType','Account');
        if(terr != null)
            UtilityTestData.mObjectTerritory2AssociationData.put('Territory2Id',terr.Id);
        sObj = new ObjectTerritory2Association();
        ObjectTerritory2Association objTerrAssoc = (ObjectTerritory2Association)UtilityTest.putFieldRecord(sObj, UtilityTestData.mObjectTerritory2AssociationData);
        List<ObjectTerritory2Association>  lObjTerrAssoc = (List<ObjectTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{objTerrAssoc});
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
        
        //Account Team Member
        sObj = new AccountTeamMember();
        UtilityTestData.mAccountTeamMember.put('AccountId',lAccount[0].id + '');
        UtilityTestData.mAccountTeamMember.put('UserId',lUser[0].id + '');
        UtilityTestData.mAccountTeamMember.put('TeamMemberRole','CSM');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountTeamMember);
        List<AccountTeamMember> lAccTeamMember1 = UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //Account Product
        UtilityTestData.mAccountProduct.put('Account__c',lAccount[0].Id);
        sObject AccProd = new Account_Product__c();
        AccProd = UtilityTest.putFieldRecord(AccProd, UtilityTestData.mAccountProduct);
        List<Account_Product__c> lAccProd = (List<Account_Product__c>) UtilityTest.makeInsert(new List<sObject>{AccProd});
        
        //Plan
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);        
        UtilityTestData.mPlan.put('Status__c','Active');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Outcome Based Success Plan').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});                
        
        // Set all the required fields and dynamic ids in Map : Contact 1
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'New');
        UtilityTestData.mOpportunityData.put('CloseDate',System.today()+'');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        //UtilityTestData.mOpportunityData.put('OrderableIn__c', 'New');
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Opportunity Contact Roles
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Product2();
       // UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
       // UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
      //  UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData); 
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        /*    

//Insert a legal entity record
sObj = new blng__LegalEntity__c();
UtilityTestData.mLegalEntityData.put('Name','test');
UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

//Create Quote
//For Cancel
sObj = new SBQQ__Quote__c();
UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[0].Id);
UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

//Create QuoteLineItem
sObj = new SBQQ__QuoteLine__c();
UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

//Create related Order record
sObj = new Order();
UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
UtilityTestData.mOrderData.put('BillToContactId',lContact[0].Id);
UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed'); 
UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
UtilityTestData.mOrderData.put('Type','New');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});

Set<id> orderIds = new Set<id>();
orderIds.add(lOrder[0].Id);
ActivateOrderFuture.activateOrder(orderIds);
*/
        Test.startTest();
        sObj = new Contract();
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
        // UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
        UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
        UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
        UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
        UtilityTestData.mContractData.put('ContractTerm','10');
        // UtilityTestData.mContractData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunityRecord[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        //  UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
        
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
        UtilityTestData.mOpportunityData.put('SBQQ__RenewedContract__c',lContract[0].Id); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});  
        Test.stopTest();
    }//END static void setupTestData()    
    
    //Method to test creation of Interlock for Account with one plan
    @isTest
    public static void testlinkPlanAndInterlockwithOnePlan(){
        List<Contract> lContract  = [SELECT Id FROM Contract LIMIT 1];
        List<Opportunity> lOppty = [SELECT Id,SBQQ__RenewedContract__c FROM Opportunity WHERE SBQQ__RenewedContract__c =:lContract[0].Id];
        Test.startTest();
        CreateInterlockAndNotify.createInterlock(new List<Id>{lOppty[0].Id});
        List<Related_Opportunity_Plan__c> lstInterlock = [SELECT Id FROM Related_Opportunity_Plan__c];
        System.assertEquals(1, lstInterlock.size());
        Test.stopTest();
    }
    
    //Method to test creation of Interlock for Account with two plan
    @isTest
    public static void testCreateInterlockAndNotify2(){
        
        List<Account> lAccount = [SELECT Id from Account];
        List<Account_LOB__c> lAccLOB = [SELECT Id FROM Account_LOB__c];        
        //Plan
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        Test.startTest();
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        List<Contract> lContract  = [SELECT Id FROM Contract LIMIT 1];
        List<Opportunity> lOppty = [SELECT Id,SBQQ__RenewedContract__c FROM Opportunity WHERE SBQQ__RenewedContract__c =:lContract[0].Id];        
        CreateInterlockAndNotify.createInterlock(new List<Id>{lOppty[0].Id});
        List<Related_Opportunity_Plan__c> lstInterlock = [SELECT Id FROM Related_Opportunity_Plan__c];
        System.assertEquals(0, lstInterlock.size());
        Test.stopTest();
    }           
}