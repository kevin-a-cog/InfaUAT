import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_FIELD from '@salesforce/schema/User_Provisioning_Request__c.User__c';
import BLANKKET_APPROVER_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Blanket_Approver1__c';
import INCIDENT_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Incident__c';
import JUSTIFICATION_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Business_Justification__c';
import BUSINESS_ROLE_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Business_Role__c';
import ADD_ONS_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Dev_Add_Ons__c';
import END_DATE_FIELD from '@salesforce/schema/User_Provisioning_Request__c.End_Date__c';
import START_DATE_FIELD from '@salesforce/schema/User_Provisioning_Request__c.Start_Date__c';
import CREATE_ADD_ONS from '@salesforce/apex/UserProvisioningHandler.createAddOnRequests';
import CHECK_EXISTING_PR from '@salesforce/apex/UserProvisioningHandler.checkExistingPermissionRequests';

export default class CreateUserProvisioningRequest extends NavigationMixin(LightningElement) {
    
    objectApiName = 'User_Provisioning_Request__c';
    showModal = false;
    existingPermissionRequests;
    submitevent;

    fields = [USER_FIELD, BLANKKET_APPROVER_FIELD, INCIDENT_FIELD,JUSTIFICATION_FIELD,START_DATE_FIELD,END_DATE_FIELD,BUSINESS_ROLE_FIELD,ADD_ONS_FIELD];

    handleSubmit(event){

        event.preventDefault();

        CHECK_EXISTING_PR({userId: event.detail.fields.User__c , lstPermission: event.detail.fields.Dev_Add_Ons__c , businessRole: event.detail.fields.Business_Role__c})
        .then((result) => {
            if(result && result.length > 0){
                this.showModal = true;
                this.submitevent = event;
                this.existingPermissionRequests = JSON.parse(JSON.stringify(result));
            }else{
                this.template.querySelector('lightning-record-form').submit(event.detail.fields);
            }

        }).catch((error) => {
            alert('ERROR OCCURED ON HANDLESUBMIT');
        });
    }

    closeModal(){
        this.submitevent = null;
        this.showModal = false;
    }

    handleProceed(){
        this.template.querySelector('lightning-record-form').submit(this.submitevent.detail.fields);
    }
    
    handleSuccess(event) {        
        CREATE_ADD_ONS({ recId: event.detail.id })
        .then((result) => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.id,
                    objectApiName: 'User_Provisioning_Request__c',
                    actionName: 'view'
                },
            }); 
        })
        .catch((error) => {
            alert('ERROR OCCURED ON HANDLESUCCESS');
        });       
    }   
}