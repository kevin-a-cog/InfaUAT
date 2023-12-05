import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import createProjLocation from '@salesforce/apex/psaCreateProjectLocationController.createProjLocation';
import getCountryListWithoutUS from '@salesforce/apex/addressDependentPicklistController.getCountryListWithoutUS';
import getStateList from '@salesforce/apex/addressDependentPicklistController.getStateList';
import getCityList from '@salesforce/apex/addressDependentPicklistController.getCityList';

export default class PsaCreateProjectLocation extends NavigationMixin(LightningElement) {
    value = '';
    valuePrimary = '';
    primaryValue = false;
    showButtons = false;
    showPrevButton = false;
    showNextButton = false;
    showSaveButton = false;
    showSaveButtonUS = false;
    showPrevButtonUS = false;
    isFirstPage = true;
    isUS = false;
    isNonUS = false;
    isHome = false;
    state;
    country;
    city;
    psaMSACode;
    @api recordId;
    loaded = true;
    countryOptions;
    stateOptions;
    cityOptions;
    displayMSACodeError = false;
    displayNonUSValidationError = false;
    errorMessage = '';
    
    get options() {
        return [
            { label: 'United States', value: 'US' },
            { label: 'Non-United States', value: 'Non-US' },
            { label: 'Home Location - Remote Employee', value: 'Home' },
        ];
    }
    get optionsPrimary(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
    onRadioOptionChanged(event){
        this.value = event.target.value;
        this.showButtons = true;
        this.showNextButton = true;
        this.isUS = false;
        this.isNonUS = false;
        this.isHome = false;
    }
    onRadioPrimaryChanged(event){
        this.valuePrimary = event.target.value;
        if(this.value == 'US'){
            this.showSaveButton = false;
            this.showSaveButtonUS = true;
        }
        else{
            this.showSaveButton = true;
            this.showSaveButtonUS = false;
        }
    }
    handlePrevious(event){
        this.isFirstPage = true;
        this.isSecondPage = false;
        this.showSaveButton = false;
        this.showPrevButton = false;
        this.showNextButton = true;
        this.showButtons = true;
        this.displayMSACodeError = false;
        this.displayNonUSValidationError = false;
    }
    handleNext(event){
        this.isFirstPage = false;
        this.isSecondPage = true;
        this.showPrevButton = true;
        this.showNextButton = false;
        if(this.value === 'US'){
            this.isUS = true;            
            this.showButtons = false;
            this.showPrevButtonUS = true;
        }
        else if(this.value === 'Non-US'){
            this.isNonUS = true;
            this.getCountries();
        }
        else{
            this.isHome = true;
        }
        if(this.valuePrimary){
            this.showSaveButton = true;
            this.showSaveButtonUS = true;
        }
    }
    handleSave(event){   
        if(this.isHome){
            this.state = '';
            this.country = '';
            this.city = '';
            this.psaMSACode = null;
        }
        else if(this.isNonUS){
            this.psaMSACode = null;
        }  
        else if(this.isUS){
            this.state = '';
            this.country = '';
            this.city = '';
        }   
        if(this.isNonUS && !(this.state && this.country && this.city)){
            console.log('inside the Non US Error if condition');
            this.displayNonUSValidationError = true;
            this.errorMessage = '* Country, State, and City are mandatory for Non-US Project location.';
        }        
        else{
            this.loaded = false;
            this.showButtons = false;
            this.getPrimaryValue();  
            createProjLocation({projId : this.recordId, isPrimary: this.primaryValue, isHomeLocation : this.isHome, psaMsaCode : this.psaMSACode,
                                state: this.state, country : this.country, city : this.city })
            .then((result) => {
                if(result){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Project Location created',
                            variant: 'success'
                        })
                    );                
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'pse__Project_Location__c',
                            actionName: 'view'
                        }
                    });
                }
            })
            .catch((error) => {
                console.log('In handleSave error....');
                this.error = error;
                // This way you are not to going to see [object Object]
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.log('Error is', this.error); 
                this.dispatchEvent(new CloseActionScreenEvent());
            }); 
        }
    }
    handleSubmit(event){
        // stop the form from submitting
        event.preventDefault();       
        if(this.isUS && !this.psaMSACode){
            this.displayMSACodeError = true;
            this.errorMessage = '* PSA MSA code mapping is mandatory for US location';
        }  
        else{
            //get all the fields
            const fields = event.detail.fields;
            
            //Map remainig fields to values here 
            this.getPrimaryValue();
            fields.pse__Project__c = this.recordId;
            fields.psa_pm_Primary__c = this.primaryValue;
            
            //submit the form
            this.template.querySelector('lightning-record-edit-form').submit(fields);               
            this.loaded = false;
            this.showPrevButtonUS = false;
            this.showSaveButtonUS = false;
            this.showButtons = false;
        }
    }
    handleSuccess(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Project Location created',
                variant: 'success'
            })
        );                
        this.dispatchEvent(new CloseActionScreenEvent());
        console.log(event);
        
        var payload = event.detail.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: payload,
                objectApiName: 'pse__Project_Location__c',
                actionName: 'view'
            }
        });
    }
    handleError(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Failed',
                message: event.detail.detail,
                variant: 'error'
            })
        ); 
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleMSACodeSelect(event){
        this.psaMSACode = event.target.value;
        this.displayMSACodeError = false;
    }
    getPrimaryValue(){
    if(this.valuePrimary == 'Yes')
        this.primaryValue = true;
        else
        this.primaryValue = false;
    }
    //Call Apex method to get Country List
    getCountries(){
        let options = [];
        getCountryListWithoutUS()
        .then((result) => {
            for (var key in result) {
                options.push({ label: result[key], value: result[key]});
            }
            this.countryOptions = options;
        })
        .catch((error) => {
            console.log('In getCountries....');
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error); 
        });  
    }
    //Call Apex method to get State List
    getStates(){
        let options = [];
        getStateList({countryName: this.country})
        .then((result) => {
            for (var key in result) {
                options.push({ label: result[key], value: result[key]});
            }
            this.stateOptions = options;
        })
        .catch((error) => {
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error); 
        });  
    }
    //Call Apex method to get City List
    getCities(){
        let options = [];
        getCityList({countryName: this.country, stateName: this.state})
        .then((result) => {
            for (var key in result) {
                options.push({ label: result[key], value: result[key]});
            }
            this.cityOptions = options;
        })
        .catch((error) => {
            console.log('In getCityList....');
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error); 
        });  
    }
     //On Country change
     handleCountryChange(event){  
        this.country = event.target.value;
        this.stateOptions = [];
        this.cityOptions = [];
        this.state = '';
        this.city = '';
        this.getStates();   
     }
     //On State change
    handleStateChange(event){
        this.state = event.target.value;
        this.cityOptions = [];
        this.city = '';
        this.getCities();
    }
    //On City change
    handleCityChange(event){
        this.city = event.target.value;
        this.displayNonUSValidationError = false;
    }
}