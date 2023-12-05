/*
Class:          KBApprovalBatchtest
@Author:        Venky K 
@Created Date:  12-Oct-2020
@Description:   Test class to test the KBApprovalBatch 
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/

@isTest

public class KBApprovalBatchtest {
    
    public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
    public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';    
    public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';
    
    
     @isTest
    public static void setup() {
        createContentReviewer();
           
        
        /*User u1 = new User();
        Profile pr = [Select Id from Profile where Name = 'System Administrator'];
        u1.lastname = 'test admin';
        u1.Email = 'test@gmail.com';
        u1.profileid = pr.Id;
        insert u1;*/
        
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
        
        Group g = [select Id from Group where DeveloperName ='KB_Content_Reviewers_Queue' AND Type = 'Queue'];

        GroupMember member = new GroupMember();
        member.UserOrGroupId = contentReviewer.Id;
        member.GroupId = g.Id;
        insert member;
         
        Knowledge__kav articleOne = new Knowledge__kav();
        system.runas(contentReviewer){
         
        	articleOne.Title = 'Article One';
            articleOne.UrlName = '00000001';
            articleOne.Primary_Product__c = 'Active VOS';
            articleOne.Product_Version__c = '9.2.4';
            articleOne.Product_Component__c = 'ActiveVOS Console';
            articleOne.IsVisibleInPkb = true;
            articleOne.Solution__c = 'test solution';
            articleOne.Description__c = 'test description';
            insert articleOne; 
            KB_Approval_Inflight__c kap = new KB_Approval_Inflight__c();
            kap.Name = articleOne.Id;
            kap.Approval_process_name__c = 'KB_Content_Review';
            kap.SubmitterId__c = userinfo.getuserid();
            kap.ActorId__c = userinfo.getuserid();
            kap.Setactor__c = true;
            insert kap;  
            
           Knowledge__kav tempone = [Select Id from Knowledge__kav limit 1];
            system.debug('tempone'+tempone);
            
        }
        
        //test.startTest();
        //Knowledge__kav articleOne = [Select Id from Knowledge__kav limit 1];              
         
        //test.stoptest();
        //custommetadatasetup();
               
        
    }
    
   
       
   public static testMethod void testbatch(){ 
       Knowledge__kav articletwo = new Knowledge__kav();
       articletwo.Title = 'Article One';
            articletwo.UrlName = '00000001';
            articletwo.Primary_Product__c = 'Active VOS';
            articletwo.Product_Version__c = '9.2.4';
            articletwo.Product_Component__c = 'ActiveVOS Console';
            articletwo.IsVisibleInPkb = true;
      		articletwo.Solution__c = 'test solution';
            articletwo.Description__c = 'test description';
            insert articletwo; 
       
            KB_Approval_Inflight__c kap = new KB_Approval_Inflight__c();
            kap.Name = articletwo.Id;
            kap.Approval_process_name__c = 'KB_Content_Review';
            kap.SubmitterId__c = userinfo.getuserid();
            kap.ActorId__c = userinfo.getuserid();
            kap.Setactor__c = true;
            insert kap;  
            
       
       Set<id> kavids = new Set<id>();
       Knowledge__kav kb = [Select Id from Knowledge__kav limit 1];
       kavids.add(kb.Id);
       
    Test.startTest();
        KBApprovalBatch blc= new KBApprovalBatch(kavids);
        ID batchprocessid = Database.executeBatch(blc,1);
    Test.stopTest();
    }
    
     
    
    public static Id getPermissionSet(String permissionSetName){
        PermissionSet permissionSet = [Select Id From PermissionSet Where Name=:permissionSetName];

        return permissionSet.Id;
    }
    
     public static void assignPermissionSet(Id userId, List<String> lstPermissionSetName){
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        for(String permissionSetName : lstPermissionSetName){
            Id permissionSetId = getPermissionSet(permissionSetName);

            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = permissionSetId;
            psa.AssigneeId = userId;
            lstPSA.add(psa);
        }
    
        System.debug('Permission Set Member List is ' + lstPSA);
        if(!lstPSA.isEmpty()) {
            insert lstPSA;
        }        
    }


    public static profile getKBUserProfile(){
        Profile profile = [Select Id, Name From Profile Where Name=:PROFILE_NAME_EMP_RESTRICTED];
        return profile;
    }

    
    public static user createContentReviewer(){
        Profile profile = getKBUserProfile();
        
        User contentReviewer = new User();
        contentReviewer.ProfileId = profile.id;
        contentReviewer.Username = KB_CONTENT_REVIEWER_USERNAME;
        contentReviewer.Email = KB_CONTENT_REVIEWER_USERNAME;
        contentReviewer.LastName = 'Reviewer';
        contentReviewer.FirstName = 'Content';
        contentReviewer.Alias = 'cr1';
        contentReviewer.TimeZoneSidKey = 'GMT';
        contentReviewer.LocaleSidKey = 'en_US';
        contentReviewer.EmailEncodingKey = 'UTF-8';
        contentReviewer.LanguageLocaleKey = 'en_US';
        contentReviewer.UserPermissionsKnowledgeUser = true;
        insert contentReviewer;
        List<String> lstPermissionSetName =  new List<String>();
        lstPermissionSetName.add('KB_Content_Reviewer');
        assignPermissionSet(contentReviewer.Id,lstPermissionSetName);

        return contentReviewer;
    }    

}