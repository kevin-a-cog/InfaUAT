import { LightningElement, api} from 'lwc';
import IPU_Check_Uncheck_Message from '@salesforce/label/c.IPU_Check_Uncheck_Message';
export default class ipueConfirmDialog extends LightningElement {

    @api frameIndexVal;
    @api sectionIndexVal;

    label = {
        IPU_Check_Uncheck_Message
    };

    onCancelClick() {
        let inputAttributes = {frameIndex:this.frameIndexVal, sectionIndex:this.sectionIndexVal};
        const closeEvent = new CustomEvent('closedialogmodal', {
            detail: inputAttributes
        });
        this.dispatchEvent(closeEvent);
    }

    onProceedClick() {
        let inputAttributes = {frameIndex:this.frameIndexVal, sectionIndex:this.sectionIndexVal};
        const proceedEvent = new CustomEvent('proceed', {
            detail: inputAttributes
        });
        this.dispatchEvent(proceedEvent);
    }

}