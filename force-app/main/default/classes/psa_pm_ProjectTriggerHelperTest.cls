/*
@created by       : Pavithra V
@created on       : 12/04/2020
@Purpose          : Test class for psa_pm_ProjectTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest
public class psa_pm_ProjectTriggerHelperTest {
    private static List<Schema.SObjectType> MY_SOBJECTS = 
            new Schema.SObjectType[]{
                Bypass_Trigger_Settings__c.SObjectType,
                PermissionSetAssignment.SObjectType,
                pse__Region__c.SObjectType,
                User.SObjectType,
                Account.SObjectType,
                pse__Work_Calendar__c.SObjectType,
                Contact.SObjectType,
                Product2.SObjectType,
                Opportunity.SObjectType,
                blng__LegalEntity__c.SObjectType,
                SBQQ__Quote__c.SObjectType,
                pse__Permission_Control__c.SObjectType,
                PSA_MSA_Code_Mapping__c.SObjectType,
                pse__Proj__c.SObjectType,	
                pse__Resource_Request__c.SObjectType,
                pse__Time_Period__c.SObjectType,
                pse__Schedule__c.SObjectType
            };

    static void assignPermissionSet(){
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Project_Name_Edit' LIMIT 1];
        PermissionSetAssignment PSAgmnt1 = new PermissionSetAssignment(AssigneeId =  UserInfo.getUserId(),
                                                                       PermissionSetId = ps.Id);
        uow.registerNew(PSAgmnt1);

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Operations' LIMIT 1];
        PermissionSetAssignment PSAgmnt2 = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(),
                                                                       PermissionSetId = permSet.Id);
        uow.registerNew(PSAgmnt2);
    }
    
    @testSetup
    static void setupObjectTestData() {
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);

        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.psa_ProjectTrigger__c = true;
        uow.registerNew(trigSetting);

        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        System.debug('AccRecType'+ AccRecType.Id);
        
        pse__Region__c reg1 = new pse__Region__c(Name='Test Region-1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg1);
        
        pse__Region__c reg2 = new pse__Region__c(Name='Test Region-2',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-2->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg2);

        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
            List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];

            Profile pr = [select ID,Name from Profile where name='System Administrator'];
            
            User user1 = new User(CommunityNickname='communityuser',
                                  ProfileId=pr.Id,
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
                                  ProfileId=pr.Id,
                                  LastName='Testing2',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8',
                                  Alias='usrTemp2',
                                  Email='usr_temp2@testorg.com',
                                  Username='usr_temp2@testorg.com');
            uow.registerNew(user2);

            Account acc = new Account();
            acc.Name='IL-PROJ INT TEST Account';
            acc.Geo__c='NA';
            acc.Signature_Success__c = true;
            uow.registerNew(acc);
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            uow.registerNew(defaultWorkCalendar);
            
            User projManager = [SELECT Id,UserRole.DeveloperName FROM User WHERE UserRole.DeveloperName = 'PS_Delivery_Manager' LIMIT 1];
            
            Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00,
                                       pse__Salesforce_User__c=userInfo.getUserId(),
                                       RecordTypeId=rt.Id);
            uow.registerRelationship(con1, Contact.AccountId,acc);
            uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
            uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);

            Contact con2 = new Contact(LastName = 'Test Contact2',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=11.00,
                                       pse__Salesforce_User__c=projManager.Id,
                                       RecordTypeId=rt.Id);
            uow.registerRelationship(con2, Contact.AccountId,acc);
            uow.registerRelationship(con2, Contact.pse__Region__c, reg1);
            uow.registerNew(con2, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
           
            Product2 prod = new Product2(Name = 'Test',Offering_Type__c='Professional Services');
            uow.registerNew(prod);
            
            Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               StageName='Validate',
                                               Name = 'Test opportunity2',
                                               psa_om_Start_Date__c=System.today(),
                                               CloseDate = System.today().addDays(2),
                                               psa_om_End_Date__c=System.today()+10,
                                               psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                               PSA_OM_Project_Type__c='JumpStart'
                                               );                                 
            uow.registerNew(opty, Opportunity.AccountId, acc);

            Opportunity opty2 = new Opportunity(Name = 'Test opportunity2',
                                                Type='Direct',
                                                CurrencyIsoCode='USD',
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
            uow.registerNew(opty2, Opportunity.AccountId, acc);
            
            blng__LegalEntity__c legalEntityRec = new blng__LegalEntity__c( Name='test',
                                                                            Business_Unit_Code__c='CH001', 
                                                                            Legal_Entity_Code__c='test123');
            uow.registerNew(legalEntityRec);
            
            SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__Primary__c=true);
            uow.registerRelationship(quoteRec, SBQQ__Quote__c.Legal_Entity__c,legalEntityRec);
            uow.registerNew(quoteRec, SBQQ__Quote__c.SBQQ__Opportunity2__c, opty);

            pse__Permission_Control__c pc = new pse__Permission_Control__c( pse__User__c = userObj.Id, 
                                                                            pse__Expense_Ops_Edit__c = true, 
                                                                            pse__Timecard_Ops_Edit__c = true,
                                                                            pse__Cascading_Permission__c = true, 
                                                                            pse__Resource_Request_Entry__c = true, 
                                                                            pse__Staffing__c = true);
            uow.registerNew(pc, pse__Permission_Control__c.pse__Region__c, reg1);
            
            PSA_MSA_Code_Mapping__c msaCodeMapping = new PSA_MSA_Code_Mapping__c(Name='Test Name');
            uow.registerNew(msaCodeMapping);

            pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Start_Date__c=System.today().addDays(1),
                                                     pse__End_Date__c=System.today().addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
            uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);

            pse__Proj__c childProjRec = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Start_Date__c=System.today().addDays(1),
                                                     pse__End_Date__c=System.today().addDays(15),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true,
                                                     psa_pm_Source__c='Interlock',
                                                     PSA_OM_ERP_Billing_Site_ID__c='Interlock');
            uow.registerRelationship(childProjRec, pse__Proj__c.pse__Parent_Project__c,projRec1);                                         
            uow.registerRelationship(childProjRec, pse__Proj__c.pse__Account__c, acc);
            uow.registerRelationship(childProjRec, pse__Proj__c.pse__Project_Manager__c,con1);
            uow.registerRelationship(childProjRec, pse__Proj__c.pse__Opportunity__c,opty2);
            uow.registerNew(childProjRec,pse__Proj__c.pse__Region__c ,reg1);

            pse__Resource_Request__c rrRec = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(10),
                                                                          pse__SOW_Hours__c=8.00,
                                                                          pse__Resource_Role__c='Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Resource__c,con1);    
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Project__c,projRec1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Opportunity__c,opty);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping);
            uow.registerNew(rrRec, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty); 
            
            pse__Resource_Request__c rrRec2 = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(15),
                                                                          pse__SOW_Hours__c=6.00,
                                                                          pse__Resource_Role__c='Offshore Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Resource__c,con2);    
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Project__c,childProjRec);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.pse__Opportunity__c,opty2);
            uow.registerRelationship(rrRec2, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping);
            uow.registerNew(rrRec2, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty2);
            
        

            pse__Schedule__c schRec = new pse__Schedule__c(pse__Start_Date__c=System.today().addDays(1),
                                                           pse__End_Date__c=System.today().addDays(10),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
            uow.registerNew(schRec);      
            Test.startTest();
            uow.commitWork();                                         
            Test.stopTest();
        }
    }
    public static testMethod void parentProjectTriggerTest(){
        
        Test.startTest();
        
        List<Account> lAccount = [SELECT Id from Account];
        System.assert(lAccount.size()>0, 'lAccount not created');
        
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name,pse__Parent_Project__c FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        System.debug('@@lProject '+ lProject[0].pse__Parent_Project__c);
        System.debug('@@lProject '+ lProject[1].pse__Parent_Project__c);
        
        List<Contact> lContact = [SELECT Id,Name,pse__Salesforce_User__r.Id,AccountId FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        System.debug('@@lContact '+ lContact);
        
        List<pse__Region__c> lRegion = [SELECT Id from pse__Region__c];
        System.assert(lRegion.size()>0, 'Region not created');
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        System.runAs(userObj){
            
            sObject sObj1 = new pse__Proj__c();
            UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
            UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
            UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
            UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[1].Id);
            UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
            UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
            UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');// 
            UtilityTestData.mProjectData.put('pse__Parent_Project__c',lProject[0].Id);
            UtilityTestData.mProjectData.put('psa_pm_Source__c','Interlock'); 
            UtilityTestData.mProjectData.put('PSA_OM_ERP_Billing_Site_ID__c','Interlock'); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProjectData);
            List<pse__Proj__c> lProject1 = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            
        }
        Test.stopTest();
        
    }
    
    public static testMethod void projectTriggerTest(){
        
        Test.startTest();
        
        List<Account> lAccount = [SELECT Id from Account];
        System.assert(lAccount.size()>0, 'lAccount not created');
        
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name,pse__Parent_Project__c FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        System.debug('@@lProject '+ lProject[0].pse__Parent_Project__c);
        System.debug('@@lProject '+ lProject[1].pse__Parent_Project__c);
        
        List<Contact> lContact = [SELECT Id,Name,pse__Salesforce_User__r.Id,AccountId FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        System.debug('@@lContact '+ lContact);
        
        List<pse__Region__c> lRegion = [SELECT Id from pse__Region__c];
        System.assert(lRegion.size()>0, 'Region not created');
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        System.runAs(userObj){
            try{
                lProject[0].pse__Opportunity__c = lOpportunity[1].Id;
                lProject[0].psa_om_Interlock__c = null;
                Update lProject[0];
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('A project is already associated with this Opportunity') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            try{
                lProject[0].psa_pm_Journey__c ='C360 Engagement';
                lProject[0].psa_pm_Portfolio_Manager__c = lContact[0].Id;
                lProject[0].pse__Project_Manager__c = lContact[0].Id; 
                Update lProject[0];
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Journey can not be changed by current user') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            try{
                lProject[0].psa_pm_Project_Category__c= 'Productive Non - Billable';
                lProject[0].psa_pm_Portfolio_Manager__c = lContact[0].Id;
                lProject[0].pse__Project_Manager__c = lContact[0].Id; //
                Update lProject[0];
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Project Category cannot be changed by current user') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            
            Test.stopTest();
        }
        
    }
    
    public static testMethod void projectTriggerJourneyUpdateTest(){
        
        Test.startTest();
        
        List<Account> lAccount = [SELECT Id from Account];
        System.assert(lAccount.size()>0, 'lAccount not created');
        
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<Contact> lContact = [SELECT Id,Name,pse__Salesforce_User__r.Id,AccountId FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        System.debug('@@lContact '+ lContact);
        
        List<pse__Region__c> lRegion = [SELECT Id from pse__Region__c];
        System.assert(lRegion.size()>0, 'Region not created');
        
        //List<User> lUser = [select Id, Name from User LIMIT ];
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Operations'];
        
        System.runAs(userObj){
            
            
            try{
                lProject[0].psa_pm_Journey__c ='C360 Engagement';
                lProject[0].psa_pm_Portfolio_Manager__c = lContact[0].Id;
                lProject[0].pse__Project_Manager__c = lContact[0].Id;
                lProject[0].pse__Opportunity_Owner__c = null;
                Update lProject[0];
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Journey can not be changed by current user') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            Test.stopTest();
        }
        
    }
    
    public static testMethod void projectTriggerCategoryUpdateTest(){
        
        Test.startTest();
        
        List<Account> lAccount = [SELECT Id from Account];
        System.assert(lAccount.size()>0, 'lAccount not created');
        
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<Contact> lContact = [SELECT Id,Name,pse__Salesforce_User__r.Id,AccountId FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        System.debug('@@lContact '+ lContact);
        
        List<pse__Region__c> lRegion = [SELECT Id from pse__Region__c];
        System.assert(lRegion.size()>0, 'Region not created');
        
        List<User> lUser = [select Id, Name from User LIMIT 10];
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'PSA_Operations'];
        
        System.runAs(userObj){
            
            try{
                lProject[0].psa_pm_Project_Category__c= 'Productive Non - Billable';
                lProject[0].psa_pm_Portfolio_Manager__c = lContact[0].Id;
                lProject[0].pse__Project_Manager__c = lContact[0].Id; 
                lProject[0].pse__Opportunity_Owner__c = lUser[2].Id;
                Update lProject[0];
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Project Category cannot be changed by current user') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            
            Test.stopTest();
        }
        
    }
    
    
    public static testMethod void projectTriggerNameUpdateTest(){
        
        Test.startTest();
        
        List<Account> lAccount = [SELECT Id from Account];
        System.assert(lAccount.size()>0, 'lAccount not created');
        
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        System.assert(lOpportunity.size()>0, 'Opportunity not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<Contact> lContact = [SELECT Id,Name,pse__Salesforce_User__r.Id,AccountId FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        System.debug('@@lContact '+ lContact);
        
        List<pse__Region__c> lRegion = [SELECT Id from pse__Region__c];
        System.assert(lRegion.size()>0, 'Region not created');
        
        
        try{
            lProject[0].psa_pm_Portfolio_Manager__c = lContact[0].Id;
            lProject[0].pse__Project_Manager__c = lContact[0].Id;
            lProject[0].Name ='Test Name Project 2';
            Update lProject[0];
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You can not edit Project Name') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void createProjShareRecsTest(){
        pse__Proj__c projRec = [SELECT Id FROM pse__Proj__c LIMIT 1];
        User uRec = [SELECT ID FROM USER WHERE Id !=:UserInfo.getUserId()  AND Isactive = true LIMIT 1];
        Contact conRec = [SELECT Id FROM Contact LIMIT 1];
        projRec.ownerId = uRec.Id;
        projRec.psa_pm_Portfolio_Manager__c = conRec.Id;
        update projRec;
    }
}