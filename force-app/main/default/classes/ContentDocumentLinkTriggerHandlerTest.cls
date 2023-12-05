/**
* @author Conga Services, gmodica
* @date 20180914
* @version 1.00
* @description Test class for ContentDocumentLinkTriggerHandler called from ContentDocumentLinkAfterInsert Trigger
*/

@isTest
private class ContentDocumentLinkTriggerHandlerTest {
    private static Map<String,String> mDocuSignStatus = new Map<String,String>();
        
    private static Map<String,String> mContentVersion = new Map<String,String>{
        'Title' => 'Test',
        'PathOnClient' => 'test.txt',
        'Origin' => 'H',
    'ContentLocation' => 'S'
    };
        
    private static Map<String,String> mDraftContentVersion = new Map<String,String>{
        'Title' => 'TestDraft',
        'PathOnClient' => 'test.txt',
        'Origin' => 'H',
    'ContentLocation' => 'S'
    };
        
    private static Map<String,String> mFinalContentVersion = new Map<String,String>{
        'Title' => 'TestFinal',
        'PathOnClient' => 'test.txt',
        'Origin' => 'H',
    'ContentLocation' => 'S'
    };     

    private static Map<String,String> mContentDocumentLink = new Map<String,String>{
        'ShareType' => 'V',
        'Visibility' => 'InternalUsers'
    };
        
