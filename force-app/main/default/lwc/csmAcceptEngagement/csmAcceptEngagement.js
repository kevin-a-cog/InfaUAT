import { LightningElement,api } from 'lwc';
import acceptEngagementRecord from '@salesforce/apex/csmAcceptEngagementController.acceptEngagementRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class CsmAcceptEngagement extends LightningElement {
 @api recordId;
 connectedCallback(){
     setTimeout(() => {this.acceptHandler();}, 2000);

   
 }
 

 acceptHandler(){
    acceptEngagementRecord({'engagementId' : this.recordId})
    .then(result => {
        this.showNotification('Success!','Record has been accepted successfully' , 'success');
        this.dispatchEvent(new CloseActionScreenEvent());
        getRecordNotifyChange([{ recordId: this.recordId }]);
    })
    .catch(error => {
        console.log('error==>  ' + JSON.stringify(error));
        this.showNotification('Error!', JSON.stringify(error) , 'error');
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