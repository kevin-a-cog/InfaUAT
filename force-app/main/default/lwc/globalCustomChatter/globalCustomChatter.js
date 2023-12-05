/*
 * Name			:	GlobalCustomChatter
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/28/2022
 * Description	:	This component displays combined chatter feeds based on the given record ids.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/28/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getFeeds from "@salesforce/apex/GlobalCustomChatterController.getFeeds";

//Custom Labels.
import No_Records_Found from '@salesforce/label/c.No_Records_Found';
import Global_Chatter from '@salesforce/label/c.Global_Chatter';
import More_Comments from '@salesforce/label/c.More_Comments';
import Show_Tagged_Posts from '@salesforce/label/c.Show_Tagged_Posts';

//Class body.
export default class GlobalCustomChatter extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api boolIncludeTaggedRecords;
	@api strQueryPaths;
	@api strChildQueries;
	@api strNoRecordsFoundMessage;

	//Track variables.
	@track boolTaggedRecordsToggle = true;
	@track lstFeedItems;

	//Private variables.
	boolRenderSpinner;
	boolHasRecords;
	boolLoadingBodies;
	strNoRecordsFoundMessageLocal;

	//Labels.
	label = {
		Global_Chatter,
		More_Comments,
		Show_Tagged_Posts
	};

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {

		//If we received a custom "No records found" message, we load it.
		if(objUtilities.isNotBlank(this.strNoRecordsFoundMessage)) {
			this.strNoRecordsFoundMessageLocal = this.strNoRecordsFoundMessage;
		} else {
			this.strNoRecordsFoundMessageLocal = No_Records_Found;
		}

		//Now we load the records.
		this.loadRecords();
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objParent = this;

		//Now we set the custom CSS.
		if(objParent.boolLoadingBodies) {
			objParent.template.querySelectorAll(".bodyContainer").forEach(objBody => {
				objParent.lstFeedItems.forEach(objFeedItem => {
					if(objFeedItem.idRecord === objBody.getAttribute("data-id")) {

						//We add the body.
						objBody.innerHTML = objFeedItem.strBody;

						//Now we check if we have any tagged content to update.
						objBody.querySelectorAll("a.link").forEach(objLink => {
							objLink.onclick = (objEvent) => {
								objParent.openRecord(objEvent);
							};
						});
					} else if(objUtilities.isNotNull(objFeedItem.lstReplies) && objFeedItem.lstReplies.length > 0) {
						objFeedItem.lstReplies.forEach(objReply => {
							if(objReply.idRecord === objBody.getAttribute("data-id")) {

								//We add the body.
								objBody.innerHTML = objReply.strBody;
		
								//Now we check if we have any tagged content to update.
								objBody.querySelectorAll("a.link").forEach(objLink => {
									objLink.onclick = (objEvent) => {
										objParent.openRecord(objEvent);
									};
								});
							}
						});
					}
				});
			});
			objParent.boolLoadingBodies = false;
		}
	}

	/*
	 Method Name : loadRecords
	 Description : This method loads the feed items.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let boolIncludeTaggedRecords = true;
		let objParent = this;
		let lstQueryPaths = new Array();
		let lstChildQueries = new Array();

		//We set the default values.
		objParent.boolHasRecords = false;
		objParent.boolRenderSpinner = true;
		objParent.boolTaggedRecordsToggle = true;
		objParent.lstFeedItems = new Array();

		//If we have query paths to include.
		if(objUtilities.isNotBlank(objParent.strQueryPaths)) {
			lstQueryPaths = objParent.strQueryPaths.split(",");
		}

		//If we have child queries to include.
		if(objUtilities.isNotBlank(objParent.strChildQueries)) {
			lstChildQueries = JSON.parse(objParent.strChildQueries);
		}

		//We convert the tagged boolean.
		if(objUtilities.isNull(objParent.boolIncludeTaggedRecords) || (typeof objParent.boolIncludeTaggedRecords === "boolean" && !objParent.boolIncludeTaggedRecords) || 
				(typeof objParent.boolIncludeTaggedRecords === "string" && objParent.boolIncludeTaggedRecords.toLowerCase() !== "true")) {
			boolIncludeTaggedRecords = false;
		}

		//We load the Feed Items.
		getFeeds({
			boolIncludeTaggedRecords: boolIncludeTaggedRecords,
			strRecordId: objParent.recordId,
			lstQueryPaths: lstQueryPaths,
			lstChildQueries: lstChildQueries
		}).then((lstResults) => {
			objParent.lstFeedItems = lstResults;
			if(objUtilities.isNotNull(objParent.lstFeedItems) && objParent.lstFeedItems.length > 0) {
				objParent.boolHasRecords = true;
				objParent.boolLoadingBodies = true;

				//Now we limit the number of attachments.
				objParent.lstFeedItems.forEach(objFeedItem => {
					if(objUtilities.isNotNull(objFeedItem.lstAttachments) && objFeedItem.lstAttachments.length > 3) {
						objFeedItem.lstAttachments = objFeedItem.lstAttachments.slice(0,2);
					}
				});
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolRenderSpinner = false;
		});
	}

	/*
	 Method Name : openRecord
	 Description : This method opens the given record.
	 Parameters	 : Object, called from openRecord, objEvent Event.
	 Return Type : None
	 */
	openRecord(objEvent) {
		if(objUtilities.isNotBlank(objEvent.currentTarget.getAttribute("data-url"))) {
			window.open(objEvent.currentTarget.getAttribute("data-url"), "_blank");
		} else {
			this[NavigationMixin.Navigate]({
				type:'standard__recordPage',
				attributes:{
					"recordId": objEvent.currentTarget.getAttribute("data-id"),
					"actionName": "view"
				}
			});
		}
	}

	/*
	 Method Name : navigateToFiles
	 Description : This method opens the File Preview.
	 Parameters	 : Object, called from navigateToFiles, objEvent Event.
	 Return Type : None
	 */
	navigateToFiles(objEvent) {
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
				pageName: 'filePreview'
			},
			state : {
				recordIds: objEvent.target.getAttribute("data-ids"),
				selectedRecordId: objEvent.target.getAttribute("data-id")
			}
		});
	}

	/*
	 Method Name : displayAllComments
	 Description : This method displays all the replies of a Feed Item.
	 Parameters	 : Object, called from displayAllComments, objEvent Event.
	 Return Type : None
	 */
	displayAllComments(objEvent) {
		let objParent = this;
		objParent.lstFeedItems.forEach(objFeedItem => {
			if(objFeedItem.idRecord === objEvent.target.getAttribute("data-id")) {
				objFeedItem.boolHasMoreThanOneReply = false;
				objFeedItem.lstReplies.forEach(objReply => {
					objReply.boolIsVisible = true;
				});
			}
		});
	}

	/*
	 Method Name : toggleTaggedRecords
	 Description : This method shows / hides tagged records.
	 Parameters	 : None
	 Return Type : None
	 */
	toggleTaggedRecords() {
		let objParent = this;
		objParent.boolLoadingBodies = true;
		objParent.boolTaggedRecordsToggle = !objParent.boolTaggedRecordsToggle;
		objParent.lstFeedItems.forEach(objFeedItem => {
			if(objFeedItem.boolFoundByTag) {
				objFeedItem.boolIsVisible = objParent.boolTaggedRecordsToggle;
			}
		});
	}
}