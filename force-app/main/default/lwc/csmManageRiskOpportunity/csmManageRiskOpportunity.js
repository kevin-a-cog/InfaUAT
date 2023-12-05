/*
 * Name			:	CsmManageRiskOpportunity
 * Author		:	Karthi Gurusamy
 * Created Date	: 	22/09/2023
 * Description	:	This LWC exposes the Manage Risk related Opportunities functionality.

 Change History
 **********************************************************************************************************
 Modified By			    Date			Jira No.		    Description					Tag
 **********************************************************************************************************
 Karthi Gurusamy		22/09/2023		    AR-3444				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api ,wire} from 'lwc';
import { NavigationMixin } from "lightning/navigation";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CsmManageRiskOpportunity.getRecords";
import getRecordsDeleted from "@salesforce/apex/CsmManageRiskOpportunity.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/CsmManageRiskOpportunity.getRecordsRelated";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import Loading from '@salesforce/label/c.Loading';
import Assigned from '@salesforce/label/c.Assigned';
import Unassigned from '@salesforce/label/c.Unassigned';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import RISKPLAN from "@salesforce/schema/Risk_Issue__c.Plan__c";
import RISKID from "@salesforce/schema/Risk_Issue__c.Id";
import STATUS from "@salesforce/schema/Risk_Issue__c.Risk_Stage__c";
import PLANACCOUNT from "@salesforce/schema/Risk_Issue__c.Plan__r.Account__c";

import hasCSMPermission from '@salesforce/customPermission/CSMUser';

const fields = [RISKID, RISKPLAN,STATUS,PLANACCOUNT];

export default class CsmManageRiskOpportunity extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api strDefaultTab;
	@api boolDisplayActions;

	//Private variables.
	boolDisplaySpinner;
	riskRecord;

	//Labels.
	label = {
		Refresh_Button,
		Loading,
		Success,
		Error
	}
    

	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:opportunity",
		strCardTitle: 'Manage Risk Opportunities',
		strSearchPlaceholder: 'Search Risk Opportunities',
		lstTabs: [
			{
				strLabel: Assigned,
				strTitle: Assigned,
				strTabValue: "1",
				strTableClass: "assignedTable",
				strObjectName: "Risk_Product_Alias__c",
				objParameters: {
					strTableId: "1",
					lstActionButtons: [ {
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
			}, {
				strLabel: Unassigned,
				strTitle: Unassigned,
				strTabValue: "2",
				strTableClass: "unassignedTable",
				strObjectName: "Opportunity",
				objParameters: {
					strTableId: "2",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "4",
						strVariant: "Brand",
						strLabel: Add_Button,
						title: Add_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}
		]
	}

	objAdditionalColumns = [
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.StageName",
			"label": "Stage",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.StageName",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "picklist",
			"type": "custom",
			"typeAttributes": {
				"options": [
					{
						"label": "Identify",
						"value": "Identify"
					},
					{
						"label": "Validate",
						"value": "Validate"
					},
					{
						"label": "Qualified",
						"value": "Qualified"
					},
					{
						"label": "Final Negotiation",
						"value": "Final Negotiation"
					},
					{
						"label": "Closed Won",
						"value": "Closed Won"
					},
					{
						"label": "Closed Lost",
						"value": "Closed Lost"
					},
					{
						"label": "No Opportunity",
						"value": "No Opportunity"
					},
					{
						"label": "Duplicate",
						"value": "Duplicate"
					},
					{
						"label": "Renewal At-Risk",
						"value": "Renewal At-Risk"
					},
					{
						"label": "Initiated",
						"value": "Initiated"
					},
					{
						"label": "Working",
						"value": "Working"
					},
					{
						"label": "Committed",
						"value": "Committed"
					}
				],
				"subtype": "picklist"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.CloseDate",
			"label": "Close Date",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.CloseDate",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "date-local",
			"typeAttributes": {
				"day": "numeric",
				"month": "short",
				"options": [],
				"subtype": "text",
				"year": "numeric"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.Cloud_Churn_Forecast_Percent__c",
			"label": "Cloud Churn Forecast %",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.Cloud_Churn_Forecast_Percent__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "percent",
			"cellAttributes": { "alignment": "left" },
			"typeAttributes": {
				"maximumFractionDigits": 2,
				"minimumIntegerDigits": 1,
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.Cloud_Churn_Forecast__c",
			"label": "Cloud Churn Forecast Amount",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.Cloud_Churn_Forecast__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "text",
			"typeAttributes": {
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.Cloud_Swing_Forecast_Percent__c",
			"label": "Cloud Swing Forecast %",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.Cloud_Swing_Forecast_Percent__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "percent",
			"cellAttributes": { "alignment": "left" },
			"typeAttributes": {
				"maximumFractionDigits": 2,
				"minimumIntegerDigits": 1,
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.Cloud_Swing_Forecast__c",
			"label": "Cloud Swing Forecast Amount",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.Cloud_Swing_Forecast__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "text",
			"typeAttributes": {
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.On_Prem_Churn_Forecast_Percent__c",
			"label": "On-Prem Churn Forecast %",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.On_Prem_Churn_Forecast_Percent__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "percent",
			"cellAttributes": { "alignment": "left" },
			"typeAttributes": {
				"maximumFractionDigits": 2,
				"minimumIntegerDigits": 1,
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.On_Premise_Churn_Forecast__c",
			"label": "On-Premise Churn Forecast Amount",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.On_Premise_Churn_Forecast__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "text",
			"typeAttributes": {
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.On_Prem_Swing_Forecast_Percent__c",
			"label": "On-Prem Swing Forecast %",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.On_Prem_Swing_Forecast_Percent__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "percent",
			"cellAttributes": { "alignment": "left" },
			"typeAttributes": {
				"maximumFractionDigits": 2,
				"minimumIntegerDigits": 1,
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.On_Premise_Swing_Forecast__c",
			"label": "On-Premise Swing Forecast  Amount",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.On_Premise_Swing_Forecast__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "text",
			"typeAttributes": {
				"options": [],
				"subtype": "text"
			}
		},
		{
			"boolIsFormula": false,
			"fieldName": "Opportunity__r.CSM_Comments__c",
			"label": "Churn Forecast Comments",
			"objType": {},
			"sortable": "true",
			"strFieldName": "Opportunity__r.CSM_Comments__c",
			"strParentObject": "Risk_Product_Alias__c",
			"subtype": "text",
			"type": "text",
			"typeAttributes": {
				"options": [],
				"subtype": "text"
			}
		}];

	@wire(getRecord, { recordId: "$recordId", fields })
	riskRecordDetails({data,error}){
			  if(data){
				  this.riskRecord = data;
				  var status = data.fields.Risk_Stage__c.value;
				  if(!hasCSMPermission || status ==='Unresolved' || status ==='Resolved'){
					  this.objConfiguration.lstTabs.forEach(tab =>{
						  tab.objParameters.boolHideCheckboxColumn = true;
					  })
				  }else{
					this.objConfiguration.lstTabs.forEach(tab =>{
						tab.objParameters.boolHideCheckboxColumn = false;
					})
				  }
			  }
	  }

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.boolDisplaySpinner = true;
		if(objUtilities.isNull(this.boolDisplayActions)) {
			this.objConfiguration.lstTabs.forEach(tab =>{
				tab.objParameters.boolDisplayActions = true;
			});
		}else{
			this.objConfiguration.lstTabs.forEach(tab =>{
				tab.objParameters.boolDisplayActions = this.boolDisplayActions;
			});
		}
		//First we load the list of records.
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
		let boolGetAssingedRecords = true;
		let strCurrentTab;
		let objParent = this;

		//First we prepare the boolean values.
		try {
			strCurrentTab = this.getCurrentTab();
		} catch(objException) {
			if(objUtilities.isNotNull(this.strDefaultTab)) {
				strCurrentTab = "" + this.strDefaultTab;
			}
			if(objUtilities.isBlank(strCurrentTab)) {
				this.objConfiguration.lstTabs.forEach(objTab => {
					if(objUtilities.isBlank(strCurrentTab)) {
						strCurrentTab = objTab.strTabValue;
					}
				});
			}
		}

		//Now we fetch the data.
		if(strCurrentTab !== "1") {
			boolGetAssingedRecords = false;
		}
		getRecords({
			strRiskId: this.recordId,
			boolGetAssingedRecords: boolGetAssingedRecords,
			planAcc: getFieldValue(this.riskRecord, PLANACCOUNT)
		}).then((objResult) => {

			//We build the tables.
			objParent.objConfiguration.lstTabs.forEach(objTab => {
				if(objTab.strTabValue === strCurrentTab) {
					var updatedRecords=[];
					if(strCurrentTab == "1") {
						//Logic to build to append the parent fields like contact phone for Assigned record						
						if(objUtilities.isNotNull(objResult.lstRecords)){
							objResult.lstRecords.forEach(record => {
								//Restructered the Json to fetch related phone and Name fields
								record.Opportunity__r.Cloud_Churn_Forecast_Percent__c = record.Opportunity__r?.Cloud_Churn_Forecast_Percent__c/100;
								record.Opportunity__r.Cloud_Swing_Forecast_Percent__c = record.Opportunity__r?.Cloud_Swing_Forecast_Percent__c/100;
								record.Opportunity__r.On_Prem_Churn_Forecast_Percent__c = record.Opportunity__r?.On_Prem_Churn_Forecast_Percent__c/100;
								record.Opportunity__r.On_Prem_Swing_Forecast_Percent__c  = record.Opportunity__r?.On_Prem_Swing_Forecast_Percent__c/100;
								
								let preparedContactRecord = record;
								updatedRecords.push(preparedContactRecord);
							});
						}
					}else{
						//updatedRecords = objResult.lstRecords;
						//Logic to build to append the parent fields like contact phone for Assigned record						
						if(objUtilities.isNotNull(objResult.lstRecords)){
							objResult.lstRecords.forEach(record => {
								//Restructered the Json to fetch related phone and Name fields
								record.Cloud_Churn_Forecast_Percent__c = record.Cloud_Churn_Forecast_Percent__c/100;
								record.Cloud_Swing_Forecast_Percent__c = record.Cloud_Swing_Forecast_Percent__c/100;
								record.On_Prem_Churn_Forecast_Percent__c = record.On_Prem_Churn_Forecast_Percent__c/100;
								record.On_Prem_Swing_Forecast_Percent__c  = record.On_Prem_Swing_Forecast_Percent__c/100;
								
								let preparedContactRecord = record;								
								updatedRecords.push(preparedContactRecord);
							});
						}				
					}
					objTab.objParameters.lstRecords = updatedRecords ;
					objTab.objParameters.lstColumns = objResult.lstColumns;
					if(boolGetAssingedRecords){
						objTab.objParameters.lstColumns.forEach(colmn =>{
							if(colmn.fieldName=='Opportunity__r.Id'){
								colmn.wrapText = true;
							}
						});
						objTab.objParameters.lstColumns.push(...this.objAdditionalColumns);
					}
					else{
						objTab.objParameters.lstColumns.forEach(colmn =>{
							if(colmn.fieldName=='Name'){
								colmn.wrapText = true;
							}
							if(colmn.type=='percent'){
								colmn.cellAttributes = { "alignment" : "left" };
							}
						});
					}
					
				}
			});
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
		if(!this.boolDisplayActions){
			this.dispatchEvent(new CustomEvent('hidebuttons'));
		}
		this.loadRecords();
		return false;
	}

    
	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objParent.template.querySelector('.' + objTab.strTableClass).searchRecord(objEvent);
			}
		});
	}

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
    selectRecords(objEvent) {
		let strCurrentTab = this.getCurrentTab();
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objTab.lstSelectedRecords = objEvent.detail.selectedRows;
				this.dispatchEvent(new CustomEvent('select', {
					detail: {
						selectedRows : objEvent.detail.selectedRows,
						tab: strCurrentTab
					}
				}));
			}
		});
    }

	/*
	 Method Name : handleCancel
	 Description : This method removes the Action panels from the UI.
	 Parameters	 : None
	 Return Type : None
	 */
    handleCancel() {
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objParent.template.querySelector('.' + objTab.strTableClass).hideActions();
			}
		});
    }

	/*
	 Method Name : removeRecords
	 Description : This method deletes the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
    removeRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		let objSource;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});

		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : addRecords
	 Description : This method adds the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	addRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});

		//Now we send the record for deletion.
		getRecordsRelated({
			strRecordId: this.recordId,
			lstRecords: lstRecords
		}).then(() => {
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
		console.log('Execute');
        const { intAction, objPayload } = objEvent.detail;
		let strCurrentTab;
		let objParent = this;

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

					//User wants to add a record.
					case "4":
						this.addRecords();
					break;
					
				}
			break;
			case 3:
				

				//First we prepare the boolean values.
				try {
					strCurrentTab = this.getCurrentTab();
				} catch(objException) {
					if(objUtilities.isNotNull(this.strDefaultTab)) {
						strCurrentTab = "" + this.strDefaultTab;
					}
					if(objUtilities.isBlank(strCurrentTab)) {
						this.objConfiguration.lstTabs.forEach(objTab => {
							if(objUtilities.isBlank(strCurrentTab)) {
								strCurrentTab = objTab.strTabValue;
							}
						});
					}
				}			
				
			break;
		}
    }


	/*
	 Method Name : getCurrentTab
	 Description : This method returns the value of the current tab.
	 Parameters	 : None
	 Return Type : String
	 */
	getCurrentTab() {
		return this.template.querySelector('lightning-tabset').activeTabValue;
	}

}