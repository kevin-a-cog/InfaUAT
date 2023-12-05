@isTest
public class CstRejectEngagementControllerTest {
    
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('CSA').getRecordTypeId();
    @testSetup
    static void setupObjectTestData(){
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        
        //Insert Account data
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Contact Data
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        // Insert new Opportunity
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Direct');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        
        UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
        
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
        sObj1 = new Opportunity();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        // Create OCR to cover the scenario where an opportunity has one OCR role with Billing Contact
        sObj = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId',lOpportunity[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('IsPrimary','true');
        UtilityTestData.mOpportunityContactRoleData.put('Role','CSM');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData );
        List<OpportunityContactRole> lOCR= (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c','false');       
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
       
        
        // create Engagement  
        UtilityTestData.mEngagementData.put('Name','Test Engagement Partner');
        UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId); 
        sObject engmntPrtnr = new Engagement__c();
        
        List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmntPrtnr});
        System.assertNotEquals(engmntListPrtnr[0].Id,null);
        
        
    }
    
    private static testmethod void acceptEngagementTesting() {
        plan__c oPlan = [Select Id From Plan__c LIMIT 1];
        Opportunity opp = [select id,name from Opportunity LIMIT 1];
        
        List<Engagement__c> engmntListPrtnr = [Select id,Name From Engagement__c ];  
        engmntListPrtnr[0].Opportunity__c = opp.id;
        engmntListPrtnr[0].Engage_with_CSM__c = true;
        engmntListPrtnr[0].Plan__c = oPlan.Id;
        
        Update engmntListPrtnr;
        
        
        
        
        test.startTest();
        
        Approval.LockResult lrList = Approval.lock(engmntListPrtnr[0].Id, false);
        
        CstRejectEngagementController.rejectEngagementRecord(engmntListPrtnr[0].Id,'test closing notes'); 
        CstRejectEngagementController.rejectEngagementRecord(engmntListPrtnr[0].Id,'test closing notes');// after unlock
        CstRejectEngagementController.rejectapprovalrecord(engmntListPrtnr[0].Id);
        try{
            CstRejectEngagementController.rejectEngagementRecord(null,'test closing notes');
        }
        catch(exception ex){
            system.debug('ex--> ' + ex); 
        }
        
        
        test.stopTest();
    
    }

    private static testmethod void rejecttEngagementTesting()
    {
            Engagement__c eng=new Engagement__c();
            eng.Name='Test Engagement Partner';
            eng.Status__c='Submitted for Approval';
            eng.RecordtypeId =EgmtRecTypeId;
            eng.RecType__c='CSA';
            insert eng;
            CstRejectEngagementController.rejectapprovalrecord(eng.id);

    }
       
    
   
}