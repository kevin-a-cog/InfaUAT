import { LightningElement, api } from 'lwc';

export default class IpueNotes extends LightningElement {

    @api recordId;

    onCloseClick() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    handleSuccess(event){

        const notes = event.detail.fields.Notes__c;
        console.log('Handle success, notes: ', JSON.stringify(notes));
        const closeEvent = new CustomEvent('savemodal', {detail:{notes}});
        this.dispatchEvent(closeEvent);

    }

}