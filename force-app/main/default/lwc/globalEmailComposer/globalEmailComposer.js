/*
 * Name			:	GlobalEmailComposer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/05/2021
 * Description	:	This LWC allows users to send emails.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/05/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getCurrentUserEmailAddress from "@salesforce/apex/GlobalEmailComposerController.getCurrentUserEmailAddress";
import getOrganizationWideEmails from "@salesforce/apex/GlobalEmailComposerController.getOrganizationWideEmails";
import getEmailTemplates from "@salesforce/apex/GlobalEmailComposerController.getEmailTemplates";
import getOriginalEmailDetails from "@salesforce/apex/GlobalEmailComposerController.getOriginalEmailDetails";
import sendEmail from "@salesforce/apex/GlobalEmailComposerController.sendEmail";

//Custom Labels.
import From from '@salesforce/label/c.From';
import To from '@salesforce/label/c.To';
import CC from '@salesforce/label/c.CC';
import BCC from '@salesforce/label/c.BCC';
import Subject from '@salesforce/label/c.Subject';
import Attachments from '@salesforce/label/c.Attachments';
import Cancel from '@salesforce/label/c.Cancel';
import Send from '@salesforce/label/c.Send';
import Sent from '@salesforce/label/c.Sent';
import Invalid_Email_Address from '@salesforce/label/c.Invalid_Email_Address';
import Populate_To_Field from '@salesforce/label/c.Populate_To_Field';
import Populate_From_Field from '@salesforce/label/c.Populate_From_Field';
import Populate_Body_Field from '@salesforce/label/c.Populate_Body_Field';
import Email_Sent_Successfully from '@salesforce/label/c.Email_Sent_Successfully';
import Invalid_Size from '@salesforce/label/c.Invalid_Size';
import Prefix_Reply from '@salesforce/label/c.Prefix_Reply';
import Prefix_Forward from '@salesforce/label/c.Prefix_Forward';

//Class body.
export default class GlobalEmailComposer extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api boolIsReply;
	@api boolIsReplyAll;
	@api boolIsForward;
	@api boolWaitForParent;
	@api boolDisplayCancelButton;
	@api boolOnlyDefaultAndCurrentUser = false;
	@api strRelatedRecordId;
	@api strParentRecordId;
	@api strNotifyComponentOnEmailSent;
	@api strTemplateFolderName;
	@api strPredefinedBody;
    @api boolDefaultFromCurrentUser;

	//Track variables.
	@track boolAttachmentIconActive = false;
	@track boolTemplateIconActive = false;
	@track strBody;
	@track lstAttachments = new Array();

	//Private variables.
	boolShowCancelButton = true;
	boolIsTemplateIconDisabled = true;
	boolDisplaySpinner;
	boolInitialLoad;
	boolDeactivateFromBlankValidation = true;
	strCurrentUserName;
	strCurrentUserEmailAddress;
	strFromAddress;
	strToAddresses;
	strCCAddresses;
	strBCCAddresses;
	strSubject;
	strRelatedToId;
	objEmailRegEx = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,5}|[0-9]{1,3})(\]?)(\s*;\s*|\s*$))*$/;
	lstToAddresses;
	lstEmailToAddresses;
	lstEmailCCAddresses;
	lstEmailBCCAddresses;
	lstEmailTemplates;
	lstEmailsToRemove = new Array();

	//Labels.
	label = {
		From,
		To,
		CC,
		BCC,
		Subject,
		Attachments,
		Cancel,
		Send,
		Sent,
		Invalid_Email_Address,
		Populate_To_Field,
		Populate_From_Field,
		Populate_Body_Field,
		Email_Sent_Successfully,
		Invalid_Size,
		Prefix_Reply,
		Prefix_Forward
	};

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let boolOnlyDefaultAndCurrentUser = false;
		let strEmailBody = "";
		let objParent = this;

		//First we set the default values.
		objParent.boolDisplaySpinner = true;
		objParent.strToAddresses = "";
		objParent.strCCAddresses = "";
		objParent.strBCCAddresses = "";
		objParent.strSubject = "";
		objParent.lstToAddresses = new Array();
		objParent.lstEmailTemplates = new Array();

		//We check if we need to hide the Cancel button.
		if(objUtilities.isNotNull(objParent.boolDisplayCancelButton) && objParent.boolDisplayCancelButton === "false") {
			objParent.boolShowCancelButton = false;
		}

		//Now we get the Email Templates, without blocking the UI cycle.
		setTimeout(function() {
			getEmailTemplates({
				strTemplateFolderName: objParent.strTemplateFolderName
			}).then(lstResults => {

				//If we received data.
				if(objUtilities.isNotNull(lstResults)) {
					lstResults.forEach(objEmailTemplate => {
						if(objUtilities.isNotBlank(objEmailTemplate.HtmlValue)) {
							objParent.lstEmailTemplates.push({
								label: objEmailTemplate.Name,
								value: objEmailTemplate.HtmlValue
							});
						}
					});

					//We enable the template icon, if there are templates available.
					if(objParent.lstEmailTemplates.length > 0) {
						objParent.boolIsTemplateIconDisabled = false;
					}
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}, 1);

		//Now we get the TO addresses.
		getCurrentUserEmailAddress().then(objResult => {
			objParent.strCurrentUserName = objResult.Name;
			objParent.strCurrentUserEmailAddress = objResult.Email;
			if(objUtilities.isNotNull(objParent.boolOnlyDefaultAndCurrentUser) && (objParent.boolOnlyDefaultAndCurrentUser === "true" || objParent.boolOnlyDefaultAndCurrentUser)) {
				boolOnlyDefaultAndCurrentUser = true;
			}
			return getOrganizationWideEmails({
				strRecordId: objParent.recordId,
				boolOnlyDefaultAndCurrentUser: boolOnlyDefaultAndCurrentUser
			});
		}).then(lstResults => {

			//Now we prepare the picklist values.
			if(objUtilities.isNotNull(lstResults)) {
				lstResults.forEach(objAddress => {

					//We save the picklist values.
					objParent.lstToAddresses.push({
						label: objAddress.DisplayName,
						value: objAddress.Id
					});

					//We save the initial value.
					if(objUtilities.isBlank(objParent.strFromAddress)) {			
                        
						//We also add the current user email address, as an option.
						objParent.lstToAddresses.push({
							label: objParent.strCurrentUserName,
							value: ""
						});
                        //Default From address to current user
                        if(objUtilities.isNotNull(objParent.boolDefaultFromCurrentUser) && (objParent.boolDefaultFromCurrentUser === "true" || objParent.boolDefaultFromCurrentUser)){
                            objParent.strFromAddress = "";
                        }else{
                            objParent.strFromAddress = objAddress.Id;
                        }
					}

					//We also save the emails to be removed from the To, CC and BCC fields.
					objParent.lstEmailsToRemove.push(objAddress.Address);
				});
			}
			return getOriginalEmailDetails({
				strRecordId: objParent.recordId
			});
		}).then(objResult => {

			//If we received data.
			if(objUtilities.isNotNull(objResult)) {

				//First we check the subject prefix we will use.
				if(objParent.boolIsReply || objParent.boolIsReplyAll) {
					objParent.strSubject = objParent.label.Prefix_Reply + " " + objResult.Subject;
				} else if(objParent.boolIsForward) {
					objParent.strSubject = objParent.label.Prefix_Forward + " " + objResult.Subject;
				} else {
					objParent.strSubject = objResult.Subject;
				}

				//Now we set the TO addresses, depending on the selection.
				if(objParent.boolIsReply) {
					objParent.strToAddresses = objResult.FromAddress;
				} else if(objParent.boolIsReplyAll) {
					objParent.strToAddresses = objResult.FromAddress;
					if(objUtilities.isNotBlank(objResult.ToAddress)) {
						if(objUtilities.isBlank(objParent.strToAddresses)) {
							objParent.strToAddresses = "";
						} else {
							objParent.strToAddresses = objParent.strToAddresses + "; ";
						}
						objParent.strToAddresses += objResult.ToAddress;
					}
					objParent.strCCAddresses = objResult.CcAddress;
					objParent.strBCCAddresses = objResult.BccAddress;
				}

				//Now we remove the unnecessary addresses.
				if(objParent.lstEmailsToRemove.length > 0) {
					objParent.lstEmailsToRemove.forEach(strAddress => {
						if(objUtilities.isNotBlank(strAddress)) {

							//Now we clean up the To address.
							if(objUtilities.isNotBlank(objParent.strToAddresses) && objParent.strToAddresses.includes(strAddress)) {
								objParent.strToAddresses = objParent.strToAddresses.replaceAll(strAddress + "; ", "").replaceAll(strAddress + ";", "").replaceAll(strAddress, "");
							}

							//Now we clean up the CC address.
							if(objUtilities.isNotBlank(objParent.strCCAddresses)) {

								//First we check the Organization Wide Addresses.
								if(objParent.strCCAddresses.includes(strAddress)) {
									objParent.strCCAddresses = objParent.strCCAddresses.replaceAll(strAddress + "; ", "").replaceAll(strAddress + ";", "").replaceAll(strAddress, "");
								}

								//We also remove the current user email address from CC.
								if(objParent.strCCAddresses.includes(objParent.strCurrentUserEmailAddress)) {
									objParent.strCCAddresses = objParent.strCCAddresses.replaceAll(objParent.strCurrentUserEmailAddress + "; ", "").replaceAll(
											objParent.strCurrentUserEmailAddress + ";", "").replaceAll(objParent.strCurrentUserEmailAddress, "");
								}
							}

							//Now we clean up the BCC address.
							if(objUtilities.isNotBlank(objParent.strBCCAddresses) && objParent.strBCCAddresses.includes(strAddress)) {
								objParent.strBCCAddresses = objParent.strBCCAddresses.replaceAll(strAddress + "; ", "").replaceAll(strAddress + ";", "").replaceAll(strAddress, "");
							}
						}
					});
				}

				//If we have a predefined body.
				if(objUtilities.isNotBlank(objParent.strPredefinedBody)) {
					objParent.strBody = objParent.strPredefinedBody;
				} else {

					//Now we create the header of the previous email.
					objParent.strBody = '<p>&nbsp;</p><table style="border-bottom-width: thin; border-bottom-style: solid; height: 2px; width: 100%;"><tr><th></th></tr></table><p>&nbsp;</p>' + 
							'<p><b>' + objParent.label.From + ':&nbsp;</b><a href="mailto:' + objResult.FromAddress.replaceAll(" ", "").replaceAll(";", "") + 
							'" rel="noopener noreferrer" target="_blank">' + objResult.FromAddress.replaceAll(" ", "").replaceAll(";", "") + '</a></p><p><b>' + objParent.label.Sent + 
							':</b>&nbsp;' + objResult.MessageDate + '</p><p><b>' + objParent.label.To + ':&nbsp;</b>';
					
					//Now we add the TO addresses.
					if(objUtilities.isNotBlank(objResult.ToAddress)) {
						objResult.ToAddress.replaceAll(" ", "").split(";").forEach(strAddress => {
							objParent.strBody += '<a href="mailto:' + strAddress + '" rel="noopener noreferrer" target="_blank">' + strAddress + '</a>;&nbsp;';
						});
					}
					
					//Now we add the CC addresses.
					objParent.strBody += '</p><p><b>' + objParent.label.CC + ':&nbsp;</b>';
					if(objUtilities.isNotBlank(objResult.CcAddress)) {
						objResult.CcAddress.replaceAll(" ", "").split(";").forEach(strAddress => {
							objParent.strBody += '<a href="mailto:' + strAddress + '" rel="noopener noreferrer" target="_blank">' + strAddress + '</a>;&nbsp;';
						});
					}
					
					//Now we add the rest of the header and body.
					if(objUtilities.isNotBlank(objResult.HtmlBody)) {
						strEmailBody = objResult.HtmlBody;
					} else if(objUtilities.isNotBlank(objResult.TextBody)) {
						strEmailBody = objResult.TextBody;
					}
					objParent.strBody += '</p><p><b>' + objParent.label.Subject + ':&nbsp;</b>' + objResult.Subject + '</p>' + strEmailBody;
				}

				//Now we save the Related To Id.
				objParent.strRelatedToId = objResult.RelatedToId;
			} else {
				objParent.strRelatedToId = objParent.recordId;
				
				//If we have a predefined body.
				if(objUtilities.isNotBlank(objParent.strPredefinedBody)) {
					objParent.strBody = objParent.strPredefinedBody;
				}
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strFullCustomCSS = "";
		let lstCustomCSS = new Array();

		//Now we set the custom CSS.
		if(!this.boolInitialLoad) {
			this.boolInitialLoad = true;

			//Modal adjustments.
			lstCustomCSS.push(".modal-container.slds-modal__container { width: 80% !important; max-width: inherit; }");
			lstCustomCSS.push(".cuf-content { margin-right: -30px; margin-left: -30px; }");
			lstCustomCSS.push(".modal-footer.slds-modal__footer { display: none; }");
			lstCustomCSS.push(".modal-body.scrollable.slds-modal__content.slds-p-around--medium { border-radius: 5px; }");
			lstCustomCSS.push(".baseDefault.forceChatterBasePublisher.forceChatterLightningComponent { margin-bottom: -60px; }");
			lstCustomCSS.push(".modal-header.slds-modal__header { display: none; }");
			lstCustomCSS.push(".hideLabel label { display: none; }");
			lstCustomCSS.push(".hideSpan > Span { display: none; }");
			lstCustomCSS.push(".hideSpan .slds-file-selector.slds-file-selector_files { width: 300px; }");
			lstCustomCSS.push(".hideSpan .slds-file-selector.slds-file-selector_files label { width: 290px; }");
			lstCustomCSS.push(".slds-rich-text-editor { min-height: 290px !important; }");
			
			//Now we apply the css.
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				lstCustomCSS.forEach(strCustomCSS => {
					strFullCustomCSS += " " + strCustomCSS + " ";
				});
				objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			});
		}
    }

	/*
	 Method Name : send
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	send() {
		let objParent = this;

		//We initialize the lists.
		objParent.lstEmailToAddresses = new Array();
		objParent.lstEmailCCAddresses = new Array();
		objParent.lstEmailBCCAddresses = new Array();

		//Now we fetch the values.
		objParent.strToAddresses = objParent.template.querySelector("lightning-input[data-id='To']").value;
		objParent.strCCAddresses = objParent.template.querySelector("lightning-input[data-id='CC']").value;
		objParent.strBCCAddresses = objParent.template.querySelector("lightning-input[data-id='BCC']").value;
		objParent.strSubject = objParent.template.querySelector("lightning-input[data-id='Subject']").value;

		//Now we validate the user has selected a FROM address.
		if(objUtilities.isNotBlank(objParent.strFromAddress) || objParent.boolDeactivateFromBlankValidation) {

			//Now we check the TO addresses.
			if(objUtilities.isNotBlank(objParent.strToAddresses)) {

				//Now we check the TO addresses.
				if(objParent.objEmailRegEx.test(objParent.strToAddresses)) {
					
					//Now we validate the CC and BCC addresses, if any.
					if(objUtilities.isNotBlank(objParent.strCCAddresses) && !objParent.objEmailRegEx.test(objParent.strCCAddresses)) {
						objUtilities.showToast("Error", objParent.label.CC + " " + objParent.label.Invalid_Email_Address, "error", this);
					} else if(objUtilities.isNotBlank(objParent.strBCCAddresses) && !objParent.objEmailRegEx.test(objParent.strBCCAddresses)) {
						objUtilities.showToast("Error", objParent.label.BCC + " " + objParent.label.Invalid_Email_Address, "error", this);
					} else {

						//Now we check the Body.
						if(objUtilities.isNotBlank(objParent.strBody)) {

							//Now we convert the strings into lists.
							objParent.strToAddresses.replaceAll(" ", "").split(";").forEach(strAddress => {
								if(objUtilities.isNotBlank(strAddress)) {
									objParent.lstEmailToAddresses.push(strAddress);
								}
							});
							if(objUtilities.isNotBlank(objParent.strCCAddresses)) {
								objParent.strCCAddresses.replaceAll(" ", "").split(";").forEach(strAddress => {
									if(objUtilities.isNotBlank(strAddress)) {
										objParent.lstEmailCCAddresses.push(strAddress);
									}
								});
							}
							if(objUtilities.isNotBlank(objParent.strBCCAddresses)) {
								objParent.strBCCAddresses.replaceAll(" ", "").split(";").forEach(strAddress => {
									if(objUtilities.isNotBlank(strAddress)) {
										objParent.lstEmailBCCAddresses.push(strAddress);
									}
								});
							}
	
							//The data is valid, so now we send the email.
							objParent.boolDisplaySpinner = true;
	
							//If we need to preexecute something on the parent, we send the notification to the parent, saying we are ready.
							if(objUtilities.isNotNull(objParent.boolWaitForParent) && (objParent.boolWaitForParent === "true" || objParent.boolWaitForParent)) {
								objParent.dispatchEvent(new CustomEvent("ready", {
									bubbles: true,
									composed: true,
									detail: {
										strBody: objParent.strBody,
										strSubject: objParent.strSubject,
										strRelatedRecordId: objParent.strRelatedRecordId,
										strParentRecordId: objParent.strParentRecordId
									}
								}));
							} else {
	
								//Otherwise, we just send the message.
								objParent.sendEmailMessage(objParent.strRelatedToId);
							}
						} else {
							objUtilities.showToast("Error", objParent.label.Populate_Body_Field, "error", objParent);
						}
					}
				} else {
					objUtilities.showToast("Error", objParent.label.To + " " + objParent.label.Invalid_Email_Address, "error", objParent);
				}
			} else {
				objUtilities.showToast("Error", objParent.label.Populate_To_Field, "error", objParent);
			}
		} else {
			objUtilities.showToast("Error", objParent.label.Populate_From_Field, "error", objParent);
		}
	}

	/*
	 Method Name : closeQuickAction
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeQuickAction() {
		let objParent = this;
		this.dispatchEvent(
			new CustomEvent("executeaction", {
				bubbles: true,
				composed: true
			})
		);
		window.postMessage({
			strTargetRecordId: objParent.strParentRecordId,
			strTargetComponent: objParent.strNotifyComponentOnEmailSent,
		}, window.location.href);
	}

	/*
	 Method Name : saveFromAddress
	 Description : This method saves the From value.
	 Parameters	 : Object, called from saveFromAddress, objEvent Event.
	 Return Type : None
	 */
	saveFromAddress(objEvent) {
		this.strFromAddress = objEvent.target.value;
	}

	/*
	 Method Name : switchState
	 Description : This method switches the icon states (Attachments and Templates).
	 Parameters	 : Object, called from switchState, objEvent Event.
	 Return Type : None
	 */
	switchState(objEvent) {
		if(objEvent.currentTarget.dataset.icon === "attachment") {
			this.boolAttachmentIconActive = !this.boolAttachmentIconActive;
		} else if(objEvent.currentTarget.dataset.icon === "template") {
			this.boolTemplateIconActive = !this.boolTemplateIconActive;
		}
    }

	/*
	 Method Name : applyEmailTemplate
	 Description : This method applies the selected email template to the email body.
	 Parameters	 : Object, called from applyEmailTemplate, objEvent Event.
	 Return Type : None
	 */
	applyEmailTemplate(objEvent) {
		this.strBody = objEvent.target.value;
	}

	/*
	 Method Name : processAttachments
	 Description : This method prepares the attachments to be sent as part of the email.
	 Parameters	 : Object, called from processAttachments, objEvent Event.
	 Return Type : None
	 */
    processAttachments(objEvent) {
		let intTotalSize = 0;
		let objFileContent;
		let objParent = this;

		//If we received at least one file.
        if(objEvent.target.files.length > 0) {

			//Now we calculate the current attachments sizes.
			objParent.lstAttachments.forEach(objSavedAttachment => {
				intTotalSize += objSavedAttachment.intSize;
			});

			//We extract one by one.
			Array.from(objEvent.target.files).forEach(objAttachment => {

				//Now we confirm the total size won't exceed the limit.
				intTotalSize += objAttachment.size;
				if(intTotalSize > 5242880) {
					objUtilities.showToast("Error", objParent.label.Invalid_Size, "error", this);
				} else {

					//If we are below the limit, we process the new attachment.
					let objReader = new FileReader();
					objReader.onload = function() {
						objFileContent = objReader.result;
						objFileContent = objFileContent.substring(objFileContent.indexOf('base64,') + 7);
						objParent.lstAttachments.push({
							strId: objAttachment.size + "" + (new Date()).getTime(),
							strName: objAttachment.name,
							strBody: objFileContent.substring(0, Math.min(objFileContent.length, 750000000)), 
							strContentType: objAttachment.type,
							intSize: objAttachment.size
						});
					};
					objReader.readAsDataURL(objAttachment);
				}
			});
        }
    }

	/*
	 Method Name : removeAttachment
	 Description : This method removes the selected attachment from the list.
	 Parameters	 : Object, called from removeAttachment, objEvent Event.
	 Return Type : None
	 */
	removeAttachment(objEvent) {
		for(let intIndex = 0; intIndex < this.lstAttachments.length; intIndex++) { 
			if(this.lstAttachments[intIndex].strId === objEvent.currentTarget.dataset.id) { 
				this.lstAttachments.splice(intIndex, 1); 
			}
		}
	}

	/*
	 Method Name : sendEmailMessage
	 Description : This method sends the email message, based on the collected data.
	 Parameters	 : String, called from sendEmailMessage, strRelatedToId Parent record that will be related to the email message record.
	 Return Type : None
	 */
	@api
	sendEmailMessage(strRelatedToId) {
		let objParent = this;
		sendEmail({
			strFromId: objParent.strFromAddress,
			strSubject: objParent.strSubject,
			strBody: objParent.strBody,
			strRelatedToId: strRelatedToId,
			lstToAddresses: objParent.lstEmailToAddresses,
			lstCCAddresses: objParent.lstEmailCCAddresses,
			lstBCCAddresses: objParent.lstEmailBCCAddresses,
			lstAttachments: objParent.lstAttachments
		}).then(() => {
			objUtilities.showToast("Success", objParent.label.Email_Sent_Successfully, "success", objParent);
			objParent.closeQuickAction();

			//Now, we post a global message to notify the email has been sent, if needed.
			if(objUtilities.isNotBlank(objParent.strNotifyComponentOnEmailSent)) {
				window.postMessage({
					strTargetRecordId: objParent.strParentRecordId,
					strTargetComponent: objParent.strNotifyComponentOnEmailSent,
				}, window.location.href);
				objParent.dispatchEvent(new CustomEvent("success", {
					bubbles: true,
					composed: true,
					detail: null
				}));
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : spinner
	 Description : This method shows/hides the spinner, from an external call.
	 Parameters	 : Boolean, called from spinner, boolDisplaySpinner If TRUE, the spinner will be displayed, otherwise it will be hidden.
	 Return Type : None
	 */
	@api
	spinner(boolDisplaySpinner) {
		this.boolDisplaySpinner = boolDisplaySpinner;
	}

	/*
	 Method Name : saveBody
	 Description : This method extracts the body from the rich text area and saves it on the corresponding value.
	 Parameters	 : Object, called from saveBody, objEvent Event.
	 Return Type : None
	 */
	@api
	saveBody(objEvent) {
		this.strBody = objEvent.target.value;
	}

	/*
	 Method Name : getBody
	 Description : This method returns the body of the rich text area.
	 Parameters	 : None
	 Return Type : String
	 */
	@api
	getBody() {
		return this.strBody;
	}
}