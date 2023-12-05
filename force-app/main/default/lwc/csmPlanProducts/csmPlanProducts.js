/*
 * Name			:	CsmPlanProducts
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/15/2021
 * Description	:	Manage Plan Products controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/15/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMPlanProductsController.getRecords";
import getRecordsDeleted from "@salesforce/apex/CSMPlanProductsController.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/CSMPlanProductsController.getRecordsRelated";
import getRecordsUpdated from "@salesforce/apex/CSMPlanProductsController.getRecordsUpdated";
import deleteInterlocks from "@salesforce/apex/CSMPlanProductsController.deleteInterlocks";
import getInterlockstoDelete from "@salesforce/apex/CSMPlanProductsController.getInterlockstoDelete";

//Schema imports.
import PLAN_ACCOUNT from "@salesforce/schema/Plan__c.Account__c";
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";

//Static resources.
import DetailsOn from '@salesforce/resourceUrl/DetailsOn';

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Plan_Products_Title from '@salesforce/label/c.Manage_Plan_Products_Title';
import Search_Plan_Products_Placeholder from '@salesforce/label/c.Search_Plan_Products_Placeholder';
import Assigned_Products_Tab from '@salesforce/label/c.Assigned_Products_Tab';
import Assigned_Products_Tab_Title from '@salesforce/label/c.Assigned_Products_Tab_Title';
import Unassigned_Products_Tab from '@salesforce/label/c.Unassigned_Products_Tab';
import Unassigned_Products_Tab_Title from '@salesforce/label/c.Unassigned_Products_Tab_Title';
import All_Assigned_Plan_Products_Tab from '@salesforce/label/c.All_Assigned_Plan_Products_Tab';
import All_Assigned_Plan_Products_Tab_Title from '@salesforce/label/c.All_Assigned_Plan_Products_Tab_Title';
import Search_Plan from '@salesforce/label/c.Search_Plan';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Update_Stage_Button from '@salesforce/label/c.Update_Stage_Button';
import Move_Button from '@salesforce/label/c.Move_Button';
import Show_All from '@salesforce/label/c.Show_All';
import Save_Button from '@salesforce/label/c.Save_Button';
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Plan_Products_Updated from '@salesforce/label/c.Plan_Products_Updated';
import Plan_Has_Risk_Product from '@salesforce/label/c.Plan_Has_Risk_Product';
import Cannot_Remove_All_Products from '@salesforce/label/c.Cannot_Remove_All_Products';
import Plan_Products_Removed from '@salesforce/label/c.Plan_Products_Removed';
import Plan_Products_Added from '@salesforce/label/c.Plan_Products_Added';
import Select_Stage from '@salesforce/label/c.Select_Stage';
import Select_Target_Plan from '@salesforce/label/c.Select_Target_Plan';

import hasCSMPermission from '@salesforce/customPermission/CSMUser';

const fields = [PLAN_ACCOUNT,IS_AUTOPILOT];

//Class body.
export default class CsmPlanProducts extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api strDefaultTab;

	//Feature specific API variables.
	@api fromcreatepage;
	@api fromeditpage;
	@api accountidpassed;
	@api plansobject;
	@api planrectypeid;
	@api PlanRecordId;

	planRecord;

	showAllAssignedCheckBox = false;
	@track isShowAllAssigned = false;

	//Track variables.
	@track boolCheckboxValue = true;

	//Wired items.
	//@wire(getRecord, { recordId: "$recordId", fields: [PLAN_ACCOUNT] }) objRecord;

	//Private variables.
	boolIsUpdateStage;
	boolIsMove;
	boolIsModalOpen;
	boolDisplaySpinner;
	//boolHasRiskProduct;
	intSizeOfListOfRecords;
	strAccountId;
	strModalTitle;
	strSelectedPlan;
	lstStatusNotIn;
	lstStageNotIn;

	@track showInterlockDeleteAlert = false;
	interlocksTodelete = [];
	planProductsToRemove = [];

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		Show_All,
		Success,
		Error,
		Plan_Products_Updated,
		Plan_Has_Risk_Product,
		Plan_Products_Removed,
		Cancel_Button,
		Save_Button,
		Search_Plan,
		Cannot_Remove_All_Products,
		Plan_Products_Added,
		Select_Stage,
		Select_Target_Plan
	}

	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:product_service_campaign_item",
		strCardTitle: Manage_Plan_Products_Title,
		strSearchPlaceholder: Search_Plan_Products_Placeholder,
		lstTabs: [
			{
				strLabel: Assigned_Products_Tab,
				strTitle: Assigned_Products_Tab_Title,
				strTabValue: "1",
				strTableClass: "assignedPlanProductsTable",
				objParameters: {
					boolEnableTreeView: true,
					strTableId: "1",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "5",
						strVariant: "Brand",
						strLabel: Update_Stage_Button,
						title: Update_Stage_Button,
						strStyleClasses: "slds-var-m-left_x-small slds-hide"
					},{
						strId: "2",
						strVariant: "Brand",
						strLabel: Remove_Button,
						title: Remove_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}, {
				boolDisplayShowAllCheckbox: true,
				strLabel: Unassigned_Products_Tab,
				strTitle: Unassigned_Products_Tab_Title,
				strTabValue: "2",
				strTableClass: "unassignedPlanProductsTable",
				objParameters: {
					strTableId: "2",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					},{
						strId: "5",
						strVariant: "Brand",
						strLabel: Update_Stage_Button,
						title: Update_Stage_Button,
						strStyleClasses: "slds-var-m-left_x-small slds-hide"
					},{
						strId: "4",
						strVariant: "Brand",
						strLabel: Add_Button,
						title: Add_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}, {
				strLabel: All_Assigned_Plan_Products_Tab,
				strTitle: All_Assigned_Plan_Products_Tab_Title,
				strTabValue: "3",
				strTableClass: "allAssignedPlanProductsTable",
				objParameters: {
					strTableId: "3",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "5",
						strVariant: "Brand",
						strLabel: Update_Stage_Button,
						title: Update_Stage_Button,
						strStyleClasses: "slds-var-m-left_x-small slds-hide"
					},{
						strId: "6",
						strVariant: "Brand",
						strLabel: Move_Button,
						title: Move_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}
		]
	}

	@wire(getRecord, { recordId: "$recordId", fields })
	planRecordDetails({data,error}){
			  if(data){
				  this.planRecord = data;
				  var isAutoPilot = data.fields.CSM_isAutoPilot__c.value;
				  if(isAutoPilot || !hasCSMPermission){
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
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		//We set the modal style to adapt to the content.
		let objStyle = document.createElement("style");
		objStyle.innerHTML = ".csmPlanProducts .slds-dropdown-trigger_click.slds-is-open .slds-dropdown, .csmPlanProducts .slds-dropdown-trigger--click.slds-is-open .slds-dropdown {";
		objStyle.innerHTML += "z-index: 999999999999999991 !important;";
		objStyle.innerHTML += "position: relative !important;";
		objStyle.innerHTML += "}";
		document.body.appendChild(objStyle);

		//Depending on the place where the component was invoked, we display specific tabs.
		if(this.fromcreatepage) {
			this.objConfiguration.lstTabs[2].objParameters.lstActionButtons[2].strLabel = Add_Button;
			this.objConfiguration.lstTabs[2].objParameters.lstActionButtons[2].title = Add_Button;
			this.objConfiguration.lstTabs.splice(0, 1);
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
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let strCurrentTab;
		let objParent = this;
		this.intSizeOfListOfRecords = 0;
		this.strAccountId = "";
		var showAllAssigned = false;

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

		//Here we define the specific values per tab.
		if(strCurrentTab === "2" || strCurrentTab === "3") {
			this.lstStatusNotIn = new Array(); 
			//this.lstStageNotIn = new Array();

			if(strCurrentTab === "2"){
				this.defaultArrayCheckboxStatus();
			}
			
			if(this.fromcreatepage) {
				this.strAccountId = this.accountidpassed;
			} else {
				this.strAccountId = getFieldValue(this.planRecord, PLAN_ACCOUNT);
			}
		}

		if(strCurrentTab === "1") {
			this.showAllAssignedCheckBox = true;
			showAllAssigned = this.isShowAllAssigned;			
		}

		//Now we fetch the data.
		getRecords({
			strPlanId: this.recordId,
			strAccountId: this.strAccountId,
			lstStatusNotIn: this.lstStatusNotIn,
			//lstStageNotIn: this.lstStageNotIn, //!!ALERT!! @Akhilesh 6 Jan 2022; this parameter is present in the CSMPlanProductsController.getRecords method 
			showAllAssigned : showAllAssigned
		}).then((objResult) => {

			//We build the tables.
			objParent.objConfiguration.lstTabs.forEach(objTab => {
				if(objTab.strTabValue === strCurrentTab) {
					if(strCurrentTab === "1") {
						objTab.objParameters.lstRecords = objResult.lstRecordsCustomStructure;
						objTab.objParameters.mapParentChildRelationship = objResult.mapParentChildRelationship;
						objTab.objParameters.lstColumns = new Array();

						//Now we adjust the final names in the columns.
						objResult.lstColumns.forEach(objColumn => {
							switch(objColumn.fieldName) {
								case "Forecast_Product__c":
									objColumn.fieldName = "strProductName";
									objColumn.label = "Product";
									objTab.objParameters.lstColumns.push(objColumn);

									//Now we add the View link.
									objTab.objParameters.lstColumns.push({
										label: "",
										fieldName: "lstIcons",
										strFieldName: "lstIcons",
										type: "custom",
										typeAttributes: {
											subtype: "icons"
										},
										initialWidth: 30
									});
								break;
								case "Contract__r.Id":
									objColumn.fieldName = "strContractId";
									if(objUtilities.isNull(objColumn.typeAttributes)) {
										objColumn.typeAttributes = new Object();
									}
									if(objUtilities.isNull(objColumn.typeAttributes.label)) {
										objColumn.typeAttributes.label = new Object();
									}
									objColumn.typeAttributes.label.fieldName = "strContract";
									objTab.objParameters.lstColumns.push(objColumn);
								break;
								case "Opportunity__r.Id":
									objColumn.fieldName = "strRenewalOpportunityId";
									if(objUtilities.isNull(objColumn.typeAttributes)) {
										objColumn.typeAttributes = new Object();
									}
									if(objUtilities.isNull(objColumn.typeAttributes.label)) {
										objColumn.typeAttributes.label = new Object();
									}
									objColumn.typeAttributes.label.fieldName = "strRenewalOpportunity";
									objTab.objParameters.lstColumns.push(objColumn);
								break;
								case "Delivery_Method__c":
									objColumn.fieldName = "strDeliveryMethod";
									objTab.objParameters.lstColumns.push(objColumn);
								break;
								case "Offering_Type__c":
									objColumn.fieldName = "strOfferingType";
									objTab.objParameters.lstColumns.push(objColumn);
								break;
								case "Status__c":
									objColumn.fieldName = "strStatus";
									objTab.objParameters.lstColumns.push(objColumn);
								break;
							/*	case "Has_Risk_Associated__c":
									objColumn.fieldName = "boolRisk";
									objColumn.subtype = "boolean";
									objColumn.type = "boolean";
									if(objUtilities.isNull(objColumn.typeAttributes)) {
										objColumn.typeAttributes = new Object();
									}
									objColumn.typeAttributes.subtype = "boolean";
									objTab.objParameters.lstColumns.push(objColumn);
								break; */
							}
						});
					} else {
						objTab.objParameters.lstRecords = objResult.lstRecords;
						objTab.objParameters.lstColumns = new Array();

						//We add the "Name" column to the records.
						objTab.objParameters.lstRecords.forEach(objRecord => {
							objRecord.lstIcons = [{
								boolIsStaticResource: true,
								intAction: 4,
								intWidth: 20,
								strURL: DetailsOn
							}];
						});
						
						//Now we adjust the final names in the columns.
						objResult.lstColumns.forEach(objColumn => {
							switch(objColumn.fieldName) {
								case "Forecast_Product__c":
									objColumn.label = "Product";
								break;
							}
							objTab.objParameters.lstColumns.push(objColumn);

							//Now we add the View link.
							switch(objColumn.fieldName) {
								case "Forecast_Product__c":
									objTab.objParameters.lstColumns.push({
										label: "",
										fieldName: "lstIcons",
										strFieldName: "lstIcons",
										type: "custom",
										typeAttributes: {
											subtype: "icons"
										},
										initialWidth: 10
									});
								break;
							}
						});
					}

					//We capture the total of records.
					objParent.intSizeOfListOfRecords = objResult.lstRecords.length;

					//Now we add inline editing for all the columns.
					objTab.objParameters.lstColumns.forEach(objColumn => {
						objColumn.editable = "false";
					});
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

		if(this.strDefaultTab === "1") {
			this.showAllAssignedCheckBox = true;
		}else{
			this.showAllAssignedCheckBox = false;
		}

		//If the tab is the Unassigned one, then we set the default value for the checkbox.
		if(this.strDefaultTab === "2") {
			this.defaultArrayCheckboxStatus(null);
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
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Related_Account_Plan__c",
                actionName: "new"
            },
            state : {
                nooverride: "1"
            }
        });
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
		let objParent = this;
		//this.boolHasRiskProduct = false;
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objTab.lstSelectedRecords = new Array();
				if(objUtilities.isNotNull(objEvent) && objUtilities.isNotNull(objEvent.detail) && objUtilities.isNotNull(objEvent.detail.selectedRows)) {
					objEvent.detail.selectedRows.forEach(strId => {
						objTab.objParameters.lstRecords.forEach(objExistingRecord => {
							if((typeof strId === "object" && strId.Id === objExistingRecord.Id) || (strId === objExistingRecord.Id)) {
								objTab.lstSelectedRecords.push(objExistingRecord);
							}
						});
					});
	
					//Now we iterate over the selected records to define the Risk products and total of Assigned records.
					//objTab.lstSelectedRecords.forEach(objRecord => {
					//	if(objRecord.Has_Risk_Associated__c || objRecord.boolRisk) {
					//	objParent.boolHasRiskProduct = true;
					//}
				//});
			}
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
	removeRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we check the status of the record.
		//if(this.boolHasRiskProduct) {

			//If closed, we show the error message.
		//	objUtilities.showToast(this.label.Error, this.label.Plan_Has_Risk_Product, "Error", this);
		//	this.boolDisplaySpinner = false;
		//} else {

			//Now we create the list of unique ids.
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
			
			//Now we confirm the user doesn't want to remove all the records.
			if(lstRecords.length === this.intSizeOfListOfRecords) {

				//If closed, we show the error message.
				objUtilities.showToast(this.label.Error, this.label.Cannot_Remove_All_Products, "Error", this);
				this.boolDisplaySpinner = false;
			} else {

				getInterlockstoDelete({removePlanProductsList:lstRecords})
				.then(result=>{
					if(result.length > 0){
						this.showInterlockDeleteAlert = true;
						this.interlocksTodelete = result;
						this.planProductsToRemove = lstRecords;
					}else{
						this.showInterlockDeleteAlert = false;

						//Now we send the record for deletion.
						getRecordsDeleted({
							lstRecords: lstRecords
						}).then(() => {

							//Now we display the success message.
							objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Removed, 'success', objParent);

							//We refresh the card.
							objParent.refreshCard();
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
						});

					}
					
				})
				.catch(objError=>{
					objUtilities.processException(objError, objParent);
				})				
			}
		//}
	}

	deleteInterlock(){
		let objParent = this;
		this.showInterlockDeleteAlert = false;		

		//Delete Interlocks
		deleteInterlocks({
			lstRecords: this.interlocksTodelete
		}).then(() => {	
			//We refresh the card.
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});

		//Remove Plan Products
		getRecordsDeleted({
			lstRecords: this.planProductsToRemove
		}).then(() => {

			//Now we display the success message.
			objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Removed, 'success', objParent);

			//We refresh the card.
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});

		
	}

	closeConfirmationScreen(){
		this.showInterlockDeleteAlert = false;
		this.boolDisplaySpinner = false;		
	}

	/*
	 Method Name : addRecords
	 Description : This method adds the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	addRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let objPlanObject = {};
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

		//Now we check the original call.
		if(this.fromcreatepage) {
				//Now we create the relationship.
				getRecordsRelated({
					strRecordId: this.PlanRecordId,
					lstRecords: lstRecords
				}).then(() => {

					//Now we display the success message.
					objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Added, 'success', objParent);

					//We refresh the card.
					objParent.refreshCard();

					var close = true;
					const closeclickedevt = new CustomEvent('closeclicked', {
						detail: { close },
					});
					//objParent.navigateToRecord(this.PlanRecordId, "view");
					// Fire the custom event to close the current tab
					//this.dispatchEvent(closeclickedevt);
					this.dispatchEvent(new CloseActionScreenEvent());  
					//Now we navigate the user to the record created.
					//objParent.navigateToRecord(this.PlanRecordId, "view");
					this.dispatchEvent(new CloseActionScreenEvent());  
					this.dispatchEvent(closeclickedevt);
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {
					//Finally, we hide the spinner.
					objParent.boolDisplaySpinner = false;
				});
			
		} else {
			getRecordsRelated({
				strRecordId: this.recordId,
				lstRecords: lstRecords
			}).then(() => {

				//Now we display the success message.
				objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Added, 'success', objParent);

				//We refresh the card.
				objParent.refreshCard();

				//We send the user to the created record.
				if(this.fromeditpage) {
					objParent.navigateToRecord(this.recordId, "view");
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        let { intAction, objPayload } = objEvent.detail;
		let strRecordId;
		let objParent = this;

		//If we are receiving subdetails.
		if(objUtilities.isNull(intAction) && objUtilities.isNull(objPayload) && objUtilities.isNotNull(objEvent.detail) && objUtilities.isNotNull(objEvent.detail.detail)) {
			intAction = objEvent.detail.detail.intAction;
			strRecordId = objEvent.detail.detail.strRecordId;
		}

		//Now, we check which event we need to execute.
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

					//User wants to update an stage.
					/**
					case "5":
						this.boolIsUpdateStage = true;
						this.strModalTitle = this.label.Select_Stage;
						this.openModal();
					break;
					**/
					//User wants to move the records.
					case "6":
						//if(this.boolHasRiskProduct) {
						//	objUtilities.showToast(this.label.Error, this.label.Plan_Has_Risk_Product, "Error", this);
						//} else {
						if(this.fromcreatepage) {
							this.addRecords();
						} else {
							this.boolIsMove = true;
							this.strModalTitle = this.label.Select_Target_Plan;
							this.openModal();
						}
						//}
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
			case 4:
				objParent.navigateToRecord(strRecordId, "view");
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

	/*
	 Method Name : navigateToRecord
	 Description : This method opens a record.
	 Parameters	 : String, called from navigateToRecord, strId Record Id.
	 			   String, called from navigateToRecord, strAction Action.
	 Return Type : None
	 */
	navigateToRecord(strId, strAction) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: strId,
                objectApiName: "Plan__c",
                actionName: strAction
            }
        });
    }

	/*
	 Method Name : showAll
	 Description : This method shows or hides all the records on the unassigned tab.
	 Parameters	 : Object, called from showAll, objEvent On click event.
	 Return Type : None
	 */
	showAll(objEvent) {
		//this.boolCheckboxValue = this.template.querySelector('.showAllCheckbox').checked;

		//We definethe default status.
        this.defaultArrayCheckboxStatus(objEvent);

		//Now we refresh the data.
		this.refreshCard();
    }
	showAllAssigned(){
		this.isShowAllAssigned = this.template.querySelector('.showAllAssignedCheckbox').checked;
		this.refreshCard();
		
	}
	

	/*
	 Method Name : defaultArrayCheckboxStatus
	 Description : This method defines the default status of the Show All checkbox arrays.
	 Parameters	 : Object, called from showAll, objEvent On click event.
	 Return Type : None
	 */
	defaultArrayCheckboxStatus(objEvent) {
		let objCheckbox;
		this.lstStatusNotIn = new Array();
		//this.lstStageNotIn = new Array();

		/**
		//If we didn't receive an event, we look for the checkbox.
		if(typeof objEvent === "undefined" || objEvent === null) {
			objCheckbox = this.template.querySelector('.showAllCheckbox');
			if(typeof objCheckbox !== "undefined" && objCheckbox !== null) {
				this.boolCheckboxValue = objCheckbox.checked;
			} else {
				this.boolCheckboxValue = true;
			}
			objEvent = {
				target: {
					checked: this.boolCheckboxValue
				}
			}
		}
		**/
		//We add the default Status.
		this.lstStatusNotIn.push("Expired");

		//If checked, we also include Stages.
        /**if(!objEvent.target.checked) {
			this.lstStageNotIn.push("Not Applicable");
		}*/
    }

	/*
	 Method Name : openModal
	 Description : This method opens the modal.
	 Parameters	 : None
	 Return Type : None
	 */
	openModal() {
		this.boolIsModalOpen = true;
	}

	/*
	 Method Name : closeModal
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeModal() {
		this.boolIsModalOpen = false;
		this.boolIsUpdateStage = false;
		this.boolIsMove = false;
		this.handlePlanRemoval();
	}

	/*
	 Method Name : updateStage
	 Description : This method updates the Stage of the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	updateStage() {
		let strStage = this.template.querySelector(".stageField").value;
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//Now we iterate over the selected records, and create the records to update.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id,
				Stage__c: strStage
			});
		});

		//First we close the modal.
		this.closeModal();

		//Now we update the records.
		getRecordsUpdated({
			lstRecords: lstRecords
		}).then(() => {

			//Now we display the success message.
			objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Updated, 'success', objParent);

			//Now we refresh the records.
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : moveRecords
	 Description : This method moves the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	moveRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;
		if(objUtilities.isNotBlank(this.strSelectedPlan)) {
	
			//Now we iterate over the selected records, and create the records to update.
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

			//First we close the modal.
			// this.closeModal(); //@Akhilesh 6 Jan 2022, move this line bottom inside finally block

			//Now we update the records.
			getRecordsRelated({ 
				strRecordId: this.strSelectedPlan, 
				lstRecords: lstRecords 
			}).then(() => {
				
				//Now we display the success message.
				objUtilities.showToast(objParent.label.Success, objParent.label.Plan_Products_Added, 'success', objParent);

				//Now we refresh the records.
				objParent.refreshCard();
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {

			//First we close the modal.
			this.closeModal();
			});
		}
	}

	/*
	 Method Name : handlePlanSelection
	 Description : This method receives the selected Plan record.
	 Parameters	 : Object, called from showAll, objEvent On Plan selection event.
	 Return Type : None
	 */
	handlePlanSelection(objEvent) {
		
		this.strSelectedPlan = objEvent.detail;
	}
  
	/*
	 Method Name : handlePlanRemoval
	 Description : This method removes the plan selection.
	 Parameters	 : None
	 Return Type : None
	 */
	handlePlanRemoval() {

		this.strSelectedPlan = null;
	}
}