import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FlaggedItemsDisplay from '@salesforce/apex/helpNetworkModerationController.FlaggedItemsDisplay';
import UnflagItem from '@salesforce/apex/helpNetworkModerationController.UnflagItem';
import DeleteItem from '@salesforce/apex/helpNetworkModerationController.DeleteItem';
import { refreshApex } from '@salesforce/apex';
import UnflagSelectedItems from '@salesforce/apex/helpNetworkModerationController.UnflagSelectedItems';
import DeleteSelectedItems from '@salesforce/apex/helpNetworkModerationController.DeleteSelectedItems';

const actions = [
    { label: 'Unflag', name: 'Unflag' },
    { label: 'Delete', name: 'Delete' },
];

const columns = [
    { label: 'EntityId', fieldName: 'URL', type: 'url', typeAttributes: { label: { fieldName: 'AuditId' }, target: '_blank' }, hideDefaultActions: true },
    { label: 'Content Creator', fieldName: 'ContentCreator', hideDefaultActions: true },
    { label: 'Entity Type', fieldName: 'EntityType', hideDefaultActions: true },
    { label: 'Content Title', fieldName: 'ContentTitle', hideDefaultActions: true },
    { label: 'Content Body', fieldName: 'ContentBody', hideDefaultActions: true },
    { label: 'Flagged By', fieldName: 'FlaggedBy', hideDefaultActions: true },
    { label: 'Note', fieldName: 'Note', hideDefaultActions: true },
    { label: 'Moderation Type', fieldName: 'ModerationType', hideDefaultActions: true },
    { label: 'Content Status', fieldName: 'ContentStatus', hideDefaultActions: true },
    { label: 'Creation Date', fieldName: 'CreatedDate', hideDefaultActions: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class HelpFlaggedItemsLanding extends LightningElement {

    wiredResults;
    data;
    draftValues;
    columns = columns;
    noRecords = false;
    showSpinner = false;
    showButtons = false;
    selectedRecords = [];




    @wire(FlaggedItemsDisplay)
    imperativeWiring(result) {
        this.wiredResults = result;
        if (result.data) {
            this.data = result.data;
            console.log('DATAAA='+JSON.stringify(this.data))
            if (this.data.length == 0) {
                this.noRecords = true;
            }
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
        if (actionName == 'Unflag') {
            UnflagItem({ entityId: rowId })
                .then((result) => {
                    console.log('Status Res=' + JSON.stringify(result));
                    if (result) {
                        refreshApex(this.wiredResults);
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Content is Unflagged.',
                                variant: 'success',
                            }),
                        );
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

        else if (actionName == 'Delete') {
            DeleteItem({ entityId: rowId })
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



    UnflagOnSelection(){
        this.showSpinner = true;
        UnflagSelectedItems({ wrapList: JSON.stringify(this.selectedRecords) })
                .then((result) => {
                    if (result) {
                        refreshApex(this.wiredResults);
                        this.selectedRecords = [];
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Content Unflagged.',
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


    DeleteOnSelection(){
        this.showSpinner = true;
        DeleteSelectedItems({ wrapList:JSON.stringify(this.selectedRecords)})
                .then((result) => {
                    if (result) {
                        refreshApex(this.wiredResults);
                        this.selectedRecords = [];
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Content Deleted.',
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