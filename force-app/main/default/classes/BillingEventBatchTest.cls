@isTest(seeAllData=false)
public class  BillingEventBatchTest {
    
    public BillingEventBatchTest() {

    }
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Billing_Event_Trigger__c = true;
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
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar; 
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
            UtilityTestData.mContactData.put('Is_Primary__c','false');
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
            
            lContact[0].pse__Is_Resource__c = true;
            //lContact[0].ReportsTo = lContact[0];
            update lContact[0];
            
            sObj = new Product2();
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
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','Jumpstart: Advanced EDC Success Pack');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
           
            Test.startTest();
            lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
            lOpportunity[0].StageName = 'Closed Won';
            update lOpportunity[0];
            
            OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= lPriceBookEntry[0].Id,TotalPrice=2000,Quantity = 2,OpportunityId = lOpportunity[0].Id);
            insert oppLine;
            
            sObj = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            UtilityTestData.mProjectData.put('psa_pm_Fees_Pre_Paid__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new pse__Milestone__c();
            UtilityTestData.mMilestone.put('Name','Test Milestone');
            UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','0.00');
            UtilityTestData.mMilestone.put('pse__Project__c',lProject[0].Id);//
            UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Labor');
            UtilityTestData.mMilestone.put('PSA_OM_PO_Number__c','PO121211');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mMilestone);

            sObj2 = new pse__Milestone__c();
            UtilityTestData.mMilestone.put('Name','Test Milestone2');
            UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','0.00');
            UtilityTestData.mMilestone.put('pse__Project__c',lProject[0].Id);//
            UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Labor');
            UtilityTestData.mMilestone.put('PSA_OM_PO_Number__c','PO121212');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mMilestone);
            
            List<pse__Milestone__c> lMilestone = (List<pse__Milestone__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj2});
            
            sObj = new Event();
            UtilityTestData.mEvent.put('WhatId',lMilestone[0].Id);
            UtilityTestData.mEvent.put('StartDateTime',System.today().addDays(1)+'');
            UtilityTestData.mEvent.put('EndDateTime',System.today().addDays(2)+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEvent);
            List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Test.stopTest();
        }
    }
    
    public static testMethod void unittest1() {
        
        Test.startTest();

        List<pse__Milestone__c> lMilestone = [Select Id, pse__Project__r.pse__Opportunity__c,pse__Project__c From pse__Milestone__c Where Name in ('Test Milestone','Test Milestone2')];
        pse__Billing_Event__c oBillingEvent = new pse__Billing_Event__c();
        oBillingEvent.pse__Project__c = lMilestone[0].pse__Project__c;
        insert oBillingEvent;
        
        list<pse__Miscellaneous_Adjustment__c> lstMiscellaneousAdjustment = new list<pse__Miscellaneous_Adjustment__c>();
        pse__Miscellaneous_Adjustment__c oMiscellaneousAdjustment1 = new pse__Miscellaneous_Adjustment__c();
        oMiscellaneousAdjustment1.Name = 'MA1';
        oMiscellaneousAdjustment1.pse__Effective_Date__c = system.today();
        oMiscellaneousAdjustment1.pse__Project__c = lMilestone[0].pse__Project__c;
        oMiscellaneousAdjustment1.pse__Amount__c = 100;
        oMiscellaneousAdjustment1.pse__Transaction_Category__c = 'Ready-to-Bill Revenue';
        oMiscellaneousAdjustment1.PSA_OM_PO_Number__c = 'PO121211';
        lstMiscellaneousAdjustment.add(oMiscellaneousAdjustment1);
        
        pse__Miscellaneous_Adjustment__c oMiscellaneousAdjustment2 = new pse__Miscellaneous_Adjustment__c();
        oMiscellaneousAdjustment2.Name = 'MA2';
        oMiscellaneousAdjustment2.pse__Effective_Date__c = system.today();
        oMiscellaneousAdjustment2.pse__Project__c = lMilestone[0].pse__Project__c;
        oMiscellaneousAdjustment2.pse__Amount__c = 100;
        oMiscellaneousAdjustment2.pse__Transaction_Category__c = 'Ready-to-Bill Revenue';
        oMiscellaneousAdjustment2.PSA_OM_PO_Number__c = 'PO121212';
        lstMiscellaneousAdjustment.add(oMiscellaneousAdjustment2);
        insert lstMiscellaneousAdjustment;
        
        list<pse__Billing_Event_Item__c> lstBillingEventItem = new list<pse__Billing_Event_Item__c>();
        pse__Billing_Event_Item__c oBillingEventItem1 = new pse__Billing_Event_Item__c();
        oBillingEventItem1.pse__Object_Id__c=lstMiscellaneousAdjustment[0].Id;
        oBillingEventItem1.pse__Miscellaneous_Adjustment__c=lstMiscellaneousAdjustment[0].Id;
        oBillingEventItem1.pse__Category__c='Miscellaneous Adjustment';
        oBillingEventItem1.pse__Billing_Event__c = oBillingEvent.Id;
        oBillingEventItem1.pse__Quantity__c = 1;
        lstBillingEventItem.add(oBillingEventItem1);
        pse__Billing_Event_Item__c oBillingEventItem2 = new pse__Billing_Event_Item__c();
        oBillingEventItem2.pse__Object_Id__c=lstMiscellaneousAdjustment[1].Id;
        oBillingEventItem2.pse__Miscellaneous_Adjustment__c=lstMiscellaneousAdjustment[1].Id;
        oBillingEventItem1.pse__Category__c='Miscellaneous Adjustment';
        oBillingEventItem2.pse__Billing_Event__c = oBillingEvent.Id;
        oBillingEventItem2.pse__Quantity__c = 1;
        lstBillingEventItem.add(oBillingEventItem2);
        insert lstBillingEventItem;
        
        
        
        oBillingEvent.pse__Is_Released__c = true;
        
        for(pse__Billing_Event_Item__c oBillingEventItem:[Select Id,pse__Object_Id__c,pse__Category__c,pse__Miscellaneous_Adjustment__c,pse__Milestone__c,pse__Timecard_Split__c,pse__Budget__c,pse__Expense__c From pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :oBillingEvent.Id]){
            system.debug('oBillingEventItem:'+oBillingEventItem);
            system.debug('oBillingEventItem.pse__Object_Id__c:'+oBillingEventItem.pse__Object_Id__c);
            system.debug('oBillingEventItem.pse__Miscellaneous_Adjustment__c:'+oBillingEventItem.pse__Miscellaneous_Adjustment__c);
            system.debug('oBillingEventItem.pse__Milestone__c: '+oBillingEventItem.pse__Milestone__c);
            system.debug('oBillingEventItem.pse__Timecard_Split__c: '+oBillingEventItem.pse__Timecard_Split__c);
            system.debug('oBillingEventItem.pse__Budget__c: '+oBillingEventItem.pse__Budget__c);
            system.debug('oBillingEventItem.pse__Expense__c: '+oBillingEventItem.pse__Expense__c);
            system.debug('oBillingEventItem.pse__Category__c: '+oBillingEventItem.pse__Category__c);
        }
        
        //update oBillingEvent;
        //BillingEventBatch oBillingEventBatch= new BillingEventBatch();
        //database.executeBatch(oBillingEventBatch);
        
        Test.stopTest();
    }
    
}