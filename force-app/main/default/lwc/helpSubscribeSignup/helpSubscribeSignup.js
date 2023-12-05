import { LightningElement } from 'lwc';
import IN_account_register from '@salesforce/label/c.IN_account_register';
import IN_SubscribeNL from '@salesforce/label/c.IN_SubscribeNL';

export default class HelpSubscribeSignup extends LightningElement {
    signup = IN_account_register;
    subscribe = IN_SubscribeNL;

    handleOnClick(event){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick(event.currentTarget.dataset.name);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(event.currentTarget.dataset.value, "_self");
    }
}