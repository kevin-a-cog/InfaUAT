/*
Class:          ContactTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for ContactTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag
Anil Solanki        23-Mar-2021   SALESRT-12936     Added Test method to cover populateCampaign Series <T01>
******************************************************************
*/
@isTest(SeeAllData=false)
public class ContactTriggerHandlerTest {    
    //static Id opptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
    //static Id opptyRec1TypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
    //static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();   
    //static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    //static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    //static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    //static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    //static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    //static Id ChannelProgramLevelRecTypeId = Schema.SObjectType.ChannelProgramLevel.RecordTypeInfosByName.get('AIR').RecordTypeId;
    private Final Static String VEMPLOYEE = Label.Profile_Employee;
    
    @testSetup
    static void setupObjectTestData() {    
        //<T01> -START
        //Creating Marketing User to create Campaign Records
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        UtilityTestData.mUserData.put('ProfileId',adminProfile.id+'');
        UtilityTestData.mUserData.put('ContactId',NULL); 
        UtilityTestData.mUserData.put('Username','marketingTestUserAdmn@m.t');
        UtilityTestData.mUserData.put('Email','marketingTestUserAdmn@m.t');
        UtilityTestData.mUserData.put('Alias','mngr');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('LastName','Test');
        UtilityTestData.mUserData.put('FirstName','User');
        UtilityTestData.mUserData.put('UserPermissionsMarketingUser','true');
        
        sObject marketingUser= new User();
        marketingUser= UtilityTest.putFieldRecord(marketingUser, UtilityTestData.mUserData);  
        
        List<User> marketingUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{marketingUser});
        
        //<T01> -END
        
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        
        User adminUser = userList[0];
        //User sogUser = userList[1];
        
        List<Contact> contactList;
        List<User> prtnrUserList;
        
        Account customerAcc = accList[0];
        //Account partnerResellerAcc = accList[1];
        Account partnerDistiAcc = accList[2];
        
        //Anil : Merged Code START 
        sObject sObj = new Account();
        Test.StartTest();
        //<T01> - Start 
        //Create Campaign records.   
        system.runAs(marketingUserList[0]){
            //Create Campaign
            sObject sobjCampaign = new Campaign();
            sObject sobjCampaign1 = new Campaign();
            
            sobjCampaign = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 1');
            UtilityTestData.mCampaignData.put('Campaign_Series__c','Cloud');
            sobjCampaign = UtilityTest.putFieldRecord(sobjCampaign, UtilityTestData.mCampaignData);
            //System.debug('@@@@@'+sObjCampaign);
            
            sobjCampaign1 = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 2');
            UtilityTestData.mCampaignData.put('Campaign_Series__c','Big Data');
            sobjCampaign1 = UtilityTest.putFieldRecord(sobjCampaign1, UtilityTestData.mCampaignData);
            UtilityTest.makeInsert(new List<sObject>{sobjCampaign,sobjCampaign1});
        }
        //<T01> - END
        
