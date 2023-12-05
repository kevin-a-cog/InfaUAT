/*
Class:          DealRegistrationAddProductsHandlerTest
@Author:        Deloitte
@Created Date:  06/07/2018
@Description:   test class for DealRegistrationAddProductsHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest
public class DealRegistrationAddProductsHandlerTest {
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();	
	@testSetup
    static void setupObjectTestData() {
        
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        
        List<Account> accountList = new List<Account>();
        
            //create reseller partner account	           
            Account partnerDistiAcc = new Account(Partner_Type__c = 'Software Reseller',RecordTypeId = AccRecTypeId_PrtnrAccnt,
                                                  PAL_PO_Completed__c = true,Payment_Terms__c ='Net 60',
                                                  Contract_Signed__c = true, FCPA_Status__c='Compliant',
                                                  Year_Founded__c= '2017', Vertical_Focus__c='Healthcare',
                                                  Geographic_Area__c='North America',NumberOfEmployees=1,
                                                  Email_Domain__c='PRM Test',Name = 'Test Account',
                                                  BillingCountry = 'India',BillingStreet = '298 S. Ringo Street', 
                                                  BillingState = 'AR', BillingPostalCode = '72201'
                                                 );	
            
            //Add all accounts to acclist
        system.runAs(adminUser)	
        {	
            accountList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerDistiAcc}); 
        }
        
        Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
        //create lead
        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert116');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
        UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
        UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
        UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
        UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
        UtilityTestData.mLeadData.put('Status','New');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test ');
        UtilityTestData.mLeadData.put('Email','LeadConvert116@testr.q');
        UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
        UtilityTestData.mLeadData.put('Country','United States');
        UtilityTestData.mLeadData.put('FirstName','LeadConvert112');
        UtilityTestData.mLeadData.put('FirstName','LeadConvert112');
        UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accountList[0].Id);
        
        sObject lead = new Lead();
        system.runAs(adminUser)
        {
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        }
        
        //create lead
        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert117');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
        UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
        UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
        UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
        UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
        UtilityTestData.mLeadData.put('Status','New');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test ');
        UtilityTestData.mLeadData.put('Email','LeadConvert116@testr.q');
        UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
        UtilityTestData.mLeadData.put('Country','United States');
        UtilityTestData.mLeadData.put('FirstName','LeadConvert112');
        UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accountList[0].Id);
        
        sObject lead1 = new Lead();
        List<lead> leadList = new list<lead>();
        system.runAs(adminUser)
        {
            lead1 = UtilityTest.putFieldRecord(lead1, UtilityTestData.mLeadData);
            leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead1});
            
            //create ProductId
            //List<Product2> testProds = new List<Product2>();
            Product2 testProd = new Product2();
            testProd.name = 'Test Prod1';
            testProd.CurrencyIsoCode = 'USD';
            testProd.Offering_Type__c='Cloud Hosted Subscription';
            //testProds.add(testProd);
            insert testProd;
            
            //create Deal_Registration_Products__c
            
            //List<Deal_Registration_Products__c> testDealProds = new List<Deal_Registration_Products__c>();
            Deal_Registration_Products__c drProd = new Deal_Registration_Products__c();
            drProd.Lead__c = leadList[1].id;
            drProd.Product__c = testProd.id;
            //testDealProds.add(drProd);
            insert drProd;
        }
        
        
    }
    
	// This test method covers SubmitStatusValidator method
    @isTest 
    public static void testSubmitStatusValidator(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			system.assertEquals(label.PRM_DealSubmit_Error,DealRegistrationAddProductsHandler.SubmitStatusValidator(String.valueOf(leadList[0].id)));
			system.assertEquals(label.PRM_Success_Message,DealRegistrationAddProductsHandler.SubmitStatusValidator(String.valueOf(leadList[1].id)));
			Lead toUpdateLead = leadList[0];
			toUpdateLead.status = 'Received';
			
			update toUpdateLead;
			system.assertEquals(label.PRM_DealRegistration_StatusValidationError,DealRegistrationAddProductsHandler.SubmitStatusValidator(String.valueOf(toUpdateLead.id)));
		}
    }
	
	// This test method covers StatusValidator method
    @isTest 
    public static void testStatusValidator(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			system.assertEquals(label.PRM_Success_Message,DealRegistrationAddProductsHandler.StatusValidator(String.valueOf(leadList[1].id)));
			Lead toUpdateLead = leadList[0];
			toUpdateLead.status = 'Received';
			
			update toUpdateLead;
			system.assertEquals(label.PRM_DealRegistration_StatusValidationError,DealRegistrationAddProductsHandler.StatusValidator(String.valueOf(toUpdateLead.id)));
		}
	}
	
	// This test method covers SubmitDealForApproval method
    @isTest 
    public static void testSubmitDealForApproval(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			system.assertEquals(label.PRM_Success_Message,DealRegistrationAddProductsHandler.SubmitDealForApproval(String.valueOf(leadList[1].id)));
			
			system.assertEquals(label.PRM_DealRegistration_StatusValidationError,DealRegistrationAddProductsHandler.StatusValidator(String.valueOf(leadList[1].id)));
		}
	}
	
	// This test method covers getFields method
    @isTest 
    public static void testgetFields(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			List<PRMProductHandlerUtility.FieldSetMember> fsmList = PRMProductHandlerUtility.getFieldDetails('Product2','AddProductsFieldSet');
			List<PRMProductHandlerUtility.FieldSetMember> resultList = DealRegistrationAddProductsHandler.getFields('Product2','AddProductsFieldSet');
			system.assertEquals(fsmList.size(),resultList.size());
		}
	}
	
	// This test method covers productSearchBar method
    @isTest 
    public static void testproductSearchBar(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			try
			{
				DealRegistrationAddProductsHandler.productSearchBar('test',null,'id');
			}
			catch(Exception e)
			{
				system.assertEquals(e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION'),true);
			}
		}
	}
	
	// This test method covers saveSelectedProducts method
    @isTest 
    public static void testsaveSelectedProducts(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		List<Deal_Registration_Products__c> drProduct = [select id from Deal_Registration_Products__c];
		List<Product2> prodList = [select id from Product2];
		system.runas(adminUser)
		{
			string result = DealRegistrationAddProductsHandler.saveSelectedProducts(JSON.serialize(drProduct),String.valueOf(leadList[1].id));
			system.assertEquals(result.contains('Product: id value of incorrect type'),true);
			system.assertEquals('Success',DealRegistrationAddProductsHandler.saveSelectedProducts(JSON.serialize(prodList),String.valueOf(leadList[1].id)));
		}
	}
	
	// This test method covers getSavedDealRegProducts method
    @isTest 
    public static void testgetSavedDealRegProducts(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		system.runas(adminUser)
		{
			List<Deal_Registration_Products__c> drProduct = DealRegistrationAddProductsHandler.getSavedDealRegProducts(String.valueOf(leadList[1].id));
			system.assertEquals(drProduct.size(),1);
		}
	}
	
	// This test method covers deleteSavedDealRegProducts method
    @isTest 
    public static void testdeleteSavedDealRegProducts(){
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
		List<Lead> leadList  = [select id from lead];
		List<Deal_Registration_Products__c> drProduct = [select id from Deal_Registration_Products__c];
		List<String> drProductString = new List<String>();
		drProductString.add(drProduct[0].id);
		system.runas(adminUser)
		{
			system.assertEquals('Success',DealRegistrationAddProductsHandler.deleteSavedDealRegProducts(drProductString,String.valueOf(leadList[1].id)));
		}
	}
}