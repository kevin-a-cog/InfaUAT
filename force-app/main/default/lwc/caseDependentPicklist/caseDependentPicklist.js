/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              22-Sep-2022     I2RT-7164           Commented code that implicitly removes old field values   T01
                                                            when it doesn't find a matching version, component,
                                                            subcomponent & problem type on the technical product line
 Vignesh D              30-Mar-2023     I2RT-7852           Make product field read only                              T02
 Shashikanth            14-Sep-2023     I2RT-9026           Capture Components fields even for Fulfilment cases       T03
*/
import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import global_styles from '@salesforce/resourceUrl/gcsSrc';

import getProductAttributes from '@salesforce/apex/caseDependentPicklistController.getProductAttributes';
import saveProductDetails from '@salesforce/apex/caseDependentPicklistController.saveProductDetails';
import getCaseDetails from '@salesforce/apex/caseDependentPicklistController.getCaseDetails';

import PRODUCT_VALUE from '@salesforce/schema/Case.Forecast_Product__c';
import COMPONENT_VALUE from '@salesforce/schema/Case.Component__c';
import SUBCOMPONENT_VALUE from '@salesforce/schema/Case.Subcomponent__c';
import VERSION_VALUE from '@salesforce/schema/Case.Version__c';
import PROBLEMTYPE_VALUE from '@salesforce/schema/Case.Problem_Type__c';
import RECORDTYPE_NAME from '@salesforce/schema/Case.Record_Type_Name__c';
import RECORDTYPEID from '@salesforce/schema/Case.RecordTypeId';
import DELIVERY_METHOD from '@salesforce/schema/Case.Delivery_Method__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';


const FIELDS = [PRODUCT_VALUE,COMPONENT_VALUE,SUBCOMPONENT_VALUE,VERSION_VALUE,PROBLEMTYPE_VALUE,RECORDTYPE_NAME,RECORDTYPEID,DELIVERY_METHOD,CASE_STATUS];

export default class CaseDependentPicklist extends LightningElement {

    @track isReadOnly = true;
    @track showEditButton = true;
    @track isRequired = false;
    @track showErrorMessage;
    @track isLoading = false;
    @track caseRecord;
    @track caseStatus;
    @track canEdit = false;

    //Used to track product and it's related obj
    @track productSectionLabel = 'Product Details';
    @track productOBJ = {label: "Product", name: 'Forecast_Product__c', editable: false, updateable: false, showEditPencil: false, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'}; //<T02>
    @track versionOBJ = {label: "Version", name: 'Version__c', editable: false, updateable: true, showEditPencil: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};
    @track componentOBJ = {label: "Component", name: 'Component__c', editable: false, updateable: true, showEditPencil: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};         //<T03>
    @track subCompOBJ = {label: "Subcomponent", name: 'Subcomponent__c', editable: false, updateable: true, showEditPencil: true, show: true, showCaseTypes: 'Technical::Operations::Fulfillment'};     //<T03>  
    @track problemTypeOBJ = {label: "Problem Type", name: 'Problem_Type__c', editable: false, updateable: true, showEditPencil: true, show: true, showCaseTypes: 'Technical::Operations'};
    @track unentitledProductOBJ = {label: "Unentitled Product", name: 'Unentitled_Product__c', editable: false, updateable: false, showEditPencil: false, show:true, showCaseTypes: 'Technical::Operations::Fulfillment'};
    @track productSectionFields = [
        this.productOBJ,
        this.versionOBJ,
        this.componentOBJ,
        this.subCompOBJ,
        this.problemTypeOBJ,
        this.unentitledProductOBJ
    ];
    @track selectedProduct;
    @track selectedComponent;
    @track selectedSubComponent;
    @track selectedProblemType;
    @track selectedVersion;
    @track unentitledProduct;

    @track caseProduct = [] ;
    @track caseComponent =[] ;
    @track caseSubComponent =[] ;
    @track caseProblemType =[] ;
    @track caseVersion =[] ;
    
    @track componentsMap ;
    @track fulfillmentComponentsMap;
    @track versionsMap;
    @track problemsMap;
    @track allProducts;
    
    @api recordId;
    @track caseRecord;
    @track recordDetailComponent;
    @track recordDetailSubComponent;
    @track recordDetailProblem;
    @track recordDetailVersion;
    @track caseRecordData;

    @track case_Component;
    @track case_SubComponent;
    @track case_ProblemType;
    @track case_Version;
    @track caseRecordTypeId;
    @track caseDeliveryMethod;
    @track caseRecordTypeName;
    isComponentConnected = false;



    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) caseRecordData ({error, data})
    {
        if(data){
          this.caseRecord = data;  
          this.caseRecordTypeId = data.recordTypeId;
          this.caseDeliveryMethod = data.fields.Delivery_Method__c.value;
          this.caseRecordTypeName = data.recordTypeInfo.name;
          console.log('this.caseRecordTypeId : ' + this.caseRecordTypeId);      
          console.log('this.caseDeliveryMethod : ' + this.caseDeliveryMethod);      
          console.log('this.caseRecordTypeName : ' + this.caseRecordTypeName);
          
          if(this.caseRecordTypeName != undefined && this.caseRecordTypeName != null){
              console.log('@log caseRecordTypeName : '+this.caseRecordTypeName);
            if(this.productOBJ.showCaseTypes != undefined && !this.productOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.productOBJ.show = false;
            }
            if(this.versionOBJ.showCaseTypes != undefined && !this.versionOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.versionOBJ.show = false;
            }
            if(this.componentOBJ.showCaseTypes != undefined && !this.componentOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.componentOBJ.show = false;
            }
            if(this.subCompOBJ.showCaseTypes != undefined && !this.subCompOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.subCompOBJ.show = false;
            }
            if(this.problemTypeOBJ.showCaseTypes != undefined && !this.problemTypeOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.problemTypeOBJ.show = false;
            }
            if(this.unentitledProductOBJ.showCaseTypes != undefined && !this.unentitledProductOBJ.showCaseTypes.includes(this.caseRecordTypeName)){
                this.unentitledProductOBJ.show = false;
            }

            if(data.fields.Status != undefined && data.fields.Status.value != null){
                this.caseStatus = data.fields.Status.value;
                
                if(this.caseStatus !== 'Closed'){
                    this.canEdit = true;
                }
                else if(this.caseStatus === 'Closed'){
                    this.canEdit = false;
                }
            }

            if(this.isComponentConnected == true){
                this.getRecordValues();
            }
        }

        }else if(error){
          console.log('requete error', JSON.stringify(error)); 
        }
      }

