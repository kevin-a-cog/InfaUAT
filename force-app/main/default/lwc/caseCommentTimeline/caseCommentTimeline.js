/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Amarender              29-Nov-2021     I2RT-4415           Case Communication (Case Comments/Chatter)                T01            
 balajip                21-Nov-2022     I2RT-7508           to pass the Case Id in the message                        T02 
 Isha Bansal            01-Jan-2023     I2RT-7491           Display banner for Jira Login on the Jire related replies T03 
 */
 import { api, LightningElement, track, wire } from 'lwc';
 import Icons from '@salesforce/resourceUrl/icons';
 import { NavigationMixin } from 'lightning/navigation';
 import { publish, MessageContext } from 'lightning/messageService'
 import CASE_COMM_MC from "@salesforce/messageChannel/CaseCommunicationMessageChannel__c";
 import { updateRecord,getRecord } from 'lightning/uiRecordApi';
 import FIELD_ID from '@salesforce/schema/Case_Comment__c.Id';
 import FIELD_IS_DELETED from '@salesforce/schema/Case_Comment__c.Is_Deleted__c';
 import getCaseCommetEmailDetails from '@salesforce/apex/CaseCommentStats.getCaseCommetEmailDetails';
 import updateCaseFeedBackRecord from '@salesforce/apex/CaseCommentController.updateCaseFeedBackRecord';
 
 //Utilities.
 import { objUtilities } from 'c/informaticaUtilities';
 const CASEFIELDS = [
     'Case.Status'
 ];
 
 export default class CaseCommentTimeline extends NavigationMixin(LightningElement) {
     @api commentList; 
     @api access;
     @api caseRecordId;
     @api isFullScreen;
     @api ccFullScreen;
     hideZissueReplyVal = false;
     @track showSpinner=false;
     @track oModal=false;
     @track caseCommentToShow;
     //Deva variables to hold feedback comment input and show modal
     feedbackCommnet;
     feedbackModelOpen=false;
     commenFeedBackRecord;
     isLike=false;
     isEdit = false;
     isReply = false;
     @api showbutton;
     @track
     caseCommentToEdit;
     recordId;
     parentCommentId;
     imageURL = {
         draft: Icons + '/sketching-24.png',
         calendar: Icons + '/clock-32.png',
         submitted: Icons + '/verification-24.png',
         draft_16: Icons + '/sketching-16.png',
         calendar_16: Icons + '/clock-16.png',
         submitted_16: Icons + '/verification-16.png',
     };
    zissue=false;
 
     get isPrivate() {
         return this.access === 'Private';
     }
 
     get showModal() {
         return this.isEdit || this.isReply;
     }
 
     get modalHeader() {
         return this.isEdit ? 'Edit Comment' : (this.isReply ? 'Reply' : '');
     }
 
     // added by piyush
     @wire(getRecord, { recordId: '$caseRecordId', fields: CASEFIELDS })
     oCase;
   // added by piyush
     get caseStatus() {
         var isClosed = false;
         if(this.oCase.data != undefined){
             isClosed = (this.oCase.data.fields.Status.value == 'Cancelled' || this.oCase.data.fields.Status.value == 'Delivered');
         }
         return isClosed;
     }
 
     @wire(MessageContext)
     messageContext;
 
     connectedCallback() {       
         let globalStyle = document.createElement('style');
         globalStyle.innerHTML = `
          .timelineAttachments .slds-pill__remove {
             display: none !important;
         }
         
         .timelineAttachments .slds-pill_container {
             border: none !important;
         }
         
         .fill_brand svg {
             fill: #0070d2;
         }`;
         document.head.appendChild(globalStyle);
     }
     get caseCommentStyles(){
         return (this.isFullScreen || this.ccFullScreen ? "col-md-8 col-md-offset-2 col-xs-12" : "col-md-8 col-md-offset-2 col-xs-12 caseCommentTimeline-height");
     }  
     
     /*Deva Start to Handle like and dislike buttons*/
     handleLikeButtonClick(commenFeedBack,event,ccRecordId) {  
         //If the user wants to switch the feedback, retreive the previously provided comments on the popup window.
         if(objUtilities.isBlank(this.feedbackCommnet)){
             this.feedbackCommnet=objUtilities.isNotBlank(commenFeedBack.Feedback__c)?commenFeedBack.Feedback__c:''; 
         }
         if(commenFeedBack && commenFeedBack.Like__c){
             return;
         }
        // alert(this.feedbackCommnet+' like '+commenFeedBack);
         this.recordId = event.target.dataset.id; 
         this.feedbackModelOpen=true;
         this.feedbackCommnet='';
         this.commenFeedBackRecord=commenFeedBack;
         this.isLike=true;
     }
     handleDislikeButtonClick(commenFeedBack,event,ccRecordId) {
         //If the user wants to switch the feedback, retreive the previously provided comments on the popup window.
         if(objUtilities.isBlank(this.feedbackCommnet)){
             this.feedbackCommnet=objUtilities.isNotBlank(commenFeedBack.Feedback__c)?commenFeedBack.Feedback__c:''; 
         }
         if(commenFeedBack && commenFeedBack.disLike__c){
             return;
         }   
         this.recordId = event.target.dataset.id; 
         this.feedbackModelOpen=true;
         this.feedbackCommnet='';
        // alert(this.feedbackCommnet+' dislike '+commenFeedBack);
         this.commenFeedBackRecord=commenFeedBack;
         this.isLike=false;       
     }
     closeFeedbackModal(event) { 
         this.feedbackCommnet='';
         if(this.isLike){
             this.showSpinner = true; 
             this.formatCaseCommentFeedBack(this.commenFeedBackRecord,event,(this.commenFeedBackRecord.Id ? this.commenFeedBackRecord.Feedback__c:''));    
             this.feedbackModelOpen = false;
         }else{
             this.showSpinner = false; 
             this.feedbackModelOpen = false;
         }
     }
     captureEnteredTextData(event){
         this.feedbackCommnet = event.target.value;  
     }
     submitFeedbackDetails(event) { 
         this.showSpinner = true;
         //Feedback is mandatory for dilike button
         if(!this.isLike && (objUtilities.isNull(this.feedbackCommnet) || objUtilities.isBlank(this.feedbackCommnet))){
             objUtilities.showToast('Error','Feedback is mandatory when dislike the comment','error',this);
         }else{
             if(objUtilities.isNotNull(this.feedbackCommnet) || objUtilities.isNotBlank(this.feedbackCommnet)){
                 this.formatCaseCommentFeedBack(this.commenFeedBackRecord,event,this.feedbackCommnet);     
             }else{
                 this.formatCaseCommentFeedBack(this.commenFeedBackRecord,event,(this.commenFeedBackRecord.Id ? this.commenFeedBackRecord.Feedback__c:''));     
             }
             this.feedbackModelOpen = false;
          }
          //this.feedbackCommnet='';
         // this.commenFeedBackRecord.Feedback__c='';
     }
     formatCaseCommentFeedBack(commenFeedBack,event,updatedFeedbackComment){     
         var  caseFeedBackObject;  
         var eventOperation='';
         if(commenFeedBack && commenFeedBack.Id){
             caseFeedBackObject=Object.assign({
                 "Id": commenFeedBack.Id,
                 "Case_Comment__c": this.recordId,
                 "disLike__c": this.isLike?false:true,
                 "Like__c": this.isLike?true:false,
                 "Feedback__c":updatedFeedbackComment
             });
             eventOperation='ISUPDATE';
         }else{
             caseFeedBackObject=Object.assign({
                 "Case_Comment__c": this.recordId,
                 "disLike__c": this.isLike?false:true,
                 "Like__c": this.isLike?true:false,
                 "Feedback__c":updatedFeedbackComment
             });
             eventOperation='ISINSERT';
         }
         this.updateCaseFeedBackRecord(caseFeedBackObject,eventOperation,event);   
 
     }
     handlePassFeedBack(event){
         this.dispatchEvent(new CustomEvent("reloadfeedback", {
             detail: this.recordId
         }));
     }
     updateCaseFeedBackRecord(caseFeedBackObject,eventOperation,event){
         updateCaseFeedBackRecord({
             sobjOperation: eventOperation,
             sobjRecord: caseFeedBackObject
           })
             .then((result) => {
                 event.stopPropagation();
                 this.feedbackCommnet = '';
                 this.dispatchEvent(new CustomEvent("reloadfeedback", {
                     detail: this.recordId
                 }));
                 this.dispatchEvent(new CustomEvent("passfeedback", {
                     detail: this.recordId
                 }));
             })
             .catch((error) => {
                 objUtilities.processException(error, this);
             })
             .finally(() => {
                 this.showSpinner = false;
             });
     }
     /*Deva End logic for like and dislike buttons*/
     /*Deva to handle event and task buttons*/
      // Navigate to View Task Page
      navigateToViewTaskPage(activityId) {
         this[NavigationMixin.Navigate]({
             type: 'standard__recordPage',
             attributes: {
                 recordId: activityId,
                 objectApiName: 'Task',
                 actionName: 'view'
             },
         });
     }
       // Navigate to View Event Page
       navigateToViewEventPage(activityId) {
         this[NavigationMixin.Navigate]({
             type: 'standard__recordPage',
             attributes: {
                 recordId: activityId,
                 objectApiName: 'Event',
                 actionName: 'view'
             },
         });
     }
     handleClick(event) {        
         switch (event.target.name) {  
             case 'task':
                 this.recordId = event.target.dataset.id;
                 this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {
                     if (element.Id == this.recordId) {
                         this.navigateToViewTaskPage(element.Id);
                     }
                 }));
                 break;
             case 'event':
                 this.recordId = event.target.dataset.id;
                 this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {                        
                     if (element.Id == this.recordId) {
                         this.navigateToViewEventPage(element.Id);
                     }
                 }));
             break;          
             case 'like':
                 this.recordId = event.target.dataset.id;
                 this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {
                     if (element.Id == this.recordId) {
                         this.handleLikeButtonClick(element.caseCommentFeedBackItem,event,element.Id);
                     }
                 }));
                 break;
             case 'dislike':
                 this.recordId = event.target.dataset.id;
                 this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {                        
                     if (element.Id == this.recordId) {
                         this.handleDislikeButtonClick(element.caseCommentFeedBackItem,event,element.Id);
                     }
                 }));
             break;
             case 'edit':
                 this.recordId = event.target.dataset.id; 
                 this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {
                     if (element.Id == this.recordId) {
                         this.caseCommentToEdit = element;                         
                         this.zissue = element.Parent_Comment__r?.ZIssue__c?true:false; //I2RT-7491 -T03
                     }
                 }));
                 
                 this.isEdit = true;                 
                 break;
 
             case 'delete':
                 var selectedCommentId = event.target.dataset.id;
                 var confirmation = confirm('The comment will be deleted.. click OK to proceed!');
                 if(confirmation){
                     this.showSpinner = true;
 
                     var fields = {};
                     fields[FIELD_ID.fieldApiName] = selectedCommentId;
                     fields[FIELD_IS_DELETED.fieldApiName] = true;
                     var recordInput = { fields };
                     updateRecord(recordInput)
                     .then(result => {
                         console.log("result - " + JSON.stringify(result));
                         this.handleSuccess(event);
                         this.showSpinner = false;
                     })
                     .catch(error => {
                         this.showSpinner = false;
                         console.log("error - " + JSON.stringify(error));
                     });
                 }
                 break;
 
             case 'close':
                 this.recordId = null;
                 this.caseCommentToEdit = null;
                 this.isEdit = false;
                 this.isReply = false;
                 this.parentCommentId = null;
                 break;
 
             case 'reply':
                 this.hideZissueReplyVal = event.target.dataset.hidezissuereply;
                 this.isReply = true;
                 this.recordId = null;
                 this.caseCommentToEdit = null;
                 this.isEdit = false;
                 this.parentCommentId = event.target.dataset.id;
                 this.zissue = event.target.dataset.zissue?true:false; //I2RT-7491 -T03
                 break;
 
             case 'showReply':
                 event.stopPropagation()
                 this.dispatchEvent(new CustomEvent("showreply", {
                     detail: event.target.dataset.id
                 }));
                 break;
 
             case 'hideReply':
                 event.stopPropagation()
                 this.dispatchEvent(new CustomEvent("hidereply", {
                     detail: event.target.dataset.id
                 }));
                 break;
 
             default:
                 break;
         }
     }
 
     handleSuccess(event) {
         this.recordId = null;
         this.caseCommentToEdit = null;
         this.isEdit = false;
         this.isReply = false;
         this.parentCommentId = null;
         publish(this.messageContext, CASE_COMM_MC, {caseId: this.caseRecordId}); //T02
     }
 
     handleWheel(event) {
         //console.log('on scroll, scrollTop >> ', event.target.scrollTop);
         //console.log('on scroll, scrollHeight >> ', event.target.scrollHeight);
         //console.log('on scroll, offsetHeight >> ', event.target.offsetHeight);
 
         //I2RT-4607
         /*if(event.target.scrollTop >= event.target.scrollHeight - event.target.offsetHeight) {
             console.log('on scroll, reached end..');
             this.dispatchEvent(new CustomEvent("loadmore", {
                 detail: ''
             }));
         }*/
     }
 
     handleShowMore(event) {
         const uid = event.currentTarget.dataset.uuid;
 
         this.template.querySelector("[data-uid=\"" + uid + "\"]").classList.toggle('expanded');
         let iconEle = this.template.querySelector("[data-icon=\"" + uid + "\"]");
         iconEle.iconName = iconEle.iconName == 'utility:chevronright' ? 'utility:switch' : 'utility:chevronright';
         //event.currentTarget.innerText = event.currentTarget.innerText == 'Show More' ? 'Show Less' : 'Show More';
 
         event.preventDefault();
     }
 
     @api
     expandAll() {
         this.template.querySelectorAll("[data-name='parent']").forEach(el => {
             el.classList.add('expanded');
             this.template.querySelector("[data-icon=\"" + el.dataset.uid + "\"]").iconName = 'utility:switch';
             //this.template.querySelector("[data-uuid=" + el.dataset.uid + "]").innerText = 'Show Less';
         });
     }
 
     @api
     collapseAll() {
         this.template.querySelectorAll("[data-name='parent']").forEach(el => {
             el.classList.remove('expanded');
             this.template.querySelector("[data-icon=\"" + el.dataset.uid + "\"]").iconName = 'utility:chevronright';
             //this.template.querySelector("[data-uuid=" + el.dataset.uid + "]").innerText = 'Show More';
         });
     }
 
     sModal(event){
         this.oModal=true;
         this.recordId = event.target.dataset.id;
         console.log('modalvalue', this.recordId);
         getCaseCommetEmailDetails({commentId: this.recordId})
         .then(result => {
         this.caseCommentToShow = result;
         console.log('allcmmm2',this.caseCommentToShow );
         });
         /*console.log('allcmmm', JSON.parse(JSON.stringify(this.commentList)));
         this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {
             if (element.Id == this.recordId) {
                 this.caseCommentToShow= element;
             }
         }));
         console.log('allcmmm1',this.caseCommentToShow );*/
     }
     cModal() {
         this.oModal = false;
     }
 
 }