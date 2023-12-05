/*
Class:          GetProcessInstanceDataTest
@Author:        Venky K 
@Created Date:  12-Oct-2020
@Description:   Test class to test the GetProcessInstanceData 
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/

@isTest
public with sharing class GetProcessInstanceDataTest {

    public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
    public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';    
    public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';
    public static final String fieldlist = 'Document_Priority__c,VersionNumber,ArticleNumber,Article_Type__c,Content_Review_Date__c,Last_Modified_Date__c,Primary_Product__c';
    public static final String objectName = 'Knowledge__kav';
    public static final String mode = 'single';
    
   @isTest
    public static void setup() {
        //create a record
       
        test.startTest();
        createContentReviewer();
        test.stoptest();
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
        Group g = [select Id from Group where DeveloperName ='KB_Content_Reviewers_Queue' AND Type = 'Queue'];

        GroupMember member = new GroupMember();
        member.UserOrGroupId = contentReviewer.Id;
        member.GroupId = g.Id;
        insert member;
         
        
        system.runas(contentReviewer){
            Knowledge__kav articleOne = new Knowledge__kav();
        	articleOne.Title = 'Article One';
            articleOne.UrlName = '00000001';
            articleOne.Primary_Product__c = 'Active VOS';
            articleOne.Product_Version__c = '9.2.4';
            articleOne.Product_Component__c = 'ActiveVOS Console';
            articleOne.IsVisibleInPkb = true;
            articleOne.Solution__c = 'test solution';
            articleOne.Description__c = 'test description';
            insert articleOne;
            KBLWCHandler.getApprovalProcessName(articleOne.Id);
        	KBLWCHandler.submitForReview(articleOne.Id, 'submit comments');  
            GetProcessInstanceData.getProcessItemData(contentReviewer.Id,fieldlist,objectName,mode);
            //GetProcessInstanceData.getObjectAvailableFieldsString(objectName);
        }
       
       //ProcessInstanceData pid = new ProcessInstanceData();
        //create an approval process
        //GenerateApprovalProcess.createApprovalProcess();

        //ApprovalSubmitter curSubmitter = new ApprovalSubmitter();
        //curSubmitter.type = 'allInternalUsers';
        //curProcess.allowedSubmitters.add(curSubmitter);


        String approvalProcessName = '';

        //submitRecord(curAccount, testUser1, approvalProcessName);


        
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