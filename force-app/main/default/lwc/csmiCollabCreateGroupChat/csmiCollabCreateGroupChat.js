import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CsmiCollabCreateGroupChat extends LightningElement {
    record_Id;
    objectApiName;
    hideButtons = true;
    connectedCallback(event){
        var currentURL = window.location.href;
        var objElement = currentURL.substring(currentURL.indexOf('/r/') + 1).split('/');
        this.objectApiName = objElement[1];
        this.record_Id = objElement[2];
        this.hideButtons = true;
    }

    handleCloseAction(event){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}