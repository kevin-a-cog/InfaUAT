/*
    @Created Date:  March 2022
    @Description:   This is the Controller for the feed activity timeline LWC. This Apex Controller fetches and builds the
    feed timeline data for est summary and est outputs.This class is covered by IPUE_ActivityTimelineCntlrTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                         Tag

    Saurabh Khandelwal    10-Mar-2022   IPUE-160        Initial create and fetched all the feeds for the record.            <T1>
    ********************************************************************************************************************************************
*/
public class IPUE_ActivityTimelineCntlr {
	
    public static Map<String,Estimation_Summary__c>estSummMap=new Map<String,Estimation_Summary__c>();
    public static Map<String,Estimation_Output__c>estOutputMap=new Map<String,Estimation_Output__c>();
    public static Map<String,FeedItem>feedsMap=new Map<String,FeedItem>();

    /*
     * method getActivities
     * @param recordId: Id of the Estimation Summary the LWC was called from
     * @description: Query out all feed related data from summary and child est outputs and put into a wrapper
     *  structure for iterating, but more flexible and ready to use in the LWC.
     */
    @AuraEnabled(cacheable=true)
    public static String getActivities(String recordId){
        
        //fetching estSummary
        estSummMap=new Map<String,Estimation_Summary__c>([SELECT Id,Name,CreatedDate,CreatedBy.Name,(SELECT Id FROM Feeds) FROM 
                                                          Estimation_Summary__c WHERE Id = :recordId]);
        
        //fetching estOutputs                                                  
        estOutputMap= new Map<String,Estimation_Output__c>(IPUE_AcitivtyUtils.getEstOutputWithFeeds(recordId));
        
           
        List<Id> parentIds = new List<Id>();
		List<sObject>feedsList = new List<sObject>();   

        for(Estimation_Summary__c est :estSummMap.values() ){
            feedsList.addAll(est.Feeds);
        }
        for(Estimation_Output__c estOut :estOutputMap.values() ){
           feedsList.addAll(estOut.Feeds);
        }
               
        //fetching feed items.
        feedsMap=new Map<String,FeedItem>([SELECT Id,Body,ParentId,CreatedDate,CreatedBy.Name,CreatedById,
                                          (SELECT CreatedDate,CommentBody,CreatedBy.Name FROM FeedComments ORDER BY CreatedDate ASC)
                                          FROM FeedItem WHERE Id IN :feedsList]);
        
        List<ActivityWrapper> feedActivityWrapper = new List<ActivityWrapper>();
        Map<String,List<FeedItem>>userIdToFeeds = new Map<String,List<FeedItem>>();
        Map<String,ResultWrapper>userIdToResultWrap= new Map<String,ResultWrapper>();
        
        for(FeedItem feed : feedsMap.values()){
            feedActivityWrapper.add(new ActivityWrapper(feed));    
        }
        //sorting wrapper based on custom sorting logic defined.
        feedActivityWrapper.sort();
        Integer counter=1;
        for(ActivityWrapper act : feedActivityWrapper){
            
            String mapKey=act.feed.ParentId+';'+act.feed.CreatedById;
            if(!userIdToResultWrap.containsKey(mapKey)){
                
                String recordName='';
                if(estSummMap.containsKey(act.feed.ParentId)){
                    recordName=estSummMap.get(act.feed.ParentId).Name;
                }
                else{
                    recordName=estOutputMap.get(act.feed.ParentId).Estimation_Schedule__r.Consumption_Description__c!=null?
                        	   estOutputMap.get(act.feed.ParentId).Estimation_Schedule__r.Consumption_Description__c.stripHtmlTags() : '';
                }
                userIdToResultWrap.put(mapKey,new ResultWrapper(act.feed.Id,act.feed.CreatedBy.Name,recordName,null,
                                                                null,true,act.feed.ParentId,act.feed.Id,counter));
            
                counter++;
            }
            
            ResultWrapper resWrap=new ResultWrapper(act.feed.Id,act.feed.CreatedBy.Name,null,act.feed.body,
                                                    act.feed.CreatedDate,act.feed.FeedComments.size()>0?true:false,
                                                    act.feed.ParentId,act.feed.Id,null);
            
            if(act.feed.FeedComments.size()>0){
                List<ResultWrapper>childWrapList=new List<ResultWrapper>();
                for(FeedComment feedCom : act.feed.FeedComments){
		            childWrapList.add(new ResultWrapper(act.feed.Id,feedCom.CreatedBy.Name,null,feedCom.CommentBody,
                                                       feedCom.CreatedDate,false,act.feed.ParentId,feedCom.Id,null));       
                }
                resWrap.childList=childWrapList;  
            }
            if(userIdToResultWrap.containsKey(mapKey)){
                userIdToResultWrap.get(mapKey).childList.add(resWrap);
            }
            
        }
        return JSON.serialize(userIdToResultWrap.values());
    }
    
