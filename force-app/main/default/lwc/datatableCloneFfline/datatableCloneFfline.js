import { LightningElement,api } from 'lwc';

export default class DatatableCloneFfline extends LightningElement {
@api context;
@api cssclass;

addRow(event){
    this.dispatchEvent(new CustomEvent('cloneffline', 
        {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                 context: this.context
            }
        }));
        console.log('Event dispatched ' + this.context);
}

}