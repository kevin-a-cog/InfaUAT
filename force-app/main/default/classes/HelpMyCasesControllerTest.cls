@isTest
public class HelpMyCasesControllerTest {
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    
    @testSetup
    public static void dataSetup(){
        try{
            Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};              
                System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                    SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
                    CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
                    technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();                    
                    
                    SObject sObj = new Account();
                    UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
                    UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
                    UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                    UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');
                    UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
                    
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                    List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});                    
                    
                    sObj = new Account();
                    UtilityTestData.mAccountData.put('Name', 'Test Support Account');
                    UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
                    UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
                    UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                    UtilityTestData.mAccountData.put('Active__c', 'true');
                    UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                    List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    
                    sObj = new Contact();
                    UtilityTestData.mContactData.put('AccountId',lNewSupportAccount[0].id);
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
                    UtilityTestData.mAccContactRelation.put('favorite__c','true');
                    UtilityTestData.mAccContactRelation.put('Access_Level__c','Read/Write');
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
                    //List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    
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
                    TimeZone tz = UserInfo.getTimeZone();
                    sObj = new Case();
                    UtilityTestData.mCase.put('Subject', 'Test technical Case');
                    UtilityTestData.mCase.put('status', 'New');
                    UtilityTestData.mCase.put('Priority', 'p3');
                    UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
                    UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
                    UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
                    UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
                    UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
                    UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
                    UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
                    UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
                    UtilityTestData.mCase.put('slaStartDate ', system.now()+'');  
                    //  UtilityTestData.mCase.put('Case_Timezone_Name__c ', bussinessHourList[0].Id); 
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
                    List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    
                    sObj = new Case_Contact__c();
                    UtilityTestData.mCaseContact.put('Contact__c', contacts[0].id );
                    UtilityTestData.mCaseContact.put('Email__c', 'test@testdeployment.com');
                    UtilityTestData.mCaseContact.put('Case__c', cases[0].id );
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
                    List<Case_Contact__c> Case_Contact = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    
                    sObj = new Org__c();
                    UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
                    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
                    List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
                    List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
                    
                    //Customer Community Plus Login User Profile
                    //  Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
                    Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
                    
                    List<user> lstUser = new List<user>();
                    UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
                    UtilityTestData.mUserData.put('Username','portalUsers@m.t');
                    UtilityTestData.mUserData.put('Email','portalUsers@m.t');
                    UtilityTestData.mUserData.put('Alias','alias');
                    UtilityTestData.mUserData.put('CommunityNickname','portalTest');
                    //  UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
                    UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
                    UtilityTestData.mUserData.put('LocaleSidKey','en_US');
                    UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
                    UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
                    //    UtilityTestData.mUserData.put('IsPortalEnabled','true');         
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
                    
                }
        } catch(Exception e){
            System.debug('Error - '+e.getStackTraceString());
        }  
    }
    
    @isTest
    public static void getSupportAccountInfoByContactTest(){
        Set<Id> accountIdsSet = new Set<Id>();
        for(Account acc : [select id from Account where RecordTypeId = :SupportAccountRecType]){
            accountIdsSet.add(acc.Id);
        }
        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            List<Case> caseList = new List<Case>();
            HelpMyCasesController.UserAccountInfo info = new HelpMyCasesController.UserAccountInfo();
            info.allOpenCases = caseList;
            
            System.runAs(user2){
                HelpMyCasesController.getSupportAccountInfoByContact(user2.ContactId,5);
                HelpMyCasesController.getSupportAccountInfo(accountIdsSet,5);
                HelpMyCasesController.getSupportAccWithRWAccess(); 
            }
        }
    }
        
    }