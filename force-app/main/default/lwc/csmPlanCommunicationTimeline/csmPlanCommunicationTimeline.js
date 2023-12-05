//Core imports
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Import Static resources
import Case_Comments_Icons from '@salesforce/resourceUrl/Case_Comments_Icons';
import Icons from '@salesforce/resourceUrl/icons';
import RedArrow from '@salesforce/resourceUrl/RedArrow';

//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Loading from '@salesforce/label/c.Loading';
import Email_Message_Tooltip from '@salesforce/label/c.Email_Message_Tooltip';
import CassiniDefaultReply from '@salesforce/label/c.CassiniDefaultReply';

//Apex Imports
import removedTaggedUser from '@salesforce/apex/CSMPlanCommunicationController.removedTaggedUser';

export default class CsmPlanCommunicationTimeline extends NavigationMixin(LightningElement) {
    //Public variables
    @api recordId;
    @api open;
    //@api sortBy;
    @api commentType;
    @api commentSubType;
    @api commentList;
    @api showbutton;
	@api boolDisplayPaginator;


    //Private variables.
    searchKeyValue;
	strAttentionRequestPrepopulation;

    showEditCommentModal;
    showDeleteCommentModal;
    showReplyCommentModal;
    @track
    commentRecordId;
    parentCommentRecordId;
    subscription=null;   
	@track 
    _commentList;
    //Labels.
    label = {   
        Loading,
        Error,
        Success,
		Email_Message_Tooltip
    }

    commentIcons = {
        inbound : Case_Comments_Icons + '/Inbound@2x.png',
        outbound : Case_Comments_Icons + '/Outbound@2x.png',
        attention : Case_Comments_Icons + '/attention@2x.png',
        meeting : Case_Comments_Icons + '/meeting@2x.png',
        collaboration : Case_Comments_Icons + '/Collaborations@2x.png',
        recommend : Case_Comments_Icons + '/recommend@2x.png',
        escalation : '/img/func_icons/util/escalation16.gif',
        draft: Icons + '/sketching-24.png',
        calendar: Icons + '/clock-32.png',
        submitted: Icons + '/verification-24.png',
        draft_16: Icons + '/sketching-16.png',
        calendar_16: Icons + '/clock-16.png',
        submitted_16: Icons + '/verification-16.png',
		RedArrow: RedArrow
    }

	openMetrics=false;
	@track metrics;

	//Private variables.
	boolInitialLoad = false;
	boolDisplayEmailModal;
	boolEmailIsReply;
	boolEmailIsReplyAll;
	strEmailRelatedRecordId;
	lstOriginalRecords;
	
     /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
		let lstOriginalRecords;
        this.showEditCommentForm = false;        
        this.showEditCommentModal = false;
        this.showDeleteCommentModal = false;
        this.showReplyCommentModal=false;
        this.lstOriginalRecords = new Array();    
		lstOriginalRecords = JSON.parse(JSON.stringify(this.commentList));
		if (typeof this.open === 'undefined') this.open = true;

		//Now we extract the comments from the groups, to send them to the paginator.
		if(objUtilities.isNotNull(lstOriginalRecords)) {
			lstOriginalRecords.forEach(objGroup => {
				if(objUtilities.isNotNull(objGroup.comments)) {
					objGroup.comments.forEach(objComment => {
						objComment.groupDate = objGroup.date;
						objComment.groupSortOrder = objGroup.sortOrder;
						objComment.groupTime = objGroup.time;
						objParent.lstOriginalRecords.push(objComment);
					});
				}
			});
		}

