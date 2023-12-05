/*
 * Name			:	schedulerOptionsSelect
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/13/2023
 * Description	:	This LWC shows additional details required by the Ask An Expert scheduler.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran	    9/13/2023		I2RT-9063		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Schema
/* Service Appointment */
import SERVICE_APPOINTMENT from '@salesforce/schema/Service_Appointment__c';
import AREA from '@salesforce/schema/Service_Appointment__c.Area__c';
import CATEGORY from '@salesforce/schema/Service_Appointment__c.Category__c';

export default class SchedulerOptionsSelect extends LightningElement {

    //API variables
    @api lstAAEProducts;
    @api strSelectedProduct;
    @api strSelectedArea;
    @api strSelectedCategory;
    @api boolRequiredFieldsFilled = false;

    //Track variables
    @track _objServiceAppointment = {
        Area__c: '',
        Category__c: ''
    };
    @track lstAreaCategories;

    //Private variables
    boolIsRendered = false;


    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	*/
	connectedCallback() {
        let objParent = this;

        //Now, we fetch the area & categories from the metadata.
        if(!objUtilities.isEmpty(objParent.lstAAEProducts) && objUtilities.isNotBlank(objParent.strSelectedProduct)){
            const objProduct = objParent.lstAAEProducts.find(obj => obj.Product__c == objParent.strSelectedProduct);
            objParent.lstAreaCategories = JSON.parse(objProduct.Area_Categories__c);
            objParent.setDraftValues();
        }
    }

    /*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	*/
    renderedCallback(){
        let objParent = this;

        if(!objParent.boolIsRendered){
            objParent.boolIsRendered = true;
            objParent.validateRecord();            
        }
    }

    /*
	 Method Name : getAreas
	 Description : This method fetches all areas for the selected product.
	 Parameters	 : None
	 Return Type : List of strings.
	*/
    getAreas() {
        return this.lstAreaCategories
            .reduce((lstAccumulator, objCurrentValue) => {
                lstAccumulator.push({ label: objCurrentValue.Area__c, value: objCurrentValue.Area__c });
                return lstAccumulator;
            }, []);
    }

    /*
	 Method Name : getCategories
	 Description : This method fetches all categories for the selected area.
	 Parameters	 : None
	 Return Type : List of strings.
	*/
    getCategories() {
        return this.lstAreaCategories
            .reduce((lstAccumulator, objCurrentValue) => {
                if (objCurrentValue.Area__c == this._objServiceAppointment.Area__c) {
                    let lst = [];
                    [...objCurrentValue.Category__c].sort().forEach(strCategory => lst.push({ label: strCategory, value: strCategory }));
                    lstAccumulator.push(...lst);
                }
                return lstAccumulator;
            }, []);
    }

    /*
	 Method Name : setDraftValues
	 Description : This method loads the draft values saved previously to persist the user input.
	 Parameters	 : None
	 Return Type : None
	*/
    setDraftValues(){
        let objParent = this;

        if(objUtilities.isNotBlank(objParent.strSelectedArea) && objParent.getAreas()?.find(obj => obj.value === objParent.strSelectedArea)){
            objParent._objServiceAppointment.Area__c = objParent.strSelectedArea;
        }
        if(objUtilities.isNotBlank(objParent.strSelectedCategory) && objParent.getCategories()?.find(obj => obj.value === objParent.strSelectedCategory)){
            objParent._objServiceAppointment.Category__c = objParent.strSelectedCategory;
        }
    }

    /*
     Method Name : inputChange
     Description : This method updates the user input to the corresponding service appointment fields.
     Parameters	 : Object, called from inputChange, objEvent On change event.
     Return Type : None
    */
    inputChange(objEvent){
        let objParent = this;
        let strFieldName = objEvent.target.name;
        let value = objEvent.detail.value;

        switch (strFieldName) {
            case 'Area__c':
                objParent._objServiceAppointment[strFieldName] = objParent.strSelectedArea = value;
                objParent._objServiceAppointment['Category__c'] = objParent.strSelectedCategory = '';
                break;
            case 'Category__c':
                objParent._objServiceAppointment[strFieldName] = objParent.strSelectedCategory = value;
                break;
            default:
                //Do nothing
                break;
        }

        objParent.validateRecord();
    }

    /*
     Method Name : validateRecord
     Description : This method checks whether all mandatory fields on the form is filled.
     Parameters	 : None
     Return Type : Boolean
    */
    validateRecord(){
        let objParent = this;
        let boolAllFieldsFilled = true;

        //Now we get all the input fields.
        const inputFields = objParent.template.querySelectorAll('lightning-combobox');

        if (inputFields) {

            //Now we check if required fields are null and blank, and display error message to fill all fields.
            inputFields.forEach(field => {
                if (field.required &&
                    (   (typeof field.value === 'string' && objUtilities.isBlank(field.value)) ||
                        (Array.isArray(field.value) && objUtilities.isEmpty(field.value)) ||
                        (typeof field.value === 'object' && Object.keys(field.value)?.length === 0)) ) {
                    boolAllFieldsFilled = false;
                }
            });
        }
        if(!boolAllFieldsFilled || inputFields?.length == 0){
            if (objParent.boolRequiredFieldsFilled) {
                objParent.boolRequiredFieldsFilled = false;
            }
        }
        else {
            objParent.boolRequiredFieldsFilled = true; 
        }
    }

    //Getter methods
    get lstAreas(){
        return objUtilities.isNotBlank(this.lstAreaCategories) ? this.getAreas() : undefined;
    }

    get lstCategories(){
        return objUtilities.isNotBlank(this.lstAreaCategories) ? this.getCategories() : undefined;
    }
}