/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TakeOwnerShipControllerAuraTest {
    
    static testMethod void TakeOwnerShipLead(){
        
        sObject sObja = new Account();
          //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        //Insert Lead
        String LEAD_RT = 'Lead';
        UtilityTestData.mLeadData.put('RecordTypeId', Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_RT).getRecordTypeId());
        sObject sObj = new Lead();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(lLead.size(), 1);
        
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        String returnValue = TakeOwnerShipControllerAura.LeadchangeOwnerShip(lLead[0].id);    
        
        //assert to check logged in user is same as lead owner
        System.assertEquals('same owner',returnValue);
    }
    static testMethod void TakeOwnerShipLeadIsPartnerUser(){
    
        //query for puser federation user
        User usr = [select id from user where FederationIdentifier = 'puser' and IsActive = true limit 1];            
        sObject sObj = new Account();
          //Insert Account data
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Lead
        String LEAD_RT = 'Lead';
        UtilityTestData.mLeadData.put('RecordTypeId', Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_RT).getRecordTypeId());
        UtilityTestData.mLeadData.put('OwnerId', usr.id);
        sObject sObj1 = new Lead();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLeadData);
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        System.assertEquals(lLead.size(),1);
        
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        String returnValue = TakeOwnerShipControllerAura.LeadchangeOwnerShip(lLead[0].id); 
        
        //assert to check if login is successful
        System.assertEquals(returnValue,'success');
     
    }
    static testMethod void TakeOwnershipLeadCanNotChangeOwnership(){
         sObject sObja = new Account();
           //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        User user = [select id from user where FederationIdentifier = 'puser' and IsActive = true limit 1];            
        User usr = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        String returnValue;
        System.runAs(usr){
         //Insert Lead
            String LEAD_RT = 'Lead';
            UtilityTestData.mLeadData.put('RecordTypeId', Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_RT).getRecordTypeId());
            sObject sObj = new Lead();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);
            List<Lead> leadList = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
            System.assertEquals(leadList.size(),1);
            
        
        
        
        
           
            TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
            returnValue = TakeOwnerShipControllerAura.LeadchangeOwnerShip(leadList[0].id);
            system.debug('returnValueContact'+ returnValue);
        }
        
        //assert to check if ownership can not be changed
        System.assertEquals(returnValue,'same owner'); 
        
    }
    static testMethod void TakeOwnerShipLeadException(){
         sObject sObja = new Account();
           //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        User usr = [select id from user where FederationIdentifier = 'unasgn' and IsActive = true limit 1];            
        User user = [select id from User limit 1];
        //Insert Lead
        String LEAD_RT = 'Lead';
        UtilityTestData.mLeadData.put('RecordTypeId', Schema.SObjectType.Lead.getRecordTypeInfosByName().get(LEAD_RT).getRecordTypeId());
        UtilityTestData.mLeadData.put('OwnerId', usr.id);
        sObject sObj = new Lead();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);
        List<Lead> leadList = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(leadList.size(),1);
        
        String returnResult;
        
        System.runAs(user){
        
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        returnResult = TakeOwnerShipControllerAura.LeadchangeOwnerShip(leadList[0].id);  
        
        }
    }    
    static testMethod void TakeOwnershipConCanNotChangeOwnership(){
    
        User usr = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        sObject sObja = new Account();
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        //Insert Contact
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> conList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(conList.size(),1);
        
        String returnValue;
        
        System.runAs(usr){
            TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
            returnValue = TakeOwnerShipControllerAura.ContactOwnership(conList[0].id);
        }
        //assert to check the condition ownership can not be changed
        System.assertEquals(returnValue,'success'); 
    }
    
    static testMethod void TakeOwnerShipContactIsPartnerUser(){
         sObject sObja = new Account();
          //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        User usr = [select id from user where FederationIdentifier = 'unasgn' and IsActive = true limit 1];
        //Insert Contact
        UtilityTestData.mContactData.put('OwnerId', usr.id);
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> conList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(conList.size(),1);
        
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        String returnResult = TakeOwnerShipControllerAura.ContactOwnership(conList[0].id);
        //assert to check if owner change is successful
        System.assertEquals('success',returnResult );
    }
    
    static testMethod void TakeOwnerShipContactException(){
        
         sObject sObja = new Account();
          //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        User usr = [select id from user where FederationIdentifier = 'unasgn' and IsActive = true limit 1];            
        User userObj = [select id from user limit 1];
        //Insert Contact
        UtilityTestData.mContactData.put('OwnerId', usr.id);
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> conList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(conList.size(),1);
        String returnResult;
        System.runAs(userObj){
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        returnResult = TakeOwnerShipControllerAura.ContactOwnership(conList[0].id);  
        
        }
    }
    static testMethod void TakeOwnerShipContact(){
        
         sObject sObja = new Account();
          //Insert Account data
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        // Insert contact
        
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.assertEquals(lContact.size(),1);
        
        TakeOwnerShipControllerAura takeOSCA = new TakeOwnerShipControllerAura();
        String returnValue = TakeOwnerShipControllerAura.ContactOwnership(lContact[0].id);  
        
        //assert to check if logged in user is same as contact owner
        System.assertEquals(returnValue, 'same owner');
    }

}