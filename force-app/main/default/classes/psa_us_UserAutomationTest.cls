/*
@created by       : Vivek Warrier
@created on       : 08-Apr-2021
@Purpose          : Test class for psa_us_UserAutomation

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_us_UserAutomationTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = accRecType;
        acc.Name = 'Informatica LLC PSA';
        acc.CSM_Segment__c='Digital Touch';
        acc.Contract_Company_Group__c='Prospect';
        acc.Payment_Terms__c='Net 30';
        acc.BillingCountry='India';
        acc.Peoplesoft_External_ID__c='1234';
        insert acc;
        
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
        
        // Create Region
        pse__Region__c regionRec = new pse__Region__c();
        regionRec.Name = 'Test Region';
        regionRec.pse__Action_Update_Current_Time_Period__c = false;
        regionRec.psa_pm_Allow_Customer_Project__c = true;
        insert regionRec;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName ='Contact' ;
        con.FirstName = 'Test';
        con.Email='testuser@example.com';
        con.pse__Is_Resource__c =true;
        con.pse__Is_Resource_Active__c=true;
        con.CurrencyIsoCode='USD';
        con.pse__Resource_Role__c='Regional Manager';
        con.pse__Region__c = regionRec.Id;
        con.pse__Default_Cost_Rate__c = 10;
        con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        con.psa_Target_Bill_Rate__c=10;
        con.Peoplesoft_External_ID__c='1234';
        con.psa_Employee_Type__c = 'Informatica-PS';
        con.MailingCountry='India';
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName ='Contact' ;
        con1.FirstName = 'Test2';
        con1.Email='testuser@1example.com';
        con1.pse__Is_Resource__c =true;
        con1.pse__Is_Resource_Active__c=true;
        con1.CurrencyIsoCode='USD';
        con1.pse__Resource_Role__c='PS Operations';
        con1.pse__Region__c = regionRec.Id;
        con1.pse__Default_Cost_Rate__c = 90;
        con1.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        con1.psa_Target_Bill_Rate__c=10;
        con1.Peoplesoft_External_ID__c='1234567';
        con1.psa_Employee_Type__c = 'Informatica-PS';
        con1.MailingCountry='India';
        conList.add(con1);

        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.LastName ='Contact' ;
        con2.FirstName = 'Test3';
        con2.Email='testuser@2example.com';
        con2.pse__Is_Resource__c =true;
        con2.pse__Is_Resource_Active__c=true;
        con2.CurrencyIsoCode='USD';
        con2.pse__Resource_Role__c='PS Operations';
        con2.pse__Region__c = regionRec.Id;
        con2.pse__Default_Cost_Rate__c = 100;
        con2.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        con2.psa_Target_Bill_Rate__c=10;
        con2.Peoplesoft_External_ID__c='1234568';
        con2.psa_Employee_Type__c = 'Informatica-PS';
        con2.MailingCountry='India';
        conList.add(con2);
        
        insert conList;
    }
    
    public static testMethod void userAutomationtest1(){
    
        Test.startTest();
        Id usrRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.Name LIKE 'PS %' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1][0].Id; 
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        System.debug('usrRoleId: ' + usrRoleId);
        
        User usr1 = new User();
        usr1.UserRoleId = usrRoleId;
        usr1.Username = 'TestSetup@example.com.test';
      	usr1.LastName = 'User';
        usr1.Email = 'testuser@example.com';
        usr1.Alias = 'tuser';
        usr1.TimeZoneSidKey = 'America/New_York';
        usr1.LocaleSidKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.ProfileId = prof.Id;
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Department = 'IPS - Project Management';
        try{
            insert usr1;
        }
        catch(Exception e){
            System.debug('User Insert failed. Error: '+ e.getMessage());
        }
        Test.stopTest();
    }
    
    public static testMethod void userAutomationtest2_Update(){
    
        Id usrRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.Name LIKE 'PS %' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1][0].Id;
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        System.debug('usrRoleId: ' + usrRoleId);
        
        List<User> usrList = new List<User>();
        User usr1 = new User();
        usr1.UserRoleId = usrRoleId;
        usr1.Username = 'TestSetup@example.com.test';
      	usr1.LastName = 'User';
        usr1.Email = 'testuser@1example.com';
        usr1.Alias = 'tuser';
        usr1.TimeZoneSidKey = 'America/New_York';
        usr1.LocaleSidKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.ProfileId = prof.Id;
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Department = 'IPS - Project Management';
        usrList.add(usr1);
        
        User usr2 = new User();
        usr2.UserRoleId = usrRoleId;
        usr2.IsActive = false;
        usr2.Username = 'TestSetup@example.com.test1';
      	usr2.LastName = 'User';
        usr2.Email = 'testuser@2example.com';
        usr2.Alias = 'tuser';
        usr2.TimeZoneSidKey = 'America/New_York';
        usr2.LocaleSidKey = 'en_US';
        usr2.EmailEncodingKey = 'UTF-8';
        usr2.ProfileId = prof.Id;
        usr2.LanguageLocaleKey = 'en_US';
        usr2.Department = 'IPS - Project Management';
        usrList.add(usr2);

        try{
            insert usrList;
        }
        catch(Exception e){
            System.debug('User Insert failed. Error: '+ e.getMessage());
        }
        
        Test.startTest();
        //Adding the below code to improve the code coverage - June Build 2022 - <T1>
        psa_us_UserAutomation.skipCondition = true;
        //</T1>
        Id usrRoleIdSC = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.DeveloperName = 'PS_Senior_Consultant' LIMIT 1][0].Id;
        usr1.UserRoleId = usrRoleIdSC;
        update usr1;
         
        //List<User> lstUsersToProcess = new List<User>();
        Map<Id,User> mapUsersToProcess = new Map<Id,User>();
        mapUsersToProcess.put(usr1.Id,usr1);
        string sNewItems = Json.serialize(mapUsersToProcess);
        string sOldList = null;
        
        psa_us_UserAutomation.contactInsertUpdate(sNewItems,sOldList);
        Test.stopTest();
    }
    
    public static testMethod void userAutomationtest3_Update(){
    
        Id usrRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.Name LIKE 'PS %' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1][0].Id;
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        System.debug('usrRoleId: ' + usrRoleId);
        
        List<User> usrList = new List<User>();
        User usr1 = new User();
        usr1.UserRoleId = usrRoleId;
        usr1.Username = 'TestSetup@example.com.test';
      	usr1.LastName = 'User';
        usr1.Email = 'testuser@example.com';
        usr1.Alias = 'tuser';
        usr1.TimeZoneSidKey = 'America/New_York';
        usr1.LocaleSidKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.ProfileId = prof.Id;
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Department = 'IPS - Project Management';
        usrList.add(usr1);
        
        User usr2 = new User();
        usr2.UserRoleId = usrRoleId;
        usr2.IsActive = false;
        usr2.Username = 'TestSetup@example.com.test1';
      	usr2.LastName = 'User';
        usr2.Email = 'testuser@1example.com';
        usr2.Alias = 'tuser';
        usr2.TimeZoneSidKey = 'America/New_York';
        usr2.LocaleSidKey = 'en_US';
        usr2.EmailEncodingKey = 'UTF-8';
        usr2.ProfileId = prof.Id;
        usr2.LanguageLocaleKey = 'en_US';
        usr2.Department = 'IPS - Project Management';
        usrList.add(usr2);
        
        User usr3 = new User();
        usr3.UserRoleId = usrRoleId;
        usr3.Username = 'TestSetup@example.com.test2';
      	usr3.LastName = 'User';
        usr3.Email = 'testuser@2example.com';
        usr3.Alias = 'tuser';
        usr3.TimeZoneSidKey = 'America/New_York';
        usr3.LocaleSidKey = 'en_US';
        usr3.EmailEncodingKey = 'UTF-8';
        usr3.ProfileId = prof.Id;
        usr3.LanguageLocaleKey = 'en_US';
        usr3.Department = 'IPS - Project Management';
        usrList.add(usr3);
        
        try{
            insert usrList;
        }
        catch(Exception e){
            System.debug('User Insert failed. Error: '+ e.getMessage());
        }
        
        Test.startTest();
        
        Id usrRoleIdSC = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.DeveloperName = 'PS_Administrator' LIMIT 1][0].Id;
        
        string sOldList = null;
        Map<Id,User> mapOldUsers = new Map<Id,User>();
        mapOldUsers.put(usr1.Id, usr1);
        mapOldUsers.put(usr2.Id, usr2);
        mapOldUsers.put(usr3.Id, usr3);
        sOldList = Json.serialize(mapOldUsers);
        
        List<User> lstUsersToProcess = new List<User>();
        usr1.UserRoleId = usrRoleIdSC;
        lstUsersToProcess.add(usr1);
        usr2.isActive = true;
        lstUsersToProcess.add(usr2);
        usr3.Department = null;
        lstUsersToProcess.add(usr3);
        update lstUsersToProcess;
                
        /* lstUsersToProcess.add(usr1);
        string sNewItems = Json.serialize(lstUsersToProcess);
                    
        psa_us_UserAutomation.contactInsertUpdate(sNewItems,sOldList); */
        
        Test.stopTest();
    }

    public static testMethod void userAutomationtest2_UpdateDept(){
    
        Id usrRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.Name LIKE 'PS %' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1][0].Id;
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        System.debug('usrRoleId: ' + usrRoleId);
        
        User usr1 = new User();
        usr1.UserRoleId = usrRoleId;
        usr1.Username = 'TestSetup@example.com.test';
      	usr1.LastName = 'User';
        usr1.Email = 'testuser@example.com';
        usr1.Alias = 'tuser';
        usr1.TimeZoneSidKey = 'America/New_York';
        usr1.LocaleSidKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.ProfileId = prof.Id;
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Department = 'IPS - Project Management';
        
        try{
            insert usr1;
        }
        catch(Exception e){
            System.debug('User Insert failed. Error: '+ e.getMessage());
        }
        
        Test.startTest();
        
        Id usrRoleIdSC = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.DeveloperName = 'PS_Senior_Consultant' LIMIT 1][0].Id;
        usr1.Department = 'Sales - PreSales';
        update usr1;
        
        //List<User> lstUsersToProcess = new List<User>();
        Map<Id,User> mapUsersToProcess = new Map<Id,User>();
        mapUsersToProcess.put(usr1.Id,usr1);
        string sNewItems = Json.serialize(mapUsersToProcess);
        string sOldList = null;
        
        psa_us_UserAutomation.skipCondition = true;    
        psa_us_UserAutomation.contactInsertUpdate(sNewItems,sOldList);
        
        Test.stopTest();
    }
    
    public static testMethod void userAutomationtest2_UpdateFields(){
    
        Id usrRoleId = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.Name LIKE 'PS %' AND UserRole.DeveloperName != 'PSA_Resource_Management' LIMIT 1][0].Id;
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        System.debug('usrRoleId: ' + usrRoleId);
        
        User usr1 = new User();
        usr1.UserRoleId = usrRoleId;
        usr1.Username = 'TestSetup@example.com.test';
      	usr1.LastName = 'User';
        usr1.Email = 'testuser@example.com';
        usr1.Alias = 'tuser';
        usr1.TimeZoneSidKey = 'America/New_York';
        usr1.LocaleSidKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.ProfileId = prof.Id;
        usr1.LanguageLocaleKey = 'en_US';
        usr1.Department = 'IPS - Project Management';
        try{
            insert usr1;
        }
        catch(Exception e){
            System.debug('User Insert failed. Error: '+ e.getMessage());
        }
        
        Test.startTest();
        
        Id usrRoleIdSC = [SELECT Id,DeveloperName FROM UserRole WHERE UserRole.DeveloperName = 'PS_Senior_Consultant' LIMIT 1][0].Id;
        usr1.LastName = 'Test Last Name';
        update usr1;
        
        //List<User> lstUsersToProcess = new List<User>();
        Map<Id,User> mapUsersToProcess = new Map<Id,User>();
        mapUsersToProcess.put(usr1.Id,usr1);
        string sNewItems = Json.serialize(mapUsersToProcess);
        string sOldList = null;
            
        psa_us_UserAutomation.contactInsertUpdate(sNewItems,sOldList);
        
        Test.stopTest();
    }
}