  @testSetup
    private static void setup() {        
       User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];//<TAX-238> 
        sObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 1');
        UtilityTestData.mAccountData.put('Contract_Company_Status__c', 'Active');
        UtilityTestData.mAccountData.put('Contract_Company_Group__c', 'Customers');
        UtilityTestData.mAccountData.put('Exclude_from_Legal_Sync__c', 'False');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObject sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name','Test Opty');
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        sObject sObj2 = new Contact();
        UtilityTestData.mContactData.put('Name','Test Con1');
        UtilityTestData.mContactData.put('LastName','LastCon');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].id);
        UtilityTestData.mContactData.put('Community_Access__c','Inactive');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Estimation_Summary__c estimationSummary1 = IPUE_TestUtils.createEstimationSummary(false, lOpportunity[0].Id);
        insert estimationSummary1;
        
        sObject legalAgreement = new Legal_Agreement__c();
       // UtilityTestData.mLegalAgreement.put('Exclude_from_Legal_Sync__c',false);
        UtilityTestData.mLegalAgreement.put('Exclude_from_Legal_Sync__c', 'false'); 
        UtilityTestData.mLegalAgreement.put('Account__c', lAccount[0].Id);   
        legalAgreement = UtilityTest.putFieldRecord(legalAgreement, UtilityTestData.mLegalAgreement);
        UtilityTest.makeInsert(new List<sObject>{ legalAgreement });  
        
        sObject docuSignStatus = new dsfs__DocuSign_Status__c();
        mDocuSignStatus.put('Legal_Agreement__c',legalAgreement.Id);
        docuSignStatus = UtilityTest.putFieldRecord(docuSignStatus, mDocuSignStatus);
        UtilityTest.makeInsert(new List<sObject>{ docuSignStatus });
                
        ContentVersion cv = new ContentVersion();
        cv = (ContentVersion)UtilityTest.putFieldRecord((sObject)cv, mContentVersion);
        cv.VersionData = Blob.valueOf('Test');
        UtilityTest.makeInsert(new List<sObject>{ cv });
        //<TAX-238> start
           system.runAs(adminUser){

            Id ProspectAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            
            sObject sObjnew = new Account();
            UtilityTestData.mAccountData.put('Name','TestERP');
            UtilityTestData.mAccountData.put('RecordTypeId', ProspectAccountRecType);
            sObjnew = UtilityTest.putFieldRecord(sObjnew, UtilityTestData.mAccountData); 
            List<Account> lAccountnew = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjnew});                                   
        }//<TAX-238> end

        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 

        sObj = new Quote_Summary__c();
        sObj = UtilityTest.putFieldRecord(sObj, new Map<String,String>{'Quote__c' => lSBQuote[0].Id});
        List<Quote_Summary__c> lSBQuoteSummary = (List<Quote_Summary__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 

    }
    
    @isTest
    private static void testAttachDocumentToLegalAgreement() {
        dsfs__DocuSign_Status__c docuSignStatus = [select Id,Legal_Agreement__c from dsfs__DocuSign_Status__c limit 1];
        System.assertNotEquals(null, docuSignStatus);
        
        Legal_Agreement__c legalAgreement = [select Id from Legal_Agreement__c where Id = :docuSignStatus.Legal_Agreement__c];
        System.assertNotEquals(null, legalAgreement);        
        
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
        System.assertNotEquals(null, cv);
        System.assertNotEquals(null, cv.ContentDocumentId);
        System.assertEquals(1, [select count() from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId]);

        ContentDocumentLink link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', docuSignStatus.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        
        Test.startTest();
        
        UtilityTest.makeInsert(new List<sObject>{ link });
        
        Test.stopTest();
        
        // get all the links and verify that there are two links to the same document, one for the document status and the other for the legal agreement
        List<ContentDocumentLink> links = [select Id, LinkedEntityId, LinkedEntity.Type from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId order by LinkedEntity.Type];
        System.assertEquals(3, links.size());
        System.assertEquals(SObjectType.dsfs__DocuSign_Status__c.name, links[0].LinkedEntity.Type);
        System.assertEquals(SObjectType.Legal_Agreement__c.name, links[1].LinkedEntity.Type);
    }
    
    @isTest
    private static void testAttachDocumentToExistingLegalAgreement() {
        dsfs__DocuSign_Status__c docuSignStatus = [select Id,Legal_Agreement__c from dsfs__DocuSign_Status__c limit 1];
        System.assertNotEquals(null, docuSignStatus);
        
        Legal_Agreement__c legalAgreement = [select Id from Legal_Agreement__c where Id = :docuSignStatus.Legal_Agreement__c];
        System.assertNotEquals(null, legalAgreement);        
        
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
        System.assertNotEquals(null, cv);
        System.assertNotEquals(null, cv.ContentDocumentId);
        System.assertEquals(1, [select count() from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId]);

        ContentDocumentLink link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', legalAgreement.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for legal agreement
        System.assertEquals(2, [select count() from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId]);
        
        link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', docuSignStatus.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        
        Test.startTest();

        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for docuSign status        
        
        Test.stopTest();
        
        // get all the links and verify that there are two links to the same document, one for the document status and the other for the legal agreement
        // no new link was created for the legal agreement as it already existed
        List<ContentDocumentLink> links = [select Id, LinkedEntityId, LinkedEntity.Type from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId order by LinkedEntity.Type];
        System.assertEquals(3, links.size());
        System.assertEquals(SObjectType.dsfs__DocuSign_Status__c.name, links[0].LinkedEntity.Type);
        System.assertEquals(SObjectType.Legal_Agreement__c.name, links[1].LinkedEntity.Type);
    }
    
    @isTest
    private static void testAttachDocumentToEstSummary() {
      
        Estimation_Summary__c estSummary = [select Id from Estimation_Summary__c LIMIT 1];   
        
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
        System.assertNotEquals(null, cv);
        System.assertNotEquals(null, cv.ContentDocumentId);
        System.assertEquals(1, [select count() from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId]);

        ContentDocumentLink link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', estSummary.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        UtilityTest.makeInsert(new List<sObject>{ link });
        
        //creating new content version
        ContentVersion cv1 = new ContentVersion();
        cv1 = (ContentVersion)UtilityTest.putFieldRecord((sObject)cv1, mContentVersion);
        cv1.VersionData = Blob.valueOf('Draft');
        UtilityTest.makeInsert(new List<sObject>{ cv1 });
        
        cv1 = [select Id, ContentDocumentId from ContentVersion where Id=:cv1.Id];
        ContentDocumentLink link1 = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', estSummary.Id);
        mContentDocumentLink.put('ContentDocumentId',cv1.ContentDocumentId);
        link1 = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link1, mContentDocumentLink);
        UtilityTest.makeInsert(new List<sObject>{ link1 });
       
    }
    
    
    @isTest
    private static void sharefileKnowledge() {
        Knowledge__kav newArticle = new Knowledge__kav();
        newArticle.Title = 'title';
        newArticle.UrlName = 'urlName';
        newArticle.Description__c = 'Test Description';
        newArticle.Solution__c = 'Test Solution';
        insert newArticle;
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
        ContentDocumentLink link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', newArticle.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        
        Test.startTest();

        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for Knowledge articles    
        
        Test.stopTest();
    }
    
     @isTest //<TAX-238> Entire Testmethod
    private static void sharefileKnowledgeERPSite() {
        Test.startTest();
        List<Account> lAccount = [SELECT Id FROM Account where name ='TestERP'];
        sObject sObj = new Account(Id = lAccount [0].Id,Peoplesoft_External_ID__c = 'TestErpId');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        lAccount = (List<Account>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
         List<ERP_Company__c> lstErpCustomer = [SELECT Id FROM ERP_Company__c];
        System.assertEquals(lstErpCustomer.size(),1);  
        
        ERP_Site__c erpSite = new ERP_Site__c(ERP_Company__c = lstErpCustomer[0].Id);
        erpSite.Exempt_Status__c = 'Exempt';
        erpSite.Exemption_On_File__c = false;
        Insert erpSite; 

        sObject sobj2 = new Opportunity();
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Direct');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
     // UtilityTestData.mOpportunityData.put('Substage__c', 'Selected');
        UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60) + '');
        sobj2 = UtilityTest.putFieldRecord(sobj2, UtilityTestData.mOpportunityData);        
        List<Opportunity> opp = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sobj2});

        

        sObject sobj3 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',opp[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
        UtilityTestData.mSBQuoteData.put('Sold_to_Account_ERP_Site__c',erpSite.Id);
        sobj3 = UtilityTest.putFieldRecord(sobj3, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> quote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sobj3});

        erpSite = [SELECT Id,Exempt_Status__c FROM ERP_Site__c LIMIT 1];
        erpSite.Exempt_Status_Date_Stamp__c = System.TODAY();
        update erpSite;
        
        Knowledge__kav newArticle = new Knowledge__kav();
        newArticle.Title = 'title';
        newArticle.UrlName = 'urlName';
        newArticle.Description__c = 'Test Description';
        newArticle.Solution__c = 'Test Solution';
        insert newArticle;
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
        ContentDocumentLink link = new ContentDocumentLink();
        mContentDocumentLink.put('LinkedEntityId', erpSite.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);

        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for Knowledge articles    
        
        Test.stopTest();
    }
    @isTest
    private static void sharefileEngagementFromProject() {
    Test.startTest();
    contact con= [select id from contact limit 1];
    Account acc= [select id from account limit 1];
    ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
    ContentDocumentLink link = new ContentDocumentLink();
    String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
    List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<1;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = acc.Id;
            oppty.Type='Direct';
            oppty.CloseDate =  system.today().addDays(2);
            oppty.StageName='Identify';
            oppty.Sales_Play__c='Data Quality';
             opptyList.add(oppty);
         }
        insert opptyList; 
         List<Plan__c> planList = new List<Plan__c>();
        for(integer i=0;i<1;i++){
            Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan '+i;
            planRec.Account__c = acc.Id;
            planRec.Status__c ='Active';
            planList.add(planRec);
        }
        insert planList;
         sObject engagement1 = new Engagement__c();
          Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
          UtilityTestData.mEngagementData.put('Account__c',acc.Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment');//
          UtilityTestData.mEngagementData.put('Plan__c',planList[0].Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
          UtilityTestData.mEngagementData.put('Opportunity__c',opptyList[0].Id);
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          engagement1 = UtilityTest.putFieldRecord(engagement1, UtilityTestData.mEngagementData);     
          List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement1});
            pse__Proj__c pr = new pse__Proj__c();
            pr.Name = 'test Project';
            pr.pse__Project_Manager__c = con.id;
            pr.psa_pm_Engagement__c = lEngagement[0].id;
            pr.pse__Start_Date__c = system.today();
            pr.pse__End_Date__c = system.today()+30;
            pr.pse__Stage__c= 'Planned';
            pr.pse__Opportunity__c = opptyList[0].id;
            insert pr;
        mContentDocumentLink.put('LinkedEntityId', pr.Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        
        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for Knowledge articles    
        
        Test.stopTest();
    }
    @isTest
    private static void sharefileProjectFromEngagement() {
    Test.startTest();
    contact con= [select id from contact limit 1];
    Account acc= [select id from account limit 1];
    ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
    ContentDocumentLink link = new ContentDocumentLink();
    String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
    List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<1;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = acc.Id;
            oppty.Type='Direct';
            oppty.CloseDate =  system.today().addDays(2);
            oppty.StageName='Identify';
            oppty.Sales_Play__c='Data Quality';
             opptyList.add(oppty);
         }
        insert opptyList; 
         List<Plan__c> planList = new List<Plan__c>();
        for(integer i=0;i<1;i++){
            Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan '+i;
            planRec.Account__c = acc.Id;
            planRec.Status__c ='Active';
            planList.add(planRec);
        }
        insert planList;
         sObject engagement1 = new Engagement__c();
          Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
          UtilityTestData.mEngagementData.put('Account__c',acc.Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment');//
          UtilityTestData.mEngagementData.put('Plan__c',planList[0].Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
          UtilityTestData.mEngagementData.put('Opportunity__c',opptyList[0].Id);
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          engagement1 = UtilityTest.putFieldRecord(engagement1, UtilityTestData.mEngagementData);     
          List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement1});
            pse__Proj__c pr = new pse__Proj__c();
            pr.Name = 'test Project';
            pr.pse__Project_Manager__c = con.id;
            pr.psa_pm_Engagement__c = lEngagement[0].id;
            pr.pse__Start_Date__c = system.today();
            pr.pse__End_Date__c = system.today()+30;
            pr.pse__Stage__c= 'Planned';
            pr.pse__Opportunity__c = opptyList[0].id;
            insert pr;
        mContentDocumentLink.put('LinkedEntityId', lEngagement[0].Id);
        mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
        link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
        UtilityTest.makeInsert(new List<sObject>{ link }); // insert link for Knowledge articles    
        
        Test.stopTest();
    }

    @isTest
    private static void updateQuoteSummaryTest(){
        Quote_Summary__c quotSummary = [SELECT Id FROM Quote_Summary__c LIMIT 1];

        Test.startTest();
            ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Title = 'Test' limit 1];
            ContentDocumentLink link = new ContentDocumentLink();
            mContentDocumentLink.put('LinkedEntityId', quotSummary.Id);
            mContentDocumentLink.put('ContentDocumentId',cv.ContentDocumentId);
            link = (ContentDocumentLink)UtilityTest.putFieldRecord((sObject)link, mContentDocumentLink);
            UtilityTest.makeInsert(new List<sObject>{ link });
        Test.stopTest();

        Quote_Summary__c finalQuoteSummary = [SELECT Id,Has_Attachment__c FROM Quote_Summary__c WHERE Id = :quotSummary.Id];
        System.assertEquals(finalQuoteSummary.Has_Attachment__c, true, 'updateQuoteSummaryTest failed');
    }
}