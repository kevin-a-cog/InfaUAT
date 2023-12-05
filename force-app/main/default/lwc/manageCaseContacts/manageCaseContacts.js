/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh Divakaran      09-May-2022     I2RT-6196           Comment CDC channel subscription                          T01
 Vignesh Divakaran      22-Aug-2022     I2RT-6894           Process contacts and set the Access Level value           T02           
 balajip                22-Aug-2022     I2RT-6867           To get unassigned contacts from the Ecom Account          T03            
 */
 import { LightningElement, track, api, wire } from "lwc";
 import { ShowToastEvent } from "lightning/platformShowToastEvent";
 import { getPicklistValues } from 'lightning/uiObjectInfoApi';
 import { NavigationMixin } from "lightning/navigation";
 import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
 import { createRecord } from 'lightning/uiRecordApi';
 import { deleteRecord } from 'lightning/uiRecordApi';
 import getFields from "@salesforce/apex/ManageCaseContacts.getFields";
 import getAssignedCaseContacts from "@salesforce/apex/ManageCaseContacts.getAssignedCaseContacts";
 import getUnassignedCaseContacts from "@salesforce/apex/ManageCaseContacts.getUnassignedCaseContacts";
 import createcasecontactcontr from "@salesforce/apex/ManageCaseContacts.createcasecontactcontr";
 import getPermissionOnObject from '@salesforce/apex/ManageCaseContacts.getPermissionOnObject';
 import updatecontacts from "@salesforce/apex/ManageCaseContacts.updatecontacts";
 import addCaseContacts from "@salesforce/apex/ManageCaseContacts.addCaseContacts";
 import removeCaseContacts from "@salesforce/apex/ManageCaseContacts.removeCaseContacts";
 import getMedataDataRecord from "@salesforce/apex/CaseController.getMedataDataRecord";
 import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCOUNTID from "@salesforce/schema/Case.AccountId"; //T03
 import CASEID from "@salesforce/schema/Case.Id";
 import SUPPORTACCOUNT from "@salesforce/schema/Case.Support_Account__c";
 import STATUS from "@salesforce/schema/Case.Status";
 import CONTACTID from "@salesforce/schema/Case.ContactId";
 import TIMEZONE_FIELD from '@salesforce/schema/Contact.Timezone__c';
import RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.Name';

 //import NAME_FIELD from '@salesforce/schema/Case_Contact__c.Name';
 import CASE_FIELD from '@salesforce/schema/Case_Contact__c.Case__c';
 import EMAIL_FIELD from '@salesforce/schema/Case_Contact__c.Email__c';
 import CONTACT_FIELD from '@salesforce/schema/Case_Contact__c.Contact__c';
 
 import global_styles from '@salesforce/resourceUrl/gcsSrc';
 import { loadStyle } from 'lightning/platformResourceLoader';
 
const fields = [CASEID,SUPPORTACCOUNT,STATUS,CONTACTID,ACCOUNTID,RECORDTYPE_NAME];//T03
 const CONTACT_OBJ = 'Contact';
 const CASE_CONTACT_OBJ = 'Case_Contact__c';
 const ASSIGNED_CONTACTS = "Assigned";
 const UNASSIGNED_CONTACTS = "UnAssigned";
 
