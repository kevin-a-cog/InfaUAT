/****************************************************************************************************************************
 *  @Class Name: ProductRequestFlowControllerTest
 *  @Author: Puneet
 *  @Date: 
 *  @Description: Test class for ProductRequestFlowController
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/
@IsTest
public class ProductRequestFlowControllerTest {
    
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    static Id ChannelProgramLevelRecTypeId = Schema.SObjectType.ChannelProgramLevel.RecordTypeInfosByName.get('AIR').RecordTypeId;
    
    @testSetup
    static void setupObjectTestData() 
	{
		List<User> userList = UtilityTest.createUsersforPRM();
		User adminUser = userList[0];
		User sogUser = userList[1];
		User psmUser = userList[2];
		
		List<Account> accList = UtilityTest.createAccountforPRM();
        system.runAs(adminUser)
		{
			/*------------------------------------------------Test Channel Program Creation Start---------------------------------------------------------*/
			//create ChannelProgram	  
			UtilityTestData.mChannelProgramData.put('Name','Test Channel Program');
			UtilityTestData.mChannelProgramData.put('Country__c','United States');
			sObject channelProgramObj = new ChannelProgram();
			channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
			
			//create ChannelProgram	  
			UtilityTestData.mChannelProgramData.put('Name','Test Channel Program 1');
			sObject channelProgramObj1 = new ChannelProgram();
			channelProgramObj1 = UtilityTest.putFieldRecord(channelProgramObj1, UtilityTestData.mChannelProgramData);
			
			List<ChannelProgram> channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj,channelProgramObj1});
			
			/*------------------------------------------------Test Channel Program Creation End---------------------------------------------------------*/
        
        
			/*------------------------------------------------Test Channel Program Level Creation Start---------------------------------------------------------*/
			//create ChannelProgramLevel
			Id ChannelProgramLevelRecTypeId = [SELECT id FROM RecordType where SObjectType='ChannelProgramLevel' and DeveloperName='AIR'].id;
			
			UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeId);
			UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');
			
			sObject channelProgramLevelObj = new ChannelProgramLevel();
			channelProgramLevelObj = UtilityTest.putFieldRecord(channelProgramLevelObj, UtilityTestData.mChannelProgramLevelData);
			
			List<ChannelProgramLevel> channelProgLevelList = (List<ChannelProgramLevel>) UtilityTest.makeInsert(new List<sObject>{channelProgramLevelObj});
			
			/*------------------------------------------------Test Channel Program Level Creation End---------------------------------------------------------*/
			
			
			/*------------------------------------------------Test Partner Program Creation Start---------------------------------------------------------*/
			//create partner program
        
			//Create partnerProgObj1 for accList[2].id
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId1);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c','VAD');
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[2].id + '');
			sObject partnerProgObj1 = new Partner_Program__c();
			partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
        
			//Create partnerProgObj1 for accList[1].id      
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
			UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
			UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
			UtilityTestData.mPartnerProgramData.put('Country__c','United States');
			UtilityTestData.mPartnerProgramData.put('Program_Status__c','Active');
			sObject partnerProgObj2 = new Partner_Program__c();
			partnerProgObj2 = UtilityTest.putFieldRecord(partnerProgObj2, UtilityTestData.mPartnerProgramData);
			
			//Create partnerProgObj1 for accList[2].id      
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c','ISV');
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
			sObject partnerProgObj3 = new Partner_Program__c();
			partnerProgObj3 = UtilityTest.putFieldRecord(partnerProgObj3, UtilityTestData.mPartnerProgramData);
			
			//Create partnerProgObj1 for accList[2].id      
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c',label.PRM_Prgrm_Type_OEM_Value);
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
			sObject partnerProgObj4 = new Partner_Program__c();
			partnerProgObj4 = UtilityTest.putFieldRecord(partnerProgObj4, UtilityTestData.mPartnerProgramData);
        
			//Create partnerProgObj1 for accList[1].id      
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
			UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
			UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
			UtilityTestData.mPartnerProgramData.put('Country__c','United States');
			UtilityTestData.mPartnerProgramData.put('Program_Status__c','Active');
			sObject partnerProgObj5 = new Partner_Program__c();
			partnerProgObj5 = UtilityTest.putFieldRecord(partnerProgObj5, UtilityTestData.mPartnerProgramData);
        
			List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj1,partnerProgObj2,partnerProgObj3,partnerProgObj4,partnerProgObj5});
			
        
			/*------------------------------------------------Test Partner Program Creation End---------------------------------------------------------*/
            
            //Create and Insert New Product Request
            UtilityTestData.mProductData.put('Name','PowerExchange for Adabas');   
            UtilityTestData.mProductData.put('PRM_Availability__c','true');
            UtilityTestData.mProductData.put('Delivery_Method__c','On Premise');
            sObject Prod1 = new Product2();
            Prod1 = UtilityTest.putFieldRecord(Prod1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProductData.put('Product_Family__c','DQ');
            UtilityTestData.mProductData.put('Name','PowerCenter Premium Edition - Real Time - Fast Clone');            
            sObject Prod2 = new Product2();
            Prod2 = UtilityTest.putFieldRecord(Prod2, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Product_Family__c','IPU');
            UtilityTestData.mProductData.put('Name','Cloud Data Integration - AWS');            
            sObject Prod3 = new Product2();
            Prod3 = UtilityTest.putFieldRecord(Prod3, UtilityTestData.mProductData);

            UtilityTestData.mProductData.put('Product_Family__c','MDM');
            UtilityTestData.mProductData.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProductData.put('Name','Cloud Data Integration - AWS');            
            sObject Prod4 = new Product2();
            Prod4 = UtilityTest.putFieldRecord(Prod4, UtilityTestData.mProductData);
            
            List<Product2> ProdList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{Prod1,Prod2,Prod3,Prod4});

            UtilityTestData.mEngagementData.put('Name','Test Product');
            UtilityTestData.mEngagementData.put('Status__c','Submitted');
            sObject EngagementObj = new Engagement__c();
            EngagementObj = UtilityTest.putFieldRecord(EngagementObj, UtilityTestData.mProductRequestData);
            List<Engagement__c> EngList = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{EngagementObj});

            UtilityTestData.mProductRequestData.put('Comments__c','PowerExchange for Adabas');
            UtilityTestData.mProductRequestData.put('Engagement__c',EngList[0].id);
            UtilityTestData.mProductRequestData.put('Product__c',ProdList[0].Id);
            UtilityTestData.mProductRequestData.put('Internal_Product_Family__c','MDM');
            Product_Request__c ProdReq = new Product_Request__c();
            ProdReq = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq, UtilityTestData.mProductRequestData);   

            UtilityTestData.mProductRequestData.put('Product__c',ProdList[1].Id);
            UtilityTestData.mProductRequestData.put('Internal_Product_Family__c','CDGC');
            Product_Request__c ProdReq2 = new Product_Request__c();
            ProdReq2 = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq2, UtilityTestData.mProductRequestData);

            UtilityTestData.mProductRequestData.put('Product__c',ProdList[2].Id);
            UtilityTestData.mProductRequestData.put('Internal_Product_Family__c','Cloud');
            Product_Request__c ProdReq3 = new Product_Request__c();
            ProdReq3 = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq3, UtilityTestData.mProductRequestData);

            UtilityTestData.mProductRequestData.put('Internal_Product_Family__c','OnPremise');
            UtilityTestData.mProductRequestData.put('Product__c',ProdList[3].Id);
            Product_Request__c ProdReq4 = new Product_Request__c();
            ProdReq4 = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq4, UtilityTestData.mProductRequestData);

            List<Product_Request__c> ProdReqList = (List<Product_Request__c>) UtilityTest.makeInsert(new List<sObject>{ProdReq,ProdReq2,ProdReq3,ProdReq4});
        }   
    }

    @IsTest
    private static void updateProductRequestsTest(){

        List<Id> productIds = new List<Id>();
        List<Product_Request__c> productRequests = [SELECT Id FROM Product_Request__c];
        
        for(Product_Request__c pr : productRequests){
            productIds.add(pr.Id);
        }

        Map<String,Object> values = new Map<String,Object>();
        values.put('Status__c','Rejected');
        values.put('Rejection_Reason__c','test');

        Test.startTest();

            Boolean finalVal = ProductRequestFlowController.updateProductRequests(productIds,values);
            System.assertEquals(finalVal, true,'updateProductRequestsTest failed');
            values.put('Status__c','Fulfilled');
            values.put('License_Key_Org_ID__c','Fulfilled');
            values.put('Fulfillment_Date__c', System.today() );
            try{
                finalVal = ProductRequestFlowController.updateProductRequests(productIds,values);    
            }
            catch(Exception e){}
            values.put('Fulfillment_Date__c', String.valueOf(System.today()) );
            finalVal = ProductRequestFlowController.updateProductRequests(productIds,values);
            System.assertEquals(finalVal, true,'updateProductRequestsTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void getProductsTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        Test.startTest();
            List<Product_Request__c> productRequests =  ProductRequestFlowController.retrieveMdmProducts(engg.Id);
            productRequests =  ProductRequestFlowController.retrieveCloudProducts(engg.Id);
            productRequests =  ProductRequestFlowController.retrieveCdgcProducts(engg.Id);
            productRequests =  ProductRequestFlowController.retrieveOnPremProducts(engg.Id);
        Test.stopTest();
    }

    @IsTest
    private static void getFieldsTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        Test.startTest();
            List<Object> fields =  ProductRequestFlowController.getFields('Product2','PRM_AddProductsFieldSet');
            System.assertEquals(fields.isEmpty(), false, 'getProductsTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void getPicklistValuesTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        Test.startTest();
            List<Object> fields =  ProductRequestFlowController.getPicklistValues('Engagement__c','Status__c');
            System.assertEquals(fields.isEmpty(), false, 'getPicklistValuesTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void getProductTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        Test.startTest();
            ProductRequestFlowController.ProductTableWrapper wrap = ProductRequestFlowController.getProducts('','Product_Family__c');
            System.assertEquals(wrap == null, false, 'getProductsTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void getMultipleProductsTest(){

        Map<String,String> productMap = new Map<String,String>();
        Test.startTest();
            productMap = ProductRequestFlowController.getMDMServices();
            System.assertEquals(productMap.isEmpty(), false, 'getMultipleProductsTest failed');
            
            productMap = ProductRequestFlowController.getCloudervices();
            System.assertEquals(productMap.isEmpty(), false, 'getMultipleProductsTest failed');

            productMap = ProductRequestFlowController.getCDGCServices();
            System.assertEquals(productMap.isEmpty(), false, 'getMultipleProductsTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void saveProductRequestTest(){

        List<Product2> prodList = [SELECT Id FROM Product2];

        Map<String,Object> finalMap = new Map<String,Object>();
        Map<String,Object> engagementValueMap = new Map<String,Object>();
        engagementValueMap.put('Name','Test');
        engagementValueMap.put('Are_you_working_on_Opportunity__c',true);
        engagementValueMap.put('Is_customer_in_a_CIS_country__c','No');
        engagementValueMap.put('How_will_this_software_be_used__c','');
        engagementValueMap.put('Customer_Name__c','Test');
        engagementValueMap.put('Comments__c','Test');
        engagementValueMap.put('Opportunity_Id__c','Test');
        engagementValueMap.put('Partner_in_Russia_or_Belarus__c',false);
        finalMap.put('engagement',engagementValueMap);

        List<Object> productList = new List<Object>();
        Map<String,Object> productMap1 = new Map<String,Object>();
        productMap1.put('provisioningEnvironment','AWS-CAN');
        productMap1.put('prod',new Map<String,Object>{'Id' => prodList[0].Id, 'Name' => 'Cloud'});
        productMap1.put('trainingCompleted','Yes');
        productMap1.put('orgId','AWS-CAN');
        productMap1.put('renewLicense',true);
        productMap1.put('reqorproductversion','Test');
        productMap1.put('serialnumber','Test');
        productMap1.put('productFamily','Cloud');

        productList.add(productMap1);
        finalMap.put('products',productList);

        Test.startTest();
            
            String val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), true);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');

            Map<String,Object> productMap2 = new Map<String,Object>();
            productMap2.put('provisioningEnvironment','AWS-CAN');
            productMap2.put('prod',new Map<String,Object>{'Id' => prodList[1].Id, 'Name' => 'Mdm'});
            productMap2.put('trainingCompleted','Yes');
            productMap2.put('orgId','AWS-CAN');
            productMap2.put('renewLicense',true);
            productMap2.put('reqorproductversion','Test');
            productMap2.put('serialnumber','Test');
            productMap2.put('productFamily','MDM');

            Map<String,Object> productMap3 = new Map<String,Object>();
            productMap3.put('provisioningEnvironment','AWS-CAN');
            productMap3.put('prod',new Map<String,Object>{'Id' => prodList[2].Id, 'Name' => 'Mdm'});
            productMap3.put('trainingCompleted','Yes');
            productMap3.put('orgId','AWS-CAN');
            productMap3.put('renewLicense',true);
            productMap3.put('reqorproductversion','Test');
            productMap3.put('serialnumber','Test');
            productMap3.put('productFamily','MDM');

            productList = new List<Object>();
            productList.add(productMap1);
            productList.add(productMap2);
            productList.add(productMap3);
            finalMap.put('products',productList);

            val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), true);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void saveProductRequestTest2(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Product_Request__c> prods = [SELECT Id FROM Product_Request__c];
        List<Product2> prodList = [SELECT Id FROM Product2];

        Map<String,Object> finalMap = new Map<String,Object>();
        Map<String,Object> engagementValueMap = new Map<String,Object>();
        engagementValueMap.put('Name','Test');
        engagementValueMap.put('Are_you_working_on_Opportunity__c',true);
        engagementValueMap.put('Is_customer_in_a_CIS_country__c','Yes');
        engagementValueMap.put('How_will_this_software_be_used__c','');
        engagementValueMap.put('Customer_Name__c','Test');
        engagementValueMap.put('Comments__c','Test');
        engagementValueMap.put('Opportunity_Id__c','Test');
        engagementValueMap.put('Partner_in_Russia_or_Belarus__c',false);
        engagementValueMap.put('Id',engg.Id);
        finalMap.put('engagement',engagementValueMap);

        List<Object> productList = new List<Object>();
        Map<String,Object> productMap1 = new Map<String,Object>();
        productMap1.put('provisioningEnvironment','AWS-CAN');
        productMap1.put('prod',new Map<String,Object>{'Id' => prodList[0].Id, 'Name' => 'Cloud'});
        productMap1.put('trainingCompleted','Yes');
        productMap1.put('orgId','AWS-CAN');
        productMap1.put('renewLicense',true);
        productMap1.put('reqorproductversion','Test');
        productMap1.put('serialnumber','Test');
        productMap1.put('productFamily','Cloud');
        productMap1.put('Id',prods[0].Id);

        productList.add(productMap1);
        finalMap.put('products',productList);

        Test.startTest();
            
            String val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), true);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');

            Map<String,Object> productMap2 = new Map<String,Object>();
            productMap2.put('provisioningEnvironment','AWS-CAN');
            productMap2.put('prod',new Map<String,Object>{'Id' => prodList[1].Id, 'Name' => 'Mdm'});
            productMap2.put('trainingCompleted','Yes');
            productMap2.put('orgId','AWS-CAN');
            productMap2.put('renewLicense',true);
            productMap2.put('reqorproductversion','Test');
            productMap2.put('serialnumber','Test');
            productMap2.put('productFamily','MDM');

            Map<String,Object> productMap3 = new Map<String,Object>();
            productMap3.put('provisioningEnvironment','AWS-CAN');
            productMap3.put('prod',new Map<String,Object>{'Id' => prodList[2].Id, 'Name' => 'Mdm'});
            productMap3.put('trainingCompleted','Yes');
            productMap3.put('orgId','AWS-CAN');
            productMap3.put('renewLicense',true);
            productMap3.put('reqorproductversion','Test');
            productMap3.put('serialnumber','Test');
            productMap3.put('productFamily','MDM');

            productList = new List<Object>();
            productList.add(productMap1);
            productList.add(productMap2);
            productList.add(productMap3);
            finalMap.put('products',productList);

            val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), true);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');
        Test.stopTest();
    }

    @IsTest
    private static void saveProductRequestTest3(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Product_Request__c> prods = [SELECT Id FROM Product_Request__c];
        List<Product2> prodList = [SELECT Id FROM Product2];

        Map<String,Object> finalMap = new Map<String,Object>();
        Map<String,Object> engagementValueMap = new Map<String,Object>();
        engagementValueMap.put('Name','Test');
        engagementValueMap.put('Are_you_working_on_Opportunity__c',true);
        engagementValueMap.put('Is_customer_in_a_CIS_country__c','Yes');
        engagementValueMap.put('How_will_this_software_be_used__c','');
        engagementValueMap.put('Customer_Name__c','Test');
        engagementValueMap.put('Comments__c','Test');
        engagementValueMap.put('Opportunity_Id__c','Test');
        engagementValueMap.put('Partner_in_Russia_or_Belarus__c',false);
        engagementValueMap.put('Id',engg.Id);
        finalMap.put('engagement',engagementValueMap);

        List<Object> productList = new List<Object>();
        Map<String,Object> productMap1 = new Map<String,Object>();
        productMap1.put('provisioningEnvironment','AWS-CAN');
        productMap1.put('prod',new Map<String,Object>{'Id' => prodList[0].Id, 'Name' => 'Cloud'});
        productMap1.put('trainingCompleted','Yes');
        productMap1.put('orgId','AWS-CAN');
        productMap1.put('renewLicense',true);
        productMap1.put('reqorproductversion','Test');
        productMap1.put('serialnumber','Test');
        productMap1.put('productFamily','Cloud');
        productMap1.put('Id',prods[0].Id);

        productList.add(productMap1);
        finalMap.put('products',productList);

        Test.startTest();
            
            String val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), false);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');

            Map<String,Object> productMap2 = new Map<String,Object>();
            productMap2.put('provisioningEnvironment','AWS-CAN');
            productMap2.put('prod',new Map<String,Object>{'Id' => prodList[1].Id, 'Name' => 'Mdm'});
            productMap2.put('trainingCompleted','Yes');
            productMap2.put('orgId','AWS-CAN');
            productMap2.put('renewLicense',true);
            productMap2.put('reqorproductversion','Test');
            productMap2.put('serialnumber','Test');
            productMap2.put('productFamily','MDM');

            Map<String,Object> productMap3 = new Map<String,Object>();
            productMap3.put('provisioningEnvironment','AWS-CAN');
            productMap3.put('prod',new Map<String,Object>{'Id' => prodList[2].Id, 'Name' => 'Mdm'});
            productMap3.put('trainingCompleted','Yes');
            productMap3.put('orgId','AWS-CAN');
            productMap3.put('renewLicense',true);
            productMap3.put('reqorproductversion','Test');
            productMap3.put('serialnumber','Test');
            productMap3.put('productFamily','MDM');

            productList = new List<Object>();
            productList.add(productMap1);
            productList.add(productMap2);
            productList.add(productMap3);
            finalMap.put('products',productList);

            val = ProductRequestFlowController.saveProductRequest(JSON.serialize(finalMap), true);
            System.assertEquals(val != null, true, 'saveProductRequestTest failed');
        Test.stopTest();
    }

    @isTest
    private static void getDataForExistingRecordTest(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];

        Test.startTest();
            String retVal = ProductRequestFlowController.getDataForExistingRecord(engg.Id);
        Test.stopTest();

    }

    @isTest
    private static void getProductRequestsTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];

        Test.startTest();
            List<Product_Request__c> prodList = ProductRequestFlowController.getProductRequests(new Set<String>{engg.Id});
        Test.stopTest();
    }

    @isTest
    private static void updateEnagagementComplianceTest(){
        Engagement__c engg = [SELECT Id,RecordTypeId,Partner_in_Russia_or_Belarus__c,Status__c FROM Engagement__c LIMIT 1];
        engg.Partner_in_Russia_or_Belarus__c = true;

        update engg;

        Test.startTest();
            ProductRequestFlowController.updateEnagagementCompliance(new List<Engagement__c>{engg});
        Test.stopTest();
    }

    @isTest
    private static void productRequestUpdatesTest(){
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        
        Test.startTest();
            engg.Status__c = 'Compliance Rejected';
            update engg;
        Test.stopTest();
    }

}