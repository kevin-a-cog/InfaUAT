/**
 * @description       :
 * @author            : Sathish Rajalingam
 * @group             :
 * @last modified on  : 05-14-2021
 * @last modified by  : Sathish Rajalingam
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   02-08-2021   Sathish Rajalingam   Initial Version

 ****************************************************************************************************
 |  Tag    |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |   1     |  28-Jan-2021      |   Sathish R               |    I2RT-862       |   Added changes related to Notify Author
 ****************************************************************************************************


 **/
@isTest
public class KnowledgeUpdateBatchTest {
	// Test data related method and initialization - Start

	public static final String PROFILE_NAME_EMP_RESTRICTED = 'Employee';

	public static final String KB_AUTHOR_USERNAME = 'oneauthor@infa.com.kbtest';
	public static final String KB_USERNAME_WITH_FEDID = 'oneuserwithfedid@infa.com.kbtest';
	public static final String KB_CONTENT_REVIEWER_USERNAME = 'onecr@infa.com.kbtest';

	public static final String SKILL_NAME_AUTHOR = 'KB_AUTHOR_CONTRIBUTOR';
	public static final String SKILL_NAME_CONTENT_REVIEWER = 'KB_CONTENT_REVIEWER';
	public static final String SKILL_NAME_ACTIVE_VOS = 'KB_TECH_ACTIVEVOS';
	public static final String USERNAME_FEDID = 'withfd1';

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

	@testSetup
	static void setupObjectTestData() {
		//Data for Batch Job - Start

		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBTestUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbtestclassuser@informatica.com',
			Alias = 'kbmig',
			Email='kbtestclassuser@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Test Class User',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBTestUser;

		System.runAs(KBTestUser){


			Integer noOfDays =  Integer.valueOf(Label.KB_Archive_Expired_Article_in_Days)+5;
			Knowledge__kav knwRec = new Knowledge__kav();
			knwRec.Title = 'Article One';
			knwRec.UrlName = '00000001';
			knwRec.Expiration_Date__c = system.today().addDays(-noOfDays);
			knwRec.Primary_Product__c = 'Active VOS';
			knwRec.Product_Version__c = '9.2.4';
			knwRec.Product_Component__c = 'ActiveVOS Console';
			knwRec.LastModifiedDate = System.now();
			knwRec.Visible_In_Public_Knowledge_Base__c = true;



			Datetime OldDate = Datetime.now().addDays(-47);
			Knowledge__kav knwRecTwo = new Knowledge__kav();
			knwRecTwo.Title = 'Article Two';
			knwRecTwo.UrlName = '00000002';
			knwRecTwo.Primary_Product__c = 'Active VOS';
			knwRecTwo.Product_Version__c = '9.2.4';
			knwRecTwo.Product_Component__c = 'ActiveVOS Console';
			knwRecTwo.Visible_In_Public_Knowledge_Base__c = true;
			knwRecTwo.CreatedDate = OldDate;
			knwRecTwo.LastModifiedDate = OldDate;


			Knowledge__kav knwRecThree = new Knowledge__kav();
			knwRecThree.Title = 'Article Three';
			knwRecThree.UrlName = '00000003';
			knwRecThree.Expiration_Date__c = system.today().addDays(-noOfDays);
			knwRecThree.Primary_Product__c = 'Active VOS';
			knwRecThree.Product_Version__c = '9.2.4';
			knwRecThree.Product_Component__c = 'ActiveVOS Console';
			knwRecThree.LastModifiedDate = System.now();
			knwRecThree.Visible_In_Public_Knowledge_Base__c = true;

			List<Knowledge__kav> kbRecList = new List<Knowledge__kav>();
			kbRecList.add(knwRec);
			kbRecList.add(knwRecTwo);
			kbRecList.add(knwRecThree);

			insert kbRecList;


			System.debug('initializeData : knwRecTwo.LastModifiedDate ' + knwRecTwo.LastModifiedDate.format());
		}

		//Data for Batch Job - End
		setupCustomSettings();
		setupSkills();
		Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);
		system.runAs(userByRole.get('Admin')){
			createAuthor();
			createContentReviewer();
			createUserWithFedId();

			User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
			User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];

