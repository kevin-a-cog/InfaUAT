import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAccounts from "@salesforce/apex/AccountSearchController.searchAccounts";
import fetchRecordTypeDetails from "@salesforce/apex/RecordType_controller.fetchRecordTypeDetails";
import hasStdAccountScreenEnabled from '@salesforce/customPermission/Enable_Standard_Account_Create';
import hasStdAccountScreenAsDefault from '@salesforce/customPermission/Enable_Standard_Account_Screen_As_Default';
import {
    createRecord
} from 'lightning/uiRecordApi';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class SearchAccount extends NavigationMixin(LightningElement) {
    @track arrayOfAccountMap = [];
    @track disableSwitch = false;
    @track isAccountSelected = false;
    @track numberOfResults = '25';
    @track saveLoading = false;
    @track selectedOption;
    @track showLoading = false;
    @track isResultBlank = false;
    @track showStdScreen = hasStdAccountScreenAsDefault;
    selectedAccount;
    //**SALESRT-13356
    @api showSearchAccount;
    @api isLeadConversion = false;
    @api leadCompanyName;
    @api saveLoading
    //**
    address = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    };

    searchParamsMap = {
        name: '',
        city: '',
        address: '',
        state: '',
        country: '',
        postal_code: '',
        gduns: '',
        account_number: '',
        phoneNumber:'',
        website:''
    };
        
    website;
    phoneNumber;
    accountsList = [];
    accountName;
    accountNumber;
    accountSiteDuns;
    addressStreet;
    addressCity;
    addressState;
    addressPostal;
    addressCountry;
    doneTypingInterval = 300;
    options;
    prospectRecordType;
    searchResultNotAvailable = false;
    selectedAccountId;
    typingTimer;
    validated = false;

    /*
     * check if logged in user has custom permission for standard account screen
     */
    get isStdAccountScreenEnabled() {  
        return hasStdAccountScreenEnabled;
    }

    /*
     * get label for save button based on selectedAccountId
     */
    get saveLabel() {
        return this.selectedAccountId && this.isAccountSelected ? 'Go To Account' : 'Save';
    }
    
    /*
     * get values for radio buttons which sets rows to be returned
     */
    get optionsForResult() {
        return [{
                label: '5',
                value: '5'
            },
            {
                label: '10',
                value: '10'
            },
            {
                label: '15',
                value: '15'
            },
            {
                label: '25',
                value: '25'
            },
        ];
    }

    /*
     * check if save needs to be enabled
     */
    get enableSave() {
        return !((this.searchResultNotAvailable || this.validated) && this.accountName);
    }

    /*
     * get class name for modal
     */
    get modalClass() {
        return this.saveLoading ? this.showStdScreen ? 'slds-modal__content modalBody' : 'slds-modal__content modalBody fix-height' : this.showStdScreen ? 'slds-modal__content' : 'slds-modal__content fix-height';
    }

    /*
     * get modal header name
     */
    get modalHeader() {
        return this.showStdScreen ? 'New Account' : 'New Account: Prospect Account';
    }

    /*
     * get record types logged in user has access to and set prospectRecordType
     */
    @wire(fetchRecordTypeDetails, {
        objectName: 'Account'
    })
    wiredAccountRecordType({
        error,
        data
    }) {
        if (data) {
            this.options = data;
            this.error = undefined;
            this.prospectRecordType = data.find(element => element.Name == 'Prospect Account');
        } else if (error) {
            this.error = error;
            this.options = undefined;
        }
        //**SALESRT-13356
        if(this.leadCompanyName != null && this.leadCompanyName != ''){
            this.accountName = this.leadCompanyName;
            this.searchParamsMap.name = this.leadCompanyName;
            this.getSearchResult(); 
        }    
        //
    }

    /*
     * get updated values for radio buttons which sets rows to be returned
     */
    handleRadioButtonChange(event) {
        this.numberOfResults = event.target.value;
        this.getSearchResult();
    }

    /*
     * handle address value changes
     */
    addressInputChange(event) {
        if (this.isAccountSelected) {
            return;
        }
        this.clearAllValues();

        this.addressStreet = event.target.street ? event.target.street : '';
        this.searchParamsMap.address = event.target.street ? event.target.street : '';

        this.addressCity = event.target.city ? event.target.city : '';
        this.searchParamsMap.city = event.target.city ? event.target.city : '';

        this.addressState = event.target.province ? event.target.province : '';
        this.searchParamsMap.state = event.target.province ? event.target.province : '';

        this.addressPostal = event.target.postalCode ? event.target.postalCode : '';
        this.searchParamsMap.postal_code = event.target.postalCode ? event.target.postalCode : '';

        this.addressCountry = event.target.country ? event.target.country : '';
        this.searchParamsMap.country = event.target.country ? event.target.country : '';

        if (this.accountName && this.addressStreet && this.addressCity && this.addressCountry) {
            this.validated = true;
        } else {
            this.validated = false;
        }
        if (this.addressStreet || this.addressCity || this.addressState || this.addressCountry) {
            this.accountsList = [];
            this.selectedAccountId = '';
            this.arrayOfAccountMap = [];
            this.getSearchResult();
        }
    }

    /*
     * handle account name changes
     */
    accountNameChange(event) {
        if (this.isAccountSelected) {
            return;
        }
        this.clearAllValues();
        if (event.target.value) {
            this.accountName = event.target.value;
            this.searchParamsMap.name = event.target.value;
        } else {
            this.accountsList = [];
            this.accountName = '';
            this.selectedAccountId = '';
            this.arrayOfAccountMap = [];
            this.searchParamsMap.name = '';
        }
        this.getSearchResult();
    }
    /*
     * handle phone number changes
     */     
    phoneNumberChange(event){
        if (this.isAccountSelected) {
            return;
        }
        this.clearAllValues();
        if (event.target.value) {
            this.phoneNumber= event.target.value;
            this.searchParamsMap.phoneNumber = event.target.value;
        } else {
            this.accountsList = [];
            this.accountName = '';
            this.selectedAccountId = '';
            this.arrayOfAccountMap = [];
            this.searchParamsMap.phoneNumber = '';
        }
        this.getSearchResult();
    }
    /*
     * handle account website changes
     */
    webSiteChange(event){
        if (this.isAccountSelected) {
            return;
        }
        this.clearAllValues();
        if (event.target.value) {
            this.website = event.target.value;
            this.searchParamsMap.website = event.target.value;
        } else {
            this.accountsList = [];
            this.accountName = '';
            this.selectedAccountId = '';
            this.arrayOfAccountMap = [];
            this.searchParamsMap.website = '';
        }
        this.getSearchResult();
    }
    
    /*
     * handle account site DUNS changes
     */
    accountSiteDunsChange(event) {
        if (this.isAccountSelected) {
            return;
        }
        this.clearAllValues();
        if (event.target.value) {
            this.accountSiteDuns = event.target.value;
            this.searchParamsMap.gduns = event.target.value;
        } else {
            this.accountsList = [];
            this.accountSiteDuns = '';
            this.selectedAccountId = '';
            this.arrayOfAccountMap = [];
            this.searchParamsMap.gduns = '';
        }
        this.getSearchResult();
    }

    /*
     * handle api call to get account search response
     */
    getSearchResult() {
        this.saveLoading = false;  //**SALESRT-13356
        clearTimeout(this.typingTimer);
        this.typingTimer = setTimeout(() => {
            if (this.accountName || this.addressStreet || this.addressCity || this.addressState || this.addressPostal || this.addressCountry || this.accountSiteDuns|| this.phoneNumber|| this.website ) {
                this.showLoading = true;
                this.accountsList = [];
                searchAccounts({
                    searchParamsMap: this.searchParamsMap,
                    countOfResult: this.numberOfResults,
                    leadConversion: this.isLeadConversion
                }).then((result) => {
                    this.showLoading = false;                   
                    this.accountsList = result;
                    this.arrayOfAccountMap = this.convertListToMap();
                    this.isResultBlank = result.length == 0 ? true : false;
                }).catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: "You've encountered some errors when trying to search Account, please contact admin",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.showLoading = false;
                    this.saveLoading = false;
                    this.disableSwitch = false;
                })
            }
        }, this.doneTypingInterval);
    }

    /*
     * Set boolean variable to false, to close the Modal
     */
    closeModal() {
        this.resetScreen();
        this.handleReset();
        const closeModalEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(closeModalEvent);
    }

    /*
     * depending on criteria handle when save button is clicked
     * 1) If account selected doesn't have salesforce Id, create account
     * 2) If account selected has salesforce Id, redirect to account
     * 3) If no account selected, all required fields entered then create prospect account 
     */
    handleSave(event) {
        event.preventDefault();
        if (!this.validateRequiredFields()) {
            return
        }
        this.saveLoading = true;
        this.disableSwitch = true;
        this.searchResultNotAvailable = false;
        this.validated = false;

        if (this.selectedAccountId) {
            this.navigateToEditAccountPage(this.selectedAccountId);
            return;
        }

        var fields = {
            'Name': this.accountName,
            'DUNS__c': this.accountSiteDuns,
            'BillingStreet': this.addressStreet,
            'BillingCity': this.addressCity,
            'BillingState': this.addressState,
            'BillingPostalCode': this.addressPostal,
            'BillingCountry': this.addressCountry,
            'RecordTypeId': this.prospectRecordType.Id,
            'Phone':this.phoneNumber,
            'Website':this.website
        };

        var objRecordInput = {
            'apiName': 'Account',
            fields
        };

        createRecord(objRecordInput).then(response => {
            const recordId = response.id;
            this.navigateToEditAccountPage(recordId);

        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: "You've encountered some errors when trying to save Account, please contact admin and reset form to search again",
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.saveLoading = false;
            this.disableSwitch = false;
        });
    }

    /*
     * SALESRT-13356 Polaris - Revisit of the entire Lead Conversion Button
     * depending on criteria handle when save button is clicked
     * 1) If account selected doesn't have salesforce Id, create account
     * 2) If account selected has salesforce Id, redirect to Lead Conversion Page
     * 3) If no account selected, all required fields entered then store account details and navigatet to lead Conversion page
     */
    handleSaveLead(event) {
        event.preventDefault();
        if (!this.validateRequiredFields()) {
            return
        }
        this.saveLoading = true;
        this.disableSwitch = true;
        this.searchResultNotAvailable = false;
        this.validated = false;
        this.showSearchAccount = false;  
        let isNewAccount = false;
        if (this.selectedAccountId){
            isNewAccount = false;
        }
        else{
            isNewAccount = true;
        }          
        let accountFields = {
            'Name': this.accountName,
            'AccountID': this.selectedAccountId,
            'DUNS__c': this.accountSiteDuns,
            'BillingStreet': this.addressStreet,
            'BillingCity': this.addressCity,
            'BillingState': this.addressState,
            'BillingPostalCode': this.addressPostal,
            'BillingCountry': this.addressCountry,
            'RecordTypeId': this.prospectRecordType.Id,
            'Phone':this.phoneNumber,
            'Website':this.website
        };
        //Created Event
        const selectEvent = new CustomEvent('selected', {
            detail: {searchAccount:this.showSearchAccount, accFields:accountFields, isNewAccount:isNewAccount}
            });
        //Dispatch Event
        this.dispatchEvent(selectEvent);

    }

    validateRequiredFields() {
        const address = this.template.querySelector('lightning-input-address');
        let country = address.country;
        let street = address.street;
        let city = address.city;
        if (!country) {
            address.setCustomValidityForField('Complete this field', 'country');
        } else {
            address.setCustomValidityForField("", 'country');
        }
        if (!street) {
            address.setCustomValidityForField('Complete this field', 'street');
        } else {
            address.setCustomValidityForField("", 'street');
        }
        if (!city) {
            address.setCustomValidityForField('Complete this field', 'city');
        } else {
            address.setCustomValidityForField("", 'city');
        }
        address.reportValidity();
        const isValid = address.checkValidity();
        return isValid;
    }

    /* 
     * Navigate to Edit Account Page
     */
    navigateToEditAccountPage(recordId) {
        this.clearAllValues();
        this.clearAccountValues();
        this.resetScreen();
        this.arrayOfAccountMap = [];
        this.saveLoading = false;
        this.disableSwitch = false;
        this.accountName = '';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    /* 
     * handle when an account is selected or unselected
     */
    handleSelect(event) {
        this.isAccountSelected = false;
        const selectedIndex = event.detail;
        let selectedObj;
        let self = this;
        this.arrayOfAccountMap.forEach(function (element, index) {
            if (index == selectedIndex) {
                element.selected = !element.selected;
                selectedObj = element;
                self.isAccountSelected = element.selected;
                if (element.selected) {
                    self.selectedAccountId = selectedObj.fields.salesforce_id;
                } else {
                    self.selectedAccountId = '';
                }
            } else {
                element.selected = false;
            }
        });
        this.accountName = selectedObj.fields.accountName;
        this.addressPostal = selectedObj.fields.postalCode;
        this.addressState = selectedObj.fields.state;
        this.addressCity = selectedObj.fields.city;
        this.addressStreet = selectedObj.fields.address;
        this.addressCountry = selectedObj.fields.country;
        this.accountNumber = selectedObj.fields.accountNumber;
        this.accountSiteDuns = selectedObj.fields.site_gduns;
        this.phoneNumber = selectedObj.fields.phoneNumber;
        this.website = selectedObj.fields.website;
        this.selectedAccount = selectedObj;
        this.validated = true;
    }

    /* 
     * used to clear value for searching
     */
    clearAllValues() {

        this.accountNumber = '';
        this.selectedAccountId = '';
        this.selectedAccount = '';
        this.isAccountSelected = false;
        this.searchResultNotAvailable = false;
        this.validated = false;
        this.isResultBlank = false;
    }

    /* 
     * used to clear value for searching
     */
    clearAccountValues() {
        this.addressPostal = '';
        this.addressState = '';
        this.addressCity = '';
        this.addressStreet = '';
        this.addressCountry = '';
        this.accountSiteDuns = '';
        this.phoneNumber='';
        this.website='';
    }

    /* 
     * reset all variables
     */
    handleReset() {
        this.addressPostal = '';
        this.addressState = '';
        this.addressCity = '';
        this.addressStreet = '';
        this.addressCountry = '';
        this.accountNumber = '';
        this.accountSiteDuns = '';
        this.phoneNumber='';
        this.website='';
        this.searchResultNotAvailable = false;
        this.validated = false;
        this.isAccountSelected = false;
        this.isResultBlank = false;
        this.arrayOfAccountMap = [];
        this.accountsList = [];
        this.accountName = [];
        this.selectedAccountId = '';
        this.searchParamsMap = {
            name: '',
            city: '',
            address: '',
            state: '',
            country: '',
            postal_code: '',
            gduns: '',
            account_number: ''
        };
    }

    /* 
     * handle switch screen button
     */
    handleSwitch(event) {
        this.showStdScreen = !this.showStdScreen;
    }

    /* 
     * handle record type change event
     */
    handleRecordTypeChange(event) {
        this.selectedOption = event.detail;
    }

    /* 
     * handle Next button on standard account screen
     */
    handleNext() {
        this.resetScreen();
        const closeModalEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(closeModalEvent);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                recordTypeId: this.selectedOption

            }
        });
    }

    /* 
     * helper method to convert List to Map
     */
    convertListToMap() {
        let arrayOfMap = [];
        if (this.accountsList.length > 0) {
            this.accountsList.forEach(function (element, index) {
                arrayOfMap.push({
                    "fields": element,
                    "Id": index,
                    "selected": false
                });
            });
        } else {
            this.searchResultNotAvailable = true;
        }
        return arrayOfMap;
    }

    resetScreen() {
        this.showStdScreen = hasStdAccountScreenAsDefault;
    }
}