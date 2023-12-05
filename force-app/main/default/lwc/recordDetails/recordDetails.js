/*
 Change History
 *************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                           Tag
 *************************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                                      NA
 Vignesh Divakaran      27-May-2022     I2RT-6153           Show GCS Segment and move Old Case Number field all the way down      T01            
 Vignesh Divakaran      02-Jun-2022     I2RT-6401           Show GCS Segment only for Technical and Operations case               T02         
 Vignesh Divakaran      07-Jul-2022     I2RT-5855           Hide ACC flag                                                         T03       
 balajip                22-Aug-2022     I2RT-6867           Case Lite changes                                                     T04       
 balajip                14-Sep-2022     I2RT-6867           Made Priority field editable for Lite Cases                           T05       
 balajip                30-Mar-2023     I2RT-7839           Replaced the standard Owner field with custom formula field           T06       
  Sandeep Duggi          28-Mar-2023     I2RT-7883          Bring the ACC flag back in Support Account and Case Layou                          T07       

*/
 import { LightningElement, api, track, wire } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
 import CASE_STATUS from '@salesforce/schema/Case.Status';
 import CASE_DESCRIPTION from '@salesforce/schema/Case.Description';
 import CASE_TYPE from '@salesforce/schema/Case.RecordType.Name'; //<T02>
 import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';
 
 const fields = [CASE_STATUS,CASE_DESCRIPTION,CASE_TYPE]; //<T02>
 //<T02>
 const CASE_TECHNICAL = 'Technical';
 const CASE_OPERATIONS = 'Operations';
 const CASE_ADMIN = 'Administrative';
 const CASE_SHIPPING = 'Fulfillment';
 const CASE_AAE = 'Ask An Expert';
 const CASE_LITE = 'Case Lite'; //T04
 
 function log(message){
     if(DEBUG !== undefined && DEBUG !== null && DEBUG === 'true'){
         console.log(message);
     }
 }
 
 export default class CaseLayout extends LightningElement {
 
     @api recordId;
     @track isEditable = false;
     @track saveMessageTitle = 'Success';
     @track saveMessage = 'Case has been updated successfully';
 
     @track sObjectName = 'Case';
     
     //T04 - included Case Lite type for applicable fields
     @track recordFields = [
         {label: "Priority", name: 'Priority', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, required: true,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false, lockForTypes: []}, //T05
         {label: "Status", name: 'Status', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Support Account", name: 'Support_Account__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: false, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE], show: false, hide:false},
         {label: "Product", name: 'Forecast_Product__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: false, required: true,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Version", name: 'Version__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: true,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE], show: false, hide:false},
         {label: "Owner", name: 'Owner__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false}, //T06
         {label: "Next Action", name: 'Next_Action__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Created Date", name: 'CreatedDate', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Last Activity Date", name: 'Case_Last_Activity__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "ACC", name: 'Acc__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE], show: false, hide:false}, //<T03> //<T07>
         {label: "Business", name: 'Business_Indicator__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "GCS Segment", name: 'GCS_Segment__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS], show: false, hide:false}, //<T01>
         {label: "Case Timezone", name: 'Case_Timezone__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: false, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Subject", name: 'Subject', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: false, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Description", name: 'Description', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: false, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE, CASE_LITE], show: false, hide:false},
         {label: "Old Case Number", name: 'Old_Case_Number__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false,showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING, CASE_AAE], show: false, hide:false} //<T01>
     ];;
 
     // Track changes to main properties
     @track isLoading = false;
     @track isEditing = false;
     @track hasChanged = false;
     @track isSaving = false;
     @track showFooter = false;
     @track showEdit = true;
     @track caseStatus;
 
     @wire(getRecord, { recordId: '$recordId', fields })
     fieldsData({data, error}){
         if(data){
             log('DATA getRecord->'+JSON.stringify(data));
             if(data.fields.Description != undefined && data.fields.Description != null){
                 this.caseDescription = data.fields.Description.value;
             }
             if(data.fields.Status != undefined && data.fields.Status.value != null){
                 this.caseStatus = data.fields.Status.value;
                 
                 if(this.caseStatus !== 'Closed' && this.caseStatus !== 'Cancelled' && this.caseStatus !== 'Delivered'){
                     this.isEditable = true;
                 }
                 else if(this.caseStatus === 'Closed' || this.caseStatus === 'Cancelled' || this.caseStatus === 'Delivered'){
                     this.isEditable = false;
                 }
             }
             if(data?.fields?.RecordType?.displayValue !== undefined && data?.fields?.RecordType?.displayValue !== null && data?.fields?.RecordType?.displayValue !== ''){ //<T02>
                 this.recordFields.forEach(field => {
                     if(field.showCaseTypes.includes(data?.fields?.RecordType?.displayValue)){
                         if(!field.hide){
                             field.show = true;
                         }
 
                         //T04 - make the field not editable based on the types specified in the attribute lockForTypes
                         if(field.lockForTypes != undefined && field.lockForTypes.includes(data?.fields?.RecordType?.displayValue)){
                             if(field.updateable){
                                 field.updateable = false;
                                 field.showEditPencil = false;
                             }
                         }
                     }
                 });
             }
         }
         else if(error){
             log('CaseLayout::ERROR @wire getRecord->'+JSON.stringify(error));
         }
     }
 
     // Show spinner error property
     get showSpinner() {
         return this.isLoading || this.isSaving;
     }
 
     // Show the record form
     get showForm() {
         return !this.isLoading && !!this.sObjectName;
     }
 
     // Check if we can edit
     get editLabel() {
         return 'Edit';
     }
 
     // Check if we can edit
     get canEdit() {
         return this.isEditable;
     }
 
     // Check if we can save, we need fields
     get canSave() {
         return this.canEdit && this.isEditing && this.hasChanged;
     }
 
     // Show a UI Message
     showToastEvent(title, message, variant) {
         const event = new ShowToastEvent({
             title,
             message,
             variant
         });
         this.dispatchEvent(event);
     }
 
     // Toggle editable state
     toggleEdit() {
         var borders = this.template.querySelectorAll('.custom-col-size-9');
         borders.forEach(element =>{
             element.classList.remove('slds-border_bottom');
         });
 
         if (this.canEdit){
             this.isEditing = !this.isEditing;
             this.showEdit = !this.showEdit;
             this.showFooter = true;
         }
 
         this.recordFields.forEach((field) => {
             field.editable = field.updateable;
             field.showEditPencil = !field.updateable;
         });
     }
 
     toggleCancel(){
         var borders = this.template.querySelectorAll('.custom-col-size-9');
         borders.forEach(element =>{
             element.classList.add('slds-border_bottom');
         });
         if (this.canEdit){
             this.isEditing = !this.isEditing;
             this.showEdit = !this.showEdit;
             this.showFooter = false;
         }
 
         this.recordFields.forEach((field) => {
             field.editable = false;
             field.showEditPencil = field.updateable;
         });
     }
 
     // Set the has changed to true
     setHasChanged() {
         this.hasChanged = true;
     }
 
     // Handle the form Submit callback
     handleFormSubmit() {
         this.isSaving = true;
     };
 
     // Handle the form Success callback
     handleFormSuccess() {
         this.isSaving = false;
         this.hasChanged = false;
         this.showToastEvent(this.saveMessageTitle, this.saveMessage, 'success');
         this.toggleCancel();
         getRecordNotifyChange([{recordId: this.recordId}]);
     };
 
     // Handle the form Error callback
     handleFormError(event) {
         this.isSaving = false;
         //this.showToastEvent('Error', event.detail.message, 'error');
     };
 
 }