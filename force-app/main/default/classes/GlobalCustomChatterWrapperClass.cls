/*
 * Name			:	GlobalCustomChatterWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/28/2022
 * Description	:	Wrapper class for Global Custom Chatter controllr.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/28/2022		N/A				Initial version.			N/A
 */
public class GlobalCustomChatterWrapperClass {

	//Public variables.
	@AuraEnabled
	public Boolean boolIsVisible {get; set;}
	@AuraEnabled
	public Boolean boolFoundByTag {get; set;}
	@AuraEnabled
	public Boolean boolHasMoreThanOneReply {
		get {
			Boolean boolResult = false;
			if(lstReplies != null && lstReplies.size() > 1) {
				boolResult = true;

				//We hide the old replies.
				for(GlobalCustomChatterWrapperClass objReply : lstReplies) {
					objReply.boolIsVisible = false;
				}
				lstReplies.get(lstReplies.size() - 1).boolIsVisible = true;
			}
			return boolResult;
		}
	}
	@AuraEnabled
	public Boolean boolHasMoreThant3Attachments {
		get {
			Boolean boolResult = false;
			if(lstAttachments != null && lstAttachments.size() > 3) {
				boolResult = true;
			}
			return boolResult;
		}
	}
	@AuraEnabled
	public Integer intExtraAttachments {
		get {
			Integer intResult = 0;
			if(boolHasMoreThant3Attachments) {
				intResult = lstAttachments.size() - 2;
			}
			return intResult;
		}
	}
	@AuraEnabled
	public Id idRecord {get; set;}
	@AuraEnabled
	public Id idCommentRecord {get; set;}
	@AuraEnabled
	public Id idCreatedBy {get; set;}
	@AuraEnabled
	public String strBody {get; set;}
	@AuraEnabled
	public String strCreatedBy {get; set;}
	@AuraEnabled
	public String strCreatedByPhotoURL {get; set;}
	@AuraEnabled
	public String strCreatedDate {get; set;}
	@AuraEnabled
	public String strAttachmentIds {
		get {
			String strResult = '';
			List<Id> lstIds = new List<Id>();
			if(lstAttachments != null && !lstAttachments.isEmpty()) {
				for(AttachmentWrapperClass objAttachment : lstAttachments) {
					lstIds.add(objAttachment.idContentDocument);
				}
				strResult = String.join(lstIds, ',');
			}
			return strResult;
		}
	}
	@AuraEnabled
	public AttachmentWrapperClass objThirdAttachment {
		get {
			AttachmentWrapperClass objResult;
			if(boolHasMoreThant3Attachments) {
				objResult = lstAttachments.get(2);
			}
			return objResult;
		}
	}
	@AuraEnabled
	public List<GlobalCustomChatterWrapperClass> lstReplies {get; set;}
	@AuraEnabled
	public List<AttachmentWrapperClass> lstAttachments {get; set;}

	//Inner class for Attachments.
	public class AttachmentWrapperClass {

		//Public variables.
		@AuraEnabled
        public Id idContentVersion {get; set;}
		@AuraEnabled
        public Id idContentDocument {get; set;}
		@AuraEnabled
        public Id idContentBody {get; set;}
		@AuraEnabled
        public String strURL {
			get {
				String strResult = '';
				if(idContentVersion != null) {
					strResult = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + idContentVersion + '&operationContext=CHATTER&contentId=' + idContentBody;
				}
				return strResult;
			}
		}
    }
}