/*
Class:          ALTF_ContactInfluenceTriggerHandlerTest 
@Author:        Uday Gangula
@Created Date:  20-NOV-2021
@Description:   Apex Class on Altify Contact Influence Object.
*/
/*
Change History
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         20-NOV-2021     SALESRT-13318            To put all the Influenced and Influenced By contacts in format of string on the contact record        T<01>

*/

@isTest
public class ALTF_ContactInfluenceTriggerHandlerTest{
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData(){
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        sObject sObj3 = new Account();
        sObject sObj4 = new Account();
        sObject sObj5 = new Account();
        System.runAs(userObj){
            UtilityTestData.mAccountData.put('Name', 'Test Influence 1');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);             
            
            UtilityTestData.mAccountData.put('Name', 'Test Influence 2');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj1 = new Account();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData); 

            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            // Set all the required fields and dynamic ids in Map
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName', 'Kevin');
            UtilityTestData.mContactData.put('LastName', 'Ma');
            UtilityTestData.mContactData.put('Email', 'Test_01@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName', 'Carlos');
            UtilityTestData.mContactData.put('LastName', 'Calero');
            UtilityTestData.mContactData.put('Email', 'Test_02@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj1 = new Contact();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName', 'Dom');
            UtilityTestData.mContactData.put('LastName', 'Turnbull');
            UtilityTestData.mContactData.put('Email', 'Test_03@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj2 = new Contact();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);

            UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
            UtilityTestData.mContactData.put('FirstName', 'Matthew');
            UtilityTestData.mContactData.put('LastName', 'Horsley');
            UtilityTestData.mContactData.put('Email', 'Test_04@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj3 = new Contact();
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mContactData);       
            
            UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
            UtilityTestData.mContactData.put('FirstName', 'Amit');
            UtilityTestData.mContactData.put('LastName', 'con2');
            UtilityTestData.mContactData.put('Email', 'Test_05@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj4 = new Contact();
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mContactData);       
            
            UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
            UtilityTestData.mContactData.put('FirstName', 'Elmar');
            UtilityTestData.mContactData.put('LastName', 'Jansen');
            UtilityTestData.mContactData.put('Email', 'Test_06@gmail.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj5 = new Contact();
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mContactData);       

            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3, sObj4, sObj5});       
        }
        Test.stopTest();
    }
    
    @isTest
    static void ContactInfluenceTestProcess(){
        List<Contact> Contacts = new List<Contact>();
        Contacts=[Select Id,Name from Contact];

        List<ALTF__Contact_Influence__c> acis = new List<ALTF__Contact_Influence__c>();
        acis.add(new ALTF__Contact_Influence__c(ALTF__Influenced_Contact__c=Contacts[0].Id,ALTF__Influencing_Contact__c=Contacts[1].Id,ALTF__Type__c='Influence'));
        acis.add(new ALTF__Contact_Influence__c(ALTF__Influenced_Contact__c=Contacts[2].Id,ALTF__Influencing_Contact__c=Contacts[3].Id,ALTF__Type__c='Conflict'));
        acis.add(new ALTF__Contact_Influence__c(ALTF__Influenced_Contact__c=Contacts[4].Id,ALTF__Influencing_Contact__c=Contacts[5].Id,ALTF__Type__c='Conflict'));
        insert acis;
            
        List<Contact> existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[1].Id];
        System.AssertEquals(existingContacts[0].Altify_Influencing_Contacts__c,Contacts[0].Name+';');
        System.AssertEquals(existingContacts[0].Altify_Influencer__c ,true);
            
        existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[0].Id];
        System.AssertEquals(existingContacts[0].Altify_Influenced_by_Contacts__c,Contacts[1].Name+';');
        System.AssertEquals(existingContacts[0].Altify_Influenced__c,true);
            
        existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[2].Id];
        System.AssertEquals(existingContacts[0].Altify_Conflict_Contacts__c,null);
        System.AssertEquals(existingContacts[0].Altify_Conflict__c,false);
            
        existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[3].Id];
        System.AssertEquals(existingContacts[0].Altify_Conflict_Contacts__c,null);
        System.AssertEquals(existingContacts[0].Altify_Conflict__c,false);
            
        existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[4].Id];
        System.AssertEquals(existingContacts[0].Altify_Conflict_Contacts__c,Contacts[5].Name+';');
        System.AssertEquals(existingContacts[0].Altify_Conflict__c,true);
            
        existingContacts = [Select Id,Name,Altify_Influenced_by_Contacts__c,Altify_Influencing_Contacts__c,Altify_Conflict_Contacts__c,Altify_Conflict__c,Altify_Influenced__c,Altify_Influencer__c from Contact where Id=:Contacts[5].Id];
        System.AssertEquals(existingContacts[0].Altify_Conflict_Contacts__c,Contacts[4].Name+';');
        System.AssertEquals(existingContacts[0].Altify_Conflict__c,true);
    }
}