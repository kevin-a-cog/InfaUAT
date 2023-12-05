/*
* Name : helpCoveoVideoDisplayControllerTest
* Author : Deeksha Shetty
* Created Date : Jan 10,2022
* Description : This is a Common test class for helpCoveoVideoDisplayController,helpBlogPostsController,helpArticles_Documents
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

@isTest
public class helpCoveoVideoDisplayControllerTest {
    
    @testSetup static void setup() {
        // Create common test accounts
        List<Topic> testTopics = new List<Topic>();
        for(Integer i=0;i<1;i++) {
            testTopics.add(new Topic(Name = 'XYZ'));
        }
        insert testTopics;        
    }
    
    static testmethod void testmethod1(){
        String token = 'abcd';
        Topic tp = [SELECT Id FROM Topic LIMIT 1];
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpCoveoVideoCalloutMock());
            helpCoveoVideoDisplayController.displayVideos(token,tp.Id);
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    static testmethod void testmethod2(){
        String token = 'abcd';
        Topic tp = [SELECT Id FROM Topic LIMIT 1];
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpCoveoVideoCalloutMock());
            helpBlogPostsController.displayBlogs(tp.Id,token);
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    static testmethod void testmethod3(){
        String token = 'abcd';
        test.startTest();
        try{
			Test.setMock(HttpCalloutMock.class, new helpArticleCalloutMock());            
            Topic tp = [SELECT Id FROM Topic LIMIT 1];           
            helpArticles_Documents.displayArticles(tp.Id,token);
         
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    static testmethod void testmethod4(){
        String token = 'abcd';
        test.startTest();
        try{
			Test.setMock(HttpCalloutMock.class, new helpArticleCalloutMock());            
            Topic tp = [SELECT Id FROM Topic LIMIT 1];           
            helpArticles_Documents.displayDocs(tp.Id,token);
         
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
}