const CASE_LITE = 'Case Lite'; //T03
 
 const tabsObj = [
 {
     tab: ASSIGNED_CONTACTS,
     helpText: "",
     fieldSet: 'Assigned_Case_Contacts',
     ccfieldSet: 'Case_Contacts'
 },
 {
     tab: UNASSIGNED_CONTACTS,
     helpText: "",
     fieldSet: 'UnAssigned_Case_Contacts'
 }
 ];
 
 export default class ManageCaseContacts extends NavigationMixin(LightningElement) {
 
     @api recordId;
 
     @track tabs = tabsObj;
     @track defaultTabOnInitialization = ASSIGNED_CONTACTS;
     @track currentTabValue;
     @track columns;
     @track fieldApiNames = [];
     @track lookupFields = [];
     @track data;
     @track NoDataAfterRendering = false;
     @track displayDataTableFooter = false;
     displaycancel = false;
     showButtons = false;
     @track showErrorMessage;
     @track displayRemoveBTN = false;
     @track displayAddBTN = false;
     searchTerm = '';
     isTimezoneModalOpen = false;
     @track value;
     timzonePicklistValues = [];
     
     //@track isLoading = false;
 
     //have this attribute to track data change
     @track draftValues = [];
     lastSavedData = [];
     selectedRow = [];
     selectedRecordsList = [];
 
     connectedCallback() {
         // this.subscribeToCaseCommentDataChange(); Commented as part of <T01>
     }
 
     renderedCallback() {
         Promise.all([
         loadStyle(this, global_styles + '/global.css'),
         ])
         .then(() => {
         console.log("All scripts and CSS are loaded.")
         })
         .catch(error => {
         console.log('Script and CSS not loaded');
         });
     }
 
     /* Commented as part of <T01>
     subscribeToCaseCommentDataChange() {
         console.log('subscribeToCaseCommentDataChange......');
 
         // Callback invoked whenever a new event message is received
         var thisReference = this;
         const messageCallback = function(response) {
             console.log('Case comment created/updated: ', JSON.stringify(response));
 
             var changeType = response.data.payload.ChangeEventHeader.changeType;
             console.log('change type: ', changeType);
             
 
             //@Akhilesh 16 Oct 2021 --start
             //thisReference.handleRefresh();
             var caseId = response?.data?.payload?.Case__c;
             console.log('case id: '+caseId);
             console.log('recordId: '+thisReference.recordId);
             if(caseId == thisReference.recordId){ 
                 thisReference.handleRefresh();
             }
             //@Akhilesh 16 Oct 2021 --end
         };
         var channelName = '/data/Case_Comment__ChangeEvent';
     }*/
 
     @wire(getRecord, { recordId: "$recordId", fields })
     supportCase;
 
     getRecordURL(sObject, Id) {
         return "/lightning/r/" + sObject + "/" + Id + "/view";
     }
 
     @wire(getPicklistValues, { recordTypeId: '012410000003ttuAAA', fieldApiName: TIMEZONE_FIELD })
     tzpicklist({ data, error }) {
         console.log('data'+data);
         if (data) {         
         this.timzonePicklistValues = JSON.parse(JSON.stringify(data.values));
         }
         if (error) {
         console.log("picklist values returned error" + JSON.stringify(error));
         }
     };
 
     @wire(getPermissionOnObject)
     createPermission({ error, data }) {
         if (data) {
             //console.log("Watch: metadataRecord data -> " + JSON.stringify(data));
             this.showButtons = data;
             // alert('value----'+data);
             //metadataRecordURL
         } else if (error) {
             // alert(JSON.stringify(error));
             //console.log("Watch: metadataRecord error -> " + JSON.stringify(error));
         }
     }
     //New Contact creation
     createContactWithDefaultValues() {
         const defaultValues = encodeDefaultFieldValues({
             Case__c: this.recordId
         });
         this[NavigationMixin.Navigate]({
             type: 'standard__objectPage',
             attributes: {
                 objectApiName: 'Case_Contact__c',
                 actionName: 'new'                
             },
             state : {
                 nooverride: '1',
                 defaultFieldValues: defaultValues
             }
         });
     }
 
 
     //handle tab selection
     handleActiveTab(event) {
         this.currentTabValue = event.target.value;
         this.handleRefresh();
     }
 
     //handle row selected
     handleRowSelected(event) {
         console.log(event.detail.selectedRows);
         const selectedRows = event.detail.selectedRows;
         this.selectedRecordsList = selectedRows;
         console.log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
         this.selectedRow = [];
         
         for (let i = 0; i < selectedRows.length; i++) {                             
         // this.selectedRow.push(selectedRows[i].contactid);
         }
         this.selectedRow = selectedRows;
         console.log("selected row final => " + JSON.stringify(this.selectedRow));
         if (this.selectedRow.length > 0) {
         this.displayDataTableFooter = true;   
         this.displaycancel = true;
         this.showErrorMessage = undefined;
         }
     }
 
     
 
     handletimezoneSelected(event){
         this.value = event.target.value;
     }
 
     handleupdate() {             
     
         var isopen = false;
         var casecontacts = JSON.parse(JSON.stringify(this.selectedRow));
         for (let i = 0; i < casecontacts.length; i++) {  
         if(casecontacts[i].contactid == undefined){
             isopen = true;
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: "Error occurred :",
                     message: "Please select a case contact that has contact associated",
                     variant: "error"
                 })
                 );
                 break;
             }
     }
     if (this.selectedRow.length > 0 && isopen) {
         this.isTimezoneModalOpen = true;
     }
 
 }
 
     closetzmodal() {             
     
         this.isTimezoneModalOpen = false;
         
     }
 
     
     /* TimeZone functionality has been removed
 
     //handler to update contact timezone
     handletzupdate(event) {
         var casecontacts = [];
         var casecontactsupdate = [];
         casecontacts = JSON.parse(JSON.stringify(this.selectedRow));
         console.log("**add Support Contacts size =1 " + casecontacts[0]);
         if(casecontacts != undefined && casecontacts.length > 0){
             this.isLoading = true;
             
             for (let i = 0; i < casecontacts.length; i++) {  
                 if(casecontacts[i].contactid == undefined){
                     this.showErrorMessage = "Selected case contact has no associated contact";                   
                 } else {
                 var tempcontact  = {'Id':casecontacts[i].contactid, 'Timezone__c':this.value};                
                 casecontactsupdate.push(tempcontact);
                 }
             };
             if(casecontactsupdate.length > 0)
             updatecontacts({ contactlist: casecontactsupdate })
             .then((result) => {
                 this.dispatchEvent(
                 new ShowToastEvent({
                     title: "Success",
                     message: "Contacts Updated Successfully",
                     variant: "success"
                 })
                 );
 
                 this.isTimezoneModalOpen = false;
                 //clear the selected rows
                 this.selectedRow = [];
 
                 //hide the datatable footer
                 this.displayDataTableFooter = false;               
                 this.displaycancel = false;
 
                 this.isLoading = false;
 
                 return this.handleRefresh();
             })
             .catch((error) => {
                 console.log(`save error --> ${JSON.stringify(error)}`);
                 this.dispatchEvent(
                 new ShowToastEvent({
                     title: "Error occurred :",
                     message: error.body.message,
                     variant: "error"
                 })
                 );
                 this.isLoading = false;
             })
         }
         else{
             this.showErrorMessage = "Please select a Contact to remove from the Support Account";
         }
     }
 
     */
 
 
     //handler to add contacts to Case from support Account Contacts
     handleAdd(event){
         const SupportContacts = this.selectedRow;
         if(SupportContacts != undefined && SupportContacts.length > 0){
             this.isLoading = true;
             addCaseContacts({ contacts: SupportContacts, supportcas: this.recordId })
                 .then((result) => {
                     this.dispatchEvent(
                         new ShowToastEvent({
                         title: "Success",
                         message: "Contacts added to the Support Account Successfully",
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
                 .catch((error) => {
                     console.log(`save error --> ${JSON.stringify(error)}`);
                     this.dispatchEvent(
                     new ShowToastEvent({
                         title: "Error occurred :",
                         message: error.body.message,
                         variant: "error"
                     })
                     );
                     this.isLoading = false;
                 })
         }
         else{
             this.showErrorMessage = "Please select a Contact to add to the Support Account";
         }
     }
 
     //Handler to cancel
     handleCancel(event){
         //hide the datatable footer
         this.displayDataTableFooter = false;
         this.displaycancel = false;
         this.handleRefresh();
     }
 
     onChange(event) {
         this.searchTerm = event.target.value;
         console.log('Search Term --> '+this.searchTerm);
 
         if(this.currentTabValue == ASSIGNED_CONTACTS){
             getAssignedCaseContacts({ searchTerm: this.searchTerm, supportcas: this.recordId, fields: this.fieldApiNames.join() })
                 .then((result) => {
                     //Promise for getAssignedCaseContacts()
                     console.log(JSON.stringify(result));
                     
                     if(result?.lstCaseContacts?.length > 0){ //<T02>
                         var storeResult = result.lstCaseContacts;
                         let mapContactIdAccessLevel = new Map(); //<T02>
                         result.lstAccountContacts.forEach(objAccountContact => { //<T02>
                             mapContactIdAccessLevel.set(objAccountContact.ContactId, objAccountContact.Access_Level__c);
                         });
                         storeResult.forEach(eachval => {                           
                             console.log('value'+eachval['Contact__r']);
                             if(eachval['Contact__r'] != undefined){                              
                                 for(var each in eachval['Contact__r']){
                                     if(each == 'Id'){
                                         eachval['contactid'] = eachval['Contact__r'][each];
                                         eachval['Access_Level__c'] = mapContactIdAccessLevel.get(eachval['Contact__r'][each]); //<T02>
                                     } else{
                                     eachval[each] = eachval['Contact__r'][each];
                                     }
                                 }
                                 
                                 console.log('storeresult'+storeResult);
                             }
                             
                         })
 
                         console.log('lookupFields --> '+this.lookupFields);
                         console.log('fieldApiNames --> '+this.fieldApiNames);
 
                         this.lookupFields.forEach(lookupField => {
                             var fieldObj = lookupField.replace('_Id','');
                             storeResult.forEach(row => {
                                 if(row[fieldObj] != undefined){
                                     for(const [key, value] of Object.entries(row[fieldObj])){
                                         var fieldName = fieldObj+'_'+key;
                                         if(key === 'Id'){
                                             var objectName = fieldObj.includes('__r') ? fieldObj.replace('__r','__c') : fieldObj;
                                             console.log('objectName -> '+objectName);
                                             row[fieldName] = this.getRecordURL(objectName, value)
                                         }
                                         else{
                                             row[fieldName] = value;
                                         }
                                     }
                                 }
                             });                       
                         });
 
                         console.log('storeResult --> '+JSON.stringify(storeResult));
                         this.data = storeResult;
                         this.NoDataAfterRendering = false; 
                         
                         this.displayRemoveBTN = true;
                         this.displayAddBTN = false;
                     }
                     else{
                         this.NoDataAfterRendering = true;
                         this.data = undefined;
                     }
                 
                 })
                 .catch((error) => {
                     //Promise for getAssignedCaseContacts()
                     console.log(JSON.stringify(error));
                 })
 
         }
         else if(this.currentTabValue == UNASSIGNED_CONTACTS){
            //T03 set the account Id based on the record type
            let accountId;
            if(getFieldValue(this.supportCase.data, RECORDTYPE_NAME) == CASE_LITE){
                accountId = getFieldValue(this.supportCase.data, ACCOUNTID);
            }else{
                accountId = getFieldValue(this.supportCase.data, SUPPORTACCOUNT);
            }
            getUnassignedCaseContacts({ searchTerm: this.searchTerm, caseid: this.recordId, supportAcc: accountId, supportcas: this.recordId, fields: this.fieldApiNames.join() })
                 .then((result) => {                   
                         //Promise for getUnassignedCaseContacts()
                         console.log(JSON.stringify(result));
                         if(result.length > 0){
                             var storeResult = result;                        
                                                                         
                             storeResult.forEach(eachval => {                           
                             console.log('value'+eachval['Contact.']);
                             if(eachval['Contact'] != undefined){                              
                                 for(var each in eachval['Contact']){
                                     if(each == 'Id'){
                                             eachval['contactid'] = eachval['Contact'][each];
                                     } else if(each != 'Access_Level__c'){ //<T02>
                                         eachval[each] = eachval['Contact'][each];
                                     }
                                 }
                                 
                                 console.log('storeresult'+storeResult);
                             }
                             
                             })                  
     
                             console.log('storeResult --> '+JSON.stringify(storeResult));
                             this.data = storeResult; 
                             this.NoDataAfterRendering = false; 
 
                             this.displayRemoveBTN = false;
                             this.displayAddBTN = true;
                         }
                         else{
                             this.NoDataAfterRendering = true;
                             this.data = undefined;
                         }
                     
                     })
                 .catch((error) => {
                     //Promise for getUnassignedCaseContacts()
                     console.log(JSON.stringify(error));
                 }) 
         }        
     }
 
     handleIconRefresh(event) {
         this.handleRefresh();
     }
 
 
     //handle refresh of the data table
     handleRefresh() {
         this.showErrorMessage = undefined;
         this.displayDataTableFooter=false;
         this.NoDataAfterRendering = false;
         this.fieldApiNames = [];
         this.lookupFields = [];
         if(this.currentTabValue == ASSIGNED_CONTACTS){
             this.data = undefined;
             var objectinput = [{'objectName':CONTACT_OBJ, 'fieldSetName':tabsObj[0].fieldSet,'parentrelationship':'Contact__r.'},{'objectName':CASE_CONTACT_OBJ, 'fieldSetName':tabsObj[0].ccfieldSet}];
             console.log('objectinput'+JSON.stringify(objectinput));
             var inputstring = JSON.stringify(objectinput);
         // getFields({ objectName: CONTACT_OBJ, fieldSetName:  tabsObj[1].fieldSet})
         getFields({inputfields: inputstring})
                 .then((result) => {
                     var cols = [];
                     console.log('resonpse'+JSON.stringify(result));
                     for(var each in result){                       
                         this.fieldApiNames.push(each);
                         var col = {};
                         col.label = result[each][0];
                         
                         col.fieldName = (each.includes('.')) ? each.split('.')[1] : each;
                     
                     // col.fieldName = (each.includes('.')) ? each.replace('.', '_') : each;
                     
                         
                     /* if(result[each][1].includes('Contact__r.')){                              
                             for(var each in eachval['Contact__r']){
                                 if(each == 'Id'){
                                     eachval['contactid'] = eachval['Contact__r'][each];
                                 } else{
                                 eachval[each] = eachval['Contact__r'][each];
                                 }
                             }
                             
                             console.log('storeresult'+storeResult);
                         }*/
                         
                     
                         switch(result[each][1]){
                             case 'PICKLIST':
                                 col.type = 'text';
                                 break;
                             case 'STRING':
                                 col.type = 'text';
                                 break;
                             case 'BOOLEAN':
                                 col.type = 'boolean';
                                 break;
                             case 'EMAIL':
                                 col.type = 'email';
                                 break;
                             case 'DATE':
                                 col.type = 'date-local';
                                 col.typeAttributes = { year: "numeric", month: "short", day: "numeric" };
                                 break;
                             case 'DATETIME':
                                 col.type = 'date-local';
                                 col.typeAttributes = { year: "numeric", month: "short", day: "numeric" };
                                 break;
                             case 'DOUBLE':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'DECIMAL':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'NUMBER':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'PERCENT':
                                 col.type = 'percent';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2, };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             default:
                                 col.type = 'text';
                                 //console.log('default');
                         }
 
                     /*   if(each.includes('.') && (each.includes('Name') || each.includes('Number'))){
                             var lookupFieldName = each.split('.').reverse()[0];
                             this.lookupFields.push(each.replace('.', '_').replace(lookupFieldName, 'Id'));
                             col.type = 'url';
                             col.fieldName = each.replace('.', '_').replace(lookupFieldName, 'Id');
                             col.typeAttributes = { label: { fieldName: each.replace('.', '_') }, target: '_self' };
                         }*/
                         console.log('@@@----col.fieldName--->>>'+col.fieldName);
                         if(col.fieldName == 'Name'){
                             col.type = 'url';
                             col.fieldName = 'caseContactURL';
                             col.typeAttributes = {
                             label:{
                                 fieldName : 'Name'
                             },
                         
                         }
                         }
                         cols.push(col);
                     }
                     this.columns = cols;
                     console.log('cols'+JSON.stringify(this.columns));
 
                     return getAssignedCaseContacts({ searchTerm: this.searchTerm, supportcas: this.recordId, fields: this.fieldApiNames.join() });
                 })
                 .then((result) => {
                     //Promise for getAssignedCaseContacts()
                     console.log(JSON.stringify(result));
                     
                     if(result?.lstCaseContacts?.length > 0){ //<T02>
                         var storeResult = result.lstCaseContacts;
                         let mapContactIdAccessLevel = new Map(); //<T02>
                         result.lstAccountContacts.forEach(objAccountContact => { //<T02>
                             mapContactIdAccessLevel.set(objAccountContact.ContactId, objAccountContact.Access_Level__c);
                         });                                              
                         storeResult.forEach(eachval => {     
                             eachval['caseContactURL'] = '/lightning/r/Case_Contact__c/'+ eachval['Id']+'/view';
                         console.log('value'+eachval['Contact__r']);
                         if(eachval['Contact__r'] != undefined){                              
                             for(var each in eachval['Contact__r']){
                                 if(each == 'Id'){
                                         eachval['contactid'] = eachval['Contact__r'][each];
                                         eachval['Access_Level__c'] = mapContactIdAccessLevel.get(eachval['Contact__r'][each]); //<T02>
                                 } else{
                                     eachval[each] = eachval['Contact__r'][each];
                                 }
                             }
                             
                             console.log('storeresult'+storeResult);
                         }
                         
                         })
 
                         /*const index = array.indexOf('Contact__r');
                             if (index > -1) {
                                 storeResult.splice(index, 1);
                         }*/
 
                         this.lookupFields.forEach(lookupField => {
                             var fieldObj = lookupField.replace('_Id','');
                             storeResult.forEach(row => {
                                 if(row[fieldObj] != undefined){
                                     console.log('row[fieldObj] --> '+JSON.stringify(row[fieldObj]));
                                     console.log('typeof --> '+typeof(row[fieldObj]));
                                     console.log('Object.entries(row[fieldObj]) --> '+Object.entries(row[fieldObj]));
                                     for(const [key, value] of Object.entries(row[fieldObj])){
                                         console.log(Key);
                                         console.log(value);
                                         var fieldName = fieldObj+'_'+key;
                                         if(key === 'Id'){
                                             var objectName = fieldObj.includes('__r') ? fieldObj.replace('__r','__c') : fieldObj;
                                             console.log('objectName -> '+objectName);
                                             row[fieldName] = this.getRecordURL(objectName, value)
                                         }
                                         else{
                                             row[fieldName] = value;
                                         }
                                     }
                                     
                                 }
                             });                       
                         });
 
                         console.log('storeResult --> '+JSON.stringify(storeResult));
                         this.data = storeResult; 
                         
                         this.displayRemoveBTN = true;
                         this.displayAddBTN = false;
                     }
                     else{
                         this.NoDataAfterRendering = true;
                     }
                 
                 })
                 .catch((error) => {
                     //Promise for getAssignedCaseContacts()
                     console.log(JSON.stringify(error));
                 })
                 .catch((error) => {
                     //Promise for getFields()
                     console.log('promise error');
                     console.log(JSON.stringify(error));
                 })
         }
         else if(this.currentTabValue == UNASSIGNED_CONTACTS){
             this.data = undefined;
             var objectinput = [{'objectName':CONTACT_OBJ, 'fieldSetName':tabsObj[1].fieldSet, 'parentrelationship':'Contact.'}];
             console.log('objectinput'+JSON.stringify(objectinput));
             var inputstring = JSON.stringify(objectinput);
             this.fieldApiNames = [];
         // getFields({ objectName: CONTACT_OBJ, fieldSetName:  tabsObj[1].fieldSet})
         getFields({inputfields: inputstring})
                 .then((result) => {
                     var cols = [];
                     console.log(JSON.stringify(result));    
                             
                     for(var each in result){
                         
                         console.log('each value'+each);
                         var col = {};
                     // var fieldapi = 'Contact.' +each; 
                         this.fieldApiNames.push(each);
                         
                         col.label = result[each][0];
                         
                         col.fieldName = (each.includes('.')) ? each.split('.')[1] : each;
                         switch(result[each][1]){
                             case 'PICKLIST':
                                 col.type = 'text';
                                 break;
                             case 'STRING':
                                 col.type = 'text';
                                 break;
                             case 'BOOLEAN':
                                 col.type = 'boolean';
                                 break;
                             case 'EMAIL':
                                 col.type = 'email';
                                 break;
                             case 'DATE':
                                 col.type = 'date-local';
                                 col.typeAttributes = { year: "numeric", month: "short", day: "numeric" };
                                 break;
                             case 'DATETIME':
                                 col.type = 'date-local';
                                 col.typeAttributes = { year: "numeric", month: "short", day: "numeric" };
                                 break;
                             case 'DOUBLE':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'DECIMAL':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'NUMBER':
                                 col.type = 'number';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             case 'PERCENT':
                                 col.type = 'percent';
                                 col.typeAttributes = { minimumIntegerDigits: 1, maximumFractionDigits: 2, };
                                 col.cellAttributes = { alignment: 'left' };
                                 break;
                             default:
                                 col.type = 'text';
                                 //console.log('default');
                             
                         }
                         cols.push(col);
 
                     /*  if(each.includes('.') && (each.includes('Name') || each.includes('Number'))){
                             var lookupFieldName = each.split('.').reverse()[0];
                             this.lookupFields.push(each.replace('.', '_').replace(lookupFieldName, 'Id'));
                             col.type = 'url';
                             col.fieldName = each.replace('.', '_').replace(lookupFieldName, 'Id');
                             col.typeAttributes = { label: { fieldName: each.replace('.', '_') }, target: '_self' };
                         }*/                      
                     }
                     var col = {};
                     col.label = 'Is Primary?';
                     col.fieldName = 'Primary__c';   
                     col.type = 'boolean';  
                     cols.push(col);
                     this.columns = cols;
                     console.log('cols'+JSON.stringify(this.columns));
                    console.log('support account'+ getFieldValue(this.supportCase.data, SUPPORTACCOUNT));
                    console.log('ecom account'+ getFieldValue(this.supportCase.data, ACCOUNTID));
                    console.log('this.supportCase.data - '+JSON.stringify(this.supportCase.data));
 
                    //T03 set the account Id based on the record type
                    let accountId;
                    if(getFieldValue(this.supportCase.data, RECORDTYPE_NAME) == CASE_LITE){
                        accountId = getFieldValue(this.supportCase.data, ACCOUNTID);
                    }else{
                        accountId = getFieldValue(this.supportCase.data, SUPPORTACCOUNT);
                    }        
                    return getUnassignedCaseContacts({ searchTerm: this.searchTerm, caseid: this.recordId, supportAcc: accountId, supportcas: this.recordId, fields: this.fieldApiNames.join() });
                 })
                 .then((result) => {
                     //Promise for getUnassignedCaseContacts()
                     console.log(JSON.stringify(result));
                     if(result.length > 0){
                         var storeResult = result;                        
                                                                     
                         storeResult.forEach(eachval => {                           
                         console.log('value'+eachval['Contact']);
                         if(eachval['Contact'] != undefined){                              
                             for(var each in eachval['Contact']){
                                 if(each == 'Id'){
                                         eachval['contactid'] = eachval['Contact'][each];
                                 } else if(each != 'Access_Level__c'){ //<T02>
                                     eachval[each] = eachval['Contact'][each];
                                 }
                             }
                             
                             console.log('storeresult'+storeResult);
                         }
                         
                         })                  
 
                         console.log('storeResult --> '+JSON.stringify(storeResult));
                         this.data = storeResult; 
                         
                         this.displayRemoveBTN = false;
                         this.displayAddBTN = true;
                     }
                     else{
                         this.NoDataAfterRendering = true;
                     }
                 
                 })
                 .catch((error) => {
                     //Promise for getUnassignedCaseContacts()
                     console.log(JSON.stringify(error));
                 })
                 .catch((error) => {
                     //Promise for getFields()
                     console.log(JSON.stringify(error));
                 })
         }        
     }
 
     createCaseContact() {
         const fields = {};
         
         var caseconts = [];
         const selrows = JSON.parse(JSON.stringify(this.selectedRow));
         
         for (let i = 0; i < selrows.length; i++) {             
             var temprec = {};
             //temprec['Name'] = selrows[i].Name;
             temprec['Email'] = selrows[i].Email;
             temprec['Contact__c'] = selrows[i].contactid;
             temprec['Case__c'] = this.recordId;
             console.log('temprec'+temprec);
             caseconts.push(temprec);
         }
 
         
         if(caseconts != undefined && caseconts.length > 0){
             createcasecontactcontr({casecon: caseconts, supportAcc: getFieldValue(this.supportCase.data, SUPPORTACCOUNT)})
             .then(casecontact => {                
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Success',
                         message: 'Case Contact added successfully',
                         variant: 'success',
                     }),
                 );
                 this.handleRefresh();
             })
             .catch(error => {
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error adding Case contact record',
                         message: error.body.message,
                         variant: 'error',
                     }),
                 );
             });
         }
         else{
             this.showErrorMessage = 'Please select a Contact to add to the case'
         }
     }
 
     deleterec(event) {
         getMedataDataRecord({metadataRecordName: 'Case_Contact_Removal_Error_Message'}).then(metadata =>{
             console.log('deleted record'+JSON.stringify(this.selectedRow));
             let caseContactId = this.supportCase.data.fields.ContactId.value;
             var delcontacts = JSON.parse(JSON.stringify(this.selectedRow));
             var delcasecontacts = [];
             let primaryContacts = false;
             let canNotBeDeleted = false;
             let errorMessage = '';
             for (let i = 0; i < delcontacts.length; i++) {  
                 //var tempcontact  = {'Id':delcontacts[i].Id};                
                 delcasecontacts.push(delcontacts[i].Id);
                 if(delcontacts[i].Primary__c){
                     primaryContacts = true;
                     errorMessage = 'Cannot remove Primary Contacts.\n' ;
                 }
                 if(delcontacts[i].Contact__c == caseContactId){
                     canNotBeDeleted = true;
                     errorMessage += metadata.Error_Message__c;
                 }
             }
             if(primaryContacts || canNotBeDeleted){
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error removing Case contact record',
                         message: errorMessage,
                         variant: 'error',
                     }),
                 );
                 return;
             }
                 console.log('deleted record tempcontact'+delcasecontacts);
                 if(delcasecontacts != undefined && delcasecontacts.length > 0){
                     removeCaseContacts({casecon: delcasecontacts})
                     .then(() => {
                         this.dispatchEvent(
                             new ShowToastEvent({
                                 title: 'Success',
                                 message: 'Case Contact removed successfully',
                                 variant: 'success'
                             })
                         );
                         this.handleRefresh();
                     })
                     .catch(error => {
                         this.dispatchEvent(
                             new ShowToastEvent({
                                 title: 'Error removing Case Contact record',
                                 message: error.body.message,
                                 variant: 'error'
                             })
                         );
                     });
                 }
                 else{
                     this.showErrorMessage = 'Please select a Contact to remove from the case'
                 }     
         }).catch(error =>{
             console.log('Error occured while fetching getMedataDataRecord on Case Controller. : ' + errpr);
         });
         
     }
 
     //Disable actions when the case is closed
     get disableActionBTNs(){
         let caseStatus = getFieldValue(this.supportCase.data, STATUS);
         //console.log('caseStatus --> '+caseStatus);
         return caseStatus != undefined && 
             caseStatus != null &&  
             caseStatus !== 'Closed' ? true : false;
     }
 
 }