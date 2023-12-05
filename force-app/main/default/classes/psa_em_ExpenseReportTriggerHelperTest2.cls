@isTest(seeAllData=true)
public class psa_em_ExpenseReportTriggerHelperTest2 {    
    /*
    public static testMethod void ExpenseReportTriggerUpdateTest() {        

        Id region = [SELECT Id FROM pse__Region__c WHERE Name = 'Informatica'].Id;

        Id account = [SELECT Id FROM Account WHERE Name LIKE '%Informatica%' LIMIT 1].Id;
        
        List<pse__Expense_Report__c> lExpenseReport = [Select Id,pse__Project__c,pse__Resource__c from pse__Expense_Report__c LIMIT 1];
        System.assert(lExpenseReport.size()>0, 'Expense Report not created');

        List<pse__Proj__c> lProject = [SELECT Id,Name,pse__Region__c,pse__Region__r.psa_Major_GEO__c FROM pse__Proj__c WHERE Id != :lExpenseReport[0].pse__Project__c AND pse__Region__c != null];
        System.assert(lProject.size()>0, 'Project not created');

        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity TEST';
        opp.CloseDate = System.today().addDays(5);
        opp.AccountId = account;
        opp.Type = 'Direct';
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Validate';
        opp.psa_om_Start_Date__c = System.today();
        opp.psa_om_End_Date__c = System.today().addDays(20);
        opp.psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM';
        opp.PSA_OM_Project_Type__c = 'JumpStart';
        opp.pse__Is_Change_Request__c = false;
        insert opp;

        List<pse__Permission_Control__c> pcList = new List<pse__Permission_Control__c>();
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = region;
        pc.pse__Cascading_Permission__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pcList.add(pc);

        pse__Permission_Control__c pc1 = new pse__Permission_Control__c();
        pc1.pse__User__c = UserInfo.getUserId();
        pc1.pse__Project__c = lProject[0].Id;
        pc1.pse__Cascading_Permission__c = true;
        pc1.pse__Expense_Entry__c = true;
        pc1.pse__Expense_Ops_Edit__c = true;
        pc1.pse__Resource_Request_Entry__c = true;
        pc1.pse__Invoicing__c = true;
        pc1.pse__Skills_And_Certifications_Entry__c = true;
        pc1.pse__Skills_And_Certifications_View__c = true;
        pc1.pse__Staffing__c = true;
        pc1.pse__Timecard_Entry__c = true;
        pc1.pse__Timecard_Ops_Edit__c = true;
        pcList.add(pc1);

        pse__Permission_Control__c pc2 = new pse__Permission_Control__c();
        pc2.pse__User__c = UserInfo.getUserId();
        pc2.pse__Resource__c = lExpenseReport[0].pse__Resource__c;
        pc2.pse__Cascading_Permission__c = true;
        pc2.pse__Expense_Entry__c = true;
        pc2.pse__Expense_Ops_Edit__c = true;
        pc2.pse__Resource_Request_Entry__c = true;
        pc2.pse__Invoicing__c = true;
        pc2.pse__Skills_And_Certifications_Entry__c = true;
        pc2.pse__Skills_And_Certifications_View__c = true;
        pc2.pse__Staffing__c = true;
        pc2.pse__Timecard_Entry__c = true;
        pc2.pse__Timecard_Ops_Edit__c = true;
        pcList.add(pc2);
        insert pcList;

        pse__Budget__c bud = new pse__Budget__c();
        bud.pse__Project__c = lProject[0].Id;
        bud.pse__Amount__c = 10000;
        bud.pse__Type__c = 'Customer Purchase Order';
        bud.CurrencyIsoCode = 'USD';
        bud.pse__Opportunity__c = opp.Id;
        bud.pse__Status__c = 'Draft';
        insert bud;

        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = System.today().addDays(1);
        sch.pse__End_Date__c = System.today().addDays(10);
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Sunday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 8;
        insert sch;

        pse__Resource_Request__c rr = new pse__Resource_Request__c();
        rr.pse__Start_Date__c = System.today().addDays(1);
        rr.pse__End_Date__c = System.today().addDays(10);
        rr.pse__Resource__c = lExpenseReport[0].pse__Resource__c;
        rr.pse__Staffer_Resource__c = lExpenseReport[0].pse__Resource__c;
        rr.pse__Project__c = lProject[0].Id;
        rr.pse__SOW_Hours__c = 8.00;
        rr.pse__Resource_Role__c = 'Consultant';
        //rr.pse__Opportunity__c = lOpportunity[0].Id);
        //rr.psa_rm_MSA_Code_Mapping__c',lCodeMapping[0].Id);
        rr.pse__Region__c = region;
        rr.psa_rm_Billable__c = true;
        rr.PSA_RM_Assignment_Type__c = 'Customer Billable';
        insert rr;
        
        //List<pse__Assignment__c> lAssignment = [SELECT Id,pse__Project__c from pse__Assignment__c WHERE pse__Project__c =: lProject[0].Id AND pse__Resource__c =:lExpenseReport[0].pse__Resource__c];
        pse__Assignment__c asgn = new pse__Assignment__c();
        asgn.Name = 'Test Assignment';
        asgn.pse__Resource__c = lExpenseReport[0].pse__Resource__c;
        asgn.pse__Schedule__c = sch.Id;
        asgn.pse__Project__c = lProject[0].Id;
        asgn.pse__Planned_Hours__c = 8.00;
        asgn.pse__Bill_Rate__c = 0.00;
        asgn.pse__Is_Billable__c = true;
        asgn.pse__Role__c = 'Senior Consultant';
        asgn.pse__Cost_Rate_Amount__c = 10.00;
        asgn.pse__Resource_Request__c = rr.Id;
        insert asgn;
        
        lExpenseReport[0].pse__Assignment__c = asgn.Id;
        lExpenseReport[0].pse__Project__c = asgn.pse__Project__c; 
        lExpenseReport[0].pse__Admin_Global_Edit__c = true;
        lExpenseReport[0].pse__Audit_Notes__c = 'Test';
        
        Test.startTest();
        update lExpenseReport[0];
        Test.stopTest();
        
    }
	*/
    
