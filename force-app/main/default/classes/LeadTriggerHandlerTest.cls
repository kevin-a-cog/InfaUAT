/*
Class:          LeadTriggerHandlerTest
@Author:        Deloitte
@Created Date:  03/13/2018
@Description:   test class for LeadTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By            Description                     Tag

Puneet Lohia     04-Jun-2021    Hardik Poojary    To test PopulateOwner method          <T01>
******************************************************************
*/

@isTest(SeeAllData=false)
private Class LeadTriggerHandlerTest{
    
    
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    //static Id userRole = [SELECT id FROM userrole where developername = 'ASEAN_Manager'].id;
    static Id PartnerProgramRecTypeCSIId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    static Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'][0];
    
    @testSetup
    static void setupObjectTestData() 
    {
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        
        List<Contact> contactList;
        
        Profile employee_profile = [SELECT Id FROM Profile where name = 'Employee' limit 1]; 
        system.runas(adminUser)
        {
            /*------------------------------------------------Test Channel Program Creation Start---------------------------------------------------------*/
            //create ChannelProgram 
            sObject channelProgramObj = new ChannelProgram();
            channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
            
            List<ChannelProgram> channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj});
            
            /*------------------------------------------------Test Channel Program Creation End---------------------------------------------------------*/
            
            
            /*------------------------------------------------Test Channel Program Level Creation Start---------------------------------------------------------*/
            //create ChannelProgramLevel
            Id ChannelProgramLevelRecTypeAIRId = [SELECT id FROM RecordType where SObjectType='ChannelProgramLevel' and DeveloperName='AIR'].id;
            Id ChannelProgramLevelRecTypeCSIId = [SELECT id FROM RecordType where SObjectType='ChannelProgramLevel' and DeveloperName='CSI'].id;
            
            UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeAIRId);
            UtilityTestData.mChannelProgramLevelData.put('Name','AIR');
            UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');     
            sObject channelProgramLevelObj = new ChannelProgramLevel();
            channelProgramLevelObj = UtilityTest.putFieldRecord(channelProgramLevelObj, UtilityTestData.mChannelProgramLevelData);
            
            UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeCSIId);
            UtilityTestData.mChannelProgramLevelData.put('Name','CSI');
            UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');     
            sObject channelProgramLevelObj1 = new ChannelProgramLevel();
            channelProgramLevelObj1 = UtilityTest.putFieldRecord(channelProgramLevelObj1, UtilityTestData.mChannelProgramLevelData);
            
            List<ChannelProgramLevel> channelProgLevelList = (List<ChannelProgramLevel>) UtilityTest.makeInsert(new List<sObject>{channelProgramLevelObj,channelProgramLevelObj1});
            
            /*------------------------------------------------Test Channel Program Level Creation End---------------------------------------------------------*/
            
            
            /*------------------------------------------------Test Partner Program Creation Start---------------------------------------------------------*/
            //create partner program
            UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
            UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
            UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
            UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
            UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
            UtilityTestData.mPartnerProgramData.put('Program_Type__c','1 Tier AIR');
            UtilityTestData.mPartnerProgramData.put('Program_Level__c','N/A');
            
            //Create partnerProgObj for accList[1].id
            sObject partnerProgObj = new Partner_Program__c();
            partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
            
            //Create partnerProgObj1 for accList[2].id
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[2].id + '');
            sObject partnerProgObj1 = new Partner_Program__c();
            partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
            
            //Create partnerProgObj2 for accList[3].id
            UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeCSIId);
            UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
            UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
            UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
            UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[1].id+'');
            UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
            UtilityTestData.mPartnerProgramData.put('Program_Level__c','Foundation');
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[3].id + '');
            sObject partnerProgObj2 = new Partner_Program__c();
            partnerProgObj2 = UtilityTest.putFieldRecord(partnerProgObj2, UtilityTestData.mPartnerProgramData);
            
            List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj,partnerProgObj1,partnerProgObj2});
            
            /*------------------------------------------------Test Partner Program Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test Partner Distributor Creation Start---------------------------------------------------------*/
            //create partner distributor
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','United States');
            sObject partnerdisti = new Partner_Distributor__c();
            partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);
            
            //create partner distributor for software reseller and SI
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[3].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','United States');
            sObject partnerdisti1 = new Partner_Distributor__c();
            partnerdisti1 = UtilityTest.putFieldRecord(partnerdisti1, UtilityTestData.mPartnerDistributorData);
            
            //create partner distributor2
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','Australia');
            sObject partnerdisti2 = new Partner_Distributor__c();
            partnerdisti2 = UtilityTest.putFieldRecord(partnerdisti2, UtilityTestData.mPartnerDistributorData);
            
            
            List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti,partnerdisti1,partnerdisti2});
            
            /*------------------------------------------------Test Partner Distributor Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test Partner Contact Creation Start---------------------------------------------------------*/
            //create partner contact of type Reseller
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            sObject contactSobj1 = new Contact();
            contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
            
            //create partner contact of type Disti
            UtilityTestData.mContactData.put('AccountId',accList[2].id + '');
            sObject contactSobj2 = new Contact();
            contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
            //create partner contact of type Software Reseller and SI
            UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
            sObject contactSobj3 = new Contact();
            contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
            
            //create another partner contact of type Reseller
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            
            sObject contactSobj4 = new Contact();
            contactSobj4 = UtilityTest.putFieldRecord(contactSobj4, UtilityTestData.mContactData);
            system.runAs(adminUser)
            {
                contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobj2,contactSobj3,contactSobj4});
            }
            
            /*------------------------------------------------Test Partner Contact Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test Partner User Creation Start---------------------------------------------------------*/
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner'])
            {
                userRoleMap.put(role.PortalAccountId, role.Id);
            }
            
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm1@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest');
            UtilityTestData.mUserData.put('CommunityNickname','mtest');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[0].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            sObject userSobj = new User();
            userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
            
            //create partner user(disti)
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest2Distii@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm2@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest');
            UtilityTestData.mUserData.put('CommunityNickname','mtest2');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[1].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
            sObject userSobj2 = new User();
            userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);
            
            //create partner user(software reseller and SI)
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest3@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest3');
            UtilityTestData.mUserData.put('CommunityNickname','mtest3');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest3');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            sObject userSobj3 = new User();
            userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);
            
            //create another partner user(reseller)
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest4@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm4@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest4');
            UtilityTestData.mUserData.put('CommunityNickname','mtest4');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[3].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest4');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            sObject userSobj4 = new User();
            userSobj4 = UtilityTest.putFieldRecord(userSobj4, UtilityTestData.mUserData);
            
            
            UtilityTestData.mUserData.put('ProfileId',employee_profile.id);
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c', '');
            UtilityTestData.mUserData.put('EmployeeNumber', '12345');
            UtilityTestData.mUserData.put('Username','employee@m.t');
            UtilityTestData.mUserData.put('Email','testemailforemployee4@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest5');
            UtilityTestData.mUserData.put('CommunityNickname','mtest5');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('LastName','mtest5');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('ContactId',null); 
            sObject userSobj5 = new User();
            userSobj5 = UtilityTest.putFieldRecord(userSobj5, UtilityTestData.mUserData);
            
            
            List<User> prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj,userSobj2,userSobj3,userSobj4,userSobj5});
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
             settings.SetupOwnerId = prtnrUserList[0].Id;
             upsert settings User_Exemptions__c.Id;
            
            User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
            settings1.Ignore_Validation_Rules__c = true;
             settings1.SetupOwnerId = prtnrUserList[1].Id;
             upsert settings1 User_Exemptions__c.Id;
            
            User_Exemptions__c settings2 = User_Exemptions__c.getOrgDefaults();
            settings2.Ignore_Validation_Rules__c = true;
             settings2.SetupOwnerId = prtnrUserList[2].Id;
             upsert settings2 User_Exemptions__c.Id;            
            /*------------------------------------------------Test Partner User Creation End---------------------------------------------------------*/        
            /*------------------------------------------------Test AccountTeamMember Creation Start---------------------------------------------------------*/
            //Add PSM to Account Team member1
            UtilityTestData.mAccountTeamMember.put('AccountId',accList[1].id + '');
            UtilityTestData.mAccountTeamMember.put('UserId',psmUser.id + '');
            UtilityTestData.mAccountTeamMember.put('TeamMemberRole','PSM');
            
            sObject AccTeamMember1 = new AccountTeamMember();
            AccTeamMember1 = UtilityTest.putFieldRecord(AccTeamMember1, UtilityTestData.mAccountTeamMember);
            
            List<AccountTeamMember> accTeamMemList = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{AccTeamMember1});
            /*------------------------------------------------Test AccountTeamMember Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test assign permission set Start---------------------------------------------------------*/
            system.runAs(adminUser)
            {
                PermissionSet ps01 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps01.Id );
                
                PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = ps1.Id );
                
                PermissionSet ps2 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[2].id, PermissionSetId = ps2.Id );
            }
            /*------------------------------------------------Test assign permission set End---------------------------------------------------------*/
            
            
            /*------------------------------------------------Test Lead creation Start---------------------------------------------------------*/
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert111');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id+'');
            UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
            UtilityTestData.mLeadData.put('Country','United States');
            UtilityTestData.mLeadData.put('FirstName','test resell');
            UtilityTestData.mLeadData.put('PartnerAccount',accList[2].id+'');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('FirstName','test3 referral');
            UtilityTestData.mLeadData.put('LastName ','test3');
            UtilityTestData.mLeadData.put('Email','test3@testr3.q');
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert1113');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');            
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[3].id+'');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','No');
            //create lead3
            sObject lead3 = new Lead();
            lead3 = UtilityTest.putFieldRecord(lead3, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert111_1');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id+'');
            UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
            UtilityTestData.mLeadData.put('Country','Antartica');
            UtilityTestData.mLeadData.put('FirstName','test resell');
            UtilityTestData.mLeadData.put('PartnerAccount',accList[2].id+'');
            
            //create lead
            sObject lead4 = new Lead();
            lead4 = UtilityTest.putFieldRecord(lead4, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert112');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test ');
            UtilityTestData.mLeadData.put('Email','LeadConvert112@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id+'');
            UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
            UtilityTestData.mLeadData.put('Country','United States');
            UtilityTestData.mLeadData.put('FirstName','LeadConvert112');
            //UtilityTestData.mLeadData.put('PartnerAccount',accList[2].id+'');
            
            //create lead
            sObject lead5 = new Lead();
            lead5 = UtilityTest.putFieldRecord(lead5, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert116');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test ');
            UtilityTestData.mLeadData.put('Email','LeadConvert116@testr.q');
            UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
            UtilityTestData.mLeadData.put('Country','United States');
            UtilityTestData.mLeadData.put('FirstName','LeadConvert112');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',null);
            //create lead
            sObject lead6 = new Lead();
            lead6 = UtilityTest.putFieldRecord(lead6, UtilityTestData.mLeadData);
            
            
            List<lead> resellleadList = new list<lead>();
            List<lead> distileadList = new list<lead>();
            List<lead> referralleadList = new list<lead>();
            system.runAs(prtnrUserList[0])
            {
                resellleadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead4,lead5});
            }
            List<User> usel1 = [Select Id,Username,ContactId from User where Id =:prtnrUserList[1].ID];
            
            List<Contact> conL = [Select Id,AccountId from Contact Where Id=:usel1[0].ContactId];
            
            system.runAs(prtnrUserList[1])
            {
                distileadList= (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead6});
            }
            system.runAs(prtnrUserList[2])
            {
                referralleadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead3});
            }
            Lead toUpdatelead = resellleadList[2];
            toUpdatelead.status='Approved';
            update toUpdatelead;
            
            
            /*------------------------------------------------Test Lead creation End---------------------------------------------------------*/
            
        }
    }
    
    //Test method for account type 'Distributor'
    @isTest
    static void updateDistributorTest1() 
    {
        test.startTest();
        List<User> DistiUserList = [select id from user where username = 'mtest2Distii@m.t' limit 1];
        List<Partner_Distributor__c> partnerdistiList = [select id,Reseller_Account__c from Partner_Distributor__c ];
        list<lead> leadList = new List<lead>();
        UtilityTestData.mLeadData.put('FirstName','test3 resell');
        UtilityTestData.mLeadData.put('LastName ','test3');
        UtilityTestData.mLeadData.put('Email','test3@testr3.q');
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert11113');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Partner Sourced/Partner Driven');
        UtilityTestData.mLeadData.put('Partner_Distributor__c',partnerdistiList[0].id+'');
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','');
        UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
        UtilityTestData.mLeadData.put('Status','Received');
        UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
        system.runAs(DistiUserList[0]){
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            leadList = (List<lead>)UtilityTest.makeInsert(new List<sObject>{lead});
            
            LeadTriggerHandler.DuplicateCheck(leadList);
        }
        //fetch user's account
        User user = [select Id,Contact.AccountId,AccountId from User where Id = :DistiUserList[0].id ];
        lead lead = [select id,Distributor__c,Reseller_SI_Partner__c from lead where Deal_Registration_Name__c='testLeadConvert11113'];
        system.assertEquals(lead.Distributor__c,user.AccountId);
        system.assertEquals(lead.Reseller_SI_Partner__c,partnerdistiList[0].Reseller_Account__c);
        test.stopTest();
    }
    
    //Test method for account type 'Reseller and SI'
    @isTest
    static void updateDistributorTest2() 
    {
        List<Account> accList = [select id from Account];
        List<ChannelProgram> channelProgList = [select id from ChannelProgram];
        List<User> ResSIUserList = [select id from user where username = 'mtest3@m.t' limit 1];
        list<lead> leadList = new List<lead>();
        test.startTest();
        UtilityTestData.mLeadData.put('FirstName','test3 referral');
        UtilityTestData.mLeadData.put('LastName ','test3');
        UtilityTestData.mLeadData.put('Email','test3@testr3.q');
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','Referral Test');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','Yes');
        UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
        UtilityTestData.mLeadData.put('Status','Received');
        UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
        system.runAs(ResSIUserList[0])
        {
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            leadList = (list<lead>)UtilityTest.makeInsert(new List<sObject>{lead});
        }
        //fetch user's account
        User user = [select Id,Contact.AccountId,AccountId from User where Id = :ResSIUserList[0].id ];
        lead lead = [select id,Reseller_SI_Partner__c from lead where Deal_Registration_Name__c='Referral Test'];
        system.assertEquals(lead.Reseller_SI_Partner__c,user.AccountId);
        test.stopTest();
    }
    
    @isTest
    static void PartnerAccountTypeCheckerTest()
    {
        Test.startTest();
        List<Account> accList = [select id from Account];
        List<User> userList = [select id from user where username = 'mtest@m.t' limit 1];
        Map<Id,String> partnerAccountIdTypeMap = new Map<Id,String>();
        partnerAccountIdTypeMap.put(accList[1].id,'Software Reseller');  
        
        system.assertEquals(LeadTriggerHandler.partnerAccountTypeChecker(userList[0].id),partnerAccountIdTypeMap);
        Test.stopTest();
    }
    
    @isTest
    static void DRTypeValidatiorTest()
    {
         test.startTest();
        /*List<User> ResUserList = [select id from user where username = 'mtest@m.t' limit 1];
        List<Account> accList = [select id from Account];
        
        //rus as partner user
        System.runAs(ResUserList[0]) 
        {
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testForDisti');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','Yes');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Approved');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id + '');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            try
            {
                List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
                system.assertEquals(leadList.size(),0);
            }
            catch(Exception e)
            {
                //System.AssertEquals(e.getMessage().contains(label.PRM_DealRegistration_ReferralTypeCheck_Error), true);
            }
            
        }*/
        
        test.stopTest();
    }
    
    //test method to check for update as Distributor Acc type
    @isTest
    static void DRTypeValidatiorTest2()
    {  
        test.startTest();
        List<User> DistiUser = [select id from user where username = 'mtest2Distii@m.t' limit 1];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Lead> leadList = [select id,Partner_Account__c from Lead where Deal_Registration_Name__c = 'testLeadConvert116'];
        List<Partner_Distributor__c> partnerdistiList = [select id from Partner_Distributor__c];
        //give access of the partner distributor record to disti user
        List<Partner_Distributor__share> shareRecLst = new List<Partner_Distributor__share>();
        System.runAs(adminUser) 
        {
            System.runAs(DistiUser[0]) 
            {
                leadList[0].Partner_Distributor__c = partnerdistiList[0].id;
                List<Lead> leadList1 = (List<Lead>) UtilityTest.makeUpdate(leadList);
                
                leadList1[0].Partner_Distributor__c = partnerdistiList[1].id;
                List<Lead> leadList2 = (List<Lead>) UtilityTest.makeUpdate(leadList1);
                
            }
        }
        test.stopTest();
    }
    
    @isTest
    static void updateDistributorMatchingCountryTest()
    {
        test.startTest();
        List<User> DistiUserList = [select id from user where username = 'mtest2Distii@m.t' limit 1];
        List<Partner_Distributor__c> partnerdistiList = [select id,Distributor__c from Partner_Distributor__c where Country__c = 'Australia'];
        List<Account> accList = [select id from Account];
        List<Lead> leadList = [select id from Lead where Deal_Registration_Name__c = 'testLeadConvert111_1'];
        List<User> ResUserList = [select id from user where username = 'mtest@m.t' limit 1];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Lead> upleadList = new List<lead>();
        system.runAs(adminUser)
        {
            leadList[0].Country = 'Australia';
            upleadList = (List<Lead>) UtilityTest.makeUpdate(leadList);
       }
        List<Lead> updatedleadList = [select id,Distributor__c from Lead where Deal_Registration_Name__c = 'testLeadConvert111_1'];
        system.assertEquals(updatedleadList[0].Distributor__c,partnerdistiList[0].Distributor__c);
        test.stopTest();
    }
    
    @isTest
    static  void apexSharingAfterUpdateTest()
    {
        List<Account> accList = [select id from Account];
        List<Account> accResellerUpdateList;
        List<Contact> ConResUpdateList;
        List<User> newUserList;
        List<Lead> toUpdateLeadList = new List<lead>();
        
        Map<Id,Id> userRoleMap = new Map<Id,Id>();
        
        test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
		List<Lead> leadList = [select id from Lead where Deal_Registration_Name__c = 'testLeadConvert111'];
                
        for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
            userRoleMap.put(role.PortalAccountId, role.Id);
        }
        
        system.runAs(adminUser)
        {
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller');
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
            UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
            UtilityTestData.mAccountData.put('billingCountry','India');
            sObject accResellerUpdate = new Account();
            accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
            
            sObject accDistUpdate = new Account();
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('Partner_Type__c','Distributor');
            accDistUpdate = UtilityTest.putFieldRecord(accDistUpdate, UtilityTestData.mAccountData);
            
            accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate,accDistUpdate});
            system.assert(accResellerUpdateList[0].id!=null,'The record is not inserted');
            
        }
        system.runAs(adminUser)
        {
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[0].id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName111');
            UtilityTestData.mContactData.put('LastName','test Con LastName111');
            UtilityTestData.mContactData.put('Email','testconemail11@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            
            sObject ConResUpdate = new Contact();
            ConResUpdate = UtilityTest.putFieldRecord(ConResUpdate, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('FirstName','test Con FirstName1122');
            UtilityTestData.mContactData.put('LastName','test Con LastName1122');
            UtilityTestData.mContactData.put('Email','testconemail122@gmail.com');
            
            sObject ConResUpdate1 = new Contact();
            ConResUpdate1 = UtilityTest.putFieldRecord(ConResUpdate1, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[1].id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName112');
            UtilityTestData.mContactData.put('LastName','test Con LastName112');
            UtilityTestData.mContactData.put('Email','testconemail12@gmail.com');
            
            sObject ConDistUpdate = new Contact();
            ConDistUpdate = UtilityTest.putFieldRecord(ConDistUpdate, UtilityTestData.mContactData);
            
            ConResUpdateList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate,ConResUpdate1,ConDistUpdate});
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest22a@m.t');
            UtilityTestData.mUserData.put('Email','mtest22a@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22a');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[0].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accResellerUpdateList[0].id));
            
            sObject newUserSobj1 = new User();
            newUserSobj1 = UtilityTest.putFieldRecord(newUserSobj1, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('Username','mtest22b@m.t');
            UtilityTestData.mUserData.put('Email','mtest22b@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22b');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[1].Id+'');
            
            sObject newUserSobj2 = new User();
            newUserSobj2 = UtilityTest.putFieldRecord(newUserSobj2, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('Username','mtest22c@m.t');
            UtilityTestData.mUserData.put('Email','mtest22c@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22c');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[2].Id+'');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accResellerUpdateList[1].id));
            
            sObject newUserSobj3 = new User();
            newUserSobj3 = UtilityTest.putFieldRecord(newUserSobj3, UtilityTestData.mUserData);
            newUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj1,newUserSobj2,newUserSobj3});
        }
        
        system.runAs(adminUser)
        {    
            leadList[0].Reseller_SI_Partner__c = accResellerUpdateList[0].id;
            
            leadList[0].Distributor__c = accResellerUpdateList[1].id;
            toUpdateLeadList = (List<Lead>) UtilityTest.makeUpdate(leadList);
            
        }
        //fetch the share records
        list<LeadShare> lead_shareListUpdated = [select id,userorgroupid from LeadShare];
        //the Partner user from new reseller account will have access to the record
        User partnerUser = [select id from User where Username = 'mtest22a@m.t'];
        list<LeadShare> lead_shareListforPartnerUsrUpdated = [select id,userorgroupid from LeadShare where userorgroupid = :partnerUser.Id and leadId = :toUpdateLeadList[0].id];
        //system.assertEquals(lead_shareListforPartnerUsrUpdated.size(), 1);
        test.stopTest();
    }
    
    @isTest
    static void LeadAndPrimaryContactValueSetterOnOpportunityTest()
    {
        Test.startTest();
        	List<Account> accList = [select id from Account];
            List<User> partnerUser = [select id from user where username = 'mtest@m.t' limit 1];
            List<Lead> leadList = [select id from Lead where Deal_Registration_Name__c = 'testLeadConvert112'];
            User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        
        	/*Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
            //create a contact as SOG(to create primary contact)
            
            //create another partner contact of type Reseller
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('Is_Primary__c','true');
            
            sObject contactSobj5 = new Contact();
            contactSobj5 = UtilityTest.putFieldRecord(contactSobj5, UtilityTestData.mContactData);
            
            List<Contact> primaryContactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj5});
            
            //create another partner user(reseller)
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest5@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm5@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest5');
            UtilityTestData.mUserData.put('CommunityNickname','mtest5');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',primaryContactList[0].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest5');
            UtilityTestData.mUserData.put('IsActive','true');
            sObject userSobj5 = new User();
            userSobj5 = UtilityTest.putFieldRecord(userSobj5, UtilityTestData.mUserData);
            
            UtilityTest.makeInsert(new List<sObject>{userSobj5});*/
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadList[0].id);
            //do not create oppty
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Approved');
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            List<Lead> cvtLead = [Select Id,IsConverted,ConvertedOpportunityId,Status from Lead where Id=:leadList[0].id ];
            //system.assertEquals(cvtLead.size(),1);
            Test.stopTest(); 
            
              
        
    }
    
    
    
    /**
    * This method is used to test populateOwner From LeadTriggerHandler 
    * <T01>
    */    
    @IsTest
    public static void populateOwnerTest(){
        Id fromUserId = System.Label.LeadFromUsername;
        Id toUserId = System.Label.LeadToUsername;
        User infogenieUser = [SELECT Id,Username FROM User WHERE Id = :fromUserId];
        System.runAs(infogenieUser){

            Test.startTest();
               // List<Partner_Distributor__c> partnerdistiList = [select id,Reseller_Account__c from Partner_Distributor__c ];
                list<lead> leadList = new List<lead>();
                UtilityTestData.mLeadData.put('FirstName','infogenie');
                UtilityTestData.mLeadData.put('LastName ','leadLast');
                UtilityTestData.mLeadData.put('Email','test51@infogenie.com');
                UtilityTestData.mLeadData.put('Status','Received');
                //create lead
                sObject lead = new Lead();
                lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
                
                leadList = (List<lead>)UtilityTest.makeInsert(new List<sObject>{lead});
            Test.stopTest();
            lead leadN = [select id,Distributor__c,Reseller_SI_Partner__c,OwnerId from lead where Email ='test51@infogenie.com'];
            system.assertEquals(leadN.OwnerId,toUserId);
        }
    }  //<T01>    


    /**
    * This method is used to test empty disqualified reason
    */    
    @IsTest
    public static void testAutoDQProcess(){
        User employeeUser = [Select id from User where EmployeeNumber = '12345'];
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
        leadList[0].Status = 'Working';
        //leadList[0].Disqualified_Reason__c = 'Not a decision maker';
        leadList[0].SL_Person_Stage__c = 'Completed';
        leadList[0].PSM__c = employeeUser.Id;
        Test.startTest();
            update leadList;        
        Test.stopTest();
            lead leadN = [select id,Status,Disqualified_Reason__c from lead where Id =:leadList[0].Id];
            system.assertEquals('Auto DQ from completed cadence',leadN.Disqualified_Reason__c);
    }  
    
    @IsTest
    public static void testAutoDQProcess2(){ 
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
        leadList[0].Status = 'Disqualified';
        leadList[0].Disqualified_Reason__c = 'Not a decision maker';
        //leadList[0].SL_Person_Stage__c = 'Completed';
        Test.startTest();
            update leadList;        
        Test.stopTest();
            lead leadN = [select id,Status,Disqualified_Reason__c from lead where Id =:leadList[0].Id];
            system.assertEquals('Not a decision maker',leadN.Disqualified_Reason__c);
    }
    
    /*
    * This method is used to test populate autodq timestamp field
    */    
    @IsTest
    public static void testPopulateAutoDQTimestamp(){
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
        leadList[0].Status = 'Working';
        leadList[0].SL_Person_Stage__c = 'Working';
        Test.startTest();
            update leadList;        
        Test.stopTest();
            lead leadN = [select id,Status,Disqualified_Reason__c,Auto_DQ_Timestamp__c from lead where Id =:leadList[0].Id];
            system.assertEquals(true,leadN.Auto_DQ_Timestamp__c != null);
    }
   
}