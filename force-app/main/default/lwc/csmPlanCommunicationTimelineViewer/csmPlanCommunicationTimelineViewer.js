/*
 * Name			:	CsmPlanCommunicationTimelineViewer
 * Author		:	Deva M
 * Created Date	: 	22/10/2021
 * Description	:	Csm Plan Communication Timeline Viewer Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M     			22/10/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement,api,wire, track } from 'lwc';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';

import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
//Apex Imports
import getRecords from '@salesforce/apex/CSMPlanCommunicationController.getRecords';
import getPermissionOnObject from '@salesforce/apex/CSMPlanCommunicationController.getPermissionOnObject';
//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Loading from '@salesforce/label/c.Loading';

//Import Static resources
import Case_Comments_Icons from '@salesforce/resourceUrl/Case_Comments_Icons';
import Icons from '@salesforce/resourceUrl/icons';
// Import message service features required for publishing and the message channel
//import { subscribe,unsubscribe, MessageContext } from 'lightning/messageService';
//import PLAN_COMMS from '@salesforce/messageChannel/csmPlanCommunication__c';

//import custom permissions
import hasCSMPermission from "@salesforce/customPermission/CSMUser";
import userId from '@salesforce/user/Id';

export default class CsmPlanCommunicationTimelineViewer  extends NavigationMixin(
    LightningElement
) {
    //Private Variables
    searchCommentHolder;
    isExpanded;
    selectedSortLabel;
    selectedSortValue;
    boolDisplaySpinner;        
    //Public variables
    @api recordId;
    @api commentType;
    @api commentSubType;
   // @wire(MessageContext)
   // messageContext;
    @track
    commentList=[];
    showButtons;
    timerInterval;
	objListener;
    subscription = null;
    //Labels.
    label = {
        Refresh_Button,
        Loading,
        Error,
        Success	
    }  

    get boolNoCommentsFound(){
        return (this.commentList && this.commentList.length > 0);
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
    }

    //Feature Configuration.
    objConfiguration = {
        strSearchPlaceholder: "Search Comment",
        listViewFilters : [
            {
                label: 'Latest Posts',
                value: 'LastModifiedDate DESC',
                isSelected: true
            }, 
            {
                label: 'Oldest Posts',
                value: 'LastModifiedDate ASC',
                isSelected: false
            }
        ]
    }
     /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
        objParent.boolShowComments =false;
        objParent.boolDisplaySpinner = false;    
        this.objConfiguration.listViewFilters.forEach(obj => {
            if(obj.isSelected == true){
                this.selectedSortLabel = obj.label;
                this.selectedSortValue = obj.value;
                this.sortBy = obj.value;
            } 
        });
        this.isExpanded=true;
        //this.subscribeToMessageChannel();
        this.showButtons=false;
        this.refreshCard();

		//We create a global listener, so we can update this component from external sources.
		objParent.objListener = function (objEvent) {

            //First we make sure the message is for us.
            if(objEvent.data && objEvent.data.strTargetRecordId === objParent.recordId && objEvent.data.strTargetComponent === "csmPlanCommunicationTimelineViewer") {
				objParent.refreshCard();
            }
        };
        window.addEventListener("message", objParent.objListener);
	}

    /*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
    disconnectedCallback() {

        //We remove the listener we opened.
        window.removeEventListener("message", this.objListener);
    }

    	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

    @api
    refreshCard(){   
        let objParent = this;
        objParent.loadRecords();
    }
    handleSearchComments(objEvent) {
        this.searchCommentHolder = objEvent.target.value;
        let objComp= this.template.querySelector('c-csm-plan-communication-timeline');
        if(objUtilities.isNotNull(objComp)){             
         //   objComp.searchRecord(objEvent); 
        }
        let strKeyword = objEvent.target.value;
		let objParent = this;       
        //If the keyword is not blank.
        if(objUtilities.isNotNull(strKeyword)){
            objParent.searchKeyValue = strKeyword.toLowerCase();
            objParent.loadRecords();
        }
    }
    @wire(getPermissionOnObject)
    createPermission({ error, data }) {
        if (data) {
            this.showButtons = data;
        } else if (error) {
        }
    }
    
    
    handleClick(objEvent){
        this.dispatchEvent(new CustomEvent("resetdata", { detail: true }));
        switch (objEvent.currentTarget.name) {
            case 'expandAll':
                this.isExpanded = true;
                this.template.querySelector('c-csm-plan-communication-timeline').expandAll();
                
            break;
            case 'collapseAll':
                this.isExpanded = false;
                this.template.querySelector('c-csm-plan-communication-timeline').collapseAll();
            break;
            case 'list-view-action':
                this.objConfiguration.listViewFilters.forEach(obj => {                    
                    if(obj.value == objEvent.detail.value){
                        obj.isSelected = true;
                        this.selectedSortLabel = obj.label;
                        this.selectedSortValue = obj.value;
                        this.sortBy = obj.value;
                    } else{
                        obj.isSelected=false;
                    }
                });
                this.loadRecords(); 
            break;
                default:
            break;
        }
    }

        /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding record.
	 Parameters	 : None
	 Return Type : None
	 */
     @api
     loadRecords(){
        let objParent = this;
		let objRequest = { strPlanId: objParent.recordId,
            strCommentType:(objUtilities.isBlank(objParent.commentType) || objParent.commentType=='All') ? '':objParent.commentType, 
			strCommentSubType:(objUtilities.isBlank(objParent.commentSubType) || objParent.commentSubType=='All') ? '' :objParent.commentSubType};
        objParent.boolDisplaySpinner=true;
        objParent.commentList= new Array(); 
        //get plan comment on success
        getRecords(objRequest)
        .then((result) => {  
            
            if(objUtilities.isNotNull(result) && result.length>0){          
                objParent.commentList = objParent.formatComments(result,objParent.searchKeyValue);
                objParent.setTimer();                
                objParent.dispatchEvent( new CustomEvent('loadcomments', {detail:{fullcommentlist:result}}));
            }
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;               
        });       
    }

    calculateTimeLeft(countDownDateString) {
		let strResult = "";
        var countDownDate = new Date(countDownDateString).getTime();
        var now = new Date().getTime();
        var distance = countDownDate - now;
		if(distance >= 0) {
			var days = Math.floor(distance / (1000 * 60 * 60 * 24));
			var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
			var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
			var seconds = Math.floor((distance % (1000 * 60)) / 1000);
			strResult = (days ? days + "d " : '') + (hours ? hours + "h " : '') + (minutes ? minutes + "m " : '') + (seconds ? seconds + "s " : '')
		}
        return strResult;
    }    
    setTimer() {
        let self = this;
        this.timerInterval = setInterval(function () {
            let isScheduled = false;
            self.commentList.forEach(wrapper => {
                wrapper.comments.forEach(comm => {
                    if (comm.isScheduled && new Date().getTime() < new Date(comm.Date_Time_Scheduled)) {
                        comm.countdown = self.calculateTimeLeft(comm.Date_Time_Scheduled);
                        isScheduled = true;
                    }
                    console.log()
                    if (comm.replies) {
                        comm.replies.forEach(repl => {
                            if (repl.comments[0].isScheduled && new Date().getTime() < new Date(repl.comments[0].Date_Time_Scheduled)) {
                                repl.comments[0].countdown = self.calculateTimeLeft(repl.comments[0].Date_Time_Scheduled);
                                isScheduled = true;
                            }
                        });
                    }
                });
            });

            if (!isScheduled) {
                clearInterval(self.timerInterval);
            }
        }, 1000);
    }
       // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
  /*     subscribeToMessageChannel() {       
        if(!this.subscription){
        this.subscription = subscribe(
            this.messageContext,
            PLAN_COMMS,
            ( message ) => {
                this.       ( message );
            });
        }     
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
    
      // Handler for message received by component
    handleMessage(message) {
        let objParent = this;
        objParent.recordId = objUtilities.isNotNull(message.recordId)?message.recordId:'';
        if(objParent.commentType !== message.commentType && objParent.commentSubType !== message.commentSubType){
			objParent.commentType = message.commentType;
			objParent.commentSubType = message.commentSubType;
			objParent.refreshCard();
        }
    }*/

    @api
	searchRecord(objEvent) {
        let strKeyword = objEvent.target.value;
		let objParent = this;       
        //If the keyword is not blank.
        if(objUtilities.isNotNull(strKeyword)){
            objParent.searchKeyValue = strKeyword.toLowerCase();
            objParent.loadRecords();
        }
    }
    formatComments(data,searchKey) {
		let boolFound
        let tmpCaseCommentList = [];

        if (objUtilities.isNotNull(data) && data.length>0) {
            let caseCommentMap = new Map();
            
            let latestInternalComment;
            if (this.sortBy == 'LastModifiedDate ASC') {
                Array.from(data).forEach(comment => {
                    if (comment && comment.Type == 'Internal' && !latestInternalComment) {
                        latestInternalComment = comment.Id;
                    }
                });
            }

            if (this.sortBy == 'LastModifiedDate DESC') {
                Array.from(data).slice().reverse()
                    .forEach(comment => {
                        if (comment && comment.Type == 'Internal' && !latestInternalComment) {
                            latestInternalComment = comment.Id;
                        }
                    });
            }


            Array.from(data).forEach(comment => {
                let tmpArr = [];

                var lastModifiedDate;
                if(comment){
                    if (comment.ContentDocumentLinks) {
                        comment.ContentDocumentLinks.forEach(att => {
                            this[NavigationMixin.GenerateUrl]({
                                type: 'standard__namedPage',
                                attributes: {
                                    pageName: 'filePreview'
                                },
                                state: {
                                    selectedRecordId: att.ContentDocumentId
                                }
                            }).then(url => {
                                tmpArr.push({
                                    type: 'icon',
                                    label: att.ContentDocument.Title + '.' + att.ContentDocument.FileExtension,
                                    name: att.ContentDocumentId,
                                    iconName: 'doctype:' + att.ContentDocument.FileExtension,
                                    alternativeText: att.ContentDocument.Title,
                                    href: url
                                });
                            });
    
                        });
                    }

                    lastModifiedDate = comment.LastModifiedDate;
                }

				//Now we create the tagged users, if any.
				let lstTaggedUsers = new Array();
				if(objUtilities.isNotNull(comment) && objUtilities.isNotNull(comment.objPlanComment)) {
					if(objUtilities.isNotNull(comment.objPlanComment.Tagged_User_1__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.objPlanComment.Tagged_User_1__r.Name,
							name: comment.objPlanComment.Tagged_User_1__r.Id,
							iconName: "standard:avatar",
							recordId: comment.objPlanComment.Id
						});
					}
					if(objUtilities.isNotNull(comment.objPlanComment.Tagged_User_2__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.objPlanComment.Tagged_User_2__r.Name,
							name: comment.objPlanComment.Tagged_User_2__r.Id,
							iconName: "standard:avatar",
							recordId: comment.objPlanComment.Id
						});
					}
					if(objUtilities.isNotNull(comment.objPlanComment.Tagged_User_3__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.objPlanComment.Tagged_User_3__r.Name,
							name: comment.objPlanComment.Tagged_User_3__r.Id,
							iconName: "standard:avatar",
							recordId: comment.objPlanComment.Id
						});
					}
					if(objUtilities.isNotNull(comment.objPlanComment.Tagged_User_4__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.objPlanComment.Tagged_User_4__r.Name,
							name: comment.objPlanComment.Tagged_User_4__r.Id,
							iconName: "standard:avatar",
							recordId: comment.objPlanComment.Id
						});
					}
					if(objUtilities.isNotNull(comment.objPlanComment.Tagged_User_5__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.objPlanComment.Tagged_User_5__r.Name,
							name: comment.objPlanComment.Tagged_User_5__r.Id,
							iconName: "standard:avatar",
							recordId: comment.objPlanComment.Id
						});
					}
				}

                let formattedDate = new Date(lastModifiedDate).toLocaleDateString("en-US", {
                    timeZone: TIMEZONE, year: 'numeric', month: 'short', day: 'numeric'
                });
                let formattedTime = new Date(lastModifiedDate).toLocaleTimeString("en-US", {
                    timeZone: TIMEZONE, hour: "2-digit", minute: "2-digit", hour12: "true"
                });

                if (!caseCommentMap.has(formattedDate)) {
                    caseCommentMap.set(formattedDate, []);
                }
               
                if(objUtilities.isNotNull(comment) && objUtilities.isNotNull(comment.CreatedBy)){
                    let iconName;
                    if(objUtilities.isNotNull(comment.Type) && 
                        (comment.Type == 'Internal' ||
                        comment.Type == 'Inbound')){
                        iconName = this.commentIcons.inbound;
                    }else if(objUtilities.isNotNull(comment.Type) && comment.Type == 'External'){
                        iconName = this.commentIcons.outbound;
                    }else{
                        iconName = this.commentIcons.collaboration;
                    }
                    let boolNotAutoPilotPlan= (objUtilities.isNotNull(comment.Plan) && !comment.Plan.CSM_isAutoPilot__c && hasCSMPermission);
                    let commentObj =  Object.assign({
                        date: formattedDate,
                        time: formattedTime,
                        datetime: formattedDate + ' ' + formattedTime,
                        uid: comment.Id,
                        isHighImportance: comment.Importance=='High',
                        isPrivate: comment.Type == 'Private',
                        isInternal: comment.Type == 'Internal',
                        isExternal: comment.Type == 'External' || comment.Type === 'Inbound',
                        isJira:comment.Type == 'JIRA',
                        isInbound: comment.Inbound,
                        iconName: iconName,
                        isScheduled: comment.Status == 'Scheduled',
                        isSubmitted: comment.Status == 'Submitted',
                        innternalCatgory:comment.Sub_Type,
						strSubject: comment.Subject,
						boolIsEmail: (objUtilities.isNotBlank(comment.Sub_Type) && comment.Sub_Type === "Email"),
						boolIsAttentionRequest: (comment.Type === 'Inbound' && comment.Sub_Type === "Attention Request"),
						boolDisplayReplyIcons: (objUtilities.isNotBlank(comment.Sub_Type) && comment.Sub_Type === "Email" && objUtilities.isNotNull(comment.Inbound) && comment.Inbound),
                        isEditable: boolNotAutoPilotPlan && !comment.Is_Automated && ((comment.Type == 'Internal' && comment.CreatedById == userId && latestInternalComment == comment.Id) ||  (comment.Status != 'Submitted') || (comment.Type == 'Private')) ,
                        isDeletable: boolNotAutoPilotPlan && ((comment.Status == 'Draft' || comment.Type == 'Private')) ,
                        isDeleted: false,
                        canReply: ((boolNotAutoPilotPlan) && ((comment.Type === 'Inbound' && (objUtilities.isNull(comment.Plan_Comments) || comment.Plan_Comments.length === 0)) || (comment.Type === 'Inbound' && comment.Sub_Type === "Attention Request") || (comment.Type === 'JIRA') || (comment.Type === 'Cassini' && comment.Sub_Type === "Auto Pilot"))),
                        showbutton:true,
                        titleClass: comment.Inbound ? "slds-page-header__name" : "slds-float_right slds-page-header__name",
                        isDraft: comment.Status == 'Draft',
                        attachments: tmpArr,
						taggedUsers: lstTaggedUsers,
                        countdown:this.calculateTimeLeft(comment.Date_Time_Scheduled),
                        replies: (objUtilities.isNotNull(comment.Plan_Comments) && comment.Plan_Comments.length >0) ? this.processChildComments(comment.lstChildComments) : null,
                        attachmentCount:  comment.ContentDocumentLinks ? comment.ContentDocumentLinks.length : 0,
                        hasAttachments:  comment.ContentDocumentLinks && comment.ContentDocumentLinks.length,
						hasTaggedUsers:  lstTaggedUsers && lstTaggedUsers.length,
                        showReplies: (objUtilities.isNotNull(comment.Plan_Comments) && comment.Plan_Comments.length >0),
                        createdDate:new Date(comment.CreatedDate).toLocaleDateString("en-US", {
                            timeZone: TIMEZONE, year: 'numeric', month: 'short', day: 'numeric'
                        }),
                        commentText: comment.Comment,
                        fullPhotoUrl: objUtilities.isNotBlank(comment.CreatedByName) ? "/profilephoto/005/T" : comment.CreatedBy.FullPhotoUrl,
						creatorName: objUtilities.isNotBlank(comment.CreatedByName) ? comment.CreatedByName : comment.CreatedBy.Name.toLowerCase()=='deployment master' ? 'Customer Success' : comment.CreatedBy.Name,
						objPlanComment: comment.objPlanComment,
                        hasMetrics:comment.PlanCommentEmailStats && comment.PlanCommentEmailStats.length,
						objAttentionRequest: {
							objCase: {
								Id: objUtilities.isNotNull(comment.objPlanComment) && objUtilities.isNotBlank(comment.objPlanComment.Case__c) ? comment.objPlanComment.Case__c : "",
								CaseNumber: objUtilities.isNotNull(comment.objPlanComment) && objUtilities.isNotBlank(comment.objPlanComment.Case__c) ? comment.objPlanComment.Case__r.CaseNumber : "",
								URL: objUtilities.isNotNull(comment.objPlanComment) && objUtilities.isNotBlank(comment.objPlanComment.Case__c) ? window.location.origin + "/" + comment.objPlanComment.Case__c : ""
							},
							strCustomerRiskReason: objUtilities.isNotNull(comment.objPlanComment) ? comment.objPlanComment.Customer_Risk_Reason__c : "",
						}
                    }, comment);
                    
                    if(objUtilities.isNotBlank(searchKey)){
                        

						//First we check if the Comment contains the keyword.
						if(objUtilities.isNotNull(commentObj.commentText) && commentObj.commentText.toLowerCase().includes(searchKey)) {
							caseCommentMap.get(formattedDate).push(commentObj);
						} else if(objUtilities.isNotNull(comment.ContentDocumentLinks) && comment.ContentDocumentLinks.length > 0) {
							boolFound = false;

							//Now we check if any of the attachments contains the keyword.
							comment.ContentDocumentLinks.forEach(objAttachment => {
								if(!boolFound && objUtilities.isNotNull(objAttachment.ContentDocument) && objUtilities.isNotBlank(objAttachment.ContentDocument.Title) && 
										(objAttachment.ContentDocument.Title + "." + objAttachment.ContentDocument.FileExtension).toLowerCase().includes(searchKey)) {
									caseCommentMap.get(formattedDate).push(commentObj);
									boolFound = true;
								}
							});
						}
                    }else if (objUtilities.isBlank(searchKey)){
                        caseCommentMap.get(formattedDate).push(commentObj);
                    }
                }
            });
            
            caseCommentMap.forEach((value, key) => {
                if(value.length > 0 ){
                    const cloned = (new Date()).getTime();
                    tmpCaseCommentList.push({
                        date: key,
                        time:cloned,
                        comments: value,
                        sortOrder: Date.parse(key)     
                    });
                }
            });
            tmpCaseCommentList.sort(this.getSortOrder("sortOrder"));
            tmpCaseCommentList = [...tmpCaseCommentList].map(commentsOnDate =>{
                commentsOnDate.comments = [...commentsOnDate.comments].sort(this.getSortOrder("sortTimeStamp")).reverse();
                return commentsOnDate;
            });
            if (this.sortBy == 'LastModifiedDate DESC') {
                tmpCaseCommentList.reverse();
            }
        }

        return tmpCaseCommentList;
    }



    getSortOrder(prop) {    
        return function(a, b) {    
            if (a[prop] > b[prop]) {    
                return 1;    
            } else if (a[prop] < b[prop]) {    
                return -1;    
            }    
            return 0;    
        }    
    }
    processChildComments(childData){
        if(objUtilities.isNotNull(childData)){
            childData.forEach((childComment, index, childData) => {
                let tempArr = this.formatComments([childComment]);
                if(tempArr && tempArr.length > 0){
                    childData[index] = tempArr[0];
                }
            });
            return childData;
        }
    }
    handleShowReply(event) {
        let objParent = this;
        objParent.commentList.forEach(objWrap => {
            objWrap.comments.forEach(objComment => {
                if (objComment.Id == event.detail) {
                    objComment.showReplies = true;
                }
            });
        });
    }

    handleHideReply(event) {
        let objParent = this;
        objParent.commentList.forEach(objWrap => {
            objWrap.comments.forEach(objComment => {
                if (objComment.Id == event.detail) {
                    objComment.showReplies = false;
                }
            });
        });
    }
}