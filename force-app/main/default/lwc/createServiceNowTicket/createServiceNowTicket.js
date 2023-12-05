import { LightningElement, track, api } from 'lwc';
import serviceNowEmailMethod from '@salesforce/apex/psa_MassEditExpensesController.serviceNowEmailMethod';
import defaultServiceNowEmail from '@salesforce/label/c.ServiceNow_Email';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateServiceNowTicket extends LightningElement {
    
    @api recordId;
    @track validated = false; //To validate the email
    snowEmail = defaultServiceNowEmail;
    snowNotes = '';

    //function to validate the Email and enable the Send Email button
    handleEmailInputChange(event){

        this.snowEmail = event.target.value;

        const emailRegex=/[A-Za-z0-9._-]+@[a-z0-9-]+\.[a-z]{2,}$/;
        if(this.snowEmail.match(emailRegex) != null){
            this.validated = false;
        }
        else{
            this.validated = true;
        }
    }

    //function to store the Notes input into the snowNotes property
    handleNotesInputChange(event){
        this.snowNotes = event.target.value;
    }

    //function to handle the close action on Cancel button
    closeAction(event){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //function to handle the action on Send Email button
    saveAction(event){

        //calling the imported apex method, passing the record 
        serviceNowEmailMethod({recordId: this.recordId, email: this.snowEmail, notes: this.snowNotes}).then(result =>{
            //Email has been sent
            if(result === 'TRUE') {
                
                this.dispatchEvent(new CloseActionScreenEvent());
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Mail Sent Successfully!',
                        variant: 'success'
                    })
                );
                
            }
            //An error was thrown when the mail was being sent
            else if(result === 'FALSE'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while updating record',
                        message: 'Uh-oh! An error occurred - Please reach out to your administrator.',
                        variant: 'error'
                    })
                );
            }
            //The mail was already sent, result was returned as 'MAIL_SENT'
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Mail Already Sent',
                        message: 'A mail has already been sent for this Expense Report.'
                    })
                );
            }
        });
        
    }
}