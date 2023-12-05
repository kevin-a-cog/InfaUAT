/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for SupportAccountController
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 Amarender    30/11/2021  I2RT-4793  T01    Code Coverage
 Vignesh D    30/05/2022  I2RT-6149  T02    Code Coverage
 */
@isTest
public with sharing class SupportAccountControllerTest {
    public SupportAccountControllerTest() {

    }
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerContactRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
    
    @testSetup
    static void setupObjectTestData() {
        //create an Account record
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Signature_Success__c', 'true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
        //UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',CustomerContactRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('OwnerId', userInfo.getUserId());
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');  
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);       
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Objective
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});        
        
        //Milestone
        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Status__c','In Progress');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Key_Milestone__c','false');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone}); 
        
        /*sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('RecordTypeId',CustomerContactRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lSupportAccContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});*/

        sObj = new AccountContactRelation();
        UtilityTestData.mAccContactRelation.put('AccountId', lAccount[0].Id);
        UtilityTestData.mAccContactRelation.put('ContactId', lContact[0].Id);
        UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
        UtilityTestData.mAccContactRelation.put('Primary__c', 'true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
        List<AccountContactRelation> lSupportAccContact = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
        //UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CSM' Limit 1];

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CSM' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Id =: UserInfo.getUserId() Limit 1];
        System.runAs(adminUser){
        adminUser.UserRoleId = userRole.Id;
            update adminUser;
            timezone__c tz = new timezone__c(location_name__c='Europe/London',location__c = 'Japan',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
            insert tz;
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus User'];
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
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS Customer Community user')]){
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
    Test.startTest();
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        sObj.put('Support_Account__c', lAccount.get(0).Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('AccountId', lAccount.get(0).Id);
        sObj.put('OwnerId', UserInfo.getUserId());
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
        
        List<ContentVersion> conVersionList = new List<ContentVersion>();
        //create ContentVersion  record 
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        conVersionList.add(contentVersion1);
        
        
        //create ContentVersion  record 
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true);
        conVersionList.add(contentVersion2);
        insert conVersionList;
        Test.stopTest();
        //Need to fix null pointer issues in ZIssueTriggerHelper
        /*zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c();
        zissue.zsfjira__Description__c = 'test';
        zissue.zsfjira__IssueId__c = 1234;
        zissue.zsfjira__IssueKey__c = '1234';        
        insert zissue;
        try{
            zsfjira__ZIssue_Case__c zfc = new zsfjira__ZIssue_Case__c();
            zfc.zsfjira__CaseId__c = lCase[0].Id;
            zfc.zsfjira__ZIssueId__c = zissue.Id;
            insert zfc;
        }catch (Exception e){
            system.debug('exception');
        }*/
    }
    
    @isTest
    static void testAllMethods(){
        Id SupportAccountId;
        Id CustomerAccountId;
        //Account acc = [Select Id,recordtype.DeveloperName From Account];
        for(Account acc : [Select Id,recordtype.DeveloperName From Account]){
            if(acc.recordtype.DeveloperName == 'Support_Account'){
                SupportAccountId = acc.Id;
            } else if(acc.recordtype.DeveloperName == 'Customer_Account'){
                CustomerAccountId = acc.Id;
            }
        }

        Case cse = [Select Id From Case Limit 1];
        Contact con = [Select Id From Contact /*Where Account.RecordType.DeveloperName ='Support_Account'*/ Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];
        AccountContactRelation acr = [Select Id from AccountContactRelation Limit 1];
        Test.startTest();

        SupportAccountController controller = new SupportAccountController();

        SupportAccountController.getAccounts(SupportAccountId);
        SupportAccountController.getCases(SupportAccountId);
        SupportAccountController.getEngagements(SupportAccountId);
        SupportAccountController.getCasesNotEscalated(SupportAccountId);
        SupportAccountController.getCasesOpen(SupportAccountId);
        SupportAccountController.getCases(SupportAccountId);
        List<Id> caseIdLst = new List<Id>{cse.Id};
            List<String> caseString=new List<String>{cse.Id};    
        String caseIdLstString = JSON.serialize(caseIdLst);
        String passSt=JSON.serialize(caseString);
        SupportAccountController.associateCasesToEngagement(engagement.Id, caseIdLstString ,'Reason');
        SupportAccountController.createEngagement(SupportAccountId, 'Test Engagement 2', 'P2', 'Hot', 'Customer', 'Escalation','Test','',passSt,'Reason',null);
        SupportAccountController.getSupportAccount(SupportAccountId);
        SupportAccountController.getUnassignedContacts(CustomerAccountId,SupportAccountId);
        SupportAccountController.getCasesEscalated(SupportAccountId);
        SupportAccountController.removeContacts(acr.Id);
        /*   timezone__c tz = new timezone__c(location_name__c='Europe/London',location__c = 'Japan',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
        insert tz;
        User communityUser = [SELECT ID FROM User Where Email = 'portalUsers@m.t' LIMIT 1];
    
        System.runAs(communityUser){
        try {
                SupportAccountController.createContact('firstname','lastname','email@test.com','1234567890','English (US)','APAC','Japan','false','Read/Write',SupportAccountId);
                SupportAccountController.updateContactRelation('firstname','lastname',con.Id,'true','1234567890','English (US)','APAC','Japan','Read/Write','true','','false',SupportAccountId);
           
        } catch (Exception e) {}
        }
        */
        //</T01>
        Test.stopTest();
    }

    @isTest
    static void testConACR(){
        Id SupportAccountId;
        timezone__c tz = new timezone__c(location_name__c='Europe/London',location__c = 'Japan',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
        insert tz;
       
        for(Account acc : [Select Id,recordtype.DeveloperName From Account where recordtype.DeveloperName='Support_Account' ]){            
                SupportAccountId = acc.Id;        
        }
        User communityUser = [SELECT ID FROM User Where Email = 'portalUsers@m.t' LIMIT 1];
        Contact con = [Select Id From Contact /*Where Account.RecordType.DeveloperName ='Support_Account'*/ Limit 1];
        Test.startTest();
        System.runAs(communityUser){
        try {
                SupportAccountController.createContact('firstname','lastname','email@test.com','1234567890','English (US)','APAC','Japan','false','Read/Write',SupportAccountId);
                SupportAccountController.updateContactRelation('firstname','lastname',con.Id,'true',/*'email@test.com',*/'1234567890','English (US)','APAC','Japan','Read/Write','true','','false',SupportAccountId);
           
            } catch (Exception e) {}            }
           
        Test.stopTest();

    }
    @isTest
    static void testUpdateContactRelation(){
        Id SupportAccountId = [Select Id From Account Where recordtype.DeveloperName ='Support_Account' Limit 1].Id;
        Contact con = [Select Id From Contact /*Where Account.RecordType.DeveloperName ='Support_Account'*/ Limit 1];
        Test.startTest();
        try{
            SupportAccountController.updateContactRelation('firstname12','lastname12',con.Id,'true',/*'email123@test1.com',*/'1234567890','English (US)','APAC','Japan','Read/Write','true','','false',SupportAccountId);
           
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    static void testAssignContactsToSupportAccount(){
        Id SupportAccountId = [Select Id From Account Where recordtype.DeveloperName ='Support_Account' Limit 1].Id;
        List<String> conIdList = new List<String>();
        for(Contact con : [Select Id From Contact Where Account.RecordType.DeveloperName ='Customer_Account']){
            conIdList.add(con.Id);
        }
        Test.startTest();
        try{
            SupportAccountController.assignContactsToSupportAccount(SupportAccountId,conIdList);
            
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    static void testUpdateDocVersion(){
        Id SupportAccountId = [Select Id From Account Where recordtype.DeveloperName ='Support_Account' Limit 1].Id;
        List<ContentDocument> listContentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 2];
        Test.startTest();
        SupportAccountController.updateDocVersion(listContentDocuments[0].Id,listContentDocuments[1].Id,'Test Description',SupportAccountId);
       
        Test.stopTest();
    }
    @isTest
    static void testRemoveFile(){
        Id SupportAccountId = [Select Id From Account Where recordtype.DeveloperName ='Support_Account' Limit 1].Id;
        List<ContentDocument> listContentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 2];
        Test.startTest();
        SupportAccountController.removeFile(listContentDocuments[0].Id,SupportAccountId);
        
        Test.stopTest();
    }
   @isTest
    static void engagementWithPlanTest(){

        Account acc = [Select Id From Account where recordtypeid=:supportAccountRecType Limit 1];
        Case cse = [Select Id From Case Limit 1];
    plan__c plan =[select id from Plan__c Limit 1];
        Test.startTest();

        SupportAccountController controller = new SupportAccountController();

        SupportAccountController.createEngagement(acc.Id, 'Test Engagement 2', 'P2', 'Hot', 'Customer', 'Escalation','Test','','["' + cse.Id + '"]','Reason',plan.Id);
       
        Test.stopTest();
    }
     @isTest
    static void engagementWithMilestoneTest(){

        Account acc = [Select Id From Account where recordtypeid=:supportAccountRecType Limit 1];
        Case cse = [Select Id From Case Limit 1];
    Milestone__c mile =[select id from Milestone__c Limit 1];
        Test.startTest();

        SupportAccountController controller = new SupportAccountController();


        SupportAccountController.createEngagement(acc.Id, 'Test Engagement 2', 'P2', 'Hot', 'Customer', 'Escalation','Test','','["' + cse.Id + '"]','Reason',mile.Id);
       
        Test.stopTest();
    }

    //---------------------------------------<T02>----------------------------
    /*
    Method Name : getCertificationRequestTest
    Description : Test fetching approved certificatio request along with approval history.
    Parameters  : None
    Return Type : None
    */
    @isTest
    public static void getCertificationRequestTest(){
        Test.startTest();

        Id supportAccountId = [SELECT Id FROM Account WHERE RecordTypeId =: SupportAccountRecType LIMIT 1]?.Id;
        List<Certification_Request__c> lstCertificationRequests = new List<Certification_Request__c>();
        String strRequestType = '';
        String strCertificationType = '';

        for(Schema.PicklistEntry objPickList : Certification_Request__c.Request_Type__c.getDescribe().getPickListValues()) {
            strRequestType = objPickList.getValue();
            break;
        }

        for(Schema.PicklistEntry objPickList : Certification_Request__c.Certification_Type__c.getDescribe().getPickListValues()) {
            strCertificationType = objPickList.getValue();
            break;
        }

        // SupportAccountController.rollupCertificationRequest(new List<Id>{supportAccountId});

        Certification_Request__c objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = supportAccountId;
        objCertificationRequest.Start_Date__c = System.today();
        objCertificationRequest.End_Date__c = System.today().addDays(20);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Approved';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);

        objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = supportAccountId;
        objCertificationRequest.Start_Date__c = System.today();
        objCertificationRequest.End_Date__c = System.today().addDays(30);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Approved';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);
        insert lstCertificationRequests;

        for(Certification_Request__c obj : lstCertificationRequests){
            obj.Status__c = 'Approved';
        }   
        update lstCertificationRequests;

        System.assertNotEquals(SupportAccountController.getCertificationRequest((String) supportAccountId) == null, true, 'There are no approved certification requests.');
        // SupportAccountController.rollupCertificationRequest(new List<Id>{supportAccountId});
        SupportAccountController.isSuccessApp();

        Test.stopTest();
    }
    //---------------------------------------<T02>----------------------------
  @isTest
    static void getPicklistValuesforRegionAndLocationTest(){
        SupportAccountController.createContact('firstname','lastname','email@test.com','1234567890','English (US)','APAvC','Japan','false','Read/Write','123321123321123');
                
        timezone__c tz = new timezone__c(location_name__c='Europe/London',location__c = 'test',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
        insert tz;
        timezone__c tz1 = new timezone__c(location_name__c='Europe/London',location__c = 'test1',region__c='APAC', timezone__c='GMT+01:00 British Summer Time (Europe/London)');
        insert tz1;
        
        SupportAccountController.getPicklistValuesforRegionAndLocation();
    }

    /*
     Method Name : orgDetailsTest
     Description : Testing community user access to org
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void orgDetailsTest() {
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())){
            sObject sObj;

            Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
            Id ecommerceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();
            Id caseLiteRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();
            
            Timezone__c objTimezone = new TimeZone__c();
            objTimezone.Name = '(GMT-07:00) Pacific Daylight Time (America/Los_Angeles)';
            objTimezone.Location__c = 'Pacific';
            objTimezone.Location_Name__c = 'America/Los Angeles';
            objTimezone.Location_Region__c = 'North America';
            objTimezone.Region__c = 'AMER';
            objTimezone.TimeZoneSidKey__c = 'America/Los_Angeles';
            objTimezone.Zone_Abbreviation__c = 'PDT';
            objTimezone.Zone_Name__c = 'Pacific Daylight Time';
            insert objTimezone;

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', customerAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test eCommerce Account');
            UtilityTestData.mAccountData.put('RecordTypeId', ecommerceAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewEcommerceAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','TEST CONTACT FIRSTNAME');
            UtilityTestData.mContactData.put('LastName','TEST CONTACT LASTNAME');
            UtilityTestData.mContactData.put('Email','testOrgEmail@test.com');
            UtilityTestData.mContactData.put('Phone','1234567890');
            UtilityTestData.mContactData.put('MailingCountry','USA');
            UtilityTestData.mContactData.put('INFA_Language__c','English');
            UtilityTestData.mContactData.put('TimeZone_Lookup__c',objTimezone.Id+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lNewContacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mAccContactRelation.put('ContactId', lNewContacts[0].Id);
            UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
            UtilityTestData.mAccContactRelation.put('IsActive', 'true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            List<AccountContactRelation> lNewAccountContacts = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Org_Name__c', 'Test Org');
            UtilityTestData.mOrgData.put('OrgType__c', 'Trial');
            UtilityTestData.mOrgData.put('Pod_Name__c', 'TEST-POD-NAME');
            UtilityTestData.mOrgData.put('OfferCode__c', 'TEST-OFFER-CODE');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'TEST-LOCATION');
            UtilityTestData.mOrgData.put('Account__c', lNewEcommerceAccount[0].Id+'');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'XXXXYYYYYZZZZZ-TEST');
            UtilityTestData.mOrgData.put('OrgId__c', 'ORGTESTZZZXXXYYY');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> lNewOrg = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Date dt = System.today().addDays(90);
            sObj = new Org_Service__c();
            UtilityTestData.mOrgServiceData.put('Org_ID__c', lNewOrg[0].Id+'');
            UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
            UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
            List<Org_Service__c> lNewOrgService = (List<Org_Service__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org_User__c();
            UtilityTestData.mOrgUserData.put('Contact__c', lNewContacts[0].Id);
            UtilityTestData.mOrgUserData.put('Org__c', lNewOrg[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
            List<Org_User__c> lNewOrgUsers = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Id customerCommunityProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1]?.Id;

            sObj = new User();
            UtilityTestData.mUserData.put('ProfileId',customerCommunityProfileId+'');
            UtilityTestData.mUserData.put('Username','testOrgEmail@test.com');
            UtilityTestData.mUserData.put('Email','testOrgEmail@test.com');
            UtilityTestData.mUserData.put('Alias','talias');
            UtilityTestData.mUserData.put('CommunityNickname','testUserNickname');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('FirstName','Test');
            UtilityTestData.mUserData.put('LastName','User');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('ContactId',lNewContacts[0].Id+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
            List<User> lNewUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Support_Lite_Community_User']?.Id;

            insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);

            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test Case Lite Case');
            UtilityTestData.mCase.put('Description', 'Test Case Lite Description');
            UtilityTestData.mCase.put('Status', 'New');
            UtilityTestData.mCase.put('Priority', 'P3');
            UtilityTestData.mCase.put('RecordTypeId', caseLiteRecordTypeId);
            UtilityTestData.mCase.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mCase.put('Org__c', lNewOrg[0].Id);
            UtilityTestData.mCase.put('ContactId ', lNewContacts[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> lNewCases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
        
        User objUser = [SELECT Id FROM User WHERE UserName = 'testOrgEmail@test.com' LIMIT 1];
        Id ecommerceAccountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'eCommerce']?.Id;
        Org_Service__c objOrgService = [SELECT Id FROM Org_Service__c LIMIT 1];
        System.runAs(objUser){
            SupportAccountController.getSupportAccount(ecommerceAccountId);
        }

        objOrgService.Org_Service_Name__c = 'Simple DI';
        update objOrgService;

        Test.stopTest();
        System.runAs(objUser){
            try{
                SupportAccountController.getSupportAccount(ecommerceAccountId);
            }
            catch(Exception e){
                //do nothing
            }
        }
    }


    @isTest
    public static void testEsupportCR() {
        Test.setMock(HttpCalloutMock.class, new SupportAccountCalloutMock());
        Account acc=[select Id from account where RecordType.name = 'Support Account' limit 1];
        try{
            SupportAccountController.eSupportAccountCRDetails(acc.Id, 'dummytoken');
            List<SupportAccountController.eSupportCRWrapper> crWrapperListResponse = SupportAccountController.eSupportAccountCRDetails(acc.Id, 'dummytoken');
            system.debug('--Resp--'+crWrapperListResponse);
        }catch(Exception ex ){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
}