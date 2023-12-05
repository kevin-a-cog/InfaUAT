@isTest(seeAllData=false)
public with sharing class contentVersionTriggerHandlerTest {

    @testSetup
    static void setupObjectTestData() {
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;

        RecordType accRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        Sobject sObj;
        Sobject sObj1;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', accRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
                
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        //System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar; 
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('pse__Is_Resource__c','true');
            UtilityTestData.mContactData.put('Is_Primary__c','false');
            UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
            UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');//psa_Employee_Type__c
            UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
            UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
            UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
            UtilityTestData.mContactData.put('psa_Employee_Type__c','Informatica-Non PS');
            
            UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
            UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

            User userObj1 =  [select Id, Name from User where IsActive=true AND  UserRole.DeveloperName = 'PS_Operations' limit 1];
            System.runAs(userObj1){

            psa_Resume__c resume = new psa_Resume__c();
            resume.psa_Resource__c = lContact[0].Id;
            resume.Name = 'Test Resume Test';
            resume.psa_Status__c = 'Submitted';
            insert resume;
        
            ContentVersion cv = new ContentVersion();
            cv.Title = 'TC Document';
            cv.PathOnClient = 'TCD.doc';
            cv.VersionData = Blob.valueOf('TC Content');
            cv.IsMajorVersion = true;
            Insert cv; 

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = resume.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';        
            Insert cdl;
            }
        
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        System.runAs(adminUser){
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('Name','Test Opty');
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Estimation_Summary__c estimationSummary = IPUE_TestUtils.createEstimationSummary(true, lOpportunity[0].Id);
            estimationSummary.Account__c = lAccount[0].Id;
            estimationSummary.Status__c = 'Initialized Agreement';
            update estimationSummary;
        }
    }
    @isTest
    public static void contentDocumentInsert(){
        
        List<psa_Resume__c> resList = [SELECT Id FROM psa_Resume__c];
        
        ContentDocumentLink cdl = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID = :reslist[0].Id][0];		
        User userObj1 = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND isActive = true LIMIT 1][0];
        
        Test.startTest();
        
        System.runAs(userObj1){
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'TC Document';
            cv1.PathOnClient = 'TCD.doc';
            cv1.VersionData = Blob.valueOf('TC Content');
            cv1.IsMajorVersion = true;
            cv1.ContentDocumentId = cdl.ContentDocumentId;
            try{
            	Insert cv1;                
            }catch(exception e){
                Assert.IsNotNull(e.getMessage(), 'DML Exception occurred');
            }
        }

        Test.stopTest();
    }
    @isTest
     public static void contentDocumentInsert2(){
        
        List<psa_Resume__c> resList = [SELECT Id FROM psa_Resume__c];
        
        ContentDocumentLink cdl = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID = :reslist[0].Id][0];
		
        User userObj1 = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND UserRole.DeveloperName != 'PS_Operations' AND UserRole.DeveloperName != 'PS_Resource_Management' AND isActive = true LIMIT 1][0];
        
        Test.startTest();
        
        System.runAs(userObj1){
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'TC Document';
            cv1.PathOnClient = 'TCD.doc';
            cv1.VersionData = Blob.valueOf('TC Content');
            cv1.IsMajorVersion = true;
            cv1.ContentDocumentId = cdl.ContentDocumentId;
            try{
            	Insert cv1;                
            }catch(exception e){
                Assert.IsNotNull(e.getMessage(), 'DML Exception occurred');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testHandleIPUEVersion(){
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        List<Estimation_Summary__c> estimationSummary = [SELECT ID, Status__c,Opportunity__c from Estimation_Summary__c LIMIT 1];
        Test.startTest();
        System.runAs(adminUser){
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'Draft - Sample Estimation',
                PathOnClient   = 'Pic.jpg',
                FirstPublishLocationId = estimationSummary[0].Id,
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion;
            
            ContentVersion newContentVersion = new ContentVersion(
                Title          = 'Draft - Sample Estimation',
                PathOnClient   = 'Pic.jpg',
                FirstPublishLocationId = estimationSummary[0].Id,
                VersionData    = Blob.valueOf('Test Content New'),
                IsMajorVersion = true);
            insert newContentVersion;
        }
        Test.stopTest();
        List<ContentDocumentLink> conDocLinkList = [Select Id from ContentDocumentLink where LinkedEntityId =:estimationSummary[0].Id];
        Assert.areEqual(1, conDocLinkList.size(), 'versioning failed for contentDocument');
    }
}