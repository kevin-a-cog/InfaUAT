/*
Class:          ProductOptionTriggerHandlerTest
@Author:        Ramya Ravi
@Created Date:  27/10/2020
@Description:   test class for ProductOptionTriggerHandler
Change History   
******************************************************************
*/
@isTest
public class ProductOptionTriggerHandlerTest {
       
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
  /*
Below methods are covering the class
*/
    @isTest
    static void myUnitTest_PO_InsertUpdate() 
    {
         
        //Creating multiple Product2 records
        sObject sObj = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X1');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('Package__c', 'True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);        
        sObject sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X2');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
         UtilityTestData.mProduct2Data.put('Package__c', 'True');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);         
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        System.assertEquals(lProduct.size(), 2);       
        SBQQ__ProductFeature__c prodfeature = new SBQQ__ProductFeature__c(SBQQ__ConfiguredSKU__c= lProduct[0].id, SBQQ__Number__c=1, SBQQ__MinOptionCount__c = 1, Name = 'Allocation');
        insert prodfeature;
        list<SBQQ__ProductOption__c> polist = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c sObjPO = new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c= lProduct[0].id , SBQQ__OptionalSKU__c= lProduct[0].id ,SBQQ__Number__c =1,Is_Child__c =true, Percentage_Allocation__c = 10,SBQQ__Feature__c = prodfeature.id );           
        //insert sObjPO;
        polist.add(sObjPO);
        SBQQ__ProductOption__c sObjPO1 = new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c= lProduct[0].id , SBQQ__OptionalSKU__c= lProduct[0].id ,SBQQ__Number__c =1,Is_Child__c =true, Percentage_Allocation__c = 80, SBQQ__Feature__c =prodfeature.Id );           
        //insert sObjPO1;
        polist.add(sObjPO1);
        insert polist;
        sObjPO.Percentage_Allocation__c = 5;
        upsert sObjPO;  
        delete sObjPO;
    }
}