import { LightningElement , track, api, wire } from 'lwc';
import fetchAllLicensesAvailable from '@salesforce/apex/licenseManagementHandler.fetchAllLicensesAvailable';
import fetchUsersForLicense from '@salesforce/apex/licenseManagementHandler.fetchUsersForLicense';
import getFieldLableAndFieldAPI from '@salesforce/apex/licenseManagementHandler.getFieldLableAndFieldAPI';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
const PAGE_SIZE = 10; // Number of records to display per page

export default class LicenseManagementApp extends LightningElement {
    isLicenseSelected = false;
    error;
    username;
    licenseOptions = [];
    selectedLicense ='';
    noUserList=false;

    @track userColumns =[];
    @track userData = [];
    @track currentPage = 1;
    @track totalPages = 0;
    allUserLicensesData = null;

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
        const cloneData = [...this.allUserLicensesData];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allUserLicensesData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.userData = this.paginateData(this.allUserLicensesData);
        
    }
    
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.userData = this.paginateData(this.allUserLicensesData);
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.currentPage+ 1;
            this.userData = this.paginateData(this.allUserLicensesData);
        }
    }

    get disablePrevious(){ 
        return this.currentPage<=1;
    }

    get disableNext(){ 
        return this.currentPage>=this.totalPages;
    }

    paginateData(data) {
        const startIndex = (this.currentPage - 1) * PAGE_SIZE;
        const endIndex = startIndex + PAGE_SIZE;
        return data.slice(startIndex, endIndex);
    }
    

    clearGridAndPaginator()
    {
        this.userData = [];
        this.currentPage = 1;
        this.totalPages = 0;
    }

    clearuserList()
    {
        this.allUserLicensesData=false;
        this.noUserList = false;
    }
    
    getFieldNamesForDatatable(){
        getFieldLableAndFieldAPI()
        .then((data) =>{
            let fieldSet = JSON.parse(data);      
            this.userColumns = [];      
            fieldSet.forEach((element)=>{
                let lab=element.label;
                if(lab=='Last Login'){
                    lab='Salesforce Last Login';
                }
                this.userColumns.push({label:lab, fieldName:element.fieldPath ,sortable: true});
            });
         })
        .catch((error) => {
            this.showError(error);
            console.log('getFieldLableAndFieldAPI error ',error);
         });
    }

    showError(error){
        let event = new ShowToastEvent({
            title: 'Error',
            message: error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleLicenseChange(event){
        this.clearuserList();
        this.clearGridAndPaginator();
        this.selectedLicense = event.detail.value;
        this.getLicensedUsers(this.selectedLicense);
        this.getFileName();
    }

    @wire(fetchAllLicensesAvailable, {}) 
    wireAssignedLicenses({error,data}) {
        if (error) {
            this.error = error ; 
            console.log('wireAssignedLicenses this.error ' , this.error);
        } else if (data) {
            this.prepareLicenseOptions(data);
        }
    };

    prepareLicenseOptions(licensesList)
    {
        this.licenseOptions = [];
        if(!!licensesList && licensesList.length > 0)
        {
            licensesList.forEach(currentItem => {
                let licenseItem = {};
                licenseItem.label = currentItem;
                licenseItem.value = currentItem;
                this.licenseOptions.push(licenseItem);
            });
        }
    }

    getLicensedUsers(licenseName){
        fetchUsersForLicense({'License':licenseName})
                .then(result => {
                if(result && result.length > 0){
                    this.getFieldNamesForDatatable(); 
                    this.totalPages = Math.ceil(result.length / PAGE_SIZE);
                    this.userData = this.paginateData(result);
                    this.allUserLicensesData = result;
                }else{
                    this.noUserList = true;
                }

                })
                .catch(error => {
                    console.log('Error fetching Licenses users list ' , error);
                });
    }

    handleExportCSV()
    {
        this.exportAsCSV();
    }

    exportAsCSV() {
      
        if (!(!!this.allUserLicensesData && this.allUserLicensesData.length > 0)) {
            return;
        }
  
        let csvHeader = '';
        for (let colIndex = 0; colIndex < this.userColumns.length; colIndex++) {
            csvHeader = csvHeader + this.userColumns[colIndex].label + ',';
        }
        csvHeader = csvHeader.substring(0, csvHeader.length - 1) + '\n';
        
        let csvRows = '';

        for (var i = 0; i < this.allUserLicensesData.length; i++) {
            let recordDetails = this.allUserLicensesData[i];
            
            let csvRow = '';
            for (let colIndex = 0; colIndex < this.userColumns.length; colIndex++) {
                
                let cellValue = recordDetails[this.userColumns[colIndex].fieldName];

                if(!!cellValue)
                {
                    csvRow += cellValue;
                }
                else
                {
                    csvRow +='';
                }
                csvRow += ',';

            }
            csvRow = csvRow.substring(0, csvRow.length - 1) + '\n';
            csvRows += csvRow;
        }
        let csvAllRows = csvHeader + csvRows;
        csvAllRows = csvAllRows.replaceAll('undefined', '').replaceAll('null', '');

        var blob = new Blob([csvAllRows], { type: 'text/plain' });
        var url = window.URL.createObjectURL(blob);
        var atag = document.createElement('a');
        atag.setAttribute('href', url);
        var fileName = this.getFileName();
        atag.setAttribute('download', fileName);
        atag.click();

    }

    getFileName(){
        const date = new Date();
        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let hours = (date.getHours()<10?'0':'') + date.getHours();
        let mins = (date.getMinutes()<10?'0':'') + date.getMinutes();
        let sec = (date.getSeconds()<10?'0':'') + date.getSeconds();
        let currentDate = `${day}-${month}-${year} ${hours}:${mins}:${sec}`;
        let fileName = this.selectedLicense+' '+currentDate+'.csv';
        return fileName;
    }
}