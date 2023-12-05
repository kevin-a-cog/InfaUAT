/***************************************************************************
*        Name        :        SupportAccountServiceTest
*        Date        :        2 Oct 2021
*        Description :        Test class for SupportAccountService
****************************************************************************
*/

@isTest
public class SupportAccountServiceTest {
    @testSetup
    static void setupObjectTestData() {
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id PartnerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Signature_Success__c', 'true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        SObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account2');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Signature_Success__c', 'false');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Partner Account123');
        UtilityTestData.mAccountData.put('RecordTypeId', PartnerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'India');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewPartnerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        UtilityTestData.mAccountData.put('Parent', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('Signature_Success__c',''+ true);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account2');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[1].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()-100+'');
        UtilityTestData.mAccountData.put('Parent', lNewCustomerAccount[1].Id);
        UtilityTestData.mAccountData.put('Signature_Success__c',''+ false);
        UtilityTestData.mAccountData.put('Support_Account_Type__c', 'Partner');
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
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
        
        //create an Entitlement record
        sObj = new Entitlement();
        UtilityTestData.mEntitlement.put('AccountId',lNewCustomerAccount[0].Id);
        UtilityTestData.mEntitlement.put('Status','Active');
        UtilityTestData.mEntitlement.put('StartDate',system.today()+'');
        UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
        List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        sObj = new Entitled_Product__c();
        UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
        UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
        UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
        UtilityTestData.mEntitledProduct.put('Active__c', 'True');
        UtilityTestData.mEntitledProduct.put('End_Date__c', System.today()+20+'');
        UtilityTestData.mEntitledProduct.put('Entitlement__c', lEntitlement[0].id);
        UtilityTestData.mEntitledProduct.put('Support_Level__c', 'Premium Success');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
        List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Entitled_Product__c();
        UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
        UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
        UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
        UtilityTestData.mEntitledProduct.put('Active__c', 'True');
        UtilityTestData.mEntitledProduct.put('End_Date__c', System.today()+20+'');
        UtilityTestData.mEntitledProduct.put('Entitlement__c', lEntitlement[0].id);
        UtilityTestData.mEntitledProduct.put('Support_Level__c', 'Signature Success');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
        List<Entitled_Product__c> lEntitledProduct1 = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Entitled_Product__c();
        UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[1].Id);
        UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
        UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
        UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
        UtilityTestData.mEntitledProduct.put('Active__c', 'True');
        UtilityTestData.mEntitledProduct.put('End_Date__c', System.today()+20+'');
        UtilityTestData.mEntitledProduct.put('Support_Level__c', 'Premium Success');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
        List<Entitled_Product__c> lEntitledProduct2 = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Entitlement();
        UtilityTestData.mEntitlement.put('AccountId',lNewSupportAccount[1].Id);
        UtilityTestData.mEntitlement.put('Status','Active');
        UtilityTestData.mEntitlement.put('Entitled_Product__c',lEntitledProduct2[0].Id);
        UtilityTestData.mEntitlement.put('StartDate',system.today()+'');
        UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
        List<Entitlement> lEntitlement1 = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Technical_Product_Line__c();
        UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
        UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
        UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise;Hosted Single Tenant;Hosted Multi Tenant');
        UtilityTestData.mtechnicalProductLine.put('Version__c', '9.2.1;9.2.2;9.2.4');
        UtilityTestData.mtechnicalProductLine.put('Component_SubComponent__c', 'Installation:Installation;Documentation:Documentation;ActiveVOS Console:Error~Permission;Performance:Job~Process performance;Hosted Application:Custom configuration~Product configuration~Logs~Others;Hosted Infrastructure:CPU~Memory~Disk~Others');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
        List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Org__c();
        UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
        List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new Service_Appointment__c();
        UtilityTestData.mServiceAppointment.put('Activity_Type__c', 'Apply EBF');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);
        List<Service_Appointment__c> serviceAppoinments = (List<Service_Appointment__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
         Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
       // Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
       // UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'WW_Sales_EVP' limit 1];
       // UserRole partnerRole = [SELECT Id FROM UserRole Where PortalType = 'Partner' limit 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        List<user> lstUser = new List<user>();
        /*UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
        UtilityTestData.mUserData.put('Username','mtest@m.t');
        UtilityTestData.mUserData.put('Email','mtest@m.t');
        UtilityTestData.mUserData.put('Alias','alias');
        UtilityTestData.mUserData.put('CommunityNickname','mtest');
        UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('IsPortalEnabled','true');         
        UtilityTestData.mUserData.put('LastName','last');
        UtilityTestData.mUserData.put('CompanyName','TEST');
        UtilityTestData.mUserData.put('IsActive','true');
        UtilityTestData.mUserData.put('UserType','PowerPartner');
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
        sObject userSobj = new User();
        userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData); 
            */
        UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        UtilityTestData.mUserData.put('Username','portalUsers@m.t');
        UtilityTestData.mUserData.put('Email','portalUsers@m.t');
        UtilityTestData.mUserData.put('Alias','alias');
        UtilityTestData.mUserData.put('CommunityNickname','portalTest');
        //UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
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
        lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{ partnerUser});
            String teamMemberRole = 'BDM';
        sObj = new AccountTeamMember();
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].id );
        UtilityTestData.mCase.put('TeamMemberRole', teamMemberRole );
        UtilityTestData.mCase.put('UserId', lstUser[0].id );
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<AccountTeamMember> lstAccountTeamMember = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }

        /*List<Certification_Request__c> lstCertificationRequests = new List<Certification_Request__c>();
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

        Certification_Request__c objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = lNewSupportAccount[0].Id;
        objCertificationRequest.Start_Date__c = System.today().addDays(1);
        objCertificationRequest.End_Date__c = System.today().addDays(20);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Approved';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);

        objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = lNewSupportAccount[0].Id;
        objCertificationRequest.Start_Date__c = System.today().addDays(1);
        objCertificationRequest.End_Date__c = System.today().addDays(30);
        objCertificationRequest.Request_Type__c = strRequestType;
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Approved';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        lstCertificationRequests.add(objCertificationRequest);
        insert lstCertificationRequests;*/
    }
    static testmethod void testSupportAccountService(){
        Test.startTest();
        Account CustAccount = [Select id ,parentId,recordtype.name from account where recordtype.name ='Customer Account' limit 1 ];
        Account SupportAccount = [Select id ,parentId,recordtype.name,Entitlement__c,Entitlement__r.StartDate,Max_Number_of_Cases_Allowed__c from account where recordtype.name ='Support Account' limit 1];
        SupportAccountService.supportAccountRollup(SupportAccount.Id);
        set<id> setid=new set<id>();
        List<Account> lstacc=new List<Account>();
        lstacc.add(SupportAccount);
        setid.add(SupportAccount.Id);
        SupportAccountService.updateSupportAccountsFuture(setid);
        SupportAccountService.upsertPartnerSupportAccountsFuture(setid);
        SupportAccountService.updateSupportAccountBasicPack(lstacc);
        Test.stopTest();
    }
    static testmethod void testSupportAccountServiceSigFalse(){
        Test.startTest();
        Account SupportAccount = [Select id ,parentId,recordtype.name,Entitlement__c,Entitlement__r.StartDate,Max_Number_of_Cases_Allowed__c from account where name ='Test Support Account2' limit 1];
        set<id> setid=new set<id>();
        setid.add(SupportAccount.Id);
        SupportAccountService.updateSupportAccountsFuture(setid);
        Test.stopTest();
    }
    static testmethod void testSupportAccountServicePartnerAccount(){
        Test.startTest();
        List<Account> partnerAccLst = [Select Id,Partner_Support_Entitlement__c,Partner_Support_End_Date__c from Account where recordtype.name='Partner Account'];
        partnerAccLst[0].Partner_Support_Entitlement__c = 'Premium Success';
        partnerAccLst[0].Partner_Support_End_Date__c = system.today().addDays(2);
        update partnerAccLst;
        SupportAccountService.upsertPartnerSupportAccounts(new Set<Id>{partnerAccLst[0].Id});
        partnerAccLst[0].Partner_Support_End_Date__c = System.today();
        update partnerAccLst;
        SupportAccountService.upsertPartnerSupportAccounts(new Set<Id>{partnerAccLst[0].Id});
        partnerAccLst[0].Partner_Support_End_Date__c = System.today().addDays(4);
        update partnerAccLst;
        SupportAccountService.upsertPartnerSupportAccounts(new Set<Id>{partnerAccLst[0].Id});
        Test.stopTest();
    }
    static testmethod void testUpsertPartnerSupportAccounts(){
        Test.startTest();
        List<Account> partnerAccLst = [Select Id,Partner_Support_Entitlement__c,Partner_Support_End_Date__c from Account where recordtype.name='Partner Account'];
        Account SupportAccount = [Select id ,parentId,recordtype.name,Entitlement__c,Entitlement__r.StartDate,Max_Number_of_Cases_Allowed__c from account where name ='Test Support Account2' limit 1];
        set<id> setid=new set<id>();
        setid.add(partnerAccLst[0].Id);
        SupportAccount.ParentId=partnerAccLst[0].Id;
        update SupportAccount;
        SupportAccountService.upsertPartnerSupportAccountsFuture(setid);
        Test.stopTest();
    }
    public static String CRON_EXP = '0 00 * * * ?';
     static testmethod void SupportAccountUpdateBatchSchedulableTest(){
        Test.startTest();
        String query = 'SELECT Id,Max_Number_of_Cases_Allowed__c,Success_Offering__c,Entitlement__c,Entitlement__r.StartDate,Entitlement__r.Enddate from Account';
        String jobId = System.schedule('testBasicScheduledApex',CRON_EXP,new SupportAccountUpdateBatchSchedulable());
        Test.stopTest();
     }
}