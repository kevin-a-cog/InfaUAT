/*Change History
*****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
*****************************************************************************************************
Amit GArg      10/10/2021  I2RT-7210   T01     Updated the code based on the wrapper class change in the apex

**/

import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContacts from "@salesforce/apex/ManageCaseContacts.getContacts";
import createcasecontactcontr from "@salesforce/apex/ManageCaseContacts.createcasecontactcontr";

export default class EsCaseAlternateContacts extends LightningElement {


    @api caserecId;
    @api suppAccId;
    @api orgId;
    @track NoDataAfterRendering;
    @track displayAddBTN;
    @track showErrorMessage;
    @track selectedRow;
    @track disableConfirmBTN = false;
    columns;
    @track data;
    tempData;
    defaultSortDirection = 'asc';
    @track  sortDirection;
    @track   sortedBy;
    searchText;
    @track buttonSearchClass = "d-flex align-items-center justify-content-end mb-2";
    COL_CONTACTS = [

        {
            label: "Contact Name",
            fieldName: "name",
            type: "text",
            sortable: true,
            
        },

        {
            label: "Email",
            fieldName: "email",
            type: "email",
            sortable: true,
            
        },

        {
            label: "Phone",
            fieldName: "phone",
            type: "text",
            sortable: true,
            
        },
        
        {
            label: "Primary",
            fieldName: "Primary__c",
            type: "boolean",
            sortable: true,
        }

    ];


    connectedCallback() {

        console.log('esAlternateContacts-->connected');
        console.log('esAlternateContacts-->connected-->caseId' + this.caserecId);
        console.log('esAlternateContacts-->connected-->suppAccId' + this.suppAccId);
       // this.caserecId = '500g000000WbolS';
       // this.suppAccId = '001g000002TRd3h';
        this.refreshData();
    }


    refreshData() {

        this.NoDataAfterRendering = false;
        this.displayAddBTN = false;
        this.showErrorMessage = undefined;
  
            this.columns = this.COL_CONTACTS;
            this.data = undefined;

            console.log('esAlternateContacts-->refreshData-->caseId' + this.caserecId);
            console.log('esAlternateContacts-->refreshData-->suppAccId' + this.suppAccId);
            //console.log('SupAcc'+SupAcc);
            getContacts({ supportAccountId: this.suppAccId, caseId: this.caserecId })
                .then((result) => {
                    console.log('refreshData->  getAlternateContacts->then ');
                // console.log(JSON.stringify(result));
                    let tempData = JSON.parse(JSON.stringify(result));
                    this.parseResult(tempData);
                })
                .catch((error) => {
                    console.log('handleRefresh->  getAlternatecontacts >catch '+JSON.stringify(error));
                })
           
                
    }
    //<T01> created seprate method to parse data
    parseResult(tempData){
        if (tempData) {
            this.data = tempData; 
            this.tempData = this.data;
        }
        else{
            this.NoDataAfterRendering = true;
            this.data = undefined;
        }
    }
   handleRowSelected(event) {
            console.log('handleRowSelected-->'+ event.detail.selectedRows);
            const selectedRows = event.detail.selectedRows;
            console.log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
            this.selectedRow =  selectedRows;
            console.log("selected row final => " + JSON.stringify(this.selectedRow));
            if (this.selectedRow.length > 0) {
              this.displayAddBTN = true;   
              this.showErrorMessage = undefined;
            }
    }

    createCaseContact() {
        
        var caseconts = [];
        console.log('selected rows'+ JSON.stringify(this.selectedRow));
        const selrows = this.selectedRow;
        if(selrows){
        this.disableConfirmBTN = true;
        
        for (let i = 0; i < selrows.length; i++) {             
            var temprec = {};
            if(selrows[i]?.contactId !== undefined && selrows[i]?.contactId !== null && selrows[i]?.contactId !== ''){
                temprec['Contact__c'] = selrows[i].contactId;
                temprec['Case__c'] = this.caserecId;
            }
            else{
                temprec['Email__c'] = selrows[i].email;
                temprec['Case__c'] = this.caserecId;
            }
            console.log('temprec'+temprec);
            caseconts.push(temprec);
        }

        createcasecontactcontr({casecon: caseconts, supportAcc: this.suppAccId})
            .then(casecontact => { 
                console.log('CaseContact: '+JSON.stringify(casecontact));
                this.showToastEvent('', 'Added Successfully!', 'success', 'dismissable');
                //dispatching the custom event
                this.dispatchEvent(new CustomEvent('addalternatecontact', {detail: caseconts})); //Send records to display on table to the parent component
            })
            .catch(error => {
                console.log('error'+ JSON.stringify(error));
                this.disableConfirmBTN = false;
                this.showToastEvent('Failed to Add!', 'An error occurred while adding Case Contact(s)', 'error', 'dismissable');
            });
        }
     
        

    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        console.log('onHandleSort');
        const { fieldName: sortedBy, sortDirection } = event.detail;     
        this.sortData(event.detail.fieldName, event.detail.sortDirection);  
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;  
       /* const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;*/
    }
    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.data));
        let isReverse = direction === 'asc' ? 1: -1;
        let keyValue = (a) => {
            return a[fieldname];
        };
       // console.log(fieldname+' fieldname==> '+isReverse); 
       
//console.log(direction+' isReverse==> '+isReverse);
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        console.log('isReverse==>264 '+isReverse);
        this.data = parseData;
    }

    showToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(event);
    }
    //I2RT-4421
    handleSearchText(event) {
        this.data = this.tempData;
        this.searchText = event.target.value;
        let parseData = JSON.parse(JSON.stringify(this.data));
        
        //this.openCases=this.Allcaseitems;
         /** START-- adobe analytics */
         try {
            util.trackCaseSearch();
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
       // console.log('filter==>',Number.isInteger(12));       
       if ( this.searchText.length >= 2) {
            var filteredRecords = [];
            let chcknmber=Number(this.searchText);
         //   alert(this.searchText +' seerach');
            for (var index in parseData) {
                var record = parseData[index];
               // console.log('index record==>',JSON.stringify(record));
                let value=JSON.stringify(record);
                if (value && value.length > 0 && value.toLowerCase().includes(this.searchText.toLowerCase())) {
                    filteredRecords.push(record);
                    //console.log('add record==>',record);
                }              
            }
            this.data=filteredRecords;
          //  console.log('record==>',filteredRecords.length);
           //you  alert(filteredRecords.length+ ' txt '+this.searchText);
        
 }else{
           this.data = this.tempData;
        //this.openCases=this.Allcaseitems ;
           // eval("$A.get('e.force:refreshView').fire();");
           // console.log('record else==>',this.openCases.length);
        }
    }
   // I2RT-4421
}