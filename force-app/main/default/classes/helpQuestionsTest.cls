/*
* Name         :   helpQuestionsTest
* Author       :   Utkarsh Jain
* Created Date :   14-FEB-2022
* Description  :   Test class for helpQuestion class.

Change History
*****************************************************************************************************************************
Modified By            Date            Jira No.            Description                                                   Tag
*****************************************************************************************************************************
Utkarsh Jain           15-JAN-2021     Utopia-ph-3         Initial version.                                              NA
Deeksha Shetty         08 May 2023     I2RT-8345          Ask a Question - Email Notification - Issue observed           T1
                                                          in New and Update Notification email template
Utkarsh Jain           04-May-2023     I2RT-8305           New product is getting created while tagging the discussion.  T2 
*/
@isTest
public with sharing class helpQuestionsTest {
    
    static testmethod void testmethodfordiscussion(){
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
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
        helpQuestions.getDiscussion(networkId, '');
        
        try{
            Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
            helpQuestions.getDiscussion(null, null);
        }catch(Exception ex){}
        Test.stopTest();
        
    }
    
    @isTest
    static void saveQuestionPost(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        system.runAs(thisUser){
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

            String tempString = 'Some test';
            Blob tempBlob = Blob.valueOf(tempString);
            String textBase64 = EncodingUtil.base64Encode(tempBlob);
            List<helpQuestions.attachmentToList> attachmentList = new List<helpQuestions.attachmentToList>();
            helpQuestions.attachmentToList attachmentObj = new helpQuestions.attachmentToList();
            attachmentObj.filename = 'testFilename.jpg';
            attachmentObj.base64 = textBase64;
            attachmentList.add(attachmentObj);
            String fileListStr = JSON.serialize(attachmentList);
            
            Test.startTest();
            helpQuestions.saveQuestionPost(thisUser.Id, networkId, feedData.ParentId, 'title', 'body <p><img src="Test"></p> <br> <span></span> <strong></strong> <em></em> <strike></strike>',fileListStr);
            try{
                /* T1 starts*/
                Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
                helpQuestions.saveQuestionPost(null, null, null, 'title', 'body',null);
                /* T1 ends*/
            }catch(Exception ex){
                
            }
            Test.stopTest();
        } 
    }
    
    @isTest
    static void saveQuestionPostToTopic(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        system.runAs(thisUser){
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
            
            TopicAssignment feedData1 = new TopicAssignment();
            feedData1.EntityId=feedData.Id;
            feedData1.NetworkId=networkId;
            feedData1.TopicId=a.Id;
            insert feedData1;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
            helpQuestions.saveQuestionPostToTopic(feedData.Id, networkId, feedData1.TopicId);
            try{
                Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
                helpQuestions.saveQuestionPostToTopic(null, networkId, null);
            }catch(Exception ex){
                
            }
            Test.stopTest();
        } 
    }
    
    
    @isTest(seealldata=true)
    static void saveAttachemtnsTest(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test66788',
                            NetworkId=networkId,
                            Description='abcde');
        insert a;
        
        FeedItem feedData = new FeedItem();
        feedData.Title='title';
        feedData.ParentId=a.Id;
        feedData.Body= 'body comment';
        feedData.NetworkScope=networkId;
        feedData.Type='QuestionPost';
        feedData.IsRichText=true;
        insert feedData;
        
        String tempString = 'Some test';
        Blob tempBlob = Blob.valueOf(tempString);
        String textBase64 = EncodingUtil.base64Encode(tempBlob);
        List<helpQuestions.attachmentToList> attachmentList = new List<helpQuestions.attachmentToList>();
        helpQuestions.attachmentToList attachmentObj = new helpQuestions.attachmentToList();
        attachmentObj.filename = 'testFilename.jpg';
        attachmentObj.base64 = textBase64;
        attachmentList.add(attachmentObj);
        String fileListStr = JSON.serialize(attachmentList);
        
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
            helpQuestions.uploadFile(fileListStr, feedData.id);
        }catch(Exception ex){}
        try{
            // helpQuestions.createContentVersion(null, null);
        }catch(Exception ex){}
        helpQuestions.uploadFile(fileListStr, feedData.id);
        Test.stopTest();
    }

    @isTest(seealldata=true)
    static void deleteHashtagTopicTest(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test9590595',
                            NetworkId=networkId,
                            Description='abcde');
        insert a;
        Topic b = new Topic(Name='test12221000',
                            NetworkId=networkId,
                            Description='abcdef');
        insert b;
        List<Topic> topicList = new List<Topic>();
        topicList.add(a);
        Test.startTest();
        try{
            // Tag 2 Start
            helpQuestions.deleteHashtagTopic(topicList, networkId);
            // Tag 2 End
        }catch(Exception ex){

        }
        Test.stopTest();
    }
    
}