/*
 * Name			:	CsmObjectivesAndMilestonesViewer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/6/2021
 * Description	:	Objectives and Milestones Viewer controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/6/2021		N/A				Initial version.					N/A
 Deva M					26/11/2021		AR-1740			Initial version.					N/A
 Deva M					30/11/2021		N/A			    add a button to sign off
 														objectives							N/A
 Karthi 				27/07/2022		AR-2150			Added Expand All/Collapse All		T1
 */

//Core imports.
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { getFieldValue, getRecord } from "lightning/uiRecordApi";

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMObjectivesAndMilestonesController.getRecords";
import isInternalUser from "@salesforce/apex/CSMObjectivesAndMilestonesController.isInternalUser";
import isCSMSuccessCommunity from "@salesforce/apex/CSMObjectivesAndMilestonesController.isCSMSuccessCommunity";

//Custom Labels.
import New_Objective from '@salesforce/label/c.New_Objective';
import Engagement_Task_Header_Name from '@salesforce/label/c.Engagement_Task_Header_Name';
import Engagement_Task_Header_Created_Date from '@salesforce/label/c.Engagement_Task_Header_Created_Date';
import Engagement_Task_Header_Last_Modified_Date from '@salesforce/label/c.Engagement_Task_Header_Last_Modified_Date';
import Engagement_Task_Header_Status from '@salesforce/label/c.Engagement_Task_Header_Status';
import Engagement_Task_Header_Due_Date from '@salesforce/label/c.Engagement_Task_Header_Due_Date';
import Engagement_Task_Header_Type from '@salesforce/label/c.Engagement_Task_Header_Type';

//import custom permissions
import hasCSMPermission from "@salesforce/customPermission/CSMUser";
import hasExternalPermission from "@salesforce/customPermission/CSM_Success_External";
//fields
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";
import STAGE from "@salesforce/schema/Plan__c.Stage__c";
const fields = [IS_AUTOPILOT, STATUS, STAGE];
import AEMEngagementCatalogURL from '@salesforce/label/c.AEMEngagementCatalogURL';