    @track disabledComponents;
    @track disabledSubComponents;
    @track disabledVersions;
    @track disabledProblems;
    @track showNoneVersion;
    @track showNoneComponent;

    renderedCallback() {
        Promise.all([
        loadStyle(this, global_styles + '/global.css'),
        ])
        .then(() => {
            console.log("CSS loaded.")
        })
        .catch(() => {
            console.log("CSS not loaded");
        });
    }

    @track buttonClicked = true;
    @track className = 'slds-section slds-show';
    @track iconName = 'utility:chevrondown';
    handleToggle() {
        this.buttonClicked = !this.buttonClicked;
        if (this.buttonClicked == false) {
            this.className = 'slds-section slds-hide';
            this.iconName = 'utility:chevronright';
        }
        else {
            this.className = 'slds-section slds-show';
            this.iconName = 'utility:chevrondown';
        }
    }
    rerenderDetails(){

        console.log('Coming in rerenderDetails !!');
         
        var foundVersion = false;
        var foundProblemType = false;

        this.caseProduct = [] ;
        this.caseComponent =[] ;
        this.caseSubComponent =[] ;
        this.caseProblemType =[] ;
        this.caseVersion =[] ;
         
        this.disabledComponents = true;
        this.disabledSubComponents = true;
        this.disabledVersions = true;
        this.disabledProblems = true; 
        this.showNoneVersion = false;
        this.showNoneComponent = false;
        
        //this.caseProduct.push({label:'None' , value:'None'});
        this.caseComponent.push({label:'None' , value:'None'});
        this.caseSubComponent.push({label:'None' , value:'None'});
        this.caseProblemType.push({label:'None' , value:'None'});
        this.caseVersion.push({label:'None' , value:'None'});
        console.log('this.caseProduct == > '+ this.caseProduct);

        console.log('@BEFORE selectedProduct ==> ' + this.selectedProduct);
        console.log('@BEFORE selectedComponent ==> ' + this.selectedComponent);
        console.log('@BEFORE selectedSubComponent ==> ' + this.selectedSubComponent);
        console.log('@BEFORE selectedselectedProblemTypeProduct ==> ' + this.selectedProblemType);
        console.log('@BEFORE selectedVersion ==> ' + this.selectedVersion);
        
        if(!!this.allProducts && this.allProducts.length > 0){
            this.allProducts.forEach(prodName =>{
                
                console.log('prodName  ==> '+prodName);
                this.caseProduct.push({label:prodName , value: prodName});
                
                if(this.selectedProduct === prodName){
                    
                    let totalComponentsMap = this.componentsMap;                
                    console.log('this.selectedProducts >>> ' + this.selectedProduct);
                    console.log('ComponentsMap >>> ' + JSON.stringify(totalComponentsMap));
                    console.log('totalComponentsMap[prodName] >>> '+ JSON.stringify(totalComponentsMap[prodName]));
                    if(this.caseRecordTypeName != 'Fulfillment')
                    {
                        this.bindComponentsData(totalComponentsMap[prodName]);
                    }

                    /** VersionMap Settings  **/
                    let totalVersionMap = this.versionsMap;
                    console.log('totalVersionMap new >>> '+ JSON.stringify(totalVersionMap));
                    if(totalVersionMap[prodName] !== null && totalVersionMap[prodName].indexOf('None')> -1){
                        this.showNoneVersion  = true;
                    }
                    if(totalVersionMap[prodName] !== null ){
                        this.disabledVersions = false;
                        totalVersionMap[prodName].forEach(version =>{
                            if(this.selectedVersion === version){
                                foundVersion = true;
                            }
                            if(version !== 'None'){
                                this.caseVersion.push({label:version , value:version});
                            }
                        });
                    }

                    /** ProblemType Settings  **/
                    let totalProblemMap = this.problemsMap;
                    console.log('totalProblemMap value >>> ' + JSON.stringify(totalProblemMap))
                    /* if(totalProblemMap[prodName] !== null){
                        this.disabledProblems = false;
                        totalProblemMap[prodName].forEach(problem =>{
                            if(this.selectedProblemType === problem){
                                foundProblemType = true;
                            }
                            this.caseProblemType.push({label:problem , value:problem});
                        });
                    } */
                    console.log('Record Type Name : ' + this.caseRecordTypeName);
                    console.log('Record Type Id : ' + this.caseRecordTypeId);
                    console.log('Record Delivery Method : ' + this.caseDeliveryMethod);
                    console.log(' (this.caseRecordTypeName == Operations) : ' + (this.caseRecordTypeName == 'Operations'));
                    var key = (this.caseRecordTypeName == 'Operations') ? this.caseRecordTypeName :
                            (this.caseRecordTypeName == 'Technical' && this.caseDeliveryMethod != null ) ? this.caseRecordTypeName + this.caseDeliveryMethod.replace(/\s+/g, ''): '';
                            
                    console.log('Key : ' + key);
                    console.log('totalProblemMap : ' + totalProblemMap);
                    console.log('totalProblemMap.get(key) : ' + totalProblemMap[key]);

                    if(totalProblemMap != null && totalProblemMap[key] != null){
                        this.disabledProblems = false;
                        totalProblemMap[key].forEach(problem =>{
                            if(this.selectedProblemType === problem){
                                foundProblemType = true;
                            }
                            this.caseProblemType.push({label:problem,value:problem});
                        });
                    }
                }

                
            });
        }

        if(this.caseRecordTypeName == 'Fulfillment' && !!this.fulfillmentComponentsMap && !!this.fulfillmentComponentsMap[this.caseDeliveryMethod])
        {
            this.bindComponentsData(this.fulfillmentComponentsMap[this.caseDeliveryMethod]);
        }
        
        if(!foundVersion){
            this.selectedVersion = 'None';
        }
        if(!foundProblemType){
            this.selectedProblemType = 'None';
        }
        
        /** To remove the duplicate Options from the Options List */
        this.caseProduct = this.caseProduct.reduce((unique, o) => {
            if(!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
              unique.push(o);
            }
            return unique;
        },[]);

        this.caseComponent = this.caseComponent.reduce((unique, o) => {
            if(!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
              unique.push(o);
            }
            return unique;
        },[]);

        this.caseSubComponent = this.caseSubComponent.reduce((unique, o) => {
            if(!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
              unique.push(o);
            }
            return unique;
        },[]);

        this.caseProblemType = this.caseProblemType.reduce((unique, o) => {
            if(!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
              unique.push(o);
            }
            return unique;
        },[]);

        this.caseVersion = this.caseVersion.reduce((unique, o) => {
            if(!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
              unique.push(o);
            }
            return unique;
        },[]);

        console.log('this.caseProduct'+ JSON.stringify(this.caseProduct));
        console.log('this.caseComponent'+ JSON.stringify(this.caseComponent));
        console.log('this.caseSubComponent'+ JSON.stringify(this.caseSubComponent));
        console.log('this.caseProblemType'+ JSON.stringify(this.caseProblemType));
        console.log('this.caseVersion'+ JSON.stringify(this.caseVersion));

        console.log('selectedProduct ==> ' + this.selectedProduct);
        console.log('selectedComponent ==> ' + this.selectedComponent);
        console.log('selectedSubComponent ==> ' + this.selectedSubComponent);
        console.log('selectedselectedProblemTypeProduct ==> ' + this.selectedProblemType);
        console.log('selectedVersion ==> ' + this.selectedVersion);
        
    }

