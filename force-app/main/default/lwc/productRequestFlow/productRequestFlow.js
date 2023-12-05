import { LightningElement,api, track, wire } from 'lwc';

import getMDMServices from '@salesforce/apex/ProductRequestFlowController.getMDMServices';
import getCDGCServices from '@salesforce/apex/ProductRequestFlowController.getCDGCServices';
import getCloudervices from '@salesforce/apex/ProductRequestFlowController.getCloudervices';
import saveProductRequest from '@salesforce/apex/ProductRequestFlowController.saveProductRequest';
import getPicklistValues from '@salesforce/apex/ProductRequestFlowController.getPicklistValues';
import getDataForExistingRecord from '@salesforce/apex/ProductRequestFlowController.getDataForExistingRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import PRM_CommunityUrl from '@salesforce/label/c.PRM_CommunityUrl';
import PRM_OldEngagementError from '@salesforce/label/c.PRM_OldEngagementError';
import PRM_CISHelptext from '@salesforce/label/c.PRM_CISHelptext';
import PRM_OrgIdHelptext from '@salesforce/label/c.PRM_OrgIdHelptext';
import PRM_SomethingWentWrong from '@salesforce/label/c.PRM_SomethingWentWrong';
import PRM_SuccessMessage from '@salesforce/label/c.PRM_SuccessMessage';
import PRM_MissingProductError from '@salesforce/label/c.PRM_MissingProductError';
import PRM_MissingFieldsError from '@salesforce/label/c.PRM_MissingFieldsError';
import PRM_ErrorMessage1 from '@salesforce/label/c.PRM_ErrorMessage1';
import PRM_ErrorMessage2 from '@salesforce/label/c.PRM_ErrorMessage2';
import PRM_ErrorMessage3 from '@salesforce/label/c.PRM_ErrorMessage3';
import PRM_ErrorMessage4 from '@salesforce/label/c.PRM_ErrorMessage4';


export default class ProductRequestFlow extends NavigationMixin(LightningElement) {

    label = {
        PRM_CommunityUrl,
        PRM_OldEngagementError,
        PRM_CISHelptext,
        PRM_OrgIdHelptext,
        PRM_SomethingWentWrong,
        PRM_SuccessMessage,
        PRM_MissingProductError,
        PRM_MissingFieldsError,
        PRM_ErrorMessage1,
        PRM_ErrorMessage2,
        PRM_ErrorMessage3,
        PRM_ErrorMessage4
    };

    activeSectionNames = [];
    activeSectionNamesChild = [];
    isSubmit = false;

    showProductScreen = true;
    callonce = true;
    callonetime = true;

    @track mdmListOptions = [];
    @track cdgcOptions = [];
    @track selectedMDMValues = [];
    @track selectedCDGCValues = [];
    @track trainingCompletedOption = [];
    @track provisionEnvironmentOptions = [];
    @track cisCustomerOptions = [];
    @track requestReasonOptions = [];

    @track cloudServiceMandate = false;
    @track workingOpportunityMandate = false;

    @track hideProductPage = false;
    @track disableButtons = false;
    @track showSpinner = false;

    
    mdmPreExistingMap = {};
    cdgcPreExistingMap = {};

    cloudOrgId;
    provisionEnvironment;
    trainingCompletedCloud;
    mdmOrgId;
    trainingCompletedMdm;
    cdgcOrgId;
    trainingCompletedCdgc;
    @track onPremTrainingComp = '';

    @track defaultCloudProduct = {};
    @track onPremProducts = [];

    mdmExtraInfo = {};
    cdgcExtraInfo = {};
    cloudProduct = {};
    mdmProducts;
    cdgcProducts;

    engagementData = {
        Name : '',
        Are_you_working_on_Opportunity__c : false,
        Is_customer_in_a_CIS_country__c : '',
        How_will_this_software_be_used__c : '',
        Customer_Name__c : '',
        Opportunity_Id__c : '',
        Comments__c : '',
        Enable_Cloud_Service__c : ''
    };
    productRequestData = [];

    errorMessage = this.label.PRM_OldEngagementError;

    /**
     * @description : method to get record Id
     */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    _currentPageReference;

    @track recordId;

    get currentPageReference(){
        return this._currentPageReference;
    }
    set currentPageReference(val){
        this._currentPageReference = val;

        if(this._currentPageReference && this._currentPageReference.state && this._currentPageReference.state.c__recordId && this.callonetime){
            this.recordId = this._currentPageReference.state.c__recordId;
            this.getData();
            this.callonetime = false;
        }
    }

