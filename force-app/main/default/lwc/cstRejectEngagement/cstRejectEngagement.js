/*
 * Name			:	CstRejectEngagement
 * Author		:	
 * Created Date	: 	
 * Description	:	CSA Reject quick action button

 Change History
 ***********************************************************************************************************************
 Modified By		Date			Jira No.		Description					                                Tag
 Chaitanya T		08/18/2023		AR-3327 		making approval comments mandatory during rejection			T01
 ***********************************************************************************************************************
 
 */
 import { LightningElement,api } from 'lwc';
 import rejectEngagementRecord from '@salesforce/apex/CstRejectEngagementController.rejectEngagementRecord';
 import rejectapprovalrecord from '@salesforce/apex/CstRejectEngagementController.rejectEngagementRecord';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { CloseActionScreenEvent } from 'lightning/actions';
 import { getRecordNotifyChange } from 'lightning/uiRecordApi';
 
 export default class CstRejectEngagement extends LightningElement {
  @api recordId;
  //<T01> start
  spinner = false;
  textValue = '';
  
  handleTextAreaChange(event){
     this.textValue = event.target.value;
  }
 
  handleSuccess(){
     let inputFields = this.template.querySelectorAll('.validate');
         let isValid = true;
         inputFields.forEach(inputField =>{
             if(!inputField.checkValidity()) {
                 inputField.reportValidity();
                 isValid = false;
             }
         });
         if(isValid){
             this.spinner = true;
             this.acceptHandler();
         }
  }
  
  handleCancel(){
     this.dispatchEvent(new CloseActionScreenEvent());
  }
  //<T01> end
  
  acceptHandler(){
     rejectEngagementRecord({'engagementId' : this.recordId, 'closingNotes':this.textValue})
     .then(result => {
         this.spinner = false;
         this.showNotification('Success!','Record has been close without engagement successfully' , 'success');
         this.dispatchEvent(new CloseActionScreenEvent());
         getRecordNotifyChange([{ recordId: this.recordId }]);
     
     })
     .catch(error => {
         console.log('error==>  ' + JSON.stringify(error));
         let msg =  (error?.body?.pageErrors !==undefined && error?.body?.pageErrors.length>0) ? error?.body?.pageErrors[0]?.message : JSON.stringify(error);
         this.showNotification('Error!', msg, 'error');
         this.dispatchEvent(new CloseActionScreenEvent());
         this.error = error;
     }); 
     
  }
 
  showNotification(stitle,msg,type) {
     const evt = new ShowToastEvent({
         title: stitle,
         message: msg,
         variant: type
     });
     this.dispatchEvent(evt);
 }
 
 }