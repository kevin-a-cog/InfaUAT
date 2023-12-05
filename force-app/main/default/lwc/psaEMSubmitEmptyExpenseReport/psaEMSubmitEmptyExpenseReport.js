import { LightningElement,track,wire } from 'lwc';
import getRequiredDates from '@salesforce/apex/psa_em_SubmitExpenseReportController.fetchRequiredDates';
import getSubmitReportResponse from '@salesforce/apex/psa_em_SubmitExpenseReportController.insertExpenseReports';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PsaEMSubmitEmptyExpenseReport extends LightningElement {
    error;
    value = [];
    boolAllSelected = false;
    successMessage;
    isLoaded = false;
    disableSubmitButton = false;
    showSubmitButton = false;
    @track options;
    @track requiredDates;
    @track selectedDates = [];
    @wire(getRequiredDates)
    
    getReqDates(result) {
        if (result.data) {
            this.options = result.data.map(element=>{
                return {
                    'label' : element,
                    'value' : element
                }
            });
            this.options.unshift({
                'label' : 'All',
                'value' : 'All'
            })
            this.requiredDates = result.data;
            this.error = undefined;
            this.isLoaded = false;
            console.log(JSON.stringify(this.options));
        }

        if (result.error) {
            this.requiredDates = undefined;
            this.isLoaded = false;
            this.error = result.error.body.message;
            //this.errors = reduceErrors(error);
            this.showToast(this.error, "error");
        }
    }
    connectedCallback(){
        this.isLoaded = true;
       
    }

    handleChange(e) {
        console.log('inside handle change',e.detail.value,Object.is('All',e.detail.value));
        if(e.detail.value.includes('All')){
            console.log('INSIDE IF');
            this.value = [...this.requiredDates,'All'];
            //console.log(JSON.stringify(this.value));
            this.boolAllSelected = true;
            console.log('INSIDE IF  ',this.boolAllSelected);
            this.showSubmitButton = true;
            return;
        }
        
        this.value = e.detail.value;
        if(!this.value.includes('All') && this.boolAllSelected){
            this.value = [];
            this.boolAllSelected = false;
            this.showSubmitButton = false;
            console.log(JSON.stringify(this.value));
        }
        if(this.value!=null && this.value.length!=0){
         
            this.showSubmitButton=true;
        }else{
            
            this.showSubmitButton=false;
        }
        
    }
    /* checkValueSelected(){
        if(this.value.length === 0){
            this.showToast('Please select a date', 'error');
            return;
        }
        return true;
    } */

    handleSubmitReport(){
       // if(this.checkValueSelected()){  
            this.disableSubmitButton = true;
            this.isLoaded = true;
            this.removeAllFromSelectedValues();
            console.log(JSON.stringify(this.value));
            getSubmitReportResponse({
                datesFromUI : JSON.stringify(this.value)

            })
            .then(result=>{
                console.log('IN THEN BLOCK');
                this.successMessage = result;
                this.showToast(this.successMessage, "success");
                this.requiredDates = null;
                this.disableSubmitButton = false;
                //console.log(JSON.stringify(result));
            })
            .catch(error=>{
                console.log('IN CATCH BLOCK');
                this.error = error.body.message;
                //console.error(JSON.stringify(error));
                this.showToast(this.error, "error");
                this.values=[];
                this.disableSubmitButton = false;
            })
            .finally(()=>{
                this.isLoaded = false;
            })
        //}
    }

    removeAllFromSelectedValues(){
        this.value.forEach((element,index)=>{
            if(element == 'All'){
                this.value.splice(index,1);
            }
        })
    }
    //This is a utility method for displaying toast notification.
    showToast(message, variant) {
        const event = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}