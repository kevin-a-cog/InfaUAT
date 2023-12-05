public class UserStoryPdfRendererController{
   public copado__User_Story__c userstoryVar { get; set; }
   public List<copado__User_Story_Metadata__c> userstorymetadataVar { get; set; }
   public List<copado__User_Story__History> userstoryHistry{ get; set; }
   public List<copado__Promoted_User_Story__c> promotedUserStory{ get; set; }
   public List<copado__User_Story_Commit__c> userstoryCommit{ get; set; }
   
   
    
    public UserStoryPdfRendererController(){
    
     userstoryVar = [SELECT Id,Name,copado__User_Story_Title__c,copadoccmint__JIRA_key__c,copado__Environment__r.name,copado__View_in_Git__c,RecordType.name,CreatedBy.name,LastModifiedBy.name,copado__Project__r.name,copado__Release__r.name,copado__Sprint__r.name,Owner.name,copado__Status__c,copado__Org_Credential__r.name,copado__Platform__c,copado__Developer__r.name,copado__Latest_Commit_Date__c  FROM copado__User_Story__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];   
     userstorymetadataVar = [SELECT Id,copado__Metadata_API_Name__c FROM copado__User_Story_Metadata__c WHERE copado__User_Story__c=:userstoryVar.id ];
     userstoryHistry =[SELECT CreatedBy.name,CreatedDate,OldValue,NewValue,field FROM copado__User_Story__History where ParentId  =:userstoryVar.id and field='copado__Org_Credential__c' and DataType='Text'];
     promotedUserStory=[select id,copado__Promotion__r.Name,copado__Promotion__r.copado__Project__r.name,copado__Promotion__r.copado__Release__r.name,copado__Promotion__r.copado__Source_Org_Credential__r.Name,  
     copado__Promotion__r.copado__Destination_Org_Credential__r.name,copado__Promotion__r.copado__Status__c from copado__Promoted_User_Story__c where copado__Promotion__r.copado__Status__c = 'completed' and copado__User_Story__c  =:userstoryVar.id];
     userstoryCommit=[select id,name,copado__Snapshot_Commit__r.Name,copado__CommitMessage__c,copado__User_Story__r.Name,copado__Status__c,copado__Snapshot_Commit__r.copado__Commit_Date__c  from copado__User_Story_Commit__c where copado__User_Story__c  =:userstoryVar.id];
    }
}