/*
* Name         :   helpCommunityController
* Author       :   Utkarsh Jain
* Created Date :   15-JAN-2022
* Description  :   Controller used for all community related queries.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Utkarsh Jain           15-JAN-2022     Utopia-ph-3         Initial version.                                          NA
Utkarsh Jain           28-SEPT-2022    I2RT-7062           Salesforce application related to quick link              1
Utkarsh Jain           26-OCT-2022     I2RT-7262           Production Bug - New communities are getting created      2
                                                           when the #tag is used in the discussion content 
Prashanth Bhat         12-JUN-2023     I2RT-8367           No-Code Data Integration search enhancement               3
Prashanth Bhat         22-JUN-2023     I2RT-8529           Introduce New sorting option in the Product community     4                                                                                  
*/
public without sharing class helpCommunityController {
    
/*
Get All communities including both parent and child.
param : userId - for providing checking if loggedin user following any community.
param : sortBy - sorty by term.
param : searchTerm - search term.
return : All community List. 
*/
    @AuraEnabled
    public static list<CommunityListWrapper> getAllCommunity(String networId, String user, String sortBy, String searchTerm){
        
        List<Topic> communityList;
        List<Help_Community__mdt> parentCommunity;
        List<CommunityListWrapper> commList = new List<CommunityListWrapper>();
        List<EntitySubscription> result = new List<EntitySubscription>();
        
        try{
            parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c FROM Help_Community__mdt];
            List<help_community_url__mdt> communityUrl = [SELECT url_name__c FROM help_community_url__mdt where developerName = 'communityUrl'];
            String SearchKey =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().trim()+'%' :'';
            //tag 3
            if((SearchKey.Contains('no') || SearchKey.Contains('no ')) && !SearchKey.Contains('no-')){
                if(SearchKey.Contains('no ')){SearchKey = SearchKey.replace('no ', 'no-');}
                else if(SearchKey.Contains('no')){SearchKey = SearchKey.replace('no', 'no-');}
            }
            String SearchKeyNoSpace =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().deleteWhitespace()+'%' :'';
            if(SearchKeyNoSpace.Contains('no') && !SearchKeyNoSpace.Contains('no-')){
                SearchKeyNoSpace = SearchKeyNoSpace.replace('no', 'no-');
            }
            String query = 'SELECT Id, Name, Description, ManagedTopicType FROM Topic where NetworkId = \'' + networId + '\'  and (Name LIKE \''+ SearchKey +'\' or Name LIKE \''+ SearchKeyNoSpace +'\' ) ORDER BY Name ' + sortBy;
            communityList = Database.query(query);
            // <tag 2 start>
            List<String> communityNames = getCommunityNames();
            for(Topic comm : communityList){
                if(communityNames.contains(comm.Name)){
                    CommunityListWrapper community = new CommunityListWrapper();
                    community.Id = comm.Id;
                    community.Name = comm.Name;
                    community.Description = comm.Description;
                    community.Link = communityUrl[0].url_name__c + '/s/topic/' + comm.Id;
                    community.IsFollowing = false;
                    for(Help_Community__mdt parentComm: parentCommunity){
                        List<String> subCommunities = parentComm.SubCommunities__c.toLowercase().split(';');
                        if(subCommunities.contains(comm.Name.toLowercase())){
                            community.ParentCommunityName = parentComm.ParentCommunity__c.toLowercase();
                        }
                    }
                    commList.add(community);
                }
                // <tag 2 end>
            }
            
            if(user != null){
                result = [SELECT Id, ParentId FROM EntitySubscription where NetworkId =: networId and SubscriberId =: user limit 1000];
                if(result.size() > 0){
                    for(CommunityListWrapper comm : commList){
                        for( EntitySubscription mycomm : result){
                            if(comm.Id == mycomm.ParentId){
                                comm.IsFollowing = true;
                            }
                        }
                        
                    }
                }
            }
            
        } catch(Exception e){
            system.debug('Error in All communities : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commList; 
    }
    
/*
Get My communities including both parent and child.
param : networId - Community Id.
param : userId - for providing checking if loggedin user following any community.
param : sortBy - sorty by term.
param : searchTerm - search term.
return : My community List. 
*/
    @AuraEnabled
    public static list<CommunityListWrapper> getMyCommunities(String networId, String user, String sortBy, String searchTerm){
        List<Topic> communityList;
        List<CommunityListWrapper> commList = new List<CommunityListWrapper>();
        List<EntitySubscription> result = new List<EntitySubscription>();
        try{
            
            List<Help_Community__mdt> parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c FROM Help_Community__mdt];
            List<help_community_url__mdt> communityUrl = [SELECT url_name__c FROM help_community_url__mdt where developerName = 'communityUrl'];
            String SearchKey =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().trim()+'%' :'';
            //tag 3
            if((SearchKey.Contains('no') || SearchKey.Contains('no ')) && !SearchKey.Contains('no-')){
                if(SearchKey.Contains('no ')){SearchKey = SearchKey.replace('no ', 'no-');}
                else if(SearchKey.Contains('no')){SearchKey = SearchKey.replace('no', 'no-');}
            }
            String SearchKeyNoSpace =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().deleteWhitespace()+'%' :'';
            if(SearchKeyNoSpace.Contains('no') && !SearchKeyNoSpace.Contains('no-')){
                SearchKeyNoSpace = SearchKeyNoSpace.replace('no', 'no-');
            }
            String query = 'SELECT Id, Name, Description, ManagedTopicType FROM Topic where NetworkId = \'' + networId + '\'  and (Name LIKE \''+ SearchKey +'\' or Name LIKE \''+ SearchKeyNoSpace +'\' ) ORDER BY Name ' + sortBy;
            communityList = Database.query(query);
            
            result = [SELECT Id, ParentId FROM EntitySubscription where NetworkId =: networId and SubscriberId =: user limit 999];
            // <tag 2 start>
            List<String> communityNames = getCommunityNames();
            if(result.size() > 0){
                for(Topic comm : communityList){
                    if(communityNames.contains(comm.Name)){
                        for(EntitySubscription following : result){
                            if(following.ParentId == comm.Id){
                                CommunityListWrapper community = new CommunityListWrapper();
                                community.Id = comm.Id;
                                community.Name = comm.Name;
                                community.Description = comm.Description;
                                community.Link = communityUrl[0].url_name__c + '/s/topic/' + comm.Id;
                                community.IsFollowing = true;
                                for(Help_Community__mdt parentComm: parentCommunity){
                                    List<String> subCommunities = parentComm.SubCommunities__c.toLowercase().split(';');
                                    if(subCommunities.contains(comm.Name.toLowercase())){
                                        community.ParentCommunityName = parentComm.ParentCommunity__c.toLowercase();
                                    }
                                }
                                commList.add(community);
                            }
                        }
                        // <tag 2 end>
                    }
                }
            }
        } catch(Exception e){
            system.debug('Error in getMyCommunities : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commList; 
    }
    
/*
Get Recommended communities including both parent and child.
param : networId - Community Id.
param : userId - for providing checking if loggedin user following any community.
param : sortBy - sorty by term.
param : searchTerm - search term.
return : Recommended community List. 
*/
    @AuraEnabled
    public static list<CommunityListWrapper> getRecommendedCommunity(String networId, String user, String sortBy, String searchTerm){
        List<Topic> communityList;
        List<AggregateResult> topicsList ;
        List<CommunityListWrapper> commList = new List<CommunityListWrapper>();
        List<CommunityListWrapper> resultList = new List<CommunityListWrapper>();
        List<EntitySubscription> result = new List<EntitySubscription>();
        try{
            
            topicsList = [select Topic.Id, COUNT(EntityId) from TopicAssignment where CreatedDate = LAST_N_DAYS:30 and NetworkId =:networId group by Topic.Id order by COUNT(EntityId) desc limit 999 OFFSET 1];
            List<Help_Community__mdt> parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c FROM Help_Community__mdt];
            List<help_community_url__mdt> communityUrl = [SELECT url_name__c FROM help_community_url__mdt where developerName = 'communityUrl'];
            
            String SearchKey =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().trim()+'%' :'';
            //tag 3
            if((SearchKey.Contains('no') || SearchKey.Contains('no ')) && !SearchKey.Contains('no-')){
                if(SearchKey.Contains('no ')){SearchKey = SearchKey.replace('no ', 'no-');}
                else if(SearchKey.Contains('no')){SearchKey = SearchKey.replace('no', 'no-');}
            }
            String SearchKeyNoSpace =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm).toLowercase().deleteWhitespace()+'%' :'';
            if(SearchKeyNoSpace.Contains('no') && !SearchKeyNoSpace.Contains('no-')){
                SearchKeyNoSpace = SearchKeyNoSpace.replace('no', 'no-');
            }
            String query = 'SELECT Id, Name, Description, ManagedTopicType FROM Topic where NetworkId = \'' + networId + '\'  and (Name LIKE \''+ SearchKey +'\' or Name LIKE \''+ SearchKeyNoSpace +'\' ) ORDER BY Name ' + sortBy;
            communityList = Database.query(query);
            // <tag 2 start>
            List<String> communityNames = getCommunityNames();
            for(Topic comm : communityList){
                if(communityNames.contains(comm.Name)){
                    CommunityListWrapper community = new CommunityListWrapper();
                    community.Id = comm.Id;
                    community.Name = comm.Name;
                    community.Description = comm.Description;
                    community.Link = communityUrl[0].url_name__c + '/s/topic/' + comm.Id;
                    community.IsFollowing = false;
                    for(Help_Community__mdt parentComm: parentCommunity){
                        List<String> subCommunities = parentComm.SubCommunities__c.toLowercase().split(';');
                        if(subCommunities.contains(comm.Name.toLowercase())){
                            community.ParentCommunityName = parentComm.ParentCommunity__c.toLowercase();
                        }
                    }
                    for(AggregateResult trendingTopic : topicsList){
                        if(trendingTopic.Id == comm.Id){
                            commList.add(community);
                        }
                    }
                    // <tag 2 end>
                }
            }
            
            if(user != null){
                result = [SELECT Id, ParentId FROM EntitySubscription where NetworkId =: networId and SubscriberId =: user limit 1000];
                if(result.size() > 0){
                    for(CommunityListWrapper comm : commList){
                        for( EntitySubscription mycomm : result){
                            if(comm.Id == mycomm.ParentId){
                                comm.IsFollowing = true;
                            }
                        }
                        
                    }
                }
            }else{
                commList.clear();
            }
        } catch(Exception e){
            system.debug('Error in getRecommendedCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commList; 
    }
    
/*
Get all Parent Communities used in combobox.
param : 
return : parent community list 
*/
    @AuraEnabled(cacheable=true)
    public static list<Help_Community__mdt> getAllCommunities(){
        List<Help_Community__mdt> parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c, Parent_Level_1__c FROM Help_Community__mdt];
        parentCommunity.sort();
        return parentCommunity;       
        
    }
    
    
/*
<tag 4 start>
Get Most followed community sorted list.
param : networId - Community Id.
return : Most followed community sorted list. 
*/
    @AuraEnabled
    public static List<String> getMostFollowedCommunity(String networkId){
        List<String> sortedCommunityByFollowers = new List<String>();
        try{
            
            AggregateResult[] results = [SELECT Parent.Name community
                                         FROM EntitySubscription 
                                         WHERE NetworkId =: networkId AND Parent.Type = 'Topic' GROUP BY Parent.Name ORDER BY Count(Id) DESC LIMIT 100]; 
            if(results.size() > 0){
                for(AggregateResult result : results){
                    sortedCommunityByFollowers.add((String)result.get('community'));
                }
            } 
            return sortedCommunityByFollowers; 
        }
        catch(Exception E){
            system.debug('Error in getMostFollowedCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());   
        }
    }
    
/*
<tag 4 start>
Get Most popular community sorted list.
param : networId - Community Id.
return : Most popular community sorted list. 
*/
    @AuraEnabled(cacheable=true)
    public static Map<Id, Integer> getMostPopularCommunity(String networkId){
          
        // Create a new map to store the result
        Map<Id,Integer> mostPopularMap = new Map<Id, Integer>();
        Map<Id,Integer> mapTopicIdToFeedItemCount = new Map<Id,Integer>();
        Map<Id,Id> mapFeedItemToTopic = new Map<Id,Id>();
        Map<Id,Integer> mapTopicToCommentCount = new Map<Id,Integer>();
        Map<Id,Integer> mapFeedItemIdToCommentCount = new Map<Id,Integer>();
        
     try{   
        //logic to collect feedItem count per topic for last 30 days
        List<AggregateResult> feedItemCount = [SELECT TopicId, COUNT(EntityId) feedItemCount
                                               FROM TopicAssignment
                                               WHERE NetworkId =: networkId and CreatedDate = LAST_N_DAYS:30 and EntityType = 'FeedItem'
                                               GROUP BY TopicId
                                               ORDER BY COUNT(EntityId) DESC];
        
        
        
        if(feedItemCount.size() > 0){
            for(AggregateResult result : feedItemCount){
                mapTopicIdToFeedItemCount.put((Id)result.get('TopicId'),(Integer)result.get('feedItemCount'));
            }
        }  
              
        //logic to collect feedcomment count per topic last 30 days
        List<FeedComment> listFeedComment = [SELECT Id,FeedItemId FROM FeedComment
                                             WHERE CreatedDate = LAST_N_DAYS:30 
                                             AND FeedItemId != null Order By CreatedDate DESC LIMIT 50000];
        
        
         if(listFeedComment != null && listFeedComment.size() > 0){
             for(FeedComment objFeedCom : listFeedComment){
                 if(!mapFeedItemIdToCommentCount.keyset().contains(objFeedCom.FeedItemId)){
                     mapFeedItemIdToCommentCount.put(objFeedCom.FeedItemId,1);
                 }
                 else{
                     Integer commentCount = mapFeedItemIdToCommentCount.get(objFeedCom.FeedItemId);
                     mapFeedItemIdToCommentCount.put(objFeedCom.FeedItemId,commentCount + 1);
                 }
             }
         }
         List<TopicAssignment> topicAgn = new List<TopicAssignment>();
         if(mapFeedItemIdToCommentCount != null){
             topicAgn = [SELECT TopicId,EntityId FROM TopicAssignment
                         WHERE NetworkId =: networkId and EntityId In:mapFeedItemIdToCommentCount.keySet() and EntityType = 'FeedItem'];
         }
        
         if(topicAgn != null && topicAgn.size() > 0){
             for(TopicAssignment objTopAssgn : topicAgn){
                 if(!mapFeedItemToTopic.keyset().contains(objTopAssgn.EntityId)){
                     mapFeedItemToTopic.put(objTopAssgn.EntityId,objTopAssgn.TopicId);
                 }
             }
         }
        
         if(mapFeedItemIdToCommentCount != null && !mapFeedItemIdToCommentCount.isEmpty()){
             for(Id feedId : mapFeedItemIdToCommentCount.keySet()){
                 if(!mapTopicToCommentCount.keyset().contains(mapFeedItemToTopic.get(feedId))){
                     mapTopicToCommentCount.put(mapFeedItemToTopic.get(feedId),mapFeedItemIdToCommentCount.get(feedId));
                 }
                 else{
                     Integer countVal = mapTopicToCommentCount.get(mapFeedItemToTopic.get(feedId)) + mapFeedItemIdToCommentCount.get(feedId); 
                     mapTopicToCommentCount.put(mapFeedItemToTopic.get(feedId),countVal);
                 }
             }
         }
        
        
        
        // Sum up the values for common keys
        for (Id key : mapTopicIdToFeedItemCount.keySet()) {
            if (mapTopicToCommentCount.containsKey(key)) {
                Integer sum = mapTopicIdToFeedItemCount.get(key) + mapTopicToCommentCount.get(key);
                mostPopularMap.put(key, sum);
                mapTopicIdToFeedItemCount.remove(key);
            }
        }
        
        // Add all keys from mapTopicIdToFeedItemCount to the mostPopularMap map
        mostPopularMap.putAll(mapTopicIdToFeedItemCount);
        
        // Add all keys from mapTopicToCommentCount to the mostPopularMap map, and merge the values if the key already exists
        for (Id key : mapTopicToCommentCount.keySet()) {
            if (!mostPopularMap.containsKey(key)) {
                mostPopularMap.put(key, mapTopicToCommentCount.get(key));
            }
        }
           
        // Output the result
        return mostPopularMap;
        }
        catch(Exception exp){
            system.debug('Error in getMostPopularCommunity : ' +exp.getMessage() + ' Stack trace : ' + exp.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+exp.getMessage());
        }        
    }
    // <tag 4 end> 
    
// <tag 2 start>
    
/*
Get all Communities used from combobox.
param : 
return : parent community list 
*/
    @AuraEnabled(cacheable=true)
    public static list<String> getCommunityNames(){
        List<String> communityList = new List<String>();
        List<Help_Community__mdt> parentCommunity = getAllCommunities();
        for(Help_Community__mdt comm: parentCommunity){
            communityList.add(comm.ParentCommunity__c);
            communityList.addAll(comm.SubCommunities__c.split(';'));
        }
        return communityList;       
    }
    
    // <tag 2 end>
    
    /*
Get all Communities used in combobox.
param : 
return : all community list 
*/
    @AuraEnabled(cacheable=true)
    public static list<CommunityOptionsWrapper> getAllCommunityOptions(String networId){
        
        List<Topic> communityList;
        List<CommunityOptionsWrapper> commList = new List<CommunityOptionsWrapper>();
        try{
            
            communityList = [SELECT Id, Name, Description, ManagedTopicType FROM Topic where NetworkId =: networId ];
            
            for(Topic comm : communityList){
                CommunityOptionsWrapper community = new CommunityOptionsWrapper();
                community.label = comm.Name;
                community.value = comm.Id;
                commList.add(community);
            }
        } catch(Exception e){
            system.debug('Error in getAllCommunityOptions: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commList; 
    }
    
    /*
Get if user is following community on community detail page.
param : commId - topicId
user - userId
networkId - networkId
return : . 
*/
    @AuraEnabled(cacheable=true)
    public static Integer getFollowingCommunity(String commId, String user, String networId){
        try{
            List<EntitySubscription> result = new List<EntitySubscription>();
            result = [SELECT Id FROM EntitySubscription where NetworkId =: networId and ParentId =: commId and SubscriberId =: user limit 1000];
            return result.size();
        }
        catch(Exception e){
            system.debug('Error in getFollowingCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    /*
Follow A Community.
param : commId - topicId
user - userId
networkId - networkId
return : . 
*/
    @AuraEnabled
    public static String followCommunity(String commId, String user, String networId){
        try{
            EntitySubscription record = new EntitySubscription(
                NetworkId=networId,
                ParentId=commId,
                SubscriberId=user);
            insert record;
        }
        catch(Exception e){
            system.debug('Error in followCommunity: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return 'success';
    }
    
    /*
UnFollow A Community.
param : commId - topicId
user - userId
networkId - networkId
return : . 
*/
    @AuraEnabled
    public static String unfollowCommunity(String commId, String user, String networId){
        try{
            List<EntitySubscription> result = new List<EntitySubscription>();
            result = [SELECT Id FROM EntitySubscription where NetworkId =: networId and ParentId =: commId and SubscriberId =: user limit 1000];
            delete result;
        }
        catch(Exception e){
            system.debug('Error in unfollowCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return 'success';
    }
    
    /*
Get All communities including both parent.
param : sortBy - sorty by term.
return : All community List. 
*/
    @AuraEnabled(cacheable=true)
    public static list<CommunityListWrapper> getAllCommunityList(String networId, String sortBy){
        
        List<Topic> communityList;
        List<AggregateResult> topicsList ;
        List<CommunityListWrapper> commList = new List<CommunityListWrapper>();
        List<CommunityListWrapper> resultList = new List<CommunityListWrapper>();
        List<EntitySubscription> result = new List<EntitySubscription>();
        try{
            
            topicsList = [select Topic.Id, COUNT(EntityId) from TopicAssignment where CreatedDate = LAST_N_DAYS:30 and NetworkId =:networId group by Topic.Id order by COUNT(EntityId) desc limit 999 OFFSET 1];
            List<Help_Community__mdt> parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c FROM Help_Community__mdt];
            List<help_community_url__mdt> communityUrl = [SELECT url_name__c FROM help_community_url__mdt where developerName = 'communityUrl'];
            String query = 'SELECT Id, Name, Description, ManagedTopicType FROM Topic where NetworkId = \'' + networId + '\'  ORDER BY Name ' + sortBy;
            communityList = Database.query(query);
            
            for(Topic comm : communityList){
                CommunityListWrapper community = new CommunityListWrapper();
                community.Id = comm.Id;
                community.Name = comm.Name;
                community.Description = comm.Description;
                community.Link = communityUrl[0].url_name__c + '/s/topic/' + comm.Id;
                community.IsFollowing = false;
                Integer count = 0;
                for(Help_Community__mdt parentComm: parentCommunity){
                    if (count >= 7) {
                        break;
                    }
                    if(parentComm.ParentCommunity__c.toLowercase() == comm.Name.toLowercase()){
                        commList.add(community);
                        count = count + 1;
                    }
                }
            }
        } catch(Exception e){
            system.debug('Error in getRecommendedCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commList; 
    }
    
    
    /*
Get Site Analytics.
param : 
return : Custom metadata for analytics component. 
*/
    @AuraEnabled(cacheable=true)
    public static List<helpCommunityAnalytics__mdt> getAnalyticsData(){
        List<helpCommunityAnalytics__mdt> analytics_data;
        try{
            analytics_data = [SELECT analytics_data__c FROM helpCommunityAnalytics__mdt where developerName = 'analytics_data'];
        }
        catch(Exception e){
            system.debug('Error in getAnalyticsData : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return analytics_data;
    }
    
    /*
Get Id of community based on community name.
param : 
return : Community Id
*/
    @AuraEnabled(cacheable=true)
    public static String getCommunityId(String commName, string networkId){
        String commId = '';
        try{
            commId = [SELECT Id, Name FROM Topic where Name =:commName and NetworkId =:networkId].Id;
        } catch(Exception e){
            system.debug('Error in getAllCommunityOptions: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return commId; 
    }
    
    // Tag 1 Start
    
    /*
Get quick links.`
param : 
return : All Quick Links
*/
    @AuraEnabled(cacheable=true)
    public static List<helpQuickLink__mdt> getQuickLinks(){
        List<helpQuickLink__mdt> result = new List<helpQuickLink__mdt>();
        try{
            List<helpQuickLink__mdt> quickLinks = [SELECT MasterLabel, QualifiedApiName FROM helpQuickLink__mdt];
            for (helpQuickLink__mdt quickLink : quickLinks) {
                helpQuickLink__mdt quickLinksRecord = [SELECT Label, quicklinkurl__c, helpQuickLinkIcon__c FROM helpQuickLink__mdt where developerName =:quickLink.QualifiedApiName LIMIT 1];
                result.add(quickLinksRecord);
            }
            return result;
        } catch(Exception e){
            system.debug('Error in getQuickLinks : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    /*
Update quick links based on record Id.`
param : 
return : Community Id
*/
    @AuraEnabled
    public static void updateQuickLinks(String recordId, String quickLinks){
        try{
            Alerts_Announcements__c ann = [Select Id, Quick_Links__c from Alerts_Announcements__c WHERE Id =: recordId LIMIT 1];
            ann.Quick_Links__c = quickLinks;
            update ann;
        } catch(Exception e){
            system.debug('Error in updateQuickLinks: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    /*
Get quick links based on Community.`
param : 
return : Quick Links
*/
    @AuraEnabled(cacheable=true)
    public static Alerts_Announcements__c getQuickLinksForRecord(String recordId){
        Alerts_Announcements__c res;
        try{
            res = [select Id, Name, Community__c, Quick_Links__c from Alerts_Announcements__c where id =: recordId LIMIT 1];
            return res;
        } catch(Exception e){
            system.debug('Error in getQuickLinksForRecord : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    /*
Get quick links based on Community.`
param : 
return : Quick Links
*/
    @AuraEnabled
    public static Alerts_Announcements__c getQuickLinksForCommunity(String communityId){
        String recordId = Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Quick Links').getRecordTypeId();
        Alerts_Announcements__c res;
        String communityName;
        try{
            communityName = helpUserRelatedList.getCommunityName(communityId);
            res = [select Id, Name, Quick_Links__c, Community__c from Alerts_Announcements__c where RecordTypeId =: recordId and Community__c INCLUDES(:communityName) LIMIT 1];
            return res;
        } catch(Exception e){
            system.debug('Error in getQuickLinksForCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    // Tag 1 end
    
    public class CommunityListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Description;
        @AuraEnabled public String ParentCommunityName;
        @AuraEnabled public String Link;
        @AuraEnabled public Boolean IsFollowing;
    }
    
    public class CommunityOptionsWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}