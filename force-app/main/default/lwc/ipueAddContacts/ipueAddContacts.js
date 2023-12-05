/*
Component Name:  IpueAddContacts
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156    Change History

********************************************************************************************************************************************
ModifiedBy            Date          JIRA No.        Description                                                 Tag
Chandana Gowda      16-jan-2023     SALESRT-14638   Enable the 'Global Contacts' search source option           <T01>
********************************************************************************************************************************************
*/
import { LightningElement, api, wire, track } from 'lwc';
import getTableColumns from '@salesforce/apex/IPUE_AddContactsController.getFieldsToDisplay';
import getContactsRecs from '@salesforce/apex/IPUE_AddContactsController.getContacts';
import getRecCount from '@salesforce/apex/IPUE_AddContactsController.getNumberOfRecords';
import getEstimationRecord from '@salesforce/apex/IPUE_AddContactsController.getEstimationRec';

export default class IpueAddContacts extends LightningElement {
    @api recordId;
    accountId;
    opportunityId;
    @api contactsFromParent; //contact records to be selected - passsed from parent(if any)
    contactRecordsToBeSelected = []; //Contact records to be selected, holds the Contact Id of the existing collaborators, newly created contact and/or the Ids paased from the parent(if any)
    @track selectedContacts = []; //Used to hold the list of selected records, used to render the selected records in the datatable
    removeSelectedFromEstimationCollabs = null; //flag to remove auto removal of auto selected estimator collaborators on initial run
    contactSearchKey = '';
    searchSource = '';
    queryFields; //contact fields to be used in the query, formed from the fields in the related list
    columns;
    contactRecs; //Records displayed on the lightning datatable
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    loadMoreStatus; //Used to display the appropriate message for infinte loading
    offSetCount = 0;
    targetDatatable;
    totalNumberOfRows = '';
    loadingTable = true;
    showCreateContact = false;

    connectedCallback(){
        //Fetch the latest account, opportunity and Estimator collaborator whenever the button is clicked
        this.getEstimationRec();
    }

    //Initialize the search source options
    get searchSourceOptions() {
        let options = [
            {label: 'Opportunity Contacts',value: 'Opportunity Contacts'},
            {label: 'Account Contacts',value: 'Account Contacts'},
            {label: 'Global Contacts',value: 'Global Contacts'} //Uncommenting to enable 'Global Contacts' search source option - <T01>
        ];
        //Default the search source to the first option
        if (!(this.searchSource)) {
            this.searchSource = options[0].value;
        }        
        return options;
    }

    getEstimationRec(){
        //Fetch estimation summary record information
        getEstimationRecord({recordId: this.recordId}).then(result => {
            this.accountId = result.Account__c ? result.Account__c : '';
            this.opportunityId = result.Opportunity__c ? result.Opportunity__c : ''; 
            //If the contactIds are passed from the parent
            if(this.contactsFromParent && this.contactsFromParent.length){
                for(let contactId of this.contactsFromParent){
                    this.contactRecordsToBeSelected.push(contactId);
                }
            }else{ //Initialize with the existing estimator collaborators
                if(result.Estimator_Collaborators__r){
                    for(let collaborator in result.Estimator_Collaborators__r){
                        this.contactRecordsToBeSelected.push(result.Estimator_Collaborators__r[collaborator].Contact__c);
                    }
                }
            }
            this.getTotalNumberOfRows();
        })
        .catch(error => {
            console.log('Error reading Estimation Summary Record information');
            console.log(error);
        });        
    }

    //Getting the columns to be displayed in the lightning datatable
    @wire(getTableColumns)
    getColumns({ error, data }) {
        if (data) {
            this.columns = [...data];
            let fieldApiNames = [];
            for(let column in data){
                fieldApiNames.push(data[column].fieldName);
            }
            this.queryFields = ','+fieldApiNames.toString();
        } else if (error) {
            console.log('Error Fetching table columns');
            console.log(error);
        }
    }
    
    //Fetch the total number of records Based on the search term and search source
    getTotalNumberOfRows(){
        getRecCount({accountId: this.accountId, opportunityId : this.opportunityId, searchSource: this.searchSource, searchTerm: this.contactSearchKey}).then(result =>{
            if(result || result == 0){
                this.totalNumberOfRows = result;
                this.offSetCount = 0; //reset the offset count, to refresh datatable
                if(this.targetDatatable){
                    //disable infinteLoading on table if the number of records fetched in less than 25
                    this.targetDatatable.enableInfiniteLoading = this.totalNumberOfRows > 25;
                    this.targetDatatable = '';
                }
                this.loadingTable = true;
            }
            this.getContacts();

        }).catch(error => {
            console.log('Unable to fetch total number of records');
            console.log(error);});
    }
    
