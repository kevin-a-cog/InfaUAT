@isTest(SeeAllData=true)
public class internalTopicDiscussionsCtrlTest {
    @isTest
    static void clearMessagesTest() {
        String communityName = label.help_siteName;
        
        String communityId = internalTopicDiscussionsCtrl.getNetworkId(communityName);
        internalTopicDiscussionsCtrl.allTopics(communityId);
        internalTopicDiscussionsCtrl.topicsWithStream(communityId);
        internalTopicDiscussionsCtrl.topicsWithoutStream(communityId);
        internalTopicDiscussionsCtrl.getStreams(communityId);
        internalTopicDiscussionsCtrl.createNewStreams(communityId);
        /*Added by Deeksha Shetty as part of Deployment Fix*/
        topic tp = new topic();
        tp.Name = 'XYZ';
        insert tp;
        internalTopicDiscussionsCtrl.createStream(tp.Id, 'test topic name', 'test topic description', communityId);
    }
    
    
}