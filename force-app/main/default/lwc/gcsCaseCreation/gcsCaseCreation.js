/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         12/03/2021  I2RT-4812   T02     to make Org Id field mandatory only for Hosted Multi Tenant products
balajip         12/03/2021  I2RT-5057   T03     to hide Version field for Administrative Case
Vignesh D       12/23/2021  I2RT-5183   T04     Pass Support Account Id as parameter.
Vignesh D       07/22/2022  I2RT-6593   T05     Show Business Impact and Estimated date for Milestone
                                                for P1 Technical/Operations cases
Vignesh D       09/05/2022  I2RT-6986   T06     Added logic to show Estimated Milestone date 
                                                based on the checkbox selected by user
Vignesh D       09/13/2022  I2RT-6865   T07     Added condition to ignore showing Case Lite record type
Vignesh D       09/30/2022  I2RT-7185   T08     Fixed incorrect field value condition on Is_AssignmentRules__c
balajip         10/31/2022  I2RT-7405   T09     fixed the bug while getting the list of Orgs.
balajip         10/31/2022  I2RT-7465   T10     to include Version__c field for Fulfillment Cases
*/

import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_ACCOUNTID from '@salesforce/schema/Case.AccountId';
import CASE_PRIORITY from '@salesforce/schema/Case.Priority';
import CASE_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';
import CASE_FORECAST_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c';
import CASE_COMPONENT from '@salesforce/schema/Case.Component__c';
import CASE_VERSION from '@salesforce/schema/Case.Version__c';
import CASE_ORG from '@salesforce/schema/Case.Org__c';
import CASE_ENVIRONMENT from '@salesforce/schema/Case.Environment__c';
import CASE_ACTIVITY_TYPE from '@salesforce/schema/Case.Activity_Type__c';
import CASE_INTERNALOREXTERNAL from '@salesforce/schema/Case.Is_Internal_Or_External_Case__c';
import CASE_ENTITLEMENT from '@salesforce/schema/Case.EntitlementId';
import CASE_ORIGIN from '@salesforce/schema/Case.Origin';
import CASE_SUPPORT_ADD_ON from '@salesforce/schema/Case.Case_Support_Add_On__c';
import CASE_SUCCESS_OFFERING from '@salesforce/schema/Case.Success_Offering__c';
import CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CASE_ORG_ID from '@salesforce/schema/Case.Org_ID__c';
import CASE_PROBLEM_AREA from '@salesforce/schema/Case.Problem_Area__c';
import CASE_SECUREAGENT from '@salesforce/schema/Case.Secure_Agent__c';
import CASE_NEXT_ACTION from '@salesforce/schema/Case.Next_Action__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_BUSINESS_IMPACT from '@salesforce/schema/Case.Business_Impact__c'; //<T05>
import CASE_ESTIMATED_DATE_FOR_MILESTONE from '@salesforce/schema/Case.Estimated_Date_for_Milestone__c'; //<T05>

import CASE_CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import CASE_DELIVERY_METHOD from '@salesforce/schema/Case.Delivery_Method__c';
import CASE_RECORDTYPEID from '@salesforce/schema/Case.RecordTypeId';
import CASE_RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.DeveloperName';

import ACC_ENTITLEMENT from '@salesforce/schema/Account.Entitlement__c';
import ACC_SUPPORT_ADD_ON from '@salesforce/schema/Account.Support_Add_On__c';
import ACC_SUCCESS_OFFERING from '@salesforce/schema/Account.Success_Offering__c';
import ACC_PARENTID from '@salesforce/schema/Account.ParentId';
import ACC_NAME from '@salesforce/schema/Account.Name';

import getAllProducts from '@salesforce/apex/CaseController.getAllProducts';
import getCaseFieldsDropdownOptions from '@salesforce/apex/CaseController.getCaseFieldsDropdownOptions';
import getVersionforSelectedProduct from '@salesforce/apex/CaseController.getVersionforSelectedProduct';
import getComponentForSelectedProduct from '@salesforce/apex/CaseController.getComponentForSelectedProduct';
import createCaseComment from '@salesforce/apex/CaseController.createCaseComment';



import getOrgIds from '@salesforce/apex/CaseController.getOrgIds';
import getAccountRelatedContacts from '@salesforce/apex/CaseController.getAccountRelatedContacts';
import getAvailableSlots from '@salesforce/apex/OperationsSchedulerController.getAvailableSlots';
import createCaseGCS from '@salesforce/apex/CaseController.createCaseGCS';
import TIME_ZONE from '@salesforce/i18n/timeZone';  

const CASE_FIELDS = [CASE_SUPPORT_ACCOUNT, CASE_RECORDTYPEID, CASE_RECORDTYPE_NAME, CASE_FORECAST_PRODUCT, 
                      CASE_DELIVERY_METHOD, CASE_INTERNALOREXTERNAL, CASE_CASE_NUMBER,
                      CASE_VERSION, CASE_COMPONENT, CASE_ORG, CASE_ENVIRONMENT, CASE_ACTIVITY_TYPE,
                      CASE_ORIGIN, CASE_ORG_ID, CASE_PRIORITY, CASE_SECUREAGENT, CASE_PROBLEM_AREA, CASE_CONTACTID,
                      CASE_BUSINESS_IMPACT, CASE_ESTIMATED_DATE_FOR_MILESTONE]; //<T05>

const ACCOUNT_FIELDS = [ACC_ENTITLEMENT,ACC_SUPPORT_ADD_ON,ACC_SUCCESS_OFFERING,ACC_NAME,ACC_PARENTID];

const ON_PREMISE = '(On Premise)';
const HOSTED_SINGLE_TENANT = '(Hosted Single Tenant)';
const HOSTED_MULTI_TENANT = '(Hosted Multi Tenant)';
const PERPETUAL = '(Perpetual)';

const SCHEDULED_ACTIVITY_TYPE = ['Request an activity/change request'];

