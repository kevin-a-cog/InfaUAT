/*
 * Name			    :	CsmDeleteConfirmationModal
 * Author		    :	Deva M
 * Created Date	    :   17/09/2021
 * Description	    :	CsmDeleteConfirmationModal.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		        17/09/2021		N/A				  Initial version.			N/A
 */

 //Core imports
 import { api, LightningElement } from 'lwc';
 import { deleteRecord } from 'lightning/uiRecordApi';

 //Utilities.
import { objUtilities } from 'c/globalUtilities';
//Apex Controllers.

export default class CsmDeleteConfirmationModal extends LightningElement {

    @api recordId;

    showSpinner = false;

    handleClick(event) {
        let objParent = this;
        switch (event.target.dataset.name) {
            case 'cancel':
                this.dispatchEvent(new CustomEvent('close'));
                break;
            case 'delete':
                this.showSpinner = true;
                deleteRecord(this.recordId)
                    .then(() => {                       
                        //Show success toast to user
                        objUtilities.showToast('Success','Record deleted successfully!','success',objParent);
                    })
                    .catch(objError => {
                        objUtilities.processException(objError, objParent);
                    })
                    .finally(() => {
                        this.dispatchEvent(new CustomEvent('close'));
                        this.showSpinner = false;
                    });
                break;
            default:
                break;
        }
    }
}