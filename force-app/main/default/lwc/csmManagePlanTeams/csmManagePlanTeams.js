/*
 * Name			    :	planTeamManagement
 * Author		    :	Deva M
 * Created Date	: 05/07/2021
 * Description	:	Plan Team Management controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		        05/07/2021		N/A				  Initial version.			N/A
 */


//Core imports.
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
//Apex Controllers.
import getUnassignedRecords from "@salesforce/apex/CSMManagePlanTeamController.getUnassignedRecords";
import getAssignedRecords from "@salesforce/apex/CSMManagePlanTeamController.getAssignedRecords";
import getRecordsDeleted from "@salesforce/apex/CSMManagePlanTeamController.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/CSMManagePlanTeamController.getRecordsRelated";
import getRecordsUpdated from "@salesforce/apex/CSMManagePlanTeamController.getRecordsUpdated";//

import updatePlanteamData from "@salesforce/apex/csmMsTeamsServiceController.updatePlanteamData";
import doCalloutCreateGroupChat from "@salesforce/apex/csmMsTeamsServiceController.doCallout_CreateGroupChat";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import CSM_Manage_Plan_Team_Title from '@salesforce/label/c.CSM_Manage_Plan_Team_Title';
import CSM_Plan_Team_Search_Placeholder from '@salesforce/label/c.CSM_Plan_Team_Search_Placeholder';
import Assigned from '@salesforce/label/c.Assigned';
import Unassigned from '@salesforce/label/c.Unassigned';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Error from '@salesforce/label/c.Error';
import Plan_Team_Error_Message from '@salesforce/label/c.CSM_PlanTeam_Delete_Error_Message';


//Using uirecord api to wire plan record
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCOUNTID from "@salesforce/schema/Plan__c.Account__c";
import PLANID from "@salesforce/schema/Plan__c.Id";
import PLAN_NAME from "@salesforce/schema/Plan__c.Name";
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";

import hasCSMPermission from '@salesforce/customPermission/CSMUser';

const fields = [PLANID, ACCOUNTID,PLAN_NAME,IS_AUTOPILOT,STATUS];
//Class body.
export default class CsmManagePlanTeams extends NavigationMixin(LightningElement) {
  //API variables.
  @api recordId;
  @api isPoppedOut=false;
  @api strDefaultTab;

  @api hideButtons=false;
  selectedRecords =[];
  preselectedRows=[];

  //Private variables.
  boolDisplaySpinner;
  planRecord;

  //Labels.
  label = {
    Refresh_Button,
    New_Button,
    Loading,
	Error,
	Plan_Team_Error_Message
  }
  
