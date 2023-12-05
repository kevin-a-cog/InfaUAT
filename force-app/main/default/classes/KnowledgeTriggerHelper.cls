/*
   @created by       : balajip
   @created on       : 07/27/2020
   @Purpose          : Knowledge handler helper class.
   @Testclass        :
   @JIRA             :


   Change History

 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  27-Oct-2020      |   Venky                   |                   |   Contributor is not getting populated correctly
 |     2      |  22-Jan-2021      |   Ranjan                  |    I2RT-868       |   Added Content Approved flag in If condition
 |     3      |  27-Jan-2021      |   Ranjan                  |    I2RT-767       |   Check GDPR Compliance flag by Author and CR
 |     4      |  27-Jan-2021      |   Ranjan                  |    I2RT-757       |   Relate Only Published Articles by Author and CR
 |     5      |  08-Apr-2021      |   Sathish                 |    I2RT-1887      |   Rejected articles are displayed in search (Internal & External)
 |     6      |  23-Aug-2021      |   Sathish                 |    I2RT-557       |   URLName will be replaced with ArticleNumber
 |     7      |  23-Aug-2021      |   Sathish                 |    I2RT-3607      |   Publishing rights for a group of authors
 |     8      |  16-Jan-2022      |   Sathish                 |    I2RT-5132      |   Direct Approver, Publishing the Article Directly without AQI
 |     9      |  29-Mar-2022      |   Sathish                 |    I2RT-5354      |   Direct Approval for PAM and EOL , Product Release and Support Guide
 |     10     |  25-Jul-2022      |   Deeksha Shetty          |    I2RT-6524.     |   Additional double Quote (“) or semi-colon (;) is getting added in the article
 |     11     |  21-Sep-2022      |   Sathish                 |    I2RT-7044      |   TR Workflow Change - One Only Article is used for the whole flow - Author to CR to TR to TR Publisd Article
 |     12     |  17-Nov-2022      |   Sathish                 |    I2RT-7274      |   Provide ability to Content Reviewers to delete files uploaded in the Article Files section of Articles authored by others
 |     13     |  23-May-2023      |   Sathish                 |    I2RT-8361      |   Ability for Publishers to submit articles for Technical Review.
 ****************************************************************************************************

 */
public class KnowledgeTriggerHelper
{

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Submits the given Knowledge record for applicable approval process
	 *
	 *————————————————————————————————————————————————————
	 * @param    approvalProcessName, comments, submitterId
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public static String submitForApproval(Id kavId, String approvalProcessName, String comments, Id submitterId){
		String returnMsg='';

		Id approverId;
		if('KB_Technical_Review'.equals(approvalProcessName)) {
			approverId = KnowledgeTriggerHelper.getTRApproverId(kavId);
		}

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(kavId);
		req.setProcessDefinitionNameOrId(approvalProcessName);
		req.setSkipEntryCriteria(true);
		req.setComments(comments);
		req.setSubmitterId(submitterId);
		if(approverId != null) {
			req.setNextApproverIds(new ID[] {approverId});
		}
		try{
			Approval.ProcessResult result = Approval.process(req);
			System.debug('approval submission result = '+result);
			if(result.isSuccess()) {
				returnMsg = 'SUCCESS';
			}else{
				for(Database.Error error : result.getErrors()) {
					returnMsg += error.getMessage() + ';';
				}
			}
		}catch(Exception ex) {
			if(ex.getMessage().indexOf('NO_APPLICABLE_PROCESS')>=0) {
				returnMsg = 'Not allowed to submit this Article for review!';
			}else{
				returnMsg = ex.getMessage();
			}
		}

		return returnMsg;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Determines and returns the Id of the Technical Reviewers Queue
	 *                   based on the Primary Product of the given Knowledge article Id
	 *
	 *————————————————————————————————————————————————————
	 * @param    kavId
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public static Id getTRApproverId(Id kavId){
		Knowledge__kav kb = [Select Id, IsVisibleInPkb, ValidationStatus, Content_Approved__c, TR_Approval__c, Is_Tech_Reviewer_Assigned__c,Primary_Product__c,
		                     Rejected_By_Technical_Reviewer__c
		                     From Knowledge__kav Where Id = :kavId];


		List<Group> lstGroup = [Select Id From Group Where Type = 'Queue' AND DeveloperNAME = :System.Label.KB_Other_Queue_Name];
		Id queueTROtherId;
		if(!lstGroup.isEmpty()) {
			queueTROtherId = lstGroup.get(0).Id;
		}

		List<Product__mdt> lstProductQueue = [Select DeveloperName, Product_Name__c, TR_Queue_Id__c From Product__mdt];
		Map<String, String> mapProductNameToQueue = new Map<String, String>();
		for (Product__mdt productQueue : lstProductQueue) {
			mapProductNameToQueue.put(productQueue.Product_Name__c, productQueue.TR_Queue_Id__c);
		}

		Id approverId;
		String submissionComment='';
		if(kb.TR_Approval__c) {
			if (kb.Is_Tech_Reviewer_Assigned__c) {
				approverId = kb.Rejected_By_Technical_Reviewer__c;
				submissionComment = 'Submitting for review to the Technical Reviewer';
			}else{
				approverId = queueTROtherId;         //default to Other queue
				if (kb.Primary_Product__c != null && mapProductNameToQueue.containsKey(kb.Primary_Product__c)) {
					approverId = mapProductNameToQueue.get(kb.Primary_Product__c);
				}
				submissionComment = 'Submitting for review to the Technical Reviewer Pool';
			}
		}else{
			approverId = UserInfo.getUserId();
			submissionComment = 'Submitting for auto approval as Technical Review not required';
		}

		System.debug('approver id identfied as ' + approverId);
		System.debug('submissionComment - ' + submissionComment);

		return approverId;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Posts a message that the given Knowledge article is submitted for review
	 *                 in the respective Chatter Group based on the given Product name
	 *
	 *————————————————————————————————————————————————————
	 * @param    productName, kavId
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public static void postToChatterGroup(String productName, knowledge__kav knwRec){
		String chatterGroupId;

		List<Product__mdt> lstProductMeta = [Select DeveloperName, Product_Name__c, KB_TR_Chatter_Group_Id__c From Product__mdt Where Product_Name__c = :productName];
		if(!lstProductMeta.isEmpty()) {
			Product__mdt productMeta = lstProductMeta.get(0);
			if(!String.isEmpty(productMeta.KB_TR_Chatter_Group_Id__c)) {
				chatterGroupId = productMeta.KB_TR_Chatter_Group_Id__c;
			}
		}
		if (String.isEmpty(chatterGroupId)) {
			List<CollaborationGroup> lstChatterGroup = [Select Id From CollaborationGroup Where Name = :System.Label.KB_Other_Chatter_Group_Name];
			if(!lstChatterGroup.isEmpty()) {
				chatterGroupId = lstChatterGroup.get(0).Id;
			}
		}

		if (!String.isEmpty(chatterGroupId)) {
			// Define the FeedItemInput object to pass to postFeedElement
			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			feedItemInput.subjectId = chatterGroupId;


			ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
			textSegmentInput1.text = ' has submitted ';


			String content = ' ('+knwRec.ArticleNumber+') for technical review. Please approve or reject the article after review.\n\n Product:'+knwRec.Primary_Product__c+'\n Product Version:'+knwRec.Product_Version__c+'\n Product Component:'+knwRec.Product_Component__c;
			ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
			textSegmentInput2.text = content;

			ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
			entityLinkSegmentInput.entityId = knwRec.Id;

			ConnectApi.EntityLinkSegmentInput userIdInput = new ConnectApi.EntityLinkSegmentInput();
			userIdInput.entityId = UserInfo.getUserId();


			// The MessageBodyInput object holds the text in the post
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			messageBodyInput.messageSegments.add(userIdInput);
			messageBodyInput.messageSegments.add(textSegmentInput1);
			messageBodyInput.messageSegments.add(entityLinkSegmentInput);
			messageBodyInput.messageSegments.add(textSegmentInput2);
			feedItemInput.body = messageBodyInput;

			// Post the feed item.
			if (!Test.isRunningTest()) {
				ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
			}
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Moves the Related KB records from the current to the newly published Knowledge article version
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	/*public void updateRelatedArticles(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
	                List<Related_KB__c> lstRelatedKBToUpdate = new List<Related_KB__c>();
	                Knowledge__kav oldKB;
	                for(Knowledge__kav kb : newMap.values()){
	                                                oldKB = oldMap.get(kb.Id);
	                                                if('Published'.equals(kb.ValidationStatus) && kb.ValidationStatus != oldKB.ValidationStatus){
	                                                                System.debug('Article is now published');
	                                                                List<Knowledge__kav> lstArchivedVersion = [SELECT Id FROM Knowledge__kav WHERE IsLatestVersion = False AND PublishStatus = 'Archived' AND KnowledgeArticleId = :kb.KnowledgeArticleId Order By VersionNumber Desc];
	                                                                if(!lstArchivedVersion.isEmpty()){
	                                                                                                Knowledge__kav lastArchivedVersion = lstArchivedVersion.get(0);
	                                                                                                System.debug('Found last archived version - ' + lastArchivedVersion);
	                                                                                                for(Related_KB__c relatedKB : [Select Id, Referred_Article__c, Referred_In__c From Related_KB__c Where Referred_Article__c = :lastArchivedVersion.Id]){
	                                                                                                                relatedKB.Referred_Article__c = kb.Id;
	                                                                                                                lstRelatedKBToUpdate.add(relatedKB);
	                                                                                                }
	                                                                }
	                                                }
	                }

	                if(!lstRelatedKBToUpdate.isEmpty()){
	                                                System.debug('Updating related articles to latest version');
	                                                update lstRelatedKBToUpdate;
	                }
	   }*/

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void checkContributedKBField(List<Knowledge__kav> newList) {
		Map<Id,String> KnowledgeArtIdLangMap =  new Map<Id,String>();
		Set<Id> articleIds= new Set<Id>();
		for(Knowledge__kav knwldgeRec :  newList) {
			system.debug('KnowledgeArticleId'+knwldgeRec.KnowledgeArticleId);
			system.debug('Language'+knwldgeRec.Language);
			if(!String.isBlank(knwldgeRec.KnowledgeArticleId)) {
				KnowledgeArtIdLangMap.put(knwldgeRec.KnowledgeArticleId,knwldgeRec.Language);
			}
		}
		system.debug('KnowledgeArtIdLangMap value is '+KnowledgeArtIdLangMap);

		if(!KnowledgeArtIdLangMap.isEmpty() && KnowledgeArtIdLangMap!=null) {
			system.debug('inside if map condition');
			for(Knowledge__kav knwldgeExistngRec : [Select Id, Language, KnowledgeArticleId From Knowledge__kav
			                                        Where KnowledgeArticleId = :KnowledgeArtIdLangMap.keySet()
			                                                                   And PublishStatus = 'Online' And ValidationStatus = 'Published']) {

				if(KnowledgeArtIdLangMap.get(knwldgeExistngRec.KnowledgeArticleId)==knwldgeExistngRec.Language) {
					system.debug('inside language comparison');
					articleIds.add(knwldgeExistngRec.KnowledgeArticleId);
				}
			}
			system.debug('articleIds'+articleIds);
			if(!articleIds.isEmpty()) {
				for(Knowledge__kav newRec :  newList) {
					if(articleIds.contains(newRec.KnowledgeArticleId)) {
						newRec.Contributed_KB__c=true;

						//LastModifiedById is used to set the contributor (created_by__c) as system fields like ownerid, articlecreatedby is still the
						//original person who created the article. AssignedToId, AssignedById is not used as they are populated after article is created
						//LastModifiedById is the only field that holds creator id during before insert. This field is reliable unless we have future methods which unlikely to have in future.

						newRec.Created_By__c = UserInfo.getUserId();
					}
				}
			}
		}
	}
	//TR Workflow Change - Start - /*<11>*/
	// private Knowledge__kav duplicateArticle(Knowledge__kav sourceKb){
	// 	KbManagement.PublishingService.publishArticle(sourceKb.KnowledgeArticleId, true);

	// 	String draftArticleId = KbManagement.PublishingService.editOnlineArticle(sourceKb.KnowledgeArticleId, false);
	// 	Knowledge__kav kb = [Select Id, ValidationStatus From Knowledge__kav Where Id = :draftArticleId];
	// 	kb.ValidationStatus = 'Pending Technical Review';
	// 	kb.TR_Approval__c = true;
	// 	//kb.Pending_TR_Placeholder__c = true;
	// 	kb.Is_Pending_TR_Version_Published__c = true;

	// 	kb.AQI_Score__c = sourceKb.AQI_Score__c;

	// 	kb.Rejected_By_Content_Reviewer__c = sourceKb.Rejected_By_Content_Reviewer__c;
	// 	kb.Content_Reviewer_Rejected__c = sourceKb.Content_Reviewer_Rejected__c;
	// 	kb.Content_Approved__c = sourceKb.Content_Approved__c;
	// 	kb.Is_Content_Reviewer_Assigned__c = sourceKb.Is_Content_Reviewer_Assigned__c;
	// 	kb.Content_Review_Date__c = sourceKb.Content_Review_Date__c;
	// 	kb.Content_Reviewed_Date__c = sourceKb.Content_Reviewed_Date__c;
	// 	kb.CR_Wait_Time__c = sourceKb.CR_Wait_Time__c;
	// 	kb.GDPR_Acknowledgement_by_Author__c = sourceKb.GDPR_Acknowledgement_by_Author__c; /* Tag 3 */
	// 	kb.GDPR_Acknowledgement_by_CR__c = sourceKb.GDPR_Acknowledgement_by_CR__c; /* Tag 3 */
	// 	kb.Rejected_By_Technical_Reviewer__c = sourceKb.Rejected_By_Technical_Reviewer__c;
	// 	kb.Technical_Reviewer_Rejected__c = sourceKb.Technical_Reviewer_Rejected__c;
	// 	kb.Is_Tech_Reviewer_Assigned__c = sourceKb.Is_Tech_Reviewer_Assigned__c;
	// 	kb.TR_Approved_Date__c = sourceKb.TR_Approved_Date__c;
	// 	kb.TR_Submitted_Date__c = sourceKb.TR_Submitted_Date__c;
	// 	kb.TR_Wait_Time__c = sourceKb.TR_Wait_Time__c;
	// 	kb.TR_Approval__c = sourceKb.TR_Approval__c;

	// 	update kb;

	// 	return kb;
	// }


	private Knowledge__kav duplicateArticle(Knowledge__kav sourceKb){

		Knowledge__kav kbToUpdate = new Knowledge__kav(Id=sourceKb.Id);

		kbToUpdate.TR_Approval__c = true;

		kbToUpdate.Is_Pending_TR_Version_Published__c = true;

		update kbToUpdate;

		return kbToUpdate;
	}
	//TR Workflow Change - End - /*<11>*/

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Submits the knowledge article for technical review
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void processApproval(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
		Knowledge__kav oldKB;
		for(Knowledge__kav kb : newMap.values()) {
			oldKB = oldMap.get(kb.Id);
			if(kb.IsMasterLanguage) {
				if('Pending Technical Review'.equals(kb.ValidationStatus) && 'Pending Content Review'.equals(oldKB.ValidationStatus)) {

					if(kb.TR_Approval__c) {
						String approvalProcessName = 'KB_Technical_Review';

						System.debug('content approved, auto submitted for approval - ' + approvalProcessName);

						String articleForApprovalId;

						Approval.unlock(kb.Id);
						Knowledge__kav dupe = duplicateArticle(kb);
						articleForApprovalId = dupe.Id;
						String returnMsg = KnowledgeTriggerHelper.submitForApproval(articleForApprovalId, approvalProcessName, 'Submitting for Technical Review', kb.CreatedById);
						if('SUCCESS'.equals(returnMsg)) {
							KnowledgeTriggerHelper.postToChatterGroup(kb.Primary_Product__c, kb);
						}
					}else{
						Approval.unlock(kb.Id);
						Knowledge__kav kbToUpdate = new Knowledge__kav(Id=kb.Id);
						kbToUpdate.ValidationStatus='Published';
						update kbToUpdate;
						if(kb.Is_Pending_TR_Version_Published__c) {
							KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, true); //TR Workflow Change - /*<11>*/
						}else{
							KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, true);
						}
					}
				}

				if('Published'.equals(kb.ValidationStatus) && 'Pending Technical Review'.equals(oldKB.ValidationStatus)) {
					Approval.unlock(kb.Id);
					if(kb.Is_Pending_TR_Version_Published__c) {
						system.debug('inside if isPendingTR Version');
						KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, true); //TR Workflow Change - /*<11>*/
					}else{
						system.debug('inside else isPendingTR Version');
						KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, true);
					}
				}
			}
		}
	}

