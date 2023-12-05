import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getApprovalHistory from '@salesforce/apex/CustomListViewController.getApprovalHistory';

export default class DealRegistrationPage extends NavigationMixin(LightningElement) {

    @track currentPageReference;
    callonetime = true;
    processHistory;
    activeSections = ['Detail', 'Partner', 'Customer', 'System'];

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    get recordId() {
        if (this.callonetime) {
            this.callonetime = false;
            this.getData();
        }
        return this.currentPageReference?.state?.c__recordId;
    }

    async getData() {

        const data = await getApprovalHistory({
            recordId: this.recordId
        })
            .catch(error => {
                console.error(JSON.stringify(error));
            });

        if (data) {
            this.processHistory = data;
        }
    }

    openUserUrl(event) {

        let id = event.currentTarget.dataset.value;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "User",
                actionName: "view",
                recordId: id
            }
        });
    }

}