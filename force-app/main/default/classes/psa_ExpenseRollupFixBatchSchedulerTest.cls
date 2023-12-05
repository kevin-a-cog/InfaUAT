/*
@created by       : Vivek Warrier
@created on       : 19-Jul-2021
@Purpose          : Test class for psa_em_ExpenseRollupFixBatchScheduler

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest
private class psa_ExpenseRollupFixBatchSchedulerTest {
    private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
            	User.SobjectType,
            	Account.SObjectType,
                pse__Region__c.SObjectType,
                pse__Work_Calendar__c.SObjectType,
                Contact.SObjectType,
                Product2.SObjectType,
                pricebookEntry.SObjectType,
                Opportunity.SObjectType,
                pse__Time_Period__c.SObjectType,
                pse__Permission_Control__c.SObjectType,
                pse__Proj__c.SObjectType,
                pse__Schedule__c.SObjectType,
                PSA_MSA_Code_Mapping__c.SObjectType,
                pse__Resource_Request__c.SObjectType,
                pse__Assignment__c.SObjectType,
                pse__Expense_Report__c.SObjectType,
                pse__Expense__c.SObjectType
                };
                
    @testSetup
    static void setupObjectTestData() {
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
                
        Profile prof = [select Id, Name from Profile where Name = 'Employee'];
        
        
        User user1 = new User(alias='testu1',
                              username='testuser1@abc123.com',
                              lastname='User1',
                              firstname='Test Resource',
                              timezonesidkey='America/New_York',
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              EmailEncodingKey='UTF-8',
                              email='rniranjanamath@informatica.com',
                              IsActive=true,	
                              profileId = prof.Id);
        uow.registerNew(user1);
        
        User user2 = new User(alias='testu2',
                              username='testuser2@abc123.com',
                              lastname='User2',
                              firstname='Test Resource',
                              timezonesidkey='America/New_York',
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              EmailEncodingKey='UTF-8',
                              email='wakram@informatica.com',
                              IsActive=true,
                              profileId = prof.Id);
        uow.registerNew(user2);
        
        User user3 = new User(alias='testu3',
                              username='testuser3@abc123.com',
                              lastname='User3',
                              firstname='Test Resource3',
                              timezonesidkey='America/New_York',
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              EmailEncodingKey='UTF-8',
                              email='mpatil@informatica.com',
                              IsActive=true,
                              profileId = prof.Id);
        uow.registerNew(user3);
                        
        //Create Account
        Account acc = new Account(Name = 'Test Account', RecordTypeId = AccRecType.Id);
        uow.registerNew(acc);
        
        pse__Region__c region1 = new pse__Region__c(Name = 'Test Region-1',pse__Action_Update_Current_Time_Period__c = false,
                                   				    psa_pm_Allow_Customer_Project__c = true);
        uow.registerNew(region1);
        
        pse__Region__c region2 = new pse__Region__c(Name = 'Test Region-2',pse__Action_Update_Current_Time_Period__c = false,
                                  					psa_pm_Allow_Customer_Project__c = true);
        uow.registerNew(region2,pse__Region__c.pse__Parent_Region__c,region1);
                
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            uow.registerNew(defaultWorkCalendar);
            //insert defaultWorkCalendar; 
            
            Contact con = new Contact(LastName = 'Test Contact', pse__Resource_Role__c = 'Regional Manager', Is_Primary__c = false,RecordTypeId = rt.Id, pse__Is_Resource__c = true,
                              pse__Default_Cost_Rate__c = 10.00, psa_Employee_Type__c = 'Informatica-Non PS', pse__Salesforce_User__c = userObj.Id,pse__Is_Resource_Active__c = true);
            uow.registerRelationship(con, Contact.pse__Region__c, region1);
            uow.registerRelationship(con, Contact.pse__Work_Calendar__c, defaultWorkCalendar);
            uow.registerNew(con,Contact.AccountId,acc);
                        
            Product2 prod = new Product2(Name = 'Test',Offering_Type__c='Professional Services');
            uow.registerNew(prod);
 
            Id pricebookId = Test.getStandardPricebookId(); 
            
            sObject sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            pricebookEntry pbe = new pricebookEntry();
            pbe.UnitPrice=100;
            pbe.CurrencyIsoCode='USD';
            pbe.IsActive=true;
            uow.registerRelationship(pbe, pricebookEntry.Pricebook2Id, lPriceBook2[0]);
            uow.registerNew(pbe, pricebookEntry.Product2Id, prod);
            
            /*
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            Opportunity opp = new Opportunity(Name = 'Test opportunity', CloseDate = System.today().addDays(2), Type = 'Direct', CurrencyIsoCode = 'USD', StageName = 'Validate',PSA_OM_Project_Type__c = 'JumpStart',
                                              psa_om_Start_Date__c = System.today(),psa_om_End_Date__c = System.today().addDays(10), psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM');
            uow.registerNew(opp,Opportunity.AccountId, acc);
            /*
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud Adoption Hybrid MDM');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
            */
            pse__Proj__c proj1 = new pse__Proj__c(pse__Project_Type__c = 'Customer Project', psa_pm_Project_Sub_Type__c ='JumpStart',pse__Is_Active__c = true,
                                                 psa_pm_Require_Product_On_Timecards__c = false, pse__Start_Date__c = System.today().addDays(-6), 
                                                 pse__End_Date__c = System.today().addDays(10), pse__Allow_Self_Staffing__c = true, psa_pm_Expense_Approval_Method__c = 'Auto-Approve');
            uow.registerRelationship(proj1, pse__Proj__c.pse__Project_Manager__c, con);
            uow.registerRelationship(proj1, pse__Proj__c.pse__Opportunity__c, opp);
            uow.registerNew(proj1, pse__Proj__c.pse__Account__c, acc);   
            
            pse__Proj__c proj2 = new pse__Proj__c(pse__Project_Type__c = 'Customer Project', psa_pm_Project_Sub_Type__c ='JumpStart',pse__Is_Active__c = true, psa_pm_Expense_Approval_Method__c = 'Auto-Approve',
                                                 pse__Start_Date__c = System.today().addDays(1), pse__End_Date__c = System.today().addDays(10),pse__Allow_Self_Staffing__c = true, pse__Is_Billable__c = true);
            uow.registerRelationship(proj2, pse__Proj__c.pse__Project_Manager__c, con);
            uow.registerRelationship(proj2, pse__Proj__c.pse__Opportunity__c, opp);
            uow.registerNew(proj2, pse__Proj__c.pse__Account__c, acc);   
            /*
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            UtilityTestData.mProjectData.put('psa_pm_Expense_Approval_Method__c','Auto-Approve'); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            
            sObj1 = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            UtilityTestData.mProjectData.put('psa_pm_Expense_Approval_Method__c','Auto-Approve'); 
            UtilityTestData.mProjectData.put('pse__Is_Billable__c','true');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            */
            pse__Time_Period__c tp = new pse__Time_Period__c(pse__Start_Date__c = System.today(), pse__End_Date__c = System.today(),pse__Type__c='Quarter');
            uow.registerNew(tp);
            /*
            UtilityTestData.mTimePeriod.put('pse__Start_Date__c',System.today()+'');
            UtilityTestData.mTimePeriod.put('pse__End_Date__c',System.today()+'');
            UtilityTestData.mTimePeriod.put('pse__Type__c','Quarter');//pse__Project__c
            UtilityTestData.mTimePeriod.put('pse__Project__c',lProject[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimePeriod);
            List<pse__Time_Period__c> lTimePeriod = (List<pse__Time_Period__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            
            pse__Schedule__c sch = new pse__Schedule__c(pse__Start_Date__c = System.today().addDays(1), pse__End_Date__c = System.today().addDays(10), pse__Monday_Hours__c = 8,
                                       pse__Tuesday_Hours__c = 8, pse__Wednesday_Hours__c = 8, pse__Thursday_Hours__c = 8, pse__Friday_Hours__c = 8, pse__Saturday_Hours__c = 8,
                                       pse__Sunday_Hours__c = 8);
            uow.registerNew(sch);
            /*
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
			*/
            
            pse__Permission_Control__c pc = new pse__Permission_Control__c(pse__User__c = userObj.Id, pse__Expense_Ops_Edit__c = true, pse__Timecard_Ops_Edit__c = true,
                                                                          pse__Cascading_Permission__c = true, pse__Resource_Request_Entry__c = true, pse__Staffing__c = true);
            uow.registerNew(pc, pse__Permission_Control__c.pse__Region__c, region1);
            /*
            UtilityTestData.mPermissionControl.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mPermissionControl.put('pse__User__c',userObj.Id);
            UtilityTestData.mPermissionControl.put('pse__Staffing__c','true');
            UtilityTestData.mPermissionControl.put('pse__Expense_Ops_Edit__c','true');
            UtilityTestData.mPermissionControl.put('pse__Timecard_Ops_Edit__c','true');
            UtilityTestData.mPermissionControl.put('pse__Cascading_Permission__c','true');
            UtilityTestData.mPermissionControl.put('pse__Resource_Request_Entry__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPermissionControl);
            
            List<pse__Permission_Control__c> lPermissionCtrl = (List<pse__Permission_Control__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            
            PSA_MSA_Code_Mapping__c psaMSA = new PSA_MSA_Code_Mapping__c(Name = 'Test Name');
            uow.registerNew(psaMSA);
            
            /*
            UtilityTestData.mCodeMapping.put('Name','Test Name');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCodeMapping); 
            List<PSA_MSA_Code_Mapping__c> lCodeMapping = (List<PSA_MSA_Code_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            pse__Resource_Request__c rr = new pse__Resource_Request__c(pse__Start_Date__c = System.today().addDays(1), pse__End_Date__c = System.today().addDays(10),
                                                                      pse__SOW_Hours__c = 8, pse__Resource_Role__c = 'Consultant', psa_rm_Billable__c = true,
                                                                      PSA_RM_Assignment_Type__c = 'Customer Billable');
            uow.registerRelationship(rr,pse__Resource_Request__c.pse__Resource__c, con);
            uow.registerRelationship(rr,pse__Resource_Request__c.pse__Staffer_Resource__c, con);
            uow.registerRelationship(rr,pse__Resource_Request__c.pse__Project__c, proj1);
            uow.registerRelationship(rr,pse__Resource_Request__c.pse__Opportunity__c,opp);
            uow.registerRelationship(rr,pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,psaMSA);
            uow.registerRelationship(rr,pse__Resource_Request__c.pse__Region__c, region1);
            uow.registerNew(rr,pse__Resource_Request__c.psa_rm_Original_Opportunity__c, opp);
            /*
            UtilityTestData.mResourceRequest.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mResourceRequest.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mResourceRequest.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Staffer_Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mResourceRequest.put('pse__SOW_Hours__c','8.00');
            UtilityTestData.mResourceRequest.put('pse__Resource_Role__c','Consultant');//
            UtilityTestData.mResourceRequest.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_MSA_Code_Mapping__c',lCodeMapping[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_Original_Opportunity__c',lOpportunity[0].Id);//
            UtilityTestData.mResourceRequest.put('PSA_OM_Opportunity_Product_Id__c',oppLine.Id);
            UtilityTestData.mResourceRequest.put('psa_rm_Billable__c','true');
            UtilityTestData.mResourceRequest.put('PSA_RM_Assignment_Type__c','Customer Billable');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mResourceRequest); 
            List<pse__Resource_Request__c> lResourceRequest = (List<pse__Resource_Request__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            pse__Assignment__c asgmt1 = new pse__Assignment__c(Name = 'Test Assignment',pse__Cost_Rate_Amount__c = 10,
                                                              pse__Planned_Hours__c = 8,pse__Bill_Rate__c = 0,pse__Is_Billable__c = true,pse__Role__c = 'Senior Consultant');
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Project__c, proj1);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Schedule__c,sch);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Resource_Request__c, rr);
            uow.registerNew(asgmt1, pse__Assignment__c.pse__Resource__c, con);
            
            pse__Assignment__c asgmt2 = new pse__Assignment__c(Name = 'Test Assignment',pse__Cost_Rate_Amount__c = 10,
                                                              pse__Planned_Hours__c = 8,pse__Bill_Rate__c = 0,pse__Is_Billable__c = true,pse__Role__c = 'Senior Consultant');
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Project__c, proj2);
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Schedule__c,sch);
            uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Resource_Request__c, rr);
            uow.registerNew(asgmt2, pse__Assignment__c.pse__Resource__c, con);
            /*
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
            UtilityTestData.mAssignmentData.put('pse__Cost_Rate_Amount__c','10.00');//
            UtilityTestData.mAssignmentData.put('pse__Resource_Request__c',lResourceRequest[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssignmentData);
            
            sObj1 = new pse__Assignment__c();
            UtilityTestData.mAssignmentData.put('Name','Test Assignment');
            UtilityTestData.mAssignmentData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mAssignmentData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mAssignmentData.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Project__c',lProject[1].Id);
            UtilityTestData.mAssignmentData.put('pse__Schedule__c',lSchedule[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Planned_Hours__c','8.00');
            UtilityTestData.mAssignmentData.put('pse__Bill_Rate__c','0.00');
            UtilityTestData.mAssignmentData.put('pse__Is_Billable__c','true');
            UtilityTestData.mAssignmentData.put('pse__Role__c','Senior Consultant');
            UtilityTestData.mAssignmentData.put('pse__Cost_Rate_Amount__c','10.00');//
            UtilityTestData.mAssignmentData.put('pse__Resource_Request__c',lResourceRequest[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssignmentData);
            List<pse__Assignment__c> lAssignment = (List<pse__Assignment__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            */
            pse__Expense_Report__c er = new pse__Expense_Report__c(Name = 'Test Expense Report-1',pse__Status__c = 'Draft',pse__Reimbursement_Currency__c = 'USD');
            uow.registerRelationship(er, pse__Expense_Report__c.pse__Project__c, proj1);
            uow.registerRelationship(er, pse__Expense_Report__c.pse__Assignment__c, asgmt1);
            uow.registerNew(er, pse__Expense_Report__c.pse__Resource__c, con);
            
            /*
            UtilityTestData.mExpenseReport.put('Name','Test Expense Report-1');
            UtilityTestData.mExpenseReport.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mExpenseReport.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mExpenseReport.put('pse__Status__c','Draft');
            UtilityTestData.mExpenseReport.put('pse__Assignment__c',lAssignment[0].Id);
            UtilityTestData.mExpenseReport.put('pse__Reimbursement_Currency__c','USD');
            UtilityTestData.mExpenseReport.put('psa_External_Id__c','false');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpenseReport); 
            List<pse__Expense_Report__c> lExpenseReport = (List<pse__Expense_Report__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            */
            pse__Expense__c exp1 = new pse__Expense__c(pse__Status__c = 'Draft',pse__Amount__c = 99, pse__Non_Reimbursible__c = false,
                                                       pse__Billable__c = false, pse__Reimbursement_Currency__c = 'INR');
            uow.registerRelationship(exp1, pse__Expense__c.pse__Resource__c, con);
            uow.registerRelationship(exp1, pse__Expense__c.pse__Project__c, proj1);
            uow.registerRelationship(exp1, pse__Expense__c.pse__Assignment__c, asgmt1);
            uow.registerNew(exp1, pse__Expense__c.pse__Expense_Report__c, er);
            
            pse__Expense__c exp2 = new pse__Expense__c(pse__Status__c = 'Draft',pse__Amount__c = 199, pse__Non_Reimbursible__c = false,
                                                       pse__Billable__c = false, pse__Reimbursement_Currency__c = 'USD');
            uow.registerRelationship(exp2, pse__Expense__c.pse__Resource__c, con);
            uow.registerRelationship(exp2, pse__Expense__c.pse__Project__c, proj1);
            uow.registerRelationship(exp2, pse__Expense__c.pse__Assignment__c, asgmt1);
            uow.registerNew(exp2, pse__Expense__c.pse__Expense_Report__c, er);
            /*
            sObj = new pse__Expense__c();
            UtilityTestData.mExpense.put('Name','Test Expense-1');
            UtilityTestData.mExpense.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mExpense.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mExpense.put('pse__Status__c','Draft');
            UtilityTestData.mExpense.put('pse__Assignment__c',lAssignment[0].Id);
            UtilityTestData.mExpense.put('pse__Amount__c','99');
            UtilityTestData.mExpense.put('pse__Expense_Report__c',lExpenseReport[0].Id);
            UtilityTestData.mExpense.put('pse__Non_Reimbursible__c','false'); 
            UtilityTestData.mExpense.put('pse__Billable__c','false');
            UtilityTestData.mExpense.put('pse__Reimbursement_Currency__c','INR');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mExpense); 
            
            sObj1 = new pse__Expense__c();
            UtilityTestData.mExpense.put('Name','Test Expense-2');
            UtilityTestData.mExpense.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mExpense.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mExpense.put('pse__Status__c','Draft');
            UtilityTestData.mExpense.put('pse__Assignment__c',lAssignment[0].Id);
            UtilityTestData.mExpense.put('pse__Amount__c','199');
            UtilityTestData.mExpense.put('pse__Expense_Report__c',lExpenseReport[0].Id);
            UtilityTestData.mExpense.put('pse__Non_Reimbursible__c','false'); 
            UtilityTestData.mExpense.put('pse__Billable__c','false');
            UtilityTestData.mExpense.put('pse__Reimbursement_Currency__c','USD');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mExpense); 
            List<pse__Expense__c> lExpense = (List<pse__Expense__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});  
            */
            
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }
    }
    
    
    static testMethod void testschedule() {
        Test.StartTest();
        psa_em_ExpenseRollupFixBatchScheduler schClass = new psa_em_ExpenseRollupFixBatchScheduler();
        String cronexpression = '0 0 1 * * ?';
        System.schedule('PSA-Update Project on Expense Batch = TEST CLASS', cronexpression, schClass);
        Test.stopTest();        
    }
}