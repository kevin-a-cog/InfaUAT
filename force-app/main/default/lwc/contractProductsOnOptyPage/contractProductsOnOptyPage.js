import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSubscriptionRecs from '@salesforce/apex/contractProductsOnOptyPageController.getSubscriptionRecs'
//Fields to be displayed on the table
const subFields = [
    { label: 'Product Name', fieldName: 'SBQQ__ProductName__c', type: 'text', sortable: false, wrapText: true, initialWidth: 700 },
    { label: 'Multiple', fieldName: 'multiple__c', type: 'text', sortable: false, initialWidth: 100},
    { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: 'number', sortable: false, initialWidth: 100},
    { label: 'Start Date', fieldName: 'SBQQ__StartDate__c', type: 'date-local', sortable: false },
    { label: 'End Date', fieldName: 'SBQQ__EndDate__c', type: 'date-local', sortable: false }
];

export default class ContractProductsOnOptyPage extends NavigationMixin(LightningElement) {
    @api optyId; @api optyName;
    columns = subFields;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    error;
    subscriptionRecs;
    connectedCallback() {
        this.loadSubscriptionRecs();
    }

    //Close the Modal, dispatch event to parent
    closeModal(event) {
        const closeEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(closeEvent);
    }

    //To navigate to the Opportunity List View
    goToOpportunitiesLst(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    //To navigate to the Opportunity record Page
    goToOpportunity(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.optyId,
                objectApiName: 'Opportunity', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    //Initial Subscription Record Load
    loadSubscriptionRecs() {
        getSubscriptionRecs({ oppId: this.optyId }).then(result => {
            result = result.filter(Obj => Obj.SBQQ__Number__c != 0);
            result = result.filter(Obj => Obj.SBQQ__Quantity__c != 0);
            result.forEach( Obj =>{
                var num = Obj.SBQQ__Number__c;
                Obj.SBQQ__Number1__c = Math.trunc(num);
                var str = String((num - Math.trunc(num)).toFixed(2)).split('.')[1];
                str = str.slice(-1) === '0'
                    ? str.slice(0, -1)
                    : str;
                Obj.SBQQ__Number2__c = Number(str);
            });
            result = result.sort((a, b) => (a.SBQQ__ContractNumber__c > b.SBQQ__ContractNumber__c) ? 1 :
                (a.SBQQ__ContractNumber__c === b.SBQQ__ContractNumber__c) ? ((a.SBQQ__Number1__c > b.SBQQ__Number1__c) ? 1 :
                    (a.SBQQ__Number1__c === b.SBQQ__Number1__c) ? ((a.SBQQ__Number2__c > b.SBQQ__Number2__c) ? 1 : -1) : -1) : -1);
            this.checkDuplicateInObject(result);
            console.log('##SubRecs: ' + JSON.stringify(this.subscriptionRecs));
        }).catch(error => {
            this.error = 'Error in fetching the Subscription records'
        });
    }

    //To find the Duplicates in the list
    checkDuplicateInObject(result) {
        var data = result;
        var parentProducts = new Array();
        data.forEach(element => {
            if (!element.hasOwnProperty('SBQQ__RequiredById__c')) {
                parentProducts.push(element.SBQQ__Product__c);
            }
        });

        var duplicates = parentProducts.reduce(function (acc, el, i, arr) {
            if (arr.indexOf(el) !== i && acc.indexOf(el) < 0) acc.push(el); return acc;
        }, []);

        data.forEach(element => {
            if (duplicates.includes(element.SBQQ__Product__c) && !element.hasOwnProperty('SBQQ__RequiredById__c')) {
                element.multiple__c = 'Multiple';
            }
            else {
                element.multiple__c = '';
            }
        });
        this.subscriptionRecs = data;
    }
}