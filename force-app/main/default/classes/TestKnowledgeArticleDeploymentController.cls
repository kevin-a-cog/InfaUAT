/**
 * @description       :
 * @author            : Sathish Rajalingam
 * @group             :
 * @last modified on  : 03-06-2021
 * @last modified by  : Sathish Rajalingam
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   10-04-2020   Sathish Rajalingam   Initial Version
 **/

/**
   @Jira : KB-130
   Change History
 *********************************************************************************************************************************************
   ModifiedBy                  Date          JIRA No.                         Description                                Tag
 *********************************************************************************************************************************************

 */
@isTest
private class TestKnowledgeArticleDeploymentController {


	@testSetup static void setupObjectTestData() {


		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBMigUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationuser@informatica.com',
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
			kavFirstMocData.UrlName = '1100000';
			kavFirstMocData.Migrated_Article_Id__c = '1100000';
			kavFirstMocData.Primary_Product__c = 'PowerCenter';
			kavFirstMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavFirstMocData;
			String strUrlName = '1100000';

			kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];


			Knowledge__kav kavSecondMocData = new Knowledge__kav();
			kavSecondMocData.Title = 'Test Article Two';
			kavSecondMocData.UrlName = '2200000';
			kavSecondMocData.Migrated_Article_Id__c = '2200000';
			kavSecondMocData.Primary_Product__c = 'PowerCenter';
			kavSecondMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavSecondMocData;
			strUrlName = '2200000';

			kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

			Knowledge__kav kavThirdMocData = new Knowledge__kav();
			kavThirdMocData.Title = 'Test Article Three';
			kavThirdMocData.UrlName = '3300000';
			kavThirdMocData.Migrated_Article_Id__c = '3300000';
			kavThirdMocData.Primary_Product__c = 'PowerCenter';
			kavThirdMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavThirdMocData;
			strUrlName = '3300000';

			kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

			Knowledge__kav kavFourMocData = new Knowledge__kav();
			kavFourMocData.Title = 'Test Article Four';
			kavFourMocData.UrlName = '4400000';
			kavFourMocData.Migrated_Article_Id__c = '4400000';
			kavFourMocData.Primary_Product__c = 'PowerCenter';
			kavFourMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavFourMocData;
			strUrlName = '4400000';

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





			CoveoV2__CoveoCaseAttachedResult__c coveoAttachSecondMocData = new CoveoV2__CoveoCaseAttachedResult__c();
			coveoAttachSecondMocData.CoveoV2__Title__c = kavSecondMocData.Title;
			coveoAttachSecondMocData.CoveoV2__UriHash__c = 'NoTl3WZwQLHiDjFð';
			coveoAttachSecondMocData.CoveoV2__ResultUrl__c = 'https://uat-infa.cs198.force.com/customersupport/s/article/0200000?language=en_US';
			coveoAttachSecondMocData.CoveoV2__case__c = sObjOne.Id;
			coveoAttachSecondMocData.CoveoV2__Source__c = 'Salesforce - KB';
			insert coveoAttachSecondMocData;

			CoveoV2__CoveoCaseAttachedResult__c coveoAttachThirdMocData = new CoveoV2__CoveoCaseAttachedResult__c();
			coveoAttachThirdMocData.CoveoV2__Title__c = kavThirdMocData.Title;
			coveoAttachThirdMocData.CoveoV2__UriHash__c = 'V9uWDvbuePuxyXRw...';
			coveoAttachThirdMocData.CoveoV2__ResultUrl__c = 'https://uat-infa.cs198.force.com/customersupport/s/articlepreview/?c__number=0300000&language=en_US';
			coveoAttachThirdMocData.CoveoV2__case__c = sObjOne.Id;
			coveoAttachThirdMocData.CoveoV2__Source__c = 'Salesforce - KB';
			insert coveoAttachThirdMocData;

