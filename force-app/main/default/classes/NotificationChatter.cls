/*
    @created by       : balajip
    @created on       : 05/23/2022
    @Purpose          : Chatter notification
    @Testclass        : 
    @JIRA             : 

Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
balajip        06/14/2022  I2RT-6431   T01     To fix the error that is thrown when chatter post 
                                                    creation is initiated from portal user context
*/
public with sharing class NotificationChatter extends Notification {
    public NotificationChatter() {

    }

    public override void send(){
        for (CriteriaInfo criteriaInfo : setCriteriaInfo){
            Set<String> setTargetUserId = criteriaInfo.setUserId;
            System.debug('NotificationChatter, send, setTargetUserId = ' + setTargetUserId);

                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                messageBodyInput.messageSegments.add(ChatterService.inputText(criteriaInfo.message.bodyText));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

            //T01 - at mention the users
            for(String targetUserId : setTargetUserId){
                //System.debug('NotificationChatter, send, targetUserId = ' + targetUserId);
                messageBodyInput.messageSegments.add(ChatterService.inputSpace());
                messageBodyInput.messageSegments.add(ChatterService.inputMention(targetUserId));
            }

                      
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = recordId; //T01
            feedItemInput.body = messageBodyInput;

            if(!Test.isRunningTest()){
                try{
                    ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
                }catch(Exception ex){
                    System.debug('error while creating the chatter post - ' + ex.getMessage());
                    System.debug(ex.getStackTraceString());
                }
            }
        }
    }
}