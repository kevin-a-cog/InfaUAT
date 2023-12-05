/*
    @created by       : Ankit Saxena
    @created on       : 02/02/2020
    @Purpose          : Expired Article Message for internal users.
    @JIRA             : I2RT-7434
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 */



 import { LightningElement, api, track, wire } from 'lwc';
 import { getRecord } from 'lightning/uiRecordApi';
 
 const ARTICLE_FIELDS = [
     'Knowledge__kav.Id',
     'Knowledge__kav.PublishStatus',
     'Knowledge__kav.Days_to_Expire__c'
 ];
 
 export default class KbExpiredArticleMesg extends LightningElement {
     @api recordId;
     @api expiredMessage;
     @track expiredCssClass = "show-expired-mesg expired-article";
     @track publishStatus;
     @track daysToExpire;
     @track isExpired = false;
     
     @wire(getRecord, { recordId: '$recordId', fields: ARTICLE_FIELDS })
     wiredRecord({error, data}){
         if(data){
             this.publishStatus = data.fields.PublishStatus.value;
             this.daysToExpire = data.fields.Days_to_Expire__c ? data.fields.Days_to_Expire__c.value : 0;
             console.log('KbExpiredArticleMesg : publishStatus, daysToExpire = ', this.publishStatus, ' : ', this.daysToExpire);
             if (this.publishStatus == 'Online' && this.daysToExpire < 0) {
                 console.log('KbExpiredArticleMesg : inside true');
                 this.expiredCssClass = 'show-expired-mesg';
                 this.isExpired = true;
             }    
         } else if (error) {
             console.log('KbExpiredArticleMesg : error= ', JSON.stringify(error));
         }
     }
 }