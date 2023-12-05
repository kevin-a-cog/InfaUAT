import lookUp from '@salesforce/apex/ManagePlanProductsController.search';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PLAN_OBJECT from '@salesforce/schema/Plan__c';
import { api, LightningElement, track, wire } from 'lwc';


export default class customLookUp extends LightningElement {

    @api objName = '';
    @api iconName = '';
    @api filter = '';
    @api searchPlaceholder='Search';

    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    //start----> (VDIVAKARAN)

    @track themeInfo;
    @track planIcon;
    planColor = 'f36e83';

    @wire(getObjectInfo, { objectApiName: PLAN_OBJECT })
    handleResult({error, data}) {
        if (data) {
            
            console.log('object UI --> ' + JSON.stringify(data));

            
            let objectInformation = data;

            // access theme info here
            // icon URL is availe as themeInfo.iconUrl
            this.themeInfo = objectInformation.themeInfo
            console.log('theme --> ' + this.themeInfo);

            this.planIcon = objectInformation.themeInfo.iconUrl;
            console.log('planicon --> ' + this.planIcon);
            
        }
        if(error) {
            // handle error
        }
    }

    //end------> (VDIVAKARAN)

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
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