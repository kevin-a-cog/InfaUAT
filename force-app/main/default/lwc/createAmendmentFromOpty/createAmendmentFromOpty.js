import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Opportunity.Account.Name';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Opportunity.AccountId';

import PRODUCTS_SWAP_SAME_ENDDATE from '@salesforce/label/c.Products_Swap_Same_End_Dt';
import UPSELL_ONLY_SAME_ENDDATE from '@salesforce/label/c.Upsell_Only_Same_End_Dt';
import ELEVATESTATUSMESSAGE from '@salesforce/label/c.ElevateStatusMessage';
import noContractFoundMessage from '@salesforce/label/c.No_Contract_Found';

import fetchContractsData from '@salesforce/apex/SameEndDateAmendCls.fetchContractsDetails';
import relinkOppWithQuote from '@salesforce/apex/CreateAmendQuote.relinkAmendQuote';
import searchContract from '@salesforce/apex/SameEndDateAmendCls.searchForContract';

import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [NAME_FIELD, ACCOUNT_NAME_FIELD, ACCOUNT_ID_FIELD];
const AMENDMENT_TYPE_OPTIONS = [
        { label: PRODUCTS_SWAP_SAME_ENDDATE, value: PRODUCTS_SWAP_SAME_ENDDATE },
        { label: UPSELL_ONLY_SAME_ENDDATE, value: UPSELL_ONLY_SAME_ENDDATE}
    ];

const columns = [
    { label: 'Contract Number', fieldName: 'contractLink', type : 'url' ,
        typeAttributes: { label: { fieldName: 'ContractNumber' }, target: '_blank' ,
        initialWidth: 90}
    }, 
    { label: 'Start Date', fieldName: 'StartDate', type :'date' ,
    initialWidth: 105},
    { label: 'End Date', fieldName: 'EndDate', type :'date-local' ,
    initialWidth: 100},
    { label: 'Renewal Type', fieldName: 'Renewal_Type__c',
    initialWidth: 80 },
    { label: 'Contract Name', fieldName: 'contractLink', type : 'url' ,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        initialWidth: 108
    },
    { label: 'Annual Recurring Revenue', fieldName: 'Annual_Recurring_Revenue1__c', type : 'currency',
    initialWidth: 110 },
    { label: 'Order No#', fieldName: 'orderLink', type: 'url',
        typeAttributes: { label: { fieldName: 'orderNumber' }, target: '_blank',
        initialWidth: 80 }    
    },
    { label: 'Quote No#', fieldName: 'quoteLink', type: 'url',
        typeAttributes: { label: { fieldName: 'quoteNumber' }, target: '_blank',
        initialWidth: 80 }    
    },
];


export default class CreateAmendmentFromOpty extends NavigationMixin(LightningElement) {
    @api recordId;
    amendTypeOptions = AMENDMENT_TYPE_OPTIONS;
    amendTypeSelected;
    oppAcctId;
    isStep1 = true;
    isStep2 = false;
    readyToSubmit = false;
    data;
    allContractsData;
    searchKey='';
    selectedContractId='';
    showSpinner = false;
    disableSearch = true;
    searchBtnClicked = false;
    disableNextBtn = true;
    noResultMsg = false;
    label = {
        PRODUCTS_SWAP_SAME_ENDDATE,
        UPSELL_ONLY_SAME_ENDDATE,
        ELEVATESTATUSMESSAGE,
        noContractFoundMessage
    };
    columns = columns;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    get oppName(){
        return getFieldValue(this.opportunity.data, NAME_FIELD);
    }

    get oppAccount(){
        return getFieldValue(this.opportunity.data, ACCOUNT_NAME_FIELD);
    }

    get oppAccountId(){
        this.oppAcctId = getFieldValue(this.opportunity.data, ACCOUNT_ID_FIELD);
        return this.oppAcctId;
    }

