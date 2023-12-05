import { LightningElement, api, track } from 'lwc';

const columns = [
    { label: 'Contact Name', fieldName: 'contactName', hideDefaultActions: true, sortable: true },
    { label: 'Contact Account', fieldName: 'contactAccount', hideDefaultActions: true, sortable: true },
    { label: 'Contact Email Address', fieldName: 'contactEmail', hideDefaultActions: true, sortable: true },
    { label: 'Access Type', fieldName: 'contactId', type: 'picklist', typeAttributes: { value: {fieldName: 'accessType'},disabled: {fieldName: 'isPicklistDisabled'}},wrapText: true}
];
export default class IpueReviewContactsTable extends LightningElement {
    @api contactRecs;
    @api selectedConatcts;
    @api tableHeight;
    columns = columns; //columns to be displayed in lightning-datatable
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    collaborators = [];
    @track selectedRecs = []; //selected contact Ids, used in lightning datatable

    
    connectedCallback() {
        
        //Parse the selectedContactIds from parent
        for(let contact of this.contactRecs){
            this.collaborators.push(contact);
        }

        //Parse the selectedContactIds from parent
        for(let contactId of this.selectedConatcts){
            this.selectedRecs.push(contactId);
        }
    }
    
    updateCollaborators(){
        this.dispatchEvent(new CustomEvent('updatecollaborators',{
            detail : this.collaborators
        }));        
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
        const cloneData = [...this.collaborators];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.collaborators = cloneData;
        this.updateCollaborators();
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleRowSelection(event){
        let rowsSelectedFromTable = event.detail.selectedRows.map(collab => collab.contactId); //selected rows from table
        let selectedRows = JSON.parse(JSON.stringify(this.selectedRecs));      
        let lstCollabRecs = JSON.parse(JSON.stringify(this.collaborators));
        //Row is selected
        if(rowsSelectedFromTable.length > selectedRows.length){
            //getting the selected row(s),setting isSelected to true
            rowsSelectedFromTable = rowsSelectedFromTable.filter((contactId) => !selectedRows.includes(contactId)); 
            for(let contact in rowsSelectedFromTable){
                let foundIndex = lstCollabRecs.findIndex(x => x.contactId == rowsSelectedFromTable[contact]);            
                lstCollabRecs[foundIndex].isSelected = true;
                if(lstCollabRecs[foundIndex].isPicklistDisabled){ //Enable picklist if any existing estimation collborator is selected
                    lstCollabRecs[foundIndex].isPicklistDisabled = false;
                }                
                this.selectedRecs.push(rowsSelectedFromTable[contact]);
            }
            this.collaborators = lstCollabRecs;
        }else{ //Row is Unselected
            //Getting the unselected row(s), setting isSelected to false
            selectedRows = selectedRows.filter((contactId) => !rowsSelectedFromTable.includes(contactId));
            for(let contact in selectedRows){
                let foundIndex = lstCollabRecs.findIndex(x => x.contactId == selectedRows[contact]);            
                lstCollabRecs[foundIndex].isSelected = false;
                if(!lstCollabRecs[foundIndex].isPicklistDisabled && lstCollabRecs[foundIndex].estimationCollaboratorId){ //Disable picklist if any existing estimation collborator is unselected
                    lstCollabRecs[foundIndex].isPicklistDisabled = true;
                }
                this.selectedRecs = this.selectedRecs.filter(contactId => contactId !==  selectedRows[contact]);
            }
            this.collaborators = lstCollabRecs;
        }
        this.updateCollaborators();
    }

    picklistChanged(event) {
        //Whenever the picklist value is updated, updating the estimatorRecs with the same
        event.stopPropagation();
        var foundIndex = this.collaborators.findIndex(x => x.contactId == event.detail.data.recordId);
        let estimatorRecsLocal = JSON.parse(JSON.stringify(this.collaborators));
        estimatorRecsLocal[foundIndex].accessType = event.detail.data.value;
        this.collaborators = estimatorRecsLocal;
        this.updateCollaborators();
    }
}