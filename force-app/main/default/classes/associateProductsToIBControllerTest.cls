/****************************************************************************************************************
Class:          associateProductsToIBControllerTest
@Author:        chandana gowda
@Created Date:  9/4/2019.
@Description:   Class for Testing the controller of the lightning component associateProductsToIB
******************************************************************************************************************
Change History 
*******************************************************************************************************************/
@isTest
public with sharing class associateProductsToIBControllerTest {
    
    //Setting up the data necessary for testing
    @testSetup
    static void setupObjectTestData() {

        sObject sObj1 = new InstallBase__c();
        UtilityTestData.mInstallBase.put('Name', 'Test Install Base 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mInstallBase);
        List<InstallBase__c> lInstallBase = (List<InstallBase__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});

        UtilityTestData.mProductData.put('Name','PowerExchange for Cassandra data type per consecutive month Test');
        UtilityTestData.mProductData.put('CurrencyIsoCode','USD');
        UtilityTestData.mProductData.put('Family','DI');
        UtilityTestData.mProductData.put('Product_Family__c','DI');
        UtilityTestData.mProductData.put('Forecast_Product__c','Cloud Application Integration');
        UtilityTestData.mProductData.put('Business_Unit__c','Address Doctor');
        UtilityTestData.mProductData.put('Forecastable__c','true');
        UtilityTestData.mProductData.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProductData.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mProductData.put('IsActive','true');
        sObject prod1 = new Product2();
        prod1 = UtilityTest.putFieldRecord(prod1, UtilityTestData.mProductData);
                
        UtilityTestData.mProductData.put('Name','Data Integration Hub Test');
        UtilityTestData.mProductData.put('CurrencyIsoCode','USD');
        UtilityTestData.mProductData.put('Family','Cloud Subscription');
        UtilityTestData.mProductData.put('Product_Family__c','DI');
        UtilityTestData.mProductData.put('Forecast_Product__c','Cloud Application Integration');
        UtilityTestData.mProductData.put('Business_Unit__c','Address Doctor');
        UtilityTestData.mProductData.put('Forecastable__c','true');
        UtilityTestData.mProductData.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProductData.put('Delivery_Method__c','NA');
        UtilityTestData.mProductData.put('IsActive','true');
        //UtilityTestData.mProductData.put('Orderable__c','true');
        sObject prod2 = new Product2();
        prod2 = UtilityTest.putFieldRecord(prod2, UtilityTestData.mProductData);
                
        UtilityTestData.mProductData.put('Name','Big Data Management');
        UtilityTestData.mProductData.put('Product_Family__c','DI');
        UtilityTestData.mProductData.put('Forecast_Product__c','Cloud Application Integration');
        UtilityTestData.mProductData.put('Business_Unit__c','Address Doctor');
        sObject prod3 = new Product2();
        prod3 = UtilityTest.putFieldRecord(prod3, UtilityTestData.mProductData);
                
        List<Product2> prodList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{prod1,prod2,prod3});
        
        sObject sObj2 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[0].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',prodList[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mInstallBaseMapping);

        sObject sObj3 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[0].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',prodList[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mInstallBaseMapping);

        /*sObject sObj4 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[0].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',prodList[2].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mInstallBaseMapping); */                

        List<InstallBase_Mapping__c> lInstallBaseMapping = (List<InstallBase_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj2,sObj3});        
    }

    //Method to test the retrival of products available for association with installBase
    static @IsTest void testgetProducts(){

        Test.startTest();

            associateProductsToIBController.getPicklistValues();
            Map<String,String> fields=associateProductsToIBController.getFields();
            InstallBase__c linstallBase=[SELECT Id FROM InstallBase__c LIMIT 1];

            String searchKeyword='Big';
            String forecastProduct='Cloud Application Integration';
            String productFamily='DI';
            String addOnCountry='';
            String addOnCategory='';
            String businessUnit='Address Doctor';
            List<String> queryfields=fields.values();
            String installBase=String.valueOf(linstallBase.Id);
            List<sObject> pillsList=new List<sObject>();
            List<Product2> lProduct=associateProductsToIBController.getProducts(searchKeyword,forecastProduct,productFamily,addOnCountry,addOnCategory,businessUnit,queryfields,installBase,pillsList);        
            System.assertEquals(1, lProduct.size());
        Test.stopTest();

    }

    //Method to test the saving of install Base Mapping records
    static @IsTest void testSaveIBMapping(){

        InstallBase__c linstallBase=[SELECT Id FROM InstallBase__c LIMIT 1];
        Product2 product=[SELECT Id FROM Product2 LIMIT 1];
        InstallBase_Mapping__c ibMapping= new InstallBase_Mapping__c();
        ibMapping.Install_Base__c = linstallBase.Id;
        ibMapping.Product__c = product.Id;
        
        Test.startTest();
            associateProductsToIBController.insertinstallBaseMapping(new List<InstallBase_Mapping__c>{ibMapping});    
        Test.stopTest();        
    }          
}