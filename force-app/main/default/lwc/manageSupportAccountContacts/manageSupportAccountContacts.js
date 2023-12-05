/*
 * Name         :   manageSupportAccountContacts
 * Author       :   Venky
 * Created Date :   07-JAN-2021
 * Description  :   

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Venky                  07-JAN-2021     UTOPIA              Initial version.                                          NA
 Vignesh D              16-NOV-2021     UTOPIA-FF1          Error Handling on removing ACR from Support Account       T01
 Vignesh D              03-MAR-2022     I2RT-5410           Show actions only for user with GCS Admin permission      T02
 balajip                22-FEB-2023     I2RT-7659           to capture Language while added Contact to Account        T03
 */

import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getUnassignedContacts from "@salesforce/apex/manageSupportAccountContacts.getUnassignedContacts";
import getAccountContactRelation from "@salesforce/apex/manageSupportAccountContacts.getAccountContactRelation";
import removeAccountContactRelation from "@salesforce/apex/manageSupportAccountContacts.removeAccountContactRelation";
import CreateNewContact from "@salesforce/apex/manageSupportAccountContacts.CreateNewContact";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCOUNT from "@salesforce/schema/Account.ParentId";
import MAXREADWRITE from "@salesforce/schema/Account.Max_Customer_R_W_Contacts__c";
import BILLSTREET from "@salesforce/schema/Account.BillingStreet";
import PARENTBILLSTREET from "@salesforce/schema/Account.Parent.BillingStreet";
import BILLCITY from "@salesforce/schema/Account.Parent.BillingCity";
import BILLSTATE from "@salesforce/schema/Account.Parent.BillingState";
import BILLPOSTALCODE from "@salesforce/schema/Account.Parent.BillingPostalCode";
import BILLCOUNTRY from "@salesforce/schema/Account.Parent.BillingCountry";
import Id from "@salesforce/schema/Account.Id";
import {loadStyle} from 'lightning/platformResourceLoader';
import myStaticResource from '@salesforce/resourceUrl/manageaccountcontact';
import checkUserPermission from '@salesforce/apex/manageSupportAccountContacts.checkUserPermission'; // <T02>

//Custom Labels
import POTENTIAL_DUPLICATE from '@salesforce/label/c.Potential_Duplicate_Lead_Validation_Message';

//import PARTNER_RELATIONSHIP from "@salesforce/schema/Account.Parent.Partner_Account__c";
//import PTR_ACCOUNT from "@salesforce/schema/Account.Parent.Partner_Account__r.Partner_Account__c";

/* Utilities */
import { log,objUtilities } from 'c/globalUtilities';

const fields = [Id,ACCOUNT,MAXREADWRITE,BILLSTREET,BILLCOUNTRY,BILLPOSTALCODE,BILLSTATE,BILLCITY, PARENTBILLSTREET];
const CONTACT_OBJ = 'Contact';
const ASSIGNED_CONTACTS = "Assigned";
const UNASSIGNED_CONTACTS = "Unassigned";
const PARTNER_ACCOUNT = "Partner Account";
const DUPLICATE = 'Duplicate Contact is present in system';
const CONPRESENT = 'Contact is present in support Account';
const tabsObj = [
  {
    tab: ASSIGNED_CONTACTS,
    helpText: "",
    fieldSet: 'Assigned_Contacts'
  },
  {
    tab: UNASSIGNED_CONTACTS,
    helpText: "",
    fieldSet: 'UnAssigned_Contacts'
  }
];

const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
];

export default class ManageSupportAccountContacts extends NavigationMixin(LightningElement) {

    @api recordId;
    @track tabs = tabsObj;
    @track defaultTabOnInitialization = ASSIGNED_CONTACTS;
    @track currentTabValue;
    @track columns;
    @track fieldApiNames = [];
    @track lookupFields = [];
    @track draftValues  =[];
    @track data;
    @track dataToShow = [];
    @track maxrows;
    @track NoDataAfterRendering = false;
    @track displayDataTableFooter = false;
    @track displaycancel = false;
    @track showErrorMessage;
    @track displayRemoveBTN = false;
    @track displayAddBTN = false;
    @track displaysave =false;
    @track totalPages =0;
    @track currentPage = 1;
    @track nextPage = 0;
    AllDataCount = 0;
    pageSize = 10;
    searchTerm = '';
    nextClass = false;
    showPrev = false;
    //@track isLoading = false;
    @track isGCSAdmin = false; // <T02>

