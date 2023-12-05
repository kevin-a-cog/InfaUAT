/*
@created by       : Pavithra V
@created on       : 12/04/2020
@Purpose          : Test class for psa_tm_TimeCardTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest(seeAllData=false)
public class psa_tm_TimeCardTriggerHelperTest {
    
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_TimeCard_Trigger__c = true;
        insert trigSetting;
    }
    
    @testSetup
    static void setupObjectTestData() {
        
        setupCustomSettings();
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        System.debug('AccRecType'+ AccRecType.Id);
        
        Sobject sObj;
        Sobject sObj1;
        
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
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        Profile prof = [select Name from Profile where Name = 'System Administrator'];
         User psaNonAdminUser = new User(alias='psaNAmin',
                                 username='psaUser2TestNAdmin@abc123.com',
                                 lastname='psaUserTestNonAdmin',
                                 firstname='psaUserTestNonAdmin',
                                 email='psaUser2TestNAdmin@abc123.com',
                                 communitynickname='psaNAmin',
                                 timezonesidkey='America/New_York',
                                 LocaleSidKey='en_US',
                                 ProfileId=prof.Id,
                                 LanguageLocaleKey='en_US',
                                 EmailEncodingKey='UTF-8');
        insert psaNonAdminUser;
        
        User userObj =  [select Id,ManagerId, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar; 
            
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
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
            UtilityTestData.mContactData.put('Is_Primary__c','false');
            UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
            UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');//
            UtilityTestData.mContactData.put('psa_Target_Bill_Rate__c','10.00');
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
            
            Test.startTest();
                        
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
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
            
            Test.stopTest();
            
            sObj = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//pse__Stage__c 
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('pse__Is_Billable__c','true');//
            UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');    
            UtilityTestData.mProjectData.put('psa_pm_Time_Approval_Method__c','Auto-Approve');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
            
            sObj1 = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('psa_pm_Time_Approval_Method__c','Auto-Approve');
            UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true'); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new pse__Time_Period__c();
            UtilityTestData.mTimePeriod.put('pse__Start_Date__c',System.today()+'');
            UtilityTestData.mTimePeriod.put('pse__End_Date__c',System.today()+'');
            UtilityTestData.mTimePeriod.put('pse__Type__c','Quarter');//pse__Project__c
            UtilityTestData.mTimePeriod.put('pse__Project__c',lProject[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimePeriod);
            List<pse__Time_Period__c> lTimePeriod = (List<pse__Time_Period__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
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
                        
            sObj = new pse__Permission_Control__c();
            UtilityTestData.mPermissionControl.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mPermissionControl.put('pse__User__c',userObj.Id);
            UtilityTestData.mPermissionControl.put('pse__Staffing__c','true');
            UtilityTestData.mPermissionControl.put('pse__Timecard_Ops_Edit__c','true');
            UtilityTestData.mPermissionControl.put('pse__Cascading_Permission__c','true');//pse__Timecard_Entry__c
            UtilityTestData.mPermissionControl.put('pse__Timecard_Entry__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPermissionControl);
            
            sObj1 = new pse__Permission_Control__c();
            UtilityTestData.mPermissionControl.put('pse__Project__c',lProject[1].Id);
            UtilityTestData.mPermissionControl.put('pse__User__c',userObj.Id);
            UtilityTestData.mPermissionControl.put('pse__Staffing__c','true');
            UtilityTestData.mPermissionControl.put('pse__Timecard_Ops_Edit__c','true');
            UtilityTestData.mPermissionControl.put('pse__Cascading_Permission__c','true');
            UtilityTestData.mPermissionControl.put('pse__Resource_Request_Entry__c','true');
            UtilityTestData.mPermissionControl.put('pse__Timecard_Entry__c','true');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPermissionControl);
            List<pse__Permission_Control__c> lPermissionCtrl = (List<pse__Permission_Control__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new PSA_MSA_Code_Mapping__c();
            UtilityTestData.mCodeMapping.put('Name','Test Name');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCodeMapping); 
            List<PSA_MSA_Code_Mapping__c> lCodeMapping = (List<PSA_MSA_Code_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new pse__Resource_Request__c();
            UtilityTestData.mResourceRequest.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mResourceRequest.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mResourceRequest.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('PSA_RM_Assignment_Type__c','Internal');
            UtilityTestData.mResourceRequest.put('pse__Staffer_Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mResourceRequest.put('pse__SOW_Hours__c','8.00');
            UtilityTestData.mResourceRequest.put('pse__Resource_Role__c','Consultant');
            UtilityTestData.mResourceRequest.put('pse__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_MSA_Code_Mapping__c',lCodeMapping[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_Original_Opportunity__c',lOpportunity[0].Id);//pse__Opportunity__c
            UtilityTestData.mResourceRequest.put('PSA_OM_Opportunity_Product_Id__c',oppLine.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mResourceRequest); 
            List<pse__Resource_Request__c> lResourceRequest = (List<pse__Resource_Request__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new pse__Assignment__c();
            UtilityTestData.mAssignmentData.put('Name','Test Assignment');
            UtilityTestData.mAssignmentData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mAssignmentData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mAssignmentData.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Schedule__c',lSchedule[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Planned_Hours__c','7.00');
            UtilityTestData.mAssignmentData.put('pse__Bill_Rate__c','0.00');
            UtilityTestData.mAssignmentData.put('pse__Is_Billable__c','true');
            UtilityTestData.mAssignmentData.put('pse__Role__c','Senior Consultant');
            UtilityTestData.mAssignmentData.put('pse__Cost_Rate_Amount__c','10.00');
            UtilityTestData.mAssignmentData.put('pse__Resource_Request__c',lResourceRequest[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssignmentData);
            
            sObj1 = new pse__Assignment__c();
            UtilityTestData.mAssignmentData.put('Name','Test Assignment');
            UtilityTestData.mAssignmentData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mAssignmentData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mAssignmentData.put('pse__Resource__c',lContact[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Project__c',lProject[1].Id);
            UtilityTestData.mAssignmentData.put('pse__Schedule__c',lSchedule[0].Id);
            UtilityTestData.mAssignmentData.put('pse__Planned_Hours__c','7.00');
            UtilityTestData.mAssignmentData.put('pse__Bill_Rate__c','0.00');
            UtilityTestData.mAssignmentData.put('pse__Is_Billable__c','true');
            UtilityTestData.mAssignmentData.put('pse__Role__c','Senior Consultant');
            UtilityTestData.mAssignmentData.put('pse__Cost_Rate_Amount__c','10.00');
            UtilityTestData.mAssignmentData.put('pse__Resource_Request__c',lResourceRequest[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssignmentData);
            List<pse__Assignment__c> lAssignment = (List<pse__Assignment__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            pse__Project_Location__c location = new pse__Project_Location__c();
            location.pse__End_Date__c = system.today();
            location.pse__Start_Date__c = system.today()-6;
            location.psa_pm_Primary__c= true;
            location.pse__Project__c = lProject[0].Id;  
            insert location;
            
            pse__Timecard_Header__c testTimecard = new pse__Timecard_Header__c();
            testTimecard.pse__End_Date__c = system.today();
            testTimecard.pse__Start_Date__c = system.today()-6;
            testTimecard.pse__Resource__c= lContact[0].Id;
            testTimecard.pse__Project__c = lProject[0].Id;
            testTimecard.pse__Assignment__c = lAssignment[0].Id;
            testTimecard.pse__Status__c = 'Saved';
            testTimecard.psa_pm_Project_Portfolio_Manager__c = userObj.Id;
            testTimecard.pse__Approver__c = userObj.Id;
            testTimecard.pse__Primary_Project_Location__c =location.Id;
            insert testTimecard;
            
            pse__Timecard__c timecard = new pse__Timecard__c();
            timecard.pse__Project__c = lProject[0].Id;
            timecard.pse__Start_Date__c = System.today()-6;
            timecard.pse__End_Date__c = System.today();
            timecard.pse__Resource__c = lContact[0].Id;
            timecard.pse__Assignment__c= lAssignment[0].Id;
            timecard.pse__Timecard_Header__c = testTimecard.Id;//
            insert timecard;
        }
    }
    
    public static testMethod void TimecardHeaderTriggerTest() {
        
        User userObj =  [select Id from User where Id =:UserInfo.getUserId() limit 1];
        
        System.runAs(userObj){
            
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
            
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
            
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
            
        List<pse__Timecard_Header__c> lTimeCardHeader = [SELECT Id,pse__Status__c from pse__Timecard_Header__c ];
        System.assert(lTimeCardHeader.size()>0, 'TimeCard Header not created');
        
        Test.startTest();
            
        List<pse__Permission_Control__c> lPermissionCtrl = [SELECT Id from pse__Permission_Control__c];
        System.assert(lPermissionCtrl.size()>0, 'Permission Control not created');
            
        List<pse__Assignment__c> lAssignment = [SELECT Id from pse__Assignment__c];
        System.assert(lAssignment.size()>0, 'Assignment not created');
            
        lTimeCardHeader[0].pse__Sunday_Hours__c =1;
        lTimeCardHeader[0].pse__Monday_Hours__c =1;
        lTimeCardHeader[0].pse__Tuesday_Hours__c=1;
        lTimeCardHeader[0].pse__Wednesday_Hours__c =1;
        lTimeCardHeader[0].pse__Thursday_Hours__c =1;
        lTimeCardHeader[0].pse__Friday_Hours__c =1;
        lTimeCardHeader[0].pse__Saturday_Hours__c =1;
        lTimeCardHeader[0].pse__Status__c = 'Saved';
        lTimeCardHeader[0].pse__Admin_Global_Edit__c = true;
        lTimeCardHeader[0].pse__Audit_Notes__c = 'Test';
        lTimeCardHeader[0].pse__Project__c = lProject[1].Id;
        lTimeCardHeader[0].pse__Assignment__c = lAssignment[1].Id;
        update lTimeCardHeader[0];
                     
        Test.stopTest();
        }
    }
    
    public static testMethod void TimecardHeaderTriggerErrorTest() {
        
        User userObj =  [select Id from User where Id =:UserInfo.getUserId() limit 1];
        
        System.runAs(userObj){
            
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
            
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
            
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        Test.startTest();
                    
        List<pse__Timecard_Header__c> lTimeCardHeader = [SELECT Id,pse__Status__c,pse__Approved__c,pse__Submitted__c from pse__Timecard_Header__c ];
        System.assert(lTimeCardHeader.size()>0, 'TimeCard Header not created');
            
        List<pse__Permission_Control__c> lPermissionCtrl = [SELECT Id from pse__Permission_Control__c];
        System.assert(lPermissionCtrl.size()>0, 'Permission Control not created');
        lPermissionCtrl[0].pse__Timecard_Ops_Edit__c = true;
        update lPermissionCtrl;
            
        List<pse__Assignment__c> lAssignment = [SELECT Id from pse__Assignment__c];
        System.assert(lAssignment.size()>0, 'Assignment not created');
            
        List<pse__Project_Location__c> lprojLocation = [Select Id from pse__Project_Location__c];
            
            try{
                pse__Timecard_Header__c testTimecard = new pse__Timecard_Header__c();
                testTimecard.pse__End_Date__c = system.today();
                testTimecard.pse__Start_Date__c = system.today()-6;
                testTimecard.pse__Resource__c= lContact[0].Id;
                testTimecard.pse__Project__c = lProject[0].Id;
                testTimecard.pse__Assignment__c = lAssignment[0].Id;
                testTimecard.pse__Status__c = 'Saved';
                testTimecard.pse__Primary_Project_Location__c =lprojLocation[0].Id;
                testTimecard.psa_pm_Project_Portfolio_Manager__c = userObj.Id;
                testTimecard.pse__Approver__c = userObj.Id;
                testTimecard.pse__Sunday_Hours__c =9;
                testTimecard.pse__Monday_Hours__c =1;
                testTimecard.pse__Tuesday_Hours__c=1;
                testTimecard.pse__Wednesday_Hours__c =1;
                testTimecard.pse__Thursday_Hours__c =1;
                testTimecard.pse__Friday_Hours__c =1;
                testTimecard.pse__Saturday_Hours__c =1;
                insert testTimecard;
                
            }catch(exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Timecard cannot be saved.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

        Test.stopTest();
        }
    }
   
    public static testMethod void TimeCardTriggerDeletionTest() {
          
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        Test.startTest();

        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        List<pse__Timecard_Header__c> lTimeCardHeader = [SELECT Id,pse__Status__c from pse__Timecard_Header__c ];
        System.assert(lTimeCardHeader.size()>0, 'TimeCard Header not created');
        
        delete lTimeCardHeader;
        
        Test.stopTest();
    }
    
}