/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Amarender              29-Nov-2021     I2RT-4415           Case Communication (Case Comments/Chatter)                T01            
 balajip                05-Apr-2022     I2RT-5459           Added feature to tag users in a Case Comment              T02
 Vignesh Divakaran      10-May-2022     I2RT-6196           Change from CDC to Platform Event subscription            T03
 Vignesh Divakaran      10-May-2022     I2RT-6196           Add getRecord wire method to refresh the comments when    T04
                                                            getRecordNotifyChange is issued  
Karthi G                27-May-2022     I2RT-6196           Added code to handle platform event subscription          T05
 Vignesh Divakaran      07-Nov-2022     I2RT-7445           Removed case comment platform event subscription          T06
                                                            & unsubscription logic along with all changes done on T05
Isha B                   16-July-2023   I2RT-8643           Show created by name as 'Informatica support for Initial response T07
Shashikanth			    18-Oct-2023		I2RT-7702		    Changed Case Comment Subject for AAE                      T08
 */

import { api, LightningElement, track, wire } from 'lwc';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import getCaseComments from '@salesforce/apex/CaseCommentController.getCaseComments';
import getPermissionOnObject from '@salesforce/apex/CaseCommentController.getPermissionOnObject';
import Case_Comments_Icons from '@salesforce/resourceUrl/Case_Comments_Icons';
import Case_comment_Icon_Internal from '@salesforce/resourceUrl/CaseInternal';
 import CASE_STATUS from '@salesforce/schema/Case.Status'; // <T04>
 import { getRecord,getFieldValue } from 'lightning/uiRecordApi'; // <T04>
 import CASE_RECORDTYPE from '@salesforce/schema/Case.RecordType.Name';     //<T08>
 import CASE_TIMEZONE from '@salesforce/schema/Case.Case_Timezone__r.TimeZoneSidKey__c';     //<T08>
 


import Id from '@salesforce/user/Id';


//I2RT-2685 Deva Generic Utilities.
import { objUtilities } from 'c/informaticaUtilities';


const MINIMAL_SEARCH_TERM_LENGTH = 3; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

const COMMENTS_PER_PAGE = 10;

