import { LightningElement, api, track } from 'lwc';

export default class DatatableFlow extends LightningElement {

    @api mydata;
    @api columns;
    @api keyfield;
    @api recordData;
    @api columnNamesCSV;
    @track sortBy;
    @track sortDirection;


    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        //rowactions should be handled by the parent.  
        this.dispatchRowActionEvent(row, action);

    }

    dispatchRowActionEvent(row, action) {
        const rowActionTaken = new CustomEvent('rowactiontaken', {
            bubbles: false, 
            detail: {row, action}
        });
        this.dispatchEvent(rowActionTaken);
    }
   

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            console.log("You selected: " + selectedRows[i]);
        }
        this.dispatchRowSelectedEvent(selectedRows);
    }    

    dispatchRowSelectedEvent(selectedRows) {
        console.log('selectedrows is: ' + JSON.stringify(selectedRows));
        const rowSelected = new CustomEvent('rowselected', {
            bubbles: false, 
            detail: {selectedRows}
        });
        this.dispatchEvent(rowSelected);
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.mydata));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.mydata = parseData;

    }

}