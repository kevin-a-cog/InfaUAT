import { LightningElement, api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getFields from '@salesforce/apex/ProductRequestFlowController.getFields';
import getProducts from '@salesforce/apex/ProductRequestFlowController.getProducts';
import getPicklistValues from '@salesforce/apex/ProductRequestFlowController.getPicklistValues';

//Labels
import PRM_EngagmentProduct_Title from '@salesforce/label/c.PRM_EngagmentProduct_Title';
import PRM_EngagmentProduct_Desc from '@salesforce/label/c.PRM_EngagmentProduct_Desc';
import PRM_EngagmentProduct_Desc1 from '@salesforce/label/c.PRM_EngagmentProduct_Desc1';
import PRM_EngagmentProduct_Product2 from '@salesforce/label/c.PRM_EngagmentProduct_Product2';
import PRM_EngagmentProduct_Product from '@salesforce/label/c.PRM_EngagmentProduct_Product';
import PRM_EngagmentProduct_Product1 from '@salesforce/label/c.PRM_EngagmentProduct_Product1';
import PRM_SerialNumberError from '@salesforce/label/c.PRM_SerialNumberError';


export default class AddEditProductsEngagement extends LightningElement {

    label={
        PRM_EngagmentProduct_Title,
        PRM_EngagmentProduct_Desc,
        PRM_EngagmentProduct_Desc1,
        PRM_EngagmentProduct_Product2,
        PRM_EngagmentProduct_Product,
        PRM_EngagmentProduct_Product1,
        PRM_SerialNumberError
    };
    @track isModalOpen = false;
    recordId;
    callOnce = true;
    showAddProduct = true;
    showSpinner = false;

    fieldStrQuery;
    searchValue = '';
    @track productList = [];
    productWrap;
    productWrapCopy;
    fieldarray = [];

    selectedProducts = [];
    activeTab = 'one';

    @api
    get finalproductlist(){
        return this.productList;
    }
    set finalproductlist(value){

        this.productList = value;

        if(this.productList){
            let finalIds = [];
            this.productList.forEach(value =>{
                finalIds.push(value.prod.Id);
            });

            if(finalIds && this.productWrap && this.productWrap.productWrap){
                this.productWrap = JSON.parse(JSON.stringify(this.productWrap));

                this.productWrap.productWrap.forEach(value => {
                    if(finalIds.includes(value.prod.Id)){
                        value.isSelected = true;
                    }
                });
            }
        }
    }

    @api
    openModal(){
        this.isModalOpen = true;
    }

    /**
     * @description : method to close the on prem product modal
     */
    async closeModal() {
        this.doGeneralReset();
        this.dispatchEvent(new CustomEvent('closemodal', {
            detail: {
                message: 'true'
            }
        }));
    }

    submitDetails() {
        this.isModalOpen = false;
    }

    connectedCallback(){
        if(this.callOnce){
            this.toggleSpinner(true);
            this.getFieldVals();
            this.callOnce = false;
        }
    }

    async getFieldVals(){

        await this.getFields();
        await this.searchProducts();
    }

    async getFields(){

        let res = await getFields({typeName: 'Product2', fsName: 'PRM_AddProductsFieldSet'})
        .catch(error => {
            console.error(JSON.stringify(error));
        });
        this.fieldarray = res;

        let fieldStrq = ""; 
        for (var key in res){
            if (!res.hasOwnProperty(key)){
                continue; 
            }

            var obj = res[key]; 
            fieldStrq += (obj.fieldPath + ","); 
        }
        this.fieldStrQuery = fieldStrq.replace(/,\s*$/, "");
    }

    async searchProducts(){
        
        let result = await getProducts({searchKeyWord : this.searchValue, fieldsStrQry : this.fieldStrQuery})
        .catch(error => {
            console.error(JSON.stringify(error));
        });

        this.productWrap = result;

        if(this.productList && this.productList.length > 0 && this.productWrap && this.productWrap.productWrap){

            let finalIds = [];
            this.productList.forEach(value =>{
                finalIds.push(value.prod.Id);
            });

            this.productWrap = JSON.parse(JSON.stringify(this.productWrap));

            this.productWrap.productWrap.forEach(value => {
                if(finalIds.includes(value.prod.Id)){
                    value.isSelected = true;
                }
            });
        }

        this.productWrapCopy = JSON.parse(JSON.stringify(this.productWrap));
        this.toggleSpinner(false);
    }

    async onSearchValue(event){
        let val = event.currentTarget.value;
        this.searchValue = val;

        if(this.searchValue.length >= 3 || 
            this.searchValue === '' || 
            this.searchValue === undefined){

            await this.searchProducts();
        }
    }

    get showProducts(){
        return this.productWrap && this.productWrap.productWrap && this.productWrap.productWrap.length > 0;
    }

    handlePlusClick(event){
        var target = event.target;  
        var selectedProductId = target.getAttribute("data-contact-id");

        if(this.productWrap && this.productWrap.productWrap){
            this.productWrap = JSON.parse(JSON.stringify(this.productWrap));
            this.productList = JSON.parse(JSON.stringify(this.productList));

            this.productWrap.productWrap.forEach(value => {

                if(value.prod.Id === selectedProductId){
                    value.isSelected = true;
                    this.productList.push(value);
                }
            });
        }
    }

    handlePillRemove(event){
        let target = event.target;
        let prodId = target.getAttribute("data-id");
        let index = target.getAttribute("data-index");
        this.productList = JSON.parse(JSON.stringify(this.productList));

        if(this.productList && this.productList.length > index){
            this.productList.splice(index,1);
        }

        this.productWrap.productWrap.forEach(value => {

            if(value.prod.Id === prodId){
                value.isSelected = false;
            }
        });
    }

    get nextButtonLabel(){
        return this.activeTab === 'one' ? 'Add/Update Products' : 'Save';
    }

    get disableAddProducts(){
        return this.productList.length === 0;
    }

    tabChange(event){
        this.activeTab = event.target.value;
    }
    
    addProducts(){

        if(this.nextButtonLabel === 'Add/Update Products'){
            this.activeTab = 'two';
        }
        else if(this.nextButtonLabel === 'Save' && this.activeTab === 'two'){

            let retVal = this.validateValues();
            if(!retVal){
                this.showToast("Error", this.label.PRM_SerialNumberError,"Error");
                return;
            }
            this.dispatchEvent(new CustomEvent('saveclick', {
                detail: {
                    message: JSON.stringify( this.productList )
                }
            }));
            this.doGeneralReset();
        }
    }

    validateValues(){
        let retVal = true;
        this.productList.forEach(val => {

            if(val.renewLicense === true && (val.serialnumber === '' || val.serialnumber === null || val.serialnumber === undefined)){
                retVal = false;
            }
        });
        
        return retVal;
    }

    doGeneralReset(){
        this.showAddProduct = true;
        this.activeTab = 'one';
        this.isModalOpen = false;
    }

    async getPickListValuesLocal(){
        this.toggleSpinner(false);
    }

    toggleSpinner(value){
        this.showSpinner = value;
    }

    handleValueChange(event){
        let target = event.currentTarget;
        var selectedProductId = target.getAttribute("data-id");
        let compName = target.getAttribute("data-name");

        let copy = JSON.parse(JSON.stringify(this.productList));
        this.productList.forEach(function(value,index){

            if(value.prod.Id === selectedProductId){
                
                if(compName === 'renewlicense'){
                    copy[index].renewLicense = target.checked;
                }
                else if(compName === 'serialnumber'){
                    copy[index].serialnumber = target.value;
                }
                else if(compName === 'reqorproductversion'){
                    copy[index].reqorproductversion = target.value;
                }
            }
        });

        this.productList = copy;
    }

    handleProductRemoval(event){
        let target = event.currentTarget;
        var selectedProductId = target.getAttribute("data-prodid");
        var index = target.getAttribute("data-index");

        this.productList = JSON.parse(JSON.stringify(this.productList));
        if(this.productList.length > index){
            this.productList.splice(index,1);
        }

        if(this.productWrap && this.productWrap.productWrap){
            this.productWrap.productWrap.forEach(value => {

                if(value.prod.Id === selectedProductId){
                    value.isSelected = false;
                }
            });
        }
    }

    showToast( title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}