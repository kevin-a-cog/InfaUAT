/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Amarender              29-Nov-2021     I2RT-4793           Showing JIRA Change requests on Support Account Page      T01
 Vignesh Divakaran	    08/03/2022	    I2RT-5185	        Add Signature Select on success offering icon             T02
 Amit Garg      	    21/06/2022	    I2RT-5996	        eSupport - Reduce Timezone selection list to              T03  
                                                            avoid incorrect selections
 Amit Garg      	    25/07/2022	    I2RT-6676	        esupport-5996 - Language and time zone not 
                                                            displayed after contact creation                          T04  
 Amit Garg      	    25/07/2022	    I2RT-6508	        Customer editing a contact from esupport is               T05
                                                            not reflecting on contact records
 Vignesh D              08/08/2022      I2RT-6864           Checkmarx security fixes 
 Amit garg              29/08/2022      I2RT-6870           PayGo: eSupport - My eComm Account(s) &                   T06  
                                                               eComAccount (Org ID) details page 
 Amit garg              15/09/2022      I2RT-7096           make sure the case create component shows sticky toasr    T08   
 Amit garg              02/10/2022      I2RT-7166           make sure email break word works when user wraps text     T09   
 balajip                02/10/2022      I2RT-7305           to make the Language field mandatory                      T10   
 Isha B                 15/05/2023      I2RT-8339,I2RT-8461   Include mandatory fields popup on contact addition under manage contacts T11
 Isha B                 20/09/2023      I2RT-9075           CR table logic to match with IN which uses the coveo search T12
 Isha B                 24/10/2023     I2RT-9435            Column Name label change in CR table                        T13
