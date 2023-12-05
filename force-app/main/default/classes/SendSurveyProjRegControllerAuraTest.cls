/*
Class:          SendSurveyProjRegControllerAuraTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for SendSurveyProjRegControllerAura

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
public class SendSurveyProjRegControllerAuraTest {
    
    @testSetup
    static void setupObjectTestData() {
			List<User> userList = UtilityTest.createUsersforPRM();
			List<Account> accList = UtilityTest.createAccountforPRM();
			List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
			User adminUser = userList[0];
			User sogUser = userList[1];
			User psmUser = userList[2];
    }
    //this test method helps in validating if the logged in user has permission set of PSG.
    @isTest 
    public static void testMethodPSMCheck(){
        
        List<String> usernamesList = new list<String> { 'mtest3@m.t' , 'prmTestSog@m.t'};
        List<User> userList = [select id,username from user where username In :usernamesList];
        System.runAs(userList[0]) {
            
            
            
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Test Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','United States');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','Florida');
            
            // Initialize a Project Reg sobject
        	sObject projReg1 = new Project_Registration__c();
        	projReg1 = UtilityTest.putFieldRecord(projReg1, UtilityTestData.mProjectRegistrationData);
            
            
        	List<Project_Registration__c> projRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{projReg1});
            
            projRegList[0].Status__c = 'Complete - Send Survey';
            projRegList[0].Project_Go_Live_Date__c = System.Today()-1;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(new List<sObject>{projRegList[0]});
            
        }
        System.runAs(userList[1]) {
            List<Project_Registration__c> ProjRegListSog = [select id from Project_Registration__c Limit 1];
        	Test.startTest();
            string result = SendSurveyProjRegControllerAura.SendSurveyProjRegPostValidation(ProjRegListSog[0].Id);
            system.assertEquals(result, 'Success');
            Test.stopTest();
        }
    }
    /* this test method helps in validating if the status of the Project Reg is Complete - Send Survey
    * before proceeding to send survey and to fetch the Project Registration fields which are used for 
	* validation checks before proceeding to send survey.*/
    @isTest 
    public static void testMethodStatusCheck(){
       
        List<String> usernamesList = new list<String> { 'mtest3@m.t' , 'mtestpsm@m.t'};
        List<User> userList = [select id,username from user where username In :usernamesList];
        
        System.runAs(userList[0]) {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Test Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','United States');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','Florida');
            
            // Initialize a Project Reg sobject
        	sObject projReg1 = new Project_Registration__c();
        	projReg1 = UtilityTest.putFieldRecord(projReg1, UtilityTestData.mProjectRegistrationData);
            
            
        	List<Project_Registration__c> projRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{projReg1});
            
            projRegList[0].Status__c = 'Complete - Send Survey';
            projRegList[0].Project_Go_Live_Date__c = System.Today()-1;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(new List<sObject>{projRegList[0]});
            
        }
        
        System.runAs(userList[1]) {
           
            List<Project_Registration__c> ProjRegListSog = [select id from Project_Registration__c Limit 1];
        	Test.startTest();
            string result = SendSurveyProjRegControllerAura.SendSurveyProjRegPostValidation(ProjRegListSog[0].Id);
            
            system.assertEquals(result, 'user access issue');
            Test.stopTest();
        }
    }
    /* this test method is used to fetch the Project Registration fields which are used for 
	* validation checks before proceeding to send survey.*/
    @isTest 
    public static void testMethodValCheck(){
       
        List<String> usernamesList = new list<String> { 'mtest3@m.t' , 'prmTestSog@m.t'};
        List<User> userList = [select id,username from user where username In :usernamesList];
        
        System.runAs(userList[0]) {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Test Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','United States');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','Florida');
            
            // Initialize a Project Reg sobject
        	sObject projReg1 = new Project_Registration__c();
        	projReg1 = UtilityTest.putFieldRecord(projReg1, UtilityTestData.mProjectRegistrationData);
            
            
        	List<Project_Registration__c> projRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{projReg1});
            
            projRegList[0].Status__c = 'Complete - Do not Send Survey';
            projRegList[0].Project_Go_Live_Date__c = System.Today()-1;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(new List<sObject>{projRegList[0]});
            
        }
        System.runAs(userList[1]) {
            List<Project_Registration__c> ProjRegListSog = [select id from Project_Registration__c Limit 1];
        	Test.startTest();
            string result = SendSurveyProjRegControllerAura.SendSurveyProjRegPostValidation(ProjRegListSog[0].Id);
            system.assertEquals(result, 'Project Reg Not Send Survey');
            Test.stopTest();
        }
    }
    /* SendSurveyProjRegPostValidation method is referenced in SendSurveyProjRegController Lightning cmp.
    * this test method is used to check if validations are all met for the Project Registration inorder to send survey.*/
    @isTest 
    public static void testMethodValCheck1(){
        
        List<String> usernamesList = new list<String> { 'mtest3@m.t' , 'prmTestSog@m.t'};
        List<User> userList = [select id,username from user where username In :usernamesList];
        
        
        System.runAs(userList[0]) {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Test Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','United States');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','Florida');
            UtilityTestData.mProjectRegistrationData.put('Customer_Contact_Email__c','');
            // Initialize a Project Reg sobject
        	sObject projReg1 = new Project_Registration__c();
        	projReg1 = UtilityTest.putFieldRecord(projReg1, UtilityTestData.mProjectRegistrationData);
            
            
        	List<Project_Registration__c> projRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{projReg1});
            
            projRegList[0].Status__c = 'Complete - Send Survey';
            projRegList[0].Project_Go_Live_Date__c = System.Today()-1;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(new List<sObject>{projRegList[0]});
            
        }
        System.runAs(userList[1]) {
            List<Project_Registration__c> ProjRegListSog = [select id from Project_Registration__c Limit 1];
        	Test.startTest();
            string result = SendSurveyProjRegControllerAura.SendSurveyProjRegPostValidation(ProjRegListSog[0].Id);
            system.assertEquals(result, 'customer email null');
            Test.stopTest();
        }
    }
    /* SendSurveyProjRegPostValidation method is referenced in SendSurveyProjRegController Lightning cmp.
    * this test method is used to check if validations are all met for the Project Registration inorder to send survey.*/
    @isTest 
    public static void testMethodValCheck2(){

        List<String> usernamesList = new list<String> { 'mtest3@m.t' , 'prmTestSog@m.t' , 'prmTestAdmn@m.t' };
        List<User> userList = [select id,username from user where username In :usernamesList];
        
        System.runAs(userList[0]) {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Test Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','United States');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','Florida');
            UtilityTestData.mProjectRegistrationData.put('Customer_Contact_Email__c','');
            // Initialize a Project Reg sobject
        	sObject projReg1 = new Project_Registration__c();
        	projReg1 = UtilityTest.putFieldRecord(projReg1, UtilityTestData.mProjectRegistrationData);
            
            
        	List<Project_Registration__c> projRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{projReg1});
            
            projRegList[0].Status__c = 'Complete - Send Survey';
            projRegList[0].Project_Go_Live_Date__c = System.Today()-1;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(new List<sObject>{projRegList[0]});
            
           
            System.runAs(userList[1]) {
            
            	UtilityTestData.mEvaluationData.put('Project_Registration__c',upProjRegList[0].Id+'');
            	UtilityTestData.mEvaluationData.put('Status__c','Survey Sent');
            	sObject eval1 = new Evaluation__c();
            
        		eval1 = UtilityTest.putFieldRecord(eval1, UtilityTestData.mEvaluationData);
            
            	List<Evaluation__c> evalList = (List<Evaluation__c>) UtilityTest.makeInsert(new List<sObject>{eval1});
            }            
        }
        System.runAs(userList[2]) {
            List<Project_Registration__c> ProjRegListSog = [select id from Project_Registration__c Limit 1];
        	Test.startTest();
            string result = SendSurveyProjRegControllerAura.SendSurveyProjRegPostValidation(ProjRegListSog[0].Id);
            system.assertEquals(result, 'duplicate issue');
            Test.stopTest();
        }
    }
}