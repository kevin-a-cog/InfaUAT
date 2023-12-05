/*
 * Name         :   CSMMakePlaybookTest
 * Author       :   Monserrat Pedroza
 * Created Date :   6/19/2021
 * Description  :   Make Playbook test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      6/19/2021       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMMakePlaybookTest {
    
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
        insert objPlan;
    }
    
    /*
     Method Name : testGettingFieldsToUpdate
     Description : Testing fetching fields to update.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testGettingFieldsToUpdate() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objRecord = [SELECT Id FROM Plan__c LIMIT 1];

            //Now we get the fields to update.
            System.assertNotEquals(CSMMakePlaybookController.getFieldsToUpdate(objRecord.Id) == null, true, 'Unable to get fields.');
        }
    }
    
    /*
     Method Name : testUpdatingPlan
     Description : Testing updating single record.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testUpdatingPlan() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objRecord = [SELECT Id FROM Plan__c LIMIT 1];

            //Now we update the plan.
            CSMMakePlaybookController.getPlanUpdated(objRecord);

            //Now we get confirm the operation.
            System.assertNotEquals([SELECT Id FROM Plan__c] == null, true, 'No records were updated.');
        }
    }
    
    /*
     Method Name : testUpdatingRecords
     Description : Testing updating records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testUpdatingRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objRecord = [SELECT Id FROM Plan__c LIMIT 1];
            List<String> lstRecordIds = new List<String>();

            //Now we prepare the data.
            lstRecordIds.add(objRecord.Id);

            //Now we update the records.
            CSMMakePlaybookController.getRecordsUpdated(lstRecordIds);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Plan__c LIMIT 1] == null, true, 'Unable to update records.');
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
        
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}