import { LightningElement,api, wire, track } from 'lwc';
import getPreviousEngagements from '@salesforce/apex/EngagementCatalogueController.getPreviousEngagements';
import getFieldLabelAndFieldAPI from '@salesforce/apex/EngagementCatalogueController.getFieldLabelAndFieldAPI';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'; 

import EC_NoEngagementsMsg from '@salesforce/label/c.EC_NoEngagementsMsg';

export default class EngagementItemDataTable extends LightningElement {
    checkFieldSet= false;
    displayNoEngagements = false;
    @track 
    columns =[];
    @track 
    visibleRecords = [];
    dataIsPresent = false;
    @api accountId='';
    @api engagementRecordType='CST';
    currentPage = 1;
    totalRecords;
    @api recordSize = 10;
    totalPage = 0;
    boolRenderPaginator = false;
    label = {EC_NoEngagementsMsg};
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

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
        const cloneData = [...this.totalRecords];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.totalRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.updateRecords();
    }

    connectedCallback(){
        this.handleOnLoad();
    }

    @wire(getPreviousEngagements,{accId:'$accountId',engagementType:'$engagementRecordType'})
    accountData({data, error}){
        if(data){
            let recList=[];
            data.forEach((rec)=>{
                let obj=Object.assign({},rec);
                let stat = '';
                if(obj.Status__c=='Completed' || obj.Status__c=='Close without Engagement'){
                    stat='Closed';
                }
                else if(obj.Status__c=='Accepted' || obj.Status__c=='Submitted for Approval' || obj.Status__c=='In Progress' || obj.Status__c=='OnHold'){
                    stat='In Progress';
                }
                obj.CustomStatus=stat;
                recList.push(obj);
            });
            this.totalRecords = recList;
            this.boolRenderPaginator = true;
            this.dataIsPresent = true;
			this.totalPage = Math.ceil(data.length/this.recordSize);
            this.updateRecords();
            if(Object.keys(recList).length){
                this.checkFieldSet = true;
            }else{
                this.displayNoEngagements = true;
            }
        }
        else if(error){
            console.log('error from datatable', error);
            this.showError(error);
        }
    }

    handleOnLoad(){
        getFieldLabelAndFieldAPI()
        .then((data) =>{
            let col=[];
        let fieldSet = JSON.parse(data);
        
        fieldSet.forEach((element)=>{
            let datatype='String';
            if(element.type=='datetime'){
                datatype='date-local';
            }
            let fName=element.fieldPath;
            if(fName=='Status__c'){
                fName='CustomStatus';
            }
            col.push({label:element.label,fieldName : fName, type: datatype,sortable: true});
        });
        this.columns = col;
         })
        .catch((error) => {
            console.log('error from handleOnLoad()', error);
            this.showError(error);
         });
    }

    showError(error){
        let event = new ShowToastEvent({
            title: 'Unable to fetch previous Engagement records',
            message: error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    get disablePrevious(){ 
        return this.currentPage<=1;
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage;
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1;
            this.updateRecords();
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1;
            this.updateRecords();
        }
    }

    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize;
        const end = this.recordSize*this.currentPage;
        this.visibleRecords = this.totalRecords.slice(start, end);
    }

    get records(){
        return this.visibleRecords;
    }
}