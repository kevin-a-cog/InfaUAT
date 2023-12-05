import { LightningElement, track, wire, api } from 'lwc';
import fetchExpenses from '@salesforce/apex/psa_MassEditExpensesController.fetchExpenses';
import fetchExpenseReport from '@salesforce/apex/psa_MassEditExpensesController.fetchExpenseReport';
import updateExpenses from '@salesforce/apex/psa_MassEditExpensesController.updateExpenses';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [     
    { label: 'Audited', fieldName: 'PSA_EM_Audited__c', type: 'boolean', editable: true,  initialWidth: 70 },
    { label: 'Expense Date', fieldName: 'pse__Expense_Date__c', type: 'date-local',wrapText : true, editable: false,initialWidth: 100, 
        typeAttributes: {  
                        day: 'numeric',  
                        month: 'numeric',  
                        year: 'numeric'
                        }
    },    
    { label: 'Type', fieldName: 'pse__Type__c', editable: false, wrapText : true },
    { label: 'Billable', fieldName: 'pse__Billable__c', type: 'boolean', editable: false, initialWidth: 70},    
    { label: 'Amount', fieldName: 'pse__Amount__c',type: 'text', editable: false,wrapText : true,initialWidth: 70},    
    { label: 'Amount To Reimburse', fieldName: 'pse__Amount_To_Reimburse__c', editable: false, wrapText : true,initialWidth: 180 },    
    { label: 'Expense Number', fieldName: 'Name', editable: false,wrapText : true,initialWidth: 160 },                                                                   
];
export default class MassEditExpenses extends LightningElement {
    @api recordId;
    records;
    wiredRecords;
    error;
    loaded = false;
    columns = columns;
    draftValues = [];
    hasRecords;
    auditNotes = '';
    currencyCodeVal = '';
    sscReviewedDate;
    tempSSCDate;
    wiredERrecords;
    
    handleFormInputChange(event){
        if( event.target.name == 'AuditNotes' ){
            this.auditNotes = event.target.value;
        }
    }
    handleDateInputChange(event){
        this.sscReviewedDate = event.target.value;
    }
    @wire( fetchExpenseReport, {recId : '$recordId'})  
    wiredER(response) {
        const { data, error } = response;     
        this.wiredERrecords = response; // track the provisioned value 
        
        if (data) {
            this.sscReviewedDate = data["psa_SSC_Reviewed_Date__c"];
            this.auditNotes = data["pse__Audit_Notes__c"];
          }
        else {}
        return refreshApex(this.wiredERrecords);
    }
            
    @wire( fetchExpenses, {recId : '$recordId'})  
    wiredAccount(response) {
        const { data, error } = response;     
        this.wiredRecords = response; // track the provisioned value 
        
        if (data) {  
            if(data.length > 0){
                this.hasRecords = true;   
                let tempRecord = JSON.parse(JSON.stringify(data));
                tempRecord.forEach(function (record) {
                    if (typeof record.Id != 'undefined') {
                        if (record.pse__Amount__c) {
                            console.log(record.pse__Amount__c +' '+ record.CurrencyIsoCode);
                            record.pse__Amount__c = record.pse__Amount__c +' '+ record.CurrencyIsoCode;
                        } 
                    }
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
        else if(error) {
            console.log(JSON.stringify(error));
            this.error = error;
            this.records = undefined;
        }
    }  

    async handleSave( event ) {
        this.loaded = false;
        const updatedFields = event.detail.draftValues;
        updatedFields.forEach(function (record) {
            if (typeof record.Id != 'undefined') {
                if (record.pse__Amount__c) {
                    record.pse__Amount__c = record.pse__Amount__c.substring(0, record.pse__Amount__c.length - 4);
                } 
            }
        }); 
        await updateExpenses( { data: updatedFields, auditNotes: this.auditNotes, sscReviewedDate : this.sscReviewedDate, recordId : this.recordId} )
        .then( result => {
            this.loaded = true;
            console.log( JSON.stringify( "Apex update result: " + result ) );
            if(result == 'SUCCESS'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Expense(s) updated',
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
    }
}