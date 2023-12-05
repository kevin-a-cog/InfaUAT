import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { LightningElement, api } from 'lwc';

export default class CustomLookupWithCreate extends LightningElement {

    @api childObjectApiName = 'Contact'; //Contact is the default value
    @api targetFieldApiName = 'AccountId'; //AccountId is the default value
    @api fieldLabel = 'Your field label here';
    @api disabled = false;
    @api defaultValue;
    @api required = false;

    handleChange(event) {
        // Creates the event
        console.log('event.detail'+JSON.stringify(event.detail));
        console.log('event.detail.value'+ JSON.stringify(event.detail.value));

        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }
}