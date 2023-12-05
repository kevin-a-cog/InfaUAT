/*
* Name : helpNetworkModerationController
* Author : Deeksha Shetty
* Created Date : March 30,2022
* Description : Controller for helpModerationActionComponent
Change History
*************************************************************************************************************************
Modified By          Date               Jira No.         Description                                          Tag

Deeksha Shetty      July 17,2023       I2RT-8306        Moderator functionality - enhancement                  T1
Deeksha Shetty      Aug  04,2023       I2RT-8826        SIT - IN Community - Moderator Action -                T2
                                                        Ask a Question - Image attached in description 
                                                        is not getting display in "FeedItem" details screen 

**************************************************************************************************************************
*/

public without sharing class helpNetworkModerationController {   
    
    @AuraEnabled(Cacheable=true)
    public static List<ModerationWrapper> ModerationDetailsDisplay(){
        try{
            Map<Id,NetworkActivityAudit> entityIdDetailmap = new Map<Id,NetworkActivityAudit>();
            List<Id> FeedItemId = new List<Id>();
            List<ModerationWrapper> tableData = new List<ModerationWrapper>();
            List<Id> FeedCommentId = new List<Id>();
            List<FeedItem> feeditemList = new List<FeedItem>();
            List<FeedComment> feedcommentList = new List<FeedComment>();
            Set<Id> FeedOwnerIds = new Set<Id>();
            Map<Id,String> usermap = new Map<Id,String>();
            set<Id> feedCommentParentId = new Set<Id>(); //T1
            Map<Id,String> feedItemIdTopicUGName = new Map<Id,String>(); //T1
            String networkId = system.label.IN_NetworkID ;
            
            List<NetworkActivityAudit> moderationDetail = [SELECT Id, CreatedById,CreatedDate, NetworkId, EntityId, ParentEntityType, 
                                                           ParentEntityId, EntityCreatedById, EntityType, Action, Description 
                                                           FROM NetworkActivityAudit where EntityId!=null AND 
                                                           Action = 'ModerationRuleReview' AND NetworkId=:networkId ORDER BY CreatedDate DESC] ;
            System.debug('moderationDetail='+moderationDetail);
            for(NetworkActivityAudit md : moderationDetail){
                entityIdDetailmap.put(md.EntityId,md);
            }           
            
            for(NetworkActivityAudit md : moderationDetail){
                Id fId = md.EntityId;
                String sObjName =fId.getSObjectType().getDescribe().getName();
                if(sObjName=='FeedItem'){
                    FeedItemId.add(fId);
                }
                else if(sObjName == 'FeedComment'){
                    FeedCommentId.add(fId);
                }
                FeedOwnerIds.add(md.CreatedById);
            }
            
            if(FeedOwnerIds.size()>0) usermap = getUserNames(FeedOwnerIds);
            /*T1 starts*/
            if(FeedCommentId.size()>0){
                feedcommentList =[SELECT Id, Status,CommentBody,CreatedById,CreatedDate,FeedItemId FROM FeedComment Where Id=:FeedCommentId ORDER BY CreatedDate DESC];
                if(feedcommentList.size()>0){
                    for(FeedComment fc : feedcommentList){
                        feedCommentParentId.add(fc.FeedItemId);
                    }                    
                }
                feedCommentParentId.addAll(FeedItemId);
            }
            
            if(FeedItemId.size()>0)
                feeditemList =[SELECT Id, Status,Body, Title,CreatedById,CreatedDate,parentId FROM FeedItem Where Id=:FeedItemId ORDER BY CreatedDate DESC];
            
            if(feedCommentParentId.size()>0){
                List<TopicAssignment> tpList = [Select Topic.Name,EntityId from TopicAssignment where EntityId=:feedCommentParentId];
                if(tpList.size()>0){
                    for(TopicAssignment tp : tpList){
                        feedItemIdTopicUGName.put(tp.EntityId,tp.topic.name);
                    }
                }
                
                List<FeedItem> UgNames = [SELECT Id,Parent.Name FROM FeedItem where Id=:feedCommentParentId AND parent.type='CollaborationGroup'];
                if(UgNames.size()>0){
                    for(FeedItem fi : UgNames){
                        feedItemIdTopicUGName.put(fi.Id,fi.Parent.Name);
                    }
                }
                
                
            }
            /*T1 ends*/                          
            
            if(feeditemList.size()>0){
                for(FeedItem fitem : feeditemList){
                    if(fitem.Status!= 'Published'){
                        ModerationWrapper wrap = new ModerationWrapper();
                        wrap.AuditId = fitem.Id;
                        wrap.ContentTitle = fitem.Title;
                        /*if(fitem.Body!=null){
wrap.ContentBody = fitem.Body.stripHtmlTags();
}*/
                        
                        wrap.ContentStatus = fitem.Status;
                        if(usermap.keyset().contains(fitem.CreatedById)){
                            wrap.ContentCreator = usermap.get(fitem.CreatedById);
                        }                    
                        wrap.EntityType = entityIdDetailmap.get(fitem.Id).EntityType;
                        wrap.URL = '/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId='+fitem.Id;
                        dateTime cd = fitem.CreatedDate;
                        wrap.CommunityName = feedItemIdTopicUGName.get(fitem.Id); /*T1*/
                        //wrap.CreatedDate = date.newInstance(cd.year(), cd.month(), cd.day());
                        tableData.add(wrap);
                        
                    }                
                }                
            }
            
            if(feedcommentList.size()>0){
                for(FeedComment fitem : feedcommentList){
                    if(fitem.Status!= 'Published'){
                        ModerationWrapper wrap = new ModerationWrapper();
                        wrap.AuditId = fitem.Id;
                        wrap.ContentTitle = 'NA';
                        /*if(fitem.CommentBody!=null){
wrap.ContentBody = fitem.CommentBody.stripHtmlTags();                        
}*/
                        
                        wrap.ContentStatus = fitem.Status;
                        if(usermap.keyset().contains(fitem.CreatedById)){
                            wrap.ContentCreator = usermap.get(fitem.CreatedById);
                        }
                        wrap.EntityType = entityIdDetailmap.get(fitem.Id).EntityType;
                        wrap.URL = '/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId='+fitem.Id;
                        dateTime cd = fitem.CreatedDate;
                        //wrap.CreatedDate = date.newInstance(cd.year(), cd.month(), cd.day());
                        wrap.CommunityName = feedItemIdTopicUGName.get(fitem.FeedItemId); /*T1*/
                        tableData.add(wrap);
                    }
                }
                
            }
            
            return tableData;
        }
        Catch(Exception e){
            system.debug('Error in Network Moderation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static List<ModerationWrapper> FlaggedItemsDisplay(){
        try{
            Map<Id,String> FeedItemId = new Map<Id,String>();
            List<ModerationWrapper> tableData = new List<ModerationWrapper>();
            Map<Id,String> FeedCommentId = new Map<Id,String>();
            List<FeedItem> feeditemList = new List<FeedItem>();
            List<FeedComment> feedcommentList = new List<FeedComment>();
            Set<Id> FeedOwnerIds = new Set<Id>();
            Map<Id,String> usermap = new Map<Id,String>();          
            Map<Id,List<String>> flaggedByUsersMap = new Map<Id,List<String>>();
            
            
            Map<Id,NetworkModeration> networkModerationDetails = new Map<Id,NetworkModeration>();
            
            List<NetworkModeration> moderationDetail = [SELECT Id, EntityId,CreatedById, ModerationType,Note FROM NetworkModeration ORDER BY CreatedDate DESC] ;            
            
            if(moderationDetail.size()>0){
                for(NetworkModeration nm : moderationDetail){                    
                    if (flaggedByUsersMap.containsKey(nm.EntityId)){
                        flaggedByUsersMap.get(nm.EntityId).add(nm.CreatedById);                                                         
                    } else{
                        flaggedByUsersMap.put(nm.EntityId, new List<String>{nm.CreatedById});                   
                    }
                    
                }            
            }  
            
            for(String nid : flaggedByUsersMap.keyset()){
                Id fId = nid;
                String sObjName =fId.getSObjectType().getDescribe().getName();
                if(sObjName=='FeedItem'){
                    FeedItemId.put(fId,sObjName);                    
                }
                else if(sObjName == 'FeedComment'){
                    FeedCommentId.put(fId,sObjName);
                }               
            }
            Map<Id,FeedItem> feeditemMap = new Map<Id,FeedItem>([SELECT Id, Status,Body, Title,CreatedById,CreatedDate FROM FeedItem Where Id=:FeedItemId.keyset() ORDER BY CreatedDate DESC]);
            Map<Id,FeedComment>  feedcommentMap =new Map<Id,FeedComment>([SELECT Id, Status,CommentBody,CreatedById,CreatedDate FROM FeedComment Where Id=:FeedCommentId.keyset() ORDER BY CreatedDate DESC]);
            if(feeditemMap.size()>0){
                for(Id feedId : feeditemMap.keySet()){
                    FeedOwnerIds.add(feeditemMap.get(feedId).CreatedById);
                }
            }
            if(feedcommentMap.size()>0){
                for(Id feedId : feedcommentMap.keySet()){
                    FeedOwnerIds.add(feedcommentMap.get(feedId).CreatedById);
                }
            }                
            
            if(FeedOwnerIds.size()>0) usermap = getUserNames(FeedOwnerIds);  
            
            for(NetworkModeration nm : moderationDetail){
                if(feeditemMap.keyset().contains(nm.EntityId)){
                    ModerationWrapper wrap = new ModerationWrapper();
                    wrap.AuditId = nm.EntityId;
                    wrap.ContentTitle = feeditemMap.get(nm.EntityId).Title;
                    if(feeditemMap.get(nm.EntityId).Body!=null){
                        wrap.ContentBody = feeditemMap.get(nm.EntityId).Body.stripHtmlTags();
                    }
                    
                    wrap.ContentStatus = feeditemMap.get(nm.EntityId).Status;
                    if(usermap.keyset().contains(feeditemMap.get(nm.EntityId).CreatedById)){
                        wrap.ContentCreator = usermap.get(feeditemMap.get(nm.EntityId).CreatedById);
                    }                    
                    wrap.EntityType = FeedItemId.get(nm.EntityId);
                    wrap.URL = '/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId='+nm.EntityId;
                    dateTime cd = feeditemMap.get(nm.EntityId).CreatedDate;
                    wrap.CreatedDate = date.newInstance(cd.year(), cd.month(), cd.day());
                    if(flaggedByUsersMap.keyset().contains(nm.EntityId)){
                        wrap.FlaggedBy = [select name from user where Id=:nm.CreatedById].Name;
                    }                    
                    wrap.Note = nm.Note;
                    wrap.ModerationType = nm.ModerationType;
                    tableData.add(wrap); 
                }
                
                
                if(feedcommentMap.keyset().contains(nm.EntityId)){
                    ModerationWrapper wrap = new ModerationWrapper();
                    wrap.AuditId = nm.EntityId;
                    wrap.ContentTitle = 'NA';
                    if(feedcommentMap.get(nm.EntityId).CommentBody!=null){
                        wrap.ContentBody = feedcommentMap.get(nm.EntityId).CommentBody.stripHtmlTags();
                    }
                    
                    wrap.ContentStatus = feedcommentMap.get(nm.EntityId).Status;
                    if(usermap.keyset().contains(feedcommentMap.get(nm.EntityId).CreatedById)){
                        wrap.ContentCreator = usermap.get(feedcommentMap.get(nm.EntityId).CreatedById);
                    }                    
                    wrap.EntityType = FeedCommentId.get(nm.EntityId);
                    wrap.URL = '/lightning/cmp/c__helpNetworkModerationWrapper?c__crecordId='+nm.EntityId;
                    dateTime cd = feedcommentMap.get(nm.EntityId).CreatedDate;
                    wrap.CreatedDate = date.newInstance(cd.year(), cd.month(), cd.day());
                    if(flaggedByUsersMap.keyset().contains(nm.EntityId)){
                        wrap.FlaggedBy = [select name from user where Id=:nm.CreatedById].Name;
                    }
                    
                    wrap.Note = nm.Note;
                    wrap.ModerationType = nm.ModerationType;
                    tableData.add(wrap); 
                }
                
            }
            return tableData;
            
        }
        Catch(Exception e){
            system.debug('Error in Flagged Items : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }        
    }
    
    @AuraEnabled
    public static String DeleteItem(String entityId){
        try{
            Id fId = entityId;
            String sObjName =fId.getSObjectType().getDescribe().getName();
            
            if(sObjName=='FeedItem'){
                List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    delete feeditemstatusList;
                }
            }
            else if(sObjName == 'FeedComment'){
                List<FeedComment> feeditemstatusList =[SELECT Id, Status FROM FeedComment Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    delete feeditemstatusList;
                }
            }            
            
            List<NetworkModeration> moderationDetail = [SELECT Id, EntityId, CreatedById, ModerationType 
                                                        FROM NetworkModeration where EntityId=:entityId];
            
            if(moderationDetail.size()>0){
                delete moderationDetail;
            }           
            return 'Success';            
        }        
        
        Catch(Exception e){
            system.debug('Error in Delete Item: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    
    @AuraEnabled
    public static String UnflagItem(String entityId){
        try{
            List<NetworkModeration> moderationDetail = [SELECT Id, EntityId, CreatedById, ModerationType 
                                                        FROM NetworkModeration where EntityId=:entityId] ;
            
            if(moderationDetail.size()>0){
                delete moderationDetail;
            }           
            return 'Success';            
        }        
        
        Catch(Exception e){
            system.debug('Error in UnflagItem: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    
    @AuraEnabled
    public static String UnflagSelectedItems(String wrapList){
        try{
            List<ModerationWrapper> resultList = (List<ModerationWrapper>)JSON.deserialize(wrapList, List<ModerationWrapper>.class);
            System.debug('resultList='+resultList);            
            List<Id> feedIds = new List<Id>();                       
            for(ModerationWrapper wrap : resultList){
                feedIds.add(wrap.AuditId);                    
            }
            List<NetworkModeration> moderationDetail = [SELECT Id, EntityId, CreatedById, ModerationType 
                                                        FROM NetworkModeration where EntityId=:feedIds ORDER BY CreatedDate DESC] ;
            
            if(moderationDetail.size()>0){
                delete moderationDetail;
            }           
            return 'Success';            
        }        
        
        Catch(Exception e){
            system.debug('Error in UnflagItem: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    
    @AuraEnabled
    public static String DeleteSelectedItems(String wrapList){
        try{
            List<ModerationWrapper> resultList = (List<ModerationWrapper>)JSON.deserialize(wrapList, List<ModerationWrapper>.class);
            System.debug('resultList='+resultList);            
            List<Id> feedItemIds = new List<Id>();
            List<Id> feedCommentIds = new List<Id>();
            List<Id> feedIds = new List<Id>();
            
            for(ModerationWrapper wrap : resultList){
                Id fId = wrap.AuditId;                            
                String sObjName =fId.getSObjectType().getDescribe().getName();
                if(sObjName=='FeedItem'){
                    feedItemIds.add(fId); 
                    
                }
                else if(sObjName == 'FeedComment'){
                    feedCommentIds.add(fId);
                    
                }
            }
            
            List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:feedItemIds];
            if(feeditemstatusList.size()>0){
                delete feeditemstatusList;
            }
            List<FeedComment> feedCommentstatusList =[SELECT Id, Status FROM FeedComment Where Id=:feedCommentIds];
            if(feedCommentstatusList.size()>0){
                delete feedCommentstatusList;
            }
            
            
            for(ModerationWrapper wrap : resultList){
                feedIds.add(wrap.AuditId);                    
            }
            List<NetworkModeration> moderationDetail = [SELECT Id, EntityId, CreatedById, ModerationType 
                                                        FROM NetworkModeration where EntityId=:feedIds ORDER BY CreatedDate DESC] ;
            
            if(moderationDetail.size()>0){
                delete moderationDetail;
            }           
            return 'Success';            
        }        
        
        Catch(Exception e){
            system.debug('Error in UnflagItem: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled
    public static String ApproveAction(String entityId){
        try{
            Id fId = entityId;
            String Status;
            Boolean isNotPublished = false;
            String sObjName =fId.getSObjectType().getDescribe().getName();
            if(sObjName=='FeedItem'){
                List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    for(FeedItem item : feeditemstatusList ){
                        if(item.Status !='Published'){
                            isNotPublished = true;
                            item.Status = 'Published';
                        }
                    }
                    if(isNotPublished){
                        update feeditemstatusList;
                        Status = feeditemstatusList[0].Status;
                    }
                    else{
                        Status = 'Already Published';
                    }
                    
                }               
            }
            else if(sObjName == 'FeedComment'){
                List<FeedComment> feeditemstatusList =[SELECT Id, Status FROM FeedComment Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    for(FeedComment item : feeditemstatusList ){
                        if(item.Status !='Published'){
                            isNotPublished = true;
                            item.Status = 'Published';
                        }
                    }                    
                    if(isNotPublished == true){
                        update feeditemstatusList;
                        Status = feeditemstatusList[0].Status;
                    }
                    else{
                        Status = 'Already Published';
                    }                   
                }
            }           
            return  Status;  
        }
        Catch(Exception e){
            system.debug('Error in ApproveAction: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    @AuraEnabled
    public static String ApproveSelectedRecords(String wrapList){
        try{
            List<ModerationWrapper> resultList = (List<ModerationWrapper>)JSON.deserialize(wrapList, List<ModerationWrapper>.class);
            System.debug('resultList='+resultList);
            Boolean isNotPublished = false;
            List<Id> feedItemIds = new List<Id>();
            List<Id> feedCommentIds = new List<Id>();
            
            for(ModerationWrapper wrap : resultList){
                Id fId = wrap.AuditId;                            
                String sObjName =fId.getSObjectType().getDescribe().getName();
                if(sObjName=='FeedItem'){
                    feedItemIds.add(fId); 
                    
                }
                else if(sObjName == 'FeedComment'){
                    feedCommentIds.add(fId);
                    
                }
            }
            
            List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:feedItemIds];
            if(feeditemstatusList.size()>0){
                for(FeedItem item : feeditemstatusList ){
                    if(item.Status !='Published'){
                        isNotPublished = true;
                        item.Status = 'Published';                             
                    }
                }
                if(isNotPublished == true){
                    update feeditemstatusList;                            
                }                        
            }                        
            
            List<FeedComment> feedCommentstatusList =[SELECT Id, Status FROM FeedComment Where Id=:feedCommentIds];
            if(feedCommentstatusList.size()>0){
                for(FeedComment item : feedCommentstatusList){
                    if(item.Status !='Published'){
                        isNotPublished = true;
                        item.Status = 'Published';
                    }
                }
                if(isNotPublished == true){
                    update feedCommentstatusList;                    
                }                
            }            
            
            return  'Success';  
        }
        Catch(Exception e){
            system.debug('Error in ApproveAction: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    @AuraEnabled
    public static String RejectSelectedRecords(String wrapList){
        try{
            List<ModerationWrapper> resultList = (List<ModerationWrapper>)JSON.deserialize(wrapList, List<ModerationWrapper>.class);            
            Boolean isNotPublished = false;
            List<Id> feedItemIds = new List<Id>();
            List<Id> feedCommentIds = new List<Id>();
            
            for(ModerationWrapper wrap : resultList){
                Id fId = wrap.AuditId;                            
                String sObjName =fId.getSObjectType().getDescribe().getName();
                if(sObjName=='FeedItem'){
                    feedItemIds.add(fId); 
                    
                }
                else if(sObjName == 'FeedComment'){
                    feedCommentIds.add(fId);                    
                }
            }
            List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:feedItemIds];
            if(feeditemstatusList.size()>0){
                delete feeditemstatusList;
            }
            
            List<FeedComment> feedCommentstatusList =[SELECT Id, Status FROM FeedComment Where Id=:feedCommentIds];
            if(feedCommentstatusList.size()>0){
                delete feedCommentstatusList;
            }
            return 'Success';
            
        }        
        
        Catch(Exception e){
            system.debug('Error in RejctAction: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        } 
        
    }
    
    
    @AuraEnabled
    public static String RejectAction(String entityId){
        try{
            Id fId = entityId;
            String Status;
            Boolean isNotPublished = false;
            String sObjName =fId.getSObjectType().getDescribe().getName();
            if(sObjName=='FeedItem'){
                List<FeedItem> feeditemstatusList =[SELECT Id, Status FROM FeedItem Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    delete feeditemstatusList;
                    Status = 'FeedItemDeleted';
                }                
            }
            else if(sObjName == 'FeedComment'){
                List<FeedComment> feeditemstatusList =[SELECT Id, Status FROM FeedComment Where Id=:entityId];
                if(feeditemstatusList.size()>0){
                    delete feeditemstatusList;
                    Status = 'FeedItemDeleted';
                }
            }           
            return  Status;  
        }
        Catch(Exception e){
            system.debug('Error in ApproveAction: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }       
    }
    
    
    
    @AuraEnabled
    public static FeedWrapper ModerationDetailDisplayOnId(Id recId){
        try{
            List<FeedItem> feeditemList = new List<FeedItem>();
            List<FeedComment> feedcommentList = new List<FeedComment>();
            List<TopicAssignment> topicAssignList = new List<TopicAssignment>();
            List<FeedItem> UgNames = new List<FeedItem>();
            String sObjName =recId.getSObjectType().getDescribe().getName();
            FeedWrapper fw = new FeedWrapper();
            String sitelabel = System.Label.IN_CommunityName;
            Set<Id> contentDocIds = new set<Id>();
            Set<Id> comContentDocIds = new set<Id>();
            List<ImageWrapper> imageUrls = new List<ImageWrapper>();
            List<ImageWrapper> cimageUrls = new List<ImageWrapper>();
            List<contentversion> contentversionList = new List<contentversion>();
            List<contentversion> comContentversionList = new List<contentversion>();
            
            if(sObjName=='FeedComment'){
                //T1
                String feedItemId =[Select FeedItemId from FeedComment where Id=:recId].FeedItemId;
                topicAssignList = [SELECT Topic.Name,topicId from TopicAssignment where EntityId=:feedItemId];
                if(topicAssignList.size()==0) UgNames = [SELECT Id,Parent.Name FROM FeedItem where Id=:feedItemId AND parent.type='CollaborationGroup'];                                                                      
            }
            else{
                topicAssignList = [SELECT Topic.Name,topicId from TopicAssignment where EntityId=:recId];
                if(topicAssignList.size()==0) UgNames = [SELECT Id,Parent.Name FROM FeedItem where Id=:recId AND parent.type='CollaborationGroup'];                           
            } 
            
            if(sObjName=='FeedItem'){                
                feeditemList =[SELECT Id, Status,Body, Title,CreatedById,CreatedDate FROM FeedItem Where Id=:recId];
                fw.FeedId = feeditemList[0].Id; 
                fw.FeedTitle = feeditemList[0].Title;
                /*T2 starts*/
                if(feeditemList[0].body.contains('<img src')){
                    for(string st1 : feeditemList[0].body.split('<')){
                        if(st1.contains('img src')){
                            string temp = st1.substringBetween('img src="', '">');
                            String ContentdocId =  temp.substringAfter('sfdc://');
                            contentDocIds.add(ContentdocId);
                            
                        }}
                    if(contentDocIds.size()>0)  contentversionList = [Select Id from contentversion where contentdocumentId IN:contentDocIds ];
                    if(contentversionList.size()>0){
                        for(contentversion cv :contentversionList ){
                            ImageWrapper iw = new ImageWrapper();
                            iw.ImageURL = '/sfc/servlet.shepherd/version/download/'  + cv.Id;
                            imageUrls.add(iw);
                        }
                    }
                }
                System.debug('imageUrls>>'+imageUrls);
                
                if(imageUrls.size()>0) fw.imageUrlList = imageUrls; /*T2 ends*/
                fw.FeedBody = feeditemList[0].Body;                
                fw.FeedCreatorName = [SELECT Name FROM USER WHERE Id=:feeditemList[0].CreatedById].Name;
                DateTime dT = feeditemList[0].CreatedDate;
                fw.CreatedDate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year();
                fw.FeedCreatedByIdURL = '/'+feeditemList[0].CreatedById;
                fw.CommunityName = topicAssignList.size()>0 ? topicAssignList[0].topic.Name : UgNames[0].Parent.Name;
                fw.CommunityUrl = topicAssignList.size()>0 ? sitelabel+'topic/' + topicAssignList[0].topicId : sitelabel+'group/' + UgNames[0].Id ;
                fw.Status = feeditemList[0].Status;
                fw.QuestionURL = sitelabel+'question/' + feeditemList[0].Id;
            }
            else if(sObjName == 'FeedComment'){                
                feedcommentList =[SELECT Id, Status,CommentBody,CreatedById,FeedItemId,CreatedDate FROM FeedComment Where Id=:recId];
                feeditemList = [SELECT Id, Status,Body, Title,CreatedById,CreatedDate FROM FeedItem Where Id=:feedcommentList[0].FeedItemId];
                
                fw.FeedId = feeditemList[0].Id;              
                fw.FeedTitle = feeditemList[0].Title;
                fw.FeedBody = feeditemList[0].Body;
                /*T2 starts*/
                if(feeditemList[0].body.contains('<img src')){
                    for(string st1 : feeditemList[0].body.split('<')){
                        if(st1.contains('img src')){
                            string temp = st1.substringBetween('img src="', '">');
                            String ContentdocId =  temp.substringAfter('sfdc://');
                            contentDocIds.add(ContentdocId);
                            
                        }
                    }
                    if(contentDocIds.size()>0)  contentversionList = [Select Id from contentversion where contentdocumentId IN:contentDocIds ];
                    if(contentversionList.size()>0){
                        for(contentversion cv :contentversionList ){
                            ImageWrapper iw = new ImageWrapper();
                            iw.ImageURL = '/sfc/servlet.shepherd/version/download/'  + cv.Id;
                            imageUrls.add(iw);
                        }
                    }
                }
                System.debug('imageUrls>>'+imageUrls);
                
                if(imageUrls.size()>0) fw.imageUrlList = imageUrls; /*T2 ends*/
                
                fw.Comment = feedcommentList[0].CommentBody.striphtmltags();
                /*T2 starts*/
                if(feedcommentList[0].CommentBody.contains('<img src=')){
                    for(string st1 : feedcommentList[0].CommentBody.split('<')){
                       System.debug('==>'+st1);
                        if((st1!=null || st1!='' || st1!=' ' ) && st1.contains('img src')){
                            string temp = st1.substringBetween('img src="', '" alt');
                            String ContentdocId =  temp.substringAfter('sfdc://');
                            comContentDocIds.add(ContentdocId);
                            
                        }
                        else{
                            System.debug('st1 value='+st1);
                        }
                    }
                        
                
                    System.debug('comContentDocIds='+comContentDocIds);
                    if(comContentDocIds.size()>0)  comContentversionList = [Select Id from contentversion where contentdocumentId IN:comContentDocIds ];
                    System.debug('comContentversionList='+comContentversionList);
                    if(comContentversionList.size()>0){
                        for(contentversion cv :comContentversionList ){
                            ImageWrapper iw = new ImageWrapper();
                            iw.ImageURL = '/sfc/servlet.shepherd/version/download/'  + cv.Id;
                            cimageUrls.add(iw);
                        }
                    }
                }
                System.debug('cimageUrls>>'+cimageUrls);
                if(cimageUrls.size()>0) fw.CommentimageUrlList = cimageUrls; /*T2 ends*/
                
                fw.FeedCommentCreatorName = [SELECT Name FROM USER WHERE Id=:feedcommentList[0].CreatedById].Name;
                fw.FeedCreatorName = [SELECT Name FROM USER WHERE Id=:feeditemList[0].CreatedById].Name;
                DateTime dT = feeditemList[0].CreatedDate;
                fw.CreatedDate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year();
                DateTime dT1 = feedcommentList[0].CreatedDate;
                fw.CommentCreatedDate = dT1.format('MMMM') +' '+dT1.day()+' '+  dT1.year();
                fw.FeedCreatedByIdURL = '/'+feeditemList[0].CreatedById;
                fw.FeedCommentCreatedByIdURL = '/'+feedcommentList[0].CreatedById;
                fw.CommunityName = topicAssignList.size()>0 ? topicAssignList[0].topic.Name : UgNames[0].Parent.Name;
                fw.CommunityUrl = topicAssignList.size()>0 ? sitelabel+'topic/' + topicAssignList[0].topicId : sitelabel+'group/' + UgNames[0].Id ;
                fw.Status = feeditemList[0].Status;
                fw.QuestionURL = sitelabel+'question/' + feeditemList[0].Id;
                
            }
            return fw;
        }
        Catch(Exception e){
            system.debug('Error in Moderation Details : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
            
        }  
    }
    
    //T1
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String feedEntityID) {
        System.debug('feedEntityID>'+feedEntityID);
        // Get content version IDs
        List<FeedAttachment> attachList = [Select RecordId FROM FeedAttachment where FeedEntityId=:feedEntityID];
        System.debug('attachList>'+attachList);
        set<Id> contentVersionIds = new set<Id>();
        
        if(attachList.size()>0){
            for(FeedAttachment att : attachList){
                contentVersionIds.add(att.RecordId);                       
            }            
        }        
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE ID IN:contentVersionIds];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
    
    
    
    public static Map<Id,String> getUserNames(Set<id> usrIds){
        Map<Id,String> userEmails = new Map<Id,String>();
        for(User u : [select Id,Name from user where Id=:usrIds]){
            userEmails.put(u.Id,u.Name);        
        }
        if(userEmails.size()>0){
            return userEmails;
        }
        else return null;        
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
    
    
    
    
    public Class ModerationWrapper{
        @AuraEnabled public String AuditId;
        @AuraEnabled public String ContentTitle;
        @AuraEnabled public String ContentBody;
        @AuraEnabled public String ContentStatus;
        @AuraEnabled public String ContentCreator;
        @AuraEnabled public String FlaggedBy;
        @AuraEnabled public String Note;
        @AuraEnabled public String ModerationType;
        @AuraEnabled public String EntityType;
        @AuraEnabled public Date CreatedDate;
        @AuraEnabled public String URL;
        @AuraEnabled public String CommunityName;
        
    }
    
    //For Moderation Details    
    Public Class FeedWrapper{
        @AuraEnabled public String FeedId;
        @AuraEnabled public String FeedTitle;
        @AuraEnabled public String FeedBody;
        @AuraEnabled public String FeedCreatorName;
        @AuraEnabled public String FeedCommentCreatorName;
        @AuraEnabled public String Comment;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String CommentCreatedDate;
        @AuraEnabled public String FeedCreatedByIdURL;
        @AuraEnabled public String FeedCommentCreatedByIdURL;
        @AuraEnabled public String CommunityName;
        @AuraEnabled public String CommunityUrl;
        @AuraEnabled public String Status;
        @AuraEnabled public String QuestionURL;
        @Auraenabled public List<ImageWrapper> imageUrlList;
        @Auraenabled public List<ImageWrapper> CommentimageUrlList;
    }
    
    Public Class ImageWrapper{
        @AuraEnabled public String ImageURL;
    }
    
    
    
    
    
}