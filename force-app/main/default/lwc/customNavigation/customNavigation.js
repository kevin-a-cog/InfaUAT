import { LightningElement ,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomNavigation extends NavigationMixin(LightningElement) {

     @api recordId;
     @api label;

     navigateToRecordViewPage = () => {
         console.log(`id --> ${this.recordId}`);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            }
        });
    }

     
}