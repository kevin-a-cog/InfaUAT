/*
 * Name         :   helpUserProfileController
 * Author       :   Deeksha Shetty
 * Created Date :   05/03/2022
 * Description  :   Controller class for helpUserProfileDetails, UserProfileFollowers,UserProfileFollowing

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 
 Deeksha Shetty        14/6/2022                        Nickname Custom Message                     T1
 **********************************************************************************************************
 
 */

public without sharing class helpUserProfileController {
    
    @AuraEnabled(Cacheable=true)
    public static help_Infa_Custom_Label__mdt getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt recordlist = [SELECT EditProfileURL__c,Gam_One_Star_Point__c,Gam_Three_Star_Point__c,GamTwo_Star_Point__c,Nickname_Validation__c      
                                                      FROM help_Infa_Custom_Label__mdt WHERE developerName = 'Gamification_Points']; //T1
            System.debug('recordlist='+recordlist);
            return recordlist;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<TopParticipantListWrapper> getFollowersforUsers(String networkId, string userId){
        List<NetworkMember> pointsList = new List<NetworkMember>();
        Map<Id,NetworkMember> pointsMap = new Map<Id,NetworkMember>();
        List<EntitySubscription> userList = new List<EntitySubscription>();
        List<TopParticipantListWrapper> results = new List<TopParticipantListWrapper>();
        List<TopParticipantListWrapper> subresults = new List<TopParticipantListWrapper>();
        List<Id> memberIds = new List<Id>();
        try{
            String sitelabel = System.Label.IN_CommunityName;
            userList = [SELECT Id, SubscriberId, Subscriber.Name FROM EntitySubscription where NetworkId =: networkId and ParentId =:userId LIMIT 1000];
            System.debug('userList='+userList);
            
            for(EntitySubscription en : userList){
                memberIds.add(en.SubscriberId);
            }
                        
            pointsList = [SELECT Id, MemberId, Member.Name, Member.FullPhotoUrl, ReputationPoints, Network.Name from 
                          NetworkMember where MemberId IN:memberIds and 
                          NetworkId =:networkId and ReputationPoints > 0 order by ReputationPoints DESC];
            System.debug('pointsList='+pointsList);
            for(NetworkMember nw: pointsList){
                pointsMap.put(nw.MemberId,nw);
            }            
            
            if(userList.size()>0){                
                for( EntitySubscription user : userList){
                    TopParticipantListWrapper participant = new TopParticipantListWrapper();
                    if(pointsMap.keyset().contains(user.SubscriberId)){
                        participant.Name = pointsMap.get(user.SubscriberId).Member.Name;
                        participant.PhotoURL = pointsMap.get(user.SubscriberId).Member.FullPhotoUrl;
                        participant.points = pointsMap.get(user.SubscriberId).ReputationPoints;
                        participant.URL = sitelabel + 'profile/'+pointsMap.get(user.SubscriberId).MemberId;
                        if(!results.contains(participant)){
                            results.add(participant);
                        }                        
                    }                    
                }                
            }
            System.debug('results='+results);
            
        } catch(Exception e){
            system.debug('Error in Followers NUmber: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
        return results; 
    }
    
    @AuraEnabled(cacheable=true)
    public static list<TopParticipantListWrapper> getFollowingNumber(string userId,String networkId){
        List<NetworkMember> pointsList;
        Map<Id,NetworkMember> pointsMap = new Map<Id,NetworkMember>();
        List<EntitySubscription> userList = new List<EntitySubscription>();
        List<TopParticipantListWrapper> results = new List<TopParticipantListWrapper>();
        List<TopParticipantListWrapper> subresults = new List<TopParticipantListWrapper>();
        List<Id> memberIds = new List<Id>();
        try{
			String sitelabel = System.Label.IN_CommunityName;            
            userList = [SELECT Id, SubscriberId,ParentId FROM EntitySubscription where NetworkId =:networkId and SubscriberId=:userId and ParentId IN (SELECT ID FROM USER) limit 1000];
            System.debug('userList='+userList);
            
            for(EntitySubscription en : userList){
                memberIds.add(en.ParentId);
            }
            
            pointsList = [SELECT Id, MemberId, Member.Name, Member.FullPhotoUrl, ReputationPoints, Network.Name from NetworkMember where MemberId IN:memberIds
                          and NetworkId =:networkId and ReputationPoints > 0 order by ReputationPoints DESC];
            System.debug('pointsList='+pointsList);
            for(NetworkMember nw: pointsList){
                pointsMap.put(nw.MemberId,nw);
            }
            System.debug('pointsMap='+pointsMap);
                for( EntitySubscription user : userList){
                    if(pointsMap.keyset().contains(user.ParentId)){
                        TopParticipantListWrapper participant = new TopParticipantListWrapper();
                        participant.Name = pointsMap.get(user.ParentId).Member.Name;
                        participant.PhotoURL = pointsMap.get(user.ParentId).Member.FullPhotoUrl;
                        participant.points = pointsMap.get(user.ParentId).ReputationPoints;
                        participant.URL = sitelabel + 'profile/'+pointsMap.get(user.ParentId).MemberId;
                        if(!results.contains(participant)){
                             results.add(participant);
                        }
                    }
                }
            System.debug('results='+results);
            
        } catch(Exception e){
            system.debug('Error in get Following Number: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
   
        return results; 
    }
    
    /*@AuraEnabled(cacheable=true)
    public static List<Productwrapper> getProductsOwnedByUser(string userId){
        try{
            String sitelabel = System.Label.IN_CommunityName;
            List<Topic> topiclist = [SELECT Id,Name FROM Topic];
            Map<String,Id> topicMap = new Map<String,Id>();
            
            for(Topic tp :topiclist){
               topicMap.put(tp.Name,tp.Id);
            }
            
            List<Productwrapper> productsOwned = new List<Productwrapper>();
            List<User> userlist = [SELECT id, Products_Owned__c FROM User Where Id=:userId];
            if(userlist.size()>0){
                for(User usr : userlist){
                    if(usr.Products_Owned__c.contains(';')){                        
                        for(String pr :usr.Products_Owned__c.split(';')){
                            Productwrapper pwrap = new Productwrapper();
                            pwrap.ProductName = pr;
                            if(topicMap.keyset().contains(pr))
                            pwrap.URL = sitelabel + 'topic/'+ topicMap.get(pr);
                            productsOwned.add(pwrap);
                        }
                    }
                    else{
                        Productwrapper pwrap = new Productwrapper();
                        pwrap.ProductName = usr.Products_Owned__c;
                        if(topicMap.keyset().contains(usr.Products_Owned__c))
                            pwrap.URL = sitelabel + 'topic/'+ topicMap.get(usr.Products_Owned__c);
                        productsOwned.add(pwrap);
                    }
                }                
            }
            System.debug('productsOwned='+productsOwned);
            if(productsOwned.size() > 0) return  productsOwned;
            else return null;
        } catch(Exception e){
            system.debug('Error in getProductsOwnedByUser: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }        
    }*/
    
    
    @AuraEnabled(cacheable=true)
    public Static UserDetailWrapper getUserdetails(String recordId, String networkId){
        try{
            List<NetworkMember> pointsList = new List<NetworkMember>();
        	Map<Id,NetworkMember> pointsMap = new Map<Id,NetworkMember>();         
            List<User> userlist = [SELECT Id,title,Name,FullphotoURL,CommunityNickname,firstname,lastname,email,companyname,Phone,Address 
                                   FROM USER where Id=:recordId];
            System.debug('userlist='+userlist);
            UserDetailWrapper usr = new UserDetailWrapper();
            usr.Userdetail = userlist;            
            usr.MemberPoints = [SELECT ReputationPoints from NetworkMember where 
                               NetworkId =:networkId and MemberId=:recordId].ReputationPoints;
                                      
            return usr;
        }
        catch(Exception e){
            system.debug('Error in User Details: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    @AuraEnabled
    public Static String handleFollow(String recordId,String userId, String networkId,String FollowType){
        try{
            System.debug('FollowType='+FollowType);
            if(FollowType=='Follow'){
                EntitySubscription record = new EntitySubscription(
                    NetworkId=networkId,
                    ParentId=recordId,
                    SubscriberId=userId);
                insert record;                
            }                                        
            
            else if(FollowType=='Unfollow'){
                System.debug('UNfollow block');
                List<EntitySubscription> result =[SELECT Id FROM EntitySubscription where NetworkId =: networkId and ParentId =: recordId and SubscriberId =: userId limit 1000];
                if(result.size()>0){
                    delete result;    
                }                           
            }
                        
            return FollowType;
            
        }
        catch(Exception e){
            system.debug('Error in Handle Follow: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static Integer getFollowingUser(String recordId, String user, String networId){
        try{
            List<EntitySubscription> result = new List<EntitySubscription>();
			result = [SELECT Id FROM EntitySubscription where NetworkId =: networId and ParentId =: recordId and SubscriberId =: user limit 1000];
            System.debug('result='+result.size());
            return result.size();
        }
        catch(Exception e){
            system.debug('Error in getFollowingUser : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static GamificationWrapper getGamificationPoints(String userId, String networkId){
        try{
            Decimal points = [SELECT Id, MemberId, ReputationPoints, Network.Name from NetworkMember where NetworkId =:networkId and MemberId=:userId].ReputationPoints;
            GamificationWrapper wrap = new GamificationWrapper();
            wrap.GamPoints = getmetadatarecords();
            wrap.Userpoint = Integer.valueof(points);
            return wrap;            
        }
        catch(Exception e){
            system.debug('Error in Gampoints: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public Static String handlePostUploadSave(String fileDetail,String imgName, String mimeType,String userId,String communityId){
        try{            
            Blob blbImageBody = EncodingUtil.base64Decode(fileDetail);            
            ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(blbImageBody, mimeType, imgName);  
            ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(communityId, userId, fileUpload);                              
            return 'Success';            
        }
        catch(Exception e){
            system.debug('Error in handlePostUploadSave: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }        
    }
    
    @AuraEnabled    
    public Static String handleNickName(String nickname){
        try{            
            User usrInfo = [Select Id,CommunityNickName from user where Id=:userinfo.getUserId()];
            usrInfo.CommunityNickName = nickname;
            update usrInfo;
            return 'Success';            
        }
        catch(Exception e){
            system.debug('Error in handleNickName: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    
    
    public class GamificationWrapper{
        @AuraEnabled public help_Infa_Custom_Label__mdt GamPoints;
        @AuraEnabled public Decimal Userpoint;
    }
     
    
    
    public class UserDetailWrapper{
         @AuraEnabled public List<User> Userdetail;
         @AuraEnabled public Decimal MemberPoints;
    }
    
    public class TopParticipantListWrapper{
        @AuraEnabled public String Name;
        @AuraEnabled public String PhotoURL;
        @AuraEnabled public Decimal Points;
        @AuraEnabled public String Badge;
        @AuraEnabled public String URL;
    }
    
    public class Productwrapper{
        @AuraEnabled public String ProductName;
        @AuraEnabled public String URL;
    }
    

}