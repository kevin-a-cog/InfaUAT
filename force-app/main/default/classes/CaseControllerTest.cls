/*
@created by       : JakinP
@created on       : 03/03/2020
@Purpose          : Test class for CaseController.
@JIRA             : 
Change History
***********************************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
***********************************************************************************************************************
Pavithra V      27-09-2021                      To increase test class coverage
balajip         21-06-2021  I2RT-6487   T01     re-wrote the whole test class to fix failures and improve code coverag.
Vignesh D		25-07-2022	I2RT-6593	T02		Increase code coverage.
balajip         01/24/23    I2RT-7224   T03   	Removed the calls to unused methods (getReportInfo, caseCommentonDeletion, updateCaseContacts, getOGRDate, createCaseContactRecord, fetchExistingServiceAppointment)
*/

@isTest
public class CaseControllerTest {
    
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    
    @testSetup
    static void setupObjectTestData() {
        try{            
            SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
            CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
            
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');
            
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
            UtilityTestData.mContactData.put('LastName','test Con LastName1');
            UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            SObject sObj1 = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id);
            UtilityTestData.mContactData.put('FirstName','TEST CONTACT FIRSTNAME');
            UtilityTestData.mContactData.put('LastName','TEST CONTACT LASTNAME');
            UtilityTestData.mContactData.put('Email','testcontact@gmail.com');
            UtilityTestData.mContactData.put('Phone','1234567890');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            ContentVersion objContent = new ContentVersion(); 
            objContent.Title = 'Test';
            objContent.PathOnClient = '/' + objContent.Title + '.jpg'; 
            objContent.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
            objContent.Origin = 'H';
            insert objContent;
            ContentDocumentLink objContentLink = new ContentDocumentLink();
            objContentLink.LinkedEntityId = contacts[0].Id;
            objContentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContent.id].ContentDocumentId;
            objContentLink.ShareType = 'I';
            objContentLink.Visibility = 'AllUsers'; 
            insert objContentLink;
            
            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
            UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
            UtilityTestData.mAccContactRelation.put('IsActive','true');
            UtilityTestData.mAccContactRelation.put('favorite__c','true');
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
            UtilityTestData.mEntitledProduct.put('End_Date__c', System.today()+2+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
            List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise;Hosted Single Tenant;Hosted Multi Tenant;Perpetual');
            UtilityTestData.mtechnicalProductLine.put('Version__c', '9.2.1;9.2.2;9.2.4');
            UtilityTestData.mtechnicalProductLine.put('status__c', 'Active');
            UtilityTestData.mtechnicalProductLine.put('Component_SubComponent__c', 'Installation:Installation;Documentation:Documentation;ActiveVOS Console:Error~Permission;Performance:Job~Process performance;Hosted Application:Custom configuration~Product configuration~Logs~Others;Hosted Infrastructure:CPU~Memory~Disk~Others');
            UtilityTestData.mtechnicalProductLine.put('Problem_Type__c', 'Services');
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

            /*sObj = new Service_Appointment__c();
            UtilityTestData.mServiceAppointment.put('Activity_Type__c', 'Apply EBF');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);
            List<Service_Appointment__c> serviceAppoinments = (List<Service_Appointment__c>) UtilityTest.makeInsert(new List<sObject>{sObj});*/

            SObject tzObj = new Timezone__c();
            UtilityTestData.mTimezone.put('Name','GMT–07:00 Pacific Daylight Time (America/Los_Angeles)');
            UtilityTestData.mTimezone.put('TimeZone__c','GMT–07:00 Pacific Daylight Time (America/Los_Angeles)');
            tzObj = UtilityTest.putFieldRecord(tzObj, UtilityTestData.mTimezone);

            SObject tzObj1 = new Timezone__c();
            UtilityTestData.mTimezone.put('Name','GMT+05:30 India Standard Time (Asia/Kolkata)');
            UtilityTestData.mTimezone.put('Timezone__c','GMT+05:30 India Standard Time (Asia/Kolkata)');
            tzObj1 = UtilityTest.putFieldRecord(tzObj1, UtilityTestData.mTimezone);
            List<Timezone__c> lTimezone = (List<Timezone__c>) UtilityTest.makeInsert(new List<sObject>{tzObj,tzObj1});

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
            // UtilityTestData.mCase.put('Service_Appointment_AAE__c ', serviceAppoinments[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');  
            //  UtilityTestData.mCase.put('Case_Timezone_Name__c ', bussinessHourList[0].Id); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            /*sObj = new Case_Contact__c();
            UtilityTestData.mCaseContact.put('Contact__c', contacts[0].id );
            UtilityTestData.mCaseContact.put('Email__c', 'test@testdeployment.com');
            UtilityTestData.mCaseContact.put('Case__c', cases[0].id );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case_Contact__c> Case_Contact = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{sObj});*/
            
            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
            
