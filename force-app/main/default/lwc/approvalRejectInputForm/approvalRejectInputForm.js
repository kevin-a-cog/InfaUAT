/*

*******************************************************************************************************************
MODIFIED BY     MODIFIED Date   JIRA        DESCRIPTION                                                         TAG
*******************************************************************************************************************
Chaitanya T     04/10/2023     AR-3465      Tech Debt - Mandating closing notes                                 T01
                                            while rejecting CSA/MFA Engagement   
*/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRecord from '@salesforce/apex/ApprovalRequestActioncls.updateRecord';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ApprovalRejectInputForm extends NavigationMixin(LightningElement) {

    @api approveRejectArrayInnerObject;
    @api sobjectname;
    @api processinstanceid;
    @api parentobjectid;
    @api actiontype;
    inputComments;
    formData = {};
    isValid = false;
    isLoading = false;

    connectedCallback() {
        this.approveRejectArrayInnerObject.forEach( (currentItem, index) => {
            if(currentItem.isRequired){
                this.isValid = true; 
            }
        });
    }

    handleSaveClick(){
        this.isLoading = true;
        updateRecord({objectName:this.sobjectname,
            formData:this.formData,
            approveRejectComment:this.inputComments,
            parentRecordId:this.parentobjectid,
            processInstanceId: this.processinstanceid,
            actionType:this.actiontype})
            .then((result) => {
                this.showToast('Success', result, 'success');
                this.isLoading = false;
                this.navigateToRecordPage(this.parentobjectid,this.sobjectname );
            })
            .catch((error)  => {
                if(error.body.message.includes('FIELD_INTEGRITY_EXCEPTION')){//<T01> start
                    let strtIndx = error.body.message.indexOf('FIELD_INTEGRITY_EXCEPTION') + 26;
                    let endIndx = error.body.message.indexOf(':',strtIndx);
                    let errorMsg = error.body.message.substr(strtIndx,endIndx-strtIndx);
                    this.showToast('Error', errorMsg, 'error');//</T01> end
                }else{
                    this.showToast('Error', error.body.message, 'error');
                }
                this.isLoading = false;
            });
    }

    handleChange(event){
        this.isValid = false;
        let keyParam = event.target.getAttribute('data-key');
        if(keyParam == 'comment_approval_fieldname'){
            this.inputComments = event.target.value.trim();
        }else{
            this.formData[keyParam] = event.target.value;
        }

        if(this.sobjectname == 'Lead' && this.inputComments && this.inputComments.length < 10 && this.actiontype == 'Reject'){
            this.isValid = true;
        }

        if(!this.inputComments || !this.formData){
            this.isValid = true;
        }
        
        this.approveRejectArrayInnerObject.forEach( (currentItem, index) => {
            if(currentItem.isRequired){
                let fieldAPI = currentItem.fieldAPIName;
                if(!this.formData.hasOwnProperty(fieldAPI) && fieldAPI != 'comment_approval_fieldname'){
                    this.isValid = true; 
                }
            }
        });

    }
    
    navigateToRecordPage(recordId,ObjectName) {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: recordId,
            objectApiName: ObjectName, 
            actionName: 'view' 
          }
        })
        .then(() => {
            refreshApex(recordId);
        });
        
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}