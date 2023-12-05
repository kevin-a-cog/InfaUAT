/*
 * Name			:	CsmManagePlanEngagement
 * Author		:	
 * Created Date	: 	
 * Description	:	Manage Plan Engagement controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 Chaitanya T			17-08-2023		AR-3365			new MFA record				T01
 Chaitanya T			25-10-2023		AR-3467			Open Success Accelerator 
 														when clicked on New CSA		T02
 **********************************************************************************************************
 
 */

//Core imports.
import { LightningElement, api , wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
//Apex Controllers.
import getRecords from "@salesforce/apex/CSMPlanEngagementController.getRecords";
import getRecordsDeleted from "@salesforce/apex/CSMPlanEngagementController.getRecordsDeleted";


//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import New_CSA_Button from '@salesforce/label/c.New_CSA_Button';//<T02>
import Loading from '@salesforce/label/c.Loading';
import Manage_Engagement from '@salesforce/label/c.Manage_Engagement';
import Search_Engagement from '@salesforce/label/c.Search_Engagement';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';


//Custom Permissions
import hasCSMPermission from '@salesforce/customPermission/CSMUser';

//Objects & Fields
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";
const fields = [IS_AUTOPILOT,STATUS];

export default class CsmManagePlanEngagement extends NavigationMixin(LightningElement) {
    //API variables.
	@api recordId;
    @api isPoppedOut = false;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	planRecord;

	//Modal Variable
	openEngagementModal = false;

	showCoveo = false;//<T02>

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		New_CSA_Button//<T02>
	}

    //Feature Configuration.
	@track objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: Manage_Engagement	,
		strSearchPlaceholder: Search_Engagement,
		objParameters: {
			strTableId: "1",
			strTableClass: "engagementTable",
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
        return (hasCSMPermission && !isAutopilot  && !isComplete);
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
			//<T01> start
			objResult.lstRecords.forEach((element) => {
				if(element.RecType__c == null){
					element.RecType__c = element.RecordType.Name;
				}
			});//<T01> end
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
		return false;
	}

     /*
	 Method Name : newRecord
	 Description : This method opens a standard page to create a new record.
	 Parameters	 : None
	 Return Type : None
	 */
     newRecord() {
		this.openEngagementModal = true;
		//this.showRecordTypeSelection = true;
    }

	//<T02> start
	/*
	 Method Name : newCSARecord
	 Description : This method opens a standard page to create a new CSA record.
	 Parameters	 : None
	 Return Type : None
	 */
     newCSARecord() {
		this.showCoveo = true;
		this.openEngagementModal = true;
    }
	//</T02> end

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

	handleCloseModal(event){		
		let objParent = this;	
		this.openEngagementModal = false;
		this.showCoveo = false;//<T02>
		objParent.refreshCard();
	}

}