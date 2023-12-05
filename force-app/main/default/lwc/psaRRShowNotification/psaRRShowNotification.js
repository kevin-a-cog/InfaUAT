import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from "@salesforce/schema/pse__Resource_Request__c.Id";
import SHOW_NOTIFICATION from '@salesforce/schema/pse__Resource_Request__c.Show_Notification__c';
import RR_Budget_Exceeded_Msg from '@salesforce/label/c.RR_Budget_Exceeded_Msg';

const fields = [SHOW_NOTIFICATION];

export default class PsaRRShowNotification extends LightningElement {
@api recordId;
displayNotification;
@wire(getRecord, { recordId: '$recordId', fields})
resourceReq(result){
    if(result.data){
        this.displayNotification = result.data.fields.Show_Notification__c.value; 
        if(this.displayNotification){
            //Show notification
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Notification',
                    message: RR_Budget_Exceeded_Msg,
                    variant: 'warning'
                })
            );
            
            //Update the shownotification field back to false
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[SHOW_NOTIFICATION.fieldApiName] = false;
            const recordInput = {
            fields: fields
            };
            updateRecord(recordInput).then((record) => {
                console.log(record);
                });                  
        }
    }
} 
}