/*
   Class:          KnowledgeTriggerHandlerTest
   @Author:        balajip
   @Created Date:  13-Oct-2020
   @Description:   Test class to Knowledge Article trigger

   Change History
 *************************************************************************************************************************************
   ModifiedBy               Date        Requested By        Description                                         Tag
 ************************************************************************************************************************************
 */
@isTest
public with sharing class KnowledgeTriggerHandlerTest {

	public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';

	public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
	public static final String KB_USERNAME_WITH_FEDID = 'oneuserwithfedid@infa.com.kbtest';
	public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';
	public static final String KB_MIGRATION_USER = 'kbmigrationusertest@informatica.com';
	public static final String KB_DIRECT_APPROVER_USERNAME = 'onedirectapprovaer@infa.com.kbtest';


	public static final String SKILL_NAME_AUTHOR = 'KB_AUTHOR_CONTRIBUTOR';
	public static final String SKILL_NAME_CONTENT_REVIEWER = 'KB_CONTENT_REVIEWER';
	public static final String SKILL_NAME_ACTIVE_VOS = 'KB_TECH_ACTIVEVOS';
	public static final String USERNAME_FEDID = 'withfd1';
	public static final String SKILL_NAME_DIRECT_APPROVER = 'KB_DIRECT_APPROVER';

	public static profile getKBUserProfile(){
		Profile profile = [Select Id, Name From Profile Where Name=:PROFILE_NAME_EMP_RESTRICTED];
		return profile;
	}

	public static Id getPermissionSet(String permissionSetName){
		PermissionSet permissionSet = [Select Id From PermissionSet Where Name=:permissionSetName];

		return permissionSet.Id;
	}

	public static void assignPermissionSet(Id userId, List<String> lstPermissionSetName){
		List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
		for(String permissionSetName : lstPermissionSetName) {
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

	public static void setupCustomSettings(){
		Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
		trigSetting.Knowledge__c = true;
		trigSetting.ProfileSkillUser__c = true;
		insert trigSetting;
	}

	public static void setupSkills(){
		List<Group> lstGroup = [Select Id, Name, DeveloperName, Type From Group Where Name like 'KB%'];
		system.debug('list of kb groups - ' + lstGroup);

		List<ProfileSkill> lstSkill = new List<ProfileSkill>();

		ProfileSkill skillAuthor = new ProfileSkill();
		skillAuthor.Name = SKILL_NAME_AUTHOR;
		skillAuthor.Permission_Set_Name__c = 'KB_Author_Contributor';
		lstSkill.add(skillAuthor);

		ProfileSkill skillCR = new ProfileSkill();
		skillCR.Name = SKILL_NAME_CONTENT_REVIEWER;
		skillCR.Permission_Set_Name__c = 'KB_Content_Reviewer';
		skillCR.Public_Group_Name__c = 'KB_Content_Review_Group';
		skillCR.Queue_Name__c = 'KB_Content_Reviewers_Queue';
		//skillCR.Chatter_Group_Name__c = 'KB Content Reviewers Group';
		lstSkill.add(skillCR);

		ProfileSkill skillActiveVOS = new ProfileSkill();
		skillActiveVOS.Name = SKILL_NAME_ACTIVE_VOS;
		skillActiveVOS.Permission_Set_Name__c = 'KB_Technical_Reviewer';
		skillActiveVOS.Public_Group_Name__c = 'KB_Active_VOS';
		skillActiveVOS.Queue_Name__c = 'KB_Active_VOS';
		//skillActiveVOS.Chatter_Group_Name__c = 'KB Active VOS';
		lstSkill.add(skillActiveVOS);

		ProfileSkill skillDirectApprover = new ProfileSkill();
		skillDirectApprover.Name = SKILL_NAME_DIRECT_APPROVER;
		skillDirectApprover.Permission_Set_Name__c = 'KB_Direct_Approver';
		skillDirectApprover.Public_Group_Name__c = 'KB_Direct_Approver_Group';
		lstSkill.add(skillDirectApprover);

		insert lstSkill;
	}

	public static ProfileSkillUser assignSkill(Id userId, String skillName){
		ProfileSkill profileSkill = [Select Id From ProfileSkill Where Name=:skillName];

		ProfileSkillUser skillUser = new ProfileSkillUser();
		skillUser.ProfileSkillId = profileSkill.Id;
		skillUser.UserId = userId;
		return skillUser;
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

		return author;
	}

	public static user createDirectApprover(){
		Profile profile = getKBUserProfile();

		User author = new User();
		author.ProfileId = profile.id;
		author.Username = KB_DIRECT_APPROVER_USERNAME;
		author.Email = KB_DIRECT_APPROVER_USERNAME;
		author.LastName = 'Direct Approver';
		author.FirstName = 'One';
		author.Alias = 'direct1';
		author.TimeZoneSidKey = 'GMT';
		author.LocaleSidKey = 'en_US';
		author.EmailEncodingKey = 'UTF-8';
		author.LanguageLocaleKey = 'en_US';
		author.UserPermissionsKnowledgeUser = true;
		insert author;

		// Group queryDirectApproverGroup = new Group(Name='KB_Direct_Approver_Group', DeveloperName='KB_Direct_Approver_Group');
		// insert queryDirectApproverGroup;

		// User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		// System.runAs(KBMigUser) {
		// 	GroupMember gm = new GroupMember(GroupId = queryDirectApproverGroup.Id, UserOrGroupId = author.Id);
		// 	insert gm;
		// }

		return author;
	}

	public static user createMigrationUser(){
		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBMigLocalUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationusertest@informatica.com',
			Alias = 'kbmig',
			Email='kbmigrationusertest@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Migration User',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBMigLocalUser;
		return KBMigLocalUser;
	}

	public static user createUserWithFedId(){
		Profile profile = getKBUserProfile();

		User userwithfedid = new User();
		userwithfedid.ProfileId = profile.id;
		userwithfedid.Username = KB_USERNAME_WITH_FEDID;
		userwithfedid.Email = KB_USERNAME_WITH_FEDID;
		userwithfedid.LastName = 'UserWithFedID';
		userwithfedid.FirstName = 'One';
		userwithfedid.Alias = 'withfd1';
		userwithfedid.TimeZoneSidKey = 'GMT';
		userwithfedid.LocaleSidKey = 'en_US';
		userwithfedid.EmailEncodingKey = 'UTF-8';
		userwithfedid.LanguageLocaleKey = 'en_US';
		userwithfedid.UserPermissionsKnowledgeUser = true;
		userwithfedid.federationIdentifier=USERNAME_FEDID;
		insert userwithfedid;

		return userwithfedid;
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

		return contentReviewer;
	}

	public static void enableRecursion(){
		TriggerHandler.processedClasses.remove('AFTER: INSERTKnowledgeTriggerHandler');
		TriggerHandler.processedClasses.remove('AFTER: UPDATEKnowledgeTriggerHandler');
		TriggerHandler.processedClasses.remove('BEFORE: INSERTKnowledgeTriggerHandler');
		TriggerHandler.processedClasses.remove('BEFORE: UPDATEKnowledgeTriggerHandler');
	}

	public static Knowledge__kav newArticle(String title, String UrlName, String productName, String productVersion, String productComponent, String secProductName, String problemType, Boolean publicKB){
		Knowledge__kav kav = new Knowledge__kav();
		kav.Title = title;
		kav.UrlName = UrlName;
		kav.Primary_Product__c = productName;
		kav.Product_Version__c = productVersion;
		kav.Product_Component__c = productComponent;
		kav.Also_Applies_To__c = secProductName;
		kav.Problem_Type__c = problemType;
		kav.Visible_In_Public_Knowledge_Base__c = publicKB;
		return kav;
	}

	public static Knowledge__kav createArticle(){
		Knowledge__kav kav = new Knowledge__kav();
		kav.Title = 'Article One';
		kav.UrlName = '00000001';
		kav.Primary_Product__c = 'Active VOS';
		kav.Product_Version__c = '9.2.4';
		kav.Product_Component__c = 'ActiveVOS Console';
		kav.Also_Applies_To__c = 'Axon Data Governance';
		kav.Problem_Type__c = 'Connectivity';
		kav.Solution__c = 'test solution';
		kav.Description__c = 'test description';
		kav.Visible_In_Public_Knowledge_Base__c = true;
		kav.AQI_Score__c=50;
		insert kav;

		return kav;
	}

	public static Knowledge__kav createArticleTriggerLess(){
		Knowledge__kav kav = new Knowledge__kav();
		kav.Title = 'Article One';
		kav.UrlName = '00000001';
		kav.Primary_Product__c = 'Active VOS';
		kav.Product_Version__c = '9.2.4';
		kav.Product_Component__c = 'ActiveVOS Console';
		kav.Also_Applies_To__c = 'Axon Data Governance';
		kav.Problem_Type__c = 'Connectivity';
		kav.Solution__c = 'test solution';
		kav.Description__c = 'test description';
		kav.Visible_In_Public_Knowledge_Base__c = true;
		kav.AQI_Score__c=50;
		kav.ValidationStatus= 'Published';
		insert kav;

		return kav;
	}

	public static void addRelatedArticle(Knowledge__kav kav){
		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test solution';
		kavRelated.Description__c = 'test description';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		insert kavRelated;

		kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '000000024';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test solution';
		kavRelated.Description__c = 'test description';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		insert kavRelated;
		KBLWCHandler.submitForReview(kavRelated.Id, 'submit comments');



		Related_KB__c relatedKB = new Related_KB__c();
		relatedKB.Referred_Article__c = kavRelated.Id;
		relatedKB.Referred_In__c = kav.Id;
		insert relatedKB;
	}

	public static void addFile(Knowledge__kav kav){
		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = 'testing.txt';
		conVer.Title = 'Sample article file';
		conVer.VersionData = EncodingUtil.base64Decode('file content');
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = kav.Id;
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		insert conDocLink;
	}

	public static void submitForReview(Knowledge__kav kav){
		enableRecursion();
		KBLWCHandler.submitForReview(kav.Id, 'submit comments');
	}

	public static void approveCRWithoutTR(Id kavId){
		Knowledge__kav kav = [Select Id, ValidationStatus, TR_Approval__c, AQI_Score__c From Knowledge__kav Where Id = :kavId];
		kav.AQI_Score__c = 90;
		kav.Content_Update__c=true;
		update kav;
		System.debug('kav 1 - ' + kav);

		ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('content approved!');
		req.setAction('Approve');
		req.setWorkitemId(workItem.Id);
		enableRecursion();
		Approval.process(req);
	}

	public static void approveCR(Id kavId){
		Knowledge__kav kav = [Select Id, ValidationStatus, TR_Approval__c, AQI_Score__c From Knowledge__kav Where Id = :kavId];
		System.debug('kav 1 - ' + kav);

		kav.AQI_Score__c = 90;
		kav.TR_Approval__c = true;
		enableRecursion();
		update kav;

		ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('content approved!');
		req.setAction('Approve');
		req.setWorkitemId(workItem.Id);
		enableRecursion();
		Approval.process(req);
	}

	public static void approveTR(Id kavId){
		ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kavId Order By CreatedDate Desc Limit 1];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('tech approved!');
		req.setAction('Approve');
		req.setWorkitemId(workItem.Id);
		enableRecursion();
		Approval.process(req);
	}

	public static Knowledge__kav createAndPublishArticleWithoutTR(){
		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticle();
			submitForReview(kav);
		}
		addRelatedArticle(kav);
		approveCRWithoutTR(kav.Id);

		return kav;
	}

	public static Knowledge__kav createAndPublishArticleWithoutTRTriggerLess(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		// User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		System.runAs(KBMigUser){

			if(kav != null)
			{
				KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
			}

		}

		return kav;
	}

	public static Knowledge__kav createAndPublishWithFilesAndArticleAttached(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		// User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		addFile(kav);
		addRelatedArticle(kav);

		System.runAs(KBMigUser){

			if(kav != null)
			{
				KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
			}

		}

		return kav;
	}

	public static Knowledge__kav createAndPublishWithArchivedArticleAttached(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		// User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '000000400';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test solution';
		kavRelated.Description__c = 'test description';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		insert kavRelated;
		KBLWCHandler.submitForReview(kavRelated.Id, 'submit comments');



		Related_KB__c relatedKB = new Related_KB__c();
		relatedKB.Referred_Article__c = kavRelated.Id;
		relatedKB.Referred_In__c = kav.Id;
		insert relatedKB;

		addRelatedArticle(kav);

		System.runAs(KBMigUser){

			if(kav != null)
			{



				Knowledge__kav KBRelatedArticle = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000400'  AND PublishStatus = 'Online' LIMIT 1];

				if(KBRelatedArticle != null)
				{

					KbManagement.PublishingService.archiveOnlineArticle(KBRelatedArticle.KnowledgeArticleId, null);

				}

				KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
			}

		}

		return kav;
	}

	public static Knowledge__kav createAndPublishWithNullArticleAttached(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		// User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '000000400';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test solution';
		kavRelated.Description__c = 'test description';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		insert kavRelated;
		KBLWCHandler.submitForReview(kavRelated.Id, 'submit comments');


		Related_KB__c relatedKB = new Related_KB__c();
		relatedKB.Referred_Article__c = kavRelated.Id;
		relatedKB.Referred_In__c = kav.Id;
		insert relatedKB;


		addRelatedArticle(kav);

		System.runAs(KBMigUser){

			if(kav != null)
			{



				Knowledge__kav KBRelatedArticle = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000400'  AND PublishStatus = 'Online' LIMIT 1];

				if(KBRelatedArticle != null)
				{
					KbManagement.PublishingService.editOnlineArticle(KBRelatedArticle.KnowledgeArticleId, false);
					Knowledge__kav KBNewRelatedArticle = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000400'  AND PublishStatus = 'Draft' LIMIT 1];
					if(KBNewRelatedArticle != null)
					{
						KbManagement.PublishingService.publishArticle(KBNewRelatedArticle.KnowledgeArticleId, false);
						KBNewRelatedArticle = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000400'  AND PublishStatus = 'Online' LIMIT 1];
					}
				}
				KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
			}

		}

		return kav;
	}

	public static Knowledge__kav publishTranslationTriggerLess(){


		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];



		}

		System.runAs(KBMigUser){
			Knowledge__kav KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND UrlName = '000000067'  LIMIT 1];


			if(KBToUpdate != null)
			{
				KbManagement.PublishingService.publishArticle(KBToUpdate.KnowledgeArticleId, true);

				String translatedKAVId = KbManagement.PublishingService.submitForTranslation(kav.KnowledgeArticleId, 'de', null, null);
				KBLWCHandler.publishTranslation(translatedKAVId);

			}

		}

		kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedDate,UrlName from Knowledge__kav where UrlName = '000000067' LIMIT 1];

		return kav;
	}





	@testSetup
	static void setupObjectTestData() {
		setupCustomSettings();
		setupSkills();
		Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);
		system.runAs(userByRole.get('Admin')){
			createAuthor();
			createContentReviewer();
			createUserWithFedId();
			createMigrationUser();
			createDirectApprover();

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
			User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
			User directApprover = [Select Id From User Where username=:KB_DIRECT_APPROVER_USERNAME];

			List<ProfileSkillUser> lstSkillUser = new List<ProfileSkillUser>();
			lstSkillUser.add(assignSkill(author.Id, SKILL_NAME_AUTHOR));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_CONTENT_REVIEWER));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_ACTIVE_VOS));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_AUTHOR));
			lstSkillUser.add(assignSkill(directApprover.Id, SKILL_NAME_DIRECT_APPROVER));
			insert lstSkillUser;


		}
	}

	@isTest
	public static void testAuthoringFlow1(){
		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticle();

			kav.AQI_Score__c = 90;
			update kav;

			submitForReview(kav);
		}

		ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('content approved!');
		req.setAction('Approve');
		req.setWorkitemId(workItem.Id);
		enableRecursion();
		Approval.process(req);
	}

	@isTest
	public static void testAuthoringFlow2(){
		try{

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(KBMigUser){
				kav = createArticle();
				submitForReview(kav);

				approveCR(kav.Id);
			}
			Knowledge__kav kavNew = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate, TR_Approval__c, AQI_Score__c From Knowledge__kav Where Title = :kav.Title And PublishStatus='Draft'];
			System.runAs(KBMigUser){
				approveTR(kavNew.Id);



			}


		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow3(){
		try{

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(KBMigUser){
				kav = createArticle();
				submitForReview(kav);

			}

			approveCR(kav.Id);


		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow4(){
		try{

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(author){
				kav = createArticle();
				submitForReview(kav);
			}
			approveCR(kav.Id);

			Knowledge__kav kavNew = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate, TR_Approval__c, AQI_Score__c From Knowledge__kav Where Title = :kav.Title And PublishStatus='Draft'];
			approveTR(kavNew.Id);



		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow5(){
		try{

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(author){
				kav = createArticle();
				KnowledgeTriggerHelper.getTRApproverId(kav.Id);
			}



		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow6(){
		try{

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(author){
				kav = createArticle();
				KnowledgeTriggerHelper.postToChatterGroup(kav.Primary_Product__c,kav);
			}



		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow7(){
		try{

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(KBMigUser){
				kav = createArticle();
				kav.ValidationStatus = 'Pending Technical Review';
				update kav;
				KnowledgeTriggerHelper helper = new KnowledgeTriggerHelper();
				Map<Id, Knowledge__kav> parNewMap = new Map<Id, Knowledge__kav>();
				parNewMap.put(kav.Id, kav);
				helper.processApproval(parNewMap, null);
			}





		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testAuthoringFlow8(){
		try{

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

			Knowledge__kav kav;



			User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

			System.runAs(author){
				kav = createArticle();
				KnowledgeTriggerHelper helper = new KnowledgeTriggerHelper();
				Map<Id, Knowledge__kav> parNewMap = new Map<Id, Knowledge__kav>();
				parNewMap.put(kav.Id, kav);
				helper.processAutoApproval(parNewMap, null);
			}



		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testArchival(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();
		try{
			KBLWCHandler.archiveArticle(kav.Id, 'archival comments');
		}catch(Exception ex) {
			System.debug('exception occurred - '+ex.getMessage());
		}
	}

	@isTest
	public static void testExtension(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		KBLWCHandler.extendAndPublish(kav.Id, '12 Months');
	}

	@isTest
	public static void testTranslation1(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		KBLWCHandler.validateTranslation(kav.Id);
	}

	@isTest
	public static void testTranslation2(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();
		KBLWCHandler.submittranslation(new List<String> {'ja'}, kav.Id);
	}

	@isTest
	public static void testTranslation3(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticle();
			submitForReview(kav);
		}
		addFile(kav);

		approveCRWithoutTR(kav.Id);
	}


	@isTest
	public static void testTranslation4(){
		Knowledge__kav kav = publishTranslationTriggerLess();
	}

	@isTest
	public static void testTranslation5(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticle();
			submitForReview(kav);
		}
		addRelatedArticle(kav);
	}

	@isTest
	public static void testTranslation6(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticle();
			submitForReview(kav);
		}

		addRelatedArticle(kav);
		approveCRWithoutTR(kav.Id);
	}

	@isTest
	public static void testFeedback(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		afl__afl_Article_Feedback__c feedback = new afl__afl_Article_Feedback__c();
		feedback.Knowledge__c = kav.Id;
		feedback.afl__Knowledge_Article_Version_Id__c = kav.KnowledgeArticleId;
		//feedback.afl__Article_Link__c = '';
		feedback.afl__Article_Number__c = kav.ArticleNumber;
		feedback.afl__Article_Title__c = kav.Title;
		feedback.afl__Feedback_Status__c = 'New';
		feedback.Like_Dislike__c = 'Dislike';
		feedback.afl__Feedback_Vote_Description__c = 'feeback comments';
		feedback.afl__Article_Created_Date__c = kav.CreatedDate;
		feedback.Feedback_User__c = UserInfo.getUserId();
		feedback.afl__Feedback_Source__c = 'External';
		feedback.Name = kav.Title;
		//feedback.OwnerId = '';
		//feedback.afl__Record_Type__c = '';

		insert feedback;

		KnowledgeTriggerHelper.getfeedbackrec(feedback.Id);
		KBLWCHandler.getLastFeedback(feedback.Id);
		KBLWCHandler.updatefeedback(feedback.Id, 'Like', 'reason', 'feedback comments');
		KnowledgeTriggerHelper.submitFeedbackReview(feedback.Id, 'review comments');
	}

	@isTest
	public static void testFeedback2(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();
		afl__afl_Article_Feedback__c feedback = new afl__afl_Article_Feedback__c();
		feedback.Knowledge__c = kav.Id;
		feedback.afl__Knowledge_Article_Version_Id__c = kav.KnowledgeArticleId;
		feedback.afl__Article_Number__c = kav.ArticleNumber;
		feedback.afl__Article_Title__c = kav.Title;
		feedback.Like_Dislike__c = 'Dislike';
		feedback.afl__Feedback_Vote_Description__c = 'feeback comments';
		feedback.afl__Article_Created_Date__c = kav.CreatedDate;
		feedback.Feedback_User__c = UserInfo.getUserId();
		feedback.afl__Feedback_Source__c = 'External';
		feedback.Name = kav.Title;
		feedback.Engineer_Comments__c = 'testabc';

		insert feedback;

		KnowledgeTriggerHelper.getfeedbackrec(feedback.Id);
		KBLWCHandler.getLastFeedback(feedback.Id);
		KBLWCHandler.updatefeedback(feedback.Id, 'Like', 'reason', 'feedback comments');
		KnowledgeTriggerHelper.submitFeedbackReview(feedback.Id, 'review comments');
	}

	@isTest
	public static void testFeedback3(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();
		afl__afl_Article_Feedback__c feedback = new afl__afl_Article_Feedback__c();
		feedback.Knowledge__c = kav.Id;
		feedback.afl__Knowledge_Article_Version_Id__c = kav.KnowledgeArticleId;
		feedback.afl__Article_Number__c = kav.ArticleNumber;
		feedback.afl__Article_Title__c = kav.Title;
		feedback.Like_Dislike__c = 'Dislike';
		feedback.afl__Feedback_Vote_Description__c = 'feeback comments';
		feedback.afl__Article_Created_Date__c = kav.CreatedDate;
		feedback.Feedback_User__c = UserInfo.getUserId();
		feedback.afl__Feedback_Source__c = 'External';
		feedback.Name = kav.Title;
		feedback.afl__Feedback_Status__c = 'Pending Review';
		feedback.afl__Action_Taken__c = 'Updated the article';
		feedback.Engineer_Comments__c = 'testabc';
		insert feedback;

		KnowledgeTriggerHelper.getfeedbackrec(feedback.Id);
		KBLWCHandler.getLastFeedback(feedback.Id);
		KBLWCHandler.updatefeedback(feedback.Id, 'Like', 'reason', 'feedback comments');
		KnowledgeTriggerHelper.submitFeedbackReview(feedback.Id, 'review comments');
	}

	@isTest
	static void validateAQITest1(){
		Knowledge__kav kav;
		String errorMsg ='Please evaluate the AQI and click Apply';
		try{
			system.debug('Inside ValidateAQITest1');
			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
			System.runAs(author){
				kav = new Knowledge__kav();
				kav.Title = 'Article One';
				kav.UrlName = '00000001';
				kav.Primary_Product__c = 'Active VOS';
				kav.Product_Version__c = '9.2.4';
				kav.Product_Component__c = 'ActiveVOS Console';
				kav.Also_Applies_To__c = 'Axon Data Governance';
				kav.Problem_Type__c = 'Connectivity';
				kav.Solution__c = 'test solution';
				kav.Description__c = 'test description';
				kav.Visible_In_Public_Knowledge_Base__c = true;
				insert kav;
				submitForReview(kav);
			}
			ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('content approved!');
			req.setAction('Approve');
			req.setWorkitemId(workItem.Id);
			enableRecursion();
			Approval.process(req);
		}catch(exception ex) {
			system.debug('error message'+ex.getMessage());
			boolean checkErrorMsg = ex.getMessage().contains(errorMsg);
			system.assert (checkErrorMsg);
		}
	}

	@isTest
	static void validateAQITest2(){
		Knowledge__kav kav;
		String errorMsg ='Please select the Content Update flag and click Apply';
		try{
			system.debug('Inside ValidateAQITest1');
			User author = [Select Id From User Where Id=:Label.KB_Migration_userid];
			System.runAs(author){
				kav = new Knowledge__kav();
				kav.Title = 'Article One';
				kav.UrlName = '00000001';
				kav.Primary_Product__c = 'Active VOS';
				kav.Product_Version__c = '9.2.4';
				kav.Product_Component__c = 'ActiveVOS Console';
				kav.Also_Applies_To__c = 'Axon Data Governance';
				kav.Problem_Type__c = 'Connectivity';
				kav.Solution__c = 'test solution';
				kav.Description__c = 'test description';
				kav.Visible_In_Public_Knowledge_Base__c = true;
				insert kav;
				submitForReview(kav);
			}
			ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('content approved!');
			req.setAction('Approve');
			req.setWorkitemId(workItem.Id);
			enableRecursion();
			Approval.process(req);
		}catch(exception ex) {
			system.debug('error message'+ex.getMessage());

			boolean checkErrorMsg = ex.getMessage().contains(errorMsg);
			system.assert (checkErrorMsg);
		}
	}

	@isTest
	static void validateRejectTest3(){
		Knowledge__kav kav;
		String errorMsg ='Please select the Content Update flag and click Apply';
		try{
			system.debug('Inside ValidateAQITest1');
			User author = [Select Id From User Where Id=:Label.KB_Migration_userid];
			System.runAs(author){
				kav = new Knowledge__kav();
				kav.Title = 'Article One';
				kav.UrlName = '00000001';
				kav.Primary_Product__c = 'Active VOS';
				kav.Product_Version__c = '9.2.4';
				kav.Product_Component__c = 'ActiveVOS Console';
				kav.Also_Applies_To__c = 'Axon Data Governance';
				kav.Problem_Type__c = 'Connectivity';
				kav.Solution__c = 'test solution';
				kav.Description__c = 'test description';
				kav.Visible_In_Public_Knowledge_Base__c = true;
				insert kav;
				submitForReview(kav);
			}
			ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('content approved!');
			req.setAction('Reject');
			req.setWorkitemId(workItem.Id);
			enableRecursion();
			Approval.process(req);
		}catch(exception ex) {
			system.debug('error message'+ex.getMessage());

			boolean checkErrorMsg = ex.getMessage().contains(errorMsg);
			system.assert (checkErrorMsg);
		}
	}

	@isTest
	static void getPositiveFeedbackTest(){
		Knowledge__kav knwRec = createAndPublishArticleWithoutTRTriggerLess();
		Knowledge__kav kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where Id = :knwRec.Id];

		afl__afl_Article_Feedback__c af = new afl__afl_Article_Feedback__c();
		af.Knowledge__c = kav.Id;
		af.afl__Article_Version__c = kav.VersionNumber;
		af.afl__Article_Number__c =  kav.ArticleNumber;
		af.afl__Article_Title__c = kav.Title;
		af.afl__Knowledge_Article_Version_Id__c = kav.Id;
		af.afl__Article_Link__c = Label.KB_URL + '/' + kav.Id + '/view';
		af.afl__Feedback_Status__c = 'New';
		af.Like_Dislike__c = 'Like';
		af.afl__Feedback_Source__c = 'Internal';
		af.afl__Feedback_Vote_Description__c = 'Nice';
		af.Feedback_User__c = userinfo.getuserid();
		af.ownerid =  Label.Feedback_Queue;
		af.Name = kav.Title.left(80);
		INSERT af;
		Integer expectedCount =1;
		Integer positiveCount =  KBLWCHandler.getPositiveFeedback(kav.Id);
		system.debug('positive count value '+positiveCount);
		system.assertEquals(expectedCount, positiveCount);
	}

	@isTest
	public static void testcopyRelatedArticlesReferrenceInKB(){
		Test.startTest();




		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(KBMigUser){

			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle One';
			kavMocData.UrlName = '0100001';
			kavMocData.Migrated_Article_Id__c = '0100001';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle two';
			kavMocData.UrlName = '0100002';
			kavMocData.Migrated_Article_Id__c = '0100002';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;


			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Three';
			kavMocData.UrlName = '0100003';
			kavMocData.Migrated_Article_Id__c = '0100003';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;



			List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId()  LIMIT 100];
			if(KBToUpdate.size() != 0)
			{
				for(Knowledge__kav kbart : KBToUpdate) {
					KbManagement.PublishingService.publishArticle(kbart.KnowledgeArticleId, true);
				}
			}
		}


		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];

		System.runAs(author){
			Knowledge__kav kav = new Knowledge__kav();
			kav.Title = 'Article 24';
			kav.UrlName = '000000067';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;


			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

			Knowledge__kav kavRelatedOne = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '0100001' AND PublishStatus = 'Online'  LIMIT 1];

			Knowledge__kav kavRelatedTwo = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '0100002' AND PublishStatus = 'Online'  LIMIT 1];

			Knowledge__kav kavRelatedThree = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '0100003' AND PublishStatus = 'Online'  LIMIT 1];

			Related_KB__c relatedKB = new Related_KB__c();
			relatedKB.Referred_Article__c = kavRelatedOne.Id;
			relatedKB.Referred_In__c = kav.Id;
			insert relatedKB;

			relatedKB = new Related_KB__c();
			relatedKB.Referred_Article__c = kavRelatedTwo.Id;
			relatedKB.Referred_In__c = kav.Id;
			insert relatedKB;

			relatedKB = new Related_KB__c();
			relatedKB.Referred_Article__c = kavRelatedThree.Id;
			relatedKB.Referred_In__c = kav.Id;
			insert relatedKB;

		}

		System.runAs(KBMigUser){
			Knowledge__kav KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND UrlName = '0100001'  LIMIT 1];


			if(KBToUpdate != null)
			{
				KbManagement.PublishingService.archiveOnlineArticle(KBToUpdate.KnowledgeArticleId, null);
			}

			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND UrlName = '0100002'  LIMIT 1];


			if(KBToUpdate != null)
			{
				KbManagement.PublishingService.editOnlineArticle(KBToUpdate.KnowledgeArticleId,false);
			}

			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND UrlName = '0100002'  LIMIT 1];


			if(KBToUpdate != null)
			{
				KbManagement.PublishingService.publishArticle(KBToUpdate.KnowledgeArticleId, true);
			}

			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND UrlName = '0100003'  LIMIT 1];


			if(KBToUpdate != null)
			{
				KbManagement.PublishingService.archiveOnlineArticle(KBToUpdate.KnowledgeArticleId, null);
			}

		}

		System.runAs(author){
			Knowledge__kav kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '000000067' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];
			KBLWCHandler.getApprovalProcessName(kav.Id);
			KBLWCHandler.submitForReview(kav.Id, 'submit comments');
			KBLWCHandler.getApprovalProcessName(kav.Id);
		}

		Test.StopTest();
	}

	@isTest
	public static void testOther1(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			Test.startTest();


			KBLWCHandler.getArticle(kav.Id);
			KBLWCHandler.getAllArticles(kav.Id);
			KBLWCHandler.getDraftArticles(kav.Id);
			KBLWCHandler.getRelatedArticles(kav.Id,true); //for external or guest user
			KBLWCHandler.getRelatedArticles(kav.Id,false); // for internal user

		}
	}

	@isTest
	public static void testOther2(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			Test.startTest();



			KBLWCHandler.getArticleForPreview(kav.Id);
			KBLWCHandler.getArticlePendingTR(kav.UrlName,'en_US');
			KBLWCHandler.getArticleByURLName(kav.UrlName,'en_US');
			KBLWCHandler.checkForDraftArticle(kav.KnowledgeArticleId, 'ja');

			KBLWCHandler.getKBFollow(kav.Id, UserInfo.getUserId());
			KBLWCHandler.getKBRelatedrecs(kav.UrlName);
			KBLWCHandler.getkbList();
			KBLWCHandler.getHelpItems();

		}
	}


	@isTest
	public static void testOther3(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			Test.startTest();



			KBLWCHandler.getskills();
			KBLWCHandler.getloggedinprofile();
			KBLWCHandler.getCurrentUsersDetails();
			KBLWCHandler.getloggedusername();
			KBLWCHandler.checkUserExistence(USERNAME_FEDID);
			KBLWCHandler.getKBArticleQualityIndexScore(kav.Id);
			KBLWCHandler.getUrlNameFromArticleNumber(kav.ArticleNumber);
			KBLWCHandler.setArticleGDPRComplianceUpvote(kav.Id,'NONE');
			String strGDPRData = '{"Title":"Test%20Article%20With%20Ip%20Address%20-%20192.168.1.1%20192.168.1.1%2035.166.204.205","Solution":"Test%20Article%20With%20Ip%20Address","Record_Type":"FAQ","Problem_Type":"NONE","Keywords":"NONE","Description":"NONE","Additional_Information":"Test%20Article%20With%20Ip%20Address"}';
			KBLWCHandler.setArticleGDPRComplianceUpvote(kav.Id,strGDPRData);

		}
	}

	@isTest
	public static void testOther4(){
		Knowledge__kav kav = createAndPublishArticleWithoutTRTriggerLess();

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			Test.startTest();


			KBLWCHandler.getApprovalProcessName(kav.Id);
			KBLWCHandler.getCurrentUserDirectApprover(kav.Id);
		}
	}

	@isTest
	public static void test_checkCharAppendBeforeInsertOrUpdate1(){

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test.sh';
		kavRelated.Description__c = 'https://www.google.com';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		kavRelated.Additional_Information__c = 'test.sh';
		kavRelated.Internal_Notes__c = 'test.sh';
		kavRelated.ValidationStatus = 'Pending Content Review';
		insert kavRelated;

		kavRelated.Solution__c = 'https://www.google.com';
		kavRelated.Description__c = 'https://www.google.com';
		kavRelated.Additional_Information__c = 'https://www.google.com';
		kavRelated.Internal_Notes__c = 'https://www.google.com';
		kavRelated.ValidationStatus = 'Pending Technical Review';
		update kavRelated;
	}

	@isTest
	public static void test_checkCharAppendBeforeInsertOrUpdate2(){

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test.sh';
		kavRelated.Description__c = '"https://www.google.com"';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		kavRelated.Additional_Information__c = 'test.sh';
		kavRelated.Internal_Notes__c = 'test.sh';
		kavRelated.ValidationStatus = 'Pending Technical Review';
		insert kavRelated;

		kavRelated.Solution__c = '"https://www.google.com"';
		kavRelated.Description__c = '"https://www.google.com"';
		kavRelated.Additional_Information__c = '"https://www.google.com"';
		kavRelated.Internal_Notes__c = '"https://www.google.com"';
		kavRelated.Technical_Reviewer_Rejected__c = true;
		update kavRelated;
	}

	@isTest
	public static void test_checkCharAppendBeforeInsertOrUpdate3(){

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test.sh';
		kavRelated.Description__c = 'test.sh';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		kavRelated.Additional_Information__c = 'test.sh';
		kavRelated.Internal_Notes__c = 'test.sh';
		kavRelated.ValidationStatus = 'Pending Technical Review';
		insert kavRelated;

		kavRelated.Solution__c = '&lt;https://www.google.com&gt;';
		kavRelated.Description__c = 'test.sh';
		kavRelated.Additional_Information__c = '&lt;https://www.google.com&gt;';
		kavRelated.Internal_Notes__c = '&lt;https://www.google.com&gt;';
		kavRelated.Technical_Reviewer_Rejected__c = true;
		update kavRelated;
	}

	@isTest
	public static void test_checkCharAppendBeforeInsertOrUpdate4(){

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Also_Applies_To__c = 'Axon Data Governance';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test.sh';
		kavRelated.Description__c = '&lt;https://www.google.com&gt;';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		kavRelated.Additional_Information__c = 'test.sh';
		kavRelated.Internal_Notes__c = 'test.sh';
		kavRelated.ValidationStatus = 'Pending Technical Review';
		insert kavRelated;

		kavRelated.Solution__c = '&lt;https://www.google.com&gt;';
		kavRelated.Description__c = '<https://www.google.com>';
		kavRelated.Additional_Information__c = '&lt;https://www.google.com&gt;';
		kavRelated.Internal_Notes__c = '&lt;https://www.google.com&gt;';
		kavRelated.Technical_Reviewer_Rejected__c = true;
		update kavRelated;
	}

	@isTest
	public static void test_validateProduct(){

		Knowledge__kav kavRelated = new Knowledge__kav();
		kavRelated.Title = 'Article Two';
		kavRelated.UrlName = '00000002';
		kavRelated.Primary_Product__c = 'Active VOS';
		kavRelated.Also_Applies_To__c = 'Active VOS';
		kavRelated.Product_Version__c = '9.2.4';
		kavRelated.Product_Component__c = 'ActiveVOS Console';
		kavRelated.Problem_Type__c = 'Connectivity';
		kavRelated.Solution__c = 'test.sh';
		kavRelated.Description__c = 'test.sh';
		kavRelated.Visible_In_Public_Knowledge_Base__c = false;
		kavRelated.Additional_Information__c = 'test.sh';
		kavRelated.Internal_Notes__c = 'test.sh';
		kavRelated.ValidationStatus = 'Pending Technical Review';
		try{
			insert kavRelated;
		}
		Catch(Exception e){
		}
	}

	@isTest
	public static void test_postochatterGroup(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];

		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];

		System.runAs(author){
			Knowledge__kav kavRelated = new Knowledge__kav();
			kavRelated.Title = 'Article Two';
			kavRelated.UrlName = '00000002';
			kavRelated.Primary_Product__c = 'Data Loader';
			//kavRelated.Product_Version__c = 'Preview';
			//kavRelated.Product_Component__c = 'Agent';
			kavRelated.Also_Applies_To__c = 'Axon Data Governance';
			kavRelated.Problem_Type__c = 'Connectivity';
			kavRelated.Solution__c = 'test.sh';
			kavRelated.Description__c = '&lt;https://www.google.com&gt;';
			kavRelated.Visible_In_Public_Knowledge_Base__c = false;
			kavRelated.Additional_Information__c = 'test.sh';
			kavRelated.Internal_Notes__c = 'test.sh';
			kavRelated.ValidationStatus = 'Pending Technical Review';
			insert kavRelated;

			test.startTest();
			KnowledgeTriggerHelper.postToChatterGroup(kavRelated.Primary_Product__c,kavRelated);
			test.stopTest();
		}
	}

	// @isTest
	// public static void testcopyRelatedArticlesReferrenceInKBSecond(){
	// 	try {
	// 		Knowledge__kav kav = createAndPublishWithFilesAndArticleAttached();

	// 		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
	// 		System.runAs(author){
	// 			enableRecursion();
	// 			KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, false);
	// 		}

	// 	}catch(Exception ex) {
	// 		System.debug('exception occurred - '+ex.getMessage());
	// 	}
	// }

	// @isTest
	// public static void testcopyFile(){
	// 	try {

	// 		Knowledge__kav kav = createAndPublishWithFilesAndArticleAttached();

	// 		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
	// 		System.runAs(author){
	// 			enableRecursion();
	// 			String translatedKAVId = KbManagement.PublishingService.submitForTranslation(kav.KnowledgeArticleId, 'de', null, null);
	// 		}

	// 	}catch(Exception ex) {
	// 		System.debug('exception occurred - '+ex.getMessage());
	// 	}
	// }

	@isTest
	public static void testvalidateRelatedArticles(){
		Knowledge__kav kav = createAndPublishWithArchivedArticleAttached();

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		System.runAs(author){
			enableRecursion();
			KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, false);
		}
	}

	@isTest
	static void validateSendToTR(){

		Knowledge__kav kav;
		system.debug('Inside validateTRReject');
		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article One';
			kav.UrlName = '00000001';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;
			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '00000001' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		System.runAs(KBMigUser){

			if(kav != null)
			{
				kav.ValidationStatus = 'Pending Content Review';
				update kav;

				enableRecursion();
				kav.ValidationStatus = 'Pending Technical Review';
				kav.TR_Approval__c = true;
				update kav;
			}
		}
	}


	@isTest
	static void validateRejectByTR(){

		Knowledge__kav kav;
		system.debug('Inside validateTRReject');
		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(author){
			kav = new Knowledge__kav();
			kav.Title = 'Article One';
			kav.UrlName = '00000001';
			kav.Primary_Product__c = 'Active VOS';
			kav.Product_Version__c = '9.2.4';
			kav.Product_Component__c = 'ActiveVOS Console';
			kav.Also_Applies_To__c = 'Axon Data Governance';
			kav.Problem_Type__c = 'Connectivity';
			kav.Solution__c = 'test solution';
			kav.Description__c = 'test description';
			kav.Visible_In_Public_Knowledge_Base__c = true;
			kav.AQI_Score__c=50;
			insert kav;
			kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName = '00000001' AND PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 1];

		}

		System.runAs(KBMigUser){

			if(kav != null)
			{
				kav.ValidationStatus = 'Pending Technical Review';
				update kav;

				enableRecursion();
				kav.Technical_Reviewer_Rejected__c = true;
				kav.ValidationStatus = 'Draft';
				kav.TR_Approval__c = true;
				update kav;
			}
		}
	}


	@isTest
	public static void testvalidateRelatedArticlesNullReference(){
		Knowledge__kav kav = createAndPublishWithNullArticleAttached();

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		System.runAs(author){
			enableRecursion();
			KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, false);
		}
	}


	@isTest
	public static void testDirectApprovalWithTR(){

		User directapprover = [Select Id From User Where username=:KB_DIRECT_APPROVER_USERNAME];
		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		Knowledge__kav kav;
		System.runAs(directapprover){
			kav = createArticle();
		}

		System.runAs(KBMigUser){
			kav.AQI_Score__c = 15;
			kav.TR_Approval__c = true;
			update kav;
		}

		System.runAs(directapprover){			
			submitForReview(kav);
		}

	}

	@isTest
	public static void testDirectApproval(){

		User directapprover = [Select Id From User Where username=:KB_DIRECT_APPROVER_USERNAME];		
		Knowledge__kav kav;
		System.runAs(directapprover){
			kav = createArticle();
			submitForReview(kav);
		}

	}

    /*@isTest
    public static void testArchival1(){
    Knowledge__kav kav = createAndPublishArticleWithoutTR();

    KBLWCHandler.archiveArticle1(kav.Id, 'archival comments', kav.KnowledgeArticleId, false, true, 'en_US', 'Online', true);
    }

    @isTest
    public static void testArchival2(){
    Knowledge__kav kav = createAndPublishArticleWithoutTR();

    KBLWCHandler.archiveArticle1(kav.Id, 'archival comments', kav.KnowledgeArticleId, false, false, 'en_US', 'Online', false);
    }*/

    // @isTest
    // public static void testEditAsDraft(){
    //   Knowledge__kav kav = createAndPublishArticleWithoutTR();

    //   enableRecursion();
    //   KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, false);
    // }
}