			List<Case> cselst = [Select Id From Case Limit 3];

		}
	}


	@isTest static void TestpublishAllDraftArticleByDML(){

		Test.startTest();

		string strCount = '1';
		string strResponse = KnowledgeArticleDeploymentController.publishAllDraftArticleByDML(strCount);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){


			strResponse = KnowledgeArticleDeploymentController.publishAllDraftArticleByDML(strCount);

			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavMocData;

			strResponse = KnowledgeArticleDeploymentController.publishAllDraftArticleByDML(strCount);

			strResponse = KnowledgeArticleDeploymentController.publishAllDraftArticleByDML('strCount');
		}

		Test.StopTest();

	}



	@isTest static void TestpublishArchiveDeleteAllApprovedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		string strResponse = KnowledgeArticleDeploymentController.publishAllApprovedArticleByDML(strCount);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){


			strResponse = KnowledgeArticleDeploymentController.publishAllApprovedArticleByDML(strCount);


			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			insert kavMocData;

			strResponse = KnowledgeArticleDeploymentController.publishAllApprovedArticleByDML(strCount);

			strResponse = KnowledgeArticleDeploymentController.publishAllApprovedArticleByDML('strCount');


			strResponse = KnowledgeArticleDeploymentController.archiveAllPublishedArticleByDML(strCount);


			strResponse = KnowledgeArticleDeploymentController.deleteAllArchivedArticleByDML(strCount);

			strResponse = KnowledgeArticleDeploymentController.archiveAllPublishedArticleByDML(strCount);

			strResponse = KnowledgeArticleDeploymentController.deleteAllArchivedArticleByDML(strCount);

		}


		Test.StopTest();

	}


	@isTest static void TestarchiveAllPublishedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		string strResponse = KnowledgeArticleDeploymentController.archiveAllPublishedArticleByDML(strCount);

		strResponse = KnowledgeArticleDeploymentController.archiveAllPublishedArticleByDML('strCount');

		Test.StopTest();

	}



	@isTest static void TestdeleteAllArchivedArticleByDML(){

		Test.startTest();


		string strCount = '1';
		string strResponse = KnowledgeArticleDeploymentController.deleteAllArchivedArticleByDML(strCount);

		strResponse = KnowledgeArticleDeploymentController.deleteAllArchivedArticleByDML('strCount');

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){
			strResponse = KnowledgeArticleDeploymentController.publishAllApprovedArticleByDML(strCount);
			strResponse = KnowledgeArticleDeploymentController.archiveAllPublishedArticleByDML(strCount);
			strResponse = KnowledgeArticleDeploymentController.deleteAllArchivedArticleByDML(strCount);
			strResponse = KnowledgeArticleDeploymentController.publishAllDraftArticleByDML(strCount);


		}



		Test.StopTest();

	}

