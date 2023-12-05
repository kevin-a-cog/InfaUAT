import { LightningElement,api,track } from 'lwc';

export default class DatatableOrgUuid extends LightningElement {

    @api value;
    @api context;
    @track showMsg = false;

    handleCopyText(event){
        this.showMsg = true;

        setTimeout(function(){ 
            this.showMsg = false;
        }.bind(this), 700);
                
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", this.value);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
        
    }
    
}