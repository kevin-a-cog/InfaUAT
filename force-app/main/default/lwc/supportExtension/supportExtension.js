/*
 * Name			:	supportExtension
 * Author		:	Vignesh Divakaran
 * Created Date	: 	23/12/2021
 * Description	:	This LWC is used to extend the support on Entitled Product.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		23/12/2021		I2RT-4792		Initial version.					N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities, log } from 'c/globalUtilities';

//Object Schema
import NAME from '@salesforce/schema/Entitled_Product__c.Name';
import END_DATE from '@salesforce/schema/Entitled_Product__c.End_Date__c';
import REASON_FOR_EXTEND_SUPPORT from '@salesforce/schema/Entitled_Product__c.Reason_for_Extend_Support__c';

//Apex Controllers.
import extendProductSupport from "@salesforce/apex/EntitledProductController.extendProductSupport";

export default class SupportExtension extends NavigationMixin(LightningElement) {

    //API variables.
	@api recordId;
    @api objectApiName;

    //Private Variables
    objEntitledProductFields = {
        NAME,
        END_DATE,
        REASON_FOR_EXTEND_SUPPORT
    };
    isLoading;
    disableSave;
    disableCancel;

    /*
	 Method Name : handleSave
	 Description : This method extends the support for the entitled product.
	 Parameters	 : Object, called from handleSave, objEvent On click event.
	 Return Type : None
	 */
    handleSave(objEvent){
        let objParent = this;
        objParent.validateButtonDisplay(true);
        let boolAllFieldsFilled = true;
        const entitledProductObj = {
            Id : objParent.recordId
        };

        //Now we get all the input fields.
        const inputFields = objParent.template.querySelectorAll('lightning-input-field');

        if (inputFields) {

            //Now we check if required fields are null and blank, and display error message to fill all fields.
            inputFields.forEach(field => {
                entitledProductObj[field.fieldName] = field.value;
                if(!objUtilities.isNotNull(field.value) && !objUtilities.isNotBlank(field.value)){
                    boolAllFieldsFilled = false;
                    objUtilities.showToast('Error', 'Please fill all the required fields.', 'error', objParent);
                }
            });

            //If all required fields are filled
           if (boolAllFieldsFilled) {

               //Now we send data to the backend, to extend the support for entitled product
               extendProductSupport({ strEntitledProductObj : JSON.stringify(entitledProductObj) })
               .then(objResponse => {
                    objUtilities.showToast('Success', 'Record has been updated successfully.', 'success', objParent);
                    objParent.handleCancel();
               })
               .catch(objError => {
                    objUtilities.processException(objError, objParent);
                    objParent.validateButtonDisplay(false);
               });
           }
           else{
                objParent.validateButtonDisplay(false);
           }
        }
    }

    /*
	 Method Name : handleCancel
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
    handleCancel(){
        let objParent = this;
        objParent[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objParent.recordId,
                objectApiName: objParent.objectApiName,
                actionName: 'view'
            }
        });
        objParent.dispatchEvent(new CloseActionScreenEvent());
    }

    /*
	 Method Name : validateButtonDisplay
	 Description : This method is used to enable & disable footer button and spinner based on state.
	 Parameters	 : Boolean, called from handleSave, boolValue.
	 Return Type : None
	 */
    validateButtonDisplay(boolValue){
        let objParent = this;
        objParent.isLoading = boolValue;
        objParent.disableSave = boolValue;
        objParent.disableCancel = boolValue;
    }

}