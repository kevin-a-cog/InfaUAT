/*
 * Name         :   GlobalRecordCompletionTest
 * Author       :   Monserrat Pedroza
 * Created Date :   8/11/2021
 * Description  :   Iframe Viewer test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      8/11/2021       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalRecordCompletionTest {
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        //Now we create a Plan.
        Plan__c objPlan = new Plan__c();
        objPlan.Name = 'Test';
        //objPlan.Description__c = 'Test';
        objPlan.Sub_Stage__c = 'On-board';
        objPlan.Plan_Operational_Model__c = 'Digital';//added this line as test class is failing
        insert objPlan;
    }
    
    /*
     Method Name : testRecordScoring
     Description : Testing scoring records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testRecordScoring() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];

            //Now we test the method.
            Test.startTest();
            System.assertNotEquals(GlobalRecordCompletionController.getRecordScoring(objPlan.Id) == null, true, 'Unable to score record.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        return objTestUser;
    }
}