    //Fetch the contact record information based on search term and search source
    getContacts(){
        getContactsRecs({ accountId: this.accountId, opportunityId : this.opportunityId,searchSource: this.searchSource, searchTerm: this.contactSearchKey, queryFields: this.queryFields, offSetCount : this.offSetCount , totalNumberOfRows: this.totalNumberOfRows}).then(data => {
            let selectedRowsVar = [...this.selectedContacts];
            
            //Remove any estimator collaboratos that were unselected, before loading new records
            if(this.contactRecs){
                for(let contactId of this.contactRecordsToBeSelected){
                    if(!(selectedRowsVar.includes(contactId)) && this.contactRecs.some(contact => contact.Id === contactId)){
                        let index = this.contactRecordsToBeSelected.indexOf(contactId);
                        this.contactRecordsToBeSelected.splice(index,1);
                    }
                }
            }

            //If the method is invoked due to scrolling, then append the records to the existing list
            if(this.targetDatatable){                         
                this.contactRecs = [...this.contactRecs,...data];
            }else{
                this.contactRecs = data;
            }

            //If the set of newly loaded records have any if the existing estimation collaborators, then auto select those records
            if(this.contactRecordsToBeSelected.length > 0){
                for(let collab in this.contactRecordsToBeSelected){
                    let contactId = this.contactRecordsToBeSelected[collab];
                    if(!(selectedRowsVar.includes(contactId)) && this.contactRecs.some(contact => contact.Id === contactId)){
                        selectedRowsVar.push(contactId);
                    }
                }
                if(this.removeSelectedFromEstimationCollabs != null){
                    this.removeSelectedFromEstimationCollabs = false;
                }
            }
            this.selectedContacts = selectedRowsVar;

            this.loadMoreStatus = '';
            //disable infinte loading, if the records are completely fetched
            if(this.targetDatatable && this.contactRecs.length >= this.totalNumberOfRows){
                this.targetDatatable.enableInfiniteLoading = false;
            }
            this.loadingTable = false;

        }).catch(error => {
            console.log('Error Fetching contact Records');
            console.log(error);});
    }

    //handler for search source picklist value change
    handleSearchSourceChange(event) {
        this.loadingTable = true;
        this.targetDatatable = this.template.querySelector('lightning-datatable');
        this.searchSource = event.detail.value;
        this.getTotalNumberOfRows();
    }

    //handler for search bar
    handleSearchContacts(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.currentTarget.value;
        //Apply the search after delay, to prevent simultaneous call on each key press
        this.delayTimeout = setTimeout(() => {
            this.loadingTable = true;
            this.targetDatatable = this.template.querySelector('lightning-datatable');
            this.contactSearchKey = searchKey;
            this.getTotalNumberOfRows();
        }, 300);
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
        const cloneData = [...this.contactRecs];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contactRecs = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    //handler for loadMore
    loadMoreContacts(event){
        this.targetDatatable = event.target;
        this.loadMoreStatus = 'Loading';
        this.loadingTable = true;
        //To get first 25 records initially
        if(this.offSetCount == 0){
            this.offSetCount = 25;
        }
        //If the count exceeds 2000, the offset does not work, disable the infinite scrolling
        else if(this.offSetCount > 2000){
            this.loadMoreStatus = 'Cannot load more records, Please update search criteria';
            event.target.enableInfiniteLoading = false;
            this.loadingTable = false;
        }
        //else increment offset by 10
        else{
            this.offSetCount = this.offSetCount + 10;
        }
        this.getContacts();
    } 

    //Handler for Row selection
    handleRowSelection(event){

        //Selected Rows from table
        const selectedRowsFromTable = event.detail.selectedRows;
        const selectedContactIdsFromTable = selectedRowsFromTable.map(contact => contact.Id);
        let selectedRowsVar = [...this.selectedContacts];
        
        //Set to TRUE if all the elements of selectedContactIdsFromTable are present in selectedRowsVar, else FALSE
        //If TRUE, then row(s) were selected that are not in the current selected list
        let rowUnSelected = selectedContactIdsFromTable.every(contactId => selectedRowsVar.includes(contactId));

        //Row(s) selected
        if(selectedRowsVar.length <= selectedRowsFromTable.length || !rowUnSelected){
            for(let contactId of selectedContactIdsFromTable){
                if(!selectedRowsVar.includes(contactId)){
                    selectedRowsVar.push(contactId);
                }
            }
        }

        //Row(s) unselected
        else{
            let removedRows = [];
            for(let contactId of selectedRowsVar){
                if(!selectedContactIdsFromTable.includes(contactId) && this.contactRecs.some(contact => contact.Id === contactId)){
                    selectedRowsVar = selectedRowsVar.filter(contactRecId => contactRecId !== contactId);
                    removedRows.push(contactId);
                }
            }
            //If any of the existing estimator collaborator is unselected, remove from the list
            if(this.removeSelectedFromEstimationCollabs != false){
                this.contactRecordsToBeSelected = this.contactRecordsToBeSelected.filter(contactRecId => !(removedRows.includes(contactRecId)));
            }
        }
        this.removeSelectedFromEstimationCollabs = true;
        this.selectedContacts = selectedRowsVar;
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleNewContact(){
        this.showCreateContact = true;
    }
    //On successful insertion of contact
    handleContactSuccess(event){
        this.showCreateContact = false;
        let contactId = event.detail;
        //Add the newly created contact to the selected list
        //Added the string check condition to add the event.detail only if it is a ID and not object
        if(contactId && typeof contactId === 'string'){
            //Storing the new contact Id, this will be auto selected when the datatable is refreshed
            this.contactRecordsToBeSelected.push(contactId);
            this.getTotalNumberOfRows();
        }
    }
    
    handleNext(){
        //create a set of selected rows and existing estimator collaborators and dispatch event to parent
        let selectedRows = [new Set([...this.selectedContacts,...this.contactRecordsToBeSelected])];
        this.dispatchEvent(new CustomEvent('next',{
            detail : selectedRows
        }));        
    }
}