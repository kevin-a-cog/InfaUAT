/*
 * Name			:	csmManageRiskProducts
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Manage Risk Products controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMManageRiskProductsController.getRecords";
import getRecordsDeleted from "@salesforce/apex/CSMManageRiskProductsController.getRecordsDeleted";
import getRecordsUpdated from "@salesforce/apex/CSMManageRiskProductsController.getRecordsUpdated";
//Schema imports.
import RISK_ISSUE_PLAN from "@salesforce/schema/Risk_Issue__c.Plan__c";
import RISK_ISSUE_STATUS from "@salesforce/schema/Risk_Issue__c.Status__c";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Risk_Products_Title from '@salesforce/label/c.Manage_Risk_Products_Title';
import Search_Risk_Products_Placeholder from '@salesforce/label/c.Search_Risk_Products_Placeholder';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import hasCSMPermission from '@salesforce/customPermission/CSMUser';
//Class body.
export default class CsmManageRiskProducts extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api boolNoModal;
	@api boolDisplayActions;

	//Feature specific API variables.
	@api fromcreatepage;
	@api fromeditpage;
	@api planidpassed;
	@api risksobject;

	//Track variables.
	@track objRiskRecord;

	//Wired items.
	@wire(getRecord, { recordId: '$recordId', fields: [RISK_ISSUE_PLAN, RISK_ISSUE_STATUS] }) objRiskRecord;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	boolRiskProductCreateScreen;
	boolRiskProductScreen;
	riskProductId;
	boolNewScreen;
	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		Success,
		Error	
	}

	//Feature Configuration.
	objConfiguration = {
			strIconName: "standard:feed",
			strCardTitle: Manage_Risk_Products_Title,
			strSearchPlaceholder: Search_Risk_Products_Placeholder,
			objParameters: {
				strTableId: "1",
				strTableClass: "riskProductTable",
				lstActionButtons: [{
					strId: "1",
					strVariant: "Neutral",
					strLabel: Cancel_Button,
					title: Cancel_Button,
					strStyleClasses: "slds-var-m-left_x-small"
				}, {
					strId: "2",
					strVariant: "Brand",
					strLabel: "Edit Risk Product",
					title: "Edit Risk Product",
					strStyleClasses: "slds-var-m-left_x-small"
				},{
					strId: "3",
					strVariant: "Brand",
					strLabel: Remove_Button,
					title: Remove_Button,
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
		this.boolNewScreen = true;
		this.boolDisplaySpinner = true;		
		this.boolRiskProductCreateScreen = false;
		this.boolRiskProductScreen=false;
		//Now we conditinally hide actions
		if(objUtilities.isNull(this.boolDisplayActions)) {
			this.objConfiguration.objParameters.boolDisplayActions = true;
		}else{
			this.objConfiguration.objParameters.boolDisplayActions = this.boolDisplayActions;
		}
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
	 Method Name :  
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let objParent = this;			
		//Now we fetch the data.
		getRecords({
			strRiskId: this.recordId
		}).then((objResult) => {
			let updatedRecords=[];
			//Logic to build to append the parent fields like contact phone for Assigned record						
			if(objUtilities.isNotNull(objResult.lstRecords)){				
				objResult.lstRecords.forEach(record => {
					//Restructered the Json to fetch related the fields
					if(objUtilities.isNotNull(record.Plan_Product_Alias__r)){
						record.Plan_Product_Alias__r.Id=objUtilities.isNotBlank(record.Plan_Product_Alias__r.Name__c) ? record.Plan_Product_Alias__r.Name__c : record.Plan_Product_Alias__c;
					}
					// and so on for other fields
					updatedRecords.push(record);
				});
			}	
			//Set Coloumn properties
			objResult.lstColumns.forEach(objColumn => {
				if(objColumn.fieldName === "Renewal_Probability__c" && (objUtilities.isNull(objParent.boolNoModal) || objParent.boolNoModal===false)){
					//objColumn.editable = "true";
					objColumn.editable = (!hasCSMPermission)?"false":"true";
				}
				if(objColumn.strFieldName==="Plan_Product_Alias__c"){
					objColumn.label='Product';
					objColumn.typeAttributes.subtype='text';
					objColumn.subtype='text';
				}
			});
			//We build the tables.
			objParent.objConfiguration.objParameters.lstRecords = updatedRecords;
			objParent.objConfiguration.objParameters.lstColumns = objResult.lstColumns;
			if(!hasCSMPermission){
				this.objConfiguration.objParameters.boolHideCheckboxColumn = true;
			}
		
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	get showButtons() {
			
		return (hasCSMPermission);
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
		this.riskProductId = null;
		this.boolNewScreen = true;
		//Add New Button Logic
		if(objUtilities.isNull(this.boolNoModal) || this.boolNoModal===false){
			this.boolRiskProductCreateScreen = true;
		}
		if(this.boolNoModal===true){
			this.dispatchEvent(new CustomEvent('create'));
		}
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
		//Now we send the event.
        this.dispatchEvent(new CustomEvent('select', {
			detail: {
				selectedRows : objEvent.detail.selectedRows
			}
		}));
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
	@api
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
	 Method Name : addRecords
	 Description : editRecords method edit the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	editRecords() {
		let objParent = this;
		let lstRecords = new Array();
		//this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		this.objConfiguration.objParameters.lstSelectedRecords.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});
		
		if(lstRecords.length>1){
			//Now we display the success message.
			objUtilities.showToast(objParent.label.Error, "Please select only one record to edit", 'error', objParent);
		}else if(lstRecords.length>0){		
			objParent.riskProductId= lstRecords[0].Id
			objParent.boolNewScreen=false;
			objParent.boolRiskProductCreateScreen = true;			
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
		let objParent = this;
		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				objParent.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to cancel the table selection.
					case "1":
						objParent.handleCancel();
					break;
						//User wants to remove a record.
					case "3":
						objParent.removeRecords();
					break;
					//User wants to add a record.
					case "2":
						objParent.editRecords();
					break;
				}
			break;
			case 3:
				//First we prepare the data (inline editing).
				if(objUtilities.isNotNull(objPayload) && objPayload.length > 0) {
					objParent.boolDisplaySpinner = true;	
					//We save the inline changes.
					getRecordsUpdated({
						lstRecords: objPayload
					}).then(() => {	
						//Now we clean up the draft values.
						objParent.loadRecords();
					}).catch((objError) => {
						objUtilities.processException(objError, objParent);
						objParent.boolDisplaySpinner = false;
					});
				}
			break;
		}
    }

	

	/*
	 Method Name : navigateToRiskIssueRecord
	 Description : This method opens a record.
	 Parameters	 : String, called from navigateToRiskIssueRecord, strId Record Id.
	 			   String, called from navigateToRiskIssueRecord, strAction Action.
	 Return Type : None
	 */
	navigateToRiskIssueRecord(strId, strAction) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: strId,
                objectApiName: "Risk_Issue__c",
                actionName: strAction
            }
        });
    }

	handleClose(objEvent){
		this.boolRiskProductCreateScreen=false;
		this.refreshCard(objEvent);
	}
}