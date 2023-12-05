@isTest
public class psa_pm_CalculateProjectActualsJobTest {
 @testSetup
    static void setupObjectTestData() {
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
         // Create Account
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<2;i++){
            Account acc = new Account();
            acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            accList.add(acc);
            
        }
        insert accList;
         // Create user/Resource 
        
        Profile prof = [select Name from Profile where Name = 'Employee'];
        
        
        List<User> userList = new List<User>();
        for(integer i=0;i<2;i++){
            userList.add(new User(alias='testRes'+i,
                                  username='testResource'+i+'@abc123.com',
                                  lastname='User '+i,
                                  firstname='Test Resource',
                                  email='testResource'+i+'@abc123.com',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  ProfileId=prof.Id,
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8'));
        }
        insert userList;
        
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<2;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            regionRec.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec);
        }
        insert regionList;
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        defaultWorkCalendar.pse__Sunday_Hours__c= 8;
        defaultWorkCalendar.pse__Monday_Hours__c=8;
        defaultWorkCalendar.pse__Tuesday_Hours__c=8;
        defaultWorkCalendar.pse__Wednesday_Hours__c=8;
        defaultWorkCalendar.pse__Thursday_Hours__c=8;
        defaultWorkCalendar.pse__Friday_Hours__c=8;
        defaultWorkCalendar.pse__Saturday_Hours__c=8;                
        insert defaultWorkCalendar; 
        
