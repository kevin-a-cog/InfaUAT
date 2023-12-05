/*
Class:          OpportunityTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/02/2018
@Description:   test class for OpportunityTriggerHandler

Change History
****************************************************************************************************
ModifiedBy          Date                Requested By        Description                 Tag
Anusha             March 5th 2022                           Test Class Update for IPUE 161   <T01>
Anusha             APR   5th 2022                           adding updatePrimaryESOnOpportunityTest method
**/

@isTest
public class OpportunityTriggerHandlerTest {      
    
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();   
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id CompetitiorRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
    static Id ProspectRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeCSIId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    private final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private final static string OPP_RENEWAL_RT = Label.Renewal_Opportunity; // Renewal Opportunity record type name on Opportunity 
    @testSetup
    static void setupObjectTestData(){
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
            settings1.Ignore_Validation_Rules__c = true;
            settings1.SetupOwnerId = userObj.Id;
            upsert settings1 User_Exemptions__c.Id;
            
            //create standard Pricebook
            Id pbId = Test.getStandardPricebookId();
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBookId = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //Creating Product2 records            
            UtilityTestData.mProductData.put('Name', 'DaaS Subscription');
            UtilityTestData.mProductData.put('Family', 'DaaS Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X1');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID1');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObj = new Product2();      
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'Cloud Subscription');
            UtilityTestData.mProductData.put('Family', 'Cloud Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X2');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID2');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj1 = new Product2();             
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'On-Premise Perpetual');
            UtilityTestData.mProductData.put('Family', 'On-Premise Perpetual');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X3');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID3');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj2 = new Product2();      
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'On-Premise Subscription');
            UtilityTestData.mProductData.put('Family', 'On-Premise Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X4');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID4');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj3 = new Product2();
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProductData);           
            
            UtilityTestData.mProductData.put('Name', 'Intelligent Cloud Data Management for FedRAMP - 120 Informatica Processing Units per consecutive month');
            UtilityTestData.mProductData.put('Product_Family__c', 'IPU');
            UtilityTestData.mProductData.put('ProductCode', 'BACKPOCKET');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID5');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj4 = new Product2();
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mProductData); 
            
            
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3, sObj4});
            System.assertEquals(lProduct.size(), 5);
            
            // 1. Insert a price book entry for the standard price book.
            sObj = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[0].Id + '' );
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);        
            sObj1 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[1].Id + '' );
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);        
            sObj2 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[2].Id + '' );
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);        
            sObj3 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[3].Id + '' );
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2,sObj3});
            System.assertEquals(lPriceBookEntry.size(),4); 
            
            List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 WHERE DeveloperName LIKE \'NA_%\' Limit 2');
            
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);             
            
            UtilityTestData.mAccountData.put('Name', 'Test Competitor Account 2');
            UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj1 = new Account();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData); 
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            // Set all the required fields and dynamic ids in Map
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Test_1Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('Email', 'Test_2Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj1 = new Contact();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);

            UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
            UtilityTestData.mContactData.put('Email', 'Test_3Test@Opp.com');
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj2 = new Contact();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);            
            
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1,sObj2});
            
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
            UtilityTestData.mOpportunityData.put('Name', 'Test NNB Opty');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
             
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('Name', 'Test Renewal Opty');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Renewal');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'No Opportunity');
            UtilityTestData.mOpportunityData.put('Substage__c', 'No Opportunity');
            UtilityTestData.mOpportunityData.put('Stage_Reason__c', 'Revision Opportunity');
            UtilityTestData.mOpportunityData.put('Admin__c', 'True');
            UtilityTestData.mOpportunityData.put('Remove_Ownership__c', 'False');
            UtilityTestData.mOpportunityData.put('Name', 'Revision : Test opportunity');
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'New');
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Primary');            
            sObj2 = new Opportunity();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData); 
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
            UtilityTestData.mOpportunityData.put('Name', 'Test PRM Opty 2');
            UtilityTestData.mOpportunityData.put('Owner',userObj.Id);
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Type','Indirect');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');            
            sObj3 = new Opportunity();
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);  
        
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
            UtilityTestData.mOpportunityData.put('Name', 'Test NNB Opty1');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
             
            sObj4 = new Opportunity();
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);  

            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('Name', 'Test Renewal Opty1');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Renewal');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            sObject sObj5 = new Opportunity();
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mOpportunityData);    
            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
            UtilityTestData.mOpportunityData.put('Name', 'Test Renewal Opty2');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Renewal');
           // UtilityTestData.mOpportunityData.put('StageName','Closed Won');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            sObject sObj6 = new Opportunity();
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mOpportunityData); 
            
            List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4,sObj5,sObj6});
            
            //Insert Opportunity Contact Roles
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[1].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Evaluator');
            sObj1 = new OpportunityContactRole();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);

            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[2].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Billing Contact');
            sObj2 = new OpportunityContactRole();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityContactRoleData);            
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1,sObj2});
            
            //Insert Opportunity Team members
            UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
            sObj = new OpportunityTeamMember ();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
            List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
            
            //Insert Estimation Summary
            //
           /* Estimation_Summary__c estimationSummary = IPUE_TestUtils.createEstimationSummary(true, lOpportunityRecord[0].Id);
            estimationSummary.Account__c = lAccount[0].Id;
            //estimationSummary.Status__c = 'Initialized Agreement';
            update estimationSummary;*/
        
            Estimation_Summary__c estimationSummary1 = IPUE_TestUtils.createEstimationSummary(false, lOpportunityRecord[0].Id);
            estimationSummary1.Primary__c = true;
            insert estimationSummary1;
            
            List<Estimator_Collaborator__c> lstEstimatorCollaborator = IPUE_TestUtils.createEstimatorCollaborator(true,lContact,estimationSummary1);

            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];
    
            sObj = new User();
            UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest1a@m.t');
            UtilityTestData.mUserData.put('Email','mtest1a@m.t');
            UtilityTestData.mUserData.put('Alias','alias1');
            UtilityTestData.mUserData.put('CommunityNickname','mtest1');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',lContact[0].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');
            UtilityTestData.mUserData.put('LastName','User 1');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
                
            List<User> communityUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{sObj});
            }  
            Test.stopTest();           
    }

    //Below method is to test DA update
    @isTest
    public static void updateDiscountApprovalTest() {
        
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<Opportunity> lOpportunity = [SELECT Id,AccountId FROM Opportunity WHERE Name = 'Test NNB Opty'];
        Test.startTest();
        System.runAs(userObj) {          
            sObject sObjDiscountApproval1 = new DiscountApproval__c  ();
            UtilityTestData.mDiscountApproval.put('Opportunity__c',lOpportunity[0].id);
            UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
            UtilityTestData.mDiscountApproval.put('Status__c','New');
            UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','6000000');
            UtilityTestData.mDiscountApproval.put('Discount__c','18');
            sObjDiscountApproval1 = UtilityTest.putFieldRecord(sObjDiscountApproval1,UtilityTestData.mDiscountApproval); 
            List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeInsert(new List<sObject>{sObjDiscountApproval1});
            
            lOpportunity[0].PT_INFA_License_Compliance__c = false;
            update lOpportunity;
        }
        Test.stopTest();
    } 
    
    //Below method is to check the functional flow on Early CMS Process
    @isTest
    public static void createCMSRequestTest() {
        
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<Opportunity> lOpportunity = [SELECT Id,AccountId FROM Opportunity WHERE Name = 'Test NNB Opty'];
        Test.startTest();
        System.runAs(userObj) {          
            
            sObject sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test Legal Entity');
            UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lOpportunity[0].AccountId);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
            UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addMonths(12)+'');
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Opportunity(Id= lOpportunity[0].Id, StageName = 'Final Negotiation',SBQQ__PrimaryQuote__c = lSBQuote[0].Id,PT_INFA_License_Compliance__c = false);
            lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});

            List<Engagement__c> lstEngagement = [SELECT Id FROM Engagement__c WHERE Opportunity__c = :lOpportunity[0].Id];
            //System.assertEquals(2,lstEngagement.size());
        }
        Test.stopTest();
    }    
    
    //Below method is to check the functional flow on Opportunity Insert
    @isTest
    public static void createTeamOnOpportunity() {
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test NNB Opty'];
        List<Contact> lContact = [SELECT Id FROM Contact];
        
        System.runAs(userObj) {          
            
            sObject sObj = new Opportunity(Id= lOpportunityRecord[0].Id, End_User__c = lContact[0].Id);
            List<Opportunity> lOpportunityRecordUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate.size(),1);
            
            sObj = new Opportunity(Id= lOpportunityRecord[0].Id, End_User__c = lContact[1].Id);
            List<Opportunity> lOpportunityRecordUpdate1 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate1.size(),1);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void createRenewalOpportunity() {
        // Set the Account Name
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];        
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Renewal Opty'];
        List<PriceBookEntry> lPriceBookEntry = [SELECT Id FROM PriceBookEntry];
        Test.startTest();
        System.runAs(userObj) {  
            
            Id pbId = Test.getStandardPricebookId(); 
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunityRecord[0].Id, Pricebook2Id = pbId );
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});   
            
            //Add OLI on Primary Opportunity
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
            
            
            sObject sObjOppLineItem1 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[1].Id);
            sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
            
            sObject sObjOppLineItem2 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[2].Id);
            sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
            
            sObject sObjOppLineItem3 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[3].Id);
            sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem,
                sObjOppLineItem1,
                sObjOppLineItem2,
                sObjOppLineItem3});
            system.assertEquals(lstOpportunityLineItem.size(),4);             
        }         
        Test.stopTest();
    }
    
    @isTest
    public static void createQuoteOrderOpportunity() {
        Test.startTest();       
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];        
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Renewal Opty'];      
        List<Account> lAccount = [SELECT Id FROM Account WHERE Name = 'Test Customer Account'];     
        List<Product2> lProduct2 = [SELECT Id FROM Product2];
        List<Contact> lContact = [SELECT Id FROM Contact];
        List<Territory2> lTerritory = [SELECT Id FROM Territory2];
        
        System.runAs(userObj) {
            
            //Standard PriceBook
            Id pricebookId = Test.getStandardPricebookId(); 
            sObject sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});            
            
            //Create Quote
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lSBQuote.size(),1);
            
            //Create QuoteLineItem
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lSBQuoteLine.size(),1);
            
            //Create related Order record
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
            List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lOrder.size(),1);
            
            sObj = new Opportunity(Id= lOpportunityRecord[0].Id, Territory2Id= lTerritory[1].Id);
            List<Opportunity> lOpportunityRecordUpdate1 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate1.size(),1);
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void adminOpportunityTest(){ 
        UtilityTest.insertSetupObjectTestData();
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1]; 
        
        system.runAs(adminUser)
        { 
            User_Exemptions__c settings = User_Exemptions__c.getInstance(userObj.Id);
            if(settings == null) {
               Settings = new User_Exemptions__c(); 
            }
            settings.Ignore_Validation_Rules__c = true;
            settings.SetupOwnerId = userObj.Id;
            upsert settings;
        }
        
        Test.startTest();
        
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Revision : Test opportunity'];
        System.runAs(userObj) { 
            lOpportunityRecord[0].Remove_Ownership__c = True;
            
            List<Opportunity> upOpptyList = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{lOpportunityRecord[0]});
            system.assertEquals(upOpptyList.size(),1);
            
            Test.stopTest();            
        }
    }
    
    @isTest
    public static void updateRenewalOpportunity() {
    
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];        
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Renewal Opty'];
        List<PriceBookEntry> lPriceBookEntry = [SELECT Id FROM PriceBookEntry];
        
        System.runAs(userObj) {          
            
            Id pbId = Test.getStandardPricebookId();
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBookId = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunityRecord[0].Id, Pricebook2Id = pbId );
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
            
            //Add OLI on Primary Opportunity
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
            
            
            sObject sObjOppLineItem1 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[1].Id);
            sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
            
            sObject sObjOppLineItem2 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[2].Id);
            sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
            
            sObject sObjOppLineItem3 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[3].Id);
            sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem,
                sObjOppLineItem1,
                sObjOppLineItem2,
                sObjOppLineItem3});
            system.assertEquals(lstOpportunityLineItem.size(),4);  
            lOpportunityRecord[0].StageName = 'Closed Lost';
            lOpportunityRecord[0].Total_OARR__c = 10;
            lOpportunityRecord[0].Stage_Comment__c = 'test';
            lOpportunityRecord[0].Stage_Reason__c = 'Order Debook';
            lOpportunityRecord[0].Renewal_Cancellation_Reason__c = 'Value/Pricing';
            lOpportunityRecord[0].Cancellation_Detail__c  = 'Pricing/Cost/Value Related';
            update lOpportunityRecord;
            Test.stopTest();
        }
    }
    
    @isTest
    public static void createNewSalesWithForecast() {
        Test.startTest();
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test NNB Opty'];
        List<Contact> lContact = [SELECT Id FROM Contact];
        
        System.runAs(userObj) {          
            
            sObject sObj = new Opportunity(Id= lOpportunityRecord[0].Id, End_User__c = lContact[0].Id);
            List<Opportunity> lOpportunityRecordUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate.size(),1);
            
            sObj = new Opportunity(Id= lOpportunityRecord[0].Id, End_User__c = lContact[1].Id);
            sObj.put('ForecastCategoryName','Commit');
            sObj.put('StageName','Qualified');
            sObj.put('Competitors__c','Alation');
            sObj.put('Incumbent_Competitors__c','Alation');
            sObj.put('Lost_To_Competitors__c','Alation');
            OpportunityTriggerHandler.OpportunityInsertFlag = false;
            List<Opportunity> lOpportunityRecordUpdate1 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate1.size(),1);
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateRTMFieldsTest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        System.runAs(userObj) {
            
            List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Renewal Opty' LIMIT 1];
            List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
            
            //Create Quote
            Test.startTest();
            sObject sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.today().addDays(30) + '');
            UtilityTestData.mSBQuoteData.remove('SBQQ__EndDate__c');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Create Contract
            sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
            UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
            UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
            UtilityTestData.mContractData.put('ContractTerm','10');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].id+'');
            
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new Opportunity();       
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Name', 'Test Amendment Opty');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Upsell');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('SBQQ__AmendedContract__c', lContract[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lAmendOppty  =  (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
          
            if(lOpportunity.size() > 0){
                lContract[0].SBQQ__RenewalForecast__c = true;
                update lContract;      
            }
            Test.stopTest();   
        }
    }
    
     @isTest
    public static void syncStageSubstageNNBTest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        System.runAs(userObj) {
            Test.startTest();
            List<Opportunity> oppNNBList = [SELECT Id FROM Opportunity WHERE RecordType.Name = :OPP_NEW_SALES_RT LIMIT 1];
            oppNNBList[0].StageName = 'Duplicate';
            oppNNBList[0].Stage_Comment__c = 'test';
            update oppNNBList;        
            Test.stopTest();
        }
    }
    
     
    @isTest
    public static void syncStageSubstageRenewalTest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        System.runAs(userObj) {
            Test.startTest();
            List<Opportunity> oppRenewList = [SELECT Id,StageName, RecordType.Id FROM Opportunity WHERE RecordType.Name = :OPP_RENEWAL_RT LIMIT 1];
            system.debug('Opp Rec Type Id:'+oppRenewList[0].RecordType.Id);
            system.debug('Schema Rec Type Id:'+Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
            oppRenewList[0].StageName = 'Duplicate';
            oppRenewList[0].Stage_Comment__c = 'test';
            update oppRenewList;
            Test.stopTest();
        }
    }
    @isTest
    public static void updatePrimaryESOnOpportunityTest () {
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        //List<PriceBookEntry> lPriceBookEntry = [SELECT Id,product2.Product_Family__c FROM PriceBookEntry];
        List<Account> lAccount = [SELECT ID FROM Account LIMIT 1];
        List<Product2> lIpuProduct = [SELECT ID,Forecast_Product__c,Product_Family__c FROM Product2 WHERE Product_Family__c = 'IPU'];
        
        List<Opportunity> lOpportunityRecord = [SELECT Id,Substage__c FROM Opportunity LIMIT 1];
        
        System.runAs(userObj) {
            
            Test.startTest();
            
            Id pbId = Test.getStandardPricebookId(); 
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            
            sObject sObj1 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBook2[0].Id, Product2Id=lIpuProduct[0].Id + '' );
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
            
            List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            System.assertEquals(lPriceBookEntry.size(),1); 
            
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunityRecord[0].Id, Pricebook2Id = pbId,recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //Add OLI on Primary Opportunity
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
            UtilityTestData.mOpportunityProdData.put('Product2Id', lIpuProduct[0].Id);
            UtilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'New');
            UtilityTestData.mOpportunityProdData.put('UnitPrice', '1.08');
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
            
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem});
            system.assertEquals(lstOpportunityLineItem.size(),1);
                  
            globalApexManager.allowRun('OpportunityBeforeUpdate');
            lOpportunityRecord[0].Substage__c = 'Sales Won';
            lOpportunityRecord[0].Stage_Comment__c = 'test';
            lOpportunityRecord[0].Stage_Reason__c = 'Update Opty';
            Update lOpportunityRecord;
            
            Test.stopTest();
        }
    }
    @isTest
    public static void updatePrimaryESOnOpportunityTest1 () {
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        //List<PriceBookEntry> lPriceBookEntry = [SELECT Id,product2.Product_Family__c FROM PriceBookEntry];
        List<Account> lAccount = [SELECT ID FROM Account LIMIT 1];
        List<Product2> lIpuProduct = [SELECT ID,Forecast_Product__c,Product_Family__c FROM Product2 WHERE Product_Family__c = 'IPU'];
        
        List<Opportunity> lOpportunityRecord = [SELECT Id,Substage__c FROM Opportunity LIMIT 1];
        
        System.runAs(userObj) {
            
            Test.startTest();
            
            Id pbId = Test.getStandardPricebookId(); 
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            
            sObject sObj1 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBook2[0].Id, Product2Id=lIpuProduct[0].Id + '' );
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
            
            List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            System.assertEquals(lPriceBookEntry.size(),1); 
            
            String OPP_RENEWAL_RT = Label.Renewal_Opportunity;
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunityRecord[0].Id, Pricebook2Id = pbId,recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            //Add OLI on Primary Opportunity
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
            UtilityTestData.mOpportunityProdData.put('Product2Id', lIpuProduct[0].Id);
            UtilityTestData.mOpportunityProdData.put('Upsell_ACV__c', '2');
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
            
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem});
            system.assertEquals(lstOpportunityLineItem.size(),1);
                  
            globalApexManager.allowRun('OpportunityBeforeUpdate');
            lOpportunityRecord[0].StageName = 'Committed';
            lOpportunityRecord[0].Stage_Comment__c = 'test';
            lOpportunityRecord[0].Stage_Reason__c = 'Update Opty';
            Update lOpportunityRecord;
            
            Test.stopTest();
        }
    }
    @isTest
    public static void opportunityProductUpdateTest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        System.runAs(userObj) {
            Test.startTest();
            List<Opportunity> lOpportunityRecord = [SELECT Id FROM Opportunity LIMIT 1];
            sObject sObj = new Opportunity(Id = lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '20.00');
            UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '20.00');
            UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '20.00');
            UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '20.00');   
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});               
            Test.stopTest();
        }
    }

    @isTest
    public static void createOptyasBDM(){
        Test.startTest();
        List<UserTerritory2Association> lTerritoryUser = (List<UserTerritory2Association>) UtilityTest.executeQuery('Select Id,Territory2Id,UserId from UserTerritory2Association WHERE Territory2.DeveloperName LIKE \'NA_%\' AND RoleInTerritory2 = \'BDM\' Limit 1');
        List<Account> lAccount = [SELECT ID FROM Account LIMIT 1];
        User bdmUser = [SELECT Id FROM User WHERE Id = :lTerritoryUser[0].UserId];

        
        UtilityTestData.mObjectTerritory2AssociationData.put('AssociationCause', 'Territory2Manual');
        UtilityTestData.mObjectTerritory2AssociationData.put('ObjectId', lAccount[0].Id);
        UtilityTestData.mObjectTerritory2AssociationData.put('SobjectType', 'Account');
        UtilityTestData.mObjectTerritory2AssociationData.put('Territory2Id', lTerritoryUser[0].Territory2Id);
        sObject sObj = new ObjectTerritory2Association();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mObjectTerritory2AssociationData);
        List<ObjectTerritory2Association> lObjTerr2Association = (List<ObjectTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{sObj});

        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
            
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritoryUser[0].Territory2Id);
        UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
        UtilityTestData.mOpportunityData.put('Name', 'Test NNB Opty as BDM');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Direct');         
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        System.runAs(bdmUser){

            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            OpportunityTriggerHandler.OpportunityInsertFlag = false;
            sObj = new Opportunity(Id= lOpportunity[0].Id, StageName = 'Final Negotiation');
            try{
                lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            }catch (Exception e){}
        }
        Test.stopTest();
    }
    
  
     @isTest
    public static void updateSubscriptionStatustest() {
        Test.startTest();
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];     
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];


        System.runAs(userObj) {          
            
             List<Opportunity> lOpportunityRecord = [SELECT Id,StageName,RecordTypeId FROM Opportunity WHERE RecordType.Name = :OPP_RENEWAL_RT LIMIT 1];
            Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
            Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
            oldMap.put(lOpportunityRecord[0].Id,lOpportunityRecord[0]);
            Contract Con = New Contract();
            Con.AccountId = lAccount[0].Id;
            Con.SBQQ__RenewalOpportunity__c = lOpportunityRecord[0].Id;
            Insert Con;
            lOpportunityRecord[0].StageName = 'Closed Lost';
            lOpportunityRecord[0].Name = '1test1';
            lOpportunityRecord[0].Stage_Comment__c = 'test';
            lOpportunityRecord[0].Cancellation_Detail__c = 'Pricing/Cost/Value Related';
            lOpportunityRecord[0].Renewal_Cancellation_Reason__c = 'Value/Pricing';
            update lOpportunityRecord;
         List<Opportunity> lOpportunityRecord1 = [SELECT Id,StageName,RecordTypeId FROM Opportunity WHERE RecordType.Name = :OPP_RENEWAL_RT AND Name='1test1' LIMIT 1];
            newMap.put(lOpportunityRecord1[0].Id,lOpportunityRecord1[0]);
            OpportunityTriggerHandler.updateSubscriptionStatus(oldMap,newMap);
            system.assertEquals(lOpportunityRecord.size(),1);

        }
        Test.stopTest();
    }
      @isTest
    public static void syncStageSubstageRenewalTest1(){
        User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
        System.runAs(userObj) {
            Test.startTest();
            List<Opportunity> oppRenList = [SELECT Id,StageName,Stage_Comment__c,Cancellation_Detail__c,Renewal_Cancellation_Reason__c FROM Opportunity WHERE RecordType.Name = :OPP_RENEWAL_RT LIMIT 5];
            oppRenList[0].StageName = 'Renewal At-Risk';
            oppRenList[0].Stage_Comment__c = 'test';
            oppRenList[0].Cancellation_Detail__c = 'Pricing/Cost/Value Related';
            oppRenList[0].Renewal_Cancellation_Reason__c = 'Value/Pricing';
            oppRenList[1].StageName = 'Initiated';
            oppRenList[1].Stage_Comment__c = 'test';
            oppRenList[1].Cancellation_Detail__c = 'Pricing/Cost/Value Related';
            oppRenList[1].Renewal_Cancellation_Reason__c = 'Value/Pricing';
            oppRenList[2].StageName = 'Working';
            oppRenList[2].Stage_Comment__c = 'test';
            oppRenList[2].Cancellation_Detail__c = 'Pricing/Cost/Value Related';
            oppRenList[2].Renewal_Cancellation_Reason__c = 'Value/Pricing';
            update oppRenList;

              try{
                    update oppRenList;
               system.assertEquals(oppRenList.size(),3);
            }
            catch(Exception e){}
                    
            Test.stopTest();
        }
    }
    
    @isTest
    public static void syncStageSubstageNNBTest1(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj) {
            Test.startTest(); 
            List<Opportunity> oppNNBList = [SELECT Id,StageName,Stage_Comment__c,Cancellation_Detail__c,Renewal_Cancellation_Reason__c FROM Opportunity WHERE RecordType.Name = :OPP_NEW_SALES_RT LIMIT 3];
            oppNNBList[0].StageName = 'Qualified';
            oppNNBList[0].Stage_Comment__c = 'test';
            oppNNBList[1].StageName = 'Validate';
            oppNNBList[1].Stage_Comment__c = 'test';
            oppNNBList[2].StageName = 'Final Negotiation';
            oppNNBList[2].Stage_Comment__c = 'test';
            try{      
                update oppNNBList;
                system.assertEquals(oppNNBList.size(),3);
            }
            catch(Exception e){}
            Test.stopTest();
        }
    }

    /*@isTest
    public static void syncStageSubstageNNBTest2(){
        User userObj = [SELECT Id,Name FROM User WHERE IsActive = true AND Department LIKE '%SALES%' AND Title LIKE '%SALES%' LIMIT 1];        
        List<Account> lAccount = [SELECT ID FROM Account LIMIT 1];

        System.runAs(userObj) {

            Test.startTest();

            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
            UtilityTestData.mOpportunityData.put('Name', 'Test Opty 1');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');         
            sObject sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);

            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
            UtilityTestData.mOpportunityData.put('Name', 'Test Opty 2');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');         
            sObject sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);

            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c', 'True');
            UtilityTestData.mOpportunityData.put('Name', 'Test Opty 3');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');         
            sObject sObj2 = new Opportunity();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
    
            List<Opportunity> oppNNBList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2});

            oppNNBList[0].StageName = 'Qualified';
            oppNNBList[0].Stage_Comment__c = 'test';
            oppNNBList[1].StageName = 'Validate';
            oppNNBList[1].Stage_Comment__c = 'test';
            oppNNBList[2].StageName = 'Final Negotiation';
            oppNNBList[2].Stage_Comment__c = 'test';
            try{      
                update oppNNBList;
                system.assertEquals(oppNNBList.size(),3);
            }
            catch(Exception e){}
            Test.stopTest();
        }
    } */

    @isTest
    public static void syncStageSubstageNNBTest2(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        User salesUser = [SELECT Id,Name FROM User WHERE IsActive = true AND Department LIKE '%SALES%' AND Title LIKE '%SALES%' LIMIT 1];
        System.runAs(userObj) {
            Test.startTest(); 
            List<Opportunity> oppNNBList = [SELECT Id,StageName,Stage_Comment__c,Cancellation_Detail__c,Renewal_Cancellation_Reason__c FROM Opportunity WHERE RecordType.Name = :OPP_NEW_SALES_RT LIMIT 3];
            
            oppNNBList[0].Territory2Id = null;
            oppNNBList[0].Champion__c = 'test';
            oppNNBList[0].OwnerId = salesUser.Id;
            oppNNBList[0].Sales_Journey__c = 'Business 360';

            try{      
                update oppNNBList;
                system.assertEquals(oppNNBList.size(),3);
            }
            catch(Exception e){}
            Test.stopTest();
        }
    }       
 
}