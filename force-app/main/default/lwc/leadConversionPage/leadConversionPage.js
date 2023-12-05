import { LightningElement,api,wire} from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {loadStyle} from 'lightning/platformResourceLoader';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_RECORDTYPE from '@salesforce/schema/Account.RecordType.Name';
import ACCOUNT_BILLINGADDRESS from '@salesforce/schema/Account.BillingAddress';
import ACCOUNT_PHONE from '@salesforce/schema/Account.Phone';
import ACCOUNT_WEBSITE from '@salesforce/schema/Account.Website';
import ACCOUNT_HEALTH from '@salesforce/schema/Account.Account_Health__c';
import ACC_BillingCity from '@salesforce/schema/Account.BillingCity';
import ACC_BillingStreet from '@salesforce/schema/Account.BillingStreet';
import ACC_BillingState from '@salesforce/schema/Account.BillingState';
import ACC_BillingPostalCode from '@salesforce/schema/Account.BillingPostalCode';
import ACC_BillingCountry from '@salesforce/schema/Account.BillingCountry';
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import CONTACT_TITLE from '@salesforce/schema/Contact.Title';
import CONTACT_ACCOUNTNAME from '@salesforce/schema/Contact.AccountName__c';
import CONTACT_ACCOUNTID from '@salesforce/schema/Contact.AccountId';
import CONTACT_PHONE from '@salesforce/schema/Contact.Phone';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
import CONTACT_MOBILE from '@salesforce/schema/Contact.MobilePhone';
import OPPORTUNITY_NAME from '@salesforce/schema/Opportunity.Name';
import OPPORTUNITY_OWNER from '@salesforce/schema/Opportunity.Owner.Name';
import OPPORTUNITY_STAGE from '@salesforce/schema/Opportunity.Substage__c';
import OPPORTUNITY_FORECAST from '@salesforce/schema/Opportunity.Deal_Forecast_Revenue__c';
import OPPORTUNITY_CLOSEDATE from '@salesforce/schema/Opportunity.CloseDate';
//import { CloseActionScreenEvent } from 'lightning/actions';
import modal from '@salesforce/resourceUrl/leadconvertcustcss';
export default class leadConversionPage extends NavigationMixin(LightningElement) {
    @api accountId;
    @api contactId;
    @api opportunityId;
    accountRecordType;accountBillingAddress;accountPhone;accountWebsite;accountHealth;
    contactName;contactTitle;contactEmail;contactPhone;contactMobile;contactAccountname;contactEmailTo;
    opportunityName;opportunityOwner;opportunityStage;opportunityForecast;opportunityCloseDate;
    accStreet;accCity;accCountry;accState;accPostalcode;

    connectedCallback() {
        loadStyle(this,modal);
    }   
    //get class name for modal
    get modalClass() {
        return 'slds-modal__content';
    }
    //returns true if Opportunity is created as part of lead conversion
    get isOpportunityCreated(){
       if(this.opportunityId != null && this.opportunityId != '' && this.opportunityId != undefined){
            return true;
        } else{
            return false;
        }
    }
    //get Account record url to display on Page
    get accountURL(){
       return '/lightning/r/' +this.accountId+ '/view';
    }
    //get Contact record url to display on Page
    get contactURL(){
         return '/lightning/r/' +this.contactId+ '/view';
    }
    //get opportunity record url to display on Page
    get opportunityURL(){
        return '/lightning/r/' +this.opportunityId+ '/view';
    }
    //Wire method to fetch the Contact record field values to display on the page
    @wire(getRecord, {recordId: '$contactId', fields: [CONTACT_NAME,CONTACT_TITLE,CONTACT_ACCOUNTNAME,CONTACT_PHONE,CONTACT_EMAIL,CONTACT_MOBILE,CONTACT_ACCOUNTID]})
    fetchContact ({error, data}) { 
        if (data) { 
            this.contactName = getFieldValue(data, CONTACT_NAME);      
            this.contactTitle = getFieldValue(data,CONTACT_TITLE);
            this.contactAccountname = getFieldValue(data, CONTACT_ACCOUNTNAME);
            this.contactAccountID = '/lightning/r/' +getFieldValue(data,CONTACT_ACCOUNTID)+ '/view';
            this.contactEmail = getFieldValue(data,CONTACT_EMAIL);
            this.contactEmailTo = 'mailto:' +this.contactEmail;
            this.contactPhone = getFieldValue(data,CONTACT_PHONE);  
            this.contactMobile = getFieldValue(data,CONTACT_MOBILE); 
        }
    } 
    //Wire method to fetch the Account record field values to display on the page
    @wire(getRecord, {recordId: '$accountId',fields:[ACCOUNT_NAME,ACCOUNT_RECORDTYPE,ACCOUNT_PHONE,ACCOUNT_WEBSITE,ACCOUNT_HEALTH,ACC_BillingCity, ACC_BillingStreet, ACC_BillingState, ACC_BillingPostalCode, ACC_BillingCountry]})//ACCOUNT_BILLINGADDRESS
    fetchAccount({error, data}){
        if (data) {
            this.accountName = getFieldValue(data, ACCOUNT_NAME);
            this.accountRecordType = getFieldValue(data, ACCOUNT_RECORDTYPE);
            this.accountPhone = getFieldValue(data, ACCOUNT_PHONE);
            this.accountWebsite = getFieldValue(data, ACCOUNT_WEBSITE);
            this.accountHealth = getFieldValue(data, ACCOUNT_HEALTH);
            this.accStreet = getFieldValue(data, ACC_BillingStreet);
            this.accCity = getFieldValue(data, ACC_BillingCity);
            this.accCountry = getFieldValue(data, ACC_BillingCountry);
            this.accState = getFieldValue(data, ACC_BillingState);
            this.accPostalcode = getFieldValue(data, ACC_BillingPostalCode);                        
        }
    }
    //Wire method to fetch the Opportunity record field values to display on the page    
    @wire(getRecord, {recordId: '$opportunityId', fields: [OPPORTUNITY_NAME,OPPORTUNITY_OWNER,OPPORTUNITY_STAGE,OPPORTUNITY_FORECAST,OPPORTUNITY_CLOSEDATE]})
    fetchOpty ({error, data}) { 
        if (data) { 
            this.opportunityName = getFieldValue(data, OPPORTUNITY_NAME);      
            this.opportunityOwner = getFieldValue(data,OPPORTUNITY_OWNER);
            this.opportunityStage = getFieldValue(data,OPPORTUNITY_STAGE);
            this.opportunityForecast = getFieldValue(data,OPPORTUNITY_FORECAST);  
            this.opportunityCloseDate = getFieldValue(data,OPPORTUNITY_CLOSEDATE);
        }       
    }  
    //Handles Navigation upon clicking on GoToLeads Button
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

    handleCloseModal(){
        //Created Event
         const closeEvent = new CustomEvent('closemodal', {
            detail: {}});
        //Dispatch Event
        this.dispatchEvent(closeEvent);
        
    }
}