        System.runAs(adminUser){
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            //Lead object data
            UtilityTestData.mLeadData.put('Email', 'testingduplicateEmailLead@test.com');
            sObj = new Lead();
            // Call methos and pass sObject and data maps
            // This utility method will populate all the fields data according to the Map passed
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);         
            UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //DMLOption setup
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            
            //Creating a duplicate Lead 2
            UtilityTestData.mLeadData.put('FirstName', 'DuplicateLeadFirst');
            UtilityTestData.mLeadData.put('Email', 'testingduplicateEmailLead@test.com');
            sObj = new Lead();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);
            UtilityTest.makeInsertDMLOptions(new List<sObject>{sObj}, dml);
            
            // Set all the required fields and dynamic ids in Map : Contact 1
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            //UtilityTestData.mContactData.put('Email', 'testingduplicate1Email@test.com');
            sObj = new Contact(Email = 'testingduplicate1Email@test.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            UtilityTest.makeInsert(new List<sObject>{sObj});
        } 
        //ANIL :Merged Code END
        
        UtilityTestData.mContactData.put('AccountId',partnerDistiAcc.id);
        UtilityTestData.mContactData.put('Is_Primary__c','False');
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','false');
        UtilityTestData.mContactData.put('Partner_Role__c','Partner Portal Admin');
        UtilityTestData.mContactData.put('MailingCountry','US');
        sObject contactSobj2 = new Contact();
        contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);    
        
        UtilityTestData.mContactData.put('AccountId',partnerDistiAcc.id);
        UtilityTestData.mContactData.put('Is_Primary__c','True');
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
        UtilityTestData.mContactData.put('Partner_Role__c','Marketing');
        UtilityTestData.mContactData.put('MailingCountry','US');
        sObject contactSobj3 = new Contact();
        contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
        //System.debug('sOBJ' + sOBJ + 'contactSobj2' + contactSobj2 + 'contactSobj3' + contactSobj3);
        
        //<T01>- Created extra test record
        UtilityTestData.mContactData.put('MQL_Program_Name__c','Test 1');
        UtilityTestData.mContactData.put('Name','Test');
        
        sObject contactSobj4 = new Contact();
        contactSobj4 = UtilityTest.putFieldRecord(contactSobj4, UtilityTestData.mContactData);
        //<T01>
        System.runAs(adminUser) {
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj2,contactSobj3,contactSobj4});
        }
        
        /*------------------------------------------------Test Partner User Creation Start---------------------------------------------------------*/
        Map<Id,Id> userRoleMap = new Map<Id,Id>();
        for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
            userRoleMap.put(role.PortalAccountId, role.Id);
        }
        
        //create partner user(disti)
        Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'][0];
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest2_check_update_share@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest3');
        UtilityTestData.mUserData.put('CommunityNickname','mtest3');
        UtilityTestData.mUserData.put('ContactId',contactList[0].id+''); 
        UtilityTestData.mUserData.put('LastName','mtest3');
        UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(customerAcc.id));
        sObject userSobj2 = new User();
        userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);
        
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest3_check_update_share@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest4');
        UtilityTestData.mUserData.put('CommunityNickname','mtest4');
        UtilityTestData.mUserData.put('ContactId',contactList[1].id+''); 
        UtilityTestData.mUserData.put('LastName','mtest4');
        UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(customerAcc.id));
        sObject userSobj3 = new User();
        userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);
        
        system.runas(adminUser){
            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj2,userSobj3});
        }
        
        system.runAs(adminUser){
            PermissionSet ps01 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps01.Id );
            
            PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = ps1.Id );
        }
        Test.StopTest();
    }
    
      //test method: contactPrimaryUpdationDupeChecker
      /*
  @isTest
  public static void contactPrimaryUpdationDupeCheckerTest() {
    List<Account> acctList = [Select Id,(SELECT Id FROM Contacts WHERE Is_Primary__c = FALSE) FROM Account];      
      Test.startTest();
      //List<User> userList = UtilityTest.createUsersforPRM();
      User adminUser = [SELECT Id FROM User WHERE Username = 'prmTestMgrAdmn@m.t' LIMIT 1];
        
      System.runAs(adminUser) {
        sObject toUpdateCon1 = (Contact) acctList[0]?.contacts[0];
        UtilityTestData.mContactData.put('Is_Primary__c','true');
        toUpdateCon1 = UtilityTest.putFieldRecord(toUpdateCon1, UtilityTestData.mContactData);
        List<Contact> con1 = UtilityTest.makeUpdate(new list<sObject>{toUpdateCon1});
        //system.assertEquals(con1.size(),1);
        Assert.areEqual(con1.size(),1);
      }
      Test.stopTest();
  }
  */
    @isTest
    public static void duplicatecheckTest(){
        String leadRecordType  = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
        Lead l = new Lead(FirstName = 'Test Lead', Email = 'testingduplicateEmailLead111@test.com', recordtypeId = leadRecordType, LastName = 'Duplicate', Company = 'Informatica');
        insert l;
        User stdUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard Platform user' AND IsActive = TRUE LIMIT 1];
        System.runAs(stdUser){
            Contact con = new Contact(FirstName = 'Test', LastName = 'Sog Contact', Email = 'testingduplicateEmailLead111@test.com');
            try{
        		insert con;
            }
            catch(Exception e){
               Assert.isNotNull(e.getMessage(),'DML Exception occurred'); 
            }
        }
    }
  //test method: contactPrimaryInsertionDupeChecker
    @isTest
    public static void contactPrimaryInsertionDupeCheckerTest() {
        List<Account> accList = [Select id,(SELECT Id FROM Contacts WHERE Is_Primary__c = FALSE)  From Account];
        List<Contact> contactList = new list<contact>();
        Test.startTest();        
        //List<User> userList = UtilityTest.createUsersforPRM();      
        //User adminUser = userList[0];                
        User adminUser = [SELECT Id FROM User WHERE Username = 'prmTestMgrAdmn@m.t' LIMIT 1];
        
        UtilityTestData.mContactData.put('AccountId',accList[0].id);
        UtilityTestData.mContactData.put('Is_Primary__c','True');      
        sObject contactSobj3 = new Contact();
        contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
        System.runAs(adminUser){
            contactList = UtilityTest.makeInsert(new List<sObject>{contactSobj3});
        }          
        Test.stopTest();
        //system.assertEquals(contactList.size(),1);    
        Assert.areEqual(contactList.size(),1, 'Contact list has one record');
    }
  
  //test method: contactPrimaryUpdationDupeChecker & sharingDRAfterUpdate
    @isTest 
    public static void testMethod3() {
        List<Contact> contactList = [Select id  From Contact limit 10];      
        sObject toUpdateCon = (Contact) contactList[1];
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
        toUpdateCon = UtilityTest.putFieldRecord(toUpdateCon, UtilityTestData.mContactData);
        
        sObject toUpdateCon1 = (Contact) contactList[2];
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','false');
        toUpdateCon1 = UtilityTest.putFieldRecord(toUpdateCon1, UtilityTestData.mContactData);
        Test.startTest();
        UtilityTest.makeUpdate(new list<sObject>{toUpdateCon,toUpdateCon1});
        Test.stopTest();
        //system.debug('List<Contact> con1 -> '+con1);
        
        User partnerUser = [select id from User where contact.View_All_Deal_Registrations__c = false LIMIT 1];
        list<leadshare> leadShareListforPartnerUsr = [select id,userorgroupid from leadshare where userorgroupid = :partnerUser.Id];
        //system.assertEquals(leadShareListforPartnerUsr.size(), 0);   
        Assert.areEqual(leadShareListforPartnerUsr.size(), 0, 'List is Empty'); 
    }
    //ANIL : Merged Code START
    /*
        Below methods are covering the class ContactTriggerHandler
        */
    @isTest
    static void myUnitTestDuplicateContactCheck() {
        User userObj = [select Id, Name from User where Profile.Name =: VEMPLOYEE AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account');
        //system.assertEquals(lAccount.size(), 5);
        Assert.areEqual(lAccount.size(), 5, 'Account has 5 records'); 
        
        Test.StartTest();
        System.runAs(userObj) {
            UtilityTestData.mContactData.put('AccountId', lAccount[4].Id);
            UtilityTestData.mContactData.put('Email', 'testingduplicate1Email@test.com');
            sObject sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            try {
                Database.insert(sObj, false);
            } catch (DmlException e) {
                //System.assert(e.getDmlMessage(1).indexOf('DuplicateContacts') > -1);
                Assert.isTrue(e.getDmlMessage(1).indexOf('DuplicateContacts') > -1,'Dml Exception occurred');
            }
        }
        Test.StopTest();
    }
        //Test method to check for duplicate contact on Update operation
    @isTest
    static void myUnitTestDuplicateContactCheckOnUpdate() {
        User userObj = [select Id, Name from User where Profile.Name =: VEMPLOYEE AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account ');
        //system.assertEquals(lAccount.size(), 5);
        Assert.areEqual(lAccount.size(), 5, 'Account has 5 records');
        Test.StartTest();
        System.runAs(userObj) {
            //Contact 2 record insert
            UtilityTestData.mContactData.put('AccountId', lAccount[4].Id);
            UtilityTestData.mContactData.put('Email', 'testingduplicate@test.com');
            UtilityTestData.mContactData.put('FirstName', 'DuplicateFirst');
            UtilityTestData.mContactData.put('LastName', 'DuplicateLast');
            UtilityTestData.mContactData.put('MailingCountry', 'US');
            sObject sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Contact 2 record update operation to detect duplicacy with Original contact in the testSetup
            sObj = new Contact(ID = lContact[0].Id);
            UtilityTestData.mContactData.put('ID', lContact[0].Id);
            UtilityTestData.mContactData.put('Email', 'testingduplicate1Email@test.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            try{
            	UtilityTest.makeUpdate(new List<sObject>{sObj});
            }
            catch(Exception e){
                Assert.isNotNull(e.getMessage(),'DML Exception occurred'); 
            }
        }
        Test.StopTest();
    }

    @isTest
    static void myUnitTestDuplicateLeadEmailCheck() {
        User userObj = [select Id, Name from User where Profile.Name =: VEMPLOYEE AND isActive=true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account');
        //system.assertEquals(lAccount.size(), 5);
        Assert.areEqual(lAccount.size(), 5, 'Account has 5 records');
        Test.StartTest();
        
        System.runAs(userObj) {
            UtilityTestData.mContactData.put('AccountId', lAccount[4].Id);
            UtilityTestData.mContactData.put('Email', 'testingduplicateEmailLead@test.com');
            UtilityTestData.mContactData.put('MailingCountry', 'US');
            UtilityTestData.mContactData.put('LastName', 'DuplicateContactLast');
            sObject sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            try {
                Database.insert(sObj, false);
            } catch (DmlException e) {
                //System.assert(e.getDmlMessage(1).indexOf('DuplicateLeads') > -1);
                Assert.isTrue(e.getDmlMessage(1).indexOf('DuplicateLeads') > -1, 'Dml exception occured');
            }
        }
        Test.StopTest();    
    }
    
     //ANIL : Merged Code END

     //<T01>
     //Method to test if Campaign series gets updated if MQL Program name is updated on Contact
    @isTest
    static void myUnitTestPopulateCampaignSeries() {
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id,Campaign_Series__c,MQL_Program_Name__c from Contact limit 1');
        Test.StartTest();
        //system.debug(lContact);
        //system.debug(lContact[0].Campaign_Series__c); 
        lContact[0].MQL_Program_Name__c = 'Test 2';
        update lContact[0];               
        // List<Contact> lContactUpdated = (List<Contact>) UtilityTest.executeQuery('Select Id,Campaign_Series__c,MQL_Program_Name__c from Contact');
        List<Contact> lContactUpdated = [Select Id,Campaign_Series__c,MQL_Program_Name__c from Contact where Id=:lContact[0].Id];
        //System.assertEquals('Big Data',lContactUpdated[0].Campaign_Series__c);
        Assert.areEqual('Big Data',lContactUpdated[0].Campaign_Series__c, 'Campaign series is Big Data');
        Test.StopTest();         
    }    
}