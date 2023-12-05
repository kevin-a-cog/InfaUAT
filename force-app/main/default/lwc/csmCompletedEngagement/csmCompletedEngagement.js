import { LightningElement,api,track,wire } from 'lwc';
import lookupSearch from '@salesforce/apex/CsmCompletedEngagementCtrl.lookupSearch';
import completeEngagement from '@salesforce/apex/CsmCompletedEngagementCtrl.completeEngagement';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

const FIELDS = ['Engagement__c.Plan__c' , 'Engagement__c.Plan__r.Name'];

export default class CsmCompletedEngagement extends LightningElement {
    @api recordId;
    @track bPlanRequired = false;
    @track bFeedbackRequired = false;

    @track selectedPlanId;
    @track EngagementHelpfulVal = true;
    @track CSMSummaryVal = '';

    @track initialSelection =[];

    @track bshowlookup = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading engaement',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            console.log('Engagement Data =' + JSON.stringify(data));
            if(data.fields.Plan__c.value != null){
            var selectedRecord = {"icon":"custom:custom55",
                                  "id": data.fields.Plan__c.value,
                                  "sObjectType":"Plan__c",
                                  "subtitle":"",
                                  "title": data.fields.Plan__r.displayValue
                                };
            this.initialSelection = [selectedRecord];
            this.selectedPlanId = data.fields.Plan__c.value;
            }  
            this.bshowlookup = true;
        }
    }


    WasItHelpfulvalue = 'Yes';

    get options() {
        return [
            { label: 'Yes', value: 'Yes'},
            { label: 'No', value: 'No'},
            { label: 'Not Applicable', value: 'Not Applicable'}
             
        ];
    }


     
    
        

          
  

    handleLookupSearch(event){
		const lookupElement = event.target;
		let objParent = this;
        var dataId = event.target.getAttribute('data-id');
		

        lookupSearch({searchTerm :event.detail.searchTerm , selectedIds : JSON.stringify(event.detail.selectedIds) , objectName : dataId, engagementId : this.recordId})
            .then(results => {
                console.log('lookup results===> ' + JSON.stringify(results));
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                console.log('error--> ' + JSON.stringify(error));
               // objUtilities.processException(objError, objParent);
         });
		
	}


    handleLookupSelectionChange(event){
        var dataId = event.target.getAttribute('data-id');
		
        switch(dataId){
			case 'Plan__c':
                this.selectedPlanId = event.detail.values().next().value;  
            break;
        }
	}


    onchangeHandler(event){
        var target = event.target;
        
        switch (target.name) {
         
            case 'engagementHelpful':
            var cbValue =  target.value;
           
            if(cbValue == 'Yes'){
                this.EngagementHelpfulVal = true;
               // this.bPlanRequired = true;
                this.bFeedbackRequired = false;
            }
            else if(cbValue == 'No'){
               // this.bPlanRequired = false;
                this.EngagementHelpfulVal = false;
                this.bFeedbackRequired = true;
            }
            else{
                this.EngagementHelpfulVal = false;
                this.bFeedbackRequired = true;
            }  
            
              break;
            case 'CSMSummary':
              
            this.CSMSummaryVal = target.value;
          }
    }


    saveHandler(event){
       var engagementhelpful = this.EngagementHelpfulVal;
       var CSMSummaryVal = this.CSMSummaryVal;
       var selectedPlanId = this.selectedPlanId;

       console.log('Final data ' + 'engagementhelpful==> ' + engagementhelpful );
       console.log('Final data ' + 'CSMSummaryVal==> ' + CSMSummaryVal );
       console.log('Final data ' + 'selectedPlanId==> ' + selectedPlanId );

       //if((engagementhelpful && selectedPlanId == undefined) || (!engagementhelpful && CSMSummaryVal == '') ){ 
      if(!engagementhelpful && CSMSummaryVal == ''){ 
        this.showNotification('Error!', 'Required Fields Missing.' , 'error'); 
       }
       else{
           // update record
           completeEngagement({engagementId : this.recordId, bEngagementhelpful : engagementhelpful, sCSMSummaryVal : CSMSummaryVal, selectedPlanId : selectedPlanId})
           .then(results => {
               console.log('completeEngagement ' + results);
               this.showNotification('Success!', 'Record has been updated successfully' , 'success'); 
               this.dispatchEvent(new CloseActionScreenEvent());
               getRecordNotifyChange([{ recordId: this.recordId }]);
           })
           .catch(error => {
               console.log('error--> ' + JSON.stringify(error));
          });
       }
    }


    showNotification(stitle,msg,type) {
        const evt = new ShowToastEvent({
            title: stitle,
            message: msg,
            variant: type
        });
        this.dispatchEvent(evt);
    }


    cancelHandler(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}