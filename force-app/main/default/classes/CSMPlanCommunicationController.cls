/*
 * Name			:	CSMPlanCommunicationController

 Change History
 ************************************************************************************************************************
 Modified By			Date			Jira No.		Description											Tag
 ************************************************************************************************************************
 ***************		2/10/2022		N/A				Initial version.								    N/A
 Karthi                 07/25/2022      AR-2770         Added PlanCommentEmailStats List					T1
 */

public without sharing class CSMPlanCommunicationController {
    @AuraEnabled(cacheable = false)
    public static void tagFilestoComments(String strPlanId, String strCommentId,List<String> fileIdList) {
        List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
        List<ContentDocumentLink> lstContentDocLinkToInsert = new List<ContentDocumentLink>();
        if(!fileIdList.isEmpty()) {
            Set<Id> setCommentId = new Set<Id>();
            setCommentId.add(Id.valueOf(strCommentId));
            lstContentDocLink = [Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension 
            From ContentDocumentLink 
            Where ContentDocumentId In :fileIdList];
        }
        for(ContentDocumentLink contentDocLink : lstContentDocLink) {
            if(contentDocLink.LinkedEntityId == Id.valueOf(strPlanId)){
                lstContentDocLinkToInsert.add(new ContentDocumentLink(Visibility= 'AllUsers', LinkedEntityId = strCommentId, ContentDocumentId = contentDocLink.ContentDocumentId));
            }
        }
        //insert attachments
        if(!lstContentDocLinkToInsert.isEmpty()) {
            insert lstContentDocLinkToInsert;
        }
    }

     /**
     * @description Method to fetch attachments for the case comment
     */
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getDocuments (String linkedEntityId, String parentId, Boolean isId) {
        system.debug('====>'+linkedEntityId+' =>  '+parentId+' => '+isId);
        if(!isId) {
            return [SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId,
            Id FROM ContentDocumentLink WHERE ContentDocumentId IN :parentId.split(',') AND LinkedEntityId = :linkedEntityId];
        } else {
            return [SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId,
                     Id FROM ContentDocumentLink WHERE LinkedEntityId = :parentId];
        }
    }
     /*
	 Method Name : checkPlanAutoPilot
	 Description : This method returns the boolean variable if provided csm custom permission available and plan i autopilot.
	 Parameters	 : String, called from checkPlanAutoPilot, strPlanId Record Id.
	 Return Type : Boolean, isAutoPilot 
	 */
    @AuraEnabled
    public static Boolean checkPlanAutoPilot(String strPlanId) {
        String strCleanPlanId;
        Boolean isAutoPilot=false;
        List<Plan__c> lstPlan= new List<Plan__c>();
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            lstPlan=[SELECT Id, CSM_isAutoPilot__c, Status__c FROM Plan__c where id=:strCleanPlanId];
            if(lstPlan.size()>0){
                isAutoPilot = CSMUtilities.hasCSMPermisson(lstPlan[0].CSM_isAutoPilot__c) && lstPlan[0].Status__c!='Complete';
            }
        }
        return isAutoPilot;
    }

	
  /*
	 Method Name : getRecords
	 Description : This method returns the Plan commnent records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 Return Type : List<Plan_Team__c>, List of plan team records
	 */
    @AuraEnabled(cacheable = false)
    public static List<CSMPlanCommunicationWrapperClass> getRecords(String strPlanId,String strCommentType, String strCommentSubType) {
		Boolean boolIsAttentionRequest = false;
		Boolean boolIsAll = true;
		Boolean boolIsInbound;
		Boolean boolShouldIncludeRecord;
		List<Plan_Comment__c> lstOriginalPlanComments = new List<Plan_Comment__c>();
        List<CSMPlanCommunicationWrapperClass> planCommentList = new List<CSMPlanCommunicationWrapperClass>();
		Map<Id, List<ContentDocumentLink>> mapChildFiles = new Map<Id, List<ContentDocumentLink>>();
        Id currentUserId = UserInfo.getUserId();
		String strTypeCondition = ' AND Type__c =:strCommentType';
        String strCleanPlanId;
        String strPreDraftValue='Pre Draft';
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
             String commentQuery  = 'SELECT Is_Automated__c, Created_By__c, Case__c, Case__r.CaseNumber, Customer_Risk_Reason__c, Id, Subject__c, CreatedBy.FullPhotoUrl,CreatedBy.Name,Comment__c, Plan__c, Type__c, Sub_Type__c ,Status__c,Visibility__c,LastModifiedDate,CreatedDate,Importance__c,Date_Time_Scheduled__c,Parent_Comment__c,CreatedById,Inbound__c, Request_Sign_Off__c,Plan__r.CSM_isAutoPilot__c,';
					commentQuery += 'Tagged_User_1__r.Id, Tagged_User_1__r.Name, Tagged_User_2__r.Id, Tagged_User_2__r.Name, Tagged_User_3__r.Id, Tagged_User_3__r.Name, Tagged_User_4__r.Id, Tagged_User_4__r.Name, Tagged_User_5__r.Id, Tagged_User_5__r.Name,';
                    commentQuery += '(SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks),';
                    commentQuery += '(SELECT id, Email_Opened__c, Plan_Comment__c,Email__c,Delivery__c  from PlanCommentEmailStats__r),'; //T1
                    commentQuery += '(SELECT Is_Automated__c, Id, Plan__r.CSM_isAutoPilot__c, Created_By__c, Subject__c, CreatedBy.FullPhotoUrl,CreatedBy.Name,Comment__c, Plan__c, Type__c, Sub_Type__c ,Status__c,Visibility__c,LastModifiedDate,CreatedDate,Importance__c,Date_Time_Scheduled__c,Parent_Comment__c,CreatedById,Inbound__c, Request_Sign_Off__c FROM Plan_Comments__r)';
                    commentQuery += ' FROM Plan_Comment__c where Plan__c=:strCleanPlanId AND Status__c!=:strPreDraftValue AND Parent_Comment__c=null';
                    commentQuery += ' AND (Visibility__c != \'Private\' OR CreatedById=:currentUserId)  AND (Status__c != \'Draft\' OR (Status__c = \'Draft\' AND CreatedById =: currentUserId))';
            if(String.isNotBlank(strCommentType)) {
				boolIsAll = false;
				if(strCommentType == 'Inbound') {
					boolIsInbound = true;
				} else if(strCommentType == 'External') {
					boolIsInbound = false;
				}
                if(String.isNotBlank(strCommentSubType) && strCommentType=='Internal' && strCommentSubType != 'My Tagged'){
                    strTypeCondition += ' AND Sub_Type__c =:strCommentSubType';
                }
				if(String.isNotBlank(strCommentSubType) && strCommentType == 'Internal' && strCommentSubType == 'My Tagged'){
                    strTypeCondition += ' AND (Tagged_User_1__c = :currentUserId OR Tagged_User_2__c = :currentUserId OR Tagged_User_3__c = :currentUserId OR Tagged_User_4__c = :currentUserId OR ';
					strTypeCondition += 'Tagged_User_5__c = :currentUserId)';
                }

				//We include Inbound records if their children contains Risks, and the selected tabs are Internal > Risk.
				if(strCommentType == 'External' || (strCommentType == 'Internal' && strCommentSubType != 'My Tagged') || strCommentType == 'Private') {
					if(String.isNotBlank(strCommentSubType)) {
						strTypeCondition = ' AND ((Type__c = :strCommentType AND Sub_Type__c = :strCommentSubType) OR Type__c = \'Inbound\')';
					} else {
						strTypeCondition = ' AND (Type__c = :strCommentType OR Type__c = \'Inbound\')';
					}
				} else if(strCommentType == 'Attention Request') {
					boolIsAttentionRequest = true;
					strTypeCondition = ' AND Type__c = \'Inbound\' AND Sub_Type__c = \'Attention Request\'';
				}

				//We add the addtional clauses.
				commentQuery += strTypeCondition;
            }
            commentQuery+=' ORDER BY CreatedDate ASC';

			//We include Inbound records if their children contains Risks, and the selected tabs are Internal > Risk.
			if(strCommentType == 'External' || (strCommentType == 'Internal' && strCommentSubType != 'My Tagged') || strCommentType == 'Private') {
				for(Plan_Comment__c objPlanComment : Database.query(commentQuery)) {
					if(objPlanComment.Type__c != 'Inbound') {
						lstOriginalPlanComments.add(objPlanComment);

						//We save the child ids.
						if(objPlanComment.Plan_Comments__r != null && !objPlanComment.Plan_Comments__r.isEmpty()) {
							for(Plan_Comment__c objChildPlanComment : objPlanComment.Plan_Comments__r) {
								mapChildFiles.put(objChildPlanComment.Id, new List<ContentDocumentLink>());
							}
						}
					} else if(objPlanComment.Plan_Comments__r != null) {
						boolShouldIncludeRecord = false;
						for(Plan_Comment__c objPlanCommentChild : objPlanComment.Plan_Comments__r) {
							if(objPlanCommentChild.Type__c == strCommentType && (strCommentType == 'External' || strCommentType == 'Private' || objPlanCommentChild.Sub_Type__c == strCommentSubType)) {
								boolShouldIncludeRecord = true;
							}
						}
						if(boolShouldIncludeRecord) {
							lstOriginalPlanComments.add(objPlanComment);

							//We save the child ids.
							if(objPlanComment.Plan_Comments__r != null && !objPlanComment.Plan_Comments__r.isEmpty()) {
								for(Plan_Comment__c objChildPlanComment : objPlanComment.Plan_Comments__r) {
									mapChildFiles.put(objChildPlanComment.Id, new List<ContentDocumentLink>());
								}
							}
						}
					}
				}
			} else {

				//We do a normal query.
				for(Plan_Comment__c objPlanComment : Database.query(commentQuery)) {
					lstOriginalPlanComments.add(objPlanComment);

					//We save the child ids.
					if(objPlanComment.Plan_Comments__r != null && !objPlanComment.Plan_Comments__r.isEmpty()) {
						for(Plan_Comment__c objChildPlanComment : objPlanComment.Plan_Comments__r) {
							mapChildFiles.put(objChildPlanComment.Id, new List<ContentDocumentLink>());
						}
					}
				}
			}

			//Now we get the Files / Attachments of the child Plan Comments.
			for(Plan_Comment__c objChildPlanComment : [SELECT Id, (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks) FROM 
					Plan_Comment__c WHERE Id IN :mapChildFiles.keySet() LIMIT 10000]) {
				if(objChildPlanComment.ContentDocumentLinks != null && !objChildPlanComment.ContentDocumentLinks.isEmpty()) {
					mapChildFiles.put(objChildPlanComment.Id, objChildPlanComment.ContentDocumentLinks);
				}
			}

			//Now we create the wrappers.
			for(Plan_Comment__c objPlanComment : lstOriginalPlanComments) {
				planCommentList.add(convertSObjectToPlanCommentWrapper(objPlanComment, mapChildFiles));
			}

			//Now we query the Email Messages related to the given plan.
			if(!boolIsAttentionRequest) {
				if(boolIsAll) {
					for(EmailMessage objEmailMessage : [SELECT Id, MessageDate, FromName, Incoming, CreatedById, Plan__c, Subject, HTMLBody, LastModifiedDate, CreatedDate, CreatedBy.FullPhotoUrl, 
							CreatedBy.Name, Plan__r.CSM_isAutoPilot__c, (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks) FROM 
							EmailMessage WHERE RelatedToId = :strPlanId LIMIT 10000]) {
						planCommentList.add(convertSObjectToPlanCommentWrapper(objEmailMessage));
					}
				} else if(boolIsInbound != null) {
					for(EmailMessage objEmailMessage : [SELECT Id, MessageDate, FromName, Incoming, CreatedById, Plan__c, Subject, HTMLBody, LastModifiedDate, CreatedDate, CreatedBy.FullPhotoUrl, 
							CreatedBy.Name, Plan__r.CSM_isAutoPilot__c, (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks) FROM 
							EmailMessage WHERE RelatedToId = :strPlanId AND Incoming = :boolIsInbound LIMIT 10000]) {
						planCommentList.add(convertSObjectToPlanCommentWrapper(objEmailMessage));
					}
				}
			}
        }
		planCommentList.sort();
        return planCommentList;
    }

    /*
	 Method Name : convertSObjectToPlanCommentWrapper
	 Description : This method wrappes a Plan Comment.
	 Parameters	 : String, called from convertSObjectToPlanCommentWrapper, objRecord Record to be wrapped.
	 Return Type : Plan Comment wrapped
	 */
    @AuraEnabled(cacheable = false)
    public static CSMPlanCommunicationWrapperClass convertSObjectToPlanCommentWrapper(SObject objRecord) {
		return convertSObjectToPlanCommentWrapper(objRecord, null);
	}

    /*
	 Method Name : convertSObjectToPlanCommentWrapper
	 Description : This method wrappes a Plan Comment.
	 Parameters	 : String, called from convertSObjectToPlanCommentWrapper, objRecord Record to be wrapped.
	 			   Map, called from convertSObjectToPlanCommentWrapper, mapChildFiles Child files.
	 Return Type : Plan Comment wrapped
	 */
    @AuraEnabled(cacheable = false)
    public static CSMPlanCommunicationWrapperClass convertSObjectToPlanCommentWrapper(SObject objRecord, Map<Id, List<ContentDocumentLink>> mapChildFiles) {
		Plan_Comment__c objPlanComment;
		EmailMessage objEmailMessage;
		CSMPlanCommunicationWrapperClass objWrappedChildRecord;
        CSMPlanCommunicationWrapperClass objWrappedRecord = new CSMPlanCommunicationWrapperClass();
		if(objRecord != null) {
			if(objRecord.getSObjectType() == Schema.Plan_Comment__c.getSObjectType()) {
				objPlanComment = (Plan_Comment__c) objRecord;
				objWrappedRecord.Inbound = objPlanComment.Inbound__c;
				objWrappedRecord.Id = objPlanComment.Id;
				objWrappedRecord.Parent_Comment = objPlanComment.Parent_Comment__c;
				objWrappedRecord.CreatedById = objPlanComment.CreatedById;
				objWrappedRecord.PlanId = objPlanComment.Plan__c;
				objWrappedRecord.Subject = objPlanComment.Subject__c;
				objWrappedRecord.Comment = objPlanComment.Comment__c;
				objWrappedRecord.Type = objPlanComment.Type__c;
				objWrappedRecord.Sub_Type = objPlanComment.Sub_Type__c;
				objWrappedRecord.Status = objPlanComment.Status__c;
				objWrappedRecord.Visibility = objPlanComment.Visibility__c;
				objWrappedRecord.Importance = objPlanComment.Importance__c;
				objWrappedRecord.LastModifiedDate = objPlanComment.LastModifiedDate;
				objWrappedRecord.CreatedDate = objPlanComment.CreatedDate;
				objWrappedRecord.Date_Time_Scheduled = objPlanComment.Date_Time_Scheduled__c;
				objWrappedRecord.CreatedBy = objPlanComment.CreatedBy;
				objWrappedRecord.Plan = objPlanComment.Plan__r;
				objWrappedRecord.Request_Sign_Off = objPlanComment.Request_Sign_Off__c;
				objWrappedRecord.ContentDocumentLinks = objPlanComment.ContentDocumentLinks;
				objWrappedRecord.PlanCommentEmailStats = objPlanComment.PlanCommentEmailStats__r; //T1
				if((objWrappedRecord.ContentDocumentLinks == null || objWrappedRecord.ContentDocumentLinks.isEmpty()) && mapChildFiles != null && !mapChildFiles.isEmpty()) {
					objWrappedRecord.ContentDocumentLinks = mapChildFiles.get(objPlanComment.Id);
				}
				objWrappedRecord.Plan_Comments = objPlanComment.Plan_Comments__r;
				objWrappedRecord.objPlanComment = objPlanComment;
				objWrappedRecord.CreatedByName = objPlanComment.Created_By__c;
				objWrappedRecord.Is_Automated = objPlanComment.Is_Automated__c;

				//Now we parse the related plan comments.
				if(objPlanComment.Plan_Comments__r != null && !objPlanComment.Plan_Comments__r.isEmpty()) {
					objWrappedRecord.lstChildComments = new List<CSMPlanCommunicationWrapperClass>();
					for(Plan_Comment__c objChildPlanComment : objPlanComment.Plan_Comments__r) {
						objWrappedChildRecord = convertSObjectToPlanCommentWrapper(objChildPlanComment, mapChildFiles);
						objWrappedChildRecord.boolExternalSorting = true;
						objWrappedChildRecord.strSortDirection = 'desc';
						objWrappedRecord.lstChildComments.add(objWrappedChildRecord);
					}
					objWrappedRecord.lstChildComments.sort();
				}
			} else if(objRecord.getSObjectType() == Schema.EmailMessage.getSObjectType()) {
				objEmailMessage = (EmailMessage) objRecord;
				objWrappedRecord.Inbound = objEmailMessage.Incoming;
				objWrappedRecord.Id = objEmailMessage.Id;
				objWrappedRecord.CreatedById = objEmailMessage.CreatedById;
				objWrappedRecord.PlanId = objEmailMessage.Plan__c;
				objWrappedRecord.Subject = objEmailMessage.Subject;
				objWrappedRecord.Comment = objEmailMessage.HTMLBody;
				objWrappedRecord.Type = 'External';
				if(objWrappedRecord.Inbound) {
					objWrappedRecord.Type = 'Inbound';
				}
				objWrappedRecord.Sub_Type = 'Email';
				objWrappedRecord.Status = 'Submitted';
				objWrappedRecord.Visibility = 'External';
				objWrappedRecord.LastModifiedDate = objEmailMessage.MessageDate;
				objWrappedRecord.CreatedDate = objEmailMessage.MessageDate;
				objWrappedRecord.CreatedBy = objEmailMessage.CreatedBy;
				objWrappedRecord.Plan = objEmailMessage.Plan__r;
				objWrappedRecord.ContentDocumentLinks = objEmailMessage.ContentDocumentLinks;
				objWrappedRecord.CreatedByName = objEmailMessage.FromName;
			}
		}
        return objWrappedRecord;
    }

    /*
	 Method Name : getEmailTemplates
	 Description : This method returns the list of email templates configured for quick action.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 Return Type : QuickActionWrapper, Wrapper instance
	 */
    @AuraEnabled(cacheable = false)
    public static QuickActionWrapper getEmailTemplates(String strPlanId) {
        QuickActionWrapper wrapper = new QuickActionWrapper();   
        for(EmailTemplate emailTemplate : [SELECT Id, Name, DeveloperName,Folder.Name,Description FROM EmailTemplate WHERE IsActive = true AND Folder.Name='Plan QuickText Templates']) {
           // Case_Communication_Quick_Text_Mapping__mdt mdt = emailTemplateMap.get(emailTemplate.Name);
            QuickTextEmailTemplateWrapper emailTemplateWrapper = new QuickTextEmailTemplateWrapper();
            emailTemplateWrapper.customMetadataName = emailTemplate.DeveloperName;
            emailTemplateWrapper.emailTemplateName = emailTemplate.DeveloperName;
            emailTemplateWrapper.description = emailTemplate.Description;
            emailTemplateWrapper.emailTemplateLabel = emailTemplate.Name;
            wrapper.emailTemplateList.add(emailTemplateWrapper);
        }                                                   
        return wrapper;
    }


    public class QuickActionWrapper {
        @AuraEnabled
        public List<String> quickUpdateFieldList {get;set;}
        @AuraEnabled
        public List<QuickTextEmailTemplateWrapper> emailTemplateList {get;set;}

        public QuickActionWrapper() {
            this.quickUpdateFieldList = new List<String>();
            this.emailTemplateList = new List<QuickTextEmailTemplateWrapper>();   
        }
    }

    public class QuickTextEmailTemplateWrapper {
        @AuraEnabled
        public String customMetadataName {get;set;}
        @AuraEnabled
        public String emailTemplateName {get;set;}
        @AuraEnabled
        public String emailTemplateLabel {get;set;}
        @AuraEnabled
        public String description {get;set;}
    }


    @AuraEnabled
    public static string fetchMergedQuickText(String templateName, String strPlanId) {
        String mergedText = '';
        mergedText = csmPlanQuickActionController.getEmailBody(strPlanId, templateName);
        return mergedText;
    }

    @AuraEnabled(cacheable = false)
    public static Boolean createJiraCommentFromPlanComment(String strRecordId) {
        Boolean boolSendRequestToJira=false;
        String strCleanCommentId;
        if(String.isNotBlank(strRecordId)) {
            strCleanCommentId = String.escapeSingleQuotes(strRecordId);
            Plan_Comment__c cc = [SELECT Id,Comment__c,Parent_Comment__c FROM Plan_Comment__c WHERE Id=:strCleanCommentId];
            String body = cc.Comment__c + Label.CaseComment_Jira;
            body = body.replaceAll('<[^>]+>',' ');
            if(cc.Parent_Comment__c <> null){
                Plan_Comment__c parentRec = [Select Id,ZIssue__c from Plan_Comment__c where Id = :cc.Parent_Comment__c]; // chnage to plan comment.
                if(parentRec.ZIssue__c != null){
                    postZiraComment(parentRec.ZIssue__c,body);
                    boolSendRequestToJira=true;
                }
            }    
        }
        return boolSendRequestToJira;
    }
     /*

     Method Name : postZiraComment
     Description : will create a jira
     Parameters  : Plan Comment Sobject
     Return Type : NULL
    */

    @future(callout=true)
    public static void postZiraComment(Id zissueId, String strbody) {
        zsfjira__ZIssue__c zc = [Select Id,Name from zsfjira__ZIssue__c  where Id = :zissueId LIMIT 1];            
        zsfjira.ZCBeans.IssueCommentResult result = zsfjira.ZC.Issues.createJIRAIssueComment(zc.Name,strbody);      
    }

    @AuraEnabled(cacheable=true)
    public static boolean getPermissionOnObject(){
        Schema.DescribeSObjectResult s = Plan_Comment__c.sObjectType.getDescribe();
        Boolean isCreateable = s.isCreateable();
        return isCreateable;
    }
    @AuraEnabled(cacheable = false)
    public static List<Plan_Team__c> getPlanTeamRecords(String strPlanId) {
        Id currentUserId = UserInfo.getUserId();
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        String strCleanPlanId;
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);   
            planTeamList = [SELECT Id, Role__c,User__c,Last_Read_TimeStamp__c FROM Plan_Team__c WHERE Plan__c=:strCleanPlanId AND User__c=:currentUserId];
        }
        return planTeamList;
    }

    @AuraEnabled(cacheable = false)
    public static void updatePlanTeamRecord(String strPlanId) {
        Id currentUserId = UserInfo.getUserId();
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        String strCleanPlanId;
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);   
            for(Plan_Team__c pteam:[SELECT Id, Role__c,User__c,Last_Read_TimeStamp__c FROM Plan_Team__c WHERE Plan__c=:strCleanPlanId AND User__c=:currentUserId]){
                pteam.Last_Read_TimeStamp__c=system.now();
                planTeamList.add(pteam);
            }
            if(planTeamList.size()>0){
                update planTeamList;
            }
        }
    }

	/*
	 Method Name : closeInboundAttentionRequestParent
	 Description : This method changes the attention request status of the parent Plan Comment to Closed.
	 Parameters	 : String, called from closeInboundAttentionRequestParent, strChildPlanCommentId Child Plan Comment Id.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
  	public static void closeInboundAttentionRequestParent(String strChildPlanCommentId) {
		Plan_Comment__c objParentPlanComment = new Plan_Comment__c();
		if(String.isNotBlank(strChildPlanCommentId)) {
			for(Plan_Comment__c objChildPlanComment : [SELECT Parent_Comment__c FROM Plan_Comment__c WHERE Id = :strChildPlanCommentId AND Parent_Comment__r.Type__c = 'Inbound' AND 
					Parent_Comment__r.Sub_Type__c = 'Attention Request' LIMIT 1]) {
				objParentPlanComment.Id = objChildPlanComment.Parent_Comment__c;
				objParentPlanComment.Attention_Request_Status__c = 'Closed';
				update objParentPlanComment;
			}
		}
   	}

	/*
	 Method Name : getTaggedUsers
	 Description : This method returns the Plan Comment record with the tagged users.
	 Parameters	 : String, called from getTaggedUsers, strChildPlanCommentId Plan Comment Id.
	 Return Type : Object
	 */
	@AuraEnabled(cacheable = false)
	public static Plan_Comment__c getTaggedUsers(String strRecordId) {
		Plan_Comment__c objPlanComment = new Plan_Comment__c();
		if(String.isNotBlank(strRecordId)) {
			for(Plan_Comment__c objExistingRecord : [SELECT Tagged_User_1__r.Id, Tagged_User_1__r.Name, Tagged_User_2__r.Id, Tagged_User_2__r.Name, Tagged_User_3__r.Id, Tagged_User_3__r.Name, 
					Tagged_User_4__r.Id, Tagged_User_4__r.Name, Tagged_User_5__r.Id, Tagged_User_5__r.Name FROM Plan_Comment__c WHERE Id = :strRecordId LIMIT 1]) {
				objPlanComment = objExistingRecord;
			}
		}
		return objPlanComment;
	}

	/*
	 Method Name : removedTaggedUser
	 Description : This method removed a tagged user from the Plan comment.
	 Parameters	 : String, called from removedTaggedUser, strPlanCommentId Plan Comment Id.
	 Return Type : Object
	 */
	@AuraEnabled(cacheable = false)
	public static Plan_Comment__c removedTaggedUser(String strPlanCommentId, String strUserId) {
		List<Id> lstIds = new List<Id>();
		Plan_Comment__c objParentPlanComment = new Plan_Comment__c();

		//If we received the ids.
		if(String.isNotBlank(strPlanCommentId) && String.isNotBlank(strUserId)) {
			for(Plan_Comment__c objExistingRecord : [SELECT Id, Tagged_User_1__c, Tagged_User_2__c, Tagged_User_3__c, Tagged_User_4__c, Tagged_User_5__c FROM Plan_Comment__c WHERE 
					Id = :strPlanCommentId LIMIT 1]) {
				
				//First we extract only the user ids that should remain.
				if(objExistingRecord.Tagged_User_1__c != strUserId) {
					lstIds.add(objExistingRecord.Tagged_User_1__c);
				}
				if(objExistingRecord.Tagged_User_2__c != strUserId) {
					lstIds.add(objExistingRecord.Tagged_User_2__c);
				}
				if(objExistingRecord.Tagged_User_3__c != strUserId) {
					lstIds.add(objExistingRecord.Tagged_User_3__c);
				}
				if(objExistingRecord.Tagged_User_4__c != strUserId) {
					lstIds.add(objExistingRecord.Tagged_User_4__c);
				}
				if(objExistingRecord.Tagged_User_5__c != strUserId) {
					lstIds.add(objExistingRecord.Tagged_User_5__c);
				}

				//Now we set all the fields to null.
				objExistingRecord.Tagged_User_1__c = null;
				objExistingRecord.Tagged_User_2__c = null;
				objExistingRecord.Tagged_User_3__c = null;
				objExistingRecord.Tagged_User_4__c = null;
				objExistingRecord.Tagged_User_5__c = null;

				//Now we fill again the fields.
				for(Id idUser : lstIds) {
					if(objExistingRecord.Tagged_User_1__c == null) {
						objExistingRecord.Tagged_User_1__c = idUser;
					} else if(objExistingRecord.Tagged_User_2__c == null) {
						objExistingRecord.Tagged_User_2__c = idUser;
					} else if(objExistingRecord.Tagged_User_3__c == null) {
						objExistingRecord.Tagged_User_3__c = idUser;
					} else if(objExistingRecord.Tagged_User_4__c == null) {
						objExistingRecord.Tagged_User_4__c = idUser;
					}
				}

				//Now we update the record.
				update objExistingRecord;

				//Now we get the new record with Id and Name values.
				objParentPlanComment = getTaggedUsers(strPlanCommentId);
			}
		}
		return objParentPlanComment;
	}

}