            //Customer Community Plus Login User Profile
            //  Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
            //UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'WW_Sales_EVP' limit 1];
            // UserRole partnerRole = [SELECT Id FROM UserRole Where PortalType = 'Partner' limit 1];
            
            List<user> lstUser = new List<user>();
            UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
            UtilityTestData.mUserData.put('Username','mtest@m.t');
            UtilityTestData.mUserData.put('Email','mtest@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest');
            //UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
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
            UtilityTest.makeInsert(new List<sObject>{userSobj});

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
        } catch(Exception e){
            System.debug('Error - '+e);
        }    
    }

    @isTest
    static void testAsPortalUser1(){
        List<User> portalUsers = [SELECT ID FROM User Where Username = 'portalUsers@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        contact cont=[select id from contact limit 1];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];

        Test.startTest();
        system.runAs(portalUsers[0]){
            CaseController  obj=new CaseController();           
            try{
                CaseController.completemilestone(newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.getSupportContactDetails(newCaseInfo.Id,acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getServiceCloudMetadata('');
            }catch(Exception ex){}
            try{
                CaseController.getCaseResolution();
            }catch(Exception ex){}
            try{
                CaseController.checkIRCompletion(newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.closeCaseRequest(newCaseInfo.Id,'test na');
            }catch(Exception ex){}
            try{
                CaseController.getTableauDashboardLinks('Tableau_Dashboards');
            }catch(Exception ex){}
            try{
                CaseController.allDataForDownloadForm();
            }catch(Exception ex){}
            try{
                CaseController.getcasesToDownload('', 'New', '','','', '',acc.id, '' );
                CaseController.getcasesToDownload('', 'New', 'P1', 'Technical','20220101', '20251231',acc.id, '23424234' );
            }catch(Exception ex){}
            try{
                CaseController.CancelAaeAppointmentHandler(newCaseInfo.Id,'test');
            }catch(Exception ex){}
            try{
                CaseController.getQuickActionLink(newCaseInfo.Id,'TSFTP');
                CaseController.getQuickActionLink(newCaseInfo.Id,'Cassini');
                CaseController.getQuickActionLink(newCaseInfo.Id,'South Deep');
            }catch(Exception ex){}
            try{
                CaseController.allSupportAccounts();
            }catch(Exception ex){}
            try{
                CaseController.allSupportAccountswrp();
            }catch(Exception ex){}
            try{                    
                CaseController.removeCurrentFiles();
            }catch(Exception ex){}
            try{
                CaseController.getCaseFieldsDropdownOptions();
            }catch(Exception ex){}
            try{
                CaseController.getCaseDetails(newCaseInfo.Id);
            }catch(Exception ex){}
                try{
                CaseController.getCaseAccess(newCaseInfo.Id, '');
            }catch(Exception ex){}
            try{
                CaseController.getLiveAssistVisibility(newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.confirmLiveAssistReason(newCaseInfo.Id,'test reason');
            }catch(Exception ex){}
            try{
                CaseController.getESupportMetadataId();
            }catch(Exception ex){}
            try{
                CaseController.getCaseCreatedCount_S1(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getCaseCreatedCount_S2(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getUploadedFiles();
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void testAsPortalUser2(){
        List<User> portalUsers = [SELECT ID FROM User Where Username = 'portalUsers@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        contact cont=[select id from contact limit 1];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];

        Test.startTest();
        system.runAs(portalUsers[0]){
            try{
                CaseController.getSupportAccountInfo(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getAccountTeamMembers(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.reOpenCase(newCaseInfo.Id,'ntvalid data');
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void testAsPortalUser3(){
        List<User> portalUsers = [SELECT ID FROM User Where Username = 'portalUsers@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        contact cont=[select id from contact limit 1];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];

        Test.startTest();
        system.runAs(portalUsers[0]){
            try{
                CaseController.getResponseTime(newCaseInfo.Id,'Callback');
            }catch(Exception ex){}
            try{
                CaseController.getAcceptedFileFormates();
            }catch(Exception ex){}
            try{
                CaseController.getAllProducts(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getAllProductsinternal();
            }catch(Exception ex){}
            try{
                CaseController.getProducts(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getAccountRelatedContacts(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getVersionforSelectedProduct('Axon Data Governance');
            }catch(Exception ex){}
            try{
                CaseController.getOrgIds('Axon Data Governance(Hosted Multi Tenant)',acc.id);
            }catch(Exception ex){}
            try{
                CaseController.calculateeOGRinMins(System.now(),newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.updateNextAction(newCaseInfo.Id,'Case Owner',true );
            }catch(Exception ex){}
            try{
                CaseController.seteOGRVisibility(newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.updateeOGR(newCaseInfo.Id ,270);    
            }catch(Exception ex){}
            try{
                CaseController.updateAccountContactRel(accContactRelations[0].id);   
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void testCaseCreation(){
        List<User> portalUsers = [SELECT ID FROM User Where Username = 'portalUsers@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        List<contact> cont=[select id from contact];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];
		AccountContactRelation objAccountContactRelation = new AccountContactRelation();
        objAccountContactRelation.ContactId = cont[1].Id;
		objAccountContactRelation.Primary__c = false;
        
        Test.startTest();
        system.runAs(portalUsers[0]){
            try{
                String caseJSON = '{"Priority":"P1","Support_Account__c":"' + acc.Id + '","Subject":"test 123","Description":"test 123","Error_Message__c":"test 123","Is_AssignmentRules__c":true,"Version__c":"9.2.4","Forecast_Product__c":"Axon Data Governance","Is_Internal_Or_External_Case__c":"External","AccountId":"' + acc.ParentId + '","EntitlementId":null,"Case_Support_Add_On__c":null,"Success_Offering__c":null,"ContactId":"' + cont[0].Id + '","Origin":"SFDC","Next_Action__c":"Case Owner","Org_ID__c":"TEST_ORG","Component__c":"Installation","Subcomponent__c":"Installation","Problem_Type__c":"Services","Secure_Agent__c":"TEST_SECURE_AGENT","Activity_Type__c":"Report an issue or for any queries"}';
                String strCaseId = CaseController.createCase(caseJSON, 'Technical', new List<AccountContactRelation>{objAccountContactRelation}, new List<Case_Contact__c>(), 'UAT', new List<DateTime>(), new List<String>{'Axon Data Governance','On Premise',''},'');
            	CaseController.reOpenCase(strCaseId,'Test Reopen');
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void testCaseCreation2(){
        List<User> CurrentUsers = [SELECT ID FROM User Where Email = 'mtest@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Engineer', 'GCS_Manager2','GCS_Administration')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = CurrentUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
        
        Account accountRec = [SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        
        List<Contact> contacts = [SELECT ID  FROM Contact];
        List<Case> cases = [SELECT ID  FROM Case];
        AccountContactRelation objAccountContactRelation = new AccountContactRelation();
        objAccountContactRelation.ContactId = contacts[1].Id;
		objAccountContactRelation.Primary__c = false;        

        Test.startTest();
        system.runAs(CurrentUsers[0]){
            
            String caseJSON = '{"Priority":"P1","Support_Account__c":"' + accountRec.Id + '","Subject":"test 123","Description":"test 123","Error_Message__c":"test 123","Is_AssignmentRules__c":true,"Version__c":"9.2.4","Forecast_Product__c":"Axon Data Governance","Is_Internal_Or_External_Case__c":"External","AccountId":"' + accountRec.ParentId + '","EntitlementId":null,"Case_Support_Add_On__c":null,"Success_Offering__c":null,"ContactId":"' + contacts[0].Id + '","Origin":"SFDC","Next_Action__c":"Case Owner"}';
            //CaseController.createCase(caseJSON, 'Technical', new List<AccountContactRelation>{objAccountContactRelation}, 'UAT', new List<DateTime>(), new List<String>{'Axon Data Governance','On Premise',''},'');
        	CaseController.createCaseGCS(caseJSON, 'Technical', 'Customer 360(Hosted Multi Tenant)', 'UAT', null);
        }    
        Test.stopTest();    
    }

    @isTest
    static void testAsInternalUser1(){
        List<User> CurrentUsers = [SELECT ID FROM User Where Email = 'mtest@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Engineer', 'GCS_Manager2','GCS_Administration')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = CurrentUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
        
        Account accountRec = [SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        
        List<Contact> contacts = [SELECT ID  FROM Contact];
        List<Case> cases = [SELECT ID, Problem_Statement__c, Closing_Notes__c, Contact.INFA_Language__c FROM Case];

        Test.startTest();
        system.runAs(CurrentUsers[0]){

            List<Technical_Product_Line__c> technicalProducts =[SELECT Id,Name,Version__c,Component_SubComponent__c FROM Technical_Product_Line__c];

            try{
                CaseController.getComponentForSelectedProduct(technicalProducts[0].Name);
                Technical_Product_Line__c techProductUpdate = new Technical_Product_Line__c();
                techProductUpdate.Id = technicalProducts[0].Id;
                techProductUpdate.Component_SubComponent__c ='Installation:Installation';
                update techProductUpdate;
                CaseController.getComponentForSelectedProduct(technicalProducts[0].Name);    
            }catch(Exception ex){}

            try{
                CaseController.getCoOwners(cases[0].Id);
            }catch(Exception ex){}
            try{
                CaseController.switchOwner(cases[0].Id, UserInfo.getUserId());
            }catch(Exception ex){}
            try{
                CaseController.getSupportAccountDetails(accountRec.Id);
            }catch(Exception ex){}
            try{
                CaseController.getDelMethodsForSelectedProduct('Axon Data Governance(Hosted Multi Tenant');
            }catch(Exception ex){}
            try{
                CaseController.createCaseComment(cases[0].Id);
            }catch(Exception ex){}
            try{
                CaseController.getCaseClosureComment(cases[0]);
            }catch(Exception ex){}
            try{
                CaseController.CaseQualityResponseWrapper wrapper = new CaseController.CaseQualityResponseWrapper();
                wrapper.ActionTaken = '';
                wrapper.IncidentTime = '';
                wrapper.DescriptionQualityColor = '';
                wrapper.ActionTakenExample = '';
                wrapper.ProblemSymptom = '';
                wrapper.ErrorMessage = '';
                wrapper.ErrorMessageExample = '';
                wrapper.IncidentTimeExample = '';
                wrapper.AdditionalDetails = '';
                wrapper.ProblemSymptomExample = '';
                wrapper.ComponentExample = '';
                wrapper.Component = '';
                wrapper.DescriptionQualityScore = '';
                wrapper.AdditionalDetailsExample = '';

                CaseController.CaseRecommendationResponseWrapper wrapper2 = new CaseController.CaseRecommendationResponseWrapper();
                wrapper2.kbUrl = '';
                wrapper2.kbHtmlText = '';

                CaseController.AccountMembersWrapper wrapper3 = new CaseController.AccountMembersWrapper();
                wrapper3.strRoleName = '';
                wrapper3.accountMembers = new List<AccountTeamMember>();
            }catch(Exception ex){}
        }
        Test.stopTest();    
    }
    
    @isTest
    static void testAsInternalUser2(){
        List<User> CurrentUsers = [SELECT ID FROM User Where Email = 'mtest@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS Customer Community user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = CurrentUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        contact cont=[select id from contact limit 1];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];

        Test.startTest();
        system.runAs(CurrentUsers[0]){
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = 'testing2.txt';
            conVer.Title = 'Sample article file';
            conVer.VersionData = EncodingUtil.base64Decode('file content');
            insert conVer;

            ContentVersion  contentVersion = [SELECT ContentDocumentId FROM ContentVersion Limit 1 ] ;
            try{            
                CaseController.getProducts(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getAllProducts(acc.id);
            }catch(Exception ex){}
            try{
                CaseController.getAllProductsinternal();
            }catch(Exception ex){}
            try{            
                CaseController.removeFile(contentVersion.ContentDocumentId,newCaseInfo.Id );
            }catch(Exception ex){}
            try{
                ContentVersion objContent = new ContentVersion(); 
                objContent.Title = 'Test';
                objContent.PathOnClient = '/' + objContent.Title + '.jpg'; 
                objContent.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
                objContent.Origin = 'H';
                insert objContent;
                ContentDocumentLink objContentLink = new ContentDocumentLink();
                objContentLink.LinkedEntityId = acc.id;
                objContentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContent.id].ContentDocumentId;
                objContentLink.ShareType = 'I';
                objContentLink.Visibility = 'AllUsers'; 
                insert objContentLink;
                CaseController.generateDownloadUrl(objContentLink.ContentDocumentId);
            }catch(Exception ex){}
            try{            
                CaseController.updateDocVersion('', new List<String>{contentVersion.ContentDocumentId}, 'doc description', 'upload comments', newCaseInfo.Id);
            }catch(Exception ex){}
            try{            
                CaseController.deleteDoc(new List<String>{contentVersion.ContentDocumentId});
            }catch(Exception ex){}
        }
        Test.stopTest(); 
    }

    @isTest
    static void testAsInternalUser3(){
        List<User> CurrentUsers = [SELECT ID FROM User Where Email = 'mtest@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = CurrentUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case  newCaseInfo=[select id from case limit 1];
        account acc=[SELECT Id, ParentId FROM Account WHERE RecordtypeId =: SupportAccountRecType];
        contact cont=[select id from contact limit 1];
        List<AccountContactRelation> accContactRelations = [SELECT Id, ContactId, Primary__c FROM  AccountContactRelation];

        globalApexManager.avoidRecursion('CaseCommentTrigger', 'before', 'insert');
        globalApexManager.avoidRecursion('CaseCommentTrigger', 'after', 'insert');
        globalApexManager.avoidRecursion('CaseCommentTrigger', 'before', 'update');
        globalApexManager.avoidRecursion('CaseCommentTrigger', 'after', 'update');

        globalApexManager.avoidRecursion('CaseTrigger', 'before', 'insert');
        globalApexManager.avoidRecursion('CaseTrigger', 'after', 'insert');
        globalApexManager.avoidRecursion('CaseTrigger', 'before', 'update');
        globalApexManager.avoidRecursion('CaseTrigger', 'after', 'update');

        Test.startTest();
        system.runAs(CurrentUsers[0]){
            try{
                CaseController.initialResponseCaseComment(newCaseInfo.Id);
            }catch(Exception ex){}
            try{
                CaseController.escalateCase(newCaseInfo.Id, 'escalation reason', 'escalation comment');
            }catch(Exception ex){}
            try{
                CaseController.requestAttn(newCaseInfo.Id, 'Revise Prioirty', 'Attention Request comments', 'selected impact', System.today()+1);
            }catch(Exception ex){}
            try{
                CaseController.doCaseRecordTypeChange(newCaseInfo, 'Technical', 'Administrative', new List<DateTime>(), new List<String>());
            }catch(Exception ex){}
            try{
                CaseController.doCaseRecordTypeChange(newCaseInfo, 'Administrative', 'Technical', new List<DateTime>(), new List<String>());
            }catch(Exception ex){}
            try{
                CaseController.removeCaseContact('', '');
            }catch(Exception ex){}
            try{
                String jsonText = '{"Data": {"attributes": {"type": "Case"},"Id": "' + newCaseInfo.Id + '","ContactId": "' + cont.Id + '"}}';
                CaseController.UpdateCaseRecord(jsonText);
            }catch(Exception ex){}
            try{
                CaseController.getMedataDataRecord('');
            }catch(Exception ex){}
            try{
                CaseController.processCaseDescQualityIndicator('', '', '', '');
            }catch(Exception ex){}
            try{
                CaseController.processCaseRecommendation('', '', '', '', '', '');
            }catch(Exception ex){}            
            try{
                CaseController.reOpenCase(newCaseInfo.Id,'ntvalid data');
            }catch(Exception ex){}
            try{
                newCaseInfo.Status = 'Solution';
                update newCaseInfo;
                CaseController.trackSolutionStatus(newCaseInfo.Id, 'Accepted' , 'String comments',system.today(), 'String reason');
            }catch(Exception ex){}                
            try{
                newCaseInfo.Status = 'Solution';
                update newCaseInfo;
                CaseController.trackSolutionStatus(newCaseInfo.Id, 'Declined' , 'String comments',system.today(), 'String reason');
            }catch(Exception ex){}                
            try{
                newCaseInfo.Status = 'Solution';
                update newCaseInfo;
                CaseController.trackSolutionStatus(newCaseInfo.Id, 'NeedMoreTime' , 'String comments',system.today(), 'String reason');
            }catch(Exception ex){}                
            try{
                Service_Appointment__c serviceAppt = [Select Id From Service_Appointment__c Limit 1];
                newCaseInfo.Service_Appointment_AAE__c = serviceAppt.Id;
                update newCaseInfo;
                CaseController.CancelAaeAppointmentHandler(newCaseInfo.Id,'test');
            }catch(Exception ex){}
        }
        Test.stopTest();
    }

    @isTest
    static void testSupportLite(){

        Id customerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
        Id ecommerceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('eCommerce').getRecordTypeId();
        Id caseLiteRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();

        sObject sObj;
        List<Account> lNewCustomerAccount = new List<Account>();
        List<Account> lNewEcommerceAccount = new List<Account>();
        List<Contact> lNewContacts = new List<Contact>();
        List<AccountContactRelation> lNewAccountContacts = new List<AccountContactRelation>();
        List<Org__c> lNewOrg = new List<Org__c>();
        List<Org_Service__c> lNewOrgService = new List<Org_Service__c>();
        List<Org_User__c> lNewOrgUsers = new List<Org_User__c>();
        List<User> lNewUsers = new List<User>();
        List<Case> lNewCases = new List<Case>();
        
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())){
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', customerAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test eCommerce Account');
            UtilityTestData.mAccountData.put('RecordTypeId', ecommerceAccountRecordTypeId);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            lNewEcommerceAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','TEST CONTACT FIRSTNAME');
            UtilityTestData.mContactData.put('LastName','TEST CONTACT LASTNAME');
            UtilityTestData.mContactData.put('Email','testOrgEmail@test.com');
            UtilityTestData.mContactData.put('Phone','1234567890');
            UtilityTestData.mContactData.put('MailingCountry','USA');
            UtilityTestData.mContactData.put('INFA_Language__c','English');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            lNewContacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId', lNewEcommerceAccount[0].Id);
            UtilityTestData.mAccContactRelation.put('ContactId', lNewContacts[0].Id);
            UtilityTestData.mAccContactRelation.put('Access_Level__c', 'Read/Write');
            UtilityTestData.mAccContactRelation.put('IsActive', 'true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            lNewAccountContacts = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Org_Name__c', 'Test Org');
            UtilityTestData.mOrgData.put('OrgType__c', 'Trial');
            UtilityTestData.mOrgData.put('Pod_Name__c', 'TEST-POD-NAME');
            UtilityTestData.mOrgData.put('OfferCode__c', 'TEST-OFFER-CODE');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'TEST-LOCATION');
            UtilityTestData.mOrgData.put('Account__c', lNewEcommerceAccount[0].Id+'');
            UtilityTestData.mOrgData.put('Pod_Location__c', 'XXXXYYYYYZZZZZ-TEST');
            UtilityTestData.mOrgData.put('OrgID__c', 'ORGTESTZZZXXXYYY');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            lNewOrg = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Date dt = System.today().addDays(90);
            sObj = new Org_Service__c();
            UtilityTestData.mOrgServiceData.put('Org_ID__c', lNewOrg[0].Id+'');
            UtilityTestData.mOrgServiceData.put('Expiration_Date__c', dt+'');
            UtilityTestData.mOrgServiceData.put('Org_Service_Name__c', 'Simple Data Integration');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgServiceData);
            lNewOrgService = (List<Org_Service__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Org_User__c();
            UtilityTestData.mOrgUserData.put('Contact__c', lNewContacts[0].Id);
            UtilityTestData.mOrgUserData.put('Org__c', lNewOrg[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
            lNewOrgUsers = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
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
            lNewUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'GCS_Support_Lite_Community_User']?.Id;

            insert new PermissionSetAssignment(AssigneeId = lNewUsers[0].Id, PermissionSetId = permissionSetId);
        }
        System.runAs(lNewUsers[0]){
            CaseController.CaseLiteDetail objCaseLiteDetail = CaseController.getCaseLiteDetails('No-Code Data Integration');
            System.assert(objCaseLiteDetail?.ContactId != null && String.isNotBlank(objCaseLiteDetail?.objSupportLiteProduct?.Product_Name_on_Support__c) && !objCaseLiteDetail?.lstOrgs.isEmpty(), 'Unable to fetch the initial details required to create case lite case');
            System.assert(CaseController.getAccountContacts(lNewOrg[0].Id)?.isEmpty(), 'Unable to fetch eCommerce account contacts from case lite creation');
            String strCaseJson = '{"Priority":"P3","Subject":"test 123","Description":"test 123","Error_Message__c":"test 123","Version__c":"Current","Forecast_Product__c":"Active VOS"}';
            Global_Config__c settings = Global_Config__c.getOrgDefaults();
            settings.Mute_Triggers__c = true;
            upsert settings Global_Config__c.Id;   
            String strCaseId = CaseController.createCase(strCaseJson, 'Case_Lite', new List<AccountContactRelation>(), new List<Case_Contact__c>(), '', new List<DateTime>(), new List<String>(), lNewOrg[0].OrgID__c);
        }
        Test.stopTest();
    }

    @isTest
    static void cancelAaeAppointmentHandlerTest(){
        Test.startTest();

        Id supportAccountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Support_Account']?.Id;
        Id ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();
        Id CASE_ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();

        //Time Slot AAE
        Time_Slot_AAE__c objTS = new Time_Slot_AAE__c();
        objTS.Product__c = 'Axon Data Governance';
        objTS.Status__c = 'Available';
        objTS.Start_Time__c = System.today().addDays(8);
        insert objTS;
        
        //Service Appointment
        Service_Appointment__c objSA = new Service_Appointment__c();
        objSA.Support_Account__c = supportAccountId;
        objSA.Subject__c = 'Test Subject';
        objSA.Description__c = 'Test Description';
        objSA.Area__c = 'Best Practices';
        objSA.Category__c = 'Test Category';
        objSA.Time_Slot_AAE__c = objTS.Id;
        objSA.RecordTypeId = ASK_AN_EXPERT_RECORDTYPEID;
        insert objSA;

        List<Case> lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :CASE_ASK_AN_EXPERT_RECORDTYPEID LIMIT 1];

        CaseController.CancelAaeAppointmentHandler(lstCases[0].Id, 'Close Service Appointment');
        Test.stopTest();
    }

    @isTest
    static void testCaseMilestoneFlags(){
        Test.startTest();
        Account supportAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Support_Account' LIMIT 1];
        Id entitlementId = [SELECT Id FROM Entitlement LIMIT 1]?.Id;
        Entitled_Product__c entitledProduct = [SELECT Id FROM Entitled_Product__c LIMIT 1];
        Id timeZone = [SELECT Id FROM TimeZone__c LIMIT 1]?.Id;

        List<User> portalUsers = [SELECT ID FROM User Where Username = 'portalUsers@m.t'];

        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Customer_Community_user')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = portalUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        List<User> CurrentUsers = [SELECT ID FROM User Where Email = 'mtest@m.t'];

        lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Engineer', 'GCS_Manager2','GCS_Administration')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = CurrentUsers[0].id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;

        case newCaseInfo = [select id from case limit 1];
       
        system.runAs(CurrentUsers[0]){
            supportAccount.Success_Offering__c = 'Signature Success';
            supportAccount.timezone__c = timeZone;
            supportAccount.Entitlement__c = entitlementId;
            update supportAccount;

            entitledProduct.Business_Critical_Success_Plan__c = true;
            update entitledProduct;

            newCaseInfo.Priority ='P1';
            newCaseInfo.EntitlementId = entitlementId;
            newCaseInfo.Subject ='Test Milestone';
            newCaseInfo.Is_AssignmentRules__c =true;
            newCaseInfo.Version__c ='9.2.4';
            newCaseInfo.Forecast_Product__c ='Axon Data Governance';
            newCaseInfo.Success_Offering__c ='Signature Success';
            newCaseInfo.Org_ID__c ='TEST_ORG';
            newCaseInfo.Case_Timezone__c = timeZone;
            newCaseInfo.Case_Support_Add_On__c = 'BCSP';
            newCaseInfo.Attention_Request__c  = 'Callback';
            newCaseInfo.Escalation_Attention__c = true;
            update newCaseInfo;
        }
       
        system.runAs(portalUsers[0]){
            CaseController.getCaseDetails(newCaseInfo.Id);
        }
        Test.stopTest(); 
    }
}