    handleNext(){
        if(this.amendTypeSelected == undefined || this.amendTypeSelected == '' || this.amendTypeSelected == null){

        }
        else{
            if(this.isStep1 == true){
                this.isStep2 = true;
                this.isStep1 = false;
                this.disableNextBtn = true;
            }
        }
        if(this.isStep2 == true && this.readyToSubmit == false){
            this.oppAcctId = getFieldValue(this.opportunity.data, ACCOUNT_ID_FIELD);
            this.getTableData();
            this.readyToSubmit = true;
            this.searchKey = '';
        }
        else if(this.readyToSubmit == true){
            this.initiateRelinkProcess();
        }
    }
  
    getFormattedData(result){
        result.forEach(function(item){
                item.orderNumber = item.SBQQ__Order__c!=undefined ? item.SBQQ__Order__r.OrderNumber : '';
                item.quoteNumber = item.SBQQ__Quote__c!=undefined ? item.SBQQ__Quote__r.Name: '';
                item.orderLink   = '/'+item.SBQQ__Order__c;
                item.quoteLink   = '/'+item.SBQQ__Quote__c;
                item.contractLink = '/'+item.Id;
            });
        //console.log('after flattening values', result);
        return result;
    }

    handlePrevious(){
        if(this.isStep2 == true){
            this.isStep1 = true;
            this.isStep2 = false;
            this.readyToSubmit = false;
            this.disableNextBtn = false;
        }
    }

    //closes the modal 
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    } 
    handleSelection(event){
        this.amendTypeSelected = event.detail.value;
        this.disableNextBtn = false;
    }

    onRowSelection(event){
        const selectedRows = event.detail.selectedRows;
        this.selectedContractId = selectedRows[0].Id;
        this.disableNextBtn = false;
    }

    hanldeChangeOnSearchBox(event){
        this.searchKey = event.detail.value;
        if(this.searchKey == undefined || this.searchKey == ''){
            this.disableSearch = true;
            if(this.searchBtnClicked == true)
            {
                this.data = this.allContractsData;
                if(this.noResultMsg == true)
                    this.noResultMsg = false;
                this.searchBtnClicked = false;
            }
        }
        else{
            this.disableSearch = false;
        }
    }

    handleSearch(){
            if(this.searchKey == undefined || this.searchKey == ''){
            this.disableSearch = true;
        }
        else{
            this.searchBtnClicked = true;
            this.data = []; //Clear current table rows.
            this.searchContracts(this.searchKey);
        }
    }

    searchContracts(searchString){
        searchContract({oppAcctId : this.oppAccountId, searchStr : searchString})
        .then((result) => {
                if(result == undefined || result.length == 0){
                    this.noResultMsg = true;
                }else{
                    this.noResultMsg = false;
                    this.data = this.getFormattedData(result);
                    console.log('results after search--',this.data);
                }
            }
        )
        .catch((error) => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    getTableData(){
        this.data = [];
        fetchContractsData({oppAcctId : this.oppAcctId})
        .then((result) => {
            if(result == undefined || result.length == 0){
                this.noResultMsg = true;
                this.data = [];
            }else{
                this.noResultMsg = false;
                this.data = this.getFormattedData(result);
                this.allContractsData = this.data;
            }
        })
        .catch((error) => {
            this.showToast('Error', 'There is an error while getting contracts details.', 'error');
        });
    }

    initiateRelinkProcess(){
        this.showSpinner = true;
        relinkOppWithQuote({contractId : this.selectedContractId, newOpportunityId : this.recordId, amendType : this.amendTypeSelected})
        .then((result) => {
            if(result != undefined){
                if(result[0] == 'Success'){
                    setTimeout(() => {
                    this.redirectToQuote(result[1]);
                    this.showSpinner = false;
                  }, 4000);
                }
                else{
                    this.showSpinner = false;
                    this.showToast('Error', result[1], 'error');
                }
            }
        })
        .catch((error) => {
            console.log('error message', error);
            this.showSpinner = false;
            this.showToast('Error', error.body.message, 'error');
        });
    }
    
    redirectToQuote(quoteId){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}