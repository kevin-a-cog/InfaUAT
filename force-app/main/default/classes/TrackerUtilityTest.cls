/*
Author Name   : Akhilesh Soni
Class Name    : TrackerUtilityTest
Created Date  : Nov 11, 2020
Description   : test class for TrackerUtility
*/
@isTest
private class TrackerUtilityTest {
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    
    @testSetup
    static void setupObjectTestData() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
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
            if (lstEntitlementProcess.size()>0){
                Entitlement updateEntitlementRec = new Entitlement();
                updateEntitlementRec.Id = lEntitlement[0].Id;
                updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
                update updateEntitlementRec;        
            } 
            List<BusinessHours> bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
            Test.startTest();
            sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'P1');
            UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
            UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
            UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', lEntitlement[0].Id);
            UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contacts[0].Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('slaStartDate ', system.now()+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
            Case cs = [Select Id,Priority From Case]; 
            
             //Plan
            sObject Plan = new Plan__c();
            UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
            UtilityTestData.mPlan.put('Name','Test Plan');//
            UtilityTestData.mPlan.put('Sub_Stage__c','Design');
            UtilityTestData.mPlan.put('AutoPilot_Status__c','Submitted for Approval');
            UtilityTestData.mPlan.put('CSM_isAutoPilot__c',false+'');
            UtilityTestData.mPlan.put('Csm_Manager__c',UserInfo.getUserId()+'');
            UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
            UtilityTestData.mPlan.put('Plan_Operational_Model__c', 'Pooled CSM');
            Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
            
           
            
            List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan}); 
            
            lPlan[0].Sub_Stage__c = 'On-board';
            update lPlan[0];
            
            Tracked_Details__c oTD = new Tracked_Details__c();
            oTD.sObjectAPI__c = 'Case';
            oTD.RecordId__c = cases[0].Id;
            oTD.Entry_Criteria__c = 'Priority == P1';
            oTD.Exit_Criteria__c = 'Priority == P2';
            oTD.Description__c = 'Priority == P2';
            oTD.Enter_Timestamp__c = system.now();
            oTD.Enter_Timestamp__c = system.now().adddays(1);
            insert oTD;
            
            TrackerUtility.getMetaData('Plan__c');
            
            Test.stopTest();
        }
    }  
        
    @isTest
    public static void testgetOptyRecordID() {
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
        Map<id,Opportunity> newmap = new Map<id,Opportunity>();
       
        //Now we create an Account.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;

		//Now we create an Opportunity.
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'Test';
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.StageName = 'Lead';
		objOpportunity.CloseDate = System.today().addDays(1);
		objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
		insert objOpportunity;        
        oldmap.put(objOpportunity.id, objOpportunity);
        Test.startTest();
        objOpportunity.CSM_Comments__c = 'Test 111';
        update objOpportunity;        
        newmap.put(objOpportunity.id, objOpportunity);
            
         TrackerUtility.trackChanges(oldmap,newmap);
         TrackerUtility.trackChanges(null,newmap);
         Test.stopTest();           
        }      
    
    
    

    
   @isTest
   private static void unitTest(){
        Test.startTest();
        Case cs = [Select Id,Priority From Case];      
        cs.Priority = 'P2';        
        update cs;
        System.debug('######'+[SELECT Id, Custom_Message__c, Caused_From__c, Stack_Trace__c, Type__c, Exception_Debug__c FROM Exceptions_Log__c]);
        Test.stopTest();
        cs.Priority = 'P1';        
        update cs;
        cs.Priority = 'P2';        
        update cs;
        //system.assert([Select Count() From Tracked_Details__c]>1);
    }
    
    @isTest private static void unitTestForExisting(){
        Case cs = [Select Id,Priority,status From Case]; 
        Tracked_Details__c oTD = new Tracked_Details__c();
        oTD.sObjectAPI__c = 'Case';
        oTD.RecordId__c = cs.Id;
        oTD.Entry_Criteria__c = 'Priority == P1';
        oTD.Exit_Criteria__c = 'Priority == P2';
        oTD.Description__c = 'Priority == P2';
        oTD.Filter_Criteria__c='Test';
        oTD.Enter_Timestamp__c = system.now();
        oTD.Enter_Timestamp__c = system.now().adddays(1);
        insert oTD;
        Test.startTest();   
        cs.status = 'P1';        
        try{
        update cs;
        }
        Catch(Exception e){
            system.debug('Exception');
        }
        Test.stopTest();
    }

     /*
     Method Name : caseFieldsTrackingTest
     Description : Testing case fields tracking.
     Parameters  : None
     Return Type : None
    */
    @isTest
    public static void caseFieldsTrackingTest() {
        Test.startTest();
        Id CUSTOMER_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id SUPPORT_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CASE_TECHNICAL_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        List<Schema.SObjectType> PRIMARY_SOBJECTS = new List<Schema.SObjectType>{
            Account.SObjectType,
            TimeZone__c.SObjectType,
            Contact.SObjectType,
            AccountContactRelation.SObjectType,
            Asset.SObjectType,
            Entitlement.SObjectType,
            Entitled_Product__c.SObjectType
        };
        List<Schema.SObjectType> SECONDARY_SOBJECTS = new List<Schema.SObjectType>{
            Asset.SObjectType,
            Account.SObjectType,
            Case.SObjectType
        };
        sObject objCustomerAccount, objSupportAccount, objTimezone, objContact, objACR;
        
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
        UtilityTestData.mContactData.put('Email','tstconmail101@gmaill.com');
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

        //Now, we commit the primary objects
        objUnitOfWork.commitWork();

        /* Secondary Objects */
        objUnitOfWork = new UnitOfWork(SECONDARY_SOBJECTS);

        Asset objAssetToUpdate = [SELECT Id FROM Asset ORDER BY Id DESC LIMIT 1];
        Entitled_Product__c objEntitledProductQueried = [SELECT Id,Entitlement__c,End_Date__c FROM Entitled_Product__c ORDER BY Id DESC LIMIT 1];
        Account objSupportAccountToUpdate = [SELECT Id FROM Account WHERE RecordTypeId = : SUPPORT_ACCOUNT_RECORDTYPEID ORDER BY Id DESC LIMIT 1];

        //Update EP on Asset
        objAssetToUpdate.Entitled_Product__c = objEntitledProductQueried.Id;
        objUnitOfWork.registerDirty(objAssetToUpdate);

        //Rollup success offering, entitlement & end date onto the support account
        objSupportAccountToUpdate.Success_Offering__c = strSuccessOffering;
        objSupportAccountToUpdate.Entitlement__c = objEntitledProductQueried.Entitlement__c;
        objSupportAccountToUpdate.End_Date__c = objEntitledProductQueried.End_Date__c;
        objUnitOfWork.registerDirty(objSupportAccountToUpdate);

        //Case
        Case objCase = new Case();
        objCase.Support_Account__c = objSupportAccountToUpdate.Id;
        objCase.Entitled_Product__c = objEntitledProductQueried.Id;
        objCase.EntitlementId = objEntitledProductQueried.Entitlement__c;
        objCase.RecordTypeId = CASE_TECHNICAL_RECORDTYPEID;
        objCase.Forecast_Product__c = strProductName;
        objCase.P0_Enabled_By__c = 'Manual';
        objUnitOfWork.registerNew(objCase);

        //Now, we commit the secondary objects 
        objUnitOfWork.commitWork();

        //Assertions
        List<Case> lstCasesQueried = [SELECT Id FROM Case ORDER BY Id DESC LIMIT 1];
        Assert.isTrue(lstCasesQueried.size() > 0, 'Case is not created.');

        List<Tracked_Details__c> lstTrackedDetails = [SELECT Id FROM Tracked_Details__c WHERE Object_Name__c = 'Case' AND Parent_Record_Id__c = :lstCasesQueried[0].Id LIMIT 1];
        Assert.isTrue(lstTrackedDetails.size() > 0, 'Case field custom history tracking record is not created.');

        Test.stopTest();
    }
}