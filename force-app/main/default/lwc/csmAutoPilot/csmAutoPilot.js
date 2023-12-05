/* Name			    :	CsmAutoPilot
* Author		    :	Deva M
* Created Date	    :   10/08/2021
* Description	    :	CsmAutoPilot controller.

Change History
**********************************************************************************************************
Modified By			    Date			    Jira No.		  Description					Tag
**********************************************************************************************************
Deva M		        10/08/2021		 N/A				      Initial version.		    	N/A
Karthi G            22/08/2023		 AR-3222				  Added changes to handle       T1
                                                              Assisted plans.			    
*/
//Core imports
import { LightningElement, api, wire } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
//Apex Imports
import lookupQueueSearch from '@salesforce/apex/LookupSearchHelper.lookupQueueSearch';
import lookupCombinedSearch from '@salesforce/apex/LookupSearchHelper.lookupCombinedSearch';
import createAutoPilotPlanComment from '@salesforce/apex/CSMAutoPilotController.createAutoPilotPlanComment';
import submitAutoPilotRequest from '@salesforce/apex/CSMAutoPilotController.submitAutoPilotRequest';
import getPlanRecord from '@salesforce/apex/CSMAutoPilotController.getPlanRecord';

//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import CSM_Auto_Pilot_Message from '@salesforce/label/c.CSM_Auto_Pilot_CSM_Message';
import CSM_CSO_Auto_Pilot_Message from '@salesforce/label/c.CSM_Auto_Pilot_CSM_CSO_Message';
import CSM_Auto_Pilot_Lookup_Error_Message from '@salesforce/label/c.CSM_Auto_Pilot_Lookup_Error_Message';
import AutoPilot_Error_Message_Data_Science from '@salesforce/label/c.AutoPilot_Error_Message_Data_Science';
import Loading from '@salesforce/label/c.Loading';

//import custom permissions
import hasCSMManagerPermission from "@salesforce/customPermission/CSMManager";
import hasCSOPermission from "@salesforce/customPermission/CSOUser";
import hasCSMPermission from "@salesforce/customPermission/CSMUser";

export default class CsmAutoPilot extends LightningElement {
    //Public variables
    @api recordId;
    @api displayPlanPilotScreen;
    planRecord;
    disableSave = false;
    //Private variables.
	boolDisplayModalSpinner;
    userQueueID;
    autoPilotCommentValues;
    initialSelection = [
        {
            id: 'na',
            sObjectType: 'na',
            icon: 'standard:lightning_component',
            title: 'Inital selection',
            subtitle: 'Not a valid record'
        }
    ];
    //Labels.
	label = {
        Success,
        Error,
        CSM_Auto_Pilot_Message,
        CSM_CSO_Auto_Pilot_Message,
        CSM_Auto_Pilot_Lookup_Error_Message,
        AutoPilot_Error_Message_Data_Science,
        Loading
    }

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback(){       
       this.loadRecords();
    }
    /*
	 Method Name : loadRecords
	 Description : This method gets executed on load and get plan record.
	 Parameters	 : None
	 Return Type : None
	 */
    loadRecords(){
        let objParent = this;
        objParent.boolDisplayModalSpinner=true;
        //getPlan Records
        getPlanRecord({ planRecordId: this.recordId})
        .then((objResponse) => {
            this.userQueueID = objResponse.userorQueueId; //T1
            this.initialSelection = objResponse.selectedOption;    //T1
            this.planRecord = objResponse.plan;    //T1

            if(this.planRecord.Plan_Comments__r !==undefined && this.planRecord.Plan_Comments__r.length>0){
                this.disableSave = true;
                objUtilities.showToast(objParent.label.Error,objParent.label.AutoPilot_Error_Message_Data_Science,'error',objParent);
            }
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplayModalSpinner = false;
        });
    }

    //Cloase the modal on click of close
    closeAction(){
        this.boolDisplayModalSpinner=false;
        this.initialSelection = [];
        this.closeQuickAction(this.recordId);
    }
    get isCSMUser(){
        return objUtilities.isNotNull(hasCSMPermission) && objUtilities.isNull(hasCSMManagerPermission) && objUtilities.isNull(hasCSOPermission);
    }
    get isCSMCSOUser(){
        return objUtilities.isNotNull(hasCSMManagerPermission) || objUtilities.isNotNull(hasCSOPermission);
    }


