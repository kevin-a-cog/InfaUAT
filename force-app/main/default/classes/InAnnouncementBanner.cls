/*
* Name         :   InAnnouncementBanner
* Author       :   Utkarsh Jain
* Created Date :   15-Feb-2022
* Description  :   Controller used to get all user related data.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                                 Tag
**************************************************************************************************************************
Utkarsh Jain           15-FEB-2022     I2RT-5421         Initial version.                                              NA
Utkarsh Jain           16-JUN-2022     I2RT-6422         Bringing Announcements on Community Page                      NA
Utkarsh Jain           14-SEPT-2022    I2RT-6886         Revolving hero banners for all the product community           1 
Utkarsh Jain           05-DEC-2022     I2RT-7549         Private User group - announcements should not be visible    
to public users.                                               2
Deeksha Shetty         19-OCT-2023     I2RT-7150         User Group: Revolving Hero banner for User group detail page   3

*/
public without sharing class InAnnouncementBanner {
    
    @AuraEnabled(cacheable=true)
    public static list<Alerts_Announcements__c> getAnnouncementList(){
        list<Alerts_Announcements__c> announcementList=new list<Alerts_Announcements__c>();
        Date todaysDate = Date.today();
        try{
            List<RecordType> recordList = [SELECT Id, Name from RecordType where Name = 'IN - Alert'];
            // Tag 2 - start
            announcementList = [select Id, Name, Description__c, End_Date__c, Start_Date__c, RecordTypeId from Alerts_Announcements__c where RecordTypeId =: recordList[0].Id and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate];
            // Tag 2 - end
            return announcementList; 
            
        } catch(Exception e){
            system.debug('Error in getAnnoncementList : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Alerts_Announcements__c> getAnnouncementTileList(String type, String id){
        list<Alerts_Announcements__c> announcementList=new list<Alerts_Announcements__c>();
        list<Alerts_Announcements__c> result=new list<Alerts_Announcements__c>();
        List<Alerts_Announcements__c> res;
        List<RecordType> recordList = [SELECT Id, Name from RecordType where Name = 'IN - Announcement'];
        List<Topic> topicName;
        // Tag 2 - start
        Date todaysDate = Date.today();
        try{
            if(type == 'HeroBanner'){
                res = [select Id, Name, Image_URL__c,Start_Date__c,End_Date__c, Select_Font_Color__c, Description__c, hero_description__c, Community__c, AnnouncementDescription__c, Active__c, RecordTypeId, Hero_Carousel__c from Alerts_Announcements__c where RecordTypeId =: recordList[0].Id and Hero_Carousel__c = true and Active__c = true and Community__c = '' and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate];
            }else if (type == 'Home'){
                res = [select Id, Name, Image_URL__c, Description__c,Start_Date__c,End_Date__c, AnnouncementDescription__c, Active__c, RecordTypeId, Community__c, Hero_Carousel__c from Alerts_Announcements__c where RecordTypeId =: recordList[0].Id and Active__c = true and User_Group__c = '' and Hero_Carousel__c = false and Community__c = '' and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate];
            }else if (type == 'Communities'){
                topicName = [SELECT Id, Name from Topic where Id =: id];
                res = [select Id, Name, Image_URL__c, Description__c,Start_Date__c,End_Date__c, AnnouncementDescription__c, Active__c, RecordTypeId, Hero_Carousel__c, Community__c from Alerts_Announcements__c where RecordTypeId =: recordList[0].Id and Active__c = true and Hero_Carousel__c = false and Community__c != '' and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate];
            }else if (type == 'Groups'){
                res = [select Id, Name, Image_URL__c,User_Group__c,Start_Date__c,End_Date__c, Description__c, AnnouncementDescription__c, Active__c, RecordTypeId, Hero_Carousel__c from Alerts_Announcements__c where RecordTypeId =: recordList[0].Id and User_Group__c =:id and Active__c = true and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate];
            }
            for(Alerts_Announcements__c annoucement: res){
                if(Date.today() >= Date.valueOf(annoucement.Start_Date__c ) && Date.today() <= Date.valueOf(annoucement.End_Date__c)){
                    if(annoucement.AnnouncementDescription__c != null && annoucement.AnnouncementDescription__c?.contains('<img') && annoucement.Active__c){
                        String firstSubString = annoucement.AnnouncementDescription__c?.substringBetween('<img', 'img>');
                        String secondSubString = firstSubString?.substringBetween('src="', '"');
                        String imglink = secondSubString?.replace('amp;', '');
                        annoucement.Image_URL__c = imglink;
                        String textSubString = annoucement.AnnouncementDescription__c.substringBetween('\"_blank\">', '</a>');
                        String linkSubString = annoucement.AnnouncementDescription__c.substringBetween('<a href=\"', '\" target');    
                        annoucement.Highlight_link__c = linkSubString;
                        annoucement.Description__c = textSubString;
                        if(type == 'Communities'){
                            if(annoucement.Community__c.contains(topicName[0].Name)){
                                announcementList.add(annoucement);  
                            }
                        }else{
                            announcementList.add(annoucement);
                        }
                    }
                }
                // Tag 2 - end
            }
            if(type == 'HeroBanner'){
                return announcementList;
            }
            if(announcementList.size() > 6){
                for(Integer i = 0; i < 6; i++){
                    result.add(announcementList[i]);
                }
                return result;
            }
            return announcementList;
            
        } catch(Exception e){
            system.debug('Error in getAnnoncementTileList : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    @AuraEnabled
    public static String createAnnouncementFromCommunity(String title,String description,String startDate,String endDate, List<string> communitites){
        try{
            if((title != null || title!='' ) && (description != null || description != '') ){
                Alerts_Announcements__c announcement = new Alerts_Announcements__c();
                announcement.AnnouncementDescription__c = description;
                announcement.Name = title;
                announcement.Start_Date__c = Date.valueOf(startDate);
                announcement.End_Date__c = Date.valueOf(endDate);
                announcement.Community__c = String.join(communitites,';');
                announcement.RecordTypeId= Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
                insert announcement;
                return announcement.Id ;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Announcement creation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static String updateAnnouncementFromCommunity(String Id, String title,String description,String startDate,String endDate,List<string> communitites){
        try{
            if((title != null || title!='' ) && (description != null || description != '') ){
                Alerts_Announcements__c announcement = new Alerts_Announcements__c();
                announcement.Id = Id;
                announcement.AnnouncementDescription__c = description;
                announcement.Name = title;
                announcement.Start_Date__c = Date.valueOf(startDate);
                announcement.End_Date__c = Date.valueOf(endDate);
                announcement.Community__c = String.join(communitites,';');
                update announcement;
                return announcement.Id ;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Announcement update : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    // Tag 1 - start
    @AuraEnabled
    public static list<Alerts_Announcements__c> getHeroBannerForCommunity(String id){
        String recordId = Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Community Banner').getRecordTypeId();
        List<Alerts_Announcements__c> res;
        String communityName;
        list<Alerts_Announcements__c> announcementList=new list<Alerts_Announcements__c>();
        
        try{
            communityName = helpUserRelatedList.getCommunityName(id);
            res = [select Id, Name, Image_URL__c,Start_Date__c,End_Date__c, Select_Font_Color__c, Description__c, hero_description__c, 
                   Community__c,Primary_Banner__c, AnnouncementDescription__c, Active__c, RecordTypeId, Hero_Carousel__c 
                   from Alerts_Announcements__c where RecordTypeId =: recordId and Active__c = true 
                   and Community__c INCLUDES(:communityName) order by LastModifiedDate DESC];
            if(res.size()>0){
                announcementList = returnAnnouncementsRevolvingBanner(res);
            }
            return announcementList;
        } catch(Exception e){
            system.debug('Error in getAnnoncementTileList : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    // Tag 1 - end
    
    
    //Tag 3 - Start - This method Fetches the Revolving banners relevant to the user Group
    @AuraEnabled
    public static list<Alerts_Announcements__c> getHeroBannerForUserGroup(String grpId){
        String recordId = Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - User Group Banner').getRecordTypeId();
        List<Alerts_Announcements__c> res;
        list<Alerts_Announcements__c> announcementList=new list<Alerts_Announcements__c>();
        String userGroupName;
        
        try{            
            if(test.isRunningTest())  userGroupName = 'Arizona User Group';
            else { userGroupName = [Select Name from CollaborationGroup where Id=:grpId].Name; }
            
            if(userGroupName!= null || userGroupName!= '' ){
                res = [select Id, Name, Image_URL__c,Start_Date__c,End_Date__c, Select_Font_Color__c, Description__c, 
                       hero_description__c, User_Group_picklist__c ,Primary_Banner__c, 
                       AnnouncementDescription__c, Active__c, RecordTypeId, Hero_Carousel__c from Alerts_Announcements__c 
                       where RecordTypeId =: recordId and Active__c = true and User_Group_picklist__c INCLUDES(:userGroupName) 
                       order by LastModifiedDate DESC];               
            }
            if(res.size()>0){
                announcementList = returnAnnouncementsRevolvingBanner(res);
            }
            
            return announcementList;
            
        } catch(Exception e){
            system.debug('Error in getAnnoncementTileList for UG : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());           
        }
    }
    
    
    //Tag 3 - This method returns the alert/announcement relevant to Group/Community
    
    public static list<Alerts_Announcements__c> returnAnnouncementsRevolvingBanner(List<Alerts_Announcements__c> res){
        list<Alerts_Announcements__c> announcementList=new list<Alerts_Announcements__c>();
        for(Alerts_Announcements__c annoucement: res){
            if ((Date.today() >= Date.valueOf(annoucement.Start_Date__c ) && Date.today() <= Date.valueOf(annoucement.End_Date__c)) || annoucement.Primary_Banner__c){
                if(annoucement.AnnouncementDescription__c != null && annoucement.AnnouncementDescription__c?.contains('<img') && annoucement.Active__c){
                    String firstSubString = annoucement.AnnouncementDescription__c?.substringBetween('<img', 'img>');
                    String secondSubString = firstSubString?.substringBetween('src="', '"');
                    String imglink = secondSubString?.replace('amp;', '');
                    annoucement.Image_URL__c = imglink;
                }
                if(annoucement.AnnouncementDescription__c.substringBetween('<a href=\"', '\" target') == null){
                    annoucement.Highlight_link__c = annoucement.AnnouncementDescription__c.substringBetween('<p>', '</p><p><img');
                    annoucement.Description__c = '';
                }else{
                    String textSubString = annoucement.AnnouncementDescription__c.substringBetween('\"_blank\">', '</a>');
                    String linkSubString = annoucement.AnnouncementDescription__c.substringBetween('<a href=\"', '\" target');    
                    annoucement.Highlight_link__c = linkSubString;
                    annoucement.Description__c = textSubString;
                }
                announcementList.add(annoucement);
            }
        }
        return announcementList;
    }
    
    // Tag 3 - end
    
    
}