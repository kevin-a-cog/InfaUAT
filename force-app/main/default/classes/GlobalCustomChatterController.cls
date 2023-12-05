/*
 * Name			:	GlobalCustomChatterController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/28/2022
 * Description	:	Global Custom Chatter controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/28/2022		N/A				Initial version.			N/A
 */
public without sharing class GlobalCustomChatterController {

//Private variables.
private static String strNewLine = EncodingUtil.urlDecode('%0A', 'UTF-8');

/*
 Method Name : getFeeds
 Description : This method returns the Chatter feeds related to the given records and query paths.
 Parameters	 : Boolean, called from getFeeds, boolIncludeTaggedRecords If TRUE, Chatter Posts where the Ids provided in the queries were tagged, will be retrieved.
				String, called from getFeeds, strRecordId Record Id.
				List<String>, called from getFeeds, lstQueryPaths List of query paths.
				List<String>, called from getFeeds, lstChildQueries List of child queries.
 Return Type : List of GlobalCustomChatterWrapperClass
 */
@AuraEnabled(cacheable = false)
public static List<GlobalCustomChatterWrapperClass> getFeeds(Boolean boolIncludeTaggedRecords, String strRecordId, List<String> lstQueryPaths, List<String> lstChildQueries) {
	Id idRecord;
	String strBody;
	String strSOSLTerm;
	String strQueryPaths = '';
	ConnectApi.FeedItem objFeedItemBatch;
	ContentVersion objExistingContentVersion;
	Matcher objMatchResults;
	Pattern objPattern = Pattern.compile('src="sfdc:\\/\\/([\\w]{18})"');
	GlobalCustomChatterWrapperClass objFeedItemRecord;
	GlobalCustomChatterWrapperClass objFeedCommentRecord;
	GlobalCustomChatterWrapperClass.AttachmentWrapperClass objWrappedAttachment;
	Set<Id> setParentIds = new Set<Id>();
	Set<Id> setSOSLFeedItemIds = new Set<Id>();
	List<Id> lstAllFeedItems = new List<Id>();
	List<Id> lstParentIds = new List<Id>();
	List<GlobalCustomChatterWrapperClass> lstResults = new List<GlobalCustomChatterWrapperClass>();
	Map<Id, String> mapBodies = new Map<Id, String>();
	Map<Id, String> mapUserPhotos = new Map<Id, String>();
	Map<Id, ContentVersion> mapContentVersions = new Map<Id, ContentVersion>();

	//If we received records.
	if(String.isNotBlank(strRecordId)) {

		//We get the main Object name.
		idRecord = strRecordId;

		//If we have query paths, we update the query.
		if(lstQueryPaths != null && !lstQueryPaths.isEmpty()) {
			strQueryPaths = ',' + String.join(lstQueryPaths, ',');
		}

		//We query the record ids.
		for(SObject objRecord : Database.query('SELECT Id' + strQueryPaths + ' FROM ' + idRecord.getSObjectType().getDescribe().getName() + ' WHERE Id = :idRecord LIMIT 1')) {
			setParentIds.add(idRecord);

			//Now we add the related record ids, if any.
			if(lstQueryPaths != null && !lstQueryPaths.isEmpty()) {
				for(String strQueryPath : lstQueryPaths) {
					setParentIds.add((Id) extractValueRecursively(objRecord, strQueryPath));
				}
			}
		}

		//If we have child queries, we get the data.
		if(lstChildQueries != null && !lstChildQueries.isEmpty()) {
			for(String strChildQuery : lstChildQueries) {
				for(SObject objRecord : Database.query(strChildQuery.toLowerCase().replaceAll('\\{recordid\\}', '\'' + strRecordId + '\''))) {
					setParentIds.add((Id) objRecord.get('Id'));
				}
			}
		}

		//If we need to consider tagged records.
		if(boolIncludeTaggedRecords != null && boolIncludeTaggedRecords) {
			lstParentIds.addAll(setParentIds);
			strSOSLTerm = String.join(lstParentIds, ' OR ');
			for(List<SObject> lstRecords : [FIND :strSOSLTerm IN ALL FIELDS RETURNING FeedItem(Id), FeedComment(FeedItemId) LIMIT 2000]) {
				for(SObject objSOSLRecord : lstRecords) {
					if(objSOSLRecord instanceof FeedItem) {
						setSOSLFeedItemIds.add((Id) objSOSLRecord.get('Id'));
					} else {
						setSOSLFeedItemIds.add((Id) objSOSLRecord.get('FeedItemId'));
					}
				}
			}
		}

		//Now we query the Feed Items of all the record ids.
		for(FeedItem objRecord : [SELECT Body, CreatedById, CreatedBy.Name, CreatedDate, Id, Status, ParentId, Type, (SELECT Id, CreatedById, CreatedBy.Name,  
				CreatedDate, CommentBody, Status, FeedItemId, RelatedRecordId FROM FeedComments ORDER BY CreatedDate ASC), (SELECT RecordId FROM FeedAttachments WHERE Type = 'Content') FROM 
				FeedItem WHERE (ParentId IN :setParentIds OR Id IN :setSOSLFeedItemIds) ORDER BY CreatedDate DESC LIMIT 10000]) {
			
			//If we have the right status.
			if(objRecord.Status == 'Published') {
				objFeedItemRecord = new GlobalCustomChatterWrapperClass();
				objFeedItemRecord.boolFoundByTag = false;
				objFeedItemRecord.boolIsVisible = true;
				objFeedItemRecord.idRecord = objRecord.Id;
				objFeedItemRecord.idCreatedBy = objRecord.CreatedById;
				objFeedItemRecord.strBody = objRecord.Body;
				objFeedItemRecord.strCreatedBy = objRecord.CreatedBy.Name;
				objFeedItemRecord.strCreatedDate = objRecord.CreatedDate.format();
				objFeedItemRecord.lstAttachments = new List<GlobalCustomChatterWrapperClass.AttachmentWrapperClass>();

				//If Body is null, we use Type.
				if(String.isBlank(objFeedItemRecord.strBody)) {
					objFeedItemRecord.strBody = objRecord.Type;
				}

				//We save the body for later.
				mapBodies.put(objFeedItemRecord.idRecord, objFeedItemRecord.strBody);

				//We determine if this Feed Items was found by tag approach.
				if(setSOSLFeedItemIds.contains(objRecord.Id) && !setParentIds.contains(objRecord.ParentId)) {
					objFeedItemRecord.boolFoundByTag = true;
				}

				//We save the id for the ConnectAPI analysis.
				lstAllFeedItems.add(objFeedItemRecord.idRecord);

				//We save the Photo Reference.
				mapUserPhotos.put(objRecord.CreatedById, null);

				//We save the attachments.
				if(objRecord.FeedAttachments != null && !objRecord.FeedAttachments.isEmpty()) {
					for(FeedAttachment objAttachment : objRecord.FeedAttachments) {
						mapContentVersions.put(objAttachment.RecordId, null);
						objWrappedAttachment = new GlobalCustomChatterWrapperClass.AttachmentWrapperClass();
						objWrappedAttachment.idContentVersion = objAttachment.RecordId;
						objFeedItemRecord.lstAttachments.add(objWrappedAttachment);
					}
				}

				//If we have replies.
				if(objRecord.FeedComments != null && !objRecord.FeedComments.isEmpty()) {
					objFeedItemRecord.lstReplies = new List<GlobalCustomChatterWrapperClass>();
					for(FeedComment objFeedComment : objRecord.FeedComments) {
						if(objFeedComment.Status == 'Published') {
							objFeedCommentRecord = new GlobalCustomChatterWrapperClass();
							objFeedCommentRecord.boolIsVisible = true;
							objFeedCommentRecord.idRecord = objFeedComment.Id;
							objFeedCommentRecord.idCommentRecord = objFeedComment.FeedItemId;
							objFeedCommentRecord.idCreatedBy = objFeedComment.CreatedById;
							objFeedCommentRecord.strBody = objFeedComment.CommentBody;
							objFeedCommentRecord.strCreatedBy = objFeedComment.CreatedBy.Name;
							objFeedCommentRecord.strCreatedDate = objFeedComment.CreatedDate.format();
							objFeedCommentRecord.lstAttachments = new List<GlobalCustomChatterWrapperClass.AttachmentWrapperClass>();

							//We save the body for later.
							mapBodies.put(objFeedCommentRecord.idRecord, objFeedCommentRecord.strBody);
							
							//We save the Photo Reference.
							mapUserPhotos.put(objFeedComment.CreatedById, null);

							//We save the Id, to look for attachments.
							if(objFeedComment.RelatedRecordId != null) {
								mapContentVersions.put(objFeedComment.RelatedRecordId, null);
								objWrappedAttachment = new GlobalCustomChatterWrapperClass.AttachmentWrapperClass();
								objWrappedAttachment.idContentVersion = objFeedComment.RelatedRecordId;
								objFeedCommentRecord.lstAttachments.add(objWrappedAttachment);
							}

							//We add the Reply to the list.
							objFeedItemRecord.lstReplies.add(objFeedCommentRecord);
						}
					}
				}
			}

			//We add the wrapped record to the list.
			lstResults.add(objFeedItemRecord);
		}

		//If we have records, we set the Photo URLs and Content Versions.
		if(!lstResults.isEmpty()) {

			//We get the URLs first.
			for(User objRecord : [SELECT Id, SmallPhotoUrl FROM User WHERE Id IN :mapUserPhotos.keySet() LIMIT 10000]) {
				mapUserPhotos.put(objRecord.Id, objRecord.SmallPhotoUrl);
			}

			//Now we get the Content Versions.
			for(ContentVersion objRecord : [SELECT Id, ContentDocumentId, ContentBodyId FROM ContentVersion WHERE Id IN :mapContentVersions.keySet() OR 
					ContentDocumentId IN :mapContentVersions.keySet() LIMIT 10000]) {
				mapContentVersions.put(objRecord.ContentDocumentId, objRecord);
				mapContentVersions.put(objRecord.Id, objRecord);
			}

			//We get the Tags from the ConnectAPI, if needed.
			if(!Test.isRunningTest()) {
				for(ConnectApi.BatchResult objFeedBatchResult : ConnectApi.ChatterFeeds.getFeedElementBatch(null, lstAllFeedItems)) {
					if(objFeedBatchResult.isSuccess()) {
						objFeedItemBatch = (ConnectApi.FeedItem) objFeedBatchResult.getResult();
						strBody = '';

						//We check the Body elements.
						for(ConnectApi.MessageSegment objSegment : objFeedItemBatch.body.messageSegments) {

							//Now we process the elements depending on their type.
							strBody += processBody(objSegment);
						}

						//If we have a body to save.
						if(String.isNotBlank(strBody)) {
							mapBodies.put(objFeedItemBatch.id, strBody);
						}

						//Now we check the replies.
						for(ConnectApi.Comment objComment : objFeedItemBatch.capabilities.comments.page.items) {
							strBody = '';

							//We check the Body elements.
							for(ConnectApi.MessageSegment objSegment : objComment.body.messageSegments) {

								//Now we process the elements depending on their type.
								strBody += processBody(objSegment);
							}

							//If we have a body to save.
							if(String.isNotBlank(strBody)) {
								mapBodies.put(objComment.id, strBody);
							}
						}
					}
				}
			}

			//We set the values.
			for(GlobalCustomChatterWrapperClass objRecord : lstResults) {
				objRecord.strCreatedByPhotoURL = mapUserPhotos.get(objRecord.idCreatedBy);

				//We check the attachments now.
				if(!objRecord.lstAttachments.isEmpty()) {
					for(GlobalCustomChatterWrapperClass.AttachmentWrapperClass objAttachment : objRecord.lstAttachments) {
						objExistingContentVersion = mapContentVersions.get(objAttachment.idContentVersion);
						objAttachment.idContentDocument = objExistingContentVersion.ContentDocumentId;
						objAttachment.idContentBody = objExistingContentVersion.ContentBodyId;
					}
				}

				//We set the final body.
				objRecord.strBody = mapBodies.get(objRecord.idRecord);

				//If we have replies.
				if(objRecord.lstReplies != null && !objRecord.lstReplies.isEmpty()) {
					for(GlobalCustomChatterWrapperClass objFeedComment : objRecord.lstReplies) {
						objFeedComment.strCreatedByPhotoURL = mapUserPhotos.get(objFeedComment.idCreatedBy);

						//We check the attachments now.
						if(!objFeedComment.lstAttachments.isEmpty()) {
							for(GlobalCustomChatterWrapperClass.AttachmentWrapperClass objAttachment : objFeedComment.lstAttachments) {
								objExistingContentVersion = mapContentVersions.get(objAttachment.idContentVersion);
								objAttachment.idContentDocument = objExistingContentVersion.ContentDocumentId;
								objAttachment.idContentBody = objExistingContentVersion.ContentBodyId;
							}
						}

						//We set the final body.
						objFeedComment.strBody = mapBodies.get(objFeedComment.idRecord);
					}
				}
			}
		}
	}
	return lstResults;
}

/*
 Method Name : extractValueRecursively
 Description : This method extracts a value recursively, from a parent-child relationship.
 Parameters	 : Object, called from extractValueRecursively, objParent Parent sObject.
				String, called from extractValueRecursively, strPath Relationship path.
 Return Type : Object
 */
public static Object extractValueRecursively(sObject objParent, String strPath) {
	String strCurrentLevel;
	String strRestOfLevel;
	Object objValue;
	List<String> lstPaths = new List<String>();
	if(strPath.contains('.')) {
		for(String strLevel : strPath.split('\\.')) {
			if(String.isBlank(strCurrentLevel)) {
				strCurrentLevel = strLevel;
			} else {
				lstPaths.add(strLevel);
			}
		}
		strRestOfLevel = String.join(lstPaths, '.');
		objValue = extractValueRecursively(objParent.getSObject(strCurrentLevel), strRestOfLevel);
	} else {
		objValue = objParent.get(strPath);
	}
	return objValue;
}

/*
 Method Name : processBody
 Description : This method processes all the body elements of a Feed Item or Feed Comment.
 Parameters	 : ConnectApi.MessageSegment, called from processBody, objSegment Chatter Item.
 Return Type : String.
 */
public static String processBody(ConnectApi.MessageSegment objSegment) {
	String strBody = '';
	ConnectApi.TextSegment objText;
	ConnectApi.EntityLinkSegment objLink;
	ConnectApi.MentionSegment objMention;
	ConnectApi.MarkupBeginSegment objLineBegin;
	ConnectApi.MarkupEndSegment objLineEnd;
	ConnectApi.InlineImageSegment objInlineImage;
	
	//Link.
	if(objSegment instanceof ConnectApi.EntityLinkSegment) {
		objLink = (ConnectApi.EntityLinkSegment) objSegment;
		strBody += '<a class="link" data-id="' + objLink.reference.id + '" data-tagged-content="true">' + objLink.text + '</a>';
	} else if(objSegment instanceof ConnectApi.MentionSegment) {

		//Mention.
		objMention = (ConnectApi.MentionSegment) objSegment;
		strBody += '<a class="link" data-id="' + objMention.record.id + '" data-tagged-content="true">@' + objMention.name + '</a>';
	} else if(objSegment instanceof ConnectApi.MarkupBeginSegment) {
		objLineBegin = (ConnectApi.MarkupBeginSegment) objSegment;

		//Markup Begin Segment.
		strBody += '<' + objLineBegin.htmlTag;

		//We add special properties, depending on the tag.
		switch on objLineBegin.htmlTag {
			when 'a' {
				strBody += ' class="link" data-url="' + objLineBegin.url + '"';
			}
		}

		//We close the tag.
		strBody += '>';
	} else if(objSegment instanceof ConnectApi.MarkupEndSegment) {
		objLineEnd = (ConnectApi.MarkupEndSegment) objSegment;

		//Markup Begin Segment.
		strBody += '</' + objLineEnd.htmlTag + '>';
	} else if(objSegment instanceof ConnectApi.InlineImageSegment) {
		objInlineImage = (ConnectApi.InlineImageSegment) objSegment;

		//Inline Image Segment.
		for(ConnectApi.FilePreview objFilePreview : objInlineImage.thumbnails.previews) {
			for(ConnectApi.FilePreviewUrl objFlePreviewURL : objFilePreview.previewUrls) {
				strBody = '<img src="' + objFlePreviewURL.previewUrl + '" />';
			}
		}
	} else if(objSegment instanceof ConnectApi.TextSegment) {

		//Text.
		objText = (ConnectApi.TextSegment) objSegment;

		//If we have breaklines, we replace them.
		if(objText.text.indexOf(strNewLine) > -1) {
			strBody += objText.text.replaceAll(strNewLine, '<p></p>');
		} else {
			strBody += objText.text;
		}
		strBody = '<span dir="ltr" class="uiOutputText">' + strBody + '</span>';
	}

	//We return the result.
	return strBody;
}
}