    //<T03>
    bindComponentsData(componentsDatasourceMap)
    {
        let sortedCompList;
        let sortedSubCompList;
         
        let foundComponent = false;
        let foundSubComponent = false;

        if(componentsDatasourceMap != null && !componentsDatasourceMap.isEmpty)
        {
            console.log('Debug 1  ==> ');
            var compList =[];
            sortedCompList =[];
            sortedSubCompList = [];
            
            for (var key in componentsDatasourceMap){                   
                compList.push(key);
            }
            console.log('compList >>>' + compList);
            compList.sort();sortedCompList = compList;
            console.log('sorted compList>>>' + sortedCompList);
                sortedCompList.forEach(compName =>{                        
                    foundComponent = foundComponent ? true : false;
                    console.log('compName  >>>'+ compName);                        
                    if(compName !== 'None' || componentsDatasourceMap.has('None')){                            
                        if(compName === 'None'){
                            this.showNoneComponent = true;
                        }
                        if(compName !== 'None'){
                            this.caseComponent.push({label:compName , value:compName});
                        }
                        this.disabledComponents = false;

                        console.log('this.selectedComponent >>> '+ this.selectedComponent);
                        console.log('compName >>> ' + compName);

                        if(this.selectedComponent === compName && componentsDatasourceMap[compName] !== null){
                            foundComponent = true;
                            var subCompList = [];
                            componentsDatasourceMap[compName].forEach(c =>{
                                subCompList.push(c);
                            });
                            subCompList.sort();
                            
                            sortedSubCompList = subCompList;
                            console.log('sortedSubCompList' + sortedSubCompList);

                            sortedSubCompList.forEach(subCompName =>{
                                if(this.selectedSubComponent === subCompName){
                                    foundSubComponent = true;
                                }
                                this.caseSubComponent.push({label:subCompName , value:subCompName});
                            });
                            this.disabledSubComponents = false;
                            if(this.selectedComponent === compName && componentsDatasourceMap[compName] === null){
                                foundComponent = true;
                                this.disabledSubComponents = true;
                            }
                        }

                    }else{
                        this.disabledComponents = true;
                        this.disabledSubComponents = true;
                    }
                });
            }

        if(!foundComponent){
            this.selectedComponent = 'None';
        }
        if(!foundSubComponent){
            this.selectedSubComponent = 'None';
        }
    }