export default class GcsCaseCreation extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;

    supportAccountId;
    supportAccount = {};

    sourceCaseId;
    sourceCase = {};
    contactPlaceHolder = 'Choose Contact';
    
    @track pageTitle;

    //@track caseTypeValue = '--Select--';
    @track productValue = '--Select--';
    @track versionValue='';
    @track productdropdownValues=[];
    @track versiondropdownValues=[];
    @track componentDropdownOptions=[];
    @track orgIdDropDownValues = [];
    @track productSelected;
    @track forecastProduct;
    @track showVersionPicklist;
    @track showProductPicklist;
    @track showNextButton;
    @track selectedCaseType;
    @track versionSelected;
    @track showRecordForm=false;
    @track showCaseSource = false;
    @track caseObjectinfo=[];
    @track selectedComponent;
    @track selectedOrgId;
    @track environments = [];
    @track problemAreas = [];
    @track selectedProblemArea;
    @track selectedEnvironment;
    
// Ops case type related variables
    @track isOperationsCase=false;
    @track isMultiTenantCase = false;
    @track caseRecoTypeId;
    @track showOperationTypeFields = false;
    @track showMultiTenantFields = false;
    @track lstActivityTypes=[];
    @track selectedActivityType;
    @track fieldsForShippingAdministrative = false;
    @track showSupportAccount = true;
    @track isRequired =true;
    @track data;
    @track entitledProducts = [];
    @track caseObj = CASE_OBJECT;
    @track runOnce = true;
    @track showOrgIdDropDown = true;
    @track showOrgIdInputBox = false;
    @track showVersionComponent = false;
    @track isNotAdminCase = true;
    //@track noError = false;
    @track error = false;
    @track showSpinner = false;
    @track showContactError = false;
    @track accountName;
    @track relatedContacts = [];
    @track selectedContact;
    @track contactClass = '';
    @track orgIdManual = '';
    @track caseSecureAgent = '';
    @track showUntitledMessage = false;
    @track showProblemArea = false;
    @track OrgIdCheckbox = false;
    //@track selectedCaseType;
    @track creditnoteId;
    @track calloperationsflow = false;
    @track hideModalHeadingLabel=true;
    @track priorities = [];
    @track selectedPriority;
    @track isEnvironmentRequired;
    @track recordTypeName;
    @track internalexternal = 'External';

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

    requiredFieldErrMsg = 'This field is required.';
    showBusinessImpactField = true; //<T05>
    selectedBusinessImpact; //<T05>
    selectedEstimateDate; //<T05>
    impactCheckbox = false; //<T06>
    doesImpactMilestone = false; //<T06>
    

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT}) 
    objectInfo;

    /*@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_INTERNALOREXTERNAL})
    caseType;*/

    @wire(getPicklistValues, {recordTypeId: '$caseRecoTypeId',fieldApiName: CASE_PRIORITY})
    priorityValues({data, error}) {
      if(data) {
        //console.log('Priorities: '+JSON.stringify(data));
        this.priorities = [];
        data.values.forEach(element => {
          this.priorities.push({label: element.value , value: element.value});
        });
      } else {
        console.log('ERROR Getting Priority: '+JSON.stringify(error));
      }
    };

    /*@wire(getCaseFieldsDropdownOptions, {})
    dropdownOption({ data, error }) {
        if (data) {
            //console.log('Priorities: '+JSON.stringify(data));
            let priorityOptions = [];
            for (var i in data.priorities) {
                priorityOptions.push({ label: data.priorities[i].value, value: data.priorities[i].value });
            }
            this.priorities = priorityOptions;
        } else {
            console.log('ERROR Getting Priority: '+JSON.stringify(error));
        }
    }*/
    
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_ENVIRONMENT})
    environments({data, error}){
      if(data){
        var environmentOptions = [];
        data.values.forEach(element => {
          environmentOptions.push({label: element.value , value : element.value});
        });
        this.environments = environmentOptions;
      } else if(error){
        console.log('Error while fetching Environments');
      }
    };

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_PROBLEM_AREA})
    problemAreas({data, error}){
      if(data){
        var problemAreaOptions = [];
        data.values.forEach(element => {
          problemAreaOptions.push({label: element.value , value : element.value});
        });
        this.problemAreas = problemAreaOptions;
      } else if(error){
        console.log('Error while fetching Problem Area - ' + JSON.stringify(error));
      }
    };
    
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_ACTIVITY_TYPE})
    activityTypes({data, error}) {
      if(data) {
        this.lstActivityTypes = [];
        data.values.forEach(element => {
          this.lstActivityTypes.push({label: element.value , value: element.value});
        });
      } else {
        console.log("Error while fetching Activity Type - " + JSON.stringify(error));
      }
    };

    // <T01>
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_INTERNALOREXTERNAL})
    caseTypeOptions;
    // </T01>

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CASE_BUSINESS_IMPACT}) //<T05>
    lstBusinessImpacts;

    @wire(getRecord, { recordId: '$supportAccountId', fields: ACCOUNT_FIELDS })
    account({ error, data }) {
      if (error) {
          console.log("error fetching account details - " + JSON.stringify(error));
      } else if (data) {
          //console.log("data.fields - " + JSON.stringify(data.fields));

          this.accountName = getFieldValue(data, ACC_NAME);
          console.log("accountName - " + this.accountName);

          this.supportAccount.AccountName = this.accountName;
          this.supportAccount.ParentId = getFieldValue(data, ACC_PARENTID);
          this.supportAccount.EntitlementId = getFieldValue(data, ACC_ENTITLEMENT);        
          this.supportAccount.SupportAddOn = getFieldValue(data, ACC_SUPPORT_ADD_ON);
          this.supportAccount.SuccessOffering = getFieldValue(data, ACC_SUCCESS_OFFERING);
  
      }
    }           
   
    @wire(getRecord, { recordId: '$sourceCaseId', fields: CASE_FIELDS })
    sourceCase({ error, data }) {
      if (error) {
          console.log("error fetching case details - " + JSON.stringify(error));
      } else if (data) {
          //console.log("data.fields - " + JSON.stringify(data.fields));

          this.sourceCase.RecordTypeId = getFieldValue(data, CASE_RECORDTYPEID);
          this.sourceCase.RecordTypeName = getFieldValue(data, CASE_RECORDTYPE_NAME);;
          this.sourceCase.CaseNumber = getFieldValue(data, CASE_CASE_NUMBER);
          this.sourceCase.SupportAccountId = getFieldValue(data, CASE_SUPPORT_ACCOUNT);
          this.sourceCase.Priority = getFieldValue(data, CASE_PRIORITY);
          this.sourceCase.ForecastProduct = getFieldValue(data, CASE_FORECAST_PRODUCT);
          this.sourceCase.DeliveryMethod = getFieldValue(data, CASE_DELIVERY_METHOD);
          this.sourceCase.Version = getFieldValue(data, CASE_VERSION);
          this.sourceCase.Org = getFieldValue(data, CASE_ORG);
          this.sourceCase.OrgId = getFieldValue(data, CASE_ORG_ID);
          this.sourceCase.SecureAgent = getFieldValue(data, CASE_SECUREAGENT);
          this.sourceCase.Environment = getFieldValue(data, CASE_ENVIRONMENT);
          this.sourceCase.ActivityType = getFieldValue(data, CASE_ACTIVITY_TYPE);
          this.sourceCase.ProblemArea = getFieldValue(data, CASE_PROBLEM_AREA);
          this.sourceCase.ContactId = getFieldValue(data, CASE_CONTACTID);
          this.sourceCase.InternalExternal = getFieldValue(data, CASE_INTERNALOREXTERNAL);
          this.sourceCase.BusinessImpact = getFieldValue(data, CASE_BUSINESS_IMPACT); //<T05>

          console.log("sourceCase - " + JSON.stringify(this.sourceCase));
          
          this.supportAccountId = this.sourceCase.SupportAccountId;
          
          this.getRelatedContacts();
          this.selectedContact = this.sourceCase.ContactId;
          console.log("selectedContact - " + this.selectedContact);

          this.caseRecoTypeId = this.sourceCase.RecordTypeId;
          this.selectedCaseType = this.sourceCase.RecordTypeName;
          this.recordTypeName = this.selectedCaseType;
          this.recordTypeChange();
      }
    }
    
    //T02
    get isOrgIdRequired(){
      return this.productSelected.includes(HOSTED_MULTI_TENANT);
    }
   
    connectedCallback(){
      console.log('@ConnectedCallback: Case Creation');
      console.log('recordId: '+this.recordId);
      
      if(String(this.recordId).startsWith('500')){
        console.log('cloning a case');
        this.sourceCaseId = this.recordId;
        this.pageTitle = 'Clone Case'
      }else{
        console.log('creating a new case');
        this.supportAccountId = this.recordId;
        this.pageTitle = 'New Case';
        this.getRelatedContacts();
      }
    }

    getRelatedContacts(){
      getAccountRelatedContacts({recordId: this.supportAccountId})
        .then(result => {
          //console.log('@@ContactData= '+JSON.stringify(result));
            /*for(var i in result){
              console.log(result[i]);
              this.relatedContacts.push({label: result[i].Contact.Name , value : result[i].Contact.Id});
            }*/
            result.forEach(element => {
              this.relatedContacts.push({label: element.Contact.Name , value: element.Contact.Id});
            })
            //this.noError = true;
            this.error = false;
            console.log('contactOptions length = '+this.relatedContacts.length);

            if(this.relatedContacts.length > 0){
                this.contactPlaceHolder = 'Choose Contact';
            }
            else{
                this.contactPlaceHolder = 'No assigned contact(s) available to select';
            }
            
        })
        .catch(error => {
          console.log('GetContact Error= '+this.supportAccountId);
          if(this.supportAccountId != undefined){
            //this.noError = false;
            this.error = true;
          }
        });
    }
  
    get caseRecordTypes() {
        if(this.caseObjectinfo.length === 0){
          this.caseObjectinfo = this.objectInfo.data.recordTypeInfos;
        }
        var recordtypeinfo = this.caseObjectinfo;
        var uiCombobox = [];
        console.log("recordtype" + recordtypeinfo);
        for(var eachRecordtype in  recordtypeinfo)//this is to match structure of lightning combo box
        {
          if(recordtypeinfo.hasOwnProperty(eachRecordtype))
          {
              if(recordtypeinfo[eachRecordtype].name!='Master' && recordtypeinfo[eachRecordtype].name != 'Operations' && recordtypeinfo[eachRecordtype].name != 'Ask An Expert' && recordtypeinfo[eachRecordtype].name != 'Case Lite') //<T07>
              {
                uiCombobox.push({ label: recordtypeinfo[eachRecordtype].name, value: recordtypeinfo[eachRecordtype].name })
              }
              
          }
        }
        console.log('uiCombobox' + JSON.stringify(uiCombobox));
        this.caseTypes = uiCombobox;
      return uiCombobox;
    }

    handleRecordTypeChange(event) {
      console.log('Record type is changed');
      var caseType = event.detail.value;
      console.log('caseType-->'+caseType);
      this.selectedCaseType=caseType;
      this.recordTypeName = event.detail.value;
      console.log('caseType- '+this.selectedCaseType);
      const rtis = this.caseObjectinfo;
      this.caseRecoTypeId= Object.keys(rtis).find(rti => rtis[rti].name === this.selectedCaseType);

      this.recordTypeChange();
    }

    recordTypeChange(){
        this.resetAllFieldValues();//Vignesh D: clear values on RecordType change
        this.showProblemArea = false;
        console.log('@@caeRec- '+this.caseRecoTypeId);
        console.log('product= '+this.productdropdownValues.length);
        console.log('selectedCaseType- '+this.selectedCaseType);

        if(this.selectedCaseType != 'Administrative'){
          getAllProducts({ accountId: this.supportAccountId })
          .then(result => {
            console.log('result -->'+JSON.stringify(result));
            var isEntitledProduct = result[0] === '----Entitled Products----' ? true : false;
            if(this.runOnce){
              this.runOnce = false;
              for(var pro in result) {
                if (result.hasOwnProperty(pro)) { 
                  this.productdropdownValues.push({label:result[pro], value:result[pro]});
                    if(isEntitledProduct){
                      isEntitledProduct = result[pro] === '----Unentitled Products----' ? false : true;
                      if(isEntitledProduct){
                        this.entitledProducts.push(result[pro]);
                      }
                    }
                }
              }
            }
            //I2RT-4571
            if(this.entitledProducts.indexOf(this.productSelected) !== -1){
              this.isRequired =true;
              this.showUntitledMessage = false;
            } 
            else{
              this.isRequired =false;
              this.showUntitledMessage = true;
            }
    
            this.showProductPicklist=true;
          })
          .catch(error => {
            console.log('Error -->'+JSON.stringify(error));
          });
        }
        
        if(!this.runOnce && this.selectedCaseType != 'Administrative')
        this.showProductPicklist=true;
        this.showOperationTypeFields = false;
        this.showMultiTenantFields = false;
        if(this.selectedCaseType == 'Administrative'){
            this.showVersionPicklist =false;
            this.showProductPicklist =false;
            this.showNextButton =true; 
            this.isNotAdminCase =false;
            this.showProblemArea = true;
        } else {
          this.isNotAdminCase = true;
        }
        if(this.productSelected != null && this.productSelected != undefined  && this.selectedCaseType != 'Administrative'){
          if(this.selectedCaseType == 'Fulfillment'){
            this.showVersionPicklist =false;
            this.showNextButton =true;              
          } else {
            this.showVersionPicklist =true;
            if(this.versionSelected != null && this.versionSelected != undefined){
              this.showNextButton =true;
            }
          }
        }
              
        if(this.sourceCaseId){
          this.selectedPriority = this.sourceCase.Priority;          
          this.selectedProblemArea = this.sourceCase.ProblemArea;
          if(this.selectedCaseType === 'Technical' && this.selectedPriority === 'P1'){ //<T05>
            this.selectedBusinessImpact = this.sourceCase.BusinessImpact;
          }
          else{
            this.selectedBusinessImpact = undefined;
            this.selectedEstimateDate = undefined;
          }
          if(this.sourceCase.InternalExternal && this.sourceCase.InternalExternal.length != 0){
            this.internalexternal = this.sourceCase.InternalExternal;
          }
          console.log("internalexternal - " + this.internalexternal);

          //T03
          if(this.sourceCase.ForecastProduct && this.sourceCase.ForecastProduct != null){
            this.forecastProduct = this.sourceCase.ForecastProduct;
            this.productSelected = this.forecastProduct + '(' + this.sourceCase.DeliveryMethod + ')';
            console.log("productSelected - " + this.productSelected);
            this.productChange();
          }
        }
    }
   

    handleProductChange(event){
      console.log('@handleProductChange');
      console.log('Product Selected: '+event.detail.value);

      this.productSelected = event.detail.value;
      this.productChange();
    }
    
    productChange(){ 
      this.resetFieldValues(); //Vignesh D: clear values on product change
      this.resetFields();
      this.showVersionPicklist = true;
      //T03
      if(this.selectedCaseType == 'Administrative'){
        this.showVersionPicklist = false;
      }

      if(this.productSelected === '----Unentitled Products----' || this.productSelected === '----Entitled Products----'){
        this.showNextButton = false;
        this.showUntitledMessage = false;
        //Deva hiding version field when actual product not selected
        //And eventually hide the next and cancel buttons so cannot create case with product
        this.showVersionPicklist = false;
      }
      else if(this.productSelected !== undefined && this.productSelected !== null && this.productSelected !== '' && this.productSelected !== '----Unentitled Products----' && this.productSelected !== '----Entitled Products----'){
        
        if(!this.productSelected.includes(ON_PREMISE) && !this.productSelected.includes(HOSTED_SINGLE_TENANT) && !this.productSelected.includes(HOSTED_MULTI_TENANT) && !this.productSelected.includes(PERPETUAL)){
            this.forecastProduct=this.productSelected;
        }
        else if(this.productSelected.includes(ON_PREMISE)){
          this.forecastProduct=this.productSelected.substring(0, this.productSelected.indexOf(ON_PREMISE));
        }
        else if(this.productSelected.includes(HOSTED_SINGLE_TENANT)){
          this.forecastProduct=this.productSelected.substring(0, this.productSelected.indexOf(HOSTED_SINGLE_TENANT));
        }
        else if(this.productSelected.includes(HOSTED_MULTI_TENANT)){
          this.forecastProduct=this.productSelected.substring(0, this.productSelected.indexOf(HOSTED_MULTI_TENANT));
        }
        else if(this.productSelected.includes(PERPETUAL)){
          this.forecastProduct=this.productSelected.substring(0, this.productSelected.indexOf(PERPETUAL));
        }
        
        console.log('this.entitledProducts='+JSON.stringify(this.entitledProducts));
              
        if(this.entitledProducts.indexOf(this.productSelected) !== -1){
          this.isRequired =true;
          this.showUntitledMessage = false;
        } 
        else{
          this.isRequired =false;
          this.showUntitledMessage = true;
        }
        
        console.log('IsRequired- '+this.isRequired)
              
        if((this.productSelected.includes(HOSTED_SINGLE_TENANT) && this.selectedCaseType == 'Technical')){
                
            console.log('inside hosted product');

            this.isOperationsCase=true;
            this.isEnvironmentRequired = true;
            const rtis = this.caseObjectinfo;

            if(this.versionSelected != null && this.versionSelected != undefined){
              this.showNextButton = false;
              this.showOperationTypeFields = true;
            }
            this.showMultiTenantFields = false;
            this.isMultiTenantCase = false;
            //this.caseRecoTypeId= Object.keys(rtis).find(rti => rtis[rti].name === 'Operations');
            this.recordTypeName = 'Operations';

            this.getOrgs();
        }
        else if(this.productSelected.includes(HOSTED_MULTI_TENANT) && this.selectedCaseType == 'Technical'){

          console.log('Inside Multi tenant');

          if(this.versionSelected != null && this.versionSelected != undefined){
            this.showNextButton = true;
            //this.showOperationTypeFields = false;
          }
          this.showOperationTypeFields = false;
          this.isOperationsCase=false;
          this.isEnvironmentRequired = false;
          this.showMultiTenantFields = true;
          this.isMultiTenantCase = true;
          const rtis = this.caseObjectinfo;
          //this.caseRecoTypeId= Object.keys(rtis).find(rti => rtis[rti].name === this.selectedCaseType);
          this.recordTypeName = this.selectedCaseType;
          this.getOrgs();

        } 
        else{
                if(this.versionSelected != null && this.versionSelected != undefined){
                  this.showNextButton = true;
                  this.showOperationTypeFields = false;
                }
                console.log('inside unhosted product');

                this.isOperationsCase=false;
                this.showOperationTypeFields = false;
                this.showMultiTenantFields = false;
                this.isMultiTenantCase = false;
                const rtis = this.caseObjectinfo;
                //this.caseRecoTypeId= Object.keys(rtis).find(rti => rtis[rti].name === this.selectedCaseType);
                this.recordTypeName = this.selectedCaseType;
        }
      }
      if(this.sourceCaseId){
        this.versionSelected = this.sourceCase.Version
        console.log("versionSelected - " + this.versionSelected);

        this.selectedOrgId = this.sourceCase.Org;
        this.orgIdManual = this.sourceCase.OrgId;
        this.caseSecureAgent = this.sourceCase.SecureAgent;
        this.selectedEnvironment = this.sourceCase.Environment;
        this.selectedActivityType = this.sourceCase.ActivityType;

        this.versionChange();
      }
      this.showAppointmentDateChecker();
    }

    getOrgs(){
      getOrgIds({productName: this.productSelected, SuppoAccId: this.supportAccountId}) //<T04> <T09>
        .then(result => { 
          console.log('orgIds- '+JSON.stringify(result));
          
          var orgIds = result;
          this.orgIdDropDownValues=[];
          
          for(var i in orgIds) {
            console.log('dataComponent->'+JSON.stringify(orgIds[i]));
            if (orgIds[i].label != null && orgIds[i].label != undefined) {
              this.orgIdDropDownValues.push({label:orgIds[i].label, value:orgIds[i].value});
            }
          }  
          console.log('this.versiondropdownValues-->'+JSON.stringify(this.orgIdDropDownValues));
        })
        .catch(error => {
          console.log('Error: '+JSON.stringify(error));
        });
    }

    @wire(getVersionforSelectedProduct, { selectedProduct: '$forecastProduct'})
    wiredVersions({ error, data }) {
        if (data) {
          this.versiondropdownValues=[];
          console.log('data->'+JSON.stringify(data));
          for(var version in data) {
            
            if (data.hasOwnProperty(version)) {
              this.versiondropdownValues.push({label:data[version], value:data[version]});
            }
          }
            console.log('this.versiondropdownValues-->'+JSON.stringify(this.versiondropdownValues));
        if(this.showRecordForm==false && this.selectedCaseType != 'Fulfillment' && this.selectedCaseType != 'Administrative')
        {
          this.showVersionPicklist=true;
        } else {
          this.showNextButton = true;
        }
            
        // getting the dependent Component
        getComponentForSelectedProduct({ selectedProduct: this.forecastProduct})
        .then(result => {
          console.log('result -->'+JSON.stringify(result));
              if (result) {
              this.componentDropdownOptions=[];
              console.log('dataComponent->'+JSON.stringify(result));
                for(var version in result) {
                  if (result.hasOwnProperty(version)) {
                    this.componentDropdownOptions.push({label:result[version], value:result[version]});
                  }
                }  
              console.log('this.versiondropdownValues-->'+JSON.stringify(this.componentDropdownOptions));
            } else if (error) {
              console.log('Error -->'+JSON.stringify(error));
            }
          });
        } else if (error) {
          console.log('Error -->'+JSON.stringify(error));
        }
    }
    
    handleVersionChange(event){
      console.log('entry handleVersionChange');
    
      this.versionSelected=event.detail.value;

      this.versionChange();
    }
    
    versionChange(){

      console.log('isMultiTenantCase-->'+this.isMultiTenantCase);
      if(this.showRecordForm==false && !this.isOperationsCase && !this.isMultiTenantCase)
      {
        this.showOperationTypeFields = false;
        this.showMultiTenantFields = false;
        this.showNextButton=true;
      }
      else if(this.showRecordForm==false && !this.isOperationsCase && this.isMultiTenantCase){
        this.showOperationTypeFields = false;
        this.showMultiTenantFields = true;
        this.showNextButton=true;
      }
      else {
        this.showOperationTypeFields = true;
      }
      console.log('version-->'+this.versionSelected);
    }

    handleOrgIdCheckboxChange(event){
      var isShowInput = event.detail.checked;
      this.OrgIdCheckbox = event.detail.checked;
      console.log('visShowInput= '+isShowInput);
      if(isShowInput){
        this.showOrgIdDropDown = false;
        this.showOrgIdInputBox = true;
      } else{
        this.showOrgIdDropDown = true;
        this.showOrgIdInputBox = false;
      }
    }

    handlePriorityChange(event){
      this.selectedPriority = event.detail.value;
      this.selectedBusinessImpact = undefined; //<T05>
      this.selectedEstimateDate = undefined; //<T05>
      this.doesImpactMilestone = false; //<T06>
      this.impactCheckbox = false; //<T06>
      this.showAppointmentDateChecker();
    }
    
    handleContactChange(event){
      this.selectedContact = event.detail.value;
      this.contactChange();
    }
    
    contactChange(){
      this.contactClass = '';
      this.showContactError = false;
    }

    showNextScreen()
    {
        console.log('navigation method entry--'+this.isOperationsCase);

        //Vignesh D: Added validation to get required fields
        var isRequiredFieldsFilled = [...this.template.querySelectorAll('lightning-combobox,lightning-input')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true); //<T05>
        
        if(isRequiredFieldsFilled){
          if(this.isOperationsCase==true) {
            console.log('Operations case entry');
            this.showOperationTypeFields=false;
            this.showRecordForm=true;
            this.objectInfo.data=false;
            this.showProductPicklist=false;
            this.showVersionPicklist=false;
            this.showNextButton=false;
            this.showSupportAccount = false;
            this.showVersionComponent = true;
          } 
          else{
            console.log('technical case entry');
            this.showRecordForm=true;
            this.objectInfo.data=false;
            this.showProductPicklist=false;
            this.showVersionPicklist=false;
            this.showNextButton=false;
    
            this.showSupportAccount = false;
            this.showProblemArea = false;
            if(this.isMultiTenantCase){
              this.showMultiTenantFields = false;
            }
            if(this.selectedCaseType == 'Administrative'){ //T10
              this.showVersionComponent = false;
            } else {
              this.showVersionComponent = true;
            }
          }
          if(this.selectedContact && this.selectedContact != ''){
            this.contactChange();
          }
          this.showBusinessImpactField = false; //<T05>
        }
    }

    goPreviousSection(){
      this.objectInfo.data=true;
      this.showProductPicklist=true;
      this.showVersionPicklist=true;
      this.showNextButton=true;
      this.showSupportAccount = true;
      this.showRecordForm=false;
      this.showProblemArea = false;
      this.showBusinessImpactField = true; //<T05>
      if(this.isOperationsCase){
        this.showOperationTypeFields = true;
      } 
      else if(this.isMultiTenantCase){
        this.showMultiTenantFields = true;
      }
      else if(this.selectedCaseType == 'Fulfillment'){
        this.showVersionPicklist=false;
      }
      else if(this.selectedCaseType == 'Administrative'){
          this.showVersionPicklist =false;
          this.showProductPicklist =false;
          this.isNotAdminCase =false;  
          this.showProblemArea = true;    
      }
    }

    handleComponentChange(event){
      console.log('coponentChange-'+event.detail.value)
      this.selectedComponent = event.detail.value;
    }

    handleOrgIdChange(event){
      console.log('OrgIds= '+JSON.stringify(event.detail.value));
      this.selectedOrgId = event.detail.value;
    }

    handleManualOrgIdChange(event){
      this.orgIdManual = event.detail.value;
    }

    handleSecureAgent(event){
      this.caseSecureAgent = event.detail.value
    }

    handleProblemAreaChange(event){
      this.selectedProblemArea = event.detail.value;
    }
    
    handleEnvironmentChange(event){
      this.selectedEnvironment = event.detail.value;
      this.showAppointmentDateChecker();
    }

    handleBusinessImpactChange(event){ //<T05>
      this.selectedBusinessImpact = event.detail.value;
    }

    handleMilestoneDateChange(event){ //<T05>
      this.selectedEstimateDate = event.detail.value;
      let currentDate = new Date(new Date().toDateString());
      let selectedDate = new Date(new Date(this.selectedEstimateDate).toDateString());
      if(selectedDate < currentDate){
          event.target.setCustomValidity('Please select a date greater than or equal to today\'s date.');
          event.target.reportValidity();
      }
      else{
          event.target.setCustomValidity("");
          event.target.reportValidity();
      }
    }

    handleTick(event){ //<T06>
      this.doesImpactMilestone = event.target.checked;
        if(!this.doesImpactMilestone){
            this.selectedEstimateDate = undefined;
        }
    }

    get showBusinessImpactFields(){ //<T05>
      return this.selectedPriority === 'P1' && this.selectedCaseType === 'Technical' && this.showBusinessImpactField ? true : false;
    }

    handleSubmit(event){
      event.preventDefault();       // stop the form from submitting
      
      //Vignesh D: Added validation to get required fields
      var isValidValue = [...this.template.querySelectorAll('lightning-combobox')]
      .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
      }, true);

      if(isValidValue){
        var isError = false;
        console.log('this.selectedContact= '+this.selectedContact);
        //event.preventDefault();       // stop the form from submitting
        //const fields = event.detail.fields;
        var slot = [];
        var caseObj = {};
        caseObj.Priority = this.selectedPriority;
        caseObj.Support_Account__c = this.supportAccountId;
        caseObj.Subject = event.detail.fields.Subject;
        caseObj.Description =event.detail.fields.Description;
        caseObj.Error_Message__c =event.detail.fields.Error_Message__c;
        caseObj.Is_AssignmentRules__c = event?.detail?.fields?.Is_AssignmentRules__c; //<T08>
        
        /*if(event.detail.fields.Is_AssignmentRules__c === 'true'){
          event.detail.fields.Is_AssignmentRules__c = true;
        }else{
          fields[CASE_STATUS.fieldApiName] = 'Assess';
        }*/

        if(!caseObj.Is_AssignmentRules__c){
          caseObj.Status = 'Assess';
        }

        if(this.isOperationsCase){
          //fields[CASE_ACTIVITY_TYPE.fieldApiName] = this.selectedActivityType;
          //fields[CASE_VERSION.fieldApiName]= this.versionSelected;
          //fields[CASE_ORG.fieldApiName] = this.selectedOrgId;
          //fields[CASE_SECUREAGENT.fieldApiName] = this.caseSecureAgent;
          //fields[CASE_COMPONENT.fieldApiName] = this.selectedComponent;
          //fields[CASE_ENVIRONMENT.fieldApiName] = this.selectedEnvironment;
          console.log('@@OrgId= '+this.orgIdManual);
          caseObj.Org__c = this.selectedOrgId;
          caseObj.Version__c = this.versionSelected;
          caseObj.Component__c = this.selectedComponent;
          caseObj.Secure_Agent__c = this.caseSecureAgent;
          caseObj.Environment__c = this.selectedEnvironment;
          caseObj.Activity_Type__c = this.selectedActivityType;
          caseObj.Org__c = this.selectedOrgId;
          
          if(this.orgIdManual !== ''){
            //fields[CASE_ORG_ID.fieldApiName] = this.orgIdManual;
            caseObj.Org_ID__c = this.orgIdManual;
          }
          if(SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType)){
              slot.push(this.slotStartDT);
              slot.push(this.slotEndDT); 
          }
        } else if(this.selectedCaseType == 'Technical'){
          //fields[CASE_VERSION.fieldApiName]= this.versionSelected;
          //fields[CASE_COMPONENT.fieldApiName] = this.selectedComponent;
          caseObj.Version__c = this.versionSelected;
          caseObj.Component__c = this.selectedComponent;
          if(this.isMultiTenantCase){
            //fields[CASE_ORG.fieldApiName] = this.selectedOrgId;
            //fields[CASE_SECUREAGENT.fieldApiName] = this.caseSecureAgent;
            caseObj.Org__c = this.selectedOrgId;
            caseObj.Secure_Agent__c = this.caseSecureAgent;
            if(this.orgIdManual !== ''){
              //fields[CASE_ORG_ID.fieldApiName] = this.orgIdManual;
              caseObj.Org_ID__c = this.orgIdManual;
            }
          }
        //T10 to set the Version__c value for Fulfillment cases
        } else if(this.selectedCaseType == 'Fulfillment'){
          caseObj.Version__c = this.versionSelected;
        } 

        //fields[CASE_FORECAST_PRODUCT.fieldApiName]=this.forecastProduct;
        //fields[CASE_SUPPORT_ACCOUNT.fieldApiName] = this.recordId;
        //fields[CASE_ACCOUNTID.fieldApiName] = getFieldValue(this.account.data, ACC_PARENTID);
        //fields[CASE_ENTITLEMENT.fieldApiName]=getFieldValue(this.account.data, ACC_ENTITLEMENT);
        //fields[CASE_SUPPORT_ADD_ON.fieldApiName]=getFieldValue(this.account.data, ACC_SUPPORT_ADD_ON);
        //fields[CASE_SUCCESS_OFFERING.fieldApiName]=getFieldValue(this.account.data, ACC_SUCCESS_OFFERING);
        //fields[CASE_CONTACTID.fieldApiName] = this.selectedContact;
        //fields[CASE_ORIGIN.fieldApiName] = 'SFDC';
        //fields[CASE_NEXT_ACTION.fieldApiName] = 'Case Owner';

        caseObj.Forecast_Product__c = this.forecastProduct;
        caseObj.Is_Internal_Or_External_Case__c = this.internalexternal;
        caseObj.AccountId = this.supportAccount.ParentId;
        caseObj.EntitlementId = this.supportAccount.EntitlementId;        
        caseObj.Case_Support_Add_On__c = this.supportAccount.SupportAddOn;
        caseObj.Success_Offering__c = this.supportAccount.SuccessOffering;
        caseObj.ContactId = this.selectedContact;
        caseObj.Origin = 'SFDC';
        caseObj.Next_Action__c = 'Case Owner';
        caseObj.Business_Impact__c = this.selectedBusinessImpact; //<T05>
        caseObj.Estimated_Date_for_Milestone__c = this.selectedEstimateDate; //<T05>

        if(this.selectedCaseType === 'Administrative' && this.selectedProblemArea !== undefined){
          //fields[CASE_PROBLEM_AREA.fieldApiName] = this.selectedProblemArea;
          caseObj.Problem_Area__c = this.selectedProblemArea;
        }

        if(this.sourceCaseId){
          caseObj.Cloned_From__c = this.sourceCaseId;
          caseObj.Cloned_From_Case_Number__c = this.sourceCase.CaseNumber;
        }
        console.log('caseOb >> ', JSON.stringify(caseObj));
    
        //console.log('event= '+JSON.stringify(fields));
        if(!isError){
          this.showSpinner = true;
          //this.template.querySelector('.recordEditForm').submit(fields);
          createCaseGCS({ caseJson: JSON.stringify(caseObj), recordTypeName: this.recordTypeName, productName: this.productSelected, environmentType: this.selectedEnvironment, slotSelected: slot })
            .then(result => {
                if(result){
                    let message = 'Case created Successfully!';
                    if(this.sourceCaseId){
                      message = 'Case cloned Successfully!';
                      console.log('caseobj:'+result);                                                                
                      createCaseComment({caseid: JSON.stringify(result)})
                      .then(result =>{
                        console.log('do nothing');
                      }).catch( error => {
                        console.log('unable to create clone comment');
                    });
                    }
                    this.showToastEvent('Success!', message,'success','dismissable');
                    //this.showSpinner = false;
                    this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                    });
                }
            })
            .catch( error => {
                this.showSpinner = false;
                this.showToastEvent('Error', error.body.message, 'error', 'dismissable');
            });
        }
      }
    }

    /*
    handleSuccess(event){
      //this.showSpinner = false;
      this.creditnoteId = event.detail.id;
      console.log('@@data= '+JSON.stringify(event.detail));
      //var caseNumber = event.detail.fields.CaseNumber == null ? event.detail.fields.Case_Number__c.value : event.detail.fields.CaseNumber.value;
      this.showToastEvent('Success!','Case created Successfully!','success','dismissable');
      console.log('gcsCaseCreation :: productSelected :: ' + this.productSelected);
      if(this.productSelected != null && this.productSelected != undefined){
        console.log('called');
        setDeliveryMethod({productName : this.productSelected, caseId : event.detail.id})
        .then(result => {
          console.log('result -->'+result);
        }).catch(error => {
          console.log('Error 11-->'+JSON.stringify(error));
        })
      }
      
      //console.log('@ContactId= '+event.detail.fields.Contact.value.id);
    
      initialResponseCaseComment({caseId : event.detail.id})
      .catch(error => {
        console.log('Error -->'+JSON.stringify(error));
      }); 
      //this.showSpinner = false;
      //redirect to record detail page
      console.log('event.detail.id-->');
      this.showSpinner = false;
          this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: this.creditnoteId,
              objectApiName: 'Case',
              actionName: 'view'
          }
        });
    }
    */

    /*
    handleError(event){
      console.log('Error: -->'+JSON.stringify(event.detail));
      this.showSpinner = false;
      let errormessage = `${event.detail.detail != undefined ? 'Error occurred while creating case. '+event.detail.detail : event.detail.message}`;
      this.showToastEvent('Error',errormessage,'error','dismissable');
    }
    */

    handleAssignment(event){
      var isAutoAssign = event.detail.checked;
      if(isAutoAssign){
        this.showCaseSource = false;
      } else {
        this.showCaseSource = true;
      }
      this.showCaseSource = false;
    }
    
    handleinternal(event){
      this.internalexternal = event.detail.value;
      console.log('internal external');
    }


    activityTypeOnChange(event)
    {
      console.log('activityTypeOnChange entry-->'+event.detail.value);
      this.selectedActivityType=event.detail.value;
      if(this.selectedActivityType!=null && this.selectedActivityType!=undefined && this.selectedActivityType!='')
      {
        this.showNextButton = true;
        /*if(this.selectedActivityType=='Apply EBF' ||this.selectedActivityType=='Restart the services' || this.selectedActivityType=='Change configuration' || this.selectedActivityType=='Migrations')
        {
          //this.calloperationsflow = true;
          this.recordTypeName = 'Operations';
            
        } else {
          if(this.selectedActivityType == 'Technical Issue'){
            const rtis = this.caseObjectinfo;
            //this.caseRecoTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Technical');
            this.recordTypeName = 'Technical';
          }
          else{
            this.recordTypeName = 'Operations';
          }      
        }*/
      }
      this.clearDateSlotFieldValues();
      this.showAppointmentDateChecker();    
    }

    handleCaseTypeChange(event){
      console.log('case type: '+event.detail.value);
      this.selectedCaseType = event.detail.value;
    }
    
    // Show a UI Message
    showToastEvent(title, message, variant, mode) {
      const event = new ShowToastEvent({
          title,
          message,
          variant,
          mode
      });
      this.dispatchEvent(event);
    }

    resetAllFieldValues(){
      this.productSelected = undefined;
      this.versionSelected = undefined;
      this.OrgIdCheckbox = false;
      this.selectedOrgId = undefined;
      this.orgIdManual = undefined;
      this.caseSecureAgent = '';
      this.selectedEnvironment = undefined;
      this.selectedActivityType = undefined;
      this.selectedProblemArea = undefined;
      this.selectedBusinessImpact = undefined; //<T05>
      this.selectedEstimateDate = undefined; //<T05>
      this.impactCheckbox = false; //<T06>
      this.doesImpactMilestone = false; //<T06>
    }

    resetFieldValues(){
      this.versionSelected = undefined;
      this.OrgIdCheckbox = false;
      this.selectedOrgId = undefined;
      this.orgIdManual = undefined;
      this.caseSecureAgent = '';
      this.selectedEnvironment = undefined;
      this.selectedActivityType = undefined;
      this.selectedProblemArea = undefined;
    }

    /*
    get showCaseTypes(){
      console.log(`caseTypes: ${JSON.stringify(this.caseType)}`);
      let types = [];
      if(this.caseType.data.values){
        this.caseType.data.values.forEach(ele => {
          types.push({label: ele.label, value: ele.value});
        });
      }
      return types;
    }
    */

    get noOrgsAvailable(){
      return this.orgIdDropDownValues.length <= 0 ? true : false;
    }

    
  /* Operations case activity window */

  showAppointmentDateChecker() {
    this.showSessionDate = SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType) ? true : false;
    this.clearDateSlotFieldValues();

    if (SCHEDULED_ACTIVITY_TYPE.includes(this.selectedActivityType) && this.selectedEnvironment && this.selectedPriority) {
      getAvailableSlots({ priority: this.selectedPriority, environmentType: this.selectedEnvironment })
        .then(objSlotsMap => {
          console.log('available slots >> ' + JSON.stringify(objSlotsMap));
          this.processAvailableSlots(objSlotsMap);
        })
        .catch(error => {
          console.log('error getting available slots >> ' + JSON.stringify(error));
        })
    }
  }

  handleDateSelect(event) {
    this.selectedDate = event.detail.value;
    this.selectedSlot = undefined;
    console.log('Selected Date >> ' + event.detail.value);
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
    console.log('slotId >> ' + event.detail.value);
    this.availableDatesWithSlots.forEach(objDay => {
      objDay.lstSlots.forEach(objSlot => {
        if (objSlot.strId === event.detail.value) {
          this.slotStartDT = objSlot.startDT;
          this.slotEndDT = objSlot.endDT;
        }
      })
    });
    console.log('slotStartDateTime >> ' + this.slotStartDT);
    console.log('slotEndDateTime >> ' + this.slotEndDT);
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
    console.log('objSlotsMap processed >> ' + JSON.stringify(objSlotsMap));
    this.availableDatesWithSlots = lstAvailableDatesAndSlots;
    this.availableDates = lstAvailableDates;
    console.log('processed dates >> ' + JSON.stringify(this.availableDates));
  }

  clearDateSlotFieldValues() {
    this.selectedDate = undefined;
    this.selectedSlot = undefined;
    this.slotStartDT = undefined;
    this.slotEndDT = undefined;
    this.availableSlots = undefined;
  }

  resetFields() {
    this.selectedActivityType = undefined;
    this.selectedEnvironment = undefined;
  }

  closequickaction(){
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

}