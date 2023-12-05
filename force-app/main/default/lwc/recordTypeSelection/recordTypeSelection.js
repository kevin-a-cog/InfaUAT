import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
export default class RecordTypeSelection extends NavigationMixin(LightningElement) {
    @track selectedOption;
    @api options;

    
    handleNext() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                recordTypeId: this.selectedOption

            }
        });
    }
    handleChange(event) {
        Array.from(this.template.querySelectorAll('lightning-input'))
            .forEach(element => {
                element.checked = false;
            });
        const checkbox = this.template.querySelector('lightning-input[data-value="' + event.target.dataset.value + '"]');
        checkbox.checked = true;
        this.selectedOption = event.target.dataset.value;
        const selectedEvent = new CustomEvent("select", {
            detail: this.selectedOption
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}