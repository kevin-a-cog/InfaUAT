import {api, LightningElement,track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue,createRecord,updateRecord,deleteRecord} from 'lightning/uiRecordApi';
import lookupContactSearch from "@salesforce/apex/convertLeadController.lookupContactSearch";
import lookupOptySearch from "@salesforce/apex/convertLeadController.lookupOptySearch";
import getDefaultContactRecords from "@salesforce/apex/convertLeadController.getDefaultContactRecords";
import getDefaultOptyRecords from "@salesforce/apex/convertLeadController.getDefaultOptyRecords";
import fetchDefaultValues from "@salesforce/apex/convertLeadController.fetchDefaultValues";
import fetchRecordTypeDetails from "@salesforce/apex/RecordType_controller.fetchRecordTypeDetails";
import convertLead from "@salesforce/apex/CustomLeadConvert.convertLead";
import getContactFieldNames from "@salesforce/apex/convertLeadController.getContactFieldNames";
import ACCOUNT_NAME from '@salesforce/schema/Lead.Account__r.Name';
import ACCOUNT_ID from '@salesforce/schema/Lead.Account__c';
import EMAIL from '@salesforce/schema/Lead.Email';
import FIRST_NAME from '@salesforce/schema/Lead.FirstName'; 
import MIDDLE_NAME from '@salesforce/schema/Lead.MiddleName';
import LAST_NAME from '@salesforce/schema/Lead.LastName';
import TITLE from '@salesforce/schema/Lead.Title';
import COMPANY from '@salesforce/schema/Lead.Company';
import PHONE from '@salesforce/schema/Lead.Phone';
import SALUTATION from '@salesforce/schema/Lead.Salutation';
import ID_FIELD from '@salesforce/schema/Lead.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader'
import modal from '@salesforce/resourceUrl/leadconvertcustcss';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ConvertLead extends NavigationMixin (LightningElement) {
    activeSections = ['A','B','C'];
    connectedCallback() {
        loadStyle(this,modal);
    }
    @track accountDisplayName;
    @track showSearchAccount = false;
    @track isOptySelected=false;
    @api recordId;
    showLoading = true;
    isLeadConversion = false;    
    isNewAccount = false;
    showStdScreen = true;
    disableContact = true;
    ifDupliateContactExists = false;
    opportunityExists = false;
    accountId;
    leadEmail;
    salutation;firstName;middleName;lastName;emailID;title;company;phone;
    selectedContactId;
    contactId = null;
    opportunityId = null; 
    disableOpportunity = true;
    disableOppLookUp = false;
    selectedOptyId;
    opportunityName;
    customerRecordType;
    options;error;
    doNotCreateOpportunity = true;
    leadCompanyName;
    displayError = false;
    errorMessage;
    showLeadConversionPage;
    dupContactValidation = true;
    isEmailChanged = false;
    isContactUpdated = false;
    recordInfo = new Map();
    conFields=[];
    disableCreateOpp;
    selectedOpp=[];
    selectedCon=[];

    //Wire method to fetch fields to prepopulate from current lead record
    @wire(getRecord, {recordId: '$recordId', fields: [ACCOUNT_NAME,ACCOUNT_ID,EMAIL,COMPANY]})
    fetchAccount ({error, data}) { 
        if (data) {        
            this.accountDisplayName = getFieldValue(data, ACCOUNT_NAME);
            this.leadCompanyName = getFieldValue(data, COMPANY);
            this.accountId = getFieldValue(data, ACCOUNT_ID);
            this.emailID = getFieldValue(data, EMAIL);
            this.disableContact = false;                  
        } else if (error) { 
            this.accountDisplayName = error;
        }        
    }  
    // Wire method to fetch default values if Duplicate contact exixts
    @wire(fetchDefaultValues, {accountId: '$accountId',email:'$emailID'})
    wiredRecords ({error, data}) {  
        this.handleContactReset(); 
        if (data) {         
            this.opportunityExists = data.opportunityExists;
            if(data.contactExists == true) {
                this.ifDupliateContactExists = true;
                this.disableContact = true;
                this.isContactSelected = true;                
                this.contactId = data.ContactId;                     
            }                   
        } else if (error) { 
            this.handleContactReset();
            this.allocationError = error;
        }
    }
    //get contact field names and values to be displayed on UI
    @wire(getContactFieldNames, {leadId: '$recordId',contactId: '$contactId'})    
    contactFields({error,data}){
       this.showLoading = true 
        if(data){ 
            this.conFields=[];           
            for (const [key, value] of Object.entries(data)) {
                let keyValue = `${key}`.split("-");              
                this.conFields.push({key:keyValue[0],value:`${value}`,state:keyValue[1]=='true'? true : false});                
            }
            this.showLoading = false; 
        } else if(error) {
            this.showLoading = false; 
            console.log('Error fetching fields of contact dynamically on the UI',error);
        }
    }
    //get default record type for contact object     
    @wire(fetchRecordTypeDetails, {
        objectName: 'Contact'
    })
    wiredContactRecordType({error,data}) {
        if (data) {
            this.options = data;
            this.error = undefined;
            this.customerRecordType = data.find(element => element.Name == 'Customer Contact');
        } else if (error) {
            this.error = error;
            this.options = undefined;
        }
    }
    //handles event dispatched from Child Component - Search Account upon clicking Search/Change Account button
    handleshowSearchAccount(event){
        this.resetOnAccountChange();
        this.showSearchAccount = event.detail.searchAccount;
        if(this.accountDisplayName == null && this.displayError == true){
            this.displayError = false; 
        }
        this.accountDisplayName = event.detail.accFields.Name; 
        this.accountFields = event.detail.accFields;  //Stores the new account field values
        this.isNewAccount = event.detail.isNewAccount;    
        this.accountId = event.detail.accFields.AccountID;
        
    }
    //Updates variables upon clicking Search/Change Account button
    onClickAccountButton(){
        this.showSearchAccount = true;
        this.isLeadConversion = true;
    }
    //Updates varibale to handle closing of Search Account Component popup
    closeSearchAccount(){
        this.showSearchAccount = false;
    }
    //Handles Contact fields change on UI
    handleFieldChange(event){
        this.recordInfo.set(event.target.fieldName,event.target.value);
        this.conFields.forEach(element => {
            if(element.key == event.target.fieldName ){
                element.value = event.target.value;
                this.isContactUpdated = true;
            }       
        }); 
    }
    handleOppNameChange(event){
        this.opportunityName = event.target.value;
    }
    //Contact lookup search method
    handleLookupContactSearch(event){
        const lookupElement = event.target;
        let objParent = this;
        lookupContactSearch({searchTerm :event.detail.searchTerm , email:this.emailID})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
    }
    //fetch values of contact record selected in lookup
    handleContactLookupSelectionChange(event){
        this.showLoading = true;   
        this.resetDefaultValues();
        this.selectedContactId = event.detail.values().next().value;
        this.contactId = this.selectedContactId;       
        this.showLoading = false;             
    }
    //contact lookup default values method
    handleLoadContactDefault(objEvent){     
        let objParent = this;
        const lookupElement = objEvent.target;
        this.showLoading = true;
        getDefaultContactRecords({email:this.emailID})
            .then((results) => {   
                lookupElement.setSearchResults(results);  
                this.showLoading = false;
            })
            .catch((objError) => {
                objUtilities.processException(objError, objParent);
                this.showLoading = false;
            });
    }
    // Contact lookup method ends
    
    //Opportunity lookup method
    handleLookupOpptySearch(event){
        const lookupElement = event.target;
        let objParent = this;
        lookupOptySearch({searchTerm :event.detail.searchTerm , accountId: this.accountId})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
    }
    //fetch values of opportunity record selected in lookup
    handleOpportunitySelectionChange(event){  
        this.selectedOptyId = event.detail.values().next().value;
        this.opportunityId = this.selectedOptyId;
        if(this.opportunityId != null){
            this.disableCreateOpp = true;
        }else {
            this.disableCreateOpp = false;
        }        
    }
    //opportunity lookup default values method
    handleLoadOpptyDefault(objEvent){  
        let objParent = this;
        const lookupElement = objEvent.target;
        this.showLoading = true;
        getDefaultOptyRecords({accountId: this.accountId})
            .then((results) => {   
                lookupElement.setSearchResults(results);  
                this.showLoading = false;
            })
            .catch((objError) => {
                objUtilities.processException(objError, objParent);
                this.showLoading = false;
            });
       }
    //Opportunity lookup method ends
    
    //handles Create new Opportunity checkbox changes
    handleCreateOpp(event){
        if(event.target.checked){
            this.disableOpportunity = false;
            this.disableOppLookUp = true;
            this.doNotCreateOpportunity = false ;
            this.opportunityName = this.leadCompanyName;
        } else{
            this.handleReset();
            this.disableOpportunity = true;
            this.disableOppLookUp = false;
            this.doNotCreateOpportunity= true;
        }
    }
    //handles Convert button 
    handleConvert(event){
        event.preventDefault();
        let isValid = true
        let accountValidation = true
        let contactValidation = true
        let oppValidation = true        
        // Set doNotCreateOpportunity Boolean
        if(this.disableOppLookUp == false && this.opportunityId != null){
                this.doNotCreateOpportunity = false;
        }
        //Check for validation
        if (this.accountDisplayName == null || this.accountDisplayName == undefined || this.accountDisplayName == '') {
            this.errorMessage = 'Please click on Search/Create button to select an Account';
            this.displayError = true;
            accountValidation = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.errorMessage,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } 
        else if( this.ifDupliateContactExists == true && (this.contactId == null || this.contactId == undefined || this.contactId == '')){
            this.errorMessage = 'Please select an existing contact before converting';
            this.displayError = true;
            accountValidation = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.errorMessage,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                oppValidation = false;
            }
        });
        inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {               
            contactValidation = inputField.reportValidity();           
        });
        isValid = accountValidation && contactValidation && oppValidation
        //Validation ends  
        //Check for Duplicate contacts
        if( isValid == true){
            this.createAccount();
        }     
    }
    //Account creation start
    createAccount(){
        this.showLoading = true;
        //Set variables for doNotCreateOpportunity
            if(this.doNotCreateOpportunity == true){
                this.handleReset();
            } 
            if(this.doNotCreateOpportunity == false && this.opportunityId != null){
                this.opportunityName =null;
            }
        // 
        if(this.isNewAccount == true){
            var fields = {
                'Name': this.accountFields.Name,
                'DUNS__c': this.accountFields.DUNS__c,
                'BillingStreet': this.accountFields.BillingStreet,
                'BillingCity': this.accountFields.BillingCity,
                'BillingState': this.accountFields.BillingState,
                'BillingPostalCode': this.accountFields.BillingPostalCode,
                'BillingCountry': this.accountFields.BillingCountry,
                'RecordTypeId': this.accountFields.RecordTypeId,
                'Phone':this.accountFields.Phone,
                'Website':this.accountFields.Website
            };
            var objRecordInput = {
                "apiName": "Account",
                fields
            };  
            createRecord(objRecordInput)
                .then(response => {
                    this.accountId = response.id;
                    this.leadConversion(this.recordId,this.contactId,this.accountId,this.opportunityId,this.doNotCreateOpportunity,this.opportunityName);
                    }).catch(error => {
                        this.errorMessage = error.message;
                        //this.displayError = true;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: error.message,
                            variant: 'error',
                        });
                    this.dispatchEvent(evt);
                    this.showLoading = false;
                });
        } else {
            this.leadConversion(this.recordId,this.contactId,this.accountId,this.opportunityId,this.doNotCreateOpportunity,this.opportunityName);
        }
    }   
    //Account creation end 

    // Lead conversion method
    leadConversion(leadId, contactId, accountId,opportunityId,doNotCreateOpportunity,opportunityName){ 
        convertLead({'leadId':leadId ,'contactId':contactId ,'accountId':accountId ,'opportunityId':opportunityId, 'doNotCreateOpportunity' : doNotCreateOpportunity, 'opportunityName' :opportunityName})
            .then(results => {                        
                if(results.response == 'failed'){
                    if(this.isNewAccount == true){
                        this.deleteAccount(this.accountId);
                    }
                    this.errorMessage = results.error;
                    this.displayError = true;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: results.error,
                        variant: 'error',
                    });
                this.dispatchEvent(evt);
                } else {                    
                    this.accountId = results.accountId;
                    this.contactId = results.contactId;
                    this.opportunityId = results.opportunityId;
                    if(this.isContactUpdated == true){
                        this.updateContact(this.contactId);
                    } 
                    this.showStdScreen = false;                   
                    this.showLeadConversionPage = true;
                }
            this.showLoading = false;                                               
            }).catch(error => {
                this.errorMessage = error;
                if(this.isNewAccount == true){
                    this.deleteAccount(this.accountId);
                }
                this.showLoading = false;
                //this.displayError = true;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error',
                });
            this.dispatchEvent(evt);
            })
    }
    // Lead conversion end
    //Update Contact Record after update
    updateContact(contactId){        
        let fields = {};
        this.conFields.forEach(element =>{
            fields[element.key] = element.value;
        });
        fields['Id'] = contactId;
        const recordInput = { fields };        
        updateRecord(recordInput)
            .then(results => {                               
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured during Contact update, please reach out to your administrator for assistance',
                    variant: 'error',
                }); 
                this.dispatchEvent(evt);           
            })        
    }
    
    // Delete Account record created upon error
    deleteAccount(accountId){
        deleteRecord(accountId)
            .then(() => { 
            }).catch(error =>{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured during Account delete, please reach out to your administrator for assistance',
                    variant: 'error',
                });
            })                   
    }
    //resets opportunity varibales if doNotCreateOpportunity = true
    handleReset(){
        this.opportunityName =null;
        this.opportunityId =null;
    }
    // resets contact related variables
    handleContactReset(){
        this.ifDupliateContactExists = false;
        this.disableContact = false;
    }
    // resets contact input text fields
    resetDefaultValues(){
        this.conFields.forEach(element =>{
            element.value ='';
        });
        this.contactId = '';
        this.errorMessage = '';
        this.displayError = false;
    } 
    // resets Opportunity attributes if Account is changed
    resetOnAccountChange(){
        this.disableCreateOpp = false;
        this.selectedOptyId = '';
        this.opportunityId = null;
        this.errorMessage = '';
        this.displayError = false;
        this.selectedOpp = [];
        this.selectedCon=[];
    } 
    /*
     * Set boolean variable to false, to close the Modal
     */
    closeModal() {
        this.handleReset();
        this.handleContactReset();
        this.resetDefaultValues();
        this.dispatchEvent(new CloseActionScreenEvent());
        
    }  
    closeConversionPage(){
        this.closeModal();
        this.handleGoToLeads();
    }  
    handleGoToLeads(){        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });        
    }
}