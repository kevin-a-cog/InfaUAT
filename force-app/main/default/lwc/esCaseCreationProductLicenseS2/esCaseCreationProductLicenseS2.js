/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              22-Nov-2021     I2RT-4833           Show Help Text next to Delivery Method                    T01
 Vignesh D              08-Mar-2022     I2RT-5620           Get support account details                               T02
 Vignesh D              08-Aug-2022     I2RT-6864           Checkmarx security fixes                                  T03
 Vignesh D              31-Aug-2022     I2RT-6865           Replace promise returned from object to string            T04
 Vignesh D              31-Aug-2022     I2RT-6865           Pass alternate contacts description to child component    T05
 Amit G                 25-Oct-2022     I2RT-7221           commented out the method to remove validation check       T06
 balajip                28-Oct-2022     I2RT-7212           to show the list of priority values in descending order   T07
 balajip                12-Jan-2023     I2RT-7257           added logic to capture the fields OrgId and Secure Agent  T08
 */

 import { LightningElement, api, track, wire } from 'lwc';
 import allSupportAccounts from '@salesforce/apex/CaseController.allSupportAccounts';
 import getCaseFieldsDropdownOptions from '@salesforce/apex/CaseController.getCaseFieldsDropdownOptions';
 import getProducts from '@salesforce/apex/CaseController.getProducts';
 import getAccountRelatedContacts from '@salesforce/apex/CaseController.getAccountRelatedContacts';
 import createCase from '@salesforce/apex/CaseController.createCase';
 import getUploadedFiles from '@salesforce/apex/CaseController.getUploadedFiles';
 import removeFile from '@salesforce/apex/CaseController.removeFile';
 import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
 import getCaseIRDateTime from '@salesforce/apex/CaseController.getCaseIRDateTime';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails'; 
 import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
 import { getRecord } from 'lightning/uiRecordApi';    
 import getServiceCloudMetadata from '@salesforce/apex/CaseController.getServiceCloudMetadata';  
 import { log } from 'c/globalUtilities'; //Vignesh

 import getOrgIds from '@salesforce/apex/CaseController.getOrgIds'; //T08

 
 //Custom Labels
 import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';
 import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';            //Amarender -> I2RT-1020: eSupport: Solutions Page
 import eSupport_Delivery_Method_Help_Text from '@salesforce/label/c.eSupport_Delivery_Method_Help_Text'; // <T01>
 
 const CaseCreationFailureMessage_MD = 'eSupport_Case_Creation_Failure_Message';
 
 
 export default class EsCaseCreationProductLicenseS2 extends LightningElement {
 
     maximize = ESUPPORT_RESOURCE + '/maximize.png';
     signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons_signature.png';
 
     @track shoShippingCaseInfo = true;
     @track showAlternateContactInfo = false;
     @track showAdditionalCaseInfo = false;
     @track showCaseSummary = false;
     @track showCaseDetails = false;
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
 
     @track iconName = 'utility:down';
     @track supportAccounts = [];
     @track selectedSupportAccount;
     @track selectedSupportAccountLabel;
     @track successOffering;
     @track products = [];
     @track allProducts = [];
     @track entitledProducts = [];
     @track unEntitledProducts = [];
     @track selectedProduct;
     @track environments = [];
     @track selectedEnvironment;
     @track priorities = [];
     @track selectedPriority;
     @track subject;
     @track description;
     @track caseInformation;
     @track recordTypeName = 'Fulfillment';
     @track caseInfoToSave = {};
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
     @track prevPageURL = 'case';
     @track triggerforsearch;                                //For Case Deflection Search
     @track placedin = 'esupportcasedeflectionshipping';    //For Case Deflection Search    
     @track __createCaseFailMessageMD_ID;
     @track createCaseFailureMessage;
 
     @track deliveryMethods = [];
     @track selectedDeliveryMethod;
     @track disableDeliveryMethod = false;
     @track showDeliveryMethod = false;
     @track showHosted = false; //T08

     //T08
     @track orgs = [];
     @track selectedOrg;
     @track secureAgent;
     @track ShowOrgtxtId=false;
     @track isOrgValue=false;
     @track ManualOrgId;
     @track showBanner = false;

     // <T01>
     label = {
         eSupport_Delivery_Method_Help_Text
     };
     // </T01>
     strAlternateContactsDescription = 'You can include other Support Account contacts to this case so they can view & comment in the case. This step is optional, you can always add/delete contacts for this case later.'; //<T05>
 
     @wire(allSupportAccounts, {})
     supportAccountOptions({ data, error }) {
         if (data) {
             let supportAccountOptions = [];
             var previousurl=encodeURI(document.referrer);//get previous page url //<T03>
             var accid=previousurl.slice(previousurl.length-18,previousurl.length); 
             if(accid.length==18)
                 this.selectedSupportAccount=(accid);
             for (var i in data) {
                 supportAccountOptions.push({ label: data[i].label, value: data[i].value });
             }
             this.supportAccounts = supportAccountOptions;
             log(this.selectedSupportAccount +'= supportAccountOptions = ' + JSON.stringify(this.supportAccounts));
 
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
             let environmentOptions = [];
 
             log('data= ' + data);
             this.contactId = data.contactId;
 
             //T07 - order the priority values in the descending order.
             let priorityList = [];
             data.priorities.forEach(element => {
                priorityList.push(element.value);                 
             });
             priorityList.reverse();
             priorityList.forEach(element => {
                priorityOptions.push({ label: element, value: element }); 
             });             
             this.priorities = priorityOptions;
 
             for (var i in data.environments) {
                 environmentOptions.push({ label: data.environments[i].value, value: data.environments[i].value });
             }
             this.environments = environmentOptions;
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
         if(sessionStorage.getItem('prod_account') != null && window.performance.navigation.type != 2){
             this.selectedSupportAccount = sessionStorage.getItem('prod_account');
             if(sessionStorage.getItem('prod_product') != null){
                 this.selectedProduct = sessionStorage.getItem('prod_product');
             }
             if(sessionStorage.getItem('prod_priority') != null){
                 this.selectedPriority = sessionStorage.getItem('prod_priority');
             }
             //T08
             if(sessionStorage.getItem('prod_orgName') != null){
                this.selectedOrg = sessionStorage.getItem('prod_orgName');
             }
             //T08
             if(sessionStorage.getItem('prod_secureAgent') != null){
                this.secureAgent = sessionStorage.getItem('prod_secureAgent');
             }
             if(sessionStorage.getItem('prod_env') != null){
                 this.selectedEnvironment = sessionStorage.getItem('prod_env');
             }
             if(sessionStorage.getItem('prod_sub') != null){
                 this.subject = sessionStorage.getItem('prod_sub');
             }
             if(sessionStorage.getItem('prod_desc') != null){
                 this.description = sessionStorage.getItem('prod_desc');
             }
             //T08
             if(sessionStorage.getItem('showManualOrgID') != null){
                this.isOrgValue=sessionStorage.getItem('showManualOrgID');
                this.ShowOrgtxtId = sessionStorage.getItem('showManualOrgID');
             }
             //T08
             if(sessionStorage.getItem('ManualOrgID') != null){
                this.ManualOrgId = sessionStorage.getItem('ManualOrgID');
             }
             if(this.selectedSupportAccount !== undefined && this.selectedSupportAccount !== null && this.selectedSupportAccount !== ''){
                 this.handleGetSupportContactdetails();
             }
         }  
     }
 
     handleAccountSelect(event) {
         log('@@SelectedAccount= ' + event.detail.value);
         this.prevPageURL = 'newcase?accountId=' + event.detail.value;
         this.selectedSupportAccount = event.detail.value;
         sessionStorage.setItem('prod_account', this.selectedSupportAccount);
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
 
         if (this.selectedSupportAccount != null && this.selectedSupportAccount != undefined) {
             /*getAllProducts({ accountId: this.selectedSupportAccount })
                 .then(result => {
                     log('result -->' + JSON.stringify(result));
                     this.entitledProducts = [];
                     let productOptions = [];
                     var isEntitledProduct = result[0] === '----Entitled Products----' ? true : false;
                     for (var pro in result) {
                         if (result.hasOwnProperty(pro)) {
                             productOptions.push({ label: result[pro], value: result[pro] });
                             if (isEntitledProduct) {
                                 isEntitledProduct = result[pro] === '----Unentitled Products----' ? false : true;
                                 if (isEntitledProduct) {
                                     this.entitledProducts.push(result[pro]);
                                 }
                             }
                         }
                     }
                     this.products = productOptions;
                 });*/
             
             getProducts({ supportAccId: this.selectedSupportAccount })
                 .then(result => {
                     log('Get Products: '+JSON.stringify(result));
                     let entitledProducts = [];
                     let unEntitledProducts = [];
                     let productOptions = [];
 
                     entitledProducts = result.filter(product => product.isEntitledProduct == true);
                     unEntitledProducts = result.filter(product => product.isEntitledProduct == false);
 
                     this.allProducts = entitledProducts.concat(unEntitledProducts);
 
                     if(entitledProducts.length > 0){
                         productOptions.push({label: '----Recently Used----', value: '----Recently Used----'});
                         entitledProducts.forEach(product => {
                             productOptions.push({label: product.productName, value: product.productName});
                         })
                     }
                     if(unEntitledProducts.length > 0){
                         productOptions.push({label: '----Others----', value: '----Others----'});
                         unEntitledProducts.forEach(product => {
                             productOptions.push({label: product.productName, value: product.productName});
                         })
                     }
                     log('Final list of Products: '+JSON.stringify(productOptions));
                     this.products = productOptions;
                 })
                 .catch(error => {
                     log('Get Products Error: '+JSON.stringify(error));
                 })
 
             getAccountRelatedContacts({ recordId: this.selectedSupportAccount })
                 .then(result => {
                     this.relatedContacts = result;
                     this.allContacts = this.relatedContacts.length;
                     this.successOffering = this.relatedContacts[0].Account.Success_Offering__c;
                     log('RelatedContacts= ' + JSON.stringify(this.relatedContacts));
                 });
             this.handleGetSupportContactdetails();
         }
     }
 
     handleProductSelect(event) {
         this.resetFields();
         this.selectedOrg=''; //T08
         this.selectedProduct = event.detail.value;
         sessionStorage.setItem('prod_product', this.selectedProduct);
         this.handleSearchDataOnBlur(event); //For Case Deflection Search
         this.showDeliveryMethod = true;
         var entitledProduct = false;
         this.allProducts.forEach(productObj => {
             if(this.selectedProduct === productObj.productName){
                 entitledProduct = productObj.isEntitledProduct;
                 Object.keys(productObj.deliveryMethodEntIdMap).forEach(dm => {
                     this.deliveryMethods.push({label: dm, value: dm});
                 });
             }
         })
         let delMethod = '';//T08
         this.disableDeliveryMethod = false;//T08
         if(this.deliveryMethods.length > 0){
             if(this.deliveryMethods.length == 1){
                delMethod = this.deliveryMethods[0].value;//T08
                this.disableDeliveryMethod = true;
             }
             else if(this.deliveryMethods.length > 1){
                 if(!entitledProduct){
                     this.deliveryMethods.forEach(dm => {
                         if(dm.value === 'On Premise'){
                             delMethod = dm.value;//T08
                             this.disableDeliveryMethod = true;
                         }
                     })
                 }
             }
         }
         this.setDeliveryMethod(delMethod);//T08
        }
     //<T06>
     
     /*
     get showUnentitledMessage(){
         let unEntitledProduct = false;
         if(this.selectedProduct && this.selectedProduct !== '' && (this.selectedProduct !== '----Entitled Products----' || this.selectedProduct !== '----Unentitled Products----')){
             this.allProducts.forEach(productObj => {
                 if(productObj.productName === this.selectedProduct && productObj.isEntitledProduct == false){
                     unEntitledProduct = true;
                 }
             });
         }
         return unEntitledProduct;
     }
     */

     //T08
     handleDeliveryMethodChange(event){
        log('handleDeliveryMethodChange, event.detail.value >> ', this.event.detail.value);
        this.setDeliveryMethod(event.detail.value);
     }

     //T08
     setDeliveryMethod(delMethod){
         this.selectedDeliveryMethod = delMethod;

         log('handleDeliveryMethodChange, this.selectedDeliveryMethod >> ', this.selectedDeliveryMethod);

         this.selectedOrg = undefined;
         this.ManualOrgId = undefined;
         this.secureAgent = undefined;

         this.showHosted = false;
         if(this.selectedDeliveryMethod == 'Hosted Multi Tenant'){
            this.showHosted = true;
            var prodName = this.selectedProduct+'('+this.selectedDeliveryMethod+')';
            getOrgIds({productName:prodName, SuppoAccId:this.selectedSupportAccount})
            .then(result => {
                log('orgIds- ' + JSON.stringify(result));
                var orgIds = result;
                let orgOptions = [];
   
                for (var i in orgIds) {
                    log('dataComponent->' + JSON.stringify(orgIds[i]));
                    if (orgIds[i].label != null && orgIds[i].label != undefined) {
                        orgOptions.push({ label: orgIds[i].label, value: orgIds[i].value });
                    }
                }
                this.orgs = orgOptions;
                log('Orgs-->' + JSON.stringify(this.orgs));
                this.showBanner = false;
            });
         }
     }

     //T08
     handleOrgChange(event) {
         this.selectedOrg = event.detail.value;
         this.showBanner = true;
         sessionStorage.setItem('prod_orgName', this.selectedOrg);
     }
 
     //T08
     handleSecureAgentChange(event) {
         this.secureAgent = event.detail.value;
         sessionStorage.setItem('prod_secureAgent', this.secureAgent);
     }
 
     //T08
     handlechkBoxOrgChange(event) {
        if(event.target.checked){
            this.isOrgValue=true;
            this.ShowOrgtxtId=true;
        }else{
            this.ShowOrgtxtId=false;
            this.isOrgValue=false;
        }
        sessionStorage.setItem('showManualOrgID', event.detail.checked);
     }

     //T08
     handleManualOrgOrgChange(event) {
        this.ManualOrgId=event.target.value;
        sessionStorage.setItem('ManualOrgID', event.detail.value);
     }

     handleEnvironmentChange(event) {
         this.selectedEnvironment = event.detail.value;
         sessionStorage.setItem('prod_env', this.selectedEnvironment);
     }
 
     handlePriorityChange(event) {
         this.selectedPriority = event.detail.value;
         sessionStorage.setItem('prod_priority', this.selectedPriority);
     }
 
     handleSubjectChange(event) {
         this.subject = event.detail.value;
         sessionStorage.setItem('prod_sub', this.subject);          
     }
 
     handleDescriptionChange(event) {
         this.description = event.detail.value;
         sessionStorage.setItem('prod_desc', this.description);        
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
 
     showAlternateContact() {
         if(this.hasReadWriteAccess){
             var isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input, lightning-textarea')]
             .reduce((validSoFar, inputField) => {
                 inputField.reportValidity();
                 return validSoFar && inputField.checkValidity();
             }, true);
             if (isValidValue){
                 this.caseInformation = this.selectedPriority + ' | Subject : ' + this.subject;
                 this.shoShippingCaseInfo = false;
                 this.showAlternateContactInfo = true;
                 this.showCaseSummary = false;
                 this.showCaseDetails = false;
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
 
         this.shoShippingCaseInfo = false;
         this.showAlternateContactInfo = false;
         this.showCaseSummary = true;
         this.showCaseDetails = false;
         var caseObj = {};
         caseObj.category = 'Fulfillment';
         caseObj.priority = this.selectedPriority;
         caseObj.product = this.selectedProduct;
         caseObj.supportAccount = this.selectedSupportAccountLabel;
         caseObj.successOffering = this.successOffering;
         caseObj.subject = this.subject;
         caseObj.description = this.description;
         caseObj.attachments = this.fileSize;
         caseObj.contacts = [];
         caseObj.environment = this.selectedEnvironment;
         caseObj.contacts = this.contactsToAdd;

         //T08
         if(this.selectedOrg == null || this.selectedOrg == undefined || this.selectedOrg == ''){
            caseObj.orgId = this.ManualOrgId;
            caseObj.orgUUID = this.ManualOrgId;
         }else{
            caseObj.orgId = this.selectedOrg;
            this.orgs.forEach(element => {
                if(element.value == this.selectedOrg){
                    caseObj.orgUUID = element.label;
                }
            });
         }
         caseObj.secureAgent = this.secureAgent;
 
         this.caseInfoToSave = caseObj;
 
         /*
         getResponseTimeForCase({accountId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: ''})
         .then(result => {
             log('caseReaponse time= '+result);
             this.caseResponseTime = result;
         })
         .catch(error => {
             log('error while getting response time'+JSON.stringify(error));
         });
         */
         var entId = '';
         this.allProducts.forEach(productObj => {
             if(productObj.productName === this.selectedProduct){
                 Object.keys(productObj.deliveryMethodEntIdMap).forEach( dm => {
                     if(dm === this.selectedDeliveryMethod){
                        entId = productObj.deliveryMethodEntIdMap[dm];
                     }
                 })
             }
         });
         getCaseIRDateTime({supportAccId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: '', entitlementId: entId})
         .then(result => {
             log('caseReaponse time= '+result);
             this.caseResponseTime = result;
         })
         .catch(error => {
             log('error while getting response time'+JSON.stringify(error));
         });
         window.scrollTo(0, 0);
         log('ShowfinalSummary');
     }
 
 
     backToShippingCaseInfo(event) {
         let preselectedContactList = event.detail.finalContactList;
         //this.allContactData = event.detail.allContactsToAdd;
         this.allContactData = preselectedContactList;
 
         this.selectedContactList = [];
         for(let i = 0; i < preselectedContactList.length; i++){
             this.selectedContactList.push(preselectedContactList[i].ContactId);
         }
         this.shoShippingCaseInfo = true;
         this.showAlternateContactInfo = false;
         this.showCaseSummary = false;
         this.showCaseDetails = false;
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
         this.shoShippingCaseInfo = false;
         this.showAlternateContactInfo = true;
         this.showCaseSummary = false;
         this.showCaseDetails = false;
 
         window.scrollTo(0, 0);
     }
 
     saveCase(event) {
         this.showSpinner = true;
         document.body.setAttribute('style', 'overflow: hidden;');
         let contacts = [];
         contacts = event.detail;
         var caseObj = {};
         caseObj.Support_Account__c = this.selectedSupportAccount;
         caseObj.Forecast_Product__c = this.selectedProduct;
         caseObj.Environment__c = this.selectedEnvironment;
         caseObj.Priority = this.selectedPriority;
         caseObj.Description = this.description;
         caseObj.Subject = this.subject;

         //T08
         if(this.isOrgValue){       
            caseObj.Org_ID__c=this.ManualOrgId;//set manually added org id
         }else{
            caseObj.Org__c = this.selectedOrg;
         }
         caseObj.Secure_Agent__c = this.secureAgent;
        
         log('caseObj== ' + JSON.stringify(caseObj));
         var product = [];
         product.push(this.selectedProduct);
         product.push(this.selectedDeliveryMethod);
         this.allProducts.forEach(productObj => {
             if(productObj.productName === this.selectedProduct){
                 Object.keys(productObj.deliveryMethodEntIdMap).forEach( dm => {
                     if(dm === this.selectedDeliveryMethod){
                        var entId = productObj.deliveryMethodEntIdMap[dm];
                        product.push(entId && entId != '' ? entId : '');
                     }
                 })
             }
         });
         log('product before case creation: '+JSON.stringify(product));
 
         createCase({ caseJson: JSON.stringify(caseObj), recordTypeName: this.recordTypeName, caseRelatedContacts: contacts, product: product })
             .then(strCaseId => { //<T04>
                 this.handleCaseDeflectionOnSubmit(); //For Case Deflection Search
                         this.shoShippingCaseInfo = false;
                         this.showAlternateContactInfo = false;
                         this.showCaseSummary = false;
                 var url = CommunityURL + 'casedetails?caseId=' + strCaseId;
                         window.open(url, '_self');
                 this.showSpinner = false;
                 document.body.removeAttribute('style', 'overflow: hidden;');
                 /** START-- adobe analytics */
                 try {
                     util.trackCreateCase("Product Download & License Request", "Completed");
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
         const uploadedFiles = event.detail.files;
         let message = ' File is attached';
         if (uploadedFiles.length > 1) {
             message = ' Files are attached';
         }
         this.showSpinner = true;
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
         sessionStorage.removeItem('prod_account');
         sessionStorage.removeItem('prod_product');
         sessionStorage.removeItem('prod_priority');
         sessionStorage.removeItem('prod_env');
         sessionStorage.removeItem('prod_sub');
         sessionStorage.removeItem('prod_desc');
         sessionStorage.removeItem('prod_orgName'); //T08
         sessionStorage.removeItem('prod_secureAgent'); //T08
         sessionStorage.removeItem('showManualOrgID'); //T08
         sessionStorage.removeItem('ManualOrgID'); //T08
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
             
                 // var unloadEventCause = { name: 'unloadPage', type: 'caseCreation' };
                 // Coveo.logCustomEvent(window.CustomCoveoCaseDflection, unloadEventCause, metadata);
                 log('Method : handleCaseDeflectionOnCancel ');
             }
         } catch (error) {
             console.error('Method : handleCaseDeflectionOnCancel; Error :' + error.message + ' : ' + error.stack);
         }
     }
     //For Case Deflection Search  - End
 
     resetFields(){
         this.deliveryMethods = [];
         this.disableDeliveryMethod = false;
         this.selectedDeliveryMethod = undefined;
         this.selectedOrg = undefined; //T08
         this.ManualOrgId = undefined; //T08
         this.showBanner = false; //T08
     }
 }