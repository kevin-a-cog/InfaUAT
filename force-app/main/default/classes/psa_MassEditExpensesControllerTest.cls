/*Change History
********************************************************************************************************************************
ModifiedBy      Date            Requested By         Description                                    Jira No.        Tag No:  
********************************************************************************************************************************
Vivek Warrier   03-02-2022      Diwan KC             Fixing issues with Record Locked               PSA-2244        T01
*/ 
@isTest
public class psa_MassEditExpensesControllerTest {
    
    @TestSetup
    private static void createTestData(){
        Sobject sObj;
        User userObj = [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        System.runAs(userObj){
            //Create Account
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Opportunity
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Enterprise Data Preparation');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Region 
            sObj = new pse__Region__c();
            UtilityTestData.mRegion.put('Name','Test Region-1');
            UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
            UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
            UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
            UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
            List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Contact
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('pse__Is_Resource__c','true');
            UtilityTestData.mContactData.put('Is_Primary__c','false');
            UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
            UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');
            //UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
            UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
            UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
            UtilityTestData.mContactData.put('psa_Employee_Type__c','Informatica-Non PS');            
            UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
            UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Project
            sObj = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            UtilityTestData.mProjectData.put('psa_pm_Expense_Approval_Method__c','Auto-Approve'); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Schedule
            sObj = new pse__Schedule__c();
            UtilityTestData.mScheduleData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mScheduleData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mScheduleData.put('pse__Monday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Tuesday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Wednesday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Thursday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Friday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Sunday_Hours__c','8');
            UtilityTestData.mScheduleData.put('pse__Saturday_Hours__c','8');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mScheduleData);
            List<pse__Schedule__c> lSchedule = (List<pse__Schedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            //Create Resource Request
            sObj = new pse__Resource_Request__c();
            UtilityTestData.mResourceRequest.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mResourceRequest.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mResourceRequest.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Staffer_Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mResourceRequest.put('pse__SOW_Hours__c','8.00');
            UtilityTestData.mResourceRequest.put('pse__Resource_Role__c','Consultant');//
            UtilityTestData.mResourceRequest.put('pse__Opportunity__c',lOpportunity[0].Id);
            //UtilityTestData.mResourceRequest.put('psa_rm_MSA_Code_Mapping__c',lCodeMapping[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mResourceRequest.put('PSA_RM_Assignment_Type__c','Internal');
            UtilityTestData.mResourceRequest.put('psa_rm_Original_Opportunity__c',lOpportunity[0].Id);//
            //UtilityTestData.mResourceRequest.put('PSA_OM_Opportunity_Product_Id__c',oppLine.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mResourceRequest); 
            List<pse__Resource_Request__c> lResourceRequest = (List<pse__Resource_Request__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Assignment
            sObj = new pse__Assignment__c();
            UtilityTestData.mAssignmentData.put('Name','Test Assignment');
            UtilityTestData.mAssignmentData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mAssignmentData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mAssignmentData.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Schedule__c',lSchedule[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Planned_Hours__c','8.00');
            UtilityTestData.mAssignmentData.put('pse__Bill_Rate__c','0.00');
            UtilityTestData.mAssignmentData.put('pse__Is_Billable__c','true');
            UtilityTestData.mAssignmentData.put('pse__Role__c','Senior Consultant');
            UtilityTestData.mAssignmentData.put('pse__Cost_Rate_Amount__c','10.00');
            UtilityTestData.mAssignmentData.put('pse__Resource_Request__c',lResourceRequest[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssignmentData);
            List<pse__Assignment__c> lAssignment = (List<pse__Assignment__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Expense Report
            sObj = new pse__Expense_Report__c();
            UtilityTestData.mExpenseReport.put('Name','Test Expense Report-1');
            UtilityTestData.mExpenseReport.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mExpenseReport.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mExpenseReport.put('pse__Status__c','Draft');
            UtilityTestData.mExpenseReport.put('pse__Assignment__c',lAssignment[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpenseReport); 
            List<pse__Expense_Report__c> lExpenseReport = (List<pse__Expense_Report__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Expenses
            sObj = new pse__Expense__c();
            UtilityTestData.mExpense.put('Name','Test Expense Report-1');
            UtilityTestData.mExpense.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mExpense.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mExpense.put('pse__Type__c','');
            UtilityTestData.mExpense.put('pse__Assignment__c',lAssignment[0].Id);//
            UtilityTestData.mExpense.put('psa_em_GL_Account_Number__c','');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpense); 
            List<pse__Expense__c> lExpense = (List<pse__Expense__c>) UtilityTest.makeInsert(new List<sObject>{sObj});             
        }
    }    
    
    @isTest
    private static void testLWCmethods(){
        List<pse__Expense_Report__c> lExpenseReport = [SELECT Id,pse__Audit_Notes__c,psa_SSC_Reviewed_Date__c FROM pse__Expense_Report__c LIMIT 1];
        List<pse__Expense__c> lExpense = [SELECT Id FROM pse__Expense__c LIMIT 1];
        lExpense[0].PSA_EM_Audited__c = true;
        
        psa_MassEditExpensesController.fetchExpenses(lExpenseReport[0].Id);
        psa_MassEditExpensesController.fetchExpenseReport(lExpenseReport[0].Id);
        psa_MassEditExpensesController.updateExpenses((Object)(lExpense),lExpenseReport[0].pse__Audit_Notes__c,lExpenseReport[0].psa_SSC_Reviewed_Date__c,(String)lExpenseReport[0].Id);
    }
    
    @isTest
    private static void testLWCmethods2(){
        List<pse__Expense_Report__c> lExpenseReport = [SELECT Id,pse__Audit_Notes__c,psa_SSC_Reviewed_Date__c FROM pse__Expense_Report__c LIMIT 1];
        List<pse__Expense__c> lExpense = [SELECT Id FROM pse__Expense__c LIMIT 1];
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
            
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        if(lExpenseReport[0] != null) cdl.LinkedEntityId = lExpenseReport[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        psa_MassEditExpensesController.serviceNowEmailMethod(lExpenseReport[0].Id, 'test@example.com', 'TEST NOTES');
    }
}