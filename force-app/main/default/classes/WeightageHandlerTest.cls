/*
    @created by       : Venky K
    @created on       : 12/03/2021
    @Purpose          : Test class for 
    @Testclass        : WeightageHandler
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip			01/10/2023	I2RT-7593	T01		Increased code coverage
 
*/
@isTest
public class WeightageHandlerTest {
    
    @testSetup
    static void setupObjectTestData() {        
        sObject sObj;
        
        //create an TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
        
        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);//Email
        UtilityTestData.mContactData.put('Email','test@test.com');
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Entitlement
        Entitlement ent = new Entitlement(AccountId = lAccount[0].Id,Name = 'Signature Success',StartDate = System.today(), EndDate = system.today().addyears(3),Support_Level__c = 'Signature Success');
        insert ent;
        
        //create a Case record
        User u =[SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive = true LIMIT 1];

        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];

        sObj = new Case();
        //bj.put('Success_Offering__c', 'Basic Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Active VOS');
        sObj.put('Version__c', '10.1');
        sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'New');
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',rt1.Id);
        sObj.put('AccountId', lAccount[0].Id);        
        sObj.put('SlaStartDate',System.now());
        sObj.put('EntitlementId',ent.Id);
        sObj.put('IsStopped',false);
        //sObj.put('Automatic_closure_Date__c',System.now().addDays(20));
        //sObj.put('OwnerId',UserInfo.getUserId());
        sObj.put('OwnerId',u.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
       
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Case_Contact__c();        
       	sObj.put('Case__c', lCase[0].Id);
        sObj.put('Contact__c', lContact[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseContact);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //T01
        sObj = new Case_Team__c();        
       	sObj.put('Case__c', lCase[0].Id);
        sObj.put('User__c', UserInfo.getUserId());
        sObj.put('Role__c', 'CoOwner');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseTeam);
        UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    @isTest
    static void testAll(){
        Test.startTest();
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c,OwnerId From Case Limit 1];
        
        Weightage_Rating__c wr = new Weightage_Rating__c();
        wr.case__c = lCase[0].Id;
        insert wr;      
        
        Test.stopTest();
    }
}