/*
* Name : HelpModerationActionComponent
* Author : Deeksha Shetty
* Created Date :  March 30,2022
* Description : This Component displays Moderation Items in landing Page.
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                 Tag
 **************************************************************************************************************************
 Deeksha Shetty       01-Feb-2022     I2RT-5249            Initial version.                                              NA
 Deeksha Shetty       25-Jul-2023     I2RT-8306            Moderator functionality - enhancement                         T1
                                                         
*/

import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ModerationDetailsDisplay from '@salesforce/apex/helpNetworkModerationController.ModerationDetailsDisplay';
import ApproveAction from '@salesforce/apex/helpNetworkModerationController.ApproveAction';
import RejectAction from '@salesforce/apex/helpNetworkModerationController.RejectAction';
import { refreshApex } from '@salesforce/apex';
import ApproveSelectedRecords from '@salesforce/apex/helpNetworkModerationController.ApproveSelectedRecords';
import RejectSelectedRecords from '@salesforce/apex/helpNetworkModerationController.RejectSelectedRecords';


const actions = [
    { label: 'Approve', name: 'Approve' },
    { label: 'Reject', name: 'Reject' },
];

//T1 starts
const columns = [
    // { label: 'EntityId', fieldName: 'AuditId', hideDefaultActions: true },
    { label: 'EntityId', fieldName: 'URL', type: 'url', typeAttributes: { label: { fieldName: 'AuditId' }, target: '_blank' }, hideDefaultActions: true },
    { label: 'Community / User Group Name', fieldName: 'CommunityName', hideDefaultActions: true },
    { label: 'Content Creator', fieldName: 'ContentCreator', hideDefaultActions: true },
    { label: 'Content Title', fieldName: 'ContentTitle', hideDefaultActions: true },
    { label: 'Entity Type', fieldName: 'EntityType', hideDefaultActions: true },
    { label: 'Content Status', fieldName: 'ContentStatus', hideDefaultActions: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
//T1 ends

export default class HelpModerationActionComponent extends LightningElement {

    wiredResults;
    data;
    draftValues;
    columns = columns;
    noRecords = false;
    showSpinner = false;
    showButtons = false;
    selectedRecords = [];


    @wire(ModerationDetailsDisplay)
    imperativeWiring(result) {
        this.wiredResults = result;
        console.log('wiredResults issue>', this.wiredResults)
        if (result.data) {
            this.data = result.data;
            if (this.data.length == 0) {
                this.noRecords = true;
            }
            console.log('Moderation Result=' + JSON.stringify(this.data));
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }

    handleRowAction(event) {
        this.showSpinner = true;
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.AuditId;
        console.log('row val=' + JSON.stringify(rowId))
        if (actionName == 'Approve') {
            ApproveAction({ entityId: rowId })
                .then((result) => {
                    console.log('Status Res=' + JSON.stringify(result));
                    if (result == 'Published') {
                        refreshApex(this.wiredResults);
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Content Approved.',
                                variant: 'success',
                            }),
                        );
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

        else if (actionName == 'Reject') {
            RejectAction({ entityId: rowId })
                .then((result) => {
                    console.log('Status Res=' + JSON.stringify(result));
                    if (result) {
                        refreshApex(this.wiredResults);
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Content Rejected.',
                                variant: 'success',
                            }),
                        );
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }


    handlerowselection() {
        this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords=' + JSON.stringify(this.selectedRecords));
        if (this.selectedRecords.length > 0) {
            this.showButtons = true;
        }
        else {
            this.showButtons = false;
        }
    }


    ApproveOnSelection() {
        this.showSpinner = true;
        ApproveSelectedRecords({ wrapList: JSON.stringify(this.selectedRecords) })
            .then((result) => {
                if (result) {
                    refreshApex(this.wiredResults);
                    this.selectedRecords = [];
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: 'Content Approved.',
                            variant: 'success',
                        }),
                    );
                    this.selectedRecords = [];
                }
            })
            .catch((error) => {
                console.log(error.body);
            });
    }

    RejectOnSelection() {
        this.showSpinner = true;
        RejectSelectedRecords({ wrapList: JSON.stringify(this.selectedRecords) })
            .then((result) => {
                if (result) {
                    refreshApex(this.wiredResults);
                    this.selectedRecords = [];
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: 'Content Rejected.',
                            variant: 'success',
                        }),
                    );
                    this.selectedRecords = [];

                }

            })
            .catch((error) => {
                console.log(error.body);
            });

    }

}