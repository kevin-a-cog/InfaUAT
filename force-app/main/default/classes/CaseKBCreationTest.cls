/**
 * @description       :
 * @author            : Sathish Rajalingam
 * @group             :
 * @last modified on  : 10-01-2021
 * @last modified by  : SF Developer
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   05-16-2021   Sathish Rajalingam   Initial Version
 **/
@isTest
public class CaseKBCreationTest {


	@testSetup
	static void setupObjectTestData() {


		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBMigUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationuser12@informatica.com',
			Alias = 'kbmig',
			Email='kbmigrationuser@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Migration User',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBMigUser;

		System.runAs(KBMigUser){


			Knowledge__kav kavFirstMocData = new Knowledge__kav();
			kavFirstMocData.Title = 'Test Article';
			kavFirstMocData.UrlName = '0100000';
			kavFirstMocData.Migrated_Article_Id__c = '0100000';
			kavFirstMocData.Primary_Product__c = 'PowerCenter';
			kavFirstMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavFirstMocData;
			String strUrlName = '0100000';

			kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];


			Knowledge__kav kavSecondMocData = new Knowledge__kav();
			kavSecondMocData.Title = 'Test Article Two';
			kavSecondMocData.UrlName = '0200000';
			kavSecondMocData.Migrated_Article_Id__c = '0200000';
			kavSecondMocData.Primary_Product__c = 'PowerCenter';
			kavSecondMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavSecondMocData;
			strUrlName = '0200000';

			kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

			Knowledge__kav kavThirdMocData = new Knowledge__kav();
			kavThirdMocData.Title = 'Test Article Three';
			kavThirdMocData.UrlName = '0300000';
			kavThirdMocData.Migrated_Article_Id__c = '0300000';
			kavThirdMocData.Primary_Product__c = 'PowerCenter';
			kavThirdMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavThirdMocData;
			strUrlName = '0300000';

			kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

			Knowledge__kav kavFourMocData = new Knowledge__kav();
			kavFourMocData.Title = 'Test Article Four';
			kavFourMocData.UrlName = '0400000';
			kavFourMocData.Migrated_Article_Id__c = '0400000';
			kavFourMocData.Primary_Product__c = 'PowerCenter';
			kavFourMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavFourMocData;
			strUrlName = '0400000';

			kavFourMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

			//create a case record
			sObject sObjOne = new Case();
			sObjOne = UtilityTest.putFieldRecord(sObjOne, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjOne});

