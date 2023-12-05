/*
 * Name			:	CSMSendGridPlanController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	12/22/2021
 * Description	:	SendGrid Controller for Cosmos.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		12/22/2021		N/A				Initial version.			N/A
Narpavi Prabu    		6-07-2022 		AR-2740			Add user Nickname in send grid email     		T01
 */
public with sharing class CSMSendGridPlanController {

	//Public variables.
	public static final String FROMSIT = 'customersuccesssit@informatica.com';
    public static final String FROMUAT = 'customersuccessuat@informatica.com';
    public static final String FROMPROD = 'customersuccess@informatica.com';
    public static final String FROMNAME = 'Customer Success';
	
    /*
	 Method Name : sendEmail
	 Description : This method sends the email using the SendGrid service.
	 Parameters	 : Object, called from sendEmail, objParameters Email parameters.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void sendEmail(Boolean boolIsPriority, String strPlanCommentId, String strUseCase) {
		Boolean boolHasContacts = false;
		Boolean boolIsSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
		SendGridWrapper.FileObject objFile;
		SendGridWrapper.EmailIdWrapper objRecipient;
		SendGridWrapper.Dynamictemplate objDynamicVariables = new SendGridWrapper.Dynamictemplate();
		SendGridWrapper.EmailIdWrapper objSender = new SendGridWrapper.EmailIdWrapper();
        SendGridWrapper.EmailIdWrapper objReplyTo = new SendGridWrapper.EmailIdWrapper();
		SendGridWrapper.Uniqueargs objUniqueArguments = new SendGridWrapper.Uniqueargs();
		SendGridWrapper.Header objHeaders = new SendGridWrapper.Header();
        SendGridWrapper.Tracking_settings objTrackingSettings = new SendGridWrapper.Tracking_settings();
        SendGridWrapper.Enable_Mode objTrackingMode = new SendGridWrapper.Enable_Mode();
		SendGridWrapper.Enable_Mode objSandboxMode = new SendGridWrapper.Enable_Mode();
		SendGridWrapper.Mail_settings objMailSettings = new SendGridWrapper.Mail_settings();
		SendGridWrapper.Personalizations objRequest = new SendGridWrapper.Personalizations();
		Set<Id> setContentDocumentIds = new Set<Id>();
        List<SendGridWrapper.FileObject> lstAttachments = new List<SendGridWrapper.FileObject>();
		List<SendGridWrapper.Personalizations> lstRequests = new List<SendGridWrapper.Personalizations>();
        Map<String, List<SendGridWrapper.FileObject>> mapAttachments;

		//We fetch the record.
		for(Plan_Comment__c objPlanComment : [SELECT Id, Comment__c, Plan__c, Plan__r.Stage__c, Plan__r.Name, Plan__r.Account__r.Name, Plan__r.Thread_Id__c, Plan__r.OwnerId, Plan__r.Owner.Name,Plan__r.Owner_NickName__c, CreatedDate FROM 
				Plan_Comment__c WHERE Id = :strPlanCommentId AND Visibility__c = 'External' AND Status__c = 'Submitted' LIMIT 1]) {

			//We set the data.
			objDynamicVariables.strPlanStage = objPlanComment.Plan__r.Stage__c;
			objDynamicVariables.strPlanComment = objPlanComment.Comment__c;
			objDynamicVariables.strPlanName = objPlanComment.Plan__r.Name;
			objDynamicVariables.strAccountName = objPlanComment.Plan__r.Account__r.Name;
			objDynamicVariables.strPlanCommentDate = objPlanComment.CreatedDate.format('d MMM yyyy, h:mm a z');
			objDynamicVariables.strRefId = objPlanComment.Plan__r.Thread_Id__c;
			objDynamicVariables.strPlanOwnerName = objPlanComment.Plan__r.Owner.Name;
           //<T01>
            objDynamicVariables.strPlanOwnerNickName = objPlanComment.Plan__r.Owner_NickName__c;        

			//We get the community URL.
			for(Site objSite : [SELECT Id FROM Site WHERE (UrlPathPrefix = 'success' OR UrlPathPrefix = 'success/s') LIMIT 1]) {
				for(SiteDetail objSiteDetail : [SELECT SecureURL FROM SiteDetail WHERE DurableId = :objSite.Id]) {
					objDynamicVariables.strPlanURL = objSiteDetail.SecureUrl + '/plan-details';
				}
			}

			//We define the plan stage.
			switch on objDynamicVariables.strPlanStage {
				when 'Purchase' {
					objDynamicVariables.boolIsStage1 = true;
				}
				when 'Implement' {
					objDynamicVariables.boolIsStage2 = true;
				}
				when 'Value' {
					objDynamicVariables.boolIsStage3 = true;
				}
				when 'Scale' {
					objDynamicVariables.boolIsStage4 = true;
				}
			}

			//We get the latest not completed milestone, based on the due date.
			for(Milestone__c objMilestone : [SELECT Name, Planned_Completion_Date__c FROM Milestone__c WHERE Objective__r.Plan__c = :objPlanComment.Plan__c AND Status__c <> 'Complete' AND 
					Planned_Completion_Date__c <> NULL ORDER BY Planned_Completion_Date__c DESC LIMIT 1]) {
				objDynamicVariables.strMilestoneDescription = objMilestone.Name;
				if(objMilestone.Planned_Completion_Date__c != null) {
					objDynamicVariables.strMilestoneDueDate = Datetime.newInstance(objMilestone.Planned_Completion_Date__c.year(), objMilestone.Planned_Completion_Date__c.month(), 
							objMilestone.Planned_Completion_Date__c.day()).format('d MMMM yyyy');
				}
			}

			//We set the unique id of the related record.
			objUniqueArguments.ccid = strPlanCommentId;
			objRequest.custom_args = objUniqueArguments;        
			
			//Now we activate the click tracking.
			objTrackingMode.enable = true;
			objTrackingSettings.click_tracking = objTrackingMode;

			//We make sure the emails are sent, disabling the sandbox mode.
			objSandboxMode.enable = false;
			objMailSettings.sandbox_mode = objSandboxMode;
			
			//Now we set the email as high priority, if needed.
			if(boolIsPriority) {
				objHeaders.priority = 'Urgent';
				objHeaders.importance = 'High';
			}

			//Now we add the recipients.
			objRequest.to = new List<SendGridWrapper.EmailIdWrapper>();
			for(Plan_Contact__c objPlanContact : [SELECT Contact__r.Name, Contact__r.Email FROM Plan_Contact__c WHERE Plan__c = :objPlanComment.Plan__c AND Recieve_Email__c = TRUE AND 
					Contact__c <> NULL AND Contact__r.Name <> NULL AND Contact__r.Email <> NULL LIMIT 1000]) {
				objRecipient = new SendGridWrapper.EmailIdWrapper();
				objRecipient.email = objPlanContact.Contact__r.Email;
				objRecipient.name = objPlanContact.Contact__r.Name.replace('\'', '&#39;');
				objRequest.to.add(objRecipient);
				boolHasContacts = true;
			}

			//If we have contacts.
			if(boolHasContacts) {

				//Now we determine the From and Reply To addresses.
				objSender.name = FROMNAME;        
				objReplyTo.name = FROMNAME;
				objSender.email = FROMPROD;
				objReplyTo.email = FROMPROD;
				if(boolIsSandbox) {
					objSender.email = FROMSIT;
					objReplyTo.email = FROMSIT;
					if(URL.getSalesforceBaseUrl().toExternalForm().contains('infa--uat') || Test.isRunningTest()){
						objSender.email = FROMUAT;
						objReplyTo.email = FROMUAT;
					}          
				}
				
				//Now we generate the documents.
				mapAttachments = SendGridGCSController.generateDocumentRecords(objDynamicVariables.strPlanComment);
				for(String strBody : mapAttachments.keySet()) {
					objDynamicVariables.strPlanComment = strBody;
					lstAttachments = mapAttachments.get(strBody);
				}

				//We get the current user data.
				for(User objCurrentUser : [SELECT Name, Email, Phone, SmallPhotoUrl FROM User WHERE Id = :objPlanComment.Plan__r.OwnerId]) {
					objFile = new SendGridWrapper.FileObject();
					objFile.filename = 'customsuccessmanagerprofilepic.png';
					objFile.type = 'image/png';
					objFile.content_id = 'customsuccessmanagerprofilepic';
					objFile.disposition = 'inline';
					objDynamicVariables.boolHasProfilePicture = true;
					objDynamicVariables.strCSMEmail = objCurrentUser.Email;
					objDynamicVariables.strCSMPhone = objCurrentUser.Phone;
					objDynamicVariables.strCSMName = objCurrentUser.Name;
					if(objCurrentUser.SmallPhotoUrl.endsWithIgnoreCase('profilephoto/005/T')) {
						objDynamicVariables.boolHasProfilePicture = false;
					} else if(!Test.isRunningTest()) {
						objFile.content = EncodingUtil.base64Encode(new PageReference(objCurrentUser.SmallPhotoUrl).getContent());
						lstAttachments.add(objFile);
					}
				}

				//Now we add the attachments.
				for(ContentDocumentLink objContentDocument : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :objPlanComment.Id LIMIT 10000]) {
					setContentDocumentIds.add(objContentDocument.ContentDocumentId);
				}
				if(!setContentDocumentIds.isEmpty()) {
					for(ContentVersion objContentVersion : [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :setContentDocumentIds AND 
							IsLatest = true LIMIT 10000]) {
						objFile = new SendGridWrapper.FileObject();
						objFile.filename = objContentVersion.Title + '.' + objContentVersion.FileExtension;
						objFile.content_id = objContentVersion.Id;
						objFile.content = EncodingUtil.base64Encode(objContentVersion.VersionData);
						lstAttachments.add(objFile);
					}
				}
		
				//Now we prepare the final request structure.
				objRequest.dynamic_template_data = objDynamicVariables;
				lstRequests.add(objRequest);
		
				//Now we send the email.
				SendGridEmailService.sendemail([SELECT Template_Id__c FROM SendGrid_Templates__mdt WHERE Domain__c = 'Service Cloud' AND Use_Case__c = :strUseCase LIMIT 1].Template_Id__c, 
						lstRequests, objSender, objReplyTo, objMailSettings, objTrackingSettings, objHeaders, lstAttachments);
			}  
		}
    }
}