@istest
public class MSTeamsServiceControllerTest {
     @isTest
    public static void testAllMethods() {
         Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        SObject sObj1;
        
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
        
        sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('origin', 'Web');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c', 'Callback');
      //  UtilityTestData.mCase.put('Next_Action_Owner__c', 'Case Owner');
        UtilityTestData.mCase.put('Priority ', 'P1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.startTest();
         Test.setMock(HTTPCalloutMock.class, new CalloutRestMock());
        MSTeamsServiceController.doCallout_instantmeeting(cases[0].Id, 'MSTeam_Group_Chat_Id__c', 'Case_Teams__r', 'email__c', 'Instant Meeting', 'eventSubject');
        MSTeamsServiceController.doCallout_CreateGroupChat(cases[0].Id, 'MSTeam_Group_Chat_Id__c', 'Case_Teams__r', 'email__c', 'Group Chat', 'eventSubject');
        MSTeamsServiceController.doCallout_Channel('channelInput','Add Channel Members');
        MSTeamsServiceController.ChannelInputPayLoad oChannelInputPayLoad = new MSTeamsServiceController.ChannelInputPayLoad();
        
        Test.stopTest();
        
    }

}