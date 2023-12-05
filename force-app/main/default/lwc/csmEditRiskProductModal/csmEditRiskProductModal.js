import { api, LightningElement } from 'lwc';

export default class CsmEditRiskProductModal extends LightningElement {
    @api recordId;
    @api riskProductId;
    @api fromCreateRiskProduct;
    connectedCallback(){
    }
    handleClose(){
        this.dispatchEvent(new CustomEvent('close'));
     }
}