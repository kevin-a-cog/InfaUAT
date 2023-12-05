/*
 * Name         :   caseContextualLayout
 * Author       :   Vignesh
 * Created Date :   06-Jun-2021
 * Description  :   

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Vignesh D              06-Jun-2021     UTOPIA              Initial version.                                          NA
 Vignesh D              19-Nov-2021     I2RT-4417           Add 'Category' and 'Area of expertise' fields             T01
                                                            to AAE Session details
 Vignesh D              22-Jun-2022     I2RT-6484           Show Hypercare section                                    T02
 balajip                22-Aug-2022     I2RT-6867           Show certain sections for Case Lite cases                 T03
 Vignesh D              22-Jun-2022     I2RT-8640           Get business owner details from certification request     T04
                                                            instead of support account
 */

import { LightningElement,api,track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

//LWC Utilties
import { log,objUtilities } from 'c/globalUtilities';
//Apex Controllers.
//import getRecords from "@salesforce/apex/GlobalUpcomingEventsController.getRecords";

//Case Fields to import from schema
import CASE_TYPE from '@salesforce/schema/Case.RecordType.Name';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_ESCALATED from '@salesforce/schema/Case.Escalated__c';
import CASE_ENGAGEMENT from '@salesforce/schema/Case.Engagement__c';
import CASE_ENGAGEMENT_NUMBER from '@salesforce/schema/Case.Engagement__r.Engagement_Number__c';
import CASE_ENGAGEMENT_PRIORITY from '@salesforce/schema/Case.Engagement__r.Priority__c';
import CASE_ENGAGEMENT_STATUS from '@salesforce/schema/Case.Engagement__r.Status__c'
import CASE_MONITORING_ENABLED from '@salesforce/schema/Case.Monitoring_Enabled__c';
import CASE_MONITORING_QUEUE from '@salesforce/schema/Case.Product_Queues__c';
import CASE_ESCALATION_NOTES from '@salesforce/schema/Case.Escalation_Notes__c';
import CASE_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';
import CASE_MCR from '@salesforce/schema/Case.Manager_Review_Comments__c';
import CASE_WEEKENDHOLIDAY from '@salesforce/schema/Case.Weekend_Holiday_Support__c';
import CASE_SUPPORTSTART from '@salesforce/schema/Case.Support_Start_DateTime__c';
import CASE_SUPPORTEND from '@salesforce/schema/Case.Support_End_DateTime__c';
import ACCOUNT_HANDLING_INSTRUCTIONS from '@salesforce/schema/Case.Support_Account__r.Handling_Instructions__c';
import AAETIME from '@salesforce/schema/Case.GCS_AAE_Session_Time__c';
import CASE_CATEGORY from '@salesforce/schema/Case.Category__c'; // <T01>
import CASE_AREA_OF_EXPERTISE from '@salesforce/schema/Case.AAE_Area_of_expertise__c'; // <T01>
import CASE_SEGMENT from '@salesforce/schema/Case.Segment__c'; // <T02>
import CASE_FORECAST_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c'; //<T02>
import CR_BUSINESS_OWNERID from '@salesforce/schema/Certification_Request__c.Owner__c'; //<T02> //<T04>
import CR_BUSINESS_OWNER_NAME from '@salesforce/schema/Certification_Request__c.Owner__r.Name'; //<T02> //<T04>

//Apex Controllers
import getAccountTeamMembers from '@salesforce/apex/CaseController.getAccountTeamMembers'; //<T02>
import getCertificationRequest from "@salesforce/apex/SupportAccountController.getCertificationRequest"; //<T04>

const fields = [CASE_TYPE,AAETIME,CASE_WEEKENDHOLIDAY,CASE_SUPPORTSTART,CASE_SUPPORTEND,CASE_STATUS,CASE_ESCALATED,CASE_ENGAGEMENT,CASE_ENGAGEMENT_NUMBER,CASE_ENGAGEMENT_PRIORITY,CASE_ENGAGEMENT_STATUS,CASE_MONITORING_ENABLED,CASE_ESCALATION_NOTES,CASE_SUPPORT_ACCOUNT,CASE_MCR,ACCOUNT_HANDLING_INSTRUCTIONS,CASE_SEGMENT,CASE_FORECAST_PRODUCT]; //<T02> //<T04>
const CASE_TECHNICAL = 'Technical';
const CASE_OPERATIONS = 'Operations';
const CASE_ADMIN = 'Administrative';
const CASE_SHIPPING = 'Fulfillment';
const CASE_AAE = 'Ask An Expert';
const CASE_LITE = 'Case Lite'; //T03

const SUPPORT_ACC_FIELDS = [ACCOUNT_HANDLING_INSTRUCTIONS];

export default class CaseConceptualSection extends NavigationMixin(LightningElement) {
    @api label;
    @api recordId;
    @api recordTypeId;
    @api engagementRecordId;

    @track isLoading = false;
    @track boolDisplayPopOver = false;
    @track caseFieldValues;
    @track caseType;
    @track caseStatus;
    @track showEscalationSection = false;    
    @track showEngagementSection = false;
    @track showMonitoringSection = false;
    @track showNotesOrMRCSection = false;
    @track showClosingSection = false;
    @track showWeekendMonitoringSection = false; // Tejasvi -> I2RT-4623: Weekend/Holiday Monitoring must show in Highlights
    @track caseEscalationComment;
    @track caseEngagement;
    @track aaesessiontime;
    @track isaaecase = false;
    @track showevents = false;
    @track caseClosingFields = [
        {label: "Closed Date", name: 'ClosedDate', show: false, hide:false, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_ADMIN,CASE_SHIPPING,CASE_LITE], class: 'slds-col slds-size_1-of-2 pad-left pad-right'}, //T03
        //{label: "Delay Close Date", name: 'Delay_Close_Date__c', show: false, hide:true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_ADMIN,CASE_SHIPPING], class: 'slds-col slds-size_1-of-2 pad-left pad-right'},
        //{label: "Resolution Type", name: 'Root_cause__c', show: false, hide:true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_SHIPPING], class: 'slds-col slds-size_1-of-2 pad-left pad-right'},
        //{label: "Resolution Code", name: 'Resolution_Code__c', show: false, hide:true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_SHIPPING], class: 'slds-col slds-size_1-of-2 pad-left pad-right'},
        //{label: "Cause of Delay", name: 'Cause_of_Delay__c', show: false,hide:true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_SHIPPING], class: 'slds-col slds-size_1-of-2 pad-left pad-right'},
        //{label: "SLA Override", name: 'SLA_Override__c', show: false,hide:false, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_SHIPPING], class:'slds-col slds-size_1-of-2 pad-left pad-right'},
        {label: "Closing Notes", name: 'Closing_Notes__c', show: false,hide:false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL,CASE_OPERATIONS,CASE_ADMIN,CASE_SHIPPING,CASE_LITE], class: 'slds-col slds-size_1-of-2 pad-left pad-right'} //T03
    ];
    activeSections = ['Escalation', 'Closed','Monitoring','Handling Instructions'];
    @track handlingInstructions;
    caseForecastProduct;
    @track objHypercareSection = {
        boolShow: false,
        strCaseSegment: '',
        strSupportAccountId: '',
        objBusinessOwner: {
            Id: '',
            Name: ''
        },
        showSupportSME: false,
        lstAccountTeamMembers: []
    }; //<T02>

    @wire(getRecord, { recordId: '$recordId', fields })
    caseFields({data,error}){
        if(data){
            log('CaseContextualLayout::DATA @wire getRecord->'+JSON.stringify(data));
            this.caseFieldValues = data;
            this.aaesessiontime = data.fields.GCS_AAE_Session_Time__c.value;
            if(data.fields.RecordType != undefined && data.fields.RecordType.displayValue != null){
                this.caseType = data.fields.RecordType.displayValue;
                this.recordTypeId = data.fields.RecordType.value.id;
                // log('CaseContextualLayout::@wire recordTypeId-->'+this.recordTypeId);
            }

            if(this.caseType == 'Ask An Expert'){
                this.isaaecase = true;
            }

            if(data.fields.Status != undefined && data.fields.Status.value != null){
                this.caseStatus = data.fields.Status.value;
            }
            this.handlingInstructions = data?.fields?.Support_Account__r?.value?.fields?.Handling_Instructions__c?.value;
            this.caseForecastProduct = data?.fields?.Forecast_Product__c?.value;
            this.objHypercareSection.strSupportAccountId = data?.fields?.Support_Account__c?.value; //<T02>
            this.objHypercareSection.strCaseSegment = data?.fields?.Segment__c?.value; //<T02>
            // this.objHypercareSection.objBusinessOwner.Id = data?.fields?.Support_Account__r?.value?.fields?.Certification_Request__r?.value?.fields?.Owner__c?.value; //<T02> //<T04>
            // this.objHypercareSection.objBusinessOwner.Name = data?.fields?.Support_Account__r?.value?.fields?.Certification_Request__r?.value?.fields?.Owner__r?.value?.fields?.Name?.value; //<T02> //<T04>
            // log('CaseType->'+this.caseType);
            // log('CaseStatus->'+this.caseStatus);
            // log('CaseEscalated->'+data.fields.Escalated__c.value);
            this.boolDisplayPopOver = false;
            return this.main();
        }
        else if(error){
            log('CaseContextualLayout::ERROR @wire getRecord->'+JSON.stringify(error));
        }
    }

    handleClearMonitoring(event){
        event.preventDefault();
        this.isLoading = true;
        let sName = event.target.getAttribute('name');
        let fields = {};
        if(sName == 'Monitoring'){
         fields = {Id : this.recordId,
                        Monitoring_Enabled__c : false,
                        Follow_Sun_Model_Support__c : false,
                        Monitoring_Start_Time__c : '',
                        Product_Queues__c : ''};
        }

        if(sName == 'Weekend'){
            fields = {  Id : this.recordId,
                Weekend_Holiday_Support__c  : false,
                Support_Start_DateTime__c : '',
                Support_End_DateTime__c : ''};
        }
        
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(sName == 'Weekend'){
                this.showWeekendMonitoringSection = false;
            }
            if(sName == 'Monitoring'){
           this.showMonitoringSection = false;
            }
           this.showToastNotifaction('Success', 'Monitoring has been stopped successfully','success');
        })
        .catch(error => {
            console.log(error);
            this.showToastNotifaction('Error', error,'error');
            
        });
    }

    showToastNotifaction(sTitle,sMessage,sVariant){
        this.isLoading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: sTitle,
                message: sMessage,
                variant: sVariant
            })
        );
    }

    main(){
        this.handleEscalationSection();
        this.handleEngagementSection();
        this.handleMonitoringSection();
        this.handleNotesOrMRCSection();
        this.handleClosingSection();
        this.handleHypercareSection(); //<T02>
    }
    
    navigateToEngagement(){
        let data = this.caseFieldValues.fields;
        let engId = data?.Engagement__c && data?.Engagement__c?.value ? data.Engagement__c.value : undefined;
        if(engId != undefined){
            this.handleNavigation(engId, 'Engagement__c');
        }
    }

    handleNavigation(strRecordId, strObjectName){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: strRecordId,
                objectApiName: strObjectName,
                actionName: "view"
            }
        });
    }

    handleEscalationSection(){
        let data = this.caseFieldValues.fields;
        if(data?.Escalated__c && data?.Escalated__c?.value){
            if(data.Escalated__c.value == true){
                this.showEscalationSection = true;                
            }
        }
        // log('showEscalationSection->'+this.showEscalationSection);
    }

    handleEngagementSection(){
        if(this.caseType){
            if(this.caseType === CASE_TECHNICAL || this.caseType === CASE_OPERATIONS){
                let data = this.caseFieldValues.fields;        
                if(data?.Engagement__r && data?.Engagement__r?.value){
                    this.caseEngagement = data.Engagement__r.value;
                    if(data?.Engagement__r?.value?.fields?.Status__c?.value){
                        if(data.Engagement__r.value.fields.Status__c.value === 'Closed'){
                            this.showEngagementSection = false;
                        }
                        else{
                            this.showEngagementSection = true;
                        }   
                    }
                }

                // log('showEngagementSection->'+this.showEngagementSection);
                // log('caseEngagement->'+JSON.stringify(this.caseEngagement));
            }
        }
    }

    handleMonitoringSection(){
        if(this.caseType){
            if(this.caseType === CASE_TECHNICAL || this.caseType === CASE_LITE || this.caseType === CASE_OPERATIONS){ //T03
                let data = this.caseFieldValues.fields;
                if(data?.Monitoring_Enabled__c && data?.Monitoring_Enabled__c?.value && data?.Monitoring_Enabled__c?.value == true){
                    this.showMonitoringSection = true;
                }
                // log('showMonitoringSection->'+this.showMonitoringSection);
                if(data?.Weekend_Holiday_Support__c && data?.Weekend_Holiday_Support__c?.value && data?.Weekend_Holiday_Support__c?.value == true){
                    this.showWeekendMonitoringSection = true;
                }
            }
        }
    }

    handleNotesOrMRCSection(){
        if(this.caseType != undefined && this.caseType != null){
            if(this.caseType === CASE_TECHNICAL || this.caseType === CASE_OPERATIONS){
                let data = this.caseFieldValues.fields;
                if((data.Escalation_Notes__c != undefined && data.Escalation_Notes__c.value != null) || (data.Manager_Review_Comments__c != undefined && data.Manager_Review_Comments__c.value != null)){
                    this.showNotesOrMRCSection = true;
                }
                // log('showNotesOrMRCSection->'+this.showNotesOrMRCSection);
            }
        }
    }

    handleClosingSection(){
        // log('CASETYPE : '+this.caseType);
        // log('CASESTATUS: '+this.caseStatus);
        if(this.caseStatus === 'Closed'){
            // log('closed case:');
            this.caseClosingFields.forEach(field => {
                if(field.showCaseTypes.includes(this.caseType)){
                    if(!field.hide){
                        field.show = true;
                        // log('label value:'+field.label);
                    }
                }
            })
            this.showClosingSection = true;
        }
    }

    //-------------------------------<T02>-----------------------------
    handleHypercareSection(){
        let objParent = this;
        if(objParent.objHypercareSection.strCaseSegment === 'Hypercare'){
            if(objUtilities.isNotBlank(objParent.objHypercareSection.strSupportAccountId)){
                getAccountTeamMembers({accountId: objParent.objHypercareSection.strSupportAccountId})
                .then(lstAccountTeamMembers => {
                    objParent.objHypercareSection.lstAccountTeamMembers = lstAccountTeamMembers.filter(accountTeamMember => {
                        let lstProducts = objUtilities.isNotBlank(accountTeamMember?.Product__c) ? accountTeamMember.Product__c.split(';') : [];
                        return lstProducts.includes(objParent.caseForecastProduct) && accountTeamMember.TeamMemberRole === 'Support SME';
                    });
                    objParent.objHypercareSection.showSupportSME = objParent.objHypercareSection.lstAccountTeamMembers.length > 0 ? true : false;
                    if (objParent.objHypercareSection.showSupportSME) { //<T04>
                        objParent.objHypercareSection.boolShow = true;
                    }
                })
                .catch(objError => {
                    objUtilities.processException(objError, objParent);
                });

                //-------------------------------<T04>-----------------------------
                getCertificationRequest({ strSupportAccountId: objParent.objHypercareSection.strSupportAccountId })
                    .then(objResponse => {
                        if (typeof objResponse === 'object' && Object.keys(objResponse)?.length && objUtilities.isNotBlank(objResponse[objParent.objHypercareSection.strCaseSegment])) {
                            let lstRecords = objResponse[objParent.objHypercareSection.strCaseSegment];
                            let objRecord = lstRecords.length ? lstRecords[0]?.objCertificationRequest : undefined;
                            if (objUtilities.isNotBlank(objRecord)) {
                                objParent.objHypercareSection.objBusinessOwner.Id = objRecord.Owner__c;
                                objParent.objHypercareSection.objBusinessOwner.Name = objRecord.Owner__r.Name;
                                objParent.objHypercareSection.boolShow = true;
                            }
                        }
                    })
                    .catch(objError => {
                        objUtilities.processException(objError, objParent);
                    });
                //-------------------------------<T04>-----------------------------
            }
        }
    }

    navigateToUser(objEvent){
        this.handleNavigation(objEvent.currentTarget.dataset.id, 'User');
    }
    //-------------------------------</T02>-----------------------------

    /*
	 Method Name : linkCellMouseOver
	 Description : This method catches the Mouse Over event on Link Cells.
	 Parameters	 : Object, called from linkCellMouseOver, objEvent Select event.
	 Return Type : None
	 */
	linkCellMouseOver(objEvent) {
        this.boolDisplayPopOver = true;

        //Now we adapt the pop over to the right position.
        let compactLayout = this.template.querySelector(".compactLayout");
        if(compactLayout.classList.contains('slds-hide')){
            compactLayout.classList.remove('slds-hide');
        }
        compactLayout.style = "top: " + ( objEvent.clientY + 30) + "px; left: " +  objEvent.clientX + "px; position: fixed; z-index: 9999999;";      
    }

    /*
	 Method Name : linkCellMouseOut
	 Description : This method catches the Mouse Out event on Link Cells.
	 Parameters	 : None.
	 Return Type : None
	 */
	linkCellMouseOut(objEvent) {
		this.boolDisplayPopOver = false;
        let compactLayout = this.template.querySelector(".compactLayout");
        if(!compactLayout.classList.contains('slds-hide')){
            compactLayout.classList.add('slds-hide');
        }   
    }

    get isescalated() { return (this.showEscalationSection || this.showEngagementSection);}

    get displayComponent(){
        return this.showevents || this.showEscalationSection || this.showEngagementSection || this.showMonitoringSection || this.showWeekendMonitoringSection || this.showNotesOrMRCSection || this.showClosingSection || this.handlingInstructions || this.isaaecase || this.objHypercareSection.boolShow; // <T01>
    }

}