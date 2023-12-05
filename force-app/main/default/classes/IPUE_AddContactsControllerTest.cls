@isTest
public with sharing class IPUE_AddContactsControllerTest {
    @testSetup
    static void setupObjectTestData() {

        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account 1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account 2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        sObject sObj2 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[1].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact 2');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);
        
        sObject sObj3 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[1].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact 3');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mContactData);


        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);

        sObj1 = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);

        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});

        Test.startTest();

        Estimation_Summary__c estimationSummary = IPUE_TestUtils.createEstimationSummary(true, lOpportunity[0].Id);
        estimationSummary.Account__c = lAccount[0].Id;
        update estimationSummary;

        Test.stopTest();
    }

    @isTest
    private static void testMethod1(){
        Estimation_Summary__c estimationSummary = [SELECT Id,Account__c,Opportunity__c FROM Estimation_Summary__c LIMIT 1];

        IPUE_AddContactsController.getFieldsToDisplay();

        Estimation_Summary__c summaryRec = IPUE_AddContactsController.getEstimationRec(estimationSummary.Id);
        System.AssertEquals(summaryRec.Estimator_Collaborators__r.size(),0,'Could not Fetch Estimation Summary Record');

        Test.startTest();
        Integer contactCount;

        contactCount = IPUE_AddContactsController.getNumberOfRecords(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Global Contacts','');
        List<Contact> lContact = [Select Id FROM Contact];
        System.AssertEquals(contactCount,lContact.size(),'Global contact count does not match');
        
        contactCount = IPUE_AddContactsController.getNumberOfRecords(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Opportunity Contacts','');
        List<OpportunityContactRole> lOppContacts = [Select Id FROM OpportunityContactRole WHERE OpportunityId =:estimationSummary.Opportunity__c];
        System.AssertEquals(contactCount,lOppContacts.size(),'Opportunity contact count does not match');
        
        contactCount = IPUE_AddContactsController.getNumberOfRecords(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Account Contacts','');
        List<AccountContactRelation> lAccContacts = [Select Id FROM AccountContactRelation WHERE AccountId =:estimationSummary.Account__c];
        System.AssertEquals(contactCount,lAccContacts.size(),'Account contact count does not match');

        Test.stopTest();
    }

    @isTest
    private static void testMethod2(){

        Test.startTest();

        String queryFields = ',Name,AccountName__c,Email';
        Estimation_Summary__c estimationSummary = [SELECT Id,Account__c,Opportunity__c FROM Estimation_Summary__c LIMIT 1];
        List<Contact> lContact = [Select Id FROM Contact];
        List<OpportunityContactRole> lOppContacts = [Select Id FROM OpportunityContactRole WHERE OpportunityId =:estimationSummary.Opportunity__c];
        List<AccountContactRelation> lAccContacts = [Select Id FROM AccountContactRelation WHERE AccountId =:estimationSummary.Account__c];
        List<sObject> lstContactRes = new List<sObject>();

        lstContactRes = IPUE_AddContactsController.getContacts(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Global Contacts','',queryFields,'0','0');
        System.AssertEquals(lstContactRes.size(),lContact.size(),'Global contact count does not match');
        
        lstContactRes = IPUE_AddContactsController.getContacts(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Opportunity Contacts','',queryFields,'0','0');
        System.AssertEquals(lstContactRes.size(),lOppContacts.size(),'Opportunity contact count does not match');
        
        lstContactRes = IPUE_AddContactsController.getContacts(estimationSummary.Account__c,estimationSummary.Opportunity__c,'Account Contacts','',queryFields,'0','0');
        System.AssertEquals(lstContactRes.size(),lAccContacts.size(),'Account contact count does not match');

        Test.stopTest();
    }  
    
    @isTest
    private static void testMethod3(){

        Test.startTest();
        Estimation_Summary__c estimationSummary = [SELECT Id,Account__c,Opportunity__c FROM Estimation_Summary__c LIMIT 1];
        Map<Id,Contact> mapContacts = new Map<Id,Contact>([SELECT Id FROM Contact]);
        List<Id> lstContactIds = new List<Id>(mapContacts.keySet());
        List<Estimator_Collaborator__c> lstNewEstimationCollabs = new List<Estimator_Collaborator__c>();

        Estimator_Collaborator__c collab = new Estimator_Collaborator__c();
        collab.Contact__c = lstContactIds[0];
        collab.Active__c = false;
        collab.Estimation_Summary__c = estimationSummary.Id;
        lstNewEstimationCollabs.add(collab);

        collab = new Estimator_Collaborator__c();
        collab.Contact__c = lstContactIds[1];
        collab.Estimation_Summary__c = estimationSummary.Id;
        lstNewEstimationCollabs.add(collab);

        insert lstNewEstimationCollabs;

        List<IPUE_ReviewContactsController.ReviewContactData> lstCollaboatorData = IPUE_ReviewContactsController.getEstimationCollaborators(estimationSummary.Id,lstContactIds);
        System.AssertEquals(lstCollaboatorData.size(),lstContactIds.size(),'Unable to fecth contacts data for review');

        IPUE_ReviewContactsController.upsertEstimationCollaborators(estimationSummary.Id,lstCollaboatorData);
        lstNewEstimationCollabs = [SELECT Id FROM Estimator_Collaborator__c WHERE Estimation_Summary__c = :estimationSummary.Id];
        System.AssertEquals(lstNewEstimationCollabs.size(),lstContactIds.size(),'Error upserting Estimator Collaborator records');

        Test.stopTest();
    }    
}