    async getData(){
        try{
            await this.preloadData();
        }
        catch(error){
            console.error(JSON.stringify(error));
        }
    }

    workingOppChange(event){
        let val = event.detail.checked;
        this.workingOpportunityMandate = val;
    }

    showProducts(){
        this.template.querySelector("c-add-edit-products-engagement").openModal();
    }

    getSaveData(event){
        let message = event.detail.message;
        this.onPremProducts = JSON.parse(message);
    }

    async onSubmitHandler(){
        this.toggleSpinner(true);
        await this.finalizeDataMethod();
    }

    async saveAsDraft(){
        this.isSubmit = false;
        this.disableButtons = true;
        await this.onSubmitHandler();
    }

    async submitClick(){
        this.isSubmit = true;
        this.disableButtons = true;
        await this.onSubmitHandler();
    }

    async connectedCallback(){

        if(this.callonce){
            let val = this.recordId;
            this.toggleSpinner(true);
            this.getMdmAndCdgcValues();
            await this.getPickListValuesLocal();
            this.toggleSpinner(false);
            this.callonce = false;
        }
    }

    async getMdmAndCdgcValues(){

        let mdmServices = await getMDMServices({})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });

        if(mdmServices){
            for (var key in mdmServices) {
                this.mdmListOptions.push( {label : mdmServices[key], value : key} );
            }
        }

        let cdgcServices = await getCDGCServices({})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });

        if(cdgcServices){
            for (var key in cdgcServices) {
                this.cdgcOptions.push( {label : cdgcServices[key], value : key} );
            }
        }

        let cloudService = await getCloudervices({})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });

        if(cloudService){
            this.defaultCloudProduct = cloudService;
        }
    }

    handleMDMChange(e){
        this.selectedMDMValues = e.detail.value;
    }

    handleCDGCChange(e){
        this.selectedCDGCValues = e.detail.value;
    }

    onPremChange(event){
        let val = event.currentTarget.value;
        this.onPremTrainingComp = val;
    }

    enableCloudService(event){
        let val = event.target.checked;
        if(val){
            this.cloudServiceMandate = true;
        }
        else{
            this.cloudServiceMandate = false;
        }
    }

    get disableCloudService(){
        return !this.cloudServiceMandate;
    }

    async finalizeDataMethod(){

        let allowExecute = true;
        if(!this.basicValidation()){
            allowExecute = false;
            this.toggleSpinner(false);
        }
        if(allowExecute){
            this.mdmProducts = this.finalMDM();
            this.cdgcProducts = this.finalCDGC();
            this.onPremProducts = this.finalOnPrem();

            this.productRequestData = [];
            this.finalProductList();

            if(this.recordId){
                this.engagementData["Id"] = this.recordId;
            }

            let finalEngagementData = JSON.parse(JSON.stringify(this.engagementData));

            if(this.engagementData && this.engagementData.How_will_this_software_be_used__c !== undefined && this.engagementData.How_will_this_software_be_used__c !== null && this.engagementData.How_will_this_software_be_used__c !== ''){
                let finalVal = this.engagementData.How_will_this_software_be_used__c.join(';');
                finalEngagementData.How_will_this_software_be_used__c = finalVal;
            }

            if(((this.productRequestData && this.isSubmit && this.productRequestData.length > 0) || !this.isSubmit)){
                
                let finalVal = {'engagement' : finalEngagementData, 'products' : this.productRequestData};
                let success = true;

                let result = await saveProductRequest({jsonVal : JSON.stringify(finalVal), isSubmit : this.isSubmit})
                .catch(e =>{
                    this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(e),"Error");
                    this.toggleSpinner(false);
                    success = false;
                });
                if(success){
                    this.showToast("Success!",this.label.PRM_SuccessMessage,"Success");
                    this.recordId = result;
                    if(this.recordId){
                        this.goBack();
                    }
                    else{
                        this.navigateToRequestHome();
                    }
                    this.toggleSpinner(false);
                }
            }
            else if(this.isSubmit){
                this.showToast("No Products Found!",this.label.PRM_MissingProductError,"Error");
                this.toggleSpinner(false);
            }
            else{
                this.showToast(this.label.PRM_SomethingWentWrong,"Please resubmit","Error");
                this.toggleSpinner(false);
            }
        }
    }

    checkAndPushProducts(val){

        let contain = false;
        this.productRequestData.forEach(value => {
            if(value.prod.Id === val.Id){
                contain = true;
            }
        });
        if(!contain){
            this.productRequestData.push(val);
        }
    }

    cloudServiceChange(event){
        let val = event.currentTarget.value;
        let target = event.currentTarget;
        var fieldName = target.getAttribute("data-name");


        if(fieldName === 'provisionEnvironment'){
            this.cloudProduct['provisioningEnvironment'] = val;
            this.provisionEnvironment = val;
        }
        else if(fieldName === 'cloudTrainingCompleted'){
            this.cloudProduct['trainingCompleted'] = val;
            this.trainingCompletedCloud = val;
        }
        else if(fieldName === 'cloudorgid'){
            this.cloudProduct['orgId'] = val;
        }

        this.cloudProduct["prod"] = this.defaultCloudProduct;
        this.cloudProduct["productFamily"] = "Cloud";
    }

    mdmChange(event){
        let val = event.currentTarget.value;
        let target = event.currentTarget;
        var fieldName = target.getAttribute("data-name");

        if(fieldName === 'trainingCompletedMdm'){
            this.mdmExtraInfo['trainingCompleted'] = val;
        }
        else if(fieldName === 'mdmorgid'){
            this.mdmExtraInfo['orgId'] = val;
        }
    }

    cdgcChange(event){

        let target = event.currentTarget;
        var fieldName = target.getAttribute("data-name");

        let val = event.currentTarget.value;

        if(fieldName === 'cdgcTrainingCompleted'){
            this.cdgcExtraInfo['trainingCompleted'] = val;
        }
        else if(fieldName === 'cdgcorgid'){
            this.cdgcExtraInfo['orgId'] = val;
        }
    }

    finalMDM(){
        let finalMap = [];

        for(let val in this.selectedMDMValues){
            let temp = {};
            let mdmVal = this.selectedMDMValues[val];
            temp = JSON.parse(JSON.stringify(this.mdmExtraInfo));
            temp["prod"] = {"Id" : mdmVal};
            temp["productFamily"] = "MDM";

            if(this.mdmPreExistingMap && this.mdmPreExistingMap.hasOwnProperty(mdmVal)){
                temp["Id"] = this.mdmPreExistingMap[mdmVal];
            }

            finalMap.push(temp);
        }

        return finalMap;
    }

    finalCDGC(){
        let finalMap = [];

        for(let val in this.selectedCDGCValues){
            let temp = {};
            let cdgcVal = this.selectedCDGCValues[val];
            temp = JSON.parse(JSON.stringify(this.cdgcExtraInfo));
            temp["prod"] = {"Id" : cdgcVal};
            temp["productFamily"] = "CDGC";

            if(this.cdgcPreExistingMap && this.cdgcPreExistingMap.hasOwnProperty(cdgcVal)){
                temp["Id"] = this.cdgcPreExistingMap[cdgcVal];
            }

            finalMap.push(temp);
        }

        return finalMap;
    }

    finalOnPrem(){
        let finalProducts = JSON.parse(JSON.stringify(this.onPremProducts));

        finalProducts.forEach(value =>{
            value['trainingCompleted'] = this.onPremTrainingComp;
            value["productFamily"] = "OnPremise";
        })
        return finalProducts;
    }
    
    finalProductList(){
        this.productRequestData = JSON.parse(JSON.stringify(this.productRequestData));

        if(this.cloudServiceMandate && this.cloudProduct && Object.keys(this.cloudProduct).length > 0){
            this.productRequestData.push(this.cloudProduct);
        }

        if(this.mdmProducts && this.mdmProducts.length > 0){
            this.productRequestData.push(...this.mdmProducts);
        }

        if(this.cdgcProducts && this.cdgcProducts.length > 0){
            this.productRequestData.push(...this.cdgcProducts);
        }

        if(this.onPremProducts && this.onPremProducts.length > 0){
            this.productRequestData.push(...this.onPremProducts);
        }
    }

    async getPickListValuesLocal(){

        let res1 = await getPicklistValues({ObjectAPIName : 'Product_Request__c', fieldAPIName : 'Training_Completed__c'})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });
        this.trainingCompletedOption = res1;

        let res2 = await getPicklistValues({ObjectAPIName : 'Product_Request__c', fieldAPIName : 'Provisioning_Environment__c'})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });
        this.provisionEnvironmentOptions = res2;

        let res3 = await getPicklistValues({ObjectAPIName : 'Engagement__c', fieldAPIName : 'Is_customer_in_a_CIS_country__c'})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });
        this.cisCustomerOptions = res3;

        let res4 = await getPicklistValues({ObjectAPIName : 'Engagement__c', fieldAPIName : 'How_will_this_software_be_used__c'})
        .catch(error => {
            this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(error),"Error");
        });
        this.requestReasonOptions = res4;
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

    basicValidation(){

        if(this.engagementData.Name === undefined || this.engagementData.Name === null || this.engagementData.Name === ''){
            this.showToast(this.label.PRM_MissingFieldsError, this.label.PRM_ErrorMessage1, "Error");
            return false;
        }
        else if(this.engagementData.How_will_this_software_be_used__c === undefined || this.engagementData.How_will_this_software_be_used__c === null || this.engagementData.How_will_this_software_be_used__c === ''){
            this.showToast(this.label.PRM_MissingFieldsError,this.label.PRM_ErrorMessage1, "Error");
            return false;
        }
        else if(this.engagementData.Are_you_working_on_Opportunity__c === true){
            if(this.engagementData.Is_customer_in_a_CIS_country__c === undefined || this.engagementData.Is_customer_in_a_CIS_country__c === null || this.engagementData.Is_customer_in_a_CIS_country__c === ''){
                this.showToast(this.label.PRM_MissingFieldsError, this.label.PRM_ErrorMessage2, "Error");
                return false;
            }
            else if(this.engagementData.Customer_Name__c === undefined || this.engagementData.Customer_Name__c === null || this.engagementData.Customer_Name__c === ''){
                this.showToast(this.label.PRM_MissingFieldsError, this.label.PRM_ErrorMessage2, "Error");
                return false;
            }
            else if(this.engagementData.Opportunity_Id__c === undefined || this.engagementData.Opportunity_Id__c === null || this.engagementData.Opportunity_Id__c === ''){
                this.showToast(this.label.PRM_MissingFieldsError, this.label.PRM_ErrorMessage2, "Error");
                return false;
            }
        }
        if(this.cloudServiceMandate && (
            (this.provisionEnvironment === undefined || this.provisionEnvironment === null || this.provisionEnvironment === '') ||
            (this.trainingCompletedCloud === undefined || this.trainingCompletedCloud === null || this.trainingCompletedCloud === '')
        )){
            this.showToast(this.label.PRM_MissingFieldsError, this.label.PRM_ErrorMessage3, "Error");
            return false;
        }

        return true;
    }

    toggleSpinner(value){
        this.showSpinner = value;
    }

    navigateToRequestHome(){
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Engagement__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' 
            }
        });
    }

    async preloadData(){

        try{
            if(this.recordId !== undefined && this.recordId !== null && this.recordId !== ''){
                let result = await getDataForExistingRecord({recordId : this.recordId})
                .catch(err => {
                    this.showToast(this.label.PRM_SomethingWentWrong,JSON.stringify(err),"Error");
                    throw err;
                });
    
                let finalResult = JSON.parse(result);
                this.engagementData = finalResult['engagement'];
                this.productRequestData = finalResult['products'];
    
                if(this.engagementData && this.engagementData.New_Flow_Request__c !== true){
                    this.hideProductPage = true;
                }
    
                if(this.engagementData && this.engagementData.Status__c !== 'Not Submitted' && this.engagementData.Status__c !== '' && this.engagementData.Status__c !== null){
                    this.hideProductPage = true;
                    this.errorMessage = this.label.PRM_ErrorMessage4;
                }

                if(this.engagementData.How_will_this_software_be_used__c !== null && this.engagementData.How_will_this_software_be_used__c !== undefined && this.engagementData.How_will_this_software_be_used__c !== ''){
                    let valueList = this.engagementData.How_will_this_software_be_used__c.split(';');
                    this.engagementData.How_will_this_software_be_used__c = valueList;
                }
    
                if(this.productRequestData){
    
                    let cloudProductTemp;
                    let mdmProductsTemp = [];
                    let cdgcProductsTemp = [];
                    let onPremProductsTemp = [];
    
                    this.productRequestData.forEach(value =>{
    
                        if(value.productFamily === 'Cloud'){
                            cloudProductTemp = value;
                        }
                        else if(value.productFamily === 'MDM'){
                            mdmProductsTemp.push(value);
                        }
                        else if(value.productFamily === 'CDGC'){
                            cdgcProductsTemp.push(value);
                        }
                        else if(value.productFamily === 'OnPremise'){
                            onPremProductsTemp.push(value);
                        }
                    });
    
                    if(cloudProductTemp){
                        this.cloudServiceMandate = true;
                        this.provisionEnvironment = cloudProductTemp.provisioningEnvironment;
                        this.trainingCompletedCloud = cloudProductTemp.trainingCompleted;
                        this.cloudOrgId = cloudProductTemp.orgId;
                        this.cloudProduct = cloudProductTemp;
                    }
                    let finalMdmValueMapTemp = {};
                    if(mdmProductsTemp){
                        let mdmTrainingCompleted;
                        let mdmOrg;
                        let selectedMdm = [];
                        mdmProductsTemp.forEach(value =>{
                            if(value.prod.Id){
                                selectedMdm.push(value.prod.Id);
                                finalMdmValueMapTemp[value.prod.Id] = value.Id;
                            }
                            mdmOrg = value.orgId;
                            mdmTrainingCompleted = value.trainingCompleted;
                        });
                        this.mdmPreExistingMap = finalMdmValueMapTemp;
                        this.selectedMDMValues = selectedMdm;
                        this.mdmOrgId = mdmOrg;
                        this.trainingCompletedMdm = mdmTrainingCompleted;
                    }
                    let finalCdgcValueMapTemp = {};
                    if(cdgcProductsTemp){
                        let cdgcTrainingCompletedTemp;
                        let cdgcOrg;
                        let selectedCDGC = [];
                        cdgcProductsTemp.forEach(value => {
                            if(value.prod.Id){
                                selectedCDGC.push(value.prod.Id);
                                finalCdgcValueMapTemp[value.prod.Id] = value.Id;
                            }
                            cdgcOrg = value.orgId;
                            cdgcTrainingCompletedTemp = value.trainingCompleted;
                        });
                        this.cdgcPreExistingMap = finalCdgcValueMapTemp;
                        this.selectedCDGCValues = selectedCDGC;
                        this.cdgcOrgId = cdgcOrg;
                        this.trainingCompletedCdgc = cdgcTrainingCompletedTemp;
                    }
    
                    if(onPremProductsTemp && onPremProductsTemp.length > 0){
    
                        onPremProductsTemp.forEach(value =>{
                            value.isSelected = true;
                        });
    
                        this.onPremProducts = JSON.parse(JSON.stringify(onPremProductsTemp));
                        this.onPremTrainingComp = onPremProductsTemp[0].trainingCompleted;
                    }
                }
            }
        }
        catch(error){
            if(error){
                console.error(JSON.stringify(error));
            }
        }
    }

    goBack(){
        let labelVal = this.label.PRM_CommunityUrl;
        labelVal += 'detail/'+this.recordId;
        window.open(labelVal, "_self");
    }

    engagementDataChange(event){

        let target = event.currentTarget;
        var fieldName = target.getAttribute("data-name");

        if(fieldName === 'Name'){
            this.engagementData.Name = target.value;
        }
        else if(fieldName === 'Are_you_working_on_Opportunity__c'){
            let val = event.detail.checked;
            this.engagementData.Are_you_working_on_Opportunity__c = val;
            this.workingOpportunityMandate = val;
        }
        else if(fieldName === 'Is_customer_in_a_CIS_country__c'){
            let val = event.currentTarget.value;
            this.engagementData.Is_customer_in_a_CIS_country__c = val;
        }
        else if(fieldName === 'Customer_Name__c'){
            this.engagementData.Customer_Name__c = event.detail.value;
        }
        else if(fieldName === 'Opportunity_Id__c'){
            this.engagementData.Opportunity_Id__c = event.detail.value;
        }
        else if(fieldName === 'Comments__c'){
            this.engagementData.Comments__c = event.detail.value;
        }
        else if(fieldName === 'Enable_Cloud_Service__c'){
            let val = event.detail.checked;
            this.engagementData.Enable_Cloud_Service__c = val;
        }
    }

    engagementDataChangeRequest(event){
        this.engagementData.How_will_this_software_be_used__c = event.detail.value;
    }

}