	public void processAutoApproval(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
		Knowledge__kav oldKB;
		Integer kbmaxallowedversion =  integer.valueOf(Label.KB_Maximum_Allowed_Version);
		for(Knowledge__kav kb : newMap.values()) {
			oldKB = oldMap.get(kb.Id);
			if(kb.IsMasterLanguage) {
				if('Published'.equals(kb.ValidationStatus) && ((((kb.Article_Type__c == 'Product Release') || (kb.Article_Type__c == 'Support Guide') || (kb.Article_Type__c == 'PAM EOL Support Statement') || (kb.Article_Type__c == 'RCA'))))) {
					if(kb.Published_Version_Number__c != null && kb.Published_Version_Number__c >= kbmaxallowedversion)
					{
						Approval.unlock(kb.Id);
						KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, false);
					}
				}
			}
		}
	}

	/* Tag 5 */
	/**
	 *————————————————————————————————————————————————————
	 * @Description: Archive the Knowledge article which was rejected by TR
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void processArchival(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
		Knowledge__kav oldKB;
		Set<Id> setkbArticleId = new Set<Id>();
		for(Knowledge__kav kb : newMap.values()) {
			oldKB = oldMap.get(kb.Id);
			if(kb.IsMasterLanguage) {
				//Condition to check the article is rejected from TR queue.
				if('Draft'.equals(kb.ValidationStatus) && 'Pending Technical Review'.equals(oldKB.ValidationStatus) && (kb.Technical_Reviewer_Rejected__c == true)) {

					if(kb.TR_Approval__c) {
						Approval.unlock(kb.Id);
						if(kb.Is_Pending_TR_Version_Published__c) {
							system.debug('inside if isPendingTR Version');
							setkbArticleId.add(kb.KnowledgeArticleId);
							//KbManagement.PublishingService.publishArticle(kb.KnowledgeArticleId, false);
						}
					}
				}
			}
		}

		// for(Id kbArticleId : setkbArticleId) {
		//   KbManagement.PublishingService.editOnlineArticle(kbArticleId, true);
		// }
	}
	/* Tag 5 */



	/**
	 *————————————————————————————————————————————————————
	 * @Description: Checks if AQI Score is applied for the Knowledge article
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void validateAQI(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
		Knowledge__kav oldKB;
		Id migrationUsr =  Label.KB_Migration_userid;
		for(Knowledge__kav kb : newMap.values()) {
			oldKB = oldMap.get(kb.Id);

			if(!kb.Contributed_KB__c) {
				//Is Current User Direct Approver - Start - /*<8>*/
				if(kb.CreatedById!=migrationUsr && !kb.Contributed_KB__c && kb.Is_Author_Direct_Approver__c)
				{
					//kb.addError('Please evaluate the AQI and click Apply' + ' ' + kb.ValidationStatus + String.valueOf(kb.AQI_Score__c));
					if((kb.AQI_Score__c == NULL || kb.AQI_Score__c  == 0) && kb.ValidationStatus == 'Pending Content Review')
					{
						kb.addError('Please evaluate the AQI and click Apply');
					}
				}
				//Is Current User Direct Approver - End - /*</8>*/
				else if(kb.CreatedById!=migrationUsr && !kb.Contributed_KB__c && (kb.AQI_Score__c == NULL || kb.AQI_Score__c  == 0)
				        && oldKB.Content_Reviewed_Date__c != kb.Content_Reviewed_Date__c && kb.Content_Approved__c) {                 /* Tag 2 */
					// kb.TR_Submitted_Date__c = null;
					// kb.ValidationStatus = 'Published';
					kb.addError('Please evaluate the AQI and click Apply');
				}else if(kb.CreatedById==migrationUsr && !kb.Contributed_KB__c && (kb.AQI_Score__c == NULL || kb.AQI_Score__c  == 0) && !kb.Content_Update__c && oldKB.Content_Reviewed_Date__c != kb.Content_Reviewed_Date__c) {
					kb.addError('Please select the Content Update flag and click Apply');
				}
			}         /*else if(kb.Contributed_KB__c && !kb.Content_Update__c && oldKB.Content_Reviewed_Date__c != kb.Content_Reviewed_Date__c){
			                                kb.Content_Update__c = true;
			                                if(kb.Content_Update__c){
			                                                        kb.addError('Please select the Content Update flag and click Apply');
			                                }

			                        }*/
		}

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    newList and oldMap
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	/*public void validateLanguage(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
	                Set<Id> masterids = new Set<Id>();
	                for(Knowledge__kav kb : newList){
	                                                if(!kb.IsMasterLanguage){
	                                                                masterids.add(kb.MasterVersionId);
	                                                }
	                }
	                if(masterids.size() > 0){
	                                                Map<id,Knowledge__kav>  kavmap= new Map<Id,Knowledge__kav  >([Select Id,PublishStatus  from Knowledge__kav where Id in :masterids]);
	                                                for(Knowledge__kav kav : newList){
	                                                                if(kavmap.get(kav.MasterVersionId).PublishStatus != 'Online'){
	                                                                                                kav.addError('You cannot create Translation article');
	                                                                }
	                                                }
	                }
	   }*/

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void resetURLName(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
		for(Knowledge__kav kb : newList) {
			if(kb.UrlName != kb.ArticleNumber) {
				//   kb.UrlName = kb.ArticleNumber;
			}
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void updateURLName(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
		List<Knowledge__kav> lstKnowledgeToUpdate = new List<Knowledge__kav>();
		for(Knowledge__kav kb : newList) {
			if(kb.isMasterLanguage && kb.UrlName != kb.ArticleNumber) {
				Knowledge__kav kbToUpdate = new Knowledge__kav(Id=kb.Id);
				//kbToUpdate.UrlName = kb.ArticleNumber;
				lstKnowledgeToUpdate.add(kbToUpdate);
			}
		}

		/*if(!lstKnowledgeToUpdate.isEmpty()){
		                update lstKnowledgeToUpdate;
		   }*/
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void resetFieldValues(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
		for(Knowledge__kav kb : newList) {
			if(kb.IsMasterLanguage) {
				kb.ValidationStatus = 'Draft';
				kb.AQI_Score__c = null;

				kb.Rejected_By_Content_Reviewer__c = null;
				kb.Content_Reviewer_Rejected__c = false;
				kb.Content_Approved__c = false;
				kb.Is_Content_Reviewer_Assigned__c = false;
				kb.Content_Review_Date__c = null;
				kb.Content_Reviewed_Date__c = null;
				kb.CR_Wait_Time__c = null;

				kb.Rejected_By_Technical_Reviewer__c = null;
				kb.Technical_Reviewer_Rejected__c = false;
				kb.Is_Tech_Reviewer_Assigned__c = false;
				kb.TR_Approved_Date__c = null;
				kb.TR_Submitted_Date__c = null;
				kb.TR_Wait_Time__c = null;
				kb.TR_Approval__c = false;
				kb.Is_Pending_TR_Version_Published__c = false;
				if(kb.Created_By__c == null && kb.Case__c == null ) {
					kb.Created_By__c = kb.OwnerId;
				}
			}
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void setValues(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {

		Map<Id,Id> kbcreatedids = new Map<Id,Id>();
		Set<Id> kbarticleids   = new Set<Id>();

		for(Knowledge__kav kb : newList) {
			kbarticleids.add(kb.KnowledgeArticleId);
			if(!String.isEmpty(kb.Expiry_Term__c)) {
				Integer monthsToExpiry = Integer.valueOf(kb.Expiry_Term__c.left(2));
				Datetime createdDate = System.today();
				if(kb.CreatedDate != null) {
					createdDate = kb.CreatedDate;
				}
				kb.Expiration_Date__c = createdDate.addMonths(monthsToExpiry).date();
			}
			kb.IsVisibleInPkb = kb.Visible_In_Public_Knowledge_Base__c;
			if(kb.IsVisibleInPkb) {
				kb.IsVisibleInCsp = true;
				kb.IsVisibleInPrm = true;
			}
		}

		for(Knowledge__kav kavarticle : [SELECT Id,KnowledgeArticleId,Original_Author__c FROM Knowledge__kav WHERE IsLatestVersion = False AND PublishStatus = 'Archived' AND KnowledgeArticleId IN :kbarticleids Order By VersionNumber asc]) {
			if(kavarticle.Original_Author__c != null) {
				System.debug('Found last archived version - ' + kavarticle);
				kbcreatedids.put(kavarticle.KnowledgeArticleId, kavarticle.Original_Author__c );
			}
		}

		for(Knowledge__kav kb : newList) {
			if(String.isBlank(kb.Original_Author__c)) {
				if(kbcreatedids.size() > 0 && kbcreatedids.get(kb.KnowledgeArticleId) != null && kbcreatedids.get(kb.KnowledgeArticleId) != kb.Original_Author__c) {
					kb.Original_Author__c = kbcreatedids.get(kb.KnowledgeArticleId);
				} else if (kbcreatedids.size() == 0 || kbcreatedids.get(kb.KnowledgeArticleId) == null) {
					kb.Original_Author__c  = kb.Created_By__c;
				}
			}

			kb.Last_Modified_Date__c = system.now();
			kb.Expert_Author__c = checkUserHasCustomPermissionAccess(kb.Created_By__c,'KB_Direct_Publish_User');

		}

	}



	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To Check whether user has custom permission
	 *————————————————————————————————————————————————————
	 * @param    Userid, String
	 * @return   Boolean
	 *————————————————————————————————————————————————————
	 **/

	public static Boolean checkUserHasCustomPermissionAccess(Id userId, String customPermissionName) {
		Set < Id > permissionSetIds = new Set < Id >();
		List < User > userList = new List < User >();
		for ( SetupEntityAccess access : [ SELECT ParentId FROM SetupEntityAccess
		                                   WHERE SetupEntityId IN ( SELECT Id FROM CustomPermission WHERE DeveloperName = :customPermissionName )])
			permissionSetIds.add(access.ParentId);
		userList = [ SELECT Username FROM User WHERE Id IN (
				     SELECT AssigneeId FROM PermissionSetAssignment
				     WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: userId ) ];
		return userList.isEmpty() ? false : true;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To capture the Content/Technical reviewer who rejects the article submission
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void captureReviewer(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {
		Knowledge__kav oldKB;
		for(Knowledge__kav kb : newMap.values()) {
			oldKB = oldmap.get(kb.Id);

			//Capture the user who rejected
			System.debug('captureReviewer, before update, Validation Status - ' + kb.ValidationStatus + ' (old-' + oldKB.ValidationStatus + ')');
			if(kb.isMasterLanguage && oldKB.ValidationStatus != kb.ValidationStatus) {
				if('Draft'.equals(kb.ValidationStatus)) {
					System.debug('captureReviewer, before update, inside IF 1');

					if(kb.Is_Article_Recalled__c == true)
					{

					}
					else if('Pending Content Review'.equals(oldKB.ValidationStatus) && kb.Content_Reviewer_Rejected__c) {
						System.debug('captureReviewer, before update, inside IF 11');
						kb.Rejected_By_Content_Reviewer__c = UserInfo.getUserId();
						kb.Is_Content_Reviewer_Assigned__c = true;
						// kb.Content_Reviewer_Rejected__c = false;
						// kb.AQI_Score__c = 0; /* Tag 2 */
						kb.GDPR_Acknowledgement_by_Author__c = false; /* Tag 3 */
						kb.GDPR_Acknowledgement_by_CR__c = false; /* Tag 3 */
						KBNotifyAuthor.sendNotificationContentOnRejection(kb,'Content Reviewer');
						KBNotifyAuthor.sendChatterPostOnRejection(kb,'Content Reviewer');
						//KBNotifyAuthor.sendEmailAlertContentOnRejection(kb,'Content Reviewer');
					} else if ('Pending Technical Review'.equals(oldKB.ValidationStatus) && kb.Technical_Reviewer_Rejected__c) {
						System.debug('captureReviewer, before update, inside IF 12');
						kb.Rejected_By_Technical_Reviewer__c = UserInfo.getUserId();
						kb.Is_Tech_Reviewer_Assigned__c = true;
						// kb.Technical_Reviewer_Rejected__c = false;
						kb.GDPR_Acknowledgement_by_Author__c = false; /* Tag 3 */
						KBNotifyAuthor.sendNotificationContentOnRejection(kb,'Technical Reviewer');
						KBNotifyAuthor.sendChatterPostOnRejection(kb,'Technical Reviewer');
						//KBNotifyAuthor.sendEmailAlertContentOnRejection(kb,'Technical Reviewer');
					}
				}else if('Pending Technical Review'.equals(kb.ValidationStatus) && 'Pending Content Review'.equals(oldKB.ValidationStatus)) {
					//to capture the content reviewer on approval
					kb.Rejected_By_Content_Reviewer__c = UserInfo.getUserId();
					kb.Content_Reviewer_Rejected__c = false;
				}else if('Published'.equals(kb.ValidationStatus) && 'Pending Technical Review'.equals(oldKB.ValidationStatus)) {
					//to capture the technical review on approval
					kb.Rejected_By_Technical_Reviewer__c = UserInfo.getUserId();
					kb.Technical_Reviewer_Rejected__c = false;
				}
			}
			System.debug('captureReviewer, before update, Rejected_By_Content_Reviewer__c - ' + kb.Rejected_By_Content_Reviewer__c);
			System.debug('captureReviewer, before update, Rejected_By_Technical_Reviewer__c - ' + kb.Rejected_By_Technical_Reviewer__c);
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void copyRelatedArticlesReferrenceInKB(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
		List<Related_KB__c> lstRelatedKBToInsert = new List<Related_KB__c>();
		for(Knowledge__kav kb : newList) {
			List<Knowledge__kav> lstKnowledgeVersion = [SELECT Id FROM Knowledge__kav WHERE IsLatestVersion = True AND PublishStatus = 'Online' AND KnowledgeArticleId = :kb.KnowledgeArticleId];
			System.debug('copyRelatedArticlesReferrenceInKB...... count 1 = ' + lstKnowledgeVersion.size());
			if(lstKnowledgeVersion.isEmpty()) {
				lstKnowledgeVersion = [SELECT Id FROM Knowledge__kav WHERE IsLatestVersion = False AND PublishStatus = 'Archived' AND KnowledgeArticleId = :kb.KnowledgeArticleId Order By VersionNumber Desc];
			}
			System.debug('copyRelatedArticlesReferrenceInKB...... count 2 = ' + lstKnowledgeVersion.size());
			if(!lstKnowledgeVersion.isEmpty()) {
				Knowledge__kav kavLatest = lstKnowledgeVersion.get(0);
				List<Knowledge__kav> currentKBList = new List<Knowledge__kav>();
				currentKBList.add(kavLatest);
				updateRelatedArticlesReferrenceInKB(currentKBList);
				List<Related_KB__c> lstRelatedKB = [SELECT Referred_Article__c,Referred_In__c FROM Related_KB__c WHERE Referred_In__c = :kavLatest.Id ]; /* Tag 4 */
				lstRelatedKB = validateRelatedArticles(lstRelatedKB);
				for(Related_KB__c relatedKB : lstRelatedKB) {
					Related_KB__c relatedKBNew = new Related_KB__c();
					relatedKBNew.Referred_In__c = kb.Id;
					relatedKBNew.Referred_Article__c = relatedKB.Referred_Article__c;
					lstRelatedKBToInsert.add(relatedKBNew);
				}
			}
		}
		if(!lstRelatedKBToInsert.isEmpty()) {
			System.debug('copyRelatedArticlesReferrenceInKB...... inserting related KBs');
			insert lstRelatedKBToInsert;
		}
	}


	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public List<Related_KB__c> validateRelatedArticles(List<Related_KB__c> lstCurrentRelatedKB) {
		//List<Related_KB__c> lstCurrentRelatedKB = [Select Id,Referred_In__c,Referred_Article__c from Related_KB__c where Referred_In__r.Id = 'ka0P00000001TEcIAM'];
		List<Related_KB__c> lstFinalRelatedKB = new List<Related_KB__c>();
		try{
			if(lstCurrentRelatedKB.size() != 0)
			{
				Set<Id> setFinalRelatedKBIds = new Set<Id>();
				Set<Id> setKnowledgeArticleIds = new Set<Id>();
				Id idParentKB = null;


				Id idParentKBId = lstCurrentRelatedKB[0].Referred_In__c;

				for(Related_KB__c relkb : lstCurrentRelatedKB) {
					setFinalRelatedKBIds.add(relkb.Referred_Article__c);
					lstFinalRelatedKB.add(relkb);
				}

				// List<String> testforid = new List<String>();
				// for(Related_KB__c relkb : lstFinalRelatedKB) {
				//       testforid.add(relkb.Referred_In__c);
				// }
				// System.debug(String.valueOf(testforid));



				// System.debug(String.valueOf(lstFinalRelatedKB.size()));


				List<Knowledge__kav> lstGetArchivedKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId from Knowledge__kav where Id IN:setFinalRelatedKBIds AND PublishStatus ='Archived' AND IsLatestVersion = True];

				System.debug(String.valueOf(lstGetArchivedKB.size()));

				if(lstGetArchivedKB.size() != 0)
				{
					for(Knowledge__kav actkb : lstGetArchivedKB) {
						lstFinalRelatedKB = removeObjectFromListById(lstFinalRelatedKB,actkb.Id,'Referred_Article__c');
					}
				}

				//System.debug(String.valueOf(lstFinalRelatedKB.size()));

				List<Knowledge__kav> lstGetNonArchivedKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId from Knowledge__kav where Id IN:setFinalRelatedKBIds AND PublishStatus ='Archived' AND IsLatestVersion = False];

				if(lstGetNonArchivedKB.size() != 0)
				{
					for(Knowledge__kav actkb : lstGetNonArchivedKB) {
						setKnowledgeArticleIds.add(actkb.KnowledgeArticleId);
						lstFinalRelatedKB = removeObjectFromListById(lstFinalRelatedKB,actkb.Id,'Referred_Article__c');
					}

					List<Knowledge__kav> lstGetNonArchivedActualKB = new List<Knowledge__kav>();
					if(setKnowledgeArticleIds.size() != 0)
					{
						lstGetNonArchivedActualKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId from Knowledge__kav where KnowledgeArticleId IN:setKnowledgeArticleIds AND PublishStatus ='Online' AND IsLatestVersion = True];
					}

					for(Knowledge__kav actkb :lstGetNonArchivedActualKB)
					{
						Related_KB__c relatedKBNew = new Related_KB__c();
						relatedKBNew.Referred_In__c = idParentKBId;
						relatedKBNew.Referred_Article__c = actkb.Id;
						lstFinalRelatedKB.add(relatedKBNew);
					}

				}

				// for(Related_KB__c relkb : lstFinalRelatedKB) {
				//   Related_KB__c relatedKBNew = new Related_KB__c();
				//   relatedKBNew.Referred_In__c = relkb.Referred_In__c;
				//   relatedKBNew.Referred_Article__c = relkb.Referred_Article__c;
				//   lstFinalRelatedKB.add(relatedKBNew);
				// }

				// testforid = new List<String>();
				// for(Related_KB__c relkb : lstFinalRelatedKB) {
				//   testforid.add(relkb.Referred_In__c);
				// }
				// System.debug(String.valueOf(testforid));

				// System.debug(String.valueOf(lstGetNonArchivedKB.size()));

				// System.debug(String.valueOf(lstFinalRelatedKB.size()));
			}

		}catch(Exception ex) {
			lstFinalRelatedKB = lstCurrentRelatedKB;
			System.debug('validateRelatedArticles Method : exception occurred - ' + ex.getMessage());
		}
		return lstFinalRelatedKB;
	}

	/**
	 *
	 */
	public List<Related_KB__c> removeObjectFromListById(List<Related_KB__c> lst, Id objRecId,String strSourceFieldName) {
		for (Integer i = lst.size() - 1; i >= 0; --i) {
			if (lst.get(i).get(strSourceFieldName) == objRecId) {
				lst.remove(i);
			}
		}
		return lst;
	}


	public void updateRelatedArticlesReferrenceInKB(List<Knowledge__kav> newList) {
		try
		{
			for(Knowledge__kav kb : newList) {
				//List<Related_KB__c> lstCurrentRelatedKB = [Select Id,Referred_In__c,Referred_Article__c from Related_KB__c where Related_KB__c = 'ka0P00000001TEcIAM'];
				List<Related_KB__c> lstCurrentRelatedKB = [SELECT Id,Referred_Article__c,Referred_In__c,Referred_ArticleNumber__c FROM Related_KB__c WHERE Referred_In__c = :kb.Id ];
				if(lstCurrentRelatedKB.size() != 0)
				{
					System.debug('updateRelatedArticlesReferrenceInKB lstCurrentRelatedKB : '+ String.valueOf(lstCurrentRelatedKB.size()));
					List<Related_KB__c> lstUpdateRelatedKBs = new List<Related_KB__c>();


					Set<Id> setCurrentRelatedKBIds = new Set<Id>();
					Set<String> setCurrentRelatedKBArticleNumbers = new Set<String>();
					Set<Id> setKnowledgeArticleIds = new Set<Id>();
					Set<Id> setDeleteKBReferenceIds = new Set<Id>();
					Set<Id> setUpdateCurrentKBReferenceIds = new Set<Id>();
					Set<Id> setUpdateNewKBReferenceIds = new Set<Id>();
					Set<Id> setCurrentKBReferenceIds = new Set<Id>();


					Set<Id> setDeleteRelatedKBIds = new Set<Id>();
					Set<Id> setUpdateRelatedKBIds = new Set<Id>();

					Map<Id, Id> mapCurrentKavIdToRelatedKBId = new Map<Id, Id>();

					Map<Id, Id> mapUpdateNewRelatedKBIdToKavId = new Map<Id, Id>();

					Map<Id, Id> mapUpdateCurrentArticleIdToKavId = new Map<Id, Id>();

					Map<Id, Id> mapUpdateNewArticleIdToKavId = new Map<Id, Id>();

					Map<Id, Id> mapUpdateCurrentKavIdToNewKavId = new Map<Id, Id>();

					Map<String,Id> mapUpdateCurrentKavIdToArticleNumber = new Map<String,Id>();


					Id idParentKB = null;


					Id idParentKBId = lstCurrentRelatedKB[0].Referred_In__c;

					System.debug('updateRelatedArticlesReferrenceInKB setCurrentKBReferenceIds : '+ String.valueOf(setCurrentKBReferenceIds.size()));

					for(Related_KB__c relkb : lstCurrentRelatedKB)
					{
						if(relkb.Referred_Article__c == null && relkb.Referred_ArticleNumber__c != null)
						{
							setCurrentRelatedKBArticleNumbers.add(relkb.Referred_ArticleNumber__c);
						}
						setCurrentKBReferenceIds.add(relkb.Referred_Article__c);
						mapCurrentKavIdToRelatedKBId.put(relkb.Referred_Article__c, relkb.Id);
					}


					List<Knowledge__kav> lstGetPublishedKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId,ArticleNumber from Knowledge__kav where ArticleNumber IN:setCurrentRelatedKBArticleNumbers AND PublishStatus ='Online'];

					System.debug('updateRelatedArticlesReferrenceInKB lstGetPublishedKB : '+ String.valueOf(lstGetPublishedKB.size()));
					if(lstGetPublishedKB.size() != 0)
					{
						for(Knowledge__kav actkb : lstGetPublishedKB)
						{
							mapUpdateCurrentKavIdToArticleNumber.put(actkb.ArticleNumber,actkb.Id);
						}

						for(Related_KB__c relkb : lstCurrentRelatedKB)
						{
							if(mapUpdateCurrentKavIdToArticleNumber.get(relkb.Referred_ArticleNumber__c) != null)
							{
								System.debug('updateRelatedArticlesReferrenceInKB mapUpdateCurrentKavIdToArticleNumber : '+ String.valueOf(mapUpdateCurrentKavIdToArticleNumber.get(relkb.Referred_ArticleNumber__c)));
								relkb.Referred_Article__c = mapUpdateCurrentKavIdToArticleNumber.get(relkb.Referred_ArticleNumber__c);
								lstUpdateRelatedKBs.add(relkb);
							}
						}

					}


					List<Knowledge__kav> lstGetArchivedKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId,ArticleNumber from Knowledge__kav where Id IN:setCurrentKBReferenceIds AND PublishStatus ='Archived' AND IsLatestVersion = True];


					System.debug('updateRelatedArticlesReferrenceInKB lstGetArchivedKB : '+ String.valueOf(lstGetArchivedKB.size()));

					if(lstGetArchivedKB.size() != 0)
					{
						for(Knowledge__kav actkb : lstGetArchivedKB)
						{
							setDeleteKBReferenceIds.add(actkb.Id);
						}

						for(Id idDeleteKbRefId : setDeleteKBReferenceIds)
						{
							setDeleteRelatedKBIds.add(mapCurrentKavIdToRelatedKBId.get(idDeleteKbRefId));
						}



						if(setDeleteRelatedKBIds.size() != 0)
						{
							Delete [SELECT Id from Related_KB__c where Id in : setDeleteRelatedKBIds ];
							System.debug('updateRelatedArticlesReferrenceInKB DELETE : '+ String.valueOf(setDeleteRelatedKBIds.size()));
						}

						System.debug('updateRelatedArticlesReferrenceInKB setDeleteRelatedKBIds : '+String.valueOf(setDeleteRelatedKBIds.size()));
					}


					List<Knowledge__kav> lstGetNonArchivedKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId,ArticleNumber from Knowledge__kav where Id IN:setCurrentKBReferenceIds AND PublishStatus ='Archived' AND IsLatestVersion = False];

					System.debug('updateRelatedArticlesReferrenceInKB lstGetNonArchivedKB : '+ String.valueOf(lstGetNonArchivedKB.size()));

					if(lstGetNonArchivedKB.size() != 0)
					{
						for(Knowledge__kav actkb : lstGetNonArchivedKB) {
							setKnowledgeArticleIds.add(actkb.KnowledgeArticleId);
							setUpdateCurrentKBReferenceIds.add(actkb.Id);
							mapUpdateCurrentArticleIdToKavId.put(actkb.KnowledgeArticleId,actkb.Id);
						}

						List<Knowledge__kav> lstGetNonArchivedActualKB = new List<Knowledge__kav>();
						if(setKnowledgeArticleIds.size() != 0)
						{
							lstGetNonArchivedActualKB = [Select Id,PublishStatus, ValidationStatus,IsLatestVersion,KnowledgeArticleId,ArticleNumber from Knowledge__kav where KnowledgeArticleId IN:setKnowledgeArticleIds AND PublishStatus ='Online' AND IsLatestVersion = True];
						}

						for(Knowledge__kav actkb :lstGetNonArchivedActualKB)
						{
							mapUpdateNewArticleIdToKavId.put(actkb.KnowledgeArticleId,actkb.Id);
							setUpdateNewKBReferenceIds.add(actkb.Id);
						}

						for(Id mapId :mapUpdateCurrentArticleIdToKavId.keySet())
						{
							mapUpdateCurrentKavIdToNewKavId.put(mapUpdateCurrentArticleIdToKavId.get(mapId), mapUpdateNewArticleIdToKavId.get(mapId));
						}

						for(Id mapId :mapUpdateCurrentKavIdToNewKavId.keySet())
						{
							mapUpdateNewRelatedKBIdToKavId.put(mapCurrentKavIdToRelatedKBId.get(mapId), mapUpdateCurrentKavIdToNewKavId.get(mapId));
						}

						for(Related_KB__c relatedKB : [Select Id,Referred_Article__c,Referred_In__c,Referred_ArticleNumber__c From Related_KB__c Where Id in:mapUpdateNewRelatedKBIdToKavId.keySet()]) {
							relatedKB.Referred_Article__c = mapUpdateNewRelatedKBIdToKavId.get(relatedKB.Id);
							lstUpdateRelatedKBs.add(relatedKB);
						}
						System.debug('updateRelatedArticlesReferrenceInKB lstGetNonArchivedKB : '+ String.valueOf(lstGetNonArchivedKB.size()));
					}

					if(lstUpdateRelatedKBs.size() != 0)
					{
						System.debug('updateRelatedArticlesReferrenceInKB UPDATE : '+ String.valueOf(lstUpdateRelatedKBs.size()));

						update lstUpdateRelatedKBs;
					}

				}
			}
		}
		catch(Exception ex) {
			System.debug('updateRelatedArticlesReferrenceInKB Method : exception occurred - ' + ex.getMessage());
		}
	}



	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void copyFiles(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
		Set<Id> setArticleId = new Set<Id>();
		for(Knowledge__kav kb : newList) {
			if(!kb.IsMasterLanguage) {
				setArticleId.add(kb.KnowledgeArticleId);
			}
		}

		if(!setArticleId.isEmpty()) {
			List<Knowledge__kav> lstKnowledgeVersion = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav
			                                            WHERE IsMasterLanguage = True AND PublishStatus = 'Online'
			                                                                                              AND KnowledgeArticleId in :setArticleId];

			Set<Id> setKAVId = new Set<Id>();
			Map<Id, Id> mapArticleIdToKAVId = new Map<Id, Id>();
			for(Knowledge__kav kb : lstKnowledgeVersion) {
				setKAVId.add(kb.Id);
				mapArticleIdToKAVId.put(kb.KnowledgeArticleId, kb.Id);
			}


			List<ContentDocumentLink> lstFile = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId in :setKAVId And IsDeleted=false];

			List<ContentDocumentLink> lstFileToInsert = new List<ContentDocumentLink>();
			for(Knowledge__kav kb : newList) {
				if(!kb.IsMasterLanguage) {
					for(ContentDocumentLink file : lstFile) {
						if(file.LinkedEntityId == mapArticleIdToKAVId.get(kb.KnowledgeArticleId)) {
							ContentDocumentLink fileNew = new ContentDocumentLink();
							fileNew.LinkedEntityId = kb.Id;
							fileNew.ContentDocumentId = file.ContentDocumentId;
							fileNew.ShareType = file.ShareType;
							fileNew.Visibility = file.Visibility;
							lstFileToInsert.add(fileNew);
						}
					}
				}
			}

			if(!lstFileToInsert.isEmpty()) {
				System.debug('copyFiles...... inserting files');
				insert lstFileToInsert;
			}
		}

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To Load Data Categories
	 *
	 *————————————————————————————————————————————————————
	 * @param    New and old map
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void updateDataCategories(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {

		/*
		   Delete all existing data categories when product, version, component, secondary product, problem type are updated
		   Create Product_version, Product_component, Problem_Type data category entries for each secondary product selected or  only when primary product is selected
		   Create Product_component entry for component
		   Create Problem_Type data category entry for  problem type
		   Create Product_version data category entry for each version selected
		 */

		Knowledge__kav oldKB;

		//To hold Map of KB records for Data categories to be udpated
		Map<Id,Knowledge__kav> kbmap= new Map<Id,Knowledge__kav>();

		// To get list of versions, Products associated to KB article
		Map<Id, List<String> > kbprVersion = new Map<Id, List<String> >();
		Map<Id, List<String> > kbpr = new Map<Id,List<String> >();

		for(Knowledge__kav kb : newMap.values()) {
			system.debug('value of kb'+kb.PublishStatus);
			system.debug('value of kb'+kb.ValidationStatus);
			if(oldmap != null) {
				oldKB = oldmap.get(kb.Id);
			}

			if(oldMap == null || (oldMap != null && (oldKB.Primary_Product__c!= kb.Primary_Product__c|| oldKB.Product_Version__c != kb.Product_Version__c || oldKB.Product_Component__c != kb.Product_Component__c || oldKB.Problem_Type__c != kb.Problem_Type__c || oldKB.Also_Applies_To__c != kb.Also_Applies_To__c))) {

				if(kb.isMasterLanguage) {
					kbmap.put(kb.Id,kb);
					if(kb.Product_Version__c != null) {
						List<String> tempversion = new List<String>();
						tempversion.addall(kb.Product_Version__c.split(';'));
						kbprVersion.put(kb.Id,tempversion);
					}

					if(kb.Also_Applies_To__c != null) {
						List<String> temppr = new List<String>();
						temppr.addall(kb.Also_Applies_To__c.split(';'));
						kbpr.put(kb.Id,temppr);
					}


					if(kb.Primary_Product__c != null && kb.Product_Version__c == null && kb.Product_Component__c == null) {
						List<String> templist = new List<String>();
						if(kbpr != null && kbpr.get(kb.Id) != null) {
							templist = kbpr.get(kb.Id);
							templist.add(kb.Primary_Product__c);
							kbpr.put(kb.Id,templist);
						} else {
							templist.add(kb.Primary_Product__c);
							kbpr.put(kb.Id,templist);
						}
					}
				}
			}

			if(kbmap.keyset().size() > 0) {

				List<Knowledge__DataCategorySelection> insertdclist = new List<Knowledge__DataCategorySelection>();

				Delete [SELECT Id from Knowledge__DataCategorySelection where parentid in : kbmap.keyset()];

				//Map<Id,Knowledge__DataCategorySelection> kdsmap = new  Map<Id,Knowledge__DataCategorySelection> ([select id,parentid,DataCategoryName, DataCategoryGroupName from Knowledge__DataCategorySelection  where parentid in :kddataids]);
				for(Knowledge__kav tempkb: kbmap.values()) {
					if(kbpr.get(tempkb.Id) != null) {
						for(String productname : kbpr.get(tempkb.Id)) {
							Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
							kdc.parentid = tempkb.Id;
							kdc.DataCategoryGroupName = 'Product_Version';
							kdc.DataCategoryName = stringreplace(productname);
							system.debug('kdc Data Category name'+kdc.DataCategoryName);
							system.debug('kdc values'+kdc);
							insertdclist.add(kdc);
							//Knowledge__DataCategorySelection kdc2 = kdc.clone();
							//kdc2.DataCategoryGroupName = 'Problem_Type';
							//insertdclist.add(kdc2);
							Knowledge__DataCategorySelection kdc3 = kdc.clone();
							kdc3.DataCategoryGroupName = 'Product_Component';
							insertdclist.add(kdc3);
						}
					}
					if(tempkb.Problem_Type__c  != null) {
						for(String problemType : tempkb.Problem_Type__c.split(';')) {
							Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
							kdc.parentid = tempkb.Id;
							//kdc.DataCategoryGroupName = 'Problem_Type';
							//kdc.DataCategoryName = stringreplace(tempkb.Primary_Product__c) + '_' + stringreplace(tempkb.Problem_Type__c);
							kdc.DataCategoryGroupName = 'Problem_Type_2';
							kdc.DataCategoryName = stringreplace(problemType);
							system.debug('kdc Data Category name'+kdc.DataCategoryName);
							system.debug('kdc values'+kdc);
							insertdclist.add(kdc);
						}
					}
					if(tempkb.Product_Component__c != null) {
						Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
						kdc.parentid = tempkb.Id;
						kdc.DataCategoryGroupName = 'Product_Component';
						//system.debug('comp'+tempkb.Product_Component__c);
						kdc.DataCategoryName = stringreplace(tempkb.Primary_Product__c) + '_' + stringreplace(tempkb.Product_Component__c);
						system.debug('kdc Data Category name'+kdc.DataCategoryName);
						system.debug('kdc values'+kdc);
						insertdclist.add(kdc);
					}
					if(kbprVersion.get(tempkb.Id) != null) {
						for(String ver: kbprVersion.get(tempkb.Id)) {
							Knowledge__DataCategorySelection kdc = new Knowledge__DataCategorySelection();
							kdc.parentid = tempkb.Id;
							kdc.DataCategoryGroupName = 'Product_Version';
							kdc.DataCategoryName = stringreplace(tempkb.Primary_Product__c) + '_' + stringreplace(ver);
							system.debug('kdc Data Category name'+kdc.DataCategoryName);
							system.debug('kdc values'+kdc);
							insertdclist.add(kdc);
						}
					}
				}

				if(insertdclist.size() > 0) {
					System.debug('data catagories - '+insertdclist);
					try{
						insert insertdclist;
					}catch(Exception ex) {
						System.debug('exception occurred - ' + ex.getMessage());
					}
				}

			}
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 *
	 *————————————————————————————————————————————————————
	 * @param    New List
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void validateProduct(List<Knowledge__kav> newList) {
		for(Knowledge__kav kb : newList) {
			if(kb.Also_Applies_To__c!=null) {
				List<String> lstProductSecondary = kb.Also_Applies_To__c.split(';');
				if(lstProductSecondary.contains(kb.Primary_Product__c)) {
					kb.addError('The Primary Product and "Also Applies To" Product cannot be the same. If applicable, please choose a different product that this article also applies to.');
				}
			}
		}
	}


	public Boolean validateUser(Knowledge__kav kb) {

		Boolean IsUserPAMEOLApprover = false;
		Boolean IsUserRCAApprover = false;
		Boolean Result = true;

		List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB PAM EOL Approver Group'];
		if(!objGroups.isEmpty())
		{
			String grpId = objGroups[0].Id;
			List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
			if(!objGroupMembers.isEmpty())
			{
				IsUserPAMEOLApprover = true;
			}
		}

		List<Group> objRCAGroups = [Select Id,Name,Type from Group WHERE Name ='KB RCA Approver Group'];
		if(!objRCAGroups.isEmpty())
		{
			String grpId = objRCAGroups[0].Id;//<13>
			List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
			if(!objGroupMembers.isEmpty())
			{
				IsUserRCAApprover = true;
			}
		}

		if(((!IsUserPAMEOLApprover) && ((kb.Article_Type__c == 'Product Release') || (kb.Article_Type__c == 'Support Guide') || (kb.Article_Type__c == 'PAM EOL Support Statement'))) || ((!IsUserRCAApprover) && ((kb.Article_Type__c == 'RCA'))))
		{
			Result = false;
		}

		return Result;
	}

	//Is Current User PAM EOL Approver - End - /*<9>*/

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To return formatted value
	 *
	 *————————————————————————————————————————————————————
	 * @param    String
	 * @return   String
	 *————————————————————————————————————————————————————
	 **/

	public static String stringreplace(String s1){
		return s1.replace(' ','_').replace('(','_').replace(')','_').replace('.','_').replace('/','_').replace('{','_').replace('-','_').replace('}','_').replace('___','_').replace('__','_').removeEnd('_');

	}

	public static String getApprovalProcessName(Id kavId){
		Knowledge__kav kb = [Select Id, IsVisibleInPkb, ValidationStatus, Content_Approved__c, TR_Approval__c, Is_Tech_Reviewer_Assigned__c,Primary_Product__c,
		                     Rejected_By_Technical_Reviewer__c,ArticleCreatedById,Created_By__c,Article_Type__c
		                     From Knowledge__kav Where Id = :kavId];                    //Is Current user is PAM EOL Approver - /*<9>*/


		String approvalProcessName = '';
		if('Draft'.equals(kb.ValidationStatus)) {
			//Is Current User Direct Approver And Author - Start - /*<7>*/
			Boolean IsUserDirectApprover = false;
			Boolean IsUserArticleAuthor = false;
			Boolean IsUserArticleContributor = false;

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Direct Approver Group'];
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
				if(!objGroupMembers.isEmpty())
				{
					IsUserDirectApprover = true;
				}

			}

			if(kb.ArticleCreatedById == UserInfo.getUserId())
			{
				IsUserArticleAuthor = true;
			}

			if((kb.Created_By__c != null) && (kb.Created_By__c == UserInfo.getUserId()))
			{
				IsUserArticleContributor = true;
			}

			//Is Current User Direct Approver And Author - End - /*</7>*/

			//Is Current Article if for PAM EOL Support Statement - Start - /*<9>*/
			if((!kb.IsVisibleInPkb) || ((kb.IsVisibleInPkb) && ((kb.Article_Type__c == 'Product Release') || (kb.Article_Type__c == 'Support Guide') || (kb.Article_Type__c == 'PAM EOL Support Statement') || (kb.Article_Type__c == 'RCA')))) {
				approvalProcessName = 'KB_Auto_Approval';
			}
			//Is Current Article if for PAM EOL Support Statement - End -  /*<9>*/
			//Start -  /*<13>*/
			else if((IsUserDirectApprover) && ((IsUserArticleAuthor) || (IsUserArticleContributor)) && (!kb.Content_Approved__c) && (kb.TR_Approval__c))
			{
				approvalProcessName = 'KB_Direct_Approval_Technical_Review'; 
			}
			//End -  /*<13>*/
			else if((IsUserDirectApprover) && ((IsUserArticleAuthor) || (IsUserArticleContributor)) && (!kb.Content_Approved__c)) /*<7>*/
			{
				approvalProcessName = 'KB_Direct_Approval'; /*<7>*/
			}
			else if(!kb.Content_Approved__c) {
				approvalProcessName = 'KB_Content_Review';
			}else if(kb.TR_Approval__c) {
				approvalProcessName = 'KB_Technical_Review';
			}
		}
		System.debug('submitted for approval - ' + approvalProcessName);

		return approvalProcessName;
	}

	//Start -  /*<13>*/
	public static String processDirectApprovalWithTR(Id kavId){

		String returnMsg = '';

		ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kavId];
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('content approved!');
		req.setAction('Approve');
		req.setWorkitemId(workItem.Id);
		Approval.process(req);

		Knowledge__kav kblatest = [Select Id, Title, IsVisibleInPkb,ArticleNumber, Primary_Product__c, ValidationStatus, Content_Approved__c, TR_Approval__c, Is_Tech_Reviewer_Assigned__c,
									Rejected_By_Technical_Reviewer__c,Product_Version__c,Product_Component__c,CreatedById
									From Knowledge__kav Where Id = :kavId];

		if('Pending Technical Review'.equals(kblatest.ValidationStatus)) {

			if(kblatest.TR_Approval__c) {
				String childapprovalProcessName = 'KB_Technical_Review';
				
				String articleForApprovalId;

				Approval.unlock(kblatest.Id);

				kblatest.Is_Pending_TR_Version_Published__c = true;

				update kblatest;

				returnMsg = KnowledgeTriggerHelper.submitForApproval(kblatest.Id, childapprovalProcessName, 'Submitting for Technical Review', kblatest.CreatedById);
				if('SUCCESS'.equals(returnMsg)) {
					KnowledgeTriggerHelper.postToChatterGroup(kblatest.Primary_Product__c, kblatest);
					returnMsg = 'SUCCESS-DT';
				}
			}
		}

		return returnMsg;
	}
	//End -  /*<13>*/

	//get feedback record

	@AuraEnabled
	public static String getfeedbackrec(Id fdid){
		afl__afl_Article_Feedback__c fdback = [Select Id, afl__Action_Taken__c, Engineer_Comments__c, afl__Feedback_Status__c
		                                       From afl__afl_Article_Feedback__c Where Id = :fdid];
		String returnval;
		if(fdback.afl__Feedback_Status__c == 'New') {
			returnval = 'New';
		} else if(String.isblank(fdback.afl__Action_Taken__c) || String.isblank(fdback.Engineer_Comments__c)) {
			returnval = 'blank';
		} else if(fdback.afl__Feedback_Status__c == 'Pending Review') {
			returnval = 'review';
		}

		return returnval;
	}

	@AuraEnabled
	public static String submitFeedbackReview(Id fdid, String comments){
		String returnMsg = '';

		afl__afl_Article_Feedback__c fdrec = [Select Id From afl__afl_Article_Feedback__c Where Id = :fdid];

		String approvalProcessName = 'Article_Feedback_Approval';

		// submit for approval
		System.debug('submitting for approval - ' + approvalProcessName);
		if(!String.isEmpty(approvalProcessName)) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(fdid);
			req.setProcessDefinitionNameOrId(approvalProcessName);
			req.setSkipEntryCriteria(false);
			req.setComments(comments);
			req.setSubmitterId(UserInfo.getUserId());
			try{
				Approval.ProcessResult result = Approval.process(req);
				System.debug('approval submission result = '+result);
				if(result.isSuccess()) {
					returnMsg = 'SUCCESS';
				}else{
					for(Database.Error error : result.getErrors()) {
						returnMsg += error.getMessage() + ';';
					}
				}
			}catch(Exception ex) {
				if(ex.getMessage().indexOf('NO_APPLICABLE_PROCESS')>=0) {
					returnMsg = 'Not allowed to submit this Article for review!';
				}else{
					returnMsg = ex.getMessage();
				}
			}

		}

		return returnMsg;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To relate the contributed article when it gets published
	 * where its previous version (Archived) is already related to any of the article.
	 *————————————————————————————————————————————————————
	 * @param    new Map and old Map
	 * @return
	 *————————————————————————————————————————————————————
	 *
	        public void relatePublishedArticle(Map<Id,Knowledge__kav> newMap){

	                        Set<Id> knwArticleIds = new Set<Id>();
	                        for(Knowledge__kav knwRec : newMap.values()){
	                                                system.debug('knwRec'+knwRec.PublishStatus);
	                                                system.debug('knwRec'+knwRec.Id);
	                                                system.debug('knwRec'+knwRec.ValidationStatus);
	                                                if(('Published'.equals(knwRec.ValidationStatus)) || ('Pending Technical Review'.equals(knwRec.ValidationStatus) )
	                                                && 'Online'.equals(knwRec.PublishStatus)){
	                                                                        system.debug('inside');
	                                                                        knwArticleIds.add(knwRec.KnowledgeArticleId);

	                                                }
	                        }
	                        system.debug('knwArticleIds'+knwArticleIds);
	                        if(!knwArticleIds.isEmpty()){
	                                                List<Related_KB__c> relatedArticles = new List<Related_KB__c>([Select Id,Referred_In__c,Referred_Article__c,Related_Knowledge_Article_Id__c,Article_Language__c
	                                                from Related_KB__c where Related_Knowledge_Article_Id__c=:knwArticleIds]);


	                                                system.debug('relatedArticles'+relatedArticles);
	                                                List<Related_KB__c> lstOfRelatedKBs = new List<Related_KB__c>();
	                                                Set<Id> referredInIds = new Set<Id>();
	                                                if(!relatedArticles.isEmpty()){
	                                                                        for(Knowledge__kav knwRec : newMap.values()){
	                                                                                                system.debug('value of knwRec'+knwRec.KnowledgeArticleId);
	                                                                                                for(Related_KB__c relatedKbRec : relatedArticles){
	                                                                                                                        if(knwRec.KnowledgeArticleId == relatedKbRec.Related_Knowledge_Article_Id__c
	                                                                                                                        && knwRec.Language==relatedKbRec.Article_Language__c && !referredInIds.contains(relatedKbRec.Referred_In__c)){
	                                                                                                                                                Related_KB__c relatedKBNew = new Related_KB__c(Referred_Article__c=knwRec.Id,
	                                                                                                                                                Referred_In__c = relatedKbRec.Referred_In__c);

	                                                                                                                                                lstOfRelatedKBs.add(relatedKBNew);
	                                                                                                                                                referredInIds.add(relatedKbRec.Referred_In__c);
	                                                                                                                                                system.debug('referredInIds'+referredInIds);
	                                                                                                                                                system.debug('lstOfRelatedKBs'+lstOfRelatedKBs);
	                                                                                                                                                system.debug('lstOfRelatedKBs'+lstOfRelatedKBs.size());
	                                                                                                                        }
	                                                                                                }
	                                                                        }
	                                                }
	                                                if(!lstOfRelatedKBs.isEmpty()){
	                                                                        insert lstOfRelatedKBs;
	                                                }
	                        }
	        } */
	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To capture the GDPRAcknowledgement by author on submitting the article to CR/TR review.
	 *————————————————————————————————————————————————————
	 * @param    String
	 * @return   String
	 *————————————————————————————————————————————————————
	 */
	public void captureGDPRAcknowledgement(Map<Id,Knowledge__kav> newMap, Map<Id,Knowledge__kav> oldMap){

		Map<Id,String> knwArticleIdLangMap = new Map<Id,String>();
		for(Knowledge__kav knwRec : newMap.values()) {
			String strComplianceResponse = '';
			Knowledge__kav oldKnwRec = oldMap.get(knwRec.Id);

			try {
				System.debug('captureGDPRAcknowledgement - strComplianceResponse - ' + strComplianceResponse);
				if(knwRec.PublishStatus !='Archived' && knwRec.PublishStatus !='Online' && (oldKnwRec.Title!=knwRec.Title || oldKnwRec.Solution__c!=knwRec.Solution__c || oldKnwRec.Description__c!=knwRec.Description__c || oldKnwRec.Additional_Information__c!=knwRec.Additional_Information__c || oldKnwRec.Keywords__c!=knwRec.Keywords__c || knwRec.GDPR_Compliance_Data_Final__c==null))
				{
					strComplianceResponse = KBContentGovernance.getArticleGDPRComplianceInitial(knwRec.Title,knwRec.Solution__c,knwRec.Description__c,knwRec.Additional_Information__c,knwRec.Keywords__c,knwRec.RecordType.Name,knwRec.Problem_Type__c,knwRec.Primary_Product__c);
					knwRec.GDPR_Compliance_Data_Final__c = strComplianceResponse;
					knwRec.GDPR_Violated_Attributes__c = null;
				}
			} catch (Exception e) {
				System.debug('Excpetion while getting article compliance'+e.getmessage()+e.getlinenumber());
			}


			if(knwRec.Content_Review_Date__c!=null && oldKnwRec.Content_Review_Date__c!=knwRec.Content_Review_Date__c) {
				knwRec.GDPR_Acknowledgement_by_Author__c = True;
				try {
					if(knwRec.PublishStatus !='Archived' && knwRec.PublishStatus !='Online')
					{
						strComplianceResponse = KBContentGovernance.getArticleGDPRComplianceInitial(knwRec.Title,knwRec.Solution__c,knwRec.Description__c,knwRec.Additional_Information__c,knwRec.Keywords__c,knwRec.RecordType.Name,knwRec.Problem_Type__c,knwRec.Primary_Product__c);
						knwRec.GDPR_Compliance_Data_By_Author__c = strComplianceResponse;
						knwRec.GDPR_Violated_Attributes_By_Author__c = null;
						knwRec.Author_for_GDPR__c = knwRec.ArticleCreatedById;
						System.debug('captureGDPRAcknowledgement - knwRec.GDPR_Compliance_Data_By_Author__c - ' + knwRec.GDPR_Compliance_Data_By_Author__c);
						knwRec.Is_GDPR_Compliance_Ignored_By_Author__c = False;
					}
				} catch (Exception e) {
					System.debug('Excpetion while getting article compliance'+e.getmessage()+e.getlinenumber());
				}
			}else if('Draft'.equals(oldKnwRec.ValidationStatus) && 'Pending Technical Review'.equals(knwRec.ValidationStatus)) {
				knwRec.GDPR_Acknowledgement_by_Author__c = True;
			}
		}

	}

	public void captureGDPRData(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap){

		Map<Id,String> knwArticleIdLangMap = new Map<Id,String>();
		for(Knowledge__kav knwRec : newList) {
			String strComplianceResponse = '';

			try {
				System.debug('captureGDPRData - strComplianceResponse - ' + strComplianceResponse);
				if(knwRec.PublishStatus !='Archived' && knwRec.PublishStatus !='Online')
				{
					strComplianceResponse = KBContentGovernance.getArticleGDPRComplianceInitial(knwRec.Title,knwRec.Solution__c,knwRec.Description__c,knwRec.Additional_Information__c,knwRec.Keywords__c,knwRec.RecordType.Name,knwRec.Problem_Type__c,knwRec.Primary_Product__c);
					knwRec.GDPR_Compliance_Data_Initial__c = strComplianceResponse;
					knwRec.GDPR_Violated_Attributes__c = null;
				}
				//Is Current User Direct Approver - Start - /*<8>*/
				List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Direct Approver Group'];
				if(!objGroups.isEmpty())
				{
					String grpId = objGroups[0].Id;
					List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :knwRec.Created_By__c];
					if(!objGroupMembers.isEmpty())
					{
						knwRec.Is_Author_Direct_Approver__c = true;
					}
				}
				//Is Current User Direct Approver - End - /*</8>*/

				//Assign Published Version - Start - /*</9>*/
				for(Knowledge__kav kavarticle : [SELECT Id,KnowledgeArticleId,VersionNumber,Language FROM Knowledge__kav WHERE IsLatestVersion = True AND PublishStatus = 'Online' AND ValidationStatus = 'Published' AND KnowledgeArticleId =: knwRec.KnowledgeArticleId AND Language =: knwRec.Language Order By VersionNumber desc]) {
					knwRec.Published_Version_Number__c = kavarticle.VersionNumber;
				}
				//Assign Published Version - End - /*</9>*/

			} catch (Exception e) {
				System.debug('Excpetion while getting article compliance'+e.getmessage()+e.getlinenumber());
			}

		}

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To update article data where rejected article with inactive user.
	 *————————————————————————————————————————————————————
	 * @param    String
	 * @return   String
	 *————————————————————————————————————————————————————
	 */
	public void updateArticleData(Map<Id,Knowledge__kav> newMap, Map<Id,Knowledge__kav> oldMap){

		Map<Id,String> knwArticleIdLangMap = new Map<Id,String>();
		for(Knowledge__kav knwRec : newMap.values()) {

			Knowledge__kav oldKnwRec = oldMap.get(knwRec.Id);
			if(knwRec.Content_Review_Date__c!=null && knwRec.Rejected_By_Content_Reviewer__c!=null && oldKnwRec.Content_Review_Date__c!=knwRec.Content_Review_Date__c && knwRec.PublishStatus !='Archived' && knwRec.PublishStatus !='Online') {
				String rejecteduserid = knwRec.Rejected_By_Content_Reviewer__c;
				List<User> usrLst =  [Select Id from User where Id=:rejecteduserid and isActive=true];
				if(usrLst.isEmpty()) {
					knwRec.Rejected_By_Content_Reviewer__c = null;
					knwRec.Is_Content_Reviewer_Assigned__c = False;
					// List<Group> grpLst =  [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'KB Content Reviewers Queue'];
					// if(!grpLst.isEmpty()) {
					//   String crqueueid = grpLst[0].Id;
					//   knwRec.Rejected_By_Content_Reviewer__c = crqueueid;
					// }
				}
				System.debug('updateArticleData - oldKnwRec.Rejected_By_Content_Reviewer__c - ' + oldKnwRec.Rejected_By_Content_Reviewer__c);
				System.debug('updateArticleData - knwRec.Rejected_By_Content_Reviewer__c - ' + knwRec.Rejected_By_Content_Reviewer__c);
			}
			if(knwRec.Is_Article_Recalled__c == true)
			{
				knwRec.Is_Article_Recalled__c = false;
			}
		}
	}




	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * To Create topics from keywords if they dont exist.
	 * Assign topics to the knowledge record if they exist.
	 * Topics has to be unique in the sense that a space character is not considered. Ex: 'test 1' or 'test1' are considered as same topic.
	 *
	 *————————————————————————————————————————————————————
	 * @param    String
	 * @return   String
	 *————————————————————————————————————————————————————
	 *

	   public void managetopics(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap){
	   try{

	        Map<String,Id> topicmap = new Map<String,Id>();
	        Map<String,Id> topicformatmap = new Map<String,Id>();
	        for(Topic tp: [SELECT Id,Description,ManagedTopicType,Name,NetworkId,TalkingAbout,createddate FROM Topic]){
	                topicmap.put(tp.Name,tp.Id);
	                topicformatmap.put(tp.Name.replaceAll('(\\s+)', '').toLowerCase(),tp.Id);
	                system.debug('topic name'+tp.Name.replaceAll('(\\s+)', ''));
	        }


	        Map<String,Set<Id>> kbtopicmap = new Map<String,Set<Id>>();
	        Set<String> createtopics = new Set<String>();
	        Set<String> assigntopics= new Set<String>();
	        Knowledge__kav kb = newMap.values()[0];

	        Map<String,Id> topicassignmap= new Map<String,Id>();
	        Map<String,Id> topicassignformatmap = new Map<String,Id>();

	        for(TopicAssignment ta : [SELECT Id,Topic.Name from TopicAssignment where EntityId = :kb.Id]){
	                topicassignmap.put(ta.Topic.Name,ta.Id);
	                topicassignformatmap.put(ta.Topic.name.replaceAll('(\\s+)', '').toLowerCase(),ta.Id);

	        }

	        /* kbidset.add(kb.Id);
	        set<Id> tempset;
	        if(kb.keywords__c != null && kb.keywords__c.contains(';')){
	                for(String s1: kb.keywords__c.split(';')){
	                        if(kbtopicmap.get(s1) == null){
	                        kbtopicmap.put(s1,new set<Id>{kb.Id});
	                        } else {
	                        tempset = kbtopicmap.get(s1);
	                        tempset.add(kb.Id);
	                        kbtopicmap.put(s1,tempset);
	                        }
	                }
	        } else {
	                if(kbtopicmap.get(kb.keywords__c) == null){
	                        kbtopicmap.put(kb.keywords__c,new set<Id>{kb.Id});
	                } else {
	                        tempset = kbtopicmap.get(kb.keywords__c);
	                        tempset.add(kb.keywords__c);
	                        kbtopicmap.put(kb.keywords__c,tempset);
	                }
	        }        */

	/*for(String s1: kb.keywords__c.split(',')){
	   String tempstr = s1.replaceAll('(\\s+)', '').toLowerCase();
	   if(!topicformatmap.containskey(tempstr)) {
	        createtopics.add(s1);
	   } else if(!topicassignformatmap.containskey(tempstr)){
	        assigntopics.add(tempstr);
	   }
	   }

	   if(createtopics.size() > 0){
	   for(String s1: createtopics){
	        Topic tp = new Topic();
	        tp.Name = s1;
	        insert tp;
	        TopicAssignment ta = new TopicAssignment();
	        ta.EntityId = kb.Id;
	        ta.TopicId = tp.Id;
	        insert ta;

	   }
	   }
	   if(assigntopics.size() > 0){
	   for(String s1: assigntopics){
	        TopicAssignment ta = new TopicAssignment();
	        ta.EntityId = kb.Id;
	        system.debug('assign topic name'+s1);
	        ta.TopicId = topicformatmap.get(s1);
	        insert ta;
	   }
	   }

	                } catch (Exception e){
	   System.debug('Excpetion while accessing topics'+e.getmessage()+e.getlinenumber());
	                }


	        }*/



	/**
	 *————————————————————————————————————————————————————
	 * @Description: Additional double Quote (“) or semi-colon (;) is getting added in the article
	 * Tag : T10
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/

	public void checkCharAppendBeforeInsertOrUpdate(List<Knowledge__kav> newList, Map<Id,Knowledge__kav> oldMap,Map<Id, Knowledge__kav> newMap,boolean valInsert) {
		for(Knowledge__kav kb : newList) {
			if((valInsert && kb.Solution__c!=null) || (!valInsert && kb.Solution__c!=null
			                                           && (oldmap.get(kb.Id).Solution__c != newMap.get(kb.Id).Solution__c)) ) {

				if( !kb.Solution__c.contains('<a href=') &&  kb.Solution__c.indexOf('.sh')>0) {
					kb.Solution__c = kb.Solution__c.replace('.sh','<span>.sh</span>');
				}

				if(!kb.Solution__c.contains('<a href=')&&(kb.Solution__c.contains('&quot;') || kb.Solution__c.contains('&gt;')) ) {

					if(kb.Solution__c.contains('&quot;')) kb.Solution__c = kb.Solution__c.replace('&quot;','<span>&quot;</span>');
					if(kb.Solution__c.contains('&gt;')) kb.Solution__c = kb.Solution__c.replace('&gt;','<span>&gt;</span>');

				}

			}

			if((valInsert && kb.Description__c!=null)|| (!valInsert && kb.Description__c!=null
			                                             && (oldmap.get(kb.Id).Description__c != newMap.get(kb.Id).Description__c)) ) {

				if(!kb.Description__c.contains('<a href=')&&  kb.Description__c.indexOf('.sh')>0 ) {
					kb.Description__c = kb.Description__c.replace('.sh','<span>.sh</span>');
				}

				if(!kb.Description__c.contains('<a href=')&& (kb.Description__c.contains('&quot;') || kb.Description__c.contains('&gt;'))) {

					if(kb.Description__c.contains('&quot;')) kb.Description__c = kb.Description__c.replace('&quot;','<span>&quot;</span>');
					if(kb.Description__c.contains('&gt;')) kb.Description__c = kb.Description__c.replace('&gt;','<span>&gt;</span>');


				}
			}

			if((valInsert && kb.Additional_Information__c!=null) || (!valInsert && kb.Additional_Information__c!=null
			                                                         && (oldmap.get(kb.Id).Additional_Information__c != newMap.get(kb.Id).Additional_Information__c)) ) {

				if(!kb.Additional_Information__c.contains('<a href=')&&
				   kb.Additional_Information__c.indexOf('.sh')>0) {
					kb.Additional_Information__c = kb.Additional_Information__c.replace('.sh','<span>.sh</span>');
				}

				if(!kb.Additional_Information__c.contains('<a href=')&& (kb.Additional_Information__c.contains('&quot;') || kb.Additional_Information__c.contains('&gt;')) ) {

					if(kb.Additional_Information__c.contains('&quot;')) kb.Additional_Information__c = kb.Additional_Information__c.replace('&quot;','<span>&quot;</span>');
					if(kb.Additional_Information__c.contains('&gt;')) kb.Additional_Information__c = kb.Additional_Information__c.replace('&gt;','<span>&gt;</span>');
				}
			}



			if((valInsert && kb.Internal_Notes__c!=null)|| (!valInsert && kb.Internal_Notes__c!=null
			                                                && (oldmap.get(kb.Id).Internal_Notes__c != newMap.get(kb.Id).Internal_Notes__c)) ) {

				if(!kb.Internal_Notes__c.contains('<a href=')&&
				   kb.Internal_Notes__c.indexOf('.sh')>0) {
					kb.Internal_Notes__c = kb.Internal_Notes__c.replace('.sh','<span>.sh</span>');
				}

				if(!kb.Internal_Notes__c.contains('<a href=')&& (kb.Internal_Notes__c.contains('&quot;') || kb.Internal_Notes__c.contains('&gt;')) ) {

					if(kb.Internal_Notes__c.contains('&quot;')) kb.Internal_Notes__c = kb.Internal_Notes__c.replace('&quot;','<span>&quot;</span>');
					if(kb.Internal_Notes__c.contains('&gt;')) kb.Internal_Notes__c = kb.Internal_Notes__c.replace('&gt;','<span>&gt;</span>');


				}
			}
		}
	}

	/* I2RT-7274 </11>*/
	/**
	 *————————————————————————————————————————————————————
	 * @Description:
	 * Used to provide colaboate permission to the file which is attached to the Kb Article
	 *————————————————————————————————————————————————————
	 * @param    newList
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	public void shareFiles(Map<Id, Knowledge__kav> newMap, Map<Id, Knowledge__kav> oldMap) {

		Set<Id> setKAVId = new Set<Id>();
		Set<Id> setDocId = new Set<Id>();
		for(Knowledge__kav kb : newMap.values()) {
			setKAVId.add(kb.Id);
		}

		List<CollaborationGroup> objGroups = [SELECT Id,Name from CollaborationGroup WHERE Name ='KB Content Reviewers Group'];
		String strCRGroupId = '';
		if(!objGroups.isEmpty())
		{
			strCRGroupId = objGroups[0].Id;
		}

		List<ContentWorkspace> objAttachLibraries = [SELECT Id,Name from ContentWorkspace WHERE Name ='KBAttachment'];
		String strAttachLibId = '';
		if(!objAttachLibraries.isEmpty())
		{
			strAttachLibId = objAttachLibraries[0].Id;
		}

		List<ContentDocumentLink> lstFileLink = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId in :setKAVId And IsDeleted=false];

		for(ContentDocumentLink filelinkobj : lstFileLink) {
			setDocId.add(filelinkobj.ContentDocumentId);
			//system.debug('######setDocLinkId filelinkobj.ContentDocumentId ' + filelinkobj.ContentDocumentId);
		}

		List<ContentDocumentLink> lstAlreadySharedFileLink = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId in :setDocId and (LinkedEntityId =:strCRGroupId or LinkedEntityId =:strAttachLibId) And IsDeleted=false];

		Map<Id, Id> mapSharedDocLinkId = new Map<Id, Id>();
		for(ContentDocumentLink filelinkobj : lstAlreadySharedFileLink) {
			mapSharedDocLinkId.put(filelinkobj.ContentDocumentId,filelinkobj.Id);
			//system.debug('######mapSharedDocLinkId filelinkobj.ContentDocumentId ' + filelinkobj.ContentDocumentId);
		}


		List<ContentDocumentLink> lstFileToInsert = new List<ContentDocumentLink>();
		for(Knowledge__kav kb : newMap.values()) {
			for(ContentDocumentLink filelink : lstFileLink) {
				if(filelink.LinkedEntityId == kb.Id && (mapSharedDocLinkId.get(filelink.ContentDocumentId) == null) && strCRGroupId != '') {
					//system.debug('######filelink.ContentDocumentId ' + filelink.ContentDocumentId + ' filelink.LinkedEntityId ' + filelink.LinkedEntityId);
					ContentDocumentLink fileNew = new ContentDocumentLink();
					fileNew.LinkedEntityId = strCRGroupId;
					fileNew.ContentDocumentId = filelink.ContentDocumentId;
					fileNew.ShareType = 'C';
					fileNew.Visibility = filelink.Visibility;
					lstFileToInsert.add(fileNew);
				}
			}

		}

		try{
			if(!lstFileToInsert.isEmpty()) {
				System.debug('shareFiles...... inserting files');
				insert lstFileToInsert;
			}
		}catch (Exception e) {
			System.debug('Excpetion while getting article attached file shared '+e.getmessage()+e.getlinenumber());
		}
		


	}
	/* I2RT-7274 - </11>*/



}