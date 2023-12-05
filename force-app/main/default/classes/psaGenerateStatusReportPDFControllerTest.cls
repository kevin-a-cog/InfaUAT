@isTest
public class psaGenerateStatusReportPDFControllerTest {
    private static List<Schema.SObjectType> sObjects = 
    new Schema.SObjectType[]{
                            User_Exemptions__c.SobjectType,
                            Account.SobjectType,
                            User.SobjectType,
                            pse__Region__c.SobjectType,
                            pse__Work_Calendar__c.SobjectType,
                            Contact.SobjectType,
                            Product2.SobjectType,
                            Pricebook2.SobjectType,
                            pricebookEntry.SobjectType,
                            Opportunity.SobjectType,
                            OpportunityLineItem.SobjectType,
                            pse__Permission_Control__c.SobjectType,
                            pse__Proj__c.SobjectType,
                            PSA_MSA_Code_Mapping__c.SobjectType,
                            pse__Project_Location__c.SobjectType,
                            pse__Schedule__c.SobjectType,
                            pse__Resource_Request__c.SobjectType,
                            pse__Assignment__c.SObjectType,
                            pse__Issue__c.SobjectType,
                            pse__Risk__c.SobjectType,
                            Status_Report__c.SobjectType,
                            Task.SobjectType,
                            Status_Report_Detail__c.SobjectType
    };
    @testSetup
    static void initializeData(){
        UnitOfWork uow = new UnitOfWork(sObjects);

        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        // Create Account
        Account acc1 = new Account();
        acc1.Name='Test Account 1';
        acc1.RecordTypeId=accRecType;
        acc1.Geo__c='NA';
        acc1.Signature_Success__c = true;
        acc1.CSM_Segment__c='Digital Touch';
        acc1.Contract_Company_Group__c='Prospect';
        acc1.Payment_Terms__c='Net 30';
        acc1.BillingCountry='India';
        uow.registerNew(acc1); 

        Account acc2 = new Account();
        acc2.Name='Test Account 2';
        acc2.RecordTypeId=accRecType;
        acc2.Geo__c='NA';
        acc2.Signature_Success__c = true;
        acc2.CSM_Segment__c='Digital Touch';
        acc2.Contract_Company_Group__c='Prospect';
        acc2.Payment_Terms__c='Net 30';
        acc2.BillingCountry='India';
        uow.registerNew(acc2); 
        
        // Create Region        
        pse__Region__c reg1 = new pse__Region__c(Name='Test Region 1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg1);
        
        pse__Region__c reg2 = new pse__Region__c(Name='Test Region 2',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-2->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg2);
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar',
                                                                              pse__Sunday_Hours__c= 8,
                                                                              pse__Monday_Hours__c=8,
                                                                              pse__Tuesday_Hours__c=8,
                                                                              pse__Wednesday_Hours__c=8,
                                                                              pse__Thursday_Hours__c=8,
                                                                              pse__Friday_Hours__c=8,
                                                                              pse__Saturday_Hours__c=8);
        uow.registerNew(defaultWorkCalendar);
        
        Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00
                                       );
        uow.registerRelationship(con1, Contact.AccountId,acc1);
        uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
        uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
        
        Contact con2 = new Contact(LastName = 'Test Contact 2',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00
                                       );
        uow.registerRelationship(con2, Contact.AccountId,acc2);
        uow.registerRelationship(con2, Contact.pse__Region__c, reg2);
        uow.registerNew(con2, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
                
        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               StageName='Validate',
                                               RecordTypeId = opptyRecType,
                                               Name = 'Test opportunity 1',
                                               psa_om_Start_Date__c=System.today(),
                                               CloseDate = System.today().addDays(2),
                                               psa_om_End_Date__c=System.today()+10,
                                               psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                               PSA_OM_Project_Type__c='JumpStart'
                                               );                                 
        uow.registerNew(opty, Opportunity.AccountId, acc1);

