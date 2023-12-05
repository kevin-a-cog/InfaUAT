import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class CustomRelatedorderproducts extends LightningElement {
    @api recordId;
    @track label = 'View';

    @wire(CurrentPageReference) pageRef;

    @track showPopupwindow = false;

    handleFulfillmentSelection(objEvent) {
        this.showPopupwindow = false;
        console.log(`custom related order products --> ${this.recordId}`);
        let selectedRow = this.recordId;
        //console.log(`selectedRow --> ${JSON.stringify(selectedRow)}`);
        //let rerender = true;
            //fireEvent(this.pageRef, 'fulfillmentChange', selectedRow);
        //fireEvent(this.pageRef, 'OrdProductsRerender', rerender);
        const {objCoordinates } = objEvent.detail;
        this.showPopupwindow = true;
        //this.template.querySelector(".compactLayout").style = "top: " + (objCoordinates.y + 30) + "px; left: " + objCoordinates.x + "px; position: fixed; z-index: 9999999;";
    }
    closePopup(event){
        this.showPopupwindow = false;
    }
}