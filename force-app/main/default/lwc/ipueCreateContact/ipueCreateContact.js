/*
Component Name:  IpueCreateContact
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156
*/
import { LightningElement,api, wire,track } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import CONTACT_STREET from '@salesforce/schema/Contact.MailingStreet';
import CONTACT_CITY from '@salesforce/schema/Contact.MailingCity';
import CONTACT_STATE from '@salesforce/schema/Contact.MailingState';
import CONTACT_ZIPCODE from '@salesforce/schema/Contact.MailingPostalCode';
import CONTACT_COUNTRY from '@salesforce/schema/Contact.MailingCountry';
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import ACCOUNT_STREET from '@salesforce/schema/Account.BillingStreet';
import ACCOUNT_CITY from '@salesforce/schema/Account.BillingCity';
import ACCOUNT_STATE from '@salesforce/schema/Account.BillingState';
import ACCOUNT_ZIPCODE from '@salesforce/schema/Account.BillingPostalCode';
import ACCOUNT_COUNTRY from '@salesforce/schema/Account.BillingCountry';

export default class IpueCreateContact extends LightningElement {
    @api accountId;
    contactId;
    @track contactStreet;
    @track contactCity;
    @track contactState;
    @track contactZipCode;
    @track contactCountry;
    showSpinner = false;  
    nameField = NAME_FIELD;
    accountfield = ACCOUNT_FIELD;
    emailField = EMAIL_FIELD;
    phoneField = PHONE_FIELD;
    streetField = CONTACT_STREET;
    cityField = CONTACT_CITY;
    stateField = CONTACT_STATE;
    zipcodeField = CONTACT_ZIPCODE;
    countryField = CONTACT_COUNTRY;

    //Fetch Account Address details
    @wire(getRecord,{recordId: '$accountId',fields :[ACCOUNT_STREET,ACCOUNT_CITY,ACCOUNT_STATE,ACCOUNT_ZIPCODE,ACCOUNT_COUNTRY]})
    setAddressFields({error,data}){
        if(data){
            let account = data;
            this.contactStreet = getFieldValue(account,ACCOUNT_STREET);
            this.contactCity = getFieldValue(account,ACCOUNT_CITY);
            this.contactState = getFieldValue(account,ACCOUNT_STATE);
            this.contactZipCode = getFieldValue(account,ACCOUNT_ZIPCODE);
            this.contactCountry = getFieldValue(account,ACCOUNT_COUNTRY);
        }else if(error){
            console.log('Unable to fetch Account details');
        }

    }

    //On successful insertion of contact, display toast and close the modal
    handleSuccess(event){
        this.contactId = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Contact Created',
            message: 'Contact '+event.detail.fields.FirstName.value+' '+event.detail.fields.LastName.value+' was created',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.handleCancel();
    }

    handleError(){
        this.showSpinner = false;
    }

    handleSubmit(){
        this.showSpinner = true;
    }

    handleCancel(){
        this.showSpinner = false;        
        this.dispatchEvent(new CustomEvent('success',{
            detail : this.contactId
        }));
    }    
}