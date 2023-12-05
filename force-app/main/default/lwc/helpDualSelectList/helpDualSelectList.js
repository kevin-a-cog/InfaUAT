/*
 * Name         :   HelpDualSelectList
 * Author       :   Utkarsh Jain
 * Created Date :   15-SEPT-2022
 * Description  :   LWC component to select the quick links in Salesforce App.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-SEPT-2022    I2RT-7062           Salesforce application related to quick link              NA
 */

import {api, track, wire, LightningElement } from 'lwc';
import getQuickLinksForRecord from "@salesforce/apex/helpCommunityController.getQuickLinksForRecord";
import updateQuickLinks from "@salesforce/apex/helpCommunityController.updateQuickLinks";
import getQuickLinks from "@salesforce/apex/helpCommunityController.getQuickLinks";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class HelpDualSelectList extends LightningElement {
    
    @api recordId;
    @track options;
    _selected = [];

    @wire(getQuickLinksForRecord, {recordId: '$recordId'})
    GetQuickLinksForRecord(result) {
        if (result.data) {
            this._selected = result.data.Quick_Links__c.split(';');
        }else if(result.error){
            console.error(result.error);
        }
    }

    @wire(getQuickLinks)
    GetQuickLinks(result) {
        if (result.data) {
            this.options = result.data.map(this.mapOptions);
        }else if(result.error){
            console.error(result.error);
        }
    }

    mapOptions(option){
        let op = {
            label: option.Label,
            value: option.Label
        }
        return op;
    }

    handleChange(e) {
        this._selected = e.detail.value;
    }

    get selected() {
        return this._selected.length ? this._selected : [];
    }

    handleClick(){
        if(this._selected.length > 5 || this._selected.length < 4){
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please select minimum 4 items and maximum 5 items.'
            });
            this.dispatchEvent(event);
        }else{
            let quickLinkString = this._selected.join(';');
            updateQuickLinks({ recordId: this.recordId, quickLinks: quickLinkString })
                .then((result) => {
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Quick link updated.'
                    });
                    this.dispatchEvent(event);
                })
                .catch((error) => {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Error Occured.'
                    });
                    this.dispatchEvent(event);
                    console.error(error);
                });
        }

    }
}