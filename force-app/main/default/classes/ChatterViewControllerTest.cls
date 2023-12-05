/*
Class:  ChatterViewControllerTest
        @Author:        Jiju
        @Created Date:  18/02/2022
        @Description:   Test Class for ChatterViewController Class.

Change History:
*/
@isTest
private class ChatterViewControllerTest {
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mChannelProgramData.put('Name','Test Channel Program');
        sObject channelProgramObj = new ChannelProgram();
        channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
        List<ChannelProgram> channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj});
    }
    
    /*
     * this test method checks if feed is enabled for an object and return reponse
    */
    @isTest
    static void testObjectWithFeedEnabled(){
        Id accountId = [Select Id from Account limit 1].Id;
        Map<String,Object> response = ChatterViewController.checkObjectSupportsFeed(accountId,false);
        System.assertEquals(response.get('isFeedEnabled'), true, 'Assert failed because isFeedEnabled is false for Account');
    }
    
    /*
     * this test method checks if feed is enabled for an object and return reponse
    */
    @isTest
    static void testObjectWithoutFeedEnabled(){
        Id channelProgramId = [Select Id from ChannelProgram limit 1].Id;
        Map<String,Object> response = ChatterViewController.checkObjectSupportsFeed(channelProgramId,false);
        System.assertEquals(response.get('isFeedEnabled'), false, 'Assert failed because isFeedEnabled is true for channel program');
    }
    
    /*
     * this test method checks if feed is not enabled creates feedMeta record and returns response for a record Id passed
    */
    @isTest
    static void testObjectWithoutFeedEnabledExistingFeedMeta(){
        Id channelProgramId = [Select Id from ChannelProgram limit 1].Id;
        ChatterViewController.checkObjectSupportsFeed(channelProgramId,false);
        Map<String,Object> response = ChatterViewController.checkObjectSupportsFeed(channelProgramId,false);
        List<Feed_Meta__c> feedMetaList = [Select Id from Feed_Meta__c Limit 1];
        System.assertEquals(response.get('feedMetaId'), feedMetaList[0].Id, 'Assert failed because feedMeta not created or doesnt match');
    }
}