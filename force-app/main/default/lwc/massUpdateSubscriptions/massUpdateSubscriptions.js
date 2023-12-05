import { api, LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/MassUpdateSubscriptionController.searchAccounts';
import updateSubscription from '@salesforce/apex/MassUpdateSubscriptionController.updateSubscription';
import getDetails from '@salesforce/apex/MassUpdateSubscriptionController.getDetails';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';


export default class MassUpdateSubscriptions extends NavigationMixin(LightningElement){
    @track isLoading = true;
    @api recordId = '';
    @track accounts = [];
    @track searchTerm = '';
    accountId = '';
    //toast
    @track visible = false;
    @track type;
    @track message;
    @api autoCloseTime = 5000;

    @track contract = '';
    @track account = '';

    @track defaultAccounts;
    columns = [
        {label: 'Account Name', fieldName: 'accountName', type: 'text'},
        {label: 'Account Number', fieldName: 'accountNumber', type: 'text'},
        {label: 'Account State/ Province', fieldName: 'stateProvince', type: 'text'},
        {label: 'Account Country', fieldName: 'country', type: 'text'},
        {label: 'Phone', fieldName: 'phone', type: 'phone'},
        {label: 'Account Record Type', fieldName: 'recordTypeName', type: 'text'},
        {label: 'DUNS Number', fieldName: 'dunsNumber', type: 'text'},
        {label: 'Global Ultimate Number', fieldName: 'ultimateNumber', type: 'text'},
        {label: 'Account Owner Alias', fieldName: 'ownerAlias', type: 'text'},
    ];

    accountsearch(event){
        if(event && event.currentTarget && event.currentTarget.value !== this.searchTerm){
                this.isLoading = true;
                var val = event.currentTarget.value;
                this.searchTerm = val;
        }
        else if(event.currentTarget.value === this.searchTerm){
            this.isLoading = false;
        }
    }

    @wire(getAccounts,{searchTerm : '$searchTerm'})
    wiredAccounts({error,data}){
        if(data){
            this.accounts = data;
            this.isLoading = false;
        }
        else if(error){
            console.log('@@error'+JSON.stringify(error));
            this.isLoading = false;
        }
    }

    cancelclick(event){
        this.redirectToContract();
    }

    redirectToContract(){
        var url = window.location.origin + "/" + this.recordId;
        console.log('@@url'+url);
        window.open(url,"_self");
    }

    connectedCallback() {
        this.isLoading = true;
        getDetails({recordId : this.recordId})
        .then(result => {
            this.contract = result.contractName;
            this.account = result.accountName;
            this.isLoading = false;
        })
        .catch(error => {
            console.log('@@error'+JSON.stringify(error));
            this.showToast('error','Error:'+JSON.stringify(error));
            this.isLoading = false;
        });
    }

    handleRowSelection = event => {
        var selectedRows=event.detail.selectedRows;
        if(selectedRows.length>1)
        {
            this.showNotification();
            var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(el.selectedRows.length-1);
            event.preventDefault();
            //return;

            if(selectedRows.length === 1){
                this.accountId = selectedRows[0];
                console.log('@@'+this.accountId);
            }

        }
        else if(selectedRows.length === 1){
            this.accountId = selectedRows[0].Id;
            console.log('@@'+this.accountId);
        }
    }

  updateSubscription  (){
        this.isLoading = true;
        updateSubscription({contractId : this.recordId, accountId : this.accountId})
        .then(result => {
            if(result === 'true'){
                this.showToast('success','Account Updated Successfully!');
                var url = window.location.origin + "/" + this.recordId;
                console.log('@@url'+url);
                window.open(url,"_self");
            }
            else{
                this.showToast('error','Error:'+result);
            }
            this.isLoading = false;
        })
        .catch(error => {
            console.log('@@error'+JSON.stringify(error));
            this.showToast('error','Error:'+JSON.stringify(error));
            this.isLoading = false;
        });
    }

    showNotification() {
        this.showToast('warning','Only one row can be selected'); //info
    }

    /*showT(){
        this.visible = true;
        let delay = 1000
        setTimeout(() => {
            this.visible = false;
        }, delay );
    }*/

    @api
    showToast(type, message) {
        this.type = type;
        this.message = message;
        this.visible = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }
 
    closeModel() {
        this.visible = false;
        this.type = '';
        this.message = '';
    }
 
    get getIconName() {
        return 'utility:' + this.type;
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

}