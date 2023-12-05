import { LightningElement, wire, api } from 'lwc';
import fetchAssignments from '@salesforce/apex/psa_SubconEvalController.fetchAssignments';
import updateAssignments from '@salesforce/apex/psa_SubconEvalController.updateAssignments';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [    
    { label: 'Assignment Name', fieldName: 'Name', editable: false, wrapText: true },   
    { label: 'Assignment End Date', fieldName: 'pse__End_Date__c', type: 'date-local', wrapText: true, editable: false, 
        typeAttributes: {  
                            day: 'numeric',  
                            month: 'numeric',  
                            year: 'numeric'
                        }
    },    
    { label: 'Project', fieldName: 'projectName', editable: false,wrapText : true },
    { label: 'Project Manager', fieldName: 'projectManager', editable: false },
    { label: 'Subcon Evaluation Sent', type: 'boolean', fieldName: 'psa_Subcon_Evaluation_Sent__c', editable: true }
];

export default class SendSubConEvaluationMail extends LightningElement {
    @api recordId;
    records;
    wiredRecords;
    error;
    loaded = false;
    columns = columns;
    draftValues = [];
    hasRecords = false;
    wiredAsgmtRecords;
    subconEvaluationSent = false;

    @wire( fetchAssignments, {recId : '$recordId'} )
    wiredAsgmt(response) {
        const { data, error } = response;     
        this.wiredAsgmtRecords = response; // track the provisioned value 
        
        if (data) {
            if(data.length > 0){
                this.hasRecords = true;   
                let tempRecord = JSON.parse(JSON.stringify(data));
                tempRecord = tempRecord.map(row => {
                    return{...row,projectName:row.pse__Project__r.Name,projectManager:row.pse__Project__r.pse__Project_Manager__r.Name};
                });                      
                this.records = tempRecord;                
                this.draftValues = tempRecord;
                console.log(this.records);
            }     
            else{
                this.hasRecords = false;   
            }
            this.loaded = true;
            this.error = undefined;
        }
        else {

        }
        return refreshApex(this.wiredAsgmtRecords);
    }

    async handleSave( event ) {
        this.loaded = false;
        const updatedFields = event.detail.draftValues; 
        await updateAssignments( { data: updatedFields } )
        .then( result => {
            this.loaded = true;
            console.log( JSON.stringify( "Apex update result: " + result ) );
            if(result == 'SUCCESS'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Evaluation Sent',
                        variant: 'success'
                    })
                );
               
                this.dispatchEvent(new CloseActionScreenEvent());
                return refreshApex(this.wiredRecords);
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while updating record',
                        message: result,
                        variant: 'error'
                    })
                );
            } 
        }).catch( error => {
        });
    }

    handleCancel(event){              
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}