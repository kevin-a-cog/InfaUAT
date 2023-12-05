/*
   @created by       : Sathish R
   @created on       : 26/07/2022
   @Purpose          : Knowledge Handler class for LWC.
   @Testclass        : KBArticleHandlerTest
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  26-Jul-2022      |  Sathish R                |                   |   Initial Version
 |     3      |  15-May-2023      |  Sathish R                |    I2RT-8359      |   Send email archival notification to author with KB DL in CC.
 |     4      |  3-June-2023      |   Sathish                 |    I2RT-8326      |   PROD - KB External Search - In "Article Preview" screen images are not getting displayed to anonymous users if the article status is in Pending Technical Review.
 |     5      |  17-Aug-2023      |  Sathish R                |    I2RT-8631      |   Provide 'Join the Community' option on Knowledge Article detail page.
 |     6      |  25-Sep-2023      |  Sathish R                |    I2RT-9013      |   Send email notification to Japanese KB team when the linked English version of translated article is updated and published.
 |     7      |  23-Nov-2023      |  Sathish R                |    I2RT-9505      |   Include Product and Author (Japanese Translator name) in the e-mail sent to Japanese DL when english version is updated and published.
 ****************************************************************************************************
 */


global without sharing class KBArticleHandler {
	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get logged in username
	 *
	 *————————————————————————————————————————————————————
	 * @param    none
	 * @return   username
	 *————————————————————————————————————————————————————
	 **/

	public static String KB_URL = Label.KB_URL;/* Tag 2 */
	public static String KB_CR_Feedback_Email = Label.KB_CR_Feedback_Email;/* Tag 2 */
	public static String KB_CR_Feedback_Recipients = Label.KB_CR_Feedback_Recipients;/* Tag 2 */
	public static String KB_CR_Feedback_Duration = Label.KB_CR_Feedback_Duration;/* Tag 2 */
	public static String KB_Archival_Email_Template = Label.KB_Archival_Email_Template;/* Tag 3 */
	public static String KB_Archival_Recipients = Label.KB_Archival_Recipients;/* Tag 3 */
	public static String KB_IN_Community_Id = Label.KB_IN_Community_Id;/* Tag 5 */

	public static String KB_Translation_Email = Label.KB_Translation_Email;/* Tag 6 */
	public static String KB_Translation_Recipients = Label.KB_Translation_Recipients;/* Tag 6 */

	@AuraEnabled
	global static List<Knowledge__kav> getArticleAllLanguages(Id kbArticleId) {

		List<Knowledge__kav> knowledgeLst = new List<Knowledge__kav>();
		Knowledge__kav kav = [SELECT Id, ArticleNumber,UrlName,IsVisibleInPkb,ValidationStatus,Language,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :kbArticleId];
		if(kav!=null) {
			List<String> lstEnglishWithJapaneshKBId = new List<String> {};
			List<Knowledge__kav> lstEnglishWithJapaneshKB = [SELECT Id from Knowledge__kav where Language = 'en_US' and Keywords__c like '%kbjapanese%'];
			for(Knowledge__kav kbitem:lstEnglishWithJapaneshKB) {
				lstEnglishWithJapaneshKBId.add(kbitem.Id);
			}
			knowledgeLst = [SELECT Id,Language,ArticleNumber,UrlName,IsVisibleInPkb, ValidationStatus,PublishStatus,KnowledgeArticleId
			                from Knowledge__kav where KnowledgeArticleId = :kav.KnowledgeArticleId and PublishStatus = 'Online' and Id NOT IN :lstEnglishWithJapaneshKBId];
		}

		return knowledgeLst;
	}

	@AuraEnabled
	public static List<Knowledge__kav> getDirectPublishedArticles(){

		Map<String, ProcessInstanceStep> map_acc = new Map<String, ProcessInstanceStep>();
		Set<Id> lstKBIds = new Set<Id>();
		Set<Id> lstKBHaveFeedbackIds = new Set<Id>();
		Date durarion = System.today() - 15;
		if(KB_CR_Feedback_Duration.trim().isNumeric())
		{
			durarion = System.today() - integer.valueof(KB_CR_Feedback_Duration.trim());
		}

		List<ProcessDefinition> lstKBProcessDefinition = [SELECT Id,Name FROM ProcessDefinition WHERE Name = 'KB Direct Approval'];
		String strKBProcessDefinitionId = '';

		if(!lstKBProcessDefinition.isEmpty())
		{
			strKBProcessDefinitionId = lstKBProcessDefinition[0].Id;
		}

		for(ProcessInstance a : [SELECT Id,Status,ProcessDefinition.Name,LastModifiedDate,ProcessDefinition.TableEnumOrId,TargetObjectId,ProcessDefinitionId from ProcessInstance where Status = 'Approved' and ProcessDefinitionId  =:strKBProcessDefinitionId and LastModifiedDate > :durarion]) {
			lstKBIds.add(a.TargetObjectId);
		}

		for(afl__afl_Article_Feedback__c a : [Select Id, Knowledge__c, Is_Article_CR_Feedback__c From afl__afl_Article_Feedback__c Where Knowledge__c IN :lstKBIds]) {
			lstKBHaveFeedbackIds.add(a.Knowledge__c);
		}


		List<Knowledge__kav> knowledgeLst = [SELECT Id, ArticleNumber, Title, UrlName, Language, ValidationStatus, PublishStatus, KnowledgeArticleId, VersionNumber, Primary_Product__c, Article_Type__c, Created_by_Formula__c, Created_By__c, LastPublishedDate, Contributed_KB__c,IsVisibleInPkb,CreatedDate,AQI_Score__c from Knowledge__kav where PublishStatus ='Online' and Id IN :lstKBIds and Id NOT IN :lstKBHaveFeedbackIds and IsVisibleInPkb = TRUE];

		return knowledgeLst;
	}

	@AuraEnabled
	public static Boolean isUserCRFeedbackSubmitter(Id kbArticleId) {
		Boolean Result = false;
		string dataflow = '';
		try
		{
			Boolean IsUserCRApprover = false;
			Boolean IsArticleCRFeedBackEligible = false;
			Set<Id> lstlclKBIds = new Set<Id>();

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Content Review Group'];
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
				if(!objGroupMembers.isEmpty())
				{
					IsUserCRApprover = true;
				}
			}

			// List<Knowledge__kav> kbList = getDirectPublishedArticles();
			// for(Knowledge__kav kbdata : kbList) {
			// 	dataflow += 'kbdata.Id ' + kbdata.Id + ' kbArticleId ' + kbArticleId + ';';
			// 	if(kbdata.Id == kbArticleId)
			// 	{
			// 		dataflow += 'kbdata.Id ' + kbdata.Id + ';';
			// 		IsArticleCRFeedBackEligible = true;
			// 		break;
			// 	}
			// }

			// if(IsUserCRApprover == true && IsArticleCRFeedBackEligible == true)
			// {
			// 	Result = true;
			// }

			if(IsUserCRApprover == true)
			{
				Result = true;
			}

		} catch (Exception e) {
			system.debug('Exception occured while extending article' + e.getmessage() + e.getlinenumber());
		}
		return Result;
	}

	//Jira : I2RT-4931 - Start

	@AuraEnabled
	public static Boolean sendAlertOnCRFeedbackWrapper(string strKBRecordId,String strCRFeedbackComment) {
		Boolean Result = false;
		string dataflow = '';
		try
		{
			sendAlertOnCRFeedback(strKBRecordId,strCRFeedbackComment);
			Result = true;

		} catch (Exception e) {
			system.debug('Exception occured while extending article' + e.getmessage() + e.getlinenumber());
		}
		return Result;
	}


	@future
	public static void sendAlertOnCRFeedback(string strLclKBRecordId,String strLclCRFeedbackComment) {
		String strResult = '';
		try{
			List<ConnectApi.BatchInput> chatterPostInputs = new List<ConnectApi.BatchInput>();
			List<Messaging.SingleEmailMessage> emailInputs= new List<Messaging.SingleEmailMessage>();
			List<Knowledge__kav> kbCRFeedback = new List<Knowledge__kav>();
			List<CollaborationGroup> kbContentReviewerGroup = new List<CollaborationGroup>();

			kbCRFeedback = [Select Id, LastModifiedDate, Title,ArticleNumber,CreatedDate,LastModifiedById,Primary_Product__c,ValidationStatus,PublishStatus,Created_By__c,Created_By__r.Email,Created_by_Formula__c From Knowledge__kav WHERE Id = :strLclKBRecordId];

			String strAuthorEmailId = '';
			if(!kbCRFeedback.isEmpty()) {
				strAuthorEmailId = kbCRFeedback[0].Created_By__r.Email;
			}
			String [] strEmailRecipients = new List<String>();
			for(String element : KB_CR_Feedback_Recipients.split (';')) {
				strEmailRecipients.add(element);
			}

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Content Review Group'];
			List<GroupMember> objGroupMembers = new List<GroupMember>();
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId];
			}

			for(Knowledge__kav objKB : kbCRFeedback) {
				emailInputs.add(sendEmailOnCRFeedback(objKB,strAuthorEmailId,strLclCRFeedbackComment,strEmailRecipients));
				if(!objGroupMembers.isEmpty())
				{
					chatterPostInputs.add(sendChatterPostOnCRFeedback(objKB,strLclCRFeedbackComment,objKB.Created_By__c));
					for(GroupMember objGrp : objGroupMembers) {
						chatterPostInputs.add(sendChatterPostOnCRFeedback(objKB,strLclCRFeedbackComment,objGrp.UserOrGroupId));
					}
				}
			}

			if(!Test.isRunningTest() && !chatterPostInputs.isEmpty()) {ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostInputs); }

			if(!Test.isRunningTest()) {Messaging.sendEmail(emailInputs);  }

		}
		catch(Exception ex) {
			System.debug('sendAlertOnCaseKBAttachment Method : exception occurred - ' + ex.getMessage());
			strResult = ex.getMessage() + ' ' + ex.getLineNumber();
		}
		//return strResult;
	}

	public static Messaging.SingleEmailMessage sendEmailOnCRFeedback(Knowledge__kav knwRec,String strLclAuthorEmailId, String strLclCRFeedbackComment, String [] strLclRecipients){

		String [] strEmailToRecipients = new List<String>();
		strEmailToRecipients.add(strLclAuthorEmailId);

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String strSubject = 'KB '+ knwRec.ArticleNumber +' received Content Reviewer feedback';
		String strKBDBodyHtml = KB_CR_Feedback_Email;
		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strKBAuthorName = knwRec.Created_by_Formula__c != null ?  knwRec.Created_by_Formula__c  : '';
		String strValidationStatus = knwRec.ValidationStatus != null ?  knwRec.ValidationStatus  : '';
		String strPublishStatus = knwRec.PublishStatus != null ?  knwRec.PublishStatus  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBURL$##',KB_URL).replace('$##KBID$##',strKBId);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBARTICLENUMBER$##',strArticleNumber).replace('$##KBTITLE$##',strTitle);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBCONTENTREVIEWERCOMMENTS$##',strLclCRFeedbackComment).replace('$##KBAUTHORNAME$##',strKBAuthorName);

		mail.setSubject(strSubject);
		mail.setHtmlBody(strKBDBodyHtml);
		mail.setToAddresses(strEmailToRecipients);
		mail.setCcAddresses(strLclRecipients);

		return mail;
	}

	public static ConnectApi.BatchInput sendChatterPostOnCRFeedback(knowledge__kav knwRec, string strLclCRFeedbackComment, String strLclRecipient){

		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		// Text content of a chatter body
		ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput20 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput21 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput30 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput5 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput6 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput7 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

		// To make the text bold
		ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
		markupEndSegment.markupType = ConnectApi.MarkupType.bold;

		// To have sentences in next line
		ConnectApi.MarkupBeginSegmentInput paragraphBegin = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput paragraphEnd = new ConnectApi.MarkupEndSegmentInput();
		paragraphBegin.markupType = ConnectApi.MarkupType.paragraph;
		paragraphEnd.markupType = ConnectApi.MarkupType.paragraph;

		// To have the hyperlink of the KB record
		ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
		entityLinkSegmentInput.entityId = knwRec.Id;


		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();



		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strKBAuthorName = knwRec.Created_by_Formula__c != null ?  knwRec.Created_by_Formula__c  : '';
		String strValidationStatus = knwRec.ValidationStatus != null ?  knwRec.ValidationStatus  : '';
		String strPublishStatus = knwRec.PublishStatus != null ?  knwRec.PublishStatus  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';

		textSegmentInput1.text = 'Hi ' + strKBAuthorName + ',';
		textSegmentInput20.text = 'Article ';
		textSegmentInput21.text = ' authored or contributed by you has received the following feedback from the Content Reviewer.';
		textSegmentInput3.text = 'Please address this comment at the earliest.';
		textSegmentInput4.text = 'Content Reviewer comments:';
		textSegmentInput5.text = strLclCRFeedbackComment;
		textSegmentInput6.text = 'This is a system generated notification.';
		textSegmentInput7.text = 'Do not reply to this chat.';
		nextLineTextSegment.text ='&nbsp;';



		// first sentence start
		messageBodyInput.messageSegments.add(textSegmentInput1);
		// first sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);


		// second sentence start
		messageBodyInput.messageSegments.add(textSegmentInput20);
		messageBodyInput.messageSegments.add(entityLinkSegmentInput);
		messageBodyInput.messageSegments.add(textSegmentInput21);
		// second sentence end


		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Third sentence start
		messageBodyInput.messageSegments.add(textSegmentInput3);
		// Third sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Four sentence (Bold) start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput4);
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Four sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Five sentence  start
		messageBodyInput.messageSegments.add(textSegmentInput5);
		// Five sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 6th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput6);
		// 6th sentence start

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 7th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput7);
		// 7th sentence start



		system.debug('messagebody'+messageBodyInput);
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = strLclRecipient;

		ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
		return batchInput;

	}

	//Jira : I2RT-4931 - End

	@AuraEnabled
	public static Boolean sendAlertOnArchivalWrapper(string strKBRecordId,String strArchivalComment) {
		Boolean Result = false;
		string dataflow = '';
		try
		{
			string strEngineerName = UserInfo.getName();
			sendAlertOnArchival(strKBRecordId,strArchivalComment,strEngineerName);
			Result = true;

		} catch (Exception e) {
			system.debug('Exception occured while sending alert for article' + e.getmessage() + e.getlinenumber());
		}
		return Result;
	}

	@future
	public static void sendAlertOnArchival(string strLclKBRecordId,String strLclArchivalComment,String strLclEngineerName) {
		String strResult = '';
		try{
			List<ConnectApi.BatchInput> chatterPostInputs = new List<ConnectApi.BatchInput>();
			List<Messaging.SingleEmailMessage> emailInputs= new List<Messaging.SingleEmailMessage>();
			List<Knowledge__kav> kbArchival = new List<Knowledge__kav>();
			List<CollaborationGroup> kbContentReviewerGroup = new List<CollaborationGroup>();

			kbArchival = [Select Id, LastModifiedDate, Title,ArticleNumber,CreatedDate,LastModifiedById,Primary_Product__c,ValidationStatus,PublishStatus,Created_By__c,Created_By__r.Email,Created_by_Formula__c,Original_Author__c,Original_Author__r.Email From Knowledge__kav WHERE Id = :strLclKBRecordId];

			String strOriginalAuthorEmailId = '';
			String strContributorEmailId = '';
			if(!kbArchival.isEmpty()) {
				strOriginalAuthorEmailId = kbArchival[0].Original_Author__r.Email;
				strContributorEmailId = kbArchival[0].Created_By__r.Email;
			}
			String [] strEmailRecipients = new List<String>();
			for(String element : KB_Archival_Recipients.split (';')) {
				strEmailRecipients.add(element);
			}

			// List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Content Review Group'];
			// List<GroupMember> objGroupMembers = new List<GroupMember>();
			// if(!objGroups.isEmpty())
			// {
			// 	String grpId = objGroups[0].Id;
			// 	objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId];
			// }

			for(Knowledge__kav objKB : kbArchival) {
				emailInputs.add(getEmailMessageForArchival(objKB,strOriginalAuthorEmailId,strContributorEmailId,strLclArchivalComment,strEmailRecipients,strLclEngineerName));
				// if(!objGroupMembers.isEmpty())
				// {
				// 	chatterPostInputs.add(sendChatterPostOnCRFeedback(objKB,strLclArchivalComment,objKB.Created_By__c));
				// 	for(GroupMember objGrp : objGroupMembers) {
				// 		chatterPostInputs.add(sendChatterPostOnCRFeedback(objKB,strLclArchivalComment,objGrp.UserOrGroupId));
				// 	}
				// }
			}

			// if(!Test.isRunningTest() && !chatterPostInputs.isEmpty()) {ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostInputs); }

			if(!Test.isRunningTest()) {Messaging.sendEmail(emailInputs);  }

		}
		catch(Exception ex) {
			System.debug('sendAlertOnCaseKBAttachment Method : exception occurred - ' + ex.getMessage());
			strResult = ex.getMessage() + ' ' + ex.getLineNumber();
		}
		//return strResult;
	}

	public static Messaging.SingleEmailMessage getEmailMessageForArchival(Knowledge__kav knwRec,String strLclAuthorEmailId,string strLclContributorEmailId, String strLclArchivalComment, String [] strLclRecipients,string strLclEngineerName){

		String [] strEmailToRecipients = new List<String>();
		strEmailToRecipients.add(strLclAuthorEmailId);
		strEmailToRecipients.add(strLclContributorEmailId);

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String strSubject = 'KB Article '+ knwRec.ArticleNumber +' is archived';
		String strKBDBodyHtml = KB_Archival_Email_Template;
		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		// String strKBAuthorName = knwRec.Created_by_Formula__c != null ?  knwRec.Created_by_Formula__c  : '';
		String strValidationStatus = knwRec.ValidationStatus != null ?  knwRec.ValidationStatus  : '';
		String strPublishStatus = knwRec.PublishStatus != null ?  knwRec.PublishStatus  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBURL$##',KB_URL).replace('$##KBID$##',strKBId);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBARTICLENUMBER$##',strArticleNumber).replace('$##KBTITLE$##',strTitle);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBARCHIVALCOMMENTS$##',strLclArchivalComment).replace('$##ENGINEERNAME$##',strLclEngineerName);

		mail.setSubject(strSubject);
		mail.setHtmlBody(strKBDBodyHtml);
		mail.setToAddresses(strEmailToRecipients);
		mail.setCcAddresses(strLclRecipients);

		return mail;
	}

	@AuraEnabled
	public static string getRelatedKBandCase(Id kbArticleId) {
		List<Knowledge__kav> relatedKBKavList = new List<Knowledge__kav>();
		List<Knowledge__kav> kbCurrentArticleDatas = new List<Knowledge__kav>();
		List<KBReferredInData> kbReferredArticleDatas = new List<KBReferredInData>();
		List<afl__afl_Article_Feedback__c> kbArticleFeedbackDatas = new List<afl__afl_Article_Feedback__c>();
		ArchivalCheckResponse archivalCheckResponse = new ArchivalCheckResponse();
		archivalCheckResponse.KBReferredArticleDatas = kbReferredArticleDatas;
		archivalCheckResponse.KBCurrentArticleDatas = kbCurrentArticleDatas;
		archivalCheckResponse.KBToCaseResponse = '';
		archivalCheckResponse.ResponseStatus = '';
		archivalCheckResponse.ErrorMessage = '';
		archivalCheckResponse.ExeFlow = '';
		string ExeFlowStatus ='305';
		try
		{
			List<Related_KB__c> relatedKBList = new List<Related_KB__c>();

			List<String> lstArticleID = new List<String>();

			string strKBToCaseJson = '';

			ExeFlowStatus += ' 372';

			relatedKBList = [SELECT Referred_In__c FROM Related_KB__c WHERE Referred_Article__c = :kbArticleId ];

			for(Related_KB__c relKB : relatedKBList) {

				lstArticleID.add(relKB.Referred_In__c);

			}

			relatedKBKavList = [SELECT Id, ArticleNumber, Title,Language,ValidationStatus,PublishStatus From Knowledge__kav where Id IN :lstArticleID order by LastModifiedDate desc];

			for (Knowledge__kav objKB : relatedKBKavList) {
				KBReferredInData kbReferredInData = new KBReferredInData();
				kbReferredInData.Id = objKB.Id != null ?  objKB.Id  : '';
				kbReferredInData.ArticleNumber = objKB.ArticleNumber != null ?  objKB.ArticleNumber  : '';
				kbReferredInData.Title = objKB.Title != null ?  objKB.Title  : '';
				kbReferredInData.Language = objKB.Language != null ?  objKB.Language : '';
				kbReferredInData.ValidationStatus = objKB.ValidationStatus != null ?  objKB.ValidationStatus  : '';
				kbReferredInData.PublishStatus = objKB.PublishStatus != null ?  objKB.PublishStatus  : '';
				kbReferredArticleDatas.add(kbReferredInData);
			}

			KBCurrentArticleDatas = [SELECT Id,UrlName,KnowledgeArticleId, ArticleNumber, Title,Language,ValidationStatus,PublishStatus,Solution__c,Internal_Notes__c,Description__c,Additional_Information__c,Question__c,Answer__c,Alternate_Questions__c From Knowledge__kav where Id =: kbArticleId];

			if(!KBCurrentArticleDatas.isEmpty()) {
				strKBToCaseJson = CaseKBCreation.getKBToCase(KBCurrentArticleDatas[0].Id,KBCurrentArticleDatas[0].KnowledgeArticleId,KBCurrentArticleDatas[0].ArticleNumber);
				kbArticleFeedbackDatas = [SELECT Id,Like_Dislike__c,afl__Article_Title__c from afl__afl_Article_Feedback__c where Knowledge__r.UrlName =: KBCurrentArticleDatas[0].UrlName];
			}



			archivalCheckResponse.ResponseStatus = 'SUCCESS';
			archivalCheckResponse.KBReferredArticleDatas = kbReferredArticleDatas;
			archivalCheckResponse.KBCurrentArticleDatas = kbCurrentArticleDatas;
			archivalCheckResponse.KBArticleFeedbackDatas = kbArticleFeedbackDatas;
			archivalCheckResponse.KBToCaseResponse = strKBToCaseJson;
			archivalCheckResponse.ExeFlow = ExeFlowStatus;

			ExeFlowStatus += ' 382';

		} catch (Exception e) {
			ExeFlowStatus += ' 385';
			system.debug('Exception occured while getRelatedKBandCase' + e.getmessage() + e.getlinenumber());
			archivalCheckResponse.ResponseStatus = 'ERROR';
			archivalCheckResponse.ErrorMessage = e.getMessage();
			archivalCheckResponse.ExeFlow = ExeFlowStatus;
		}
		return JSON.serialize(archivalCheckResponse);
	}


	//Tag 06 - Start

	/*********************************************************************************************************
	 * @name			sendAlertOnMasterArticlePublishWrapper
	 * @author			Sathish R
	 * @created			24 / 09 / 2023
	 * @description		Wrapper method used to call the Alert method on Master Article Publish
	 * @param			List<Id> Ids : Used the KB Article ID
	 **********************************************************************************************************/
	@InvocableMethod(label='Send Notification On Master Article Publish' description='Send Notification On Master Article Publish' category= 'Knowledge')
	public static void sendAlertOnMasterArticlePublishWrapper(List<Id> Ids) {
		Boolean Result = false;
		string dataflow = '';
		try
		{
			for(Id id : Ids)
			{
				string strKBRecordId = id;
				sendAlertOnMasterArticlePublish(strKBRecordId);
			}
			Result = true;

		} catch (Exception e) {
			system.debug('Exception occured while extending article' + e.getmessage() + e.getlinenumber());
		}
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Sathish R
	 * @created			24 / 09 / 2023
	 * @description		Method used to call the Alert method on Master Article Publish
	 * @param			String strLclKBRecordId : KB Article ID
	 **********************************************************************************************************/
	public static void sendAlertOnMasterArticlePublish(string strLclKBRecordId) {
		String strResult = '';
		try{
			List<ConnectApi.BatchInput> chatterPostInputs = new List<ConnectApi.BatchInput>();
			List<Messaging.SingleEmailMessage> emailInputs= new List<Messaging.SingleEmailMessage>();
			List<Knowledge__kav> kbMasterArticle = new List<Knowledge__kav>();
			List<Knowledge__kav> kbChildArticle = new List<Knowledge__kav>();/* Tag 7 */
			List<CollaborationGroup> kbContentReviewerGroup = new List<CollaborationGroup>();

			kbMasterArticle = [Select Id, LastModifiedDate, Title,ArticleNumber,CreatedDate,LastModifiedById,Primary_Product__c,ValidationStatus,PublishStatus,Created_By__c,Created_By__r.Email,Created_by_Formula__c,Original_Author_Formula__c,Last_Modified_By_Formula__c,KnowledgeArticleId,IsMasterLanguage,Language From Knowledge__kav WHERE Id = :strLclKBRecordId];

			String strAuthorEmailId = '';
			String strChildArticleContributorName = '';/* Tag 7 */
			if(!kbMasterArticle.isEmpty()) {
				strAuthorEmailId = kbMasterArticle[0].Created_By__r.Email;
				/* Tag 7 - start */
				kbChildArticle = [Select Id, LastModifiedDate, Title,ArticleNumber,CreatedDate,LastModifiedById,Primary_Product__c,ValidationStatus,PublishStatus,Created_By__c,Created_By__r.Email,Created_by_Formula__c,Original_Author_Formula__c,Last_Modified_By_Formula__c,KnowledgeArticleId,IsMasterLanguage,Language From Knowledge__kav WHERE Language = 'ja' AND ArticleNumber =:kbMasterArticle[0].ArticleNumber AND IsMasterLanguage = FALSE AND KnowledgeArticleId =:kbMasterArticle[0].KnowledgeArticleId];
				if(!kbChildArticle.isEmpty()) {
					strChildArticleContributorName = kbChildArticle[0].Created_by_Formula__c;
				}
				/* Tag 7 - end */
			}
			String [] strEmailRecipients = new List<String>();
			for(String element : KB_Translation_Recipients.split (';')) {
				strEmailRecipients.add(element);
			}

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Type = 'Queue' and Name = 'KB Japanese Translation Queue'];
			List<GroupMember> objGroupMembers = new List<GroupMember>();
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId];
			}

			string strLclCRFeedbackComment = '';

			for(Knowledge__kav objKB : kbMasterArticle) {
				emailInputs.add(sendEmailOnMasterArticlePublish(objKB,strAuthorEmailId,strLclCRFeedbackComment,strEmailRecipients,strChildArticleContributorName));/* Tag 7 */
				if(!objGroupMembers.isEmpty())
				{
					chatterPostInputs.add(sendChatterPostOnMasterArticlePublish(objKB,strLclCRFeedbackComment,objKB.Created_By__c,strChildArticleContributorName));/* Tag 7 */
					for(GroupMember objGrp : objGroupMembers) {
						chatterPostInputs.add(sendChatterPostOnMasterArticlePublish(objKB,strLclCRFeedbackComment,objGrp.UserOrGroupId,strChildArticleContributorName));/* Tag 7 */
					}
				}
			}

			if(!Test.isRunningTest() && !chatterPostInputs.isEmpty()) {ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostInputs); }

			if(!Test.isRunningTest()) {Messaging.sendEmail(emailInputs);  }

		}
		catch(Exception ex) {
			System.debug('sendAlertOnCaseKBAttachment Method : exception occurred - ' + ex.getMessage());
			strResult = ex.getMessage() + ' ' + ex.getLineNumber();
		}
		//return strResult;
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Sathish R
	 * @created			24 / 09 / 2023
	 * @description		Method used send mail on Master Article Publish
	 * @param			String strLclKBRecordId : KB Article ID
	 * @return			Email with Content
	 **********************************************************************************************************/
	public static Messaging.SingleEmailMessage sendEmailOnMasterArticlePublish(Knowledge__kav knwRec,String strLclAuthorEmailId, String strLclCRFeedbackComment, String [] strLclRecipients,String strLclChildArticleContributorName){

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String strSubject = 'KB '+ knwRec.ArticleNumber +' English version is updated and pending translation';
		String strKBDBodyHtml = KB_Translation_Email;
		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strKBAuthorName = knwRec.Original_Author_Formula__c != null ?  knwRec.Original_Author_Formula__c  : '';
		String strKBContributorName = knwRec.Created_by_Formula__c != null ?  knwRec.Created_by_Formula__c  : '';
		String strKBPublisherName = knwRec.Last_Modified_By_Formula__c != null ?  knwRec.Last_Modified_By_Formula__c  : '';
		String strKBPrimaryProduct = knwRec.Primary_Product__c != null ?  knwRec.Primary_Product__c  : '';/* Tag 7 */
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBURL$##',KB_URL).replace('$##KBID$##',strKBId);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBARTICLENUMBER$##',strArticleNumber).replace('$##KBTITLE$##',strTitle);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBAUTHORNAME$##',strKBAuthorName).replace('$##KBCONTRIBUTOR$##',strKBContributorName).replace('$##KBPUBLISHEDBY$##',strKBPublisherName);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBPRIMARYPRODUCT$##',strKBPrimaryProduct).replace('$##KBCHILDCONTRIBUTOR$##',strLclChildArticleContributorName);/* Tag 7 */

		mail.setSubject(strSubject);
		mail.setHtmlBody(strKBDBodyHtml);
		mail.setToAddresses(strLclRecipients);

		return mail;
	}

	/*********************************************************************************************************
	 * @name			The name of your class or method
	 * @author			Sathish R
	 * @created			24 / 09 / 2023
	 * @description		Method used send chatter post on Master Article Publish
	 * @param			String strLclKBRecordId : KB Article ID
	 * @return			Chatter Post with Content
	 **********************************************************************************************************/
	public static ConnectApi.BatchInput sendChatterPostOnMasterArticlePublish(knowledge__kav knwRec, string strLclCRFeedbackComment, String strLclRecipient,String strLclChildArticleContributorName){

		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		// Text content of a chatter body
		ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput20 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput21 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput30 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput31 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput40 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput41 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput50 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput51 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput6 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput7 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

		// To make the text bold
		ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
		markupEndSegment.markupType = ConnectApi.MarkupType.bold;

		// To have sentences in next line
		ConnectApi.MarkupBeginSegmentInput paragraphBegin = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput paragraphEnd = new ConnectApi.MarkupEndSegmentInput();
		paragraphBegin.markupType = ConnectApi.MarkupType.paragraph;
		paragraphEnd.markupType = ConnectApi.MarkupType.paragraph;

		// To have the hyperlink of the KB record
		ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
		entityLinkSegmentInput.entityId = knwRec.Id;


		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();



		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strKBAuthorName = knwRec.Original_Author_Formula__c != null ?  knwRec.Original_Author_Formula__c  : '';
		String strKBContributorName = knwRec.Created_by_Formula__c != null ?  knwRec.Created_by_Formula__c  : '';
		String strKBPublisherName = knwRec.Last_Modified_By_Formula__c != null ?  knwRec.Last_Modified_By_Formula__c  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';
		String strKBPrimaryProduct = knwRec.Primary_Product__c != null ?  knwRec.Primary_Product__c  : '';/* Tag 7 */

		textSegmentInput1.text = 'Hi Team,';
		textSegmentInput20.text = 'Article ' + strArticleNumber + ' : ' ;
		textSegmentInput21.text = ', English version is updated, please update the corresponding non-English version.';
		textSegmentInput30.text = 'Product - ';/* Tag 7 */
		textSegmentInput31.text = strKBPrimaryProduct;/* Tag 7 */
		textSegmentInput40.text = 'Author (Japanese Translator name) - ';/* Tag 7 */
		textSegmentInput41.text = strLclChildArticleContributorName;/* Tag 7 */
		// textSegmentInput50.text = 'Master Article Published By : ';
		// textSegmentInput51.text =  strKBPublisherName;		
		textSegmentInput6.text = 'This is a system generated notification.';
		textSegmentInput7.text = 'Do not reply to this chat.';
		nextLineTextSegment.text ='&nbsp;';



		// first sentence start
		messageBodyInput.messageSegments.add(textSegmentInput1);
		// first sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);


		// second sentence start
		messageBodyInput.messageSegments.add(textSegmentInput20);
		messageBodyInput.messageSegments.add(entityLinkSegmentInput);
		messageBodyInput.messageSegments.add(textSegmentInput21);
		// second sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Third sentence start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput30);
		messageBodyInput.messageSegments.add(markupEndSegment);
		messageBodyInput.messageSegments.add(textSegmentInput31);
		// Third sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Four sentence  start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput40);
		messageBodyInput.messageSegments.add(markupEndSegment);
		messageBodyInput.messageSegments.add(textSegmentInput41);
		// Four sentence end

		// messageBodyInput.messageSegments.add(paragraphBegin);
		// messageBodyInput.messageSegments.add(nextLineTextSegment);
		// messageBodyInput.messageSegments.add(paragraphEnd);

		// // 5th sentence start		
		// messageBodyInput.messageSegments.add(markupBeginSegment);
		// messageBodyInput.messageSegments.add(textSegmentInput50);
		// messageBodyInput.messageSegments.add(markupEndSegment);
		// messageBodyInput.messageSegments.add(textSegmentInput51);
		// // 5th sentence start

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 6th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput6);
		// 6th sentence start

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 7th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput7);
		// 7th sentence start



		system.debug('messagebody'+messageBodyInput);
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = strLclRecipient;

		ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
		return batchInput;

	}
	
	//Tag 06 -End


	//Start - /*<4>*/
	public static List<Knowledge__kav> getProcessedVersionKBImageTag(List<Knowledge__kav> kbList) {

		Map<String, String> mapRefidAndUrl = new Map<String, String>();

		Pattern prtImageTag = Pattern.compile('(<img.*?src=(?:\"|\')(.+?)(?:\"|\').*?></img>)');

		Pattern prtRefid = Pattern.compile('refid=[a-zA-Z0-9]{15}');

		for(Knowledge__kav kb : kbList) {

			Matcher mtrImageTag = prtImageTag.matcher(kb.Any_additional_details_like_Screenshots__c + ' '
			                                          + kb.Steps_to_configure_the_parameter__c + ' '
			                                          + kb.Solution__c + ' '
			                                          + kb.Internal_Notes__c  + ' '
			                                          + kb.Description__c + ' '
			                                          + kb.Additional_Information__c);

			while(mtrImageTag.find())
			{
				Matcher mtrRefid = prtRefid.matcher(mtrImageTag.group(2));
				while(mtrRefid.find())
				{
					if(mtrRefid.group(0) != null)
					{
						mapRefidAndUrl.put(mtrRefid.group(0).replace('refid=',''), mtrImageTag.group(2));
					}
				}
			}

			List<ContentDistribution> lstexistconDistImageTag = new List<ContentDistribution>();
			lstexistconDistImageTag = [Select Id,ContentVersionId,ContentVersion.Title,DistributionPublicUrl,ContentDownloadUrl from ContentDistribution where ContentVersion.Title IN : mapRefidAndUrl.keySet()];


			if(!lstexistconDistImageTag.isEmpty()) {
				for(ContentDistribution objConDist :lstexistconDistImageTag)
				{
					if ((kb.Any_additional_details_like_Screenshots__c != null) && (kb.Any_additional_details_like_Screenshots__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Any_additional_details_like_Screenshots__c = kb.Any_additional_details_like_Screenshots__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}

					if ((kb.Steps_to_configure_the_parameter__c != null) && (kb.Steps_to_configure_the_parameter__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Steps_to_configure_the_parameter__c = kb.Steps_to_configure_the_parameter__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}

					if ((kb.Solution__c != null) && (kb.Solution__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Solution__c = kb.Solution__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}

					if ((kb.Internal_Notes__c != null) && (kb.Internal_Notes__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Internal_Notes__c = kb.Internal_Notes__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}

					if ((kb.Description__c != null) && (kb.Description__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Description__c = kb.Description__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}

					if ((kb.Additional_Information__c != null) && (kb.Additional_Information__c.indexOf(objConDist.ContentVersion.Title) > -1)) {
						kb.Additional_Information__c = kb.Additional_Information__c.replace(mapRefidAndUrl.get(objConDist.ContentVersion.Title),objConDist.ContentDownloadUrl.replace('&','&amp;'));
					}
				}
			}

		}

		return kbList;
	}
	@AuraEnabled
	public static String setProcessedVersionKBImageTag(String kavId) {

		String returnMsg ='';

		try {

			//system.debug('setProcessedVersionKBImageTag : '+ kavId);
			List<Knowledge__kav> kbList = [SELECT Id,KnowledgeArticleId,Any_additional_details_like_Screenshots__c
			                               ,Steps_to_configure_the_parameter__c
			                               ,Solution__c
			                               ,Internal_Notes__c
			                               ,Description__c
			                               ,Additional_Information__c
			                               FROM Knowledge__kav
			                               WHERE Id = :kavId];

			List<String> arrayOfContVerId = new List<String>();
			Map<String, String> mapRefidAndUrl = new Map<String, String>();
			Map<String, String> mapCreateCVRefidAndUrl = new Map<String, String>();
			Map<String, String> mapRefidAndContVerId = new Map<String, String>();


			Pattern prtImageTag = Pattern.compile('(<img.*?src=(?:\"|\')(.+?)(?:\"|\').*?></img>)');


			Pattern prtRefid = Pattern.compile('refid=[a-zA-Z0-9]{15}');



			for(Knowledge__kav kb : kbList) {


				Matcher mtrImageTag = prtImageTag.matcher(kb.Any_additional_details_like_Screenshots__c + ' '
				                                          + kb.Steps_to_configure_the_parameter__c + ' '
				                                          + kb.Solution__c + ' '
				                                          + kb.Internal_Notes__c  + ' '
				                                          + kb.Description__c + ' '
				                                          + kb.Additional_Information__c);

				System.debug(kb.Any_additional_details_like_Screenshots__c + ' '
				             + kb.Steps_to_configure_the_parameter__c + ' '
				             + kb.Solution__c + ' '
				             + kb.Internal_Notes__c  + ' '
				             + kb.Description__c + ' '
				             + kb.Additional_Information__c );

				while(mtrImageTag.find())
				{
					Matcher mtrRefid = prtRefid.matcher(mtrImageTag.group(2));
					while(mtrRefid.find())
					{
						if(mtrRefid.group(0) != null)
						{
							mapRefidAndUrl.put(mtrRefid.group(0).replaceAll('refid=',''), mtrImageTag.group(2));
							mapCreateCVRefidAndUrl.put(mtrRefid.group(0).replaceAll('refid=',''), mtrImageTag.group(2));

						}


					}

				}

				//ContentVersion Check and Insert - Start
				List<ContentVersion> lstnewconVerImageTag = new List<ContentVersion>();
				List<ContentVersion> lstexistconVerImageTag = new List<ContentVersion>();
				lstexistconVerImageTag = [Select Id,Title From ContentVersion where Title IN : mapRefidAndUrl.keySet() and IsLatest=true];

				if(!lstexistconVerImageTag.isEmpty()) {
					for(ContentVersion objConV :lstexistconVerImageTag)
					{
						if (objConV.Title != null && mapCreateCVRefidAndUrl.containsKey(objConV.Title)) {
							mapCreateCVRefidAndUrl.remove(objConV.Title);
							//System.Debug('Removed ' + objConV.Title);
						}
					}
				}

				if(!mapCreateCVRefidAndUrl.isEmpty()) {

					for (String key: mapCreateCVRefidAndUrl.keyset())
					{
						PageReference pageRef = new PageReference (mapRefidAndUrl.get(key).replace ('&amp;','&'));
						String Title = key;
						String PathOnClient = key;
						Blob versiondata;

						if(!test.isRunningTest()) {
							versiondata = pageRef.getContent();
						}else{
							versiondata=blob.valueOf(' <img alt="One.png" src="https://infa--testinfa489.sandbox.file.force.com/servlet/rtaImage?eid=ka03K0000005Y7Z&amp;feoid=00N3f000000ZgGS&amp;refid=0EM3K0000007yCV"></img><br>Knowledge Test FAQ Test TR Eight Knowledge Test FAQ Test TR Eight null Knowledge Test FAQ Test TR Eight');
						}

						ContentVersion oContentVersion = new ContentVersion();
						oContentVersion.title = Title;
						oContentVersion.PathOnClient  = PathOnClient;
						oContentVersion.versiondata  = versiondata;
						oContentVersion.IsMajorVersion  = true;
						lstnewconVerImageTag.add(oContentVersion);
					}


					if(!lstnewconVerImageTag.isEmpty()) {
						Insert lstnewconVerImageTag;
					}
				}

				//ContentVersion Check and Insert - End

				//ContentDistribution Check And Insert - Start
				lstexistconVerImageTag = new List<ContentVersion>();
				lstexistconVerImageTag = [Select Id,Title From ContentVersion where Title IN : mapRefidAndUrl.keySet() and IsLatest=true];
				if(!lstexistconVerImageTag.isEmpty()) {
					for(ContentVersion objConV :lstexistconVerImageTag)
					{
						mapRefidAndContVerId.put(objConV.Title, objConV.Id);
					}
				}
				List<ContentDistribution> lstenewconDistImageTag = new List<ContentDistribution>();
				List<ContentDistribution> lstexistconDistImageTag = new List<ContentDistribution>();
				lstexistconDistImageTag = [Select Id,ContentVersionId,ContentVersion.Title,DistributionPublicUrl,ContentDownloadUrl from ContentDistribution where ContentVersion.Title IN : mapRefidAndUrl.keySet()];

				if(!lstexistconDistImageTag.isEmpty()) {
					for(ContentDistribution objConDist :lstexistconDistImageTag)
					{
						if (objConDist.ContentVersion.Title != null && mapRefidAndContVerId.containsKey(objConDist.ContentVersion.Title)) {
							mapRefidAndContVerId.remove(objConDist.ContentVersion.Title);
							//System.Debug('Removed ' + objConDist.ContentVersion.Title);
						}
					}
				}


				if(!mapRefidAndContVerId.isEmpty()) {

					for (String key: mapRefidAndContVerId.keyset())
					{
						String conVerId = mapRefidAndContVerId.get(key);
						String Title = key;

						ContentDistribution conDist = new ContentDistribution();
						conDist.ContentVersionId = conVerId;
						conDist.Name = Title;
						conDist.PreferencesAllowViewInBrowser = true;
						conDist.PreferencesLinkLatestVersion = true;
						conDist.PreferencesNotifyOnVisit = false;
						conDist.PreferencesPasswordRequired = false;
						conDist.PreferencesAllowOriginalDownload = true;
						lstenewconDistImageTag.add(conDist);
					}


					if(!lstenewconDistImageTag.isEmpty()) {
						Insert lstenewconDistImageTag;
					}
				}
				//ContentDistribution Check And Insert - End

				//System.Debug('mapRefidAndUrl ' + mapCreateCVRefidAndUrl.keySet());

				returnMsg = 'SUCCESS';
			}

		} catch (Exception e) {
			returnMsg = 'ERROR : '+e.getmessage()+e.getlinenumber();
		}
		return returnMsg;
	}
	//End - /*<4>*/

	@AuraEnabled
	public static String removeRelatedArticlesFromKB(String relkbId) {
		AuraEnabledResponse auraEnabledResponse = new AuraEnabledResponse();
		auraEnabledResponse.ResponseStatus = '';
		auraEnabledResponse.ErrorMessage = '';
		auraEnabledResponse.ExeFlow = '';
		string ExeFlowStatus ='776';
		try
		{
			List<Related_KB__c> lstCurrentRelatedKB = [SELECT Id,Referred_Article__c,Referred_In__c,Referred_ArticleNumber__c,OwnerId FROM Related_KB__c WHERE Id = :relkbId ];
			if(lstCurrentRelatedKB.size() != 0)
			{
				System.debug('removeRelatedArticlesFromKB lstCurrentRelatedKB : '+ String.valueOf(lstCurrentRelatedKB.size()));
				delete lstCurrentRelatedKB;
				auraEnabledResponse.ResponseStatus = 'SUCCESS';

			}
			else {
				auraEnabledResponse.ResponseStatus = 'ALREADY';
			}

			auraEnabledResponse.ExeFlow = ExeFlowStatus;

		} catch (Exception e) {
			System.debug('removeRelatedArticlesFromKB Method : exception occurred - ' + e.getMessage());
			ExeFlowStatus += ' 790';
			system.debug('Exception occured while removeRelatedArticlesFromKB' + e.getmessage() + e.getlinenumber());
			auraEnabledResponse.ResponseStatus = 'ERROR';
			auraEnabledResponse.ErrorMessage = e.getMessage();
			auraEnabledResponse.ExeFlow = ExeFlowStatus;
		}
		return JSON.serialize(auraEnabledResponse);
	}
	//Start - /*<5>*/
	@AuraEnabled
	public static String getProductsTopic(String strKBProduct) {
		List<KB_Product_Topic_Mapping__mdt> mappingProductsTopic = new List<KB_Product_Topic_Mapping__mdt>();
		List<Topic> objTopic = new List<Topic>();
		String Result = '';
		String strINTopic = '';
		String strModKBProduct = strKBProduct.trim();
		String strINCommunityId = KB_IN_Community_Id;
		try
		{
			mappingProductsTopic = [SELECT Product__c, Topic__c from KB_Product_Topic_Mapping__mdt where Product__c = :strModKBProduct];

			if(!mappingProductsTopic.isEmpty()) {
				strINTopic = mappingProductsTopic[0].Topic__c;
				strINTopic = strINTopic.trim();
				objTopic =  [SELECT Id, Name, NetworkId from Topic where Name = :strINTopic and NetworkId = :strINCommunityId];
				//objTopic =  [SELECT Id, Name, NetworkId from Topic where Name = :strINTopic];

				if(!objTopic.isEmpty()) {
					Result = objTopic[0].Id + '$$##$$' + objTopic[0].Name.trim();
				}
				else {
					Result = 'NOTOPIC';
				}
			}
			else {
				Result = 'NOTOPIC';
			}

		} catch (Exception e) {
			Result = 'NOTOPIC';
			system.debug('Exception occured while sending alert for article' + e.getmessage() + e.getlinenumber());
		}
		return Result;
	}
	//End - /*<5>*/

	public class ArchivalCheckResponse
	{
		public List<KBReferredInData> KBReferredArticleDatas;
		public List<Knowledge__kav> KBCurrentArticleDatas;
		public List<afl__afl_Article_Feedback__c> KBArticleFeedbackDatas;
		public string KBToCaseResponse { get; set; }
		public string ResponseStatus { get; set; }
		public string ErrorMessage { get; set; }
		public string ExeFlow { get; set; }
		
	}

	public class AuraEnabledResponse
	{	
		public string ResponseStatus { get; set; }
		public string ErrorMessage { get; set; }
		public string ExeFlow { get; set; }
		
	}

	public class KBReferredInData
	{
	public string Id   { get; set; }
	public string ArticleNumber   { get; set; }
	public string Title   { get; set; }
	public string Language   { get; set; }
	public string ValidationStatus   { get; set; }
	public string PublishStatus   { get; set; }
	}

}