    public static testMethod void ExpenseReportTriggerInsertTest() {
        
        //List<Contact> lContact = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c != null AND pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true LIMIT 1];

        //List<pse__Assignment__c> lAssignment = [SELECT Id,pse__Project__c FROM pse__Assignment__c WHERE pse__Resource__c =: lContact[0].Id];

       //List<pse__Proj__c> lProject = [SELECT Id FROM pse__Proj__c WHERE Id =: lAssignment[0].pse__Project__c];
        List<pse__Assignment__c> lAssignment = [SELECT Id, pse__Resource__c, pse__Project__c FROM pse__Assignment__c WHERE pse__Project__c != null AND pse__Resource__c != null AND 
                                                pse__Resource__r.pse__Salesforce_User__c != null AND pse__Resource__r.pse__Is_Resource__c = true AND 
                                                pse__Resource__r.pse__Is_Resource_Active__c = true AND pse__Project__r.pse__Is_Active__c = true
                                                AND pse__Closed_for_Expense_Entry__c = false LIMIT 1]; 
        if(lAssignment.size() > 0){
            pse__Permission_Control__c pc = new pse__Permission_Control__c();
            pc.pse__User__c = UserInfo.getUserId();
            //pc.pse__Resource__c = lContact[0].Id;
            pc.pse__Resource__c = lAssignment[0].pse__Resource__c;
            pc.pse__Cascading_Permission__c = true;
            pc.pse__Expense_Entry__c = true;
            pc.pse__Expense_Ops_Edit__c = true;
            insert pc;

            pse__Expense_Report__c mEx = new pse__Expense_Report__c();
            mEx.Name = 'Test Expense Report-1';
            //mEx.pse__Resource__c = lContact[0].Id;
            mEx.pse__Resource__c = lAssignment[0].pse__Resource__c;
            //mEx.pse__Project__c = lProject[0].Id;
            mEx.pse__Project__c = lAssignment[0].pse__Project__c;
            mEx.pse__Status__c = 'Draft';
            mEx.pse__Assignment__c = lAssignment[0].Id;

            Test.startTest();
            insert mEx;
            Test.stopTest();   
        }     
    }
}