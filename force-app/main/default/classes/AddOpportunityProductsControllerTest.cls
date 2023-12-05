/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*  @Author:        Sumitkumar Mittal
*  @Created Date:  04/24/2018
*  @Description:   Test class for AddOpportunityProductsController class with the updated test framework
*/

@isTest
private class AddOpportunityProductsControllerTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {
        
        //Insert Account setup data
        sObject sObj = new Account();
        // Call methos and pass sObject and data maps
        // This utility method will populate all the fields data according to the Map passed
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
    }//END static void setupTestData()
    
    
    
    /*
Below methods are covering the class ContactTriggerHandler
*/
	@isTest
    static void myUnitTest_ProductSearchBar() {
        
        User userObj = [select Id, Name from User where Profile.Name =: vEmployee AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account limit 1');
        
        Test.StartTest();
        //System.runAs(userObj) {
            
            String searchKeyword='Laptop';
            String pillsList;
            
            List<AddOpportunityProductsController.DisplayProductRecords> lstProdRecords = new List<AddOpportunityProductsController.DisplayProductRecords>();
            AddOpportunityProductsController.DisplayProductRecords obj1 = new AddOpportunityProductsController.DisplayProductRecords();
            obj1.isSelected = True;
            obj1.Name = 'Prod1';
            obj1.Products = 'Data Transformation';
            obj1.ForecastFamily='On Prem Subscription';
            obj1.ProductFamily='DQ';
            obj1.DeliveryMethod='On Premise';
            obj1.PricingBusinessModel='Subscription';
            obj1.ProcessingEngine='Mix DB'; 
            
            lstProdRecords.add(obj1);
            
            string prodName = obj1.Name;
            string prodFamily = obj1.ProductFamily;
            string prodProducts = obj1.Products;
            string prodId = obj1.prodId;
            String family='';
            String forcast=''; 
            String Bussiness= null;
            String family2='';
            String engine='';
            
            String prodRecords = JSON.serialize(lstProdRecords);
            
            //Inserting new test product2
            sObject sObj = new Product2(Name = 'Laptop X200');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Data Transformation');
            UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'NA');
        UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Fee');
            UtilityTestData.mProduct2Data.put('Forecastable__c', 'True');
            UtilityTestData.mProduct2Data.put('IsActive', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lProduct.size(), 1);
            
            //create/ standard Pricebook1
            Id priceBookId  = Test.getStandardPricebookId();
            // 1. Insert a price book entry for the standard price book.
            
            sObj = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = pricebookId, Product2Id=lProduct[0].Id + '' );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lPBEntry.size(),1);                        

            //Creating Product2 records
            UtilityTestData.mProductData.put('Forecast_Product__c', 'Data Transformation');
            UtilityTestData.mProductData.put('Family', 'DaaS Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X1');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProductData.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProductData.put('Processing_Engine__c', 'NA');
         UtilityTestData.mProductData.put('Offering_Type__c', 'Fee');
            UtilityTestData.mProductData.put('Forecastable__c', 'Mix DB');
            sObj = new Product2(Name= 'DaaS Subscription');      
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductData);
            system.debug('*******sObj ='+sObj);
            
            UtilityTestData.mProductData.put('Family', 'Cloud Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X2');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Processing_Engine__c', 'NA');
         UtilityTestData.mProductData.put('Offering_Type__c', 'Fee');
            sObject sObj1 = new Product2(Name= 'Cloud Subscription');             
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProductData);
            system.debug('*******sObj1 ='+sObj1);
            
            UtilityTestData.mProductData.put('Family', 'On-Premise Perpetual');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X3');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Processing_Engine__c', 'NA');
         UtilityTestData.mProductData.put('Offering_Type__c', 'Fee');
            sObject sObj2 = new Product2(Name= 'On-Premise Perpetualn');      
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Family', 'On-Premise Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X4');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Processing_Engine__c', 'NA');
            UtilityTestData.mProductData.put('Offering_Type__c', 'Fee');
            sObject sObj3 = new Product2(Name= 'On-Premise Subscription');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProductData);            
            List<Product2> lProductCustom = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj3});
            //System.assertEquals(lProductCustom.size(), 4);
            
            pillsList = JSON.serialize(lProductCustom);
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Rejected');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
            UtilityTestData.mOpportunityData.put('Pricebook2Id', pricebookId);
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '100');     
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');     
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            String testFields = 'Id, Forecast_Product__c';
            
            AddOpportunityProductsController.productSearchBar(searchKeyWord,pillsList, testFields); 
            AddOpportunityProductsController.initProducts(pillsList, testFields);
            AddOpportunityProductsController.getPage();
            AddOpportunityProductsController.getFieldsMapPicklists();
            AddOpportunityProductsController.searchProducts(family, forcast, Bussiness, family2, engine, pillsList, testFields);
            
            family='DaaS Subscription';
            forcast='Data Transformation'; 
            Bussiness= null;
            family2='DaaS Subscription';
            
            AddOpportunityProductsController.searchProducts(family, forcast, Bussiness, family2, engine, pillsList, testFields);
            
            testFields = 'Product2.Forecast_Product__c';
            AddOpportunityProductsController.getSelectedProducts(prodRecords,lOpportunityPrimary[0].Id, testFields);
            AddOpportunityProductsController.fetchOpportunityType(lOpportunityPrimary[0].Id);
        //}
        
        Test.StopTest();
        
    }
    
    
    //SaveSelectedMethod lightning controller method code coverage
	@isTest
    static void myUnitTest_SaveSelectedProducts() {
        
        User userObj = [select Id, Name from User where Profile.Name =: vEmployee AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account limit 1');
        system.debug('***'+userObj);
        
        Test.StartTest();
        //System.runAs(userObj) {
            //Inserting new test product2
            
            sObject sObj = new Product2(Name = 'XBOX 300');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Data Transformation');
            UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'NA');
            UtilityTestData.mProduct2Data.put('Forecastable__c', 'True');
        UtilityTestData.mProduct2Data.put('Offering_type__c', 'Fee');
            UtilityTestData.mProduct2Data.put('IsActive', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lProduct.size(), 1);
            
            //create/ standard Pricebook1
            /*Id priceBookId    = Test.getStandardPricebookId();
            
            sObj = new Pricebook2(ID = priceBookId);
           // UtilityTestData.mPricebook2Data.put('ID', priceBookId);
            UtilityTestData.mPricebook2Data.put('IsActive', 'true');
           // UtilityTestData.mPricebook2Data.put('Active', 'true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj}); */
            //create/ standard Pricebook1
            Id pbId = Test.getStandardPricebookId();
            sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            System.assertEquals(lPriceBook.size(), 1);
            // 1. Insert a price book entry for the standard price book.
            
            sObj = new PriceBookEntry(UnitPrice=10000, Pricebook2Id = lPriceBook[0].Id + '', Product2Id=lProduct[0].Id + '' );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lPBEntry.size(),1);
            
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Rejected');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
            UtilityTestData.mOpportunityData.put('Pricebook2Id', lPriceBook[0].Id + '' );
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '100');     
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');     
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            String rid1 = lOpportunityPrimary[0].Id;
            
            Map<String, String> transTypeAndID = new Map<String, String>(); 
            transTypeAndID.put(lPriceBook[0].Id + '' , 'New'); 
            String priceBookEntryMap = System.JSON.serialize(transTypeAndID); 
            
            List<PricebookEntry> pbel = new List<PricebookEntry>(); 
            pbel.add(lPBEntry[0]); 
            String oppProdRecords = JSON.serialize(pbel); 
            AddOpportunityProductsController.saveSelectedProducts(oppProdRecords,rid1,priceBookEntryMap);  
            AddOpportunityProductsController.getTransTypeSelect();
            
        //}
        Test.StopTest();
    }
    
    
    //getFields Method lightning controller method code coverage
	@isTest
    static void myUnitTest_getFields() {
        
        String sObjectName = 'Product2'; 
        String fieldSetName = 'AddProductsFieldSet'; 
        
        User userObj = [select Id, Name from User where Profile.Name =: vEmployee AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account limit 1');
        List<AddOpportunityProductsController.FieldSetMember> fsml = new List<AddOpportunityProductsController.FieldSetMember>(); 
        Test.StartTest();
        //System.runAs(userObj) {
            fsml = AddOpportunityProductsController.getFields(sObjectName, fieldSetName); 
            System.assertEquals('Name', fsml[0].fieldPath);    
        //}
        Test.StopTest();
    }
    
    
    
    //Method lightning controller method code coverage
	@isTest
    static void myUnitTest_displayMethods() {
        
        User userObj = [select Id, Name from User where Profile.Name =: vEmployee AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account limit 1');
        
        Test.StartTest();
        //System.runAs(userObj) {
            //Inserting new test product2
            
            sObject sObj = new Product2(Name = 'TV 2000');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Data Transformation');
            UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'NA');
        UtilityTestData.mProduct2Data.put('Offering_type__c', 'Fee');
            UtilityTestData.mProduct2Data.put('Forecastable__c', 'True');
            UtilityTestData.mProduct2Data.put('IsActive', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lProduct.size(), 1);
            
            //create/ standard Pricebook1
            Id priceBookId  = Test.getStandardPricebookId();
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Rejected');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
            UtilityTestData.mOpportunityData.put('Pricebook2Id', priceBookId );
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '100');     
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');     
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            String rid2 = lOpportunityPrimary[0].Id;
            List<OpportunityLineItem> oppProdsLst = new List<OpportunityLineItem>();
            
            List<AddOpportunityProductsController.DisplayOpportunityProducts> lstOppProdRecords2 = new List<AddOpportunityProductsController.DisplayOpportunityProducts>();
            List<PricebookEntry> lstPriceBookEntry = new  List<PricebookEntry>();
            
            AddOpportunityProductsController.DisplayOpportunityProducts obj3 = new AddOpportunityProductsController.DisplayOpportunityProducts();
            obj3.salesPrice = 100.0;
            obj3.PriceBookEnteryId = priceBookId;
            obj3.changedPrice=50.0;
            obj3.prodName='TV';
            obj3.prodFamily='DI';
            obj3.prodId=lProduct[0].Id;
            obj3.prodProducts='Data Transformation';
            
            lstOppProdRecords2.add(obj3);
            
            String oppProdRecords2 = JSON.serialize(lstOppProdRecords2);
            
            for(AddOpportunityProductsController.DisplayOpportunityProducts objOppProdRecords:lstOppProdRecords2){
                PricebookEntry price = new PricebookEntry(
                    UseStandardPrice = false,
                    Pricebook2Id = priceBookId,
                    UnitPrice = objOppProdRecords.salesPrice,
                    IsActive = true,
                    Product2Id = objOppProdRecords.prodId); 
                
                lstPriceBookEntry.add(price);
            } 
        //}
        Test.StopTest();
    }
}