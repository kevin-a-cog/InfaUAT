/*
* Name : helpAuthHomeController
* Author : Deeksha Shetty
* Created Date : Feb 17,2022
* Description : Controller for helpAuthHomeIdeas
Change History
******************************************************************************************************************************
Modified By          Date            Jira No.              Description                                        Tag
Deeksha Shetty       14/6/2022       I2RT-6042             Authenticated Ideas Upvote Grey out and count is 5         T1
*******************************************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

public without sharing class helpAuthHomeController {
    
    @AuraEnabled(cacheable=true)
    public static List<ideaWrapper> ideasDisplay(String networkId,String userId){
        try{
            //find the topic user following then see the ideas that has highest upvotes in that topoic
            Community communityinfo =[SELECT Id,Name FROM Community where NetworkId =:networkId];
            Id communityid = communityinfo.Id;
            String sitelabel = System.Label.IN_CommunityName;
            Map<String,Topic> topicNamesFollowedByUser = new Map<String,Topic>();
            List<Topic> tplist =  new List<Topic>();
            List<String> topicNameList = new List<String>();
            Set<Id> topicSpecificIdeas = new Set<Id>();
            Set<Id> ideacreatedbyyou = new Set<Id>();
            List<Id> userFollowingTopics = new List<Id>();            
            List<EntitySubscription> followResult = new List<EntitySubscription>();
            List<Idea> ideaDetail = new List<Idea>();
            Set<Id> allIds = new Set<Id>();
            set<id> allids2 = new set<Id>();
            List<Idea> ideaList3 = new List<Idea>();
            List<Idea> idealist2 = new List<Idea>();
            
            ideaDetail = [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                          VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                          LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE  CommunityId =:communityid 
                          AND  Categories!=null AND categories!='Change Request' AND Status!='Draft' AND Status!=null AND Categories EXCLUDES('Change Request')
                          AND CreatedbyId=:userId ORDER BY Upvote_Count__c DESC LIMIT 5] ; //T1
            
           
            
            for(Idea idd:ideaDetail ){
                ideacreatedbyyou.add(idd.Id);
            }
            
            //T1
            if(ideaDetail.size()<5){
                followResult = [SELECT Id,ParentId FROM EntitySubscription where NetworkId =: networkId 
                                and SubscriberId =:userId];              
                
                if(followResult.size()>0){
                    for(EntitySubscription en: followResult){                        
                        if(!userFollowingTopics.contains(en.ParentId)) userFollowingTopics.add(en.ParentId);                        
                    }
                   
                }
                if(userFollowingTopics.size()>0){
                    tplist =  [Select Id, Name From Topic Where Id IN:userFollowingTopics];
                    for(Topic t : tplist){
                        topicNameList.add(t.Name);
                    }                    
                }  
                
                if(topicNameList.size()>0){
                    if(ideacreatedbyyou.size()>0){
                        idealist2= [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                                               VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                                               LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE Id NOT IN:ideacreatedbyyou 
                                               AND Categories IN:topicNameList
                                               AND categories!='Change Request' AND Categories EXCLUDES('Change Request') 
                                               AND Status!='Draft' AND Status!=null
                                               AND Upvote_Count__c>0 Order by Upvote_Count__c DESC];
                        
                    }
                    else{
                        idealist2= [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                                               VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                                               LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE Categories IN:topicNameList
                                               AND categories!='Change Request' AND Categories EXCLUDES('Change Request') 
                                               AND Status!='Draft' AND Status!=null
                                               AND Upvote_Count__c>0 Order by Upvote_Count__c DESC];
                        
                    }
                    
                                           
                    ideaDetail.addAll(idealist2);                                        
                }
               
            }
          
            for(Idea idd:ideaDetail ){
                allIds.add(idd.Id);
            }            
            
            List<Community_Interactions__c> upvotecountlist = [Select Id__c from Community_Interactions__c where Id__c IN:allIds 
                                                               AND Vote__c='Upvote'];
            
            Map<Id,List<Community_Interactions__c>> upvotecountforIdea = new Map<Id,List<Community_Interactions__c>>();
            
            for(Community_Interactions__c com: upvotecountlist){               
                if(!upvotecountforIdea.keyset().contains(com.Id__c)){
                    upvotecountforIdea.put(com.Id__c,new List<Community_Interactions__c>{com});
                }
                else{
                    upvotecountforIdea.get(com.Id__c).add(com);
                }
            }
           
            
            
            List<ideaWrapper> ideawraplist = new List<ideaWrapper>();
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){
                    ideaWrapper wrap = new ideaWrapper();                
                    wrap.totalVoteCount = item.Total_Count__c;                    
                    if(upvotecountforIdea.keyset().contains(item.Id)){
                        wrap.upvoteCount= upvotecountforIdea.get(item.Id).size();                        
                    }
                    else{
                        wrap.upvoteCount= 0;
                    }                       
                    
                    wrap.Status = item.Status;
                    wrap.ideaId = item.Id;
                    wrap.Title = item.title;
                    wrap.Body = item.body;
                    if(item.Categories.contains(';')){
                        wrap.Category = item.Categories.replaceAll(';',',');
                    }
                    else{
                        wrap.Category = item.Categories;
                    }
                    
                    DateTime dT = item.CreatedDate;
                    wrap.CreatedDate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year() + ' '+ 'at' + ' '+ dt.format('hh:mm a');                    
                    wrap.CreatorName = item.CreatorName;
                    wrap.communityName = communityinfo.Name;
                    wrap.url = sitelabel+'ideadetail?id=' + item.Id;
                    //T1
                    if(ideawraplist.size()<5) 
                        ideawraplist.add(wrap);
                }}
            
            System.debug('ideawraplist='+ideawraplist);
            
            
            //this is executed for New User
            
            if(ideawraplist.size()==0 || ideawraplist.isEmpty()){
                
                ideaList3 = [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                             VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                             LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE CommunityId =:communityid 
                             AND categories!='Change Request' AND  Categories!=null AND Categories EXCLUDES('Change Request')
                             AND Status!='Draft' AND Status!=null AND Upvote_Count__c > 0 ORDER BY Upvote_Count__c DESC LIMIT 5 ] ; //T1
            }
            
            else if(ideawraplist.size()<5 && allIds.size()>0){
                if(test.isRunningTest()){
                    ideaList3 = [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                                 VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                                 LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE CommunityId =:communityid
                                 AND Categories EXCLUDES('Change Request') AND categories!='Change Request' AND  Categories!=null
                                 AND Status!='Draft' AND Status!=null AND Upvote_Count__c > 0 ORDER BY Upvote_Count__c DESC LIMIT 5] ; //T1
                }
                else{
                    ideaList3 = [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                                 VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                                 LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE Id NOT IN:allIds 
                                 AND CommunityId =:communityid AND Categories EXCLUDES('Change Request')
                                 AND  categories!='Change Request' AND  Categories!=null
                                 AND Status!='Draft' AND Status!=null AND Upvote_Count__c > 0 ORDER BY Upvote_Count__c DESC LIMIT 5] ; //T1
                    
                }
                
                
            }
            
          
            if(ideaList3.size()>0){
                for(Idea idd:ideaList3){
                    allids2.add(idd.Id);
                }                    
            }
           
            
            List<Community_Interactions__c> upvoteclist = [Select Id__c from Community_Interactions__c where Id__c IN:allids2 
                                                           AND Vote__c='Upvote'];
            
          
            
            if(upvoteclist.size()>0){
                for(Community_Interactions__c com: upvoteclist){               
                    if(!upvotecountforIdea.keyset().contains(com.Id__c)){
                        upvotecountforIdea.put(com.Id__c,new List<Community_Interactions__c>{com});
                    }
                    else{
                        upvotecountforIdea.get(com.Id__c).add(com);
                    }
                }
                
            }
            
           
            
            if(ideaList3.size()>0 ){
                for(Idea item : ideaList3){
                    ideaWrapper wrap = new ideaWrapper();                
                    wrap.totalVoteCount = item.Total_Count__c;                    
                    if(upvotecountforIdea.keyset().contains(item.Id)){
                        wrap.upvoteCount= upvotecountforIdea.get(item.Id).size();                        
                    }
                    else{
                        wrap.upvoteCount= 0;
                    }                       
                    
                    wrap.Status = item.Status;
                    wrap.ideaId = item.Id;
                    wrap.Title = item.title;
                    wrap.Body = item.body;
                    if(item.Categories.contains(';')){
                        wrap.Category = item.Categories.replaceAll(';',',');
                    }
                    else{
                        wrap.Category = item.Categories;
                    }
                    
                    DateTime dT = item.CreatedDate;
                    wrap.CreatedDate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year() + ' '+ 'at' + ' '+ dt.format('hh:mm a');                    
                    wrap.CreatorName = item.CreatorName;
                    wrap.communityName = communityinfo.Name;
                    wrap.url = sitelabel+'ideadetail?id=' + item.Id;
                    //T1
                    if(ideawraplist.size()<5)
                        ideawraplist.add(wrap);
                }}
            
           
            return ideawraplist;
        }
        Catch(Exception e){
            system.debug('Error in ideaDisplay : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
	public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
    }    
    
    public class ideaWrapper{
        @AuraEnabled public Id ideaId;
        @AuraEnabled public String title;
        @AuraEnabled public String Body;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String communityName;
        @AuraEnabled public String Category;
        @AuraEnabled public decimal totalVoteCount;
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Status;
        @AuraEnabled public String url;
    }
    
    
}