        Opportunity opty2 = new Opportunity(Name = 'Test opportunity 2',
                                                Type='Direct',
                                                CurrencyIsoCode='USD',
                                                RecordTypeId = opptyRecType,
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
        uow.registerNew(opty2, Opportunity.AccountId, acc2);
        
        pse__Permission_Control__c pc = new pse__Permission_Control__c( pse__User__c = userObj.Id, 
                                                                            pse__Expense_Ops_Edit__c = true, 
                                                                            pse__Timecard_Ops_Edit__c = true,
                                                                            pse__Cascading_Permission__c = true, 
                                                                            pse__Resource_Request_Entry__c = true,
                                                                            pse__Timecard_Entry__c = true, 
                                                                            pse__Staffing__c = true);
        uow.registerNew(pc, pse__Permission_Control__c.pse__Region__c, reg1);
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c( pse__User__c = userObj.Id, 
                                                                            pse__Expense_Ops_Edit__c = true, 
                                                                            pse__Timecard_Ops_Edit__c = true,
                                                                            pse__Cascading_Permission__c = true, 
                                                                            pse__Resource_Request_Entry__c = true,
                                                                            pse__Timecard_Entry__c = true, 
                                                                            pse__Staffing__c = true);
        uow.registerNew(pc2, pse__Permission_Control__c.pse__Region__c, reg2);
        
        // Create Project
        pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Project_Type__c = 'Customer Project',
                                                     psa_pm_Time_Approval_Method__c = 'Auto-Approve',
                                                     psa_pm_Require_Milestone_on_Timecards__c = false,
                                                     psa_pm_Require_Product_On_Timecards__c =false,
                                                     psa_pm_Require_Location_On_Timecards__c = false,
                                                     Name = 'Test Project 1',
                                                     pse__Stage__c='Completed',
                                                     pse__Start_Date__c=currentDate.addDays(-6),
                                                     pse__End_Date__c=currentDate.addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
        uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);
        
