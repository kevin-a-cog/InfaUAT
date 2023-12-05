/*
Class:          CreateSubscriptionLinesTest 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Scheduler class for CreateSubscriptionLineBatch,CreateSubscriptionLines
****************************************************************************************
*
*/

@isTest (seeAllData=false)
public class CreateSubscriptionLinesTest {
    
    @testSetup
    static void setupObjectTestData() {
        //List<User> userList = UtilityTest.createUsersforPRM();
        //User adminUser = userList[0];
        //Create a new Instance of our Object Account
        User adminUser = [Select Id from User where id =: UserInfo.getUserId()];
        System.runAs(adminUser){
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            sObject sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            UtilityTestData.mAccountData.put('CSM_Segment__c','High-Touch');
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
        
            sObj = new AccountTeamMember();
            UtilityTestData.mAccountTeamMember.put('AccountId',lAccount[0].id + '');
            UtilityTestData.mAccountTeamMember.put('UserId',adminUser.id + '');
            UtilityTestData.mAccountTeamMember.put('TeamMemberRole','CSM');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountTeamMember);
            List<AccountTeamMember> lAccTeamMember1 = UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test Product 1');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Quality');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            
            sObject sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test Product 2');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Quality');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            
            //Create a new instance of Quote object
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c','True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Test.startTest();
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[1].Id);//
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        	UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
            sObj1= UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

            
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderData.put('Status','Draft');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
            List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            UtilityTestData.mContractData.put('Renewal_Type__c','SMG');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);

            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            
           
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            test.stopTest();

            
        }
    }
    
    public static testMethod void testCreateSubscriptionLineBatch (){
        test.startTest();
        
        CreateSubscriptionLineBatch createsub = new CreateSubscriptionLineBatch();
        Database.executeBatch(createsub);      
        
        test.stopTest();
    }
}