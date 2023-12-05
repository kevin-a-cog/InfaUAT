import { LightningElement, api, track } from 'lwc';

export default class SpModalComponent extends LightningElement {
    @api showModal;
    @api modalHeader;
    @api modalBody;
    @track isModalOpen = false;
    openModal() {
        this.isModalOpen = true;
    }
    constructor() {
        super();
        this.showModal = false;
      }
    handleClose() {
        console.log('Close child')
        this.dispatchEvent(new CustomEvent('close'));
    }
}