/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              22-Nov-2021     I2RT-4833           Show Help Text next to Delivery Method                    T01
 Amarender              29-Nov-2021     I2RT-4421           Storing CDQI API Response on Case record                  T02
 Amarender              03-Dec-2021     I2RT-5103           Deserialize JSON Object                                   T03
 Vignesh D              08-Mar-2022     I2RT-5620           Get support account details                               T04
 balajip                14-Mar-2022     I2RT-5678           Show Org UUID in the summary instead of the Org Id        T05
 Sandeep Duggi          14-Apr-2022     I2RT-6181           eSupport - During case creation while product selection   T06
                                                            rename Entitled and Un-Entitled to Recently Used and Others
 Vignesh D              22-Jul-2022     I2RT-6593           Commented Milestone checkbox related functionalities      T07
 Vignesh D              08-Aug-2022     I2RT-6864           Checkmarx security fixes                                  T08
 Sandeep Duggi           July- 23-2022   I2RT-6741           eSupport: hide delivery method of Hosted Single Tenant   T09
 Vignesh D              26-Aug-2022     I2RT-6986           Reverted commented Milestone checkbox related             T10
                                                            functionalities
 Vignesh D              31-Aug-2022     I2RT-6865           Replace promise returned from object to string            T11
 Vignesh D              31-Aug-2022     I2RT-6865           Pass alternate contacts description to child component    T12
 Amit G                 25-Oct-2022     I2RT-7221           commented out the method to remove validation check       T13
 balajip                28-Oct-2022     I2RT-7212           to show the list of priority values in descending order   T14
 */

 import { LightningElement, api, track, wire } from 'lwc';
 import allSupportAccounts from '@salesforce/apex/CaseController.allSupportAccounts';
 import removeCurrentFiles from '@salesforce/apex/CaseController.removeCurrentFiles';
 import getCaseFieldsDropdownOptions from '@salesforce/apex/CaseController.getCaseFieldsDropdownOptions';
 import getAccountRelatedContacts from '@salesforce/apex/CaseController.getAccountRelatedContacts';
 import getProducts from '@salesforce/apex/CaseController.getProducts';
 import getVersionforSelectedProduct from '@salesforce/apex/CaseController.getVersionforSelectedProduct';
 import getOrgIds from '@salesforce/apex/CaseController.getOrgIds';
 import getComponentForSelectedProduct from '@salesforce/apex/CaseController.getComponentForSelectedProduct';
 import createCase from '@salesforce/apex/CaseController.createCase';
 import getUploadedFiles from '@salesforce/apex/CaseController.getUploadedFiles';
 import removeFile from '@salesforce/apex/CaseController.removeFile';
 import processCaseDescQualityIndicator from '@salesforce/apex/CaseController.processCaseDescQualityIndicator';
 import processCaseRecommendation from '@salesforce/apex/CaseController.processCaseRecommendation';
 import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
 import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';            //Amarender -> I2RT-1020: eSupport: Solutions Page
 import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
 import getCaseIRDateTime from '@salesforce/apex/CaseController.getCaseIRDateTime'; 
 import getESupportMetadataId from '@salesforce/apex/CaseController.getESupportMetadataId';  // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
 import { getRecord } from 'lightning/uiRecordApi';                                          // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
 import getCaseCreatedCount from '@salesforce/apex/CaseController.getCaseCreatedCount_S2';   // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';                          // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
 import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails';
 import getServiceCloudMetadata from '@salesforce/apex/CaseController.getServiceCloudMetadata';
 import getAvailableSlots from '@salesforce/apex/OperationsSchedulerController.getAvailableSlots';
 import TIME_ZONE from '@salesforce/i18n/timeZone';  
 import { log } from 'c/globalUtilities'; //Vignesh 
 import getSupportAccountDetails from '@salesforce/apex/CaseController.getSupportAccountDetails'; // <T04>
 
 //Custom Labels
 import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';
 import AskOurCommunityURL from '@salesforce/label/c.AskOurCommunityURL';
 import eSupport_Delivery_Method_Help_Text from '@salesforce/label/c.eSupport_Delivery_Method_Help_Text'; // <T01>
 
 const METADATA_FIELDS = [
     'Service_Cloud_General_Setting__mdt.Case_Count_Maximum_Limit__c',
     'Service_Cloud_General_Setting__mdt.Case_Count_Warning_Limit__c'
 ];
 const SCHEDULED_ACTIVITY_TYPE = ['Request an activity/change request'];
 const CaseCreationFailureMessage_MD = 'eSupport_Case_Creation_Failure_Message';
 
 
 export default class EsCaseCreationCaseInfoTechnical extends LightningElement {
     maximize = ESUPPORT_RESOURCE + '/maximize.png';
     signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons_signature.png';
     liveAgent = ESUPPORT_RESOURCE + '/live_agent.png';
     postQuestions = ESUPPORT_RESOURCE + '/post_questions.png';
 
     @api proceedUrl;
     @api showLastValues;
 
     @track showBusinessImpact = false;
     @track showVersion = false;
     @track showDeliveryMethod = false;
     @track showHostedRelated = false;
     @track showHosted = false;
     @track doesImpactMilestone = false;
     @track isInfoTrue = false;
     @track technicalCaseInfo = true;
     @track additionalInfoTechnical = false;
     @track alternateContactInfo = false;
     @track finalSummaryCase = false;
     @track showCaseDetails = false;
     @track showAdditionalCaseInformation = true;
     @track iconName = 'utility:down';
     @track isAttachmentDeletePopup = false;
     @track showBanner = false;
 
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
     @track showSpinner = false;
     @track showCaseCancelModal = false;
     @track SupportAccId='001g000002UsTULAA3'  ;
     @track supportAccounts = [];
     @track selectedSupportAccount;
     @track selectedSupportAccountLabel;
     @track successOffering;
     @track products = [];
     @track selectedProduct;
     @track allProducts = [];
     @track entitledProducts = [];
     @track unEntitledProducts = [];
     @track forecastProduct;
     @track orgs = [];
     @track selectedOrg;
     @track versions = [];
     @track selectedVersion;
     @track productComponents = [];
     @track selectedProductComponent;
     @track secureAgent;
     @track environments = [];
     @track selectedEnvironment;
     @track activities = [];
     @track selectedActivity;
     @track subject;
     @track priorities = [];
     @track selectedPriority;
     @track issueSummary;
     @track description;
     @track errorMessage;
     @track recordTypeName = 'Technical';
     @track caseInformation;
     @track problemTypes = [];
     @track selectedProblemType;
     @track contactId;
     @track caseInfo = {};
     @track caseInfoToSave = {};
     @track relatedContacts = [];
     @track fileSize = 0;
     @track alternateContact;
     @track contactsToAdd = [];
     @track caseContacts = [];
     @track caseDocuments = [];
     @track buttonLabel = 'Skip for now';
     @track selectedContact = 0;
     @track allContacts;
     @track uploadedFiles = [];
     @track fileToRemove;
     @track caseResponseTime;
     @track triggerforsearch;                                //For Case Deflection Search
     @track placedin = 'esupportcasedeflectiontechnical';    //For Case Deflection Search
     @track selectedContactList = [];
     @track allContactData = [];
 
     @track isQIAvailable = false;
     @track cdqiApiJSONResponse = {};        //<T02>
     @track boolProblemSymptom = false;
     @track boolErrorMessage = false;
     @track boolActionTaken = false;
     @track boolIncidentTime = false;
     @track boolDetailDesc = false;
     @track boolComponent = false;
     @track boolAdditionalDetails = false;
     @track actionTakenExample;
     @track problemSymptomExample;
     @track errorMessageExample;
     @track incidentTimeExample;
     @track componentExample;
     @track additionalDetailsExample;
     @track qualityScore;
     @track qualityScoreColor;
     @track strengthCss;
     @track isInGreen;
     @track isInAmber;
     @track isInRed;
     @track disableFields = false;
     @track proceedButtonCSS = 'es-button es-button--primary';
     // @track strengthIndicatorCSS = "es-form-hide";
 
     @track metadataRecordId = '';               // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @track caseCount;                           // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @track maxCaseCountLimit;                   // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @track warnCaseCountLimit;                  // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @track isCaseCountVisible = false;          // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @track caseCountString = '';                // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
 
     @track isAgentAvailable = false;                  //Amarender -> I2RT-717: eSupport:LiveChat 
     @track cloudProductSelected = false;            //Amarender -> I2RT-717: eSupport:LiveChat
     @track kbUrl;
     @track selectedImpact;
     @track impactCheckbox = false;
     @track selectedEstimateDate;
     @track placeholdertext = "Share a detailed description of the problem. \nWhat are the problem symptoms? \nWhen did it occur? \nWhat were the actions taken just before the occurrence ?";
     @track  optionsTemp = [
         { label: 'Critical Development Blocker', value: 'Critical Development Blocker' },
         { label: 'Critical Production Service Outage', value: 'Critical Production Service Outage' },
         { label: 'Production Deployment Blocker', value: 'Production Deployment Blocker' },
         { label: 'Upcoming Go Live', value: 'Upcoming Go Live' },
         { label: 'Widespread Production Service Outage', value: 'Widespread Production Service Outage' },
     ];
 
     @track prevPageURL = 'case';  
     @track askCommunityLink = AskOurCommunityURL;
     @track hasReadWriteAccess = false;
     @track ShowOrgtxtId=false;
     @track isOrgValue=false;
     @track ManualOrgId;
     // this.selectedSupportAccount=this.SupportAccId;
     @track __createCaseFailMessageMD_ID;
     @track createCaseFailureMessage;
 
     //Operations Activity Window
     @track userTimeZone = TIME_ZONE;
     @track availableDatesWithSlots;
     @track availableDates;
     @track selectedDate;
     @track availableSlots;
     @track selectedSlot;
     slotStartDT;
     slotEndDT;
 
     @track deliveryMethods = [];
     @track selectedDeliveryMethod;
     @track disableDeliveryMethod = false;
 
     // <T01>
     label = {
         eSupport_Delivery_Method_Help_Text
     };
     // </T01>
     strAlternateContactsDescription = 'You can include other Support Account contacts to this case so they can view & comment in the case. This step is optional, you can always add/delete contacts for this case later.'; //<T12>
 
     connectedCallback(){
 
         // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
         getESupportMetadataId()
             .then(result => {
                 log('ESupport Metadata Id Result => ' + result);
                 this.metadataRecordId = result;
             })
             .catch(error => {
                 log("ESupport Metadata Error => " + JSON.stringify(error))
             });
         //Vignesh D -> I2RT-3939: Handle Case Creation error
         getServiceCloudMetadata({ metadataName: CaseCreationFailureMessage_MD })
             .then(result => {
                 log('Case Creation Failure Message metadata Id => '+result);
                 this.__createCaseFailMessageMD_ID = result;
             })
             .catch(error => {
                 log('Metadata error => '+error);
             });
         if(sessionStorage.getItem('tech_account') != null && window.performance.navigation.type != 2){
             this.selectedSupportAccount = sessionStorage.getItem('tech_account');
             if(sessionStorage.getItem('tech_product') != null){
                 this.selectedProduct = sessionStorage.getItem('tech_product');
                 let customEvent = this.createCustomEvent(this.selectedProduct);
                 this.handleProductSelect(customEvent);
                 if(sessionStorage.getItem('tech_version') != null){
                     this.selectedVersion = sessionStorage.getItem('tech_version');
                 }
                 if(sessionStorage.getItem('tech_orgName') != null){
                     this.selectedOrg = sessionStorage.getItem('tech_orgName');
                 }
                 if(sessionStorage.getItem('tech_secureAgent') != null){
                     this.secureAgent = sessionStorage.getItem('tech_secureAgent');
                 }
                 if(sessionStorage.getItem('tech_activity') != null){
                     this.selectedActivity = sessionStorage.getItem('tech_activity');
                 }
                 if(sessionStorage.getItem('tech_env') != null){
                     this.selectedEnvironment = sessionStorage.getItem('tech_env');
                 }
             }
             if(sessionStorage.getItem('tech_relatedComp') != null){
                 this.selectedProductComponent = sessionStorage.getItem('tech_relatedComp');
             }
             if(sessionStorage.getItem('tech_priority') != null){
                 this.selectedPriority = sessionStorage.getItem('tech_priority');
                 if (this.selectedPriority == 'P1') {
                     this.showBusinessImpact = true;
                     this.selectedImpact = sessionStorage.getItem('tech_impact');
                     if( sessionStorage.getItem('tech_milestone')){
                         this.impactCheckbox = true;
                         this.doesImpactMilestone = true;
                         this.selectedEstimateDate = sessionStorage.getItem('tech_date');
                     }
                 }
                 else {
                     this.showBusinessImpact = false;
                 }
             }
             if(sessionStorage.getItem('tech_sub') != null){
                 this.subject = sessionStorage.getItem('tech_sub');
             }
             if(sessionStorage.getItem('tech_desc') != null){
                 this.description = sessionStorage.getItem('tech_desc');
             }
             if(sessionStorage.getItem('tech_message') != null){
                 this.errorMessage = sessionStorage.getItem('tech_message');
             }
             if(sessionStorage.getItem('showManualOrgID') != null){
                 this.isOrgValue=sessionStorage.getItem('showManualOrgID');
                 this.ShowOrgtxtId = sessionStorage.getItem('showManualOrgID');
                 // alert(this.ShowOrgtxtId );
             }
             if(sessionStorage.getItem('ManualOrgID') != null){
                 this.ManualOrgId = sessionStorage.getItem('ManualOrgID');
                 // alert(this.ManualOrgId );
             }
 
             if(this.selectedSupportAccount !== undefined && this.selectedSupportAccount !== null && this.selectedSupportAccount !== ''){
                 this.handleGetSupportContactdetails();
                 this.getSupportAccountDetails(); // <T04>
             }
         }  
         else{
             this.clearSessionData();
         }
     }
 
     createCustomEvent(data) {
         let customEvent = { detail: { value: {} } };
         customEvent.detail.value = data;
         return customEvent;
     }
     
     @wire(getCaseFieldsDropdownOptions, {})
     dropdownOption({ data, error }) {
         if (data) {
             log("data  ====> ", data);
             let environmentOptions = [];
             let activityOptions = [];
             let priorityOptions = [];
             let problemTypeOptions = [];
             log('data= ' + data);
             this.contactId = data.contactId;
             for (var i in data.environments) {
                 environmentOptions.push({ label: data.environments[i].value, value: data.environments[i].value });
             }
             this.environments = environmentOptions;
 
             for (var i in data.activities) {
                 activityOptions.push({ label: data.activities[i].value, value: data.activities[i].value });
             }
             this.activities = activityOptions;
 
             //T14 - order the priority values in the descending order.
             let priorityList = [];
             data.priorities.forEach(element => {
                priorityList.push(element.value);                 
             });
             priorityList.reverse();
             priorityList.forEach(element => {
                priorityOptions.push({ label: element, value: element }); 
             });             
             this.priorities = priorityOptions;
 
             for (var i in data.problemTypes) {
                 problemTypeOptions.push({ label: data.problemTypes[i].value, value: data.problemTypes[i].value });
             }
             this.problemTypes = problemTypeOptions;
         } else {
             log('Error getting dropdown ' + JSON.stringify(error));
         }
     }
 
     @wire(allSupportAccounts, {})
     supportAccountOptions({ data, error }) {
         if (data) {
             let supportAccountOptions = [];
             var previousurl=encodeURI(document.referrer);//get previous page url //<T08>
             var accid=previousurl.slice(previousurl.length-18,previousurl.length); 
             if(accid.length==18)
                 this.selectedSupportAccount=(accid);
             for (var i in data) {                
                     supportAccountOptions.push({ label: data[i].label, value: data[i].value });                 
             }
             this.supportAccounts = supportAccountOptions;
             log(this.selectedSupportAccount +'= supportAccountOptions = ' + JSON.stringify(this.supportAccounts));
 
             let customEvent = this.createCustomEvent(this.selectedSupportAccount);
             this.handleAccountSelect(customEvent);
 
             removeCurrentFiles()
                 .then(result => {
                     if (result) {
                         log('file removed successfully.');
                     }
                 });
         } else {
             log('GetContact Error= ' + JSON.stringify(error));
         }
     }
 
     // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
     @wire(getRecord, { recordId: '$metadataRecordId', fields: METADATA_FIELDS })
     metadataRecord({ error, data }) {
         if (data) {
             log("Watch: metadataRecord data -> " + JSON.stringify(data));
 
             this.maxCaseCountLimit = parseInt(data.fields.Case_Count_Maximum_Limit__c.value); // UPPER LIMIT
             log("Watch: maxCaseCountLimit -> " + this.maxCaseCountLimit);
 
             this.warnCaseCountLimit = parseInt(data.fields.Case_Count_Warning_Limit__c.value); // LOWER LIMIT
             log("Watch: warnCaseCountLimit -> " + this.warnCaseCountLimit);
 
             // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
             this.handleCaseCreatedCount(this.selectedSupportAccount);
         } else if (error) {
             log("Watch: metadataRecord error -> " + JSON.stringify(error));
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
 
 //Anil - 3590 add org manually
 handlechkBoxOrgChange(event) {
     if(event.target.checked){
         this.isOrgValue=true;
         this.ShowOrgtxtId=true;
     }else{
         this.ShowOrgtxtId=false;
         this.isOrgValue=false;
     }
     sessionStorage.setItem('showManualOrgID', event.detail.checked);
     // alert(''+event.target.checked);
 }
 //Anil - 3590 add org manually
 handleManualOrgOrgChange(event) {
         this.ManualOrgId=event.target.value;
     sessionStorage.setItem('ManualOrgID', event.detail.value);
     // alert(''+event.target);
 }
     // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
     handleUpgradeMessage() {
         let msg = 'WARNING: You are approaching maximum case limit for your product entitlement. For more information, please email iCare@informatica.com.';
         if (this.caseCount >= this.maxCaseCountLimit) {
             msg = 'WARNING: You have reached the maximum limit for your product entitlement. For more information, please email iCare@informatica.com.';
         }
         const event = new ShowToastEvent({
             title: 'Informatica says:',
             message: msg,
             variant: 'warning',
             mode: 'sticky'
         });
         this.dispatchEvent(event);
     }
 
     // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
     handleCaseCreatedCount(supportAccount) {
         // Tejasvi Royal -> I2RT-3285: Case Count Calc. (Enhancement)
         getCaseCreatedCount({ selectedAccId: supportAccount })
             .then(result => {
                 let caseCountReturned = result;
                 log('TR -> caseCountReturned -> ' + caseCountReturned);
                 if (caseCountReturned >= 0) {
                     this.caseCount = caseCountReturned;
                     if (caseCountReturned >= this.warnCaseCountLimit && caseCountReturned < this.maxCaseCountLimit) {
                         this.isCaseCountVisible = true;
                         this.caseCountString = this.caseCount + ' of ' + this.maxCaseCountLimit + ' cases opened in this year.';
                         this.disableFields = false;
                         this.proceedButtonCSS = 'es-button es-button--primary';
                     }
                     if (caseCountReturned >= this.maxCaseCountLimit) {
                         this.isCaseCountVisible = true;
                         this.caseCountString = 'You have reached the maximum limit for your product entitlement. For more information, please email iCare@informatica.com.';
                         this.disableFields = true;
                         this.proceedButtonCSS = 'es-button es-button--secondary';
                     }
                     log('TR -> maxCaseCountLimit --> ', this.maxCaseCountLimit);
                     log('TR -> warnCaseCountLimit --> ', this.warnCaseCountLimit);
                     log('TR -> caseCount -> ' + this.caseCount);
                 }
                 if (caseCountReturned < 0) {
                     this.disableFields = false;
                     this.isCaseCountVisible = false;
                     if (caseCountReturned === -5) log('caseCount ==> ' + NotBasicSupportAccount_AND_SingleSupportAccountPresent);
                     if (caseCountReturned === -6) log('caseCount ==> ' + NotBasicSupportAccount_AND_MultipleSupportAccountsPresent);
                 }
             })
             .catch(error => {
                 log("Case Count Apex Error => " + JSON.stringify(error));
             });
     }
     
     handleAccountSelect(event) {
         log('@@SelectedAccount= ' + event.detail.value);
         this.prevPageURL = 'newcase?accountId=' + event.detail.value;
         sessionStorage.setItem('tech_account', event.detail.value);
         this.selectedSupportAccount = event.detail.value;
 
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
         sessionStorage.setItem('tech_accountName', accountName); //For Case Deflection Search 
         this.selectedSupportAccountLabel = accountName;
 
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
                     log('entitled products: '+JSON.stringify(this.entitledProducts));
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
                     //this.successOffering = this.relatedContacts[0].Account.Success_Offering__c; commented as part of <T04>
                     log('RelatedContacts= ' + JSON.stringify(this.relatedContacts));
                 });
             // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
             this.handleCaseCreatedCount(this.selectedSupportAccount);
             this.handleGetSupportContactdetails();
             this.getSupportAccountDetails(); // <T04>
         }
     }
 
     handleProductSelect(event) {
         this.resetFields();
         this.selectedProduct = event.detail.value;
         this.selectedOrg='';
         log('Product Selected ==> '+this.selectedProduct);        
         log("Product event =====> ", event);
         sessionStorage.setItem('tech_product', this.selectedProduct);
         this.showVersion = true;
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
         if(this.deliveryMethods.length > 0){
             if(this.deliveryMethods.length == 1){
                 this.selectedDeliveryMethod = this.deliveryMethods[0].value;
                 this.disableDeliveryMethod = true;
             }
             else if(this.deliveryMethods.length > 1){
                 if(!entitledProduct){
                     this.deliveryMethods.forEach(dm => {
                         if(dm.value === 'Hosted Single Tenant'){    // t09
                             this.deliveryMethods.pop(dm);
                         }
                         if(dm.value === 'On Premise'){
                             this.selectedDeliveryMethod = dm.value;
                             this.disableDeliveryMethod = true;
                         }
                     })
                 }
             }
         }
         this.productDeliveryMethodChecker();
     }
     //<T13>
     /*get showUnentitledMessage(){
         let unEntitledProduct = false;
         if(this.selectedProduct && this.selectedProduct !== '' && (this.selectedProduct !== '----Recently Used----' || this.selectedProduct !== '----Others----')){
             this.allProducts.forEach(productObj => {
                 if(productObj.productName === this.selectedProduct && productObj.isEntitledProduct == false){
                     unEntitledProduct = true;
                 }
             });
         }
         return unEntitledProduct;
     }*/
 
     handleDeliveryMethod(event){
         this.selectedDeliveryMethod = event.detail.value;
         this.selectedOrg = undefined;
         this.ManualOrgId = undefined;
         this.secureAgent = undefined;
         this.productDeliveryMethodChecker();
     }
 
     productDeliveryMethodChecker(){
         
         if(this.selectedProduct && this.selectedProduct != '' && this.selectedDeliveryMethod && this.selectedDeliveryMethod != ''){
             if (this.selectedDeliveryMethod.includes('Hosted Single Tenant')){
                 this.showHosted = false;
                 this.showHostedRelated = true;
             }
             else if(this.selectedDeliveryMethod.includes('Hosted Multi Tenant')){
                 this.showHosted = true;
                 this.showHostedRelated = false;
             }
             else{
                 this.showHosted = false;
                 this.showHostedRelated = false;
             }
             this.handleCloudProduct();   
                 
                 //Amarender -> I2RT-717: eSupport:LiveChat
             if (this.selectedProduct && this.selectedProduct != '' && (this.selectedProduct !== '----Recently Used----' || this.selectedProduct !== '----Others----') &&
                 this.selectedDeliveryMethod && this.selectedDeliveryMethod != '') {
                     
                 if (!this.selectedDeliveryMethod.includes('On Premise') && !this.selectedDeliveryMethod.includes('Hosted Single Tenant') && !this.selectedDeliveryMethod.includes('Hosted Multi Tenant') && !this.selectedDeliveryMethod.includes('Perpetual')) {
                     //this.forecastProduct = this.selectedProduct;
                     this.recordTypeName = 'Technical';
                 } else if (this.selectedDeliveryMethod.includes('On Premise')) {
                     //this.forecastProduct = this.selectedProduct.substring(0, this.selectedProduct.indexOf('(On Premise)'));
                     this.recordTypeName = 'Technical';
                 } else if (this.selectedDeliveryMethod.includes('Hosted Single Tenant')) {
                     //this.forecastProduct = this.selectedProduct.substring(0, this.selectedProduct.indexOf('(Hosted Single Tenant)'));
                     this.recordTypeName = 'Operations';
                     //Amarender -> I2RT-717: eSupport:LiveChat - Start
                     var flatButton = $('.flatButton');
                     if (flatButton.text().includes('Chat with an Expert')) {
                         this.isAgentAvailable = true;
                     }
                     this.cloudProductSelected = true;
                     //Amarender -> I2RT-717: eSupport:LiveChat - End
                 } else if (this.selectedDeliveryMethod.includes('Hosted Multi Tenant')) {
                     //this.forecastProduct = this.selectedProduct.substring(0, this.selectedProduct.indexOf('(Hosted Multi Tenant)'));
                     this.recordTypeName = 'Technical';
                     //Amarender -> I2RT-717: eSupport:LiveChat - Start
                     var flatButton = $('.flatButton');
                     if (flatButton.text().includes('Chat with an Expert')) {
                         this.isAgentAvailable = true;
                     }
                     this.cloudProductSelected = true;
                     //Amarender -> I2RT-717: eSupport:LiveChat - End
                 } else if (this.selectedProduct.includes('Perpetual')) {
                     //this.forecastProduct = this.selectedProduct.substring(0, this.selectedProduct.indexOf('(Perpetual)'));
                     this.recordTypeName = 'Technical';
                 }
                 sessionStorage.setItem('fc_product', this.selectedProduct);            
                 this.handleSearchDataOnBlur(event); //For Case Deflection Search
                 //  alert(this.selectedProduct +'62331'); 
                 var ProdName=this.selectedProduct+'('+this.selectedDeliveryMethod+')';
                 getOrgIds({ productName:ProdName  ,SuppoAccId:this.selectedSupportAccount })
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
                 log('recordType ==> '+this.recordTypeName);
             }
             this.showAppointmentDateChecker();
             this.clearDateSlotFieldValues();
         }
     }
 
     @wire(getVersionforSelectedProduct, { selectedProduct: '$selectedProduct' })
     wiredVersions({ error, data }) {
         if (data) {
             let versionOptions = [];
             log('data->' + JSON.stringify(data));
             for (var version in data) {
                 if (data.hasOwnProperty(version)) {
                     versionOptions.push({ label: data[version], value: data[version] });
                 }
             }
             this.versions = versionOptions;
             log('this.versions-->' + JSON.stringify(this.versions));
 
             // getting the dependent Component
             getComponentForSelectedProduct({ selectedProduct: this.selectedProduct })
                 .then(result => {
                     log('result -->' + JSON.stringify(result));
                     if (result) {
                         let productComponentOptions = [];
                         log('dataComponent->' + JSON.stringify(result));
                         for (var version in result) {
                             if (result.hasOwnProperty(version)) {
                                 productComponentOptions.push({ label: result[version], value: result[version] });
                             }
                         }
                         this.productComponents = productComponentOptions;
                         log('this.versions-->' + JSON.stringify(this.productComponents));
                     } else if (error) {
                         log('Error -->' + JSON.stringify(error));
                     }
                 });
         } else if (error) {
             log('Error -->' + JSON.stringify(error));
         }
     }
 
     handleVersionChange(event) {
         this.selectedVersion = event.detail.value;
         sessionStorage.setItem('tech_version', this.selectedVersion);
     }
 
     hadleOrgChange(event) {
         this.selectedOrg = event.detail.value;
         this.showBanner = true;
         sessionStorage.setItem('tech_orgName', this.selectedOrg);
     }
 
     handleSecureAgentChange(event) {
         this.secureAgent = event.detail.value;
         sessionStorage.setItem('tech_secureAgent', this.secureAgent);
     }
 
     handleComponentChange(event) {
         this.selectedProductComponent = event.detail.value;
         sessionStorage.setItem('tech_relatedComp', this.selectedProductComponent);
     }
 
     handleActivityChange(event) {
         this.selectedActivity = event.detail.value;
         sessionStorage.setItem('tech_activity', this.selectedActivity);
         this.clearDateSlotFieldValues();
         this.showAppointmentDateChecker();
     }
 
     handleEnvironmentChange(event) {
         this.selectedEnvironment = event.detail.value;
         sessionStorage.setItem('tech_env', this.selectedEnvironment);
         this.showAppointmentDateChecker();
     }
 
     handleSubjectChange(event) {
         this.subject = event.detail.value;
         sessionStorage.setItem('tech_sub', this.subject);        
     }
 
     handlePriorityChange(event) {
         this.selectedPriority = event.detail.value;
 
         if (this.selectedPriority == 'P1') {
             this.showBusinessImpact = true;
         }
         else {
             this.showBusinessImpact = false;
             this.selectedImpact = undefined;
             this.impactCheckbox = false;
             this.selectedEstimateDate = undefined;
         }
         sessionStorage.setItem('tech_priority', this.selectedPriority);
         this.showAppointmentDateChecker();
     }
 
     handleImpactChange(event){
         this.selectedImpact = event.detail.value;
         sessionStorage.setItem('tech_impact', this.selectedImpact);
     }
 
     handleDateChange(event){
         this.selectedEstimateDate = event.detail.value;
         let currentDate = new Date(new Date().toDateString());
         let selectedDate = new Date(new Date(this.selectedEstimateDate).toDateString());
         log(`currentDate -> ${currentDate}`);
         log(`selectedDate -> ${selectedDate}`);
         if(selectedDate < currentDate){
             event.target.setCustomValidity('Please select a date greater than or equal to today\'s date.');
             event.target.reportValidity();
         }
         else{
             event.target.setCustomValidity("");
             event.target.reportValidity();
             sessionStorage.setItem('tech_date', this.selectedEstimateDate);
         }
     }
 
     handleIssueSummaryChange(event) {
         this.issueSummary = event.detail.value;
     }
 
     handleDescriptionChange(event) {
         this.description = event.detail.value;
         sessionStorage.setItem('tech_desc', this.description);        
     }
 
     handleProcessCaseDescQualityIndicator(event) {
         log('handleProcessCaseDescQualityIndicator');
         this.handleSearchDataOnBlur(event); //For Case Deflection Search
         if (this.description == null && this.errorMessage == null && this.subject == null){
             this.isQIAvailable = false;
             return;
         }
         log('Calling apex controller method : processCaseDescQualityIndicator');
         processCaseDescQualityIndicator({ caseDesc: this.description, errorMsg: this.errorMessage, subject: this.subject, product: this.selectedProduct })
             .then(result => {
                 if (result) {
                     log('result= ' + result);
                     let response = JSON.parse(result);
                     this.cdqiApiJSONResponse = JSON.parse(result);  //<T02>
                     log('response : ' + JSON.stringify(response));
                     log('response.ActionTaken : ' + response.ActionTaken);
                     let score = response.DescriptionQualityScore;
                     this.qualityScore = response.DescriptionQualityScore + "%";
                     this.qualityScoreColor = response.DescriptionQualityColor;
                     this.boolActionTaken = response.ActionTaken == "1" ? true : false;
                     this.boolErrorMessage = response.ErrorMessage == "1" ? true : false;
                     this.boolIncidentTime = response.IncidentTime == "1" ? true : false;
                     this.boolProblemSymptom = response.ProblemSymptom == "1" ? true : false;
                     this.boolAdditionalDetails = response.AdditionalDetails == "1" ? true : false;
                     this.boolComponent = response.Component == "1" ? true : false;
                     // this.boolDetailDesc = (this.description != null && this.description.length > 100) ? true : false;;
                     this.problemSymptomExample = response.ProblemSymptomExample;
                     this.errorMessageExample = response.ErrorMessageExample;
                     this.incidentTimeExample = response.IncidentTimeExample;
                     this.actionTakenExample = response.ActionTakenExample;
                     this.additionalDetailsExample = response.AdditionalDetailsExample;
                     this.componentExample = response.ComponentExample;
                     log(' response.DescriptionQualityScore : ' + response.DescriptionQualityScore);
                     log(' response.DescriptionQualityColor : ' + response.DescriptionQualityColor);
 
                     switch(response.DescriptionQualityColor){
                         case "red":
                             this.isInAmber = false;
                             this.isInRed = true;
                             this.isInGreen = false;
                             break;
                         case "amber":
                             this.isInAmber = true;
                             this.isInRed = false;
                             this.isInGreen = false;
                             break;
                         case "green":
                             this.isInAmber = false;
                             this.isInRed = false;
                             this.isInGreen = true;
                             break;
                         default:
                             this.isInAmber = false;
                             this.isInRed = false;
                             this.isInGreen = false;
                             this.isQIAvailable = false;
                     }
                     if (score > 0){
                         this.isQIAvailable = true;
                     } else{
                         this.isQIAvailable = false;
                     }
                 } else {
                     this.isQIAvailable = false;
                 }
             }).catch(error => {
                 log('Error : ' + JSON.stringify(error));        //<T02>
             });
     }
 
     //For Case Deflection Search - Start
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
     //For Case Deflection Search - End
 
     get showPercentage(){
         return `width:${this.qualityScore};`;
     }
 
     handleprocessCaseRecommendation(event) {
         log('handleprocessCaseRecommendation');
         log('Calling apex controller method : processCaseRecommendation' );
         processCaseRecommendation({ caseDesc: this.description, errorMsg: this.errorMessage, title: this.subject, product: this.selectedProduct, component: this.selectedProductComponent, version: this.selectedVersion })
             .then(result => {
                 try {
                     if (result) {
                         if (result.kbHtmlText != "" && result.kbUrl != ""){
                             this.template.querySelector('.es-kb-log-recommendation').className = 's-kb-log-recommendation slds-show';
                         }
                         log('result= ' + JSON.stringify(result));
                         log('res :'+ result);
                         this.kbUrl = result.kbUrl;
                         this.logsHTML = result.kbHtmlText;
                         this.template.querySelector('.es-kb-recommended__desc').innerHTML =result.kbHtmlText;
                         log('this.kbUrl : ' + this.kbUrl);
                         } 
                 } catch (error) {
                     this.template.querySelector('.es-kb-log-recommendation').className = 's-kb-log-recommendation slds-hide';
                     log('Error in then block : ' + error);
                 }
                 
             }).catch(error => {
                 this.template.querySelector('.es-kb-log-recommendation').className = 's-kb-log-recommendation slds-hide';
 
                 log('Error : ' + error);
             });
     }
 
     handleErrorMessageChange(event) {
         this.errorMessage = event.detail.value;
         sessionStorage.setItem('tech_message', this.errorMessage);        
     }
 
     handleProblemTypeChange(event) {
         this.selectedProblemType = event.detail.value;
     }
 
     showAdditionalInfoTechnical() {
         if(this.hasReadWriteAccess){
             var isValidValue = this.validateInputField();
             if (isValidValue){
                 this.caseInformation = this.selectedPriority + ' | Subject : ' + this.subject;
                 this.technicalCaseInfo = false;
                 this.additionalInfoTechnical = true;
                 this.alternateContactInfo = false;
                 this.finalSummaryCase = false;
                 this.showCaseDetails = false;
                 this.handleprocessCaseRecommendation();
                 window.scrollTo(0, 0);
             }
         }
         else{
             this.showToastEvent('Error', 'You do not have access to create case for this Support Account.', 'error', 'dismissable');
         }
         
     }
     showAlternateContact() {
         this.technicalCaseInfo = false;
         this.additionalInfoTechnical = false;
         this.alternateContactInfo = true;
         this.finalSummaryCase = false;
         this.showCaseDetails = false;
         window.scrollTo(0, 0);
     }
 
     showFinalSummaryPage(event) {
         log('called');
         log('ContactList- ' + JSON.stringify(event.detail.finalContactList));
         this.contactsToAdd = event.detail.finalContactList;
         //this.allContactData = event.detail.allContactsToAdd;
         this.allContactData = this.contactsToAdd;
         if (this.contactsToAdd.length > 1) {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         } else {
             this.alternateContact = this.contactsToAdd.length + ' Contacts';
         }
         var caseObjInfo = {};
         caseObjInfo.category = 'Technical';
         caseObjInfo.priority = this.selectedPriority;
         caseObjInfo.supportAccount = this.selectedSupportAccountLabel;
         caseObjInfo.product = this.selectedProduct;
         caseObjInfo.problemArea = this.problemArea;
         caseObjInfo.successOffering = this.successOffering;
         caseObjInfo.environment = this.selectedEnvironment;
         caseObjInfo.relatedComponent = this.selectedProductComponent;
         caseObjInfo.subject = this.subject;
         caseObjInfo.description = this.description;
         caseObjInfo.attachments = this.fileSize;
         caseObjInfo.recordtypeName = this.recordTypeName;
         caseObjInfo.contacts = [];
         caseObjInfo.contacts = this.contactsToAdd;
         caseObjInfo.attachments = this.fileSize;
         caseObjInfo.percentage = this.qualityScore;
         caseObjInfo.strengthColor = this.qualityScoreColor;
 
         //T05 - capture both the Org Id and Org UUID so that Org UUID can be shown in the Summary section
         if(this.selectedOrg == null || this.selectedOrg == undefined || this.selectedOrg == ''){
             caseObjInfo.orgId = this.ManualOrgId;
             caseObjInfo.orgUUID = this.ManualOrgId;
         }else{
             caseObjInfo.orgId = this.selectedOrg;
             this.orgs.forEach(element => {
                 if(element.value == this.selectedOrg){
                     caseObjInfo.orgUUID = element.label;
                 }
             });
         }
 
         caseObjInfo.secureAgent = this.secureAgent;
         caseObjInfo.activity = this.selectedActivity;
         caseObjInfo.cdqiJSON = this.cdqiApiJSONResponse;        //<T02>
         if(this.recordTypeName === 'Operations' && SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivity)){
             caseObjInfo.serviceApointmentStart = this.slotStartDT;
             caseObjInfo.serviceApointmentEnd = this.slotEndDT;        
         }
         this.caseInfoToSave = caseObjInfo;
         this.technicalCaseInfo = false;
         this.additionalInfoTechnical = false;
         this.alternateContactInfo = false;
         this.finalSummaryCase = true;
 
         /*
         getResponseTimeForCase({accountId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: 'Technical'})
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
         getCaseIRDateTime({supportAccId : this.selectedSupportAccount, casePriority : this.selectedPriority, recordTypeName: 'Technical', entitlementId: entId})
         .then(result => {
             log('caseReaponse time= '+result);
             this.caseResponseTime = result;
         })
         .catch(error => {
             log('error while getting response time'+JSON.stringify(error));
         });
         window.scrollTo(0, 0);
     }
 
     backToAlternateContact(event) {
         log('back to alternate contact -> '+JSON.stringify(event.detail));
         let preselectedContactList = event.detail.contacts;
         let preselectedContactsPerPage = event.detail.contactList;
         log("data1234", event.detail);
         log('preselectedContactList: '+JSON.stringify(preselectedContactList));
         log('preselectedContactsPerPage: '+JSON.stringify(preselectedContactsPerPage));
         this.selectedContactList = [];
         for(let i = 0; i < preselectedContactList.length; i++){
             this.selectedContactList.push(preselectedContactList[i].ContactId);
         }
         this.allContactData = preselectedContactsPerPage;
         log('allcontactdata: '+JSON.stringify(this.allContactData));
         this.technicalCaseInfo = false;
         this.additionalInfoTechnical = false;
         this.alternateContactInfo = true;
         this.finalSummaryCase = false;
         this.showCaseDetails = false;
         window.scrollTo(0, 0);
     }
 
     backToAdditionalInfoTechnical(event) {
         let preselectedContactList = event.detail.finalContactList;
         //this.allContactData = event.detail.allContactsToAdd;
         this.allContactData = preselectedContactList;
         this.selectedContactList = [];
         for(let i = 0; i < preselectedContactList.length; i++){
             this.selectedContactList.push(preselectedContactList[i].ContactId);
         }
         this.technicalCaseInfo = false;
         this.additionalInfoTechnical = true;
         this.alternateContactInfo = false;
         this.finalSummaryCase = false;
         this.showCaseDetails = false;
         window.scrollTo(0, 0);
     }
 
     backToTechnicalCaseInfo() {
         this.technicalCaseInfo = true;
         this.additionalInfoTechnical = false;
         this.alternateContactInfo = false;
         this.finalSummaryCase = false;
         this.showCaseDetails = false;
         window.scrollTo(0, 0);
     }
 
     saveCase(event) {
         log('event---> called' + event.detail);
         let contacts = [];
         contacts = event.detail;
         this.showSpinner = true;        
         document.body.setAttribute('style', 'overflow: hidden;');
         var caseObj = {};
         caseObj.Support_Account__c = this.selectedSupportAccount;
         caseObj.Forecast_Product__c = this.selectedProduct;
         caseObj.Version__c = this.selectedVersion;
         if(this.isOrgValue)       
             caseObj.Org_ID__c=this.ManualOrgId;//set manually added org id
         else
             caseObj.Org__c = this.selectedOrg;
             caseObj.Secure_Agent__c = this.secureAgent;
         caseObj.Component__c = this.selectedProductComponent;
         caseObj.Activity_Type__c = this.selectedActivity;
         caseObj.Environment__c = this.selectedEnvironment;
         caseObj.Priority = this.selectedPriority;
         caseObj.Issue_Summary__c = this.issueSummary;
         caseObj.Description = this.description;
         caseObj.Error_Message__c = this.errorMessage;
         caseObj.Subject = this.subject;
         caseObj.Problem_Type__c = this.selectedProblemType;
         caseObj.CDQI_JSON__c = JSON.stringify(this.cdqiApiJSONResponse);        //<T03>
         caseObj.Business_Impact__c = this.selectedImpact;
         if(this.selectedEstimateDate){
             caseObj.Estimated_Date_for_Milestone__c = this.selectedEstimateDate;
         }
         log('caseObj== ' + JSON.stringify(caseObj));
         var slot = [];
         if(this.recordTypeName === 'Operations' && SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivity)){
             slot.push(this.slotStartDT);
             slot.push(this.slotEndDT);
         }
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
         
         createCase({ caseJson: JSON.stringify(caseObj), recordTypeName: this.recordTypeName, caseRelatedContacts: contacts, environmentType: this.selectedEnvironment, slotSelected: slot, product: product })
             .then(strCaseId => { //<T11>
                 this.handleCaseDeflectionOnSubmit(); //For Case Deflection Search
                 var url = CommunityURL + 'casedetails?caseId=' + strCaseId;
                         window.open(url, '_self');
                 this.showSpinner = false;
                 document.body.removeAttribute('style', 'overflow: hidden;');
                     /** START-- adobe analytics */
                 try {
                     util.trackCreateCase("Technical", "Completed");
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
 
     handleTick(event) {
         this.doesImpactMilestone = event.target.checked;
         if(!this.doesImpactMilestone){
             this.selectedEstimateDate = undefined;
         }
         sessionStorage.setItem('tech_milestone', this.doesImpactMilestone);
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
 
     get acceptedFormats() {
         let acceptedFileFormates = [];
         getAcceptedFileFormates({})
             .then(result => {
                 acceptedFileFormates = result;
             });
         log('acceptedFileFormates= ' + JSON.stringify(acceptedFileFormates));
         return acceptedFileFormates;
     }
 
     handleAddFile() {
         this.template.querySelector('#add-file').className = 'slds-visible';
     }
 
     handleUploadFinished(event) {
         //Get the list of uploaded files
         this.showSpinner = true;
         const uploadedFiles = event.detail.files;
         
         //this.fileSize = this.fileSize + uploadedFiles.length + message;
         
         getUploadedFiles()
             .then(result => {
                 if (result) {
                     log('result= ' + JSON.stringify(result));
                     this.uploadedFiles = result;
                     let message = ' File is attached';
                     if (this.uploadedFiles.length > 1) {
                         message = ' Files are attached';
                     }
                     this.fileSize = this.uploadedFiles.length + message;
                     this.showUploadedFiles = true;
                     log('@@@-----this.fileSize----->>>'+this.fileSize);
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
 
     removeAttachmentDetails(event) {
         this.fileToRemove = event.target.value;
         this.isDeleteModal = true;
     }
 
     confirmFileRemoveDetail() {
         this.showSpinner = true;
         removeFile({ documentId: this.fileToRemove, caseId: this.caseInfo.Id })
             .then(result => {
                 if (result) {
                     log('result= ' + JSON.stringify(result));
                     this.caseDocuments = result;
                     this.isDeleteModal = false;
                 }
                 this.showSpinner = false;
             });
     }
 
     cancelFileRemoveDetail() {
         this.fileToRemove = '';
         this.isDeleteModal = false;
     }
 
     showCancelpopup() {
         log('called cancel popup');
         this.showCaseCancelModal = true;
     }
 
     hideCancelPopup() {
         this.showCaseCancelModal = false;
     }
 
     handleAlternateContacts() {
 
     }
 
     //Amarender -> I2RT-717: eSupport:LiveChat - Start
     handleStartChat() {
         var flatButton = $('.flatButton');
         var helpButton = $('.helpButton');
         log('flatButton : ' + flatButton.text());
         log('helpButton : ' + helpButton.text());
         if (flatButton !== null && flatButton.text().includes('Chat with an Expert')) {
             this.showSpinner = true;
             new Promise(
                 (resolve, reject) => {
                     flatButton.trigger("click");
                     setTimeout(() => {
                         resolve();
                     }, 3000);
                 }).then(
                     () => this.showSpinner = false
                 );
 
         }
         if (helpButton !== null && helpButton.text().includes('Chat with an Expert')) {
             this.showSpinner = true;
             new Promise(
                 (resolve, reject) => {
                     setTimeout(() => {
                         helpButton.trigger("click");
                         resolve();
                     }, 0);
                 }).then(
                     () => this.showSpinner = false
                 );
         }
     }
 
     get showChatButton() {
 
         if (this.isAgentAvailable && this.cloudProductSelected) {
             return true;
         }
 
         return false;
     }
 
     handleCloudProduct() {
         this.cloudProductSelected = false;
         if (!this.cloudProductSelected) {
             var closeButton = $('.closeButton');
             log('closeButton : ' + $('.closeButton'));
             closeButton.trigger("click");
         }
     }
     //Amarender -> I2RT-717: eSupport:LiveChat - End
 
     validateInputField(){
         var isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input, lightning-textarea')]
         .reduce((validSoFar, inputField) => {
             inputField.reportValidity();
             log('inputvalidatity: '+JSON.stringify(inputField.reportValidity()));
             return validSoFar && inputField.checkValidity();
         }, true);
         return isValidValue;
     }
 
     backButton(){
         window.open(this.prevPageURL, '_self');
     }
 
     goPrevPage(event){
         this.handleCaseDeflectionOnCancel(); //For Case Deflection Search
         event.preventDefault();
         this.clearSessionData();
         this.hideCancelPopup();
         window.open(this.prevPageURL, '_self');
     }
 
     clearSessionData(){
         sessionStorage.removeItem('tech_account');
         sessionStorage.removeItem('tech_product');
         sessionStorage.removeItem('tech_version');
         sessionStorage.removeItem('tech_orgName');
         sessionStorage.removeItem('tech_secureAgent');
         sessionStorage.removeItem('tech_activity');
         sessionStorage.removeItem('tech_env');
         sessionStorage.removeItem('tech_relatedComp');
         sessionStorage.removeItem('tech_priority');
         sessionStorage.removeItem('tech_sub');
         sessionStorage.removeItem('tech_desc');
         sessionStorage.removeItem('tech_message');
         sessionStorage.removeItem('tech_impact');
         sessionStorage.removeItem('tech_milestone');
         sessionStorage.removeItem('tech_date');
         sessionStorage.removeItem('showManualOrgID');
         sessionStorage.removeItem('ManualOrgID');
         
         sessionStorage.removeItem["tech_accountName"]; //For Case Deflection Search                        
         
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
 
     //---------------------------------------<T04>--------------------------------
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
         })
     }
     //---------------------------------------</T04>-------------------------------
 
     showToastEvent(title, message, variant, mode) {
         const event = new ShowToastEvent({
             title,
             message,
             variant,
             mode
         });
         this.dispatchEvent(event);
     }
 
     /* Operations case activity window */
 
     showAppointmentDateChecker(){
         this.showSessionDate = SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivity) ? true : false;
         this.clearDateSlotFieldValues();
 
         if(SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivity) && this.selectedEnvironment && this.selectedPriority){
             getAvailableSlots({ priority: this.selectedPriority, environmentType: this.selectedEnvironment })
                 .then(objSlotsMap => {
                     log('available slots >> '+JSON.stringify(objSlotsMap));
                     this.processAvailableSlots(objSlotsMap);
                 })
                 .catch(error => {
                     log('error getting available slots >> '+JSON.stringify(error));
                 })
         }
     }
 
     handleDateSelect(event){
         this.selectedDate = event.detail.value;
         this.selectedSlot = undefined;
         log('Selected Date >> '+event.detail.value);
         let slots = new Array();
 
         this.availableDatesWithSlots.forEach(objDay => {
             if(objDay.strDate === this.selectedDate){
                 objDay.lstSlots.forEach(objSlot => {
                     slots.push({label: objSlot.strSlotLabel, value: objSlot.strId});
                 })
             }
         });
         this.availableSlots = slots;
     }
 
     handleSlotSelect(event){
         this.selectedSlot = event.detail.value;
         log('slotId >> '+event.detail.value);
         this.availableDatesWithSlots.forEach(objDay => {
             objDay.lstSlots.forEach(objSlot => {
                 if(objSlot.strId === event.detail.value){
                     this.slotStartDT = objSlot.startDT;
                     this.slotEndDT = objSlot.endDT;
                 }
             })
         });
         log('slotStartDateTime >> '+this.slotStartDT);
         log('slotEndDateTime >> '+this.slotEndDT);
     }
 
     processAvailableSlots(objSlotsMap){
         let boolHasSlots;
         let intIndex = 0;
         let lstAvailableDatesAndSlots = new Array();
         let lstAvailableDates = new Array();
 
         Object.entries(objSlotsMap).map(objDay => {
             boolHasSlots = false;
             if(typeof objDay[1] !== "undefined" && objDay[1] !== null && objDay[1].length > 0) {
                 boolHasSlots = true;
                 objDay[1].forEach(objSlot => {
                     objSlot.strSlotLabel = (new Intl.DateTimeFormat('en-US', {
                         hour: '2-digit', 
                         hourCycle: 'h12',
                         minute: '2-digit',
                         timeZone: TIME_ZONE,
                     }).format(new Date(objSlot.startDT)))/*.replace("AM", "").replace("PM", "").replace(" ", "") + " - " + (new Intl.DateTimeFormat('en-US', {
                         hour: '2-digit', 
                         hourCycle: 'h12',
                         minute: '2-digit',
                         timeZone: TIME_ZONE,
                     }).format(new Date(objSlot.endDT))).toLowerCase()*/;
                     objSlot.strId = "" + intIndex;
                     intIndex++;
                 });
             }
 
             if(boolHasSlots){
                 lstAvailableDatesAndSlots.push({
                     strDate: objDay[0],
                     lstSlots: objDay[1]
                 });
                 lstAvailableDates.push({
                     label: objDay[0], 
                     value: objDay[0]
                 });
             }
         });
         log('objSlotsMap processed >> '+JSON.stringify(objSlotsMap));
         this.availableDatesWithSlots = lstAvailableDatesAndSlots;
         this.availableDates = lstAvailableDates;
         log('processed dates >> '+JSON.stringify(this.availableDates));
     }
 
     clearDateSlotFieldValues(){
         this.selectedDate = undefined;
         this.selectedSlot = undefined;
         this.slotStartDT = undefined;
         this.slotEndDT = undefined;
         this.availableDates = undefined;
         this.availableSlots = undefined;
     }
 
     resetFields(){
         this.deliveryMethods = [];
         this.disableDeliveryMethod = false;
         this.selectedDeliveryMethod = undefined;
         this.selectedActivity = undefined;
         this.selectedEnvironment = undefined;
         this.selectedOrg = undefined;
         this.ManualOrgId = undefined;
         this.showBanner = false;
     }
 }