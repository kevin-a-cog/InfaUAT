/*
 * Name			:	CsmPlanRisks
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Manage Risk Products controller.

 Change History
 ***************************************************************************************************************************
 Modified By			Date			Jira No.		Description												Tag
 ***************************************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.										N/A
 Karthi					29/11/2022		AR-3014			Added condition to hide edit for Complete Plans			<T1>
 Chaitanya T			13/10/2023		AR-3481			moving the error message to a custom label				<T02>
 */

//Core imports.
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMPlanRisksController.getRecords";
//import getRecordsDeleted from "@salesforce/apex/CSMPlanRisksController.getRecordsDeleted";
import validateRisk from "@salesforce/apex/CSMPlanRisksController.validateRisk";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Risks_And_Issues_Title from '@salesforce/label/c.Manage_Risks_And_Issues_Title';
import Search_Risks_And_Issues_Placeholder from '@salesforce/label/c.Search_Risks_And_Issues_Placeholder';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Error from '@salesforce/label/c.Error';
import CSMActiveRiskErrorMsg from '@salesforce/label/c.CSMActiveRiskErrorMsg';//<T02>
//Fields
import AUTO_PILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";
const PLAN_FIELDS = [AUTO_PILOT,STATUS];

//import custom permissions
import hasCSMPermission from "@salesforce/customPermission/CSMUser";

//Class body.
export default class CsmPlanRisks extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api readOnly=false;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
    boolShowRiskEditScreen;
	boolShowPAFVAlidation;
	riskRecordId;
	fromCreateRisk;
	planautopilotvalue;

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		Error
	}

	//Wire Plan record to load
	@wire(getRecord, { recordId: "$recordId", fields: PLAN_FIELDS })
	planRecord;

	//Show new riks button only if plan is not autopilot and has csm permissions
	get boolShowNewRiskButton(){
		const autoPilot = getFieldValue(
			this.planRecord.data,
			AUTO_PILOT
	  	);	  
		const isComplete = getFieldValue(this.planRecord.data,STATUS)=='Complete'; //<T1>
		return (objUtilities.isNotBlank(autoPilot) && autoPilot == false && objUtilities.isNotNull(hasCSMPermission) && !isComplete && !this.readOnly)?true:false;
	}

	//Feature Configuration.
	@track objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: Manage_Risks_And_Issues_Title,
		strSearchPlaceholder: Search_Risks_And_Issues_Placeholder,
		objParameters: {
			strTableId: "1",
			strTableClass: "risksAndIssuesTable",
			lstActionButtons: [{
				strId: "1",
				strVariant: "Neutral",
				strLabel: Cancel_Button,
				title: Cancel_Button,
				strStyleClasses: "slds-var-m-left_x-small"
			}/*, {
				strId: "2",
				strVariant: "Brand",
				strLabel: Remove_Button,
				title: Remove_Button,
				strStyleClasses: "slds-var-m-left_x-small"
			}*/, {
				strId: "3",
				strVariant: "Brand",
				strLabel: "Edit Risk",
				title: "Edit Risk",
				strStyleClasses: "slds-var-m-left_x-small"
			}]
		}
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
        this.boolShowRiskEditScreen = false;
		this.fromCreateRisk=false;
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
		let iscomplete=false;
		//Now we fetch the data.
		getRecords({
			strRecordId: this.recordId,
			filterCloseRisk:false
		}).then((objResult) => {
			//Show error message on screen if paf cycle not ran once			
			if(objUtilities.isNotNull(objResult.lstRecords)){
				objResult.lstRecords.forEach(record => {
					this.planautopilotvalue=record.Plan__r?.CSM_isAutoPilot__c;
					iscomplete=record.Plan__r?.Status__c==='Complete'; //<T1>
					if(objUtilities.isNotBlank(record.Plan__r?.Plan_Status_Reason__c)){
						objParent.boolShowPAFVAlidation=false;
						return false;
					}else{
						objParent.boolShowPAFVAlidation=true;
						return false;
					}
				});
			}
			//We build the tables.
			
			objParent.objConfiguration.objParameters.lstRecords = objResult.lstRecords;
			objParent.objConfiguration.objParameters.lstColumns = objResult.lstColumns;
			objParent.objConfiguration.objParameters.boolHideCheckboxColumn = true;
			/*if(objParent.planautopilotvalue || !hasCSMPermission || iscomplete || this.readOnly){				
				objParent.objConfiguration.objParameters.boolHideCheckboxColumn = true;				
			}else{
				objParent.objConfiguration.objParameters.boolHideCheckboxColumn = false;
			 
			}*/
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
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
		let objParent = this;
		objParent.riskRecordId=null;
		objParent.boolDisplaySpinner = true;		
        //Valdiate PAf Cycle
		validateRisk({
			strPlanId: this.recordId
		}).then((objResult) => {			
			//Show error message on screen if paf cycle not ran once			
			/*if(objUtilities.isNotNull(objResult) && objResult.boolOnePAFCycleCompleted===false){
				objUtilities.showToast(objParent.label.Error,"Please complete one Adoption Factor Cycle to create Risk",'error',objParent);
			}else */
			if(objUtilities.isNotNull(objResult) && objResult.boolOpenRiskAvailable===true){
				objUtilities.showToast(objParent.label.Error,CSMActiveRiskErrorMsg,'error',objParent);//<T02>
			}else{
				objParent.boolShowRiskEditScreen = true;
				objParent.fromCreateRisk=true;
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});

    }

	
    /*
    Method Name : handleClose
    Description : This method executes on close
    Parameters	: objEvent onclick event.
    Return Type : None
    */
	handleClose(objEvent){
		this.boolShowRiskEditScreen = false;
		this.riskRecordId=null;
		this.refreshCard(objEvent);
	}

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

	/*Depricated
	 Method Name : removeRecords
	 Description : This method deletes the selected records.
	 Parameters	 : None
	 Return Type : None
	 
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
	}*/
	/*
	 Method Name : editRiskRecords
	 Description : This method edit the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	editRiskRecords(){
		let objParent = this;
		let selectedRecords=objParent.objConfiguration.objParameters.lstSelectedRecords;
		let lstRecords = new Array();

		//First we create the list of unique ids.
		selectedRecords.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});		
		if(lstRecords.length>1){
			//Now we display the success message.
			objUtilities.showToast(objParent.label.Error, "Please select only one record", 'error', objParent);
		}else if(lstRecords.length>0){		
			objParent.riskRecordId= lstRecords[0].Id
			objParent.boolShowRiskEditScreen = true;
			objParent.fromCreateRisk=false;		
		}
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
						this.handleCancel();
					break;
					//User wants to remove a record.
					case "2":
						//this.removeRecords();
					break;
					//User wants to remove a record.
					case "3":
						this.editRiskRecords();
					break;
				}
			break;
		}
    }
}