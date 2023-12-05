/*
Class:          AccountFCPAExpirationDateCalculatorTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for AccountFCPAExpirationDateCalculator

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
public class AccountFCPAExpirationDateCalculatorTest {
	
	static Id AccRecTypeId_PrtnrAccnt = [SELECT id FROM RecordType where SObjectType='Account' and DeveloperName='Partner_Account'].id;
    
    @testSetup
    static void setupObjectTestData() {
        List<User> userList = UtilityTest.createUsersforPRM();
    }
    
    //This method creates data to invoke process builder named 'Account_Upsert' and updates the FCPA expiration date.      
    
    @isTest 
    public static void setFCPAExpirationDateTestInsert(){
        
		User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        Integer NoOfMonths;
        List<Account> accList;
        
        system.runAs(sogUser){ 
        	//create reseller partner account
        	UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
			UtilityTestData.mAccountData.put('Name','test Account FCPA 1');
        	UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
        	UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
        	UtilityTestData.mAccountData.put('Contract_Signed__c','true');
        	UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
        	UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
        	UtilityTestData.mAccountData.put('Year_Founded__c','2017');
        	UtilityTestData.mAccountData.put('FCPA_Status__c','Compliant');
        	UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
        	UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
        	UtilityTestData.mAccountData.put('NumberOfEmployees','1');
        	UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
        	UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
        	sObject partnerAcc1 = new Account();
        	partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);
			
            
			//Add all accounts to acclist
			accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1});
        
		
			List<PRM_Custom_Data_Settings__mdt> PRM_Custom_Data_No_Of_Days = new List<PRM_Custom_Data_Settings__mdt>();   
			//Get the number of months after the FCPA Expiration Date need to be set after the record creation
			PRM_Custom_Data_No_Of_Days = [SELECT No_Of_Days_After_Program_Expires__c from PRM_Custom_Data_Settings__mdt where No_Of_Days_After_Program_Expires__c <> null limit 1];        
			if(PRM_Custom_Data_No_Of_Days != null && !PRM_Custom_Data_No_Of_Days.isEmpty())
			{
				NoOfMonths = (Integer)PRM_Custom_Data_No_Of_Days[0].No_Of_Days_After_Program_Expires__c;
			}
			Account acc  = [select Id,FCPA_Expiration_Date__c from Account];
			System.assertEquals(acc.FCPA_Expiration_Date__c, system.today().addMonths(NoOfMonths));
        }
    }
    
    //This method covers an exception that may occur due to data       
    @isTest 
    public static void setFCPAExpirationDateTestUpdate(){
        Test.startTest();
		User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        try{
			
			//create reselller partner account
			UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
			UtilityTestData.mAccountData.put('Name','test Account FCPA 2');
			UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
			UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
			UtilityTestData.mAccountData.put('Contract_Signed__c','true');
			UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
			UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
			UtilityTestData.mAccountData.put('Year_Founded__c','2017');
			UtilityTestData.mAccountData.put('FCPA_Status__c','Non-Compliant');
			UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
			UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
			UtilityTestData.mAccountData.put('NumberOfEmployees','1');
			UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
			UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
			sObject partnerAcc1 = new Account();
			partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);
        
			//Add all accounts to acclist
			List<Account> accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1});
            system.assert(accList[0].Id!=null,'The record not inserted');

			//Update Account    
			system.runAs(sogUser){
				Account TypeCastAcc = (Account)accList[0];
				TypeCastAcc.FCPA_Status__c = 'Compliant'; 
				UtilityTest.makeUpdate(new list<sObject>{TypeCastAcc});
			}
			Account acc  = [select Id,FCPA_Expiration_Date__c from Account];
			
			List<PRM_Custom_Data_Settings__mdt> PRM_Custom_Data_No_Of_Days = new List<PRM_Custom_Data_Settings__mdt>();
			Integer NoOfMonths;    
			//Get the number of months after the FCPA Expiration Date need to be set after the record creation
			PRM_Custom_Data_No_Of_Days = [SELECT No_Of_Days_After_Program_Expires__c from PRM_Custom_Data_Settings__mdt where No_Of_Days_After_Program_Expires__c <> null limit 1];        
			if(PRM_Custom_Data_No_Of_Days != null && !PRM_Custom_Data_No_Of_Days.isEmpty())
			{
				NoOfMonths = (Integer)PRM_Custom_Data_No_Of_Days[0].No_Of_Days_After_Program_Expires__c;
			}
			System.assertEquals(acc.FCPA_Expiration_Date__c.year(), system.today().addMonths(NoOfMonths).year());
        }
        catch(Exception e){}
        Test.stopTest();
    }
}