/*
 Change History
 *************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                          Tag
 *************************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                                     NA
 Vignesh Divakaran      10-14-2022      I2RT-7319           Hide Case Lite record type from the list of available options        T01
 Isha Bansal            03-30-2023      I2RT-6727           Include FTO in the change owner while record type change             T02
 Shashikanth            09-22-2023      I2RT-9026           Capture Components fields even for Fulfilment cases                  T03
                                                                                          
 */
 import { LightningElement,wire,api,track } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 import { getPicklistValues } from 'lightning/uiObjectInfoApi';
 import { CloseActionScreenEvent } from 'lightning/actions';
 
 import { log } from 'c/globalUtilities'; //Vignesh
 
 import CASE_OBJECT from '@salesforce/schema/Case';
 import ENVIRONMENT from '@salesforce/schema/Case.Environment__c';
 import ACTIVITY_TYPE from '@salesforce/schema/Case.Activity_Type__c';
 import PROBLEM_AREA from '@salesforce/schema/Case.Problem_Area__c';
 import PRIORITY from '@salesforce/schema/Case.Priority';
 import TIME_ZONE from '@salesforce/i18n/timeZone';
 
 import getProducts from '@salesforce/apex/CaseController.getProducts';
 import doCaseRecordTypeChange from '@salesforce/apex/CaseController.doCaseRecordTypeChange';
 import getAvailableSlots from '@salesforce/apex/OperationsSchedulerController.getAvailableSlots';
 import lookupCombinedSearch from '@salesforce/apex/RaiseHandController.lookupCombinedSearch';
 import getVersionforSelectedProduct from '@salesforce/apex/CaseController.getVersionforSelectedProduct';
 import { unsubscribe } from 'lightning/messageService';
 
 const CASE_FIELDS = [
     'Case.Subject',
     'Case.CaseNumber',
     'Case.Status',
     'Case.RecordTypeId',
     'Case.Description',
     'Case.Issue_Summary__c',
     'Case.Environment__c',
     'Case.Activity_Type__c',
     'Case.Priority',
     'Case.Support_Account__c',
     'Case.Problem_Area__c',
     'Case.Entitled_Product__c',
     'Case.Entitled_Product__r.Name',
     'Case.Forecast_Product__c',
     'Case.Version__c',
     'Case.Component__c',
     'Case.Subcomponent__c'
 ];
 const SCHEDULED_ACTIVITY_TYPE = ['Request an activity/change request'];
 const CASE_TECHNICAL = 'Technical';
 const CASE_OPERATIONS = 'Operations';
 const CASE_ADMINISTRATIVE = 'Administrative';
 const CASE_FULFILLMENT = 'Fulfillment';
 const CASE_ASK_AN_EXPERT = 'Ask An Expert';
 
 export default class CaseChangeRecordType extends LightningElement {
   @api recordId;
   caseRecord;
   caseSchema;
 
   selectedRecordType;
   lstSelectedRecordType;
   lstRecordType;
 
   lstCurrentRecordType;
   currentRecordType;
 
   bCaseSchemaFetchCompleted = false;
   bCaseRecordFetchCompleted = false;
 
   isClosedCase = true;
   sCloseCaseErrorMsg = '';
 
   bRequiredServiceAppointment = false;
   mapCaseRecordTypeIdWiseName = new Map();
   
   showSpinner = false;
   enteredIssueSummary;
   enteredDescription;
 
   lstEnvironment = [];
   selectedEnvironment;
   
   lstAllActivityType = [];
   lstActivityType = [];
   selectedActivityType;
 
   lstPriority = [];
   selectedPriority;
   
   step = 1;
   displayftotable=false; // T02 I2RT-6727
   //Operations Activity Window
   @track showSessionDate = false;
   @track userTimeZone = TIME_ZONE;
   @track availableDatesWithSlots;
   @track availableDates;
   @track selectedDate;
   @track availableSlots;
   @track selectedSlot;
   slotStartDT;
   slotEndDT;
   changedCaseOwnerId;
   @track disableBTNs = true;
 
   allProducts = [];
   lstProducts = [];
   lstVersions = [];
   selectedProduct;
   productName = '';
   selectedVersion;
   lstProblemArea = [];
   selectedProblemArea;
 
   //1
   constructor() {
     super();
     log('@Log=> Constructor:CaseChangeRecordType:');
   }
 
   //2
 
   @wire(getObjectInfo, {
     objectApiName: CASE_OBJECT
   })
   fetchCaseSchema({ error, data }) {
     if (data) {
       this.error = undefined;
       log("fetchCaseSchema.start=>");
       this.caseSchema = data;
       //log('caseSchema=>' + JSON.stringify(this.caseSchema));
       this.bCaseSchemaFetchCompleted = true;
       this.doInit();
       log("fetchCaseSchema.end=>");
     } else if (error) {
       this.error = error;
       log("@Log=>error:" + JSON.stringify(error));
     }
   }
 
   @wire(getPicklistValues, {
     recordTypeId: "$caseSchema.defaultRecordTypeId",
     fieldApiName: ENVIRONMENT
   })
   fetchEnvironmentPickList({ data, error }) {
     if (data) {
       log("fetchEnvironmentPickList.start=>");
       for (var i in data.values) {
         log("@Log=>data.values[i]:" + JSON.stringify(data.values[i]));
         this.lstEnvironment.push({
           label: data.values[i].value,
           value: data.values[i].value
         });
       }
       log("fetchEnvironmentPickList.end=>");
     } else {
       log("@Log=>error:" + JSON.stringify(error));
     }
   }
 
   @wire(getPicklistValues, {
     recordTypeId: "$caseSchema.defaultRecordTypeId",
     fieldApiName: ACTIVITY_TYPE
   })
   fetchActivityTypePickList({ data, error }) {
     if (data) {
       log("fetchActivityTypePickList.start=>");
       for (var i in data.values) {
         log("@Log=>data.values[i]:" + JSON.stringify(data.values[i]));
         
         let selectedRecordTypeName = this.mapCaseRecordTypeIdWiseName.get(this.selectedRecordType);
         log('@Log=> selectedRecordTypeName:' + selectedRecordTypeName);
 
         //@Akhilesh 17 May 2021 -- start
         /*this.lstActivityType.push({
           label: data.values[i].value,
           value: data.values[i].value
         });*/
         this.lstAllActivityType.push(data.values[i]);
         //@Akhilesh 17 May 2021 -- end
 
       }
       log("fetchActivityTypePickList.end=>");
     } else {
       log("@Log=>error:" + JSON.stringify(error));
     }
   }
 
   @wire(getPicklistValues, {
     recordTypeId: "$caseSchema.defaultRecordTypeId",
     fieldApiName: PROBLEM_AREA
   })
   fetchProblemAreaPickList({ data, error }) {
     if (data) {
       log("fetchProblemAreaPickList.start=>");
       for (var i in data.values) {
         log("@Log=>data.values[i]:" + JSON.stringify(data.values[i]));
         this.lstProblemArea.push({
           label: data.values[i].value,
           value: data.values[i].value
         });
       }
       log("fetchProblemAreaPickList.end=>");
     } else {
       log("@Log=>error:" + JSON.stringify(error));
     }
   }
 
   @wire(getPicklistValues, {
     recordTypeId: "$caseSchema.defaultRecordTypeId",
     fieldApiName: PRIORITY
   })
   fetchPriorityPickList({ data, error }) {
     if (data) {
       log("fetchPriorityPickList.start=>");
       for (var i in data.values) {
         log("@Log=>data.values[i]:" + JSON.stringify(data.values[i]));
 
         this.lstPriority.push({
           label: data.values[i].value,
           value: data.values[i].value
         });
         
       }
 
       this.lstPriority.sort((a, b) => (a.label > b.label) ? 1 : -1);
 
       log('@Log=> this.lstPriority:' + JSON.stringify(this.lstPriority));
       log("fetchPriorityPickList.end=>");
     } else {
       log("@Log=>error:" + JSON.stringify(error));
     }
   }
 
   @wire(getRecord, {
     recordId: "$recordId",
     fields: CASE_FIELDS
   })
   fetchCaseRecord({ error, data }) {
     if (data) {
       log("fetchCaseRecord.start=>"+JSON.stringify(data));
       this.caseRecord = data;
       //log('caseRecord=>' + JSON.stringify(this.caseRecord));
       //log('data.fields.Status.value=>' + data.fields.Status.value);
       if (
         data.fields.Status.value != "Closed" &&
         data.fields.Status.value != "Resolved"
       ) {
         this.isClosedCase = false;
       } else {
         this.sCloseCaseErrorMsg =
           'Record type change for "Closed Case" is not allowed.';
       }
       this.bCaseRecordFetchCompleted = true;
       this.doInit();
       log("fetchCaseRecord.end=>");
     } else if (error) {
       log("error=>" + error);
     }
   }
 
   @wire(getVersionforSelectedProduct, { selectedProduct: '$productName' })
   versions({ error, data }) {
       if (data) {
         log('Get Versions: '+JSON.stringify(data));
 
           let versionOptions = [];
           data.forEach(version => {
             versionOptions.push({label: version, value: version});
           });
 
           this.lstVersions = versionOptions;
           log('Final Versions: '+JSON.stringify(this.lstVersions));
       } else if (error) {
           log('Get Version Error:'+JSON.stringify(error));
           //this.showToast("Error!", error.body.message, "error");
       }
   }
 
   //3
   doInit() {
     log("@Log=> doInit:");
 
     if (this.bCaseSchemaFetchCompleted && this.bCaseRecordFetchCompleted) {
       log("recordId:" + this.recordId);
       //log("this.caseSchema=>" + JSON.stringify(this.caseSchema));
       //log("this.caseRecord=>" + JSON.stringify(this.caseRecord));
 
       let optionsValues = [];
       let existingOptionsValues = [];
       const rtInfos = this.caseSchema.recordTypeInfos;
       //log("rtInfos=>" + JSON.stringify(rtInfos));
 
       let rtValues = Object.values(rtInfos);
       //log("rtValues=>" + JSON.stringify(rtValues));
 
       for (let i = 0; i < rtValues.length; i++) {
         this.mapCaseRecordTypeIdWiseName.set(
           rtValues[i].recordTypeId,
           rtValues[i].name
         );
 
         if (rtValues[i].name !== "Master" && rtValues[i].name !== CASE_ASK_AN_EXPERT && rtValues[i].name !== 'Case Lite') { //<T01>
           if (this.caseRecord.recordTypeId != rtValues[i].recordTypeId) {
             optionsValues.push({
               label: rtValues[i].name,
               value: rtValues[i].recordTypeId
             });
           } else {
             this.currentRecordType = this.caseRecord.recordTypeId;
             existingOptionsValues.push({
               label: rtValues[i].name,
               value: rtValues[i].recordTypeId
             });
           }
         }
       }
       this.lstCurrentRecordType = existingOptionsValues;
       this.lstRecordType = optionsValues;
 
       this.enteredIssueSummary  = this.caseRecord.fields.Issue_Summary__c.value;
       this.enteredDescription  = this.caseRecord.fields.Description.value;
       this.selectedEnvironment = this.caseRecord.fields.Environment__c.value;
 
       this.selectedActivityType = this.caseRecord.fields.Activity_Type__c.value;
       this.selectedPriority = this.caseRecord.fields.Priority.value;
       this.selectedProblemArea = this.caseRecord.fields.Problem_Area__c.value;
       this.showAppointmentDateChecker();
     }
   }
   
   /* Handle Selections */
 
   handleRecordTypeChange(event) {
     log("@Log=>handleRecordTypeChange");
     this.selectedRecordType = event.detail.value;
     this.lstSelectedRecordType = [];
     this.lstSelectedRecordType.push({
       label: this.mapCaseRecordTypeIdWiseName.get(this.selectedRecordType),
       value: this.selectedRecordType
     });
     log(
       "@Log=> selectedRecordType:" +
         this.mapCaseRecordTypeIdWiseName.get(this.selectedRecordType)
     );
     this.disableNextBTN();
     this.clearValues();
   }
 
   handleCombinedLookupSearch(event) {
     const lookupElement = event.target;    
     lookupCombinedSearch(event.detail)
         .then(results => {
             log('lookup results: '+JSON.stringify(results));
             lookupElement.setSearchResults(results);
         })
         .catch(error => {
             log('Combined Lookup Failed -> ' + error);
         });
   }
   handleCombinedLookupSelectionChange(event) {
       const selectedId = event.detail.values().next().value;
       log('[Child] selectedId -> ' + selectedId);     
       this.changedCaseOwnerId = selectedId;
       if(selectedId!=undefined && selectedId!=null && selectedId.startsWith('005')){ // T02 - if selected is is user and not queue  I2RT-6727         
         this.displayftotable=true;       //show event details       
       }else{
         this.displayftotable=false;
       }
       this.disableNextBTN();     
   }
 
   handleProductChange(event){
     this.selectedProduct = event.detail.value;
     this.selectedVersion = undefined;
     if(this.selectedProduct !== '----Entitled Products----' && this.selectedProduct !== '----Unentitled Products----'){
       this.allProducts.forEach(productObj => {
         if(productObj.productName === this.selectedProduct){
           this.productName = this.selectedProduct.replace(productObj.deliveryMethod, '');
         }
       })
     }
     else{
       this.productName = '';
     }
   } 
 
   handleVersionChange(event){
     this.selectedVersion = event.detail.value;
     log('selected version: '+this.selectedVersion);
   }
 
   handleProblemAreaChange(event){
     this.selectedProblemArea = event.detail.value;
   }
 
   handleIssueSummaryChange(event) {
     log("@Log=>handleIssueSummaryChange");
     this.enteredIssueSummary = event.detail.value;
   }
 
   handleDescriptionChange(event) {
     log("@Log=>handleDescriptionChange");
     this.enteredDescription = event.detail.value;
   }
 
   handleEnvironmentChange(event) {
     log("@Log=>handleEnvironmentChange");
     this.selectedEnvironment = event.detail.value;  
     this.showAppointmentDateChecker(); //Vignesh D: I2RT-581 -> Operations Scheduler
   }
 
   handleActivityTypeChange(event) {
     log("@Log=>handleActivityTypeChange");
     this.selectedActivityType = event.detail.value;
     this.showAppointmentDateChecker(); //Vignesh D: I2RT-581
   }
 
   handlePriorityChange(event) {
     log("@Log=>handlePriorityChange");
     this.selectedPriority = event.detail.value;
     this.showAppointmentDateChecker(); //Vignesh D: I2RT-581
   }
 
   /* Operations case activity window */
   showAppointmentDateChecker() {
     this.showSessionDate = SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType) ? true : false;
     this.clearDateSlotFieldValues();
 
     if (SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType) && this.selectedEnvironment && this.selectedPriority) {
       getAvailableSlots({ priority: this.selectedPriority, environmentType: this.selectedEnvironment })
         .then(objSlotsMap => {
           log('available slots >> ' + JSON.stringify(objSlotsMap));
           this.processAvailableSlots(objSlotsMap);
         })
         .catch(error => {
           log('error getting available slots >> ' + JSON.stringify(error));
         })
     }
   }
 
   handleDateSelect(event) {
     this.selectedDate = event.detail.value;
     this.selectedSlot = undefined;
     log('Selected Date >> ' + event.detail.value);
     let slots = new Array();
 
     this.availableDatesWithSlots.forEach(objDay => {
       if (objDay.strDate === this.selectedDate) {
         objDay.lstSlots.forEach(objSlot => {
           slots.push({ label: objSlot.strSlotLabel, value: objSlot.strId });
         })
       }
     });
     this.availableSlots = slots;
   }
 
   handleSlotSelect(event) {
     this.selectedSlot = event.detail.value;
     log('slotId >> ' + event.detail.value);
     this.availableDatesWithSlots.forEach(objDay => {
       objDay.lstSlots.forEach(objSlot => {
         if (objSlot.strId === event.detail.value) {
           this.slotStartDT = objSlot.startDT;
           this.slotEndDT = objSlot.endDT;
         }
       })
     });
     log('slotStartDateTime >> ' + this.slotStartDT);
     log('slotEndDateTime >> ' + this.slotEndDT);
   }
 
   processAvailableSlots(objSlotsMap) {
     let boolHasSlots;
     let intIndex = 0;
     let lstAvailableDatesAndSlots = new Array();
     let lstAvailableDates = new Array();
 
     Object.entries(objSlotsMap).map(objDay => {
       boolHasSlots = false;
       if (typeof objDay[1] !== "undefined" && objDay[1] !== null && objDay[1].length > 0) {
         boolHasSlots = true;
         objDay[1].forEach(objSlot => {
           objSlot.strSlotLabel = (new Intl.DateTimeFormat('en-US', {
             hour: '2-digit',
             hourCycle: 'h12',
             minute: '2-digit',
             timeZone: TIME_ZONE,
           }).format(new Date(objSlot.startDT)));
           objSlot.strId = "" + intIndex;
           intIndex++;
         });
       }
 
       if (boolHasSlots) {
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
     log('objSlotsMap processed >> ' + JSON.stringify(objSlotsMap));
     this.availableDatesWithSlots = lstAvailableDatesAndSlots;
     this.availableDates = lstAvailableDates;
     log('processed dates >> ' + JSON.stringify(this.availableDates));
   }
 
   getProductsDetails(){
     log('Support Account: '+this.caseRecord.fields.Support_Account__c.value);
     getProducts({ supportAccId:  this.caseRecord.fields.Support_Account__c.value})
       .then(productWrapper => {
         log('Get Products: '+JSON.stringify(productWrapper));
         let entitledProducts = [];
         let unEntitledProducts = [];
         let productOptions = [];
 
         productWrapper.forEach(product => {
           if(product.isEntitledProduct){
             Object.keys(product.deliveryMethodEntIdMap).forEach(dm => {
               var productName = `${product.productName}(${dm})`;
               var entitledProductId = product.deliveryMethodEntIdMap[dm];
               var deliveryMethod = `(${dm})`;
               entitledProducts.push({productName: productName, entitledProductId: entitledProductId, deliveryMethod: deliveryMethod});
             })
           }
           else if(!product.isEntitledProduct){
             Object.keys(product.deliveryMethodEntIdMap).forEach(dm => {
               var productName = `${product.productName}(${dm})`;
               var entitledProductId = '';
               var deliveryMethod = `(${dm})`;
               unEntitledProducts.push({productName: productName, entitledProductId: entitledProductId, deliveryMethod: deliveryMethod});
             })
           }
         });
 
         this.allProducts = entitledProducts.concat(unEntitledProducts);
 
         if(entitledProducts.length > 0){
             productOptions.push({label: '----Entitled Products----', value: '----Entitled Products----'});
             entitledProducts.forEach(product => {
                 productOptions.push({label: product.productName, value: product.productName});
             })
         }
         if(unEntitledProducts.length > 0){
             productOptions.push({label: '----Unentitled Products----', value: '----Unentitled Products----'});
             unEntitledProducts.forEach(product => {
                 productOptions.push({label: product.productName, value: product.productName});
             })
         }
         log('Final list of Products: '+JSON.stringify(productOptions));
         this.lstProducts = productOptions;
       })
       .catch(error => {
         log('Get Products Error: '+JSON.stringify(error));
         this.showToast("Error!", error.body.message, "error");
       })
   }
 
   /* Validate Button Display */
 
   disableNextBTN(){
     this.disableBTNs = this.selectedRecordType && this.selectedRecordType !== '' /*&& this.changedCaseOwnerId && this.changedCaseOwnerId !== ''*/ ? false : true;
   }
 
 
   /* OnClick Event Methods */
 
   onPrevious() {
     log("@Log=> onPrevious:");
     if (this.step == 2) {
       this.step--;
     }
   }
 
   onNext() {
     log("@Log=> onNext:");
     if (this.step == 1) {
       this.step++;
 
       this.lstActivityType = [];
       //@Akhilesh 17 May 2021 -- start
       let selectedRecordTypeName = this.mapCaseRecordTypeIdWiseName.get(this.selectedRecordType);
       log('@Log=> selectedRecordTypeName:' + selectedRecordTypeName);
       for (var i in this.lstAllActivityType) {
         if(selectedRecordTypeName == 'Operations'){
           if(this.lstAllActivityType[i].value != 'Technical Issue'){
             this.lstActivityType.push({
                 label: this.lstAllActivityType[i].value,
                 value: this.lstAllActivityType[i].value
             });
           }
         }
       }
       //@Akhilesh 17 May 2021 -- start
 
       this.enteredIssueSummary  = this.caseRecord.fields.Issue_Summary__c.value;
       this.enteredDescription  = this.caseRecord.fields.Description.value;
       this.selectedEnvironment = this.caseRecord.fields.Environment__c.value;
       this.selectedActivityType = this.caseRecord.fields.Activity_Type__c.value;
       this.selectedPriority = this.caseRecord.fields.Priority.value;
       this.selectedProblemArea = this.caseRecord?.fields?.Problem_Area__c?.value;
       this.getProductsDetails();
     }
    
   }
 
   onSave() {
     this.disableBTNs = true;
     this.showSpinner = true;
     log("@Log=>onSave");
     log("@Log=>this.selectedRecordType:" + this.selectedRecordType);
 
     let existingRecordTypeName = this.mapCaseRecordTypeIdWiseName.get(this.currentRecordType);
     log("@Log=>existingRecordTypeName:" + existingRecordTypeName);
 
     let selectedRecordTypeName = this.mapCaseRecordTypeIdWiseName.get(this.selectedRecordType);
     log("@Log=>selectedRecordTypeName:" + selectedRecordTypeName);
     
     var product = [];
     let oCase = {
       'sobjecType': 'Case'
     };
     oCase.Id = this.recordId;
     oCase.RecordTypeId = this.selectedRecordType;
     if(this.changedCaseOwnerId && this.changedCaseOwnerId !== ''){
       oCase.OwnerId = this.changedCaseOwnerId;
     }
     if(this.productName && this.productName !== ''){
       oCase.Forecast_Product__c = this.productName;
       
       log('allProducts: '+JSON.stringify(this.allProducts));
       this.allProducts.forEach(productObj => {
         if(productObj.productName === this.selectedProduct){
           product.push(productObj.productName);
           let deliveryMethod = productObj.deliveryMethod.replace('(','').replace(')','');
           product.push(deliveryMethod);
           product.push(productObj.entitledProductId);
         }
       });
     }

     //<T03>
     if((this.productName && this.productName !== '') || 
        (existingRecordTypeName === CASE_FULFILLMENT && selectedRecordTypeName !== CASE_FULFILLMENT) || 
        (existingRecordTypeName !== CASE_FULFILLMENT && selectedRecordTypeName === CASE_FULFILLMENT)){
        oCase.Component__c = '';
        oCase.Subcomponent__c = '';
     }
     //</T03>

     if(this.selectedVersion && this.selectedVersion !== ''){
       oCase.Version__c = this.selectedVersion;
     }
     if(this.selectedProblemArea && this.selectedProblemArea !== ''){
       oCase.Problem_Area__c = this.selectedProblemArea;
     }
 
     let sRequiredFieldsMissing = '';
     var slot = [];
 
     if(this.changedCaseOwnerId == null || this.changedCaseOwnerId == undefined || this.changedCaseOwnerId == ''){
       sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Case Owner';
     }
 
     if(selectedRecordTypeName === CASE_TECHNICAL || selectedRecordTypeName === CASE_FULFILLMENT){
         if(this.selectedProduct == null || this.selectedProduct == undefined || this.selectedProduct == ''){
           sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Product';
         }
 
         if(this.selectedVersion == null || this.selectedVersion == undefined || this.selectedVersion == ''){
           sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Version';
         }
     }
     else if(selectedRecordTypeName === CASE_ADMINISTRATIVE){
         if(this.selectedProblemArea == null || this,this.selectedProblemArea == undefined || this.selectedProblemArea == ''){
           sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Problem Area';
         }
     }
     else if (selectedRecordTypeName === CASE_OPERATIONS) {
       
       if(this.enteredIssueSummary == null || this.enteredIssueSummary == ''){
         sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Issue Summary';
       }
 
       if(this.enteredDescription == null || this.enteredDescription == ''){
         sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Description';
       } 
 
       if(this.selectedEnvironment == null || this.selectedEnvironment == ''){
         sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Environment';
       } 
 
       if(this.selectedActivityType == null || this.selectedActivityType == ''){
         sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Activity Type';
       } 
 
       if(this.selectedPriority == null || this.selectedPriority == ''){
         sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Priority';
       } 
 
       if(this.showSessionDate){
         if(!this.selectedDate || !this.slotStartDT || !this.slotEndDT){
           sRequiredFieldsMissing += (sRequiredFieldsMissing == '' ? '' : ', ') + 'Session Date/TimeSlot';
         }
       }
 
       if(sRequiredFieldsMissing == ''){
         oCase.Issue_Summary__c = this.enteredIssueSummary;
         oCase.Description = this.enteredDescription;
         oCase.Environment__c = this.selectedEnvironment;
         oCase.Activity_Type__c = this.selectedActivityType;
         oCase.Priority = this.selectedPriority;
         slot = [];
         if(SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType)){
           slot.push(this.slotStartDT);
           slot.push(this.slotEndDT);
         }
       }
       
     } 
 
     if (sRequiredFieldsMissing != '') {
       this.disableBTNs = false;
       this.showSpinner = false;
       this.showToast(
         "Error!",
         "Required field(s) missing:" + sRequiredFieldsMissing,
         "error"
       );
     }
     else {
       log("@Log=>oCase:" + JSON.stringify(oCase));
       log('product: '+JSON.stringify(product));
       
       doCaseRecordTypeChange({
           oCase: oCase,
           existingRecordTypeName: existingRecordTypeName,
           newRecordTypeName: selectedRecordTypeName,
           slotSelected: slot,
           product: product
         })
         .then((resp) => {
           log("@Log=>resps:" + JSON.stringify(resp));
         
             this.showToast(
             "Success!",
             "Record Type is changed successfully.",
             "success"
           ); 
           this.closeAction();
         
         })
         .catch((err) => {
           this.disableBTNs = false;
           this.showSpinner = false;
           log("err>>", JSON.parse(JSON.stringify(err)));
           this.showToast("Error!", err.body.message, "error");
         });
     }
   }
 
 
   /* Reset properties */
 
   clearValues(){
     this.changedCaseOwnerId = undefined;
     this.selectedProduct = undefined;
     this.selectedVersion = undefined;
     this.selectedProblemArea = undefined;
     this.productName = '';
   }
 
   clearDateSlotFieldValues() {
     this.selectedDate = undefined;
     this.selectedSlot = undefined;
     this.slotStartDT = undefined;
     this.slotEndDT = undefined;
     this.availableSlots = undefined;
   }
 
   /* Toast Message */
 
   showToast(sTitle, sMsg, sVariant) {
     const event = new ShowToastEvent({
       title: sTitle,
       message: sMsg,
       variant: sVariant
     });
     this.dispatchEvent(event);
   }
 
   /* Getter methods */
 
   get isStep1() {
     return this.step == 1 ? true : false;
   }
 
   get isStep2() {
     return this.step == 2 ? true : false;
   }
 
   get isTechnical() {
     let recordTypeName = this.mapCaseRecordTypeIdWiseName.get(
       this.selectedRecordType
     );
     return recordTypeName == CASE_TECHNICAL ? true : false;
   }
 
   get isAdministrative() {
     let recordTypeName = this.mapCaseRecordTypeIdWiseName.get(
       this.selectedRecordType
     );
     return recordTypeName == CASE_ADMINISTRATIVE ? true : false;
   }
 
   get isOperations() {
     let recordTypeName = this.mapCaseRecordTypeIdWiseName.get(
       this.selectedRecordType
     );
     return recordTypeName == CASE_OPERATIONS ? true : false;
   }
 
   get isFulfillment() {
     let recordTypeName = this.mapCaseRecordTypeIdWiseName.get(
       this.selectedRecordType
     );
     return recordTypeName == CASE_FULFILLMENT ? true : false;
   }
 
   get versionOptions(){
     return this.lstVersions;
   }
 
   /* Close Action */
 
   closeAction(){
     getRecordNotifyChange([{recordId: this.recordId}]);
     this.dispatchEvent(new CloseActionScreenEvent());
   }
 }