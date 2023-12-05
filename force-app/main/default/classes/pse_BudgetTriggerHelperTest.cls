/*
@created by       : PAVITHRA
@created on       : 11/24/2021
@Purpose          : Test class for pse_BudgetTriggerHelper.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class pse_BudgetTriggerHelperTest {
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSE_Budget__c = true;
        insert trigSetting;
    }
    
     @testSetup
    static void setupObjectTestData() {
        
        setupCustomSettings();
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        System.debug('AccRecType'+ AccRecType.Id);
        
        Sobject sObj;
        Sobject sObj1;
        Sobject sObj2;
        Sobject sObj3;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');// 
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        UtilityTestData.mRegion.put('pse__Region_Name_Chain__c','North America');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        for(pse__Region__c reg : lRegion){
            System.debug('reg.pse__Region_Name_Chain__c: ' + reg.pse__Region_Name_Chain__c);
        }
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar; 
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('Is_Primary__c','false');            
            UtilityTestData.mContactData.put('pse__Is_Resource__c','true');
            UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
            UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');//psa_Employee_Type__c
            UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
            UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
            UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
            UtilityTestData.mContactData.put('psa_Employee_Type__c','Informatica-Non PS');
            
            UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
            UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            /*sObj = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
            Id pricebookId = Test.getStandardPricebookId(); 
            
            sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            sObj = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});*/
            
            Test.startTest();
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud Adoption Hybrid MDM');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            UtilityTestData.mOpportunityData.put('pse__Region__c',lRegion[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
                        
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            /*lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
            lOpportunity[0].StageName = 'Closed Won';
            update lOpportunity[0];
            
            OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= lPriceBookEntry[0].Id,TotalPrice=2000,Quantity = 2,OpportunityId = lOpportunity[0].Id);
            insert oppLine;
            Test.stopTest();*/

            sObj = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Internal');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('CurrencyIsoCode','USD');
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');  
            UtilityTestData.mProjectData.put('pse__Region__c',lRegion[0].Id);  
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new pse__Budget__c();
            UtilityTestData.mBudget.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mBudget.put('pse__Amount__c','100');
            UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order Change Request');
            UtilityTestData.mBudget.put('CurrencyIsoCode','USD');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBudget);
            
            sObj2 = new pse__Budget__c();
            UtilityTestData.mBudget.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mBudget.put('pse__Amount__c','101');
            UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order Change Request');
            UtilityTestData.mBudget.put('CurrencyIsoCode','USD');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mBudget);
            
            sObj1 = new pse__Budget__c();
            UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mBudget.put('pse__Amount__c','10');
            UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order Change Request');
            UtilityTestData.mBudget.put('pse__Status__c','Approved');
            UtilityTestData.mBudget.put('CurrencyIsoCode','USD');
            UtilityTestData.mBudget.put('Additional_Hours__c','10');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mBudget);
            
            sObj3 = new pse__Budget__c();
            UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mBudget.put('pse__Amount__c','10');
            UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order Change Request');
            UtilityTestData.mBudget.put('pse__Status__c','Approved');
            UtilityTestData.mBudget.put('CurrencyIsoCode','USD');
            UtilityTestData.mBudget.put('Additional_Hours__c','10');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mBudget);
            List<pse__Budget__c> lBudget = (List<pse__Budget__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
        }
    }
    
    public static testMethod void testBudgetTrigger() {
        
        List<pse__Budget__c> lBudget = new List<pse__Budget__c>();
        
        for(pse__Budget__c bud : [Select id,Additional_Hours__c,pse__Status__c from pse__Budget__c WHERE pse__Amount__c >= 100]){
            bud.Additional_Hours__c = 10.00;
            bud.pse__Status__c = 'Approved';
			lBudget.add(bud);            
        }
        
        Test.startTest();
        update lBudget;
        Test.stopTest();
    }
    
    public static testMethod void testDeleteBudgetTrigger() {
        
        List<pse__Budget__c> lBudget = new List<pse__Budget__c>();
        
        for(pse__Budget__c bud : [Select id from pse__Budget__c WHERE pse__Status__c = 'Approved']){
            lBudget.add(bud);
        }
        
        Test.startTest();
        delete lBudget;
        Test.stopTest();
    }

}