/*
@created by       : SONIYA CHOUHAN
@created on       : 02/01/2021
@Purpose          : Test class for psa_pm_ProjectContactHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_pm_ProjectContactHelperTest {
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.ProjectContactTrigger__c = true;
        trigSetting.PSA_Project_Contact__c = true;
        insert trigSetting;
        

    }
    
    static void assignPermissionSet(){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Project_Name_Edit'];
        insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Operations'];
        insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = permSet.Id);
    }
    
    static void NonsetupTestData(){
        
    }
    
    @testSetup
    static void setupObjectTestData() {
        setupCustomSettings();
        Sobject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        Sobject sObj2 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-3');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mRegion);
        
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        insert defaultWorkCalendar; 
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
            
        Sobject sObj23 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
        UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
        UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');
        UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
        UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
        UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj23 = UtilityTest.putFieldRecord(sObj23, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj23});
        
       
        
        for(Contact con : lContact){
            con.pse__Is_Resource__c = true;
            //con.ReportsTo = con;
        }
        update lContact;
        
        sObject sObj14 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj14 = UtilityTest.putFieldRecord(sObj14, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj14});

        Sobject sObj5 = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','8 – JumpStart');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
        UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');
        UtilityTestData.mProjectData.put('psa_pm_Primary_Contact__c','true');
        UtilityTestData.mProjectData.put('CurrencyIsoCode','USD');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        
        
        
        List<psa_pm_Project_Contact__c> proConList = new List<psa_pm_Project_Contact__c>();
        psa_pm_Project_Contact__c projCon = new psa_pm_Project_Contact__c(
             psa_pm_Project__c = lProject[0].Id, psa_pm_Contact__c = lContact[0].Id,
              psa_pm_Contact_Role__c = 'PS Customer', psa_pm_Primary_Contact__c =true );
        proConList.add(projCon);
        
        
        
        Insert proConList;
    }
    
    public static testMethod void ProjectContactTriggerTest(){
        list<pse__Proj__c> proj = [SELECT Id FROM pse__Proj__c];
        list<Contact> con = [SELECT Id FROM Contact];
        psa_pm_Project_Contact__c projCon2 = new psa_pm_Project_Contact__c(
            psa_pm_Project__c = proj[0].Id, psa_pm_Contact__c = con[0].Id,
            psa_pm_Contact_Role__c = 'IPS Sales', psa_pm_Primary_Contact__c =true );
        
        List<psa_pm_Project_Contact__c> projContact = [SELECT Id, Name, psa_pm_Project__c,
                                                       psa_pm_Contact__c, psa_pm_Contact_Role__c,
                                                       psa_pm_Primary_Contact__c FROM psa_pm_Project_Contact__c];
        Test.startTest();
        Insert projCon2;
        projContact[0].psa_pm_Contact_Role__c = 'IPS Sales';
        Update projContact;
        Test.stopTest();
    }
    public static testMethod void ProjectContactTriggerTest1(){
        list<pse__Proj__c> proj = [SELECT Id FROM pse__Proj__c];
        list<Contact> con = [SELECT Id FROM Contact];
        psa_pm_Project_Contact__c projCon2 = new psa_pm_Project_Contact__c(
            psa_pm_Project__c = proj[0].Id, psa_pm_Contact__c = con[0].Id,
            psa_pm_Contact_Role__c = 'IPS Sales', psa_pm_Primary_Contact__c =false );
        
        Test.startTest();
        Insert projCon2;
        projCon2.psa_pm_Primary_Contact__c = True;
        Update projCon2;
        Test.stopTest();
    }
}