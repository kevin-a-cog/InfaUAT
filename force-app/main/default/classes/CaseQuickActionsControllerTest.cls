@isTest
public class CaseQuickActionsControllerTest {
    
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;       

        Id OperationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        Id CustomerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id SupportAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        Id ServiceAppointmentOperationsRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Operations').getRecordTypeId();

        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecordTypeId);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test1 Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecordTypeId);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+110+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //Create a TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //Create Contact record
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
        UtilityTestData.mContactData.put('Email','test@test.com');
        UtilityTestData.mContactData.put('TimeZone_Lookup__c',lTimezone[0].Id);
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',CustomerContactRecordTypeId);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //Create Case
        sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Success_Offering__c', 'Premium Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Axon Data Governance');
        sObj.put('Version__c', '4.3.4');
        //sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'New');
        sObj.put('Environment__c', 'PROD');
        sObj.put('Next_Steps__c', 'Test Nest Steps');
        sObj.put('Problem_Statement__c', 'Test Problem Statement');
        sObj.put('RecordTypeId',OperationsCaseRecordTypeId);
        sObj.put('AccountId', lNewCustomerAccount[0].Id);
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

    }
    

    @isTest
    static void testgetEmailBody(){
        Case c = [Select Id,ContactId from Case LIMIT 1];
        String templateName = 'Request additional Info';
        Id caseId = c?.Id;
        Id contactId = c?.ContactId;
        String parsedTemplateContent = '';
        Test.startTest();

        parsedTemplateContent = CaseQuickActionsController.getEmailBody(caseId, templateName);
        System.assert(String.isNotEmpty(parsedTemplateContent), 'No Email templates found!');

        Contact con = new Contact(Id = contactId, INFA_Language__c = 'Dutch');
        update con;
        parsedTemplateContent = CaseQuickActionsController.getEmailBody(caseId, templateName);
        System.assert(String.isNotEmpty(parsedTemplateContent), 'No Email templates found!');

        con.INFA_Language__c = 'English';
        update con;
        parsedTemplateContent = CaseQuickActionsController.getEmailBody(caseId, templateName);
        System.assert(String.isNotEmpty(parsedTemplateContent), 'No Email templates found!');

        Test.stopTest();
    }

    @isTest
    static void testcreateCaseCommentRecord(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        Case c = new Case(Id = caseId, Status = 'Solution');
        Test.startTest();
        update c;
        CaseQuickActionsController.createCaseCommentRecord(caseId, 'Test case comment', '');
        CaseQuickActionsController.createCaseCommentRecord(caseId, 'Test case comment', 'Decline Solution');
        Test.stopTest();
    }

    @isTest
    static void testcheckopenjiras(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        Test.startTest();
        CaseQuickActionsController.checkopenjiras(caseId);
        Test.stopTest();
    }

    @isTest
    static void updateCaseStatus(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        Test.startTest();
        CaseQuickActionsController.updateCaseStatus(caseId, 'Research', 'Test case comment');
        Test.stopTest();
    }

    @isTest
    static void testRenderTemplate(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;
        String templateContent = 'Test description of {{{Case.Description}}} and created on {{{Case.CreatedDate}}}.';
        String timeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]?.TimeZoneSidKey;
        String formattedDateTime = 'dd-MMMMM-yyyy hh:mm a z';
        Test.startTest();
        CaseQuickActionsController.renderTemplate(caseId, templateContent, timeZoneName, formattedDateTime);
        Test.stopTest();
    }
        
}