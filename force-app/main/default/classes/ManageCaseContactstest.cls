/*
Class:          ManageCaseContactstest
@Author:        Venky
@Created Date:  13-Jan-2021
@Description:   Test class to ManageCaseContacts

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public with sharing class ManageCaseContactstest {

    public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';

    public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
    public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';

    public static final String SKILL_NAME_AUTHOR = 'KB_AUTHOR_CONTRIBUTOR';
    public static final String SKILL_NAME_CONTENT_REVIEWER = 'KB_CONTENT_REVIEWER';
    public static final String SKILL_NAME_ACTIVE_VOS = 'KB_TECH_ACTIVEVOS';  
   

   

    @testSetup
    static void setupObjectTestData() {         
        System.runAs(new User(Id = UserInfo.getUserId())){
            //Customer Account
            sObject Account = new Account();
            Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();        
            
            UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
            Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
            
            //Support Account
            sObject Account2 = new Account();
            Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();        
            UtilityTestData.mAccountData.put('Name','Test Support Account');
            UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId2);
            UtilityTestData.mAccountData.put('ParentId',lAccount[0].Id);
            Account2 = UtilityTest.putFieldRecord(Account2, UtilityTestData.mAccountData);
            
            List<Account> lsupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account2});
            
            //Contact
            sObject Contactrec = new Contact();
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            Contactrec = UtilityTest.putFieldRecord(Contactrec, UtilityTestData.mContactData);                   
            List<Contact> lContact = new List<Contact>();
            lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contactrec});
            
            
            
            //Case
            sObject Caserec = new Case();
            UtilityTestData.mCase.put('AccountId',lsupportAccount[0].Id);
            UtilityTestData.mCase.put('ContactId',lContact[0].Id);  
            Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
            List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec});
            
            timezone__c tz = new timezone__c(location_name__c='Europe/London',location__c = 'Japan',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
            insert tz;
            
            //Case Contact
            sObject Casecon = new Case_Contact__c();
            UtilityTestData.mCaseContact.put('Case__c',lcase[0].Id);
            UtilityTestData.mCaseContact.put('Contact__c',lContact[0].Id);  
            Casecon = UtilityTest.putFieldRecord(Casecon, UtilityTestData.mCaseContact);
            System.debug('Casecon-rec before insert->'+Casecon);
            List<Case_Contact__c> lcasecon = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{Casecon});   
            System.debug('Casecon-rec after insert->'+lcasecon);
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
            List<user> lstUser = new List<user>();
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','portalUsers@m.t');
            UtilityTestData.mUserData.put('Email','portalUsers@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','portalTest');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
            UtilityTestData.mUserData.put('ContactId',lContact[0].Id +'');
            sObject partnerUser = new User();
            partnerUser = UtilityTest.putFieldRecord(partnerUser, UtilityTestData.mUserData);
            lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{partnerUser});
            List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
            for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name = 'GCS_Customer_Community_user']){
                lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = lstUser[0].id, PermissionSetId = ps.Id ));
            }
            insert lstInsertPermissionSets;
            
            //Manually sharing the Timezone record, since criteria based sharing doesn't work in test class
            TimeZone__Share tzShare = new TimeZone__Share ();
            tzShare.ParentId = tz.Id;
            tzShare.UserOrGroupId = partnerUser.Id;
            tzShare.AccessLevel = 'read';
            insert tzShare;
        }
    }
    
    

    static testMethod void testManageCaseContacts(){
        System.debug('testManageCaseContacts--entry');
        List<ManageCaseContacts.Fieldsetwrapper> fswrapperlist = new List<ManageCaseContacts.Fieldsetwrapper>();
        ManageCaseContacts.Fieldsetwrapper fsw = new ManageCaseContacts.Fieldsetwrapper();
        String caseid;
        String accId;
        List<Id> caseConId=new List<Id>();
        fsw.objectName = 'Contact';
        fsw.fieldSetName = 'Assigned_Case_Contacts';
        fswrapperlist.add(fsw);
        Test.startTest();
        ManageCaseContacts.getFields(JSON.serialize(fswrapperlist));
        
        
      
        String caseConFields='Email__c,Primary__c';
        String AccountContactRelationfields='is_admin__c';
        String searchKey='Test';
        List<Case> c=new List<Case>([select Id,caseNumber from Case limit 1]);
        List<Account> lsupportAccount=new List<Account>([select Id,Name from Account limit 1]); 
        List<Case_Contact__c> lcasecon = new List<Case_Contact__c>([select Id,Name from Case_Contact__c ]);
           List<Contact> lstContact = new List<Contact>([select Id,Name,Email from Contact limit 1]);
        System.debug('lcasecon-->'+lcasecon);
        if(!c.isempty())
        {
            caseid=String.valueOf(c[0].Id);
        }
        if(!lsupportAccount.isEmpty())
        {
            accId=String.valueOf(lsupportAccount[0].Id);
        }
        if(!lcasecon.isempty())
        {
            caseConId.add(lcasecon[0].Id);
        }
        
        System.debug('caseConId-->'+caseConId);        
        ManageCaseContacts.getAssignedCaseContacts(searchKey,caseid,caseConFields);
        ManageCaseContacts.getUnassignedCaseContacts(searchKey,caseid,accId,AccountContactRelationfields);
        ManageCaseContacts.removeCaseContacts(caseConId);
        ManageCaseContacts.updatecontacts(lstContact);
        ManageCaseContacts.addCaseContacts(lstContact,caseid);
        ManageCaseContacts.createcasecontactcontr(lcasecon,accId);
        
        Test.stopTest();
    }

    @isTest
    public static void createNewContactEmailExceptionTest(){
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<Account> lAccount = [Select Id From Account where RecordTypeId = :supportAccountRecId Limit 1];
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        
        
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('Email','testcon');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact conObj = (Contact) UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        Test.startTest();
        try {
            ManageCaseContacts.CreateNewContact(JSON.serialize(conObj),lAccount[0].Id,lCase[0].Id,'APAC','Japan');
        } catch (Exception e) {
            System.debug('Exception e : ' + e);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void createNewContactLastNameExceptionTest(){
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<Account> lAccount = [Select Id From Account where RecordTypeId = :supportAccountRecId Limit 1];
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        
        
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('Email','testcon@infa.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact conObj = (Contact) UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        Test.startTest();
        try {
            ManageCaseContacts.CreateNewContact(JSON.serialize(conObj),lAccount[0].Id,lCase[0].Id,'APAC','Japan');
        } catch (Exception e) {
            System.debug('Exception e : ' + e);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void createNewContactFirstNameExceptionTest(){
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<Account> lAccount = [Select Id From Account where RecordTypeId = :supportAccountRecId Limit 1];
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        
        
        sObject sObj = new Contact();
        UtilityTestData.mContactData.put('LastName','lastname1');
        UtilityTestData.mContactData.put('Email','testcon@infa.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact conObj = (Contact) UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        Test.startTest();
        try {
            ManageCaseContacts.CreateNewContact(JSON.serialize(conObj),lAccount[0].Id,lCase[0].Id,'APAC','Japan');
        } catch (Exception e) {
            System.debug('Exception e : ' + e);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void createNewContactTest(){
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id customerContactRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        List<Account> lAccount = [Select Id, parentID From Account where RecordTypeId = :supportAccountRecId Limit 1];
        System.assertNotEquals(0, lAccount.size());
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        list<Contact> lContact = [select id from contact];
        System.assertNotEquals(0, lCase.size());
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObject sObj = new AccountContactRelation();
        UtilityTestData.mAccContactRelation.put('AccountId', lAccount[0].Id);
        UtilityTestData.mAccContactRelation.put('ContactId', lContact[0].Id);
        UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
        UtilityTestData.mAccContactRelation.put('Primary__c', 'true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
        List<AccountContactRelation> lSupportAccContact = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        UtilityTestData.mContactData.put('Email','testcon@infa.com');
        UtilityTestData.mContactData.put('Access_Level__c','Read/Write');
        UtilityTestData.mContactData.put('Timezone__c','GMT+05:30 India Standard Time (Asia/Kolkata)');
        UtilityTestData.mContactData.put('INFA_Language__c','English');
        UtilityTestData.mContactData.put('Language__c','English');
        UtilityTestData.mContactData.put('Phone','+19876543210');
        UtilityTestData.mContactData.put('RecordTypeId',customerContactRecId);
        UtilityTestData.mContactData.put('Is_Primary__c','Active');
        Contact conObj = (Contact) UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        user portalUser = [select id from user where email = 'portalUsers@m.t' limit 1];
        Test.startTest();
        ManageCaseContacts.CreateNewContact(JSON.serialize(conObj),lAccount[0].Id,lCase[0].Id,'APAC','Japan');
        system.runas(portalUser){
            ManageCaseContacts.CreateNewContact(JSON.serialize(conObj),lAccount[0].Id,lCase[0].Id,'APAC','Japan');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getAlternateContactsTest(){
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<Account> lAccount = [Select Id From Account where RecordTypeId = :supportAccountRecId Limit 1];
        System.assertNotEquals(0, lAccount.size());
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        System.assertNotEquals(0, lCase.size());
        Test.startTest();
        ManageCaseContacts.getPermissionOnObject();
        ManageCaseContacts.getContacts(lAccount[0].Id,lCase[0].Id);
        Test.stopTest();
    }
}