@isTest
private class UserStoryPdfRendererControllerTest {
    @isTest
    static void testControllerInitialization() {
        // Create test data
        copado__User_Story__c testUserStory = new copado__User_Story__c(copado__User_Story_Title__c= 'Test Story');
        insert testUserStory;

        System.currentPageReference().getParameters().put('id', testUserStory.Id);        
        UserStoryPdfRendererController controller = new UserStoryPdfRendererController();

        System.assertEquals(testUserStory.Id, controller.userstoryVar.Id);
    }

}