			sObject sObjTwo = new Case();
			sObjTwo = UtilityTest.putFieldRecord(sObjTwo, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjTwo});

			sObject sObjThree = new Case();
			sObjThree = UtilityTest.putFieldRecord(sObjThree, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjThree});

			sObject sObjFour = new Case();
			sObjFour = UtilityTest.putFieldRecord(sObjFour, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjFour});

			sObject sObjFive = new Case();
			sObjFive = UtilityTest.putFieldRecord(sObjFive, UtilityTestData.mCase);
			UtilityTest.makeInsert(new List<sObject> {sObjFive});



			CoveoV2__CoveoCaseAttachedResult__c coveoAttachSecondMocData = new CoveoV2__CoveoCaseAttachedResult__c();
			coveoAttachSecondMocData.CoveoV2__Title__c = kavSecondMocData.Title;
			coveoAttachSecondMocData.CoveoV2__UriHash__c = 'NoTl3WZwQLHiDjFð';
			coveoAttachSecondMocData.CoveoV2__ResultUrl__c = 'https://uat-infa.cs198.force.com/customersupport/s/article/0200000?language=en_US';
			coveoAttachSecondMocData.CoveoV2__case__c = sObjOne.Id;
			coveoAttachSecondMocData.CoveoV2__Source__c = 'Salesforce - KB';
			insert coveoAttachSecondMocData;

			CoveoV2__CoveoCaseAttachedResult__c coveoAttachThirdMocData = new CoveoV2__CoveoCaseAttachedResult__c();
			coveoAttachThirdMocData.CoveoV2__Title__c = kavThirdMocData.Title;
			coveoAttachThirdMocData.CoveoV2__UriHash__c = 'V9uWDvbuePuxyXRw';
			coveoAttachThirdMocData.CoveoV2__ResultUrl__c = 'https://uat-infa.cs198.force.com/customersupport/s/articlepreview?c__number=0300000&language=en_US';
			coveoAttachThirdMocData.CoveoV2__case__c = sObjOne.Id;
			coveoAttachThirdMocData.CoveoV2__Source__c = 'Salesforce - KB';
			insert coveoAttachThirdMocData;

			CoveoV2__CoveoCaseAttachedResult__c coveoAttachFourMocData = new CoveoV2__CoveoCaseAttachedResult__c();
			coveoAttachFourMocData.CoveoV2__Title__c = kavFourMocData.Title;
			coveoAttachFourMocData.CoveoV2__UriHash__c = 'V9uWDvbuePuxyXRer';
			coveoAttachFourMocData.CoveoV2__ResultUrl__c = 'https://uat-infa.cs198.force.com/customersupport/s/articlepreview?c__number=0400000&language=en_US';
			coveoAttachFourMocData.CoveoV2__case__c = sObjOne.Id;
			coveoAttachFourMocData.CoveoV2__Source__c = 'Salesforce - KB';
			insert coveoAttachFourMocData;

			List<Case> cselst = [Select Id From Case Limit 3];

			Case_KB__c caseKBRec = new Case_KB__c();
			caseKBRec.Case__c = cselst[1].Id;
			caseKBRec.Knowledge__c = kavFirstMocData.Id;
			caseKBRec.Type__c = 'Updated Existing';
			caseKBRec.Name = 'KB'+String.valueOf(kavFirstMocData.Id)+'Case';
			caseKBRec.ArticleNumber__c = String.valueOf(kavFirstMocData.ArticleNumber);
			insert caseKBRec;

			caseKBRec = new Case_KB__c();
			caseKBRec.Case__c = cselst[0].Id;
			caseKBRec.Knowledge__c = kavFourMocData.Id;
			caseKBRec.Type__c = 'Updated Existing';
			caseKBRec.Name = 'KB'+String.valueOf(kavFourMocData.Id)+'Case';
			caseKBRec.ArticleNumber__c = String.valueOf(kavFourMocData.ArticleNumber);
			insert caseKBRec;


		}
	}

	@isTest
	public static void TestgetCaseKB(){

		Test.startTest();

		User KBMigUser = [Select Id From User Where username='kbmigrationuser12@informatica.com'];

		List<Case> cselst = [Select Id From Case Limit 4];
		String strUrlName = '0100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0300000';
		Knowledge__kav kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		cselst[0].Subject = 'Subject One';
		cselst[0].Description = 'Description One';
		cselst[0].Forecast_Product__c = 'PowerCenter';
		cselst[0].Version__c = '10.1';
		cselst[0].Problem_Type__c = 'Accelerator';
		cselst[0].Component__c =  'PC Service';
		cselst[0].KB_Keyword__c = 'Keyword One';
		cselst[0].KB_Action__c = 'Create New';
		cselst[0].KB_Template__c = 'Solution';
		update cselst[0];
		
				
		cselst[1].Subject = 'Subject Two';
		cselst[1].Description = 'Description Two';
		cselst[1].Forecast_Product__c = 'PowerCenter';
		cselst[0].Version__c = '10.1';
		cselst[1].Problem_Type__c = 'Accelerator';
		cselst[0].Component__c =  'PC Service';
		cselst[1].KB_Keyword__c = 'Keyword Two';
		cselst[1].KB_Action__c = 'Create New';
		cselst[1].KB_Template__c = 'FAQ';
		update cselst[1];

		cselst[2].Subject = 'Subject Three';
		cselst[2].Description = 'Description Three';
		cselst[2].Forecast_Product__c = 'PowerCenter';
		cselst[2].Version__c = '6.0';	
		cselst[2].Problem_Type__c = 'Accelerator';
		cselst[2].Component__c = 'Axon - Rest API';
		cselst[2].KB_Keyword__c = 'Keyword Three';
		cselst[2].KB_Action__c = 'Create New';
		cselst[2].KB_Template__c = 'FAQ';
		update cselst[2];

		cselst[3].Subject = 'Subject Four';
		cselst[3].Description = 'Description Four';
		cselst[3].Forecast_Product__c = 'PowerCenter';
		cselst[3].Version__c = '6.0';	
		cselst[3].Problem_Type__c = 'Accelerator';
		cselst[3].Component__c = 'Axon - Rest API';
		cselst[3].KB_Keyword__c = 'Keyword Four';
		cselst[3].KB_Action__c = 'Create New';
		cselst[3].KB_Template__c = 'FAQ';
		update cselst[3];

		sObject sObjOne = new Case();
		sObjOne =  cselst[0];

		sObject sObjTwo = new Case();
		sObjTwo =  cselst[1];

		sObject sObjThree = new Case();
		sObjThree =  cselst[2];

		sObject sObjFour = new Case();
		sObjFour =  cselst[3];

		Id caseKBRecKnowledgeId = kavFirstMocData.Id;

		Case_KB__c caseKBRec = [SELECT Id, Case__c,Knowledge__c,Type__c,Name,ArticleNumber__c from Case_KB__c where Knowledge__c =:caseKBRecKnowledgeId];

		System.runAs(KBMigUser){
			CaseKBCreation.processKnowledgeBaseArticle(cselst[0].Id,'Keyword','Solution','Create New','');

			CaseKBCreation.processKnowledgeBaseArticle(cselst[1].Id,'Keyword','Solution','Use Existing',kavFirstMocData.Id);

			CaseKBCreation.processKnowledgeBaseArticle(cselst[0].Id,'Keyword','FAQ','Create New','');

			CaseKBCreation.processKnowledgeBaseArticle(cselst[2].Id,'Keyword','FAQ','Create New','');

			CaseKBCreation.processKnowledgeBaseArticle(cselst[3].Id,'Keyword','FAQ','Create New','');

		}



		Test.StopTest();

	}

	@isTest
	public static void TestgetCaseKBTwo(){

		Test.startTest();

		User KBMigUser = [Select Id From User Where username='kbmigrationuser12@informatica.com'];

		List<Case> cselst = [Select Id From Case Limit 4];
		String strUrlName = '0100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0300000';
		Knowledge__kav kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		sObject sObjOne = new Case();
		sObjOne =  cselst[0];

		sObject sObjTwo = new Case();
		sObjTwo =  cselst[1];

		sObject sObjThree = new Case();
		sObjThree =  cselst[2];

		sObject sObjFour = new Case();
		sObjFour =  cselst[3];

		Id caseKBRecKnowledgeId = kavFirstMocData.Id;

		Case_KB__c caseKBRec = [SELECT Id, Case__c,Knowledge__c,Type__c,Name,ArticleNumber__c from Case_KB__c where Knowledge__c =:caseKBRecKnowledgeId];
		System.runAs(KBMigUser){
			CaseKBCreation.processKnowledgeBaseArticle(cselst[1].Id,'Keyword','FAQ','Use Existing',kavFirstMocData.Id);

			CaseKBCreation.processKnowledgeBaseArticle(cselst[2].Id,'Keyword','FAQ','Updated Existing',kavFirstMocData.Id);

			CaseKBCreation.processKnowledgeBaseArticle(cselst[2].Id,'Keyword','FAQ','Updated Existing',kavSecondMocData.Id);

			CaseKBCreation.processKnowledgeBaseArticle(cselst[2].Id,'','','NA',null);

		}


		Test.StopTest();

	}


	@isTest
	public static void TestgetCaseKBThree(){

		Test.startTest();

		User KBMigUser = [Select Id From User Where username='kbmigrationuser12@informatica.com'];

		List<Case> cselst = [Select Id From Case Limit 5];
		String strUrlName = '0100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '0300000';
		Knowledge__kav kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		sObject sObjOne = new Case();
		sObjOne =  cselst[0];

		sObject sObjTwo = new Case();
		sObjTwo =  cselst[1];

		sObject sObjThree = new Case();
		sObjThree =  cselst[2];

		sObject sObjFour = new Case();
		sObjFour =  cselst[3];

		sObject sObjFive = new Case();
		sObjFive =  cselst[4];

		Id caseKBRecKnowledgeId = kavFirstMocData.Id;

		Case_KB__c caseKBRec = [SELECT Id, Case__c,Knowledge__c,Type__c,Name,ArticleNumber__c from Case_KB__c where Knowledge__c =:caseKBRecKnowledgeId];



		System.runAs(KBMigUser){

			CaseKBCreation.getCaseToKB(cselst[0].Id);

			CaseKBCreation.processCaseKB(sObjFour.Id, kavThirdMocData.Id, kavThirdMocData.ArticleNumber, 'Create New');

			CaseKBCreation.updateKBToCase(caseKBRec.Id,kavThirdMocData.Id);

			CaseKBCreation.processCaseKB(sObjFour.Id, kavThirdMocData.Id, kavThirdMocData.ArticleNumber, 'Updated Existing');

			CaseKBCreation.processCaseKB(sObjFive.Id, kavThirdMocData.Id, kavThirdMocData.ArticleNumber, '');

			CaseKBCreation.getKBToCase(kavThirdMocData.Id,kavThirdMocData.KnowledgeArticleId,kavThirdMocData.ArticleNumber);


		}

		Test.StopTest();

	}

}