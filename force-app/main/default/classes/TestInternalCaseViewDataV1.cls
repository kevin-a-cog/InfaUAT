/*
Class:          BusinessDaysCalculationTest
@Author:        Aishwarya Badri
@Created Date:  15-Mar-2021
@Description:   Test class to BusinessDaysCalculation

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class TestInternalCaseViewDataV1 {
    
    @testSetup
    static void setupObjectTestData() {
        //Customer Account
        sObject Account = new Account();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();        
        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        //   List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Support Account
        sObject Account2 = new Account();
        Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();        
        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId2);
        Account2 = UtilityTest.putFieldRecord(Account2, UtilityTestData.mAccountData);
        
        List<Account> lsupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account2});
        
        //Contact
        sObject Contactrec = new Contact();
        UtilityTestData.mContactData.put('AccountId', lsupportAccount[0].Id);
        Contactrec = UtilityTest.putFieldRecord(Contactrec, UtilityTestData.mContactData);                   
        Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);
        List<Contact> lContact = new List<Contact>();
        System.runAs(userByRole.get('Admin')){
            lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contactrec});
        }
        
        
        
        //Case
        sObject Caserec = new Case();
        UtilityTestData.mCase.put('AccountId',lsupportAccount[0].Id);
        UtilityTestData.mCase.put('ContactId',lContact[0].Id);  
        Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
        List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec});  
        
        //Case Contact
        sObject Casecon = new Case_Contact__c();
        UtilityTestData.mCaseContact.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mCaseContact.put('Email__c','test123@test.com');  
        Casecon = UtilityTest.putFieldRecord(Casecon, UtilityTestData.mCaseContact);
        System.debug('Casecon-rec before insert->'+Casecon);
        List<Case_Contact__c> lcasecon = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{Casecon});   
        System.debug('Casecon-rec after insert->'+lcasecon);
        
        
    }
    
    
    static testMethod void testManageCaseContacts(){
        
        List<Case> c=new List<Case>([select Id,CaseNumber from Case Limit 1]);
        InternalCaseViewDataV1 datav1 = new InternalCaseViewDataV1();
        datav1.bIsCaseComment=false;
        datav1.bIsEmail=false;
        datav1.bIsAttachment=false;
        datav1.bIsWebex=false;
        datav1.bIsCall=false;
        datav1.bIsSubCase=false;
        datav1.bIsFeedActivity=false;
        datav1.redId='001';
        datav1.type='Call';
        datav1.createdAt=Date.newInstance(2021, 12, 25);
        datav1.commentBody='test comment body';
        datav1.relatedCase=c[0];
        
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.FromAddress = 'test123@informatica.com';        
        //emailMessage1.HtmlBody = email.htmlBody;
        emailMessage1.TextBody ='email body text';
        emailMessage1.Incoming = false;
        emailMessage1.Subject = 'email.subject';
        emailMessage1.MessageDate=System.now(); 
        
        insert emailMessage1;
        Attachment attachment = new Attachment();
        
        attachment.Name = 'attachment1';
        
        attachment.Body = blob.valueOf('my attachment text');
        attachment.ParentId = emailMessage1.Id;
        insert attachment;
        datav1.msg=emailMessage1;
        datav1.attachment=attachment;
         datav1.webex = new ActivityHistory();
            datav1.call = new ActivityHistory();
        datav1.feed=new feeditem();
        datav1.formattedDate=Date.newInstance(2021, 12, 25).format();
        
        
    }
}