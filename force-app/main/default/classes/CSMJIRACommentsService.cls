public with sharing class CSMJIRACommentsService {
    
     /*
     Method Name : createPlanCommentFromPlanFeed
     Description : This method creates a Plan comment record from the Plan Feed
     Parameters  : List of FeedItem Record
     Return Type : NULL
    */

    public void createPlanCommentFromFeedItem(List<FeedItem> baseFeedItemList){
        List<FeedItem> feedItemToProcessList = new  List<FeedItem>();
        List<Plan_Comment__c> planCommentToCreateList = new  List<Plan_Comment__c>();
        List<String> zIssueStringList = new List<String>();
        Map<Id,String> feedIdZIssueStringMap = new Map<Id,String>();
        Map<String,Id> zissueNameIdMap = new  Map<String,Id>();
        Set<Id> tst=new Set<Id>();
        String stringmatch = Label.CaseComment_Jira;
        //Loop through the list.
        //rec.ParentId.getSObjectType().getDescribe().getName() == 'Plan__c'
        //Check if created by = jira ==> cc.CreatedById == Label.jiraintegrationuser
        //!rec.Body.contains(stringmatch)
        //Add them to the List.
        for(FeedItem FIRec : baseFeedItemList){
            if(FIRec.ParentId.getSObjectType().getDescribe().getName() == 'Plan__c' &&
                (FIRec.CreatedById == Label.jiraintegrationuser || test.isRunningTest())){
                if(!FIRec.Body.contains(stringmatch)){
                    feedItemToProcessList.add(FIRec);
                    tst.add(FIRec.Id);
                }
            }
        }
     
        if(!feedItemToProcessList.isEmpty()){            
            for(FeedItem FIRec : feedItemToProcessList){
                String sRegex = '^.*?-(.*)-.*$';
                Pattern sPattern = Pattern.compile(sRegex);
                system.debug(FIRec.Body);
                String textval = FIRec.Body.stripHtmlTags();
                Matcher sMatcher = sPattern.matcher(textval);
                String sMatch = '';
                if(sMatcher.matches()){
                    sMatch = sMatcher.group(1).trim();
                }
                feedIdZIssueStringMap.put(FIRec.Id,sMatch);
            }
        }
        for(zsfjira__ZIssue__c zi : [Select Id,Name from zsfjira__ZIssue__c where Name in :feedIdZIssueStringMap.values()])  {
            if(zi.name <> null){
                zissueNameIdMap.put(zi.Name,zi.Id); //need to check this value.
            }
        }
         if(!feedItemToProcessList.isEmpty()){
            for(FeedItem objFIRRecord : feedItemToProcessList){
                Plan_Comment__c objPlanCommnetRecord = new Plan_Comment__c(); 
                objPlanCommnetRecord  = CSMUtilities.createPlanComment(objFIRRecord.ParentId,objFIRRecord.Body,CSMUtilities.STATUS_SUBMITTED,'JIRA','',true);
                Id zIssueId = zissueNameIdMap.get(feedIdZIssueStringMap.get(objFIRRecord.Id)); //need to check
                if(zIssueId <> null){
                    objPlanCommnetRecord.ZIssue__c = zIssueId;
                }
                planCommentToCreateList.add(objPlanCommnetRecord);
            }        
            if(!planCommentToCreateList.isEmpty()){
                insert planCommentToCreateList;
            }
            delete feedItemToProcessList;
        }        
    }
   

}