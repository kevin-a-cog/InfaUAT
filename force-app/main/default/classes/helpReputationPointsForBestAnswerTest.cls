@isTest

public class helpReputationPointsForBestAnswerTest {
    
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

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'test body';
        fc.FeedItemId = feedData.Id;
        insert fc;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.getParamsFromFlow(mockDataList);
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
        feedData.CreatedById = UserInfo.getUserId();
        insert feedData;
        
        FeedItem feedData1 = new FeedItem();
        feedData1.Title='title';
        feedData1.ParentId=a.Id;
        feedData1.Body= 'body comment';
        feedData1.NetworkScope=networkId;
        feedData1.CreatedById = UserInfo.getUserId();
        feedData1.Type='QuestionPost';
        feedData1.IsRichText=true;
        insert feedData1;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        TopicAssignment ta1 = new TopicAssignment(topicId = a.Id, entityId = feedData1.Id, NetworkId=networkId);
        insert ta1;

        List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = a.Id;
        cin.Content_type__c = 'Feed Best Answer';
        cin.Type__c = a.Name;
        cin.User__c = UserInfo.getUserId();
        comlist.add(cin);
        
        Community_Interactions__c cin2 = new Community_Interactions__c();
        cin2.Id__c = a.Id;
        cin2.Content_type__c = 'Feed Best Answer';
        cin2.Type__c = a.Name;
        cin2.User__c = UserInfo.getUserId();
        comlist.add(cin2);            
        insert comlist;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.getParamsFromFlow(mockDataList);
        }
        Catch(Exception e){}            

        test.stopTest();
    }   
    
    static testmethod void testmethod3(){
        
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

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'test body';
        fc.FeedItemId = feedData.Id;
        insert fc;
        
        delete fc;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.getParamsFromFlow(mockDataList);
        }
        Catch(Exception e){}            

        test.stopTest();
    }   
    
    static testmethod void testmethod4(){
        
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
        feedData.Status='PendingReview';
        insert feedData;
        
        feedData.Status='Published';
        update feedData;

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'test body';
        fc.FeedItemId = feedData.Id;
        fc.Status = 'PendingReview';
        insert fc;
        
        fc.Status = 'Published';
        update fc;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
     
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.getParamsFromFlow(mockDataList);
        }
        Catch(Exception e){}            

        test.stopTest();
    }   
    
    static testmethod void testmethod5(){
        
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
        feedData.Status='PendingReview';
        insert feedData;
        
        feedData.Status='Published';
        update feedData;

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'test body';
        fc.FeedItemId = feedData.Id;
        fc.Status = 'PendingReview';
        insert fc;
        
        fc.Status = 'Published';
        update fc;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
        
		delete fc;
        delete feedData;
        
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.getParamsFromFlow(mockDataList);
        }
        Catch(Exception e){}            

        test.stopTest();
    }   
    
    static testmethod void testmethod6(){
        
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

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'test body';
        fc.FeedItemId = feedData.Id;
        insert fc;
        
        TopicAssignment ta = new TopicAssignment(topicId = a.Id, entityId = feedData.Id, NetworkId=networkId);
        insert ta;
        
        List<helpReputationPointsForBestAnswer.ReputationPointsWrapper> mockDataList = new List<helpReputationPointsForBestAnswer.ReputationPointsWrapper>();
        helpReputationPointsForBestAnswer.ReputationPointsWrapper mockData = new helpReputationPointsForBestAnswer.ReputationPointsWrapper();

        List<TopicAssignment> TopicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentList.add(ta);
        mockData.TopicAssignmentList = TopicAssignmentList; 
        mockDataList.add(mockData);
        List<Id> bestCommentID = new List<Id>();
		bestCommentID.add(fc.Id);
        Map<Id, Id> feedTopicIdMap = new Map<Id, Id>();
        feedTopicIdMap.put(feedData.Id, a.Id);
        Set<String> topicIds = new Set<String>();
        topicIds.add('testId');
        
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpReputationFeedBestAnswerCalloutMock());
            helpReputationPointsForBestAnswer.executeCommentCount(bestCommentID, feedTopicIdMap, topicIds);
        }
        Catch(Exception e){}            

        test.stopTest();
    }   
    
}