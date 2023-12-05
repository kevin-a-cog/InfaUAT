@isTest
public class DnbAutomationTest {
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    @isTest
    public static void upsertQuoteSummaryTest(){
        
        Id pbId = Test.getStandardPricebookId();
        //Insert Account setup data
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Inserting an Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObj = new Opportunity(); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        //Creating Secondary Opportunity
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Secondary');
        UtilityTestData.mOpportunityData.put('Name', 'Secondary');
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '70'); 
        UtilityTestData.mOpportunityData.put('Pricebook2Id ', pbId); 
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //update the pricebook on Opty
        sObj = new Opportunity(id = lOpportunity[0].Id, Pricebook2Id = pbId);
        sObj1 = new Opportunity(id = lOpportunity[1].Id, Pricebook2Id = pbId);
        lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});
        
        //Insert Opportunity Contact Roles
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[0].Id);
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        
        //Insert Opportunity Team members
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
        sObj = new OpportunityTeamMember ();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        //insert quote;   
        Test.startTest();
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Split_Percentage__c from Opportunity where Name =\'Primary\' Limit 1');
        system.assertEquals(lOpportunityPrimary.size(),1);
        List<Account> liAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        List<Contact> liContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        system.assertEquals(lContact.size(),1);
        List<Quote_Summary__c> listQS;
        System.runAs(userObj) {           
            
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityPrimary[0].Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
            system.assertEquals(lSBQuote.size(),1);
            List<Id> idList = new List<Id>();
            idList.add(lSBQuote[0].Id);
            DnbAutomation.upsertQuoteSummary(idList); // Quote Summary Creation
            DnbAutomation.upsertQuoteSummary(null); //Exception
            DnbAutomation.upsertQuoteSummary(idList); //QS Update 
        }
        Test.stopTest();
        listQS = (List<Quote_Summary__c>) UtilityTest.executeQuery('Select Id from Quote_Summary__c Limit 1');
        system.assertEquals(listQS.size(),1);
    }
}