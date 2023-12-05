/*
 * Name			:	esAlternateContacts
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/25/2022
 * Description	:	This LWC displays alternate contacts.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran      10/25/2022		I2RT-7256		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { esUtilities } from 'c/esUtilities';

export default class EsAlternateContacts extends LightningElement {

    //API variables
    @api objParameters;

    //Track variables
    @track lstAllContacts = [];
    @track lstAllSelectedRecordIds = [];

    //Private variables
    strSearchTerm;
    strIconName = 'utility:down';
    strSortDirection = 'asc';
    strSortedBy;
    lstColumns = [
        { label: 'First Name', fieldName: 'strFirstName', type: 'text', sortable: true },
        { label: "Last Name", fieldName: "strLastName", type: "text", sortable: true },
        { label: "Email Address", fieldName: "strEmail", type: "text", sortable: true },
        { label: "Phone Number", fieldName: "strPhone", type: "text", sortable: true }
    ];
    lstContactsInView = [];
    intCurrentPage = 1;
    intTotalPages = 0;
    intTotalRecords = 0;
    intRecordPerPage = 10;

    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters  : None
     Return Type : None
    */
    connectedCallback() {
        let objParent = this;

        if(!objUtilities.isEmpty(objParent.objParameters.lstAllContacts)){
            //Now, we make a deep copy of the values
            objParent.lstAllContacts = JSON.parse(JSON.stringify(objParent.objParameters.lstAllContacts));
            objParent.lstAllSelectedRecordIds = JSON.parse(JSON.stringify(objParent.objParameters.lstAllSelectedRecordIds));;
            objParent.resetPaginationValues();
        }        
    }

    /*
     Method Name : resetPaginationValues
     Description : This method resets pagination values based on the visible records .
     Parameters  : None
     Return Type : None
    */
     resetPaginationValues(){
        let objParent = this;
        let intDataLength = objParent.lstAllContacts.filter(obj => obj.boolIsVisible === true).length;

        objParent.intCurrentPage = intDataLength >= 1 ? 1 : 0;
        objParent.intTotalRecords = intDataLength;
        objParent.intTotalPages = Math.ceil(objParent.intTotalRecords/objParent.intRecordPerPage);
    }

    /*
	 Method Name : search
	 Description : This method searches across records.
	 Parameters	 : Event, called from search, objEvent Event.
	 Return Type : None
	*/
    search(objEvent){
        let objParent = this;
        objParent.strSearchTerm = objEvent.target.value?.toLocaleLowerCase();
        objParent.lstAllContacts.forEach(objRecord => {
            let strSearchValue = Object.values(objRecord).join(' ')?.toLocaleLowerCase();
            if(objUtilities.isBlank(objParent.strSearchTerm) || strSearchValue.includes(objParent.strSearchTerm)) {
				objRecord.boolIsVisible = true;
			} else {
				objRecord.boolIsVisible = false;
			}
        });
        objParent.resetPaginationValues();
        objParent.lstAllSelectedRecordIds = [...objParent.lstAllSelectedRecordIds];
    }

    /*
	 Method Name : sort
	 Description : This method sorts the data.
	 Parameters	 : Event, called from sort, objEvent On click Event.
	 Return Type : None
	*/
    sort(objEvent){
        let objParent = this;
        let lstClonedData = [...objParent.lstAllContacts];
        const { fieldName: sortedBy, sortDirection } = objEvent.detail;

        objParent.lstAllContacts = lstClonedData.sort(esUtilities.sortBy(objParent.strSortedBy, objParent.strSortDirection === 'asc' ? 1 : -1));
        objParent.strSortedBy = sortedBy;
        objParent.strSortDirection = sortDirection;
    }

    /*
	 Method Name : sort
	 Description : This method sorts the data.
	 Parameters	 : Event, called from sort, objEvent On click Event.
	 Return Type : None
	*/
    select(objEvent){
        let objParent = this;
        let lstSelectedRows = objEvent.detail.selectedRows;
        let lstSelectedRowsInView = [];
        let lstSelectedRowsInViewOld = [];

        lstSelectedRows.forEach(obj => {
            lstSelectedRowsInView.push(obj.strId);
        });
        console.log(lstSelectedRows);
        console.log(lstSelectedRowsInView);
        console.log(lstSelectedRowsInViewOld);
        objParent.lstContactsInView.filter(objContact => objParent.lstAllSelectedRecordIds.includes(objContact.strId)).forEach(objContact => lstSelectedRowsInViewOld.push(objContact.strId));
        objParent.lstAllSelectedRecordIds = Array.from(new Set([...objParent.lstAllSelectedRecordIds.filter(strSelectedRecordId => !lstSelectedRowsInViewOld.includes(strSelectedRecordId)), ...lstSelectedRowsInView]));
        console.log(JSON.stringify(objParent.lstAllSelectedRecordIds));
    }

    /*
	 Method Name : first
	 Description : This method sets the current page to the first page.
	 Parameters	 : None
	 Return Type : None
	*/
    first(){
        this.intCurrentPage = this.intTotalPages >= 1 ? 1 : 0;
    }

    /*
	 Method Name : last
	 Description : This method sets the current page to the last page.
	 Parameters	 : None
	 Return Type : None
	*/
    last(){
        this.intCurrentPage = this.intTotalPages >= 1 ? this.intTotalPages : 0;
    }

    /*
	 Method Name : next
	 Description : This method sets the current page to the next page.
	 Parameters	 : None
	 Return Type : None
	*/
    next(){
        this.intCurrentPage = (this.intTotalPages >= 1 && this.intCurrentPage >= 1 && this.intCurrentPage != this.intTotalPages) ? (this.intCurrentPage + 1) : this.intCurrentPage;
    }

    /*
	 Method Name : previous
	 Description : This method sets the current page to the previous page.
	 Parameters	 : None
	 Return Type : None
	*/
    previous(){
        this.intCurrentPage = (this.intTotalPages >= 1 && this.intCurrentPage >= 1 && this.intCurrentPage !== 1) ? (this.intCurrentPage - 1) : this.intCurrentPage; 
    }

    /*
	 Method Name : goToPreviousStep
	 Description : This method fires an event to parent component to hide the current step and show the previous step.
	 Parameters	 : None
	 Return Type : None
	*/
    goToPreviousStep(){
        this.dispatchEvent(new CustomEvent('goback', { detail: {lstAllSelectedRecordIds: this.lstAllSelectedRecordIds}, bubbles: false }));
    }

    /*
	 Method Name : proceed
	 Description : This method fires an event to parent component to hide the current step and show the next step.
	 Parameters	 : None
	 Return Type : None
	*/
    proceed(){
        this.dispatchEvent(new CustomEvent('proceed', { detail: {lstAllSelectedRecordIds: this.lstAllSelectedRecordIds}, bubbles: true }));
    }

    /*
	 Method Name : cancelCaseCreation
	 Description : This method fires an event to parent component to cancel the case creation process.
	 Parameters	 : None
	 Return Type : None
	*/
    cancelCaseCreation(){
        this.dispatchEvent(new CustomEvent('cancel', { detail: '', bubbles: true }));
    }

    /* Getter Methods */
    get startingRecord(){
        return this.intCurrentPage > 0 ? (this.intCurrentPage * this.intRecordPerPage) - this.intRecordPerPage + 1 : 0;
    }

    get endingRecord(){
        return this.intCurrentPage === this.intTotalPages && (this.intTotalRecords % this.intRecordPerPage) >= 1 ? this.intTotalRecords : (this.intCurrentPage * this.intRecordPerPage);
    }

    get lstContacts(){
        this.lstContactsInView = this.lstAllContacts?.filter(obj => obj.boolIsVisible === true)?.slice((this.intCurrentPage * this.intRecordPerPage) - this.intRecordPerPage, this.intCurrentPage * this.intRecordPerPage);
        return this.lstContactsInView;
    }

    get showContacts(){
        return this.lstAllContacts?.length >= 1;
    }

    get alternateContactMessage(){
        return this.lstAllSelectedRecordIds.length >= 1 ? `Alternate Contacts Selected (${this.lstAllSelectedRecordIds.length}/${this.lstAllContacts.length})`: `Alternate Contacts`;
    }

    get buttonLabel(){
        return this.lstAllSelectedRecordIds.length >= 1 ? 'Proceed' : 'Skip for now';
    }

}