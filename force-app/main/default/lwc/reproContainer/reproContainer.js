import { LightningElement,api } from 'lwc';

export default class ReproContainer extends LightningElement {
    @api recordId;

    isPopout = false;

    handlepopin(event){
       this.isPopout = false;
       this.template.querySelector("c-repro-environments").handlepopin();
    }

    setpop(event){
        console.log('setpop function');
        this.isPopout = true;
    }

    connectedCallback(){
        console.log('recid in container'+this.recordId);
    }
}