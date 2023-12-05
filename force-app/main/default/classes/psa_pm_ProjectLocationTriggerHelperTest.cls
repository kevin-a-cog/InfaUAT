/*
@created by       : SONIYA CHOUHAN
@created on       : 01/25/2021
@Purpose          : Test class for psa_pm_ProjectLocationTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public with sharing class psa_pm_ProjectLocationTriggerHelperTest {
    

    @testSetup
    static void setupObjectTestData() {
        
        Bypass_Trigger_Settings__c settings = new Bypass_Trigger_Settings__c();
        settings.SetupOwnerId = UserInfo.getUserId();
		settings.PSA_Project_Location__c = true;//setting it to true so that trigger is not bypassed
		upsert settings;

        Sobject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        Sobject sObj2 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-3');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mRegion);
        
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        // User runUser =  [select Id, Name, UserRole.DeveloperName from User where UserRole.DeveloperName LIKE 'PS_%' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1];
        
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
        }
        update lContact;
        
        sObject sObj14 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj14 = UtilityTest.putFieldRecord(sObj14, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj14});
        
        PSA_MSA_Code_Mapping__c ppmc = new PSA_MSA_Code_Mapping__c();
        ppmc.psa_pm_City_Name__c = 'Test City';
        ppmc.psa_pm_County_Name__c = 'Test County';
        ppmc.psa_pm_MSA_Code__c = 'MSA Code';
        ppmc.psa_pm_Work_Country__c = 'Test Work County';
        insert ppmc;

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
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        
        Sobject sObj61 = new pse__Project_Location__c();
        UtilityTestData.mLocation.put('Name','Test Location');
        UtilityTestData.mLocation.put('pse__Project__c',lProject[0].Id);
        sObj61 = UtilityTest.putFieldRecord(sObj61, UtilityTestData.mLocation);
        
        Sobject sObj62 = new pse__Project_Location__c();
        UtilityTestData.mLocation.put('Name','Test Location');
        UtilityTestData.mLocation.put('pse__Project__c',lProject[0].Id);
        //UtilityTestData.mLocation.put('psa_pm_Primary__c','true');
        UtilityTestData.mLocation.put('psa_PM_Work_City__c','Test City');
        UtilityTestData.mLocation.put('PSA_PM_Work_Country_code__c','12345');
        UtilityTestData.mLocation.put('PSA_PM_Work_State__c','Test State');
        UtilityTestData.mLocation.put('psa_pm_MSA_Code_Mapping__c',ppmc.Id);
        sObj62 = UtilityTest.putFieldRecord(sObj62, UtilityTestData.mLocation);
        

        Sobject sObj6 = new pse__Project_Location__c();
        UtilityTestData.mLocation.put('Name','Test Location');
        UtilityTestData.mLocation.put('pse__Project__c',lProject[0].Id);
        UtilityTestData.mLocation.put('psa_pm_Primary__c','true');
        UtilityTestData.mLocation.put('psa_PM_Work_City__c','Test City');
        UtilityTestData.mLocation.put('PSA_PM_Work_Country_code__c','12345');
        UtilityTestData.mLocation.put('PSA_PM_Work_State__c','Test State');
        UtilityTestData.mLocation.put('psa_pm_MSA_Code_Mapping__c',ppmc.Id);
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mLocation);
        List<pse__Project_Location__c> lProjectlocation = (List<pse__Project_Location__c>) UtilityTest.makeInsert(new List<sObject>{sObj6,sObj61,sObj62});

    }
    public static testMethod void ProjectLocationTriggerTest2() {
        //User runUser =  [select Id, Name from User where UserRole.DeveloperName LIKE 'PS_Senior_Consultant' LIMIT 1];
        //System.runAs(runUser){
            Test.startTest();
            try
                
            {
                List<pse__Project_Location__c> lProjectlocation = [SELECT Id,Name FROM pse__Project_Location__c WHERE psa_pm_Primary__c = true];
                System.assert(lProjectlocation.size()>0, lProjectlocation);
                lProjectlocation[0].psa_pm_Primary__c = false;
                update lProjectlocation[0];
                
            }
            catch(Exception e)
                
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('There are no Primary Work Location(s). Please make sure there is exactly one Primary Work Location on a project.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
    
    
            
            Test.stopTest();
        //}
    }
    public static testMethod void ProjectLocationTriggerTest1() {
        Test.startTest();
        List<pse__Project_Location__c> lProjectlocation = [SELECT Id,Name FROM pse__Project_Location__c WHERE psa_pm_Primary__c = true];
        System.assert(lProjectlocation.size()>0, lProjectlocation);
        lProjectlocation[0].psa_pm_Primary__c = true;
        update lProjectlocation[0];
        
               
        List<pse__Project_Location__c> lProjectlocationUpdate = [SELECT Id,Name FROM pse__Project_Location__c WHERE psa_pm_Primary__c = false];
        delete lProjectlocationUpdate;
        Test.stopTest();
    }
    
}