    //</T03>

    handleChangeSubComponent(event) {        
        this.selectedSubComponent = event.target.value;
        this.rerenderDetails();
    }

    handleChangeComponent(event) {        
        this.selectedComponent = event.target.value;
        console.log('Onchange of Component : selectedSubComponent >>>'+ this.selectedSubComponent);
        this.rerenderDetails();
    }

    handleChangeProblemType(event) {        
        this.selectedProblemType = event.target.value;
        this.rerenderDetails();
    }

    handleChangeVersion(event) {        
        this.selectedVersion = event.target.value;
        this.rerenderDetails();
    }

    handleChangeProduct(event){
        this.selectedProduct = event.target.value;
        this.selectedComponent = 'None';  
        this.selectedSubComponent ='None';
        this.selectedProblemType = 'None';
        this.selectedVersion   = 'None';  
        this.rerenderDetails();
    }

    get displayComponent(){
        return this.productSectionFields.filter(e=>e.show === true).length > 0 ? true : false;
    }

    getRecordValues(){
        console.log('Case record ID >>> ' + this.recordId);
        
        let caseId = this.recordId;
        getProductAttributes ({ caseId: caseId})
        .then(result => {
            console.log(JSON.stringify(result));

            let tempData = JSON.parse(JSON.stringify(result));
            
            this.componentsMap = tempData.componentsMap;
            this.fulfillmentComponentsMap = tempData.fulfillmentComponentsMap;              //<T03>
            this.versionsMap = tempData.versionsMap;
            this.problemsMap = tempData.problemsMap;
            this.allProducts = tempData.allProducts;           
            console.log('this.problemsMap : ' + this.problemsMap);
            this.selectedProduct     = tempData.caseRecDetails.Forecast_Product__c  === undefined ? 'None' : tempData.caseRecDetails.Forecast_Product__c ;
            this.selectedComponent   = tempData.caseRecDetails.Component__c === undefined ? 'None' : tempData.caseRecDetails.Component__c;
            this.selectedSubComponent= tempData.caseRecDetails.SubComponent__c === undefined ? 'None' : tempData.caseRecDetails.SubComponent__c;
            this.selectedProblemType = tempData.caseRecDetails.Problem_Type__c === undefined ? 'None' : tempData.caseRecDetails.Problem_Type__c;
            this.selectedVersion     = tempData.caseRecDetails.Version__c === undefined ? 'None' : tempData.caseRecDetails.Version__c;
            
            console.log('selectedProduct ==> ' + this.selectedProduct);
            console.log('selectedComponent ==> ' + this.selectedComponent);
            console.log('selectedSubComponent ==> ' + this.selectedSubComponent);
            console.log('selectedselectedProblemTypeProduct ==> ' + this.selectedProblemType);
            console.log('selectedVersion ==> ' + this.selectedVersion);

            this.rerenderDetails();
            this.checkExistingValues();           

        })
        .catch(error => {
            console.log('ERROR IN CASE DEPENDANT PICKLIST!!');
        })

        
    }

