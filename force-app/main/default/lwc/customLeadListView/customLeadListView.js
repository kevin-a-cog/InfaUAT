import { LightningElement, wire } from 'lwc';
import getLeads from '@salesforce/apex/CustomListViewController.getLeads';

export default class CustomLeadListView extends LightningElement {

    employeeColumns = [
        { label: 'Deal Registration', fieldName: 'dealRegURL', type: "url", typeAttributes: { label: { fieldName: 'Deal_Registration_Number__c' } } },
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Account', fieldName: 'accountURL', type: "url", typeAttributes: { label: { fieldName: 'accountName' } } },
        { label: 'Reseller/SI Partner', fieldName: 'resellerURL', type: "url", typeAttributes: { label: { fieldName: 'resellerName' } } },
        { label: 'Field Sales Rep', fieldName: 'fieldSalesURL', type: "url", typeAttributes: { label: { fieldName: 'fieldSalesRep' } } },
        { label: 'PSM', fieldName: 'psmURL', type: "url", typeAttributes: { label: { fieldName: 'psmName' } } },
        { label: 'Opportunity', fieldName: 'opportunityId', type: "url", typeAttributes: { label: { fieldName: 'opportunityName' } } },
        {
            label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date',
            typeAttributes: {
                day: 'numeric', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
            }
        }
    ];

    key = '';
    employeeData;
    showTable = false;
    error = '';

    async connectedCallback() {
        const resp = await this.getData();
    }

    async getData() {

        const data = await getLeads({
            key: this.key
        })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.error = JSON.stringify(error);
                this.showTable = false;
            });

        if (data) {
            let isSite = window.location.origin.indexOf('my.site.com') > -1;
            let dataCopy = JSON.parse(JSON.stringify(data));
            dataCopy.forEach(dt => {
                dt.dealRegURL = isSite === true ? '/s/dealregistration?c__recordId=' + dt.Id : '/lightning/n/DealRegistration?c__recordId=' + dt.Id;
                dt.accountName = dt.Account__c ? dt.Account__r.Name : '';
                dt.accountURL = dt.Account__c ? '/lightning/r/' + dt.Account__c + '/view' : '';
                dt.resellerName = dt.Reseller_SI_Partner__c ? dt.Reseller_SI_Partner__r.Name : '';
                dt.resellerURL = dt.Reseller_SI_Partner__c ? '/lightning/r/' + dt.Reseller_SI_Partner__c + '/view' : '';
                dt.fieldSalesRep = dt.Field_Sales_Rep__c ? dt.Field_Sales_Rep__r.Name : '';
                dt.fieldSalesURL = dt.Field_Sales_Rep__c ? '/lightning/r/' + dt.Field_Sales_Rep__c + '/view' : '';
                dt.psmName = dt.PSM__c ? dt.PSM__r.Name : '';
                dt.psmURL = dt.PSM__c ? '/lightning/r/' + dt.PSM__c + '/view' : '';
                dt.opportunityName = dt.Opportunity__c ? dt.Opportunity__r.Name : '';
                dt.opportunityId = dt.Opportunity__c ? '/lightning/r/' + dt.Opportunity__c + '/view' : '';
            });

            this.employeeData = dataCopy;
            this.showTable = true;
            this.error = '';
        }
    }

    async handleKeySearch() {
        const resp = await this.getData();
    }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        if (searchKey) {
            this.key = searchKey;
        } else {
            this.key = '';
        }
    }
}