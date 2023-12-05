@isTest(seeAllData = false)
public class CSMObjectivesSignoffControllerTest {
    
    @testSetup 
    public static void setup() {
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        

        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        //  UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
         // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);        
        UtilityTestData.mObjective.put('Is_Template__c','true');
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective}); 
		
    }
    
    @isTest
    public static void testObjSignoff() {
        List<Objective__c> lObjective = [Select Id from Objective__c];
        List<Plan__c> lPlan = [Select Id from Plan__c];
        List<Plan_Contact__c> lPlanContact = [Select Id,contact__c from Plan_Contact__c];
        CSMObjectivesSignoffController.getRecords(lPlan[0].Id);
        CSMObjectivesSignoffController.getContactRecords(lPlan[0].Id);
        CSMObjectivesSignoffController.fetchMergedQuickText(lPlan[0].Id,'Test');
        CSMObjectivesSignoffController.createObJectivePlanComment(lPlan[0].Id,'Test',lPlanContact[0].Contact__c,lObjective);
        CSMObjectivesSignoffController.updateSignoffObjectives(lPlanContact[0].Contact__c,lObjective);
    }

}