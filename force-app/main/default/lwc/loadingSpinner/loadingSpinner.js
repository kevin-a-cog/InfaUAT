import { LightningElement, api } from 'lwc';

export default class LoadingSpinner extends LightningElement {
    @api showSpinner = false
    @api spinnerMessage = '';
}