  //Feature Configuration.
@track objConfiguration = {
		strIconName: "standard:team_member",
		strCardTitle: CSM_Manage_Plan_Team_Title,
		strSearchPlaceholder: CSM_Plan_Team_Search_Placeholder,
		lstTabs: [
			{
				strLabel: Assigned,
				strTitle: Assigned,
				strTabValue: "1",
				strTableClass: "assignedTable",
				strObjectName: "Plan_Team__c",				
				objParameters: {
					strTableId: "1",					
					strKeyField : "Id",					
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
					},
					{
						strId: "3",
						strVariant: "Brand",
						strLabel: 'Create Group Chat',
						title: 'CreateGroupChat',
						strStyleClasses: "slds-var-m-left_x-small slds-hide"
					}
				]
				}
			}, {
				strLabel: Unassigned,
				strTitle: Unassigned,
				strTabValue: "2",
				strTableClass: "unassignedTable",
				strObjectName: "Plan_Team__c",
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

	@wire(getRecord, { recordId: "$recordId", fields })
	planRecordDetails({data,error}){
			  if(data){
				  this.planRecord = data;
				  var isAutoPilot = data.fields.CSM_isAutoPilot__c.value;
				  var status = data.fields.Status__c.value;
				  if(isAutoPilot || !hasCSMPermission || status==='Complete'){
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
  
	  get showButtons() {
		  var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);	
		  const isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';		
		  return (hasCSMPermission && !isAutopilot && !this.hideButtons  && !isComplete);
	  }
  /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;	
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		if(this.hideButtons === true){
			this.objConfiguration.strCardTitle ='Add Plan Team Members to Group Chat';
			this.objConfiguration.lstTabs.splice(1, 1); //Remove Unassigned Tab (if created from iCollab Quick Action)
			this.objConfiguration.lstTabs.forEach(objTab =>{
				if(objTab.strTabValue === "1"){
					objTab.strLabel = 'Assigned Plan Team Members';
					objTab.objParameters.lstActionButtons.splice(0, 2); //Remove the extra Buttons (if created from iCollab Quick Action)
				}				
			})
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
		if(boolGetAssingedRecords === true){
			getAssignedRecords({
				strPlanId: this.recordId,
				  strplanAccountId:getFieldValue(this.planRecord, ACCOUNTID)
			}).then((objResult) => {
	
				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {
						
						objTab.objParameters.lstPreSelectedRows = new Array();

						var updatedRecords=objResult.lstRecords;
						if(objUtilities.isNotNull(updatedRecords)){
							updatedRecords.forEach(record => {
								record.Name=objUtilities.isNotBlank(record.Full_Name__c) ? record.Full_Name__c : record.Name;
								if(record.icollabTeam__c === true && this.hideButtons === true){
									objTab.objParameters.lstPreSelectedRows.push(record.Id);
								}
							});
						}
						objTab.objParameters.lstRecords = updatedRecords;						
						objTab.objParameters.lstColumns = objResult.lstColumns;						
						
						if(strCurrentTab == "1") {
							//Now we add inline editing for all the columns.
							objTab.objParameters.lstColumns.forEach(objColumn => {
								if(objColumn.strFieldName==="Role__c" || objColumn.strFieldName==="Primary__c"){
									//objColumn.editable = "true";
									var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);									
		  							var isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';		
									objColumn.editable = (!hasCSMPermission || isAutopilot || isComplete)?"false":"true";
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
		}else{
			getUnassignedRecords({
				strPlanId: this.recordId,
				strplanAccountId:getFieldValue(this.planRecord, ACCOUNTID)
			}).then((objResult) => {
	
				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {
						objTab.objParameters.lstRecords = objResult.lstRecords;
						objTab.objParameters.lstColumns = objResult.lstColumns;
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;
				
			});
		}		
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
		let strCurrentTab = this.getCurrentTab();
		let strObjectName;
		let objParent = this;

		//First we define on which tab we are.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue != undefined && objTab.strTabValue === strCurrentTab) {
				strObjectName = objTab.strObjectName;
			}
		});

		//Now we open the new subtab.
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: strObjectName,
                actionName: "new"
            },
            state : {
                nooverride: "1",
                defaultFieldValues: encodeDefaultFieldValues({
					Plan__c: this.recordId
				}),
				recordTypeId: objParent.strRecordTypeId
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
		var noOfSelectedRows = 0;

		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objTab.lstSelectedRecords = objEvent.detail.selectedRows;
				this.selectedRecords = objEvent.detail.selectedRows;
				noOfSelectedRows = objEvent.detail.selectedRows.length;
			}
		});

		/** Show the CreateGroupChat button ONLY if more than 2 Rows are selected **/
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {			
				objTab.objParameters.lstActionButtons.forEach(button => {					
					if(button.title === "CreateGroupChat" && noOfSelectedRows >=2){
						button.strStyleClasses = "slds-var-m-left_x-small slds-visible";
					}else if(button.title === "CreateGroupChat" && noOfSelectedRows <2){
						button.strStyleClasses = "slds-var-m-left_x-small slds-hide";
					}
				})
			}
		})
		
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
			lstRecords: lstRecords,
			strPlanId: this.recordId
		}).then((result) => {
			if(result == false){
				objParent.boolDisplaySpinner = false;
				//Now we display the success message.
				objUtilities.showToast(objParent.label.Error, objParent.label.Plan_Team_Error_Message, 'error', objParent);			
			}else{
				objParent.refreshCard();
			}
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
			lstRecords.push(
			objSelectedRecord
			);
		});

		//Now we send the record for deletion.
		getRecordsRelated({
			strRecordId: this.recordId,
			lstRecords: lstRecords
		}).then(result => {
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
			objParent.boolDisplaySpinner = false;
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
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
		let objParent = this;
		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
			case 2:
				console.log(objPayload.currentTarget.dataset.id);
				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to cancel the table selection.
					case "1":
					//case "3":
						this.handleCancel();
					break;

					//User wants to remove a record.
					case "2":
						this.removeRecords();
					break;
					//User want to Create a Group Chat with selected teammembers
					case "3":
					this.handleCreateGroupChat();
					break;

					//User wants to add a record.
					case "4":
						this.addRecords();
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
	 Method Name : getCurrentTab
	 Description : This method returns the value of the current tab.
	 Parameters	 : None
	 Return Type : String
	 */
	getCurrentTab() {
		return this.template.querySelector('lightning-tabset').activeTabValue;
	}

	/*
	 Method Name : handleCreateGroup
	 Description : This method adds the members to the group chat.
	 Parameters	 : None
	 Return Type : String
	 */
	handleCreateGroupChat(){
		let objParent = this;
		var selectedPlanTeamMembers = this.selectedRecords;

		console.log('selectedPlanTeamMembers '+ JSON.stringify(selectedPlanTeamMembers));
		console.log('Plan Name '+ JSON.stringify(getFieldValue(this.planRecord, PLAN_NAME)));

		updatePlanteamData({ptAllData : selectedPlanTeamMembers, ptId: this.recordId})
		.then(result=>{
			objUtilities.showToast(objParent.label.Success,'The Plan Team Members has been added to chat successfully!','success',objParent);
			
			//Callout to Create Group Chat 
			doCalloutCreateGroupChat({sobjectid:this.recordId,responsefield:"MSTeam_Group_Chat_Id__c",relationshipname:"plan_team__r",memberemailfield:"User_Email__c",calloutname:"Group_Chat_New",subj:getFieldValue(this.planRecord, PLAN_NAME)})
			.then(result=>{
				objUtilities.showToast(objParent.label.Success,'Group Chat has been created successfully!','success',objParent);
				
			})
			.catch((objError) => {
				objUtilities.processException(objError, objParent);
				objParent.boolDisplaySpinner = false;
			}).finally(() => {
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;

				this.refreshCard();

				if(this.hideButtons === true){
					const selectedEvent = new CustomEvent("closeaction");			  
					// Dispatches the close Modal event.
					this.dispatchEvent(selectedEvent);
				}
			});
			
			
		})
		.catch((objError) => {
			objUtilities.processException(objError, objParent);
			objParent.boolDisplaySpinner = false;
		});
	}

}