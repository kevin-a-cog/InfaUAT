@isTest
public class psa_BEI_QLI_ControllerTest {
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Billing_Event_Trigger__c = true;
        insert trigSetting;

        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;

        Global_Config__c globalSettings = Global_Config__c.getOrgDefaults();
        globalSettings.Mute_Triggers__c = true;
        upsert globalSettings Global_Config__c.Id;
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
        UtilityTestData.mRegion.put('pse__Region_Name_Chain__c','APJ');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        UtilityTestData.mRegion.put('pse__Region_Name_Chain__c','APJ');
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
            UtilityTestData.mProjectData.put('pse__Region__c',lRegion[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            pse__Budget__c bud = new pse__Budget__c();
            bud.pse__Project__c = lProject[0].Id;
            bud.pse__Amount__c = 10000;
            bud.pse__Type__c = 'Customer Purchase Order Change Request';
            bud.CurrencyIsoCode = 'USD';
            bud.pse__Opportunity__c = lOpportunity[0].Id;
            bud.pse__Status__c = 'Approved';
            bud.pse__Approved__c = TRUE;
            bud.pse__Include_In_Financials__c = TRUE;
            insert bud;
            
            Test.startTest();
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);//
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            OpportunityLineItem oppLineItem = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            oppLineItem.SBQQ__QuoteLine__c = lSBQuoteLine[0].Id;
            update oppLineItem;
            
            list<pse__Miscellaneous_Adjustment__c> lstMiscellaneousAdjustment = new list<pse__Miscellaneous_Adjustment__c>();
            pse__Miscellaneous_Adjustment__c oMiscellaneousAdjustment1 = new pse__Miscellaneous_Adjustment__c();
            oMiscellaneousAdjustment1.Name = 'MA1';
            oMiscellaneousAdjustment1.pse__Effective_Date__c = system.today();
            oMiscellaneousAdjustment1.pse__Project__c = lProject[0].Id;
            oMiscellaneousAdjustment1.pse__Amount__c = 100;
            oMiscellaneousAdjustment1.pse__Transaction_Category__c = 'Ready-to-Bill Revenue';
            oMiscellaneousAdjustment1.PSA_OM_PO_Number__c = 'PO121211';
            lstMiscellaneousAdjustment.add(oMiscellaneousAdjustment1);
            
            pse__Miscellaneous_Adjustment__c oMiscellaneousAdjustment2 = new pse__Miscellaneous_Adjustment__c();
            oMiscellaneousAdjustment2.Name = 'MA2';
            oMiscellaneousAdjustment2.pse__Effective_Date__c = system.today();
            oMiscellaneousAdjustment2.pse__Project__c = lProject[0].Id;
            oMiscellaneousAdjustment2.pse__Amount__c = 100;
            oMiscellaneousAdjustment2.pse__Transaction_Category__c = 'Ready-to-Bill Revenue';
            oMiscellaneousAdjustment2.PSA_OM_PO_Number__c = 'PO121212';
            lstMiscellaneousAdjustment.add(oMiscellaneousAdjustment2);
            insert lstMiscellaneousAdjustment;

            List<pse__Billing_Event__c> beList = new List<pse__Billing_Event__c>();
            pse__Billing_Event__c oBillingEvent = new pse__Billing_Event__c();
            oBillingEvent.pse__Project__c = lProject[0].Id;
            beList.add(oBillingEvent);

            pse__Billing_Event__c oBillingEvent1 = new pse__Billing_Event__c();
            oBillingEvent1.pse__Project__c = lProject[0].Id;
            beList.add(oBillingEvent1);

            insert beList;
            
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
            Test.stopTest();
        }
    }
    @isTest
    private static void test_fetchColumnDetails() {
        Test.startTest();
        pse__Billing_Event_Item__c beItem = [SELECT Id,pse__Billing_Event__c FROM pse__Billing_Event_Item__c LIMIT 1];     
        OpportunityLineItem oli = [SELECT Id,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.Name FROM OpportunityLineItem LIMIT 1];
        pse__Budget__c budget = [SELECT Id,Name FROM pse__Budget__c LIMIT 1];
        Product2 product = [SELECT Id,Name FROM Product2 LIMIT 1];
        List<psa_BEI_QLI_Controller.QuoteLinewrapper> result = psa_BEI_QLI_Controller.fetchColumnDetails(beItem.pse__Billing_Event__c);
        Test.stopTest();
    }
    //When there is no billing event items for the billing event
    @isTest
    private static void test_fetchColumnDetailsErrorMsg1() {
        Test.startTest();
        pse__Billing_Event__c billingEvent = [SELECT Id FROM pse__Billing_Event__c WHERE Id NOT IN (SELECT pse__Billing_Event__c FROM pse__Billing_Event_Item__c) LIMIT 1];     
        List<psa_BEI_QLI_Controller.QuoteLinewrapper> result = psa_BEI_QLI_Controller.fetchColumnDetails(billingEvent.Id);
        Assert.areEqual('No Billing Event Item record found', result[0].errorMsg);
        Test.stopTest();
    }
     //When there is matching budget but no Oppty Product
    @isTest
    private static void test_fetchColumnDetailsErrorMsg2() {
        Test.startTest();
        pse__Billing_Event_Item__c beItem = [SELECT Id,pse__Billing_Event__c FROM pse__Billing_Event_Item__c LIMIT 1];     
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        delete oliList;
        List<psa_BEI_QLI_Controller.QuoteLinewrapper> result = psa_BEI_QLI_Controller.fetchColumnDetails(beItem.pse__Billing_Event__c);
        Assert.areEqual('No opportunity product is found for the matching budget', result[0].errorMsg);
        Test.stopTest();
    }    
     //When there is billing event items for the billing event but no matching budget
     @isTest
     private static void test_fetchColumnDetailsErrorMsg3() {
         Test.startTest();
         pse__Billing_Event_Item__c beItem = [SELECT Id,pse__Billing_Event__c FROM pse__Billing_Event_Item__c LIMIT 1];     
         pse__Budget__c budget = [SELECT Id,Name FROM pse__Budget__c LIMIT 1];
         delete budget;
         List<psa_BEI_QLI_Controller.QuoteLinewrapper> result = psa_BEI_QLI_Controller.fetchColumnDetails(beItem.pse__Billing_Event__c);
         Assert.areEqual('No budget matching the criteria found', result[0].errorMsg);
         Test.stopTest();
     }   
    @isTest
    private static void test_updateBillingEventItems() {
        Test.startTest();
        pse__Billing_Event__c billingEvent = [SELECT Id FROM pse__Billing_Event__c LIMIT 1];
        pse__Billing_Event_Item__c bei = [SELECT Id FROM pse__Billing_Event_Item__c LIMIT 1];

        Id quoteLineId = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1].Id;
        
        String result = psa_BEI_QLI_Controller.updateBillingEventItems(billingEvent.Id, quoteLineId);
        Test.stopTest();
        
        System.assertEquals('SUCCESS', result);
        
        bei = [SELECT CR_Quote_Line_Item__c FROM pse__Billing_Event_Item__c WHERE Id = :bei.Id];
        System.assertEquals(bei.CR_Quote_Line_Item__c, quoteLineId);
    }

    @isTest
    private static void test_areChildRecordsEqual(){
        
        pse__Billing_Event__c billingEvent = [SELECT Id FROM pse__Billing_Event__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        List<pse__Billing_Event_Item__c> bei = [SELECT Id FROM pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :billingEvent.Id];
        bei[0].CR_Quote_Line_Item__c = quoteLine.Id;
        bei[1].CR_Quote_Line_Item__c = quoteLine.Id;
        update bei;
        Test.startTest();
        Boolean result1 = psa_BEI_QLI_Controller.areChildRecordsEqual(billingEvent.Id);
        Test.stopTest();
        System.assertEquals(true, result1);
    }

    @isTest
    private static void test_areChildRecordsNotEqual(){
        pse__Billing_Event__c billingEvent = [SELECT Id FROM pse__Billing_Event__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        List<pse__Billing_Event_Item__c> bei = [SELECT Id FROM pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :billingEvent.Id];
        bei[0].CR_Quote_Line_Item__c = quoteLine.Id;
        bei[1].CR_Quote_Line_Item__c = null;
        update bei;
        Test.startTest();
        Boolean result1 = psa_BEI_QLI_Controller.areChildRecordsEqual(billingEvent.Id);
        Test.stopTest();
        System.assertEquals(false, result1);
    }
}