/*
 * Name			:	enableDisableP0
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/21/2023
 * Description	:	This LWC will enable and disable the P0 flag on the case.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					                Tag
 **********************************************************************************************************
 Vignesh Divakaran		10/21/2023		I2RT-8841		Initial version.			                N/A
 Vignesh Divakaran		11/20/2023		I2RT-9503		Added logic to get Business Justification   T01
                                                        to enable/disable P0 on the case.
 */

//Core imports.
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Schema
/* Case */
import CASE from "@salesforce/schema/Case";
import P0_ENABLED_BY from "@salesforce/schema/Case.P0_Enabled_By__c";
import BUSINESS_JUSTIFICATION from "@salesforce/schema/Case.Business_Justification__c"; //<T01>

export default class EnableDisableP0 extends LightningElement {

    //API variables
    @api recordId;
    @api objectApiName; //<T01>
    
    //Track variables
    @track objCase = {};

    //Private variables
    boolInitialLoad = true; //<T01>
    boolDisplaySpinner;


    /* Wire Method */
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [P0_ENABLED_BY]
    })
    wiredRecord({ error, data }) {
        let objParent = this;

        if (error) {
            objUtilities.processException(error, objParent);
        }
        else if (data) {
            objParent.boolInitialLoad = false; //<T01>
            objParent.objCase[P0_ENABLED_BY.fieldApiName] = getFieldValue(data, P0_ENABLED_BY);
        }
    };

    /*
	 Method Name : save
	 Description : This method updates the P0 flag on the case.
	 Parameters	 : None
	 Return Type : None
	 */
    save() { //<T01>
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        
        //Now we get all the input fields.
        const lstInputFields = objParent.template.querySelectorAll('lightning-input-field');

        if (!objParent.validateInput(lstInputFields)) {
            objParent.boolDisplaySpinner = false;
			return objUtilities.showToast("Error", "Please fill all the required fields.", "error", objParent);
        }

        const fields = {};
        fields['Id'] = this.recordId;
        fields[P0_ENABLED_BY.fieldApiName] = objUtilities.isNotBlank(objParent.objCase[P0_ENABLED_BY.fieldApiName]) ? '' : 'Manual';
        lstInputFields.forEach(objField => {
            fields[objField.fieldName] = objField.value;
        });
        const objRecord = { fields };

        updateRecord(objRecord)
            .then(() => {
                objUtilities.showToast("Success", "Case is updated successfully!", "success", objParent);
            })
            .catch((objError) => {
                objUtilities.processException(objError, objParent);
            })
            .finally(() => {
                objParent.boolDisplaySpinner = false;
                objParent.cancel();
            });
    }

    /*
     Method Name : validateInput
     Description : This method checks whether all mandatory fields on the form is filled.
     Parameters	 : None
     Return Type : Boolean
    */
    validateInput(lstInputFields) { //<T01>
        let boolAllFieldsFilled = true;

        lstInputFields.forEach(objField => {
            if (objField.required && (typeof objField.value === 'string' || typeof objField.value === 'object') && objUtilities.isBlank(objField.value)) {
                    boolAllFieldsFilled = false;
            }
        });

        return boolAllFieldsFilled;
    }

    /*
	 Method Name : cancel
	 Description : This method closes the quick action.
	 Parameters	 : None
	 Return Type : None
	 */
    cancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //Getter Methods
    get strMessage() {
        return objUtilities.isNotBlank(this.objCase[P0_ENABLED_BY.fieldApiName]) ? 'Are you sure you want to disable P0?' : 'Are you sure you want to enable P0?';
    }

    get strHeader() { //<T01>
        return objUtilities.isNotBlank(this.objCase[P0_ENABLED_BY.fieldApiName]) ? 'Disable P0' : 'Enable P0';
    }
}