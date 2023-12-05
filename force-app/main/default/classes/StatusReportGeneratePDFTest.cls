/*
@created by       : RANJAN KISHORE
@created on       : 02/17/2021
@Purpose          : This test class provides code coverage to the Class "StatusReportGeneratePDF"

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public class StatusReportGeneratePDFTest {
    
    @testSetup
    static void initializeData(){
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
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
        
        
        // Create Region
        
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<2;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            //regionRec.psa_pm_Territory_ID_Mapping__c = '1234'+i;
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
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            
            conList.add(con);
            
        }
        insert conList;
        
        // Create Product
        List<Product2> prodList = new List<Product2>();
        for(integer i=0;i<2;i++){
            Product2 prodRec = new Product2();
            prodRec.Name = 'Test Product '+i;
            prodRec.Offering_Type__c='Professional Services';
            prodList.add(prodRec);
        }
        insert prodList;
        
        // Get the Standard price book Id and create active pricebook.
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 priceBookRec = new Pricebook2();
        priceBookRec.Id = pricebookId;
        priceBookRec.IsActive = True;
        
        update priceBookRec;
        
        // Create Pricebook Entry
        List<pricebookEntry> priceBookEntryList = new List<pricebookEntry>();
        for(integer i=0;i<2;i++){
            pricebookEntry pbEntry = new pricebookEntry();
            pbEntry.Pricebook2Id = priceBookRec.Id;
            pbEntry.Product2Id = prodList[i].Id;
            pbEntry.UnitPrice=100;
            pbEntry.CurrencyIsoCode='USD';
            pbEntry.IsActive=true;
            priceBookEntryList.add(pbEntry);
        }
        insert priceBookEntryList; 
        
        
        
        
         Test.startTest();
        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<2;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = accList[i].Id;
            oppty.CurrencyIsoCode='USD';
            oppty.Type='Direct';
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identity';
            oppty.psa_om_Start_Date__c = currentDate;
            oppty.psa_om_End_Date__c = currentDate.addDays(10);
            oppty.PSA_OM_Project_Type__c = 'JumpStart';
            oppty.psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM';
            oppty.Sales_Play__c='Data Quality';
            opptyList.add(oppty);
            
        }
        insert opptyList; 
        
        opptyList[0].Pricebook2Id = priceBookEntryList[0].Pricebook2Id;
        opptyList[1].Pricebook2Id = priceBookEntryList[1].Pricebook2Id;
        update  opptyList;
        
        // Create OpportunityLineItem 
        List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>();
        for(integer i=0;i<2;i++){
            OpportunityLineItem opptyLineItem = new OpportunityLineItem();
            opptyLineItem.pricebookentryid = priceBookEntryList[i].Id;
            opptyLineItem.TotalPrice = 2000;
            opptyLineItem.Quantity =2;
            opptyLineItem.OpportunityId = opptyList[i].Id;
            opptyLineItemList.add(opptyLineItem);
        }
        insert opptyLineItemList;
        //Create Permission Control
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
            permControl.pse__Region__c = regionList[i].Id;
            permControlLst.add(permControl);
        }
        insert permControlLst;
         Test.stopTest();
        // Create Project
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        for(integer i=0;i<2;i++){
            pse__Proj__c projRec = new pse__Proj__c();
            projRec.Name = 'Test Project '+i;
            projRec.pse__Project_Manager__c = conList[i].Id;
            projRec.pse__Project_Type__c = 'Customer Project';
            projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
            projRec.pse__Opportunity__c = opptyList[i].Id;
            projRec.pse__Account__c = accList[i].Id;  
            projRec.CurrencyIsoCode='USD';
            projRec.pse__Region__c = regionList[i].Id;
            projRec.pse__Start_Date__c=currentDate.addDays(-6);
            projRec.pse__End_Date__c = currentDate.addDays(10);
            projRec.pse__Is_Active__c=true;
            projRec.pse__Allow_Self_Staffing__c=true;
            projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
            projRec.psa_pm_Require_Product_On_Timecards__c =false;
            projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
            projRec.psa_pm_Require_Location_On_Timecards__c = false;
            
            projList.add(projRec);
            
        }
        insert projList;
        
        
        
        // create PSA MSA Code Mapping
        List<PSA_MSA_Code_Mapping__c> psaMSACodeMappingList = new List<PSA_MSA_Code_Mapping__c>();
        for(integer i=0;i<2;i++){
            PSA_MSA_Code_Mapping__c psaMSACodeMapping = new PSA_MSA_Code_Mapping__c();
            psaMSACodeMapping.Name = 'Test MSA Code Map '+i;
            psaMSACodeMappingList.add(psaMSACodeMapping);
        }
        insert psaMSACodeMappingList;
        
        List<pse__Project_Location__c> projLocList = new List<pse__Project_Location__c>();
        for(integer i=0;i<2;i++){
            pse__Project_Location__c projLoc = new pse__Project_Location__c();
            projLoc.pse__Project__c = projList[i].Id;
            projLoc.psa_pm_Primary__c =true;
            projLoc.psa_pm_MSA_Code_Mapping__c = psaMSACodeMappingList[i].Id;
            projLocList.add(projLoc);
        }
        insert projLocList;
        
        // Create Schedule
        
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
        for(integer i=0;i<2;i++){
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
        }
        insert scheduleList;
        system.runAs(userObj){
            // Create Resource Request
            List<pse__Resource_Request__c> resourceReqList = new List<pse__Resource_Request__c>();
            for(integer i=0;i<2;i++){
                pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
                resourceReq.pse__Start_Date__c = currentDate.addDays(1);
                resourceReq.pse__End_Date__c = currentDate.addDays(10);
                resourceReq.pse__Staffer_Resource__c = conList[i].Id;
                resourceReq.pse__Project__c = projList[i].Id;
                resourceReq.pse__SOW_Hours__c =8;
                resourceReq.pse__Resource_Role__c = 'Consultant';
                resourceReq.CurrencyIsoCode='USD';
                resourceReq.pse__Opportunity__c = opptyList[i].Id;
                resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMappingList[i].Id;
                resourceReq.pse__Region__c = regionList[i].Id;
                resourceReq.psa_rm_Original_Opportunity__c = opptyList[i].Id;
                resourceReq.PSA_OM_Opportunity_Product_Id__c =  opptyLineItemList[i].Id;
                resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
                resourceReq.psa_rm_Billable__c = true;
                resourceReqList.add(resourceReq);
            }
            insert resourceReqList;  
            
            // Create Assignment
            
            List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
            for(integer i=0;i<2;i++){
                pse__Assignment__c assignRec = new pse__Assignment__c();
                assignRec.Name = 'Test Assignment '+i;
                assignRec.pse__Schedule__c = scheduleList[i].Id;
                assignRec.pse__Resource__c = conList[i].Id;
                assignRec.pse__Project__c = projList[i].Id;
                assignRec.pse__Planned_Hours__c = 7;
                assignRec.pse__Bill_Rate__c =0;
                assignRec.pse__Is_Billable__c = true;
                assignRec.pse__Role__c ='Senior Consultant';
                assignRec.pse__Cost_Rate_Amount__c =10;
                assignRec.CurrencyIsoCode='USD';
                assignRec.pse__Resource_Request__c = resourceReqList[i].Id;
                assignmentList.add(assignRec);
                
            }
            insert assignmentList;
            
            // Create Issues
            List<pse__Issue__c> issueLst = new List<pse__Issue__c>();
            
            for(integer i=0;i<6;i++){
                
                pse__Issue__c issueRec = new pse__Issue__c();
                if(i<3){// Adding three Issues to each project
                    issueRec.pse__Project__c=projList[0].Id;  
                }else{
                    issueRec.pse__Project__c=projList[1].Id;
                }
                issueRec.pse__Issue_Name__c = 'Test Issue '+i;
                issueRec.pse__Date_Raised__c = currentDate;
                issueRec.PSA_Issue_History__c = 'Sample Issue Created '+i;
                issueRec.pse__Action_Plan__c ='No action plan is required.';
                issueRec.PSA_Status__c='OPEN';
                issueRec.PSA_Priority__c='LOW';
                issueLst.add(issueRec);
            }
            insert issueLst;
            
            // Create Risks
            
            List<pse__Risk__c> riskLst = new List<pse__Risk__c>();
            
            for(integer i=0;i<6;i++){
                pse__Risk__c riskRec = new pse__Risk__c();
                if(i<3){ // Adding three risks to each project
                    riskRec.pse__Project__c = projList[0].Id;
                }else{
                    riskRec.pse__Project__c = projList[1].Id;
                }
                riskRec.pse__Date_Raised__c=currentDate;
                riskRec.PSA_Risk_History__c='Sample Risk created';
                riskRec.PSA_Impact__c='LOW';
                riskRec.PSA_Status__c='OPEN';
                riskRec.pse__Risk_Name__c='Test Risk '+i;
                riskLst.add(riskRec);
            }
            insert riskLst;
            
            // Create Status Report
            List<Status_Report__c> statReportLst = new List<Status_Report__c>();
            for(Integer i=0;i<2;i++){
                Status_Report__c statRep = new Status_Report__c();
                statRep.PSA_PM_Project__c = projList[i].Id;
                statRep.Status_Report_Name__c ='Test Status Report '+i;
                statRep.PSA_PM_Key_Accomplishments__c='Test Key Accomplishments '+i;
                statRep.PSA_PM_Next_Steps__c ='Test Next Steps '+i;
                statRep.PSA_PM_Cost__c='Green';
                statRep.PSA_PM_Resources__c='Yellow';
                statRep.PSA_PM_Schedule__c='Red';
                statRep.PSA_PM_Technical__c='Green';
                statRep.PSA_PM_Scope__c='Yellow';
                statRep.PSA_PM_Status_Report_Week__c=currentDate.toStartofWeek().addDays(1);
                statReportLst.add(statRep);
                
            }
            insert statReportLst;
            
            
            // Create TimeCard
            List<pse__Timecard_Header__c> timecardList = new List<pse__Timecard_Header__c>(); 
            for(integer i=0;i<6;i++){
                pse__Timecard_Header__c timecard = new pse__Timecard_Header__c();
                timecard.pse__Start_Date__c =  currentDate.toStartofWeek().addDays(-7);
                timecard.pse__End_Date__c = currentDate.toStartofWeek().addDays(-1);
                
                if(i<3){
                    timecard.pse__Project__c=projList[0].Id;
                    timecard.pse__Resource__c=conList[0].Id;
                    timecard.pse__Assignment__c = assignmentList[0].Id;
                    timecard.pse__Primary_Project_Location__c =projLocList[0].Id;
                    
                }else{
                    timecard.pse__Project__c=projList[1].Id;
                    timecard.pse__Resource__c=conList[1].Id;
                    timecard.pse__Assignment__c = assignmentList[1].Id;
                    timecard.pse__Primary_Project_Location__c =projLocList[1].Id;
                }
                timecard.pse__Project_Methodology__c ='ActiveVOS';
                timecard.psa_pm_Project_Portfolio_Manager__c = userObj.Id;
                timecard.pse__Approver__c = userObj.Id;
                
                timecardList.add(timecard);
            }
            
            insert timecardList;
        }
    }
    
    @isTest
    static void generatePDFTest(){
        
        Test.startTest();
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id from Status_Report__c]);
        
        List<ContentDocumentLink> conDocLinkBefore = new List<ContentDocumentLink>([select Id from ContentDocumentLink  where LinkedEntityId=:statsReportLst[0].Id]);
        
        // Generating PDF Report
        StatusReportGeneratePDF.generatePDF(statsReportLst[0].Id);
        
        List<ContentDocumentLink> conDocLinkAfter = new List<ContentDocumentLink>([select Id from ContentDocumentLink  where LinkedEntityId=:statsReportLst[0].Id]);
        
        system.assertEquals(0, conDocLinkBefore.size());
        system.assertEquals(1, conDocLinkAfter.size());
        // Deleting already generated PDF report from the content document link and generate a new one.
        StatusReportGeneratePDF.generatePDF(statsReportLst[0].Id);
        
        Test.stopTest();
        
    }
    @isTest
    static void attachIssuesAndRisksTest(){
        
        Test.startTest();
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id,PSA_PM_Project__c from Status_Report__c]);
        List<pse__Issue__c> issueLst = [Select Id from pse__Issue__c where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c];
        List<pse__Risk__c> riskLst =[Select Id from pse__Risk__c  where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c];
        List<Status_Report_Detail__c> statsDetailLstBefore = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                              from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.attachIssuesAndRisks(statsReportLst[0].Id, riskLst, issueLst);
        
        List<Status_Report_Detail__c> statsDetailLstAfter = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                             from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        Test.stopTest();
        system.assertEquals(0, statsDetailLstBefore.size());
        system.assertEquals(6, statsDetailLstAfter.size());
    }
    
    @isTest
    static void removeIssuesAndRisksTest(){
        
        Test.startTest();
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id,PSA_PM_Project__c from Status_Report__c]);
        List<pse__Issue__c> issueLst = [Select Id from pse__Issue__c where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c];
        List<pse__Risk__c> riskLst =[Select Id from pse__Risk__c  where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c];
        List<Status_Report_Detail__c> statsDetailLstBefore = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                              from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.attachIssuesAndRisks(statsReportLst[0].Id, riskLst, issueLst);
        
        List<Status_Report_Detail__c> statsDetailLstAfter = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                             from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.removeIssuesAndRisks(statsReportLst[0].Id, riskLst, issueLst);
        
        List<Status_Report_Detail__c> statsDetailLstAfterRemove = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                                   from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        
        Test.stopTest();
        system.assertEquals(0, statsDetailLstBefore.size());
        system.assertEquals(6, statsDetailLstAfter.size());
        system.assertEquals(0, statsDetailLstAfterRemove.size());
        
    }
    
    @isTest
    static void getIssuesAndRiskTest(){
        
        Test.startTest();
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id,PSA_PM_Project__c from Status_Report__c]);
        List<pse__Issue__c> issueLst = [Select Id from pse__Issue__c where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c Limit 1];
        List<pse__Risk__c> riskLst =[Select Id from pse__Risk__c  where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c Limit 2];
        List<Status_Report_Detail__c> statsDetailLstBefore = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                              from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.attachIssuesAndRisks(statsReportLst[0].Id, riskLst, issueLst);
        
        List<Status_Report_Detail__c> statsDetailLstAfter = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                             from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.IssueAndRiskWrapper getIssuesRisks = new StatusReportGeneratePDF.IssueAndRiskWrapper();
        getIssuesRisks = StatusReportGeneratePDF.getIssuesAndRisk(statsReportLst[0].Id);
        
        Test.stopTest();
        system.assertEquals(0, statsDetailLstBefore.size());
        system.assertEquals(3, statsDetailLstAfter.size());
        system.assertEquals(1, getIssuesRisks.lstOfAttachedIssues.size());
        system.assertEquals(2, getIssuesRisks.lstOfAttachedRisks.size());
        system.assertEquals(2, getIssuesRisks.lstOfUnattchedIssues.size());
        system.assertEquals(1, getIssuesRisks.lstOfUnattachedRisks.size());
        
    }
    @isTest
    static void attachTimecardsAndRemoveTimecardsTest(){
        
        Test.startTest();
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id,PSA_PM_Project__c from Status_Report__c]);
        List<StatusReportGeneratePDF.TimecardWrapper> attachTimecards = new List<StatusReportGeneratePDF.TimecardWrapper>();
        List<StatusReportGeneratePDF.TimecardWrapper> removeTimecards = new List<StatusReportGeneratePDF.TimecardWrapper>();
        
        List<pse__Timecard_Header__c> timecardLst = [Select Id,PSA_TM_Resource_Role__c,pse__Assignment__r.pse__Is_Billable__c,
                                                     pse__Assignment__r.pse__Start_Date__c, pse__Assignment__r.pse__End_Date__c,
                                                     pse__Resource__r.name, PSA_TM_Resource_Role_Override__c,pse__Total_Hours__c,
                                                     pse__Start_Date__c, pse__Status__c, pse__End_Date__c,pse__Project__c,
                                                     pse__Project__r.Name from pse__Timecard_Header__c
                                                     where pse__Project__c =:statsReportLst[0].PSA_PM_Project__c Limit 3];
        
        for(pse__Timecard_Header__c timecardRec : timecardLst){
            StatusReportGeneratePDF.TimecardWrapper timecardWrapper = new StatusReportGeneratePDF.TimecardWrapper();
            timecardWrapper.resource = timecardRec.pse__Resource__r.name;
            timecardWrapper.role = timecardRec.PSA_TM_Resource_Role__c;
            timecardWrapper.totalHours = String.valueOf(timecardRec.pse__Total_Hours__c);
            timecardWrapper.Id = timecardRec.Id;
            timecardWrapper.startDate = timecardRec.pse__Assignment__r.pse__Start_Date__c;
            timecardWrapper.endDate = timecardRec.pse__Assignment__r.pse__End_Date__c;
            timecardWrapper.isBillable = timecardRec.pse__Assignment__r.pse__Is_Billable__c;
            attachTimecards.add(timecardWrapper); // Size will be 3
            if(removeTimecards.isEmpty()){
                removeTimecards.add(timecardWrapper); //Size will be 1
            }
        }
        
        List<Status_Report_Detail__c> statsDetailLstBefore = [Select Id,PSA_Timecard__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                              from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        // attaching all the three timecards of a project
        StatusReportGeneratePDF.attachTimecards(statsReportLst[0].Id, attachTimecards);
        
        List<Status_Report_Detail__c> statsDetailLstAfter = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                             from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        // removing a timecard of a project
        StatusReportGeneratePDF.removeTimecards(statsReportLst[0].Id, removeTimecards);
        
        List<Status_Report_Detail__c> statsDetailLstAfterRemove = [Select Id,PSA_Timecard__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c 
                                                                   from Status_Report_Detail__c  where PSA_Status_Report__c=:statsReportLst[0].Id];
        
        StatusReportGeneratePDF.TimecardWrapperList allTimeCards= StatusReportGeneratePDF.getTimecards(statsReportLst[0].Id);
        
        Test.stopTest();
        system.assertEquals(0, statsDetailLstBefore.size());
        system.assertEquals(3, statsDetailLstAfter.size());
        system.assertEquals(2, statsDetailLstAfterRemove.size());
        system.assertEquals(2, allTimeCards.attachedTimecards.size());
        system.assertEquals(1, allTimeCards.unAttachedTimecards.size());
    }
    
}