/****************************************************************************************************************************
 *  @Class Name: PRMProductTableControllerTest
 *  @Author: Puneet
 *  @Date: 
 *  @Description:This is a Test class for PRMProductTableController
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/
@IsTest
public class PRMProductTableControllerTest {
    
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
            sObject Prod1 = new Product2();
            Prod1 = UtilityTest.putFieldRecord(Prod1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name','PowerCenter Premium Edition - Real Time - Fast Clone');            
            sObject Prod2 = new Product2();
            Prod2 = UtilityTest.putFieldRecord(Prod2, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name','Cloud Data Integration - AWS');            
            sObject Prod3 = new Product2();
            Prod3 = UtilityTest.putFieldRecord(Prod3, UtilityTestData.mProductData);
            
            List<Product2> ProdList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{Prod1,Prod2,Prod3});

            UtilityTestData.mEngagementData.put('Name','Test Product');
            UtilityTestData.mEngagementData.put('Status__c','Submitted');
            sObject EngagementObj = new Engagement__c();
            EngagementObj = UtilityTest.putFieldRecord(EngagementObj, UtilityTestData.mProductRequestData);
            List<Engagement__c> EngList = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{EngagementObj});

            UtilityTestData.mProductRequestData.put('Comments__c','PowerExchange for Adabas');
            UtilityTestData.mProductRequestData.put('Engagement__c',EngList[0].id);
            UtilityTestData.mProductRequestData.put('Product__c',ProdList[0].Id);
            Product_Request__c ProdReq = new Product_Request__c();
            ProdReq = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq, UtilityTestData.mProductRequestData);   

            UtilityTestData.mProductRequestData.put('Product__c',ProdList[1].Id);
            Product_Request__c ProdReq2 = new Product_Request__c();
            ProdReq2 = (Product_Request__c) UtilityTest.putFieldRecord(ProdReq2, UtilityTestData.mProductRequestData);   

            List<Product_Request__c> ProdReqList = (List<Product_Request__c>) UtilityTest.makeInsert(new List<sObject>{ProdReq,ProdReq2});
        }
    }

    @IsTest
    private static void getproductsTest(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        PRMProductTableController controller = new PRMProductTableController();
        controller.engagementId = engg.Id;

        Test.startTest();
            List<Product_Request__c> productList = controller.getproducts();
            System.assertEquals(productList.isEmpty(), false, 'Products not found');
        Test.stopTest();
    }

    @IsTest
    private static void getmdmProductsTest(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        PRMProductTableController controller = new PRMProductTableController();
        controller.engagementId = engg.Id;

        Test.startTest();
            List<Product_Request__c> productList = controller.getmdmProducts();
            System.assertEquals(productList.isEmpty(), true, 'Products found');
        Test.stopTest();
    }

    @IsTest
    private static void getcdgcProductsTest(){

        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        PRMProductTableController controller = new PRMProductTableController();
        controller.engagementId = engg.Id;

        Test.startTest();
            List<Product_Request__c> productList = controller.getcdgcProducts();
            System.assertEquals(productList.isEmpty(), true, 'Products found');
        Test.stopTest();
    }

    @IsTest
    private static void getengagementTest(){
     
        Engagement__c engg = [SELECT Id FROM Engagement__c LIMIT 1];
        PRMProductTableController controller = new PRMProductTableController();
        controller.engagementId = engg.Id;

        Test.startTest();
            Engagement__c engagement = controller.getengagement();
            System.assertEquals(engagement.Product_Request_Number__c != null, true, 'Engagement not found');
        Test.stopTest();
    }
}