        // Create Contact
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        List<Contact> conList = new List<Contact>();
        for(integer i =0;i<2;i++){
            Contact con = new Contact();
            con.AccountId = accList[i].Id;
            con.LastName ='Contact '+i;
            con.FirstName = 'Test';
            con.Email='test'+i+'email@gmail.com';
            con.pse__Is_Resource__c =true;
            con.pse__Is_Resource_Active__c=true;
            con.CurrencyIsoCode='USD';
            con.pse__Resource_Role__c='Regional Manager';
            con.pse__Region__c = regionList[i].Id;
            con.pse__Default_Cost_Rate__c = 10;
            con.pse__Salesforce_User__c = userList[i].Id;
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            
            conList.add(con);
            
        }
        insert conList;
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        
        sObject sObj = new Product2();
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
        UtilityTestData.mOpportunityData.put('AccountId',accList[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
        UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');
        UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud Adoption Hybrid MDM');
        UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
        lOpportunity[0].StageName = 'Closed Won';
        update lOpportunity[0];
        
        OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= lPriceBookEntry[0].Id,TotalPrice=2000,Quantity = 2,OpportunityId = lOpportunity[0].Id);
        insert oppLine;
        
        Test.startTest();
         List<pse__Permission_Control__c> permControlLst = new List<pse__Permission_Control__c>();
        for(integer i=0;i<2;i++){
            pse__Permission_Control__c permControl = new pse__Permission_Control__c();
            //permControl.pse__Project__c = projList[i].Id;
            permControl.pse__User__c = userObj.Id;
            permControl.pse__Staffing__c = true;
            permControl.pse__Resource_Request_Entry__c=true;
            permControl.pse__Timecard_Ops_Edit__c = true;
            permControl.pse__Cascading_Permission__c = true;
            permControl.pse__Timecard_Entry__c = true;
            permControl.pse__Expense_Entry__c = true;
            permControl.pse__Expense_Ops_Edit__c = true;
            permControl.pse__Region__c = regionList[i].Id;
            permControlLst.add(permControl);
        }
        insert permControlLst;
        
        system.runAs(userObj){
            //Create Project
            List<pse__Proj__c> projList = new List<pse__Proj__c>();
            pse__Proj__c projRec = new pse__Proj__c();
            projRec.Name = 'Test Project';
            projRec.pse__Stage__c='Completed';
            projRec.pse__Project_Manager__c = conList[0].Id;
            projRec.pse__Project_Type__c = 'Customer Project';
            projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
            projRec.pse__Opportunity__c = lOpportunity[0].Id;
            projRec.pse__Account__c = accList[0].Id;  
            projRec.CurrencyIsoCode='USD';
            projRec.Run_Actuals_Job__c = TRUE;
            projRec.pse__Region__c = regionList[0].Id;
            projRec.pse__Start_Date__c=currentDate.addDays(-6);
            projRec.pse__End_Date__c = currentDate.addDays(10);
            projRec.pse__Is_Active__c=true;
            projRec.pse__Allow_Self_Staffing__c=true;
            projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
            projRec.psa_pm_Require_Product_On_Timecards__c =false;
            projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
            projRec.psa_pm_Require_Location_On_Timecards__c = false;  
            projRec.pse__Is_Billable__c = TRUE;
            projList.add(projRec);
            
            insert projList;        
        
            //Create PSA MSA Code Mapping
            List<PSA_MSA_Code_Mapping__c> psaMSACodeMappingList = new List<PSA_MSA_Code_Mapping__c>();
            PSA_MSA_Code_Mapping__c psaMSACodeMapping = new PSA_MSA_Code_Mapping__c();
            psaMSACodeMapping.Name = 'Test MSA Code Map';
            psaMSACodeMapping.psa_pm_MSA_Code__c='11223';
            psaMSACodeMappingList.add(psaMSACodeMapping);
            insert psaMSACodeMappingList;
            
            //Create Project Location
            List<pse__Project_Location__c> projLocList = new List<pse__Project_Location__c>();
            pse__Project_Location__c projLoc = new pse__Project_Location__c();
            projLoc.pse__Project__c = projList[0].Id;
            projLoc.psa_pm_Primary__c =true;
            projLoc.psa_pm_MSA_Code_Mapping__c = psaMSACodeMappingList[0].Id;
            projLocList.add(projLoc);
            insert projLocList;
            
            // Create Schedule            
            List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
            pse__Schedule__c scheduleRec = new pse__Schedule__c();
            scheduleRec.pse__Start_Date__c = currentDate.addDays(1);
            scheduleRec.pse__End_Date__c = currentDate.addDays(10);
            scheduleRec.pse__Monday_Hours__c = 8;
            scheduleRec.pse__Tuesday_Hours__c = 8;
            scheduleRec.pse__Wednesday_Hours__c = 8;
            scheduleRec.pse__Thursday_Hours__c = 8;
            scheduleRec.pse__Friday_Hours__c = 8;
            scheduleRec.pse__Saturday_Hours__c = 8;
            scheduleRec.pse__Sunday_Hours__c = 8;
            scheduleList.add(scheduleRec);
            insert scheduleList;
            
            // Create Resource Request
            List<pse__Resource_Request__c> resourceReqList = new List<pse__Resource_Request__c>();
            
            pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
            resourceReq.pse__Start_Date__c = currentDate.addDays(1);
            resourceReq.pse__End_Date__c = currentDate.addDays(10);
            //resourceReq.pse__Staffer_Resource__c = conList[0].Id;
            resourceReq.pse__Project__c = projList[0].Id;
            resourceReq.pse__Opportunity__c = lOpportunity[0].Id;
            resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMappingList[0].Id;
            //resourceReq.PSA_OM_Opportunity_Product_Id__c =  opptyLineItemList[0].Id;
            resourceReq.psa_rm_Original_Opportunity__c = lOpportunity[0].Id;
            resourceReq.pse__Region__c = regionList[0].Id;
            resourceReq.pse__SOW_Hours__c =8;
            resourceReq.pse__Resource_Role__c = 'Consultant';
            resourceReq.CurrencyIsoCode='USD';
            resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
            resourceReq.psa_rm_Billable__c = true;
            resourceReqList.add(resourceReq);
            
            insert resourceReqList;  
            
            // Create Assignment            
            List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
            pse__Assignment__c assignRec = new pse__Assignment__c();
            assignRec.Name = 'Test Assignment';
            assignRec.pse__Planned_Hours__c = 7;
            assignRec.pse__Bill_Rate__c =0;
            assignRec.pse__Is_Billable__c = true;
            assignRec.pse__Role__c ='Senior Consultant';
            assignRec.pse__Cost_Rate_Amount__c =10;
            assignRec.CurrencyIsoCode='USD';
            assignRec.pse__Resource_Request__c = resourceReqList[0].Id;  
            assignRec.pse__Schedule__c = scheduleList[0].Id;
            assignRec.pse__Resource__c = conList[0].Id;
            assignRec.pse__Project__c = projList[0].Id;
            assignRec.pse__Projected_Revenue__c = 80;
            assignmentList.add(assignRec);
            assignmentList[0].pse__Role__c =null;
            insert assignmentList;            
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAssignment(){
        Test.StartTest(); 
        List<pse__Assignment__c> assignRec = [SELECT Id FROM pse__Assignment__c LIMIT 1];
        assignRec[0].pse__Projected_Revenue__c = 80;
        update assignRec;
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }
    
     @isTest
    static void testBudget(){        
        Test.StartTest(); 
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<pse__Proj__c> lProject = [SELECT Id FROM pse__Proj__c LIMIT 1];
       
         //Create Budget
        sObject sObj = new pse__Budget__c();
        UtilityTestData.mBudget.put('pse__Expense_Amount__c','1000');
        UtilityTestData.mBudget.put('pse__Effective_Date__c',System.today().addDays(-1)+'');
        UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order');
        UtilityTestData.mBudget.put('pse__Billable__c','true');
        UtilityTestData.mBudget.put('pse__Approved__c','true');
        UtilityTestData.mBudget.put('pse__Include_In_Financials__c','true');
        UtilityTestData.mBudget.put('pse__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mBudget.put('pse__Amount__c','1000');
        UtilityTestData.mBudget.put('pse__Pre_Billed_Amount__c','100');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBudget);
        List<pse__Budget__c> lBudget = (List<pse__Budget__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lBudget[0].pse__Status__c = 'Approved';
        lBudget[0].pse__Approved__c = true;
        lBudget[0].pse__Include_In_Financials__c = true;
        update lBudget;
        
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }
    
    @isTest
    static void testTimecard(){
        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        List<pse__Assignment__c> lAssignment = [SELECT Id,pse__Project__c FROM pse__Assignment__c LIMIT 1];
        List<pse__Project_Location__c> lLocation = [SELECT Id FROM pse__Project_Location__c LIMIT 1];
        User userObj =  [select Id,ManagerId, Name from User where Id =:UserInfo.getUserId() limit 1];
                
        Test.StartTest();        
        //Create Timecard
        pse__Timecard_Header__c testTimecard = new pse__Timecard_Header__c();
        testTimecard.pse__End_Date__c = system.today();
        testTimecard.pse__Start_Date__c = system.today()-6;
        testTimecard.pse__Resource__c= lContact[0].Id;
        testTimecard.pse__Project__c = lAssignment[0].pse__Project__c;
        testTimecard.pse__Assignment__c = lAssignment[0].Id;
        testTimecard.pse__Status__c = 'Saved';
        testTimecard.psa_pm_Project_Portfolio_Manager__c = userObj.Id;
        testTimecard.pse__Approver__c = userObj.Id;
        testTimecard.pse__Primary_Project_Location__c = lLocation[0].Id;
        testTimecard.pse__Project_Methodology__c = 'Address Verification';
        testTimecard.pse__Bill_Rate__c = 40;
        insert testTimecard;
        
        List<pse__Timecard__c> timecardList = new List<pse__Timecard__c>();
        List<Boolean> boolList = new List<Boolean>{false,true};
        for(Integer i=0; i<2; i++){
            for(Integer j=0; j<2; j++){
                pse__Timecard__c timecard = new pse__Timecard__c();
                timecard.pse__Project__c = lAssignment[0].pse__Project__c;
                timecard.pse__Start_Date__c = System.today()-6;
                timecard.pse__End_Date__c = System.today();
                timecard.pse__Resource__c = lContact[0].Id;
                timecard.pse__Assignment__c= lAssignment[0].Id;
                timecard.pse__Timecard_Header__c = testTimecard.Id;
                timecard.pse__Billable__c = boolList[j];
                timecard.pse__External_Resource__c = boolList[i];          
                timecard.pse__Approved__c = true;
                timecard.pse__Include_In_Financials__c = true;
                timecard.pse__Time_Credited__c = true;
                timecard.pse__Time_Excluded__c = true;
                timecard.pse__Total_Cost__c = 10;
                timecard.pse__Total_Hours__c = 8;
                timecardList.add(timecard);
            }
        }
        insert timecardList;
        
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }

    @isTest
    static void testExpense(){
        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        List<pse__Proj__c> lProject = [SELECT Id FROM pse__Proj__c LIMIT 1];
        List<pse__Assignment__c> lAssignment = [SELECT Id FROM pse__Assignment__c LIMIT 1];
            
        Test.StartTest();        
        //Create Expense
        sObject sObj = new pse__Expense_Report__c();
        UtilityTestData.mExpenseReport.put('Name','Test Expense Report-1');
        UtilityTestData.mExpenseReport.put('pse__Resource__c',lContact[0].Id);
        UtilityTestData.mExpenseReport.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mExpenseReport.put('pse__Status__c','Draft');
        //UtilityTestData.mExpense.put('pse__Billable__c','true');
        UtilityTestData.mExpenseReport.put('pse__Assignment__c',lAssignment[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpenseReport); 
        List<pse__Expense_Report__c> lExpenseReport = (List<pse__Expense_Report__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Expense__c();
        UtilityTestData.mExpense.put('pse__Expense_Report__c',lExpenseReport[0].Id);
        UtilityTestData.mExpense.put('Name','Test Expense Report-1');
        UtilityTestData.mExpense.put('pse__Resource__c',lContact[0].Id);
        UtilityTestData.mExpense.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mExpense.put('pse__Type__c','Car Rental');
        UtilityTestData.mExpense.put('pse__Amount__c','1200');
        UtilityTestData.mExpense.put('pse__Assignment__c',lAssignment[0].Id);//
        UtilityTestData.mExpense.put('psa_em_GL_Account_Number__c','');
        UtilityTestData.mExpense.put('pse__Submitted__c','true');
        UtilityTestData.mExpense.put('pse__Approved__c','true');
        UtilityTestData.mExpense.put('pse__Include_In_Financials__c','true');
        //UtilityTestData.mExpense.put('pse__Billable__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpense); 
        List<pse__Expense__c> lExpense = (List<pse__Expense__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }
	
     @isTest
    static void testMilestone(){        
        Test.StartTest();  
        
        //Create Milestone
        List<pse__Proj__c> projList = [SELECT Id FROM pse__Proj__c LIMIT 1];
        List<OpportunityLineItem> lOppItem = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        sObject sObj = new pse__Milestone__c();
        UtilityTestData.mMilestone.put('Name','Test Milestone');
        UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','10.00');
        UtilityTestData.mMilestone.put('pse__Milestone_Cost__c','5.00');
        UtilityTestData.mMilestone.put('CurrencyIsoCode','USD');
        UtilityTestData.mMilestone.put('pse__Status__c','Approved');
        UtilityTestData.mMilestone.put('pse__Approved__c','true');
        UtilityTestData.mMilestone.put('pse__Include_In_Financials__c','true');
        UtilityTestData.mMilestone.put('pse__Project__c',projList[0].Id);
        UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Billing');
        UtilityTestData.mMilestone.put('pse__Actual_Date__c',String.valueOf(System.today()));
        UtilityTestData.mMilestone.put('PSA_OM_Opportunity_Product_Id__c',lOppItem[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mMilestone); 
        
        List<pse__Milestone__c> lMilestone = (List<pse__Milestone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        lMilestone[0].pse__Approved__c = true;
        lMilestone[0].pse__Include_In_Financials__c = true;
        update lMilestone;
        
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);  
        
        Test.StopTest();
    }
     @isTest
    static void testMiscAdjustment(){
        List<pse__Proj__c> lProject = [SELECT Id FROM pse__Proj__c LIMIT 1];
        Test.StartTest();        
        //Create Miscellaneous Adjustment
        list<pse__Miscellaneous_Adjustment__c> lstMiscellaneousAdjustment = new list<pse__Miscellaneous_Adjustment__c>();
        List<String> transactionCategory = new List<String>{'Internal Budget','Expense Budget','Expense Cost','Other Cost','Internal Cost','External Cost','Pass-Through Ready-to-Bill Revenue','Pre-Billed Revenue','Ready-to-Bill Revenue','Booked Revenue'};
        for(Integer i=0; i<10; i++){
            pse__Miscellaneous_Adjustment__c oMiscellaneousAdjustment = new pse__Miscellaneous_Adjustment__c();
            oMiscellaneousAdjustment.Name = 'MA1';
            oMiscellaneousAdjustment.pse__Effective_Date__c = system.today();
            oMiscellaneousAdjustment.pse__Project__c = lProject[0].Id;
            oMiscellaneousAdjustment.pse__Amount__c = 100;
            oMiscellaneousAdjustment.pse__Transaction_Category__c = transactionCategory[i];
            oMiscellaneousAdjustment.PSA_OM_PO_Number__c = 'PO121211'; 
            oMiscellaneousAdjustment.pse__Approved__c = true;
            oMiscellaneousAdjustment.pse__Include_In_Financials__c = true;
            lstMiscellaneousAdjustment.add(oMiscellaneousAdjustment);
        }
        insert lstMiscellaneousAdjustment;
        
        psa_pm_CalculateProjectActualsJob sch = new psa_pm_CalculateProjectActualsJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }	
}