        pse__Proj__c projRec2 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Project_Type__c = 'Customer Project',
                                                     psa_pm_Time_Approval_Method__c = 'Auto-Approve',
                                                     psa_pm_Require_Milestone_on_Timecards__c = false,
                                                     psa_pm_Require_Product_On_Timecards__c =false,
                                                     psa_pm_Require_Location_On_Timecards__c = false,
                                                     Name = 'Test Project 2',
                                                     pse__Stage__c='Completed',
                                                     pse__Start_Date__c=currentDate.addDays(-6),
                                                     pse__End_Date__c=currentDate.addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec2, pse__Proj__c.pse__Account__c, acc2);
        uow.registerRelationship(projRec2, pse__Proj__c.pse__Project_Manager__c,con2);
        uow.registerRelationship(projRec2, pse__Proj__c.pse__Opportunity__c,opty2);
        uow.registerNew(projRec2,pse__Proj__c.pse__Region__c ,reg2);
        
        // create PSA MSA Code Mapping
        PSA_MSA_Code_Mapping__c msaCodeMapping1 = new PSA_MSA_Code_Mapping__c(Name='Test Name 1');
        uow.registerNew(msaCodeMapping1);
        
        PSA_MSA_Code_Mapping__c msaCodeMapping2 = new PSA_MSA_Code_Mapping__c(Name='Test Name 2');
        uow.registerNew(msaCodeMapping2);
        
        pse__Project_Location__c projLoc1= new pse__Project_Location__c(psa_pm_Primary__c =true);
        uow.registerRelationShip(projLoc1,pse__Project_Location__c.psa_pm_MSA_Code_Mapping__c,msaCodeMapping1);
        uow.registerNew(projLoc1,pse__Project_Location__c.pse__Project__c,projRec1);

        pse__Project_Location__c projLoc2 = new pse__Project_Location__c(psa_pm_Primary__c =true);
        uow.registerRelationShip(projLoc2,pse__Project_Location__c.psa_pm_MSA_Code_Mapping__c,msaCodeMapping2);
        uow.registerNew(projLoc2,pse__Project_Location__c.pse__Project__c,projRec2);
        
        // Create Schedule
        pse__Schedule__c schRec = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(10),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec);
        pse__Schedule__c schRec2 = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(11),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec2);
        system.runAs(userObj){  
            pse__Resource_Request__c rrRec1 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(10),
                                                                          pse__SOW_Hours__c=8.00,
                                                                          pse__Resource_Role__c='Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');
            uow.registerRelationship(rrRec1, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec1, pse__Resource_Request__c.pse__Project__c,projRec1);
            uow.registerRelationship(rrRec1, pse__Resource_Request__c.pse__Opportunity__c,opty);
            uow.registerRelationship(rrRec1, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping1);
            uow.registerNew(rrRec1, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty); 

            pse__Resource_Request__c rrRec2 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(15),
                                                                          pse__SOW_Hours__c=6.00,
                                                                          pse__Resource_Role__c='Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');    
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Project__c,projRec2);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Opportunity__c,opty2);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping2);
            uow.registerNew(rrRec2, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty2);
            
            //Create Assignment
            pse__Assignment__c asgmt1 = new pse__Assignment__c(Name = 'Test Assignment 1',
                                                                pse__Cost_Rate_Amount__c = 0,
                                                                pse__Planned_Hours__c = 8,
                                                                pse__Bill_Rate__c = 0,
                                                                pse__Is_Billable__c = true,
                                                                psa_rm_Assignment_Type__c ='Shadowing',
                                                                pse__Role__c = null);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Project__c, projRec1);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Schedule__c,schRec);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Resource_Request__c, rrRec1);
            uow.registerNew(asgmt1, pse__Assignment__c.pse__Resource__c, con1);

            pse__Assignment__c asgmt2 = new pse__Assignment__c(Name = 'Test Assignment 2',
                                                                pse__Cost_Rate_Amount__c = 10,
                                                                pse__Planned_Hours__c = 8,
                                                                pse__Bill_Rate__c = 0,
                                                                pse__Is_Billable__c = true,
                                                                pse__Role__c = 'Senior Consultant');
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Project__c, projRec2);
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Schedule__c,schRec2);
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Resource_Request__c, rrRec2);
            uow.registerNew(asgmt2, pse__Assignment__c.pse__Resource__c, con2);
            
            //Create Issues
            pse__Issue__c issueRec1 = new pse__Issue__c(pse__Issue_Name__c='Test Issue 1',
                                                       pse__Date_Raised__c=currentDate,
                                                       PSA_Issue_History__c='Sample Issue Created 1',
                                                       pse__Action_Plan__c='No action plan is required.',
                                                       PSA_Status__c='OPEN',
                                                       PSA_Priority__c='LOW'
            );
            uow.registerNew(issueRec1,pse__Issue__c.pse__Project__c,projRec1);
            pse__Issue__c issueRec2 = new pse__Issue__c(pse__Issue_Name__c='Test Issue 2',
                                                       pse__Date_Raised__c=currentDate,
                                                       PSA_Issue_History__c='Sample Issue Created 2',
                                                       pse__Action_Plan__c='No action plan is required.',
                                                       PSA_Status__c='OPEN',
                                                       PSA_Priority__c='LOW'
            );
            uow.registerNew(issueRec2,pse__Issue__c.pse__Project__c,projRec2);
            
            // Create Risk
            pse__Risk__c riskRec1 = new pse__Risk__c(
                pse__Date_Raised__c=currentDate,
                PSA_Risk_History__c='Sample Risk created',
                PSA_Impact__c='LOW',
                PSA_Status__c='OPEN',
                pse__Risk_Name__c='Test Risk 1'
            );
            uow.registerNew(riskRec1,pse__Risk__c.pse__Project__c,projRec1);
            pse__Risk__c riskRec2 = new pse__Risk__c(
                pse__Date_Raised__c=currentDate,
                PSA_Risk_History__c='Sample Risk created',
                PSA_Impact__c='LOW',
                PSA_Status__c='OPEN',
                pse__Risk_Name__c='Test Risk 1'
            );
            uow.registerNew(riskRec2,pse__Risk__c.pse__Project__c,projRec2);
            
            // Create Status Report
            Status_Report__c statRec1 = new Status_Report__c(
                Status_Report_Name__c ='Test Status Report 1',
                PSA_PM_Key_Accomplishments__c='Test Key Accomplishments 1',
                PSA_PM_Cost__c='Green',
                PSA_PM_Resources__c='Yellow',
                PSA_PM_Schedule__c='Red',
                PSA_PM_Technical__c='Green',
                PSA_PM_Scope__c='Yellow',
                PSA_PM_Status_Report_Week__c=currentDate.toStartofWeek().addDays(1)
            );            
            uow.registerNew(statRec1,Status_Report__c.PSA_PM_Project__c,projRec1);
            
            Status_Report__c statRec2 = new Status_Report__c(
                Status_Report_Name__c ='Test Status Report 2',
                PSA_PM_Key_Accomplishments__c='Test Key Accomplishments 2',
                PSA_PM_Cost__c='Green',
                PSA_PM_Resources__c='Yellow',
                PSA_PM_Schedule__c='Red',
                PSA_PM_Scope__c='Yellow',
                PSA_PM_Status_Report_Week__c=currentDate.toStartofWeek().addDays(1)
            );            
            uow.registerNew(statRec2,Status_Report__c.PSA_PM_Project__c,projRec2);

            //Create Task
            Task t1 = new Task(psa_Status__c='Accomplished');
            uow.registerNew(t1,Task.WhatId,projRec1);

            Task t2 = new Task(psa_Status__c='Incomplete');
            uow.registerNew(t2,Task.WhatId,projRec1);

            Task t3 = new Task(psa_Status__c='Upcoming');
            uow.registerNew(t3,Task.WhatId,projRec1);


            //Create Status Report Detail
            Status_Report_Detail__c statRepDetail1 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail1,Status_Report_Detail__c.PSA_Issue__c,issueRec1);
            uow.registerNew(statRepDetail1,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail2 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail2,Status_Report_Detail__c.PSA_Risk__c,riskRec1);
            uow.registerNew(statRepDetail2,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail3 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail3,Status_Report_Detail__c.PSA_Issue__c,issueRec2);
            uow.registerNew(statRepDetail3,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail4 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail4,Status_Report_Detail__c.PSA_Risk__c,riskRec2);
            uow.registerNew(statRepDetail4,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail5 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail5,Status_Report_Detail__c.PSA_Project_Activity__c,t1);
            uow.registerNew(statRepDetail5,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail6 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail6 ,Status_Report_Detail__c.PSA_Project_Activity__c,t2);
            uow.registerNew(statRepDetail6,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Status_Report_Detail__c statRepDetail7 = new Status_Report_Detail__c();
            uow.registerRelationship(statRepDetail7,Status_Report_Detail__c.PSA_Project_Activity__c,t3);
            uow.registerNew(statRepDetail7,Status_Report_Detail__c.PSA_Status_Report__c,statRec1);

            Test.startTest();
            uow.commitWork();                                         
            Test.stopTest();
        }
    }
    @isTest
    public static void psaStatusReportControllerTest(){        
        List<Status_Report__c> statsReportLst = new List<Status_Report__c>([Select Id,PSA_PM_Project__c from Status_Report__c]);
        
        apexPages.StandardController sc = new ApexPages.StandardController(statsReportLst[0]);
        psaGenerateStatusReportPDFController controller1 = new psaGenerateStatusReportPDFController(sc);
        
    }
}