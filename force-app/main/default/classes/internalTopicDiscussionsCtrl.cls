public without sharing class internalTopicDiscussionsCtrl {
    
    @auraEnabled
    public static Id getNetworkId(String siteName){  //eSupport
        System.debug('getNetworkId > ' + siteName);
        return [Select Id, Name from network where Name = :siteName limit 1].id;
    } //''


    public static Map<Id, ConnectApi.Topic> allTopics(String communityId){
        Map<Id, ConnectApi.Topic> topicsMap = new Map<Id, ConnectApi.Topic>();
        for(ConnectApi.Topic tp : ConnectApi.Topics.getTopics(communityId, 0, 100, ConnectApi.TopicSort.alphaAsc).topics){
            topicsMap.put(tp.id, tp);
        }
        return topicsMap;
    }
    
    @auraEnabled
    public static Map<Id, String> topicsWithStream(String communityId){
        Map<Id, String> topicsMap = new Map<Id, String>();
        for(ConnectApi.ChatterStream cs : ConnectApi.ChatterFeeds.getStreams(communityId, 0, 250, ConnectApi.SortOrder.MostRecentlyViewed).items ){
            if(cs.subscriptions <> null){
                for(ConnectApi.FeedEnabledEntity entity : cs.subscriptions){
                    topicsMap.put(entity.id, entity.name);
                }
            }
        }
        return topicsMap;
    }
    
    @auraEnabled
    public static Map<String, ConnectApi.Topic> topicsWithoutStream(String communityId){
        System.debug('topicsWithoutStreams invoked!');
        Map<String, ConnectApi.Topic> noStreamTopics = new  Map<String, ConnectApi.Topic>();
        Map<Id, ConnectApi.Topic> allTopics = allTopics(communityId);
        Map<Id, String> topicsMapWithStream = topicsWithStream(communityId);
        Boolean topicWithoutStreamFound = false;
        for(ConnectApi.Topic tp : allTopics.values()){
            if(topicsMapWithStream == null || !topicsMapWithStream.containsKey(tp.id)){
                noStreamTopics.put(tp.id, tp);
            }
        }
        System.debug('noStreamTopics > ' + json.serializePretty(noStreamTopics));
        return noStreamTopics;
    }
    
    @auraEnabled
    public static Map<String, String> getStreams(String communityId){
        System.debug('getStreams > ' + communityId);
        Map<String, String> streamsMap = new Map<String, String>();
        for(ConnectApi.ChatterStream cs : ConnectApi.ChatterFeeds.getStreams(communityId, 0, 250, ConnectApi.SortOrder.MostRecentlyViewed).items ){
            if(cs.subscriptions <> null){
                streamsMap.put(cs.id, cs.name);
                
            }
        }
        System.debug('streamsMap > ' + streamsMap);
        return streamsMap;
    }
    
    @auraEnabled
    public static String createNewStreams(String communityId){
        System.debug('createNewStreams invoked!');
        String result = 'false';
        try{
            Map<String, ConnectApi.Topic> topicsWithoutStream = topicsWithoutStream(communityId);
            for(ConnectApi.Topic tp : topicsWithoutStream.values()){
                createStream(tp.id, tp.name, tp.Description, communityId);
            }
            result = 'true';
        }catch(Exception ex){
            result = ex.getMessage();
        }
        
        return result;
    }
    
    public static void createStream(Id topicId, String topicName, String topicDescription, String communityId){
        System.debug('Createing Stream for > ' + topicName);
        ConnectApi.StreamSubscriptionInput sub1 = new ConnectApi.StreamSubscriptionInput();
        sub1.entityId = topicId;
        
        List<ConnectApi.StreamSubscriptionInput> subscriptions = new List<ConnectApi.StreamSubscriptionInput>();
        subscriptions.add( sub1 );
        
        ConnectApi.ChatterStreamInput streamInput = new ConnectApi.ChatterStreamInput();
        streamInput.name = topicName;
        streamInput.description = topicDescription;
        streamInput.subscriptionsToAdd = subscriptions;
        
        ConnectApi.ChatterStream stream = ConnectApi.ChatterFeeds.createStream( communityId, streamInput );
        System.debug('stream id > ' + stream.id + ' and stream name ' + stream.name);
        
    }
   
    /*
     * String communityId = internalTopicDiscussionsCtrl.getNetworkId('Informatica Network');
    for(ConnectApi.ChatterStream cs : ConnectApi.ChatterFeeds.getStreams('0DB7j000000Gn49GAC').items){
        system.debug('stream delete > ' + cs.name);
        ConnectApi.chatterfeeds.deleteStream('0DB3f0000008OJ3GAM', cs.id);
    }
*/
}