import { LightningElement, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    selectedValue;

    handleChange(event) {
        //show the selected value on UI
        this.selectedValue = event.detail.value;

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                 context: this.context, value: this.selectedValue
            }
        }));
    }
}