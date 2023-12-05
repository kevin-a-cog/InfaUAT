/*
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					                Tag
 **********************************************************************************************************
 NA                     NA      		UTOPIA			Initial version.			                N/A
 Vignesh Divakaran      31-Aug-2022		I2RT-6865		Pass the alternate contacts description     T01
                                                        from parent component
 */

import { LightningElement, track, api, wire } from 'lwc';
import getAccountRelatedContacts from '@salesforce/apex/CaseController.getAccountRelatedContacts';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";
import CONTACT_ID from "@salesforce/schema/User.Contact.Id";
import { log } from 'c/globalUtilities'; //Vignesh

export default class EsCaseCreationAlternateContact extends LightningElement {
    @track isModalOpen = false;
    @track notAvailableAltContact = false;
    @api showAdditionalCaseInformation = false;
    @api caseType;
    @api caseInformation;
    @api caseAttachmentNumber;
    @api proceedUrl;
    @api goBackUrl;
    @api relatedContacts;
    @api selectedAccount;
    @api preselectedContacts;
    @api contactList = [];
    @api strAlternateContactsDescription; //<T01>
    @track loggedincontactId
    
    @track buttonLabel = 'Skip for now';
    @track contactsToAdd=  [];
    @track allContactsToAdd=  [];
    @track finalContactList=  [];
    @track selectedContact = 0;
    @track allContacts = [];
    @track contacts = [];
    @track displayContacts = [];
    @track page = 1; //this will initialize 1st page
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 10; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @track columns;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track customData;
    @track isPrimaryContact=false;
    @track CON_COLS = [
        { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: true },
        { label: "Last Name", fieldName: "LastName", type: "text", sortable: true },
        { label: "Email Address", fieldName: "Email", type: "text", sortable: true },
        { label: "Phone Number", fieldName: "Phone", type: "text", sortable: true },
    ];
    @track conid;
    @track error;
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            // this.isPrimaryContact = getFieldValue(this.user.data, CONTACT_ID); data.fields.Contact.value.fields.Is_Primary__c.value;
            this.conid = data.fields.Contact.value.fields.Id.value;
          //  log(  this.conid+'==conid '+JSON.stringify(this.alternateContacts));
          //check for prmary contact
            this.isPrimary(this.conid);
        }
    }
     isPrimary(recId){
            for(var x in this.alternateContacts){
                if(recId == this.alternateContacts[x].ContactId && this.alternateContacts[x].Primary__c){
                    this.isPrimaryContact = true;
                       log(this.alternateContacts[x].ContactId +' <==> '+this.alternateContacts[x].Primary__c)
            
                }
              //  log(this.alternateContacts[x].ContactId +' <==> '+this.alternateContacts[x].Primary__c)
            }
         // this.relatedContacts.length +' '+recId;
    }
    @track selection;
    @track selectedContactsToAdd = [];
    @track selectedContactsToAddList = [];
    connectedCallback(){
        this.alternateContacts = this.relatedContacts;
        this.columns = this.CON_COLS;
        this.contacts = this.alternateContacts;
        log("data==> "+JSON.stringify(this.contactList));
        log('preselected -> '+JSON.stringify(this.preselectedContacts));
        log("this.alternateContacts data ==> "+JSON.stringify(this.alternateContacts));
      //  alert(  this.conid+'conid');
        //this.allContactsToAdd.push(...this.contactList);
        //this.selectedContact = this.preselectedContacts.length;
        this.selectedContactsToAddList.push(...this.contactList);
        this.selectedContactsToAdd.push(...this.contactList.map(ACR => ACR.Contact));
        this.selectedContact = this.preselectedContacts.length;
        this.selection = this.preselectedContacts;

        if(this.selectedContact == 0){
            this.buttonLabel = 'Skip for now';
        } else {
            this.buttonLabel = 'Proceed';
        }
    }

    renderedCallback(){
 
     
        if(this.items<=0){            
            this.items = this.contacts;
            this.endingRecord =  this.items.length; // this.pageSize;
        }
        this.endingRecord = this.endingRecord == 0 ? ((this.items.length < this.pageSize) ? this.items.length : this.pageSize)  : this.endingRecord ;
        this.totalRecountCount = this.contacts.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        /*if(this.preselectedContacts.length > 0){
            let rows = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.getSelectRows(rows);
        }  */

    }

   /*  addItem(event){
        var isChecked = event.detail.checked;
        var contact = event.target.value;
        let contacts = this.contactsToAdd;
        let allContacts = this.relatedContacts;
        this.allContacts = this.relatedContacts.length;
        log('contact- '+event.target.value);
        log('isChecked- '+isChecked);
        if(isChecked){
            if(contacts.length === 0){
                let newContact = [];
                for(var j in allContacts){
                    if(allContacts[j].Id == contact){
                        newContact.push(allContacts[j]);
                    }
                }
                this.contactsToAdd = [];
                this.contactsToAdd = newContact;
            } else {
                let newContact = [];
                let existingIds = [];
                for(var i in contacts){
                    if(contacts[i].Id !== contact)
                    existingIds.push(contacts[i].Id);
                }
                for(var j in allContacts){
                    if(allContacts[j].Id == contact || existingIds.indexOf(allContacts[j].Id) !== -1){
                        newContact.push(allContacts[j]);
                    }
                }
                this.contactsToAdd = newContact;
            }
        } else {
            var newContactList = [] ;
            for(var i in contacts){
                if(contacts[i].Id !== contact){
                    newContactList.push(contacts[i]);
                }
            }   
            this.contactsToAdd = newContactList;
        }
        if(this.contactsToAdd.length > 1){
            this.alternateContact = this.contactsToAdd.length + 'Contacts';
        } else {
            this.alternateContact = this.contactsToAdd.length + 'Contacts';
        }
        if(this.contactsToAdd.length === 0){
            this.buttonLabel = 'Skip for now';
        } else {
            this.buttonLabel = 'Proceed';
        }
        this.selectedContact = this.contactsToAdd.length;
        log('contactsToAdd= '+JSON.stringify(this.contactsToAdd));
    } */
    @track displayContactsData = [];
    selectAlternateContacts(event){
        const selectedRows = event.detail.selectedRows;
        this.getSelectRows(selectedRows);
        log("selectedRows: "+JSON.stringify(selectedRows));
    }

    /*getSelectRows(selectedRows){
        this.contactsToAdd = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            log('selected Rows :' + selectedRows);
            [...this.alternateContacts].map(record =>{
                if (record.ContactId == selectedRows[i].Id) {
                    this.contactsToAdd.push(record);
                }
            });
            log(this.contactsToAdd);
        }

        if(this.contactsToAdd.length > 1){
            this.alternateContact = this.contactsToAdd.length + ' Contacts';
        } else {
            this.alternateContact = this.contactsToAdd.length + ' Contacts';
        }

        let updated = true;
        if (this.allContactsToAdd.length > 0){
            for(let contacts in this.allContactsToAdd){
                if (this.allContactsToAdd[contacts].pagenumber == this.page){
                    let pageselectedcontact = {
                        pagenumber : this.page,
                        selectedRows : this.contactsToAdd
                    }
                    let contactLength = this.allContactsToAdd[contacts].selectedRows.length;
                    this.allContactsToAdd.splice(contacts, 1, pageselectedcontact);
                    let finalDiff = this.contactsToAdd.length - contactLength;

                    this.selectedContact = this.selectedContact + finalDiff;
                    log("Called1", finalDiff);
                    log("Called11", contactLength);
                    log("Called111", this.contactsToAdd.length);
                    
                    updated = false;
                }
            }
        }
        if (updated && this.contactsToAdd.length > 0){
            let pageselectedcontact = {
                pagenumber : this.page,
                selectedRows : this.contactsToAdd
            }
            this.allContactsToAdd.push(pageselectedcontact);
            this.selectedContact = this.selectedContact + this.contactsToAdd.length;
            log("Called");

        }
        if(this.selectedContact == 0){
            this.buttonLabel = 'Skip for now';
        } else {
            this.buttonLabel = 'Proceed';
        }
        this.flatAllContactToAdd();
    }*/

    getSelectRows(selectedRows){
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        //List of selected item we maintains. array of objects
        let selectedItemsObjSet = new Set();
        let selectedItemsObjSetList = new Set();
        
        this.displayContacts.map(contact => {
            loadedItemsSet.add(contact.Id);
        });

        if(selectedRows){
            selectedRows.map(selectedRow => {
                updatedItemsSet.add(selectedRow.Id);
            });

            updatedItemsSet.forEach(id => {
                if(!selectedItemsSet.has(id)){
                    selectedItemsSet.add(id);
                }
            });
        }

        loadedItemsSet.forEach(id => {
            if(selectedItemsSet.has(id) && !updatedItemsSet.has(id)){
                selectedItemsSet.delete(id);
            }
        });

        // this.displayContacts.forEach(contactRecord => {
        //     if(selectedItemsSet.has(contactRecord.Id)){
        //         selectedItemsObjSet.add(contactRecord);
        //     }
        // });
        this.alternateContacts.forEach(ACR => {
            if(selectedItemsSet.has(ACR.ContactId)){
                selectedItemsObjSet.add(ACR.Contact);
            }
        })

        // this.alternateContacts.map(ACR => {
        //     if(selectedItemsObjSet.has(ACR.Contact)){
        //         selectedItemsObjSetList.add(ACR);
        //     }
        // });

        this.alternateContacts.map(ACR => {
            if(selectedItemsSet.has(ACR.ContactId)){
                selectedItemsObjSetList.add(ACR);
            }
        })

        this.selection = [...selectedItemsSet];
        this.selectedContactsToAdd = [...selectedItemsObjSet];
        this.selectedContactsToAddList = [...selectedItemsObjSetList];
        log('---Selection---'+JSON.stringify(this.selection));
        log('---Selection Object---'+JSON.stringify(this.selectedContactsToAdd));
        log('---Current Data---'+JSON.stringify(this.selectedContactsToAddList));
        this.selectedContact = this.selection.length;

        if(this.selectedContact == 0){
            this.buttonLabel = 'Skip for now';
        } else {
            this.buttonLabel = 'Proceed';
        }
    }

    onHandleSort(event) {
        log('onHandleSort');
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.contacts];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contacts = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        //  log('onHandleSort',this.openCases);
    }

    sortBy(field, reverse, primer) {
        //log('sortBy',field);
        const key = primer
            ? function (x) {
                return primer(x.Contact[field]);
            }
            : function (x) {
                return x.Contact[field];
            };

        return function (a, b) {
            a = typeof(key(a))==="string" ? key(a).toLowerCase() : key(a);
            b = typeof(key(b))==="string" ? key(b).toLowerCase() : key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    makeSelectedRowPersistance(){
        /*let updated = true;
        if (this.allContactsToAdd.length > 0){
            for(let contacts in this.allContactsToAdd){
                if (this.allContactsToAdd[contacts].pagenumber == this.page){
                    this.allContactsToAdd[contacts].selectedRows = this.contactsToAdd;
                    updated = false;
                }
            }
        }
        if (updated && this.contactsToAdd.length > 0){
            let pageselectedcontact = {
                pagenumber : this.page,
                selectedRows : this.contactsToAdd
            }
            this.allContactsToAdd.push(pageselectedcontact);
        }
        this.flatAllContactToAdd();

        this.preselectedContacts = [...this.finalContactList].map(record => {
            return record.ContactId;
        });*/
        //this.customData = {finalContactList: this.finalContactList, allContactsToAdd: this.allContactsToAdd};
        //this.customData = {finalContactList: this.selectedContactsToAdd, allContactsToAdd: this.selectedContactsToAdd};
        this.customData = {finalContactList: this.selectedContactsToAddList};
        log('custom Data: '+JSON.stringify(this.customData));
    }
    
    proceed(){
        log('event called-->')
        this.makeSelectedRowPersistance();
        const clickEvent = new CustomEvent('proceed', { detail: this.customData, bubbles: true });
        // Dispatches the event.
        this.dispatchEvent(clickEvent);
        log('called Now--->');
    }

    goToPreviousStep(){

        log('event called-->')
        this.makeSelectedRowPersistance();

        const clickEvent = new CustomEvent('goback', { detail: this.customData, bubbles: false });
        // Dispatches the event.
        this.dispatchEvent(clickEvent);
    }

    cancelProcess(){
        //Go to the cancel Process
        const cancelEvent = new CustomEvent('cancel', { detail: '', bubbles: true });
        // Dispatches the event.
        this.dispatchEvent(cancelEvent);
    }

    openModal() {
        this.isModalOpen = true;
        document.body.classList += ' modal-open';

    }
    closeModal() {
        this.isModalOpen = false;
        document.body.classList -= ' modal-open';
    }
    submitDetails() {
        this.isModalOpen = false;
        document.body.classList -= ' modal-open';
    }

    handleNewContacts(){
        log('refreshContact- '+this.selectedAccount);

        getAccountRelatedContacts({recordId: this.selectedAccount})
        .then(result => {
            this.relatedContacts = result;
            /* this.alternateContacts  = [...this.relatedContacts].map(record => {
                return record.Contact;
            }); */
            this.alternateContacts = this.relatedContacts;
            this.allContacts = this.relatedContacts.length;
            this.contacts = this.alternateContacts;
            this.isModalOpen = false;

            //re-render pagination start & end records count
            if(this.items<=0){            
                this.items = this.contacts;
                log('this.items.length : ' + this.items.length);
                this.endingRecord =  this.items.length; // this.pageSize;
            }
            this.endingRecord = this.endingRecord == 0 || this.endingRecord > 0 ? ((this.contacts.length < this.pageSize) ? this.contacts.length : this.pageSize) : this.endingRecord ;
            this.totalRecountCount = this.contacts.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 

            log('RefreshedContacts= '+JSON.stringify(this.relatedContacts));
        });
    }

    handleSearchText(event) {
        var searchText = event.target.value;
        if (searchText.length >= 3) {
            var filteredRecords = [];
            for (var index in this.alternateContacts) {
                var record = this.alternateContacts[index];
                let value = JSON.stringify(record);
                if (value && value.length > 0 && value.toLowerCase().includes(searchText.toLowerCase())) {
                    filteredRecords.push(record);
                }
            }
            //Amarender -> I2RT-3050
            this.endingRecord = filteredRecords.length < this.pageSize ? filteredRecords.length : this.pageSize ;                       //Amarender -> I2RT-3050
            this.contacts = filteredRecords;
        } else {
            //Amarender -> I2RT-3050
            this.endingRecord = this.alternateContacts.length < this.pageSize ? this.alternateContacts.length : this.pageSize ;         //Amarender -> I2RT-3050
            this.contacts = this.alternateContacts;
        }
        this.getSelectRows(this.selectedContactsToAdd);
    }

    makeRowsPersisted(step){
        /*log('preselectedcontacts -> '+JSON.stringify(this.preselectedContacts));
        this.template.querySelector('lightning-datatable').selectedRows = this.preselectedContacts;
        let updated = true;
        if (this.allContactsToAdd.length > 0){
            for(let contacts in this.allContactsToAdd){
                if (this.allContactsToAdd[contacts].pagenumber == this.page + step){
                    this.allContactsToAdd[contacts].selectedRows = this.contactsToAdd;
                    updated = false;
                }
            }
            log("allContactsToAdd4", this.allContactsToAdd);
        }
        if (updated && this.allContactsToAdd.length > 0){
            let pageselectedcontact = {
                pagenumber : this.page + step,
                selectedRows : this.contactsToAdd
            }
            this.allContactsToAdd.push(pageselectedcontact);
            log("allContactsToAdd5  ", this.allContactsToAdd);
        }
        this.preselectedContacts = [...this.finalContactList].map(record => {
            return record.ContactId;
        });*/
        this.template.querySelector('lightning-datatable').selectedRows = this.selection;
    }

     //clicking on first  button this method will be called
     firstHandler() {
        this.startingRecord = 1;
        this.page = 2;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
            this.makeRowsPersisted(0);
        }
    }
    //clicking on last button this method will be called
    lastHandler() {
        this.page = this.totalPage;
        if (this.page > 1) {
            this.displayRecordPerPage(this.page);
            this.makeRowsPersisted(0);
        }
    }
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
            this.makeRowsPersisted(1);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
            this.makeRowsPersisted(-1);
        }
    }
    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = this.alternateContacts.length < this.pageSize ? this.alternateContacts.length : (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.startingRecord = this.startingRecord + 1;
        log("page switched 5", this.startingRecord);

        // return getAlternateContacts();
    }

    get getAlternateContacts() {
        log("page switched");
        this.items=this.contacts;
        if(this.allContacts.length<=0){
            this.allContacts=this.alternateContacts.length;
            log("page switched 1", this.allContacts);

        }
        if(this.startingRecord>1){
            this.displayContacts= this.items.slice((this.startingRecord-1),this.endingRecord); 
            log("page switched 2", this.displayContacts);

        }else{
            this.displayContacts= this.items.slice(0,this.pageSize); 
            log("page switched 3", this.displayContacts);
        }
        
        this.displayContacts = [...this.displayContacts].map(record =>{
            return record.Contact;
        });
        log("page switched 4", this.displayContacts);

         return this.displayContacts;
     }

     flatAllContactToAdd(){
        /*this.finalContactList = [];
        log("allContactsToAdd8", this.allContactsToAdd);
        for (let contact in this.allContactsToAdd){
            this.finalContactList.push(...this.allContactsToAdd[contact].selectedRows);
        }
        log("final", this.finalContactList);*/
    }
}