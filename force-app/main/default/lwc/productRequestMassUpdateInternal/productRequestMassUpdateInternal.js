import { LightningElement, api, track, wire} from 'lwc';

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import retrieveMdmProducts from '@salesforce/apex/ProductRequestFlowController.retrieveMdmProducts';
import retrieveCloudProducts from '@salesforce/apex/ProductRequestFlowController.retrieveCloudProducts';
import retrieveCdgcProducts from '@salesforce/apex/ProductRequestFlowController.retrieveCdgcProducts';
import retrieveOnPremProducts from '@salesforce/apex/ProductRequestFlowController.retrieveOnPremProducts';
import updateProductRequests from '@salesforce/apex/ProductRequestFlowController.updateProductRequests';

export default class ProductRequestMassUpdateInternal extends LightningElement {

    @api recordId;
    tempRecordId;

    @track showSpinner = true;
    
    @track mdmData;
    @track mdmError;
    @track rejected = false;
    mdmSelectedRows = [];
    
    @track cloudData;
    @track cloudError;
    cloudSelectedRows = [];

    @track cdgcData;
    @track cdgcError;
    cdgcSelectedRows = [];

    @track onPremData;
    @track onPremError;
    onPremSelectedRows = [];

    activeTab = 'cloud';

    columns = [
        { label: 'Product Request Name', fieldName: 'Name' },
        { label: 'Product', fieldName: 'ProductName'},
        { label: 'Status', fieldName: 'Status__c'}
    ];

    mdmProductsTemp = [];
    cloudProductsTemp = [];
    cdgcProductsTemp = [];
    onPremProductsTemp = [];

    /**
     * @description : method to retrieve mdm products
     */
    @wire(retrieveMdmProducts, {engagementId:'$recordId'})
    wiredMDMProducts(result) {
        this.mdmProductsTemp = result;

        if (result.data) {
            let tempData = JSON.parse(JSON.stringify(result.data));
            tempData.forEach( val => {
                val.ProductName = val.Product__r.Name;
            });
            this.mdmData = tempData;
            this.mdmError = undefined;
            this.toggleSpinner(false);
        } else if (result.error) {
            this.mdmError = result.error;
            this.mdmData = undefined;
            this.toggleSpinner(false);
        }
    }

    /**
     * @description : method to retrieve cloud products
     */
    @wire(retrieveCloudProducts, {engagementId:'$recordId'})
    wiredCloudProducts(result) {
        this.cloudProductsTemp = result;

        if (result.data) {
            let tempData = JSON.parse(JSON.stringify(result.data));
            tempData.forEach( val => {
                val.ProductName = val.Product__r.Name;
            });
            this.cloudData = tempData;
            this.cloudError = undefined;
            this.toggleSpinner(false);
        } else if (result.error) {
            this.cloudError = result.error;
            this.cloudData = undefined;
            this.toggleSpinner(false);
        }
    }

    /**
     * @description : method to retrieve cdgc products
     */
    @wire(retrieveCdgcProducts, {engagementId:'$recordId'})
    wiredCDGCProducts(result) {
        this.cdgcProductsTemp = result;
        if (result.data) {
            let tempData = JSON.parse(JSON.stringify(result.data));
            tempData.forEach( val => {
                val.ProductName = val.Product__r.Name;
            });
            this.cdgcData = tempData;
            this.cdgcError = undefined;
            this.toggleSpinner(false);
        } else if (result.error) {
            this.cdgcError = result.error;
            this.cdgcData = undefined;
            this.toggleSpinner(false);
        }
    }

    /**
     * @description : method to retrieve on premise products
     */
    @wire(retrieveOnPremProducts, {engagementId:'$recordId'})
    wiredOnPremProducts(result) {
        this.onPremProductsTemp = result;
        if (result.data) {
            let tempData = JSON.parse(JSON.stringify(result.data));
            tempData.forEach( val => {
                val.ProductName = val.Product__r.Name;
            });
            this.onPremData = tempData;
            this.onPremError = undefined;
            this.toggleSpinner(false);
        } else if (result.error) {
            this.onPremError = result.error;
            this.onPremData = undefined;
            this.toggleSpinner(false);
        }
    }