     //have this attribute to track data change
    @track draftValues = [];
    lastSavedData = [];
    selectedRow = [];
    selectedRecordsList = [];
    
    @track selectedAccountId ;
    @track sortBy;
    @track sortDirection;

    @track isShowModal = false;
    @track headerValue;
    @track isCreateNewACR;
    @track isCreateNewContact;
    @track defaultValAccount;
    @track defaultValContact;
    defaultValContactLang; //T03
    @track isLoadingSpinner;
    @track successMessage;
    
    //[Vignesh D: added public property to show popout modal]
    @api showpopicon = false;
    @track showPopOut = false;

    settings = {
        fieldNameContactName: "__ContactName",
        fieldNameContactURL: "__ContactRecordURL",
        fieldNameAccountName: "__AccountName",
        fieldNameAccountURL: "__AccountRecordURL"
    }
    
    COL_ASSIGNED = [
        {
            label: "Contact",
            fieldName: this.settings.fieldNameContactURL,
            type: "url",
            sortable: true,
            typeAttributes: {
              label: { fieldName: this.settings.fieldNameContactName },
              target: "_self"
            },
            wrapText: true
        },
        {
            label: "Primary Contact",
            fieldName: "Primary__c",
            type: "boolean",
            sortable: true,
           // editable :true
        },
        {
            label: "Access",
            fieldName: "Access_Level__c",
            type: "text",
            sortable: true,
           // wrapText: true

        },    
        {
            label: "Email",
            fieldName: "ContactEmail",
            type: "email",
            sortable: true,
           // wrapText: true
            
        },
    
        {
            label: "Phone",
            fieldName: "ContactPhone",
            type: "text",
            sortable: true,
          //  wrapText: true
        },
        /*
        {
            label: "Roles",
            fieldName: "Roles",
            type: "text",
            sortable: true,
           // wrapText: true

        },*/
        {
            label: "Timezone",
            fieldName: "Contact_Timezone__c",
            type: "text",
            sortable: true,
           // wrapText: true

        },
        {
            label: "Account",
            fieldName: this.settings.fieldNameAccountURL,
            type: "url",
            sortable: true,
            typeAttributes: {
              label: { fieldName: this.settings.fieldNameAccountName },
              target: "_self"
            },
            wrapText: true
        },
        /*{
            label: "Active",
            fieldName: "IsActive",
            type: "boolean",
            sortable: true,
            //editable :true
        },*/
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        }

 
    ];


    COL_UNASSIGNED = [
        {
            label: "Contact",
            fieldName: this.settings.fieldNameContactURL,
            type: "url",
            sortable: true,
            typeAttributes: {
              label: { fieldName: this.settings.fieldNameContactName },
              target: "_self"
            }
        },
    
        {
            label: "Account",
            fieldName: this.settings.fieldNameAccountURL,
            type: "url",
            sortable: true,
            typeAttributes: {
              label: { fieldName: this.settings.fieldNameAccountName },
              target: "_self"
            }
        },
    
        {
            label: "Email",
            fieldName: "Email",
            type: "email",
            sortable: true,
            
        },

        {
            label: "Phone",
            fieldName: "Phone",
            type: "text",
            sortable: true,
            
        }
    ];

    connectedCallback() {
        //---------------------------------------<T02>-------------------------------
        let objParent = this;

        checkUserPermission()
        .then((result) => {
            objParent.isGCSAdmin = result;
        })
        .catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
        //---------------------------------------</T02>------------------------------
        
    }
    renderedCallback() {
        loadStyle(this, myStaticResource);
    }

    @wire(getRecord, { recordId: "$recordId", fields })
    supportAccount;

    getRecordURL(sObject, Id) {
        return "/lightning/r/" + sObject + "/" + Id + "/view";
    }

    //New Contact creation
    createContactWithDefaultValues() {
        this.isShowModal = true;
        this.isCreateNewContact = true;
        this.headerValue = 'New Contact: Customer Contact';
        this.defaultValAccount =  getFieldValue(this.supportAccount.data, ACCOUNT);
        this.successMessage = 'Contact has been created successfully!';
    }

    //New Account contact relation
    createACRWithDefaultValues() {
        this.isShowModal = true;
        this.isCreateNewACR = true;
        this.headerValue = 'New Account Contact Relationship';
        
        this.defaultValContact = this.selectedRow[0].Id;
        this.defaultValContactLang = this.selectedRow[0].Lang; //T03
        
        this.successMessage ='Account Contact Relationship has been created successfully!';
        this.template.querySelector('lightning-tabset').activeTabValue = 'Assigned';
    }

    handleOnLoad(event){
        //log('this.supportAccount.data.fields--->',this.supportAccount.data.fields.Parent.value.fields.BillingStreet.value);
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                    if(field.fieldName == 'MailingStreet'){
                        field.value = this.supportAccount.data.fields.Parent.value.fields.BillingStreet.value;
                    }
                    if(field.fieldName == 'MailingState'){
                        field.value = this.supportAccount.data.fields.Parent.value.fields.BillingState.value;
                    }
                    if(field.fieldName == 'MailingCity'){
                        field.value = this.supportAccount.data.fields.Parent.value.fields.BillingCity.value;
                    }
                    if(field.fieldName == 'MailingPostalCode'){
                        field.value = this.supportAccount.data.fields.Parent.value.fields.BillingPostalCode.value;
                    }
                    if(field.fieldName == 'MailingCountry'){
                        field.value = this.supportAccount.data.fields.Parent.value.fields.BillingCountry.value;
                    }
               });
        }
        /*var fields = record[this.recordId].fields;
        log('@@@----2-->>>>>', fields);
        fields.MailingState.value = 'California';
        log('@@@----3-->>>>>',fields.MailingStreet.value);*/
    }
    //New Contact creation
    handleNewContactSubmit(event){
        this.isLoadingSpinner = true;
        //log('handleNewContactSubmit: ' + JSON.stringify(event.detail.fields));
        event.preventDefault();
        const fields = event.detail.fields;
        this.ContactDetail = JSON.stringify(fields);
        CreateNewContact({ ContactRec: this.ContactDetail, SupportAccountId: this.recordId })
            .then((result) => {
                //log('result ' + JSON.stringify(result));
                //KG to handle duplicates
                if(result != undefined && (result.indexOf('Duplicate') > -1 || result.includes(CONPRESENT))){
                    //log('in it');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Contact already exists in the system',
                            variant: "error",
                            mode: 'dismissable'
                        })
                    );
                    this.isLoadingSpinner = false;
                }
                else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: this.successMessage,
                        variant: "success"
                    })
                    );
                    this.hideModalBox();
                    this.currentTabValue == ASSIGNED_CONTACTS;
                    return this.handleRefresh();
                }
            })
            .catch((error) => {
                let errorMessage = error.body.message;
                let errorMsg = 'Max Read/Write contacts limit';
                let duplicateError = 'DUPLICATES_DETECTED';
                let potentialDuplicateError = POTENTIAL_DUPLICATE;
                if(errorMessage.includes(errorMsg)){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Max Read/Write contacts limit reached.',
                            variant: "error",
                            mode: 'dismissable'
                        })
                    );
                    this.hideModalBox();
                }
                if(errorMessage.includes(duplicateError)){ //KG 3798
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: 'Contact already exists in the system',
                            variant: "error",
                            mode: 'dismissable'
                        })
                    );
                    this.hideModalBox();
                }
                if(errorMessage.includes(potentialDuplicateError)){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: potentialDuplicateError,
                            variant: "error",
                            mode: 'dismissable'
                        })
                    );
                    this.hideModalBox();
                }
                //log(JSON.stringify(error));
            })
    }

    //Handle Submit for ACR
    handleSubmit(event){
        this.isLoadingSpinner = true;
        //log(JSON.stringify(event.detail.fields));
    }

    //Handle Submit for ACR
    handleContactSubmit(event){
        this.isLoadingSpinner = true;
        //log('handleNewACRSubmit: ' + JSON.stringify(event.detail.fields));
    }

    //Handle Error for ACR/Contact Creation
    handleError(event){
        this.isLoadingSpinner = false;
    }

    //Handle Success for ACR/Contact Creation
    handleSucess(event){               
        //log('New Record Id : '+ event.detail.id);
        this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: this.successMessage,
              variant: "success"
            })
          );
          this.hideModalBox();
          this.currentTabValue = ASSIGNED_CONTACTS;
          return this.handleRefresh();
    }    

    //Hide the Modal section
    hideModalBox() {  
        this.isShowModal = false;
        this.isCreateNewACR = false;
        this.isCreateNewContact = false;
        this.isLoadingSpinner = false;
        this.headerValue = 'New Record';
        this.successMessage ='New Record Created successfully!';
    }

    //handle tab selection
    handleActiveTab(event) {
        this.currentTabValue = event.target.value;
        this.nextClass = false;
    
        //log('handleActiveTab' + this.currentTabValue);
        this.handleRefresh();
        
    }

    //handle row selected
    handleRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        //log('handleRowSelected: selectedRows = ' + JSON.stringify(selectedRows));

        this.selectedRecordsList = selectedRows;
      //  log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
        this.selectedRow = [];
        for (let i = 0; i < selectedRows.length; i++) {
          this.selectedRow.push({ 
                Id: selectedRows[i].Id,
                Lang: selectedRows[i].INFA_Language__c //T03
            });
        }
       // log("selected row final => " + JSON.stringify(this.selectedRow));
        if (this.selectedRow.length > 0) {
          this.displayDataTableFooter = true;
          this.displaycancel = true;
          //this.displaysave = true;
          this.showErrorMessage = undefined;
        }
    }

    //handler to remove Support Account Contacts from Support Account
    handleRemove(event) {
        let objParent = this;
        const SupportContacts = this.selectedRow;
        //log("**add Support Contacts size = " + SupportContacts.length);
        if(SupportContacts != undefined && SupportContacts.length > 0){
            this.isLoading = true;
            removeAccountContactRelation({ supportContacts: SupportContacts, supportAcc: this.recordId })
            .then((result) => {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Success",
                    message: "Contacts removed from Support Account Successfully",
                    variant: "success"
                  })
                );

                //clear the selected rows
                this.selectedRow = [];

                //hide the datatable footer
                this.displayDataTableFooter = false;               
                this.displaycancel = false;

                this.isLoading = false;

                return this.handleRefresh();
            })
            .catch((objError) => {
                //<T01>
                objUtilities.processException(objError, objParent);
                //</T01>
                this.isLoading = false;
            })
        }
        else{
            this.showErrorMessage = "Please select a Contact to remove from the Support Account";
        }
    }



    //Handler to cancel
    handleCancel(event){
        //hide the datatable footer
        this.displayDataTableFooter = false;
        this.displaycancel = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        //log('Search Term --> '+this.searchTerm);
        this.handleRefresh();
    }

    handleAccountSelcted(event){
        this.selectedAccountId = event.detail;
        //log('handleAccountSelcted -> SelectedAccountId-->'+this.selectedAccountId);
        this.handleRefresh();
    }

    handleIconRefresh(event) {
        this.searchTerm = '';
        this.handleRefresh();
    }


    getRecordURL(sObject, Id) {
        return "/lightning/r/" + sObject + "/" + Id + "/view";
    }

    //handle refresh of the data table
    handleRefresh() {
        this.NoDataAfterRendering = false;
        this.displayDataTableFooter = false;
        this.showErrorMessage = undefined;
        //log('handleRefresh -> SelectedAccountId-->'+this.selectedAccountId);
        //log('handleRefresh -> supportAccount-->'+ JSON.stringify( this.supportAccount));
        //log('handleRefresh -> getfieldvalue-->'+ getFieldValue(this.supportAccount.data, ACCOUNT));

        if(this.selectedAccountId == undefined){
            this.selectedAccountId = getFieldValue(this.supportAccount.data, ACCOUNT);
        }

        if(this.currentTabValue == ASSIGNED_CONTACTS){
            this.columns = this.COL_ASSIGNED;
            this.data = undefined;
            this.maxrows =false;
            //log(`ASSIGNED_CONTACTS -> maxrows-->${this.maxrows}`);

            //log('this.recordId'+this.recordId);
            let SupAcc = getFieldValue(this.supportAccount.data, Id);
            //log('SupAcc'+SupAcc);
            getAccountContactRelation({ searchTerm: this.searchTerm, supportAcc: this.recordId})
                .then((result) => {

                    //log('handleRefresh->  getAccountContactRelation->then ');

                    //Promise for getAssignedSupportContacts()
                    //log(JSON.stringify(result));
                    let tempData = JSON.parse(JSON.stringify(result));

                    if (tempData) {

                        for (let i = 0; i < tempData.length; i++) {
                            //log('tempData before processing ==> ' + JSON.stringify(tempData[i]));
                
                            if(tempData[i].ContactId){
                            tempData[i][this.settings.fieldNameContactName] = tempData[i].Contact.Name;
                            tempData[i][this.settings.fieldNameContactURL] = this.getRecordURL("Contact",tempData[i].ContactId);
                            }
                            //log('tempData before processing ==> ' + JSON.stringify(tempData[i].Contact.Account.Name));

                            if(tempData[i].Contact.Account.Name){
                            tempData[i][this.settings.fieldNameAccountName] = tempData[i].Contact.Account.Name;
                            tempData[i][this.settings.fieldNameAccountURL] = this.getRecordURL("Account", tempData[i].Contact.AccountId);
                            }

                            if(tempData[i].Contact.Email){
                                tempData[i].ContactEmail = tempData[i].Contact.Email;
                            }

                            if(tempData[i].Contact.Phone){
                                tempData[i].ContactPhone = tempData[i].Contact.Phone;
                            }


                        }
        
                        //log('tempData --> '+JSON.stringify(tempData));
                        this.data = tempData; 
                        this.lastSavedData = tempData;
                        this.displayRemoveBTN = true;
                        this.displayAddBTN = false;
                    }
                    else{
                        this.NoDataAfterRendering = true;
                        this.data = undefined;
                    }
                    var newdata = [];
                    var finalPage = 0;
                    this.AllDataCount = this.data.length;
                    if(this.data.length > this.pageSize){
                        finalPage = this.pageSize;
                    }else{
                        finalPage = this.data.length;
                    }
                    this.nextPage = finalPage;
                    for(var i=0; i<finalPage;i++){
                        newdata.push(this.data[i]);
                    }
                    this.nextClass = false;
                    if(this.nextPage >= this.AllDataCount){
                        this.nextClass = true;
                    }
                    this.dataToShow = newdata;
                    this.showPrev = true;
                    this.currentPage = 1;
                })
                .catch((error) => {
                    //log('handleRefresh->  getAccountContactRelation->catch ');
                    //log(JSON.stringify(error));
                })

        }
        else if(this.currentTabValue == UNASSIGNED_CONTACTS){
            this.columns = this.COL_UNASSIGNED;
            this.data = undefined;
            this.maxrows = true;
            //log(`UNASSIGNED_CONTACTS -> maxrows-->${this.maxrows}`);
            //log(`UNASSIGNED_CONTACTS -> SelectedAccountId-->${this.selectedAccountId}`);
            //log('Customer Account'+ JSON.stringify(getFieldValue(this.supportAccount.data, ACCOUNT)))
            let AccountId ='';
            if(String(this.selectedAccountId)){
                AccountId = String(this.selectedAccountId); 
            }
            else{
                AccountId = getFieldValue(this.supportAccount.data, ACCOUNT);
            }
            //log('AccountId'+ AccountId);

            getUnassignedContacts({ searchTerm: this.searchTerm, accountId: AccountId, supportAcc: this.recordId })
                .then((result) => {

                    //log('handleRefresh->  getUnassignedContacts->then ');

                    //Promise for getAssignedSupportContacts()
                    //log(JSON.stringify(result));
                    let tempData = JSON.parse(JSON.stringify(result));

                    if (tempData) {

                        for (let i = 0; i < tempData.length; i++) {
                            //log('tempData before processing ==> ' + JSON.stringify(tempData[i]));
                
                            if(tempData[i].Id){
                            tempData[i][this.settings.fieldNameContactName] = tempData[i].Name;
                            tempData[i][this.settings.fieldNameContactURL] = this.getRecordURL("Contact",tempData[i].Id);
                            }
                            
                            if(tempData[i].AccountId){
                            tempData[i][this.settings.fieldNameAccountName] = tempData[i].Account.Name;
                            tempData[i][this.settings.fieldNameAccountURL] = this.getRecordURL("Account", tempData[i].AccountId);
                            }

                        }
        
                        //log('tempData --> '+JSON.stringify(tempData));
                        this.data = tempData; 
                        
                        this.displayRemoveBTN = false;
                        this.displayAddBTN = true;
                    
                    }
                    else{
                        this.NoDataAfterRendering = true;
                        this.data = undefined;
                    }
                    var newdata = [];
                    var finalPage = 0;
                    this.AllDataCount = this.data.length;
                    if(this.data.length > this.pageSize){
                        finalPage = this.pageSize;
                    }else{
                        finalPage = this.data.length;
                    }
                    this.nextPage = finalPage;
                    for(var i=0; i<finalPage;i++){
                        newdata.push(this.data[i]);
                    }
                    if(this.nextPage >= this.AllDataCount){
                        this.nextClass = true;
                    }
                    this.dataToShow = newdata;
                    this.showPrev = true;
                    this.currentPage = 1;
                })
                .catch((error) => {
                    //Promise for getUnassignedContacts()
                    //log(JSON.stringify(error));
                }) 
        }
    }
    Nextsetofdata(){
        this.showPrev = false;
        var newdata = [];
        this.dataToShow = [];
        var start = this.currentPage + this.pageSize;
        var finalPage = 0;
        finalPage = this.nextPage + this.pageSize;
        if(this.data.length < finalPage){
            finalPage = this.data.length;
        }
        log('@@-finalPage->>',finalPage);
        this.currentPage = this.nextPage ;
        this.nextPage = finalPage;
        
        
        for(var i=this.currentPage; i<this.nextPage;i++){
            newdata.push(this.data[i]);
        }
        //log('@@-finalPage->>',newdata);
        this.currentPage = this.currentPage +1;
        this.nextClass = false;
        if(this.nextPage >= this.AllDataCount){
            this.nextClass = true;
        }
        //log(newdata);
        this.dataToShow = newdata;
    }
    moveToLastPage(){
        this.nextClass = true;
        this.showPrev = false;  
        this.nextPage = this.AllDataCount
        
        this.currentPage = ((this.AllDataCount/this.pageSize)*this.pageSize) ;
        if(this.currentPage >=this.nextPage){
            var mod = this.AllDataCount%this.pageSize;
            if(mod == 0){
                this.currentPage = this.currentPage -this.pageSize;
            }else{
                this.currentPage = this.currentPage -mod;
            }
        }
        var newdata = [];
        this.dataToShow = [];
        for(var i=this.currentPage; i<this.AllDataCount;i++){
            newdata.push(this.data[i]);
        }
        this.currentPage = this.currentPage + 1;
        this.dataToShow = newdata;
    }
    moveToPrevPage(){
        this.nextClass = false;
        var newdata = [];
        this.dataToShow = [];
        this.currentPage = this.currentPage - this.pageSize - 1;
        this.nextPage = this.currentPage + this.pageSize ;
        for(var i=this.currentPage; i<this.nextPage;i++){
            newdata.push(this.data[i]);
        }
        this.currentPage = this.currentPage + 1;
        this.dataToShow = newdata;
        if(this.currentPage == 1){
            this.showPrev = true;
        }
    }
    moveToFirstPage(){
        this.nextClass = false;
        this.showPrev = true;
        this.nextPage = this.pageSize;
        if(this.nextPage > this.AllDataCount){
            this.nextPage = this.AllDataCount;
        }
        this.currentPage = 0;
        var newdata = [];
        this.dataToShow = [];
        for(var i=this.currentPage; i<this.nextPage;i++){
            newdata.push(this.data[i]);
        }
        this.currentPage = this.currentPage + 1;
        this.dataToShow = newdata;
    }
    handleRowAction( event ) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'AccountContactRelation',
                        actionName: 'edit'
                    }
                });
                break;
            default:
        }

    }



    
  doSorting(event) {

    //log('called doSorting');
    //log( 'label'+ JSON.stringify(event.detail));

    var fname= event.detail.fieldName;
    if(fname.includes('RecordURL')){
      fname= fname.replace('RecordURL','Name')
    }
    //log('doSorting-->fname'+fname);
    this.sortBy = fname;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
    this.sortBy = event.detail.fieldName;

  }
  
  
  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.data));
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
    this.data = parseData;
    var newdata = [];
    var finalPage = 0;
    this.AllDataCount = this.data.length;
    if(this.data.length > this.pageSize){
        finalPage = this.pageSize;
    }else{
        finalPage = this.data.length;
    }
    this.nextPage = finalPage;
    for(var i=0; i<finalPage;i++){
        newdata.push(this.data[i]);
    }
    if(this.nextPage >= this.AllDataCount){
        this.nextClass = true;
    }
    this.dataToShow = newdata;
    this.showPrev = true;
  }

  //[Vignesh D: added modal logic]
  openModal(event){
    //log('show->'+this.recordId);
    this.showPopOut = true;
  }
  closepopout(event){
    this.showPopOut = false;
  }
}