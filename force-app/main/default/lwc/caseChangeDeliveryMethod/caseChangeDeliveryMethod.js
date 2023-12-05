/*
 * Name			:	caseChangeDeliveryMethod
 * Author		:	Balaji P
 * Created Date	: 	6/17/2022
 * Description	:	This LWC is used to change product, its related fields and override delivery method.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					    		    Tag
 **********************************************************************************************************
 Balaji P		        6/17/2022		I2RT-6222		Initial version.				    	    N/A
 Vignesh D		        3/31/2023		I2RT-7852		Show product and its related fields         T01
                                                        along with override delivery method.
 Vignesh D		        5/04/2023		I2RT-8325		Fetch orgs whenever product and delivery    T02
                                                        method is changed
 Vignesh D		        8/18/2023		I2RT-8847		Show override delivery method with all      T03
                                                        values
 Shashikanth            9/19/2023       I2RT-9026       Capture Components fields even for          T04
                                                        Fulfilment cases                                                        
 */

//Core imports.
import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Object Schema
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_ORG from '@salesforce/schema/Case.Org__c';
import CASE_ORG_ID from '@salesforce/schema/Case.Org_ID__c';
import CASE_SECUREAGENT from '@salesforce/schema/Case.Secure_Agent__c';
import CASE_ENVIRONMENT from '@salesforce/schema/Case.Environment__c';
import CASE_ACTIVITY_TYPE from '@salesforce/schema/Case.Activity_Type__c'
import CASE_RECORDTYPEID from '@salesforce/schema/Case.RecordTypeId';
import CASE_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';
import CASE_FORECAST_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c';
import CASE_ENTITLED_PRODUCT from '@salesforce/schema/Case.Entitled_Product__c';
import CASE_EP_DELIVERY_METHOD from '@salesforce/schema/Case.Entitled_Product__r.Delivery_Method__c';
import CASE_DEV_DEL_METHOD_PROPS from '@salesforce/schema/Case.DEV_Delivery_Method_Orig_Properties__c';
import CASE_DELIVERY_METHOD_OVERRIDDEN_VALUE from '@salesforce/schema/Case.Delivery_Method_Overridden_Value__c';
import CASE_COMPONENT from '@salesforce/schema/Case.Component__c';
import CASE_SUBCOMPONENT from '@salesforce/schema/Case.Subcomponent__c';
import CASE_VERSION from '@salesforce/schema/Case.Version__c';
import CASE_PROBLEMTYPE from '@salesforce/schema/Case.Problem_Type__c';
import CASE_RECORDTYPE_NAME from '@salesforce/schema/Case.Record_Type_Name__c';
import CASE_DELIVERY_METHOD from '@salesforce/schema/Case.Delivery_Method__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';

//Apex Controllers.
import getOrgIds from '@salesforce/apex/CaseController.getOrgIds';
import getProductAttributes from '@salesforce/apex/caseDependentPicklistController.getProductAttributes';
import getDelMethodsForSelectedProduct from '@salesforce/apex/CaseController.getDelMethodsForSelectedProduct';

const CASE_FIELDS = [CASE_SUPPORT_ACCOUNT, CASE_RECORDTYPEID, CASE_FORECAST_PRODUCT, CASE_DELIVERY_METHOD_OVERRIDDEN_VALUE, 
                        CASE_ORG, CASE_ORG_ID, CASE_SECUREAGENT, CASE_ENVIRONMENT, CASE_ACTIVITY_TYPE, 
    CASE_ENTITLED_PRODUCT, CASE_EP_DELIVERY_METHOD, CASE_DEV_DEL_METHOD_PROPS, CASE_COMPONENT, CASE_SUBCOMPONENT,
    CASE_VERSION, CASE_PROBLEMTYPE, CASE_RECORDTYPE_NAME, CASE_DELIVERY_METHOD, CASE_STATUS];

export default class CaseChangeDeliveryMethod extends LightningElement {

    //API variables.
    @api recordId;

    //Private variables.
    @track processCount = 5;
    
    deliveryMethodOptions = [];
    orgIdOptions = [];
    activityTypeOptions = [];
    environmentOptions = [];

