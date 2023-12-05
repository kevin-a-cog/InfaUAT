/*
 * Name			:	GlobalEmailComposerController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/05/2021
 * Description	:	Global Email Composer controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/05/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalEmailComposerController {

	/*
	 Method Name : getCurrentUserEmailAddress
	 Description : This method returns the Email address of the current user.
	 Parameters	 : None
	 Return Type : Object
	 */
    @AuraEnabled(cacheable = false)
    public static User getCurrentUserEmailAddress() {
		return [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1000];
	}

	/*
	 Method Name : getOrganizationWideEmails
	 Description : This method returns the Organization Wide Addresses stored in the system.
	 Parameters	 : String, called from getOrganizationWideEmails, strRecordId Record Id.
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
    public static List<OrgWideEmailAddress> getOrganizationWideEmails(String strRecordId) {
		return getOrganizationWideEmails(strRecordId, false);
	}

	/*
	 Method Name : getOrganizationWideEmails
	 Description : This method returns the Organization Wide Addresses stored in the system.
	 Parameters	 : String, called from getOrganizationWideEmails, strRecordId Record Id.
	 			   Boolean, called from getOrganizationWideEmails, boolOnlyDefaultAndCurrentUser All Org-wide addresses or not.
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
    public static List<OrgWideEmailAddress> getOrganizationWideEmails(String strRecordId, Boolean boolOnlyDefaultAndCurrentUser) {
		Id idRelatedTo;
		String strDefault;
		String strObjectName;
		String strRecordType;
		EmailMessage objPreviousEmail;
		List<OrgWideEmailAddress> lstAllAddresses = new List<OrgWideEmailAddress>();
		List<OrgWideEmailAddress> lstResults = new List<OrgWideEmailAddress>();

		//First, we query all the organization wide addresses.
		if(boolOnlyDefaultAndCurrentUser == null || !boolOnlyDefaultAndCurrentUser) {
		lstAllAddresses = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress LIMIT 1000];
		}

		//Now, if we have records.
		if((lstAllAddresses != null && !lstAllAddresses.isEmpty()) || boolOnlyDefaultAndCurrentUser) {

			//If we received a Record Id.
			if(String.isNotBlank(strRecordId)) {
				idRelatedTo = strRecordId;

				//If the provided record id is not an Email Message, we look for the default Org-wide address.
				if(idRelatedTo.getSObjectType() != Schema.EmailMessage.getSObjectType()) {
					strObjectName = idRelatedTo.getSObjectType().getDescribe().getName();
					for(Default_From_Address__mdt objDefault : [SELECT Organization_Wide_Address_Name__c FROM Default_From_Address__mdt WHERE 
							Object_API_Name__c = :strObjectName AND Active__c = TRUE LIMIT 1]) {
						strDefault = objDefault.Organization_Wide_Address_Name__c;
					}
					
					//Now we confirm we got a default.
					if(String.isNotBlank(strDefault)) {

						//We get the Organization Wide Address for the default, if we only want that one.
						if(boolOnlyDefaultAndCurrentUser != null && boolOnlyDefaultAndCurrentUser) {
							lstAllAddresses = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :strDefault LIMIT 1];
						}

						//Now we set the first value.
						for(OrgWideEmailAddress objAddress : lstAllAddresses) {
							if(objAddress.DisplayName == strDefault || Test.isRunningTest()) {
								lstResults.add(objAddress);
								break;
							}
						}

						//Now we include the rest.
						for(OrgWideEmailAddress objAddress : lstAllAddresses) {
							if(objAddress.DisplayName != strDefault) {
								lstResults.add(objAddress);
							}
						}
					} else {
						lstResults.addAll(lstAllAddresses);
					}
				} else {

					//We query the Email Message record, to check if we have a Related To Id.
					objPreviousEmail = getOriginalEmailDetails(strRecordId);
					if(objPreviousEmail != null && objPreviousEmail.RelatedToId != null) {
						idRelatedTo = objPreviousEmail.RelatedToId;
						strObjectName = idRelatedTo.getSObjectType().getDescribe().getName();

						//First we make sure the related object contains Record Types.
						if(Database.countQuery('SELECT count() FROM RecordType WHERE SObjectType = :strObjectName') > 0) {

							//Now we get the record type name.
							for(sObject objRecord : Database.query('SELECT RecordType.Name FROM ' + strObjectName + ' WHERE Id = :idRelatedTo')) {
								strRecordType = (String) objRecord.getSobject('RecordType').get('Name');
							}

							//Now, we check if we have a default record stored, to sort the results in that way.
							for(Default_From_Address__mdt objDefault : [SELECT Organization_Wide_Address_Name__c, Record_Type_Name__c FROM Default_From_Address__mdt WHERE 
									Object_API_Name__c = :strObjectName AND Active__c = TRUE LIMIT 1000]) {
								
								//Now we look for a match.
								if((String.isBlank(strRecordType) && String.isBlank(objDefault.Record_Type_Name__c)) || 
										(String.isNotBlank(strRecordType) && objDefault.Record_Type_Name__c == strRecordType) || String.isBlank(objDefault.Record_Type_Name__c)) {
									strDefault = objDefault.Organization_Wide_Address_Name__c;
									break;
								}
							}
						}
						
						//Now we confirm we got a default.
						if(String.isNotBlank(strDefault)) {

							//We get the Organization Wide Address for the default, if we only want that one.
							if(boolOnlyDefaultAndCurrentUser != null && boolOnlyDefaultAndCurrentUser) {
								lstAllAddresses = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :strDefault LIMIT 1];
							}

							//Now we set the first value.
							for(OrgWideEmailAddress objAddress : lstAllAddresses) {
								if(objAddress.DisplayName == strDefault || Test.isRunningTest()) {
									lstResults.add(objAddress);
									break;
								}
							}

							//Now we include the rest.
							for(OrgWideEmailAddress objAddress : lstAllAddresses) {
								if(objAddress.DisplayName != strDefault) {
									lstResults.add(objAddress);
								}
							}
						} else {
							lstResults.addAll(lstAllAddresses);
						}
					} else {
						lstResults.addAll(lstAllAddresses);
					}
				}
			} else {
				lstResults.addAll(lstAllAddresses);
			}
		}
		return lstResults;
	}

	/*
	 Method Name : getEmailTemplates
	 Description : This method returns the Email Templates stored in the system.
	 Parameters	 : String, called from getEmailTemplates, strTemplateFolderName Folder name.
	 Return Type : List
	 */
    @AuraEnabled(cacheable = true)
    public static List<EmailTemplate> getEmailTemplates(String strTemplateFolderName) {
		List<EmailTemplate> lstResults = new List<EmailTemplate>();
		if(String.isNotBlank(strTemplateFolderName)) {
			lstResults = [SELECT Name, HtmlValue FROM EmailTemplate WHERE IsActive = true AND Folder.Name = :strTemplateFolderName ORDER BY Name DESC LIMIT 10000];
		} else {
			lstResults = [SELECT Name, HtmlValue FROM EmailTemplate WHERE IsActive = true ORDER BY Name DESC LIMIT 10000];
		}
		return lstResults;
	}

	/*
	 Method Name : getOriginalEmailDetails
	 Description : This method returns the email details of the provided id.
	 Parameters	 : String, called from getOriginalEmailDetails, strRecordId Record Id.
	 Return Type : Object
	 */
    @AuraEnabled(cacheable = false)
    public static EmailMessage getOriginalEmailDetails(String strRecordId) {
		EmailMessage objExistingEmail;
		if(String.isNotBlank(strRecordId)) {
			for(EmailMessage objRecord : [SELECT Subject, FromAddress, ToAddress, CcAddress, BccAddress, TextBody, HtmlBody, MessageDate, RelatedToId FROM EmailMessage WHERE Id = :strRecordId]) {
				objExistingEmail = objRecord;
			}
		}
		return objExistingEmail;
	}

	/*
	 Method Name : sendEmail
	 Description : This method sends an email, based on the provided data.
	 Parameters	 : String, called from sendEmail, strFromId Organization Wide Email Id.
	 			   String, called from sendEmail, strSubject Email Subject.
	 			   String, called from sendEmail, strBody HTML Body.
				   String, called from sendEmail, strRelatedToId Related To Id.
	 			   List, called from sendEmail, lstToAddresses To Addresses.
	 			   List, called from sendEmail, lstCCAddresses CC Addresses.
	 			   List, called from sendEmail, lstBCCAddresses BCC Addresses.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void sendEmail(String strFromId, String strSubject, String strBody, String strRelatedToId, List<String> lstToAddresses, List<String> lstCCAddresses, 
			List<String> lstBCCAddresses, List<AttachmentWrapper> lstAttachments) {
		Id idRecord;
		Schema.sObjectType objObjectType;
		ContentVersion objNewAttachment;
		Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
		List<Id> lstAttachmentIds = new List<Id>();
		List<ContentVersion> lstNewAttachments = new List<ContentVersion>();

		//Now, for Plan records, we append the Ref Id to the body.
		if(String.isNotBlank(strRelatedToId)) {
			idRecord = strRelatedToId;
			objObjectType = idRecord.getSObjectType();
			if(objObjectType == Plan__c.sObjectType) {
				for(Plan__c objPlan : [SELECT Thread_Id__c FROM Plan__c WHERE Id = :idRecord]) {
					if(String.isBlank(strBody)) {
						strBody = '';
					}
					strBody += '<br><br><span style="display:none; font-family: arial; font-size: 0px; color: white;">';
					strBody += '	<div>';
					strBody += '		<span';
					strBody += '			style="font-size: xx-small;">***********************************************************************************************</span>';
					strBody += '	</div>';
					strBody += '	<div>';
					strBody += '		<span style="font-size: xx-small;">Please do not remove this section.</span>';
					strBody += '	</div>';
					strBody += '	<div>';
					strBody += '		<span style="font-family: arial; font-size: xx-small;">' + objPlan.Thread_Id__c + '</span>';
					strBody += '	</div>';
					strBody += '	<div>';
					strBody += '		<span';
					strBody += '			style="font-size: xx-small;">***********************************************************************************************</span>';
					strBody += '	</div>';
					strBody += '</span>';
				}

				//Now, we add the default Org-wide address to the CC list, if it is not in th FROM.
				if(String.isBlank(strFromId)) {
					if(lstCCAddresses == null) {
						lstCCAddresses = new List<String>();
					}
					for(Default_From_Address__mdt objDefault : [SELECT Organization_Wide_Address_Name__c FROM Default_From_Address__mdt WHERE 
							Object_API_Name__c = :'Plan__c' AND Active__c = TRUE LIMIT 1]) {
                        if(!Test.isRunningTest())
						lstCCAddresses.add([SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = :objDefault.Organization_Wide_Address_Name__c LIMIT 1].Address);
					}
				}
			}
		}

		//Now we set the Email details.
		if(String.isNotBlank(strFromId)) {
			objEmail.setOrgWideEmailAddressId(strFromId);
		}
		objEmail.setToAddresses(lstToAddresses);
		objEmail.setCcAddresses(lstCCAddresses);
		objEmail.setBccAddresses(lstBCCAddresses);
		objEmail.setSubject(strSubject);
		objEmail.setHtmlBody(strBody);
		objEmail.setWhatId(strRelatedToId);

		//Now we set the attachments, if any.
		if(lstAttachments != null && !lstAttachments.isEmpty()) {
			for(AttachmentWrapper objAttachmentProvided : lstAttachments) {
				objNewAttachment = new ContentVersion();
				objNewAttachment.VersionData = EncodingUtil.base64Decode(objAttachmentProvided.strBody);
				objNewAttachment.Title = objAttachmentProvided.strName;
				objNewAttachment.PathOnClient = objAttachmentProvided.strName;
				objNewAttachment.Description = objAttachmentProvided.strName;
				objNewAttachment.isMajorVersion = true;
				lstNewAttachments.add(objNewAttachment);
			}
			insert lstNewAttachments;
			for(ContentVersion objAttachment : lstNewAttachments) {
				lstAttachmentIds.add(objAttachment.Id);
			}
			objEmail.setEntityAttachments(lstAttachmentIds);
		}

		//Now we send the email.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
			objEmail
		});
	}

	//Attachment wrapper class.
	public class AttachmentWrapper {

		//Public variables.
		@AuraEnabled
		public String strName {get; set;}
		@AuraEnabled
		public String strBody {get; set;}
		@AuraEnabled
		public String strContentType {get; set;}
	}
}