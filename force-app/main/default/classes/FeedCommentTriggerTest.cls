@isTest
public class FeedCommentTriggerTest {
    
    public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static   Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static   Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();

    //I2RT-4422
    @testSetup
    static void setupObjectTestData() {
        
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
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }

    //I2RT-4422
    @isTest
    static void testSupportEscalation(){
        Account acc = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];

        EngagementService engService = new EngagementService();
        Engagement__c engagement = EngagementService.createSupportEscalation(acc.Id, 'Test Engagement', 'P2', 'Hot', 'Customer', 'Escalation', 'details', '');
        insert engagement;

        Test.startTest();
        //Create Related Feed Item Record
        FeedItem feedItem = new FeedItem(ParentId = engagement.Id, Body = 'Test Body');
        insert feedItem;
        FeedComment feedComment = new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test Comment');
        insert feedComment;
        Test.stopTest();
    }

    @isTest
    public static void afterInsertTest(){
        //Parent Record
        Account acc = new Account(Name = 'Test Account',BillingCountry='US',ShippingCountry='US');
        insert acc;
        
        //Create Related Feed Item Record
        FeedItem fi = new FeedItem(ParentId = acc.Id, Body = 'Test Body');
        insert fi;
        
        //Create Feed Comment Record
        FeedComment fc = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        FeedComment fc1 = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        FeedComment fc2= new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        FeedComment fc3 = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        FeedComment fc4 = new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment');
        insert fc;
		insert fc1;
        insert fc2;
        insert fc3;
        insert fc4;
        
        //Get Feed Comment Record
        FeedComment objFC = [Select Id, CommentBody, FeedItemId, ParentId FROM FeedComment LIMIT 1];
        
        //Check Feed Comment Parent Id
        System.assertEquals(objFC.ParentId, acc.Id);
    }
}