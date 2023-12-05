@isTest
public with sharing class esAskAnExpertFlowContainerControllerTest {
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();

    @testSetup
    static void setupObjectTestData() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            //create an TimeZone record
            SObject sObj = new TimeZone__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
            List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
             sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
            UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('Active__c', 'true');
            UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
            UtilityTestData.mAccountData.put('Success_Offering__c', 'Signature Success');

            UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.debug('new List<sObject>{sObj} ' + lNewSupportAccount[0].Owner.userRole.name);
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id);
            UtilityTestData.mContactData.put('FirstName','test Con FirstName1');
            UtilityTestData.mContactData.put('LastName','test Con LastName1');
            UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = 'testing.txt';
            conVer.Title = 'Sample article file';
            conVer.VersionData = EncodingUtil.base64Decode('file content');
            insert conVer;
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = contacts[0].Id;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.shareType = 'V';
            insert conDocLink;   
            
           
            
            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
            UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
            UtilityTestData.mAccContactRelation.put('IsActive','true');
            UtilityTestData.mAccContactRelation.put('Access_Level__c','Read/Write');
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new AccountContactRole();
            UtilityTestData.mAccContact.put('AccountId', lNewSupportAccount[0].id);
            UtilityTestData.mAccContact.put('ContactId', contacts[0].id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContact);
            List<AccountContactRole> accountContactRoles = (List<AccountContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Entitled_Product__c();
            UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
            UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
            UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mEntitledProduct.put('Active__c', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
            List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise;Hosted Single Tenant;Hosted Multi Tenant;Perpetual');
            UtilityTestData.mtechnicalProductLine.put('Version__c', '9.2.1;9.2.2;9.2.4');
            UtilityTestData.mtechnicalProductLine.put('Component_SubComponent__c', 'Installation:Installation;Documentation:Documentation;ActiveVOS Console:Error~Permission;Performance:Job~Process performance;Hosted Application:Custom configuration~Product configuration~Logs~Others;Hosted Infrastructure:CPU~Memory~Disk~Others');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
            List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //create an Entitlement record
            sObj = new Entitlement();
            UtilityTestData.mEntitlement.put('AccountId',lNewCustomerAccount[0].Id);
            UtilityTestData.mEntitlement.put('Status','Active');
            UtilityTestData.mEntitlement.put('StartDate',system.today().addDays(-10)+'');
            UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
            List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Signature Success' and IsActive = true LIMIT 1];
            system.debug('@@lstEntitlementProcess= '+lstEntitlementProcess);
            if (lstEntitlementProcess.size()>0)
            {
                Entitlement updateEntitlementRec = new Entitlement();
                updateEntitlementRec.Id = lEntitlement[0].Id;
                updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
                update updateEntitlementRec;        
            } 
            List<BusinessHours> bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
            Test.startTest();
          
            
            
            List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
            
            
      Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
//UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'WW_Sales_EVP' limit 1];
// UserRole partnerRole = [SELECT Id FROM UserRole Where PortalType = 'Partner' limit 1];
List<user> lstUser = new List<user>();
/* UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
UtilityTestData.mUserData.put('Username','mtest@m.t');
UtilityTestData.mUserData.put('Email','mtest@m.t');
UtilityTestData.mUserData.put('Alias','alias');
UtilityTestData.mUserData.put('CommunityNickname','mtest');
UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
UtilityTestData.mUserData.put('LocaleSidKey','en_US');
UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
// UtilityTestData.mUserData.put('IsPortalEnabled','true');
UtilityTestData.mUserData.put('LastName','last');
UtilityTestData.mUserData.put('CompanyName','TEST');
UtilityTestData.mUserData.put('IsActive','true');
//UtilityTestData.mUserData.put('UserType','PowerPartner');
UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
sObject userSobj = new User();
userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
*/
UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
UtilityTestData.mUserData.put('Username','portalUsers@m.t');
UtilityTestData.mUserData.put('Email','portalUsers@m.t');
UtilityTestData.mUserData.put('Alias','alias');
UtilityTestData.mUserData.put('CommunityNickname','portalTest');
// UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
UtilityTestData.mUserData.put('LocaleSidKey','en_US');
UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
// UtilityTestData.mUserData.put('IsPortalEnabled','true');
UtilityTestData.mUserData.put('LastName','last');
UtilityTestData.mUserData.put('CompanyName','TEST');
UtilityTestData.mUserData.put('IsActive','true');
// UtilityTestData.mUserData.put('UserType','PowerPartner');
UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
UtilityTestData.mUserData.put('ContactId',contacts[0].Id +'');
// UtilityTestData.mUserData.put('UserRoleId',partnerRole.Id +'');
sObject partnerUser = new User();
partnerUser = UtilityTest.putFieldRecord(partnerUser, UtilityTestData.mUserData);
// lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj, partnerUser});
lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{partnerUser});
            
            String teamMemberRole = 'BDM';
            sObj = new AccountTeamMember();
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].id );
            UtilityTestData.mCase.put('TeamMemberRole', teamMemberRole );
            UtilityTestData.mCase.put('UserId', lstUser[0].id );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<AccountTeamMember> lstAccountTeamMember = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new ServiceResource();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
            sObj.put('RelatedRecordId', UserInfo.getUserId());
            sObj.put('name', 'Ask An Expert');
            sObj.put('isActive', true);
            List<ServiceResource> lServiceResources = (List<ServiceResource>)UtilityTest.makeInsert(new List<sObject>{sObj});
    
            Test.stopTest();
        }
    }
    
    
    static testmethod void checkAAEMonthlyLimitationTest(){
        Test.startTest();
        Account lNewSupportAccount = [Select Id,Name from Account where recordtypeid=:SupportAccountRecType Limit 1];
        
        List<ServiceAppointment>  saList= ScehdulerTestDataFactory.createServiceAppointments(lNewSupportAccount.ID,false,1);
        for(ServiceAppointment sa:saList){
            sa.appointmenttype='Ask_An_Expert'; 
            sa.Description  = 'test';
        }
        insert saList;
        boolean  hasLimitReached = esAskAnExpertFlowContainerController.checkAAEMonthlyLimitation(String.valueOf(lNewSupportAccount.Id));
        System.assert(hasLimitReached == false);
        Test.stopTest();
    }

    static testmethod void fetchAAEResourcesTest(){
        Test.startTest();
        Account lNewSupportAccount = [Select Id,Name from Account Limit 1];
        String lstResourceId = esAskAnExpertFlowContainerController.fetchAAEResources();
        System.assert(lstResourceId != null);
        Test.stopTest();
    }
    static testmethod void hasAccessCheckTest(){
        user partuser=[Select id from user where Username='portalUsers@m.t'];
        Test.startTest();
        Account lNewSupportAccount = [Select Id,Name from Account where recordtypeid=:SupportAccountRecType Limit 1];
        system.runAs(partuser){
            boolean hasAccess = esAskAnExpertFlowContainerController.hasAccessCheck(lNewSupportAccount.Id);
        }
        Test.stopTest();
    }
}