    handleEdit(){

        this.isReadOnly = false;
        if(getFieldValue(this.caseRecord, RECORDTYPE_NAME) === 'Technical' || getFieldValue(this.caseRecord, RECORDTYPE_NAME) === 'Shipping Request' )
        {
            this.isRequired = true;
        }

    }

    handleSave(){

    this.isLoading = true;    
    this.showErrorMessage = undefined;
    let caseId = this.recordId;
    
    saveProductDetails ({ caseId:caseId,selectedProduct:this.selectedProduct,selectedComponent:this.selectedComponent,selectedSubComponent:this.selectedSubComponent,selectedProblemType:this.selectedProblemType, selectedVersion:this.selectedVersion,componentsMap:this.componentsMap,versionsMap: this.versionsMap, unentProduct: this.unentitledProduct})
    .then(result => {

        console.log(JSON.stringify(result));

        let message = JSON.parse(JSON.stringify(result));
        if(message.indexOf('SUCCESS') > -1){
            console.log('SUCCESS!!!');
            console.log('this.showErrorMessage : ' + this.showErrorMessage);
            this.isLoading = false;
            this.isReadOnly = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case has been updated successfully',
                    variant: 'success',
                }),
            );
            notifyRecordUpdateAvailable([{recordId: this.recordId}]);               //<T03>
        }else{
            console.log('display error message ... '+message);
            this.showErrorMessage = message;
            this.isReadOnly = false;
            this.isLoading = false;
        }
    })
    .catch(error => {
        this.isLoading = false;        
        console.log('ERROR WHILE SAVING !!');
    })
    
    }

    handleCancel(){  
       this.isReadOnly = true;
       this.showErrorMessage = undefined;
       this.getRecordValues(); /** Reset the original Values */ 
    }

    connectedCallback(){
        this.isComponentConnected = true;
        this.getRecordValues(); 
    }

    checkExistingValues(){ 
            getCaseDetails({caseId:this.recordId})
            .then(result => {
                let temp = JSON.parse(JSON.stringify(result));

                this.selectedComponent    = this.case_Component = temp.Component__c === undefined ? 'None' : temp.Component__c;
                this.selectedSubComponent = this.case_SubComponent = temp.Subcomponent__c === undefined ? 'None' : temp.Subcomponent__c;
                this.selectedProblemType  = this.case_ProblemType = temp.Problem_Type__c === undefined ? 'None' : temp.Problem_Type__c;
                this.selectedVersion      = this.case_Version = temp.Version__c === undefined ? 'None' : temp.Version__c;

                this.rerenderDetails();
                console.log('checkExistingValues >> rerenderDetails - Completed');
                
                /*if(this.selectedVersion !== this.case_Version || this.selectedProblemType !== this.case_ProblemType || this.selectedSubComponent !== this.case_SubComponent || this.selectedComponent !== this.case_Component){ //<T01>
                    checkExistingValues({caseId:this.recordId,selectedComponent:this.selectedComponent,selectedSubComponent:this.selectedSubComponent,selectedProblemType:this.selectedProblemType, selectedVersion:this.selectedVersion})
                    .then(result => {
                        console.log('Updated existing records successfully!');
                    })
                    .catch(error => {
                        console.log('Error while updating existing records!');
                    })
                }*/
                })
        .catch(error => {
            console.log('Error while fetching Case Details!');
        })

    }

    setUnentitledProd(event){
        this.unentitledProduct = event.detail.checked;
        console.log('unentitled product --> '+this.unentitledProduct);
    }

}