//Class body.
export default class CsmObjectivesAndMilestonesViewer extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api boolHideActions;
	@api strPreSelectedObjective;
	@api strPreSelectedMilestone;

	//Private variables.
	boolDisplaySpinner;
	boolDisplayAddObjective;
	boolDisplayEditObjective;
	boolDisplayDeleteObjective;
	boolDisplayApplyTemplate;
	boolDisplayAddMilestone;
	boolDisplayManageObjectives;
	boolDisplayEditMilestone;
	boolDisplayDeleteMilestone;
	boolDisplayManageMilestone;
	boolDisplayCreateRisk;
	boolDisplayCreateTask;
	boolDisplayCreateEngagement;
	//boolDisplayNewButton = false;
	boolDisplayObjectiveSignoff;
	boolIsInternalUser = true;
	boolIsCSMCommunity = false;
	strSelectedRecord;	
	boolRecordLocked=false;
	boolExpandAll=false;
	//Labels.
	label = {
		New_Objective
	}
	get boolDisplayNewButton(){
		let boolShowNewObjectiveButton = false;
		const isAutoPilot = getFieldValue(this.planRecordDetails.data,IS_AUTOPILOT);
		const isComplete = getFieldValue(this.planRecordDetails.data,STATUS)=='Complete';
		if((hasCSMPermission || hasExternalPermission) && !isAutoPilot && !this.boolRecordLocked && !isComplete){
			boolShowNewObjectiveButton=true;
		}
		return boolShowNewObjectiveButton;
	}
	//Feature Configuration.
	objParameters = {
		boolEnableTreeView: true,
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolEnablePopOver: false,
		boolHideCheckboxColumn: true,
		strTableId: "2",
		strTableClass: "objectivesAndMilestonesTable2",
		lstColumnsSpecificConfigurations: {
			1: [
				{
					fieldName: "strBusinessGoal",
					label: "Business Goal",
					strFieldName: "strBusinessGoal",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strBusinessGoal"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strTechnicalGoal",
					label: "Technical Goal",
					strFieldName: "strTechnicalGoal",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strTechnicalGoal"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strCreated",
					label: "Created By",
					strFieldName: "strCreated",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strCreated"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strLastUpdated",
					label: "Last Modified By",
					strFieldName: "strLastUpdated",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strLastUpdated"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strSignedOff",
					label: "Signed off",
					strFieldName: "strSignedOff",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strSignedOff"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strTargetKPI",
					label: "Target KPI",
					strFieldName: "strTargetKPI",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strTargetKPI"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strActualKPI",
					label: "Actual KPI",
					strFieldName: "strActualKPI",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strActualKPI"
						},
						subtype: "text"
					}
				}
			],
			2: [
				{
					fieldName: "strDescription",
					label: "Description",
					strFieldName: "strDescription",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strDescription"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strCreated",
					label: "Created By",
					strFieldName: "strCreated",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strCreated"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strLastUpdated",
					label: "Last Modified By",
					strFieldName: "strLastUpdated",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strLastUpdated"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "strActualCompletionDate",
					label: "Actual Completion date",
					strFieldName: "strActualCompletionDate",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "strActualCompletionDate"
						},
						subtype: "text"
					}
				}
			]
		},
		lstColumns: [
			{
				fieldName: "strName",
				label: "Name",
				fixedWidth: 240,
				strFieldName: "strName",
				type: "custom",
				typeAttributes: {
					boolisname: true,
					label: {
						fieldName: "strName"
					},
					subtype: "html"
				}
			},
			{
				fieldName: "strPlannedCompletionDate",
				label: "Planned Completion Date",
				strFieldName: "strPlannedCompletionDate",
				subtype: "text",
				type: "text",
				typeAttributes: {
					label: {
						fieldName: "strPlannedCompletionDate"
					},
					subtype: "text"
				}
			},
			{
				label: "Products",
				fieldName: "lstProducts",
				strFieldName: "lstProducts",
				type: "custom",
				typeAttributes: {
					subtype: "badges"
				},
				objAdditionalAttributes: {
					intListLimit: 2
				}
			},
			{
				label: "Status",
				fieldName: "objStatus",
				strFieldName: "objStatus",
				type: "custom",
				typeAttributes: {
					subtype: "badges"
				}
			},
			{
				label: "",
				fieldName: "lstIcons",
				strFieldName: "lstIcons",
				type: "custom",
				typeAttributes: {
					subtype: "icons"
				},
				strStyle: "width: 100px;"
			}
		],
		lstCustomCSS: [
			{
				strSelector: "lightning-button-menu lightning-primitive-icon:last-of-type",
				strCSS: "display: none;"
			},
			{
				strSelector: "lightning-button-menu button.slds-button",
				strCSS: "border-width: 0px; background-color: transparent;"
			}
		]
	};
	objChildTableParameters = {
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolEnablePopOver: false,
		boolHideCheckboxColumn: true,
		strSortDirection: "desc",
		strSortedBy: "LastModifiedDateFull",
		lstColumns: [
			{
				fieldName: "Name",
				label: Engagement_Task_Header_Name,
				fixedWidth: 270,
				strFieldName: "Name",
				type: "custom",
				wrapText: true,
				typeAttributes: {
					boolisname: true,
					label: {
						fieldName: "Name"
					},
					subtype: "link"
				}
			},
			{
				fieldName: "CreatedDate",
				label: Engagement_Task_Header_Created_Date,
				fixedWidth: 130,
				strFieldName: "CreatedDate",
				subtype: "text",
				type: "text",
				wrapText: true,
				typeAttributes: {
					label: {
						fieldName: "CreatedDate"
					},
					subtype: "text"
				}
			},
			{
				fieldName: "LastModifiedDate",
				label: Engagement_Task_Header_Last_Modified_Date,
				fixedWidth: 170,
				strFieldName: "LastModifiedDate",
				subtype: "text",
				type: "text",
				wrapText: true,
				typeAttributes: {
					label: {
						fieldName: "LastModifiedDate"
					},
					subtype: "text"
				}
			},
			{
				fieldName: "Status",
				label: Engagement_Task_Header_Status,
				fixedWidth: 180,
				strFieldName: "Status",
				subtype: "text",
				type: "text",
				wrapText: true,
				typeAttributes: {
					label: {
						fieldName: "Status"
					},
					subtype: "text"
				}
			},
			{
				fieldName: "DueDate",
				label: Engagement_Task_Header_Due_Date,
				fixedWidth: 100,
				strFieldName: "DueDate",
				subtype: "text",
				type: "text",
				wrapText: true,
				typeAttributes: {
					label: {
						fieldName: "DueDate"
					},
					subtype: "text"
				}
			},
			{
				fieldName: "Type",
				label: Engagement_Task_Header_Type,
				fixedWidth: 100,
				strFieldName: "Type",
				subtype: "text",
				type: "text",
				wrapText: true,
				typeAttributes: {
					label: {
						fieldName: "Type"
					},
					subtype: "text"
				}
			}
		]
	};
	
	@wire(getRecord, { recordId: "$recordId", fields })
	planRecordDetails;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		console.log('obj');
		let objParent = this;
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		//First we check if we need to display the actions or not.
		if(objUtilities.isNull(objParent.boolHideActions) || objUtilities.isBlank(objParent.boolHideActions) || objParent.boolHideActions.toLowerCase() === "false" || !objParent.boolHideActions) {
			objParent.objParameters.lstColumns.push({
				label: "Actions",
				fieldName: "lstActions",
				strFieldName: "lstActions",
				type: "custom",
				typeAttributes: {
					subtype: "icons"
				}
			});
		}

		//We check if the user is internal or not.
		isInternalUser().then(boolIsInternalUser => {
			objParent.boolIsInternalUser = boolIsInternalUser;
		});
		isCSMSuccessCommunity().then(boolIsCSMCommunity => {
			objParent.boolIsCSMCommunity = boolIsCSMCommunity;
			objParent.objParameters.lstColumns[2].objAdditionalAttributes.intListLimit=10;
		});

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
			
			//We prepare the data table.
			objParent.objParameters.lstRecords = objResult.lstRecordsCustomStructure;
			objParent.objParameters.mapParentChildRelationship = objResult.mapParentChildRelationship;
			objParent.boolRecordLocked=objResult.boolRecordLocked;

			//Now we check if we need to provide child table parameters for Milestones.
			if(objUtilities.isNotNull(objParent.objParameters.lstRecords)) {
				objParent.objParameters.lstRecords.forEach(objRecord => {
					if(objUtilities.isNotNull(objRecord.objAdditionalInformation) && objRecord.objAdditionalInformation.boolHasChildTable) {
						objRecord.objAdditionalInformation.objChildTable = {
							...objParent.objChildTableParameters,
							lstRecords: objRecord.objAdditionalInformation.lstChildRecordsCustomStructure
						}
					}
				});
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : badgeColor
	 Description : This method returns the corresponding Badge class given a value.
	 Parameters	 : String, called from badgeColor, strValue Badge value.
	 Return Type : String
	 */
	badgeColor(strValue) {
		let strStyle;
		switch(strValue) {
			case "Draft":
				strStyle = "background-color: #DFFF00";
			break;
			case "Yet to Start":
				strStyle = "background-color: #9FE2BF";
			break;
			case "In Progress":
				strStyle = "background-color: #40E0D0";
			break;
			case "Delayed":
				strStyle = "background-color: #FFBF00";
			break;
			case "On-hold":
				strStyle = "background-color: #FF7F50";
			break;
			case "Complete":
				strStyle = "background-color: #2ECC71";
			break;
			case "Canceled":
				strStyle = "background-color: #DE3163";
			break;
		}
		return strStyle;
	}

	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from refreshCard, objEvent click event.
	 Return Type : None
	 */
	refreshCard(objEvent) {
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}

		//We refresh the Assigned table.
		this.boolDisplaySpinner = true;
		this.loadRecords();
		return false;
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
		try {
		let { intAction, strRecordId, objAdditionalAttributes } = objEvent.detail.detail;

		//First, we check which event we need to execute.
		this.strSelectedRecord = strRecordId;
		this.strPreSelectedObjective = "";
		this.strPreSelectedMilestone = "";
		switch(parseInt(intAction)) {
			case 1:

				//The user wants to open/close the details section of the selected row.
				this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
					objTable.getAdditionalInformationExpandedCollapsed(objAdditionalAttributes);
				});
			break;
			case 2:
				
				//The user wants to open the Edit Objective modal.
				this.boolDisplayEditObjective = true;
			break;
			case 3:
				
				//The user wants to open the Delete Objective modal.
				this.boolDisplayDeleteObjective = true;
			break;
			case 4:
				
				//The user wants to open the Apply Template modal.
				this.boolDisplayApplyTemplate = true;
				if(objUtilities.isNotNull(objAdditionalAttributes) && objUtilities.isNotBlank(objAdditionalAttributes.strParentId)) {
					this.strPreSelectedObjective = objAdditionalAttributes.strParentId;
					this.strPreSelectedMilestone = strRecordId;
				} else {
					this.strPreSelectedObjective = strRecordId;
				}
			break;
			case 5:
				
				//The user wants to open the Add Milestone modal.
				this.boolDisplayAddMilestone = true;
			break;
			case 6:
				
				//The user wants to open the Manage Objective Products modal.
				this.boolDisplayManageObjectives = true;
			break;
			case 7:
				
				//The user wants to open the Edit Milestone modal.
				this.boolDisplayEditMilestone = true;
			break;
			case 8:
				
				//The user wants to open the Delete Milestone modal.
				this.boolDisplayDeleteMilestone = true;
			break;
			case 9:
				
				//The user wants to open the Manage Milestone Products modal.
				this.boolDisplayManageMilestone = true;
			break;
			case 10:
				
				//The user wants to open the Create Risk modal.
				this[NavigationMixin.Navigate]({
					type: 'standard__objectPage',
					attributes: {
						objectApiName: 'Risk_Issue__c'	,
						actionName: 'new'
					}
				});
				this.strSelectedRecord = null;
			break;
			case 11:
				
				//The user wants to open the Create Task modal.
				this[NavigationMixin.Navigate]({
					type: 'standard__objectPage',
					attributes: {
						objectApiName: 'Task',
						actionName: 'new'
					},
					state: {
						defaultFieldValues: encodeDefaultFieldValues({
							WhatId: this.strSelectedRecord
						})
					}
				});
				this.strSelectedRecord = null;
			break;
			case 12:
				
				//The user wants to open the Create Engagement modal.
				this.boolDisplayCreateEngagement = true;
			break;
			case 13:
				let stageval=getFieldValue(this.planRecordDetails.data,STAGE);	
				let stage = stageval==='Implement'?'Implement,Design':stageval;
				let urlforNavigate = AEMEngagementCatalogURL +'/?planId='+this.recordId+'&milestoneId='+this.strSelectedRecord+'#f:engagementadoptionstage=['+stage+']'; 
				this[NavigationMixin.Navigate]({
					type: 'standard__webPage',
						attributes: {
							url: urlforNavigate
						}
					},
					true // Replaces the current page in your browser history with the URL
				);
			break;
		}
		} catch(objException){}
    }

	/*
	 Method Name : closeModal
	 Description : This method closes the current modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeModal(objEvent) {
		this.boolDisplayAddObjective = false;
		this.boolDisplayEditObjective = false;
		this.boolDisplayDeleteObjective = false;
		this.boolDisplayApplyTemplate = false;
		this.boolDisplayAddMilestone = false;
		this.boolDisplayManageObjectives = false;
		this.boolDisplayEditMilestone = false;
		this.boolDisplayDeleteMilestone = false;
		this.boolDisplayManageMilestone = false;
		this.boolDisplayCreateRisk = false;
		this.boolDisplayCreateTask = false;
		this.boolDisplayCreateEngagement = false;
		this.boolDisplayObjectiveSignoff = false;
		this.strSelectedRecord = null;
		this.refreshCard(objEvent);
    }

	/*
	 Method Name : displayAddObjective
	 Description : This method displays the Add Objective modal.
	 Parameters	 : None
	 Return Type : None
	 */
	displayAddObjective() {
		this.boolDisplayAddObjective = true;
    }

	/*
	 Method Name : displayObjectiveSignoff
	 Description : This method displays the Objective sign off modal.
	 Parameters	 : None
	 Return Type : None
	 */
	displayObjectiveSignoff() {
		this.boolDisplayObjectiveSignoff = true;
    }

	/*
	 Method Name : handletoggleCollapse
	 Description : This method Expands All/Collapses All the child rows and detail records.
	 Parameters	 : None
	 Return Type : None
	 */
	//T1
	handletoggleCollapse(){
		if(this.boolExpandAll){
			this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
				objTable.getAllRowsExpandedCollapsed(false);
			});
			this.boolExpandAll=false;
		}
		else{
			this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
				objTable.getAllRowsExpandedCollapsed(true);
			});
			this.boolExpandAll=true;
		}
	}
}