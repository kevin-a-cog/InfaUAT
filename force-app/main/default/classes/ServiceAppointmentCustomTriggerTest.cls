/*
 * Name         :   ServiceAppointmentCustomTriggerTest
 * Author       :   Vignesh Divakaran
 * Created Date :   10/8/2023
 * Description  :   Test class for ServiceAppointmentCustomTrigger, ServiceAppointmentTriggerHandler,ServiceAppointmentTriggerHelper.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      10/8/2023       I2RT-9063       Initial version.                        N/A
 Vignesh Divakaran      10/8/2023       I2RT-8841       Moved DMLs into UOW framework           T01
 */
@isTest(seeAllData = false)
public with sharing class ServiceAppointmentCustomTriggerTest {

    private static Id CUSTOMER_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    private static Id SUPPORT_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    private static Id ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();
    private static Id CASE_ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();
    private static List<Schema.SObjectType> PRIMARY_SOBJECTS = new List<Schema.SObjectType>{
        Account.SObjectType,
        TimeZone__c.SObjectType,
        Contact.SObjectType,
        AccountContactRelation.SObjectType,
        Asset.SObjectType,
        Entitlement.SObjectType,
        Entitled_Product__c.SObjectType,
        Time_Slot_AAE__c.SObjectType,
        User.SObjectType,
        PermissionSetAssignment.SObjectType
    };
    private static List<Schema.SObjectType> SECONDARY_SOBJECTS = new List<Schema.SObjectType>{
        Asset.SObjectType,
        Account.SObjectType,
        Time_Slot_AAE__Share.SObjectType
    };
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        sObject objCustomerAccount, objSupportAccount, objTimezone, objContact, objACR, objTimeSlot, objUser, objPermissionSetAssignment;

        System.runAs(new User(Id = UserInfo.getUserId())){

            /* Primary Objects */
            UnitOfWork objUnitOfWork = new UnitOfWork(PRIMARY_SOBJECTS);

            //Customer Account
            objCustomerAccount = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CUSTOMER_ACCOUNT_RECORDTYPEID);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            objCustomerAccount = UtilityTest.putFieldRecord(objCustomerAccount, UtilityTestData.mAccountData);
            objUnitOfWork.registerNew(objCustomerAccount);
            
            //Support Account
            objSupportAccount = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('RecordTypeId', SUPPORT_ACCOUNT_RECORDTYPEID);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('Active__c', 'true');
            objSupportAccount = UtilityTest.putFieldRecord(objSupportAccount, UtilityTestData.mAccountData);
            objUnitOfWork.registerNew(objSupportAccount, Account.ParentId, objCustomerAccount);

            //Timezone
            objTimezone = new TimeZone__c();
            objTimezone = UtilityTest.putFieldRecord(objTimezone, UtilityTestData.mTimeZone);
            objUnitOfWork.registerNew(objTimezone);

            //Contact
            objContact = new Contact();
            UtilityTestData.mContactData.put('FirstName','Test');
            UtilityTestData.mContactData.put('LastName','Contact');
            UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');   
            objContact = UtilityTest.putFieldRecord(objContact, UtilityTestData.mContactData);
            objUnitOfWork.registerRelationship(objContact, Contact.TimeZone_Lookup__c, objTimezone);
            objUnitOfWork.registerNew(objContact, Contact.AccountId, objCustomerAccount);

            //ACR
            objACR = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
            UtilityTestData.mAccContactRelation.put('IsActive', 'true');
            objACR = UtilityTest.putFieldRecord(objACR, UtilityTestData.mAccContactRelation);
            objUnitOfWork.registerRelationship(objACR, AccountContactRelation.AccountId, objSupportAccount);
            objUnitOfWork.registerNew(objACR, AccountContactRelation.ContactId, objContact);
            
            //Asset
            Asset objAsset = new Asset();
            objAsset.Name = 'Temporary Support';
            objUnitOfWork.registerRelationship(objAsset, Asset.AccountId, objCustomerAccount);
            objUnitOfWork.registerNew(objAsset, Asset.Support_Account__c, objSupportAccount);

            String strProductName = 'Axon Data Governance';
            String strSuccessOffering = 'Premium Success';
            String strSlaProcessId = [SELECT Id FROM SLAProcess WHERE IsActive = true AND Name = :strSuccessOffering limit 1]?.Id;

            //Entitlement
            Entitlement objEntitlement = new Entitlement();
            objEntitlement.Name = 'Temporary Support';
            objEntitlement.Support_Level__c = strSuccessOffering;   
            objEntitlement.SlaProcessId = strSlaProcessId;
            objEntitlement.StartDate = System.today();
            objEntitlement.EndDate = System.today().addDays(20);
            objUnitOfWork.registerRelationship(objEntitlement, Entitlement.AccountId, objCustomerAccount);
            objUnitOfWork.registerNew(objEntitlement, Entitlement.AssetId, objAsset);

            //Entitled Product
            Entitled_Product__c objEntitledProduct = new Entitled_Product__c();
            objEntitledProduct.Name = strProductName + '(On Premise)';
            objEntitledProduct.Forecast_Product__c = strProductName;
            objEntitledProduct.Delivery_Method__c = 'On Premise';
            objEntitledProduct.Support_Level__c = strSuccessOffering;
            objEntitledProduct.End_Date__c = objEntitlement.EndDate;
            objUnitOfWork.registerRelationship(objEntitledProduct, Entitled_Product__c.Account__c, objCustomerAccount);
            objUnitOfWork.registerRelationship(objEntitledProduct, Entitled_Product__c.Support_Account__c, objSupportAccount);
            objUnitOfWork.registerNew(objEntitledProduct, Entitled_Product__c.Entitlement__c, objEntitlement);

            //Time Slot
            List<Time_Slot_AAE__c> lstTimeSlots = new List<Time_Slot_AAE__c>();

            Time_Slot_AAE__c objTS1 = new Time_Slot_AAE__c();
            objTS1.Product__c = strProductName;
            objTS1.Status__c = 'Available';
            objTS1.Start_Time__c = System.today().addDays(8);
            lstTimeSlots.add(objTS1);

            Time_Slot_AAE__c objTS2 = new Time_Slot_AAE__c();
            objTS2.Product__c = strProductName;
            objTS2.Status__c = 'Available';
            objTS2.Start_Time__c = System.today().addDays(9);
            lstTimeSlots.add(objTS2);

            Time_Slot_AAE__c objTS3 = new Time_Slot_AAE__c();
            objTS3.Product__c = strProductName;
            objTS3.Status__c = 'Available';
            objTS3.Start_Time__c = System.today().addDays(10);
            lstTimeSlots.add(objTS3);
            objUnitOfWork.registerNew(lstTimeSlots);

            //Create customer community user
            Id CUSTOMER_COMMUNITY_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1]?.Id;

            objUser = new User();
            UtilityTestData.mUserData.put('ProfileId',CUSTOMER_COMMUNITY_PROFILE_ID+'');
            UtilityTestData.mUserData.put('Username','tstconmail101@gmail.com');
            UtilityTestData.mUserData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mUserData.put('Alias','talias');
            UtilityTestData.mUserData.put('CommunityNickname','testUserNickname');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('FirstName','Test');
            UtilityTestData.mUserData.put('LastName','Contact');
            UtilityTestData.mUserData.put('IsActive','true');
            objUser = UtilityTest.putFieldRecord(objUser, UtilityTestData.mUserData);
            objUnitOfWork.registerNew(objUser, User.ContactId, objContact);
            
            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Customer_Community_user' LIMIT 1]?.Id;
            objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSetId);
            objUnitOfWork.registerNew(objPermissionSetAssignment, PermissionSetAssignment.AssigneeId, objUser);

            //Now, we commit the primary objects
            objUnitOfWork.commitWork();

            /* Secondary Objects */
            objUnitOfWork = new UnitOfWork(SECONDARY_SOBJECTS);

            Id userId = [SELECT Id FROM User WHERE UserName = 'tstconmail101@gmail.com' LIMIT 1]?.Id;
            Asset objAssetToUpdate = [SELECT Id FROM Asset LIMIT 1];
            Entitled_Product__c objEntitledProductQueried = [SELECT Id,Entitlement__c,End_Date__c FROM Entitled_Product__c LIMIT 1];
            Account objSupportAccountToUpdate = [SELECT Id FROM Account WHERE RecordTypeId = : SUPPORT_ACCOUNT_RECORDTYPEID LIMIT 1];

            //Update EP on Asset
            objAssetToUpdate.Entitled_Product__c = objEntitledProductQueried.Id;
            objUnitOfWork.registerDirty(objAssetToUpdate);

            //Rollup success offering, entitlement & end date onto the support account
            objSupportAccountToUpdate.Success_Offering__c = strSuccessOffering;
            objSupportAccountToUpdate.Entitlement__c = objEntitledProductQueried.Entitlement__c;
            objSupportAccountToUpdate.End_Date__c = objEntitledProductQueried.End_Date__c;
            objUnitOfWork.registerDirty(objSupportAccountToUpdate);

            //Manually share Time Slot AAE records as criteria based sharing rules are not evaluated in test class
            List<Time_Slot_AAE__Share> lstTimeSlotShares = new List<Time_Slot_AAE__Share>();
            for(Time_Slot_AAE__c objTS : [SELECT Id FROM Time_Slot_AAE__c]){
                Time_Slot_AAE__Share objTimeSlotShare = new Time_Slot_AAE__Share();
                objTimeSlotShare.AccessLevel = 'Read';
                objTimeSlotShare.ParentID = objTS.Id;
                objTimeSlotShare.UserOrGroupId = userId;
                lstTimeSlotShares.add(objTimeSlotShare);
            }
            objUnitOfWork.registerNew(lstTimeSlotShares);

            //Now, we commit the secondary objects 
            objUnitOfWork.commitWork();
        }
    }

    /*
     Method Name : createAAECase
     Description : Testing Ask An Expert case creation as esupport user.
     Parameters  : None
     Return Type : None
    */
    @isTest
    public static void createAAECase() {
        Test.startTest();
        User objCustomerUser = [SELECT Id FROM User WHERE UserName = 'tstconmail101@gmail.com' LIMIT 1];
        Id supportAccountId = [SELECT Id FROM Account WHERE RecordTypeId = :SUPPORT_ACCOUNT_RECORDTYPEID LIMIT 1]?.Id;
        List<Time_Slot_AAE__c> lstTimeSlots = [SELECT Id FROM Time_Slot_AAE__c WHERE Status__c = 'Available'];

        //Create Service Appointment as esupport user
        System.runAs(objCustomerUser){
            Service_Appointment__c objSA = new Service_Appointment__c();
            objSA.Support_Account__c = supportAccountId;
            objSA.Subject__c = 'Test Subject';
            objSA.Description__c = 'Test Description';
            objSA.Area__c = 'Best Practices';
            objSA.Category__c = 'Test Category';
            objSA.Time_Slot_AAE__c = lstTimeSlots[0].Id;
            objSA.RecordTypeId = ASK_AN_EXPERT_RECORDTYPEID;
            insert objSA;
        }

        //Assertions
        lstTimeSlots = [SELECT Id FROM Time_Slot_AAE__c WHERE Status__c = 'Booked'];
        Assert.isTrue(lstTimeSlots.size() > 0, 'Time Slot AAE status is not updated to \'Booked\'');

        List<Case> lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :CASE_ASK_AN_EXPERT_RECORDTYPEID];
        Assert.isTrue(lstCases.size() > 0, 'Ask An Expert Case is not created.');

        List<Event> lstEvents = [SELECT Id FROM Event WHERE IsChild = false];
        Assert.isTrue(lstEvents.size() > 0, 'Event is not created.');

        Test.stopTest();
    }

    /*
     Method Name : muteTriggersTest
     Description : Testing Service Appointment trigger muting.
     Parameters  : None
     Return Type : None
    */
    @isTest
    public static void muteTriggersTest() {

        //Enable muting
        Global_Config__c objSettings = Global_Config__c.getOrgDefaults();
        objSettings.Mute_Triggers__c = true;
        objSettings.Ignore_All_Flows__c = true;
        upsert objSettings Global_Config__c.Id;  

        Test.startTest();
        User objCustomerUser = [SELECT Id FROM User WHERE UserName = 'tstconmail101@gmail.com' LIMIT 1];
        Id supportAccountId = [SELECT Id FROM Account WHERE RecordTypeId = :SUPPORT_ACCOUNT_RECORDTYPEID LIMIT 1]?.Id;
        List<Time_Slot_AAE__c> lstTimeSlots = [SELECT Id FROM Time_Slot_AAE__c WHERE Status__c = 'Available'];

        //Create Service Appointment as esupport user
        System.runAs(objCustomerUser){
            Service_Appointment__c objSA = new Service_Appointment__c();
            objSA.Support_Account__c = supportAccountId;
            objSA.Subject__c = 'Test Subject';
            objSA.Description__c = 'Test Description';
            objSA.Area__c = 'Best Practices';
            objSA.Category__c = 'Test Category';
            objSA.Time_Slot_AAE__c = lstTimeSlots[0].Id;
            objSA.RecordTypeId = ASK_AN_EXPERT_RECORDTYPEID;
            insert objSA;
        }

        //Assertions
        lstTimeSlots = [SELECT Id FROM Time_Slot_AAE__c WHERE Status__c = 'Booked'];
        Assert.isTrue(lstTimeSlots.size() == 0, 'FLOW MUTING FAILED: Time Slot AAE status is updated to \'Booked\'');

        List<Case> lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :CASE_ASK_AN_EXPERT_RECORDTYPEID];
        Assert.isTrue(lstCases.size() == 0, 'TRIGGER MUTING FAILED: Ask An Expert Case is created.');

        List<Event> lstEvents = [SELECT Id FROM Event WHERE IsChild = false];
        Assert.isTrue(lstEvents.size() == 0, 'TRIGGER MUTING FAILED: Event is created.');

        Test.stopTest();
    }
}