/*
@created by       : SONIYA CHOUHAN
@created on       : 02/02/2021
@Purpose          : Test class for psa_pm_ContentDocumentLinkTriggerHandler

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public with sharing class psa_pm_ContentDocumentTriggerHandlerTest {
  private static List<Schema.SObjectType> sObjects = 
            new Schema.SObjectType[]{
                                    Bypass_Trigger_Settings__c.SObjectType,
                                    User_Exemptions__c.SObjectType,
                                    Account.SObjectType,
                                    pse__Region__c.SObjectType,
                                    pse__Work_Calendar__c.SObjectType,
                                    Contact.SObjectType,
                                    Product2.SObjectType,
                                    PricebookEntry.SObjectType,
                                    Opportunity.SObjectType,
                                    pse__Proj__c.SObjectType,
                                    pse__Time_Period__c.SObjectType,
                                    pse__Schedule__c.SObjectType,
                                    pse__Permission_Control__c.SObjectType,
                                    PSA_MSA_Code_Mapping__c.SObjectType,
                                    pse__Resource_Request__c.SObjectType,
                                    pse__Assignment__c.SObjectType,
                                    pse__Project_Location__c.SObjectType,
                                    pse__Timecard_Header__c.SObjectType,
                                    Engagement__c.SObjectType,
                                    psa_Resume__c.SObjectType
                                    };   
    
    @testSetup
    static void setupObjectTestData() {
        UnitOfWork uow = new UnitOfWork(sObjects);
        
        //Enable Trigger
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_TimeCard_Trigger__c = true;
        uow.registerNew(trigSetting);

        //Bypass Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);
        
        //Create Account
        Id acctRecordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName  = 'Customer_Account' LIMIT 1].Id;
        Account acct = new Account(Name = 'Test Account', RecordTypeId = acctRecordTypeId);
        uow.registerNew(acct);
        
        //Create Region
        pse__Region__c region = new pse__Region__c();
        uow.registerNew(region);
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        //Create Work Calendar
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        uow.registerNew(defaultWorkCalendar);
        
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        //Create Contact    
        Contact con = new Contact(LastName = 'Test Contact', pse__Resource_Role__c = 'Regional Manager', pse__Is_Resource__c = true, 
                                  Is_Primary__c = false, RecordTypeId = rt.Id, pse__Salesforce_User__c = userObj.Id,
                                 pse__Is_Resource_Active__c = true, pse__Default_Cost_Rate__c = 10, psa_Target_Bill_Rate__c = 10
                                 );
        uow.registerRelationship(con, Contact.pse__Work_Calendar__c, defaultWorkCalendar);
        uow.registerRelationship(con, Contact.pse__Region__c, region);
        uow.registerNew(con, Contact.AccountId, acct);
        
        //Create Product
        Product2 prod = new Product2(Name = 'Test', Offering_Type__c='Professional Services');
        uow.registerNew(prod);

        //Activate PriceBook
        Id pricebookId = Test.getStandardPricebookId();         
        Pricebook2 pb = new Pricebook2(Id = pricebookId,IsActive = True);
        update pb;
        
        //Create PriceBook Entry
        PricebookEntry pbe = new PricebookEntry(UnitPrice=100, CurrencyIsoCode='USD',IsActive=true);
        uow.registerRelationship(pbe, PricebookEntry.Pricebook2Id, pb);
        uow.registerNew(pbe, PricebookEntry.Product2Id, prod);
        
        //Create Opportunity
        Opportunity opp = new Opportunity(Name = 'Test opportunity',Type = 'Direct', CurrencyIsoCode = 'USD', StageName = 'Validate',
                                          CloseDate = System.today().addDays(2));
        uow.registerRelationship(opp, Opportunity.Pricebook2Id, pb);
        uow.registerNew(opp, Opportunity.AccountId, acct);
        
        //Create Project
        pse__Proj__c proj = new pse__Proj__c(pse__Project_Type__c = 'Customer Project', pse__Allow_Self_Staffing__c = true, pse__Is_Active__c = true,
                                            psa_pm_Require_Product_On_Timecards__c = false, pse__Start_Date__c = System.today().addDays(1), 
                                            pse__End_Date__c = System.today().addDays(10));
        uow.registerRelationship(proj, pse__Proj__c.pse__Project_Manager__c, con);
        uow.registerRelationship(proj, pse__Proj__c.pse__Opportunity__c, opp);
        uow.registerNew(proj, pse__Proj__c.pse__Account__c, acct);
        
		//Create Time period
        pse__Time_Period__c tp = new pse__Time_Period__c(pse__Start_Date__c = System.today(), pse__End_Date__c = System.today(), pse__Type__c = 'Quarter');
        uow.registerNew(tp);
        
        //Create Schedule
        pse__Schedule__c sch = new pse__Schedule__c(pse__Monday_Hours__c = 8, pse__Tuesday_Hours__c = 8, pse__Wednesday_Hours__c = 8,
                                                   	pse__Thursday_Hours__c = 8, pse__Friday_Hours__c = 8, pse__Saturday_Hours__c = 8,
                                                    pse__Sunday_Hours__c = 8, pse__Start_Date__c = System.today().addDays(1),
                                                    pse__End_Date__c = System.today().addDays(10));
        uow.registerNew(sch);
        
        //Create Permission Controls
        pse__Permission_Control__c pc1 = new pse__Permission_Control__c(pse__Staffing__c = true, pse__Timecard_Ops_Edit__c = true,pse__User__c = userObj.Id, 
                                                                        pse__Cascading_Permission__c = true, pse__Timecard_Entry__c = true);
        uow.registerNew(pc1, pse__Permission_Control__c.pse__Project__c, proj);
        
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c(pse__Staffing__c = true, pse__Timecard_Ops_Edit__c = true,pse__User__c = userObj.Id, 
                                                                        pse__Cascading_Permission__c = true, pse__Timecard_Entry__c = true,
                                                                        pse__Resource_Request_Entry__c = true);
        uow.registerNew(pc2, pse__Permission_Control__c.pse__Project__c, proj);
        	
        //Create PSA MSA code mapping
        PSA_MSA_Code_Mapping__c psaMsaCode = new PSA_MSA_Code_Mapping__c(Name = 'Test Name');
        uow.registerNew(psaMsaCode);
            
        //Create Resource Request
        pse__Resource_Request__c rr = new pse__Resource_Request__c(pse__Start_Date__c = System.today().addDays(1),PSA_RM_Assignment_Type__c = 'Customer Billable',
                                                                   pse__End_Date__c = System.today().addDays(10),psa_rm_Billable__c = true,
                                                                   pse__SOW_Hours__c = 8, pse__Resource_Role__c = 'Consultant');
        uow.registerRelationship(rr, pse__Resource_Request__c.pse__Project__c, proj);
        uow.registerRelationship(rr, pse__Resource_Request__c.pse__Opportunity__c, opp);
        uow.registerRelationship(rr, pse__Resource_Request__c.pse__Staffer_Resource__c, con);
        uow.registerRelationship(rr, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c, psaMsaCode);
        uow.registerRelationship(rr, pse__Resource_Request__c.pse__Region__c, region);
        uow.registerRelationship(rr, pse__Resource_Request__c.psa_rm_Original_Opportunity__c, opp);
        uow.registerNew(rr, pse__Resource_Request__c.pse__Resource__c, con);
          
        //Create Assignments
        pse__Assignment__c assgmt1 = new pse__Assignment__c(Name = 'Test Assignment', pse__Planned_Hours__c = 7,
                                                            pse__Bill_Rate__c = 0, pse__Is_Billable__c = true, pse__Role__c = 'Senior Consultant',
                                                            pse__Cost_Rate_Amount__c = 10);
        uow.registerRelationship(assgmt1, pse__Assignment__c.pse__Project__c, proj);
        uow.registerRelationship(assgmt1, pse__Assignment__c.pse__Schedule__c, sch);
        uow.registerRelationship(assgmt1, pse__Assignment__c.pse__Resource_Request__c, rr);
        uow.registerNew(assgmt1, pse__Assignment__c.pse__Resource__c, con);
           
        pse__Assignment__c assgmt2 = new pse__Assignment__c(Name = 'Test Assignment', pse__Planned_Hours__c = 7,
                                                            pse__Bill_Rate__c = 0, pse__Is_Billable__c = true, pse__Role__c = 'Senior Consultant',
                                                            pse__Cost_Rate_Amount__c = 10);
        uow.registerRelationship(assgmt2, pse__Assignment__c.pse__Project__c, proj);
        uow.registerRelationship(assgmt2, pse__Assignment__c.pse__Schedule__c, sch);
        uow.registerRelationship(assgmt2, pse__Assignment__c.pse__Resource_Request__c, rr);
        uow.registerNew(assgmt2, pse__Assignment__c.pse__Resource__c, con);
        
        //Create Project location
        pse__Project_Location__c location = new pse__Project_Location__c(pse__End_Date__c = system.today(), pse__Start_Date__c = system.today().addDays(-6),
                                                                         psa_pm_Primary__c = true);
        uow.registerNew(location, pse__Project_Location__c.pse__Project__c, proj);
          
        //Create Timecard Header
        pse__Timecard_Header__c tch = new pse__Timecard_Header__c(pse__End_Date__c = system.today(), pse__Start_Date__c = system.today().addDays(-6),
                                                                  pse__Status__c = 'Saved', psa_pm_Project_Portfolio_Manager__c = userObj.Id,
                                                                  pse__Approver__c = userObj.Id);
        uow.registerRelationship(tch, pse__Timecard_Header__c.pse__Project__c, proj);
        uow.registerRelationship(tch, pse__Timecard_Header__c.pse__Assignment__c, assgmt1);
        uow.registerRelationship(tch, pse__Timecard_Header__c.pse__Primary_Project_Location__c, location);
        uow.registerNew(tch, pse__Timecard_Header__c.pse__Resource__c, con);        	
        	
        //Create PSA Record Type Engagement
        Id psaEngRecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Professional_Services_SOW_Review').getRecordTypeId();
        Engagement__c eng = new Engagement__c(RecordTypeId = psaEngRecordTypeId, Name = 'Test Eng', psa_pm_Version__c='Proposal' );
        uow.registerNew(eng, Engagement__c.Opportunity__c,opp);
        
        //Create Resume
        psa_Resume__c resume = new psa_Resume__c(Name = 'test resume', psa_Status__c = 'Submitted');
        uow.registerNew(resume);
        
        //Commit to the database
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
        
    }
    
    @isTest
    public static void contentDocumentInsert(){
        List<pse__Proj__c> projList = [SELECT Id FROM pse__Proj__c];
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument];
        Test.startTest();
        conDocList[0].Title = 'Test Doc';
        update conDocList;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = projList[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        
        Insert cdl;
        Delete cdl;
        Delete conDocList;
        projList = [SELECT Id,PSA_PM_Has_Attachment__c FROM pse__Proj__c];
        Assert.IsFalse(projList[0].PSA_PM_Has_Attachment__c, 'Has attachment updated');
        Test.stopTest();
    }
    @isTest
    public static void contentDocumentInsertForTimeCard(){
        List<pse__Timecard_Header__c > tcList = [SELECT Id FROM pse__Timecard_Header__c ];
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TC Document';
        cv.PathOnClient = 'TCDOC.pdf';
        cv.VersionData = Blob.valueOf('TC Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'TC2Document';
        cv1.PathOnClient = 'RCD2.pdf';
        cv1.VersionData = Blob.valueOf('TC2 Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tcList[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        
        Insert cdl;
        Delete cdl;
        Delete conDocList;
        tcList = [SELECT Id,PSA_TM_Has_Attachments__c FROM pse__Timecard_Header__c];
        Assert.IsFalse(tcList[0].PSA_TM_Has_Attachments__c, 'Has attachment updated');        
        Test.stopTest();
    }
    @isTest
    public static void contentDocumentDelete(){
        List<pse__Proj__c> projList = [SELECT Id FROM pse__Proj__c];
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = projList[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        
        Insert cdl;
        Delete conDocList;
        projList = [SELECT Id,PSA_PM_Has_Attachment__c FROM pse__Proj__c];
        Assert.IsFalse(projList[0].PSA_PM_Has_Attachment__c, 'Has attachment updated');
        Test.stopTest();
    }
    @isTest
    public static void contentDocumentDeleteForTC(){
        List<pse__Timecard_Header__c > tcList = [SELECT Id FROM pse__Timecard_Header__c ];
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TC Document';
        cv.PathOnClient = 'TCD.pdf';
        cv.VersionData = Blob.valueOf('TC Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tcList [0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        
        Insert cdl;
        Delete conDocList;
        
		tcList = [SELECT Id,PSA_TM_Has_Attachments__c FROM pse__Timecard_Header__c];
        Assert.IsFalse(tcList[0].PSA_TM_Has_Attachments__c, 'Has attachment updated');        
        Test.stopTest();
    }

    @isTest
    public static void preventEngagementFileCreationTest(){
        List<Engagement__c> engList = [SELECT Id FROM Engagement__c LIMIT 1];
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test Group abcd',CollaborationType = 'Public');
        insert cg;
        psa_pm_ContentDocumentLinkTriggerHelper.engFileSharingGrpId = cg.Id;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TC Document';
        cv.PathOnClient = 'TCD.pdf';
        cv.VersionData = Blob.valueOf('TC Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = engList[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';        
        Insert cdl;

        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'TC1 Document';
        cv1.PathOnClient = 'TCD1.pdf';
        cv1.VersionData = Blob.valueOf('TC Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = engList[0].Id;
        cdl1.ContentDocumentId = conDocId;
        cdl1.shareType = 'V';        
        try{
         Insert cdl1;   
        }
        catch(Exception e){
            Assert.IsNotNull(e.getMessage(), 'DML Exception occurred');
        }
        
        Test.stopTest();
    }
    
     @isTest
    public static void validationOnResume(){   
        psa_Resume__c resume = [SELECT Id FROM psa_Resume__c LIMIT 1];
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test Group abcd123',CollaborationType = 'Public');
        insert cg;
        psa_pm_ContentDocumentLinkTriggerHelper.rmoGroupId = cg.Id;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TC Document';
        cv.PathOnClient = 'TCD.pdf';
        cv.VersionData = Blob.valueOf('TC Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument];
        conDocList[0].Title = 'Test Doc';
        update conDocList;
        
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = resume.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';        
        Insert cdl;
        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :resume.Id LIMIT 1];
		Assert.IsTrue(cdlList.size() > 0, 'Content Document link created for Resume');
    }
}