//*************************************************************************8 */








	@isTest static void TestpublishSelectiveDraftArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	
		string strResponse = KnowledgeArticleDeploymentController.publishSelectiveDraftArticleByDML(strCount,strAritcleID);


		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveDraftArticleByDML(strCount,strAritcleID);

			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;
			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '0100000' LIMIT 1];
			strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveDraftArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveDraftArticleByDML('strCount',strAritcleID);
		}

		Test.StopTest();

	}



	@isTest static void TestpublishArchiveEditDeleteSelectiveApprovedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	
		string strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){
			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);


			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;

			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '0100000' LIMIT 1];			
			strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	


			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML('strCount',strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML(strCount,strAritcleID);
		}

		Test.StopTest();

	}


	@isTest static void TestarchiveSelectivePublishedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';				
		string strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML(strCount,strAritcleID);

		strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML('strCount',strAritcleID);


		Test.StopTest();

	}



	@isTest static void TestdeleteSelectiveArchivedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	
		string strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML(strCount,strAritcleID);

		strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML('strCount',strAritcleID);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){
			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.publishSelectiveDraftArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);
			strResponse = KnowledgeArticleDeploymentController.deleteSelectiveArchivedArticleByDML(strCount,strAritcleID);

		}

		Test.StopTest();

	}


	@isTest static void TesteditSelectivePublishedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	
		string strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);


			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;
			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '0100000' LIMIT 1];
			strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML('strCount ',strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);

		}


		Test.StopTest();

	}

	
	@isTest static void TesteditSelectiveArchivedArticleByDML(){

		Test.startTest();

		string strCount = '1';
		List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '1100000' LIMIT 1];
		string strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	
		string strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		System.runAs(KBMigUser){

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML(strCount,strAritcleID);


			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article';
			kavMocData.UrlName = '0100000';
			kavMocData.Migrated_Article_Id__c = '0100000';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;
			KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c,UrlName,ArticleNumber,Id FROM Knowledge__kav WHERE UrlName = '0100000' LIMIT 1];
			strAritcleID = string.valueof(KBToUpdate[0].Id) + ';';	

			strResponse = KnowledgeArticleDeploymentController.publishSelectiveApprovedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.archiveSelectivePublishedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.editSelectiveArchivedArticleByDML(strCount,strAritcleID);

			strResponse = KnowledgeArticleDeploymentController.editSelectivePublishedArticleByDML('strCount ',strAritcleID);


		}



		Test.StopTest();

	}


	@isTest static void TestgetCaseKB(){

		Test.startTest();

		string strCount = '1';

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		List<Case> cselst = [Select Id From Case Limit 4];
		String strUrlName = '1100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '2200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '3300000';
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

		Case_KB__c caseKBRec = new Case_KB__c();
		caseKBRec.Case__c = cselst[1].Id;
		caseKBRec.Knowledge__c = null;
		caseKBRec.Type__c = 'Create New';
		caseKBRec.Name = 'KB'+String.valueOf(kavFirstMocData.Id)+'Case';
		caseKBRec.ArticleNumber__c = '';
		insert caseKBRec;


		string strResponse = '';

		System.runAs(KBMigUser){

			strResponse = KnowledgeArticleDeploymentController.createNewKnowledgeBaseArticleFromCaseByDML(strCount,cselst[0].Id);

			strResponse = KnowledgeArticleDeploymentController.createNewKnowledgeBaseArticleFromCaseByDML (strCount,cselst[1].Id + ';' + cselst[3].Id);

			strResponse = KnowledgeArticleDeploymentController.createNewKnowledgeBaseArticleFromCaseByDML(strCount,cselst[2].Id);


		}



		Test.StopTest();

	}

	@isTest static void TestreassignKnowledgeBaseArticleByDML(){

		Test.startTest();

		string strCount = '1';

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		String strUrlName = '1100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '2200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '3300000';
		Knowledge__kav kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];


		string strResponse = '';

		System.runAs(KBMigUser){

			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(kavSecondMocData.Id);
			req.setProcessDefinitionNameOrId('KB_Content_Review');
			req.setSkipEntryCriteria(true);
			req.setComments('submit for approval');
			req.setSubmitterId(kavSecondMocData.CreatedById);
			try{
				Approval.ProcessResult result = Approval.process(req);
			}catch(Exception ex) {}

			strResponse = KnowledgeArticleDeploymentController.reassignKnowledgeBaseArticleByDML(strCount,kavSecondMocData.Id + '#' + KBMigUser.Id);

		}



		Test.StopTest();
	}

	@isTest static void TestRejectKnowledgeBaseArticleByDML(){

		Test.startTest();

		string strCount = '1';

		User KBMigUser = [Select Id From User Where username='kbmigrationuser@informatica.com'];

		String strUrlName = '1100000';
		Knowledge__kav kavFirstMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '2200000';
		Knowledge__kav kavSecondMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];

		strUrlName = '3300000';
		Knowledge__kav kavThirdMocData = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber,CreatedById from Knowledge__kav where UrlName =:strUrlName];


		string strResponse = '';

		System.runAs(KBMigUser){

			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(kavSecondMocData.Id);
			req.setProcessDefinitionNameOrId('KB_Content_Review');
			req.setSkipEntryCriteria(true);
			req.setComments('submit for approval');
			req.setSubmitterId(kavSecondMocData.CreatedById);
			try{
				Approval.ProcessResult result = Approval.process(req);
			}catch(Exception ex) {}

			strResponse = KnowledgeArticleDeploymentController.rejectKnowledgeBaseArticleByDML (strCount,kavSecondMocData.Id + ';');

		}

		Test.StopTest();
	}


}