    supportAccountId;
    forecastProduct;
    origDeliveryMethod;
	origDelMethodProps;
    origOrgId;
    origOrgManual;
    origSecureAgent;
    origEnvironment;
    origActivityType;

    orgId;
    orgManual = '';
    secureAgent = '';
    environment = '';
    activityType = '';

    @track deliveryMethod;
    @track manualOrgFlag = false;
    @track isOverridden = false;
    // @track showConfirmationModal = false;

    requiredFieldErrMsg = 'This field is required.';

    @track productOBJ = {label: "Product", name: 'Forecast_Product__c', editable: false, updateable: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};
    @track versionOBJ = {label: "Version", name: 'Version__c', editable: false, updateable: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};
    @track componentOBJ = {label: "Component", name: 'Component__c', editable: false, updateable: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};       //<T04>
    @track subCompOBJ = {label: "Subcomponent", name: 'Subcomponent__c', editable: false, updateable: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};   //<T04>
    @track problemTypeOBJ = {label: "Problem Type", name: 'Problem_Type__c', editable: false, updateable: true, show: true, showCaseTypes: 'Technical::Operations'};
    @track productSectionFields = [
        this.productOBJ,
        this.versionOBJ,
        this.componentOBJ,
        this.subCompOBJ,
        this.problemTypeOBJ
    ];
    
    objResponse;
    strSelectedProduct;
    strSelectedVersion;
    strSelectedComponent;
    strSelectedSubcomponent;
    strSelectedDeliveryMethod;
    strSelectedProblemType;
    boolIsOverrideDeliveryMethodRequired = true;
    orginalOverrideDeliveryMethod;


