@isTest(seeAllData = false)
public class TestInterlockTrigger {
    @testSetup
    static void setupObjectTestData() 
    {
     try {
            CollaborationGroup objSMGChatterGroup = new CollaborationGroup();
            objSMGChatterGroup.Name = 'SMG';
            objSMGChatterGroup.CollaborationType = 'Public';
            insert objSMGChatterGroup;
        } catch(Exception objException) {}
        
        
                Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.Knowledge__c = true;
        trigSetting.ProfileSkillUser__c = true;
        trigSetting.Interlock_trigger__c=true;
        insert trigSetting;
        
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');
        
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        UtilityTestData.mOpportunityData.put('CloseDate', String.valueOf(Date.today().addDays(120)));
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3Q41.17B6O}');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
         Id RecordTypeIdPS = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdPS);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        //List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        
        
        Id RecordTypeIdSMG = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId();
        Id RecordTypeIdPresales = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('PreSales').getRecordTypeId();
        Id RecordTypeIdCST = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdSMG);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        //List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
        Related_Opportunity_Plan__c interlock1=new Related_Opportunity_Plan__c();
        interlock1.Plan__c=lPlan[0].id;
        interlock1.Account__c=lAccount[0].id;
        interlock1.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock1.recordtypeid=RecordTypeIdSMG;
        interlock1.Ignore_ABV__c=true;
        
        Related_Opportunity_Plan__c interlock2=new Related_Opportunity_Plan__c();
         interlock2.Plan__c=lPlan[0].id;
        interlock2.Account__c=lAccount[0].id;
        interlock2.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock2.recordtypeid=RecordTypeIdPS;
        interlock2.Interlock_Type__c='Jumpstart';
        interlock2.Ignore_ABV__c=true;
        
        
                Related_Opportunity_Plan__c interlock3=new Related_Opportunity_Plan__c();
         interlock3.Plan__c=lPlan[0].id;
        interlock3.Account__c=lAccount[0].id;
        interlock3.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock3.recordtypeid=RecordTypeIdPresales;
        interlock3.Interlock_Type__c='Jumpstart';
        interlock3.Ignore_ABV__c=true;
        
        
                Related_Opportunity_Plan__c interlock4=new Related_Opportunity_Plan__c();
         interlock4.Plan__c=lPlan[0].id;
        interlock4.Account__c=lAccount[0].id;
        interlock4.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock4.recordtypeid=RecordTypeIdCST;
        interlock4.Interlock_Type__c='Jumpstart';
        interlock4.Ignore_ABV__c=true;
        
        
        
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 =new List<Related_Opportunity_Plan__c>();
        lRelatedopportunityPlan2.add(interlock1);
        lRelatedopportunityPlan2.add(interlock2);
        lRelatedopportunityPlan2.add(interlock3);
        lRelatedopportunityPlan2.add(interlock4);
        
        insert lRelatedopportunityPlan2;
    }
       static testMethod void testInterlockTrigger() {
        try {
            CollaborationGroup objSMGChatterGroup = new CollaborationGroup();
            objSMGChatterGroup.Name = 'SMG';
            objSMGChatterGroup.CollaborationType = 'Public';
            insert objSMGChatterGroup;
        } catch(Exception objException) {}
        
         test.startTest();
        Bypass_Trigger_Settings__c trigSetting = [select id from Bypass_Trigger_Settings__c limit 1];
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');
        
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        UtilityTestData.mOpportunityData.put('CloseDate', String.valueOf(Date.today().addDays(120)));
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3Q41.17B6O}');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
         Id RecordTypeIdPS = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdPS);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        //List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        
        
        Id RecordTypeIdSMG = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId();
        Id RecordTypeIdPresales = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('PreSales').getRecordTypeId();
        Id RecordTypeIdCST = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdSMG);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        //List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
        Related_Opportunity_Plan__c interlock1=new Related_Opportunity_Plan__c();
        interlock1.Plan__c=lPlan[0].id;
        interlock1.Account__c=lAccount[0].id;
        interlock1.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock1.recordtypeid=RecordTypeIdSMG;
        interlock1.Ignore_ABV__c=true;
        
        Related_Opportunity_Plan__c interlock2=new Related_Opportunity_Plan__c();
         interlock2.Plan__c=lPlan[0].id;
        interlock2.Account__c=lAccount[0].id;
        interlock2.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock2.recordtypeid=RecordTypeIdPS;
        interlock2.Interlock_Type__c='Jumpstart';
        interlock2.Ignore_ABV__c=true;
        
        
                Related_Opportunity_Plan__c interlock3=new Related_Opportunity_Plan__c();
         interlock3.Plan__c=lPlan[0].id;
        interlock3.Account__c=lAccount[0].id;
        interlock3.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock3.recordtypeid=RecordTypeIdPresales;
        interlock3.Interlock_Type__c='Jumpstart';
        interlock3.Ignore_ABV__c=true;
        
        
                Related_Opportunity_Plan__c interlock4=new Related_Opportunity_Plan__c();
         interlock4.Plan__c=lPlan[0].id;
        interlock4.Account__c=lAccount[0].id;
        interlock4.Opportunity__c=lOpportunity[0].id;
       // interlock1.Thread_Id__c='Ref{00DL.5y0LE:a3qL.10q1u}';
        interlock4.recordtypeid=RecordTypeIdCST;
        interlock4.Interlock_Type__c='Jumpstart';
        interlock4.Ignore_ABV__c=true;
        
        
        
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 =new List<Related_Opportunity_Plan__c>();
        lRelatedopportunityPlan2.add(interlock1);
        lRelatedopportunityPlan2.add(interlock2);
        lRelatedopportunityPlan2.add(interlock3);
        lRelatedopportunityPlan2.add(interlock4);
        
        insert lRelatedopportunityPlan2;
        test.stopTest(); 
       }
      static testMethod void testInterlockTrigger1() {
        
        
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 = [select id from Related_Opportunity_Plan__c];
        
        delete lRelatedopportunityPlan2;
        }

}