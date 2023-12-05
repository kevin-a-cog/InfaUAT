@isTest
public class spContactDataTableControllerTest {
     @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','Lname');
        UtilityTestData.mContactData.put('Email',userinfo.getUserEmail());
        UtilityTestData.mContactData.put('Phone','1231231234');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
       
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','Business Value');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
    }
    
        //GlobalDataTableWrapperClass wrrpr =new GlobalDataTableWrapperClass();
        //wrrpr.strRecordId = '75817269812769ssdjk';
        
    
    
    private static testmethod void planDataTableMethodTest(){        
        Plan_Contact__c oPC = [Select Id,Name,Plan__c From Plan_Contact__c LIMIT 1];
        Contact oCon = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        GlobalDataTableWrapperClass wrrpr =new GlobalDataTableWrapperClass();
        wrrpr.strRecordId = '75817269812769ssdjk';
        
        test.startTest();
        spContactDataTableController.fetchPlanRelatedContact(oPC.Plan__c);
        
        oCon.Id = null;
        oCon.Email = 'test001@gmail.com';
        oCon.Phone = '1234567894';
        string conData = JSON.serialize(oCon);
        spContactDataTableController.getPCRecords(wrrpr.strRecordId);
        spContactDataTableController.CreateNewContact(conData,oCon.AccountId ,oPC.Plan__c , 'Technical Owner');
        Contact oCon2 = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        spContactDataTableController.updateContact(JSON.serialize(oCon2), oCon2.AccountId, oPC.Plan__c, 'Technical Owner', oPC.Id);
        spContactDataTableController.removePlanContact(oPC.Id);
        test.stopTest();
    }
    
    private static testmethod void planDataTableMethodTestExceptions(){        
        Plan_Contact__c oPC = [Select Id,Name,Plan__c From Plan_Contact__c LIMIT 1];
        Contact oCon = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        
        test.startTest();                
        string conData = JSON.serialize(oCon);
    
        Contact oCon2 = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        try{
            spContactDataTableController.CreateNewContact(conData,oCon.AccountId ,oPC.Plan__c , 'Technical Owner');
        }catch(exception ex){
            system.debug('ex--> ' + ex);                
        }        
        test.stopTest();
    }
    
    private static testmethod void planDataTableMethodTestExceptions2(){        
        Plan_Contact__c oPC = [Select Id,Name,Plan__c From Plan_Contact__c LIMIT 1];
        Contact oCon = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        
        test.startTest();
        Contact oCon2 = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        try{
            spContactDataTableController.updateContact(JSON.serialize(''), oCon2.AccountId, oPC.Plan__c, 'Technical Owner', null);
        }catch(exception ex){
            system.debug('ex--> ' + ex);                
        }      
        
        test.stopTest();
    }
    
     
    
    
}