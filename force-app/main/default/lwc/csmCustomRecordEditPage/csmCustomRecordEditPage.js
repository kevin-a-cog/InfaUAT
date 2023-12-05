import { LightningElement, wire,api} from 'lwc';
import {getRecord, getRecordUi,updateRecord  } from 'lightning/uiRecordApi';
//import custom permissions
import hasCSOPermission from '@salesforce/customPermission/CSOUser';
import hasCSMPermission from '@salesforce/customPermission/CSMUser';
//Apex Controllers.
import checkInternalRecords from "@salesforce/apex/CSMObjectiveAndMilestoneViewController.checkInternalRecords";
//Custom label
import Loading from '@salesforce/label/c.Loading';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
export default class CsmCustomRecordEditPage extends LightningElement {
    @api recordId;
    @api sobjectApiName;
    uiRecordEdit;
    showSpinner=true;
    modalTitle;
    keyMilestoneValue;
    boolDisableInternalField;
    activeSectionNames=[];
    //Labels.
	label = {
        Loading
    }
    @wire(getRecordUi, {
        recordIds: "$recordId",
        layoutTypes: "Full",
        modes: "Edit",
    })
    wiredRecordEdit({ error, data }) {
        if (data) {
            this.fetchedUiData =data;
            if(this.sobjectApiName == 'Objective__c'){
                this.modalTitle = 'Edit Objective';
                for (let layout of Object.values(data.layouts.Objective__c)) {
                    this.uiRecordEdit = layout.Full.Edit;
                    break;
                }          
            }
            if(this.sobjectApiName == 'Milestone__c'){
                this.modalTitle = 'Edit Milestone';
                for (let layout of Object.values(data.layouts.Milestone__c)) {
                    this.uiRecordEdit = layout.Full.Edit;
                    break;
                }
            }/*else{
                for (let layout of Object.values(data.layouts.Risk_Issue__c)) {                                    
                    this.uiRecordEdit = layout.Full.Edit;
                    break;
                }
            }*/
            if(this.uiRecordEdit ){
                let sections=this.uiRecordEdit.sections;
                sections.forEach(section =>{
                    this.activeSectionNames.push(section.id);
                });
            }
        }
        else {
            // TODO: Data handling
        }
    }

     /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;	
		objParent.showSpinner = false;
        objParent.boolDisableInternalField=false;
		//First we load the list of records.
		objParent.loadRecords();	
	}
    /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding data.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
        let objParent = this;
        objParent.showSpinner = true;	
        checkInternalRecords({
            strRecordId: objParent.recordId
        }).then((objResult) => {
            objParent.boolDisableInternalField = objResult;
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.showSpinner = false;				
        });
    }


    handleSubmit(event){
       // event.preventDefault();       // stop the form from submitting
       // const fields = event.detail.fields;
       // fields.Key_Milestone__c =  this.keyMilestoneValue;
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
    handleChange(event) {
        const keyMilestoneField = this.template.querySelector('[data-id="Key_Milestone__c"]');
        console.log('event.target.checked'+event.target.checked);
        console.log('event.target.value'+event.target.value);
        if(objUtilities.isNotNull(keyMilestoneField) && event.target.value && typeof(event.target.value) === "boolean"){
            this.keyMilestoneValue = event.target.value;
        }
    }
    handleLoad() {        
        //Disabling the input fields for CSM user
       // if(objUtilities.isNull(hasCSOPermission) && hasCSMPermission){
            const signoffField = this.template.querySelector('[data-id="Sign_Off_Date__c"]');
            if(objUtilities.isNotNull(signoffField)){
                signoffField.disabled = true;
            }
            const customerSignoffContactField = this.template.querySelector('[data-id="Customer_Sign_off_Contact__c"]');
            if(objUtilities.isNotNull(customerSignoffContactField)){
                customerSignoffContactField.disabled = true;
            }
            const customerSignoffField = this.template.querySelector('[data-id="Customer_Sign_Off__c"]');
            if(objUtilities.isNotNull(customerSignoffField)){
                customerSignoffField.disabled = true;
            }
       // }
        const internalField = this.template.querySelector('[data-id="Is_Internal__c"]');
        if(objUtilities.isNotNull(internalField)){           
            internalField.disabled = this.boolDisableInternalField;
        }
    }

    handleError() {
        this.showSpinner = false;
    }

    handleSuccess(event) {
        let objParent = this;
        const payload = event.detail;
        console.log(JSON.stringify(payload));
        objUtilities.showToast('Success','Record(s) Updated successfully!','success',objParent); 
        objParent.dispatchEvent(new CustomEvent('close'));
        objParent.showSpinner = false;
    }

    handleClick(event) {
        switch (event.target.dataset.name) {
            case 'save':
                if (this.validate()) {
                    //this.showSpinner = true;
                    this.template.querySelector('[data-name="recordFormSubmitButton"]').click();
                }
                break;

            case 'cancel':
                this.dispatchEvent(new CustomEvent('close'));
                break;

            default:
                break;
        }
    }

    validate() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            isValid = ip.reportValidity();
        });
        return isValid;
    }
}