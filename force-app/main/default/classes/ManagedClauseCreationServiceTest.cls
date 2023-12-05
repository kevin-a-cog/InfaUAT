/*
This class test is for the following classes:
    - ManagedClauseCreationService
    - ManagedClauseCreationTriggerHandler
*/
@isTest
private class ManagedClauseCreationServiceTest {

    @testSetup
    static void setup() {       
        // create clause bundles based on configured mapping info. Add just one clause in each bundle to facilitate testing.
        List<ManagedClauseCreationService.MappingInfo> configuredInfos = ManagedClauseCreationService.getMappingInfoForSourceObject(Schema.SObjectType.Lead.getName());
        system.assertEquals(false, configuredInfos.isEmpty());
        Integer numClausesPerBundle = 0;
        for (ManagedClauseCreationService.MappingInfo mi : configuredInfos) {
            ManagedClauseCreationTestDataFactory.createClauseBundle(mi.name, 'Test Clause Bundle', 1, mi);
        }    
    }

    @isTest
    static void testLeadCreationWithManagedClauses() {

        // get test clause bundles.
        List<APXT_Redlining__Clause_Bundle__c> clauseBundles = getClauseBundles();      
        system.assertEquals(2, clauseBundles.size());       

        // enable custom setting for existing managed clauses deletion
        Managed_Clauses_Settings__c customSetting = new Managed_Clauses_Settings__c(Always_Delete_Existing_Managed_Clauses__c = true);
        insert customSetting;
    
        test.startTest();

        // create test lead.
        Lead testLead = new Lead(
            LastName = 'Test',
            FirstName = 'Test',         
            LeadSource = ManagedClauseCreationTestDataFactory.getPickListDefaultOrFirstValue(Lead.LeadSource),
            Company = 'Test',
            DoNotCall = true, // Controlling field. Set to true to allow trigger execution. 
            NumberOfEmployees = 0,
            Country = 'US'
        );
        insert testLead;        

        // set lead Id
        Id leadId = testLead.Id;

        // get managed clauses for object to check that has been created for one of the configured selectors.
        List<APXT_Redlining__Managed_Clause__c> managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(1, managedClauses.size());

        testLead.DoNotCall = false; // set controlling field to false (the trigger won't execute) 
        testLead.NumberOfEmployees = 100; // set selector field to wrong value to later update.
        update testLead;

        // check the existence of managed clauses despite the change in selection criteria. Just one managed clause.
        managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(1, managedClauses.size());

        testLead.DoNotCall = true; // re-enable trigger execution.
        testLead.NumberOfEmployees = 1; // set selector field to the correct value to add new clause.
        update testLead;

        // check trigger execution and creation of managed clauses by selection criteria change.
        managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(2, managedClauses.size());

        // check object assignment field value.
        List<Lead> testLeads = getLeads(new Set<Id>{leadId});
        system.assertEquals(1, testLeads.size());
        system.assertEquals('Test Clause Bundle', testLeads[0].Description); 

        delete testLeads;

        test.stopTest();        

        // check managed clauses deletion.
        managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(true, managedClauses.isEmpty());
    }

    @isTest
    static void testManagedClausesSelectiveDeletion() {

        // value to update managed clause text.
        String managedClauseText = 'Updated text.';

        test.startTest();
        
        // create test lead, just for one bundle addition.
        Lead testLead = new Lead(
            LastName = 'Test',
            FirstName = 'Test',         
            LeadSource = ManagedClauseCreationTestDataFactory.getPickListDefaultOrFirstValue(Lead.LeadSource),
            Company = 'Test',
            DoNotCall = true, // Controlling field. Set to true to allow trigger execution. 
            NumberOfEmployees = 0,
            Country = 'US'
        );
        insert testLead;        

        // get test lead id.
        Id leadId = testLead.Id;

        // check managed clauses number = 1.
        List<APXT_Redlining__Managed_Clause__c> managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(1, managedClauses.size());

        // update existing managed clause text.
        Id managedClauseId = managedClauses[0].Id;
        managedClauses[0].APXT_Redlining__Latest_Revision_Text__c = managedClauseText;
        update managedClauses;

        // update lead criteria for bundle selection and new managed clause creation.
        testLead.NumberOfEmployees = 1;
        update testLead;

        // check addition of new managed clause.
        managedClauses = getManagedClausesByLeadId(new Set<Id>{leadId});
        system.assertEquals(2, managedClauses.size());

        // check updated managed clause text persistance despite new clause bundle selection.
        for (APXT_Redlining__Managed_Clause__c mc : managedClauses) {
            if (mc.Id == managedClauseId) {
                system.assertEquals(managedClauseText, mc.APXT_Redlining__Latest_Revision_Text__c);
                break;
            }
        }

        test.stopTest();                
    }
    
    /********
    Selectors
    ********/
    private static List<Lead> getLeads(Set<Id> leadIds) {
        return [
            SELECT 
                Id, 
                Description 
            FROM Lead 
            WHERE Id IN :leadIds];
    }

    private static List<APXT_Redlining__Managed_Clause__c> getManagedClausesByLeadId(Set<Id> leadIds) {
        return [
            SELECT
                Id,
                APXT_Redlining__Latest_Revision_Text__c                             
            FROM APXT_Redlining__Managed_Clause__c
            WHERE Lead__c IN :leadIds
        ];
    }

    private static List<APXT_Redlining__Clause_Bundle__c> getClauseBundles() {
        return [
            SELECT 
                Id, 
                Name, 
                APXT_Redlining__Description__c,
                Order__c,
                APXT_Redlining__totalClauses__c 
            FROM APXT_Redlining__Clause_Bundle__c 
            ORDER BY Order__c NULLS LAST
        ];
    }

}