    statusOnChange(event){
        let value = event.target.value;

        if(value === 'Rejected'){
            this.rejected = true;
        }
        else{
            this.rejected = false;
        }
    }

    tabChange(event){
        this.activeTab = event.target.value;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async onSubmitHandler(event){
        event.stopPropagation();
        event.preventDefault();
        const fields = event.detail.fields;
        let val = this.validateFields(fields);

        if(val === false){
            return;
        }
        let finalSelectedRows = [];

        if(this.mdmSelectedRows && this.mdmSelectedRows.length > 0){
            finalSelectedRows = finalSelectedRows.concat(this.mdmSelectedRows);
        }
        if(this.cloudSelectedRows && this.cloudSelectedRows.length > 0){
            finalSelectedRows = finalSelectedRows.concat(this.cloudSelectedRows);
        }
        if(this.cdgcSelectedRows && this.cdgcSelectedRows.length > 0){
            finalSelectedRows = finalSelectedRows.concat(this.cdgcSelectedRows);
        }
        if(this.onPremSelectedRows && this.onPremSelectedRows.length > 0){
            finalSelectedRows = finalSelectedRows.concat(this.onPremSelectedRows);
        }

        if(finalSelectedRows && finalSelectedRows.length > 0){

            this.toggleSpinner(true);
            let productRequestIds = [];

            finalSelectedRows.forEach(val => {
                productRequestIds.push(val.Id);
            });

            let finalStatus = true;
            let value = await updateProductRequests({productRequestIds : productRequestIds, values : fields })
            .catch(error => {
                finalStatus = false;
                this.showToast("Something went wrong!",JSON.stringify(error),"Error");
                this.toggleSpinner(false);
            });
            this.toggleSpinner(false);
            if(finalStatus){
                this.showToast("Success!","Product Request Updated Successfully","Success");
                this.refreshRecords();
                this.closeQuickAction();
            }
        }
        else{
            this.showToast("Please select product requests","No product request selected, please select to proceed.","Error");
        }
    }

    validateFields(fields){
        if(fields.Status__c === 'Rejected'){
            
            if(fields.Rejection_Reason__c === undefined || fields.Rejection_Reason__c === null || fields.Rejection_Reason__c === ''){
                this.showToast("Please provide neccessary fields","Rejection reason is needed when updating status as rejected","Error");
                return false;
            }
        }
        else{
            if(fields.Status__c !== null && fields.Status__c === 'Fulfilled' && fields.Fulfillment_Date__c === null){
                this.showToast("Please provide neccessary fields","Please provide fulfillment date for fulfilled status","Error");
                return false;
            }
            if(fields.Status__c === null){ //|| fields.Fulfillment_Date__c === null || fields.License_Key_Org_ID__c === null
                
                this.showToast("Please provide neccessary fields","Please provide status.","Error");
                return false;
            }
        }
        return true;
    }

    onRowSelectionMdm( event ) {
        const selectedRows = event.detail.selectedRows;
        this.mdmSelectedRows = selectedRows;
    }

    onRowSelectionCloud( event ) {
        const selectedRows = event.detail.selectedRows;
        this.cloudSelectedRows = selectedRows;
    }

    onRowSelectionCdgc( event ) {
        const selectedRows = event.detail.selectedRows;
        this.cdgcSelectedRows = selectedRows;
    }

    onRowSelectionOnPrem( event ) {
        const selectedRows = event.detail.selectedRows;
        this.onPremSelectedRows = selectedRows;
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

    toggleSpinner(val){
        this.showSpinner = val;
    }

    refreshRecords(){
        refreshApex(this.cloudProductsTemp);
        refreshApex(this.mdmProductsTemp);
        refreshApex(this.cdgcProductsTemp);
        refreshApex(this.onPremProductsTemp);
    }
}