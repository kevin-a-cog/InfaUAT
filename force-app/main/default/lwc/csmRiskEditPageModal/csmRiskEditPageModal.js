import { api, LightningElement } from 'lwc';

export default class CsmRiskEditPageModal extends LightningElement {
    @api recordId;
    @api riskRecordId;
    @api boolFromPAF;
    @api fromCreateRisk;
      
     /*
    Method Name : handleClose
    Description : This method executes on close
    Parameters	: objEvent onclick event.
    Return Type : None
    */
	handleClose(objEvent){
        this.dispatchEvent(new CustomEvent('close'));
    }
}