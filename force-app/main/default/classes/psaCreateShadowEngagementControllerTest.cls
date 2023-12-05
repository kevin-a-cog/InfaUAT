@isTest
public class psaCreateShadowEngagementControllerTest {
    @testSetup
    static void setupObjectTestData() {
        //Create Account
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        User userObj = [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        Sobject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
         //Create Region 
         sObj = new pse__Region__c();
         UtilityTestData.mRegion.put('Name','Test Region-1');
         UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
         UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
         UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
         UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
         sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
         List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
        //Create Contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
        UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','true');
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
        UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');
        UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
        UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
        UtilityTestData.mContactData.put('psa_Employee_Type__c','Informatica-Non PS');            
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    @isTest
    private static void testLWCmethods(){
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        psaCreateShadowEngagementController.createShadowEngagement(conList[0].Id, 'Focus Area Experience', 'CAI','Upcoming (1 month)','test','test');
    }
}