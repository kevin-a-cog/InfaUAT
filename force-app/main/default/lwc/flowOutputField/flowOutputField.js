import { LightningElement, api } from 'lwc';
export default class FlowOutputField extends LightningElement {
    @api iconName;
    @api fieldName;
    @api fieldValue;
    
    connectedCallback(){
        if(this.iconName === ""){
            this.iconName = null;
        }
    }
}