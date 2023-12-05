/**
 * @description       :
 * @author            : Sathish Rajalingam
 * @group             :
 * @last modified on  : 26-07-2022
 * @last modified by  : SF Developer
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   26-07-2022   Sathish Rajalingam   Initial Version
 **/
@isTest
public class KBArticleHandlerTest {

	public static final String KB_MIGRATION_USER = 'kbmigrationkbahuser@informatica.com';

	@testSetup
	public static void setupObjectTestData(){

		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBMigUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationkbahuser@informatica.com',
			Alias = 'kbmig',
			Email='kbmigrationkbahuser@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Migration User Test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBMigUser;

		System.runAs(KBMigUser){

			Knowledge__kav kavSecondMocData = new Knowledge__kav();

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

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Three';
			kavMocData.UrlName = '0100004';
			kavMocData.Migrated_Article_Id__c = '0100004';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			kavMocData.IsVisibleInPkb= true;
			kavMocData.Visible_In_Public_Knowledge_Base__c= true;
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Five';
			kavMocData.UrlName = '0100005';
			kavMocData.Migrated_Article_Id__c = '0100005';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			kavMocData.IsVisibleInPkb= true;
			kavMocData.Visible_In_Public_Knowledge_Base__c= true;
			kavMocData.Internal_Notes__c = '<div class="SharepointToSalesforceMigrationCss"><a title="" href="http://webops/GCS/SR_Retrieval.asp?SRNum=1-159969863" target="_blank">SR 1-159969863</a></div>';
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Six';
			kavMocData.UrlName = '0100006';
			kavMocData.Migrated_Article_Id__c = '0100006';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Pending Technical Review';
			kavMocData.Any_additional_details_like_Screenshots__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.Steps_to_configure_the_parameter__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.Solution__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.Internal_Notes__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.Description__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.Additional_Information__c= ' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight';
			kavMocData.IsVisibleInPkb= true;
			kavMocData.Visible_In_Public_Knowledge_Base__c= true;
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Seven';
			kavMocData.UrlName = '0100007';
			kavMocData.Migrated_Article_Id__c = '0100007';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			kavMocData.IsVisibleInPkb= true;
			kavMocData.Visible_In_Public_Knowledge_Base__c= true;
			kavMocData.Internal_Notes__c = '<div class="SharepointToSalesforceMigrationCss"><a title="" href="http://webops/GCS/SR_Retrieval.asp?SRNum=1-159969863" target="_blank">SR 1-159969863</a></div>';
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Eight';
			kavMocData.UrlName = '0100008';
			kavMocData.Migrated_Article_Id__c = '0100008';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			kavMocData.IsVisibleInPkb= true;
			kavMocData.Visible_In_Public_Knowledge_Base__c= true;
			insert kavMocData;

			//create a case record
			sObject sObjOne = new Case();
			sObjOne = UtilityTest.putFieldRecord(sObjOne, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjOne});

			List<Case> cselst = [Select Id From Case Limit 3];


			kavMocData = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100001'];

			KbManagement.PublishingService.publishArticle(kavMocData.KnowledgeArticleId, true);

			kavMocData = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100004'];

			kavSecondMocData = kavMocData;

			KbManagement.PublishingService.publishArticle(kavMocData.KnowledgeArticleId, true);

			kavMocData = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100005'];

			KbManagement.PublishingService.publishArticle(kavMocData.KnowledgeArticleId, true);

			Case_KB__c caseKBRec = new Case_KB__c();
			caseKBRec.Case__c = sObjOne.Id;
			caseKBRec.Knowledge__c = kavMocData.Id;
			caseKBRec.Type__c = 'Updated Existing';
			caseKBRec.Name = 'KB'+String.valueOf(kavMocData.Id)+'Case';
			caseKBRec.ArticleNumber__c = String.valueOf(kavMocData.ArticleNumber);
			insert caseKBRec;

			Related_KB__c relatedKB = new Related_KB__c();
			relatedKB.Referred_Article__c = kavMocData.Id;
			relatedKB.Referred_In__c = kavSecondMocData.Id;
			insert relatedKB;

			kavMocData = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100007'];

			KbManagement.PublishingService.publishArticle(kavMocData.KnowledgeArticleId, true);

			relatedKB = new Related_KB__c();
			relatedKB.Referred_Article__c = kavMocData.Id;
			relatedKB.Referred_In__c = kavSecondMocData.Id;
			insert relatedKB;

		}

	}

	@isTest
	public static void testgetArticleAllLanguages(){
		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			Knowledge__kav kavMocData = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100001' And PublishStatus='Online'];
			Knowledge__kav kavCRFeedBack = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100004' And PublishStatus='Online'];
			KbManagement.PublishingService.submitForTranslation (kavMocData.KnowledgeArticleId,'ja',null,null);
			Knowledge__kav kavMocDataJapanese = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100001' And PublishStatus='Draft' And Language = 'ja'];
			Knowledge__kav kavMocDataForArchival  = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100005'];
			Knowledge__kav kavMocDataForProcessImageTag = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate,Any_additional_details_like_Screenshots__c, Steps_to_configure_the_parameter__c, Solution__c, Internal_Notes__c, Description__c,Additional_Information__c From Knowledge__kav Where UrlName = '0100006'];
			Knowledge__kav kavMocDataForRemoveRelatedKB  = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100007'];
			Related_KB__c relkbMocDataForRemoveRelatedKB  =  [SELECT Id,Referred_Article__c,Referred_In__c,Referred_ArticleNumber__c,OwnerId FROM Related_KB__c WHERE Referred_Article__c =: kavMocDataForRemoveRelatedKB.Id];
			Knowledge__kav kavMocDataForMasterArticlePublish  = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100008'];
			List<Id> Ids = new List<Id>();
			Ids.add(kavMocDataForMasterArticlePublish.Id);

			KbManagement.PublishingService.completeTranslation(kavMocDataJapanese.Id);
			KBArticleHandler.getArticleAllLanguages(kavMocData.Id);
			KBArticleHandler.getDirectPublishedArticles();
			KBArticleHandler.isUserCRFeedbackSubmitter(kavMocData.Id);
			KBArticleHandler.sendAlertOnCRFeedbackWrapper(kavCRFeedBack.Id,'test feedback');
			KBArticleHandler.sendAlertOnArchivalWrapper(kavCRFeedBack.Id,'test archival');
			KBArticleHandler.getRelatedKBandCase(kavMocDataForArchival.Id);
			KBArticleHandler.setProcessedVersionKBImageTag(kavMocDataForProcessImageTag.Id);
			List<Knowledge__kav> kavMocDataForProcessImageTagList =  new List<Knowledge__kav>();
			kavMocDataForProcessImageTagList.add(kavMocDataForProcessImageTag);
			KBArticleHandler.getProcessedVersionKBImageTag(kavMocDataForProcessImageTagList);
			KBArticleHandler.removeRelatedArticlesFromKB(relkbMocDataForRemoveRelatedKB.Id);
			KBArticleHandler.removeRelatedArticlesFromKB(relkbMocDataForRemoveRelatedKB.Id);
			KBArticleHandler.removeRelatedArticlesFromKB(relkbMocDataForRemoveRelatedKB.Id+'w');
			KBArticleHandler.getProductsTopic('PowerCenter');
			
			KBArticleHandler.sendAlertOnMasterArticlePublishWrapper(Ids);
		}


	}

	public static void testsendAlertOnMasterArticlePublishWrapper(){
		User KBMigUser = [Select Id From User Where username=:KB_MIGRATION_USER];
		System.runAs(KBMigUser){
			
			Knowledge__kav kavMocDataForMasterArticlePublish  = [Select Id, Title, ArticleNumber, UrlName, ValidationStatus, PublishStatus, KnowledgeArticleId, CreatedDate From Knowledge__kav Where UrlName = '0100008'];
			List<Id> Ids = new List<Id>();
			Ids.add(kavMocDataForMasterArticlePublish.Id);						
			KBArticleHandler.sendAlertOnMasterArticlePublishWrapper(Ids);
		}


	}

}