/*
Class:          AQITest
@Author:        Venky K 
@Created Date:  12-Oct-2020
@Description:   Test class to test the ArticleQualityTriggerHelper 
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public with sharing class AQITest {

    public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';

    public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
    public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';

    public static final String SKILL_NAME_AUTHOR = 'KB_AUTHOR_CONTRIBUTOR';
    public static final String SKILL_NAME_CONTENT_REVIEWER = 'KB_CONTENT_REVIEWER';
    public static final String SKILL_NAME_ACTIVE_VOS = 'KB_TECH_ACTIVEVOS';
    
    
   @testSetup
    static void setupObjectTestData() {
        setupCustomSettings(UserInfo.getOrganizationId());    
    }

    public static profile getKBUserProfile(){
        Profile profile = [Select Id, Name From Profile Where Name=:PROFILE_NAME_EMP_RESTRICTED];
        return profile;
    }

    public static Id getPermissionSet(String permissionSetName){
        PermissionSet permissionSet = [Select Id From PermissionSet Where Name=:permissionSetName];

        return permissionSet.Id;
    }

   
    public static void setupCustomSettings(Id idval){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.ArticleQuality__c = true;
        trigSetting.ProfileSkillUser__c = true;
        insert trigSetting;
        Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(idval);
        system.debug('bypass'+bts);
    }

       

    public static user createAuthor(){
        
        Profile profile = getKBUserProfile();
        
        User author = new User();
        author.ProfileId = profile.id;
        author.Username = KB_AUTHOR_USERNAME;
        author.Email = KB_AUTHOR_USERNAME;
        author.LastName = 'Author';
        author.FirstName = 'One';
        author.Alias = 'auth1';
        author.TimeZoneSidKey = 'GMT';
        author.LocaleSidKey = 'en_US';
        author.EmailEncodingKey = 'UTF-8';
        author.LanguageLocaleKey = 'en_US';
        author.UserPermissionsKnowledgeUser = true;
        insert author;
        List<String> lstPermissionSetName =  new List<String>();
        lstPermissionSetName.add('KB_Author_Contributor');
        assignPermissionSet(author.Id,lstPermissionSetName);

        return author;
        
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

    @isTest
    public static void testKB(){
             
        Test.startTest();
        createAuthor();
        createContentReviewer();
       
        User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
        User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
       
		Knowledge__kav articleOne = new Knowledge__kav();
        Test.stopTest();
        System.runAs(author){
            
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
        }
    
        Knowledge__kav temparticle = [Select Id, ValidationStatus,PublishStatus,IsVisibleInPkb,Visible_In_Public_Knowledge_Base__c,IsMasterLanguage,KnowledgeArticleId,Title From Knowledge__kav Where Id = :articleOne.Id];
        System.debug('articleOne - ' + temparticle);
       
    
        System.runAs(contentReviewer){
            system.debug('publish state'+temparticle.PublishStatus);
            system.debug('master language'+temparticle.IsVisibleInPkb);
            
			aqi_ltng_mng__Article_Quality__c aq = new aqi_ltng_mng__Article_Quality__c();
            aq.Name = 'test aqi';
            aq.aqi_ltng_mng__Article_Unique__c = true;
            aq.aqi_ltng_mng__Knowledge_Article_Id__c = temparticle.KnowledgeArticleId;
            aq.aqi_ltng_mng__Article_Title__c = temparticle.Title;
            aq.aqi_ltng_mng__Knowledge_Article_Version_Id__c  = temparticle.Id;            
            aq.aqi_ltng_mng__Agent__c = userinfo.getuserId();            
            aq.aqi_ltng_mng__Article_Version__c = 0;
            insert aq;          
           
    }
        
        ArticleQualityTriggerHandler ath = new ArticleQualityTriggerHandler();
        ath.beforeUpdate();
        ath.afterDelete();
        
        //aqi_ltng_mng__Article_Quality__c aqi = [Select Id from aqi_ltng_mng__Article_Quality__c LIMIT 1];
        //UPDATE aqi;        
}

}