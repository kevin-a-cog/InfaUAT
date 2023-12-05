import { api, LightningElement } from 'lwc';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class CsmPlanCommunicationEditFormModal extends LightningElement {
    @api recordId;
    @api commentRecordId;
    @api strParentCommentId;
    @api isPoppedOut;
    @api isEditForm;
    @api isReplyForm;

    //Signoff  variables
    @api strSignoffContact;
    @api lstSelectedObjectives;
    @api strCommentBody;
	@api alternateId;

    connectedCallback(){
        this.isPoppedOut=false;
        this.setCommentValue();
    }
    @api
    setCommentValue(){
        let objComp= this.template.querySelector('c-csm-plan-communication-edit-form');
        if(objUtilities.isNotNull(objComp) && objUtilities.isNotNull(this.strCommentBody)){          
            objComp.setSignOffParams(this.strCommentBody,this.strSignoffContact,this.lstSelectedObjectives);   
        }
    }
    renderedCallback(){
        this.setCommentValue();
    }
    get modalTitle(){
        let modalHeader = 'Create Comment';
        if(objUtilities.isNotNull(this.isEditForm) && this.isEditForm===true && objUtilities.isNull(this.strCommentBody)){
            modalHeader='Edit Comment';
        } 
        if(objUtilities.isNotNull(this.isReplyForm) && this.isReplyForm===true){
            modalHeader='Reply';
        } 
        return modalHeader;
    }

    handleClose(objEvent){
        this.dispatchEvent(new CustomEvent('close'));
    }
}