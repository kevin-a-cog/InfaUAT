/*
* Name : helpIdeasController
* Author : Deeksha Shetty
* Created Date : Jan 11,2022
* Description : Controller for helpIdeas/helpChangeRequest (Detail Page) and helpIdeasLanding LWC component.
Change History
**********************************************************************************************************
Modified By         Date           Jira No.        Description Tag

Deeksha Shetty     Feb 22,2022    I2RT-5543         Incorrect list of Ideas are displayed under 'My Ideas' tab

**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

public without sharing class helpIdeasController {
    
    //Fetching the Labels From Metadata
    @AuraEnabled
    public static help_Infa_Custom_Label__mdt getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt recordlist = [SELECT Learn_More__c ,Related_Ideas__c,Related_CR__c,TakeMeThere__c,Edit_Idea__c ,
                                                      VotePoints__c, Idea_Categories__c, Idea_Status__c, Infa_Account_site__c    
                                                      FROM help_Infa_Custom_Label__mdt WHERE developerName = 'helpIdea'];
            System.debug('recordlis='+recordlist);
            return recordlist;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    
    
    @AuraEnabled
    public static String getUserType(String userId){
        try{
            String Usertype = [Select UserType from User where Id=:userId].UserType;
            System.debug('Usertype='+Usertype);
            return Usertype;            
        }
        Catch(Exception e){
            system.debug('Error in UserType : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    
    //This method displays the Idea and Its comments on Detail Page
    @AuraEnabled
    public static List<ideaWrapper> ideasDisplay(String IdeaUrlId, String userId){
        try{
            System.debug('IdeaUrlId='+IdeaUrlId);
            List<String> categoryList = new List<String>();
            List<IdeaComment> ideaCommentList = [SELECT CommentBody,Id,createdDate, IdeaId,CommunityId,CreatorFullPhotoUrl,CreatedById,
                                                 CreatorName,UpVotes FROM IdeaComment where IdeaId=:IdeaUrlId  ORDER BY createdDate DESC];
            
            List<Idea> ideaDetail = [SELECT Id, Title,Body, NumComments,Total_Count__c,Upvote_Count__c, 
                                     VoteScore, VoteTotal, Categories, Status, LastCommentDate,createdDate,
                                     LastCommentId, ParentIdeaId, CreatorName FROM Idea WHERE Id=:IdeaUrlId] ;            
            
            List<ideaCommentWrapper> commentlist = new List<ideaCommentWrapper>();
            if(ideaCommentList.size()>0){
                for(IdeaComment comm : ideaCommentList){
                    ideaCommentWrapper icomm = new ideaCommentWrapper();
                    icomm.ideaCommentId = comm.Id;
                    icomm.IdeaId = comm.IdeaId;
                    icomm.CreatorFullPhotoUrl = comm.CreatorFullPhotoUrl;
                    icomm.CreatorName = comm.CreatorName;
                    icomm.CommentBody = comm.CommentBody;
                    icomm.commentedUserId = comm.CreatedById;
                    dateTime cd = comm.CreatedDate;
                    date createDate = date.newInstance(cd.year(), cd.month(), cd.day());
                    icomm.noOfDays = createDate.daysBetween(date.today());
                    commentlist.add(icomm);           
                }
            }
            
            Map<Id, List<ideaCommentWrapper>> mapppp = new Map<Id, List<ideaCommentWrapper>>();
            for(ideaCommentWrapper idd : commentlist){
                if (mapppp.containsKey(idd.IdeaId)){
                    mapppp.get(idd.IdeaId).add(idd);                                                         
                } else{
                    mapppp.put(idd.IdeaId, new List<ideaCommentWrapper>{idd});                   
                }
            }                       
            
            List<ideaWrapper> ideawraplist = new List<ideaWrapper>();
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){
                    ideaWrapper wrap = new ideaWrapper();                
                    wrap.totalVoteCount = item.Total_Count__c;
                    if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                    else{wrap.upvoteCount= item.Upvote_Count__c;}                    
                    wrap.Status = item.Status;
                    wrap.ideaId = item.Id;
                    wrap.Title = item.title;                    
                    wrap.Body = item.body;
                    wrap.Category = item.Categories;
                    if(item.Categories.contains(';')){
                        categoryList = item.Categories.split(';');
                        wrap.CategoryList = categoryList; 
                    }
                    else{
                        categoryList.add(item.Categories);
                        wrap.CategoryList = categoryList;
                    }                                                                              
                    DateTime dT = item.CreatedDate;
                    wrap.CreatedDate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year();
                    wrap.ideaCommentDetail = mapppp.get(item.Id); 
                    wrap.CreatorName = item.CreatorName;
                    
                    ideawraplist.add(wrap);
                }}
            
            return ideawraplist;
        }
        Catch(Exception e){
            system.debug('Error in ideaDisplay : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    // This method used to Add Comment
    @AuraEnabled
    public static String addComments(String CommentBody,String IdeaId){
        try{
            if(CommentBody!=null && IdeaId!=null ){
                IdeaComment ideacomm = new IdeaComment();
                ideacomm.CommentBody = CommentBody;                
                ideacomm.IdeaId = IdeaId;
                insert ideacomm;
                return 'success'; 
            }
            else{
                return null;
            }            
                       
        }
        Catch(Exception e){
            system.debug('Error in add ideas : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }       
    }
    
    //THis method used to save the edited comment
    @AuraEnabled
    public static String SaveEditedComment(String ideacommId, String ideaId,String commentBody){
        try{
            if(ideacommId!=null && ideaId!=null && commentBody!=null){
                List<IdeaComment> ideaCommentBody = [SELECT CommentBody FROM IdeaComment where Id=:ideacommId and IdeaId=:ideaId];
                System.debug('ideaCommentBody='+ideaCommentBody);
                if(ideaCommentBody.size() >0){
                    for(IdeaComment ic : ideaCommentBody){
                        ic.CommentBody = commentBody;
                    }
                }
                update ideaCommentBody;            
                return 'Success';                
            }
            else{
                return null;
            }
            
        }
        Catch(Exception e){
            system.debug('Error in saving edited Comment : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }        
    }
    
    
    //this method deletes the comment.
    @AuraEnabled
    public static String deleteComment(String ideacommId){
        try{
            if(ideacommId!=null){
                System.debug('ideacommId='+ideacommId);
                IdeaComment ideacomm = new IdeaComment(Id = ideacommId);                            
                Delete ideacomm;
                return 'success'; 
            }
            else{
                return null;
            }
                        
        }
        Catch(Exception e){
            system.debug('Error in idea Delete : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
            
        }        
    }
    
    // this method shows the related Ideas in Detail page
    @AuraEnabled
    public static List<ideaWrapper> showRelatedIdeas(String networkId, String Ideaid){
        try{
            Community communityinfo =[SELECT Id,Name FROM Community where NetworkId =:networkId];
            Id communityid = communityinfo.Id;
            String sitelabel = System.Label.IN_CommunityName;
            String ideaCategory = [Select Categories from Idea where Id=:Ideaid].categories;            
            String SelectedCategory;
            if(ideaCategory.contains(';')){
                SelectedCategory = ideaCategory.split(';')[0];                
            }
            else{
                SelectedCategory = ideaCategory;
            }
            List<Idea> ideaDetail = new List<Idea>();
            if(ideaCategory !='Change Request'){
                ideaDetail = [SELECT Id, Title,Body,Status,Total_Count__c,Upvote_Count__c,categories FROM Idea WHERE Id!=:Ideaid 
                              AND categories!='Change Request' AND Status!='Draft'AND Status!=null AND Categories =:SelectedCategory AND
                              CommunityId =:communityid ORDER BY CreatedDate DESC limit 3];
            }
            else{
                ideaDetail = [SELECT Id, Title,Body,Status,Total_Count__c,Upvote_Count__c,categories FROM Idea WHERE categories='Change Request' AND 
                              Id!=:Ideaid AND Status!='Draft' AND Status!=null AND CommunityId =:communityid  ORDER BY CreatedDate DESC limit 3]; 
            }
            List<ideaWrapper> ideawraplist = new List<ideaWrapper>();
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){
                    ideaWrapper wrap = new ideaWrapper();
                    wrap.ideaId = item.Id;
                    String titleString = item.Title;
                    Integer maxiSize = 50;
                    if(titleString.length() > maxiSize ){
                        titleString = titleString.substring(0, maxiSize);
                    }
                    wrap.title = titleString;                    
                    String sizeString = item.body.stripHtmlTags();
                    Integer maxSize = 120;
                    if(sizeString.length() > maxSize ){
                        sizeString = sizeString.substring(0, maxSize) + '....';
                    }
                    wrap.totalVoteCount = item.Total_Count__c;
                    if(item.Upvote_Count__c == null || item.Upvote_Count__c==0 ){
                        wrap.upvoteCount= 0;
                    }
                    else{
                        wrap.upvoteCount= item.Upvote_Count__c;
                    }
                    
                    wrap.Status = item.Status;
                    wrap.Body = sizeString;
                    wrap.communityName = item.categories;
                    wrap.url = sitelabel+'ideadetail?id=' + item.Id;
                    ideawraplist.add(wrap);
                }
            }
            else{
                ideaWrapper wrap = new ideaWrapper();
                wrap.NoIdeaData = 'nodata';
                ideawraplist.add(wrap);
            }
            System.debug('ideawraplist='+ideawraplist);
            return ideawraplist;            
        }
        Catch(Exception e){
            system.debug('Error in related ideasss : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        } 
    }
    
    //Handles logic related to Idea LIKE
    @AuraEnabled
    public static String likeCountUpdate(Id objId, String likeType, String isLike, String userId){        
        try{            
                if(isLike == 'Like'){
                    String ideaCategory = [Select Categories from Idea where Id=:objId].categories;
                    List<Community_Interactions__c> query = [Select Id__c,Type__c,IsLiked__c from Community_Interactions__c where 
                                                             Id__c=:objId and User__c=:userId];
                    System.debug('query='+query);
                    if(query.size()==0){                         
                        
                        if(likeType =='IdeaLike' && ideaCategory!='Change Request'){            //when user hits like on Idea    
                            Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = objId);
                            ideaObj.Type__c ='Idea';
                            ideaObj.IsLiked__c = true;
                            ideaObj.User__c  = userinfo.getUserId();
                            insert ideaObj;                        
                        }
                        else if(likeType =='IdeaLike' && ideaCategory=='Change Request'){
                            Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = objId);
                            ideaObj.Type__c ='CRT';
                            ideaObj.IsLiked__c = true;
                            ideaObj.User__c  = userinfo.getUserId();
                            insert ideaObj;                       
                        }
                        else{
                            System.debug('ideaCategory='+ideaCategory);
                        }
                        
                    }
                    else{                    
                        query[0].IsLiked__c = true;
                        update query;                                                      
                    }
                    
                    //update LIke count in Parent Idea
                    List<Idea> updateList = [Select Id,Like_Count__c  From Idea Where Id=:objId];
                    for(Idea ide : updateList){
                        if(ide.Like_Count__c==null){
                            ide.Like_Count__c = 1;
                        }
                        else{
                            ide.Like_Count__c = ide.Like_Count__c + 1;                               
                        }
                        System.debug('ide.Like_Count__c='+ide.Like_Count__c);
                    }
                    System.debug('updateList='+updateList);
                    if(updateList.size()>0){
                        System.debug('Updated successfully');
                        update  updateList;
                    } 
                    
                }
                else if(isLike == 'Dislike'){
                    if(likeType =='IdeaLike'){
                        System.debug('objId='+objId);
                        List<Community_Interactions__c> deleteList = [Select Id,Id__c,IsLiked__c,User__c from Community_Interactions__c WHERE
                                                                      Id__c=:objId and User__c=:userinfo.getUserId()];
                        System.debug('deleteList='+deleteList);
                        if(deleteList.size()>0){
                            for(Community_Interactions__c com :deleteList ){
                                com.IsLiked__c = false;
                            }
                            update deleteList;                                                
                        }
                        
                        //update LIke count in Parent Idea
                        List<Idea> updateList = [Select Id,Like_Count__c  From Idea Where Id=:objId];
                        for(Idea ide : updateList){
                            if(ide.Like_Count__c==null){
                                ide.Like_Count__c = 0;
                            }
                            else{
                                ide.Like_Count__c = ide.Like_Count__c - 1;                               
                            }                    
                        }
                        if(updateList.size()>0){
                            System.debug('Updated successfully');
                            update  updateList;
                        }
                    }                    
                }            
                
                else System.debug('isLike='+isLike);
                return 'Sucesss'+'--'+isLike ;
            
                       
        }
        Catch(Exception e){
            system.debug('Error in LIke Count Update : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }                    
    }
    
    //Handles logic related to Comment Like
    @AuraEnabled
    public static String likeCountUpdateforComment(Id objId,String isLike){        
        try{            
                System.debug('objId='+objId);
                System.debug('isLike='+isLike);
                if(isLike == 'Like'){
                    System.debug('Entered here 1');
                    List<Community_Interactions__c> query = [Select Id__c,Type__c from Community_Interactions__c where 
                                                             Type__c='Idea Comment' AND Id__c=:objId and User__c=:userinfo.getUserId()];
                    System.debug('query='+query);
                    if(query.size()==0){ 
                        
                        //when user hits like on Idea comment    
                        Community_Interactions__c ideaCommentObj  = new Community_Interactions__c(Id__c = objId); //new idea comment type object
                        ideaCommentObj.Type__c = 'Idea Comment';
                        ideaCommentObj.IsLiked__c = true;
                        ideaCommentObj.User__c  = userinfo.getUserId();
                        insert ideaCommentObj;                        
                    }
                    else{                    
                        query[0].IsLiked__c = true;
                        update query;                                                      
                    }
                }
                
                else if(isLike == 'Dislike'){
                    System.debug('entered dislike block');
                    List<Community_Interactions__c> deleteList = [Select Id,Id__c,IsLiked__c,User__c from Community_Interactions__c where Type__c='Idea Comment' 
                                                                  AND Id__c=:objId and User__c=:userinfo.getUserId()];
                    System.debug('deleteList='+deleteList);
                    if(deleteList.size()>0){
                        for(Community_Interactions__c com :deleteList ){
                            com.IsLiked__c = false;
                        }
                        update deleteList;                                        
                    }                                   
                }            
                
                else System.debug('isLike='+isLike);                
                return 'Sucesss'+'--'+isLike ;
            
                        
        }
        Catch(Exception e){
            system.debug('Error in LIke Count Update : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }                    
    }
    
    //This method checks if the user has liked,commented,followed,upvoted or downvoted as and when they visit the page.
    @AuraEnabled
    public static userActivityWrapper returnUser(Id ideaId, Id userId){
        try{
            String userLikeData ,userFollowData,userVoteData;
            
            List<Community_Interactions__c> usrelist = [Select Id from Community_Interactions__c where Id__c=:ideaId and 
                                                        User__c=:userId and IsLiked__c= true];
            if(usrelist.size()>0) userLikeData='UserExists';
            
            
            List<Community_Interactions__c> usrelist2 = [Select Id,Vote__c from Community_Interactions__c where Id__c=:ideaId and User__c=:userId 
                                                         and (Vote__c= 'Upvote' OR Vote__c='Downvote')];
            if(usrelist2.size()>0 && usrelist2[0].Vote__c == 'Upvote' ){
                userVoteData = 'UpvoteUserExists';
            }
            else if(usrelist2.size()>0 && usrelist2[0].Vote__c == 'Downvote'){
                userVoteData ='DownvoteUserExists';
            }
            
            List<Community_Interactions__c> votecount = [Select Id,Vote__c from Community_Interactions__c where Id__c=:ideaId and Vote__c= 'Upvote'];
            
            
            List<Community_Interactions__c> usrelist3 = [Select Id from Community_Interactions__c where Id__c=:ideaId and 
                                                         User__c=:userId and Follow__c=true];
            if(usrelist3.size()>0) userFollowData= 'UserExists';
            
            
            Map<Id,ideaComment> commentList = new Map<Id,ideaComment>([Select Id From ideaComment where IdeaId=:ideaId]);            
            List<Community_Interactions__c> userlist = [Select Id__c,User__c from Community_Interactions__c where User__c=:userId 
                                                        AND Type__c='Idea Comment' AND IsLiked__c=true];
            List<String> likedCommentList = new List<String>();            
            if(userlist.size() >0){
                for(Community_Interactions__c cm : userlist){
                    if(commentList.keyset().contains(cm.Id__c)){
                        likedCommentList.add(cm.Id__c);
                    }
                }                        
            }
            System.debug('likedCommentList='+likedCommentList);
            
            userActivityWrapper uawrap = new userActivityWrapper();
            uawrap.FollowUser = userFollowData;
            uawrap.LikeUser = userLikeData;
            uawrap.votedUser = userVoteData;
            uawrap.upvoteTotalCount = votecount.size();
            if(likedCommentList.size()>0) uawrap.ideaCommentLikeList = likedCommentList;
            
            
            return uawrap;            
        }
        Catch(Exception e){
            system.debug('Error in userlist : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }                 
    }
    
    //method handles upvote
    @AuraEnabled
    public static Idea handleUpvoteCount(Id ideaId , Id UserId){
        try{            
                String ideaCategory = [Select Categories from Idea where Id=:ideaId].categories;
                List<Community_Interactions__c> upvoteList = [Select Id__c,Vote__c,User__c,Follow__c from Community_Interactions__c 
                                                              where Id__c=:ideaId and User__c=:userinfo.getUserId()];
                System.debug('upvoteList='+upvoteList);
                
                help_Infa_Custom_Label__mdt getvotecount = getmetadatarecords();
                Decimal voteno = getvotecount.VotePoints__c;
            
            	List<Community_Interactions__c> upvotecountlist = [Select Id__c from Community_Interactions__c where 
                                                             Id__c=:ideaId and Vote__c='Upvote' ];
            	List<Community_Interactions__c> downvotecountlist = [Select Id__c from Community_Interactions__c where 
                                                             Id__c=:ideaId and Vote__c='Downvote' ];
                
                if(upvoteList.size()==0){
                    if(ideaCategory!='Change Request' && !ideaCategory.contains('Change Request')){
                        Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                        ideaObj.Type__c ='Idea';
                        ideaObj.Vote__c = 'Upvote';
                        ideaObj.Follow__c = true;    //Logic where Follow is checked when user Upvotes
                        ideaObj.User__c  = userinfo.getUserId();
                        insert ideaObj;
                    }
                    else if(ideaCategory=='Change Request' || ideaCategory.contains('Change Request')){
                        Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                        ideaObj.Type__c ='CRT';
                        ideaObj.Vote__c = 'Upvote';
                        ideaObj.Follow__c = true;    //Logic where Follow is checked when user Upvotes
                        ideaObj.User__c  = userinfo.getUserId();
                        insert ideaObj;
                    }
                    else{
                        System.debug('ideaCategory='+ideaCategory);
                    }
                    
                    List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                    System.debug('updateList 1='+updateList);
                    
                    for(Idea ide : updateList){
                        if(ide.Upvote_Count__c==null){
                            ide.Upvote_Count__c = voteno;                       
                        }
                        else{                    
                            ide.Upvote_Count__c = upvotecountlist.size() + voteno;                        
                        }
                        System.debug('ide.Upvote_Count__c='+ide.Upvote_Count__c);
                    }
                    update updateList;
                    
                }
                else if(upvoteList[0].Vote__c ==null){
                    System.debug('Block 2');
                    for(Community_Interactions__c com :upvoteList){                    
                        com.Vote__c = 'Upvote';
                        com.Follow__c = true;    //Logic where Follow is checked when user Upvotes
                    }
                    update upvoteList;
                    List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                    System.debug('updateList='+updateList);
                    for(Idea ide : updateList){
                        if(ide.Upvote_Count__c==null){
                            ide.Upvote_Count__c = voteno;                            
                        }
                        else{                            
                            ide.Upvote_Count__c = upvotecountlist.size() + voteno;                               
                        }
                        System.debug('ide.Upvote_Count__c='+ide.Upvote_Count__c);
                    }
                    update updateList;
                    
                }
                else if(upvoteList[0].Vote__c == 'Downvote'){
                    System.debug('Block 3');
                    upvoteList[0].Vote__c = 'Upvote';
                    upvoteList[0].Follow__c = true;    //Logic where Follow is checked when user Upvotes
                    update upvoteList;
                    
                    if(upvoteList[0].User__c==userinfo.getUserId()){
                        List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                        System.debug('updateList='+updateList);
                        for(Idea ide : updateList){
                            if(ide.Upvote_Count__c==null){
                                ide.Upvote_Count__c = voteno;
                                ide.Downvote_Count__c = downvotecountlist.size() - voteno;
                            }
                            else{
                                ide.Downvote_Count__c = downvotecountlist.size() - voteno;
                                ide.Upvote_Count__c = upvotecountlist.size() + voteno;                               
                            }
                            System.debug('ide.Upvote_Count__c='+ide.Upvote_Count__c);
                        }
                        update updateList;
                        
                    }
                    
                    else{                        
                        List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                        System.debug('updateList='+updateList);
                        for(Idea ide : updateList){
                            if(ide.Upvote_Count__c==null){
                                ide.Upvote_Count__c = voteno;                                
                            }
                            else{                                
                                ide.Upvote_Count__c = upvotecountlist.size() + voteno;                               
                            }
                            System.debug('ide.Upvote_Count__c='+ide.Upvote_Count__c);
                        }
                        update updateList;
                        
                    }
                }
                else System.debug('Something is wrong');                    
                
                Idea ideaVoteCount =[SELECT Id, Upvote_Count__c FROM Idea where Id=:ideaId];
                return ideaVoteCount;
            
                       
        }
        Catch(Exception e){
            system.debug('Error in Upvote : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }
    }
    
    //this method handles downvote
    @AuraEnabled
    public static Idea handleDownvoteCount(Id ideaId , Id UserId){
        try{
            
                String ideaCategory = [Select Categories from Idea where Id=:ideaId].categories;
                List<Community_Interactions__c> upvoteList = [Select Id__c,Vote__c,User__c,Follow__c from Community_Interactions__c  
                                                              where  Id__c=:ideaId and User__c=:userinfo.getUserId()];
                System.debug('upvoteList='+upvoteList);
                help_Infa_Custom_Label__mdt getvotecount = getmetadatarecords();
                Decimal voteno = getvotecount.VotePoints__c;
                List<Community_Interactions__c> upvotecountlist = [Select Id__c from Community_Interactions__c where 
                                                             Id__c=:ideaId and Vote__c='Upvote' ];
            	List<Community_Interactions__c> downvotecountlist = [Select Id__c from Community_Interactions__c where 
                                                             Id__c=:ideaId and Vote__c='Downvote' ];
                
                if(upvoteList.size()==0){
                    if(ideaCategory!='Change Request' && !ideaCategory.contains('Change Request')){
                        Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                        ideaObj.Type__c ='Idea';
                        ideaObj.Vote__c = 'Downvote';  
                        ideaObj.Follow__c = false;    //Logic where Follow is unchecked when user downvotes
                        ideaObj.User__c  = userinfo.getUserId();
                        insert ideaObj;
                    }
                    else if(ideaCategory=='Change Request' || ideaCategory.contains('Change Request')){
                        Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                        ideaObj.Type__c ='CRT';
                        ideaObj.Vote__c = 'Downvote';  
                        ideaObj.Follow__c = false;    //Logic where Follow is unchecked when user downvotes
                        ideaObj.User__c  = userinfo.getUserId();
                        insert ideaObj;
                    }
                    else{
                        System.debug('ideaCategory='+ideaCategory);
                    }
                    
                    List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                    System.debug('updateList 1='+updateList);
                    for(Idea ide : updateList){
                        if(ide.Downvote_Count__c==null){
                            ide.Downvote_Count__c = voteno;
                            ide.Upvote_Count__c = upvotecountlist.size()-voteno;
                        }
                        else{                    
                            ide.Downvote_Count__c = downvotecountlist.size() + voteno;
                            ide.Upvote_Count__c = upvotecountlist.size()-voteno;
                        }
                        System.debug('ide.Downvote_Count__c='+ide.Downvote_Count__c);
                    }
                    update updateList;
                    
                }
                else if(upvoteList[0].Vote__c ==null){
                    for(Community_Interactions__c com :upvoteList){                    
                        com.Vote__c = 'Downvote';
                        com.Follow__c = false;    //Logic where Follow is unchecked when user downvotes
                    }
                    update upvoteList;
                    List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                    System.debug('updateList='+updateList);
                    for(Idea ide : updateList){
                        if(ide.Downvote_Count__c==null){
                            ide.Downvote_Count__c = voteno;
							ide.Upvote_Count__c = upvotecountlist.size()-voteno;                            
                        }
                        else{                            
                            ide.Downvote_Count__c = downvotecountlist.size() + voteno;
                            ide.Upvote_Count__c = upvotecountlist.size()-voteno;
                        }
                        System.debug('ide.Downvote_Count__c='+ide.Downvote_Count__c);
                    }
                    update updateList;
                    
                }
                else if(upvoteList[0].Vote__c == 'Upvote'){
                    System.debug('Block 3');
                    upvoteList[0].Vote__c = 'Downvote';
                    if(upvoteList[0].Follow__c == true) upvoteList[0].Follow__c = false;    //Logic where Follow is unchecked when user downvotes
                    update upvoteList;
                    
                    if(upvoteList[0].User__c==userinfo.getUserId()){
                        List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                        System.debug('updateList1='+updateList);
                        if(updateList.size()>0){
                            for(Idea ide : updateList){
                                if(ide.Downvote_Count__c==null){
                                    ide.Downvote_Count__c = voteno;
                                    if(ide.Upvote_Count__c != null )ide.Upvote_Count__c = upvotecountlist.size() - voteno;
                                }
                                else{
                                    if(ide.Upvote_Count__c != null )ide.Upvote_Count__c = upvotecountlist.size() - voteno;
                                    ide.Downvote_Count__c = downvotecountlist.size() + voteno;                               
                                }
                                System.debug('ide.Upvote_Count__c='+ide.Upvote_Count__c);
                            }
                            update updateList;
                        }
                        
                    }
                    
                    else{                        
                        List<Idea> updateList = [Select Id,Upvote_Count__c,Downvote_Count__c From Idea Where Id=:ideaId];
                        System.debug('updateList2='+updateList);
                        for(Idea ide : updateList){
                            if(ide.Downvote_Count__c==null){
                                ide.Downvote_Count__c = voteno;                                
                            }
                            else{                                
                                ide.Downvote_Count__c = downvotecountlist.size() + voteno;                               
                            }
                            System.debug('ide.Downvote_Count__c='+ide.Downvote_Count__c);
                        }
                        update updateList;
                        
                    }
                }
                else System.debug('***Something is wrong***');
                
                Idea ideaVoteCount =[SELECT Id, Upvote_Count__c FROM Idea where Id=:ideaId];
                return ideaVoteCount;                
            
            
            
        }
        Catch(Exception e){
            system.debug('Error in Upvote : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }
    }
    
    
   //this method handles Follow
    @AuraEnabled
    public static String handleFollow(Id ideaId,String followType, Id UserId){
        try{
            
                if(followType == 'Follow'){
                    String ideaCategory = [Select Categories from Idea where Id=:ideaId].categories;
                    List<Community_Interactions__c> query = [Select Id__c,Type__c,Follow__c  from Community_Interactions__c 
                                                             where Id__c=:ideaId and User__c=:userId];
                    System.debug('query='+query);
                    if(query.size()==0){ 
                        System.debug('ideaId='+ideaId);
                        if(ideaCategory!='Change Request' && !ideaCategory.contains('Change Request')){
                            Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                            ideaObj.Type__c ='Idea';
                            ideaObj.Follow__c = true;
                            ideaObj.User__c  = UserId;
                            insert ideaObj;     
                        }
                        else if(ideaCategory=='Change Request' || ideaCategory.contains('Change Request')){
                            Community_Interactions__c ideaObj = new Community_Interactions__c(Id__c = ideaId);
                            ideaObj.Type__c ='CRT';
                            ideaObj.Follow__c = true;
                            ideaObj.User__c  = UserId;
                            insert ideaObj; 
                        }
                        else{
                            System.debug('ideaCategory='+ideaCategory);
                        }
                        
                    }
                    else{                    
                        query[0].Follow__c = true;
                        update query;                                                      
                    }
                }
                
                else if(followType == 'Unfollow'){                
                    System.debug('ideaId='+ideaId);
                    List<Community_Interactions__c> followList = [Select Follow__c,User__c from Community_Interactions__c 
                                                                  where Id__c=:ideaId and User__c=:userinfo.getUserId()];
                    System.debug('followList='+followList);
                    if(followList.size()>0){
                        for(Community_Interactions__c com :followList ){
                            com.Follow__c = false;
                        }
                        update followList;                                        
                    }
                }
                return 'Follow Success';
            
            
            
        }
        Catch(Exception e){
            system.debug('Error in Follow : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }
    }
    
  
    //IDEAS LANDING : Displays Ideas Based on All/My Ideas Tab    
    @AuraEnabled
    public static List<ideasLandingWrapper> IdeasLandingDisplay(String networkId,String userId,String sortvalue){
        try{
            System.debug('networkId='+networkId);
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;            
            String sitelabel = System.Label.IN_CommunityName;
            List<ideasLandingWrapper> displayideawraplist = new List<ideasLandingWrapper>();
            
            Map<Id,Idea> allideaMap = new Map<Id,Idea>([SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedDate,CreatedById FROM Idea 
                                     WHERE CommunityId =:communityid AND Categories EXCLUDES('Change Request') AND Categories!='Change Request' AND Status!=null AND  Categories!=null
                                     ORDER BY CreatedDate DESC]);
            
            System.debug('allideaMap size='+allideaMap.size());
            
            //Your Followed Ideas community interaction records
            
            List<Community_Interactions__c> fetchFollowIdea = [SELECT Id__c FROM Community_Interactions__c where Type__c='Idea' AND
                                                               Follow__c= true AND User__c=:userId AND Id__c IN:allideaMap.keyset() Order by LastModifiedDate DESC];
            Map<String,Community_Interactions__c> followIdeaMap = new Map<String,Community_Interactions__c>();
            System.debug('fetchFollowIdea='+fetchFollowIdea);
            for(Community_Interactions__c com : fetchFollowIdea){
                followIdeaMap.put(com.Id__c,com);
            }
            
                                                
            if(allideaMap.size()>0){
                for(Idea item :allideaMap.values()){
                    if(sortvalue == 'myideas'){
                        if(followIdeaMap.keyset().contains(item.Id) ||(allideaMap.get(item.Id).Status=='Draft' && allideaMap.get(item.Id).CreatedById==userId)){   //I2RT-5543
                            ideasLandingWrapper wrap = new ideasLandingWrapper();
                            wrap.Id = item.Id;
                            String titleString = item.Title;
                            Integer maxiSize = 67;
                            if(titleString.length() > maxiSize ){
                                titleString = titleString.substring(0, maxiSize);
                            }
                            wrap.Name = titleString;
                            wrap.Status = item.Status;
                            wrap.category = item.Categories;
                            String sizeString;
                            if(item.Body!='') 
                                sizeString =item.body.stripHtmlTags();
                            Integer maxSize = 120;
                            if(sizeString.length() > maxSize ){
                                sizeString = sizeString.substring(0, maxSize) + '....';
                            }
                            wrap.Description = sizeString;             
                            DateTime dT = item.CreatedDate;                
                            wrap.createddate = Date.valueof(dT.year()+'-'+dT.month() +'-'+dT.day()) ;
                            wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day();
                            if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                            else{wrap.upvoteCount= item.Upvote_Count__c;}
                            wrap.Link = sitelabel+'ideadetail?id=' + item.Id;               
                            displayideawraplist.add(wrap);                                
                        }                        
                    }
                    else if(sortvalue == 'allIdeas' && item.Status!='Draft' && item.Status!='Archived'){
                        ideasLandingWrapper wrap = new ideasLandingWrapper();
                        wrap.Id = item.Id;
                        String titleString = item.Title;
                        Integer maxiSize = 67;
                        if(titleString.length() > maxiSize ){
                            titleString = titleString.substring(0, maxiSize);
                        }
                        wrap.Name = titleString;
                        wrap.Status = item.Status;
                        wrap.category = item.Categories;
                        String sizeString;
                        if(item.Body!='') 
                            sizeString =item.body.stripHtmlTags();
                        Integer maxSize = 120;
                        if(sizeString.length() > maxSize ){
                            sizeString = sizeString.substring(0, maxSize) + '....';
                        }
                        wrap.Description = sizeString;           
                        DateTime dT = item.CreatedDate;                
                        wrap.createddate = Date.valueof(dT.year()+'-'+dT.month() +'-'+dT.day()) ;
                        wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day();
                        if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                        else{wrap.upvoteCount= item.Upvote_Count__c;}
                        wrap.Link = sitelabel+'ideadetail?id=' + item.Id;
                        //wrap.Link = sitelabel+'idea/' + item.Id;
                        displayideawraplist.add(wrap);                        
                    }                                    
                }
                  
            }           
                                                         
            return displayideawraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in idea Landing Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    //IDEA LANDING: this method shows RECOMMENDED Ideas. Ideas fetched from Coveo    
    @AuraEnabled
    public static List<ideasLandingWrapper> recommendedIdeasDisplay(String networkId, String token){
        try{
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT  recommendedVideoEndpoint__c FROM help_Infa_Custom_Label__mdt  WHERE developerName ='helpIdea'];            
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;
            String sitelabel = System.Label.IN_CommunityName;
            string authorizationHeader = 'Bearer ' +token;
            List<ideasLandingWrapper> recommendedideawraplist = new List<ideasLandingWrapper>();
            

            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.recommendedVideoEndpoint__c,
                                                                     '',authorizationHeader,'','','',token);            
            
            
            String responseString = dataResponse.getBody();
            
            responseString = responseString.replace('"sfupvote_count__c" :', '"sfupvotecount" :');
            responseString = responseString.substringAfter('results"'+' '+':');        
            responseString = responseString.substring(0,responseString.lastIndexOf('}'));                    
            List<coveoDetailWrapper> resultList = (List<coveoDetailWrapper>)JSON.deserialize(responseString, List<coveoDetailWrapper>.class);            
            List<rawWrapper> rawList = new List<rawWrapper>();
            if(!resultList.isEmpty()){               
                for(coveoDetailWrapper vwrap : resultList){
                    rawList.add(vwrap.raw);
                }
            }            
            
            for(rawWrapper item : rawList){
                ideasLandingWrapper wrap = new ideasLandingWrapper();
                wrap.Id = item.sfid;
                String titleString = item.systitle;
                Integer maxiSize = 67;
                if(titleString.length() > maxiSize ){
                    titleString = titleString.substring(0, maxiSize);
                }
                wrap.Name = titleString;
                wrap.Status = item.sfstatus;
                wrap.category = item.sfcategories;
                String sizeString = item.sfbody.stripHtmlTags();
                Integer maxSize = 120;
                if(sizeString.length() > maxSize ){
                    sizeString = sizeString.substring(0, maxSize) + '....';
                }
                wrap.Description = sizeString;
                
                string date1 = item.sfcreateddate;            
                Long longDate  = Long.valueOf(date1);
                DateTime dt = DateTime.newInstance(longDate);
                wrap.createddate = Date.valueof(dt.year()+'-'+dt.month() +'-'+dt.day() );
                wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day();
                if(item.sfupvotecount == null){wrap.upvoteCount=0;}
                else{wrap.upvoteCount= Integer.valueOf(item.sfupvotecount);}
                wrap.Link = sitelabel+'ideadetail?id=' + item.sfid;
                recommendedideawraplist.add(wrap);               
            }
            return recommendedideawraplist;
                        
        }
        
        Catch(Exception e){
            system.debug('Error in Recommended Ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
      
    
    //IDEA LANDING: This method sorts all Ideas and My ideas as per created date
    @AuraEnabled
    public static List<ideaWrapper> sortbyFilterIdeas(String networkId,String userId,String sortFilter,String sortIdeasVal){
        try{
            System.debug('networkId='+networkId);
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;
            List<Idea> ideaDetail = new List<Idea>();
            List<ideaWrapper> followideawraplist = new List<ideaWrapper>();
            
            if(sortFilter == 'Latest'){
                ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status, LastCommentDate,CreatedById,
                              createdDate, LastCommentId, CreatorName FROM Idea 
                              WHERE CommunityId =:communityid AND Categories!='Change Request' AND Status!=null AND Categories!=null 
                              ORDER BY CreatedDate DESC] ;                
            }
            else{
                ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status, LastCommentDate,CreatedById,
                              createdDate, LastCommentId, CreatorName FROM Idea 
                              WHERE CommunityId =:communityid AND Categories!='Change Request' AND Status!=null AND Categories!=null 
                              ORDER BY CreatedDate ASC] ; 
            }
            Map<Id,Idea> allideaMap = new Map<Id,Idea>();
            for(Idea idd : ideaDetail){
                allideaMap.put(idd.Id,idd);
            }                        
            
            //Your Follow Ideas Community interaction record
            
            List<Community_Interactions__c> fetchFollowIdea = [SELECT Id__c FROM Community_Interactions__c where Type__c='Idea' AND
                                                               Follow__c= true AND User__c=:userId AND Id__c IN:allideaMap.keyset()];
            Map<String,Community_Interactions__c> followedIdeasMap = new Map<String,Community_Interactions__c>();
            System.debug('fetchFollowIdea='+fetchFollowIdea);
            for(Community_Interactions__c com : fetchFollowIdea){
                followedIdeasMap.put(com.Id__c,com);
            }
            
                                    
            if(ideaDetail.size()>0){                
                for(Idea item :ideaDetail){
                    if(sortIdeasVal=='myIdeas'){
                        if(followedIdeasMap.keyset().contains(item.Id) ||(allideaMap.get(item.Id).Status=='Draft' && allideaMap.get(item.Id).CreatedById==userId)){  //I2RT-5543
                            System.debug('Enterd here');
                            ideaWrapper wrap = new ideaWrapper();
                            wrap.ideaId = item.Id;
                            wrap.category = item.Categories;
                            wrap.Title = item.title;
                            wrap.Status = item.Status;
                            if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                            else{wrap.upvoteCount= item.Upvote_Count__c;}
                            wrap.Body = item.body.stripHtmlTags();            
                            DateTime dT = item.CreatedDate;                
                            wrap.CreatedDate = dT.year()+'-'+dT.month() +'-'+dT.day() ;
                            wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day();
                            followideawraplist.add(wrap);                                
                        }
                    }
                    else if(sortIdeasVal == 'allIdeas'){
                        ideaWrapper wrap = new ideaWrapper();
                        wrap.ideaId = item.Id;
                        wrap.Title = item.title;
                        wrap.Status = item.Status;
                        wrap.category = item.Categories;
                        wrap.Body = item.body.stripHtmlTags();            
                        DateTime dT = item.CreatedDate;                
                        wrap.CreatedDate = dT.year()+'-'+dT.month() +'-'+dT.day() ;
                        wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day();
                        if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                        else{wrap.upvoteCount= item.Upvote_Count__c;}
                        followideawraplist.add(wrap);                        
                    }
           
                }
                System.debug('followideawraplist='+followideawraplist);                
                
            }
            return followideawraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in sort my ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    //This methods sorts recommended ideas as per created date
    @AuraEnabled
    public static List<ideasLandingWrapper> sortRecommendedIdeas (String networkId, String sortfilter,String token){
        try{
            System.debug('sortfilter='+sortfilter);
            List<ideasLandingWrapper> recommendedIdeasDisplay = recommendedIdeasDisplay(networkId,token);
            System.debug('recommendedIdeasDisplay='+recommendedIdeasDisplay);
            Map<Date,List<ideasLandingWrapper>>  dateValueMap = new Map<Date,List<ideasLandingWrapper>>();
            List<Date> datelist = new List<Date>();
            List<Date> recentDates = new List<Date>();
            List<ideasLandingWrapper> sortedList = new List<ideasLandingWrapper>();
            
            if(recommendedIdeasDisplay.size()>0){
                system.debug('entered here');
                for(ideasLandingWrapper wrap : recommendedIdeasDisplay){
                    if (dateValueMap.containsKey(wrap.createddate)){
                        dateValueMap.get(wrap.createddate).add(wrap);                                                         
                    } else{
                        dateValueMap.put(Date.Valueof(wrap.createddate), new List<ideasLandingWrapper>{wrap});                   
                    }
                }
                System.debug('dateValueMap='+dateValueMap);
                
                if(!dateValueMap.isEmpty()){
                    for(Date d : dateValueMap.keyset()){
                        datelist.add(d);           
                    }
                }
                
                if(!datelist.isEmpty()){
                    datelist.sort();
                    System.debug('datelist='+datelist);                           
                    for(Integer i = datelist.size()-1; i>=0;i--){
                        recentDates.add(datelist.get(i));                    
                    }
                }
                System.debug('recentDates='+recentDates);                
                
                if(sortfilter == 'Latest'){
                    if(!recentDates.isEmpty()){
                        for(Date dt : recentDates){
                            for(ideasLandingWrapper req : dateValueMap.get(dt)){
                                if(dateValueMap.containsKey(dt)){
                                    sortedList.add(req);
                                }
                            }
                        }
                    }
                    System.debug('Latest sortedList='+sortedList); 
                }
                else if(sortfilter == 'Old'){                    
                    if(!datelist.isEmpty()){
                        for(Date dt : datelist){
                            for(ideasLandingWrapper req : dateValueMap.get(dt)){
                                if(dateValueMap.containsKey(dt)){
                                    sortedList.add(req);
                                }
                            }
                        }
                    }
                    System.debug('Old sortedList='+sortedList); 
                }                                
            }
            return sortedList;
            
        }
        Catch(Exception e){
            system.debug('Error in sort recommednded Ideas : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    
    public class userActivityWrapper{
        @AuraEnabled public String FollowUser;
        @AuraEnabled public String LikeUser;
        @AuraEnabled public String votedUser;
        @AuraEnabled public List<String> ideaCommentLikeList;
        @AuraEnabled  public Decimal upvoteTotalCount;
    }
    
    
    
    public class ideaWrapper{
        @AuraEnabled public Id ideaId;
        @AuraEnabled public String title;
        @AuraEnabled public String Body;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String stringdate;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String communityName;
        @AuraEnabled public String Category;
        @AuraEnabled public List<String> CategoryList;
        @AuraEnabled public String url;
        @AuraEnabled public decimal totalVoteCount;
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Status;
        @AuraEnabled public String NoIdeaData; 
        @AuraEnabled public List<ideaCommentWrapper> ideaCommentDetail;		
    }
    
    public class ideaCommentWrapper{
        @AuraEnabled public String ideaCommentId;
        @AuraEnabled public String IdeaId;
        @AuraEnabled public String CommunityId;
        @AuraEnabled public String CreatorFullPhotoUrl;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String CommentBody;
        @AuraEnabled public Integer noOfDays;        
        @AuraEnabled public String commentedUserId;
        @AuraEnabled public String label= 'Like';
        @AuraEnabled public String disableEdit = 'true';
        @AuraEnabled public String disableDelete = 'true';
        
    }
    
    public class ideasLandingWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Status;
        @AuraEnabled public String Category;        
        @AuraEnabled public Date createddate;
		@AuraEnabled public String stringdate;         
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Description;
        @AuraEnabled public String Link;       
    }
    
    public class coveoDetailWrapper {        
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String sfid;                
        @AuraEnabled public String systitle;
        @AuraEnabled public String sfstatus;
        @AuraEnabled public Decimal sfupvotecount;
        @AuraEnabled public String sfcategories;
        @AuraEnabled public String sfbody;
        @AuraEnabled public String sfcreateddate;
        
    }
}