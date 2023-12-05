/*
Class:          AuraPrdctReqAddPrdctsHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for PRMProductHandlerUtility

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
public class AuraPrdctReqAddPrdctsHandlerTest {
    
    @testSetup
    static void setupObjectTestData() {
		
		List<User> userList = UtilityTest.createUsersforPRM();
		List<Account> accList = UtilityTest.createAccountforPRM();
		List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
		User adminUser = userList[0];
		
        system.runAs(adminUser)
		{
        	UtilityTestData.mEngagementData.put('Name','Test Engagement');
        	UtilityTestData.mEngagementData.put('Status__c','Not Submitted');
        	sObject engmnt = new Engagement__c();
        	engmnt = UtilityTest.putFieldRecord(engmnt, UtilityTestData.mEngagementData);
        
        	UtilityTestData.mEngagementData.put('Name','Test Engagement1');
        	UtilityTestData.mEngagementData.put('Status__c','Fulfilled');
        	sObject engmnt1 = new Engagement__c();
        	engmnt1 = UtilityTest.putFieldRecord(engmnt1, UtilityTestData.mEngagementData);
        
        	system.runAs(prtnrUserList[0])
        	{ 
        		List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmnt});
        	}
        	system.runAs(adminUser)
        	{
            	List<Engagement__c> engmntListadmin = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmnt1});
        	}
        	
        	UtilityTestData.mProductData.put('Name','Big Data Management');
        	UtilityTestData.mProductData.put('CurrencyIsoCode','USD');
        	UtilityTestData.mProductData.put('PRM_Product_Family__c','Intelligent Big Data');
        	UtilityTestData.mProductData.put('PRM_Product_Sub_Family__c','Big Data Management');
        	UtilityTestData.mProductData.put('PRM_Products__c','Big Data Management');
        	UtilityTestData.mProductData.put('Forecastable__c','false');
        	UtilityTestData.mProductData.put('IsActive','true');
        	UtilityTestData.mProductData.put('Orderable__c','true');
        	sObject prod1 = new Product2();
        	prod1 = UtilityTest.putFieldRecord(prod1, UtilityTestData.mProductData);
        
        	UtilityTestData.mProductData.put('Name','PowerExchange for Adabas');
        	UtilityTestData.mProductData.put('PRM_Product_Family__c','Intelligent Data Integration');
        	UtilityTestData.mProductData.put('PRM_Product_Sub_Family__c','PowerExchange');
        	UtilityTestData.mProductData.put('PRM_Products__c','PowerExchange for Adabas');
        	sObject prod2 = new Product2();
        	prod2 = UtilityTest.putFieldRecord(prod2, UtilityTestData.mProductData);
        
        	List<Product2> prodList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{prod1,prod2});
        }
    }
    //This test method helps in returning the new Org Id generate URL to the Partners
    @isTest 
    public static void testMethodgetNewOrgIdURL(){
        AuraProductRequestAddProductsHandler.getDependentOptionsImpl('Product2','PRM_Product_Family__c','PRM_Product_Sub_Family__c');
        AuraProductRequestAddProductsHandler.getPicklistValues('Product2','PRM_Product_Family__c');
        AuraProductRequestAddProductsHandler.getFields('Product2', 'PRM_AddProductsFieldSet');
        AuraProductRequestAddProductsHandler.getNewOrgIdURL();
    }
    //This test method helps in validating the Engagement Status, if it's already 'Fulfilled' then blocks users from adding/removing products
    @isTest 
    public static void testMethodStatusValidator(){
        
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		User partnerUser = [select id from user where username = 'mtest@m.t' limit 1];
	
        List<Engagement__c> engmntList = [Select id,Name From Engagement__c];
        

        AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[0].Id));
		system.assertEquals(AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[0].Id)),'SUCCESS');
        
        system.runAs(partnerUser)
        {
            AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[0].Id));
			system.assertEquals(AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[0].Id)),'SUCCESS');
        }
        system.runAs(adminUser)
        {
            AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[1].Id));
			system.assertEquals(AuraProductRequestAddProductsHandler.StatusValidator(String.valueOf(engmntList[0].Id)),'SUCCESS');
        }
        
        
    }
    //this test method will fetch the products based on the selected value from the 'Products' picklist and will fetch the products based on the entered keyword in searchbar comparing with the 'Name' field
    @isTest 
    public static void testMethodproductSearch(){
        List<Product2> prodList = [select Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c,Id from Product2];
        string pillist = JSON.serialize(prodList);
		User partnerUser = [select id from user where username = 'mtest@m.t' limit 1];
        system.runAs(partnerUser)
        {
            AuraProductRequestAddProductsHandler.productSearchBar('Big Data Management' , pillist,'Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c');
			system.assertEquals(AuraProductRequestAddProductsHandler.productSearchBar('Big Data Management' , pillist,'Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c').size(),1);
            AuraProductRequestAddProductsHandler.searchProducts('Big Data Management' , pillist,'Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c');
			system.assertEquals(AuraProductRequestAddProductsHandler.searchProducts('Big Data Management' , pillist,'Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c').size(),1);
        }
    }
    /*this test method will Save the selected products to the Deal Registration Product Table,if 
    * they don't need additional data like IpAddress,HostNames etc, else navigates users to another screen asking to fill those additional details.*/
    
    @isTest 
    public static void testMethodsaveSelectedProducts(){
        List<Product2> prodList = [select Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c,Id from Product2];
        string pillist = JSON.serialize(prodList);
		User partnerUser = [select id from user where username = 'mtest@m.t' limit 1];
        List<Engagement__c> engmntList = [Select id,Name From Engagement__c];
        system.runAs(partnerUser)
        {
            AuraProductRequestAddProductsHandler.saveSelectedProducts(pillist,String.valueOf(engmntList[1].Id));
			system.assertEquals(AuraProductRequestAddProductsHandler.saveSelectedProducts(pillist,String.valueOf(engmntList[1].Id)).size(),2);
        }
    }
    
    // this test method will help in deleting the deal registration products from the selected product pilllist
    @isTest 
    public static void testMethoddeleteSavedProductRequests(){
        List<Product2> prodList = [select Name,PRM_Product_Family__c,PRM_Product_Sub_Family__c,PRM_Products__c,Id from Product2];
        string pillist = JSON.serialize(prodList);
		User partnerUser = [select id from user where username = 'mtest@m.t' limit 1];
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<PRMProductHandlerUtility> lstProductRecords = new List<PRMProductHandlerUtility>();
        
        system.runAs(partnerUser)
        {
            List<Engagement__c> engmntList = [Select id,Name From Engagement__c];

            lstProductRecords = AuraProductRequestAddProductsHandler.saveSelectedProducts(pillist,String.valueOf(engmntList[0].Id));
            string lstPRodJson = JSON.serialize(lstProductRecords);
            //To cover exception.
            AuraProductRequestAddProductsHandler.saveProductsWithAdditionalDetails(lstPRodJson,String.valueOf(engmntList[0].Id));
            system.assertEquals(AuraProductRequestAddProductsHandler.saveProductsWithAdditionalDetails(lstPRodJson,String.valueOf(engmntList[0].Id)),'Success');
            for(PRMProductHandlerUtility objProductRecords : lstProductRecords)
            {
                objProductRecords.ipAddress = '1212121212';
            }

            string lstPRodJson1 = JSON.serialize(lstProductRecords);

            AuraProductRequestAddProductsHandler.saveProductsWithAdditionalDetails(lstPRodJson1,String.valueOf(engmntList[0].Id));
			system.assertEquals(AuraProductRequestAddProductsHandler.saveProductsWithAdditionalDetails(lstPRodJson1,String.valueOf(engmntList[0].Id)),'Success');
            List<Product_Request__c> listToDelete = new List<Product_Request__c>();
            listToDelete = AuraProductRequestAddProductsHandler.getSavedProductRequests(String.valueOf(engmntList[0].Id));
        }
        system.runAs(adminUser)
        {
            List<String> prodReqToDelete = new List<String>();
            List<Engagement__c> engmntList = [Select id,Name From Engagement__c];
            List<Product_Request__c> listToDelete = new List<Product_Request__c>();
            listToDelete = AuraProductRequestAddProductsHandler.getSavedProductRequests(String.valueOf(engmntList[0].Id));
            for(Product_Request__c prodReq : listToDelete)
            {
                prodReqToDelete.add(prodReq.Id);
            }
            AuraProductRequestAddProductsHandler.deleteSavedProductRequests(prodReqToDelete,String.valueOf(engmntList[0].Id));
        }
    }
}