/*
@created by       : RANJAN KISHORE
@created on       : 04/02/2020
@Purpose          : This Test class provides code coverages to the trigger PSA_AssignmentTrigger 
and its handler and helper classes.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/
@isTest
    public with sharing class PSA_AssignmentTriggerTest {
        private static List<Schema.SObjectType> sObjects = 
        new Schema.SObjectType[]{
            Bypass_Trigger_Settings__c.SobjectType,
            User_Exemptions__c.SobjectType,
            Account.SobjectType,
            User.SobjectType,
            pse__Region__c.SobjectType,
            pse__Work_Calendar__c.SobjectType,
            Contact.SobjectType,
            Opportunity.SobjectType,
            pse__Permission_Control__c.SobjectType,
            pse__Proj__c.SobjectType,
            PSA_MSA_Code_Mapping__c.SobjectType,
            pse__Project_Location__c.SobjectType,
            pse__Schedule__c.SobjectType,
            pse__Resource_Request__c.SobjectType,
            pse__Assignment__c.SObjectType
        };
    @testSetup
    static void initializeData(){
        UnitOfWork uow = new UnitOfWork(sObjects);

        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        // Turn on the Assignment Trigger via Custom Settings.
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_AssignmentTrigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        uow.registerNew(trigSetting);

        //Skip Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);
        
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
        
        // Create user/Resource         
        Profile prof = [select Name from Profile where Name = 'Employee'];        
        
        User user1 = new User(CommunityNickname='communityuser',
                                  ProfileId=prof.Id,
                                  LastName='Testing1',
                                  Alias='userTep1',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8',
                                  Email='usr_temp1@testorg.com',
                                  UserName='usr_temp1@testorg.com');
        uow.registerNew(user1);
            
        User user2 = new User(CommunityNickname='communityuser1',
                                  ProfileId=prof.Id,
                                  LastName='Testing2',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8',
                                  Alias='usrTemp2',
                                  Email='usr_temp2@testorg.com',
                                  Username='usr_temp2@testorg.com');
        uow.registerNew(user2);
        
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
                
        // Create Contact
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00,
                                       psa_Target_Bill_Rate__c = 10,
                                       CurrencyIsoCode='USD'
                                       );
        uow.registerRelationship(con1, Contact.pse__Salesforce_User__c,user1);                               
        uow.registerRelationship(con1, Contact.AccountId,acc1);
        uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
        uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);

        Contact con2 = new Contact(LastName = 'Test Contact 2',
                                   pse__Resource_Role__c='Regional Manager',
                                   pse__Is_Resource__c=true,
                                   Is_Primary__c=false,
                                   pse__Is_Resource_Active__c=true,
                                   pse__Default_Cost_Rate__c=11.00);
        uow.registerRelationship(con2, Contact.pse__Salesforce_User__c,user2);   
        uow.registerRelationship(con2, Contact.AccountId,acc2);
        uow.registerRelationship(con2, Contact.pse__Region__c, reg2);
        uow.registerNew(con2, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
        
        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               StageName='Validate',
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
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
            uow.registerNew(opty2, Opportunity.AccountId, acc2); 
      
        //Create Permission Control
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
        
         system.runAs(userObj){
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
        
        //Create Project Location   
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
        pse__Schedule__c schRec3 = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(13),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec3);
        pse__Schedule__c schRec4 = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(14),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec4);
        pse__Schedule__c schRec5 = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(15),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec5);
        pse__Schedule__c schRec6 = new pse__Schedule__c(pse__Start_Date__c=currentDate.addDays(1),
                                                           pse__End_Date__c=currentDate.addDays(14),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
        uow.registerNew(schRec6);
       
        // Create Resource Request 
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
                                                                      pse__End_Date__c=System.today().addDays(10),
                                                                      pse__SOW_Hours__c=8.00,
                                                                      pse__Resource_Role__c='Consultant',
                                                                      psa_rm_Billable__c=true,
                                                                      pse__Status__c='Draft');
        uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Region__c,reg1);
        uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Project__c,projRec1);
        uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Opportunity__c,opty);
        uow.registerRelationship(rrRec2, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping1);
        uow.registerNew(rrRec2, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty); 
        pse__Resource_Request__c rrRec3 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                      pse__End_Date__c=System.today().addDays(10),
                                                                      pse__SOW_Hours__c=8.00,
                                                                      pse__Resource_Role__c='Consultant',
                                                                      psa_rm_Billable__c=true,
                                                                      pse__Status__c='Draft');
        uow.registerRelationship(rrRec3, pse__Resource_Request__c.pse__Region__c,reg1);
        uow.registerRelationship(rrRec3, pse__Resource_Request__c.pse__Project__c,projRec1);
        uow.registerRelationship(rrRec3, pse__Resource_Request__c.pse__Opportunity__c,opty);
        uow.registerRelationship(rrRec3, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping1);
        uow.registerNew(rrRec3, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty); 
        
        pse__Resource_Request__c rrRec4 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                      pse__End_Date__c=System.today().addDays(15),
                                                                      pse__SOW_Hours__c=6.00,
                                                                      pse__Resource_Role__c='Consultant',
                                                                      psa_rm_Billable__c=true,
                                                                      pse__Status__c='Draft');    
        uow.registerRelationship(rrRec4, pse__Resource_Request__c.pse__Region__c,reg1);
        uow.registerRelationship(rrRec4, pse__Resource_Request__c.pse__Project__c,projRec2);
        uow.registerRelationship(rrRec4, pse__Resource_Request__c.pse__Opportunity__c,opty2);
        uow.registerRelationship(rrRec4, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping2);
        uow.registerNew(rrRec4, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty2);
        
        pse__Resource_Request__c rrRec5 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                      pse__End_Date__c=System.today().addDays(15),
                                                                      pse__SOW_Hours__c=6.00,
                                                                      pse__Resource_Role__c='Consultant',
                                                                      psa_rm_Billable__c=true,
                                                                      pse__Status__c='Draft');   
        uow.registerRelationship(rrRec5, pse__Resource_Request__c.pse__Region__c,reg1);
        uow.registerRelationship(rrRec5, pse__Resource_Request__c.pse__Project__c,projRec2);
        uow.registerRelationship(rrRec5, pse__Resource_Request__c.pse__Opportunity__c,opty2);
        uow.registerRelationship(rrRec5, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping2);
        uow.registerNew(rrRec5, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty2);
        
        pse__Resource_Request__c rrRec6 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                      pse__End_Date__c=System.today().addDays(15),
                                                                      pse__SOW_Hours__c=6.00,
                                                                      pse__Resource_Role__c='Consultant',
                                                                      psa_rm_Billable__c=true,
                                                                      pse__Status__c='Draft');    
        uow.registerRelationship(rrRec6, pse__Resource_Request__c.pse__Region__c,reg1);
        uow.registerRelationship(rrRec6, pse__Resource_Request__c.pse__Project__c,projRec2);
        uow.registerRelationship(rrRec6, pse__Resource_Request__c.pse__Opportunity__c,opty2);
        uow.registerRelationship(rrRec6, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping2);
        uow.registerNew(rrRec6, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty2);
        
        // Create Assignment
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
                                                            pse__Cost_Rate_Amount__c = 0,
                                                            pse__Planned_Hours__c = 8,
                                                            pse__Bill_Rate__c = 0,
                                                            pse__Is_Billable__c = true,
                                                            CurrencyIsoCode='USD',
                                                            pse__Role__c = 'Senior Consultant');
        uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Project__c, projRec1);
        uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Schedule__c,schRec2);
        uow.registerRelationship(asgmt2, pse__Assignment__c.pse__Resource_Request__c, rrRec2);
        uow.registerNew(asgmt2, pse__Assignment__c.pse__Resource__c, con1);
        pse__Assignment__c asgmt3 = new pse__Assignment__c(Name = 'Test Assignment 3',
                                                            pse__Cost_Rate_Amount__c = 0,
                                                            pse__Planned_Hours__c = 8,
                                                            pse__Bill_Rate__c = 0,
                                                            pse__Is_Billable__c = true,
                                                            pse__Role__c = 'Senior Consultant');
        uow.registerRelationship(asgmt3, pse__Assignment__c.pse__Project__c, projRec1);
        uow.registerRelationship(asgmt3, pse__Assignment__c.pse__Schedule__c,schRec3);
        uow.registerRelationship(asgmt3, pse__Assignment__c.pse__Resource_Request__c, rrRec3);
        uow.registerNew(asgmt3, pse__Assignment__c.pse__Resource__c, con1);
        pse__Assignment__c asgmt4 = new pse__Assignment__c(Name = 'Test Assignment 4',
                                                            pse__Cost_Rate_Amount__c = 0,
                                                            pse__Planned_Hours__c = 8,
                                                            pse__Bill_Rate__c = 0,
                                                            pse__Is_Billable__c = true,
                                                            pse__Role__c = 'Senior Consultant');
        uow.registerRelationship(asgmt4, pse__Assignment__c.pse__Project__c, projRec2);
        uow.registerRelationship(asgmt4, pse__Assignment__c.pse__Schedule__c,schRec4);
        uow.registerRelationship(asgmt4, pse__Assignment__c.pse__Resource_Request__c, rrRec4);
        uow.registerNew(asgmt4, pse__Assignment__c.pse__Resource__c, con2);
        pse__Assignment__c asgmt5 = new pse__Assignment__c(Name = 'Test Assignment 5',
                                                            pse__Cost_Rate_Amount__c = 0,
                                                            pse__Planned_Hours__c = 8,
                                                            pse__Bill_Rate__c = 0,
                                                            pse__Is_Billable__c = true,
                                                            pse__Role__c = 'Senior Consultant');
        uow.registerRelationship(asgmt5, pse__Assignment__c.pse__Project__c, projRec2);
        uow.registerRelationship(asgmt5, pse__Assignment__c.pse__Schedule__c,schRec5);
        uow.registerRelationship(asgmt5, pse__Assignment__c.pse__Resource_Request__c, rrRec5);
        uow.registerNew(asgmt5, pse__Assignment__c.pse__Resource__c, con2);
        pse__Assignment__c asgmt6 = new pse__Assignment__c(Name = 'Test Assignment 6',
                                                            pse__Cost_Rate_Amount__c = 0,
                                                            pse__Planned_Hours__c = 8,
                                                            pse__Bill_Rate__c = 0,
                                                            pse__Is_Billable__c = true,
                                                            pse__Role__c = 'Senior Consultant');
        uow.registerRelationship(asgmt6, pse__Assignment__c.pse__Project__c, projRec2);
        uow.registerRelationship(asgmt6, pse__Assignment__c.pse__Schedule__c,schRec6);
        uow.registerRelationship(asgmt6, pse__Assignment__c.pse__Resource_Request__c, rrRec6);
        uow.registerNew(asgmt6, pse__Assignment__c.pse__Resource__c, con2);

            Test.startTest();
            uow.commitWork();                                         
            Test.stopTest();
        }
    }

    @isTest
    public static void validateDefaultsForShadowingTypeOnInsert(){        
        Test.startTest();
        pse__Assignment__c assgmt = [SELECT Id,pse__Cost_Rate_Amount__c,pse__Use_Resource_Default_Cost_Rate__c FROM pse__Assignment__c WHERE psa_rm_Assignment_Type__c = 'Shadowing' LIMIT 1];        
        Test.stopTest();
        
        system.assertEquals(0, assgmt.pse__Cost_Rate_Amount__c);
        system.assertEquals(false, assgmt.pse__Use_Resource_Default_Cost_Rate__c);        
    }

    @isTest
    public static void validateDefaultsForShadowingTypeOnUpdate(){        
        Test.startTest();
        pse__Assignment__c assgmt = [SELECT Id FROM pse__Assignment__c WHERE psa_rm_Assignment_Type__c <> 'Shadowing' LIMIT 1];        
        assgmt.psa_rm_Assignment_Type__c = 'Shadowing';
        update assgmt;
        assgmt = [SELECT Id,pse__Cost_Rate_Amount__c,pse__Use_Resource_Default_Cost_Rate__c FROM pse__Assignment__c WHERE ID = :assgmt.Id LIMIT 1];
        Test.stopTest();
        
        system.assertEquals(0, assgmt.pse__Cost_Rate_Amount__c);
        system.assertEquals(false, assgmt.pse__Use_Resource_Default_Cost_Rate__c); 
            
    }
    
    @isTest
    public static void updateProjectEndDateTestOnInsert(){
       
        Test.startTest();
        pse__Schedule__c scheduleRec = [select id,pse__End_Date__c, Name from pse__Schedule__c order by pse__End_Date__c desc Limit 1];
        
        pse__Assignment__c assignmentRec = [select id,pse__End_Date__c,pse__Project__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Schedule__c =:scheduleRec.Id LIMIT 1];
        
        pse__Proj__c projRec =[select Id,pse__End_Date__c from pse__Proj__c where Id=:assignmentRec.pse__Project__c];
           
        Test.stopTest();
        
        system.assertEquals(assignmentRec.pse__End_Date__c, projRec.pse__End_Date__c);
        
    }
    @isTest
    public static void updateProjectEndDateTestOnUpdate(){
      
        Date scheduleEndDateBefore;
        Date projEndDateBefore;
        
        Test.startTest();
        pse__Schedule__c scheduleRec = [select id,pse__End_Date__c, Name from pse__Schedule__c order by pse__End_Date__c Limit 1];
        pse__Assignment__c assignmentRec = [select id,pse__End_Date__c,pse__Project__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Schedule__c =:scheduleRec.Id LIMIT 1];
        
        scheduleEndDateBefore = scheduleRec.pse__End_Date__c;
        
        scheduleRec.pse__End_Date__c = scheduleEndDateBefore.addDays(10);
        
        update scheduleRec;
        
        pse__Proj__c projRecBefore =[select Id,pse__End_Date__c from pse__Proj__c where Id=:assignmentRec.pse__Project__c];
        
        projEndDateBefore = projRecBefore.pse__End_Date__c;
        
        update assignmentRec;
        
        Test.stopTest();
        
         pse__Proj__c projRecAfter =[select Id,pse__End_Date__c from pse__Proj__c where Id=:assignmentRec.pse__Project__c];
       
        //system.assertEquals(scheduleEndDateBefore, projEndDateBefore);
        //system.assertEquals(scheduleEndDateBefore.addDays(10), projRecAfter.pse__End_Date__c);
        
    }
    @isTest
    public static void createPermControlAfterAssignInsertTest1(){
       // To Test assignment record with role that creates the permission control record.
        pse__Assignment__c assignmentRec = [select Id,pse__Role__c,pse__End_Date__c,pse__Project__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Role__c!=null and pse__Resource__r.pse__Salesforce_User__c!=null Limit 1];
        
       List<pse__Permission_Control__c> permControlList = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        system.assertEquals(1, permControlList.size());
    }
    @isTest
    public static void createPermControlAfterAssignInsertTest2(){
       // To Test assignment record without role that will not create the permission control record.
        pse__Assignment__c assignmentRec = [select Id,pse__Role__c,pse__End_Date__c,pse__Project__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Role__c=null and pse__Resource__r.pse__Salesforce_User__c!=null Limit 1];
        
       List<pse__Permission_Control__c> permControlList = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        system.assertEquals(0, permControlList.size());
        
    }
    @isTest
    public static void updatePermControlAfterAssignUpdateTest1(){
       Test.startTest();
        // To Test assignment record without role that gets updated with a role which will create the permission control record.
        pse__Assignment__c assignmentRec = [select Id,pse__Role__c,pse__End_Date__c,pse__Project__c,pse__Resource__r.pse__Salesforce_User__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Role__c=null and pse__Resource__r.pse__Salesforce_User__c!=null Limit 1];
        system.debug('Before rec'+assignmentRec.pse__Role__c);
       List<pse__Permission_Control__c> permControlListBefore = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        assignmentRec.pse__Role__c ='Project Manager';
        update assignmentRec;
        Test.stopTest();
        pse__Assignment__c assignmentAfterRec = [select Id,pse__Role__c,pse__End_Date__c,pse__Project__c,pse__Resource__r.pse__Salesforce_User__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where Id=:assignmentRec.Id];
        
        system.debug('after rec'+assignmentAfterRec.pse__Role__c);
        
        system.debug('check the ids'+(assignmentRec.Id==assignmentAfterRec.Id));
        system.debug('check the roles'+(assignmentRec.pse__Role__c!=assignmentAfterRec.pse__Role__c));
        system.debug('check the roles'+(assignmentRec.pse__Role__c!=assignmentAfterRec.pse__Role__c));
        
        
        List<pse__Permission_Control__c> permControlListafter = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        
        system.assertEquals(0, permControlListBefore.size());
        system.assertEquals(1, permControlListafter.size());
    }
    @isTest
    public static void updatePermControlAfterAssignUpdateTest2(){
        
        // To Test assignment record with role that gets updated with a different role
       // which will delete the exisiting permission control and create a new permission control record.
        Test.startTest();
        String existingPermCtrlId;
        Id newPermCtrlId;
        boolean existingPermCtrlDeleted = true;
        pse__Assignment__c assignmentRec = [select Id,pse__Role__c,pse__End_Date__c,pse__Project__c, Name,pse__Schedule__r.pse__End_Date__c 
                                            from pse__Assignment__c where pse__Role__c!=null and pse__Resource__r.pse__Salesforce_User__c!=null Limit 1];
        
       List<pse__Permission_Control__c> permControlListBefore = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        existingPermCtrlId = permControlListBefore[0].Id;
        assignmentRec.pse__Role__c ='Project Manager';
        update assignmentRec;
        
        Test.stopTest();
        List<pse__Permission_Control__c> permControlListafter = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c
                                                    WHERE psa_us_Assignment__c =:assignmentRec.Id AND pse_us_Is_Automated__c = true];
        
        for(pse__Permission_Control__c permControlRec : permControlListafter){
            
            if(permControlRec.Id==existingPermCtrlId){
                existingPermCtrlDeleted = false;
            }            
        }
        
        system.assert(existingPermCtrlDeleted);
        system.assertEquals(1, permControlListBefore.size());
        system.assertEquals(1, permControlListafter.size());
    }    
}