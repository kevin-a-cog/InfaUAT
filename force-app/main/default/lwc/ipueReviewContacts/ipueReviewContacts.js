/*
Component Name:  IpueReviewContacts
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156
*/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEstimationCollaboratorsList from '@salesforce/apex/IPUE_ReviewContactsController.getEstimationCollaborators';
import upsertEstimationCollaborators from '@salesforce/apex/IPUE_ReviewContactsController.upsertEstimationCollaborators';

export default class IpueReviewContacts extends LightningElement {

    @api recordId; //Estimation Summary Id passed from parent
    @api selectedContactIds; //Selected contact Ids passed from parent
    @track selectedRecs = []; //selected contact Ids, used in lightning datatable
    @track selectedContactIdList = []; //temp variable, updated from selectedContactIds
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    showLoading = false;
    sortedBy;
    @track collaborators = []; //All Estimator collaborator records from Apex
    existingCollaborators;
    selectedExistingCollaborators;
    newCollaborators;
    selectedNewCollaborators;

    //Enable Finish only if there are Estimator records
    get disableFinish(){
        if((this.collaborators && this.collaborators.length)){
            return false;
        }else{
            return true;
        }
    }

    get showError(){
        if((this.existingCollaborators || this.newCollaborators) && !this.collaborators.length){
            return true;
        }
        return false;
    }

    get existingCollabsHeight(){
        if(this.existingCollaborators || this.newCollaborators){
            if(!this.newCollaborators.length){
                if(this.existingCollaborators.length > 4){
                    return 'height: 270px;';
                }else{
                    return '';
                }
            }else{
                if(this.existingCollaborators.length > 3){
                    return 'height: 190px;';
                }else{
                    return '';
                }
            }
        }
        return 'height: 190px;';
    }

    get newCollabsHeight(){
        if(this.newCollaborators || this.existingCollabsHeight){
            if(!this.existingCollabsHeight.length){
                if(this.newCollaborators.length > 4){
                    return 'height: 270px;';
                }else{
                    return '';
                }
            }else{
                if(this.newCollaborators.length > 3){
                    return 'height: 190px;';
                }else{
                    return '';
                }
            }
        }
        return 'height: 190px;';
    }

    
    connectedCallback() {
        //Parse the selectedContactIds from parent
        for(let contactId of this.selectedContactIds[0]){
            this.selectedContactIdList.push(contactId);
        }
        this.getEstimationCollaborators();
    }
    
    getEstimationCollaborators(){
        //Fetching estimator/contact records
        getEstimationCollaboratorsList({recordId: this.recordId,selectedContactIds: this.selectedContactIdList}).then(result => {
            let existingCollabs = [];
            let selectedExistingCollabs = [];
            let newCollabs = [];
            let selectedNewCollabs = [];
            for(let collab of result){
                if(collab.estimationCollaboratorId){
                    existingCollabs.push(collab);
                    if(collab.isSelected){
                        selectedExistingCollabs.push(collab.contactId);
                    }
                }else{
                    newCollabs.push(collab);
                    if(collab.isSelected){
                        selectedNewCollabs.push(collab.contactId);
                    }
                }
                this.collaborators.push(collab);
            }

            this.existingCollaborators = existingCollabs;
            this.newCollaborators = newCollabs;
            this.selectedExistingCollaborators = selectedExistingCollabs;
            this.selectedNewCollaborators = selectedNewCollabs;

        }).catch(error =>{
            console.log('Error fetching collaborators data');
            console.log(error);            
        });
    }

    updateCollaborator(event){
        let updatedCollabs = event.detail;
        for(let collab of updatedCollabs){
            let index = this.collaborators.findIndex(contact => contact.contactId === collab.contactId);
            this.collaborators[index] = collab;
        }
    }    
    
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleFinish(){
        this.showLoading = true;
        let lstCollabRecs = JSON.parse(JSON.stringify(this.collaborators));
        //Upsert Estimation Collaborators record
        upsertEstimationCollaborators({recordId: this.recordId,lstCollaboatorData: lstCollabRecs}).then(result => {            
            //On Success, display toast and close the quick action
            const evt = new ShowToastEvent({
                title: 'Estimator Collaborators Updated',
                message: 'Estimator Collaborators were successfully updated',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.handleCancel();
        })
        .catch(error => {
            console.log('Error upserting estimation collaborator records');
            console.log(error);
        });
    }

    handlePrevious(){
        let selectedRows = this.collaborators.filter(contact => contact.isSelected).map(contact => contact.contactId);
        this.dispatchEvent(new CustomEvent('previous',{
            detail : selectedRows
        }));        
    }
}