*/
                                                            

  import { LightningElement, wire, track, api } from 'lwc';
  import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
  import { refreshApex } from '@salesforce/apex';  
  import { getRecord } from "lightning/uiRecordApi";  //Amarender -> I2RT-636: eSupport: Support Account Details Page
  import USER_ID from "@salesforce/user/Id";          //Amarender -> I2RT-636: eSupport: Support Account Details Page
  import CONTACT_ID from "@salesforce/schema/User.ContactId";         //Amarender -> I2RT-636: eSupport: Support Account Details Page
  import getSupportAccount from '@salesforce/apex/SupportAccountController.getSupportAccount';
  import createContact from '@salesforce/apex/SupportAccountController.createContact';
  import updateContactRelation from '@salesforce/apex/SupportAccountController.updateContactRelation';
  import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
  import { loadStyle } from 'lightning/platformResourceLoader';//<T09>
  import TABLECSS from '@salesforce/resourceUrl/manageaccountcontact';//<T09>
  import { getObjectInfo } from 'lightning/uiObjectInfoApi';
  import { getPicklistValues } from 'lightning/uiObjectInfoApi';
  import CONTACT_OBJECT from '@salesforce/schema/Contact';
  import LANGUAGE_FIELD from '@salesforce/schema/Contact.INFA_Language__c';
  import TIMEZONE_FIELD from '@salesforce/schema/Contact.Timezone__c';
  import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
  import updateDocVersion from '@salesforce/apex/SupportAccountController.updateDocVersion';
  import removeFile from '@salesforce/apex/SupportAccountController.removeFile';
  import getUnassignedContacts from "@salesforce/apex/SupportAccountController.getUnassignedContacts";
  import assignContactsToSupportAccount from "@salesforce/apex/SupportAccountController.assignContactsToSupportAccount";
  import removeContacts from "@salesforce/apex/SupportAccountController.removeContacts";
  import locationAndRegionValues from "@salesforce/apex/SupportAccountController.getPicklistValuesforRegionAndLocation";//<T03>
  import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken"; //<T12>
  import eSupportAccountCRDetails from "@salesforce/apex/SupportAccountController.eSupportAccountCRDetails"; //<T12>
  
  const actions = [
  { label: 'Edit', name: 'edit' },
  { label: 'Delete', name: 'delete' },
  ];
  
  const pdActions = [
  { label: 'Edit', name: 'edit' },
  { label: 'Delete', name: 'delete' },
  ];
  
  /* Display Message on Page when No Access/Error */
  const NO_RECORD_ACCESS_MESSAGE = 'You don\'t have access to record.';
  const ERROR_MESSAGE = 'An occurred while fetching data.'
  
  export default class EsSupportAccountDetails extends LightningElement {
  signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons_signature.png';
  
  
  
  @track isLoaded = true;
  @track isContactModal = false;
  @track isAlternateContactModal = false;
  @track isDeleteModal = false;
  @track isEditModal = false;
  @track dataChangeRequest = false;
  @track showSpinner = false;
  @track isPrimaryContact = false;            //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track items = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track pditems = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track contacts = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track allContacts = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track displayContacts = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track allDocuments = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track displayDocuments = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track projectDocuments = [];                 //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track caseAttachments = [];                 //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track caseDetail = {};                      //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track supportAccount = {};                  //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track entitlement = {};                     //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track owner;                     //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track timezone = {};                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track changeRequests = [];                        //Amarender -> I2RT-636: eSupport: Support Account Details Page
  @track isChangeRequests = false;                //<T01>
  @track buttonCss = 'es-button es-button--secondary';
  @track disableConfirmButton = true;
  @track isEditContact = false;
  @track attachmentsAvailable = false;
  @track accountId;
  @track accountParentId;
  @track contactId;
  @track uploadedDocId;
  @track currentDocId;
  @track docDescription;
  @track fileDescription;
  @track isAddUpdateAttachment;
  @track fileToRemove;
  @track loggedInUser;
  @track acrId;
  @track page = 1; //this will initialize 1st page
  @track startingRecord = 1; //start record position per page
  @track endingRecord = 0; //end record position per page
  @track pageSize = 10; //default value we are assigning
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records
  @track pdPage = 1; //this will initialize 1st page
  @track pdStartingRecord = 1; //start record position per page
  @track pdEndingRecord = 0; //end record position per page
  @track pdTotalRecountCount = 0; //total record count received from all retrieved records
  @track pdTotalPage = 0; //total number of page is needed to display all records
  
  //Loader
  @track boolDisplaySpinner = true;
  @track boolHasAccess = false;
  @track strMessage = NO_RECORD_ACCESS_MESSAGE;
  
  @track columns;
  @track crcolumns;
  @track defaultSortDirection = 'asc';
  @track sortDirection = 'asc';
  @track sortedBy;
  @track altConColumns;
  //<T03> starts
  conTimezoneRegion;
  conTimezoneLocation;
  RegionAndLocations;
  regionOptions;
  locationOptions;
  //<T03> ends

  @track searchtoken = ''; //<T12>

  @track COL_CONTACTS = [
      { label: 'Primary', fieldName: 'Primary__c', type: "boolean",initialWidth: 20,sortable:true},
      { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: true },
      { label: "Last Name", fieldName: "LastName", type: "text", sortable: true },
      { label: "Email Address", fieldName: "Email", type: "text", sortable: true },
      { label: "Phone Number", fieldName: "Phone__c", type: "text", sortable: true },
      { label: "Privileges", fieldName: "Access_Level__c", type: "text", sortable: true },
      { label: "Contact Time Zone", fieldName: "Contact_Timezone__c", type: "text", sortable: true },
      { label: "Language", fieldName: "Contact_Language__c", type: "text", sortable: true },
      { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'right' } }
  ];
  //<T01>
  //<T06> starts
  @track COL_CONTACTS_PAYGO = [
     { label: 'Primary', fieldName: 'Primary__c', type: "boolean",initialWidth: 20,sortable:true},
     { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: true },
     { label: "Last Name", fieldName: "LastName", type: "text", sortable: true },
     { label: "Email Address", fieldName: "Email", type: "text", sortable: true },
     { label: "Phone Number", fieldName: "Phone__c", type: "text", sortable: true },
     { label: "Privileges", fieldName: "Access_Level__c", type: "text", sortable: true },
     { label: "Contact Time Zone", fieldName: "Contact_Timezone__c", type: "text", sortable: true },
     { label: "Language", fieldName: "Contact_Language__c", type: "text", sortable: true }
 ];
 //<T06> ends
 /* @track COL_CRS = [
      { label: "Bug/Enhancement Number", fieldName: "zsfjira__IssueKey__c", type: "text", sortable: true },
      { label: 'Title', fieldName: 'zsfjira__Summary__c', type: 'text', sortable: true },
      // { label: "Type", fieldName: "zsfjira__IssueType__c", type: "text", sortable: true },
      { label: "Product", fieldName: "zsfjira__Project__c", type: "text", sortable: true },
      { label: "Reported Version", fieldName: "zsfjira__AffectsVersions__c", type: "text", sortable: true },
      { label: "Current Status", fieldName: "zsfjira__Status__c", type: "text", sortable: true },
      { label: "To be fixed in version", fieldName: "zsfjira__FixVersions__c", type: "text", sortable: true },
      // { label: "Open Date", fieldName: "zsfjira__Created__c", type: "text", sortable: true },
      // { label: "Close Date", fieldName: "zsfjira__Resolved__c", type: "text", sortable: true }
  ];*/
  @track COL_CRS = [ //<T12>
  { label: "Change Request Number", fieldName: "ideaURL", type: "url",typeAttributes: {label: { fieldName: 'requestNumber' }, target: '_blank'} }, 
  { label: "Type", fieldName: "requestType", type: "text", sortable: true },
  { label: "Title", fieldName: "Name", type: "text", sortable: true }, //T13
  { label: "Product", fieldName: "productName", type: "text", sortable: true },
  { label: "Status", fieldName: "Status", type: "text", sortable: true },
  { label: "To be fixed in version", fieldName: "tobefixedversion", type: "text", sortable: true },
  
];
  // </T01>
  @track COL_PDS = [
      { label: "Name", fieldName: "Title", type: "text", sortable: true },
      { label: 'Description', fieldName: 'Description', type: 'text', sortable: true },
      { label: "Content Type", fieldName: "FileType", type: "text", sortable: true },
      { label: "Last Modified Date", fieldName: "LastModifiedDate", type: "text", sortable: true },
      { label: "Created By", fieldName: "Name", type: "text", sortable: true }
      // { type: 'action', typeAttributes: { rowActions: pdActions, menuAlignment: 'right' } }
  ];
  ALT_COL_CONTACTS = [
  
      {
          label: "Contact Name",
          fieldName: "Name",
          type: "text",
          sortable: true,
          
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
          
      },
      
      {
          label: "Primary",
          fieldName: "Is_Primary__c",
          type: "boolean",
          sortable: true,
      }
  
  ];
  @track conChanged = false;
  @track acrChanged = false;
  @track conFirstName;
  @track conLastName;
  @track conEmail;
  @track conPhone;
  @track conLanguage;
  @track conTimezone;
  @track conPrivilege;
  @track conPrimary = false;
  @track altContacts = [];
  @track showAssignBtn = false;
  @track newContactAssigned = false;
  @track isDeleteContactModal = false;
  @track contactIdToDelete;
  isEcomAcc;
  orgDetails;
  //Amarender -> I2RT-636: eSupport: Support Account Details Page - Start
  /* @wire(getRecord, { recordId: USER_ID, fields: [CONTACT] })
  user({
      error,
      data
  }) {
      if (error) {
          this.error = error;
      } else if (data) {
          // this.isPrimaryContact = data.fields.Contact.value.fields.Is_Primary__c.value;
          this.loggedInUserContactId = data.fields.Contact.value.fields.Id.value;
      }
  } */
  //Amarender -> I2RT-636: eSupport: Support Account Details Page - End
  
  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  contactMetadata;
  
  @wire(getPicklistValues,
  {
      recordTypeId: '$contactMetadata.data.defaultRecordTypeId', 
      fieldApiName: LANGUAGE_FIELD
  })
  languageOptions;
  //<T03> starts
  @wire(locationAndRegionValues)
  user({
      error,
      data
  }) {
      if (error) {
          this.error = error;
      } else if (data) {
          this.RegionAndLocations = data;
          var regions = [];
          for(var i=0;i<this.RegionAndLocations.length;i++){
              var val = this.RegionAndLocations[i].Region;
              regions.push({label:val,value:val})
          }
          this.regionOptions = regions;
          
      }
  } 
  //<T03> ends
 
  @wire(getPicklistValues,
  {
      recordTypeId: '$contactMetadata.data.defaultRecordTypeId', 
      fieldApiName: TIMEZONE_FIELD
  })
  timeZoneOptions;
  
  get altContactsAvailable(){
      return this.altContacts.length > 0 ? true : false;
  }
  //Amarender -> I2RT-636: eSupport: Support Account Details Page - Start

  async setSearchToken(){ // <T12>
    var varlclCalledFrom ='esupportcrsearch'; //<T12> 
    getSearchToken({ strCalledFrom: varlclCalledFrom })
                        .then((result) => {
                            try {
                                this.searchtoken = JSON.parse(result).APISearchToken; 
                                this.getchangeRequests();
                                } catch (error) {
                                    console.log('error', 'Method : getSearchToken; then Catch Error :' +JSON.stringify(error));
                            }
                        }).catch(error => {
                            console.log("error - " + 'Method : getSearchToken; then Catch Error :' + JSON.stringify(error));                            
                        });
  }
  getchangeRequests(){ //<T12>
    eSupportAccountCRDetails({ accountId: this.accountId, token: this.searchtoken})
                        .then((result) => {
                            try {       
                                this.changeRequests = result;  
                                if(this.changeRequests.length > 0){
                                  this.changeRequests.forEach(item => item['ideaURL'] = item['Link']);
                                  
                              }
                                if(this.changeRequests != null && this.changeRequests != 'undefined' && this.changeRequests.length > 0){
                                  this.isChangeRequests = true;
                              }
                                } catch (error) {
                                    console.log('error', 'Error in fetching the CRs: ' + JSON.stringify(error));
                            }
                        }).catch(error => {
                            console.log('error', 'Error in fetching the CRS in eSupportAccountCRDetails: ' + JSON.stringify(error));                          
                        });
  }
  async connectedCallback() {
        
    var url = new URL(encodeURI(window.location.href)); //<T06>
      
      var accountId;
      if (url.searchParams.get("accountid") != null){
          accountId = url.searchParams.get("accountid");
      }else{
          accountId = sessionStorage.getItem("supportAccountId");
      }     
      accountId = (accountId == null) ? localStorage.getItem("supportAccountId") : accountId;
      
      if (accountId != null && accountId != '' && accountId != undefined) {
          this.accountId = accountId;      }
    await this.setSearchToken(); //<T12>
  
   if (this.accountId != null && this.accountId != '' && this.accountId != undefined) {
          this.accountId = accountId;
                   
          getSupportAccount({ accountId: accountId })
              .then(result => {
                  this.isEcomAcc = result.isEcomAcc; // <T06>
                  this.orgDetails = result.orgDetails; // <T06>
                  if(result && Object.keys(result).length > 0){
                      this.supportAccount = result.acc;
                      this.accountParentId = this.supportAccount.ParentId;
                      this.loggedInUser = result.loggedUser;
                      if(this.supportAccount.Success_Offering__c == 'Basic Success'){
                          this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';
                      }else if(this.supportAccount.Success_Offering__c == 'Premium Success'){
                          this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-02.svg';
                      }else if(this.supportAccount.Success_Offering__c == 'Signature Success' || this.supportAccount.Success_Offering__c == 'Signature Select'){ // <T02>
                          this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-03.svg';
                      }
                      
                      this.contacts = [...result.contacts].map(record =>{
                          
                          if(this.loggedInUser.ContactId == record.ContactId && record.Primary__c){
                              this.isPrimaryContact = true;
                          }
                          record.FirstName = record.Contact.FirstName;
                          record.LastName = record.Contact.LastName;
                          record.Email = record.Contact.Email;
                          record.Phone__c = record.Contact.Phone;
                          record.Contact_Language__c = record.Language__c;//<T04>
                          return record;
                      });
                      // <T01>
                      if(!this.isEcomAcc){
                      //this.changeRequests = result.jiraIssues; //<T12>
                      
                      if(this.changeRequests != null && this.changeRequests != 'undefined' && this.changeRequests.length > 0){
                          this.isChangeRequests = true;
                      }
                      // </T01>
                      this.projectDocuments = [...result.projectDocuments].map(record =>{                          
                          record.Name = record.CreatedBy.FirstName + " " + record.CreatedBy.LastName;
                          record.LastModifiedDate = new Date(record.LastModifiedDate).toGMTString().substr(5,11);
                          return record;
                      });
                      if(this.projectDocuments != null && this.projectDocuments != 'undefined' && this.projectDocuments.length > 0){
                          this.attachmentsAvailable = true;
                          this.caseAttachments = this.projectDocuments;
                      } 
                     }
                      this.entitlement = result.acc.Entitlement__r;
                      //Amarender -> I2RT-2945 - start
                      /*if(this.entitlement != null && this.entitlement != 'undefined'){
                          var endDate = new Date(this.entitlement.EndDate);
                          this.entitlement.EndDate = endDate.toGMTString().substr(5,11) ;
                      }*/
                      //Amarender -> I2RT-2945 - end
                      if(this.supportAccount.End_Date__c){
                          var endDate = new Date(this.supportAccount.End_Date__c);
                          this.supportAccount.End_Date__c = endDate.toGMTString().substr(5,11) ;
                      }
                      this.timezone = result.acc.TimeZone__r;                     
                      this.owner = result.accOwnerName;           //Changes made as part of I2RT-2946
                      //<T06> starts
                      if(this.isEcomAcc){
                         this.columns = this.COL_CONTACTS_PAYGO;
                      }else{
                      this.columns = this.COL_CONTACTS;
                      }
                      //<T06> ends
                      this.crcolumns = this.COL_CRS;
                      this.pdColumns = this.COL_PDS;
                      this.altConColumns = this.ALT_COL_CONTACTS;
                      this.setEnableAccess();
                  }
                  else{
                      this.setDisableAccess(false);
                  }
              })
              .catch(error => {
                  console.log("error - " + JSON.stringify(error));
                  this.setDisableAccess(true);
              });
      }
  }
  //Amarender -> I2RT-636: eSupport: Support Account Details Page - End
  
  
  
  renderedCallback(){
      if(this.items<=0 || this.newContactAssigned){            
          this.items = this.contacts;
          this.endingRecord = this.endingRecord == 0 ? ((this.items.length < this.pageSize) ? this.items.length : this.pageSize)  : this.endingRecord ;
      }
      this.endingRecord = this.endingRecord == 0 ? ((this.items.length < this.pageSize) ? this.items.length : this.pageSize)  : this.endingRecord ;
      if(this.newContactAssigned && this.endingRecord == this.totalRecountCount){
          this.endingRecord = this.contacts.length;
      }
      this.totalRecountCount = this.contacts.length;
      this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
      
      if(this.pditems<=0){            
          this.pditems = this.projectDocuments;
          this.pdEndingRecord =  this.pditems.length; // this.pageSize;
      }
      this.pdEndingRecord = this.pdEndingRecord == 0 ? ((this.pditems.length < this.pageSize) ? this.pditems.length : this.pageSize)  : this.pdEndingRecord ;
      this.pdTotalRecountCount = this.projectDocuments.length;
      this.pdTotalPage = Math.ceil(this.pdTotalRecountCount / this.pageSize); 
      if (this.showSpinner){
          document.body.setAttribute('style', 'overflow: hidden;');
      }
      else{
          document.body.removeAttribute('style', 'overflow: hidden;');
      }
      //<T09> starts
     Promise.all([
     loadStyle(this, TABLECSS),
     ])
     .then(() => {
         console.log("CSS loaded.")
     })
     .catch(() => {
         console.log("CSS not loaded");
     });
     //<T09> ends
     
  }
  
  setEnableAccess(){
      this.boolDisplaySpinner = false;
      this.boolHasAccess = true;
  }
  
  setDisableAccess(isError){
      this.boolDisplaySpinner = false;
      this.boolHasAccess = false;
      this.strMessage = isError ? ERROR_MESSAGE : NO_RECORD_ACCESS_MESSAGE;
  }
  
  handleRowAction(event) {
      const action = event.detail.action;
      const row = event.detail.row;      
      if(!this.isPrimaryContact){
          const toast = new ShowToastEvent({
              title: 'Access Denied',
              message: 'You cannot edit this Contact',
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(toast);
          return;
      }
      
      switch (action.name) {
          case 'edit':
             //T03 starts
             this.locationOptions = [];    
             for(var i=0;i<this.RegionAndLocations.length;i++){
                 var locOptions = [];
                 var match = false;
                 for(var j=0;j<this.RegionAndLocations[i].location.length;j++){
                     var value = this.RegionAndLocations[i].location[j].Loc;
                     locOptions.push({label:value,value:value});
                     var val = this.RegionAndLocations[i].location[j].TZ;
                     if(val == row.Timezone__c){
                         this.conTimezoneLocation = this.RegionAndLocations[i].location[j].Loc;
                         this.conTimezoneRegion = this.RegionAndLocations[i].Region;
                         match = true;
                     }
                 }
                 if(match == true){
                     this.locationOptions = locOptions;
                 }
                 
             }
             //T03 ends
              this.isEditContact = true;
              this.acrId = row.Id;
              this.contactId = row.ContactId;
              this.conFirstName = row.FirstName;
              this.conLastName = row.LastName;
              this.conEmail = row.Email;
              this.conPrivilege = row.Access_Level__c;
              this.conPhone = row.Phone__c;
              this.conTimezone = row.Timezone__c;
              this.conLanguage = row.Language__c;
              this.conPrimary = row.Primary__c;
              this.validateContactConfirmButton();
              this.openContactModal();
              break;
          
          case 'delete':              
              var rowId = row.Id;              
              this.contactIdToDelete = row.Id;              
              this.isDeleteContactModal = true;                                               
      }
  }
  
  confirmDeleteContact() {    
      this.showSpinner = true;      
      removeContacts({accContact: this.contactIdToDelete})
          .then(result => {
              console.log('returnMessage'+ result);
              if(result === "SUCCESS"){
                  this.showSpinner = false;
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Success',
                          message: 'Contact removed successfully',
                          variant: 'success'
                      })
                  );                  
                  this.contacts = this.contacts.filter(record => record.Id != this.contactIdToDelete);                  
                  return refreshApex(this.displayContacts); 
                  
              }    
              if(result.includes("Error"))  {
                  this.showSpinner = false;
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error ',
                          message: 'Error removing contact record',
                          variant: 'error'
                      })
                  );                
              }                                
          })
          .catch(error => {
              this.showSpinner = false;
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error removing Contact record',
                      message: error.body.message,
                      variant: 'error'
                  })
              );            
          });
          this.isDeleteContactModal = false;
  }
  
  handlePDRowAction(event) {
      const action = event.detail.action;
      const row = event.detail.row;      
      if(!this.isPrimaryContact){
          const toast = new ShowToastEvent({
              title: 'Access Denied',
              message: (action.name == 'edit') ? 'You cannot edit this Document' : 'You cannot delete this Document',
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(toast);
          return;
      }
      
      switch (action.name) {
          case 'edit':
              
              break;
          case 'delete':
              
              break;
      }
  }
  
  //Amarender -> I2RT-2947
  validateContactConfirmButton(){
      this.disableConfirmButton = !this.conTimezoneLocation || !this.conTimezoneRegion || !this.conFirstName || !this.conLastName || !this.conPrivilege || !this.conPhone ||(!this.conEmail && !this.isEditContact) || !this.conLanguage; //<T03> //T10
      this.buttonCss = (!this.disableConfirmButton) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
  }
  handleSearchText(event) {
      
      var searchText = event.target.value;
      if (searchText.length >= 3) {
          var filteredRecords = [];
          for (var index in this.contacts) {
              var record = this.contacts[index];
              let value = JSON.stringify(record);
              if (value && value.length > 0 && value.toLowerCase().includes(searchText.toLowerCase())) {
                  filteredRecords.push(record);
              }
          }
          this.endingRecord = filteredRecords.length < this.pageSize ? filteredRecords.length : this.pageSize ;
          this.contacts = filteredRecords;
      } else {
          this.endingRecord = this.allContacts.length < this.pageSize ? this.allContacts.length : this.pageSize ;
          this.contacts = this.allContacts;
          localStorage.setItem("filter_timeVal","2");
      }
  }
  
  get getContacts() {
      var inp=this.template.querySelector("lightning-input");//get search text field
      if( inp!=null){
          var inpVal=inp.value;         
          var firstTime = localStorage.getItem("first_timeVal");
          var filterval = localStorage.getItem("filter_timeVal");
          
          if(inp.value!=''){
              if(firstTime==null) {
                 
                   this.startingRecord=1;
                   this.endingRecord=10;
                   if(inpVal.length>10){  
                       this.page=2;
                   }
               }
              
              localStorage.clear();
          }else{            
               
              if(filterval==null) {
                   
               }else{
                  this.startingRecord=1;
                  this.endingRecord=10;
                  if(inpVal.length>10){  
                      this.page=2;
                  }
                  localStorage.clear();    
                   
               }
             
              
          }
      }else{
         
         // alert('else' +inp);
          
      }
      
      this.items=this.contacts;
      if(this.allContacts.length<=0){
          this.allContacts=this.contacts;
      }     
      if(this.startingRecord>1){
          this.displayContacts= this.items.slice((this.startingRecord-1),this.endingRecord); 
      }else{
          this.displayContacts= this.items.slice(0,this.pageSize); 
      }      
      return this.displayContacts;
  }
  
  get getProjectDocuments() {
      this.pditems=this.projectDocuments;
      if(this.allDocuments.length<=0){
          this.allDocuments=this.projectDocuments;
      }
      if(this.pdStartingRecord>1){
          this.displayDocuments= this.pditems.slice((this.pdStartingRecord-1),this.pdEndingRecord); 
      }else{
          this.displayDocuments= this.pditems.slice(0,this.pageSize); 
      }
          return this.displayDocuments;
      }
  
  //clicking on first  button this method will be called
  firstHandler() {
      localStorage.setItem("first_timeVal","2");
      this.startingRecord = 1;
      this.page = 2;
      if (this.page > 1) {
          this.page = this.page - 1; //decrease page by 1
          this.displayRecordPerPage(this.page);
      }
  }
  //clicking on last button this method will be called
  lastHandler() {
      localStorage.setItem("first_timeVal","2");
      this.page = this.totalPage;
      if (this.page > 1) {
          this.displayRecordPerPage(this.page);
      }
  }
  //clicking on previous button this method will be called
  previousHandler() {
      localStorage.setItem("first_timeVal","2");
      if (this.page > 1) {
          this.page = this.page - 1; //decrease page by 1
          this.displayRecordPerPage(this.page);
      }
  }
  
  //clicking on next button this method will be called
  nextHandler() {
      localStorage.setItem("first_timeVal","2");
      console.log(this.page+' +'+this.totalPage);
      if ((this.page < this.totalPage) && this.page !== this.totalPage) {
          this.page = this.page + 1; //increase page by 1
          this.displayRecordPerPage(this.page);
      }
  }
  //this method displays records page by page
  displayRecordPerPage(page) {
  
      this.startingRecord = ((page - 1) * this.pageSize);
      this.endingRecord = this.contacts.length < this.pageSize ? this.contacts.length : (this.pageSize * page);
  
      this.endingRecord = (this.endingRecord > this.totalRecountCount)
          ? this.totalRecountCount : this.endingRecord;
  
      this.startingRecord = this.startingRecord + 1;
      //this.getContacts;
  }
  
  //clicking on first  button this method will be called
  pdFirstHandler() {
      this.pdStartingRecord = 1;
      this.pdPage = 2;
      if (this.pdPage > 1) {
          this.pdPage = this.pdPage - 1; //decrease page by 1
          this.displaydocumentsPerPage(this.pdPage);
      }
  }
  //clicking on last button this method will be called
  pdLastHandler() {
      this.pdPage = this.pdTotalPage;
      if (this.pdPage > 1) {
          this.displaydocumentsPerPage(this.pdPage);
      }
  }
  //clicking on previous button this method will be called
  pdPreviousHandler() {
      if (this.pdPage > 1) {
          this.pdPage = this.pdPage - 1; //decrease page by 1
          this.displaydocumentsPerPage(this.pdPage);
      }
  }
  
  //clicking on next button this method will be called
  pdNextHandler() {
      if ((this.pdPage < this.pdTotalPage) && this.pdPage !== this.pdTotalPage) {
          this.pdPage = this.pdPage + 1; //increase page by 1
          this.displaydocumentsPerPage(this.pdPage);
      }
  }
  //this method displays records page by page
  displaydocumentsPerPage(pdPage) {
  
      this.pdStartingRecord = ((pdPage - 1) * this.pageSize);
      this.pdEndingRecord = this.projectDocuments.length; //< this.pageSize ? this.contacts.length : (this.pageSize * page);
  
      this.pdEndingRecord = (this.pdEndingRecord > this.pdTotalRecountCount)
          ? this.pdTotalRecountCount : this.pdEndingRecord;
  
      this.pdStartingRecord = this.pdStartingRecord + 1;
      getProjectDocuments();
  }
  
  openContactModal() {
      this.isContactModal = true;
      if(!this.isEditContact){
          this.conFirstName = null;
          this.conLastName = null;
          this.conEmail = null;
          this.conPrivilege = null;
          this.conPhone = null;
          this.conLanguage = null;
          this.conTimezone = null;
          this.conPrimary = false;
          this.validateContactConfirmButton();
          document.body.classList += ' modal-open';
          /** START-- adobe analytics */
          try {
              util.trackButtonClick("Create New Contact");
          }
          catch(ex) {
              console.log("Error =======>",ex.message);
          }
          /** END-- adobe analytics*/
  
      }
  }
  closeContactModal() {
   
    this.showSpinner = true;//T11 
      //remove ACR record if cancel was called 
     
      if(this.acrId!==null && this.selectedAltContacts!=null){ //ACR created from manage contacts section but cancel button clicked on contact page //T11       -> add contact not created   
        this.contactIdToDelete = this.acrId;       
        removeContacts({ accContact: this.contactIdToDelete })
        .then(result => {      
          if (result === "SUCCESS") {
            this.contacts = this.contacts.filter(record => record.Id !== this.contactIdToDelete);           
          }
        })
        .catch(error => {          
          console.error('An error occurred:', error);          
        })
        .finally(() => {
            this.showSpinner = false;
            this.isContactModal = false;
            this.isEditContact = false;
            document.body.classList -= ' modal-open';        
            this.selectedAltContacts=null; //T11
          // Default block, executed regardless of success or error
          
        });            
        
        } //T11 changes ends here 
        else{
            this.isContactModal = false;
        this.isEditContact = false;
        document.body.classList -= ' modal-open';
        this.showSpinner = false;//T11
        this.selectedAltContacts=null; //T11
        }
        
        
       
  }
  openAlternateContactModal() {
      this.handleManageContacts();
      this.isAlternateContactModal = true;
      document.body.classList += ' modal-open';
      /** START-- adobe analytics */
      try {
          util.trackButtonClick("Manage  Contacts");
      }
      catch(ex) {
          console.log("Error =======>",ex.message);
      }
      /** END-- adobe analytics*/
  }
  closeAlternateContactModal() {
      this.isAlternateContactModal = false;
      document.body.classList -= ' modal-open';
  }
  openDeleteModal() {
      this.isDeleteModal = true;
  }
  closeDeleteModal() {
      this.isDeleteModal = false;
  }
  openEditModal(event) {
      this.isAddUpdateAttachment = true;
      this.currentDocId = event.target.value;
  }
  closeEditModal() {
      this.isAddUpdateAttachment = false;
      this.docDescription = null;
  }
  
  @track buttonClicked = true;
  @track iconName = 'utility:down';
  @track className = 'slds-media slds-media_center es-slds-media slds-show';
  handleToggle(event) {
      let currentDiv = event.target;
      let targetIdentity = event.target.dataset.targetId;
      let targetDiv = this.template.querySelector(`[data-id="${targetIdentity}"]`);
      targetDiv.buttonClicked = !targetDiv.buttonClicked;
      targetDiv.className = targetDiv.buttonClicked ? 'slds-media slds-media_center es-slds-media slds-hide' : 'slds-media slds-media_center es-slds-media slds-show';
      currentDiv.iconName = targetDiv.buttonClicked ? 'utility:right' : 'utility:down';
  }
  get options() {
      return [
          { label: 'Read Only', value: 'Read Only' },
          { label: 'Read/Write', value: 'Read/Write' },
      ];
  }
  
  onHandleSort(event) {
     
      const { fieldName: sortedBy, sortDirection } = event.detail;
      const cloneData = [...this.contacts];
      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
      this.contacts = cloneData;
      this.sortDirection = sortDirection;
      this.sortedBy = sortedBy;
      //  console.log('onHandleSort',this.openCases);
  }
  
  onHandleCRSort(event) {
      
      const { fieldName: sortedBy, sortDirection } = event.detail;
      const cloneData = [...this.changeRequests];
      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
      this.changeRequests = cloneData;
      this.sortDirection = sortDirection;
      this.sortedBy = sortedBy;
      //  console.log('onHandleSort',this.openCases);
  }
  
  onHandlePDSort(event) {
     
      const { fieldName: sortedBy, sortDirection } = event.detail;
      const cloneData = [...this.projectDocuments];
      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
      this.projectDocuments = cloneData;
      this.sortDirection = sortDirection;
      this.sortedBy = sortedBy;
  }
  
  handleFirstNameChange(event){
      this.conChanged = true;
      this.conFirstName = event.detail.value;
      this.validateContactConfirmButton();
  }
  
  handleLastNameChange(event){
      this.conChanged = true;
      this.conLastName = event.detail.value;
      this.validateContactConfirmButton();
  }
  
  handleConEmailChange(event){
      this.conChanged = true;
      this.conEmail = event.detail.value;
      this.validateContactConfirmButton();
  }
  
  handleConPhoneChange(event){
      this.acrChanged = true;
      this.conChanged = true;//<T05>
      this.conPhone = event.detail.value;
      this.validateContactConfirmButton();
  }
  
  handleConLanguageChange(event){
      this.acrChanged = true;
      this.conChanged = true;//<T05>
      this.conLanguage = event.detail.value;
      this.validateContactConfirmButton(); //T10
    }
  //<T03>starts
  handleLocationChange(event){
      this.acrChanged = true;
      this.conTimezoneLocation = event.detail.value;
      this.validateContactConfirmButton();
      //alert(this.conTimezoneLocation);
  }
  handleRegionChange(event){
     this.acrChanged = true;
     this.conChanged = true;//<T05>
     this.conTimezoneRegion = event.detail.value;
     this.locationOptions = [];
     for(var i=0;i<this.RegionAndLocations.length;i++){
         if(this.conTimezoneRegion == this.RegionAndLocations[i].Region){
             for(var j=0;j<this.RegionAndLocations[i].location.length;j++){                
                 var val = this.RegionAndLocations[i].location[j].Loc;                 
                 this.locationOptions.push({label:val,value:val});
             }
         }
         
     }
     this.validateContactConfirmButton();
  }
  //<T03> ends
  /*handleConTimeZoneChange(event){
      this.acrChanged = true;
      this.conTimezone = event.detail.value;
      this.validateContactConfirmButton();
  }*/
  
  handleConPrivilegeChange(event){
      this.acrChanged = true;
      this.conPrivilege = event.detail.value;
      this.validateContactConfirmButton();
  }
  
  handleConPrimaryChange(event){
      this.acrChanged = true;
      this.conPrimary = event.target.checked;
  }
  
  confirmContact(){
      
      if(!this.conFirstName || !this.conLastName || !this.conPhone || !this.conEmail ){
          this.buttonCss = (this.conFirstName  && this.conLastName && this.conPhone && (this.conEmail && !this.isEditContact)) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
          return;
      }
  
      if(this.isEditContact){
          this.confirmUpdateContactRelation();
      }else {
          this.confirmCreateContact();
      }
      document.body.classList -= ' modal-open';
  
  }
  
  confirmCreateContact(){
      this.showSpinner = true;
      createContact({firstName: this.conFirstName,lastName: this.conLastName, phone: this.conPhone, email: this.conEmail,language: this.conLanguage,primary: this.conPrimary,privilege: this.conPrivilege,Region: this.conTimezoneRegion,Location: this.conTimezoneLocation,accountId: this.accountId})//<T03>
      .then(
          result => {
              let record = result;              
              record.FirstName = result.Contact.FirstName;
              record.LastName = result.Contact.LastName;
              record.Email = result.Contact.Email;
              record.Contact_Timezone__c = result.Timezone__c;//<T04>
              record.Contact_Language__c = result.Language__c;//<T04> 
              this.contacts.push(record);
              this.newContactAssigned = true;
              // this.totalRecountCount = this.contacts.length;
              // this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
              this.selectedAltContacts=null ;//T11
              this.showSpinner = false;
              this.isContactModal = false;
              const toast = new ShowToastEvent({
                  title: 'Contact Created',
                  message: 'New contact is created successfully.',
                  variant: 'success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(toast);
          }
      ).catch(error => {         
          this.showSpinner = false;
          this.isContactModal = false;
          const toast = new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error',
              mode: 'sticky' //<T08>
          });
          this.dispatchEvent(toast);
      });
  }
  
  confirmUpdateContactRelation(){
      this.showSpinner = true;
      updateContactRelation({firstName: this.conFirstName,lastName: this.conLastName,contactId: this.contactId,nameChanged:this.conChanged,phone: this.conPhone,/* email: this.conEmail,*/language: this.conLanguage,privilege: this.conPrivilege,Region: this.conTimezoneRegion,Location: this.conTimezoneLocation,primary: this.conPrimary, acrId: this.acrId,acrChanged: this.acrChanged,accountId: this.accountId})
      .then(
          result => {
              this.contacts = [...this.contacts].map(record => {                  
                  if(result.length >1 ){
                      if(record.Id == result[0].Id){
                          record.Timezone__c = result[0].Timezone__c;
                          record.Access_Level__c = result[0].Access_Level__c;
                          record.Primary__c = result[0].Primary__c;
                          record.Phone__c = result[0].Phone__c;
                          record.Language__c = result[0].Language__c;
                          record.Contact_Timezone__c = result[0].Timezone__c;//<T04>
                          record.Contact_Language__c = result[0].Language__c;//<T04> 
                          if(this.loggedInUser.ContactId == record.ContactId && !result[0].Primary__c){
                              this.isPrimaryContact = false;
                          }else if(this.loggedInUser.ContactId == record.ContactId && result[0].Primary__c){
                              this.isPrimaryContact = true;
                          }
                      }
                      if(record.ContactId == result[1].Id){
                          record.FirstName = result[1].FirstName;
                          record.LastName = result[1].LastName;
                          //record.Email = result[1].Email;
                      }
                  }else if (result.length == 1 && this.conChanged) {
                      if(record.ContactId == result[0].Id){
                          record.FirstName = result[0].FirstName;
                          record.LastName = result[0].LastName;
                          //record.Email = result[0].Email;
                      }
                  }else if (result.length == 1 && this.acrChanged) {
                      if(record.Id == result[0].Id){
                          record.Timezone__c = result[0].Timezone__c;
                          record.Access_Level__c = result[0].Access_Level__c;
                          record.Primary__c = result[0].Primary__c;
                          record.Phone__c = result[0].Phone__c;
                          record.Language__c = result[0].Language__c;
                          if(this.loggedInUser.ContactId == record.ContactId && !result[0].Primary__c){
                              this.isPrimaryContact = false;
                          }else if(this.loggedInUser.ContactId == record.ContactId && result[0].Primary__c){
                              this.isPrimaryContact = true;
                          }
                      }
                  }
                  return record;
              });
              this.conNameChanged = false;
              this.acrChanged = false;
              this.isEditContact = false;
              this.showSpinner = false;
              this.isContactModal = false;
              const toast = new ShowToastEvent({
                  title: 'Contact Updated',
                  message: 'Contact updated successfully.',
                  variant: 'success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(toast);
              this.selectedAltContacts=null ;//T11
              return refreshApex(this.contacts);
          }
      ).catch(error => {
          this.showSpinner = false;
          this.isContactModal = false;
          var message;
          
          const toast = new ShowToastEvent({
              title: 'Server Error',
              message: error.body.message,
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(toast);
      });
  }
  
  
  sortBy(field, reverse, primer) {
      //console.log('sortBy',field);
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
  
  handleRowSelected(event) {
      
      const selectedRows = event.detail.selectedRows;
     // alert(selectedRows);
  }
  
  handleAltContactsRowSelected(event) {
      
      const selectedRows = event.detail.selectedRows;      
      this.selectedAltContacts = selectedRows;
      if(selectedRows.length > 0){
          this.showAssignBtn = true;
      }else{
          this.showAssignBtn = false;
      }
  }
  
  updateDoc() {
      this.showSpinner = true;      
      if (this.uploadedDocId == null || this.uploadedDocId == '' || this.uploadedDocId == 'undefined') {
          this.uploadedDocId = this.currentDocId;
          this.currentDocId = '';
      }
      updateDocVersion({ docToDelete: this.currentDocId, docToUpdate: this.uploadedDocId, docDescription: this.docDescription, accountId: this.accountId })
          .then(result => {
              if (result) {
                  if(result.length > 0){
                      this.attachmentsAvailable = true;
                  }else{
                      this.attachmentsAvailable = false;
                  }
                  this.caseAttachments = [...result].map(record =>{                     
                      record.Id = record.ContentDocument.Id;
                      record.DownloadUrl = '/sfc/servlet.shepherd/document/download/' + record.ContentDocument.Id;
                      record.Title = record.ContentDocument.Title;
                      record.Description = record.ContentDocument.Description;
                      record.FileType = record.ContentDocument.FileType;
                      record.Name = record.ContentDocument.CreatedBy.FirstName + " " + record.ContentDocument.CreatedBy.LastName;
                      record.LastModifiedDate = new Date(record.ContentDocument.LastModifiedDate).toGMTString().substr(5,11);
                      return record;
                  });
                  this.uploadedDocId = '';
                  this.currentDocId = '';
                  this.docDescription = '';
              }
              this.isEditModal = false;
              this.showSpinner = false;
          });
  }
  
  get acceptedFormats() {
      let acceptedFileFormates = [];
      getAcceptedFileFormates({})
          .then(result => {
              acceptedFileFormates = result;
          });
      return acceptedFileFormates;
  }
  
  handleAddAttachmentClick() {
      this.isAddUpdateAttachment = true;
      document.body.classList += ' modal-open';
      /** START-- adobe analytics */
      try {
          util.trackButtonClick("Add Updates/Files");
      }
      catch(ex) {
          console.log("Error =======>",ex.message);
      }
      /** END-- adobe analytics*/
  }
  
  handleFileDescription(event) {
      this.fileDescription = event.detail.value;
  }
  
  closeAddAttachment(event) {
      this.docDescription = '';
      if(this.uploadedDocId != null && this.uploadedDocId != '' && this.uploadedDocId != 'undefined'){
          // this.isAddUpdateAttachment = false;
          this.removeAttachmentDetails(event);
          this.fileToRemove = this.uploadedDocId;
      }else{
          this.isAddUpdateAttachment = false;
      }
      document.body.classList -= ' modal-open';
  }
  
  updateFileDetails() {
      let isValidValue = this.validateInputField();
      if (isValidValue){
          this.updateDoc();
          this.isAddUpdateAttachment = false;
          document.body.classList -= ' modal-open';
      }
  }
  
  validateInputField(){
      let isValidValue = [...this.template.querySelectorAll('lightning-textarea')]
      .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
      }, true);
      return isValidValue;
  }
  
  handleUploadFinished(event) {
      const uploadedFiles = event.detail.files;
      console.log('fileDetails= ' + JSON.stringify(uploadedFiles));
      this.uploadedDocId = uploadedFiles[0].documentId;
      console.log('docId= ' + this.uploadedDocId);
  }
  removeAttachmentDetails(event) {
      this.fileToRemove = event.target.value;
      this.isDeleteModal = true;
  }
  
  confirmFileRemoveDetail() {
      this.showSpinner = true;
      console.log('called' + this.fileToRemove);
      removeFile({ documentId: this.fileToRemove,accountId: this.accountId })
          .then(result => {
              if (result) {
                  if(result.length == 0){
                      this.attachmentsAvailable = false;
                  }
                  console.log('result= ' + JSON.stringify(result));
                  this.caseAttachments = [...result].map(record =>{
                      record.Id = record.ContentDocument.Id;
                      record.DownloadUrl = '/sfc/servlet.shepherd/document/download/' + record.ContentDocument.Id;
                      record.Title = record.ContentDocument.Title;
                      record.Description = record.ContentDocument.Description;
                      record.FileType = record.ContentDocument.FileType;
                      record.Name = record.ContentDocument.CreatedBy.FirstName + " " + record.ContentDocument.CreatedBy.LastName;
                      record.LastModifiedDate = new Date(record.ContentDocument.LastModifiedDate).toGMTString().substr(5,11);
                      return record;
                  });
                  this.isDeleteModal = false;
                  this.isAddUpdateAttachment = false;
                  this.uploadedDocId = '';
                  this.docDescription = '';
              }
              this.showSpinner = false;
          });
  }
  
  cancelFileRemoveDetail() {
      this.fileToRemove = '';
      this.isDeleteModal = false;
  }
  
  
  handleDocDescriptionChange(event) {
      this.docDescription = event.detail.value;
  }
  
  closeDeleteContactModal() {
      this.isDeleteContactModal = false;
  }
  downloadDoc(event){
            let url = '/sfc/servlet.shepherd/document/download/' + event.currentTarget.dataset.id;
      window.open(url,'_self');
  }
  
      handleManageContacts(){
          this.showSpinner = true;
          getUnassignedContacts({ accountId: this.accountParentId, supportAcc: this.accountId })
          .then((result) => {
              this.showSpinner = false;
              
                      this.altContacts = result;
                  })
                  .catch((error) => {
                      console.log(JSON.stringify(error));
                  }); 
      }
  
      handleAssignContacts(){
          this.showSpinner = true;          
          let contactsList = [...this.selectedAltContacts].map(con =>{
              let contact;
              contact = con.Id;
              return contact;
          });
          this.showAssignBtn = false;
          assignContactsToSupportAccount({supportAccount: this.accountId, contacts: contactsList})
          .then(result => {
              [...result].map(record =>{
                
                  record.FirstName = record.Contact.FirstName;
                  record.LastName = record.Contact.LastName;
                  record.Email = record.Contact.Email;
                  this.contacts.push(record);
                  this.acrId=record.Id; //T11
                  this.conFirstName = record.Contact.FirstName; //T11
                  this.conLastName = record.Contact.LastName; //T11
                  this.conLanguage=record.Language__c?record.Language__c:record.Contact.INFA_Language__c;//T11
                  this.conTimezone=record.Timezone__c?record.Timezone__c:record.Contact.Timezone__c;//T11
                  this.conPhone=record.Contact.Phone; //T11 
                  this.conPrivilege=record.Access_Level__c  //T11
                  this.conEmail=record.Contact.Email; //T11
              });
              this.newContactAssigned = true;
              this.showSpinner = false;
              this.closeAlternateContactModal();
              /* T11 starts here*/
              this.contactId=contactsList[0]; // T11
              this.acrChanged=true;      // T11        
              this.isEditContact=true; // T11
              this.openContactModal(); // T11            
            /*  const toast = new ShowToastEvent({
                  title: 'Contact(s) Assigned',
                  message: 'Contact(s) assigned successfully.',
                  variant: 'success',
                  mode: 'dismissable'
              });
              this.dispatchEvent(toast);
              */
              /* T11 ends here*/
          })
          .catch(error => {
              this.showSpinner = false;
              console.log('error : '+ error)
              console.log('JSON.stringify(error) : ' + JSON.stringify(error));
              this.closeContactModal(); // T11 ->remove the ACR if contact addition resulted in error 
          });
      }
  }