    //wrapper class for result.
    public class ResultWrapper{
        public String ownerName {get; set;}
        public String recordName {get; set;}
        public String feedBody {get; set;}
        public String createdDay {get; set;}
        public String createdMonth{get; set;}
        public String createdYear{get; set;}
        public Boolean showChild {get; set;} 
        public List<ResultWrapper> childList {get; set;}  
        public Id feedId {get; set;} 
        public Id parentId {get; set;}
        public String recordId {get; set;}
        public Map<String,FeedItem>feedsItemsMap {get;set;}
        
        public ResultWrapper(Id feedId, String ownerName, String recordName,String body, DateTime createdDate,
                             Boolean showChild,String parentId,String recordId,Integer counter){
            this.feedId=feedId;
            this.parentId=parentId;
            this.ownerName=ownerName;
            this.recordName=recordName;
            this.feedBody=body!=null ? body.stripHtmlTags():null;
            if(this.feedBody!=null && this.feedBody.length()>30){
 				this.feedBody=this.feedBody.substring(0,29)+'...';
            }
            if(createdDate!=null){
                this.createdDay=createdDate.format('d');
                this.createdMonth=createdDate.format('MMM');
                this.createdYear=createdDate.format('YYYY');
            }
            this.showChild=showChild;

            if(this.showChild && counter !=null && counter>2){
                this.showChild=false;
            }
            this.childList=new List<ResultWrapper>();
            this.recordId=recordId;                                
        }
    }

    //comparable class for implementing custom sorting logic.
    public class ActivityWrapper implements Comparable{
       
        public FeedItem feed {get; set;}
         
        public ActivityWrapper(FeedItem feed){
            this.feed = feed;     
        }
        
        public Integer compareTo(Object compareTo) {
            ActivityWrapper actObj = (ActivityWrapper) compareTo;
            String objectType = '';
            String baseobjectType = '';
 
            if(actObj.feed != NULL)
                objectType = 'feed';

            if(feed != NULL)
                baseobjectType = 'feed';

           
            if(baseobjectType == 'feed'){
                
                if(objectType == 'feed'){
                    
                    //when both feeds have feed comments then we will sort on lastest feed comments basis.
                    if(feedsMap.get(feed.Id).FeedComments.size()>0 && feedsMap.get(actObj.feed.Id).FeedComments.size()>0){   
                        Integer latestFeedCommentIndex=feedsMap.get(feed.Id).FeedComments.size()-1;
                        Integer latestactObjFeedCommentIndex=feedsMap.get(actObj.feed.Id).FeedComments.size()-1;
                        if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate > feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return -1;
                        if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate == feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return 0;
                        if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate < feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return 1;
                    }
                else{
                        
                        //when one feed have feed comments and other has no feed comments.
                        if(feedsMap.get(feed.Id).FeedComments.size()==0 && feedsMap.get(actObj.feed.Id).FeedComments.size()>0){
                            Integer latestactObjFeedCommentIndex=feedsMap.get(actObj.feed.Id).FeedComments.size()-1;
                            if(feed.CreatedDate > feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return -1;
                            if(feed.CreatedDate == feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return 0;
                            if(feed.CreatedDate < feedsMap.get(actObj.feed.Id).FeedComments[latestactObjFeedCommentIndex].CreatedDate) return 1;
                        }
                        else if(feedsMap.get(feed.Id).FeedComments.size()>0 && feedsMap.get(actObj.feed.Id).FeedComments.size()==0){
                            Integer latestFeedCommentIndex=feedsMap.get(feed.Id).FeedComments.size()-1;
                           	if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate > actObj.feed.CreatedDate) return -1;
                            if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate == actObj.feed.CreatedDate) return 0;
                            if(feedsMap.get(feed.Id).FeedComments[latestFeedCommentIndex].CreatedDate < actObj.feed.CreatedDate) return 1;
                        }
                        else if(feedsMap.get(feed.Id).FeedComments.size()==0 && feedsMap.get(actObj.feed.Id).FeedComments.size()==0){
                            if(feed.CreatedDate > actObj.feed.CreatedDate) return -1;
                            if(feed.CreatedDate == actObj.feed.CreatedDate) return 0;
                            if(feed.CreatedDate < actObj.feed.CreatedDate) return 1;
                        }
                           
                    }
 
                }
            }
            return 1; 
        }
        
    }
    
}