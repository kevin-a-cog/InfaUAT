/*
Class:  AccountTriggerHandlerTest
        @Author:        Anil Solanki
        @Created Date:  05/29/2018
        @Description:   Test Class for AccountTriggerHandler Class.
*/
@isTest
private class AccountTriggerHandlerTest{
    
   private Final Static Id ProspectAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
   private Final Static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {


        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id PartnerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        
    
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Partner Account');
            UtilityTestData.mAccountData.put('RecordTypeId', PartnerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('Partner_Support_Entitlement__c', 'Basic Success');
            UtilityTestData.mAccountData.put('Partner_Support_End_Date__c',System.today()+10+'');
            UtilityTestData.mAccountData.put('New_Logo_SPIFF__c','G2K Eligible');

            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);

            sObject sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account 1');
            UtilityTestData.mAccountData.put('RecordTypeId', ProspectAccountRecType);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData); 
            
            sObject sObj2 = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account 2');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData); 
                        
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
          
                 
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
            UtilityTestData.mContactData.put('MailingCountry', 'USA');
            UtilityTestData.mContactData.put('Partner_Role__c','Partner Portal Admin');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

           
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise');
            UtilityTestData.mtechnicalProductLine.Put('Status__c','Active');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
            List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            

    }  

   private Final Static String vEmployee = Label.Profile_Employee;
  
    static testMethod void IgnoreaccountDeleteTest() {
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
                 
        Test.startTest();
           try{
                     sObj = new Account(Id = lAccount [0].Id );
                     sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                     globalApexManager.avoidRecursion('AccountBeforeDelete ');
                     UtilityTest.makeDelete(new List<sObject>{sObj});
                     List<Account> lAccountDeleted = [Select Id,Name from Account];
                     //System.assertEquals(lAccountDeleted.size(),0);
                     
           }
           Catch(Exception e){
                 
           }
        Test.stopTest();
    }
    
    
     static testMethod void accountDeleteTest() {
        User userObj = [select Id, Name from User where Profile.Name = 'Employee' AND isActive=true limit 1];
        
        Test.startTest();
            System.runAs(userObj) {
                 try{
                 sObject sObj = new Account();
                 sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
                 List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
                 System.assertEquals(lAccount.size(),1);
        
                     sObj = new Account(Id = lAccount [0].Id );
                     sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                     UtilityTest.makeDelete(new List<sObject>{sObj});
    
                     List<Account> lAccountDeleted = [Select Id,Name from Account];
                     //System.assertEquals(lAccountDeleted.size(),1);
                     
                 }
                 Catch(Exception e){
                 
                 }
            }
        Test.stopTest();
    }
    
    static testmethod void validateSignatureSuccess (){
        Test.startTest();
        Account custAccount = [Select id,Signature_Success__c from Account where  recordtypeId= :CustomerAccountRecType];
        custAccount.Signature_Success__c = true;
        custAccount.Acc__c = true;
        custAccount.Success_Portfolio__c='APAC';
        update custAccount ;
        Test.stopTest();
        
    }
    
    static testmethod void validatePartnerSupport (){
        Id PartnerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();

        Account PartnerAccount = [Select id,Partner_Support_Entitlement__c,Partner_Support_End_Date__c from account where  recordtypeId= :PartnerAccountRecType ];
        PartnerAccount.Partner_Support_Entitlement__c ='Premium Success';
        PartnerAccount.Partner_Support_End_Date__c=System.today()+100;
        update PartnerAccount;

        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Account SupportAccount = [Select id,Partner_Support_Entitlement__c,Partner_Support_End_Date__c from account where  recordtypeId= :SupportAccountRecType ];


        PartnerAccount.Partner_Support_Entitlement__c ='Basic Success';
        PartnerAccount.Partner_Support_End_Date__c=System.today()+120;
        update PartnerAccount;
    }

    static testMethod void AccountBeforeUpdateTest() {

        List<Account> lAccount = [Select Id FROM Account WHERE RecordTypeId =:ProspectAccountRecType and Peoplesoft_External_ID__c = null];

        sObject sObj = new Account(Id = lAccount [0].Id,Peoplesoft_External_ID__c = 'TestErpId', ShippingCountry ='US');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> accUpdateList = (List<Account>) UtilityTest.makeUpdate(new List<sObject>{sObj});

        List<ERP_Company__c> lstErpCustomer = [SELECT Id FROM ERP_Company__c];
        System.assertEquals(lstErpCustomer.size(),1); 
    }     
        
    @IsTest
    public static void testSpiffFunctionality(){

            List<Account> lAccount = [Select Id,New_Logo_SPIFF__c FROM Account LIMIT 1];
            SObject sObj;
            SObject sObj1;

            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);    
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

            Test.startTest();
        	globalApexManager.allowRun('AccountAfterUpdate');
            sObj = new Account(Id = lAccount [0].Id,New_Logo_SPIFF__c = '');
            List<Account> accUpdateList = (List<Account>) UtilityTest.makeUpdate(new List<sObject>{sObj});

            sObj = new Account(Id = lAccount [0].Id,New_Logo_SPIFF__c = 'G2K Active Customer');
            accUpdateList = (List<Account>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            Test.stopTest();
    }
        
}