			List<ProfileSkillUser> lstSkillUser = new List<ProfileSkillUser>();
			lstSkillUser.add(assignSkill(author.Id, SKILL_NAME_AUTHOR));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_CONTENT_REVIEWER));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_ACTIVE_VOS));
			lstSkillUser.add(assignSkill(contentReviewer.Id, SKILL_NAME_AUTHOR));
			insert lstSkillUser;
		}
	}

	public static Knowledge__kav createArticleForCR(){



		Knowledge__kav knwRecTwo = new Knowledge__kav();
		knwRecTwo.Title = 'Article Twenty Two';
		knwRecTwo.UrlName = '00000022';
		knwRecTwo.Primary_Product__c = 'Active VOS';
		knwRecTwo.Product_Version__c = '9.2.4';
		knwRecTwo.Product_Component__c = 'ActiveVOS Console';
		knwRecTwo.Also_Applies_To__c = 'Axon Data Governance';
		knwRecTwo.Problem_Type__c = 'Connectivity';
		knwRecTwo.Solution__c = 'test solution';
		knwRecTwo.Description__c = 'test description';
		knwRecTwo.Visible_In_Public_Knowledge_Base__c = true;
		knwRecTwo.AQI_Score__c=50;
		knwRecTwo.Created_By__c =  UserInfo.getUserId();
		knwRecTwo.Original_Author__c =  UserInfo.getUserId();
		insert knwRecTwo;

		return knwRecTwo;
	}


	public static Knowledge__kav createArticleForTR(){

		Knowledge__kav knwRecTwo = new Knowledge__kav();
		knwRecTwo.Title = 'Article Twenty Two';
		knwRecTwo.UrlName = '00000022';
		knwRecTwo.Primary_Product__c = 'Active VOS';
		knwRecTwo.Product_Version__c = '9.2.4';
		knwRecTwo.Product_Component__c = 'ActiveVOS Console';
		knwRecTwo.Also_Applies_To__c = 'Axon Data Governance';
		knwRecTwo.Problem_Type__c = 'Connectivity';
		knwRecTwo.Solution__c = 'test solution';
		knwRecTwo.Description__c = 'test description';
		knwRecTwo.Visible_In_Public_Knowledge_Base__c = true;
		knwRecTwo.AQI_Score__c=50;
		knwRecTwo.Created_By__c =  UserInfo.getUserId();
		knwRecTwo.Original_Author__c =  UserInfo.getUserId();
		insert knwRecTwo;

		return knwRecTwo;
	}


	public static void submitForReview(Knowledge__kav kav){
		enableRecursion();
		KBLWCHandler.getApprovalProcessName(kav.Id);
		KBLWCHandler.submitForReview(kav.Id, 'submit comments');
	}


	public static Knowledge__kav createAndCRRejectArticle(){

		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		User SysAdmin = [Select Id From User Where username='kbtestclassuser@informatica.com'];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticleForCR();
			submitForReview(kav);
		}

		System.runAs(SysAdmin){
			ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('content rejected!');
			req.setAction('Reject');
			req.setWorkitemId(workItem.Id);
			enableRecursion();
			Approval.process(req);
		}
		

            kav = [Select Id,ArticleNumber,Original_Author__c,LastModifiedById,Created_By__c,Rejected_By_Content_Reviewer__c,Rejected_By_Technical_Reviewer__c,Primary_Product__c,Product_Version__c,Product_Component__c,Title,LastModifiedDate from Knowledge__kav Where Id = :kav.Id];
            
            
		return kav;
	}

      public static Knowledge__kav createAndTRRejectArticle(){
		User author = [Select Id From User Where username=:KB_AUTHOR_USERNAME];
		User contentReviewer = [Select Id From User Where username=:KB_CONTENT_REVIEWER_USERNAME];
		Knowledge__kav kav;
		System.runAs(author){
			kav = createArticleForTR();
			submitForReview(kav);
		}		
		
            ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kav.id];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('content rejected!');
		req.setAction('Reject');
		req.setWorkitemId(workItem.Id);
		enableRecursion();
		Approval.process(req);

            kav = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate, TR_Approval__c, AQI_Score__c From Knowledge__kav Where Id = :kav.Id];

		return kav;
	}

      // Test data related method and initialization - End
      
      @isTest
      static void knowledgeUpdateBatchArchiveTest1(){
            
            Knowledge__kav knwRec = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,UrlName,Title from Knowledge__kav WHERE UrlName='00000001'];
            KbManagement.PublishingService.publishArticle(knwRec.KnowledgeArticleId, true);
            Knowledge__kav knwRecPublished = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title
            from Knowledge__kav where Id=:knwRec.Id];
            String publishStatusBefore =  knwRecPublished.PublishStatus;
            
            Test.startTest();
            KnowledgeUpdateBatch archiveBatch = new KnowledgeUpdateBatch('ARCHIVE');
            Database.executeBatch(archiveBatch);
            Test.stopTest();
            
            Knowledge__kav knwRecArchived = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title,LastModifiedDate
            from Knowledge__kav where Id=:knwRec.Id];
            String publishStatusAfter = knwRecArchived.PublishStatus;
            
            System.debug('knowledgeUpdateBatchArchiveTest1 : Title - ' + knwRecArchived.Title);
            System.debug('knowledgeUpdateBatchArchiveTest1 : LastModifiedDate - ' + knwRecArchived.LastModifiedDate.format());
            
            system.assertEquals('Online', publishStatusBefore);
            system.assertEquals('Archived', publishStatusAfter);
            
            system.debug('value of knwRec'+knwRecArchived);
            
      }
      
      @isTest
      static void knowledgeUpdateBatchArchiveTest2(){
            
            
            Knowledge__kav knwRec = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,UrlName,Title from Knowledge__kav WHERE UrlName='00000001'];
            KbManagement.PublishingService.publishArticle(knwRec.KnowledgeArticleId, true);
            Knowledge__kav knwRecPublished = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title
            from Knowledge__kav where Id=:knwRec.Id];
            
            String publishStatusBefore =  knwRecPublished.PublishStatus;
            
            Test.startTest();
            KnowledgeUpdateBatch archiveBatch = new KnowledgeUpdateBatch();
            Database.executeBatch(archiveBatch);
            Test.stopTest();
            
            Knowledge__kav knwRecArchived = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title,LastModifiedDate
            from Knowledge__kav where Id=:knwRec.Id];
            String publishStatusAfter = knwRecArchived.PublishStatus;
            
            System.debug('knowledgeUpdateBatchArchiveTest2 : Title - ' + knwRecArchived.Title);
            System.debug('knowledgeUpdateBatchArchiveTest2 : LastModifiedDate - ' + knwRecArchived.LastModifiedDate.format());
            
            system.assertEquals('Online', publishStatusBefore);
            system.assertEquals('Archived', publishStatusAfter);
            
      }
      
      @isTest
      static void knowledgeUpdateBatchArchiveExceptionTest(){
            
            
            Knowledge__kav knwRec = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,UrlName,Title from Knowledge__kav WHERE UrlName='00000001'];
            
            Knowledge__kav knwRecPublished = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title
            from Knowledge__kav where Id=:knwRec.Id];
            
            String publishStatusBefore =  knwRecPublished.PublishStatus;
            
            Test.startTest();
            KnowledgeUpdateBatch archiveBatch = new KnowledgeUpdateBatch();
            Database.executeBatch(archiveBatch);
            Test.stopTest();
            
            Knowledge__kav knwRecArchived = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,Title,LastModifiedDate
            from Knowledge__kav where Id=:knwRec.Id];
            String publishStatusAfter = knwRecArchived.PublishStatus;
            
            System.debug('knowledgeUpdateBatchArchiveExceptionTest : Title - ' + knwRecArchived.Title);
            System.debug('knowledgeUpdateBatchArchiveExceptionTest : LastModifiedDate - ' + knwRecArchived.LastModifiedDate.format());
            
            system.assertEquals('Draft', publishStatusBefore);
            system.assertEquals('Draft', publishStatusAfter);
            
      }
      
      @isTest
      static void knowledgeUpdateBatchDeleteTest(){
            
            
            Knowledge__kav knwRec = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,UrlName,Title,LastModifiedDate from Knowledge__kav WHERE UrlName='00000002'];
            
            System.debug('knowledgeUpdateBatchDeleteTest : Title - ' + knwRec.Title);
            System.debug('knowledgeUpdateBatchDeleteTest : LastModifiedDate - ' + knwRec.LastModifiedDate.format());
            
            Test.startTest();
            
            KnowledgeUpdateBatch deleteBatch = new KnowledgeUpdateBatch('DELETE');
            Database.executeBatch(deleteBatch);
            
            KnowledgeUpdateBatch deleteTestBatch = new KnowledgeUpdateBatch('TEST DELETE');
            Database.executeBatch(deleteTestBatch);
            
            Test.stopTest();
            
      }
      
      @isTest
      static void knowledgeUpdateBatchNotifyTest(){
            
            
            
            Knowledge__kav knwRec = [Select Id,PublishStatus,KnowledgeArticleId,CreatedDate,ValidationStatus,Expiration_Date__c,UrlName,Title,LastModifiedDate from Knowledge__kav WHERE UrlName='00000001'];
            
            System.debug('knowledgeUpdateBatchNotifyTest : Title - ' + knwRec.Title);
            System.debug('knowledgeUpdateBatchNotifyTest : LastModifiedDate - ' + knwRec.LastModifiedDate.format());
            
            Test.startTest();
            
            KnowledgeUpdateBatch notifyBatch = new KnowledgeUpdateBatch('NOTIFY AUTHORS');
            Database.executeBatch(notifyBatch);
            
            notifyBatch = new KnowledgeUpdateBatch('TEST NOTIFY AUTHORS');
            Database.executeBatch(notifyBatch);
            
            Test.stopTest();
            
      }

      @isTest
      static void sendEmailChatterNotificationContentOnRejectionTest(){
                        
            List<Knowledge__kav> scope = [Select Id,ArticleNumber,Original_Author__c,LastModifiedById,Created_By__c,Primary_Product__c,Product_Version__c,Product_Component__c,Title,LastModifiedDate from Knowledge__kav];

            Knowledge__kav knwRec = createArticleForCR();
		                      
            Test.startTest();
                     
            KBNotifyAuthor.sendNotificationContentOnRejection(knwRec,'Content Reviewer');
            KBNotifyAuthor.sendChatterPostOnRejection(knwRec,'Content Reviewer');
            KBNotifyAuthor.sendEmailAlertContentOnRejection(knwRec,'Content Reviewer');

            KBNotifyAuthor.sendNotificationContentOnRejection(knwRec,'Technical Reviewer');
            KBNotifyAuthor.sendChatterPostOnRejection(knwRec,'Technical Reviewer');
            KBNotifyAuthor.sendEmailAlertContentOnRejection(knwRec,'Technical Reviewer');
                        
            Test.stopTest();
            
      }      
      
      
}