    /* Wire Methods */
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT}) 
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    sourceCase({ error, data }) {
        if (error) {
            console.log("error fetching case details - " + JSON.stringify(error));
            this.processCount--;
        } else if (data) {

            this.supportAccountId = getFieldValue(data, CASE_SUPPORT_ACCOUNT);
            //this.forecastProduct = getFieldValue(data, CASE_FORECAST_PRODUCT);
            this.orgId = getFieldValue(data, CASE_ORG);
            this.orgManual = getFieldValue(data, CASE_ORG_ID);
            this.secureAgent = getFieldValue(data, CASE_SECUREAGENT);
            this.environment = getFieldValue(data, CASE_ENVIRONMENT);
            this.activityType = getFieldValue(data, CASE_ACTIVITY_TYPE);

            this.orginalOverrideDeliveryMethod = getFieldValue(data, CASE_DELIVERY_METHOD_OVERRIDDEN_VALUE);
            this.deliveryMethod = getFieldValue(data, CASE_DELIVERY_METHOD_OVERRIDDEN_VALUE);
            this.origDeliveryMethod = getFieldValue(data, CASE_EP_DELIVERY_METHOD);
            this.origDelMethodProps = getFieldValue(data, CASE_DEV_DEL_METHOD_PROPS);
            this.origOrgId = this.orgId;
            this.origOrgManual = this.orgManual;
            this.origSecureAgent = this.secureAgent;
            this.origEnvironment = this.environment;
            this.origActivityType = this.activityType;

            this.manualOrgFlag = false;
            if(this.orgManual && this.orgManual !== '' && (!this.orgId || this.orgId === '')){
                this.manualOrgFlag = true;
            }

            if(this.deliveryMethod && this.deliveryMethod !== ''){
                this.isOverridden = true;
            }

            this.caseRecord = data;  
            this.caseRecordTypeId = data.recordTypeId;
            this.caseDeliveryMethod = data.fields.Delivery_Method__c.value;
            this.caseRecordTypeName = data.recordTypeInfo.name;
          
            if (objUtilities.isNotBlank(this.caseRecordTypeName)) {
                if (objUtilities.isNotBlank(this.productOBJ.showCaseTypes) && !this.productOBJ.showCaseTypes.includes(this.caseRecordTypeName)) this.productOBJ.show = false;
                if (objUtilities.isNotBlank(this.versionOBJ.showCaseTypes) && !this.versionOBJ.showCaseTypes.includes(this.caseRecordTypeName)) this.versionOBJ.show = false;
                if (objUtilities.isNotBlank(this.componentOBJ.showCaseTypes) && !this.componentOBJ.showCaseTypes.includes(this.caseRecordTypeName)) this.componentOBJ.show = false;
                if (objUtilities.isNotBlank(this.subCompOBJ.showCaseTypes) && !this.subCompOBJ.showCaseTypes.includes(this.caseRecordTypeName)) this.subCompOBJ.show = false;
                if (objUtilities.isNotBlank(this.problemTypeOBJ.showCaseTypes) && !this.problemTypeOBJ.showCaseTypes.includes(this.caseRecordTypeName)) this.problemTypeOBJ.show = false;
            }
            this.strSelectedProduct = data.fields?.Forecast_Product__c?.value;
            this.strSelectedVersion = objUtilities.isNotBlank(data.fields?.Version__c?.value) ? data.fields?.Version__c?.value : 'None';
            this.strSelectedComponent = objUtilities.isNotBlank(data.fields?.Component__c?.value) ? data.fields?.Component__c?.value : 'None';
            this.strSelectedSubcomponent = objUtilities.isNotBlank(data.fields?.Subcomponent__c?.value) ? data.fields?.Subcomponent__c?.value : 'None';
            this.strSelectedProblemType = objUtilities.isNotBlank(data.fields?.Problem_Type__c?.value) ? data.fields?.Problem_Type__c?.value : 'None';

            this.processCount--;
            this.getOrgs();
            this.getProductAttributesDetails();
        }
    }

    @wire(getDelMethodsForSelectedProduct, { selectedProduct: '$strSelectedProduct'})
    wiredDelMethods({ error, data }) {
        if (error) {
            console.log("error calling getDelMethodsForSelectedProduct - ", JSON.stringify(error));
            this.processCount--;
        } else if (data) {
            console.log('data -->', JSON.stringify(data));
            this.deliveryMethodOptions=[];
            data.forEach(delMethod => {
                console.log('delMethod -->', JSON.stringify(delMethod));
                this.deliveryMethodOptions.push({label:delMethod, value:delMethod});
            });
            console.log('this.deliveryMethodOptions-->',JSON.stringify(this.deliveryMethodOptions));
            this.processCount--;
            this.getOrgs(); //<T02>
        }
    }
    
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_ENVIRONMENT})
    environments({data, error}){
        if(data){
            var environmentOptions = [];
            data.values.forEach(element => {
                environmentOptions.push({label: element.value , value : element.value});
            });
            this.environmentOptions = environmentOptions;
            console.log('this.environmentOptions-->',JSON.stringify(this.environmentOptions));
            this.processCount--;
        } else if(error){
            console.log('Error while fetching Environments');
            this.processCount--;
        }
    };
    
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_ACTIVITY_TYPE})
    activityTypes({data, error}) {
        if(data) {
            this.activityTypeOptions = [];
            data.values.forEach(element => {
                this.activityTypeOptions.push({label: element.value , value: element.value});
            });
            console.log('this.activityTypeOptions-->',JSON.stringify(this.activityTypeOptions));
            this.processCount--;
        } else if(error){
            console.log("Error while fetching Activity Types - " + JSON.stringify(error));
            this.processCount--;
        }
    };

    getOrgs() {
        let strDeliveryMethod = objUtilities.isNotBlank(this.deliveryMethod) ? this.deliveryMethod : this.origDeliveryMethod; //<T02>
        var productName = this.strSelectedProduct + '(' + strDeliveryMethod + ')'; //<T02>
        this.processCount++;
        getOrgIds({productName: productName, SuppoAccId: this.supportAccountId}) //<T04>
        .then(result => { 
            console.log('orgIds- '+JSON.stringify(result));
            
            this.orgIdOptions=[];
            result.forEach(element => {
                console.log('element->', JSON.stringify(element));
                this.orgIdOptions.push({label:element.label, value:element.value});
            });
            console.log('this.orgIdOptions-->'+JSON.stringify(this.orgIdOptions));
            this.processCount--;
        })
        .catch(error => {
            console.log('Error: '+JSON.stringify(error));
            this.processCount--;
        });
    }

    getProductAttributesDetails() {
        let objParent = this;

        getProductAttributes({ caseId: objParent.recordId })
            .then(objResponse => {
                objParent.objResponse = objResponse;
            }).catch(objError => {
                objUtilities.processException(objError, objParent);
            })
            .finally(() => {
                objParent.processCount--;
            });
    }

    /*
     Method Name : inputChange
     Description : This method updates the user input to the corresponding fields.
     Parameters	 : Object, called from inputChange, objEvent On change event.
     Return Type : None
     */
    inputChange(objEvent){
        switch (objEvent.currentTarget.name) {
            case 'deliveryMethod':
                this.deliveryMethod = objEvent.detail.value;
                this.validate(objEvent); //<T03>
                this.orgId = null; //<T02>
                this.getOrgs(); //<T02>

                //<T04>
                if(this.caseRecordTypeName == 'Fulfillment')
                {
                    this.strSelectedComponent = null;
                    this.strSelectedSubcomponent = null;
                }
                //</T04>
                break;
            case 'orgCheckbox':
                this.manualOrgFlag = objEvent.target.checked;
                break;
            case 'orgId':
                this.orgId = objEvent.detail.value;
                break;
            case 'orgManual':
                this.orgManual = objEvent.detail.value;
                break;
            case 'secureAgent':
                this.secureAgent = objEvent.detail.value;
                break;
            case 'environment':
                this.environment = objEvent.detail.value;
                this.validate(objEvent);
                break;
            case 'activityType':
                this.activityType = objEvent.detail.value;
                this.validate(objEvent);
                break;
            case 'product':
                this.strSelectedVersion = null;
                this.strSelectedProblemType = null;
                this.strSelectedComponent = null;
                this.strSelectedSubcomponent = null;
                this.deliveryMethod = null;
                this.strSelectedProduct = objEvent.target.value;
                this.orgId = null; //<T02>
                this.getOrgs(); //<T02>
                break;
            case 'version':
                this.strSelectedVersion = objEvent.target.value;
                this.validate(objEvent);
                break;
            case 'component':
                this.strSelectedComponent = objEvent.target.value;
                this.strSelectedSubcomponent = null;
                break;
            case 'subcomponent':
                this.strSelectedSubcomponent = objEvent.target.value;
                break;
            case 'problemtype':
                this.strSelectedProblemType = objEvent.target.value;
                break;            
        }
    }

    validate(objEvent) {
        if ((objUtilities.isBlank(objEvent.target.value) || objEvent.target.value === 'None') && objEvent.target.required) {
            objEvent.target.setCustomValidity(this.requiredFieldErrMsg);
            objEvent.target.reportValidity();
        }
        else {
            objEvent.target.setCustomValidity("");
            objEvent.target.reportValidity();
        }
    }

    /*
	 Method Name : cancel
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
    cancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    save(event){

        event.preventDefault(); // stop the form from submitting
      
        var validationSuccess = true;
        [...this.template.querySelectorAll('lightning-combobox')].forEach(element => {
            if (element.checkValidity()) {
                if (element.value === 'None' && element.required) {
                    element.setCustomValidity(this.requiredFieldErrMsg);
                    element.reportValidity();
                    validationSuccess = false;
                }
                else {
                    element.setCustomValidity("");
                    element.reportValidity();
                }
            }
            else if (!element.checkValidity()) {
                element.setCustomValidity(this.requiredFieldErrMsg);
                element.reportValidity();
                validationSuccess = false;
            }
        });
  
        if(validationSuccess){
            if(this.deliveryMethod === 'On Premise'){
                this.orgId = '';
                this.orgManual = '';
                this.secureAgent = '';
                this.environment = '';
                this.activityType = ''; 
            } else if(this.deliveryMethod === 'Hosted Multi Tenant'){
                this.environment = '';
                this.activityType = ''; 
            }

            if(this.manualOrgFlag){
                this.orgId = '';
            }else{
                this.orgManual = '';
            }
            
            if(objUtilities.isBlank(this.orginalOverrideDeliveryMethod) && objUtilities.isNotBlank(this.deliveryMethod)){
                this.origDelMethodProps = 'Org__c:' + (this.origOrgId == null ? '' : this.origOrgId);
                this.origDelMethodProps += ',Org_ID__c:' + (this.origOrgManual == null ? '' : this.origOrgManual);
                this.origDelMethodProps += ',Secure_Agent__c:' + (this.origSecureAgent == null ? '' : this.origSecureAgent);
                this.origDelMethodProps += ',Environment__c:' + (this.origEnvironment == null ? '' : this.origEnvironment);
                this.origDelMethodProps += ',Activity_Type__c:' + (this.origActivityType == null ? '' : this.origActivityType);
            }
            this.strSelectedProduct = this.strSelectedProduct === 'None' ? null : this.strSelectedProduct;
            this.strSelectedVersion = this.strSelectedVersion === 'None' ? null : this.strSelectedVersion;
            this.strSelectedComponent = this.strSelectedComponent === 'None' ? null : this.strSelectedComponent;
            this.strSelectedSubcomponent = this.strSelectedSubcomponent === 'None' ? null : this.strSelectedSubcomponent;
            this.strSelectedProblemType = this.strSelectedProblemType === 'None' ? null : this.strSelectedProblemType;
            
            const fields = {};
            fields[CASE_ID.fieldApiName] = this.recordId;
            fields[CASE_DELIVERY_METHOD_OVERRIDDEN_VALUE.fieldApiName] = this.deliveryMethod;
            fields[CASE_ORG.fieldApiName] = this.orgId;
            fields[CASE_ORG_ID.fieldApiName] = this.orgManual;
            fields[CASE_SECUREAGENT.fieldApiName] = this.secureAgent;
            fields[CASE_ENVIRONMENT.fieldApiName] = this.environment;
            fields[CASE_ACTIVITY_TYPE.fieldApiName] = this.activityType;
            fields[CASE_FORECAST_PRODUCT.fieldApiName] = this.strSelectedProduct;
            fields[CASE_VERSION.fieldApiName] = this.strSelectedVersion;
            fields[CASE_COMPONENT.fieldApiName] = this.strSelectedComponent;
            fields[CASE_SUBCOMPONENT.fieldApiName] = this.strSelectedSubcomponent;
            fields[CASE_PROBLEMTYPE.fieldApiName] = this.strSelectedProblemType;
            if(!this.isOverridden){
                fields[CASE_DEV_DEL_METHOD_PROPS.fieldApiName] = this.origDelMethodProps;
            }
            const recordInput = { fields };
            console.log(recordInput);

            this.processCount++;
            updateRecord(recordInput)
                .then(() => {
                    objUtilities.showToast('Success', 'Case has been updated successfully!', 'success', this);
                    this.cancel();
                    // Display fresh data in the form
                    return refreshApex(this.recordId);
                })
                .catch(error => {
                    console.log('Error overriding the delivery method: ', JSON.stringify(error));
                    objUtilities.showToast('Error', error.body.message, 'error', this);
                })
                .finally(() => {
                    this.processCount--;
                });
        }
    }

    /* Getter Methods */
    get isEPAvailable(){
        return  this.strSelectedProduct && this.strSelectedProduct !== '' && this.origDeliveryMethod && this.origDeliveryMethod !== '';
    }

    get showOrg(){
        return (this.deliveryMethod && (this.deliveryMethod === 'Hosted Single Tenant' || this.deliveryMethod === 'Hosted Multi Tenant'));
    }
    
    get showEnvironment(){
        return (this.deliveryMethod && this.deliveryMethod === 'Hosted Single Tenant');
    }

    get orgsAvailable(){
        return this.orgIdOptions && this.orgIdOptions.length;
    }

    get showSpinner(){
        return this.processCount > 0;
    }

    get isOrgIdRequired(){
        return (this.deliveryMethod && this.deliveryMethod === 'Hosted Multi Tenant');
    }

    get lstProducts() {
        let lst = [];
        this.objResponse?.allProducts.forEach(strProduct => {
            lst.push({ label: strProduct, value: strProduct });
        });
        return lst;
    }

    get lstVersions() {
        let lst = [{ label: 'None', value: 'None' }];
        if (objUtilities.isNotNull(this.objResponse?.versionsMap) && objUtilities.isObject(this.objResponse?.versionsMap) && objUtilities.isNotBlank(this.strSelectedProduct) && this.strSelectedProduct !== 'None') {
            this.objResponse.versionsMap[this.strSelectedProduct]?.forEach(strVersion => {
                lst.push({ label: strVersion, value: strVersion });
            });
        }
        return lst;
    }
    
    get lstComponents() {
        let lst = [{ label: 'None', value: 'None' }];

        //<T04>
        if(this.caseRecordTypeName == 'Fulfillment')
        {
            let strDeliveryMethod = objUtilities.isNotBlank(this.deliveryMethod) ? this.deliveryMethod : this.origDeliveryMethod;
            if (objUtilities.isNotNull(this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod]) && objUtilities.isObject(this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod])) {
                Object.keys(this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod])?.forEach(strComponent => {
                    lst.push({ label: strComponent, value: strComponent });
                });
            }
        }   //</T04>
        else
        {
            if (objUtilities.isNotNull(this.objResponse?.componentsMap) && objUtilities.isObject(this.objResponse?.componentsMap) && objUtilities.isNotBlank(this.strSelectedProduct) && this.strSelectedProduct !== 'None') {
                Object.keys(this.objResponse.componentsMap[this.strSelectedProduct])?.forEach(strComponent => {
                    lst.push({ label: strComponent, value: strComponent });
                });
            }
        }
        return lst;
    }

    get lstSubcomponents() {
        let lst = [];

        //<T04>
        if(this.caseRecordTypeName == 'Fulfillment')
        {
            let strDeliveryMethod = objUtilities.isNotBlank(this.deliveryMethod) ? this.deliveryMethod : this.origDeliveryMethod;
            if (objUtilities.isNotNull(this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod]) && objUtilities.isObject(this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod]) && objUtilities.isNotBlank(this.strSelectedComponent) && this.strSelectedComponent !== 'None') {
                this.objResponse?.fulfillmentComponentsMap[strDeliveryMethod][this.strSelectedComponent]?.forEach(strSubcomponent => {
                    lst.push({ label: strSubcomponent, value: strSubcomponent });
                });
            }
        }   //<T04>
        else
        {
            lst = [{ label: 'None', value: 'None' }];
            if (objUtilities.isNotNull(this.objResponse?.componentsMap) && objUtilities.isObject(this.objResponse?.componentsMap) && objUtilities.isNotBlank(this.strSelectedProduct) && objUtilities.isNotBlank(this.strSelectedComponent) && this.strSelectedComponent !== 'None') {
                this.objResponse.componentsMap[this.strSelectedProduct][this.strSelectedComponent]?.forEach(strSubcomponent => {
                    lst.push({ label: strSubcomponent, value: strSubcomponent });
                });
            }
        }
        return lst;
    }

    get lstProblemTypes() {
        let lst = [{ label: 'None', value: 'None' }];
        if (objUtilities.isNotNull(this.objResponse?.problemsMap) && objUtilities.isObject(this.objResponse?.problemsMap)) {
            let strKey = this.caseRecordTypeName == 'Operations' ? this.caseRecordTypeName : (this.caseRecordTypeName == 'Technical' && objUtilities.isNotBlank(this.caseDeliveryMethod) ? this.caseRecordTypeName + this.caseDeliveryMethod.replace(/\s+/g, '') : '');
            this.objResponse.problemsMap[strKey]?.forEach(strProblemType => {
                lst.push({ label: strProblemType, value: strProblemType });
            });
        }
        return lst;
    }

    get lstOriginalDeliveryMethods() {
        let lst = [];
        if (objUtilities.isNotBlank(this.origDeliveryMethod)) lst.push({ label: this.origDeliveryMethod, value: this.origDeliveryMethod });
        return lst;
    }

    get disableVersion() {
        return objUtilities.isNotBlank(this.strSelectedProduct) && this.strSelectedProduct !== 'None' ? false : true;
    }

    get disableComponent() {
        return objUtilities.isNotBlank(this.strSelectedProduct) && this.strSelectedProduct !== 'None' ? false : true;
    }

    get disableSubcomponent() {
        return objUtilities.isNotBlank(this.strSelectedComponent) && this.strSelectedComponent !== 'None' ? false : true;
    }
}