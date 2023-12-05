/*
* Name			:	CSMEngagementTriggerHandlerTest
* Author		:	
* Created Date	: 	
* Description	:	Test class for CsmEngagementTriggerHelper, CSMEngagementTgrHelper_WithoutSharing

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					                Tag
**********************************************************************************************************
 Chaitanya T       12/04/2023                       To increase the code coverage               T01
*/
@IsTest 
public class CSMEngagementTriggerHandlerTest {
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Product Request').getRecordTypeId();
    static Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    static Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
    static Id GEMSEscalationRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Support_Escalation').getRecordTypeId();
    private static final String RENEWAL_RECORDTYPE_NAME = Label.Renewal_Opportunity;
    
    @testSetup
    static void setupObjectTestData() 
    {
        List<Account> accList = new List<Account>();
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        
            
        system.runAs(adminUser){        
            //create SI partner account
            UtilityTestData.mAccountData.put('Name','Software reseller and SI');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');
            UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
            UtilityTestData.mAccountData.put('Partner_Type__c','Systems Integrator');
            sObject partnerAcc1 = new Account();
            partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);
        
            //create SI partner account
            UtilityTestData.mAccountData.put('Name','Software reseller and SI 2');
            sObject partnerAcc2 = new Account();
            partnerAcc2 = UtilityTest.putFieldRecord(partnerAcc2, UtilityTestData.mAccountData);
        
            //Add all accounts to acclist
            accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1,partnerAcc2});

             //Opportunity
            Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
            Id pbId = Test.getStandardPricebookId();
            UtilityTestData.mOpportunityData.put('AccountId', accList[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');
            UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
            UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
            UtilityTestData.mOpportunityData.put('Name', 'Primary');
            UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
            UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
            UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
            sObject sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
            //Plan
            sObject Plan = new Plan__c();
            UtilityTestData.mPlan.put('Account__c',accList[0].Id);
            UtilityTestData.mPlan.put('Name','Test Plan One');//
            UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
            UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
            UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
            UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
            Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
            List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
            
            List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
            planTeamList.add(new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=lPlan[0].Id,Role__c='CSA',Primary__c=false)); 
            insert planTeamList;
        
            //Engagement
            sObject engagement = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',accList[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('Status__c','Approved');
            UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
            UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
            engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);   
            
            sObject engagement3 = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',accList[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpStartRT);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('Status__c','Completed');
            engagement3= UtilityTest.putFieldRecord(engagement3, UtilityTestData.mEngagementData);
            
            sObject engagement2 = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',accList[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('Status__c','Approved');
            UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
            engagement2 = UtilityTest.putFieldRecord(engagement2, UtilityTestData.mEngagementData);   
            List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement,engagement2});
        }
        List<User> prtnrUserList = new List<User>();
        List<Contact> contactList = new List<Contact>();        
        system.runAs(adminUser){
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Is_Primary__c','true');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('FirstName','Contact');
            UtilityTestData.mContactData.put('Email','Contact1@test.com');
            sObject contactSobj1 = new Contact();
            contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Email','Contact2@test.com');
            sObject contactSobj2 = new Contact();
            contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Email','Contact3@test.com');
            sObject contactSobj3 = new Contact();
            contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contacta@test.com');
            sObject contactSobja = new Contact();
            contactSobja = UtilityTest.putFieldRecord(contactSobja, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contactb@test.com');
            sObject contactSobjb = new Contact();
            contactSobjb = UtilityTest.putFieldRecord(contactSobjb, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contactc@test.com');
            sObject contactSobjc = new Contact();
            contactSobjc = UtilityTest.putFieldRecord(contactSobjc, UtilityTestData.mContactData);
            
            Test.startTest();
            system.runAs(adminUser){
                contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobjb,contactSobj2,contactSobj3,contactSobja,contactSobjc});
            }
            
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
            
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
                userRoleMap.put(role.PortalAccountId, role.Id);
            }
            
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp1@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp1');
            UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp1@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp1');
            UtilityTestData.mUserData.put('LastName','user1');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a employee user sobject
            sObject prtnrUser1 = new User();
            prtnrUser1 = UtilityTest.putFieldRecord(prtnrUser1, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp2@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp2');
            UtilityTestData.mUserData.put('ContactId',contactList[1].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp2@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp2');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a user sobject
            sObject prtnrUser2 = new User();
            prtnrUser2 = UtilityTest.putFieldRecord(prtnrUser2, UtilityTestData.mUserData);

            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp3@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp3');
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp3@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp3');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a employee user sobject
            sObject prtnrUser3 = new User();
            prtnrUser3 = UtilityTest.putFieldRecord(prtnrUser3, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp4@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp4');
            UtilityTestData.mUserData.put('ContactId',contactList[3].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp4@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp4');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a user sobject
            sObject prtnrUser4 = new User();
            prtnrUser4 = UtilityTest.putFieldRecord(prtnrUser4, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp5@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp5');
            UtilityTestData.mUserData.put('ContactId',contactList[4].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp5@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp5');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a user sobject
            sObject prtnrUser5 = new User();
            prtnrUser5 = UtilityTest.putFieldRecord(prtnrUser5, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp6@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp6');
            UtilityTestData.mUserData.put('ContactId',contactList[5].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp6@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp6');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            // Initialize a user sobject
            sObject prtnrUser6 = new User();
            prtnrUser6 = UtilityTest.putFieldRecord(prtnrUser6, UtilityTestData.mUserData);
            
            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{prtnrUser1,prtnrUser2,prtnrUser3,prtnrUser4,prtnrUser5,prtnrUser6});

            PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps1.Id );
            PermissionSet psb = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = psb.Id );
            PermissionSet psb2 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[2].id, PermissionSetId = psb2.Id );
            PermissionSet psb3 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[3].id, PermissionSetId = psb3.Id );
            PermissionSet psb4 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[4].id, PermissionSetId = psb4.Id );
            PermissionSet psb5 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[5].id, PermissionSetId = psb5.Id );
                Test.stopTest();
            
        Global_Config__c gl = new Global_Config__c(SetupOwnerId=UserInfo.getOrganizationId(),Ignore_All_Flows__c=true);
        insert gl;
        }
    }
    //Covers Account populating when engagement is created by Partner user
    //and Apex sharing on insert and update of engagement object
    static testMethod void allPRMEngagmentTriggerMethods()
    {
        
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [select id,Name from Account limit 2];
        system.assert(userList[0].Id!=null,'The record not queried');
        system.assert(adminUser.Id!=null,'The record not queried');
        system.assert(accList[0].Id!=null,'The record not queried');
        
       Test.startTest();
        //Run as Partner user so that the Account is pre-populated.
        system.runAs(userList[0]){
            UtilityTestData.mEngagementData.put('Name','Test Engagement Partner');
            UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId); 
            sObject engmntPrtnr = new Engagement__c();
            List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmntPrtnr});
            System.assertNotEquals(engmntListPrtnr[0].Id,null);
        }
        Engagement__c insertedEngmnt = [select id,Account__c from Engagement__c limit 1];
        system.assertEquals(insertedEngmnt.Account__c, accList[0].id);
        
        //fetch the share records
        list<Engagement__Share> eng_shareList = [select id,userorgroupid,AccessLevel from Engagement__Share];
        //system.assertEquals(eng_shareList.size(), 3);
        
        UtilityTestData.mEngagementData.put('Name','Test Engagement 1');
        UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId);
        UtilityTestData.mEngagementData.put('Account__c',accList[0].id);   
        sObject engmnt = new Engagement__c();
        engmnt = UtilityTest.putFieldRecord(engmnt, UtilityTestData.mEngagementData);
        
        //Run as admin to update the account on engagement so that the apexSharingUpdate is covered.
        List<Engagement__c> upEngmntList = new List<Engagement__c>();
        system.runAs(adminUser){
            List<Engagement__c> engmntList = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmnt});
            engmntList[0].Name = 'test sd';
            engmntList[0].Account__c = accList[1].Id;
            upEngmntList = (List<Engagement__c>) UtilityTest.makeUpdate(engmntList);
            System.assertEquals(upEngmntList[0].Account__c,accList[1].Id);
        }
        //fetch the share records
        list<Engagement__Share> updatedEng_shareList = [select id,userorgroupid,AccessLevel from Engagement__Share where parentid = :upEngmntList[0].id];
        system.assertEquals(updatedEng_shareList.size(), 3);
        Test.stopTest();
    }
    
    static testMethod void NotifyUsersTest(){
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [select id,Name from Account limit 1];
        Test.startTest();
        //Run as Partner user so that the Account is pre-populated.
        system.runAs(userList[0]){
            UtilityTestData.mEngagementData.put('Name','Test Engagement Partner');
            UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId); 
            sObject engmntPrtnr = new Engagement__c();
            List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmntPrtnr});
            System.assertNotEquals(engmntListPrtnr[0].Id,null);
        }
        Engagement__c insertedEngmnt = [select id,Account__c from Engagement__c Limit 1];
        List<Id> engagementList = new List<Id>();
        engagementList.add(insertedEngmnt.Id);
        
        EngagementInvocableNotifyCSM.invokeAction(engagementList);
        Test.stopTest();
    }

   
    
    static testMethod void handleExceptionTest(){
        try{
            List<Id> engagementList = new List<Id>();
            EngagementInvocableNotifyCSM.invokeAction(engagementList);
        }catch(Exception ex){
            system.debug('Handle Exception');
        }
    }
    
    static testMethod void testIPSJumpStartEngagement(){
        Test.startTest();
        
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.psa_ProjectTrigger__c = true;
        insert trigSetting;
        
        List<Account> lAccount = [select id,Name from Account limit 1];
        
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Contact
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('LastName','Contact');
        UtilityTestData.mContactData.put('Email','Contact861@test.com');
        UtilityTestData.mContactData.put('MailingCountry','USA');
        sObject contactSobj1 = new Contact();
        contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>)UtilityTest.makeInsert(new List<sObject>{contactSobj1});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('Override_Eligibility__c',true+'');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        
        //Engagement
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Accepted');
        UtilityTestData.mEngagementData.put('Project_Manager__c',lContact[0].id);
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);   
        
        
       sObject engagement1 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
        UtilityTestData.mEngagementData.put('Project_Manager__c',lContact[0].id);
        engagement1 = UtilityTest.putFieldRecord(engagement1, UtilityTestData.mEngagementData); 
        
         sObject engagement2 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
        UtilityTestData.mEngagementData.put('Project_Manager__c',lContact[0].id);
        engagement2 = UtilityTest.putFieldRecord(engagement2, UtilityTestData.mEngagementData);
        
        sObject engagement3 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
        UtilityTestData.mEngagementData.put('Project_Manager__c',lContact[0].id);
        engagement3 = UtilityTest.putFieldRecord(engagement3, UtilityTestData.mEngagementData); 
        
        sObject engagement4 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Completed');
        UtilityTestData.mEngagementData.put('Project_Manager__c',lContact[0].id);
        engagement4 = UtilityTest.putFieldRecord(engagement4, UtilityTestData.mEngagementData);
        
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement,engagement1,engagement2,engagement3,engagement4});
        
        lEngagement[0].Status__c= 'Submitted for Approval';
        lEngagement[1].Status__c= 'Approved';
        lEngagement[2].Status__c= 'Rejected';
        lEngagement[3].Status__c= 'Completed';
        //lEngagement[4].Status__c= 'Completed';
        update lEngagement;
        
        
        Test.stopTest();
    } 
    
    static testMethod void testcompletedIPSJumpStartEngagement(){
        Test.startTest();
        List<Account> lAccount = [select id,Name from Account limit 1];
        
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('LastName','Contact');
        UtilityTestData.mContactData.put('Email','Contact861@test.com');
        UtilityTestData.mContactData.put('MailingCountry','USA');
        sObject contactSobj1 = new Contact();
        contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>)UtilityTest.makeInsert(new List<sObject>{contactSobj1});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Engagement
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);        
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
       
        lEngagement[0].Project_Manager__c = lContact[0].Id;
        update lEngagement;
        
        Test.stopTest();
    } 
    
    static testMethod void testdeletedIPSJumpStartEngagement(){
        Test.startTest();
        List<Account> lAccount = [select id,Name from Account limit 1];
        list<Notification_Criteria_Field__mdt> supportTier = [SELECT Id, DeveloperName from Notification_Criteria_Field__mdt];
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('LastName','Contact');
        UtilityTestData.mContactData.put('Email','Contact861@test.com');
        UtilityTestData.mContactData.put('MailingCountry','USA');
        sObject contactSobj1 = new Contact();
        contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>)UtilityTest.makeInsert(new List<sObject>{contactSobj1});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
       // UtilityTestData.mPlan.put('CSM_isAutoPilot__c','true');
        UtilityTestData.mPlan.put('Journey__c','Business 360');
        UtilityTestData.mPlan.put('Implementation_Owner__c','Customer');
        UtilityTestData.mPlan.put('Plan_status_picklist__c','Green');
        UtilityTestData.mPlan.put('Current_State_of_plan__c','Onboarding');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        lPlan[0].CSM_isAutoPilot__c= true;
        update lPlan[0];
        //Engagement
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);        
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
        
        //Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement1 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstartRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagement1 = UtilityTest.putFieldRecord(engagement1 , UtilityTestData.mEngagementData);        
        List<Engagement__c> lEngagement1 = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement1});
       
        //List<Engagement__c> lEngagement1 = [select id from Engagement__c limit 2];
        delete lEngagement1[0];
        Test.stopTest();
    } 
    
    static testMethod void testCSTEngagement(){
        User usrObj = createTestUser('System Administrator', true);
        System.runAs(usrObj) {
            Test.startTest();
            List<Engagement__c> leng =new List<Engagement__c>();
            
            
            for(Engagement__c obj:[Select Id,Status__c,OwnerId from Engagement__c]){
                obj.Status__c= 'Accepted';
                obj.OwnerId= usrObj.Id;
                leng.add(obj);
            }
            
            update leng;
            
            Test.stopTest();
        }
    }
    
    static testMethod void testCSTEngagementChatter(){
        User usrObj = createTestUser('System Administrator', true);
        
        
        System.runAs(usrObj) {
            Test.startTest();
            List<Account> lAccount = [select id,Name from Account limit 1];
            List<Contact> lContact = [select id from Contact limit 1];
            sObject engagement2 = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Primary_Contact__c',lContact[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());            
            UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
            UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
            UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
            engagement2 = UtilityTest.putFieldRecord(engagement2, UtilityTestData.mEngagementData);
            List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement2});
            Test.stopTest();
        }
    }
    
    static testMethod void testcompletedCSTEngagement(){
        User usrObj = createTestUser('System Administrator', true);
        List<PermissionSetAssignment> lstPermissionSets = new  List<PermissionSetAssignment>();
        for(PermissionSet objPermissionSet :[SELECT Id, type FROM PermissionSet WHERE Name LIKE 'Super_User']) {
			if(objPermissionSet.Type == 'Regular'){
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = usrObj.id, PermissionSetId = objPermissionSet.Id));
			}
        }
        insert lstPermissionSets;
        System.runAs(usrObj) {

        Test.startTest();
        List<Account> lAccount = [select id,Name from Account limit 1];
        List<Contact> lContact = [select id from Contact limit 1];
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Engagement
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
        UtilityTestData.mEngagementData.put('RecType__c','CSA');
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);     
        
 
        sObject engagement1 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
        UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
        UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
        UtilityTestData.mEngagementData.put('RecType__c','CSA');
        engagement1 = UtilityTest.putFieldRecord(engagement1, UtilityTestData.mEngagementData);   
            
         sObject engagement2 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Primary_Contact__c',lContact[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());            
        UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
        UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
        UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
        UtilityTestData.mEngagementData.put('RecType__c','CSA');
        engagement2 = UtilityTest.putFieldRecord(engagement2, UtilityTestData.mEngagementData);
            
        sObject engagement3 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());            
        UtilityTestData.mEngagementData.put('Engagement_Model__c','Repeatable');
        UtilityTestData.mEngagementData.put('Engagement_ID__c','ENG-987');
        UtilityTestData.mEngagementData.put('RecType__c','CSA');
        engagement3 = UtilityTest.putFieldRecord(engagement3, UtilityTestData.mEngagementData);
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement,engagement1,engagement2,engagement3});
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});

      
        
        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);

        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone});

        lEngagement[0].Status__c= 'Completed';
        lEngagement[0].Milestone__c= lMilestone[0].Id;
        lEngagement[0].Closing_Notes__c= 'test';
        lEngagement[1].Status__c= 'Close without Engagement';
        lEngagement[1].Closing_Notes__c= 'test';
        lEngagement[2].Status__c= 'Accepted';
        lEngagement[2].Milestone__c= lMilestone[0].Id;
        lEngagement[0].OwnerId= usrObj.Id;
        update lEngagement;
        
        Test.stopTest();
        }
    }
    
     static testMethod void testSupportEngagement(){
        User usrObj = createTestUser('System Administrator', true);
        List<PermissionSetAssignment> lstPermissionSets = new  List<PermissionSetAssignment>();
        for(PermissionSet objPermissionSet :[SELECT Id,type FROM PermissionSet WHERE Name LIKE 'Super_User']) {
			if(objPermissionSet.Type == 'Regular'){
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = usrObj.id, PermissionSetId = objPermissionSet.Id));
			}
        }
        insert lstPermissionSets;
        System.runAs(usrObj) {
        Test.startTest();
        List<Account> lAccount = [select id,Name from Account limit 1];
        List<User> lUser = [Select Id from User limit 1];
        
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');//
         UtilityTestData.mPlan.put('Override_Eligibility__c',true+'');
         UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Engagement
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', GEMSEscalationRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);    
        
        
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject cstEngagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        cstEngagement = UtilityTest.putFieldRecord(cstEngagement, UtilityTestData.mEngagementData);        
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement,cstEngagement});
        
        lEngagement[0].CSM_Summary__c= 'Test';
         if(lUser[0] <> null){
             lEngagement[0].OwnerId = usrObj.Id;
         }
        update lEngagement;
        
        Test.stopTest();
        }
    }


    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id, type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            if(ps.Type == 'Regular'){
                PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
                psAssignList.add(psAssign);
            }
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
    
    static testmethod void testQueueable() {
         // query for test data to pass to queueable class
         List<Plan_Team__c > lstPlanTeamRecords = [select id, name from Plan_Team__c ];
         // Create our Queueable instance
         CsmEngagementTriggerHelper obj = new CsmEngagementTriggerHelper(lstPlanTeamRecords);
         // startTest/stopTest block to force async processes to run
         Test.startTest();        
         System.enqueueJob(obj);
         Test.stopTest();  
     }

    static testmethod void testConsumeEUInternal() {//<T01> start
        List<Engagement__c> engList = [SELECT Id,Account__c,Engagement_Units__c FROM Engagement__c LIMIT 1];
        engList[0].Engagement_Units__c = 1;
        List<Schema.SObjectType> sObjects = new Schema.SObjectType[] {Engagement__c.SobjectType};
        UnitOfWork uow = new UnitOfWork(sObjects);
        uow.registerDirty(engList);
        uow.commitWork();
        CsmEngagementTriggerHelper.consumeEUInternal(engList);
    }//</T01> end
}