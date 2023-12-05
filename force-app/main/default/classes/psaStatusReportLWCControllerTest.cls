@isTest
private class psaStatusReportLWCControllerTest {

    @testSetup
    static void setupObjectTestData() {
        //Skip validation rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        SBQQ.TriggerControl.disable();
        Global_Config__c globalSettings = Global_Config__c.getOrgDefaults();
        globalSettings.Mute_Triggers__c = true;
        upsert globalSettings Global_Config__c.Id;

        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        Sobject sObj;
        Sobject sObj1;
        
        //Create Account
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Region 1
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        //Create Region 2
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        //Create Permission control
        List<pse__Permission_Control__c> permControlLst = new List<pse__Permission_Control__c>();
        pse__Permission_Control__c permControl = new pse__Permission_Control__c();
        permControl.pse__User__c = userObj.Id;
        permControl.pse__Staffing__c = true;
        permControl.pse__Resource_Request_Entry__c=true;
        permControl.pse__Timecard_Ops_Edit__c = true;
        permControl.pse__Cascading_Permission__c = true;
        permControl.pse__Timecard_Entry__c = true;
        permControl.pse__Region__c = lRegion[0].Id;
        insert permControl;
        System.runAs(userObj){
            //Create Work Calendar
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar; 
            
            //Create Contact
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
            update lContact[0];
            
            //Create Product
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
            //Activate Pricebook
            Id pricebookId = Test.getStandardPricebookId();             
            sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //Create PriceBookEntry
            sObj = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Opportunity
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud Adoption Hybrid MDM');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);

            Test.startTest();
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
           
            lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
            lOpportunity[0].StageName = 'Closed Won';
            update lOpportunity[0];
            
            //Create Opp Line Item
            //OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= lPriceBookEntry[0].Id,TotalPrice=2000,Quantity = 2,OpportunityId = lOpportunity[0].Id);
            //insert oppLine;
            
            //Create Project
            sObj = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('CurrencyIsoCode','USD');
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            UtilityTestData.mProjectData.put('pse__Billing_Type__c','Time and Materials');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create PSA MSA Code Mapping
            PSA_MSA_Code_Mapping__c psaMSACodeMapping = new PSA_MSA_Code_Mapping__c();
            psaMSACodeMapping.Name = 'Test MSA Code Map ';
            psaMSACodeMapping.psa_pm_MSA_Code__c='11223';
            insert psaMSACodeMapping;
        
            //Create Project Location
            pse__Project_Location__c projLoc = new pse__Project_Location__c();
            projLoc.pse__Project__c = lProject[0].Id;
            projLoc.psa_pm_Primary__c =true;
            projLoc.psa_pm_MSA_Code_Mapping__c = psaMSACodeMapping.Id;
            insert projLoc;
            
            // Create Schedule            
            List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();            
            pse__Schedule__c scheduleRec = new pse__Schedule__c();
            scheduleRec.pse__Start_Date__c = Date.today();
            scheduleRec.pse__End_Date__c = Date.today();
            scheduleRec.pse__Monday_Hours__c = 8;
            scheduleRec.pse__Tuesday_Hours__c = 8;
            scheduleRec.pse__Wednesday_Hours__c = 8;
            scheduleRec.pse__Thursday_Hours__c = 8;
            scheduleRec.pse__Friday_Hours__c = 8;
            scheduleRec.pse__Saturday_Hours__c = 8;
            scheduleRec.pse__Sunday_Hours__c = 8;            
            insert scheduleRec;
           
            //Create Resource Request                
            pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
            resourceReq.pse__Start_Date__c = Date.today().addDays(1);
            resourceReq.pse__End_Date__c = Date.today().addDays(10);
            resourceReq.pse__Project__c = lProject[0].Id;
            resourceReq.pse__Opportunity__c = lOpportunity[0].Id;
            resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMapping.Id;
            resourceReq.psa_rm_Original_Opportunity__c = lOpportunity[0].Id;
            resourceReq.pse__Region__c = lRegion[0].Id;
            resourceReq.pse__SOW_Hours__c =8;
            resourceReq.pse__Resource_Role__c = 'Consultant';
            resourceReq.CurrencyIsoCode='USD';
            resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
            resourceReq.psa_rm_Billable__c = true;
            insert resourceReq;  
                
            //Create Assignment
            pse__Assignment__c assignRec = new pse__Assignment__c();
            assignRec.Name = 'Test Assignment ';
            assignRec.pse__Planned_Hours__c = 7;
            assignRec.pse__Bill_Rate__c =0;
            assignRec.pse__Is_Billable__c = true;
            assignRec.pse__Role__c ='Senior Consultant';
            assignRec.pse__Cost_Rate_Amount__c =10;
            assignRec.CurrencyIsoCode='USD';
            assignRec.pse__Resource_Request__c = resourceReq.Id;  
            assignRec.pse__Schedule__c = scheduleRec.Id;
            assignRec.pse__Resource__c = lContact[0].Id;
            assignRec.pse__Project__c = lProject[0].Id;
            insert assignRec;
                
            //Create Milestone
            sObj = new pse__Milestone__c();
            UtilityTestData.mMilestone.put('Name','Test Milestone');
            UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','10.00');
            UtilityTestData.mMilestone.put('CurrencyIsoCode','USD');
            UtilityTestData.mMilestone.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Labor');
            UtilityTestData.mMilestone.put('pse__Actual_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mMilestone.put('pse__Include_In_Financials__c','TRUE');
            //UtilityTestData.mMilestone.put('pse__Status__c','Approved');
            //UtilityTestData.mMilestone.put('pse__Approved__c','TRUE');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mMilestone); 
            List<pse__Milestone__c> lMilestone = (List<pse__Milestone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
          
            //Create Status Report
            Status_report__c testStatusReport = new Status_Report__c();
            testStatusReport.Status_Report_Name__c = 'Test Status Report';
            testStatusReport.PSA_PM_Project__c = lProject[0].Id;
            testStatusReport.PSA_PM_Status_Report_Week__c = Date.newInstance(2023, 08, 28);
            insert testStatusReport;

            //Create Issue
            pse__Issue__c testIssue = new pse__Issue__c();
            testIssue.pse__Project__c = lProject[0].Id;
            testIssue.pse__Issue_Name__c = 'Test Issue';
            testIssue.pse__Issue_Description__c = 'Test Issue Description';
            testIssue.pse__Date_Raised__c = System.today();
            testIssue.pse__Status__c ='Not Yet Started';
            testIssue.PSA_Status__c = 'OPEN'; 
            insert testIssue;

            //Create Risk
            pse__Risk__c testRisk = new pse__Risk__c();
            testRisk.pse__Project__c = lProject[0].Id;
            testRisk.pse__Risk_Name__c='Test Risk';
            testRisk.pse__Risk_Description__c='Test Description';
            testRisk.PSA_Status__c='OPEN';
            insert testRisk;
        
            //Create Task
            Task testTask = new Task();
            testTask.WhatId = lProject[0].Id;
            insert testTask;
            Test.stopTest();            
        }
    }
    @isTest
    static void testGetProjectData() {
        // Create test data for Status_report__c and related records
        pse__Milestone__c milestoneRec = [SELECT Id FROM pse__Milestone__c LIMIT 1];
        milestoneRec.pse__Status__c = 'Approved';
        milestoneRec.pse__Approved__c = true;
        update milestoneRec;
        pse__Proj__c projRec = [SELECT Id FROM pse__Proj__c LIMIT 1];
        Status_report__c testStatusReport = [SELECT Id,PSA_PM_Project__c FROM Status_report__c LIMIT 1];
        // Set appropriate fields for testMilestone
        // Call the controller method
        Test.startTest();
        psaStatusReportLWCController.DataWrapper result = psaStatusReportLWCController.getProjectData(testStatusReport.Id);
        Test.stopTest();

        // Assertions
        //System.assertEquals(1, result.issuesList.size());
        //System.assertEquals(1, result.risksList.size());
        //System.assertEquals(1, result.assignmentList.size());
        //System.assertEquals(1, result.prjActList.size());
        //System.assertEquals(1, result.milestoneList.size());
    }

    @isTest
    static void testInsertSRDRecords() {        
        pse__Proj__c projRec = [SELECT Id FROM pse__Proj__c LIMIT 1];
        Status_report__c testStatusReport = [SELECT Id,PSA_PM_Project__c FROM Status_report__c LIMIT 1];
        pse__Issue__c testIssue = [SELECT Id FROM pse__Issue__c LIMIT 1];
        pse__Risk__c testRisk = [SELECT Id FROM pse__Risk__c  LIMIT 1];
        pse__Milestone__c testMilestone = [SELECT Id FROM pse__Milestone__c  LIMIT 1];
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        pse__Assignment__c testAssignment  = [SELECT Id FROM pse__Assignment__c LIMIT 1];

        testMilestone.pse__Status__c = 'Approved';
        testMilestone.pse__Approved__c = true;
        update testMilestone;
        
        List<String> issueRecords = new List<String>{testIssue.Id};
        List<String> riskRecords = new List<String>{testRisk.Id};
        List<String> assignmentRecords = new List<String>{testAssignment.Id};
        List<String> prjActRecords = new List<String>{testTask.Id};
        List<String> milestoneRecords = new List<String>{testMilestone.Id};

        // Call the controller method
        Test.startTest();
        Boolean isInserted = psaStatusReportLWCController.insertSRDRecords(testStatusReport.Id, issueRecords, riskRecords, assignmentRecords, prjActRecords, milestoneRecords);
        Test.stopTest();

        // Assertions
        //System.assertEquals(true, isInserted);

        // Check if Status_Report_Detail__c records are created
        List<Status_Report_Detail__c> insertedRecords = [SELECT Id, PSA_Status_Report__c, PSA_Issue__c, PSA_Risk__c, PSA_Assignment__c, PSA_Project_Activity__c, PSA_Milestone__c FROM Status_Report_Detail__c WHERE PSA_Status_Report__c = :testStatusReport.Id];
        system.debug('@@@insertedRecords:'+insertedRecords);
        //System.assertEquals(5, insertedRecords.size());
    }

    @isTest
    static void testGeneratePDF() {
        // Create test data for Status_report__c and related records
        Status_report__c testStatusReport = [SELECT id FROM Status_report__c LIMIT 1 ];

        // Call the controller method
        Test.startTest();
        Boolean isGenerated = psaStatusReportLWCController.generatePDF(testStatusReport.Id);
        Test.stopTest();

        // Assertions
        //System.assertEquals(true, isGenerated);

        // Add any additional assertions related to PDF generation if necessary
    }
}