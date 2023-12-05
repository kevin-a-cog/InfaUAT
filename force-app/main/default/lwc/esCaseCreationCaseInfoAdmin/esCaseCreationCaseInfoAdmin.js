/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              08-Mar-2022     I2RT-5620           Get support account details                               T01
 Vignesh D              08-Aug-2022     I2RT-6864           Checkmarx security fixes                                  T02
 Vignesh D              31-Aug-2022     I2RT-6865           Replace promise returned from object to string            T03
 Vignesh D              31-Aug-2022     I2RT-6865           Pass alternate contacts description to child component    T04
 balajip                28-Oct-2022     I2RT-7212           to show the list of priority values in descending order   T05

 */

 import { LightningElement, api, track, wire } from 'lwc';
 import allSupportAccounts from '@salesforce/apex/CaseController.allSupportAccounts';
 import getCaseFieldsDropdownOptions from '@salesforce/apex/CaseController.getCaseFieldsDropdownOptions';
 import getAccountRelatedContacts from '@salesforce/apex/CaseController.getAccountRelatedContacts';
 import createCase from '@salesforce/apex/CaseController.createCase';
 import getUploadedFiles from '@salesforce/apex/CaseController.getUploadedFiles';
 import removeFile from '@salesforce/apex/CaseController.removeFile';
 import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
 import getCaseIRDateTime from '@salesforce/apex/CaseController.getCaseIRDateTime';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
 import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails';
 import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';            //Amarender -> I2RT-1020: eSupport: Solutions Page
 import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
 import EolGcsGuideUrl from '@salesforce/label/c.EOL_GCS_Guide';
 import { getRecord } from 'lightning/uiRecordApi';    
 import getServiceCloudMetadata from '@salesforce/apex/CaseController.getServiceCloudMetadata';  
 import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';
 import { log } from 'c/globalUtilities'; //Vignesh
 import getSupportAccountDetails from '@salesforce/apex/CaseController.getSupportAccountDetails'; // <T01>
 
 const CaseCreationFailureMessage_MD = 'eSupport_Case_Creation_Failure_Message';
 
 
 export default class EsCaseCreationCaseInfoAdmin extends LightningElement {
 
     @api proceedUrl;
     maximize = ESUPPORT_RESOURCE + '/maximize.png';
     signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons_signature.png';
 
     EolGcsGuide = EolGcsGuideUrl;
     
     @track showEolGuideAlert = false;
     @track showAdditionalCaseInformation = false;
     @track showCaseSummary = false;
     @track showAdminCaseInfo = true;
     @track showAlternateContactInfo = false;
     @track showAdditionalCaseInfo = false;
     @track isModalOpen = false;
     @track isCallBackModal = false;
     @track isRevisePriorityModal = false;
     @track isReopenCaseModal = false;
     @track isCloseCaseModal = false;
     @track isCreateContactModal = false;
     @track isAlternateContactModal = false;
     @track isDeleteModal = false;
     @track isEditModal = false;
     @track showUploadedFiles = false;
     @track isAttachmentDeletePopup = false;
     @track showCaseCancelModal = false;
     @track showSpinner = false;
     @track selectedContactList = [];
     @track allContactData = [];
     @track showProduct = false;
 
     @track iconName = 'utility:down';
     @track supportAccounts = [];
     @track selectedSupportAccount;
     @track selectedSupportAccountLabel;
     @track successOffering;
     @track priorities = [];
     @track selectedPriority;
     @track problemAreas = [];
     @track selectedProblemType;
     @track contactId;
     @track subject;
     @track description;
     @track caseInformation;
     @track recordTypeName = 'Administrative';
     @track caseInfo = {};
     @track uploadedFiles = [];
     @track fileToRemove = '';
     @track fileSize = 0;
     @track relatedContacts = [];
     @track alternateContact;
     @track contactsToAdd = [];
     @track caseContacts = [];
     @track caseDocuments = [];
     @track buttonLabel = 'Skip for now';
     @track selectedContact = 0;
     @track allContacts;
     @track caseResponseTime;
     @track selectedProblemArea;
     @track hasReadWriteAccess = false;
 
     @track triggerforsearch;                                    //For Case Deflection Search
     @track placedin = 'esupportcasedeflectiongeneralinquiry';    //For Case Deflection Search    
 
     @track prevPageURL = 'case';
     @track __createCaseFailMessageMD_ID;
     @track createCaseFailureMessage;
 
     strAlternateContactsDescription = 'You can include other Support Account contacts to this case so they can view & comment in the case. This step is optional, you can always add/delete contacts for this case later.'; //<T04>
 
     @wire(allSupportAccounts, {})
     supportAccountOptions({ data, error }) {
         if (data) {
             let supportAccountOptions = [];
             var previousurl=encodeURI(document.referrer);//get previous page url //<T02>
             var accid=previousurl.slice(previousurl.length-18,previousurl.length); 
             if(accid.length==18)
                 this.selectedSupportAccount=(accid);
             for (var i in data) {
                 supportAccountOptions.push({ label: data[i].label, value: data[i].value });
             }
             this.supportAccounts = supportAccountOptions;
             log('supportAccountOptions = ' + JSON.stringify(this.supportAccounts));
 
             // //Get the AccountId from the URL
             // let url = new URL(window.location.href);
 
             // let accountId = url.searchParams.get("accountId");
             //this.selectedSupportAccount = accountId;
             var customEvent = { detail: { value : { } } };
             customEvent.detail.value = this.selectedSupportAccount;
             this.handleAccountSelect(customEvent);
             
         } else {
             log('GetContact Error= ' + JSON.stringify(error));
         }
     }
 
     @wire(getCaseFieldsDropdownOptions, {})
     dropdownOption({ data, error }) {
         if (data) {
 
             let priorityOptions = [];
             let problemAreaOptions = [];
             log('data= ' + data);
             this.contactId = data.contactId;
 
             //T05 - order the priority values in the descending order.
             let priorityList = [];
             data.priorities.forEach(element => {
                priorityList.push(element.value);                 
             });
             priorityList.reverse();
             priorityList.forEach(element => {
                priorityOptions.push({ label: element, value: element }); 
             });             
             this.priorities = priorityOptions;

             for (var i in data.problemAreas) {
                 problemAreaOptions.push({ label: data.problemAreas[i].value, value: data.problemAreas[i].value });
             }
             this.problemAreas = problemAreaOptions;
         } else {
             log('Error getting dropdown ' + JSON.stringify(error));
         }
     }
 
     @wire(getRecord, { recordId: '$__createCaseFailMessageMD_ID', fields: 'Service_Cloud_General_Setting__mdt.eSupport_Error_Message__c' })
     metaRecord({ error, data }) {
         if(data){
             log('metaRecord data => '+JSON.stringify(data));
             this.createCaseFailureMessage = data?.fields?.eSupport_Error_Message__c?.value;
         }
         else if(error){
             log('metaRecord error => '+error);
         }
     }
 
     connectedCallback(){
         //Vignesh D -> I2RT-3939: Handle Case Creation error
         getServiceCloudMetadata({ metadataName: CaseCreationFailureMessage_MD })
             .then(result => {
                 log('Case Creation Failure Message metadata Id => '+result);
                 this.__createCaseFailMessageMD_ID = result;
             })
             .catch(error => {
                 log('Metadata error => '+error);
             });
         if(sessionStorage.getItem('admin_account') != null && window.performance.navigation.type != 2){
             this.selectedSupportAccount = sessionStorage.getItem('admin_account');
             if(sessionStorage.getItem('admin_priority') != null){
                 this.selectedPriority = sessionStorage.getItem('admin_priority');
             }
             if(sessionStorage.getItem('admin_area') != null){
                 this.selectedProblemArea = sessionStorage.getItem('admin_area');
             }
             if(sessionStorage.getItem('admin_sub') != null){
                 this.subject = sessionStorage.getItem('admin_sub');
             }
             if(sessionStorage.getItem('admin_desc') != null){
                 this.description = sessionStorage.getItem('admin_desc');
             }
             if(this.selectedSupportAccount !== undefined && this.selectedSupportAccount !== null && this.selectedSupportAccount !== ''){
                 this.handleGetSupportContactdetails();
                 this.getSupportAccountDetails(); // <T01>
             }
         }  
     }
 
     handleAccountSelect(event) {
         this.selectedSupportAccount = event.detail.value;
         this.prevPageURL = 'newcase?accountId=' + event.detail.value;
         sessionStorage.setItem('admin_account', event.detail.value);
         let accountId = this.selectedSupportAccount;
         let accountName = '';
         let supportAccounts = [];
         supportAccounts = this.supportAccounts;
         log('supportAccounts= ' + JSON.stringify(supportAccounts));
         log('accountId= ' + accountId);
         for (var i in supportAccounts) {
             if (supportAccounts[i].value == accountId) {
                 accountName = supportAccounts[i].label;
             }
         }
         this.selectedSupportAccountLabel = accountName;
         sessionStorage.setItem('prod_accountName', accountName);  //For Case Deflection Search  
 
         getAccountRelatedContacts({ recordId: this.selectedSupportAccount })
             .then(result => {
                 this.relatedContacts = result;
                 this.allContacts = this.relatedContacts.length;
                 //this.successOffering = this.relatedContacts[0].Account.Success_Offering__c; commented as part of <T01>
                 log('RelatedContacts= ' + JSON.stringify(this.relatedContacts));
             });
         this.handleGetSupportContactdetails();
         this.getSupportAccountDetails(); // <T01>
     }
 
     handlePriorityChange(event) {
         this.selectedPriority = event.detail.value;
         sessionStorage.setItem('admin_priority', this.selectedPriority);
 
     }
 
     handleSubjectChange(event) {
         this.subject = event.detail.value;
         sessionStorage.setItem('admin_sub', this.subject);
 
     }
 
     handleProblemAreaChange(event){
         this.selectedProblemArea = event.detail.value;
         if (this.selectedProblemArea == 'End of Support') {
             this.showEolGuideAlert = true;
         }
         else {
             this.showEolGuideAlert = false;
         }
         sessionStorage.setItem('admin_area', this.selectedProblemArea);
     }
 
     // openEolGcsGuide() {
     //     window.open(EolGcsGuideUrl, '_self');
     // }
 
     handleDescriptionChange(event) {
         this.description = event.detail.value;
         sessionStorage.setItem('admin_desc', this.description);
 
     }
 
     showAlternateContact() {
         if(this.hasReadWriteAccess){
             var isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input, lightning-textarea')]
             .reduce((validSoFar, inputField) => {
                 inputField.reportValidity();
                 return validSoFar && inputField.checkValidity();
             }, true);
             if (isValidValue){
                 this.caseInformation = this.selectedPriority + ' | Subject : ' + this.subject;
                 this.showCaseSummary = false;
                 this.showAdminCaseInfo = false;
                 this.showAlternateContactInfo = true;
                 window.scrollTo(0, 0);
             }
         }
         else{
             this.showToastEvent('Error', 'You do not have access to create case for this Support Account.', 'error', 'dismissable');
         }
     }
 
     ShowfinalSummary(event) {
         this.contactsToAdd = event.detail.finalContactList;
         //this.allContactData = event.detail.allContactsToAdd;
         this.allContactData = this.contactsToAdd;
         if (this.contactsToAdd.length > 1) {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         } else {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         }
 
         this.showCaseSummary = true;
         this.showAdminCaseInfo = false;
         this.showAlternateContactInfo = false;
         var caseObj = {};
         caseObj.category = 'Administrative';
         caseObj.priority = this.selectedPriority;
         caseObj.problemArea = this.selectedProblemType;
         caseObj.supportAccount = this.selectedSupportAccountLabel;
         caseObj.successOffering = this.successOffering;
         caseObj.subject = this.subject;
         caseObj.description = this.description;
         caseObj.attachments = this.fileSize;
         caseObj.contacts = [];
         caseObj.contacts = this.contactsToAdd;
         this.caseInfoToSave = caseObj;
         
         /*
         getResponseTimeForCase({accountId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: ''})
         .then(result => {
             
             this.caseResponseTime = result;
             log('caseReaponse time= '+this.caseResponseTime);
         })
         .catch(error => {
             log('error while getting response time'+JSON.stringify(error));
         });
         */
         getCaseIRDateTime({supportAccId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: ''})
         .then(result => {
             
             this.caseResponseTime = result;
             log('caseReaponse time= '+this.caseResponseTime);
         })
         .catch(error => {
             log('error while getting response time'+JSON.stringify(error));
         });
         window.scrollTo(0, 0);
     }
 
     backToAlternateContact(event) {
         let preselectedContactList = event.detail.contacts;
         let preselectedContactsPerPage = event.detail.contactList;
         this.selectedContactList = [];
         for(let i = 0; i < preselectedContactList.length; i++){
             this.selectedContactList.push(preselectedContactList[i].ContactId);
         }
         this.allContactData = preselectedContactsPerPage;
         this.showCaseSummary = false;
         this.showAdminCaseInfo = false;
         this.showAlternateContactInfo = true;
         window.scrollTo(0, 0);
     }
 
     backToAdminCaseInfo(event) {
         let preselectedContactList = event.detail.finalContactList;
         //this.allContactData = event.detail.allContactsToAdd;
         this.allContactData = preselectedContactList;
 
         this.selectedContactList = [];
         for(let i = 0; i < preselectedContactList.length; i++){
             this.selectedContactList.push(preselectedContactList[i].ContactId);
         }
         log('admin case info');
         this.showCaseSummary = false;
         this.showAdminCaseInfo = true;
         this.showAlternateContactInfo = false;
         window.scrollTo(0, 0);
     }
 
     saveCase(event) {
         this.showSpinner = true;
         document.body.setAttribute('style', 'overflow: hidden;');
         let contacts = [];
         contacts = event.detail;
         var caseObj = {};
         caseObj.Support_Account__c = this.selectedSupportAccount;
         caseObj.Priority = this.selectedPriority;
         caseObj.Problem_Area__c = this.selectedProblemArea;
         caseObj.Description = this.description;
         caseObj.Subject = this.subject;
         createCase({ caseJson: JSON.stringify(caseObj), recordTypeName: this.recordTypeName, caseRelatedContacts: contacts })
             .then(strCaseId => { //<T03>
                 this.handleCaseDeflectionOnSubmit(); //For Case Deflection Search
                 var url = CommunityURL + 'casedetails?caseId=' + strCaseId;
                 window.open(url, '_self');
                 this.showCaseSummary = false;
                 this.showAdminCaseInfo = false;
                 this.showAlternateContactInfo = false;
                 this.showSpinner = false;
                 document.body.removeAttribute('style', 'overflow: hidden;');
                 /** START-- adobe analytics */
                 try {
                     util.trackCreateCase("Support Account Administration", "Completed");
                 }
                 catch(ex) {
                     log(ex.message);
                 }
                 /** END-- adobe analytics*/
             })
             .catch( error => {
                 this.showSpinner = false;
                 log('Error @CreateCase: '+JSON.stringify(error));
                 if(DEBUG === 'true' && error?.body?.message){   
                     this.showToastEvent('Error', error.body.message, 'error', 'dismissable');
                 }
                 else{
                     this.showToastEvent('Error', this.createCaseFailureMessage, 'error', 'dismissable');
                 }
             });
             this.clearSessionData();
     }
 
 
     handleChange(event) {
         this.value = event.detail.value;
     }
 
     addItem(event) {
         var isChecked = event.detail.checked;
         var contact = event.target.value;
         let contacts = this.contactsToAdd;
         let allContacts = this.relatedContacts;
         log('contact- ' + event.target.value);
         log('isChecked- ' + isChecked);
         if (isChecked) {
             if (contacts.length === 0) {
                 let newContact = [];
                 for (var j in allContacts) {
                     if (allContacts[j].Id == contact) {
                         newContact.push(allContacts[j]);
                     }
                 }
                 this.contactsToAdd = newContact;
             } else {
                 for (var i in contacts) {
                     if (contacts[i].Id !== contact) {
                         for (var j in allContacts) {
                             if (allContacts[j].Id == contact) {
                                 contacts.push(allContacts[j]);
                             }
                         }
                     }
                 }
                 this.contactsToAdd = contacts;
             }
 
         } else {
             var newContactList = [];
             for (var i in contacts) {
                 if (contacts[i].Id !== contact) {
                     newContactList.push(contacts[i]);
                 }
             }
             this.contactsToAdd = newContactList;
         }
         if (this.contactsToAdd.length > 1) {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         } else {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         }
         if (this.contactsToAdd.length === 0) {
             this.buttonLabel = 'Skip for now';
         } else {
             this.buttonLabel = 'Proceed';
         }
         this.selectedContact = this.contactsToAdd.length;
         log('contactsToAdd= ' + JSON.stringify(this.contactsToAdd));
     }
 
     openModal() {
         this.isModalOpen = true;
     }
 
     closeModal() {
         this.isModalOpen = false;
     }
 
     openCallBackModal() {
         this.isCallBackModal = true;
     }
     closeCallBackModal() {
         this.isCallBackModal = false;
     }
     openRevisePriorityModal() {
         this.isRevisePriorityModal = true;
     }
     closeRevisePriorityModal() {
         this.isRevisePriorityModal = false;
     }
     openReopenCaseModal() {
         this.isReopenCaseModal = true;
     }
     closeReopenCaseModal() {
         this.isReopenCaseModal = false;
     }
     openCloseCaseModal() {
         this.isCloseCaseModal = true;
     }
     closeCloseCaseModal() {
         this.isCloseCaseModal = false;
     }
     openAlternateContactModal() {
         this.isAlternateContactModal = true;
     }
     openCreateContactModal() {
         this.isCreateContactModal = true;
     }
     closeCreateContactModal() {
         this.isCreateContactModal = false;
     }
     closeAlternateContactModal() {
         this.isAlternateContactModal = false;
     }
     openDeleteModal() {
         this.isDeleteModal = true;
     }
     closeDeleteModal() {
         this.isDeleteModal = false;
     }
     openEditModal() {
         this.isEditModal = true;
     }
     closeEditModal() {
         this.isEditModal = false;
     }
 
     handleToggle(event) {
         this.buttonClicked = !this.buttonClicked;
         let currentSection = event.target;
         let targetSection = event.target.dataset.targetId;
         this.template.querySelector(`[data-id="${targetSection}"]`).classList.toggle('slds-hide');
         currentSection.iconName = this.buttonClicked ? 'utility:right' : 'utility:down';
     }
 
     buttonClickedCaseInfo = true;
     handleToggleCaseInfo() {
         this.buttonClickedCaseInfo = !this.buttonClickedCaseInfo;
     }
     get iconNameCaseInfo() {
         return this.buttonClickedCaseInfo ? 'utility:down' : 'utility:right';
     }
 
     get acceptedFormats() {
         let acceptedFileFormates = [];
         getAcceptedFileFormates({})
             .then(result => {
                 acceptedFileFormates = result;
             });
         log('acceptedFileFormates= ' + JSON.stringify(acceptedFileFormates));
         return acceptedFileFormates;
     }
 
     handleUploadFinished(event) {
         // Get the list of uploaded files
         this.showSpinner = true;
         const uploadedFiles = event.detail.files;
         let message = ' File is attached';
         if (uploadedFiles.length > 1) {
             message = ' Files are attached';
         }
         this.fileSize = uploadedFiles.length + message;
         getUploadedFiles()
             .then(result => {
                 if (result) {
                     log('result= ' + JSON.stringify(result));
                     this.uploadedFiles = result;
                     this.showUploadedFiles = true;
                 }
                 this.showSpinner = false;
             });
     }
 
     removeAttachment(event) {
         this.fileToRemove = event.target.value;
         this.isAttachmentDeletePopup = true;
     }
 
     confirmFileRemove() {
         log('confirmFileRemove');
         this.showSpinner = true;
         removeFile({ documentId: this.fileToRemove, isDetailPage: false })
             .then(result => {
                 if (result) {
                     log('result= ' + JSON.stringify(result));
                     this.uploadedFiles = result;
                     if (this.uploadedFiles.length === 0) {
                         this.showUploadedFiles = false;
                     }
                     this.isAttachmentDeletePopup = false;
                     let message = ' File is attached';
                     if (this.uploadedFiles.length > 1) {
                         message = ' Files are attached';
                     }
                     this.fileSize = this.uploadedFiles.length + message;
                 }
                 this.showSpinner = false;
             });
     }
 
     cancelFileRemove() {
         this.fileToRemove = '';
         this.isAttachmentDeletePopup = false;
     }
 
     showCancelpopup() {
         this.showCaseCancelModal = true;
     }
 
     hideCancelPopup() {
         this.showCaseCancelModal = false;
     }
 
     backButton(){
         window.open(this.prevPageURL, '_self');
     }
 
     goPrevPage(event) {
         this.handleCaseDeflectionOnCancel(); //For Case Deflection Search
         event.preventDefault();
         this.clearSessionData();
         this.hideCancelPopup();
         window.open(this.prevPageURL, '_self');
     }
 
     clearSessionData(){
         sessionStorage.removeItem('admin_account');
         sessionStorage.removeItem('admin_priority');
         sessionStorage.removeItem('admin_area');
         sessionStorage.removeItem('admin_sub');
         sessionStorage.removeItem('admin_desc');
     }
 
     downloadDoc(event){
         log('row details : ' + event.detail);
         log(event.currentTarget.dataset.id);
         let url = '/sfc/servlet.shepherd/document/download/' + event.currentTarget.dataset.id;
         window.open(url,'_self');
     }
 
     handleGetSupportContactdetails(){
         getSupportContactDetails({ caseId: '', supportAccountId: this.selectedSupportAccount })
         .then(result => {
             if(result != undefined && result != null){
                 this.hasReadWriteAccess = result.isReadWrite;
             }
         })
         .catch(error => {
             log('Contact details Error => '+JSON.stringify(error))
         });
     }
 
     //---------------------------------------<T01>--------------------------------
     /*
     Method Name : getSupportAccountDetails
     Description : This method gets support account details.
     Parameters	 : None
     Return Type : None
     */
     getSupportAccountDetails(){
         getSupportAccountDetails({ supportAccountId: this.selectedSupportAccount })
         .then(objSupportAccount => {
             this.successOffering = objSupportAccount?.Success_Offering__c;
         })
         .catch(objError => {
             log('ERROR while getting support account details: '+JSON.stringify(objError));
         });
     }
     //---------------------------------------</T01>-------------------------------
 
     showToastEvent(title, message, variant, mode) {
         const event = new ShowToastEvent({
             title,
             message,
             variant,
             mode
         });
         this.dispatchEvent(event);
     }
 
     //For Case Deflection Search  - Start
     handleSearchDataOnBlur(event) {
         try {
             var varTargetName = '';
             if (event.target.name != undefined)
                 varTargetName = event.target.name;
             this.triggerforsearch = Math.random().toString() + '###$$$$####' + varTargetName;
             log('Method : handleSearchDataOnBlur ');
         } catch (error) {
             console.error('Method : handleSearchDataOnBlur; Error :' + error.message + ' : ' + error.stack);
         }
     }
 
     handleCaseDeflectionOnSubmit() {
         try {
             if (Coveo != undefined) {
                 var submitEventCause = { name: 'submitButton', type: 'caseCreation' };
                 var metadata = {};
                 Coveo.logCustomEvent(window.CustomCoveoCaseDflection, submitEventCause, metadata);
             
                 var unloadEventCause = { name: 'unloadPage', type: 'caseCreation' };
                 Coveo.logCustomEvent(window.CustomCoveoCaseDflection, unloadEventCause, metadata);
                 log('Method : handleCaseDeflectionOnSubmit ');
             }
         } catch (error) {
             console.error('Method : handleCaseDeflectionOnSubmit; Error :' + error.message + ' : ' + error.stack);
         }
     }
 
     handleCaseDeflectionOnCancel() {
         try {
             if (Coveo != undefined) {
                 var cancelEventCause = { name: 'cancelButton', type: 'caseCreation' };
                 var metadata = {};
                 Coveo.logCustomEvent(window.CustomCoveoCaseDflection, cancelEventCause, metadata);
             
                 //var unloadEventCause = { name: 'unloadPage', type: 'caseCreation' };
                 //Coveo.logCustomEvent(window.CustomCoveoCaseDflection, unloadEventCause, metadata);
                 log('Method : handleCaseDeflectionOnCancel ');
             }
         } catch (error) {
             console.error('Method : handleCaseDeflectionOnCancel; Error :' + error.message + ' : ' + error.stack);
         }
     }
     //For Case Deflection Search  - End
 
 }