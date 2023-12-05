/*

*******************************************************************************************************************
MODIFIED BY     MODIFIED Date   JIRA        DESCRIPTION                                                         TAG
*******************************************************************************************************************
balajip         27-Sep-2022     I2RT-7159   added method handleAccountChange to capture the selected Account    T01
ChaitanyaT      12-Sep-2023     AR-3383     Expansion Lead workflow added file upload for Source is Plan        T02
Vignesh D		10-Nov-2023     I2RT-8172   Show base component search for Case & Account record pages			T03
ChaitanyaT      15-Nov-2023     AR-3555     UAT Feedback - Expansion Lead                                       T04
*/

import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { objUtilities } from 'c/globalUtilities';

import modal from "@salesforce/resourceUrl/referralManagementStyle";
import { loadStyle } from "lightning/platformResourceLoader";

import getAccountDetails from "@salesforce/apex/ReferralManagementController.getAccountDetails";
import getReferralOwner from "@salesforce/apex/ReferralManagementController.getReferralOwner";
import lookupSearch from "@salesforce/apex/ReferralManagementController.lookupSearch";
import lookupSearchPlan from "@salesforce/apex/ReferralManagementController.lookupSearchPlan";
import getDefaultRecords from "@salesforce/apex/ReferralManagementController.getDefaultRecords";
import deleteFile from "@salesforce/apex/ReferralManagementController.deleteFile";
import linkFiles from "@salesforce/apex/ReferralManagementController.linkFiles";
import invokeChatterPost from "@salesforce/apex/ReferralManagementController.invokeChatterPost";
import ReferralPlanDescwatermark from '@salesforce/label/c.ReferralPlanDescwatermark';
export default class ReferralManagement extends NavigationMixin(LightningElement) {

record_Id;
objectApiName;

showOther;
source;
accountId;
supportaccountId;
product;
showSpinner;
selectedContactId;
@track uploadedFiles = [];//T02
uploadedDocIds = [];//T02
waterMarkForDescription = '';//T02
textAreaValue;//T02
label = {ReferralPlanDescwatermark};//T02

connectedCallback(event){
    loadStyle(this, modal);

    var currentURL = window.location.href;
    var objElement = currentURL.substring(currentURL.indexOf('/r/') + 1).split('/');
    this.objectApiName = objElement[1];
    this.record_Id = objElement[2];
    console.log(this.objectApiName + ' ' + this.record_Id);

    if(this.objectApiName ==='Plan__c'){
        this.source = 'Plan';
        this.waterMarkForDescription = this.label.ReferralPlanDescwatermark;//T02
    }else if(this.objectApiName ==='Case'){
        this.source = 'Case';
    }else if(this.objectApiName ==='pse__Proj__c'){
        this.source = 'Project';
    }else{
        this.source = 'Other';
        this.showOther = true;
    }

    getAccountDetails({recId : this.record_Id , objAPIName : this.objectApiName})
    .then(result => {
       var accIdList = result.split(';');
       this.accountId = accIdList[0];
       if(accIdList[1]){
        this.supportaccountId = accIdList[1];
       }
    })
    .catch(error => {
        console.log(`getAccountDetails --> error: ${error}`);
    })
}
handleLoad() { 
    const sourceFields = this.template.querySelector('[data-id="Source__c"]');
    if (this.source == 'Plan' && sourceFields) {
        sourceFields.disabled = true;  
    }
  }

//<T02> start
get displayFileUpload(){
    if(this.source == 'Plan'){
        return true;
    }
    return false;
}

handleUploadFinished(event){
    // Get the list of uploaded files
    this.uploadedDocIds = [];
    if(this.uploadedFiles.length > 0){
        for(var i=0;i<event.detail.files.length;i++){
            this.uploadedFiles.push(JSON.parse(JSON.stringify(event.detail.files[i])));
        }
    }else{
        this.uploadedFiles = JSON.parse(JSON.stringify(event.detail.files));
    }
    this.uploadedFiles.forEach(uploadFile =>{
        this.uploadedDocIds.push(uploadFile.documentId);
    });
}

/*
    Method Name : acceptedFormats
    Description : This method will get the accepted file formats
    Parameters	 : None
    Return Type : String
*/
get acceptedFormats() {
    return ['.pdf', '.jpg', '.png','.xlsx','.xls','.csv','.doc','.docx','.txt','.jpeg','.gif']; //csmPlanCommunicationEditForm
}

/*
    Method Name : handleFileRemove
    Description : This method will delete the file which has been clicked on remove
    Parameters	 : event
    Return Type : None
*/
handleFileRemove(event) {
    var allFilesBeforeDelete = [...this.uploadedFiles];
    var deleteDocumentId = event.target.name;
    this.uploadedFiles = this.uploadedFiles.filter(item => item.name !== deleteDocumentId);
    var difference = allFilesBeforeDelete.filter(x => !this.uploadedFiles.includes(x));
    this.showSpinner = true;
    deleteFile({'fileIdsToDelete': difference[0].documentId})
        .then((result) => {
            if(result == false){
                console.log('unable to delete File');
            }
        }).catch((error) => {
            console.log('file cannot be deleted ' , error);
        }).finally(() => {
            this.showSpinner = false;
        });
    this.uploadedDocIds = [];
    this.uploadedFiles.forEach(uploadFile =>{
        this.uploadedDocIds.push(uploadFile.documentId);
    });
}

handleTextAreaChange(){
    this.textAreaValue = this.template.querySelector("lightning-textarea").value
}
//</T02> end

handleSuccess(event){
    this.showSpinner = false;
    var referralId = event.detail.id;
    console.log('referralId >> '+ referralId);
    if(this.source == 'Plan' && this.uploadedDocIds.length > 0){//link the files uploaded if any to the referral //<T02> start
        this.showSpinner = true;
        linkFiles({'recordId': referralId,'uploadedFileIds':this.uploadedDocIds})
            .then(() => {
            }).catch((error) => {
                console.log('files cannot added ' , error);
            }).finally(() => {
                this.showSpinner = false;
        });
    }
    if(this.source == 'Plan' && this.uploadedDocIds.length == 0){//link the files uploaded if any to the referral //<T02> start
        this.showSpinner = true;
        invokeChatterPost({'recordId': referralId})
            .then(() => {
            }).catch((error) => {
                console.log('files cannot added ' , error);
            }).finally(() => {
                this.showSpinner = false;
        });
    }//</T02> end
    //Now we close the quick Action
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success : ',
            message: 'Referral has been created successfully!',
            variant: 'success',
        }),
    );
    //Navigate to new record
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: referralId,
            actionName: 'view'
        }
    });
    
}

