/*
*  @Author:  Anil Solanki     
*  @Created Date: 10 Feb 2021
*  @Description:   Test class for UpdateLeadScoreOpportunityBatch with the updated test framework
*/
@isTest
private class UpdateLeadScoreOpportunityBatchTest{
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() { 
         //Insert Account setup data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Priority_Group__c','A');
        UtilityTestData.mContactData.put('Priority_Score__c','90');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Priority_Group__c','B');
        UtilityTestData.mContactData.put('Priority_Score__c','70');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //Inserting an Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Name','Test LEAD SCORING');
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');
        UtilityTestData.mOpportunityData.put('OrderableIn__c', 'New');    
        UtilityTestData.mOpportunityData.put('Priority_Score__c',null);
        UtilityTestData.mOpportunityData.put('SBQQ__AmendedContract__c',null);
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Name','Test LEAD SCORING 2');
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');
        UtilityTestData.mOpportunityData.put('OrderableIn__c', 'New');  
        UtilityTestData.mOpportunityData.put('Priority_Score__c',null);
        UtilityTestData.mOpportunityData.put('SBQQ__AmendedContract__c',null);
        sObj1 = new Opportunity();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
     
        sObj = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId',lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('IsPrimary','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData );
        
        sObj1 = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId',lOpportunityPrimary[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('IsPrimary','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData );
        
        List<OpportunityContactRole> opportunityRoleList = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        //List<Contact> lOCR= (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1}); 
    }
    
     static testmethod void unitTestExecuteBatch(){
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];

        List<Opportunity> opportunityList = [Select Id,Name,Priority_Score__c from Opportunity Limit 2];
        opportunityList[0].Priority_Score__c = null;
        opportunityList[1].Priority_Score__c = null;
        update opportunityList;
        System.runAs(userObj) { 
            Test.startTest();
            UpdateLeadScoreOpportunityBatch cls  = new UpdateLeadScoreOpportunityBatch();
            Database.executeBatch(cls);
            Test.stopTest();
        }
    }
 }