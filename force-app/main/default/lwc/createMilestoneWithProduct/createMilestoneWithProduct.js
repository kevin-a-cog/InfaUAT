import { api, LightningElement } from 'lwc';

export default class CreateMilestoneWithProduct extends LightningElement {
    @api objectiveId;
    @api milestoneId;
    @api index;

    @api
    get objProducts() {
        return this._objProducts;
    }

    set objProducts(value) {
        this._objProducts = value;
    }

    @api
    get selectedObjProducts() {
        return this.selectedMilestoneProducts;
    }

    set selectedObjProducts(value) {
        this.selectedMilestoneProducts = value;
    }

    objProductColumns = [
        { label: 'Product', fieldName: 'Product__c', sortable: true },
        { label: 'Product Forecast', fieldName: 'Forecast_Product__c', sortable: true },
        { label: 'Offering', fieldName: 'Offering_Type__c', sortable: true },
        { label: 'Business Model', fieldName: 'Pricing_Business_Model__c', sortable: true },
        { label: 'Status', fieldName: 'Status__c', sortable: true }
    ];
    _objProducts = [];
    selectedMilestoneProducts = [];
    showSpinner = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    connectedCallback() {
        this.showSpinner = true;
    }

    @api
    getMilestoneData() {
        if (!this.validate()) {
            return false;
        }

        let data = {
            record: {
                'sobjectType': 'Milestone__c'
            },
            productList: this.template.querySelector('[data-name="milestone-product-table"]').getSelectedRows().map(pr => pr.Id)
        };

        if (this.milestoneId) {
            data.record.Id = this.milestoneId;
        } else {
            data.record.sobjectType = 'Milestone__c';
        }

        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            data.record[ip.fieldName] = ip.value;
        });

        return data;
    }

    @api
    resetKeyMilestone() {
        this.template.querySelector('[data-name="keyMilestone"]').value = false;
    }

    validate() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            isValid = ip.reportValidity();
        });
        return isValid;
    }

    handleLoad() {
        this.showSpinner = false;
    }

    handleClick(event) {
        const accordionSection = this.template.querySelector('[data-name="accordionSection"]');
        const accordionIcon = this.template.querySelector('[data-name="accordion-icon"]');
        switch (event.target.dataset.name) {
            case 'accordionHeader':
                accordionSection.classList.toggle('slds-is-open');
                accordionIcon.iconName = accordionSection.classList.value.includes('slds-is-open') ? 'utility:switch' : 'utility:chevronright';
                event.stopPropagation();
                break;

            case 'accordion-icon':
                accordionSection.classList.toggle('slds-is-open');
                accordionIcon.iconName = accordionSection.classList.value.includes('slds-is-open') ? 'utility:switch' : 'utility:chevronright';
                event.stopPropagation();
                break;

            case 'remove':
                this.dispatchEvent(new CustomEvent('remove', { detail: this.index }));
                break;

            default:
                break;
        }
    }

    handleChange(event) {
        switch (event.target.dataset.name) {
            case 'keyMilestone':
                if (event.target.value) {
                    this.dispatchEvent(new CustomEvent('keychange', { detail: this.index }));
                }
                break;
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this._objProducts];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this._objProducts = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


}