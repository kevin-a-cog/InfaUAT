/*
 * Name			:	certificationRequestCreateV2
 * Author		:	Vignesh Divakaran
 * Created Date	: 	7/21/2023
 * Description	:	This is used to create certification request from the screen flow.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran	    7/21/2023		I2RT-8640		Initial version.			                        N/A
 Vignesh Divakaran	    8/14/2023		I2RT-8958		Show custom products & validation for preferred     T01
                                                        request type
*/

//Core imports.
import { LightningElement, api, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Utilities.
import { screenFlow } from 'c/flowUtilities';
import { objUtilities } from 'c/globalUtilities';

//Schema
/* Certification Request */
import CERTIFICATION_REQUEST from '@salesforce/schema/Certification_Request__c';
import REQUEST_TYPE from '@salesforce/schema/Certification_Request__c.Request_Type__c';
import CERTIFICATION_TYPE from '@salesforce/schema/Certification_Request__c.Certification_Type__c';
import PRODUCT from '@salesforce/schema/Certification_Request__c.Product__c';
import BUSINESS_JUSTIFICATION from '@salesforce/schema/Certification_Request__c.Business_Justification__c';
import START_DATE from '@salesforce/schema/Certification_Request__c.Start_Date__c';
import END_DATE from '@salesforce/schema/Certification_Request__c.End_Date__c';
import BUSINESS_OWNER from '@salesforce/schema/Certification_Request__c.Owner__c';
import STATUS from '@salesforce/schema/Certification_Request__c.Status__c';
import SUPPORT_ACCOUNT from '@salesforce/schema/Certification_Request__c.Support_Account__c';

//Custom Labels.
import Solution_Categories from '@salesforce/label/c.Solution_Categories'; //<T01>

export default class CertificationRequestCreateV2 extends LightningElement {

    //API variables
    @api recordId;
    @api objSupportAccount; //<T01>
    @api objAccountTeamMember;
    @api lstCertificationRequests;
    @api lstCaseSegmentPeriodConfigurations; //<T01>
    @api boolRequiredFieldsFilled = false;
    @api boolShowErrorMessage = false;
    @api strErrorMessage; //<T01>
    @api objCertificationRequestDraft;
    @api 
    get objCertificationRequest(){
        return this._objCertificationRequest;
    }

    //Track variables
    @track _objCertificationRequest = {
        Request_Type__c: '',
        Certification_Type__c: '',
        Product__c: '',
        Business_Justification__c: '',
        Start_Date__c: '',
        End_Date__c: '',
        Owner__c: '',
        Status__c:'',
        Support_Account__c: ''
    };
    @track lstProducts = []; //<T01>
    @track lstDraftProducts = []; //<T01>

    //Private variable
    strWarningMessage;
    boolLoaded = false;
    boolDisplaySpinner = true;
    _objCertificationRequestDraft;

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	*/
	connectedCallback() {
        let objParent = this;

        if(objUtilities.isNotBlank(objParent.objCertificationRequestDraft?.Request_Type__c)){
            objParent.setProducts(); //<T01>
            objParent.setDraftValues();
            objParent.setWarningMessage();
        }
        else{
            objParent.setDefaultValues();
        }
    }

    /*
     Method Name : inputChange
     Description : This method updates the user input to the corresponding certification request fields.
     Parameters	 : Object, called from inputChange, objEvent On change event.
     Return Type : None
    */
    inputChange(objEvent){
        let objParent = this;
        let strFieldName = objEvent.target?.fieldName || objEvent.target.name;
        let value = objEvent.detail.value;

        switch (strFieldName) {
            case 'Request_Type__c':
                objParent._objCertificationRequest[strFieldName] = value;
                objParent.resetFieldValues();
                objParent.preRequisiteValidate(); //<T01>
                objParent.setWarningMessage();
                objParent.setDefaultValues();
                objParent.setProducts(); //<T01>
                break;
            case 'Certification_Type__c':
                objParent._objCertificationRequest[strFieldName] = value;
                break;
            case 'Product__c':
                objParent._objCertificationRequest[strFieldName] = (typeof value !== 'string') && (typeof value === 'object') ? Object.values(value)?.join(';') : value; //<T01>
                break;
            case 'Business_Justification__c':
                objParent._objCertificationRequest[strFieldName] = value;
                break;
            case 'Start_Date__c':
                objParent._objCertificationRequest[strFieldName] = value;
                break;
            case 'End_Date__c':
                objParent._objCertificationRequest[strFieldName] = value;
                break;
            case 'Owner__c':
                objParent._objCertificationRequest[strFieldName] = (typeof value !== 'string') && (typeof value === 'object') ? value?.toString() : value;
                break;
            default:
                //Do nothing
                break;
        }

        objParent.validateRecord();
    }

    /*
	 Method Name : setDraftValues
	 Description : This methods loads the draft values saved previously to persist the user input in case of an error.
	 Parameters	 : None
	 Return Type : None
	*/
    setDraftValues(){
        let objParent = this;

        if(objUtilities.isNotBlank(objParent.objCertificationRequestDraft)){
            const objCopy = { ...objParent._objCertificationRequest };
            const draftCopy = { ...objParent.objCertificationRequestDraft };

            Object.keys(draftCopy)?.forEach(strFieldName => {
                if (objCopy.hasOwnProperty(strFieldName)) {
                    objCopy[strFieldName] = draftCopy[strFieldName];
                    if (draftCopy['Request_Type__c'] === 'Preferred' && strFieldName === 'Product__c' && objUtilities.isNotBlank(draftCopy[strFieldName])) { //<T01>
                        objParent.lstDraftProducts = draftCopy['Product__c']?.split(';');
                    }
                }
            });

            objParent._objCertificationRequest = objCopy;
        }
    }

    /*
	 Method Name : setDefaultValues
	 Description : This method loads the default values from the latest active certification request from the same request type selected.
	 Parameters	 : None
	 Return Type : None
	*/
    setDefaultValues(){
        let objParent = this;
        let REQUEST_TYPE_TO_FIELDS_MAP = new Map();
        REQUEST_TYPE_TO_FIELDS_MAP.set('Hypercare', ['Certification_Type__c', 'Product__c', 'End_Date__c']);
        REQUEST_TYPE_TO_FIELDS_MAP.set('Preferred', ['Product__c', 'End_Date__c']);
        const objCopy = { ...this._objCertificationRequest };

        if(objParent.lstCertificationRequests?.length){
            let crMap = new Map();
            const lstCertificationRequests = [...objParent.lstCertificationRequests];

            //Now, we create a map of request type to latest certification request
            lstCertificationRequests.forEach(objRecord => {
                let key = objRecord['Request_Type__c'];
                if(!crMap.has(key) || (crMap.has(key) && crMap.get(key)?.CreatedDate < objRecord.CreatedDate)){
                    crMap.set(key, objRecord);
                }
            });

            //Now, we default the values only for the fields found in the map
            if(crMap.has(objCopy.Request_Type__c) && objUtilities.isNotBlank(objCopy['Request_Type__c']) && objCopy['Request_Type__c'] !== 'Preferred'){
                const objRecord = crMap.get(objCopy.Request_Type__c);
                const fields = REQUEST_TYPE_TO_FIELDS_MAP.get(objRecord.Request_Type__c);

                fields.forEach(field => {
                    objCopy[field] = objRecord[field];
                });

                objParent._objCertificationRequest = objCopy;
            }
        }
    }

    /*
     Method Name : resetFieldValues
     Description : This method resets all fields on certification request excluding the Request_Type__c.
     Parameters	 : None
     Return Type : None
    */
    resetFieldValues(){
        let objParent = this;
        const objCopy = { ...objParent._objCertificationRequest };

        Object.keys(objCopy).forEach(strField => {
            if(strField !== 'Request_Type__c'){
                objCopy[strField] = '';
            }
        });

        objParent._objCertificationRequest = objCopy;
        objParent.lstDraftProducts = []; //<T01>
    }

    /*
	 Method Name : setWarningMessage
	 Description : This method displays the warning message when there is already an active certification request for the request type selected.
	 Parameters	 : None
	 Return Type : None
	*/
    setWarningMessage(){
        let objParent = this;

        if(objParent.lstCertificationRequests?.length){
            let crMap = new Map();
            const lstCertificationRequests = [...objParent.lstCertificationRequests];

            //Now, we create a map of request type to latest certification request
            lstCertificationRequests.forEach(objRecord => {
                let key = objRecord['Request_Type__c'];
                if(!crMap.has(key) || (crMap.has(key) && crMap.get(key)?.CreatedDate < objRecord.CreatedDate)){
                    crMap.set(key, objRecord);
                }
            });

            if(objUtilities.isNotBlank(objParent._objCertificationRequest['Request_Type__c']) && crMap.has(objParent._objCertificationRequest['Request_Type__c']) && objParent._objCertificationRequest['Request_Type__c'] !== 'Preferred'){
                let objRecord = crMap.get(objParent._objCertificationRequest['Request_Type__c']);
                let formattedDate = `${objParent.dateFormatter(objRecord.End_Date__c, {year: 'numeric', month: 'long', day: 'numeric'})}`;
                objParent.strWarningMessage = `There is already an active ${objRecord.Request_Type__c} for this Support Account for ${objRecord.Product__c} until ${formattedDate}. Any new requests with overlapping dates will override the current one.`;
            }
            else {
                objParent.strWarningMessage = undefined;
            }
        }        
    }

     /*
     Method Name : preRequisiteValidate
     Description : This method checks all pre-requistes based on the request type chosen and fires the validations.
     Parameters	 : None
     Return Type : None
    */
    preRequisiteValidate() { //<T01>
        let objParent = this;

        if (objParent.validateSupportSME()) return;
        if (objParent.validateSuccessOffering()) return;
        
        if (objParent.boolShowErrorMessage) {
            objParent.boolShowErrorMessage = false;
            objParent.strErrorMessage = undefined;
        }
    }

    /*
     Method Name : validateSupportSME
     Description : This method updates the boolean property and invokes the flow next navigation to display the error message.
     Parameters	 : None
     Return Type : None
    */
    validateSupportSME() {
        let objParent = this;

        if (objParent._objCertificationRequest.Request_Type__c === 'Hypercare' && objUtilities.isBlank(objParent.objAccountTeamMember?.Id)) {
            objParent.boolShowErrorMessage = true;
            objParent.strErrorMessage = `There is no 'Support SME' account team member under the Support Account.`; //<T01>
            screenFlow.next(objParent);
        }
        return objParent.boolShowErrorMessage; //<T01>
    }

    /*
     Method Name : validateSuccessOffering
     Description : This method updates the boolean property and invokes the flow next navigation to display the error message.
     Parameters	 : None
     Return Type : None
    */
    validateSuccessOffering() { //<T01>
        let objParent = this;

        if (objParent._objCertificationRequest.Request_Type__c === 'Preferred' && objUtilities.isNotBlank(objParent.objSupportAccount?.Success_Offering__c) && objParent.objSupportAccount?.Success_Offering__c !== 'Premium Success') {
            objParent.boolShowErrorMessage = true;
            objParent.strErrorMessage = `Success Offering on the Support Account should be Premium Success in order to create Preferred Certification Request.`
            screenFlow.next(objParent);
        }
        return objParent.boolShowErrorMessage;
    }

    /*
     Method Name : setProducts
     Description : This method loads custom list of products from metadata for Preferred request type.
     Parameters	 : None
     Return Type : None
    */
    setProducts(){ //<T01>
        let objParent = this;

        if(!objUtilities.isEmpty(objParent.lstCaseSegmentPeriodConfigurations)){
            let lstProducts = [];
            let lstProductsFormatted = [];
            let boolIsPC2Customer = objParent.isPC2Customer();

            objParent.lstCaseSegmentPeriodConfigurations.forEach(obj => {
                let strProduct = obj.Product__c;
                if (obj.Segment__c === 'Preferred' && !lstProducts.includes(strProduct) && (!obj.Is_PC2_Customer__c || (boolIsPC2Customer && obj.Is_PC2_Customer__c)))
                    lstProducts.push(strProduct);
            });

            if (!objUtilities.isEmpty(lstProducts)) {
                lstProducts.forEach(strProduct => {
                    lstProductsFormatted.push({ label: strProduct, value: strProduct });
                });
            }

            objParent.lstProducts = lstProductsFormatted;
        }
    }

    /*
     Method Name : isPC2Customer
     Description : This method checks whether the support account is a PC2 customer.
     Parameters	 : None
     Return Type : Boolean
    */
    isPC2Customer() { //<T01>
        let SOLUTION_CATEGORIES = objUtilities.isNotBlank(Solution_Categories) ? Solution_Categories.split(',') : [];
        return SOLUTION_CATEGORIES.includes(this.objSupportAccount?.Support_Account_Solution_Category__c);
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
        const inputFields = objParent.template.querySelectorAll('lightning-input-field,lightning-dual-listbox'); //<T01>

        if (inputFields) {

            //Now we check if required fields are null and blank, and display error message to fill all fields.
            inputFields.forEach(field => {
                if (field.required &&
                    (   (typeof field.value === 'string' && objUtilities.isBlank(field.value)) ||
                        (Array.isArray(field.value) && objUtilities.isEmpty(field.value)) ||
                        (typeof field.value === 'object' && field.value === {})) ) {    //<T01>
                    boolAllFieldsFilled = false;
                }
            });
        }
        if(!boolAllFieldsFilled || inputFields?.length <= 1){
            if (objParent.boolRequiredFieldsFilled) {
                objParent.boolRequiredFieldsFilled = false;
            }
        }
        else {
            objParent.boolRequiredFieldsFilled = true; //<T01>
            objParent._objCertificationRequest.Status__c = 'New';
            objParent._objCertificationRequest.Support_Account__c = objParent.recordId;
        }

        return boolAllFieldsFilled;
    }

    /*
	 Method Name : dateFormatter
	 Description : This method returns the formatted date.
	 Parameters	 : (Date, Object), called from setWarningMessage, (strDate, objFormat)
	 Return Type : String
	*/
    dateFormatter(strDate, objFormat){
        let strFormmatedDate = '';
        if(objUtilities.isNotBlank(strDate)){
            let newDate = new Date(strDate);
            //Use timezone from salesforce user
            objFormat.timezone = TIME_ZONE;
            strFormmatedDate = new Intl.DateTimeFormat(LOCALE, objFormat).format(newDate);
        }

        return strFormmatedDate; 
    }

    /*
	 Method Name : load
	 Description : This method gets executed when all the input fields inside the record edit form are loaded & disables the spinner.
	 Parameters	 : None
	 Return Type : None
	 */
    load(){
        let objParent = this;

        if(!objParent.boolLoaded){
            objParent.boolLoaded = true;
          	objParent.validateRecord();
            objParent.toggleSpinner();
        }
    }

    /*
	 Method Name : toggleSpinner
	 Description : This method toggles the spinner's boolean value.
	 Parameters	 : None
	 Return Type : None
	*/
    toggleSpinner(){
        this.boolDisplaySpinner = !this.boolDisplaySpinner;
    }

    //Getter methods
    get objectApiName() {
        return CERTIFICATION_REQUEST?.objectApiName;
    }

    get isHypercare(){
        return this._objCertificationRequest?.Request_Type__c === 'Hypercare';
    }

    get isPreferred(){
        return this._objCertificationRequest?.Request_Type__c === 'Preferred';
    }

    get showWarning(){
        return !!this.strWarningMessage;
    }
}