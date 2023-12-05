import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    getFieldValue,
    getRecord
} from 'lightning/uiRecordApi';
import ACCOUNT_ID from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c';
import submitQuote from '@salesforce/apex/RelinkOpptyController.submitQuoteDetails';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class RelinkOpportunityLwc extends LightningElement {
    @api recordId;
    createRecord = false;
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ACCOUNT_ID],
        optionalFields: []
    })
    currentQuote;

    opportunityId = '';

    get filter() {
        let accId = getFieldValue(this.currentQuote.data, ACCOUNT_ID);
        return accId ? 'isClosed = false AND accountId = ' + '\'' + accId + '\'' + ' ' + 'AND Type != \'Renewal\'' : 'isClosed = false AND Type != \'Renewal\'';
    }
    handleSelection(event) {
        let eventData = event.detail;
        let values = event.detail.selectedId;
        this.opportunityId = values;
    }
    @api
    handleSubmit() {
        if (this.opportunityId == '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Opportunity not selected, Please select to proceed',
                    variant: 'Error',
                }),
            );
        } else {
            var par = {
                eventname: "spinner",
                eventvalue: true
            };
            const valueSelectedEvent = new CustomEvent('valuechangeevent', {
                detail: par
            });
            this.dispatchEvent(valueSelectedEvent);
            submitQuote({
                    quoteId: this.recordId,
                    newOpptyId: this.opportunityId
                })
                .then(result => {
                    let returnvalue = result;
                    var par = {
                        eventname: "spinner",
                        eventvalue: false
                    };
                    const valueSelectedEvent = new CustomEvent('valuechangeevent', {
                        detail: par
                    });
                    this.dispatchEvent(valueSelectedEvent);
                    if (returnvalue === 'true') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Successfully Relinked Opportunity!',
                                variant: 'success',
                            }),
                        );
                        var par = {
                            eventname: "closemodal",
                            eventvalue: false
                        };
                        const valueSelectedEvent = new CustomEvent('valuechangeevent', {
                            detail: par
                        });
                        this.dispatchEvent(valueSelectedEvent);
                        window.location.reload();
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error with Relink :' + returnvalue,
                                variant: 'Error',
                            }),
                        );
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Something went wrong!',
                            variant: 'Error',
                        }),
                    );
                    var par = {
                        eventname: "spinner",
                        eventvalue: false
                    };
                    const valueSelectedEvent = new CustomEvent('valuechangeevent', {
                        detail: par
                    });
                    this.dispatchEvent(valueSelectedEvent);
                });
        }
    }
}