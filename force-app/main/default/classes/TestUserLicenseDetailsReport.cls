/****************************************************************************************************************
Class:          TestUserLicenseDetailsReport 
@Author:        Rupesh
@Created Date:   5/29/2018 
@Description:    Test Class for UserLicenseDetailsReport

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Mohammed Anies      25th July 2022                    Karthik Thitte      Test class updated to include pending license request and using name column for MPLs


************************************************************************************************************************************************************
******************************************************************************************************************/
@isTest
public class TestUserLicenseDetailsReport {
        
        @TestSetup
    static void setupTestData(){
        Profile pr = [select ID,Name from Profile where name = 'Employee'];
        sObject sObj = new User();
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User>  lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj});

            User_Provisioning_Request__c userProvisioning = new User_Provisioning_Request__c();
        userProvisioning.User__c = lUser[0].Id;
        userProvisioning.Incident__c = 'test#';
        userProvisioning.Business_Justification__c = 'Test Business justification';
        userProvisioning.Business_Role__c = 'IPS Associate Consultant';
        userProvisioning.Dev_Add_Ons__c = 'Altify Normal User;CPQ Quote;Einstein Activity Capture/Inbox;Altify Normal User;CPQ Quote;Einstein Activity Capture/Inbox';

        insert userProvisioning;
    }
   
    @isTest
    private static void testmethod2(){
        Test.startTest();
        User_Provisioning_Request__c userProvisioning = [SELECT Id,Pending_Permission_Assignment__c FROM User_Provisioning_Request__c LIMIT 1];
        UserProvisioningHandler.createAddOnRequests(userProvisioning.Id);
            EmailTemplate template = [Select id from EmailTemplate where name = 'UserLicensereporttemplate'];
            UserLicenseDetailsReport  emailSch = new UserLicenseDetailsReport ();
            //emailSch.sendmail();
            String sch = '0 0 23 * * ?'; 
            System.schedule('Test Territory Check', sch, emailSch); 
        Test.stopTest(); 
    }
  }