    //Set the close quick action false and can eb called in multiple methods
    closeQuickAction(recordId) {
        var closeQA = new CustomEvent('close');
        if(recordId){
            const filters = [recordId];        
            closeQA = new CustomEvent('close', {
                detail: {filters}
            });    
        }
        this.dispatchEvent(closeQA);
    }    
    //handle logic for Post record sucess full save for lightning-record-edit-form LDS
    handleSuccess(event) {
        this.boolDisplayModalSpinner=false;
        let objParent = this;
        if(objUtilities.isNotNull(this.userQueueID)){
            if (this.isCSMUser && !this.isCSMCSOUser && this.userQueueID.startsWith("005")) {
                objParent.boolDisplayModalSpinner = true;
                //Show success toast to user
                objUtilities.showToast(objParent.label.Success,objParent.label.CSM_Auto_Pilot_Message,'success',objParent);
                if(objUtilities.isNotBlank(this.autoPilotCommentValues)){
                    this.autoPilotCommentValues=objParent.label.CSM_Auto_Pilot_Message +'<br> Comments: '+ this.autoPilotCommentValues;
                }else{
                    this.autoPilotCommentValues=objParent.label.CSM_Auto_Pilot_Message;
                }
                //submit for approval process and create plan comments 
                submitAutoPilotRequest({    planRecordId: this.recordId ,
                                            autoPilotRequestComments: this.autoPilotCommentValues 
                                        })
                .then((result) => {
                    //Show success toast to user
                    objUtilities.showToast(objParent.label.Success,objParent.label.CSM_CSO_Auto_Pilot_Message,'success',objParent);                
                })
                .catch((objError) => {
                    objUtilities.processException(objError, objParent);
                }).finally(() => {
                    //Finally, we hide the spinner.
                    objParent.boolDisplayModalSpinner = false;
                });        
            }
            if(this.isCSMCSOUser || this.userQueueID.startsWith("00G")){
                objParent.boolDisplayModalSpinner = true;
                if(objUtilities.isNotBlank(this.autoPilotCommentValues)){
                    this.autoPilotCommentValues='Plan is in AutoPilot Mode <br> Comment : ' + this.autoPilotCommentValues;
                }else{
                    this.autoPilotCommentValues='Plan is in AutoPilot Mode';
                }
                //Create plan comment on success
                createAutoPilotPlanComment({ planRecordId: this.recordId , autoPilotComments: this.autoPilotCommentValues ,addInfo :true,prevOwner :this.planRecord.Owner.Name})
                .then((result) => {
                    //Show success toast to user
                    objUtilities.showToast(objParent.label.Success,objParent.label.CSM_CSO_Auto_Pilot_Message,'success',objParent);                
                })
                .catch((objError) => {
                    objUtilities.processException(objError, objParent);
                }).finally(() => {
                    //Finally, we hide the spinner.
                    objParent.boolDisplayModalSpinner = false;
                });
            }
            //Close the modal
            this.closeQuickAction(this.recordId);
        }
    }
    captureComment(event){
        this.autoPilotCommentValues=event.detail.value;
    }

    /*
	 Method Name : handleError
	 Description : This method gets executed on error of record edit form.
	 Parameters	 : objEvent
	 Return Type : None
	 */
    handleError(objEvent){
        let objParent = this;
        let payLoad = objUtilities.isNotNull(objEvent.detail.detail)?objEvent.detail.detail:objEvent.detail ;
        objUtilities.showToast(objParent.label.Error,payLoad,'error', objParent);
        objParent.closeAction();
    }
     //handle logic on record submit for lightning-record-edit-form LDS
    handleSubmit(objEvent) {
        objEvent.preventDefault(); 
        let objParent = this;
        this.boolDisplayModalSpinner=true;          
        //Validate the custom lookup component is blank or not
        if(objUtilities.isBlank(this.userQueueID)){
            objUtilities.showToast(objParent.label.Error,objParent.label.CSM_Auto_Pilot_Lookup_Error_Message,'error',objParent);
            this.boolDisplayModalSpinner=false;
        }else{
            // Get data from submitted form 
            const fields = objEvent.detail.fields;
            if (objParent.isCSMUser && this.userQueueID.startsWith("005")){
                fields.AutoPilot_Status__c = 'Submitted for Approval';
                fields.CSM_isAutoPilot__c = false;
            }  
            if (objParent.isCSMCSOUser || this.userQueueID.startsWith("00G")) {
                fields.AutoPilot_Status__c = 'Approved';
                fields.CSM_isAutoPilot__c = true;
            }            
            // You need to submit the form after validation
            objParent.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }
    //Search for queue
    handleQueueLookupSearch(event) {
        const lookupElement = event.target;
        let objParent = this;
        lookupQueueSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
    }   
    handleQueueLookupSelectionChange(event) {
        this.userQueueID = event.detail.values().next().value;
    }
    handleCombinedLookupSearch(event) {
        const lookupElement = event.target;
        let objParent = this;
        lookupCombinedSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
    }
    handleCombinedLookupSelectionChange(event) {
        this.userQueueID = event.detail.values().next().value;   
    }
}