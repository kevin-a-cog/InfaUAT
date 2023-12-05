/*
 Change History
 ******************************************************************************************************************************
 Modified By            Date            Jira No.        Tag         Description                                             
 ******************************************************************************************************************************
 Shashikanth            6/14/2023       I2RT-8533       T01         GEMS - Chatter Post should also stop the GEMS Timer
 */
import { LightningElement,api,wire} from 'lwc';
import fetchTimeDuration from '@salesforce/apex/engagementTimerController.fetchTimeDuration';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS=['Engagement__c.Id','Engagement__c.Status__c'];

export default class EngagementTimer extends LightningElement {
    @api recordId;
    bShowMsg= false;
    msg1 = ' Last Activity:';       //<T01>
    msg = '';
    

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
      
    if (error) {
       console.log('error occured : ' + JSON.stringify(error));
    }
     else if (data) {      
      console.log('(data occured : ' + JSON.stringify((data)));      
           this.bShowMsg= false;   
           this.apexHandler();             
    }
}



    apexHandler(){
        fetchTimeDuration({'recId' : this.recordId}).then( numberOfDays => {
           console.log('numberOfDays===> ' + numberOfDays);
           if(numberOfDays > 0){
            if(numberOfDays==1)
            {
                this. msg = '' + numberOfDays + ' Day Ago';
            }
            else
            {
                this. msg = '' + numberOfDays + ' Days Ago';
            }
             this.bShowMsg = true
           }
        }).catch( err => {
          
        });
    }

}