handleSubmit(event){
    event.preventDefault();
    let objParent = this;
    this.showSpinner = true;
    const fields = event.detail.fields;

    if(this.textAreaValue == '' || this.textAreaValue == null || this.textAreaValue == undefined){//<T02> start
        this.showSpinner=false;
        this.template.querySelector("lightning-textarea").reportValidity();
        return;
    }
    /*if(this.source == 'Plan' && this.uploadedFiles==''){//<T04> start
        objUtilities.showToast('Error','Please upload the Cassini consumption Trend','error',objParent);
        this.showSpinner=false;
        return;
    }*///</T04> end
    //</T02> end
    if( objUtilities.isBlank(this.selectedContactId) && objUtilities.isBlank(fields?.Customer_Contact__c)){ //<T03>
        objUtilities.showToast('Error','Please select the Contact','error',objParent);
        this.showSpinner=false;
    }else{

        if(this.objectApiName ==='Plan__c'){
            fields.Plan__c = this.record_Id;
        }else if(this.objectApiName ==='Case'){
            fields.Case__c = this.record_Id;
            fields.Support_Account__c = this.supportaccountId;
        }else if(this.objectApiName ==='pse__Proj__c'){
            fields.Project__c = this.record_Id;
        }

        fields.Customer_Contact__c = this.selectedContactId;
        fields.Description__c = this.textAreaValue;//<T02>

        getReferralOwner({source : this.source, product : this.product})
        .then(result =>{  
            if(result){
                fields.OwnerId = result;
            }  
            console.log('onsubmit event recordEditForm'+ JSON.stringify(fields));

            this.template.querySelector('lightning-record-edit-form').submit(fields); 
        })
        .catch(error=>{
            console.log(`getReferralOwner --> error: ${error}`);
        }) 
    }
 
    
}

closeModal(event){    
    this.showSpinner = false;
    if(this.uploadedDocIds.length > 0){//<T02> start
        this.showSpinner = true;
        deleteFile({'fileIdsToDelete': this.uploadedDocIds})
        .then((result) => {
            if(result == false){
                console.log('unable to delete Files');
            }
        }).catch((error) => {
            console.log('file cannot be deleted ' , error);
        }).finally(() => {
            this.showSpinner = false;
        });
    }//</T02> end
    this.dispatchEvent(new CloseActionScreenEvent());
}

handleInputfieldChange(event){
   
    var fieldName = event.currentTarget.fieldName;
    var value = event.currentTarget.value;
    console.log(fieldName + ' ' + value );
    switch(fieldName){        
        case 'Source__c':
            this.source = value;
            if(value === 'Other'){
                this.showOther = true;
            }else{
                this.showOther = false;
            }
            break;   
        case 'Product__c':
            this.product = value;
            break;
        
    }
}

handleError(event){
    this.showSpinner = false;
    console.log('error >> '+ JSON.stringify(event.detail));
}

//T01
handleAccountChange(event){
    console.log('handleAccountChange, event.detail >> '+ JSON.stringify(event.detail));
    //console.log('handleAccountChange, event.target >> '+ JSON.stringify(event.target));
    this.accountId = (event.detail.value)[0];
}

handleLookupSearch(event){

    const lookupElement = event.target;
    let objParent = this;
    var dataId = event.target.getAttribute('data-id');
    //console.log('dataId >> '+ dataId);
    //console.log('dataId >> '+ JSON.stringify(event.detail));
    //console.log('Source >> '+ this.source);
    //console.log('recordId >> '+ this.record_Id);
    console.log('accountId >> '+ this.accountId);
    
    if(this.source != 'Plan'){
    lookupSearch({searchTerm :event.detail.searchTerm , selectedIds : event.detail.selectedIds , accountId: this.accountId})
        .then(results => {
            lookupElement.setSearchResults(results);
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        });
    }
    else{
        lookupSearchPlan({searchTerm :event.detail.searchTerm , selectedIds : event.detail.selectedIds , accountId: this.accountId, planId : this.record_Id})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
    }

}

handleLookupSelectionChange(event){
    this.selectedContactId = event.detail.values().next().value;
}
//load default plan contacts on focus as part of AR-2509

handleLoadDefault(objEvent){
    if(this.source == 'Plan'){
    let objParent = this;
    const lookupElement = objEvent.target;
    getDefaultRecords({ strRecordId: this.record_Id })
    .then((results) => {   
        lookupElement.setSearchResults(results);           
    })
    .catch((objError) => {
        objUtilities.processException(objError, objParent);
    }).finally(() => {
    });
   }// only fetch default if source = plan
}
  
    //Getter Methods
    get showStandardSearch() { //<T03>
        return ['Case', 'Account'].includes(this.objectApiName);
    }
	
	get productsMandatory(){//<T04> start
		if(this.source == 'Plan'){
			return false;
		}
		return true;
	}//</T04> end
}