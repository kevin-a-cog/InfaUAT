import lookUp from '@salesforce/apex/CustomLookupLwcController.search';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';


export default class customLookUp extends LightningElement {

    @api objName = '';
    @api iconName = '';
    @api filter = '';
    @api filterVariable = '';
    @api searchPlaceholder='Search';

    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';


    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter', filterVariable :'$filterVariable'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }


    handleClick() {
        
    console.log('searchTerm -->'+this.searchTerm);
    console.log('objName -->'+this.objName);
    console.log('filter -->'+this.filter);
    console.log('filterVariable -->'+this.filterVariable);

        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;

        const valueRemovalEvent = new CustomEvent('lookupremoved', { detail: false });
        this.dispatchEvent(valueRemovalEvent);

    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

}