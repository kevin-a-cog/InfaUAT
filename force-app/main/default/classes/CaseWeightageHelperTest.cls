@isTest
public with sharing class CaseWeightageHelperTest {
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    public static Id OperationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
    public static List<Account> lNewCustomerAccount;
    public static List<Account> lNewSupportAccount;
    public static List<Account> supAcc;
    public static List<BusinessHours> bussinessHourList;
    public static List<Contact> contacts;
	public static List<Entitlement> lEntitlement;
    
    @testSetup
    static void setupObjectTestData() {
          Test.startTest();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
            //insert GCS_Subscription__c
            insert new GCS_Subscription__c (Case_Views__c='RecentlyViewedCases;RecentlyViewedCases;AllOpenCases;Weekend_Holiday_Combined_View',
            Engineering_Workspace_List_View_Sort__c ='B2B_Data_Exchange_Case;RecentlyViewedCases;Cloud_B2B_Case;Axon_Data_Governance_Case',
            Pinned_View__c='RecentlyViewedCases'
            );
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('@Developer --> lNewCustomerAccount :' + lNewCustomerAccount);
            
              //create an Entitlement record
              sObj = new Entitlement();
              UtilityTestData.mEntitlement.put('AccountId',lNewCustomerAccount[0].Id);
              UtilityTestData.mEntitlement.put('Status','Active');
              UtilityTestData.mEntitlement.put('StartDate',system.today().addDays(-10)+'');
              UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
              sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
              lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
              
              List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name 
                                                        FROM SlaProcess 
                                                        WHERE Name='Signature Success' and IsActive = true LIMIT 1];
            
              system.debug('@@lstEntitlementProcess= '+lstEntitlementProcess);
              if (lstEntitlementProcess.size()>0){
                  Entitlement updateEntitlementRec = new Entitlement();
                  updateEntitlementRec.Id = lEntitlement[0].Id;
                  updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
                  update updateEntitlementRec;        
              } 

            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
            UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('Active__c', 'true');
            UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
            UtilityTestData.mAccountData.put('Entitlement__c', lEntitlement[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
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
             contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('79 Number of Queries used in this apex code so far: ' + Limits.getQueries());
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
            System.debug('93 Number of Queries used in this apex code so far: ' + Limits.getQueries());
            sObj = new AccountContactRelation();
            UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
            UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
            UtilityTestData.mAccContactRelation.put('IsActive','true');
            UtilityTestData.mAccContactRelation.put('Access_Level__c','Read/Write');
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
            List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('102 Number of Queries used in this apex code so far: ' + Limits.getQueries());
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
            System.debug('117 Number of Queries used in this apex code so far: ' + Limits.getQueries());
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise;Hosted Single Tenant;Hosted Multi Tenant;Perpetual');
            UtilityTestData.mtechnicalProductLine.put('Version__c', '9.2.1;9.2.2;9.2.4');
            UtilityTestData.mtechnicalProductLine.put('Component_SubComponent__c', 'Installation:Installation;Documentation:Documentation;ActiveVOS Console:Error~Permission;Performance:Job~Process performance;Hosted Application:Custom configuration~Product configuration~Logs~Others;Hosted Infrastructure:CPU~Memory~Disk~Others');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
            List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
            supAcc = [SELECT Id, Name, ParentId, Parent.BillingCountry, Parent.OwnerId, BillingCountry, Entitlement__c,
            Entitlement__r.Support_Level__c,TimeZone__c,TimeZone__r.Name,Support_Add_On__c from Account WHERE Id =:lNewSupportAccount[0].Id];
            System.debug('130 Number of Queries used in this apex code so far: ' + Limits.getQueries());
            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'P1');
            UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
            UtilityTestData.mCase.put('Next_Action__c ', 'INFA R&D');
            UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            
         /*   sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'P2');
            UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
            UtilityTestData.mCase.put('Next_Action__c ', 'Third Party');
            UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases1 = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj}); */

            SObject sObj1 = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case22');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'P3');
            UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
            UtilityTestData.mCase.put('Next_Action__c ', 'Customer');
            //UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback from Engineer');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
           
	        System.debug('189 Number of Queries used in this apex code so far: ' + Limits.getQueries());
            /*Case_Comment__c caseCommentParent = new Case_Comment__c();
            caseCommentParent.Case__c = cases[1].Id;
            caseCommentParent.Comment__c = 'aaaaaaaaa';
            caseCommentParent.Type__c = 'Revise Prority';
            caseCommentParent.Comment_to_Search__c = 'childtestservletComment';
            caseCommentParent.Visibility__c = 'External';
            insert caseCommentParent;*/
            /*sObj = new Case_Contact__c();
            UtilityTestData.mCase.put('Contact__c', contacts[0].id);
            UtilityTestData.mCase.put('Case__c', cases[0].id);//
            UtilityTestData.mCase.put('Email__c', 'test123@mailinator.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case_Contact__c> Case_Contact = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{sObj});*/
            
            sObj = new Org__c();
            UtilityTestData.mOrgData.put('Entitled_Product__c',lEntitledProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
            List<Org__c> orgs = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            /*sObj = new Service_Appointment__c();
            UtilityTestData.mServiceAppointment.put('Activity_Type__c', 'Apply EBF');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);
            List<Service_Appointment__c> serviceAppoinments = (List<Service_Appointment__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); */
            List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
             //  Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
             Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User' limit 1];
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
            lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{ partnerUser});
            // lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj, partnerUser});   
            String teamMemberRole = 'BDM';
            sObj = new AccountTeamMember();
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].id );
            UtilityTestData.mCase.put('TeamMemberRole', teamMemberRole );
            UtilityTestData.mCase.put('UserId', lstUser[0].id );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<AccountTeamMember> lstAccountTeamMember = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
        }
          Test.stopTest();
    }
    
    static void populateData(){
        lNewCustomerAccount = [Select Id From Account Where Name ='Test Customer Account'];
        lNewSupportAccount = [Select Id From Account Where Name ='Test Support Account'];
        bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];        
        supAcc = [SELECT Id, Name, ParentId, Parent.BillingCountry, Parent.OwnerId, BillingCountry, Entitlement__c,
                  Entitlement__r.Support_Level__c,TimeZone__c,TimeZone__r.Name,Support_Add_On__c 
                  From Account WHERE Id =:lNewSupportAccount[0].Id];
        contacts = [Select Id From Contact Where AccountId = :lNewCustomerAccount[0].id];
        lEntitlement = [Select Id From Entitlement Where AccountId = :lNewCustomerAccount[0].id];
    }
    
    
    @isTest
    private static void unitTest_P1(){
		test.startTest();
        populateData();
        SObject sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('status', 'New');
        UtilityTestData.mCase.put('Priority', 'P1');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
        UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
        UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
        UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
        UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
        UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
        UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
        UtilityTestData.mCase.put('Next_Action__c ', 'INFA R&D');
        UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
		test.stopTest();
    }
    
    @isTest
    private static void unitTest_P2(){
        test.startTest();
        populateData();
        //create an Engagement record
        sObject oEngagement = new Engagement__c();
        oEngagement = UtilityTest.putFieldRecord(oEngagement, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{oEngagement});
        
        sObject sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('status', 'New');
        UtilityTestData.mCase.put('Priority', 'P2');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
        UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
        UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
        UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
        UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
        UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
        UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
        UtilityTestData.mCase.put('Next_Action__c ', 'INFA R&D');
        UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
        UtilityTestData.mCase.put('Engagement__c', oEngagement.Id);
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        CaseWeightageHelper.MilestoneWrapper oMilestoneWrapper = new CaseWeightageHelper.MilestoneWrapper();
        oMilestoneWrapper.name= 'Initial Response';
        oMilestoneWrapper.TimeRemainingInMins = decimal.valueOf('0.00');
        oMilestoneWrapper.IsViolated = true;
        
        
        
        
        CaseWeightageHelper.MilestoneWrapper wrapperMileStone = new CaseWeightageHelper.MilestoneWrapper();
        wrapperMileStone.compareTo(oMilestoneWrapper);
        test.stopTest();
    }
    
    @isTest
    private static void unitTest_P3(){
        test.startTest();
		populateData();
        SObject sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('status', 'New');
        UtilityTestData.mCase.put('Priority', 'P3');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c ', 'Callback from Engineer');
        UtilityTestData.mCase.put('EntitlementId ', supAcc[0].Entitlement__c);
        UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
        UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
        UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
        UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
        UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
        UtilityTestData.mCase.put('Next_Action__c ', 'INFA R&D');
        UtilityTestData.mCase.put('Case_Support_Add_On__c', 'BCSP');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        CaseWeightageHelper.MilestoneWrapper oMilestoneWrapper = new CaseWeightageHelper.MilestoneWrapper();
        oMilestoneWrapper.name= 'Initial Response';
        oMilestoneWrapper.TimeRemainingInMins = decimal.valueOf('00.02');
        oMilestoneWrapper.IsViolated = true;
        
        
        
        
        CaseWeightageHelper.MilestoneWrapper wrapperMileStone = new CaseWeightageHelper.MilestoneWrapper();
        wrapperMileStone.compareTo(oMilestoneWrapper);
        test.stopTest();
    }
     @isTest
    private static void unitTest_Operational(){
        test.startTest();
		populateData();
        SObject sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Success_Offering__c', 'Premium Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Axon Data Governance');
        sObj.put('Version__c', '4.3.4');
        //sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', Contacts[0].Id); 
        sObj.put('Status', 'New');
        sObj.put('Environment__c', 'PROD');
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',OperationsCaseRecordTypeId);
        sObj.put('AccountId', lNewCustomerAccount[0].Id);
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
      
        
        
        
        
       
        test.stopTest();
    }
    /*
     public class MilestoneWrapper 
    {
        public String name{get;set;}
        public Decimal TimeRemainingInMins{get;set;}
        public boolean IsViolated{get;set;}
        
        
    }*/
    
    
    /*public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testmethod void weightUpdateScheduleTest(){
        List<Case_Weightage__c> cwList = new List<Case_Weightage__c>();
        for(Case_Weightage__c cw:[Select Id,Hours_Offset__c,Minutes_Offset__c,Business__c,SameTimeZone__c 
                                  From Case_Weightage__c ]){
            cw.SameTimeZone__c = true;
            cwList.add(cw);
        }

      //  update cwList;
        system.debug('&&&&&&&'+[SELECT Id, MilestoneTypeId, MilestoneType.Name, CaseId, BusinessHoursId, StartDate, TargetDate, TimeRemainingInMins, CompletionDate, IsCompleted, IsViolated FROM CaseMilestone]);
       Test.startTest();
        //String jobId = System.schedule('WeightUpdateSchedule',CRON_EXP,new WeightUpdateSchedule());
        Test.stopTest();
    }*/
}