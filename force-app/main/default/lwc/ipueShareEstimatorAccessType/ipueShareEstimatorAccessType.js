/*
Component Name:  IpueShareEstimatorAccessType
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156
*/
import { LightningElement, api } from 'lwc';

export default class IpueShareEstimatorAccessType extends LightningElement {

    @api recordId;
    @api value; //picklist value
    @api disabled; //to enable/disable picklist

    accessTypes = [
        { label: 'Read', value: 'Read' },
        { label: 'Read/Write', value: 'Edit' }
    ]

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { recordId: this.recordId, value: this.value }
            }
        }));
    }
}