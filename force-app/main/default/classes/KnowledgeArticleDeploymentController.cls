/**
 * @author Sathish Rajalingam
 * @date 22-Jun-2020
 *

 * @description The main purpose of the class is used to publish the KB Articles from Draft to Published state and Processing the Attachments as well.
 */

/*
   Change History
 *********************************************************************************************************************************************
   ModifiedBy                  Date          JIRA No.                         Description                                Tag
 *********************************************************************************************************************************************

 */
Public Class KnowledgeArticleDeploymentController
{
	Public static String strTableName = 'Knowledge__kav';

	Public static String strInProgress = 'Start-';

	/*******************************************************************************************************
	 * @description Publish the KB Article from Draft.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String publishAllDraftArticleByDML(String parCount)
	{
		try
		{

			//return 'Done publishAllDraftArticleByDML | '+  String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done publishAllDraftArticleByDML Action denied for loggged in user | '+  String.valueOf(parCount) + ' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND ArticleCreatedById = :UserInfo.getUserId() LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done publishAllDraftArticleByDML | '+ String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {

						KbManagement.PublishingService.publishArticle(kbart.KnowledgeArticleId, true);

					}
				}
				return 'Done publishAllDraftArticleByDML | '+ String.valueOf(intCount);
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	/*******************************************************************************************************
	 * @description Publish the KB Article which was in Approved state earlier.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String publishAllApprovedArticleByDML(String parCount)
	{
		try
		{
			//return 'Done publishAllApprovedArticleByDML | '+  String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done publishAllApprovedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount) + ' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus,Migrated_PublishStatus__c FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND Migrated_PublishStatus__c = 'Approved' AND ArticleCreatedById = :UserInfo.getUserId()  LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done publishAllApprovedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {

						KbManagement.PublishingService.publishArticle(kbart.KnowledgeArticleId, true);

					}
				}
				return 'Done publishAllApprovedArticleByDML | '+ String.valueOf(intCount);
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	/*******************************************************************************************************
	 * @description Archive the KB Article which was in publish state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String archiveAllPublishedArticleByDML(String parCount)
	{
		try
		{
			//return 'Done archiveAllPublishedArticleByDML | '+ String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done archiveAllPublishedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount) + ' $Completed';
			}
			else {

				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus FROM Knowledge__kav WHERE PublishStatus = 'Online' AND ArticleCreatedById = :UserInfo.getUserId()  LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done archiveAllPublishedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {



						KbManagement.PublishingService.archiveOnlineArticle(kbart.KnowledgeArticleId,null);

					}
				}



				return 'Done archiveAllPublishedArticleByDML | '+ String.valueOf(intCount);
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	/*******************************************************************************************************
	 * @description delete the KB Article which is in Archived state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String deleteAllArchivedArticleByDML(String parCount)
	{
		try
		{
			//return 'Done deleteAllArchivedArticleByDML | '+ String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done deleteAllArchivedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount) + ' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId,PublishStatus FROM Knowledge__kav WHERE PublishStatus = 'Archived' AND ArticleCreatedById = :UserInfo.getUserId()  LIMIT 100];
				Integer intCount = KBToUpdate.size();

				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done deleteAllArchivedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);
					for(Knowledge__kav kbart : KBToUpdate) {
						KbManagement.PublishingService.deleteArchivedArticle(kbart.KnowledgeArticleId);
					}
				}

				return 'Done deleteAllArchivedArticleByDML | '+ String.valueOf(intCount);
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	/*********************** Only Selective Article **********************/


	/*******************************************************************************************************
	 * @description Publish the KB Article which was in Approved state earlier.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String publishSelectiveApprovedArticleByDML(String parCount,String parArticleID)
	{
		try
		{
			System.debug('publishSelectiveApprovedArticleByDML parArticleID : ' + parArticleID);
			//return 'Done publishSelectiveApprovedArticleByDML | '+  String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			parArticleID= parArticleID.replaceAll( '\\s+', '');

			List<String> lstSelectiveArticleID = parArticleID.split (';');

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done publishSelectiveApprovedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND Migrated_PublishStatus__c = 'Approved'  AND Id IN :lstSelectiveArticleID LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done publishSelectiveApprovedArticleByDML | ' + String.valueOf(intCount)+ ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {

						KbManagement.PublishingService.publishArticle(kbart.KnowledgeArticleId, true);

					}
				}
				return 'Done publishSelectiveApprovedArticleByDML | '+ String.valueOf(intCount);
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	/*******************************************************************************************************
	 * @description Archive the KB Article which was in publish state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String archiveSelectivePublishedArticleByDML(String parCount,String parArticleID)
	{
		try
		{
			//return 'Done archiveSelectivePublishedArticleByDML | '+ String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			parArticleID= parArticleID.replaceAll( '\\s+', '');

			List<String> lstSelectiveArticleID = parArticleID.split (';');

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done archiveSelectivePublishedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
			}
			else {

				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Online' AND ValidationStatus= 'Published' AND Id IN :lstSelectiveArticleID LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done archiveSelectivePublishedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {



						KbManagement.PublishingService.archiveOnlineArticle(kbart.KnowledgeArticleId,null);

					}
				}



				return 'Done archiveSelectivePublishedArticleByDML | '+ String.valueOf(intCount);
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	/*******************************************************************************************************
	 * @description delete the KB Article which is in Archived state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String deleteSelectiveArchivedArticleByDML(String parCount,String parArticleID)
	{
		try
		{
			//return 'Done deleteSelectiveArchivedArticleByDML | '+ String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			parArticleID= parArticleID.replaceAll( '\\s+', '');

			List<String> lstSelectiveArticleID = parArticleID.split (';');

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done deleteSelectiveArchivedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount) + ' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Archived' AND Id IN :lstSelectiveArticleID LIMIT 100];
				Integer intCount = KBToUpdate.size();

				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done deleteSelectiveArchivedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);
					for(Knowledge__kav kbart : KBToUpdate) {
						KbManagement.PublishingService.deleteArchivedArticle(kbart.KnowledgeArticleId);
					}
				}

				return 'Done deleteSelectiveArchivedArticleByDML | '+ String.valueOf(intCount);
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	/*******************************************************************************************************
	 * @description Edit the KB Article which was in publish state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String publishSelectiveDraftArticleByDML(String parCount,String parArticleID)
	{
		try
		{

			//return 'Done publishSelectiveDraftArticleByDML | '+  String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			parArticleID= parArticleID.replaceAll( '\\s+', '');

			List<String> lstSelectiveArticleID = parArticleID.split (';');


			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done publishSelectiveDraftArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount) + ' $Completed';
			}
			else {
				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND ValidationStatus= 'Published' AND IsMasterLanguage = true AND Id IN :lstSelectiveArticleID LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done publishSelectiveDraftArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {

						KbManagement.PublishingService.publishArticle(kbart.KnowledgeArticleId, false);

					}
				}
				return 'Done publishSelectiveDraftArticleByDML | '+ String.valueOf(intCount);
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}



	/*******************************************************************************************************
	 * @description Edit the KB Article which was in publish state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String editSelectivePublishedArticleByDML(String parCount,String parArticleID)
	{
		Map<String,Integer> mapSystemDraft = new Map<String,Integer>();
		String strCurrentArticle = '';
		try
		{
			//return 'Done editSelectivePublishedArticleByDML | '+ String.valueOf(parCount);

			Integer intTempCount = Integer.valueOf(parCount);

			parArticleID= parArticleID.replaceAll( '\\s+', '');

			List<String> lstSelectiveArticleID = parArticleID.split (';');

			List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

			Integer intUserCount = KBMigrationUser.size();
			if(intUserCount == 0)
			{
				return 'Done editSelectivePublishedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
			}
			else {

				List<Knowledge__kav> ToProcessArticle  = [SELECT PublishStatus, ArticleNumber, Id, ValidationStatus, Language FROM Knowledge__kav WHERE PublishStatus = 'Online' AND ValidationStatus= 'Published'  AND IsMasterLanguage = true AND Id IN :lstSelectiveArticleID];

				List<String> lstSelectiveArticleNumber = new List<String> {};
				List<String> lstSelectiveOnline = new List<String> {};
				List<String> lstAlreadyCheckedOut = new List<String> {};
				List<String> lstNotCheckedOut = new List<String> {};

				integer i = 0;
				for(Knowledge__kav kbitem:ToProcessArticle) {
					lstSelectiveArticleNumber.add(kbitem.ArticleNumber);
					lstSelectiveOnline.add(kbitem.ArticleNumber + '$$' + kbitem.Language + '$$' + kbitem.ValidationStatus + '$$Draft##'+kbitem.Id);
				}

				List<Knowledge__kav> DraftArticle  = [SELECT PublishStatus, ArticleNumber, Id, ValidationStatus, Language FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND ValidationStatus= 'Published' AND IsMasterLanguage = true AND ArticleNumber IN :lstSelectiveArticleNumber];

				integer j = 0;
				for(Knowledge__kav kbitem:DraftArticle) {
					String strtest = kbitem.ArticleNumber + '$$' + kbitem.Language + '$$' + kbitem.ValidationStatus + '$$' + kbitem.PublishStatus;
					mapSystemDraft.put(strtest,j++);
				}

				for(String kbArtNumber : lstSelectiveOnline)
				{
					if(mapSystemDraft.containsKey(kbArtNumber.split('##')[0]))
					{
						lstAlreadyCheckedOut.add(kbArtNumber.split('##')[1]);
					}
					else {
						lstNotCheckedOut.add(kbArtNumber.split('##')[1]);
					}

				}



				List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Online' AND ValidationStatus= 'Published'  AND IsMasterLanguage = true AND Id IN :lstNotCheckedOut LIMIT 100];
				Integer intCount = KBToUpdate.size();
				intCount = KBToUpdate.size();
				String strDecidetoExit = '';
				if(intCount == 0)
				{
					return 'Done editSelectivePublishedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
				}
				else {
					intCount+= Integer.valueOf(parCount);

					for(Knowledge__kav kbart : KBToUpdate) {
						strCurrentArticle = kbart.Id;
						KbManagement.PublishingService.editOnlineArticle(kbart.KnowledgeArticleId,false);

					}
				}

				return 'Done editSelectivePublishedArticleByDML |  ' +  String.valueOf(intCount);
			}

		} catch (Exception e) {
			return 'The following exception has occurred: {' + strCurrentArticle + '}' + e.getMessage() + e.getLineNumber() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	/*******************************************************************************************************
	 * @description Edit the KB Article which was in archived state.
	 * @param parCount number of recordds processed
	 * @return Returns the opration output
	 */
	@AuraEnabled
	Public Static String editSelectiveArchivedArticleByDML(String parCount,String parArticleID)
	{
		try
		{
			Map<String,Integer> mapSystemDraft = new Map<String,Integer>();
			String strCurrentArticle = '';
			try
			{
				//return 'Done editSelectiveArchivedArticleByDML | '+ String.valueOf(parCount);

				Integer intTempCount = Integer.valueOf(parCount);

				parArticleID= parArticleID.replaceAll( '\\s+', '');

				List<String> lstSelectiveArticleID = parArticleID.split (';');

				List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

				Integer intUserCount = KBMigrationUser.size();
				if(intUserCount == 0)
				{
					return 'Done editSelectiveArchivedArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
				}
				else {

					List<Knowledge__kav> ToProcessArticle  = [SELECT PublishStatus, ArticleNumber, Id, ValidationStatus, Language FROM Knowledge__kav WHERE PublishStatus = 'Archived' AND ValidationStatus= 'Published' AND IsMasterLanguage = true AND Id IN :lstSelectiveArticleID];

					List<String> lstSelectiveArticleNumber = new List<String> {};
					List<String> lstSelectiveArchived = new List<String> {};
					List<String> lstAlreadyCheckedOut = new List<String> {};
					List<String> lstNotCheckedOut = new List<String> {};

					integer i = 0;
					for(Knowledge__kav kbitem:ToProcessArticle) {
						lstSelectiveArticleNumber.add(kbitem.ArticleNumber);
						lstSelectiveArchived.add(kbitem.ArticleNumber + '$$' + kbitem.Language + '$$' + kbitem.ValidationStatus + '$$Draft##'+kbitem.Id);
					}

					List<Knowledge__kav> DraftArticle  = [SELECT PublishStatus, ArticleNumber, Id, ValidationStatus, Language FROM Knowledge__kav WHERE PublishStatus = 'Draft' AND ValidationStatus= 'Published'  AND ArticleNumber IN :lstSelectiveArticleNumber];

					integer j = 0;
					for(Knowledge__kav kbitem:DraftArticle) {
						String strtest = kbitem.ArticleNumber + '$$' + kbitem.Language + '$$' + kbitem.ValidationStatus + '$$' + kbitem.PublishStatus;
						mapSystemDraft.put(strtest,j++);
					}

					for(String kbArtNumber : lstSelectiveArchived)
					{
						if(mapSystemDraft.containsKey(kbArtNumber.split('##')[0]))
						{
							lstAlreadyCheckedOut.add(kbArtNumber.split('##')[1]);
						}
						else {
							lstNotCheckedOut.add(kbArtNumber.split('##')[1]);
						}

					}



					List<Knowledge__kav> KBToUpdate  = [SELECT KnowledgeArticleId, PublishStatus, Migrated_PublishStatus__c, UrlName, ArticleNumber, Id, ValidationStatus FROM Knowledge__kav WHERE PublishStatus = 'Archived' AND ValidationStatus= 'Published' AND IsMasterLanguage = true AND Id IN :lstNotCheckedOut LIMIT 100];
					Integer intCount = KBToUpdate.size();
					intCount = KBToUpdate.size();
					String strDecidetoExit = '';
					if(intCount == 0)
					{
						return 'Done editSelectiveArchivedArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
					}
					else {
						intCount+= Integer.valueOf(parCount);

						for(Knowledge__kav kbart : KBToUpdate) {
							strCurrentArticle = kbart.Id;
							KbManagement.PublishingService.editArchivedArticle(kbart.KnowledgeArticleId);

						}
					}

					return 'Done editSelectiveArchivedArticleByDML |  ' +  String.valueOf(intCount);
				}

			} catch (Exception e) {
				return 'The following exception has occurred: {' + strCurrentArticle + '}' + e.getMessage() + e.getLineNumber() + ' | ' + String.valueOf(parCount) + ' $Completed';
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	@AuraEnabled
	Public Static String createNewKnowledgeBaseArticleFromCaseByDML(String parCount,String parCaseID)
	{
		try
		{
			Map<String,Integer> mapSystemDraft = new Map<String,Integer>();
			String strCurrentCase = '';
			try
			{
				//return 'Done editSelectiveArchivedCaseByDML | '+ String.valueOf(parCount);

				Integer intTempCount = Integer.valueOf(parCount);

				parCaseID= parCaseID.replaceAll( '\\s+', '');

				List<String> lstSelectiveCaseID = parCaseID.split (';');

				List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

				Integer intUserCount = KBMigrationUser.size();
				if(intUserCount == 0)
				{
					return 'Done CreateNewKnowledgeBaseCaseFromCaseByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
				}
				else {

					List<Case> ToProcessCase  = [SELECT Id, CaseNumber, Subject, KB_Action__c,KB_Keyword__c,KB_Template__c FROM Case WHERE Id IN :lstSelectiveCaseID AND KB_Action__c = 'Create New' ];

					List<String> lstSelectiveCaseSubject = new List<String> {};
					List<String> lstSelectiveArchived = new List<String> {};
					List<String> lstAlreadyPresentKBTitle = new List<String> {};
					List<String> lstAlreadyPresentCaseKB = new List<String> {};


					integer i = 0;
					for(Case caseitem:ToProcessCase) {
						lstSelectiveCaseSubject.add(caseitem.Subject);
					}

					List<Knowledge__kav> AlreadyPresentKB  = [SELECT PublishStatus, Id, ValidationStatus, Language,Title FROM Knowledge__kav WHERE PublishStatus != 'Archived' AND Title IN :lstSelectiveCaseSubject];


					for(Knowledge__kav kbArticle : AlreadyPresentKB)
					{
						lstAlreadyPresentKBTitle.add(kbArticle.Title);
					}

					List<Case> ToProcessFilteredCase  = [SELECT Id, CaseNumber, Subject, KB_Action__c,KB_Keyword__c,KB_Template__c FROM Case WHERE Id IN :lstSelectiveCaseID AND KB_Action__c = 'Create New' AND Subject IN  :lstSelectiveCaseSubject AND Subject NOT IN :lstAlreadyPresentKBTitle LIMIT 5];
					Integer intCount = ToProcessFilteredCase.size();
					intCount = ToProcessFilteredCase.size();
					String strDecidetoExit = '';
					if(intCount == 0)
					{
						return 'Done CreateNewKnowledgeBaseCaseFromCaseByDML | ' + String.valueOf(intCount) + ' $Completed';
					}
					else {
						intCount+= Integer.valueOf(parCount);
						for(Case caseData : ToProcessFilteredCase) {
							strCurrentCase = caseData.Id;
							string strOutput = checkAndUpdateKnowledgeBaseArticle(caseData.Id,caseData.KB_Keyword__c,caseData.KB_Template__c,caseData.KB_Action__c,'');
							if(strOutput.indexOf('$$$$#####ERROR#####$$$$') > -1)
								return 'The following exception has occurred: {' + strCurrentCase + '}' + strOutput + ' | ' + String.valueOf(parCount) + ' $Completed';
						}
					}

					return 'Done CreateNewKnowledgeBaseCaseFromCaseByDML |  ' +  String.valueOf(intCount);
				}

			} catch (Exception e) {
				return 'The following exception has occurred: {' + strCurrentCase + '}' + e.getMessage() + e.getLineNumber() + ' | ' + String.valueOf(parCount) + ' $Completed';
			}



		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}

	@AuraEnabled
	Public Static String reassignKnowledgeBaseArticleByDML(String parCount,String parArticleIDAssignID)
	{
		try
		{
			String strArticleID = '';
			String strUserID = '';
			try
			{
				//return 'Done editSelectiveArchivedCaseByDML | '+ String.valueOf(parCount);

				Integer intTempCount = Integer.valueOf(parCount);

				parArticleIDAssignID = parArticleIDAssignID.replaceAll( '\\s+', '');

				List<String> lstSelectiveArticleIDAssignID = parArticleIDAssignID.split (';');

				List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Name = 'Deployment master' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

				Integer intUserCount = KBMigrationUser.size();
				if(intUserCount == 0)
				{
					return 'Done reassignKnowledgeBaseArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
				}
				else {

					integer i = 0;

					Integer intCount = lstSelectiveArticleIDAssignID.size();
					intCount = lstSelectiveArticleIDAssignID.size();
					String strDecidetoExit = '';
					if(intCount == 0)
					{
						return 'Done reassignKnowledgeBaseArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
					}
					else {
						intCount += Integer.valueOf(parCount);

						for(String assignidkbid : lstSelectiveArticleIDAssignID) {
							String[] lstCurrentArticleIDAssignID  = assignidkbid.split('#');
							strArticleID = '';
							strArticleID = lstCurrentArticleIDAssignID[0];
							strArticleID = strArticleID.trim();
							strUserID = lstCurrentArticleIDAssignID[1];
							if(strArticleID != '')
							{
								List<ProcessInstanceWorkitem> workItems = [Select Id,ActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: lstCurrentArticleIDAssignID[0]];
								for(ProcessInstanceWorkitem workItem : workItems) {
									if(workItem.ActorId != lstCurrentArticleIDAssignID[1])
									{
										workItem.ActorId = lstCurrentArticleIDAssignID[1];
										update workItem;
									}
								}
							}
						}
					}

					return 'Done reassignKnowledgeBaseArticleByDML | ' + String.valueOf(intCount) + ' ' + strArticleID + ' ' + strUserID + ' $Completed';
				}

			} catch (Exception e) {
				return 'The following exception has occurred: {' + strArticleID + '}' + e.getMessage() + ' ' +  e.getLineNumber() + ' | ' + String.valueOf(parCount) + ' $Completed';
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	@AuraEnabled
	Public Static String rejectKnowledgeBaseArticleByDML(String parCount,String parArticleIDAssignID)
	{
		try
		{
			String strArticleID = '';
			String strUserID = '';
			try
			{
				//return 'Done editSelectiveArchivedCaseByDML | '+ String.valueOf(parCount);

				Integer intTempCount = Integer.valueOf(parCount);

				parArticleIDAssignID = parArticleIDAssignID.replaceAll( '\\s+', '');

				List<String> lstSelectiveArticleID = parArticleIDAssignID.split (';');

				List<User> KBMigrationUser  = [SELECT Id FROM User WHERE (Name = 'KB Migration User' AND Id = :UserInfo.getUserId()) OR (Name = 'Deployment master' AND Id = :UserInfo.getUserId()) OR (Id = :Label.KB_Deployment_User_Id AND Id = :UserInfo.getUserId()) LIMIT 1];

				Integer intUserCount = KBMigrationUser.size();
				if(intUserCount == 0)
				{
					return 'Done rejectKnowledgeBaseArticleByDML Action denied for loggged in user | ' +  String.valueOf(parCount)+ ' $Completed';
				}
				else {

					integer i = 0;

					Integer intCount = lstSelectiveArticleID.size();
					intCount = lstSelectiveArticleID.size();
					String strDecidetoExit = '';
					if(intCount == 0)
					{
						return 'Done rejectKnowledgeBaseArticleByDML | ' + String.valueOf(intCount) + ' $Completed';
					}
					else {
						intCount += Integer.valueOf(parCount);

						for(String assignidkbid : lstSelectiveArticleID) {
							strArticleID = '';												
							strArticleID = assignidkbid;
							strArticleID = strArticleID.trim();							
							if(strArticleID != '')
							{
								List<ProcessInstanceWorkitem> workItems = [Select Id,ActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: strArticleID];
								for(ProcessInstanceWorkitem workItem : workItems) {
									Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
									req.setComments('Rejected!');
									req.setAction('Reject');
									req.setWorkitemId(workItem.Id);									
									Approval.process(req);
								}
							}
						}
					}

					return 'Done rejectKnowledgeBaseArticleByDML | ' + String.valueOf(intCount) + ' ' + strArticleID + ' ' + strUserID + ' $Completed';
				}

			} catch (Exception e) {
				return 'The following exception has occurred: {' + strArticleID + '}' + e.getMessage() + ' ' +  e.getLineNumber() + ' | ' + String.valueOf(parCount) + ' $Completed';
			}

		} catch (Exception e) {
			return 'The following exception has occurred: ' + e.getMessage() + ' | ' + String.valueOf(parCount) + ' $Completed';
		}
	}


	public static string checkAndUpdateKnowledgeBaseArticle(string strRecordId,string strKeywords,string strArticleType,string strActionType,string strArticleId) {

		String strDataFlowStatus = '';
		String CREATE_NEW = 'Create New';
		String USE_EXISTING = 'Use Existing';
		String UPDATED_EXISTING = 'Updated Existing';
		String NOT_APPLICABLE = 'NA';//Jira : I2RT-4955
		try {
			strDataFlowStatus += ' ' + strActionType + ' ' + strRecordId;
			Case caseRecord = [SELECT Id, CaseNumber, Status, Subject, Description, Priority, Next_Action__c, Forecast_Product__c, Version__c,
			                   CreatedDate, LastmodifiedDate,Closing_Notes__c,Component__c,Problem_Type__c,OwnerId,Root_Cause_Analysis__c FROM Case WHERE Id = :strRecordId];

			List<Case_KB__c> casekbExistCreateNew = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND Type__c = :CREATE_NEW];

			//List<Case_KB__c> casekbExistUpdateOrUse = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND (Type__c = :USE_EXISTING OR Type__c = :UPDATED_EXISTING)];

			//Jira : I2RT-4955
			List<Case_KB__c> casekbExistNotApplicable = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND Type__c = :NOT_APPLICABLE];

			if(strActionType == CREATE_NEW)
			{

				if(caseRecord != null)
				{
					//Jira : I2RT-4955 - Start
					if(!casekbExistNotApplicable.isEmpty())
					{
						delete casekbExistNotApplicable;
					}
					//Jira : I2RT-4955 - End

					strDataFlowStatus += ' Create New Section';
					string title = caseRecord.Subject != null ? caseRecord.Subject : '';
					string keywords =  strKeywords != null ? strKeywords : '';
					string internalNotes = caseRecord.CaseNumber != null ? caseRecord.CaseNumber : '';
					string infaProducts = caseRecord.Forecast_Product__c != null ? caseRecord.Forecast_Product__c : '';
					string solution = caseRecord.Closing_Notes__c != null ? caseRecord.Closing_Notes__c : '';
					solution += caseRecord.Description != null ? ' \n'+ caseRecord.Description : '';

					string problemDescription =  caseRecord.Description != null ? caseRecord.Description : '';
					problemDescription += caseRecord.Root_Cause_Analysis__c != null ? ' \n'+caseRecord.Root_Cause_Analysis__c : '';

					string template = strArticleType != null ? strArticleType.trim().toLowerCase() : '';
					string recordtypeid = '';
					string caseId =  caseRecord.Id != null ? caseRecord.Id : '';
					string productversion = caseRecord.Version__c != null ? caseRecord.Version__c : '';
					string component = caseRecord.Component__c != null ? caseRecord.Component__c : '';
					string problemtype = caserecord.Problem_Type__c != null ? caserecord.Problem_Type__c : '';
					string actiontype = strActionType != null ? strActionType : '';
					string ownerid = caseRecord.OwnerId != null ? caserecord.OwnerId : '';
					string solutionrectypeid = null;


					if(template != 'faq' && template != 'whitepaper' && template != 'how to')
					{
						problemDescription =  caseRecord.Description != null ? caseRecord.Description : '';
						problemDescription += caseRecord.Root_Cause_Analysis__c != null ? ' \n'+caseRecord.Root_Cause_Analysis__c : '';
					}
					else {
						problemDescription = '';
					}

					infaProducts = valueForPickList(infaProducts,Knowledge__kav.Primary_Product__c,'','');
					productversion = valueForPickList(productversion,Knowledge__kav.Product_Version__c,'Primary_Product__c',infaProducts);
					component = valueForPickList(component,Knowledge__kav.Product_Component__c,'Primary_Product__c',infaProducts);
					problemtype = valueForPickList(problemtype,Knowledge__kav.Problem_Type__c,'','');

					// system.debug ('infaProducts : ' + infaProducts);
					// system.debug ('productversion : ' + productversion);
					// system.debug ('component : ' + component);
					// system.debug ('problemtype : ' + problemtype);



					List<RecordType> kbRecordTypeList= [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Knowledge__kav'];

					for(RecordType kbRecordType : kbRecordTypeList)
					{
						if(string.valueOf(kbRecordType.Name).trim().toLowerCase() == template)
						{
							recordtypeid = kbRecordType.Id;
						}
						if(string.valueOf(kbRecordType.Name).trim().toLowerCase() == 'solution')
						{
							solutionrectypeid = kbRecordType.Id;
						}
					}

					recordtypeid = recordtypeid.trim() == '' ? solutionrectypeid : recordtypeid;

					Integer randomNumber = Integer.valueof((Math.random() * 1000000000));
					String strUrlName = 'KB' + String.valueOf(randomNumber);
					Knowledge__kav knwRec = new Knowledge__kav();
					knwRec.Title = title;
					knwRec.UrlName = strUrlName;
					knwRec.Expiration_Date__c = system.today().addYears(1);
					knwRec.Primary_Product__c = infaProducts;
					knwRec.Solution__c = solution;
					knwRec.Description__c = problemDescription;
					knwRec.Additional_Information__c = '';
					knwRec.Keywords__c = keywords;
					knwRec.Product_Version__c = productversion;
					knwRec.Product_Component__c = component;
					knwRec.Problem_Type__c = problemtype;
					knwRec.Created_By__c = ownerid;
					knwRec.RecordTypeId = recordtypeid;
					knwRec.Internal_Notes__c = internalNotes;

					strDataFlowStatus += ' Going to Insert KB ' + JSON.serialize(knwRec);

					strDataFlowStatus += ' Before KB Insert';

					insert knwRec;

					knwRec = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];


					knwRec.UrlName = String.valueOf(knwRec.ArticleNumber);
					update knwRec;


					Case_KB__c caseKBRec = new Case_KB__c();
					if(casekbExistCreateNew.isEmpty() == false)
					{
						casekbExistCreateNew[0].Case__c = strRecordId;
						casekbExistCreateNew[0].Knowledge__c = knwRec.Id;
						casekbExistCreateNew[0].Type__c = actiontype;
						casekbExistCreateNew[0].Name = 'KB'+String.valueOf(knwRec.Id)+'Case'+strRecordId;
						casekbExistCreateNew[0].ArticleNumber__c = String.valueOf(knwRec.ArticleNumber);
						update casekbExistCreateNew;
						caseKBRec = casekbExistCreateNew[0];
					}
					else
					{
						caseKBRec.Case__c = strRecordId;
						caseKBRec.Knowledge__c = knwRec.Id;
						caseKBRec.Type__c = actiontype;
						caseKBRec.Name = 'KB'+String.valueOf(knwRec.Id)+'Case'+strRecordId;
						caseKBRec.ArticleNumber__c = String.valueOf(knwRec.ArticleNumber);
						insert caseKBRec;
					}


					strDataFlowStatus += ' After KB Insert or Update';
					strDataFlowStatus += '############# caseKBRec'+JSON.serialize(caseKBRec)+ ' #################';
				}

			}


			strDataFlowStatus += 'OK';



		} catch (Exception e) {
			system.debug('Exception in checkAndUpdateKnowledgeBaseArticle : '+e.getmessage()+e.getlinenumber());
			strDataFlowStatus += ' $$$$#####ERROR#####$$$$ : Exception in checkAndUpdateKnowledgeBaseArticle : '+e.getmessage()+e.getlinenumber();


		}
		return strDataFlowStatus;
	}

	public static string valueForPickList(string strInputValue,Schema.sObjectField dependentField,string controlFieldName, string controlFieldValue)
	{
		string strResult = '';
		try{
			Schema.DescribeFieldResult describePickListField = dependentField.getDescribe();

			Schema.sObjectField controllerField = describePickListField.getController();

			boolean isPickListValuePresent = false;
			boolean isPickListValueValidWithControlField = false;
			String base64string = '';
			List<Schema.PicklistEntry> valuesPickListField = describePickListField.getPicklistValues();
			for(Schema.PicklistEntry valuePickListField : valuesPickListField) {
				if((valuePickListField.getValue().trim().toLowerCase() == strInputValue.trim().toLowerCase()) && valuePickListField.isActive() == true)
				{
					strResult = valuePickListField.getValue();
					strResult = strResult.trim();
					isPickListValuePresent = true;
					system.debug ('dependentfield Object' + JSON.serialize(valuePickListField));
					base64string = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(valuePickListField))).get('validFor'));
					break;
				}
			}

			if(controlFieldName != '' && isPickListValuePresent == true)
			{
				system.debug ('dependentfield Object base64string ' + base64string);

				Map<String, List<String> > objResults = new Map<String, List<String> >();
				List<String> controllingValues = new List<String>();

				if(controllerField != null) {
					Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
					List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());

					for (Schema.PicklistEntry ple : controllerValues) {
						String value = ple.getValue();
						//objResults.put(value, new List<String>());
						controllingValues.add(value);
					}

					if(base64string != null)
					{
						system.debug ('dependentfield Object binary ' + base64ToBits(base64string));
						String binarystring = base64ToBits(base64string);
						List<String> binarychars = binarystring.split('');
						for (Integer i = 0; i < binarychars.size(); i++) {
							if(binarychars[i] == '1')
							{
								if(controllingValues.get(i) == controlFieldValue)
								{
									isPickListValueValidWithControlField = true;
									system.debug ('dependentfield Matched Value ' + controllingValues.get(i));
								}
							}
						}
					}
				}
			}
			else if(isPickListValuePresent == true)
			{
				isPickListValueValidWithControlField = true;
			}

			if(isPickListValueValidWithControlField != true)
			{
				strResult = '';
			}

		} catch (Exception e) {
			system.debug('Exception in valueForPickList : '+e.getmessage() + ' ' + e.getlinenumber());
		}
		return strResult;
	}

	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	private static final String base64Chars = '' +
	                                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
	                                          'abcdefghijklmnopqrstuvwxyz' +
	                                          '0123456789+/';


	public static String base64ToBits(String validFor) {


		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}





	/*********************** Only Selective Article **********************/

}