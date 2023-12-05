@isTest
public class CsmAcceptEngagementControllerTest {
  
      static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Subscription Adoption').getRecordTypeId();
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
        
        // create Engagement 
        UtilityTestData.mEngagementData.put('Name','Test Engagement Partner');
        UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId); 
        sObject engmntPrtnr = new Engagement__c();
        List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmntPrtnr});
        System.assertNotEquals(engmntListPrtnr[0].Id,null);
    }
    
    private static testmethod void acceptEngagementTesting() {
        
        Opportunity opp = [select id,name from Opportunity LIMIT 1];
        
        List<Engagement__c> engmntListPrtnr = [Select id,Name From Engagement__c ];  
        engmntListPrtnr[0].Opportunity__c = opp.id;
        engmntListPrtnr[0].Engage_with_CSM__c = true;
        Update engmntListPrtnr;
        test.startTest();
        try{
            csmAcceptEngagementController.acceptEngagementRecord(engmntListPrtnr[0].Id);
          csmAcceptEngagementController.acceptEngagementRecord(null);
        }
        catch(exception ex){
           system.debug('ex--> ' + ex); 
        }
        
        
        test.stopTest();
        
    }
    
}