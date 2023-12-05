import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MsaCodeWarning from '@salesforce/label/c.MsaCodeWarning';
import countryUS from '@salesforce/label/c.countryUS';
import getCountryList from '@salesforce/apex/addressDependentPicklistController.getCountryList';
import getStateList from '@salesforce/apex/addressDependentPicklistController.getStateList';
import getCityList from '@salesforce/apex/addressDependentPicklistController.getCityList';
import updateAddress from '@salesforce/apex/addressDependentPicklistController.updateAddress';
import getDefaultValues from '@salesforce/apex/addressDependentPicklistController.getDefaultValues';

export default class AddressDependentPicklist extends LightningElement {
labels = { MsaCodeWarning, countryUS };
@track countryOptions;
@track stateOptions;
@track cityOptions;
@track selectedCountryValue;
@track selectedStateValue;
@track selectedCityValue;
tempCountry;
tempState;
tempCity;
tempCountryOptions;
tempStateOptions;
tempCityOptions;
disabledCountry = true;
disabledState = true;
disabledCity = true;
showButtons = false;
isLoading = false;
disableSave = false;
displayWarning = false;
displayNonUSValidationError = false;
errorMessage = '';

@api recordId;
    //On page load - Get the saved values and the related picklist options
    connectedCallback(){
        getDefaultValues({recordId: this.recordId})
        .then((result) => {
            this.selectedCountryValue = result.Country;
            this.selectedStateValue = result.State;
            this.selectedCityValue = result.City;
            this.tempCountry = result.Country;
            this.tempState = result.State;
            this.tempCity = result.City;
            
            let cOptions = [];
            for (let keyC in result.CountryOptions) {
                cOptions.push({ label: result.CountryOptions[keyC], value: result.CountryOptions[keyC]});
            }
            this.countryOptions = cOptions;

            let sOptions = [];
            for (let keyS in result.StateOptions) {
                sOptions.push({ label: result.StateOptions[keyS], value: result.StateOptions[keyS]});
            }
            this.stateOptions = sOptions;

            let cyOptions = [];
            for (let keyCy in result.CityOptions) {
                cyOptions.push({ label: result.CityOptions[keyCy], value: result.CityOptions[keyCy]});
            }
            this.cityOptions = cyOptions;

            this.tempCountryOptions = cOptions;
            this.tempStateOptions = sOptions;
            this.tempCityOptions = cyOptions;
        })
        .catch((error) => {
            console.log('getDefaultValues error....');
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error); 
        });          
    }
    
    //Call Apex method to get Country List
    getCountries(){
        let options = [];
        getCountryList()
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
        getStateList({countryName: this.selectedCountryValue})
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
        getCityList({countryName: this.selectedCountryValue, stateName: this.selectedStateValue})
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
        this.displayWarning = false;
        this.displayNonUSValidationError = false;
        this.disableSave = false;      
        this.selectedCountryValue = event.target.value;
        this.selectedStateValue = '';
        this.selectedCityValue = '';
        this.stateOptions = [];
        this.cityOptions = [];
        this.getStates();    
        if(event.target.value == countryUS){
            this.displayWarning = true;
            this.disableSave = true;
            this.disabledState = true;
            this.disabledCity = true;
        }    
        else{
            this.displayWarning = false;
            this.disableSave = false;
            this.disabledState = false;
            this.disabledCity = false;
        }
    }
    //On State change
    handleStateChange(event){
        this.displayNonUSValidationError = false;
        this.selectedStateValue = event.target.value;
        this.cityOptions = [];
        this.selectedCityValue = '';
        this.getCities();
    }
    //On City change
    handleCityChange(event){
        this.displayNonUSValidationError = false;
        this.selectedCityValue = event.target.value;
    }
    //Event on Address edit
    handleEdit(event){
        if(this.selectedCountryValue == countryUS){
            this.disabledState = true;
            this.disabledCity = true;
        } 
        else{
            this.disabledState = false;
            this.disabledCity = false;
        }
        this.disabledCountry = false;        
        this.showButtons = true;
        if(this.selectedCountryValue != countryUS){
            this.disableSave = false;
        }
    }
    //Event on Cancel
    handleCancel(event){
        this.showButtons = false;
        this.displayNonUSValidationError = false;
        this.displayWarning = false;
        this.disabledCountry = true;
        this.disabledState = true;
        this.disabledCity = true;
        this.selectedCountryValue = this.tempCountry;
        this.selectedStateValue = this.tempState;
        this.selectedCityValue = this.tempCity;
        
        this.countryOptions = this.tempCountryOptions;
        this.stateOptions = this.tempStateOptions;
        this.cityOptions = this.tempCityOptions;
    }
    //Event on Address Save
    handleSave(event){
        this.isLoading = true;
        this.tempCountry = this.selectedCountryValue;
        this.tempState = this.selectedStateValue;
        this.tempCity = this.selectedCityValue;
        this.tempCountryOptions = this.countryOptions; 
        this.tempStateOptions = this.stateOptions;
        this.tempCityOptions = this.cityOptions;
        //Add validation for mandatory fields
        if(!(this.selectedCountryValue && this.selectedStateValue && this.selectedCityValue)){
            this.displayNonUSValidationError = true;
            this.errorMessage = '* Country, State, and City are mandatory for Non-US Project location.';
            this.isLoading = false;
        }
        else{
            updateAddress({recordId: this.recordId, countryName: this.selectedCountryValue, stateName: this.selectedStateValue, cityName: this.selectedCityValue})
            .then((result) => {
                if(result === 'SUCCESS'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Address updated successfully',
                            variant: 'success'
                        })
                    );
                    this.showButtons = false;
                    this.disabledCountry = true;
                    this.disabledState = true;
                    this.disabledCity = true;
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('In handleSave error....');
                this.error = error;
                // This way you are not to going to see [object Object]
                console.log('Error is', this.error); 
            });  
        }
    }
}