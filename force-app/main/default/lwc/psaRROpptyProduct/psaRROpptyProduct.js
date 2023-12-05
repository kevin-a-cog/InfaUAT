import { LightningElement, api, track, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import RR_OPPTY_RECORD_ID from '@salesforce/schema/pse__Resource_Request__c.PSA_OM_Opportunity_Product_Id__c';

import getOpptyProductSelectionFields from '@salesforce/apex/psa_ResourceRequestController.getOpptyProductSelectionFields';
import getOpptyProducts from '@salesforce/apex/psa_ResourceRequestController.getOpptyProducts';
import setOpptyProduct from '@salesforce/apex/psa_ResourceRequestController.setOpptyProduct';
import psaOPSPermission from '@salesforce/customPermission/PSA_Operations';
import psaRevOpsPermission from '@salesforce/customPermission/PSA_Deal_Desk';
import psaRMOPermission from '@salesforce/customPermission/PSA_Resource_Manager';


const resReqFields = [
'pse__Resource_Request__c.PSA_OM_Opportunity_Product_Id__c',
'pse__Resource_Request__c.pse__Status__c'
];

export default class PsaRROpptyProduct extends NavigationMixin(LightningElement)  {
@api recordId;

origOpptyProductId = '';
newOpptyProductId = '';
@track selectedOpptyProduct = [];
@track showDatatable = false;
@track showNoDataMsg = false;
status;
error;
toastTitle;
toastMessage;
toastVariant;

@wire(getRecord , {recordId: '$recordId', fields: resReqFields}) 
getResourceRequest({ error, data }) {
if(data){
this.status = data.fields.pse__Status__c.value;
console.log('this.data',data);
console.log('this.status',this.status);
console.log('Inside connected call back')
console.log('psaOPSPermission',psaOPSPermission)
console.log('psaRMOPermission',psaRMOPermission)
if(!(this.status==='Draft' || this.status ==='Forecast') && !(psaOPSPermission || psaRMOPermission || psaRevOpsPermission)){

this.toastTitle='Information!';
this.toastMessage='You do not have the ability to associate an Opportunity Product to the Resource Request when Status is NOT in Draft OR Forecast. Please contact your Resource Manager.';
this.toastVariant='info';
this.showToastMessage(this.toastTitle,this.toastMessage,this.toastVariant);
this.closeQuickAction();  

}else{
this.origOpptyProductId = getFieldValue(data, RR_OPPTY_RECORD_ID);
console.log("origOpptyProductId = " + this.origOpptyProductId); 
} 

}else if(error){
console.log('error',JSON.stringify(error))
}
}

@track columns = [];
@track opptyProducts = [];
@track opptyProductAll = [];

@track saveInProgress=false;

selectionFields = [];

connectedCallback(){

getOpptyProductSelectionFields()
.then(results => {
console.log("results = " + JSON.stringify(results));

var i=1;
var columns = []
results.forEach(fieldInfo => {
    console.log("fieldInfo = " + JSON.stringify(fieldInfo));

    var fieldName = 'field'+i++;
    var column = {label: fieldInfo.Field_Label__c, fieldName: fieldName, cellAttributes: { class: { fieldName: 'origCSSClass' }}};
    if(fieldInfo.Links_To__c){
        column['type'] = 'url';
        column['typeAttributes'] = { label: { fieldName: fieldName+'label' }, target: '_blank' };
    }
    if(fieldInfo.Field_Name__c==='ListPrice' || fieldInfo.Field_Name__c==='TotalPrice'){
        column['type'] = 'currency';
        column['typeAttributes'] = { currencyCode: { fieldName: 'CurrencyIsoCode'},currencyDisplayAs: "code"};
        
    }
    console.log("column = " + JSON.stringify(column));
    columns.push(column);

    var selectionField = {name:fieldName, path:fieldInfo.Field_Name__c, link:fieldInfo.Links_To__c};
    this.selectionFields.push(selectionField);
})
console.log("this.columns = " + JSON.stringify(columns));
this.columns = columns;

getOpptyProducts({
    resourceRequestId:this.recordId
})
.then(results => {
    console.log("results = " + JSON.stringify(results));

    var items=[];

    results.forEach(element => {
        console.log("each element = " + JSON.stringify(element));

        console.log("oppty product id = " + element.Id);
        var opptyProduct = {};
        opptyProduct["id"] = element.Id;
        
        this.selectionFields.forEach(fieldInfo => {
            console.log("fieldInfo = " + JSON.stringify(fieldInfo));

                if(fieldInfo.link){
                    opptyProduct[fieldInfo.name+'label'] = this.getGrandchild(element, fieldInfo.path);
                opptyProduct[fieldInfo.name] = '/lightning/r/' + this.getGrandchild(element, fieldInfo.link) + '/view';
            
                } else{
                    opptyProduct[fieldInfo.name] = this.getGrandchild(element, fieldInfo.path);
                        
            }
        })
        
        if(element.Id == this.origOpptyProductId){
            opptyProduct['origCSSClass'] = 'slds-theme_warning';
        }
        opptyProduct['CurrencyIsoCode']=element.CurrencyIsoCode;
        console.log("opptyProduct = " + JSON.stringify(opptyProduct));

        items.push(opptyProduct);
        console.log("opptyProduct =11== " + JSON.stringify(opptyProduct));
    });
    this.opptyProducts = items;
    this.opptyProductAll = items;
    if(this.opptyProductAll.length == 0){
        this.showNoDataMsg = true;
        console.log("this.showNoDataMsg = " + this.showNoDataMsg);
    }else{
        console.log("this.showDatatable = " + this.showDatatable);
        this.showDatatable = true;
    }
    console.log("opptyProducts = " + JSON.stringify(this.opptyProducts));
})
.catch(error => {
    console.log("error occurred = " + JSON.stringify(error));
})
})
.catch(error => {
console.log("error occurred = " + JSON.stringify(error));
})

}

getURL(recordId){
var recordUrl;

console.log('recordId - ' + recordId);

this[NavigationMixin.GenerateUrl]({
type: "standard__recordPage",
attributes: {
    recordId: recordId,
    actionName: "view"
}
}).then((url) => {
console.log('url - ' + url);
recordUrl = url;
})

console.log('recordUrl - ' + recordUrl);
return recordUrl; 
}

handleSelect(event) {
const selectedRows = event.detail.selectedRows;
// Display that fieldName of the selected rows
selectedRows.forEach(element => {
console.log("You selected: " + JSON.stringify(element));
this.newOpptyProductId=element.id;
})
}

updateSearch(event) {
//console.log('first field = ' + JSON.stringify(this.selectionFields[0]));
var regex = new RegExp(event.target.value,'gi')

var opptyProducts = [];
this.opptyProductAll.forEach(row => {
var allRowValue = '';
this.selectionFields.forEach( fieldInfo => {
    if(fieldInfo.link){
        allRowValue += row[fieldInfo.name+'label'] + '---';
    }else{
        allRowValue += row[fieldInfo.name] + '---';
    }
})
//console.log('allRowValue = '+allRowValue);
if(regex.test(allRowValue)){
    opptyProducts.push(row);
}
});
this.opptyProducts = opptyProducts;

}

saveSelection(event){
console.log("newOpptyProductId = " + this.newOpptyProductId);
var title;
var message;
var variant;
if(this.newOpptyProductId){
this.saveInProgress=true;
setOpptyProduct({
    resourceRequestId:this.recordId,
    opptyProductId:this.newOpptyProductId
})
.then(result => {
    var status = result.substring(0,result.indexOf(":"));
    console.log('status',status);
    if(status==='Success'){
        console.log("saved successfully!");
        
        this.toastTitle='Success',
        this.toastMessage=result.substring(result.indexOf(":")+1); 
        this.toastVariant='success';

        this.showToastMessage(this.toastTitle,this.toastMessage,this.toastVariant);
        this.saveInProgress=false;
        this.closeQuickAction();
    }else if(status ==='Error'){

        this.toastTitle='Error',
        this.toastMessage=result.substring(result.indexOf(":")+1); 
        this.toastVariant='error';

        this.showToastMessage(this.toastTitle,this.toastMessage,this.toastVariant);
        this.saveInProgress=false;
        this.closeQuickAction();
    }
    
})
.catch(error => {
    
    console.log("erron on save.." + JSON.stringify(error));
    this.toastTitle='Error';
    this.toastMessage= error.body.message;
    this.toastVariant='error';
    
    this.showToastMessage(this.toastTitle,this.toastMessage,this.toastVariant);
    this.saveInProgress=false;
})
}else{

    this.toastTitle='Error';
    this.toastMessage='Please select one of the options!';
    this.toastVariant='error';
    
this.showToastMessage(this.toastTitle,this.toastMessage,this.toastVariant);
return;
}
}

cancel(event){
this.closeQuickAction();
}

closeQuickAction() {
const closeQA = new CustomEvent('close');
// Dispatches the event.
this.dispatchEvent(closeQA);
}

getGrandchild(jsonObj, pathString){
var grandchild = jsonObj;

var pathArray = pathString.split(".");
//console.log("pathArray=" + JSON.stringify(pathArray));

pathArray.forEach(item => {
//console.log("grandchild=" + JSON.stringify(grandchild));
//console.log("item=" + JSON.stringify(item));
grandchild = grandchild[item];
})

return grandchild;
};
showToastMessage(toastTitle,toastMsg,variantType){

this.dispatchEvent(
new ShowToastEvent({
    title: toastTitle,
    message: toastMsg,
    variant: variantType,
}),
);
}
}