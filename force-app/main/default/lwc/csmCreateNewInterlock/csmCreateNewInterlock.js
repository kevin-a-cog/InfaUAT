import { LightningElement,api,wire } from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { objUtilities } from 'c/globalUtilities';
import { NavigationMixin } from "lightning/navigation";

import lookupSearch from "@salesforce/apex/csmPlanInterlockController.lookupSearch";
import getRecordsInserted from "@salesforce/apex/csmPlanInterlockController.getRecordsInserted";

const FIELDS = ['Plan__c.Account__c'];
//Custom labels
import Error from '@salesforce/label/c.Error';
import Success from '@salesforce/label/c.Success';
import RecurrenceInterval from '@salesforce/schema/Task.RecurrenceInterval';

export default class CsmCreateNewInterlock extends NavigationMixin(LightningElement) {
@api recordId;

selectedOpptyId;
accountId;
interlockId;
customLookupClass;
showSpinner = false;

	//Labels.
	label = {   
		Error,
		Success
	}

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
			console.log(JSON.stringify(data));
			this.accountId = data.fields.Account__c.value;
		}
	}

	 /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
     connectedCallback(){       
        let objParent = this;
		objParent.customLookupClass="slds-p-left_small slds-p-right_xx-small";
     }
    handleLookupSelectionChange(event){
        var dataId = event.target.getAttribute('data-id');
		
        switch(dataId){
			case 'Opportunity':
                this.selectedOpptyId = event.detail.values().next().value;  
				this.customLookupClass="slds-p-left_small slds-p-right_xx-small";
            break;
        }
	}

    handleLookupSearch(event){
		const lookupElement = event.target;
		let objParent = this;
		objParent.customLookupClass="slds-p-left_small slds-p-right_xx-small";
        var dataId = event.target.getAttribute('data-id');		
        lookupSearch({searchTerm :event.detail.searchTerm , selectedIds : event.detail.selectedIds , objectName : dataId, accId : this.accountId})
		.then(results => {
			if(objUtilities.isNotNull(results) && results.length>0){
				objParent.customLookupClass="slds-p-left_small slds-p-right_xx-small lookup_overlay_custom";
			}else{
				objParent.customLookupClass="slds-p-left_small slds-p-right_xx-small";
			}			
			lookupElement.setSearchResults(results);
		})
		.catch(objError => {
			objUtilities.processException(objError, objParent);
		});		
	}

     /*
	 Method Name : handleCancel
	 Description : This method is to Close the Modal popup
	 Parameters	 : None
	 Return Type : None
	 */
	handleCancel(event){
		//this.openEngagementModal = false;
		this.showRecordTypeSelection = false;
        const closeEvent = new CustomEvent('closemodal', { detail: this.openEngagementModal });
        this.dispatchEvent(closeEvent);
	}

    handleError(event){
		this.showSpinner = false;
		console.log('error'+JSON.stringify(event.detail));
	}

    handleSubmit(event){
		let objParent = this;
        event.preventDefault();
        if(objUtilities.isNull(objParent.selectedOpptyId)){
			objUtilities.showToast(objParent.label.Error, 'Please select opportunity, to save Interlock', 'error', objParent);
			return;
		}
        else{
		//Validate if the opportunity is not blank
		console.log(objParent.selectedOpptyId);
		console.log('objUtilities.isNotNull(objParent.selectedOpptyId)' + objUtilities.isNotNull(objParent.selectedOpptyId));
		if(objUtilities.isNotNull(objParent.selectedOpptyId)){
			this.showSpinner = true;		
			const fields = event.detail.fields;
        	fields.Original_Opportunity__c = this.selectedOpptyId;		
			getRecordsInserted({interlock : Object.assign({ 'SobjectType' : 'Related_Opportunity_Plan__c' }, fields)})
			.then(result=>{
				this.showSpinner = false;
				if(result){
					this.interlockId = result;
				}
				console.log('this.interlockId >'+this.interlockId);
				var interlockId = this.interlockId;			
				
				//Now we display the success message.
				objUtilities.showToast(objParent.label.Success, 'Interlock is created successfully !', 'success', objParent);
				
				//Navigate to new record
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: interlockId,
						actionName: 'view'
					}
				});

				/**Close the Modal */			
				const closeEvent = new CustomEvent('closemodal');
				this.dispatchEvent(closeEvent);
			})
			.catch(objError=>{
				objUtilities.processException(objError, objParent);
				objParent.boolDisplaySpinner = false;
			})
			.finally(() => {
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;
			});
		}else{
			//Now we display the success message.
			objUtilities.showToast(objParent.label.Error, 'Please select opportunity, to save Interlock', 'error', objParent);
		}
	}
        
    }

	
}