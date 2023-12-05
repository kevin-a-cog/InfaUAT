import { LightningElement,api,track } from 'lwc';

export default class EsCaseCreationFilled extends LightningElement {

    @api filledLabel;
    @api filledValue;
    @api filledStep;

    @track additionalCaseInfo;

    connectedCallback(){
        if (this.filledLabel.includes('Additional Case Information')) {
            if(this.filledValue == 0){
                this.filledValue = '0 Files attached';
            }
        }
    }

}