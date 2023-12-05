/*
* Name         :   helpGroupChapterLeaders
* Author       :   Saumya Gaikwad
* Created Date :   28/07/2022
* Description  :   Controller class for chapter leader section on group details page

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                Tag
**********************************************************************************************************
Saumya Gaikwad      28/07/2022         I2RT-6758      Initial version.            T3
*/

 
public class helpGroupChapterLeaders {
    /* T3 - Displaying chapter leaders name in the Group details widget.*/
    @AuraEnabled(cacheable=true)
    public static list<membersWrapper> getChapterLeader(String collaborationGroupId, String UserId){
        List<membersWrapper> chapterLeadersList = new List<membersWrapper>();
        Boolean isComponentVisible = false;
        List<help_Infa_Custom_Label__mdt> communityUrl = [SELECT community_url__c FROM help_Infa_Custom_Label__mdt WHERE developerName = 'community_url'];
        for(CollaborationGroupMember cgObj : [Select id, collaborationGroup.ownerId, memberid, member.CommunityNickname, member.FullPhotoUrl from CollaborationGroupMember where collaborationRole = 'Admin' and collaborationGroupId = :collaborationGroupId ORDER BY member.CommunityNickname ASC ]){
            if(cgObj.collaborationGroup.ownerId != cgObj.memberid && chapterLeadersList.size() < 4){
                membersWrapper memberObj = new membersWrapper();
                memberObj.chapterLeader = cgObj;
                memberObj.profileUrl = communityUrl[0].community_url__c + 'profile/'+cgObj.MemberId;
                chapterLeadersList.add(memberObj);
            }
        }
        return chapterLeadersList;
    }
    
    /* T3 - Displaying chapter leaders name in the Group details widget.*/
    public class membersWrapper{
        @AuraEnabled public CollaborationGroupMember chapterLeader {get; set;}
        @AuraEnabled public String profileUrl {get; set;}
    }
}