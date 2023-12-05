@isTest
public class IPUE_ActivityTimelineCntlrTest {

    @testSetup
    static void setupObjectTestData() {
     	
        IPUE_TestUtils.setupAllData();
       // IPUE_TestUtils.setupFormData();
        
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
       // Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
       // testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        insert testSummary;
        
        //Create Related Feed Item Record
        FeedItem fi = new FeedItem(ParentId = testSummary.Id, Body = 'Test Body1');
        insert fi;
        
        //Create Related Feed Item Record
        FeedItem fi1 = new FeedItem(ParentId = testSummary.Id, Body = 'Test Body2');
        insert fi1;
        
        
        //Create Feed Comment Record
        List<FeedComment>feedComments=new List<FeedComment>();
        feedComments.add(new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment'));
        feedComments.add(new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment'));
        feedComments.add(new FeedComment(FeedItemId = fi.Id, CommentBody = 'Test Comment'));
        feedComments.add(new FeedComment(FeedItemId = fi1.Id, CommentBody = 'Test Comment'));
        feedComments.add(new FeedComment(FeedItemId = fi1.Id, CommentBody = 'Test Comment'));
        insert feedComments;

    }
    @isTest
    public static void getActivitiesTest(){

        Estimation_Summary__c summary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];  
        List<FeedItem>feedsWithOutComments= new List<FeedItem>();
        //Create Related Feed Item Record
        feedsWithOutComments.add(new FeedItem(ParentId = summary.Id, Body = 'Test Body1'));

        //Create Related Feed Item Record
        feedsWithOutComments.add(new FeedItem(ParentId = summary.Id, Body = 'Test Body2'));
       
        insert feedsWithOutComments;
        
        String wrapperJSON = IPUE_ActivityTimelineCntlr.getActivities(summary.Id);
        System.assert(wrapperJSON!=null);
        
        List<FeedItem>feedsWithComments=[SELECT Id,CreatedDate,(SELECT CreatedDate FROM FeedComments ORDER BY CreatedDate ASC)
                                         FROM FeedItem WHERE ParentId = :summary.Id];
        
        IPUE_ActivityTimelineCntlr.ActivityWrapper actFeed1= new IPUE_ActivityTimelineCntlr.ActivityWrapper(feedsWithComments[0]);
        IPUE_ActivityTimelineCntlr.ActivityWrapper actFeed2= new IPUE_ActivityTimelineCntlr.ActivityWrapper(feedsWithComments[1]);

        feedsWithOutComments=[SELECT Id,CreatedDate,(SELECT CreatedDate FROM FeedComments ORDER BY CreatedDate ASC)
                                                    FROM FeedItem WHERE id IN  :feedsWithOutComments];
        
        IPUE_ActivityTimelineCntlr.ActivityWrapper actFeed3= new IPUE_ActivityTimelineCntlr.ActivityWrapper(feedsWithOutComments[0]);
        System.assert(actFeed2.compareTo(actFeed3)==0);
    }
 
}