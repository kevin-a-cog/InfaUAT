/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              08-Mar-2022     I2RT-5620           Show differemt success offering icons                     T01
 */

 import { LightningElement, track, api } from 'lwc';
 import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
 import { log } from 'c/globalUtilities'; //Vignesh
 
 export default class EsCaseCreationSummary extends LightningElement {
     //signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons_signature.png';
     @track isModalOpen = false;
     @track notAvailableAltContact=false;
     @api showEnvironment = false;
     @api showProduct = false;
     @api showProblemArea= false;
     @api showRelatedComponent= false;
     @api showStrengthMeter= false;
     @api showAdditionalCaseInformation= false;
     @api caseType;
     @api caseInformation;
     @api category;
     @api problemArea;
     @api product;
     @api environment;
     @api proceedUrl;
     @api goBackUrl;
     @api fileSize;
     @api alternateContact;
     @api caseInfoToSave;
     @api caseInfo;
     @api caseResponseTime;
     @api contactList;
 
     @track contacts =[];
     @track contactToRemove;
     @track showStrangthBar = false;
     @track descriptionQuality;
     successOfferingIcon; // <T01>
     connectedCallback(){
         this.contacts = this.caseInfo.contacts;
         log("datafromtech: "+JSON.stringify(this.caseInfo));
         log('contactList: '+JSON.stringify(this.contactList));
         if(this.caseInfo.category == 'Technical' && this.caseInfo.percentage != undefined && this.caseInfo.percentage.substring(0, this.caseInfo.percentage.length - 1) > -1){
             this.showStrangthBar = true;
         }
 
         //---------------------------------------<T01>--------------------------------
         switch(this.caseInfo?.successOffering){
             case 'Signature Select':
                 this.successOfferingIcon = ESUPPORT_RESOURCE + '/license_icons-03.svg';
                 break;
             case 'Signature Success':
                 this.successOfferingIcon = ESUPPORT_RESOURCE + '/license_icons-03.svg';
                 break;
             case 'Premium Success':
                 this.successOfferingIcon = ESUPPORT_RESOURCE + '/license_icons-02.svg';
                 break;
             case 'Standard':
                 this.successOfferingIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';
                 break;
             case 'Basic Success':
                 this.successOfferingIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';
                 break;
             default: 
                 //Do nothing
                 break;
         }
         //---------------------------------------</T01>--------------------------------
     }
 
     renderedCallback(){
         if (this.contacts.length == 0){
             this.notAvailableAltContact = true;
         }
         if(this.showStrangthBar){
             this.makeStrengthIndicatorDefault();
             this.applyClasstoStrengthIndicator(this.caseInfo.strengthColor);
         }
     }
     
     get showPercentage(){
         return `width:${this.caseInfo.percentage};`;
     }
 
     applyClasstoStrengthIndicator(color) {
         var id = "strengthBar";
         var className = "es-case-summary__strength-indicator--" + color;
         var element = this.template.querySelector('[data-id=' + id + ']');
         element.classList.add(className.trim());
         switch(color){
             case "red":
                 this.descriptionQuality = "Poor";
                 break;
             case "amber":
                 this.descriptionQuality = "Fair";
                 break;
             case "green":
                 this.descriptionQuality = "Strong";
                 break;
         }
 }
 
     makeStrengthIndicatorDefault(){
         var id = "strengthBar";
         var element = this.template.querySelector('[data-id=' + id + ']');
         if (element.classList.contains("es-case-summary__strength-indicator--red")) {
             element.classList.remove("es-case-summary__strength-indicator--red");
         }
         if (element.classList.contains("es-case-summary__strength-indicator--green")) {
             element.classList.remove("es-case-summary__strength-indicator--green");
         }
         if (element.classList.contains("es-case-summary__strength-indicator--amber")) {
             element.classList.remove("es-case-summary__strength-indicator--amber");
         }
 }   
 
     saveCase(){
         const clickEvent = new CustomEvent('confirmcasecreate', { detail: this.contacts, bubbles: true });
         // Dispatches the event.
         this.dispatchEvent(clickEvent);
         log('called Now--->')
     }
 
     backToAlternateContact(){
         const finalContactList = {
             contacts: this.contacts,
             contactList: this.contacts
         }
         log('finalContactList: '+JSON.stringify(finalContactList));
         const clickEvent = new CustomEvent('backtoalternatecontact', { detail: finalContactList, bubbles: true });
         // Dispatches the event.
         this.dispatchEvent(clickEvent);
         log('back to--->')
     }
 
     deleteContact(){
         var contactId = this.contactToRemove;
         let allContacts = this.contacts;
         let newList = [];
         for(var i in allContacts){
             if(allContacts[i].Id !== contactId){
                 newList.push(allContacts[i]);
             }
         }
         this.contacts = newList;
 
         let newContactList = [];
         /*for(let page in this.contactList){
             let selectedRowsWithPage = {
                 pagenumber : this.contactList[page].pagenumber,
                 selectedRows : []
             };
             let selectedRows = this.contactList[page].selectedRows;
             for(let row in selectedRows){
                 if(selectedRows[row].Id != contactId){
                     selectedRowsWithPage.selectedRows.push(selectedRows[row]);
                 }
             }
             newContactList.push(selectedRowsWithPage);
         }*/
         //this.contactList = newContactList;
         this.contactList = newList;
         this.isModalOpen = false;
     }
 
     openModal(event) {
         this.contactToRemove = event.target.value;
         log('@@IdToRemove- '+this.contactToRemove);
         this.isModalOpen = true;
     }
     closeModal() {
         this.isModalOpen = false;
     }
     submitDetails() {
         this.isModalOpen = false;
     }
 
     cancelProcess(){
         //Go to the cancel Process
         const cancelEvent = new CustomEvent('cancel', { detail: '', bubbles: true });
         // Dispatches the event.
         this.dispatchEvent(cancelEvent);
     }
     
     getCount() {
         let counter = 1;
         while (counter <= 5) {
             log(counter);
             counter = counter + 1;
         }
     }
     data = [
         {
             id: 1,
             firstName: 'Raj',
             lastName: 'Khanna',
             email: 'rk@abc.com',
             phoneNumber: '+(901) 987867863'
         },
         {
             id: 2,
             firstName: 'Raj',
             lastName: 'Khanna',
             email: 'rk@abc.com',
             phoneNumber: '+(901) 987867863'
         }
     ]
     
     get showCaseResponseTime(){
         return this.caseResponseTime !== undefined && this.caseResponseTime !== null && this.caseResponseTime !== '' ? true : false;
     }
 
 }