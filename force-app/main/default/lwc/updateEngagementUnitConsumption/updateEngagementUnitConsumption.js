import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord,getFieldValue } from "lightning/uiRecordApi";
import ACCOUNT_NAME from "@salesforce/schema/Engagement_Unit__c.Account__r.Name";
import getEngUnitConsumptionsType from '@salesforce/apex/EngagementUnitConsumptionController.getEngUnitConsumptionsType';
import getEngUnitConsumptionsRecordDetails from '@salesforce/apex/EngagementUnitConsumptionController.getEngUnitConsumptionsRecordDetails';
import updateEngUnitConsumptionStatus from '@salesforce/apex/EngagementUnitConsumptionController.updateEngUnitConsumptionStatus';
import checkIsEngUnitUpdatable from '@salesforce/apex/EngagementUnitConsumptionController.checkIsEngUnitUpdatable';
import SA_NoEngUnitConsAvailableMsg from '@salesforce/label/c.SA_NoEngUnitConsAvailableMsg';
import SA_UpdatedEngUnitConStatusSuccessMsg from '@salesforce/label/c.SA_UpdatedEngUnitConStatusSuccessMsg';
import SA_NoEditPermissionEngUnitConMsg from '@salesforce/label/c.SA_NoEditPermissionEngUnitConMsg';

export default class UpdateEngagementUnitConsumption extends LightningElement {
    @api recordId;
    spinner = false;
    noEngUnitConMsg = false;
    label = {SA_NoEngUnitConsAvailableMsg,SA_UpdatedEngUnitConStatusSuccessMsg,SA_NoEditPermissionEngUnitConMsg};

    connectedCallback(){
        this.checkIsEngUnitUpdate();
    }

    checkIsEngUnitUpdate(){
        checkIsEngUnitUpdatable()
        .then(result =>{
            if(result == false){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.label.SA_NoEditPermissionEngUnitConMsg,
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error =>{
            this.spinner = false;
            console.log('checkIsEngUnitUpdatable error ' , error);
        })
    }
    

    /*
	 Method Name : getEngUnitConsumptionsType
	 Description : This method gets the list of EU consumption context id record types
	 Parameters	 : recordId
	 Return Type : None
	 */
    @wire(getEngUnitConsumptionsType, {idRecord:'$recordId'})
    wiredEngUnitConsType({data, error}){
        if(data){
            let lstOption = [];
            if(Object.keys(data).length>0){
                for (const [key, value] of Object.entries(data)) {
                    lstOption.push({value: `${key}`,label: `${value}`});
                }
                this.contextTypeCBOpts = lstOption;
            }else{
                this.noEngUnitConMsg = true;
            }
        }
        else if (error) {
            console.log('getEngUnitConsumptions error ' , error);
        }
    }

    /*
	 Method Name : getRecord
	 Description : This method gets the account related to EU record
	 Parameters	 : recordId
	 Return Type : None
	 */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            ACCOUNT_NAME
        ]
    })
    wiredEngagementUnit;

    get accName() {
        return getFieldValue(this.wiredEngagementUnit.data, ACCOUNT_NAME);
    }

    contextTypeCBValue = '';
    contextTypeCBOpts = [];

    get contextTypeCBOptions() {
        return this.contextTypeCBOpts;
    }

    handleContextTypeCBChange(event) {
        this.spinner = true;
        this.contextTypeCBValue = event.detail.value;
        this.populateEngComboboxOptions();
    }

    engComboBoxOpts=[];

    get engComboboxOptions(){
        return this.engComboBoxOpts;
    }

    /*
	 Method Name : populateEngComboboxOptions
	 Description : This method updates the engComboBoxOpts with the Name
	 Parameters	 : recordId, contextTypeCBValue - selected Context type
	 Return Type : None
	 */
    populateEngComboboxOptions(){
        getEngUnitConsumptionsRecordDetails({idRecord:this.recordId,recType:this.contextTypeCBValue})
        .then(result =>{
            let lstOption = [];
            result.forEach(eachEng =>{
                lstOption.push({value: eachEng.engId,label: eachEng.displayName});
            });
            this.engComboBoxOpts = lstOption;
            this.spinner = false;
        })
        .catch(error =>{
            console.log('getEngUnitConsumptionsRecordDetails error ' , error);
            this.spinner = false;
        })
        
    }

    engComboboxValue = '';
    handleEngComboBoxChange(event){
        this.engComboboxValue = event.detail.value;
    }

    statusComboboxValue = '';

    get statusComboboxOptions(){
        return [
            { label: 'Completed', value: 'Completed' },
            { label: 'Cancelled', value: 'Cancelled' },
        ];
    }

    handleStatusComboBoxChange(event){
        this.statusComboboxValue = event.detail.value;
    }

    /*
	 Method Name : handleSuccess
	 Description : This method gets called when the submit button is clicked from the footer
	 Parameters	 : None
	 Return Type : None
	 */
    handleSuccess() {
        let inputFields = this.template.querySelectorAll('.validate');
        let isValid = true;
        inputFields.forEach(inputField =>{
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if(isValid){
            this.spinner = true;
            this.updateEUConStatus();
        }
    }

    /*
	 Method Name : updateEUConStatus
	 Description : This method from the handleSuccess method, updates the Eng Unit consumption to the selected status
	 Parameters	 : IdEngList, status - String(cancelled/completed)
	 Return Type : None
	 */
    updateEUConStatus(){
        updateEngUnitConsumptionStatus({IdEngList:this.engComboboxValue, idRecord:this.recordId, status:this.statusComboboxValue})
        .then(result =>{
            if(result){
                this.spinner = false;
                this.updateEngConsUnitsAndCloseModal();
            }
        })
        .catch(error =>{
            this.spinner = false;
            console.log('updateEngUnitConsumptionStatus error ' , error);
        })
    }

    updateEngConsUnitsAndCloseModal(){
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: this.label.SA_UpdatedEngUnitConStatusSuccessMsg,
                variant: 'success'
            })
        );
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}