export default class CaseCommentListView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api commentVisibility;
    @api commentCategory;
    @api tabName;
    @api commentStatus;
    @api commentType;
    @api commentInbound;
    @api fullScreen;
    @api ccFullScreen;
    @api taggedUserId;

    isPopout = false;
    showSpinner = false;
    showButtons = false;
    @track
    caseCommentList = [];
    activeSections = [];
    isExpanded = true;
    wiredCaseComments;
    timerInterval;
    subscription = null;
    searchKey = '';
    _searchThrottlingTimeout;
    _searchTerm;
    _cleanSearchTerm;
    loading = false;
    hasOriginalRecord = false;

    caseCommentSub;

    currentPage = 1;
    caseCommentsRaw = [];
    caseRecordType = '';
    caseTimezone = '';

    @track
    filters = [{
        label: 'Latest Posts',
        value: 'LastModifiedDate DESC',
        isSelected: true
    }, {
        label: 'Oldest Posts',
        value: 'LastModifiedDate ASC',
        isSelected: false
    }];

    

    get selectedSort() {
        return this.filters.filter(fil => fil.isSelected)[0].label;
    }

    get caseCommentsCount() { 
        return (this.caseCommentList && this.caseCommentList.length > 0) || this.hasOriginalRecord || this.searchKey != '';
    }

    get sortBy() {
        return this.filters.filter(fil => fil.isSelected)[0].value;
    }

    get visibility() {
        return this.commentVisibility ? this.commentVisibility : '';
    }
 
    get status() {
        return this.commentStatus ? this.commentStatus : '';
    }

    get type() {
        return this.commentType ? this.commentType : '';
    }

    get isInbound(){
        console.log('this.commentInbound=' + this.commentInbound);
        return this.commentInbound;
    }

    /*@wire(getCaseComments, { caseRecordId: '$recordId', visibility: '$visibility', status: '$status', sortBy: '$sortBy', searchKey: '$searchKey' })
    getCaseComments(response) {
        this.wiredCaseComments = response;
        if (response.error) {
            console.log('error>>>', JSON.parse(JSON.stringify(response.error)));
        }
        if (response.data) {
            this.caseCommentList = this.formatComments(response.data);
            if (!this.hasOriginalRecord && this.caseCommentList && this.caseCommentList.length) {
                this.hasOriginalRecord = true;
            }
            this.setTimer();
        }
        this.loading = false;
        this.showSpinner = false;
    }*/

    @wire(getPermissionOnObject)
    createPermission({ error, data }) {
        if (data) {
            //console.log("Watch: metadataRecord data -> " + JSON.stringify(data));
            this.showButtons = data;
           // alert('value----'+data);
            //metadataRecordURL
        } else if (error) {
           // alert(JSON.stringify(error));
            //console.log("Watch: metadataRecord error -> " + JSON.stringify(error));
        }
    }
    connectedCallback() {
        console.log('@Log=> connectedCallback:');
        this.showSpinner = true;
        
        if(this.commentCategory != null && this.commentCategory != ''){
            let ccDetails = this.commentCategory.split('-');
            console.log('@Log=> ccDetails:' + ccDetails);
            
            if(ccDetails.length > 1){
                this.visibility = ccDetails[0];
                this.commentCategory = ccDetails [1];
            }
        }
        
        this.fetchCaseComments({    
            caseRecordId: this.recordId,
            visibility: this.visibility,
            commentCategory:this.commentCategory,
            status: this.status,
            sortBy: this.sortBy,
            type: this.type,
            isInbound: this.isInbound,
            tabName: this.tabName,
            taggedUserId: this.taggedUserId //T02
        });
    }


    @api
    refresh(visibility,commentCategory){
        console.log('@Log=> refresh:' );
        this._cleanSearchTerm = '';
        this.searchKey = '';
        this.currentPage = 1;
        
        this.fetchCaseComments({    
            caseRecordId: this.recordId,
            visibility: visibility,
            commentCategory:commentCategory,
            status: this.status,
            sortBy: this.sortBy,
            type: this.type,
            isInbound: this.isInbound,
            tabName: this.tabName,
            taggedUserId: this.taggedUserId //T02
        });
    }

    fetchCaseComments(params) {
       
        let params2 = params;
        params2.limitValue = COMMENTS_PER_PAGE;
        params2.offset = (this.currentPage - 1) * COMMENTS_PER_PAGE;
        if(this.currentPage = 1){
            this.caseCommentsRaw = [];
        }
        let searchKey = params.searchKey;
        //console.log('@Log=> fetchCaseComments params2:' + JSON.stringify(params2) );
        getCaseComments(params2).then(response => {
            console.log('@Log=> response.length:' + response.length);
            //console.log('@Log=> response:' + JSON.stringify(response));
            this.caseCommentList = [];
            this.hasOriginalRecord = false;
            
            if(response.length > 0){
                //@Akhilesh 1 Oct 2021 --start
                //this.caseCommentsRaw = this.caseCommentsRaw.concat(response); // ? who coded this ?
                this.caseCommentsRaw = response;
                //@Akhilesh 1 Oct 2021 --end
                console.log('@Log=> caseCommentsRaw count:' + JSON.stringify(this.caseCommentsRaw.length));
                this.caseCommentList = this.formatComments(this.caseCommentsRaw,searchKey);                
                if (!this.hasOriginalRecord && this.caseCommentList && this.caseCommentList.length) {
                    this.hasOriginalRecord = true;
                }
                //Deva ITRT 2636 :dispatch event to pass the comment list to parent component
                this.dispatchEvent( new CustomEvent('loadcomments', {detail:{fullcommentlist:this.caseCommentList}}));                
                //Deva ITRT 2636 :End
                this.setTimer();
            }
            
        }).catch(err => {   
            console.log('ERROR>>', JSON.stringify(err));
        }).finally(() => {
            this.loading = false;
            this.showSpinner = false;
        });
    }

    handleKeyUp(event) {
        this.searchKey = event.target.value;
        this.updateSearchTerm(event.target.value);
    }

    updateSearchTerm(newSearchTerm) {
        const newCleanSearchTerm = newSearchTerm.trim();
        this._cleanSearchTerm = newCleanSearchTerm;

        if (this._searchThrottlingTimeout) {
            clearTimeout(this._searchThrottlingTimeout);
        }

        this._searchThrottlingTimeout = setTimeout(() => {
            if (this._cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                this.loading = true;
                this.searchKey = this._cleanSearchTerm;
                this.fetchCaseComments({
                    caseRecordId: this.recordId,
                    visibility: this.visibility,
                    commentCategory:this.commentCategory,
                    status: this.status,
                    sortBy: this.sortBy,
                    searchKey: this._cleanSearchTerm,
                    type: this.type,
                    isInbound: this.isInbound,
                    tabName: this.tabName,
                    taggedUserId: this.taggedUserId //T02
                });
            } else {
                this.fetchCaseComments({
                    caseRecordId: this.recordId,
                    visibility: this.visibility,
                    commentCategory:this.commentCategory,
                    status: this.status,
                    sortBy: this.sortBy,
                    type: this.type,
                    isInbound: this.isInbound,
                    tabName: this.tabName,
                    taggedUserId: this.taggedUserId //T02
                });
            }
            this._searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    processChildComments(childData){
        if(objUtilities.isNotNull(childData)){
            childData.forEach((childComment, index, childData) => {
                let tempArr = this.formatComments([childComment]);
                if(tempArr && tempArr?.length > 0){
                    childData[index] = tempArr[0];
                }
            });
            return childData;
        }
    }

    formatComments(data,searchKey) {
        // console.log('@Log=> formatComments:'+JSON.stringify(data));
        // console.log('@Log=> formatComments:'+data[0].childComment);
        // console.log('@Log=> formatComments length:', data.length);

        let tmpCaseCommentList = [];

        if (data && data.length > 0) {
            let caseCommentMap = new Map();
            
            let latestInternalComment;
            if (this.sortBy == 'LastModifiedDate DESC') {
                Array.from(data).forEach(comment => {
                    // console.log('each comment'+JSON.stringify(comment));
                    if (comment.comment && comment.comment.Visibility__c == 'Internal' && !latestInternalComment) {
                        latestInternalComment = comment.comment.Id;
                    }
                });
            }

            if (this.sortBy == 'LastModifiedDate ASC') {
                Array.from(data).slice().reverse()
                    .forEach(function (comment) {
                        if (comment.comment && comment.comment.Visibility__c == 'Internal' && !latestInternalComment) {
                            latestInternalComment = comment.comment.Id;
                        }
                    });
            }

            Array.from(data).forEach(comment => {
                // console.log('inside');
                let tmpArr = [];

                var lastModifiedDate;
                let recentParentCommentUpdate;
                if(comment.comment){
                    if (comment.comment.ContentDocumentLinks) {
                        comment.comment.ContentDocumentLinks.forEach(att => {
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
                    //Balaji - As part of Prod Issue #175 - No update on Parent Comment , LastModifiedDate changed to CreatedDate
                    lastModifiedDate = comment.comment.CreatedDate;
                    // <T01>
                    if(comment.childComment != null && comment.childComment.comment.Status__c == 'Submitted'){
                        recentParentCommentUpdate = comment.childComment.comment.LastModifiedDate;
                    }else{
                        recentParentCommentUpdate = comment.comment.CreatedDate;
                    }
                    // </T01>
                        
                }else if(comment.caseHistory){
                    lastModifiedDate = comment.caseHistory.CreatedDate;
                }else if(comment.taskRecord){
                    lastModifiedDate = comment.taskRecord.LastModifiedDate;
                }
               if(comment.eventRecord){
                    lastModifiedDate = comment.eventRecord.LastModifiedDate;
                }
                // <T01>
                let recentUpdateTimeStamp = (recentParentCommentUpdate != undefined && recentParentCommentUpdate != '') ? new Date(recentParentCommentUpdate) :  new Date(lastModifiedDate);
                recentParentCommentUpdate = '';
                // </T01>

				// T02 - Now we create the tagged users, if any.
				let lstTaggedUsers = new Array();
				if(objUtilities.isNotNull(comment) && objUtilities.isNotNull(comment.comment)) {
					if(objUtilities.isNotNull(comment.comment.Tagged_User_1__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.comment.Tagged_User_1__r.Name,
							name: comment.comment.Tagged_User_1__r.Id,
							iconName: "standard:avatar",
							recordId: comment.comment.Id
						});
					}
					if(objUtilities.isNotNull(comment.comment.Tagged_User_2__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.comment.Tagged_User_2__r.Name,
							name: comment.comment.Tagged_User_2__r.Id,
							iconName: "standard:avatar",
							recordId: comment.comment.Id
						});
					}
					if(objUtilities.isNotNull(comment.comment.Tagged_User_3__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.comment.Tagged_User_3__r.Name,
							name: comment.comment.Tagged_User_3__r.Id,
							iconName: "standard:avatar",
							recordId: comment.comment.Id
						});
					}
					if(objUtilities.isNotNull(comment.comment.Tagged_User_4__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.comment.Tagged_User_4__r.Name,
							name: comment.comment.Tagged_User_4__r.Id,
							iconName: "standard:avatar",
							recordId: comment.comment.Id
						});
					}
					if(objUtilities.isNotNull(comment.comment.Tagged_User_5__r)) {
						lstTaggedUsers.push({
							type: 'icon',
							label: comment.comment.Tagged_User_5__r.Name,
							name: comment.comment.Tagged_User_5__r.Id,
							iconName: "standard:avatar",
							recordId: comment.comment.Id
						});
					}
				}

                let formattedDate = new Date(lastModifiedDate).toLocaleDateString("en-US", {
                    timeZone: TIMEZONE, year: 'numeric', month: 'short', day: 'numeric'
                });
                let formattedTime = new Date(lastModifiedDate).toLocaleTimeString("en-US", {
                    timeZone: TIMEZONE, hour: "2-digit", minute: "2-digit", hour12: "true"
                });
                /* let createdTime = new Date(comment.comment.CreatedDate).toLocaleTimeString("en-US", {
                    timeZone: TIMEZONE, hour: "2-digit", minute: "2-digit", hour12: "true"
                }); */
                if (!caseCommentMap.has(formattedDate)) {
                    caseCommentMap.set(formattedDate, []);
                }
               
                //Amarender - added as part of I2RT-3465 - start
                let commentIcons = {
                    inbound : Case_Comments_Icons + '/Inbound@2x.png',
                    outbound : Case_Comments_Icons + '/Outbound@2x.png',
                    attention : Case_Comments_Icons + '/attention@2x.png',
                    meeting : Case_Comments_Icons + '/meeting@2x.png',
                    collaboration : Case_Comments_Icons + '/Collaborations@2x.png',
                    recommend : Case_Comments_Icons + '/recommend@2x.png',
                    escalation : '/img/func_icons/util/escalation16.gif',
                    internal : Case_comment_Icon_Internal,
                    private : Case_Comments_Icons + '/Outbound@2x.png'
                }
                if(comment.comment){
                     let iconName;
                     let isInbound = comment.comment.Inbound__c;
                     if(comment.comment.Type__c != null){
                         if(comment.comment.Type__c.includes('Callback') || comment.comment.Type__c == 'Revise Priority' || comment.comment.Type__c == 'Live Assistance'){
                            iconName = commentIcons.attention;
                         }else if(comment.comment.Type__c.includes('Escalation')){
                            iconName = commentIcons.escalation;
                         }else if(comment.comment.Type__c == 'Raise Hand'){                       
                             iconName = commentIcons.collaboration;
                         }else if(comment.comment.Type__c == 'Request More Info' || comment.comment.Type__c == 'Provide Solution' || comment.comment.Type__c == 'Close Case' || comment.comment.Type__c == 'JIRA Request' || comment.comment.Type__c == 'Delay Close'){
                            iconName = commentIcons.outbound;
                         }
                     } else if(comment.comment.Recommendation__c != null){
                        iconName = commentIcons.recommend;
                     }else if(comment.comment.Visibility__c == 'Internal'){
                        iconName = commentIcons.internal;
                     }else if(isInbound){
                         iconName = commentIcons.inbound;
                     }else{
                         iconName = commentIcons.outbound;
                     }
                    //Amarender - added as part of I2RT-3465 - end
                    
                    let commentObj =  Object.assign({
                        date: formattedDate,
                        time: formattedTime,
                        datetime: formattedDate + ' ' + formattedTime,
                        sortTimeStamp: recentUpdateTimeStamp,
                        role: comment.role,
                        uid: comment.comment.Id,
                        isHighImportance: comment.comment.Importance__c,
                        isPrivate: comment.comment.Visibility__c == 'Private',
                        isInternal: comment.comment.Visibility__c == 'Internal',
                        isExternal: comment.comment.Visibility__c == 'External',
                        isInbound: comment.comment.Inbound__c,
                        iconName: iconName,                                         //Amarender - added as part of I2RT-3465
                        isScheduled: comment.comment.Status__c == 'Scheduled',
                        isSubmitted: comment.comment.Status__c == 'Submitted',
                        isopened: comment.comment.Email_Opened__c,
                        commentCatgory:comment.comment.Comment_Category__c,
                        //I2RT-2685 Deva Added a condition to hide edit and delete buttons for south depp comments. 
                        // <T01>
                        isEditable: ((comment.comment.Visibility__c == 'Internal' && comment.comment.CreatedById == Id && latestInternalComment == comment.comment.Id) || comment.comment.Status__c != 'Submitted' || comment.comment.Visibility__c == 'Private' ||
                                    (latestInternalComment == comment.comment.Id && !objUtilities.isBlank(comment.comment.Type__c)))  && 
                                    objUtilities.isBlank(comment.comment.Recommendation__c) && comment.comment.Type__c != 'Raise Hand' && comment.comment.Type__c != 'JIRA Request',
                        // </T01>
                        isDeletable: comment.comment.Status__c != 'Submitted' && objUtilities.isBlank(comment.comment.Recommendation__c),
                        isDeleted: false,
                        canReply: ((comment.comment.Inbound__c && (!comment.comment.Case_Comments__r)) || (comment.comment.ZIssue__c != null && comment.comment.ZIssue__c != undefined)),
                        hideZIssueReply : (comment.comment.ZIssue__c != null && comment.comment.ZIssue__c != undefined) ? true : false,
                        titleClass: comment.comment.Inbound__c ? "slds-page-header__name" : "slds-float_right slds-page-header__name",
                        isDraft: comment.comment.Status__c == 'Draft',
                        attachments: tmpArr,
                        taggedUsers: lstTaggedUsers, //T02
                        caseCommentFeedBackItem: comment.caseCommentFeedBack ,                        
                        isEmailOpened : comment.caseCommentEmailStat?.Email_Opened__c, 
                        isEmailSent : (comment.caseCommentEmailStat != null && comment.caseCommentEmailStat != undefined) ? true : false,
                        caseCommentEmailStat: comment.caseCommentEmailStat ,
                        likeState: comment.caseCommentFeedBack ? comment.caseCommentFeedBack.Like__c : false,
                        disLikeState: comment.caseCommentFeedBack ? comment.caseCommentFeedBack.disLike__c : false,
                        replies: comment.childComments ? this.processChildComments(comment.childComments) : comment.childComment ? this.formatComments([comment.childComment]) : null,
                        attachmentCount: comment.comment.ContentDocumentLinks ? comment.comment.ContentDocumentLinks.length : 0,
                        hasAttachments: comment.comment.ContentDocumentLinks && comment.comment.ContentDocumentLinks.length,
                        hasTaggedUsers:  lstTaggedUsers && lstTaggedUsers.length, //T02
                        showReplies: true,
                        scheduledTime: new Date(comment.comment.Date_Time_Scheduled__c).toLocaleString("en-US", {
                            year: 'numeric', month: 'short', day: 'numeric', timeZone: TIMEZONE, hour: "2-digit", minute: "2-digit", hour12: "true"
                        }),
                         //Deva : I2RT-2630 : Added a additional Param to display if the replies are added 
                         //Amar - Prod Issue #175 - No update on Parent Comment, So not required to show created date time on Parent Comment.
                        /* createdDate:comment.childComment ? new Date(comment.comment.CreatedDate).toLocaleDateString("en-US", {
                            timeZone: TIMEZONE, year: 'numeric', month: 'short', day: 'numeric'
                        }) + ' ' + createdTime + ' ' :null, */
                        commentText: comment.comment.Comment__c,
                        fullPhotoUrl: comment.comment.CreatedBy.FullPhotoUrl,
                        /*creatorName: comment.comment.CreatedBy.Name*/
                        // creatorName: comment.comment.CreatedBy.Name.toLowerCase()=='deployment master' ? comment.comment.Owner.Name : comment.comment.CreatedBy.Name
                        
                       // creatorName: (comment.comment.Created_By__c != ' ' && comment.comment.Created_By__c != undefined) ? comment.comment.Created_By__c : comment.comment.CreatedBy.Name.toLowerCase()=='infa support' ? 'Informatica Support' : comment.comment.CreatedBy.Name
                       creatorName: (() => { //T07
                        if (comment.comment.Sub_Type__c !==null && comment.comment.Sub_Type__c!==undefined && comment.comment.Sub_Type__c && comment.comment.Sub_Type__c === 'Initial Response') {
                          return 'Informatica Support';
                        } else if (comment.comment.Created_By__c !== undefined && comment.comment.Created_By__c && comment.comment.Created_By__c !== ' ' ) {
                          return comment.comment.Created_By__c;
                        } else if (comment.comment.CreatedBy.Name.toLowerCase() === 'infa support' || comment.comment.CreatedBy.Name.toLowerCase() === 'sfdcadmin') {
                          return 'Informatica Support';
                        } else {
                          return comment.comment.CreatedBy.Name;
                        }
                      })(),
                    }, comment.comment);
                    // console.log('isEmailOpened : ' + commentObj.isEmailOpened);
                    // console.log('comment.caseCommentEmailStat : ' + JSON.stringify(comment.caseCommentEmailStat));
                    caseCommentMap.get(formattedDate).push(commentObj);
                   /* if(searchKey != undefined && commentObj.commentText != null && commentObj.commentText != undefined && commentObj.commentText != '' && commentObj.commentText.includes(searchKey)){
                        caseCommentMap.get(formattedDate).push(commentObj);
                    }else if (searchKey == undefined){
                        caseCommentMap.get(formattedDate).push(commentObj);
                    }*/ //-> commented by Isha
                }else if(objUtilities.isNotNull(comment.caseHistory)){  
                    
                    let caseHistoryObj = Object.assign({
                        uid: comment.caseHistory.Id,
                        date: formattedDate,
                        time: formattedTime,
                        datetime: formattedDate + ' ' + formattedTime,
                        sortTimeStamp: recentUpdateTimeStamp,
                        isHighImportance: false,
                        iconName : commentIcons.internal,                    //Amarender - added as part of I2RT-3465
                        isPrivate: false,
                        isInternal: true,
                        isExternal: false,
                        isScheduled: false,
                        isSubmitted: true,
                        isEmailSent : comment.Email_Sent__c,
                        caseCommentEmailStat: {Email_Opened__c : false},
                        commentCatgory: 'General Comments',
                        isEditable: false,
                        isDeletable: false,
                        isDeleted: false,
                        canReply: false,
                        hideZIssueReply: false,
                        titleClass: "slds-float_right slds-page-header__name",
                        isDraft: false,
                        //attachments: tmpArr,
                        //replies: comment.childComment ? this.formatComments([comment.childComment]) : null,
                        //attachmentCount: comment.comment.ContentDocumentLinks ? comment.comment.ContentDocumentLinks.length : 0,
                        hasAttachments: false,
                        showReplies: false,
                        commentText: 'Status changed from ' + comment.caseHistory.OldValue + ' to ' + comment.caseHistory.NewValue,
                        fullPhotoUrl: comment.userProfilePhotoUrl,
                        role: comment.role,
                        creatorName: comment.caseHistory.CreatedBy.Name
                    }, comment.caseHistory);
                    // console.log('caseHistoryObj || searchKey : ' + caseHistoryObj.commentText + '||' + searchKey);
                    if(searchKey != undefined && caseHistoryObj.commentText != null && caseHistoryObj.commentText != undefined && caseHistoryObj.commentText != '' && caseHistoryObj.commentText.includes(searchKey)){
                        caseCommentMap.get(formattedDate).push(caseHistoryObj);
                    }else if (searchKey == undefined){
                        caseCommentMap.get(formattedDate).push(caseHistoryObj);
                    }
                }
                if(objUtilities.isNotNull(comment.taskRecord)){//check and add tasks if not null
                    let taskObj = this.getActivityObject(comment.taskRecord,commentIcons,formattedDate,formattedTime,recentUpdateTimeStamp,'T');
                    if(searchKey != undefined && taskObj.commentText != null && taskObj.commentText != undefined && taskObj.commentText != '' && taskObj.commentText.includes(searchKey)){
                        caseCommentMap.get(formattedDate).push(taskObj);
                    }else if (searchKey == undefined){
                        caseCommentMap.get(formattedDate).push(taskObj);
                    }
                    
                }
                if(objUtilities.isNotNull(comment.eventRecord)){//check and add Events if not null
                    let eventObj = this.getActivityObject(comment.eventRecord,commentIcons,formattedDate,formattedTime,recentUpdateTimeStamp,'E');
                    if(searchKey != undefined && eventObj.commentText != null && eventObj.commentText != undefined && eventObj.commentText != '' && eventObj.commentText.includes(searchKey)){
                        caseCommentMap.get(formattedDate).push(eventObj);
                    }else if (searchKey == undefined){
                        caseCommentMap.get(formattedDate).push(eventObj);
                    }
                }
            });
            
            caseCommentMap.forEach((value, key) => {
                if(value.length > 0 ){
                    tmpCaseCommentList.push({
                        date: key,
                        comments: value,
                        sortOrder: Date.parse(key)  //key.getTime()     
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
            
            console.log('tmpCaseCommentList count >>', tmpCaseCommentList.length);
        }
        return tmpCaseCommentList;
    }
     //Deva - Start - I2RT-3585 Prepare Task or Event Object respectively and push to list
     getActivityObject(activityObject, commentIcons,formattedDate,formattedTime,recentUpdateTimeStamp,activityType){
        let caseCommentSubject = this.getCaseCommentSubject(activityObject, activityType);      //<T08>
        return Object.assign({
            uid: activityObject.Id,
            date: formattedDate,
            time: formattedTime,
            datetime: formattedDate + ' ' + formattedTime,
            sortTimeStamp: recentUpdateTimeStamp,
            isHighImportance: false,
            iconName : activityType==='E'? commentIcons.meeting :commentIcons.collaboration,                    //Amarender - added as part of I2RT-3465
            isPrivate: false,
            isInternal: true,
            isExternal: false,
            isScheduled: false,
            isSubmitted: true,
            caseCommentEmailStat: {Email_Opened__c : false},
            commentCatgory: 'Activity Comments',
            isEditable: false,
            isDeletable: false,
            isDeleted: false,
            canReply: false,
            titleClass: "slds-float_right slds-page-header__name",
            isDraft: false,
            hasAttachments: false,
            showReplies: false,
            commentText: caseCommentSubject,                //<T08>
            fullPhotoURL: '',
            creatorName: activityObject.CreatedBy.Name,
            taskRecord:activityType==='T'?true:false,
            eventRecord:activityType==='E'?true:false
        }, activityObject);
    }
     //Deva - End - I2RT-3585 

    //<T08>
    /*
	 Method Name : getCaseCommentSubject
	 Description : This method returns Case Comment Subject.
	 Parameters	 : activityObject, activityType
	 Return Type : String
	 */
    getCaseCommentSubject(activityObject, activityType){
        let caseCommentSubject = '';
        if(this.caseRecordType === "Ask An Expert" && activityType === 'E'){
            let formattedActivityDateTime = new Date(activityObject.ActivityDateTime).toLocaleDateString("en-US", {
                timeZone: this.caseTimezone, year: 'numeric', month: 'short', day: 'numeric',hour: "2-digit", minute: "2-digit", hour12: "true"
            });
            caseCommentSubject = `AAE session ${activityObject.Subject} scheduled on ${formattedActivityDateTime}`;
        }
        else{
            let subjectPretext = (activityType === 'E') ? 'Event Logged With Subject - ' : 'Task  Logged With Subject - ';
            caseCommentSubject = subjectPretext + activityObject.Subject;
        }
        return caseCommentSubject;
    }
    //</T08>


    //Comparer Function    
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

    handleClick(event) {
        switch (event.currentTarget.name) {
            case 'expandAll':
                this.isExpanded = true;
                this.activeSections = [];
                this.caseCommentList.forEach(comment => {
                    this.activeSections.push(comment.Id);
                });
                //this.handleShowReply();
                this.template.querySelector('c-case-comment-timeline').expandAll();
                break;

            case 'collapseAll':
                this.isExpanded = false;
                this.activeSections = [];
                this.template.querySelector('c-case-comment-timeline').collapseAll();
                //this.handleHideReply();
                break;

            case 'refresh':
                //this.showSpinner = true;
                this._cleanSearchTerm = '';
                this.searchKey = '';
                this.currentPage = 1;
                this.fetchCaseComments({
                    caseRecordId: this.recordId,
                    visibility: this.visibility,
                    commentCategory:this.commentCategory,
                    status: this.status,
                    sortBy: this.sortBy,
                    searchKey: this._cleanSearchTerm,
                    type: this.type,
                    isInbound: this.isInbound,
                    tabName: this.tabName,
                    taggedUserId: this.taggedUserId //T02
                });
                break;

            case 'popout':
                this.isPopout = true;
                break;

            case 'popin':
                this.isPopout = false;
                break;

            default:
                break;
        }

        //Deva ITRT 2636 : on Click of any button reset the Labels
        this.dispatchEvent(new CustomEvent("resetdata", { detail: true }));
        //Deva ITRT 2636 : End
    }
    handleSelect(event) {
        this.filters.forEach(fil => {
            fil.isSelected = fil.value == event.detail.value
        });
        let params = {
            caseRecordId: this.recordId,
            visibility: this.visibility,
            commentCategory:this.commentCategory,
            status: this.status,
            sortBy: this.sortBy,
            type: this.type,
            taggedUserId: this.taggedUserId //T02
        };

        if (this._cleanSearchTerm) {
            params = Object.assign({ searchKey: this._cleanSearchTerm }, params);
        }
        this.fetchCaseComments(params);
        console.log('this.filters>>', JSON.parse(JSON.stringify(this.filters)));
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    setTimer() {
        let self = this;
        this.timerInterval = setInterval(function () {
            let isScheduled = false;
            self.caseCommentList.forEach(wrapper => {
                wrapper.comments.forEach(comm => {
                    if (comm.isScheduled && new Date().getTime() < new Date(comm.Date_Time_Scheduled__c)) {
                        comm.countdown = self.calculateTimeLeft(comm.Date_Time_Scheduled__c);
                        isScheduled = true;
                    }
                    console.log()
                    if (comm.replies) {
                        comm.replies.forEach(repl => {
                            if (repl.comments[0].isScheduled && new Date().getTime() < new Date(repl.comments[0].Date_Time_Scheduled__c)) {
                                repl.comments[0].countdown = self.calculateTimeLeft(repl.comments[0].Date_Time_Scheduled__c);
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
    handleReloadFeedBack(event){
         //Deva ITRT 2636 : on Click of any button reset the Labels
         this.dispatchEvent(new CustomEvent("resetdata", { detail: true }));
        //Deva ITRT 2636 : End
        this._cleanSearchTerm = '';
        this.searchKey = '';
        this.fetchCaseComments({
            caseRecordId: this.recordId,
            visibility: this.visibility,
            commentCategory:this.commentCategory,
            status: this.status,
            sortBy: this.sortBy,
            searchKey: this._cleanSearchTerm,
            type: this.type,
            isInbound: this.isInbound,
            tabName: this.tabName,
            taggedUserId: this.taggedUserId //T02
        });
    }
    calculateTimeLeft(countDownDateString) {
        var countDownDate = new Date(countDownDateString).getTime();
        var now = new Date().getTime();
        var distance = countDownDate - now;
        var days = Math.floor(distance / (1000 * 60 * 60 * 24));
        var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.floor((distance % (1000 * 60)) / 1000);

        return (days ? days + "d " : '') + (hours ? hours + "h " : '')
            + (minutes ? minutes + "m " : '') + (seconds ? seconds + "s " : '');
    }
    handleShowReply(event) {
        //Deva ITRT 2636 : on Click of any button reset the Labels
        this.dispatchEvent(new CustomEvent("resetdata", { detail: true }));
        //Deva ITRT 2636 : End      

        this.caseCommentList.forEach(commWrap => commWrap.comments.forEach(element => {
            if (event) {
                if (element.Id == event.detail) {
                    element.showReplies = true;
                }
            } else {
                element.showReplies = true;
            }
        }));
    }

    handleHideReply(event) {
        //Deva ITRT 2636 : on Click of any button reset the Labels
        this.dispatchEvent(new CustomEvent("resetdata", { detail: true }));
        //Deva ITRT 2636 : End
        this.caseCommentList.forEach(commWrap => commWrap.comments.forEach(element => {
            if (event) {
                if (element.Id == event.detail) {
                    element.showReplies = false;
                }
            } else {
                element.showReplies = false;
            }
        }));
    }

    handleLoadMore(event){
        this.currentPage++;

        this.fetchCaseComments({
            caseRecordId: this.recordId,
            visibility: this.visibility,
            commentCategory:this.commentCategory,
            status: this.status,
            sortBy: this.sortBy,
            searchKey: this._cleanSearchTerm,
            type: this.type,
            isInbound: this.isInbound,
            tabName: this.tabName,
            taggedUserId: this.taggedUserId //T02
        });
    }
     
     // <T04>
     @wire(getRecord, { recordId: '$recordId', fields: [CASE_STATUS,CASE_RECORDTYPE,CASE_TIMEZONE] })     //<T08>
    relatedMedia({ data, error }) {
        if (data) {
            let thisReference = this;
            thisReference.currentPage = 1;
            //<T08>
            thisReference.caseRecordType = getFieldValue(data, CASE_RECORDTYPE);    
            thisReference.caseTimezone = getFieldValue(data, CASE_TIMEZONE);
            //</T08>   
            thisReference.fetchCaseComments({
                caseRecordId: thisReference.recordId,
                visibility: thisReference.visibility,
                commentCategory: thisReference.commentCategory,
                status: thisReference.status,
                sortBy: thisReference.sortBy,
                searchKey: thisReference._cleanSearchTerm,
                type: thisReference.type,
                isInbound: thisReference.isInbound,
                tabName: thisReference.tabName,
   				taggedUserId: thisReference.taggedUserId //T02
            }); 
        } else if (error) {
            console.log('Error' + JSON.stringify(error));
        }
    }
}