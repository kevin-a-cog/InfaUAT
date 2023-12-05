/*
@created by       : Pavithra V
@created on       : 12/04/2020
@Purpose          : Test class for psa_rm_ResourceRequestTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest(seeAllData=false)
public class psa_rm_ResourceRequestTriggerHelperTest {
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_ResourceRequest_Trigger__c = true;
        insert trigSetting;
    }
    
    @testSetup
    static void setupObjectTestData() {
        
        setupCustomSettings();
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
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
        UtilityTestData.mRegion.put('psa_pm_Allow_Customer_Project__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('psa_pm_Allow_Customer_Project__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        Profile prof = [select Name from Profile where Name = 'Employee'];
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
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            defaultWorkCalendar.pse__Sunday_Hours__c= 8;
            defaultWorkCalendar.pse__Monday_Hours__c=8;
            defaultWorkCalendar.pse__Tuesday_Hours__c=8;
            defaultWorkCalendar.pse__Wednesday_Hours__c=8;
            defaultWorkCalendar.pse__Thursday_Hours__c=8;
            defaultWorkCalendar.pse__Friday_Hours__c=8;
            defaultWorkCalendar.pse__Saturday_Hours__c=8;                
            insert defaultWorkCalendar; 
            
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
            
            for(Contact con : lContact){
                con.pse__Is_Resource__c = true;
                //con.ReportsTo = con;
            }
            update lContact;
            
            
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
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
            UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//
            UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud Adoption Hybrid MDM');
            UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
            UtilityTestData.mOpportunityData.put('pse__Is_Change_Request__c','false');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
            lOpportunity[0].StageName = 'Closed Won';
            update lOpportunity[0];
            
            Test.startTest();
            OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= lPriceBookEntry[0].Id,TotalPrice=2000,Quantity = 2,OpportunityId = lOpportunity[0].Id);
            insert oppLine;
            
            sObj = new pse__Proj__c();
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
            UtilityTestData.mProjectData.put('pse__Region__c',lRegion[0].Id);    
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
            UtilityTestData.mProjectData.put('pse__Is_Billable__c','true');
            UtilityTestData.mProjectData.put('pse__Region__c',lRegion[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new pse__Budget__c();
            UtilityTestData.mBudget.put('pse__Amount__c','1000');
            UtilityTestData.mBudget.put('pse__Effective_Date__c',System.today().addDays(-1)+'');
            UtilityTestData.mBudget.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mBudget.put('pse__Type__c','Customer Purchase Order');
            UtilityTestData.mBudget.put('pse__Billable__c','true');
            UtilityTestData.mBudget.put('pse__Approved__c','true');
            UtilityTestData.mBudget.put('pse__Include_In_Financials__c','true');
            UtilityTestData.mBudget.put('pse__Opportunity__c',lOpportunity[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBudget);
            List<pse__Budget__c> lBudget = (List<pse__Budget__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
                        
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
            UtilityTestData.mPermissionControl.put('pse__Project__c',lproject[0].Id);
            UtilityTestData.mPermissionControl.put('pse__User__c',userObj.Id);
            UtilityTestData.mPermissionControl.put('pse__Staffing__c','true');
            UtilityTestData.mPermissionControl.put('pse__Resource_Request_Entry__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPermissionControl);
            List<pse__Permission_Control__c> lPermissionCtrl = (List<pse__Permission_Control__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new PSA_MSA_Code_Mapping__c();
            UtilityTestData.mCodeMapping.put('Name','Test Name');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCodeMapping); 
            
            sObj1 = new PSA_MSA_Code_Mapping__c();
            UtilityTestData.mCodeMapping.put('Name','Test Name 2');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCodeMapping); 
            List<PSA_MSA_Code_Mapping__c> lCodeMapping = (List<PSA_MSA_Code_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new pse__Project_Location__c();
            UtilityTestData.mLocation.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mLocation.put('psa_pm_MSA_Code_Mapping__c',lCodeMapping[0].Id);//
            UtilityTestData.mLocation.put('psa_pm_Primary__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLocation); 
            List<pse__Project_Location__c> lProjLocation = (List<pse__Project_Location__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new pse__Resource_Request__c();
            UtilityTestData.mResourceRequest.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mResourceRequest.put('pse__End_Date__c',System.today().addDays(10)+'');
            //UtilityTestData.mResourceRequest.put('pse__Resource__c',lContact[0].Id);
            //UtilityTestData.mResourceRequest.put('pse__Staffer_Resource__c',lContact[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Project__c',lProject[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_Billable__c','true');
            UtilityTestData.mResourceRequest.put('pse__SOW_Hours__c','8.00');
            UtilityTestData.mResourceRequest.put('pse__Requested_Bill_Rate__c','8.00');
            UtilityTestData.mResourceRequest.put('pse__Resource_Role__c','Consultant');//
            //UtilityTestData.mResourceRequest.put('psa_rm_Assign_Held_Resource__c','true');
            UtilityTestData.mResourceRequest.put('PSA_OM_Opportunity_Product_Id__c',oppLine.Id);
            UtilityTestData.mResourceRequest.put('psa_rm_MSA_Code_Mapping__c',lCodeMapping[0].Id);
            UtilityTestData.mResourceRequest.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mResourceRequest.put('psa_rm_Original_Opportunity__c',lOpportunity[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mResourceRequest); 
            List<pse__Resource_Request__c> lResourceRequest = (List<pse__Resource_Request__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('lResourceRequest -->' + lResourceRequest[0].Id);
            
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
            
            Test.stopTest();
        }
    }
    
    public static testMethod void ResourceRequestTriggerTest() {
        
        Test.startTest();
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        
        List<pse__Work_Calendar__c> lWorkCalendar = [SELECT Id FROM pse__Work_Calendar__c];
        System.assert(lWorkCalendar.size()>0, 'WorkCalendar not created');
        
        List<pse__Resource_Request__c> lResourceRequest = [Select Id,pse__Project__c from pse__Resource_Request__c];
        System.assert(lResourceRequest.size()>0, 'Resource Request not created');
        
        if(lContact.size()>1){
            lResourceRequest[0].pse__Staffer_Resource__c = lContact[1].Id;
            lContact[1].pse__Work_Calendar__c = lWorkCalendar[0].Id;
            Update lContact;
        update lResourceRequest;
        }
        
              
        
        Test.stopTest();
    }
    
    public static testMethod void populateMSAFieldsTest() {
        
        Test.startTest();
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        
        List<pse__Work_Calendar__c> lWorkCalendar = [SELECT Id FROM pse__Work_Calendar__c];
        System.assert(lWorkCalendar.size()>0, 'WorkCalendar not created');
        
        List<pse__Resource_Request__c> lResourceRequest = [Select Id,pse__Project__c from pse__Resource_Request__c];
        System.assert(lResourceRequest.size()>0, 'Resource Request not created');
        
        List<PSA_MSA_Code_Mapping__c> lMSACodeMapping = [Select Id from PSA_MSA_Code_Mapping__c];
        System.assert(lMSACodeMapping.size()>0, 'MSA CodeMapping not created');
        
        lResourceRequest[0].psa_rm_MSA_Code_Mapping__c = lMSACodeMapping[1].Id ;
        update lResourceRequest;      
        
        Test.stopTest();
    }
    
    public static testMethod void populateMSAFieldsUpdateTest() {
        
        Test.startTest();
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Project_Location__c> lProjLocation = [SELECT Id from pse__Project_Location__c];
        System.assert(lProjLocation.size()>0, 'Project Location not created');
        
        List<pse__Resource_Request__c> lResourceRequest = [Select Id,pse__Project__c from pse__Resource_Request__c];
        System.assert(lResourceRequest.size()>0, 'Resource Request not created');
        
        List<PSA_MSA_Code_Mapping__c> lMSACodeMapping = [Select Id from PSA_MSA_Code_Mapping__c];
        System.assert(lMSACodeMapping.size()>0, 'MSA CodeMapping not created');
        
        lProject[0].psa_pm_Primary_Project_Location__c = lProjLocation[0].Id;
        update lProject;
        
        lResourceRequest[0].psa_rm_MSA_Code_Mapping__c = null;
        update lResourceRequest;      
        
        Test.stopTest();
    }
    
    public static testMethod void updateAssignementRecordsTest() {
        
        Test.startTest();
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Project_Location__c> lProjLocation = [SELECT Id from pse__Project_Location__c];
        System.assert(lProjLocation.size()>0, 'Project Location not created');
        
        List<PSA_MSA_Code_Mapping__c> lMSACodeMapping = [Select Id from PSA_MSA_Code_Mapping__c];
        System.assert(lMSACodeMapping.size()>0, 'MSA CodeMapping not created');
        
        List<Opportunity> lOpportunity = [Select Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Region__c> lRegion =[Select id from pse__Region__c];
        
        List<OpportunityLineItem> lOpportunityLineItem = [Select id from OpportunityLineItem];
        
        List<pse__Assignment__c> lAssignment = [SELECT Id,Name,pse__Role__c,pse__Project__c,pse__Schedule__c FROM pse__Assignment__c];
        
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        
        sObject sObj1 = new pse__Resource_Request__c();
        UtilityTestData.mResourceRequest.put('pse__Start_Date__c',System.today().addDays(10)+'');
        UtilityTestData.mResourceRequest.put('pse__End_Date__c',System.today().addDays(12)+'');
        //UtilityTestData.mResourceRequest.put('pse__Staffer_Resource__c',lContact[0].Id);
        UtilityTestData.mResourceRequest.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mResourceRequest.put('pse__SOW_Hours__c','8.00');
        UtilityTestData.mResourceRequest.put('pse__Resource_Role__c','Consultant');
        //UtilityTestData.mResourceRequest.put('psa_rm_Assign_Held_Resource__c','true');
        UtilityTestData.mResourceRequest.put('PSA_OM_Opportunity_Product_Id__c',lOpportunityLineItem[0].Id);
        //UtilityTestData.mResourceRequest.put('pse__Assignment__c',lAssignment[0].Id);
        UtilityTestData.mResourceRequest.put('psa_rm_MSA_Code_Mapping__c',lMSACodeMapping[0].Id);
        UtilityTestData.mResourceRequest.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mResourceRequest.put('psa_rm_Billable__c','true');
        UtilityTestData.mResourceRequest.put('psa_rm_Original_Opportunity__c',lOpportunity[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mResourceRequest); 
        List<pse__Resource_Request__c> lResourceRequest = (List<pse__Resource_Request__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObject sObj = new pse__Milestone__c();
        UtilityTestData.mMilestone.put('Name','Test Milestone');
        UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','2000.00');
        UtilityTestData.mMilestone.put('CurrencyIsoCode','USD');
        UtilityTestData.mMilestone.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Billing');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mMilestone); 
        List<pse__Milestone__c> lMilestone = (List<pse__Milestone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Skill__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSkill);
        List<pse__Skill__c> lSkill = (List<pse__Skill__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        psa_rm_ResourceRequestTriggerHelper.isTestRun = true;
        lResourceRequest[0].pse__Staffer_Resource__c = lContact[0].Id;
        lResourceRequest[0].pse__Assignment__c = lAssignment[0].Id;
        lResourceRequest[0].psa_rm_Billable__c = true;
        lResourceRequest[0].psa_rm_Assign_Held_Resource__c = true;
        lResourceRequest[0].pse__Requested_Bill_Rate__c = 2000.00;
        lResourceRequest[0].pse__Primary_Skill_Certification__c = lSkill[0].Id;
        lResourceRequest[0].PSA_RM_Submit_for_Staffing__c = true;
        update lResourceRequest;
        System.debug('lResourceRequest1 -->' + lResourceRequest[0].Id);
        
        delete lResourceRequest;
        Test.stopTest();
    } 
}