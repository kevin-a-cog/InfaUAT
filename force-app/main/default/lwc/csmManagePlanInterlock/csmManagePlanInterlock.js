//Core imports.
import { LightningElement, api , wire , track} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

//Apex Controllers.
import getRecords from "@salesforce/apex/csmPlanInterlockController.getRecords";
import getRecordsDeleted from "@salesforce/apex/csmPlanInterlockController.getRecordsDeleted";
import getDisplayForecast from "@salesforce/apex/CSMChurnForecastController.getDisplayChurnForecast"; //AR-3141


//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Engagement from '@salesforce/label/c.Manage_Engagement';
import Search_Engagement from '@salesforce/label/c.Search_Engagement';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Churn_Forecast_Label from '@salesforce/label/c.Churn_Forecast_Label';

//Custom Permissions
import hasCSMPermission from '@salesforce/customPermission/CSMUser';
import hasCSOPermission from '@salesforce/customPermission/CSOUser';//added as part of AR-2947
import hasPermissiontoCreate from '@salesforce/customPermission/Allow_Permission';

//Objects & Fields
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";
const fields = [IS_AUTOPILOT,STATUS];

export default class CsmManagePlanInterlock extends NavigationMixin(LightningElement) {
    //API variables.
	@api recordId;
    @api isPoppedOut = false;

	openInterlockModal = false;
	openForecastmodal = false;
	boolShowRiskScreen=false;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	planRecord;
	
	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		Churn_Forecast_Label
	}

    //Feature Configuration.
	@track objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: 'Manage Related Opportunites'	,
		strSearchPlaceholder: 'Search Interlock',
		objParameters: {
			strTableId: "1",
			strTableClass: "interlockTable",
			lstActionButtons: [{
				strId: "1",
				strVariant: "Neutral",
				strLabel: Cancel_Button,
				title: Cancel_Button,
				strStyleClasses: "slds-var-m-left_x-small"
			}, {
				strId: "2",
				strVariant: "Brand",
				strLabel: Remove_Button,
				title: Remove_Button,
				strStyleClasses: "slds-var-m-left_x-small"
			}]
		}
	}

	@wire(getRecord, { recordId: "$recordId", fields })
	planRecordDetails({data,error}){
			if(data){
				this.planRecord = data;
				var isAutoPilot = data.fields.CSM_isAutoPilot__c.value;				
				var status = data.fields.Status__c.value;
				if(isAutoPilot || !hasCSMPermission || status==='Complete'){
					this.objConfiguration.objParameters.boolHideCheckboxColumn = true;
				}else{
					this.objConfiguration.objParameters.boolHideCheckboxColumn = false;
				}
			}
	}

	get showButtons() {
		var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);		
		const isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';
        return (hasCSOPermission && !isAutopilot && hasPermissiontoCreate  && !isComplete);//added as part of AR-2947
    }

	//AR-3141 
    @wire(getDisplayForecast, { planId: '$recordId' })
    showForecast;
	//AR-3141

	get showForecastButton(){
		var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);		
		const isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';
		return (!isAutopilot && !isComplete && this.showForecast.data);
	}
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;		

		//Now we load the list of records.
		this.loadRecords();
		

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

    /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let objParent = this;

		//Now we fetch the data.
		getRecords({
			strRecordId: this.recordId
		}).then((objResult) => {

			//We build the tables.
			objParent.objConfiguration.objParameters.lstRecords = objResult.lstRecords;
			objParent.objConfiguration.objParameters.lstColumns = objResult.lstColumns;
			objParent.boolDisplaySpinner = false;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
			objParent.boolDisplaySpinner = false;
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

    /*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	refreshCard(objEvent) {
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}

		//We refresh the Assigned table.
		this.boolDisplaySpinner = true;
		this.template.querySelector('.searchField').value = "";
		this.loadRecords();
		refreshApex(this.showForecast); //AR-3141
		if(this.openForecastmodal){
			this.template.querySelector('c-csm-churn-forecast').refreshCard();
		}
		return false;
	}

     /*
	 Method Name : newRecord
	 Description : This method opens a standard page to create a new record.
	 Parameters	 : None
	 Return Type : None
	 */
	/**
     newRecord() {
		//let strCurrentTab = this.getCurrentTab();
		let strObjectName;
		let objParent = this;

		//Now we open the new subtab.
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Related_Opportunity_Plan__c",
                actionName: "new"
            },
            state : {
                nooverride: "1",
                defaultFieldValues: encodeDefaultFieldValues({
					Plan__c: this.recordId
				})
				//recordTypeId: objParent.strRecordTypeId
            }
        });
    }
	**/

    /*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		this.template.querySelector('.' + this.objConfiguration.objParameters.strTableClass).searchRecord(objEvent);
	}

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
    selectRecords(objEvent) {
		this.objConfiguration.objParameters.lstSelectedRecords = objEvent.detail.selectedRows;
    }

	/*
	 Method Name : handleCancel
	 Description : This method removes the Action panels from the UI.
	 Parameters	 : None
	 Return Type : None
	 */
    handleCancel() {
		this.template.querySelector('.' + this.objConfiguration.objParameters.strTableClass).hideActions();
    }

	/*
	 Method Name : removeRecords
	 Description : This method deletes the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	removeRecords() {
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//Now we create the list of unique ids.
		this.objConfiguration.objParameters.lstSelectedRecords.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});

		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {

			//We refresh the card.
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to cancel the table selection.
					case "1":
					case "3":
						this.handleCancel();
					break;

					//User wants to remove a record.
					case "2":
						this.removeRecords();
					break;
				}
			break;
		}
    }	

	/*
	 Method Name : newRecord
	 Description : This method opens a standard page to create a new record.
	 Parameters	 : None
	 Return Type : None
	 */
     newRecord() {
		this.openInterlockModal = true;
    }

	/*
	 Method Name : handleCloseModal
	 Description : This method closes the Modal
	 Parameters	 : None
	 Return Type : None
	 */
	handleCloseModal(event){		
		let objParent = this;	
		this.openInterlockModal = false;
		this.openForecastmodal = false; //AR-3141
	/*	if(event.detail){
			this.boolShowRiskScreen=true;
		} */
		objParent.refreshCard(); 
	}

	handleCloseRisk(event){
		this.boolShowRiskScreen=false;
	}

	//AR-3141
	forecastChurn() {
		this.openForecastmodal = true;
    }

}