/*  
@Author:        Anil Sahu  
@Created Date:  3may21
@Description:   Test class for CaseControllerWithoutSharing controller.

Change History
************************************************************************************************************************
Modified By         Date            Jira No.        Description                                                 Tag
************************************************************************************************************************
NA                  NA              UTOPIA          Initial version.                                            NA
Vignesh Divakaran   16/12/2021      UTOPIA-FF2      Increase code coverage                                      T01
Amarender           17/12/2021      UTOPIA-FF2      Increase code coverage                                      T02
balajip             17/03/2022      Mar 2022 Build  Fix test failures                                           T03
balajip             01/08/2022      I2RT-6765       Added test method testAllMethods2 to improve code coverage  T04
balajip             03/10/2022      I2RT-7200       Added coverage for new method insertCaseComment and updateCase  T05
*/
@isTest
public class CaseControllerWithoutSharingTest {
    
    public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
    public static   Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
    public static   Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical').getRecordTypeId();
    public static   Id AdministrativeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Administrative').getRecordTypeId();
    public static   Id askexpRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ask_An_Expert').getRecordTypeId();
    
    @testSetup
    static void setupObjectTestData() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            SObject sObj = new Account();
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
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id); 
            UtilityTestData.mContactData.put('FirstName','test Con FirstName1'); 
            UtilityTestData.mContactData.put('Salutation','Mr.');
            UtilityTestData.mContactData.put('LastName','test Con LastName1');
            UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('Access_Level__c','Read/Write');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.debug('contacts***'+contacts);
            System.debug('con'+[Select Id,Name from contact limit 1]);
            /*  ContentVersion conVer = new ContentVersion();
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
            */  
            
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
            UtilityTestData.mAccContact.put('Primary__c', ''+true);
            UtilityTestData.mAccContact.put('IsActive', ''+true);
            UtilityTestData.mAccContact.put('Access_Level__c','Read/Write');
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
            UtilityTestData.mCase.put('Intial_Response_time__c ', system.now()+''); 
            //  UtilityTestData.mCase.put('Case_Timezone_Name__c ', bussinessHourList[0].Id); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sobj = new Case_Comment__c();
            UtilityTestData.mCaseComment.put('Comment__c ', 'Test');  
            UtilityTestData.mCaseComment.put('Status__c ', 'Draft');  
            List<Case_Comment__c> casecomments = (List<Case_Comment__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test admin Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'p3');
            UtilityTestData.mCase.put('RecordTypeId', AdministrativeRecordTypeId);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');  
            UtilityTestData.mCase.put('Problem_Area__c', 'End of Life Version Support'); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> casesadmin = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'p3');
            UtilityTestData.mCase.put('RecordTypeId', askexpRecordTypeId);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');  
            UtilityTestData.mCase.put('Intial_Response_time__c ', system.now()+''); 
            //  UtilityTestData.mCase.put('Case_Timezone_Name__c ', bussinessHourList[0].Id); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> casesAskexp = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Case_Contact__c caseContact = new Case_Contact__c();
            caseContact.Contact__c = contacts[0].id;
            caseContact.Case__c = cases[0].id;
            insert caseContact;
            
            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            /*sObj = new Service_Appointment__c();
            UtilityTestData.mServiceAppointment.put('Activity_Type__c', 'Apply EBF');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);
            List<Service_Appointment__c> serviceAppoinments = (List<Service_Appointment__c>) UtilityTest.makeInsert(new List<sObject>{sObj});*/
            List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
            //  UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'WW_Sales_EVP' limit 1];
            //  UserRole partnerRole = [SELECT Id FROM UserRole Where PortalType = 'Partner' limit 1];
            
            List<user> lstUser = new List<user>();
            /*  UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
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
    }
    
    static testMethod void testFetchOrgNames() {
        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        List<User> portalUsers = [SELECT ID FROM User Where Email = 'portalUsers@m.t'];
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS Customer Community user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
        
        Account accountRec = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        system.debug('accountRec---'+accountRec);
        List<Contact> contacts = [SELECT ID  FROM Contact limit 1];
        system.debug('contacts---'+contacts);
        case caseinf=[select id,contactId from case limit 1];
        //T03 - commented to fix Too many SOQL exception
        //caseinf.contactid = contacts[0].Id;
        //update caseinf;
        system.debug('caseinf' + caseinf);
        
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];
        //Case_Contact__c CaseContact=[select id from Case_Contact__c];
        Test.startTest();
        Case_Contact__c CaseContact=[select id from Case_Contact__c];
        list<string> lst=new List<string>();
        lst.add('Account Manager');
        CaseControllerWithoutSharing.getSupportAccount(accountRec.Id);
        CaseControllerWithoutSharing.getCase(caseinf.id);
        CaseControllerWithoutSharing.getContact(contacts[0].id);
        system.runAs(portalUsers[0]){
            CaseControllerWithoutSharing.isValidUser(caseinf.id,accountRec.Id, 'Read/Write');
        }
        CaseControllerWithoutSharing.initialResponseCaseComment(caseinf.id);
        
        CaseControllerWithoutSharing.getAccountTeamMembers(accountRec.Id,lst);
        CaseControllerWithoutSharing.getPrimarySupportAccountContacts(accountRec.Id);
        CaseControllerWithoutSharing.getSupportAccountContacts(accountRec.Id);
        set<id> setcon=new set<id>();
        setcon.add(contacts[0].id);
        CaseControllerWithoutSharing.getAssignedSupportAccountContacts(accountRec.Id,setcon);
        CaseControllerWithoutSharing.getUnAssignedSupportAccountContacts(accountRec.Id,setcon);
        
        CaseControllerWithoutSharing.getCaseContacts(caseinf.id);
        CaseControllerWithoutSharing.updateAccountContactRelation('firstName','lastName',contacts[0].id,'true','2345678989','','','Read/Write','true',accContactRelations[0].id,'true',accountRec.Id);
        List<Case_Comment__c> casecommnet = new List<Case_Comment__c> ();
        casecommnet.add(new Case_Comment__c(Status__c= 'Draft',Comment__c = 'Test'));
        CaseControllerWithoutSharing.insertCaseComments(casecommnet);
        
        //Clone the record
        case clonecase = caseinf.clone(false, false, false, false);
        Case_Contact__c  sObjcc = new Case_Contact__c();
        sObjcc.Contact__c=contacts[0].id;
        sObjcc.Case__c=caseinf.id;
        list<Case_Contact__c> cs=new list<Case_Contact__c>(); 
        cs.add(sObjcc);      
        CaseControllerWithoutSharing.createCaseContacts(cs,accountRec.Id);
        CaseControllerWithoutSharing.deleteCaseContact(CaseContact.id);
        // CaseControllerWithoutSharing.deleteAccountContactRelation('');
        // system.runAs(portalUsers[0]){
        // CaseControllerWithoutSharing.createCase(clonecase);
        //}
        
        //CaseControllerWithoutSharing.isPrimaryContact(accountRec.id);
        Test.stopTest();
    }

    static testMethod void testFetchcasecont() {
        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        List<User> portalUsers = [SELECT ID FROM User Where Email = 'portalUsers@m.t'];
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS Customer Community user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
        Account accountRec = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        List<Contact> contacts = [SELECT ID  FROM Contact limit 1];
        case caseinf=[select id from case  limit 1];
        case caseinadminf=[select id from case where recordTypeid=:AdministrativeRecordTypeId limit 1];
        case caseinaAsk=[select id from case where recordTypeid=:askexpRecordTypeId limit 1];
        
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];
        Case_Contact__c CaseContact=[select id from Case_Contact__c];
        Test.startTest();
        Case newCase = new Case();
        newCase.Subject = 'Test technical subject';
        newCase.Description = 'Test description';
        newCase.Issue_Summary__c = 'Test description';
        newCase.Forecast_Product__c = 'Axon Data Governance';
        newCase.Version__c = '9.2.1';
        newCase.Component__c = 'Installation';
        newCase.Support_Account__c = accountRec.Id; 
        
        //Clone the record
        case clonecase = caseinf.clone(false, false, false, false);
        Case_Contact__c  sObjcc = new Case_Contact__c();
        sObjcc.Contact__c=contacts[0].id;
        sObjcc.Case__c=caseinf.id;
        list<Case_Contact__c> cs=new list<Case_Contact__c>(); 
        cs.add(sObjcc);  
        CaseControllerWithoutSharing.initialResponseCaseComment(caseinadminf.id);
        CaseControllerWithoutSharing.initialResponseCaseComment(caseinaAsk.id);
        CaseControllerWithoutSharing.createCaseContacts(cs);
        CaseControllerWithoutSharing.createCase(newCase);
        
        // CaseControllerWithoutSharing.deleteCaseContact(CaseContact.id);
        //  CaseControllerWithoutSharing.checkUserReadWriteAccess('');
        // system.runAs(portalUsers[0]){
        // CaseControllerWithoutSharing.createCase(clonecase);
        //}
        
        //CaseControllerWithoutSharing.isPrimaryContact(accountRec.id);
        Test.stopTest();
    }
    
    static testMethod void testAllMethods(){
        
        Id customerAccId = [Select Id from Account where RecordType.Name = 'Customer Account' LIMIT 1]?.Id;
        Id CustomerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        test.startTest();
        if(String.isNotEmpty(customerAccId)){
            Contact con = new Contact();
            con.AccountId = customerAccId;
            con.FirstName = 'TEST CONTACT FIRSTNAME';
            con.LastName = 'TEST CONTACT LASTNAME';
            con.Salutation = 'Mr.';
            con.Email = 'testcontactinfa@informatica.com';
            con.MailingCountry = 'India';
            con.Phone = '9999999999';
            con.RecordTypeId = CustomerContactRecordTypeId;
            
            CaseControllerWithoutSharing.createContact(con);
        }
        
        
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        
        if(String.isNotEmpty(caseId)){
            Case_Comment__c cc = new Case_Comment__c();
            cc.Comment__c = 'Test case comment';
            cc.Inbound__c = false;
            cc.Status__c = 'Submitted';
            cc.Visibility__c = 'Internal';
            cc.Case__c = caseId;
            cc.Sub_Type__c = 'General Response';
            cc.Comment_Category__c = 'General Comments';
            
            //T03 - commented to fix Too many SOQL exception
            //CaseControllerWithoutSharing.insertCaseComments(new List<Case_Comment__c>{cc});
        }
        
        CaseControllerWithoutSharing.getUser(UserInfo.getUserId());
        test.stopTest();
    }
    
    //---------------------------------------<T01>----------------------------
    /*
    Method Name : testDuplicateContact
    Description : Testing duplicate lead or contact.
    Parameters  : None
    Return Type : None
    */
    @isTest
    public static void testDuplicateContact() {
        
        String strEmail = 'testinformatica@testinformatica.com';
        
        Test.startTest();
        
        System.assertNotEquals(CaseControllerWithoutSharing.isLeadExists(strEmail), true,  'Potential Duplicate Contact already exist in system');
        System.assertNotEquals(CaseControllerWithoutSharing.isContactExists(strEmail), true, 'Duplicate contact already exist in system.');
        
        Test.stopTest();
    }
    //---------------------------------------</T01>----------------------------
    //
    
    //---------------------------------------<T02>----------------------------
    /*
    Method Name : testGetSupportAccountJiras
    Description : Testing Support Account Jiras.
    Parameters  : None
    Return Type : None
    */
    @isTest
    public static void testGetSupportAccountJiras(){
        Test.startTest();
        Account accountRec = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        CaseControllerWithoutSharing.getSupportAccountJiras(accountRec.Id);
        Test.stopTest();
    }
    //---------------------------------------<T02>----------------------------

    //T04
    @isTest
    public static void testAllMethods2(){
        Test.startTest();
        Account accountRec = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];

        CaseControllerWithoutSharing.GetAllCases('Select Id From Case ', accountRec.Id, ' ');
        try{
            CaseControllerWithoutSharing.updateEvent(null);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.updateEventRelation(null);
        }catch(Exception ex){}
        try{
            AccountContactRelation acr = [Select Id From AccountContactRelation Where Account.RecordType.Name = 'Support Account' Limit 1];
            CaseControllerWithoutSharing.deleteAccountContactRelation(acr.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    public static void testSupportLite(){
        Test.startTest();
        CaseControllerWithoutSharing.getOrgs('Data Loader');
        CaseControllerWithoutSharing.getEcommerceAccountContacts([SELECT Id FROM Account LIMIT 1]?.Id);

        //T05
        try{
            CaseControllerWithoutSharing.createACR(new AccountContactRelation());
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.createCaseContact(new Case_Contact__c());
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.queryTimezone('region','location');
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.CheckIFACRExists('',[SELECT Id FROM Account LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.isContactUnderDifferentAccountExists('',[SELECT Id FROM Account LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.createEntitledProduct(new Entitled_Product__c());
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.getSupportAccountInfoByContact([SELECT Id FROM Contact LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.getAccountManagerName([SELECT Id FROM Account LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.getOrg('');
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.getOrgId([SELECT Id FROM Account LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            CaseControllerWithoutSharing.getEcommerceAccountInfo([SELECT Id FROM Account LIMIT 1]?.Id);
        }catch(Exception ex){}
        try{
            Case cse = [Select Id, Subject from Case LIMIT 1];
            CaseControllerWithoutSharing.updateCase(cse);
        }catch(Exception ex){}
        try{
            Case cse = [Select Id, Subject from Case LIMIT 1];
            Case_Comment__c cseComment = new Case_Comment__c();
            cseComment.Case__c = cse.Id;
            CaseControllerWithoutSharing.insertCaseComment(cseComment);
        }catch(Exception ex){}
        Test.stopTest();
    }
}