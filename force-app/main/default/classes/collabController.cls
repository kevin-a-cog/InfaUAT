public class collabController {
    @AuraEnabled  
    public static string cloneCollab( String recId ) {
        Raise_Hand__c rH = [SELECT Id, Name, Accepted_On__c, Closed_On__c, Status__c, Accepted_By__c,
                            Case__c, Type__c,Title__c, Description__c, Subtype__c, Product__c,Feed_Item_Id__c   
                            FROM Raise_Hand__c where Id = :recId limit 1];
                            
        FeedItem fd = [SELECT Id, ParentId, Type, Title, Body, LikeCount, CommentCount, LinkUrl, IsRichText, RelatedRecordId, 
                       InsertedById, NetworkScope, Visibility, BestCommentId, HasContent, HasLink, HasFeedEntity, 
                       HasVerifiedComment, IsClosed, Status FROM FeedItem where id = :rh.Feed_Item_Id__c];
        
        Raise_Hand__c collClone = rH.clone(false, false, false, false);
        collClone.Accepted_On__c = null;
        collClone.Closed_On__c = null;
        collClone.Accepted_By__c = null;
        collClone.Status__c = 'Open';
        insert collClone;
        
        FeedItem cloneFeed = fd.clone(false, false, false, false);
        cloneFeed.ParentId = collClone.Id;
        insert cloneFeed;
        collClone.Feed_Item_Id__c = cloneFeed.id;
        update cloneFeed; 
        return collClone.Id;
    }
     @AuraEnabled  
    public static void updateCollab( String recId, Boolean RemoveTeamMember) {
        try{
            Raise_Hand__c rH = [SELECT Id, Name, Product__c,Title__c,Subtype__c,Description__c,Accepted_By__c,CreatedDate,Accepted_On__c,Case__c,Type__c,Skill__c, Closed_On__c, Status__c FROM Raise_Hand__c where Id = :recId limit 1];
           
            if(!RemoveTeamMember){
                for(Case_Team__c ct: [Select Id from Case_Team__c where case__c = :rH.Case__c and  User__c = :rH.Accepted_By__c limit 1]){
                    delete ct;
                }
            }
            
            rH.Accepted_On__c = null;
            rH.Closed_On__c = null; 
            rH.Accepted_By__c = null;
            rH.Status__c = 'Open';
            update rH;
            
            Case c = new Case();
            if(rH.Case__c != null){
              c =   [Select Id,Account.Name,Support_Level__c,GCS_Segment__c,Account.New_Org_Account_Number__c,Acc__c,CaseNumber,OwnerId,Priority,Forecast_Product__c,Version__c,Support_Account__r.New_Org_Account_Number__c,Support_Account__r.Name from CASE where Id = :rH.Case__c];
            }
            
            String chatterGroupName = SkillService.getSkillByName(rH.Skill__c).Chatter_Group_Name__c;
            Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get(chatterGroupName).Id;
            RaiseHandService.notificationNewRequest(c,rH,chatterGroupId);
            String caseComment = RaiseHandService.constructCaseCommentpublic(rH);
            
            insert CaseCommentService.createRaiseHand(c.Id, caseComment);
            
        }Catch(Exception e){
            System.debug('Exception happened in updatecollab:'+e.getMessage()+','+e.getLineNumber());
        }
    }
    
}