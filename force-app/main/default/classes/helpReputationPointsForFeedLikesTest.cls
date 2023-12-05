@isTest

public class helpReputationPointsForFeedLikesTest {
    
    static testmethod void testmethod1(){
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        

        Topic a = new Topic(Name='test9590595',
                            NetworkId=networkId,
                            Description='abcd');
        insert a;
        
        FeedItem feedData = new FeedItem();
        feedData.Title='title';
        feedData.ParentId=a.Id;
        feedData.Body= 'body comment';
        feedData.NetworkScope=networkId;
        feedData.Type='QuestionPost';
        feedData.IsRichText=true;
        insert feedData;
        
        FeedItem feedData1 = new FeedItem();
        feedData1.Title='title';
        feedData1.ParentId=a.Id;
        feedData1.Body= 'body comment';
        feedData1.NetworkScope=networkId;
        feedData1.Type='QuestionPost';
        feedData1.IsRichText=true;
        insert feedData1;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = a.Id;
        cin.Content_type__c = 'Feed Like';
        cin.Type__c = a.Name;
        cin.User__c = UserInfo.getUserId();
        comlist.add(cin);
        
        Community_Interactions__c cin2 = new Community_Interactions__c();
        cin2.Id__c = a.Id;
        cin2.Content_type__c = 'Feed Like';
        cin2.Type__c = a.Name;
        cin2.User__c = UserInfo.getUserId();
        comlist.add(cin2);            
        insert comlist;
        
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedLikesCalloutMock());
            helpReputationPointsForFeedLikes.getParamsFromFlow();
        }
        Catch(Exception e){}            
        test.stopTest();
    }   
    
    
    static testmethod void testmethod2(){
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        

        Topic a = new Topic(Name='test9590595',
                            NetworkId=networkId,
                            Description='abcd');
        insert a;
        
        FeedItem feedData = new FeedItem();
        feedData.Title='title';
        feedData.ParentId=a.Id;
        feedData.Body= 'body comment';
        feedData.NetworkScope=networkId;
        feedData.Type='QuestionPost';
        feedData.IsRichText=true;
        insert feedData;
        
        FeedItem feedData1 = new FeedItem();
        feedData1.Title='title';
        feedData1.ParentId=a.Id;
        feedData1.Body= 'body comment';
        feedData1.NetworkScope=networkId;
        feedData1.Type='QuestionPost';
        feedData1.IsRichText=true;
        insert feedData1;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedLikesCalloutMock());
            helpReputationPointsForFeedLikes.getParamsFromFlow();
        }
        Catch(Exception e){}            
        test.stopTest();
    }   
}