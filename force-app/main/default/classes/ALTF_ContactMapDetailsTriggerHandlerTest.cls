/*
Class:          ALTF_ContactMapDetailsTriggerHandlerTest
@Author:        Uday Kumar
@Created Date:  10/20/2021
@Description:   test class for ALTF_ContactMapDetailsTriggerHandler

Change History
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         20-NOV-2021     SALESRT-13318            To stamp the 4 attributes present on Contact Map Details record to Contact record on conditions.      T<01> 

*/

@isTest
public class ALTF_ContactMapDetailsTriggerHandlerTest{  //<T01>
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData(){
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        System.runAs(userObj){
            UtilityTestData.mAccountData.put('Name', 'Test ContactMapDetails1');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);             
            
            UtilityTestData.mAccountData.put('Name', 'Test ContactMapDetails2');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj1 = new Account();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData); 
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            // Set all the required fields and dynamic ids in Map
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Test_1Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Test_2Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj1 = new Contact();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);

            UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
            UtilityTestData.mContactData.put('Email', 'Test_3Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj2 = new Contact();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);            
            
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1,sObj2});
            
            UtilityTestData.mContactMapDetailsData.put('ALTF__Account__c',lAccount[0].Id);
            UtilityTestData.mContactMapDetailsData.put('ALTF__Contact__c',lContact[0].Id);
            sobj = new ALTF__Contact_Map_Details__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactMapDetailsData);
            UtilityTestData.mContactMapDetailsData.put('ALTF__Account__c',lAccount[1].Id);
            UtilityTestData.mContactMapDetailsData.put('ALTF__Contact__c',lContact[0].Id);
            sobj1 = new ALTF__Contact_Map_Details__c();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactMapDetailsData);
            List<ALTF__Contact_Map_Details__c> lcontactMapDetails = (List<ALTF__Contact_Map_Details__c>) UtilityTest.makeInsert(new List<sobject>{sobj,sobj1});         
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void ContactMapDetailsUpdateTest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<ALTF__Contact_Map_Details__c> lcontactMapDetails = [Select Id,ALTF__Contact__c,ALTF__Decision_Orientation__c,ALTF__Coverage__c,ALTF__Political__c,ALTF__Status__c,ALTF__Account__c from ALTF__Contact_Map_Details__c where (ALTF__Account__r.Name='Test ContactMapDetails1' OR ALTF__Account__r.Name='Test ContactMapDetails2')]; 
        Test.startTest();
        System.runAs(userObj){          
            lcontactMapDetails[0].ALTF__Decision_Orientation__c = 'Technical';
            lcontactMapDetails[0].ALTF__Coverage__c= 'Multiple contacts';
            lcontactMapDetails[0].ALTF__Political__c= 'Political Structure';
            lcontactMapDetails[0].ALTF__Status__c= 'Supporter';
            update lcontactMapDetails[0];
                    
            lcontactMapDetails[1].ALTF__Decision_Orientation__c = 'Relationship';
            lcontactMapDetails[1].ALTF__Coverage__c= 'Brief Contact';
            lcontactMapDetails[1].ALTF__Political__c= 'Outside Political Structure';
            lcontactMapDetails[1].ALTF__Status__c= 'Neutral';
            update lcontactMapDetails[1];
            List<ALTF__Contact_Map_Details__c> lcontactMapDetails1 = [Select Id,ALTF__Contact__c,ALTF__Decision_Orientation__c,ALTF__Coverage__c,ALTF__Political__c,ALTF__Status__c,ALTF__Account__c from ALTF__Contact_Map_Details__c where (ALTF__Account__r.Name='Test ContactMapDetails1' OR ALTF__Account__r.Name='Test ContactMapDetails2')]; 
            Test.StopTest();
                    
            List<Contact> Contacts =[Select Id,Altify_Coverage__c,Altify_Political_Status__c,Altify_Support__c,Altify_Decision_Orientation__c from Contact where Id=:lcontactMapDetails1[0].ALTF__Contact__c];
            system.assertEquals(Contacts[0].Altify_Coverage__c,lcontactMapDetails[0].ALTF__Coverage__c);
            system.assertEquals(Contacts[0].Altify_Political_Status__c,lcontactMapDetails[0].ALTF__Political__c);
            system.assertEquals(Contacts[0].Altify_Support__c,lcontactMapDetails[0].ALTF__Status__c);
            system.assertEquals(Contacts[0].Altify_Decision_Orientation__c,lcontactMapDetails[0].ALTF__Decision_Orientation__c );
            delete lcontactMapDetails[0];
                    
            List<Contact> Contacts1 =[Select Id,Altify_Coverage__c,Altify_Political_Status__c,Altify_Support__c,Altify_Decision_Orientation__c from Contact where Id=:lcontactMapDetails1[0].ALTF__Contact__c];
                  
        }    
    }
    
    @isTest
    static void ContactMapDetailsDeleteTest()
    {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<ALTF__Contact_Map_Details__c> lcontactMapDetails = [Select Id,ALTF__Contact__c,ALTF__Decision_Orientation__c,ALTF__Coverage__c,ALTF__Political__c,ALTF__Status__c,ALTF__Account__c from ALTF__Contact_Map_Details__c where (ALTF__Account__r.Name='Test ContactMapDetails1' OR ALTF__Account__r.Name='Test ContactMapDetails2')]; 
        Test.startTest();
        System.runAs(userObj){          
            lcontactMapDetails[0].ALTF__Decision_Orientation__c = 'Technical';
            lcontactMapDetails[0].ALTF__Coverage__c= 'Multiple contacts';
            lcontactMapDetails[0].ALTF__Political__c= 'Political Structure';
            lcontactMapDetails[0].ALTF__Status__c= 'Supporter';
            update lcontactMapDetails[0];
                    
            lcontactMapDetails[1].ALTF__Decision_Orientation__c = 'Relationship';
            lcontactMapDetails[1].ALTF__Coverage__c= 'Brief Contact';
            lcontactMapDetails[1].ALTF__Political__c= 'Outside Political Structure';
            lcontactMapDetails[1].ALTF__Status__c= 'Neutral';
            update lcontactMapDetails[1];
                    
            List<ALTF__Contact_Map_Details__c> lcontactMapDetails1 = [Select Id,ALTF__Contact__c,ALTF__Decision_Orientation__c,ALTF__Coverage__c,ALTF__Political__c,ALTF__Status__c,ALTF__Account__c from ALTF__Contact_Map_Details__c where (ALTF__Account__r.Name='Test ContactMapDetails1' OR ALTF__Account__r.Name='Test ContactMapDetails2')];        
            List<Contact> Contacts =[Select Id,Altify_Coverage__c,Altify_Political_Status__c,Altify_Support__c,Altify_Decision_Orientation__c from Contact where Id=:lcontactMapDetails1[0].ALTF__Contact__c];
                     
            delete lcontactMapDetails[0];
            Test.StopTest();
                     
            List<Contact> Contacts1 =[Select Id,Altify_Coverage__c,Altify_Political_Status__c,Altify_Support__c,Altify_Decision_Orientation__c from Contact where Id=:lcontactMapDetails1[0].ALTF__Contact__c];                  
            system.assertEquals(Contacts[0].Altify_Coverage__c,null);
            system.assertEquals(Contacts[0].Altify_Political_Status__c,null);
            system.assertEquals(Contacts[0].Altify_Support__c,null);
            system.assertEquals(Contacts[0].Altify_Decision_Orientation__c,null);     
        }    
    }   
}