/*
Change History
*********************************************************************************************************************
ModifiedBy      Date        Jira No.    Description                                                 Tag
*********************************************************************************************************************
NA              NA          UTOPIA      Initial version.                                            NA
Amit Garg       10/01/2022  I2RT-4592   Restrict Events query to ignore child events                T01
balajip         05/04/2022  I2RT-5459   Added feature to tag users in a Case Comment                T02
balajip         13/08/2022  I2RT-6662   To not delete the Case Comment that is being saved.         T03
Vignesh D       07/10/2022  I2RT-7197   Added logic to verify user's access and then get the        T04
                                        Case Comments in without sharing context
Vignesh D       01/12/2022  I2RT-7534   Allow before & after insert case comment trigger to run     T05
                                        for the second time
Vignesh D       16/12/2022  I2RT-7604   Added Created_By__c field to the query                      T06
Isha Bansal     03/22/2023   I2RT-7615 The collaborate category comments should                     T07
                                        come both in the Internal and Collaboration tab  
Isha Bansal     16/07/2023  I2RT-8643  Included Sub type field in query of method 'getCaseComments'  T08 
Isha Bansal     19/07/2023   I2RT-8643 Search not working properly in case comment fix               T09
Isha Bansal     19/07/2023   I2RT-8643 Made search case insensitive and fixed search in email        T10
Shashikanth		18-Oct-2023	 I2RT-7702  Added ActivityDateTime field for Event records.			     T11

*/
public with sharing class CaseCommentController {
    public static String sortOrder = 'ASC';
    public static globalApexManager GAM = new globalApexManager();
    
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException{}
    
    @AuraEnabled(cacheable=true)
    public static boolean getPermissionOnObject(){
        Schema.DescribeSObjectResult s = Case_Comment__c.sObjectType.getDescribe();
        Boolean isCreateable = s.isCreateable();
        return isCreateable;
    }

    /** 
     * @description Method to fetch the pre-draft comment for auto save feature
     */ 
    @AuraEnabled
    public static List<Case_Comment__c> getPreDraftComment(String caseRecordId) {
        String caseId = caseRecordId; 
        List<Case_Comment__c> caseCommentList = new List<Case_Comment__c>();
        try {
            caseCommentList = [SELECT Id, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, 
                                    Email_Opened__c,Visibility__c, Status__c, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl,
                                    CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate,
                                    Tagged_User_1__c, Tagged_User_1__r.Name, Tagged_User_2__c, Tagged_User_2__r.Name, Tagged_User_3__c, Tagged_User_3__r.Name, Tagged_User_4__c, Tagged_User_4__r.Name, Tagged_User_5__c, Tagged_User_5__r.Name, //T02
                                    (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id 
                                    FROM ContentDocumentLinks)
                              FROM Case_Comment__c
                              WHERE Case__c = :caseId AND Parent_Comment__c = null AND Status__c = 'Pre Draft' AND CreatedById =: UserInfo.getUserId()
                              ORDER BY Createddate asc
                              ];
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return caseCommentList;
    }
    /**
     * @description Method to update case team member with last read time stamps
     * @Developer : Deva ITRT 2636
     * Date:12-June-2021 
     */    
    @AuraEnabled
    public static void updateCaseTeamMember(String caseTeamRecordId){        
        if(caseTeamRecordId!=null){
            update new Case_Team__c(Id=caseTeamRecordId,Last_Read_TimeStamp__c=System.now());
        }
    }
    /**
     * @description Method to fetch current team member associated to case
     * @Developer : Deva ITRT 2636
     * Date:12-June-2021 
     */    
    @AuraEnabled
    public static List<Case_Team__c> getCaseTeamMember(String caseRecordId){
        List<Case_Team__c> caseTeamList = new List<Case_Team__c>();
        if(String.isnotBlank(caseRecordId)){
            caseTeamList = [SELECT Id, Last_Read_TimeStamp__c FROM Case_Team__c WHERE User__c=: UserInfo.getUserId() AND Case__c=:caseRecordId Limit 1];
        }
        return caseTeamList;
    }

    /**
     * @description Method to fetch the all case comments along with file attachments and child comments if any
     */
    @AuraEnabled
    public static List<CaseCommentWrapper> getCaseComments(String caseRecordId, String visibility,String commentCategory, 
                                                           String status, String type, Boolean isInbound, String sortBy, String searchKey, String tabName,
                                                           Integer limitValue, Integer offset, String taggedUserId) { //T02
        System.debug('@Developer -->getCaseComments:' );
        System.debug('@Developer --> caseRecordId :' + caseRecordId);
        System.debug('@Developer --> visibility :' + visibility);
        System.debug('@Developer --> commentCategory :' + commentCategory);
        System.debug('@Developer --> status :' + status);
        System.debug('@Developer --> type :' + type);
        System.debug('@Developer --> isInbound :' + isInbound);
        System.debug('@Developer --> sortBy :' + sortBy);
        System.debug('@Developer --> searchKey :' + searchKey);
        System.debug('@Developer --> tabName :' + tabName);
        System.debug('@Developer --> limitValue :' + limitValue);
        System.debug('@Developer --> offset :' + offset);
        String typ = type;
        String caseId = caseRecordId;
        Id currentUserId = UserInfo.getUserId();

        List<CaseCommentWrapper> commentList = new List<CaseCommentWrapper>();
                                                                            
        Set<Id> caseCommentUserIdSet = new Set<Id>();
        Map<String, String> roleMap = new Map<String, String>();
        
        Set<Id> childCommentIdSet = new Set<Id>();
        List<Case_Comment__c> caseCommentList = new List<Case_Comment__c>();
        List<Case_Comment__c> caseChildCommentList = new List<Case_Comment__c>();
        Map<Id, Case_Comment__c> childCommentMap = new Map<Id, Case_Comment__c>();
        Map<Id, String> userProfilePhotoURLMap = new Map<Id,String>();
        String srchKey =  String.isNotBlank(searchKey) ? String.escapeSingleQuotes(searchKey) : '';
        Boolean showTasksEvents = (tabName != null && (tabName.equalsIgnoreCase('AllMainTab') || tabName.equalsIgnoreCase('InternalAllTab')));
         //Deva - Start - I2RT-3585 the below logic should not run if the user click on Task Tab
        if((String.isNotBlank(type) && !type.equalsIgnoreCase('Tasks')) || String.isBlank(type)){
            //@Akhilesh 20 May 2021 --start    Sub_Type__c   Type__c      Created_By__c                                        
            String soqlChildCaseComment = 'SELECT Id,Recommendation__c, Created_By__c, ZIssue__c,Extend_OGR_By__c, Inbound__c, Parent_Comment__c,Parent_Comment__r.ZIssue__c, Case__c, Comment__c, Type__c,Sub_Type__c, Date_Time_Scheduled__c, Severity__c, Email_Opened__c,Email_Clicked__c,Delivery__c,Visibility__c, Status__c, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl,' 
                            + ' CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate, Comment_Category__c, Email_Sent__c, '
                            + ' Tagged_User_1__c, Tagged_User_1__r.Name, Tagged_User_2__c, Tagged_User_2__r.Name, Tagged_User_3__c, Tagged_User_3__r.Name, Tagged_User_4__c, Tagged_User_4__r.Name, Tagged_User_5__c, Tagged_User_5__r.Name, ' //T02
                            + ' (SELECT Id, Case_Comment__c,Email_Opened__c FROM CaseCommentEmailStats__r), '
                            + ' (SELECT Id, Case_Comment__c, Like__c, disLike__c,Feedback__c FROM CaseCommentFeedbacks__r where Ownerid=:currentUserId)'
                            + ' FROM Case_Comment__c' 
                            + ' WHERE Case__c = :caseId AND Parent_Comment__c != null AND Status__c != \'Pre Draft\' AND Is_Deleted__c = false AND (Visibility__c != \'Private\' OR CreatedById=:currentUserId)'
                            + ' AND (Status__c != \'Draft\' OR (Status__c = \'Draft\' AND CreatedById =: currentUserId))';//Vignesh D: Include Draft comments only if the created by user is same as logged in user //added Parent_Comment__r.ZIssue__c I2RT-7491 //T08
            
                            //Deva added feedback object query to pull case feedback and convert as like and dislike buttons
            String soqlParentCaseComment = 'SELECT Id,Recommendation__c, Created_By__c, ZIssue__c, Extend_OGR_By__c, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Type__c,Sub_Type__c, Date_Time_Scheduled__c, Severity__c, Email_Opened__c,Email_Clicked__c,Delivery__c,Visibility__c, Status__c, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl,' 
                            + ' CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate, Comment_Category__c,Email_Sent__c, '
                            + ' Tagged_User_1__c, Tagged_User_1__r.Name, Tagged_User_2__c, Tagged_User_2__r.Name, Tagged_User_3__c, Tagged_User_3__r.Name, Tagged_User_4__c, Tagged_User_4__r.Name, Tagged_User_5__c, Tagged_User_5__r.Name, ' //T02
                            + ' (SELECT Id, Inbound__c, Parent_Comment__c,Parent_Comment__r.ZIssue__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, Visibility__c, Is_Deleted__c, ' 
                            + ' Status__c, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl, CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate, Comment_Category__c FROM Case_Comments__r WHERE Is_Deleted__c = false order by createdDate),' 
                            + ' (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks),' 
                            + ' (SELECT Id, Case_Comment__c,Email_Opened__c FROM CaseCommentEmailStats__r), '
                            + ' (SELECT Id, Case_Comment__c, Like__c, disLike__c,Feedback__c FROM CaseCommentFeedbacks__r where Ownerid=:currentUserId)'
                            + ' FROM Case_Comment__c' 
                            + ' WHERE (Case__c = :caseId AND Parent_Comment__c = null AND Status__c != \'Pre Draft\' AND Is_Deleted__c = false AND (Visibility__c != \'Private\' OR CreatedById=:currentUserId)'
                            + ' AND (Status__c != \'Draft\' OR (Status__c = \'Draft\' AND CreatedById =: currentUserId))';//Vignesh D: Include Draft comments only if the created by user is same as logged in user . Added Parent_Comment__r.ZIssue__c I2RT-7491 //T08

            if(String.isNotBlank(visibility)) {
                String visiblty = visibility;
                if(searchKey==null || String.isBlank(searchKey)) { // T09
                     soqlChildCaseComment += ' AND Visibility__c = :visiblty';
                    }else{
                        soqlChildCaseComment += ' AND Parent_Comment__r.Visibility__c = :visiblty';   
                    }
                soqlParentCaseComment += ' AND Visibility__c = :visiblty';
            }  
            
            if(String.isNotBlank(commentCategory) && commentCategory != 'All' && !type.equalsIgnoreCase('Raise Hand')) { //T07 - added raise hand condition
                String comCat = commentCategory;
                soqlChildCaseComment += ' AND Comment_Category__c = :comCat';
                soqlParentCaseComment += ' AND Comment_Category__c = :comCat';
            }  
            
            if(String.isNotBlank(status)) {
                String stats = status;
                soqlChildCaseComment += ' AND Status__c = :stats';
                soqlParentCaseComment += ' AND Status__c = :stats';
            }  
            //Deva :  I2RT-3566 :  Modified the logic to club Escalation,Call Back, Revise Priority,  Live Assistance as Attention Request
            if(String.isNotBlank(type) && type.equalsIgnoreCase('Attention Request')){
                //I2RT-4234 - included type Predictive Escalation
                Set<String> commentTypeSet = new Set<String>{'Predictive Escalation','Escalation','Callback','Revise Priority','Live Assistance'};
                soqlChildCaseComment += ' AND Type__c IN :commentTypeSet';
                soqlParentCaseComment += ' AND Type__c IN :commentTypeSet';
            }else if(String.isNotBlank(type) && type.equalsIgnoreCase('Raise Hand')){ //T07
                soqlParentCaseComment += ' AND (Type__c = :typ ';   //T07 
                soqlChildCaseComment += ' AND (Type__c = :typ ';
                    if(String.isNotBlank(commentCategory)){
                        soqlParentCaseComment+='  OR Comment_Category__c=:commentCategory)';
                        soqlChildCaseComment+='  OR Comment_Category__c=:commentCategory)';
                    }else{
                        soqlParentCaseComment+=')';
                        soqlChildCaseComment+=')';
                    } // T07 ends here
                
            } else if(String.isNotBlank(type)) {                
                if(searchKey==null || String.isBlank(searchKey)) {
                    soqlChildCaseComment += ' AND Type__c = :typ';
                }else{
                    soqlChildCaseComment += ' AND Parent_Comment__r.Type__c = :typ';                    
                }
                soqlParentCaseComment += ' AND Type__c = :typ';
            }
            
            if(isInbound != null && isInbound) {
                if(searchKey==null || String.isBlank(searchKey)) {  //T09
                    soqlChildCaseComment += ' AND Inbound__c = true';
                } else{
                    soqlChildCaseComment += ' AND Parent_Comment__r.Inbound__c = true';
                }
                soqlParentCaseComment += ' AND Inbound__c = true';
            }
            
          /*  if(String.isNotBlank(searchKey)) { //T09 -> commented it out
                soqlChildCaseComment += ' AND Comment_to_Search__c LIKE \'%' + srchKey + '%\'';
                soqlParentCaseComment += ' AND Comment_to_Search__c LIKE \'%' + srchKey + '%\'';
            }*/

            //T02
            if(String.isNotBlank(taggedUserId)){
                soqlParentCaseComment += ' AND (Tagged_User_1__c = :taggedUserId OR Tagged_User_2__c = :taggedUserId OR Tagged_User_3__c = :taggedUserId OR Tagged_User_4__c = :taggedUserId OR Tagged_User_5__c = :taggedUserId)';
            }
            
            System.debug('@Developer --> soqlChildCaseComment :' + soqlChildCaseComment);
            caseChildCommentList = Database.query(soqlChildCaseComment);

            List<Case_Comment__c> caseChildCommentSearchList = new List<Case_Comment__c>(); //T09
            if(searchKey!=NULL && String.isNotBlank(searchKey)) { //T09
                for(Case_Comment__c childcomm:caseChildCommentList){
                    if(childcomm.Comment__c.stripHtmlTags().toLowerCase()?.contains(searchKey.toLowerCase())){            //T10- stripHtmlTags and  toLowerCase             
                        caseChildCommentSearchList.add(childcomm);
                    }
                }//for loops ends here                
                    caseChildCommentList=caseChildCommentSearchList;
                
            }
           
            set<Id> setParentCommentId = new set<Id>();
            for(Case_Comment__c cc : caseChildCommentList){
                setParentCommentId.add(cc.Parent_Comment__c);
                userProfilePhotoURLMap.put(cc.CreatedById, cc.CreatedBy.FullPhotoUrl);
            }
            
            if(caseChildCommentList.size() > 0  ){
                soqlParentCaseComment += ' ) OR  Id IN :setParentCommentId ';
            }
            else{
                soqlParentCaseComment += ' ) ';
            }
            
            if(String.isNotBlank(sortBy)) {
                String srtBy = String.escapeSingleQuotes(sortBy);
                soqlParentCaseComment += ' ORDER BY ' + srtBy;
            }

            //I2RT-4607
            /*if(limitValue != null && offset != null){
                soqlParentCaseComment += ' LIMIT ' + limitValue + ' OFFSET ' + offset;
            }*/
           
            System.debug('@Developer --> soqlParentCaseComment :' + soqlParentCaseComment);
            //@Akhilesh 20 May 2021 --end 
            
            caseCommentList = Database.query(soqlParentCaseComment);

            List<Case_Comment__c> caseCommentSearchList = new List<Case_Comment__c>(); //T09
            if(searchKey!=null && String.isNotBlank(searchKey)){ //T09                
                for(Case_Comment__c casecomm:caseCommentList){
                    if(casecomm.Comment__c.stripHtmlTags().toLowerCase()?.contains(searchKey.toLowerCase()) || (setParentCommentId!=null && setParentCommentId.contains(casecomm.Id))){  //T10- stripHtmlTags and  toLowerCase
                        caseCommentSearchList.add(casecomm);                        
                    }
                }               
                    caseCommentList=caseCommentSearchList;               
             }
                           
            for(Case_Comment__c cc : caseCommentList) {
                caseCommentUserIdSet.add(cc.CreatedById);
                userProfilePhotoURLMap.put(cc.CreatedById, cc.CreatedBy.FullPhotoUrl);
                for(Case_Comment__c ccr : cc.Case_Comments__r) {
                    caseCommentUserIdSet.add(ccr.CreatedById);
                    childCommentIdSet.add(ccr.Id);
                    userProfilePhotoURLMap.put(ccr.CreatedById, ccr.CreatedBy.FullPhotoUrl);
                }
            }

            if(!childCommentIdSet.isEmpty()) {
                childCommentMap = new Map<Id, Case_Comment__c>([SELECT Id,Recommendation__c, Extend_OGR_By__c, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Type__c, Date_Time_Scheduled__c, Severity__c, Visibility__c, Status__c, 
                                        CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl, CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate,Comment_Category__c, 
                                        Tagged_User_1__c, Tagged_User_1__r.Name, Tagged_User_2__c, Tagged_User_2__r.Name, Tagged_User_3__c, Tagged_User_3__r.Name, Tagged_User_4__c, Tagged_User_4__r.Name, Tagged_User_5__c, Tagged_User_5__r.Name,  //T02
                                        (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks),
                                        (SELECT Id, Case_Comment__c, Like__c, disLike__c,Feedback__c FROM CaseCommentFeedbacks__r where Ownerid=:currentUserId)
                                        FROM Case_Comment__c
                                        WHERE Id IN :childCommentIdSet
                                        ]);
            }  

            for(Case_Team__c team : [SELECT Role__c, User__c FROM Case_Team__c WHERE User__c IN :caseCommentUserIdSet AND Case__c = :caseId]) {
                roleMap.put(team.User__c, team.role__c);
            }

            List<CaseCommentWrapper> childccwraplist;

            for(Case_Comment__c cc : caseCommentList) {
                String role = roleMap.containsKey(cc.CreatedById) ? roleMap.get(cc.CreatedById): '';     
                childccwraplist = new List<CaseCommentWrapper>();       
                if(!cc.Case_Comments__r.isEmpty()) {
                   // commentList.add(new CaseCommentWrapper(cc, role, new CaseCommentWrapper(childCommentMap.get(cc.Case_Comments__r[0].Id), roleMap.containsKey(cc.Case_Comments__r[0].CreatedById) ? roleMap.get(cc.Case_Comments__r[0].CreatedById): '', null)));
                   if(string.isblank(cc.ZIssue__c)){
                            commentList.add(new CaseCommentWrapper(cc, role, new CaseCommentWrapper(childCommentMap.get(cc.Case_Comments__r[0].Id), roleMap.containsKey(cc.Case_Comments__r[0].CreatedById) ? roleMap.get(cc.Case_Comments__r[0].CreatedById): '',null)));
                    } else{
                            for(case_comment__c ccommen: cc.Case_Comments__r){
                                CaseCommentWrapper childccwrap = new CaseCommentWrapper(ccommen, roleMap.containsKey(ccommen.CreatedById) ? roleMap.get(ccommen.CreatedById): '', null); 
                                childccwraplist.add(childccwrap);                        
                            }     
                            commentList.add(new CaseCommentWrapper(cc, role, childccwraplist,true));                
                    }
                } else {                
                    commentList.add(new CaseCommentWrapper(cc, role, null));
                }
            }            
            if(tabName == 'AllMainTab'){
                List<CaseHistory> lstCaseHistory = [Select Id, CaseId, Field, NewValue, OldValue, CreatedById, CreatedDate, 
                                                    CreatedBy.Name
                                                    From CaseHistory 
                                                    Where Field IN ('Status','Priority') And CaseId = :caseId];
                for(CaseHistory caseHistory : lstCaseHistory){
                    String role = roleMap.containsKey(caseHistory.CreatedById) ? roleMap.get(caseHistory.CreatedById): ''; 
                    String userProfilePhotoUrl =  userProfilePhotoURLMap.containsKey(caseHistory.CreatedById) ? userProfilePhotoURLMap.get(caseHistory.CreatedById) : '';
                    commentList.add(new CaseCommentWrapper(caseHistory,userProfilePhotoUrl,role));
                }  
            }
             
        } 
        //Deva - Start - I2RT-3585 To Capture the tasks and events associated to case  
        //Query  task and wrap the records to wrpaper list
        // if(String.isNotBlank(type) && type.equalsIgnoreCase('Tasks')){
        // Amarender - I2RT-3585 - Modified condition to show Tasks and Events on All Tab, Internal All Tab.
        if(showTasksEvents){
            for(Task taskRecord:[SELECT Id, WhoId, WhatId, Subject, Status, Priority,CreatedDate,CreatedBy.Name,LastModifiedDate FROM Task where WhatId =:caseId ]){
                commentList.add(new CaseCommentWrapper(taskRecord));
            }
            for(Event eventRecord:[SELECT Id, WhoId, WhatId, Subject, ActivityDate, EndDate, CreatedDate,CreatedBy.Name,LastModifiedDate,ActivityDateTime FROM Event where WhatId =:caseId and ischild = false ]){ //<T01>      //<T11>
                commentList.add(new CaseCommentWrapper(eventRecord));
            }
        }
        //Deva - End - I2RT-3585
        if (sortBy == 'LastModifiedDate ASC') {
            CaseCommentController.sortOrder = 'ASC';
        }else{
            CaseCommentController.sortOrder = 'DESC';
        }
        commentList.sort();
        return commentList;
    }

    /**
     * @description Method to fetch the all case comments along with file attachments and child comments if any for eSupport
     */
    @AuraEnabled
    public static List<CaseCommentWrapper> getCaseCommentsForEsupport(String caseRecordId, String sortBy, String searchKey) {
        
        //---------------------------------------<T04>-------------------------------
        //Now, we validate the user's access to see case
        String strCaseAccessMessage = CaseController.getCaseAccess((Id) caseRecordId, '');
        if(String.isNotBlank(strCaseAccessMessage) && !Test.isRunningTest()){
            throw new AuraHandledException(strCaseAccessMessage);
        }
        //---------------------------------------<T04>-------------------------------

        List<CaseCommentWrapper> commentList = new List<CaseCommentWrapper>();
        //Amarender - I2RT-4321 - Search Case Comments using SOSL - Start
        if(String.isNotBlank(searchKey)){
            commentList = getCaseCommentsSOSL(caseRecordId,sortBy,searchKey);
        }else{
            commentList = getAllCaseCommentsForEsupport(caseRecordId,sortBy,searchKey);
        }
        //Amarender - I2RT-4321 - Search Case Comments using SOSL - End
        System.debug('@@commentList= '+commentList);
        return commentList;
    }

    //Amarender - I2RT-4321 - Search Case Comments using SOSL.
    private static List<CaseCommentWrapper> getCaseCommentsSOSL(String caseId,String sortBy, String searchKey){
        List<CaseCommentWrapper> commentList = new List<CaseCommentWrapper>();
        List<Case_Comment__c> caseCommentList = new List<Case_Comment__c>();
        List<Case_Comment__c> lstCaseCommentsQueried = new List<Case_Comment__c>(); //<T04>
        Set<Id> caseCommentIds = new Set<Id>();
        Set<Id> caseCommentUserIdSet = new Set<Id>();
        Map<String, String> roleMap = new Map<String, String>();
        Map<Id, Case_Comment__c> childCommentMap = new Map<Id, Case_Comment__c>();
        Id currentUserId = UserInfo.getUserId();
        if(String.isNotBlank(searchKey)) {
            searchKey = String.escapeSingleQuotes(searchKey+= '*');
        } 
        if(String.isNotBlank(caseId)) {
            caseId = String.escapeSingleQuotes(caseId);
        } 
        if(String.isNotBlank(sortBy)) {
            sortBy = String.escapeSingleQuotes(sortBy);
        }
        //---------------------------------------<T04>-------------------------------
        String queryString = 'FIND {'+searchKey+'} IN ALL FIELDS RETURNING ' +
                                    ' Case_Comment__c(Id,Parent_Comment__c,CreatedById,LastModifiedDate ' +
                                    ' WHERE Case__c = \''+caseId+'\' AND Status__c = \'Submitted\' AND Visibility__c = \'External\' ' +
                                    ' ORDER BY ' + sortBy + ')';
        List<Search.SearchResult> ccRecList = CaseControllerWithoutSharing.getSearchResults(queryString)?.get('Case_Comment__c');
        //---------------------------------------<T04>-------------------------------
        for(Search.SearchResult sr : ccRecList){
            Case_Comment__c ccRec = (Case_Comment__c) sr.getSObject();
            caseCommentUserIdSet.add(ccRec.CreatedById);
            if(ccRec.Parent_Comment__c == null){
                caseCommentIds.add(ccRec.Id);
            }
            if (ccRec.Parent_Comment__c != null ){
                caseCommentIds.add(ccRec.Parent_Comment__c);
            }
        }
        for(Case_Team__c team : [SELECT Role__c, User__c FROM Case_Team__c WHERE User__c IN :caseCommentUserIdSet AND Case__c = :caseId]) {
            roleMap.put(team.User__c, team.role__c);
        }
        //---------------------------------------<T04>-------------------------------
        if(!caseCommentIds.isEmpty()){
            String strQuery =  'Select Id,Comment__c,Case__c,Parent_Comment__c,Is_Replied_To__c,Status__c,Is_Deleted__c,Visibility__c,CreatedById,Inbound__c,Date_Time_Scheduled__c, Severity__c, Email_Opened__c,CreatedBy.Name, CreatedBy.SmallPhotoUrl, Type__c, Sub_Type__c,CreatedBy.FullPhotoUrl, Importance__c, LastModifiedDate, Comment_Category__c, CreatedDate,OwnerId,Owner.Name, Created_By__c, ' + //<T06>
                                ' Tagged_User_1__c, Tagged_User_1__r.Name, Tagged_User_2__c, Tagged_User_2__r.Name, Tagged_User_3__c, Tagged_User_3__r.Name, Tagged_User_4__c, Tagged_User_4__r.Name, Tagged_User_5__c, Tagged_User_5__r.Name, ' + //T02
                                '(SELECT Id,Comment__c,Case__c,Parent_Comment__c,Is_Replied_To__c,Status__c,Is_Deleted__c,Visibility__c,CreatedById,Inbound__c,Date_Time_Scheduled__c, Severity__c, Email_Opened__c,CreatedBy.Name, CreatedBy.SmallPhotoUrl, Type__c, Sub_Type__c,CreatedBy.FullPhotoUrl, Importance__c, LastModifiedDate, Comment_Category__c, CreatedDate,OwnerId,Owner.Name, Created_By__c FROM Case_Comments__r ) '+ //<T06>
                                ' From Case_Comment__c where Id in (\''+String.join(new List<Id>(caseCommentIds), '\',\'')+'\') and Parent_Comment__c = null ';
            if(String.isNotBlank(sortBy)) {
                strQuery += ' ORDER BY ' + sortBy;
            }
            lstCaseCommentsQueried = (List<Case_Comment__c>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
        }
        //---------------------------------------<T04>-------------------------------
        for(Case_Comment__c cc : lstCaseCommentsQueried){ //<T04>
            caseCommentList.add(cc);
            for(Case_Comment__c ccr : cc.Case_Comments__r) {
                caseCommentUserIdSet.add(ccr.CreatedById);
                childCommentMap.put(ccr.Id,ccr);
            }
        }

        for(Case_Comment__c cc : caseCommentList) {
            String role = roleMap.containsKey(cc.CreatedById) ? roleMap.get(cc.CreatedById): '';
            if(!cc.Case_Comments__r.isEmpty()) {
                commentList.add(new CaseCommentWrapper(cc, role, new CaseCommentWrapper(childCommentMap.get(cc.Case_Comments__r[0].Id), roleMap.containsKey(cc.Case_Comments__r[0].CreatedById) ? roleMap.get(cc.Case_Comments__r[0].CreatedById): '', null)));
            } else {
                commentList.add(new CaseCommentWrapper(cc, role, null));
            }
        }
        return commentList;
    }
    /**
     * @description Method to fetch the all case comments along with file attachments and child comments if any for eSupport
     */
    
    private static List<CaseCommentWrapper> getAllCaseCommentsForEsupport(String caseRecordId, String sortBy, String searchKey) {
        String caseId = caseRecordId;

        List<CaseCommentWrapper> commentList = new List<CaseCommentWrapper>();
        List<Case_Comment__c> caseCommentList = new List<Case_Comment__c>();
        Set<Id> caseCommentUserIdSet = new Set<Id>();
        Map<String, String> roleMap = new Map<String, String>();
        Map<Id, Case_Comment__c> childCommentMap = new Map<Id, Case_Comment__c>();
        Set<Id> childCommentIdSet = new Set<Id>();
        String srchKey = String.isNotBlank(searchKey)?String.escapeSingleQuotes(searchKey) : '';
        Id currentUserId = UserInfo.getUserId();
        String query = 'SELECT Id, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, Email_Opened__c,Visibility__c, Status__c, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl, Type__c, Sub_Type__c,'
                        + ' CreatedBy.FullPhotoUrl, Importance__c, LastModifiedDate, Comment_Category__c, CreatedDate,OwnerId,Owner.Name, Created_By__c, ' //<T06>
                        + ' (SELECT Id, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, Visibility__c, Is_Deleted__c, ' 
                        + ' Status__c, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl, CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate, Comment_Category__c, Created_By__c FROM Case_Comments__r Where Comment_to_Search__c LIKE \'%' + srchKey + '%\' AND Status__c = \'Submitted\' AND Visibility__c = \'External\' LIMIT 1),' //<T06>
                        + ' (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks)'
                        + ' FROM Case_Comment__c' 
                        + ' WHERE Case__c = \''+ String.escapeSingleQuotes(caseId) +'\' AND Parent_Comment__c = null AND Status__c = \'Submitted\' AND Visibility__c = \'External\''; //<T04>
        
        
        if(String.isNotBlank(searchKey)) {
            query += ' AND Comment_to_Search__c LIKE \'%' + srchKey + '%\'';
        }

        if(String.isNotBlank(sortBy)) {
            String srtBy = String.escapeSingleQuotes(sortBy);
            query += ' ORDER BY ' + srtBy;
        }  
        List<SObject> lstSobjects = CaseControllerWithoutSharing.getSObjectRecords(query); //<T04>
        caseCommentList = !lstSobjects.isEmpty() ? (List<Case_Comment__c>) lstSobjects : new List<Case_Comment__c>(); //<T04>
        for(Case_Comment__c cc : caseCommentList) {
            caseCommentUserIdSet.add(cc.CreatedById);
            for(Case_Comment__c ccr : cc.Case_Comments__r) {
                caseCommentUserIdSet.add(ccr.CreatedById);
                childCommentIdSet.add(ccr.Id);
            }
        }

        if(!childCommentIdSet.isEmpty()) {
            String strChildCommentQuery = 'SELECT Id, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, Visibility__c, Status__c, Created_By__c, '+ //<T06>
                                            'CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl, CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate,Comment_Category__c,'+
                                            '(SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks) FROM Case_Comment__c '+
                                            'WHERE Id in (\''+String.join(new List<Id>(childCommentIdSet), '\',\'')+'\')';
            lstSobjects = CaseControllerWithoutSharing.getSObjectRecords(strChildCommentQuery);
            childCommentMap = !lstSobjects.isEmpty() ? new Map<Id, Case_Comment__c>((List<Case_Comment__c>) lstSobjects) : new Map<Id, Case_Comment__c>();
        }  

        for(Case_Team__c team : [SELECT Role__c, User__c FROM Case_Team__c WHERE User__c IN :caseCommentUserIdSet AND Case__c = :caseId]) {
            roleMap.put(team.User__c, team.role__c);
        }
        for(Case_Comment__c cc : caseCommentList) {
            String role = roleMap.containsKey(cc.CreatedById) ? roleMap.get(cc.CreatedById): '';
            if(!cc.Case_Comments__r.isEmpty()) {
                commentList.add(new CaseCommentWrapper(cc, role, new CaseCommentWrapper(childCommentMap.get(cc.Case_Comments__r[0].Id), roleMap.containsKey(cc.Case_Comments__r[0].CreatedById) ? roleMap.get(cc.Case_Comments__r[0].CreatedById): '', null)));
            } else {
                commentList.add(new CaseCommentWrapper(cc, role, null));
            }
        }
        return commentList;
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements 
    /**
     * @description Method to add/create case comments from eSupport
     */
    @AuraEnabled
    public static void addCaseCommentsFromEsupport(String caseRecordId, String commentBody) {
        
        //---------------------------------------<T04>-------------------------------
        //Now, we validate the user's access to add case comment on the case
        String strCaseAccessMessage = CaseController.getCaseAccess((Id) caseRecordId, 'Read/Write');
        if(String.isNotBlank(strCaseAccessMessage) && !Test.isRunningTest()){
            throw new AuraHandledException(strCaseAccessMessage);
        }
        //---------------------------------------<T04>-------------------------------

        Case_Comment__c cc = new Case_Comment__c();

        cc.Case__c = caseRecordId;
        cc.Inbound__c = true;
        cc.Status__c = 'Submitted';
        cc.Visibility__c = 'Internal';
        cc.Comment_Category__c = 'General Comments';
        cc.Comment__c = commentBody;

        // Not Required currently: 
        // cc.Type__c = 'Raise Hand';
        // cc.Sub_Type__c = 'General Response';
        // cc.Comment_to_Search__c = commentBody;

        CaseControllerWithoutSharing.insertCaseComment(cc); //<T04>
    }

    /**
     * @description Method to fetch the configuration for quick actions like quick text, quick update
     */
    @AuraEnabled(cacheable=true)
    public static QuickActionWrapper getQuickActionConfiguration(String caseId) {
        QuickActionWrapper wrapper = new QuickActionWrapper();
        List<String> criteriaFieldList = new List<String>();
        criteriaFieldList = SalesforceUtils.getFieldsFromFieldSet(Label.Collaboration_Criteria_Case_Fieldset, 'Case');
        List<Case> caseList = new List<Case>();
        String queryString = 'SELECT Id, ' + String.join(criteriaFieldList, ',') 
                             + ' FROM Case WHERE Id = :caseId';
        caseList = Database.query(queryString);

        if(!caseList.isEmpty()) {
            Map<String, String> superFilterMap = new Map<String, String>();
            Map<String, Object> fieldsToValue = caseList[0].getPopulatedFieldsAsMap();
            Map<String, Case_Communication_Quick_Text_Mapping__mdt> emailTemplateMap = new Map<String, Case_Communication_Quick_Text_Mapping__mdt>();
            
            for(String field : criteriaFieldList) {
                superFilterMap.put(field, fieldsToValue.containsKey(field) ? String.valueOf(fieldsToValue.get(field)) : '');
            }
            
            /* Quick Update
            for(Case_Communication_Quick_Update_Mapping__mdt mdt : [SELECT Fieldset__c, 
                                                                    (SELECT Field_Api_Name__c, Field_Value__c 
                                                                    FROM Case_Communication_Criteria_Records__r)
                                                                    FROM Case_Communication_Quick_Update_Mapping__mdt]) {
                Boolean isTarget = true;                                                        
                for(Case_Communication_Criteria_Record__mdt criteria : mdt.Case_Communication_Criteria_Records__r) {
                    if(superFilterMap.containsKey(criteria.Field_Api_Name__c) && criteria.Field_Value__c == superFilterMap.get(criteria.Field_Api_Name__c) ) {
                        continue;
                    } else {
                        isTarget = false;
                        break;
                    }
                }   
                if(isTarget) {
                    wrapper.quickUpdateFieldList = SalesforceUtils.getFieldsFromFieldSet(mdt.Fieldset__c, 'Case');
                    break;
                }                                                     
            }*/

            for(Case_Communication_Quick_Text_Mapping__mdt mdt : [SELECT DeveloperName, Description__c, Email_Template_Name__c,
                                                                    (SELECT Field_Api_Name__c, Field_Value__c 
                                                                    FROM Case_Communication_Criteria_Records__r)
                                                                    FROM Case_Communication_Quick_Text_Mapping__mdt]) {
                Boolean isTarget = false;                                                        
                for(Case_Communication_Criteria_Record__mdt criteria : mdt.Case_Communication_Criteria_Records__r) {
                    if(superFilterMap.containsKey(criteria.Field_Api_Name__c) && criteria.Field_Value__c == superFilterMap.get(criteria.Field_Api_Name__c) ) {
                        isTarget = true;
                        break;
                    } else {
                        continue;
                    }
                }   
                if(isTarget) {
                    emailTemplateMap.put(mdt.Email_Template_Name__c, mdt);
                }                                                     
            }
            
            Set<String> overrideFolderforLanguages = new Set<String>{'Dutch','Chinese','Korean'};
            String defaultTemplateFolder = 'Case QuickText Templates English';
            Boolean operations = false;
            Set<String> folderset = new Set<String>();
            String folderName;
            for(Case c : [Select Id,ContactId, Contact.INFA_Language__c,Record_Type_Name__c from Case where Id =: caseId]){
                if(c.ContactId != null && c.Contact.INFA_Language__c != null){
                    Integer indexOfSpace = c.Contact.INFA_Language__c.indexOf(' ');
                    if(indexOfSpace != -1)
                        folderName = c.Contact.INFA_Language__c.substring(0, indexOfSpace);
                }
                if(c.Record_Type_Name__c == 'Operations'){
                    operations = true;
                }
            }
            if(String.isEmpty(folderName)){
                folderName = 'English';
            }
            if(!String.isEmpty(folderName) && overrideFolderforLanguages.contains(folderName)){
                folderName = 'English';
            }
            
            folderName = 'Case QuickText Templates '+folderName;
            folderset.add(folderName);
            if(operations){
                folderName = 'Case QuickText Templates Operations';
                folderset.add(folderName);
            }
            
            

            for(EmailTemplate tmp : [SELECT Id, Name, DeveloperName,Folder.Name FROM EmailTemplate WHERE IsActive = true AND Name IN :emailTemplateMap.keyset() AND Folder.Name IN: folderset]) {
                Case_Communication_Quick_Text_Mapping__mdt mdt = emailTemplateMap.get(tmp.Name);
                QuickTextEmailTemplateWrapper emailTemplateWrapper = new QuickTextEmailTemplateWrapper();
                emailTemplateWrapper.customMetadataName = mdt.DeveloperName;
                emailTemplateWrapper.emailTemplateName = tmp.DeveloperName;
                emailTemplateWrapper.description = mdt.Description__c;
                emailTemplateWrapper.emailTemplateLabel = tmp.Name;
                wrapper.emailTemplateList.add(emailTemplateWrapper);
            }
        }
        return wrapper;
    }

    /**
     * @description Method to save the case comment record
     */
    @AuraEnabled
    public static Case_Comment__c saveComment(Case_Comment__c comment, List<String> fileIdList) {
        System.debug('@Developer --> saveComment :');
        System.debug('@Developer --> comment.Comment__c :' + comment.Comment__c);
        System.debug('@Developer --> comment :' + comment);

        Savepoint sp = Database.setSavepoint();
        try {
            Case cse;
            // Updating the case status before creating or updating the case comment.
            if('Submitted'.equals(comment.Status__c) && comment.Case__c != null && !String.isEmpty(comment.Type__c)){
                String status;
                Boolean isRCASent = false;
                Case oldCase;
                if(String.isNotEmpty(comment?.Case__c)){
                    oldCase = [Select Id,RCA_Pending_flag__c,Is_RCA_Sent__c from Case where Id =: comment.Case__c];
                }
     
                //Boolean caseClosed = false;
                Boolean caseIsDelayClose = false;
                switch on comment.Type__c {
                    when 'Request More Info' {
                        status = 'Research';
                        comment.Sub_Type__c = 'General Response';
                        comment.Comment_Category__c = 'General Comments';
                    }
                    when 'Provide Solution' {
                        isRCASent = oldCase.RCA_Pending_flag__c == 'Yes' ? false : oldCase.RCA_Pending_flag__c == 'No' ? true : false;
                        status = 'Solution';
                        comment.Sub_Type__c = 'Solution Response';
                        comment.Comment_Category__c = 'General Comments';
                    }
                    when 'Send RCA' {
                       isRCASent = true;
                       comment.Sub_Type__c = 'Solution Response';
                       comment.Comment_Category__c = 'General Comments'; 
                    }
                    when 'Delay Close' {
                        caseIsDelayClose = true;
                        comment.Comment_Category__c = 'General Comments';
                    }
                    when 'Close Case' {
                        status = 'Closed';
                        //caseClosed = true;
                        comment.Sub_Type__c = 'General Response';
                        comment.Comment_Category__c = 'General Comments';
                    }
                }

                /*if(caseClosed){
                    Case cse = new Case();
                    cse.Id = comment.Case__c;
                    cse.Closed__c = caseClosed;
                    update cse;
                }
                else*/ if(String.isNotEmpty(status)){
                    if(cse == null )
                        cse = new Case();
                    cse.Id = comment.Case__c;
                    cse.Status = status;
                    if(status == 'Solution'){
                        cse.Is_RCA_Sent__c = isRCASent;
                    }
                    if(status == 'Closed'){
                        deleteScheduledComments(new List<Id>{comment.Case__c}, comment.Id); //T03
                    }
                    // update cse;
                }
                else if(isRCASent){
                    cse = new Case();
                    cse.Id = comment.Case__c;
                    cse.Is_RCA_Sent__c = isRCASent;
                }
                if(caseIsDelayClose){
                    if(cse == null )
                        cse = new Case();
                    cse.Id = comment.Case__c;
                    cse.Is_Delay_Close__c = caseIsDelayClose;
                    // update cse;
                }
            }

            if(comment?.Visibility__c == 'Internal' && comment?.Comment_Category__c != null){
                if(cse == null )
                    cse = new Case();
                cse.Id = comment.Case__c;
                if(comment.Comment_Category__c == 'Case Owner Review'){
                    cse.Engineer_Review_Comments__c = comment.Comment__c?.replaceAll('<[/a-zAZ0-9]*>','');
                }
                if(comment.Comment_Category__c == 'Escalation Notes'){
                    cse.Escalation_Notes__c = comment.Comment__c?.replaceAll('<[/a-zAZ0-9]*>','');
                }
                if(comment.Comment_Category__c == 'Manager Review'){
                    cse.Manager_Review_Comments__c = comment.Comment__c?.replaceAll('<[/a-zAZ0-9]*>','');
                }
            }
            if(cse != null)
                update cse;

            //I2RT-2192 append verbiage to the comment if there are attachments.
            List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
            Set<Id> conDocIds = new Set<Id>();
            if(!fileIdList.isEmpty() || comment.Id != null) {
                Set<Id> setCommentId = new Set<Id>();
                if(comment.Id != null){
                    setCommentId.add(comment.Id);
                }
                lstContentDocLink = [Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension 
                                        From ContentDocumentLink 
                                        Where ContentDocumentId In :fileIdList Or LinkedEntityId in :setCommentId];
                
                if((comment.Visibility__c == 'Internal' || comment.Visibility__c == 'External') && !comment.Inbound__c && (comment.Status__c == 'Submitted' || comment.Status__c == 'Scheduled')){
                    Set<String> setAttachmentName = new Set<String>();
                    for(ContentDocumentLink contentDocLink : lstContentDocLink){
                        setAttachmentName.add(contentDocLink.ContentDocument.Title + '.' + contentDocLink.ContentDocument.FileExtension);
                        conDocIds.add(contentDocLink.ContentDocumentId);
                    }
                    if(setAttachmentName != null && !setAttachmentName.isEmpty() && !comment.Comment__c.contains(String.join(new List<String>(setAttachmentName), '<br>')))
                        comment.Comment__c += '<br>Lookout for these attachments in the case,<br>' + String.join(new List<String>(setAttachmentName), '<br>');
                }
            }

            List<ContentDocumentLink> lstContentDocLinkToInsert = new List<ContentDocumentLink>();

            System.debug('@Developer --> comment :' + comment);
            //@Akhilesh 16 Apr 2021 -- start
            //upsert comment;
            if(comment.Id != null){

                string sComment = comment.Comment__c;
                if(sComment.contains('/servlet/rtaImage?refid=')){
                    String sRegEx = '(?si)("(.*?\\/servlet\\/rtaImage\\?refid=\\w{15})")';
                    Pattern oPattern = Pattern.compile(sRegEx);
                    Matcher oMatcher = oPattern.matcher(sComment);
                    while (oMatcher.find()){          
                        String sOutput = oMatcher.group(2);
                        System.debug('@Developer --> sOutput :' + sOutput);
                        sComment = sComment.replace(sOutput ,sOutput + '&eid=' + comment.Id + '&feoid=' + Label.CaseComment_Comment_Field_Id);
                    } 
                    System.debug('@Developer --> sComment :' + sComment);
                }
            
                comment.Comment__c = sComment;

                update comment;

                for(ContentDocumentLink cdl : [Select Id,ContentDocumentId,Visibility,ShareType,LinkedEntityId From ContentDocumentLink where LinkedEntityId = :comment.Case__c and ContentDocumentId in :conDocIds]){
                    if(comment.Case__c == cdl.LinkedEntityId && comment.Visibility__c == 'External'){
                        cdl.Visibility = 'AllUsers';
                        cdl.ShareType='V';
                    }else if (comment.Case__c == cdl.LinkedEntityId && comment.Visibility__c == 'Internal') {
                        cdl.Visibility = 'InternalUsers';
                        cdl.ShareType='I';
                    }
                    lstContentDocLinkToInsert.add(cdl);
                }
            }
            else{
                // only one pre-draft can exist which is oldest one remaining all must be removed to maintain data consistency
                List<Case_Comment__c> caseCommentList = [SELECT Id, Inbound__c, Parent_Comment__c, Case__c, Comment__c, Date_Time_Scheduled__c, Severity__c, 
                                                                Email_Opened__c,Visibility__c, Status__c, CreatedById, CreatedBy.Name, CreatedBy.SmallPhotoUrl,
                                                                CreatedBy.FullPhotoUrl,OwnerId,Owner.Name, Importance__c, LastModifiedDate,
                                                                (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id 
                                                                FROM ContentDocumentLinks)
                                                        FROM Case_Comment__c
                                                        WHERE Case__c = :comment.Case__c 
                                                        AND Parent_Comment__c = null 
                                                        AND Status__c = 'Pre Draft'
                                                        AND CreatedById =: UserInfo.getUserId()
                                                        ORDER BY Createddate asc
                                                        ];
                if(caseCommentList.size() > 1){
                    caseCommentList.remove(0);
                    delete caseCommentList;
                }
               
                
                insert comment;
                system.debug('-----comment id----->>>'+comment.id);

                string sComment = comment.Comment__c;
                if(sComment.contains('/servlet/rtaImage?refid=')){
                    String sRegEx = '(?si)("(.*?\\/servlet\\/rtaImage\\?refid=\\w{15})")';
                    Pattern oPattern = Pattern.compile(sRegEx);
                    Matcher oMatcher = oPattern.matcher(sComment);
                    while (oMatcher.find()){          
                        String sOutput = oMatcher.group(2);
                        System.debug('@Developer --> sOutput :' + sOutput);
                        sComment = sComment.replace(sOutput ,sOutput + '&eid=' + comment.Id + '&feoid=' + Label.CaseComment_Comment_Field_Id);
                    } 
                    System.debug('@Developer --> sComment :' + sComment);
                }
            
                comment.Comment__c = sComment;
                update comment;

                //copy attachments to the Case Comment
                if(!fileIdList.isEmpty()) {
                    for(ContentDocumentLink contentDocLink : lstContentDocLink) {
                        //When the comment is newly added from GCS Console and set the Access, ContentDocumentLink records will be updated accordingly.
                        if(contentDocLink.LinkedEntityId == comment.Case__c){
                            String visibility = 'InternalUsers';
                            String shareType='I';
                            if(comment.Visibility__c == 'External'){
                                visibility = 'AllUsers';
                                shareType='V';
                            }
                            lstContentDocLinkToInsert.add(new ContentDocumentLink(Id=contentDocLink.Id, LinkedEntityId = comment.Case__c, ContentDocumentId = contentDocLink.ContentDocumentId, Visibility = visibility, ShareType = shareType));
                            lstContentDocLinkToInsert.add(new ContentDocumentLink(LinkedEntityId = comment.Id, ContentDocumentId = contentDocLink.ContentDocumentId, Visibility = visibility, ShareType = shareType));
                        }
                    }                    
                }
            }
            //@Akhilesh 16 Apr 2021 -- end
            
            //insert attachments
            if(!lstContentDocLinkToInsert.isEmpty()) {
                Database.upsert(lstContentDocLinkToInsert, false);
            }

            //update Parent Case Comment
            if(comment.Parent_Comment__c != null){
                Case_Comment__c parentComment = new Case_Comment__c();
                parentComment.Id = comment.Parent_Comment__c;
                parentComment.Is_Replied_To__c = true;
                update parentComment;
            }

        } catch(Exception ex) {
            Database.rollback( sp );
            throw new AuraHandledException(ex.getMessage());
        }
        return comment;
    }
    
    
    /*
     Method Name : addCloseCaseComment
     Description : This method is called from Flow to add a close case comment, when a case is set to delay close.
     Parameters  : Case Record Ids.
     Return Type : None.
     */
    @InvocableMethod(label='Add Close Case Comment' description='This method is called from Flow to add a close case comment, when a case is set to delay close')
    public static void addCloseCaseComment(List<Id> caseIds) {
        
        String FOLDER_PREFIX = 'Case QuickText Templates ';//I2RT-4574
        String DEFAULT_FOLDER_NAME = FOLDER_PREFIX + 'English';//I2RT-4574
        //Set<String> OVERRIDE_FOLDER_FOR_LANGUAGES = new Set<String>{'Dutch','Chinese','Korean'};//I2RT-4574
        List<Case> CasesToUpdate = new List<Case>();
        List<Case_Comment__c> CommentsToCreate = new List<Case_Comment__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, String> CaseIdToFolderNameMap = new Map<Id, String>();
        Set<String> folderNameSet;
        Map<String, EmailTemplate> emailTemplates = new Map<String, EmailTemplate>(); 
        
        try{
            
            for(Case c : [Select Id,Status,ContactId,Contact.INFA_Language__c,Problem_Statement__c,Closing_Notes__c from Case where Id IN :caseIds]){
                //I2RT-4574
                String language = '';                
                if(String.isNotEmpty(c?.Contact?.INFA_Language__c)){
                    language = c.Contact.INFA_Language__c;
                    Integer indexOfSpace = language.indexOf(' ');
                    if(indexOfSpace != -1){
                        language = language.substring(0, indexOfSpace);
                    }
                }
                /*if(OVERRIDE_FOLDER_FOR_LANGUAGES.contains(language)){
                    language = 'English';
                }*/
                String emailTemplateFolderName = FOLDER_PREFIX + language;
                CaseIdToFolderNameMap.put(c.Id, emailTemplateFolderName);
                
                caseMap.put(c.Id, c);
            }
    
            folderNameSet = new Set<String>(CaseIdToFolderNameMap.values());
            folderNameSet.add(DEFAULT_FOLDER_NAME);
            for(EmailTemplate ET : [SELECT HtmlValue,Folder.Name FROM EmailTemplate WHERE Name = 'Close Case' AND Folder.Name IN :folderNameSet]){
                emailTemplates.put(ET.Folder.Name, ET);
                System.debug('Email Template Folder Name: '+ET.Folder.Name);  
            }
    
            EmailTemplate emailTemplateDefault = emailTemplates.get(DEFAULT_FOLDER_NAME);
            for(Case c : caseMap.values()){
                //I2RT-4574
                EmailTemplate emailTemplate = emailTemplateDefault;
                String folderName = CaseIdToFolderNameMap.get(c.Id);
                if(emailTemplates.containsKey(folderName)){
                    emailTemplate = emailTemplates.get(folderName);
                }
                System.debug('emailTemplate --> '+emailTemplate);

                Case_Comment__c CaseComment = new Case_Comment__c();
                CaseComment.Comment__c = getParsedEmailTemplate(emailTemplate, c);
                CaseComment.Inbound__c = false;
                CaseComment.Status__c = 'Submitted';
                CaseComment.Visibility__c = 'External';
                CaseComment.Case__c = c.Id;
                CaseComment.Sub_Type__c = 'General Response';
                CaseComment.Comment_Category__c = 'General Comments';
                
                c.Status = 'Closed';
    
                CasesToUpdate.add(c);
                CommentsToCreate.add(CaseComment);
    
            }
            if(caseMap.keySet().size() > 0){
                deleteScheduledComments(new List<Id>(caseMap.keySet()));
            }
            update CasesToUpdate;
            //---------------------------------------<T05>-------------------------------
            globalApexManager.allowRun('CaseCommentTrigger', 'before', 'insert');
            globalApexManager.allowRun('CaseCommentTrigger', 'after', 'insert');
            TriggerHandler.processedClasses.remove('BEFORE: INSERTCaseCommentTriggerHandler');
            TriggerHandler.processedClasses.remove('AFTER: INSERTCaseCommentTriggerHandler');
            //---------------------------------------</T05>-------------------------------
            insert CommentsToCreate;
        }
        catch(Exception e){
            GAM.CreateLogs('CaseCommentController.addCloseCaseComment() -> ' + e.getCause(), CasesToUpdate, 'CasesToUpdate');
            //GAM.InsertDebugLogs();
        }
        
    }

    //Method to delete scheduled case comments before closing case
    public static void deleteScheduledComments(List<Id> caseIds){
        //T03
        deleteScheduledComments(caseIds, null);
    }
    
    //T03
    //Method to delete scheduled case comments before closing case
    //and filter out the given Case Comment
    public static void deleteScheduledComments(List<Id> caseIds, Id caseCommentIdToExclude){
        List<Id> lstCaseCommentIdToExclude = new List<Id>();
        if(caseCommentIdToExclude != null){
            lstCaseCommentIdToExclude.add(caseCommentIdToExclude);
        }

        if(caseIds.size() > 0){
            List<Case_Comment__c> lstCaseComments = new List<Case_Comment__c>();

            for(Case_Comment__c cc : [Select Id from Case_Comment__c where Case__c IN :caseIds and Status__c = 'Scheduled' 
                                        And Id Not In :lstCaseCommentIdToExclude]){
                lstCaseComments.add(cc);
            }

            if(lstCaseComments.size() > 0){
                delete lstCaseComments;
            }
        } 
    }

    //I2RT-4574
    public static String getParsedEmailTemplate(EmailTemplate ET, Case c){
        
        Map<String, String> mapVariablesToReplace = new Map<String, String>();
        mapVariablesToReplace.put('{{{Case.Problem_Statement__c}}}', c.Problem_Statement__c);
        mapVariablesToReplace.put('{{{Case.Closing_Notes__c}}}', c.Closing_Notes__c);
        String strHTMLCode = ET.HtmlValue;
        List<String> stripInlineStyles = new List<String>(); 

        String regex = 'style=\"[^\"]*\"';
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(strHTMLCode);
        while(m.find()) {
            System.debug(m.group(0));
            stripInlineStyles.add(m.group(0));
        }

        for(String style : stripInlineStyles){
            strHTMLCode = strHTMLCode.replaceAll(style, '');
        }

        if(String.isNotBlank(strHTMLCode)) {
            if(!mapVariablesToReplace.isEmpty()) {
                for(String strStringToReplace : mapVariablesToReplace.keySet()) {
                    if(String.isNotBlank(mapVariablesToReplace.get(strStringToReplace))) {
                        strHTMLCode = strHTMLCode.replace(strStringToReplace, mapVariablesToReplace.get(strStringToReplace));
                    }
                    else if(String.isBlank(mapVariablesToReplace.get(strStringToReplace))){
                        strHTMLCode = strHTMLCode.replace(strStringToReplace, ' ');
                    }
                }
            }
        }

        return strHTMLCode;
    }
    
    
    /**
     * @description Method to fetch attachments for the case comment
     */
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getDocuments (String linkedEntityId, String parentId, Boolean isId) {
        if(!isId) {
            return [SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId,
            Id FROM ContentDocumentLink WHERE ContentDocumentId IN :parentId.split(',') AND LinkedEntityId = :linkedEntityId];
        } else {
            return [SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId,
                     Id FROM ContentDocumentLink WHERE LinkedEntityId = :parentId];
        }
    }

    /**
     * @description Method to fetch parsed text after processing the email template by merging the value of the field referenced
     */
    @AuraEnabled
    public static string fetchMergedQuickText(String templateName, String recordId) {
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        emailTemplateList = [SELECT Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :templateName];

        /*if(!emailTemplateList.isEmpty()) {
            return SalesforceUtils.mergeText(emailTemplateList[0].HtmlValue, recordId).get(recordId);
        }*/

        /*String contactlanguage = '';
        if(!String.isEmpty(recordId)){
            Case c = [Select Id,ContactId, Contact.INFA_Language__c from Case where Id =: recordId];
            if(c != null && c.ContactId != null && c.Contact.INFA_Language__c != null){
                contactlanguage = c.Contact.INFA_Language__c;
            }
        }*/

        String mergedText = '';
        mergedText = CaseQuickActionsController.getEmailBody(recordId, templateName/*, contactlanguage*/);
        return mergedText;
    }

     /**
     * @description Method to fetch parsed text after processing the email template by merging the value of the field referenced
     */
    @AuraEnabled
    public static void updateCaseFeedBackRecord(String sobjOperation,CaseCommentFeedback__c sobjRecord) {
        System.debug('--Record>>>'+sobjRecord);
        try{
            if(String.isNotBlank(sobjOperation) && sobjOperation.equals('ISINSERT')){
                if(sobjRecord!=null){
                    insert sobjRecord;
                }
            }
            if(String.isNotBlank(sobjOperation) && sobjOperation.equals('ISUPDATE')){
                if(sobjRecord!=null){
                    update sobjRecord;
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public class CaseCommentWrapper implements Comparable {
        @AuraEnabled
        public String role {get;set;}
        @AuraEnabled
        public Datetime createdDate {get;set;}
        @AuraEnabled
        public CaseHistory caseHistory {get;set;}
        @AuraEnabled
        public String userProfilePhotoUrl {get;set;}
        @AuraEnabled
        public Case_Comment__c comment {get;set;}
        @AuraEnabled
        public CaseCommentWrapper childComment {get;set;}
        @AuraEnabled
        public List<CaseCommentWrapper> childComments {get;set;} 
        @AuraEnabled        
        public List<ContentDocumentLink> caseDocuments{get; set;}
        @AuraEnabled
        public CaseCommentFeedback__c caseCommentFeedBack{get; set;}
        @AuraEnabled
        public CaseCommentEmailStat__c caseCommentEmailStat{get; set;}
        //Deva - I2RT-3585 Created the variables to hold task and event Record.
        @AuraEnabled
        public Task taskRecord {get;set;}
        @AuraEnabled
        public Event eventRecord {get;set;}

        public CaseCommentWrapper(Case_Comment__c comment, String role, CaseCommentWrapper childComment) {
            this.role = role;
            this.comment = comment;
            this.childComment = childComment;
            this.createdDate = comment.CreatedDate;
           //Deva Start addded the logic to dynamically display like and dislike buttons
           Service_Cloud_General_Setting__mdt obj=getServiceSettingMetadata; 
           Boolean checkCondition = evaluateCondition(comment,obj.Filter_Condition__c);
           if(comment.CaseCommentFeedbacks__r!=null &&
               comment.CaseCommentFeedbacks__r.size()>0 && checkCondition){                   
               this.caseCommentFeedBack=comment.CaseCommentFeedbacks__r[0];
           }else if(checkCondition){
                this.caseCommentFeedBack=new CaseCommentFeedback__c(Case_Comment__c=comment.Id,disLike__c=false,Like__c=false,Feedback__c='');
           }
            //Deva End
            //Amarender -- I2RT-3584 Email Metrics - Start 
            if(comment.CaseCommentEmailStats__r!=null &&
               comment.CaseCommentEmailStats__r.size()>0){                   
               this.caseCommentEmailStat=comment.CaseCommentEmailStats__r[0];
           }
           //Amarender -- I2RT-3584 Email Metrics - End 
        }

        public CaseCommentWrapper(Case_Comment__c comment, String role, List<CaseCommentWrapper> childComment, Boolean listchild) {
            this.role = role;
            this.comment = comment;
            this.childComments = childComment;
            this.createdDate = comment.CreatedDate;
           //Deva Start addded the logic to dynamically display like and dislike buttons
           Service_Cloud_General_Setting__mdt obj=getServiceSettingMetadata; 
           Boolean checkCondition = evaluateCondition(comment,obj.Filter_Condition__c);
           if(comment.CaseCommentFeedbacks__r!=null &&
               comment.CaseCommentFeedbacks__r.size()>0 && checkCondition){                   
               this.caseCommentFeedBack=comment.CaseCommentFeedbacks__r[0];
           }else if(checkCondition){
                this.caseCommentFeedBack=new CaseCommentFeedback__c(Case_Comment__c=comment.Id,disLike__c=false,Like__c=false,Feedback__c='');
           }
            //Deva End
            //Amarender -- I2RT-3584 Email Metrics - Start 
            if(comment.CaseCommentEmailStats__r!=null &&
               comment.CaseCommentEmailStats__r.size()>0){                   
               this.caseCommentEmailStat=comment.CaseCommentEmailStats__r[0];
           }
           //Amarender -- I2RT-3584 Email Metrics - End 
        }

        public CaseCommentWrapper(Case_Comment__c comment, String role, CaseCommentWrapper childComment, List<ContentDocumentLink> caseDocuments) {
            this.role = role;
            this.comment = comment;
            this.childComment = childComment;
            this.caseDocuments = caseDocuments;
            this.createdDate = comment.CreatedDate;
           //Deva Start addded the logic to dynamically display like and dislike buttons
           Service_Cloud_General_Setting__mdt obj=getServiceSettingMetadata; 
           Boolean checkCondition = evaluateCondition(comment,obj.Filter_Condition__c);
           if(comment.CaseCommentFeedbacks__r!=null &&
               comment.CaseCommentFeedbacks__r.size()>0 && checkCondition){                   
               this.caseCommentFeedBack=comment.CaseCommentFeedbacks__r[0];
           }else if(checkCondition){
                this.caseCommentFeedBack=new CaseCommentFeedback__c(Case_Comment__c=comment.Id,disLike__c=false,Like__c=false,Feedback__c='');
           }
            //Deva End
            //Amarender -- I2RT-3584 Email Metrics - Start 
            if(comment.CaseCommentEmailStats__r!=null &&
               comment.CaseCommentEmailStats__r.size()>0){                   
               this.caseCommentEmailStat=comment.CaseCommentEmailStats__r[0];
           }
           //Amarender -- I2RT-3584 Email Metrics - End 
        }

        public CaseCommentWrapper(CaseHistory caseHistory, String userProfilePhotoUrl,String role){
            this.caseHistory = caseHistory;
            this.createdDate = caseHistory.CreatedDate;
            this.userProfilePhotoUrl = userProfilePhotoUrl;
            this.role = role;
        } 
        //Deva - Start - I2RT-3585 To Capture the tasks and events associated to case
        public CaseCommentWrapper(Task taskRecord){
            this.taskRecord = taskRecord;   
            this.createdDate = taskRecord.CreatedDate;         
        }
        public CaseCommentWrapper(Event eventRecord){
            this.eventRecord = eventRecord;   
            this.createdDate = eventRecord.CreatedDate;         
        }
        //Deva - End - I2RT-3585
        public Integer compareTo(Object compareTo) {
            CaseCommentWrapper compareToComment = (CaseCommentWrapper)compareTo;

            if (this.createdDate == compareToComment.createdDate) return 0;

            if(CaseCommentController.sortOrder == 'ASC'){
                if (this.createdDate > compareToComment.createdDate) return 1;
                return -1;
            }else{
                if (this.createdDate > compareToComment.createdDate) return -1;
                return 1;
            }
        }
    }
    //Resuable method to ealuate the condition dynamically
    private static Boolean evaluateCondition(SObject record, String condition){
        Boolean returnValue = false;        
        Map<String, Object> context = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));        
        try{
            ScriptEngine scriptEngine = ScriptEngine.getInstance();
            Object result = scriptEngine.eval(condition, context);
            System.debug('result = ' + result);
            returnValue = (Boolean)result;
        }catch(Exception ex){
            System.debug('exception = ' + ex.getMessage());
        }        
        return returnValue;
    }
   
     /* Variable map to prepare the metadata setting data*/ 
    public static Service_Cloud_General_Setting__mdt getServiceSettingMetadata{get{
        if(getServiceSettingMetadata==null){
            getServiceSettingMetadata=[SELECT Filter_Condition__c, Id, DeveloperName FROM Service_Cloud_General_Setting__mdt where DeveloperName='Case_Comms_Like_Dislike_Visible_Settings'];
        }return getServiceSettingMetadata;}set;
    }
    public class QuickActionWrapper {
        @AuraEnabled
        public List<String> quickUpdateFieldList {get;set;}
        @AuraEnabled
        public List<QuickTextEmailTemplateWrapper> emailTemplateList {get;set;}

        public QuickActionWrapper() {
            this.quickUpdateFieldList = new List<String>();
            this.emailTemplateList = new List<QuickTextEmailTemplateWrapper>();   
        }
    }

    public class QuickTextEmailTemplateWrapper {
        @AuraEnabled
        public String customMetadataName {get;set;}
        @AuraEnabled
        public String emailTemplateName {get;set;}
        @AuraEnabled
        public String emailTemplateLabel {get;set;}
        @AuraEnabled
        public String description {get;set;}
    }


    /*
     Method Name : isCaseCommentAssociatedToCase
     Description : This method is called from caseCommentListView & checks if the list of case comments are associated to given case.
     Parameters  : Case Comment Ids & Case Record Id.
     Return Type : Boolean.
     */
    @AuraEnabled
    public static Boolean isCaseCommentAssociatedToCase(List<Id> caseCommentIds, Id caseId) {
        Boolean boolReturn = false;
        for(Case_Comment__c cc : [Select Id from Case_Comment__c Where Id IN :caseCommentIds AND Case__c =: caseId]){
            boolReturn = true;
            break;
        }
        return boolReturn;
    }

 
}