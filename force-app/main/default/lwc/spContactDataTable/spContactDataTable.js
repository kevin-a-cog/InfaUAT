import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
//import getContacts from '@salesforce/apex/spTest.getContactData';
import fetchPlanRelatedContact from '@salesforce/apex/spContactDataTableController.fetchPlanRelatedContact';
import CreateNewContact from '@salesforce/apex/spContactDataTableController.CreateNewContact';
import updateContact from '@salesforce/apex/spContactDataTableController.updateContact';
import getPCRecords from '@salesforce/apex/spContactDataTableController.getPCRecords';



import removePlanContactController from '@salesforce/apex/spContactDataTableController.removePlanContact';
//import getRecordsDeleted from '@salesforce/apex/spContactDataTableController.getRecordsDeleted';

//Custom label
import Loading from '@salesforce/label/c.Loading';
//Utilities.
import { objUtilities } from 'c/globalUtilities';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
const actions = [
    { label: 'Edit', iconName: 'utility:edit', name: 'edit' },
    { label: 'Delete', iconName: 'utility:delete', name: 'delete' }
];

const columns = [
    { label:'Name', fieldName: 'Contact__rName',  sortable:true, hideDefaultActions: true },
    { label: 'Email Address', fieldName: 'Contact__rEmail',  sortable:true, hideDefaultActions: true },
    { label: 'Role', fieldName: 'Role__c', sortable:true, hideDefaultActions: true },
    { label: 'Phone Number', fieldName: 'Contact__rPhone', sortable:true, hideDefaultActions: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];

const RW_CONTACTLIMIT = 'Max Read/Write contacts limit reached';
const DEFAULT_ERR_MESSAGE = 'An error occurred while creating contact.';
const DUPLICATEERRMSG = 'Contact already exist in the system'; 
const DUPLICATECASECON = 'Contact is added to plan already';


export default class SpContactDataTable extends LightningElement {
    @track allRecords; //All data available for data table  
    @track disableConfirmButton = true;
    @track buttonCss = 'es-button es-button--secondary'; 
    @track isEditContact = false;
    error;
    columns = columns; 
    showTable = false; //Used to render table after we get the data from apex controller    
    recordsToDisplay = []; //Records to be displayed on the page
    rowNumberOffset; //Row number
    preSelected = [];
    selectedRows;
    @api planRecordId;
    @api accountid;
    
    contactfname = '';
    contactlname = '';    
    contactEmail = '';
    contactRole = '';
    contactPhone = '';

    ContactDetail;
    contactname;

    selectedPlanDelId;
    editContactId = '';
    editPlanContactId;
    isLoadingSpinner;
    label = {
		Loading
	}
    
    @track wiredConList = [];
    @api bhasEditAccess = false;   

    

    // for global data table 
    //Feature Configuration.
   /* @track
	 objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: 'Global Contact Table'	,
		strSearchPlaceholder: 'Search Global Contact',
        strTableClass: "spPlanContactTable",
		strTableId: "1",			
			lstActionButtons: [{
				strId: "1",
				strVariant: "Neutral",
				strLabel: 'Cancel',
				title: 'Cancel',
				strStyleClasses: "slds-var-m-left_x-small"
			}, {
				strId: "2",
				strVariant: "Brand",
				strLabel: 'Remove',
				title: 'Remove',
				strStyleClasses: "slds-var-m-left_x-small"
			}]
	}
 
    loadRecords() {
		let objParent = this;
		//Now we fetch the data.
		getPCRecords({
			strRecordId: this.planRecordId
		}).then((objResult) => {
			//We build the tables.
			objParent.objConfiguration.lstRecords = objResult.lstRecords;
			objParent.objConfiguration.lstColumns = objResult.lstColumns;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.isLoadingSpinner = false;
		});
	}


*/
    connectedCallback(){
        console.log('spContactDataTable planRecordId ==> ' + this.planRecordId); 
        //this.isLoadingSpinner=true;
        this.fetchContactHelper();
        //this.loadRecords();
       
    }

    	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	
	refreshCard(objEvent) {
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}
        let searchObj  = this.template.querySelector('.searchField');        
        this.isLoadingSpinner = true;
        if(objUtilities.isNotNull(searchObj)){            
            searchObj.value="";
        }
		this.loadRecords();
		return false;
	} */

    	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	
	searchRecord(objEvent) {
		let objParent = this;
        objParent.template.querySelector('.' + objParent.objConfiguration.strTableClass).searchRecord(objEvent);
	}
 */
     /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 
     selectRecords(objEvent) {
		this.objConfiguration.lstSelectedRecords=objEvent.detail.selectedRows;
    }
*/
    	/*
	 Method Name : handleCancel
	 Description : This method removes the Action panels from the UI.
	 Parameters	 : None
	 Return Type : None
	 
     handleCancel() {
		let objParent = this;
		objParent.template.querySelector('.' + objParent.objConfiguration.strTableClass).hideActions();
     }*/
    /*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;
		let objParent = this;
		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {
					//User wants to cancel the table selection.
					case "1":
					case "3":
						this.handleCancel();
					break;

					//User wants to remove a record.
					case "2":
						this.removeRecords();
					break;					
				}
			break;
			case 3:
                //Place holder for Inline editing if required				
				//First we prepare the data (inline editing).
				if(objUtilities.isNotNull(objPayload) && objPayload.length > 0) {
					
				}
			break;
		}
    }
*/
    /*
	 Method Name : removeRecords
	 Description : This method deletes the selected records.
	 Parameters	 : None
	 Return Type : None
	 
     removeRecords() {
		let objParent = this;
		let objSource;
		let lstRecords = new Array();
		//First we create the list of unique ids.
		objSource = objParent.objConfiguration.lstSelectedRecords;
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});

		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}
*/

   /* @wire(fetchPlanRelatedContact, { planId: '$planRecordId' })
    wopps({error,data}){
        this.showTable = false;
        this.allRecords = [];
       
        if(data){
            this.wiredConList = data;
            var parsedata = JSON.parse(JSON.stringify(data));
            let records = [];
            for(let i=0; i<parsedata.length; i++){
                if(parsedata[i].Contact__r != undefined){
                    parsedata[i].Contact__rName = parsedata[i].Contact__r.Name;
                    parsedata[i].Contact__rEmail = parsedata[i].Contact__r.Email;
                    parsedata[i].Contact__rPhone = parsedata[i].Contact__r.Phone;
                }

                let record = {};
                record.rowNumber = ''+(i+1);
                record.caseLink = '/'+parsedata[i].Id;                
                record = Object.assign(record, parsedata[i]);                
                records.push(record);
            }
            console.log('planRecordId====> ' + this.planRecordId);
            console.log('records contact ====> ' + JSON.stringify(records));
            setTimeout(() => {   
                this.allRecords = records;
                this.showTable = true;}, 
                200);
        }else{
            this.error = error;
        }       
    }*/
    get optionsRole() {
        return [
            { label: 'Business Owner', value: 'Business Owner' },
            { label: 'Technical Owner', value: 'Technical Owner' },
            { label: 'Business Contributor', value: 'Business Contributor' },
            { label: 'Technical Contributor', value: 'Technical Contributor' },
            { label: 'Collaborator', value: 'Collaborator' }
        ];
    }

    /*** Add/Edit Contact Modal ***/
    @track isActionContactModal = false;
    @track isDeleteContactModal = false;
    @track rowSelected;
    @track actionSelected;
    openActionContactModal() {
        this.isActionContactModal = true;
        if(this.isEditContact == false){
            this.contactId = '';
            this.contactfname = '';
            this.contactlname = '';            
            this.contactEmail = '';
            this.contactRole = '';
            this.contactPhone = '';
            document.body.classList += ' modal-open';
        }
        /** START-- adobe analytics */
       try {
        util.trackButtonClick("Add Contact Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }
    handleRoleChange(event) {
        this.contactRole = event.detail.value;
    }
    closeActionContactModal() {
        this.isActionContactModal = false;
        this.isEditContact = false;
        this.editContactId = '';
      
        document.body.classList -= ' modal-open';
    }
    openDeleteContactModal() {
        this.isDeleteContactModal = true;
    }
    closeDeleteContactModal() {
        this.isDeleteContactModal = false;
    }


    removePlanContact(){
		let objParent = this;
        removePlanContactController({ planContactId: this.selectedPlanDelId })
        .then((result) => {
            if(result == 'SUCCESS'){
                const event = new ShowToastEvent({
                    title : 'Success',
                    message : 'Delete request has been sent to your CSM successfully.',
                    variant : 'success',
                    mode : 'dismissable'
                });
                this.dispatchEvent(event);
               this.isDeleteContactModal = false;
               this.fetchContactHelper();
            }                
        })
        .catch((objError) => {
			objUtilities.processException(objError, objParent);
        })
    }


    dataChangeHandler(event){
        var whichFld = event.target.name;
        var sData = event.target.value;
        if(whichFld == 'fname'){
            this.contactfname = sData;
        }
        else if(whichFld == 'lname'){
            this.contactlname = sData;
        }
        else if(whichFld == 'email'){
            this.contactEmail = sData;
        }
        else if(whichFld == 'phone'){
            this.contactPhone = sData;
        }        
    }


    /*** Edit/Delete Contact Modal ***/
    handleEditDelete(event) {
        this.rowSelected = event.detail.rowValue;
        this.actionSelected = event.detail.actionValue;
        console.log('Main Row'+JSON.stringify(this.rowSelected));
        switch (this.actionSelected.name) {
            case 'edit':
            if(!this.bhasEditAccess){
                const event = new ShowToastEvent({
                    title : 'Error',
                    message : 'You do not have permissions to modify this record.',
                    variant : 'error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(event);
                return;
            }    
            this.isEditContact = true;
            console.log('this.rowSelected==> ' + JSON.stringify(this.rowSelected));
            this.contactId = this.rowSelected.Id;
            /*this.contactName = this.rowSelected.Name;
            this.contactPhone = this.rowSelected.Phone;
            this.contactRole = this.rowSelected.Level__c;
            this.contactEmail = this.rowSelected.Email;*/
            console.log('this.allRecords==> ' + JSON.stringify(this.allRecords)); 
            this.contactfname = this.rowSelected.Contact__rFirstName;
            this.contactlname = this.rowSelected.Contact__rLastName;
            this.contactPhone = this.rowSelected.Contact__rPhone;
            this.contactRole = this.rowSelected.Role__c;
            this.contactEmail = this.rowSelected.Contact__rEmail;
            this.editContactId = this.rowSelected.Contact__c; 
            this.editPlanContactId = this.rowSelected.Id; 
            this.openActionContactModal();
            break;
            
            case 'delete':
                if(!this.bhasEditAccess){
                    const event = new ShowToastEvent({
                        title : 'Error',
                        message : 'You do not have permissions to modify this record.',
                        variant : 'error',
                        mode : 'dismissable'
                    });
                    this.dispatchEvent(event);
                    return;
                } 
            this.selectedPlanDelId = this.rowSelected.Id; 
            this.contactname= this.rowSelected.Contact__rFirstName +' '+this.rowSelected.Contact__rLastName ;
            console.log('Contact Name-->'+this.contactname);
            this.openDeleteContactModal();                                   
        }
    }

 
    submitUpdateHelper(){
        this.isLoadingSpinner = true;
        if(this.contactfname == '' || this.contactlname == '' ||this.contactEmail == '' || this.contactPhone == '' || this.contactRole == '' ){
            const event = new ShowToastEvent({
                title : 'Error',
                message : 'Required Fields Missing.',
                variant : 'error',
                mode : 'dismissable'
            });
            this.dispatchEvent(event);
            this.isLoadingSpinner = false;
           return;
        }

        let fields = { 
            'FirstName' : this.contactfname,
            'LastName' : this.contactlname,
            'Email' : this.contactEmail,
            'Phone' : this.contactPhone,
            'Id' : this.editContactId
           }
        this.ContactDetail = JSON.stringify(fields); 
        console.log('contact fields -->'+JSON.stringify(fields));
        updateContact({ 'ContactRec': this.ContactDetail, 'SupportAccountId': this.accountid, 'planId': this.planRecordId, 'planContactRole' : this.contactRole, 'planContactId' : this.editPlanContactId })
        .then((result) => {  
            this.isLoadingSpinner = false;              
            console.log('result ' + JSON.stringify(result));
               var res = JSON.stringify(result) ;                                  
                const event = new ShowToastEvent({
                    title : 'Success',
                    message : res,
                    variant : 'success',
                    mode : 'dismissable'
                });
                this.dispatchEvent(event);
                this.isActionContactModal = false;
                refreshApex(this.wiredConList);
                this.fetchContactHelper();

            
         ////   this.dispatchEvent(new CustomEvent('addnewcontact', { detail: this.result })); //Send records to display on table to the parent component
            this.isCreateNewContact = false;
            document.body.classList -= ' modal-open';
            this.closeActionContactModal();

        })
        .catch((error) => {
            console.log(JSON.stringify(error));  
            this.isLoadingSpinner = false;
            let errorMessage;            
            errorMessage = 'There is an issue is in updating the contact - please reach out to your CSM for further help on this.';            
            const event = new ShowToastEvent({
                title : 'Error',
                message : errorMessage,
                variant : 'error',
                mode : 'dismissable'
            });
            this.dispatchEvent(event);
        })
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail.recordsToDisplay;
        this.preSelected = event.detail.preSelected;
        if(this.recordsToDisplay && this.recordsToDisplay > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        }else{
            this.rowNumberOffset = 0;
        } 
    }    

        submitContactHandler(){
            this.isLoadingSpinner = true;
            // this.isCreateNewContact = false;
            console.log('handleSubmit: ');
            console.log('contactRole===> ' + this.contactRole);
            if(this.contactfname == '' || this.contactlname == '' ||this.contactEmail == '' || this.contactPhone == '' || this.contactRole == '' ){
                const event = new ShowToastEvent({
                    title : 'Error',
                    message : 'Required Fields Missing.',
                    variant : 'error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoadingSpinner = false;
               return;
            }
            let fields = { 
                            'FirstName' : this.contactfname,
                            'LastName' : this.contactlname,
                            'Email' : this.contactEmail,
                            'Phone' : this.contactPhone,
                           }
            this.ContactDetail = JSON.stringify(fields); 
            console.log('contact fields -->'+JSON.stringify(fields));
            
            CreateNewContact({ ContactRec: this.ContactDetail, SupportAccountId: this.accountid, planId: this.planRecordId, planContactRole : this.contactRole })
                .then((result) => {  
                    this.isLoadingSpinner = false;              
                    var str1 = 'CONTACTPRESENT';
                    var str2 = 'DUPLICATE';
                    console.log('result ' + JSON.stringify(result));
                    var res = JSON.stringify(result) ;                      
                    var compareOne = result.localeCompare(str1);
                    var compareTwo = result.localeCompare(str2)
                    console.log('compareOne ' + result.localeCompare(str1));
                    console.log('compareTwo ' + result.localeCompare(str2));
                    if(compareOne === 0 ||compareTwo === 0 || res.includes("DUPLICATES_DETECTED")){                    
                        const event = new ShowToastEvent({
                            title : 'Error',
                            message : 'Contact already exist in the system',
                            variant : 'error',
                            mode : 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }             
                    if(res.includes(DUPLICATECASECON)){
                        const event = new ShowToastEvent({
                            title : 'Error',
                            message : 'Contact already exist on the plan',
                            variant : 'error',
                            mode : 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }           
                    console.log('res===> ' + res);
                    if(res == '"Contact is added to Plan successfully"'){
                        const event = new ShowToastEvent({
                            title : 'Success',
                            message : res,
                            variant : 'success',
                            mode : 'dismissable'
                        });
                        this.dispatchEvent(event);

                        refreshApex(this.wiredConList);
                        this.fetchContactHelper();

                    }
                 ////   this.dispatchEvent(new CustomEvent('addnewcontact', { detail: this.result })); //Send records to display on table to the parent component
                    this.isCreateNewContact = false;
                    document.body.classList -= ' modal-open';
                    this.closeActionContactModal();
    
                })
                .catch((error) => {
                    
                    console.log(JSON.stringify(error));  
                    this.isLoadingSpinner = false;
                    let errorMessage;
                    if(error.body.message != undefined && error.body.message.includes(RW_CONTACTLIMIT)){
                        errorMessage = RW_CONTACTLIMIT;
                    }
                    else if(error.body.message != undefined && error.body.message.includes(DUPLICATEERRMSG)){
                        errorMessage = DUPLICATEERRMSG;
                    }
                    else if(error.body.message != undefined && error.body.message.includes("Please enter valid Email")){ //added as part of AR-2754 updated email
                        errorMessage = error.body.message;
                    }
                  /*  else if(error.body.message != undefined && error.body.message.includes(POTENTIAL_DUPLICATE)){
                        errorMessage = POTENTIAL_DUPLICATE;
                    }*/
                    else{
                        errorMessage = DEFAULT_ERR_MESSAGE;
                    }
                    const event = new ShowToastEvent({
                        title : 'Error',
                        message : errorMessage,
                        variant : 'error',
                        mode : 'dismissable'
                    });
                    this.dispatchEvent(event);
                })
                /** START-- adobe analytics */
                try {
                util.trackButtonClick("Add Contact Confirm");
                }
                catch(ex) {
                    log(ex.message);
                }
                /** END-- adobe analytics*/
            }


       @api fetchContactHelper(){
           let objParent = this;
           objParent.isLoadingSpinner=true;
            fetchPlanRelatedContact({ planId: this.planRecordId })
            .then(data => {
                this.showTable = false;
                this.allRecords = [];               
                
                    this.wiredConList = data;
                    var parsedata = JSON.parse(JSON.stringify(data));
                    let records = [];
                    for(let i=0; i<parsedata.length; i++){
                        if(parsedata[i].Contact__r != undefined){
                            parsedata[i].Contact__rName = parsedata[i].Contact__r.Name;
                            parsedata[i].Contact__rEmail = parsedata[i].Contact__r.Email;
                            parsedata[i].Contact__rPhone = parsedata[i].Contact__r.Phone;
                            parsedata[i].Contact__rFirstName = parsedata[i].Contact__r.FirstName;
                            parsedata[i].Contact__rLastName = parsedata[i].Contact__r.LastName;
                        }
        
                        let record = {};
                        record.rowNumber = ''+(i+1);
                        record.caseLink = '/'+parsedata[i].Id;                
                        record = Object.assign(record, parsedata[i]);                
                        records.push(record);
                    }
                    console.log('planRecordId====> ' + this.planRecordId);
                    console.log('records contact ====> ' + JSON.stringify(records));
                    setTimeout(() => {   
                        this.allRecords = records;
                        this.showTable = true;}, 
                        200);
                     
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                //Finally, we hide the spinner.
                objParent.isLoadingSpinner = false;
            });
        }
}