		//We display the paginator by default, if not provided.
		if(objUtilities.isNull(objParent.boolDisplayPaginator) || objUtilities.isBlank(objParent.boolDisplayPaginator)) {
			objParent.boolDisplayPaginator = true;
		} else if(objParent.boolDisplayPaginator.toLowerCase() === "true") {
			objParent.boolDisplayPaginator = true;
		} else if(objParent.boolDisplayPaginator.toLowerCase() === "false") {
			objParent.boolDisplayPaginator = false;
			objParent.changeTablePage({
				detail: objParent.lstOriginalRecords
			});
		}
	}

	/*
	 Method Name : changeTablePage
	 Description : This method changes the page on the Table.
	 Parameters	 : Object, called from sortBy, objEvent Change event.
	 Return Type : None
	 */
	changeTablePage(objEvent) { 
		let boolIsAdded;
		let objParent = this;
		let lstNewRecords = objEvent.detail;
		objParent._commentList = new Array();
		if(objUtilities.isNotNull(lstNewRecords)) {
			lstNewRecords.forEach(objComment => {
				boolIsAdded = false;
				objParent._commentList.forEach(objGroup => {
					if(objGroup.date === objComment.groupDate && objGroup.sortOrder === objComment.groupSortOrder && objGroup.time === objComment.groupTime) {
						objGroup.comments.push(objComment);
						boolIsAdded = true;
					}
				});
				if(!boolIsAdded) {
					objParent._commentList.push({
						date: objComment.groupDate,
						sortOrder: objComment.groupSortOrder,
						time: objComment.groupTime,
						comments: [
							objComment
						]
					});
				}
			});
		}
	}

    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }
    handleClose(objEvent){
        let objParent=this;
        objParent.showEditCommentModal = false;
        objParent.showDeleteCommentModal = false;
        objParent.showReplyCommentModal=false;
        objParent.commentRecordId=null;
        objParent.parentCommentRecordId=null;
        objParent.dispatchEvent(new CustomEvent('close'));
    }


    handleClick(objEvent) {        
        this.commentRecordId = objEvent.currentTarget.dataset.uuid;
        this.parentCommentRecordId = objEvent.currentTarget.dataset.id;
        switch (objEvent.currentTarget.dataset.name) {
            case 'control':
                const uid = objEvent.currentTarget.dataset.uuid;
                this.template.querySelector("[data-uid=\"" + uid + "\"]").classList.toggle('expanded');
                let iconEle = this.template.querySelector("[data-icon=\"" + uid + "\"]");
                iconEle.iconName = iconEle.iconName == 'utility:chevronright' ? 'utility:switch' : 'utility:chevronright';
                objEvent.preventDefault();
            break;
            case 'edit':
                this.showEditCommentModal=true;
                this.showDeleteCommentModal=false;
            break;
            case 'reply':                
                this.showReplyCommentModal = true;
				if(objEvent.currentTarget.dataset.type =='Cassini' && objEvent.currentTarget.dataset.subtype =='Auto Pilot'){
					this.strAttentionRequestPrepopulation =CassiniDefaultReply;
				}
            break;
            case 'delete':
                this.showEditCommentModal=false;
                this.showDeleteCommentModal=true;
            break;
            case 'showReply':
                objEvent.stopPropagation()
                this.dispatchEvent(new CustomEvent("showreply", {
                    detail: objEvent.target.dataset.id
                }));
            break;
            case 'hideReply':
                objEvent.stopPropagation()
                this.dispatchEvent(new CustomEvent("hidereply", {
                    detail: objEvent.target.dataset.id
                }));
            break;
        }        
    }
    @api
    expandAll() {
        this.template.querySelectorAll("[data-name='parent']").forEach(el => {
            el.classList.add('expanded');
            this.template.querySelector("[data-icon=\"" + el.dataset.uid + "\"]").iconName = 'utility:switch';
        });
    }

    @api
    collapseAll() {
        this.template.querySelectorAll("[data-name='parent']").forEach(el => {
            el.classList.remove('expanded');
            this.template.querySelector("[data-icon=\"" + el.dataset.uid + "\"]").iconName = 'utility:chevronright';
        });
    }

	/*
	 Method Name : replyEmail
	 Description : This method opens the Email component to reply to the current Plan Comment.
	 Parameters	 : Object, called from replyEmail, objEvent Click event.
	 Return Type : None
	 */
	replyEmail(objEvent) {
		let objParent = this;

		//We set the general data.
		objParent.boolDisplayEmailModal = true;
		objParent.boolEmailIsReply = false;
		objParent.boolEmailIsReplyAll = false;
		objParent.strEmailRelatedRecordId = objEvent.currentTarget.dataset.id;

		//Now we decide which type of action the user wants to run.
		switch(objEvent.currentTarget.dataset.action) {
			case "1":
				objParent.boolEmailIsReply = true;
			break;
			case "2":
				objParent.boolEmailIsReplyAll = true;
			break;
		}
    }

	/*
	 Method Name : hideEmailModal
	 Description : This method hides the Email modal.
	 Parameters	 : None
	 Return Type : None
	 */
	hideEmailModal() {
		this.boolDisplayEmailModal = false;
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objCSSDiv;
		let objParent = this;

		//Now we set the custom CSS.
		if(!objParent.boolInitialLoad) {
			objParent.boolInitialLoad = true;

			//Now we include the CSS.
			objCSSDiv = objParent.template.querySelector('.customGeneralCSS');
			if(objUtilities.isNotNull(objCSSDiv)) {
				objCSSDiv.innerHTML = "<style> " + 
						".csmPlanCommunicationTimeline-attachments[data-id=" + objParent.recordId + "] lightning-primitive-icon.slds-pill__remove {" + 
						"	display: none !important;" + 
						"} </style>";
			}
		}
	}

	/*
	 Method Name : removeTaggedUser
	 Description : This method removes a tagged user.
	 Parameters	 : Object, called from removeTaggedUser, objEvent Event.
	 Return Type : None
	 */
	removeTaggedUser(objEvent) {
		let objParent = this;
		let lstTaggedUsers = new Array();

		//We remove the record from the backend.
		if(objUtilities.isNotBlank(objEvent.detail.item.recordId) && objUtilities.isNotBlank(objEvent.detail.item.name)) {
			removedTaggedUser({
				strPlanCommentId: objEvent.detail.item.recordId,
				strUserId: objEvent.detail.item.name
			}).then(objResult => { 
				objParent._commentList.forEach(notif => {
					notif.comments.forEach(comment => {
						if(comment.objPlanComment.Id === objEvent.detail.item.recordId) {
							
							//We extract the new users.
							if(objUtilities.isNotNull(objResult.Tagged_User_1__r)) {
								lstTaggedUsers.push({
									type: 'icon',
									label: objResult.Tagged_User_1__r.Name,
									name: objResult.Tagged_User_1__r.Id,
									iconName: "standard:avatar",
									recordId: objResult.Id
								});
							}
							if(objUtilities.isNotNull(objResult.Tagged_User_2__r)) {
								lstTaggedUsers.push({
									type: 'icon',
									label: objResult.Tagged_User_2__r.Name,
									name: objResult.Tagged_User_2__r.Id,
									iconName: "standard:avatar",
									recordId: objResult.Id
								});
							}
							if(objUtilities.isNotNull(objResult.Tagged_User_3__r)) {
								lstTaggedUsers.push({
									type: 'icon',
									label: objResult.Tagged_User_3__r.Name,
									name: objResult.Tagged_User_3__r.Id,
									iconName: "standard:avatar",
									recordId: objResult.Id
								});
							}
							if(objUtilities.isNotNull(objResult.Tagged_User_4__r)) {
								lstTaggedUsers.push({
									type: 'icon',
									label: objResult.Tagged_User_4__r.Name,
									name: objResult.Tagged_User_4__r.Id,
									iconName: "standard:avatar",
									recordId: objResult.Id
								});
							}
							if(objUtilities.isNotNull(objResult.Tagged_User_5__r)) {
								lstTaggedUsers.push({
									type: 'icon',
									label: objResult.Tagged_User_5__r.Name,
									name: objResult.Tagged_User_5__r.Id,
									iconName: "standard:avatar",
									recordId: objResult.Id
								});
							}
	
							//Now we set the new values.
							comment.hasTaggedUsers = lstTaggedUsers && lstTaggedUsers.length;
							comment.taggedUsers = lstTaggedUsers;
						}
					});
				});
			}).catch(objError => {
				objUtilities.processException(objError, objParent);
			});
		}
    }

	/*
	 Method Name : openRecord
	 Description : This method opens a record.
	 Parameters	 : Object, called from openRecord, objEvent Event.
	 Return Type : None
	 */
	openRecord(objEvent) {
		this[NavigationMixin.Navigate]({
			type:'standard__recordPage',
			attributes:{
				"recordId": objEvent.currentTarget.dataset.recordId,
				"actionName": "view"
			}
		});
	}
	
	/*
	 Method Name : openmetrics
	 Description : This method opens Plan comment stat record.
	 Parameters	 : Object, called from openmetrics, objEvent Event.
	 Return Type : None
	 JIRA: AR-2770
	 */
	openmetrics(objEvent){
		this.openMetrics=true;
		this._commentList.forEach(notif => {			
			notif.comments.forEach(comment => {
				if(comment.Id === objEvent.target.dataset.id) {
					this.metrics = comment.PlanCommentEmailStats;
				}
			});
		});
		
	}

	closeMetrics(objEvent){
		this.openMetrics=false;
	}
}