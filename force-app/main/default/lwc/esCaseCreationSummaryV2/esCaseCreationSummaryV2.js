/*
 * Name			:	esCaseCreationSummaryV2
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/25/2022
 * Description	:	This LWC displays summary of case creation details. It is refactored based on esCaseCreationSummary LWC.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran      10/25/2022		I2RT-7256		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class EsCaseCreationSummaryV2 extends LightningElement {

    //API variables
    @api objParameters;
    @api objCase;

    //Track variables
    @track lstContacts = [];
    
    //Private variables
    strContactToDelete;
    lstAllSelectedRecordIds = [];
    boolShowConfirmationModal = false;

    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters  : None
     Return Type : None
    */
    connectedCallback() {
        let objParent = this;

        if(!objUtilities.isEmpty(objParent.objParameters.lstAllContacts)){
            objParent.lstAllSelectedRecordIds = JSON.parse(JSON.stringify(objParent.objParameters.lstAllSelectedRecordIds));
            objParent.lstContacts = JSON.parse(JSON.stringify(objParent.objParameters.lstAllContacts))?.filter(objContact => objParent.lstAllSelectedRecordIds.includes(objContact.strId));
        }        
    }

    /*
	 Method Name : openConfirmation
	 Description : Event, called from openConfirmation, objEvent On click event.
	 Parameters	 : None
	 Return Type : None
	*/
    openConfirmation(objEvent){
        this.boolShowConfirmationModal = true;
        this.strContactToDelete = objEvent.target.value;
    }

    /*
	 Method Name : closeConfirmation
	 Description : This method closes the delete contact confirmation modal.
	 Parameters	 : None
	 Return Type : None
	*/
    closeConfirmation(){
        this.boolShowConfirmationModal = false;
    }

    /*
	 Method Name : deleteContact
	 Description : This method closes the delete contact confirmation modal.
	 Parameters	 : None
	 Return Type : None
	*/
    deleteContact(){
        this.lstContacts = this.lstContacts.filter(objContact => objContact.strId != this.strContactToDelete);
        this.lstAllSelectedRecordIds = this.lstAllSelectedRecordIds.filter(strId => strId != this.strContactToDelete);
        this.closeConfirmation();
    }

    /*
	 Method Name : goToPreviousStep
	 Description : This method fires an event to parent component to hide the current step and show the previous step.
	 Parameters	 : None
	 Return Type : None
	*/
    goToPreviousStep(){
        this.dispatchEvent(new CustomEvent('goback', { detail: {lstAllSelectedRecordIds: this.lstAllSelectedRecordIds}, bubbles: true }));
    }

    /*
	 Method Name : createCase
	 Description : This method fires an event to parent component to create the case.
	 Parameters	 : None
	 Return Type : None
	*/
    createCase(){
        let lstContactsToAdd = [];

        this.lstContacts.forEach(objContact => {
            let objCaseContact = {};
            if(objUtilities.isNotBlank(objContact?.strContactId)){
                objCaseContact.Contact__c = objContact.strContactId
            }
            else{
                objCaseContact.Email__c = objContact.strEmail;
            }
            lstContactsToAdd.push(objCaseContact);
        });
        this.dispatchEvent(new CustomEvent('create', { 
            detail: {
                lstContactsToAdd: lstContactsToAdd,
                lstAllSelectedRecordIds: this.lstAllSelectedRecordIds
            }, 
            bubbles: true 
        }));
    }
    
    /*
	 Method Name : cancelCaseCreation
	 Description : This method fires an event to parent component to cancel the case creation process.
	 Parameters	 : None
	 Return Type : None
	*/
    cancelCaseCreation(){
        this.dispatchEvent(new CustomEvent('cancel', { detail: '', bubbles: true }));
    }

    /* Getter Methods */
    get showContacts(){
        return this.lstContacts.length >= 1;
    }
}