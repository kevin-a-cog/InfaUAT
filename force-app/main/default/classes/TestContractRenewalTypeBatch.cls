/*
* Copyright 2019 Deloitte Digital México
* Author: Diego Soto
* Creation date: January 2019
* Description: Execute test method take and save in a list all null values
*/ 

@isTest (seeAllData=false)
public class TestContractRenewalTypeBatch {

    @testSetup
    static void setupObjectTestData() {
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        //Create a new Instance of our Object Account
        System.runAs(adminUser){
            Account objAccount = new Account();
           
            //Set the values for objAccount
      		objAccount.Name ='TestAccount';
      		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      		objAccount.BillingCountry = 'USA';
           
            //Insert new record
      		insert objAccount;
        	//Create a new instance of Quote object
        	sObject sObj = new SBQQ__Quote__c();
        	UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',objAccount.Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',objAccount.Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',objAccount.Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
			List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
    }
    
    /**
* this method is methodName to test ContractRenewalTypeBatch
*
* @param NA
* @return return-Void
* @throws exception - NA
*/
    @isTest
    static void methodNameSubscription (){
      string query;
      test.startTest();
        	//Create a new Instance of our Object Account
            Account objAccount = new Account();
           
            //Set the values for objAccount
      		objAccount.Name ='TestAccount';
      		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      		objAccount.BillingCountry = 'USA';
           
            //Insert new record
      		insert objAccount;
        	
            User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        	List<SBQQ__Quote__c> lSBQuote = [Select id from SBQQ__Quote__c limit 1]; 
            //Create a new Instance of our Object Contract
      		Contract objContract = new Contract();
           
            //Set the values for objContract
      		objContract.Name='TestContract';
      		objContract.AccountId= objAccount.Id;
      		objContract.Status='Draft';
      		objContract.ContractTerm= 12;
      		objContract.CurrencyIsoCode= 'USD';
      		objContract.SBQQ__RenewalForecast__c= False;
        	objContract.SBQQ__RenewalOpportunityRecordTypeId__c='qwqwb15464644';
        	objContract.SBQQ__RenewalOpportunityStage__c='Initiated';
			objContract.SBQQ__Quote__c = lSBQuote[0].Id;
        	//objContract.Renewal_Type__c='Subscription';
        	//objContract.SBQQ__RenewalOwner__c= adminUser.Id;
            //Insert new Record
            List<Contract> contractList = new List<Contract>();
        	contractList.add(objContract);
      		insert contractList;
        	
        	Contract objContractUpdate = [Select Id,Status,Name from Contract where Name='TestContract'];
        	objContractUpdate.Status='Activated';
        	update objContractUpdate;
            
        	Product2 objProduct = new Product2();
      		objProduct.Name='testProduct';
      		objProduct.CurrencyIsoCode='USD';
           objProduct.Offering_Type__c ='Fee';
        		//objProduct.Forecast_Product__c='Support';
      		insert objProduct;
        
       		Product2 objProduct2 = new Product2();
      		objProduct2.Name='testProduct';
      		objProduct2.CurrencyIsoCode='USD';
       		objProduct2.Family='On-Premise Perpetual';
         objProduct2.Offering_Type__c ='Fee';
      		insert objProduct2;
      		
        	SBQQ__Subscription__c objSubscription = new SBQQ__Subscription__c();
      		objSubscription.CurrencyIsoCode= 'USD'; 
      		objSubscription.SBQQ__Account__c= objAccount.Id;
        	objSubscription.SBQQ__Quantity__c= 12;
        	objSubscription.SBQQ__Contract__c=objContract.Id;
        	objSubscription.SBQQ__Product__c=objProduct.Id;
       		
        	SBQQ__Subscription__c objSubscription2 = new SBQQ__Subscription__c();
      		objSubscription2.CurrencyIsoCode= 'USD'; 
      		objSubscription2.SBQQ__Account__c= objAccount.Id;
        	objSubscription2.SBQQ__Quantity__c= 12;
        	objSubscription2.SBQQ__Contract__c=objContract.Id;
        	objSubscription2.SBQQ__Product__c=objProduct2.Id;
        	
        	List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        	subscriptionList.add(objSubscription2);
         	subscriptionList.add(objSubscription);
       
        	insert (subscriptionList);
           
            //Parameters of ExecuteBatch(context,BatchSize)
            ContractRenewalTypeBatch contractRenewal = new ContractRenewalTypeBatch();
        	//contractRenewal.contractList= 'Select '
      		Database.executeBatch(contractRenewal);   
      
      test.stopTest();
    }
    
    @isTest
    static void methodSupport (){
      string query;
      test.startTest();
        	//Create a new Instance of our Object Account
            Account objAccount = new Account();
           
            //Set the values for objAccount
      		objAccount.Name ='TestAccount';
      		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      		objAccount.BillingCountry = 'USA';
           
            //Insert new record
      		insert objAccount;
        	
            User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
            //Create a new Instance of our Object Contract
            List<SBQQ__Quote__c> lSBQuote = [Select id from SBQQ__Quote__c limit 1];
      		Contract objContract = new Contract();
           
            //Set the values for objContract
      		objContract.Name='TestContract';
      		objContract.AccountId= objAccount.Id;
      		objContract.Status='Draft';
      		objContract.ContractTerm= 12;
      		objContract.CurrencyIsoCode= 'USD';
      		objContract.SBQQ__RenewalForecast__c= False;
        	objContract.SBQQ__RenewalOpportunityRecordTypeId__c='qwqwb15464644';
        	objContract.SBQQ__RenewalOpportunityStage__c='Initiated';
        	objContract.SBQQ__Quote__c = lSBQuote[0].Id;
        	//objContract.Renewal_Type__c='Subscription';
        	//objContract.SBQQ__RenewalOwner__c= adminUser.Id;
            //Insert new Record
            List<Contract> contractList = new List<Contract>();
        	contractList.add(objContract);
      		insert contractList;
        	
        	Contract objContractUpdate = [Select Id,Status,Name from Contract where Name='TestContract'];
        	objContractUpdate.Status='Activated';
        	update objContractUpdate;
            
        	Product2 objProduct = new Product2();
      		objProduct.Name='testProduct';
      		objProduct.CurrencyIsoCode='USD';
       		objProduct.Forecast_Product__c='Support';
            objProduct.Offering_Type__c ='Fee';
      		insert objProduct;
        
       		Product2 objProduct2 = new Product2();
      		objProduct2.Name='testProduct';
      		objProduct2.CurrencyIsoCode='USD';
       		objProduct2.Family='On-Premise Perpetual';
            objProduct2.Offering_Type__c ='Fee';
      		insert objProduct2;
      		
        	SBQQ__Subscription__c objSubscription = new SBQQ__Subscription__c();
      		objSubscription.CurrencyIsoCode= 'USD'; 
      		objSubscription.SBQQ__Account__c= objAccount.Id;
        	objSubscription.SBQQ__Quantity__c= 12;
        	objSubscription.SBQQ__Contract__c=objContract.Id;
        	objSubscription.SBQQ__Product__c=objProduct.Id;
       		
        	SBQQ__Subscription__c objSubscription2 = new SBQQ__Subscription__c();
      		objSubscription2.CurrencyIsoCode= 'USD'; 
      		objSubscription2.SBQQ__Account__c= objAccount.Id;
        	objSubscription2.SBQQ__Quantity__c= 12;
        	objSubscription2.SBQQ__Contract__c=objContract.Id;
        	objSubscription2.SBQQ__Product__c=objProduct2.Id;
        	
        	List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        	subscriptionList.add(objSubscription2);
         	subscriptionList.add(objSubscription);
       
        	insert (subscriptionList);
           
            //Parameters of ExecuteBatch(context,BatchSize)
            ContractRenewalTypeBatch contractRenewal = new ContractRenewalTypeBatch();
      		Database.executeBatch(contractRenewal);   
      
      test.stopTest();
    }
    
    @isTest
    static void methodNameDaaS (){
      string query;
      test.startTest();
        	//Create a new Instance of our Object Account
            Account objAccount = new Account();
           
            //Set the values for objAccount
      		objAccount.Name ='TestAccount';
      		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      		objAccount.BillingCountry = 'USA';
           
            //Insert new record
      		insert objAccount;
        	
            User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
            //Create a new Instance of our Object Contract
            List<SBQQ__Quote__c> lSBQuote = [Select id from SBQQ__Quote__c limit 1];
      		Contract objContract = new Contract();
           
            //Set the values for objContract
      		objContract.Name='TestContract';
      		objContract.AccountId= objAccount.Id;
      		objContract.Status='Draft';
      		objContract.ContractTerm= 12;
      		objContract.CurrencyIsoCode= 'USD';
      		objContract.SBQQ__RenewalForecast__c= False;
        	objContract.SBQQ__RenewalOpportunityRecordTypeId__c='qwqwb15464644';
        	objContract.SBQQ__RenewalOpportunityStage__c='Initiated';
        	objContract.SBQQ__Quote__c = lSBQuote[0].Id;
            List<Contract> contractList = new List<Contract>();
        	contractList.add(objContract);
      		insert contractList;
        	
        	Contract objContractUpdate = [Select Id,Status,Name from Contract where Name='TestContract'];
        	objContractUpdate.Status='Activated';
        	update objContractUpdate;
            
        	Product2 objProduct = new Product2();
      		objProduct.Name='testProduct';
      		objProduct.CurrencyIsoCode='USD';
       		objProduct.Family='DaaS Subscription';
            objProduct.Offering_Type__c ='Fee';
      		insert objProduct;
        
       		Product2 objProduct2 = new Product2();
      		objProduct2.Name='testProduct';
      		objProduct2.CurrencyIsoCode='USD';
       		objProduct2.Family='DaaS Subscription';
             objProduct2.Offering_Type__c ='Fee';
      		insert objProduct2;
      		
        	SBQQ__Subscription__c objSubscription = new SBQQ__Subscription__c();
      		objSubscription.CurrencyIsoCode= 'USD'; 
      		objSubscription.SBQQ__Account__c= objAccount.Id;
        	objSubscription.SBQQ__Quantity__c= 12;
        	objSubscription.SBQQ__Contract__c=objContract.Id;
        	objSubscription.SBQQ__Product__c=objProduct.Id;
       		
        	SBQQ__Subscription__c objSubscription2 = new SBQQ__Subscription__c();
      		objSubscription2.CurrencyIsoCode= 'USD'; 
      		objSubscription2.SBQQ__Account__c= objAccount.Id;
        	objSubscription2.SBQQ__Quantity__c= 12;
        	objSubscription2.SBQQ__Contract__c=objContract.Id;
        	objSubscription2.SBQQ__Product__c=objProduct2.Id;
        	
        	List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        	subscriptionList.add(objSubscription2);
         	subscriptionList.add(objSubscription);
       
        	insert (subscriptionList);
           
            //Parameters of ExecuteBatch(context,BatchSize)
            ContractRenewalTypeBatch contractRenewal = new ContractRenewalTypeBatch();
      		Database.executeBatch(contractRenewal);   
      
      test.stopTest();
    }
    @isTest
    static void methodNameWithOwner (){
      string query;
      test.startTest();
        	//Create a new Instance of our Object Account
            Account objAccount = new Account();
           
            //Set the values for objAccount
      		objAccount.Name ='TestAccount';
      		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
      		objAccount.BillingCountry = 'USA';
           
            //Insert new record
      		insert objAccount;
        	
            User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
            //Create a new Instance of our Object Contract
            List<SBQQ__Quote__c> lSBQuote = [Select id from SBQQ__Quote__c limit 1];
      		Contract objContract = new Contract();
           
            //Set the values for objContract
      		objContract.Name='TestContract';
      		objContract.AccountId= objAccount.Id;
      		objContract.Status='Draft';
      		objContract.ContractTerm= 12;
      		objContract.CurrencyIsoCode= 'USD';
      		objContract.SBQQ__RenewalForecast__c= False;
        	objContract.SBQQ__RenewalOpportunityRecordTypeId__c='qwqwb15464644';
        	objContract.SBQQ__RenewalOpportunityStage__c='Initiated';
        	objContract.Renewal_Type__c='Subscription';
        	objContract.SBQQ__Quote__c = lSBQuote[0].Id;
        	objContract.SBQQ__RenewalOwner__c= adminUser.Id;
            List<Contract> contractList = new List<Contract>();
        	contractList.add(objContract);
      		insert contractList;
        	
        	Contract objContractUpdate = [Select Id,Status,Name from Contract where Name='TestContract'];
        	objContractUpdate.Status='Activated';
        	update objContractUpdate;
            
        	Product2 objProduct = new Product2();
      		objProduct.Name='testProduct';
      		objProduct.CurrencyIsoCode='USD';
       		objProduct.Family='DaaS Subscription';
        	objProduct.Offering_Type__c ='Fee';
      		insert objProduct;
        
       		Product2 objProduct2 = new Product2();
      		objProduct2.Name='testProduct';
      		objProduct2.CurrencyIsoCode='USD';
       		objProduct2.Family='DaaS Subscription';
            objProduct2.Offering_Type__c ='Fee';
      		insert objProduct2;
      		
        	SBQQ__Subscription__c objSubscription = new SBQQ__Subscription__c();
      		objSubscription.CurrencyIsoCode= 'USD'; 
      		objSubscription.SBQQ__Account__c= objAccount.Id;
        	objSubscription.SBQQ__Quantity__c= 12;
        	objSubscription.SBQQ__Contract__c=objContract.Id;
        	objSubscription.SBQQ__Product__c=objProduct.Id;
       		
        	SBQQ__Subscription__c objSubscription2 = new SBQQ__Subscription__c();
      		objSubscription2.CurrencyIsoCode= 'USD'; 
      		objSubscription2.SBQQ__Account__c= objAccount.Id;
        	objSubscription2.SBQQ__Quantity__c= 12;
        	objSubscription2.SBQQ__Contract__c=objContract.Id;
        	objSubscription2.SBQQ__Product__c=objProduct2.Id;
        	
        	List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        	subscriptionList.add(objSubscription2);
         	subscriptionList.add(objSubscription);
       
        	insert (subscriptionList);
           
            //Parameters of ExecuteBatch(context,BatchSize)
            ContractRenewalTypeBatch contractRenewal = new ContractRenewalTypeBatch();
      		Database.executeBatch(contractRenewal);   
      
      test.stopTest();
    }
  
}