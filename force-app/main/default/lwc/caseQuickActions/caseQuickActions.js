/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                           NA
 Amarender              15-Dec-2021     I2RT-5157           Next Action field selection during Always defaults 
                                                            to 'Case Owner' when transitioning through case states     T01
 Vignesh D              07-Jan-2022     I2RT-5069           Remove resetFields() from setButtonVisibility() method     T02
                                                            and call it before every Next Best Action where applicable
 Vignesh D              24-Jan-2022     I2RT-5328           Validate Rich text field input for blank & spaces          T03                                    
 Vignesh D              31-Jan-2022     I2RT-5387           Add resolution code & type to list of fields to update     T04
                                                            on delayed closing                                                                            
 balajip                22-Aug-2022     I2RT-6867           Case Lite changes                                          T05
 
Sathish R               25-Oct-2022     I2RT-7308           Add Article Validation status and Article                  T06
                                                            language columns in the KB list under KB action            
Vignesh D               08-Nov-2022     I2RT-7449           Added condition to exclude setting version to None         T08
                                                            for Case Lite
balajip                 04-Nov-2022     I2RT-7322           to use separate template for Case Lite for 
                                                              Delayed Close Response                                   T09
balajip                 21-Nov-2022     I2RT-7508           to pass the Case Id in the payload                         T10
balajip                 25-Nov-2022     I2RT-7519           to pass current Tab Id in the request to open the subtab   T11

Sathish R               17-Sep-2023     I2RT-9046           KB action selection changes on case closure based on 
                                                            resolution types and resolution codes.                     T12
Shashikanth             19-Sep-2023     I2RT-9026           Capture Components fields even for Fulfilment cases        T13
Sathish R               24-Oct-2023     I2RT-9212           New column - 'Article Record Type' in attached KBs and 
                                                            search results KB table in case layout.                    T14
*/
import { LightningElement, track, api, wire } from 'lwc';
import { publish, createMessageContext, releaseMessageContext} from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import passEmailTemplate from "@salesforce/messageChannel/CaseCommunicationMessageChannel__c";
import getEmailBody from '@salesforce/apex/CaseQuickActionsController.getEmailBody';
import checkopenjiras from '@salesforce/apex/CaseQuickActionsController.checkopenjiras';
import getProductAttributes from '@salesforce/apex/caseDependentPicklistController.getProductAttributes';

import createCaseCommentRecord from '@salesforce/apex/CaseQuickActionsController.createCaseCommentRecord';
import updateCaseStatus from '@salesforce/apex/CaseQuickActionsController.updateCaseStatus';
import completemilestone from '@salesforce/apex/CaseController.completemilestone';

import getCaseResolution from '@salesforce/apex/CaseController.getCaseResolution';
import { getRecord,notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_Status from '@salesforce/schema/Case.Status';
import PRODUCT_VALUE from '@salesforce/schema/Case.Forecast_Product__c';
import COMPONENT_VALUE from '@salesforce/schema/Case.Component__c';
import SUBCOMPONENT_VALUE from '@salesforce/schema/Case.Subcomponent__c';
import VERSION_VALUE from '@salesforce/schema/Case.Version__c';
import PROBLEMTYPE_VALUE from '@salesforce/schema/Case.Problem_Type__c';
import CASE_Contact from '@salesforce/schema/Case.Contact.INFA_Language__c';
import Contact_Language from '@salesforce/schema/Contact.INFA_Language__c';
import Contact_OBJECT from '@salesforce/schema/Contact';
import RECORDTYPE_NAME from '@salesforce/schema/Case.Record_Type_Name__c';
import RECORDTYPEID from '@salesforce/schema/Case.RecordTypeId';
import DELIVERY_METHOD from '@salesforce/schema/Case.Delivery_Method__c';
import EXPECTED_DATE from '@salesforce/schema/Case.Expected_Date__c';
import RESOLUTION_TYPE from '@salesforce/schema/Case.Root_cause__c';
import RESOLUTION_CODE from '@salesforce/schema/Case.Resolution_Code__c';
import AUTO_CLOSURE_DATE from '@salesforce/schema/Case.Automatic_closure_Date__c';
import IS_DELAY_CLOSE from '@salesforce/schema/Case.Is_Delay_Close__c';
import RCA_PENDING from '@salesforce/schema/Case.RCA_Pending_flag__c';
import CLOSING_NOTES from '@salesforce/schema/Case.Closing_Notes__c';
import IS_RCA_SENT from '@salesforce/schema/Case.Is_RCA_Sent__c';
import NEXT_ACTION from '@salesforce/schema/Case.Next_Action__c';           //<T01>
import CASE_NEXT_STEPS from '@salesforce/schema/Case.Next_Steps__c'; //<T03>
import CASE_PROBLEM_STATEMENT from '@salesforce/schema/Case.Problem_Statement__c'; //<T03>
import CASE_ROOT_CAUSE_ANALYSIS from '@salesforce/schema/Case.Root_Cause_Analysis__c'; //<T03>
import KB_Language from '@salesforce/label/c.KB_Language'; //T06

/* Utilities */
import { log, objUtilities } from 'c/globalUtilities';
import { NavigationMixin } from 'lightning/navigation';

//Start --> Sathish R --> Jira : I2RT-3105
import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import getSimilarArticle from "@salesforce/apex/KBContentSearch.getSimilarArticle";
import processKnowledgeBaseArticle from "@salesforce/apex/CaseKBCreation.processKnowledgeBaseArticle";
import getCaseToKB from "@salesforce/apex/CaseKBCreation.getCaseToKB";
import KB_ACTION from '@salesforce/schema/Case.KB_Action__c';
import KB_KEYWORD from '@salesforce/schema/Case.KB_Keyword__c';
import KB_TEMPLATE from '@salesforce/schema/Case.KB_Template__c';


const KBADDACTION =
    { type: 'action', typeAttributes: { rowActions: [{ label: 'Add', name: 'add' },{ label: 'View', name: 'view' }] } };
const KBDELETEUPDATEACTION = {
    type: 'action', typeAttributes: {
        rowActions: [
            { label: 'Delete', name: 'delete' }, { label: 'Update', name: 'update' }, { label: 'View', name: 'view' }
        ]
    }
};
const KBVIEWACTION =
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } 
};

//KB ACTIONS
const KB_CREATE_NEW = 'Create New';
const KB_USE_EXISTING = 'Use Existing';
const KB_UPDATE_EXISTING = 'Updated Existing';
const NOT_APPLICABLE = 'NA'; //Jira : I2RT-4955
const CLOSE_CASE = 'Close Case';
const PROVIDE_SOLUTION = 'Provide Solution';
const DELAYED_CLOSING = 'Delayed Closing';
const KB_NONE = '--None--'; //T12

//T12 - START
const DOCUMENTED_SOLUTION = 'Documented Solution'; 
const UNDOCUMENTED_SOLUTION = 'Undocumented Solution'; 
const ADVANCED_TROUBLESHOOTING = 'Advanced Troubleshooting'; 
const CUSTOM_CONFIGURATION = 'Custom Configuration'; 
const CHANGE_REQUEST = 'Change Request';
const EBF_PATCH = 'EBF/patch'; 
const WORKAROUND = 'Workaround'; 
const KB = 'KB'; 
const KB_ACTION_TOAST_MESSAGE = 'Attention! The Resolution Type and Resolution Code combination you selected may require a KB Action. Please attach or create a KB to support this case.'
//T12 - END

//End --> Sathish R --> Jira : I2RT-3105

const fields = [CASE_Status,RCA_PENDING,CASE_Contact,PRODUCT_VALUE,COMPONENT_VALUE,SUBCOMPONENT_VALUE,VERSION_VALUE,PROBLEMTYPE_VALUE,RECORDTYPE_NAME,RECORDTYPEID,DELIVERY_METHOD,RESOLUTION_TYPE,RESOLUTION_CODE,AUTO_CLOSURE_DATE,IS_DELAY_CLOSE,EXPECTED_DATE,KB_ACTION,KB_TEMPLATE,KB_KEYWORD,CLOSING_NOTES,IS_RCA_SENT,NEXT_ACTION];  //<T01>

//Case Status
const CASE_STATUS_NEW = 'New';
const CASE_STATUS_ASSESS = 'Assess';
const CASE_STATUS_RESEARCH = 'Research';
const CASE_STATUS_SOLUTION = 'Solution';
const CASE_STATUS_CLOSED = 'Closed';

//Case RecordTypes
const CASE_TECHNICAL = 'Technical';
const CASE_LITE = 'Case Lite'; //T05
const CASE_OPERATIONS = 'Operations';
const CASE_ADMINISTRATIVE = 'Administrative';
const CASE_FULFILLMENT = 'Fulfillment';

//UI Validations
const INCORRECT_RCA_PENDING = 'Please update RCA Pending to \'No\'.';

//Start --> Sathish R --> Jira : I2RT-7308 - T06
function GetKBLanguageFieldValue(parLanguageCode, thislcl) {
    var varLanguage = parLanguageCode;
    try {
        var varFieldValue = parLanguageCode.trim();
        if (varFieldValue == '') {
            varLanguage = '';
        }
        else {
            varFieldValue = varFieldValue.toLowerCase();
            var len = thislcl.AllLanguages.length;
            while (len--) {
                if (len != 0) {
                    var varLangDetails = thislcl.AllLanguages[len - 1].split('$$');
                    if (varLangDetails.length > 0) {
                        if (varLangDetails[1].toLowerCase() == varFieldValue) {
                            varLanguage = varLangDetails[0];
                        }
                    }
                }
            }
        }

    } catch (error) {
        log('case GetKBLanguageFieldValue error --> ' + JSON.stringify(error));       
    }
    return varLanguage;
}
//End --> Sathish R --> Jira : I2RT-7308 - T06

export default class CaseQuickActions extends NavigationMixin(LightningElement) {
    @api recordId;
    //API variables.
    @api boolIsInSubtab;
    @api strMethodName;
    @api objEvent;
    
    @track showModal = false;
    @track showProvideSolution = false;
    @track showProvideSolutionForAdminFulfillment = false;
    @track showRequestMoreInfo = false;
    @track showRequestMoreInfoForAdminFulfillment = false
    @track showCloseCase = false;
    @track showCloseCaseForAdminFulfillment = false;
    @track showCloseCaseClosingNotesNew = false;
    @track showCloseCaseRCAKBSolution = false;
    @track showAutoCloserDate = false;
    @track showCancelDelayClosing = false;
    @track showProvideSolutionButtont = false;
    @track showRequestMoreInfoButton = false;
    @track showCloseCaseButton = false;
    @track showDelayClosingButton = false;
    @track showCancelDelayClosingButton = false;
    @track showProductVersionForFulFillment = false;
    @track showLanguage = false;
    //@track showChangeLanguageButton=false;
    @track showEditFormFields = 'slds-hide';
    @track modalHeader;
    @track templateName;
    @track caseStatus;
    @track currentStatus;
    @track caseAutomaticClosureDate;
    @track caseIsDelayClose;
    //@track selectedLanguage;
    //@track showlanguagevalue;
    //@track defaultLanguage;
    //@track languageOptions = [];
    @track showNewKbSection = false;
    @track showErrorInKb = false;
    @track showacceptreject = false;
    @track isSolutionState = false;
    //@track showLanguageLabel = true;
    @track showSaveButton = true;
    @track showBackButton = false;
    @track showAcceptedSolutionField = false;
    @track showRejectNeedMoreInfoField = false;
    @track showNeedMoreTimeField = false;
    @track isGetEmailBody = true;
    @track caseComment = '';
    @track jiraclosemessage = false;
    @track problemst = ' ';
    @track showsolclosefields = true;
    @track showClosingNotesField = false;
    @track closingnoteslabel;
    @track closingnotesvalue = '';
    @track showClosingNotesRequired = false;


    //Start --> Sathish R --> Jira : I2RT-3105
    @track showUpdateKbSection = false;
    @track searchTokenFor = 'casetokbassociation';
    @track searchtoken = '';
    @track searchhubname = '';
    @track searchorgname = '';
    @track showSearchTokenError = false;
    @track showSearchTokenSuccess = false;
    @track showCaseSpace = true;
    @track showUpdateKBSectionSpinner = false;
    @track showAssociatesKB = false;
    @track searchTerm = '';
    @track kbSearchData = [];
    @track kbSelectedData = [];
    @track kbExistingSelectedData = [];
    @track kbSelectedAction = 'NA';  //Jira : I2RT-4955
    @track kbSelectedId = '';
    @track kbCaseKeyword = '';
    @track kbSelectedTemplate = undefined;
    @track showKBActionDropDown = true;
    @track showKBActionReadOnly = false;
    @track kbExistingSelectedAction = 'NA';  //Jira : I2RT-4955
    @track currentModalHeader = '';
    @track showKBActionSubSection = false;

    //T12 - Start
    kbActionWithNAOptions = [
    { label: '--None--', value: '--None--' },
    { label: 'NA', value: 'NA' },
    { label: 'Create New', value: 'Create New' },
    { label: 'Use Existing', value: 'Use Existing' },
    { label: 'Updated Existing', value: 'Updated Existing' }];

    kbActionWithOutNAOptions = [
    { label: '--None--', value: '--None--' },
    { label: 'Create New', value: 'Create New' },
    { label: 'Use Existing', value: 'Use Existing' },
    { label: 'Updated Existing', value: 'Updated Existing' }];
    
    @track kbActionOptions = this.kbActionWithNAOptions;

    kbActionNAOption = this.kbActionOptions[0];
    //T12 - End

    @track kbcolumnswithadd = [        
        { label: 'Title', fieldName: 'title', type: 'string' },
        { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
        { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
        { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
        { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
    ];

    @track kbcolumnswithdeleteupdate = [        
        { label: 'Title', fieldName: 'title', type: 'string' },
        { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
        { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
        { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
        { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
    ];
    @track AllLanguages = KB_Language.toString().split(';');//T06
        
    @track showSearchNoResult = false;
    @track showSearchSuccess = false;
    @track showSelectedKBInKBSpace = false;
    @track showKBSpaceSearchSpinner = false;
    searchPlaceholder = 'Search for KnowledgeBase';
    inputClass = 'slds-form-element';
    KBRECORDURL = 'https://HOSTNAME/lightning/r/Knowledge__kav/RECORDID/view';
    //End --> Sathish R --> Jira : I2RT-3105

    @track KbTemplateOptions = [{ label: 'FAQ', value: 'FAQ' },
    { label: 'Whitepaper', value: 'Whitepaper' },
    { label: 'Solution', value: 'Solution' },
    { label: 'HOW TO', value: 'HOW TO' }];
    context = createMessageContext();

    actionType;
    @track selectedExpectedDate; //Vignesh D: I2RT-3695
    
    @track showDeliveredButton = false; // I2RT-4322
    @track showCancelled = false; // I2RT-4322
    
    @track bShowModalReason = false; // added by piyush 22 sep
    @track aaeCancelDeliverNotes = '';
    @track aaeCancelDeliverEvent = '';
    @track showDelayedClosing = false;
    @track boolIsRCASent = false;

    //<T03>
    objRichTextFields = [
        CLOSING_NOTES.fieldApiName,
        CASE_NEXT_STEPS.fieldApiName,
        CASE_PROBLEM_STATEMENT.fieldApiName,
        CASE_ROOT_CAUSE_ANALYSIS.fieldApiName
    ];

    @wire(getRecord, { recordId: '$recordId', fields })
    relatedMedia({ data, error }) {
        if (data) {
            log('Data= ' + JSON.stringify(data));
            this.currentStatus = data.fields.Status.value;
            this.recordTypeName = data.recordTypeInfo.name;
            this.showEditFormFields = 'slds-show';
            this.caseRecordTypeId = data.recordTypeId;
            this.caseDeliveryMethod = data.fields.Delivery_Method__c.value;
            this.caseRecordTypeName = data.recordTypeInfo.name;
            this.caseResolutionType = data?.fields?.Root_cause__c?.value;
            this.selectedResolutionType = data?.fields?.Root_cause__c?.value;
            this.caseResolutionCode = data?.fields?.Resolution_Code__c?.value;
            this.selectedResolutionCode = data?.fields?.Resolution_Code__c?.value;
            
            this.caseAutomaticClosureDate = data?.fields?.Automatic_closure_Date__c?.value;
            this.caseIsDelayClose = data?.fields?.Is_Delay_Close__c?.value;
            this.selectedExpectedDate = data?.fields?.Expected_Date__c?.value;
            this.closingnotesvalue = data?.fields?.Closing_Notes__c?.value;
            
            if(data.fields.RCA_Pending_flag__c){
                this.rcapending = data.fields.RCA_Pending_flag__c.value;
            }
            this.boolIsRCASent = data.fields.Is_RCA_Sent__c.value;
            //Start --> Sathish R --> Jira : I2RT-3105
            if (data.fields.KB_Action__c != undefined && data.fields.KB_Action__c != null) {
                this.kbSelectedAction = data.fields.KB_Action__c.value;
                this.kbExistingSelectedAction = data.fields.KB_Action__c.value;
            }

            if (data.fields.KB_Keyword__c != undefined && data.fields.KB_Keyword__c != null) {
                this.kbCaseKeyword = data.fields.KB_Keyword__c.value;                
            }

            if (data.fields.KB_Template__c != undefined && data.fields.KB_Template__c != null) {
                this.kbSelectedTemplate = data.fields.KB_Template__c.value;                
            }
            //End --> Sathish R --> Jira : I2RT-3105
        
            this.selectedNextAction = data.fields.Next_Action__c.value;     //<T01>
            this.setButtonVisibility();

            //Now we check if we are opening this component in a subtab.
            if(this.boolIsInSubtab) {
                this[this.strMethodName](this.objEvent);
            }
        } else if (error) {
            log('Error' + JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    objectInfo;

    //T05
    get isCaseLite(){
        return (this.recordTypeName == CASE_LITE);
    }

    get hasNotesData(){
        return this.aaeCancelDeliverNotes == '' ? true : false;
    }

    handleBackClick() {
        this.showLanguage = false;
        this.showNewKbSection = false;
        this.showUpdateKbSection = false;
        this.hideUpdateKBSpace();        
        this.showErrorInKb = false;
        this.showEditFormFields = 'slds-show';
        this.showBackButton = false;
        this.showSaveButton = true;
    }

    handleKBChange(event) {
        var selectedValue = event.detail.value;       
        this.processKBActionRelatedDetails(selectedValue);//T12
    }

    setButtonVisibility() {
        log('calling setButtonVisibility');
        //this.resetFields(); <T02>
        if (this.currentStatus == CASE_STATUS_NEW && (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS)) { //T05
            this.showCloseCaseButton = true;
        } else if (this.currentStatus == CASE_STATUS_ASSESS) {
            this.showProvideSolutionButtont = true;
            this.showRequestMoreInfoButton = true;
            this.showCloseCaseButton = true;
            this.showDelayClosingButton = this.caseIsDelayClose ? false : true;
            this.showCancelDelayClosingButton = this.caseIsDelayClose ? true : false;
            this.isSolutionState = false;
            this.showacceptreject = false;
        } else if (this.currentStatus == CASE_STATUS_RESEARCH) {
            this.showProvideSolutionButtont = true;
            this.showRequestMoreInfoButton = false;
            this.showCloseCaseButton = true;
            this.showDelayClosingButton = this.caseIsDelayClose ? false : true;
            this.showCancelDelayClosingButton = this.caseIsDelayClose ? true : false;
            this.isSolutionState = false;
            this.showacceptreject = false;
        } else if (this.currentStatus == CASE_STATUS_SOLUTION) {
            this.showProvideSolutionButtont = false;
            this.showRequestMoreInfoButton = false;
            this.showCloseCaseButton = true;
            this.showDelayClosingButton = this.caseIsDelayClose ? false : true;
            this.showCancelDelayClosingButton = this.caseIsDelayClose ? true : false;
            this.isSolutionState = true;
            this.showacceptreject = this.recordTypeName === CASE_OPERATIONS && (this.rcapending === 'Yes' || this.rcapending === 'No' && !this.boolIsRCASent) ? false : true;
        } else {
            this.showProvideSolutionButtont = false;
            this.showRequestMoreInfoButton = false;
            this.showCloseCaseButton = false;
            this.showDelayClosingButton = false;
            this.showCancelDelayClosingButton = false;
            this.isSolutionState = false;
            this.showacceptreject = false;
        }
        //added by piyush 
        if(this.currentStatus == 'Booked' || this.currentStatus == 'Scheduled'){
            this.showDeliveredButton = true;
            this.showCancelled = true;   
        }
        else{
            this.showDeliveredButton = false;
            this.showCancelled = false;   
        }
    }

    closeReasonModal(event){
        this.bShowModalReason = false;
        this.aaeCancelDeliverNotes = '';
        this.aaeCancelDeliverEvent = '';   
    }

    handleStatusUpdateReason(event){
        var whichAction = event.target.label;   
        this.aaeCancelDeliverEvent = whichAction;     
        this.bShowModalReason = true;
    }

    cancelDeliverReasonChange(event){
    var value = event.target.value;
    this.aaeCancelDeliverNotes = value;
    }

    submitCaseCommentAAE(event){
        this.showSpinner = true;
        var whichAction =  this.aaeCancelDeliverEvent;

        updateCaseStatus({ caseId: this.recordId , status : whichAction, caseCommentNotes : this.aaeCancelDeliverNotes  })
        .then(result => {
                this.bShowModalReason = false;
                this.aaeCancelDeliverNotes = '';
                this.aaeCancelDeliverEvent = '';                  
                this.showToastEvent('Success', 'Status has been updated successfully.' , 'success');
                notifyRecordUpdateAvailable([{
                    recordId: this.recordId
                }]);
                this.dispatchEvent(
                    new CustomEvent("close", {
                        bubbles: true,
                        composed: true
                    })
                );
                this.showSpinner = false;
            //   log('Success!!!' + JSON.stringify(result));
            
        })
        .catch(error => {
            log('Error: createCaseCommentRecord' + JSON.stringify(error));
            this.showSpinner = false;
            this.showToastEvent('Error', error.body.message, 'error');
        });
    }

    handleProvideSolution() {
        this.resetFields(); //<T02>
        this.getProductValues();
        this.showModal = true;
        this.showsolclosefields = false;
        this.showClosingNotesField = true;
        this.closingnoteslabel = 'Closing Notes / Proposed Solution';
        console.log('closingnotes'+this.closingnoteslabel);
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        this.ShowKBActionSection = false;//Sathish - I2RT-3105
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = false;
        if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
            this.showProvideSolution = true;
            this.showRequestMoreInfo = false;
            this.showCloseCase = false;            
            //this.showAutoCloserDate = false;
            //this.showCancelDelayClosing = false;
            this.handleToggleKBActionSection(PROVIDE_SOLUTION);
        } else if (this.recordTypeName == CASE_ADMINISTRATIVE || this.recordTypeName == CASE_FULFILLMENT) {
            this.showProvideSolutionForAdminFulfillment = true;
            this.showRequestMoreInfoForAdminFulfillment = false;
            this.showCloseCaseForAdminFulfillment = false;
            if (this.recordTypeName == CASE_FULFILLMENT) {
                this.showProductVersionForFulFillment = true;
            }
        }
        //this.showChangeLanguageButton=true;
        this.isGetEmailBody = true;
        this.modalHeader = 'Provide Solution';
        this.templateName = 'Provide Solution without RCA';
        this.actionType = 'Provide Solution';
        //this.caseStatus = CASE_STATUS_SOLUTION;
        this.renderCaseResolution();       
    }

    handleRequestMoreInfo() {
        this.resetFields(); //<T02>
        this.getProductValues();
        this.showModal = true;
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = false;
        if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
            this.showProvideSolution = false;
            this.showRequestMoreInfo = true;
            this.showCloseCase = false;
            this.showKBActionSection = false;
            //this.showAutoCloserDate = false;
            //this.showCancelDelayClosing = false;
        } else if (this.recordTypeName == CASE_ADMINISTRATIVE || this.recordTypeName == CASE_FULFILLMENT) {
            this.showProvideSolutionForAdminFulfillment = false;
            this.showRequestMoreInfoForAdminFulfillment = true;
            this.showCloseCaseForAdminFulfillment = false;
            if (this.recordTypeName == CASE_FULFILLMENT) {
                this.showProductVersionForFulFillment = true;
            }
        }
        this.isGetEmailBody = true;
        //this.showChangeLanguageButton=true;
        this.modalHeader = 'Request More Info';
        this.templateName = 'Request additional Info';
        this.actionType = 'Request More Info';
        //this.caseStatus = CASE_STATUS_RESEARCH;        
    }
    
    handleAcceptSolution() {
        this.getProductValues();
        this.showModal = true;
        this.showProvideSolutionWithRCAFields = false;
        this.showsolclosefields = false;
        this.showProvideSolution = false;
        this.showRequestMoreInfo = false;
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = false;
        this.showCloseCase = false;
        this.showProvideSolutionForAdminFulfillment = false;
        this.showRequestMoreInfoForAdminFulfillment = false;
        this.showCloseCaseForAdminFulfillment = false;
        this.showProductVersionForFulFillment = false;
        //this.showChangeLanguageButton=true;
        this.showAcceptedSolutionField = true;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        this.isGetEmailBody = false;
        this.modalHeader = 'Accept Solution';
        this.actionType = 'Accept Solution';
        this.caseStatus = CASE_STATUS_CLOSED;
        this.renderCaseResolution();
        this.showKBActionSection = false;
    }

    handleRejectSolution() {
        this.resetFields(); //<T02>
        this.showModal = true;
        this.showProvideSolutionWithRCAFields = false;
        this.showProvideSolution = false;
        this.showRequestMoreInfo = false;
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = false;
        this.showCloseCase = false;
        this.showProvideSolutionForAdminFulfillment = false;
        this.showRequestMoreInfoForAdminFulfillment = false;
        this.showCloseCaseForAdminFulfillment = false;
        this.showProductVersionForFulFillment = false;
        //this.showChangeLanguageButton=true;
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = true;
        this.showNeedMoreTimeField = false;
        this.isGetEmailBody = false;
        this.modalHeader = 'Decline Solution';
        this.actionType = 'Decline Solution';
        this.caseStatus = CASE_STATUS_RESEARCH;
        this.showKBActionSection = false;
    }

    handleNeedMoreTime() {
        this.resetFields(); //<T02>
        this.showModal = true;
        this.showProvideSolutionWithRCAFields = false;
        this.showProvideSolution = false;
        this.showRequestMoreInfo = false;
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = false;
        this.showCloseCase = false;
        this.showProvideSolutionForAdminFulfillment = false;
        this.showRequestMoreInfoForAdminFulfillment = false;
        this.showCloseCaseForAdminFulfillment = false;
        this.showProductVersionForFulFillment = false;
        //this.showChangeLanguageButton=true;
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = true;
        this.isGetEmailBody = false;
        this.modalHeader = 'Need More Time';
        this.actionType = 'Need More Time';
        this.caseStatus = CASE_STATUS_SOLUTION;
        this.showKBActionSection = false;
    }

    handleCloseCase() {      
        this.resetFields(); //<T02>
        checkopenjiras({ caseId: this.recordId })
        .then(result => {
            log('result' + result);
            if (result) {
                this.jiraclosemessage = true;
            }
            this.showsolclosefields = false;
            this.getProductValues();
            this.showModal = true;
            this.showAcceptedSolutionField = false;
            this.showRejectNeedMoreInfoField = false;
            this.showNeedMoreTimeField = false;
            this.showCloseCaseRCAKBSolution = false;
            this.ShowKBActionSection = false;//Sathish - I2RT-3105
            this.showAutoCloserDate = false;
            this.showDelayedClosing = false;
            this.showCancelDelayClosing = false;
            if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
                this.showProvideSolutionWithRCAFields = false;
                this.showProvideSolution = false;
                this.showRequestMoreInfo = false;
                //this.showAutoCloserDate = false;
                //this.showCancelDelayClosing = false;
                this.showCloseCase = true;  
                //this.showCloseCaseClosingNotesNew = false;                                      
                    //if(this.currentStatus == CASE_STATUS_NEW || this.currentStatus == CASE_STATUS_ASSESS ){ //3554 KG if status is New/Assess add Closing Notes field 
                this.showCloseCaseClosingNotesNew = true;
                this.showClosingNotesField = true;
                this.closingnoteslabel = 'Closing Notes / Proposed Solution';
            //}
            /*if(this.currentStatus == CASE_STATUS_RESEARCH){
                this.showCloseCaseClosingNotesNew = false;
            } */
                this.handleToggleKBActionSection(CLOSE_CASE); //Sathish - I2RT-3105    
                if (this.currentStatus != CASE_STATUS_SOLUTION) {                       
                    this.showCloseCaseRCAKBSolution = true;
                }
            } else if (this.recordTypeName == CASE_ADMINISTRATIVE || this.recordTypeName == CASE_FULFILLMENT) {
                this.showProvideSolutionForAdminFulfillment = false;
                this.showRequestMoreInfoForAdminFulfillment = false;
                this.showCloseCaseForAdminFulfillment = true;
                if (this.recordTypeName == CASE_FULFILLMENT) {
                    this.showProductVersionForFulFillment = true;
                }
                this.showClosingNotesField = true;
                this.closingnoteslabel = 'Closing Notes';
            }
            this.isGetEmailBody = true;
            //this.showChangeLanguageButton = true;
            this.modalHeader = 'Close Case';
            this.templateName = 'Close Case';
            this.actionType = 'Close Case';
            //this.caseStatus = CASE_STATUS_CLOSED;
            this.renderCaseResolution();
        });        
    }

    handleDelayClosing() {
        this.resetFields(); //<T02>
        this.getProductValues();
        this.showModal = true;
        this.showLanguage = false;
        //this.showChangeLanguageButton = false;
        this.showCancelDelayClosing = false;
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        //this.showLanguageLabel = false;
        this.showProvideSolutionWithRCAFields = false;
        this.showProvideSolution = false;
        this.showRequestMoreInfo = false;
        this.showCloseCase = false;
        this.showClosingNotesField = true;
        this.modalHeader = 'Delayed Closing';
        this.isGetEmailBody = true;
        this.templateName = 'Delayed Close Response';
        //T08 to select different template for Lite cases
        if(this.recordTypeName == CASE_LITE){
            this.templateName += ' - Lite'; 
        }
        this.actionType = 'Delay Close';
        this.showProvideSolutionForAdminFulfillment = false;
        this.showRequestMoreInfoForAdminFulfillment = false;

        if(this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS){ //T05
            this.showAutoCloserDate = true;
            this.showDelayedClosing = false;
            this.closingnoteslabel = 'Closing Notes / Proposed Solution';
            this.showCloseCaseForAdminFulfillment = false;
            this.showProductVersionForFulFillment = false;
            this.renderCaseResolution();        
            this.handleToggleKBActionSection(DELAYED_CLOSING);
        }
        else if(this.recordTypeName == CASE_ADMINISTRATIVE || this.recordTypeName == CASE_FULFILLMENT){
            this.showAutoCloserDate = false;
            this.showDelayedClosing = true;
            this.closingnoteslabel = 'Closing Notes';
            this.showCloseCaseForAdminFulfillment = true;
            if (this.recordTypeName == CASE_FULFILLMENT) {
                this.showProductVersionForFulFillment = true;
            }
        }
    }

    handleCancelDelayClosing() {
        this.resetFields(); //<T02>
        this.showModal = true;
        this.showLanguage = false;
        //this.showChangeLanguageButton = false;
        this.showProvideSolutionWithRCAFields = false;
        this.showProvideSolution = false;
        this.showRequestMoreInfo = false;
        this.showCloseCase = false;
        this.showAutoCloserDate = false;
        this.showDelayedClosing = false;
        this.showCancelDelayClosing = true;
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        this.showCloseCaseForAdminFulfillment = false;
        this.showProductVersionForFulFillment = false;
        //this.showLanguageLabel = false;
        this.modalHeader = 'Cancel Delayed Closing';
        this.showKBActionSection = false;
    }

    handleclosingnotes(event){
        this.closingnotesvalue = event.target.value;
        this.showClosingNotesRequired = this.closingnotesvalue && this.closingnotesvalue !== '' ? false : true;
    }

    //Vignesh D: 02-Nov-2021 #I2RT-4419-------START-------

    /* Getter: Show 'Send RCA' Next Best Action */
    get showSendRCA(){
        return this.currentStatus === CASE_STATUS_SOLUTION && 
            this.recordTypeName === CASE_OPERATIONS &&
            ((this.rcapending === 'Yes' || this.rcapending === 'No') && !this.boolIsRCASent);
    }

    /* Method: onclick handler 'Send RCA' */
    handleSendRCA(){
        this.resetFields(); //<T02>
        this.getProductValues();
        this.showModal = true;
        this.showsolclosefields = false;
        this.showClosingNotesField = true;
        this.closingnoteslabel = 'Closing Notes / Proposed Solution';
        console.log('closingnotes'+this.closingnoteslabel);
        this.showAcceptedSolutionField = false;
        this.showRejectNeedMoreInfoField = false;
        this.showNeedMoreTimeField = false;
        this.ShowKBActionSection = false;
        if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
            this.showProvideSolution = true;
            this.showRequestMoreInfo = false;
            this.showCloseCase = false;            
            this.showAutoCloserDate = false;
            this.showCancelDelayClosing = false;
            this.handleToggleKBActionSection(PROVIDE_SOLUTION);
        } else if (this.recordTypeName == CASE_ADMINISTRATIVE || this.recordTypeName == CASE_FULFILLMENT) {
            this.showProvideSolutionForAdminFulfillment = true;
            this.showRequestMoreInfoForAdminFulfillment = false;
            this.showCloseCaseForAdminFulfillment = false;
            if (this.recordTypeName == CASE_FULFILLMENT) {
                this.showProductVersionForFulFillment = true;
            }
        }
        this.isGetEmailBody = true;
        this.modalHeader = 'Send RCA';
        this.templateName = 'Provide Solution with RCA';
        this.actionType = 'Send RCA';
        this.renderCaseResolution(); 
    }

    //Vignesh D: 02-Nov-2021 #I2RT-4419-------END---------

    closeModal() {
        this.showModal = false;
        //this.selectedLanguage = this.defaultLanguage;
        this.setButtonVisibility();
        this.getProductValues();
    }

    submitCase(event) {
        console.log('submitcase');
        event.preventDefault();

        //[Vignesh D: product fields input required validation]
        var isRequiredFieldsFilled = true;
        [...this.template.querySelectorAll('lightning-combobox')].forEach(element => {
            log(`${element.name} --> ${element.value} --> ${element.checkValidity()}`);
            if (element.checkValidity()) {
                if (element.value === 'None' && element.disabled !== true) {
                    element.setCustomValidity('This field is required.');
                    isRequiredFieldsFilled = false;
                    element.reportValidity();
                }
                else {
                    element.setCustomValidity("");
                    element.reportValidity();
                }
            }
            else if (!element.checkValidity()) {
                element.setCustomValidity('This field is required.');
                isRequiredFieldsFilled = false;
                element.reportValidity();
            }
        });

        //[Vignesh D: Validate Auto Close Date (DateTime)]
        if (this.modalHeader == 'Delayed Closing') {
            [...this.template.querySelectorAll('lightning-input')].forEach(element => {
                log(`${element.name} ---> ${element.value} --> validity: ${element.checkValidity()}`);
                if (element.name === 'AutoCloseDate') {
                    if (element.checkValidity() && (this.selectedAutoCloseDate !== undefined && this.selectedAutoCloseDate != null)) {
                        let selectedDateTime = new Date(this.selectedAutoCloseDate);
                        let currentDateTime = new Date();
                        log(`selectedDateTime -> ${selectedDateTime}`);
                        log(`currentDateTime -> ${currentDateTime}`);
                        if (selectedDateTime < currentDateTime) {
                            element.setCustomValidity('Please select Date and Time in future.');
                            isRequiredFieldsFilled = false;
                            element.reportValidity();
                        }
                        else {
                            element.setCustomValidity("");
                            element.reportValidity();
                        }
                    } else if (!element.checkValidity() && (this.selectedAutoCloseDate === undefined || this.selectedAutoCloseDate == null)) {
                        element.setCustomValidity('This field is required.');
                        isRequiredFieldsFilled = false;
                        element.reportValidity();
                    }
                    else if (!element.checkValidity()) {
                        element.setCustomValidity('Please select Date and Time in future.');
                        isRequiredFieldsFilled = false;
                        element.reportValidity();
                    }
                }
            })
        }

        //[Vignesh D: Validate Expected Date (Date)]
        if(this.modalHeader == 'Need More Time'){
            [...this.template.querySelectorAll('lightning-input')].forEach(element => {
                log(`${element.name} ---> ${element.value} --> validity: ${element.checkValidity()}`);
                if(element.name === 'Expected_Date__c'){
                    if(element.reportValidity() && (this.selectedExpectedDate !== undefined && this.selectedExpectedDate != null)){
                        let selectedDate = new Date(this.selectedExpectedDate);
                        let currentDate = new Date();
                        log(`selectedDateTime -> ${selectedDate}`);
                        log(`currentDateTime -> ${currentDate}`);
                        if(selectedDate < currentDate){
                            element.setCustomValidity('Please select a date greater than or equal to today.');
                            isRequiredFieldsFilled = false;
                            element.reportValidity();
                        }
                        else{
                            element.setCustomValidity("");
                            element.reportValidity();
                        }
                    }else if(!element.checkValidity() && (this.selectedExpectedDate === undefined || this.selectedExpectedDate == null)){
                        element.setCustomValidity('This field is required.');
                        isRequiredFieldsFilled = false;
                        element.reportValidity();  
                    }
                    else if(!element.checkValidity()){
                        element.setCustomValidity('Please select a date greater than or equal to today.');
                        isRequiredFieldsFilled = false;
                        element.reportValidity();
                    }
                }
            })
        }
        if (this.modalHeader == 'Provide Solution' || this.modalHeader == 'Send RCA' || this.modalHeader == 'Close Case' || this.modalHeader == 'Delayed Closing') {
            if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
                // log('selectedResolutionType -->'+this.selectedResolutionType);
                // log('caseResolutionType -->'+this.caseResolutionType);
                // log('selectedResolutionCode -->'+this.selectedResolutionCode);
                // log('caseResolutionCode -->'+this.caseResolutionCode);
                if (this.selectedResolutionType == undefined || this.selectedResolutionType == null) {
                    this.showRequiredRT = true;
                    isRequiredFieldsFilled = false;
                }
                if (this.selectedResolutionCode == undefined || this.selectedResolutionCode == null) {
                    this.showRequiredRC = true;
                    isRequiredFieldsFilled = false;
                }
            }

            if (this.handleIsKBActionAvailable() == true) {
                if (this.handleKBActionValidation() == false) {
                    isRequiredFieldsFilled = false;
                }
            }
        }

        /*
        if(!isRequiredFieldsFilled){
            var buttonElement = this.template.querySelector('.save-btn');
            buttonElement.click();
        }*/

        if (isRequiredFieldsFilled) {
            var isError = false;
            var fields = event.detail.fields;
            fields.Next_Action__c = this.selectedNextAction === undefined || this.selectedNextAction === 'None' ? null : this.selectedNextAction;  //<T01>
            if (this.modalHeader == 'Request More Info') {
                if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
                    fields.Forecast_Product__c = this.selectedProduct;
                    fields.Version__c = this.selectedVersion === undefined || this.selectedVersion === 'None' ? null : this.selectedVersion;
                    fields.Component__c = this.selectedComponent === undefined || this.selectedComponent === 'None' ? null : this.selectedComponent;
                }
                if (this.recordTypeName == CASE_FULFILLMENT) {
                    fields.Forecast_Product__c = this.selectedProduct;
                    fields.Version__c = this.selectedVersion === undefined || this.selectedVersion === 'None' ? null : this.selectedVersion;
                }
            }
            else if (this.modalHeader == 'Provide Solution' || this.modalHeader == 'Send RCA' || this.modalHeader == 'Close Case' || this.modalHeader == 'Delayed Closing') { //<T04>
                if (this.recordTypeName == CASE_TECHNICAL || this.recordTypeName == CASE_LITE || this.recordTypeName == CASE_OPERATIONS) { //T05
                    fields.Forecast_Product__c = this.selectedProduct;
                    fields.Version__c = this.selectedVersion === undefined || this.selectedVersion === 'None' ? null : this.selectedVersion;
                    fields.Component__c = this.selectedComponent === undefined || this.selectedComponent === 'None' ? null : this.selectedComponent;
                    fields.Subcomponent__c = this.selectedSubComponent === undefined || this.selectedSubComponent === 'None' ? null : this.selectedSubComponent;
                    fields.Problem_Type__c = this.selectedProblemType === undefined || this.selectedProblemType === 'None' ? null : this.selectedProblemType;
                    fields.Root_cause__c = this.selectedResolutionType != undefined && this.selectedResolutionType != '' ? this.selectedResolutionType : this.caseResolutionType;
                    fields.Resolution_Code__c = this.selectedResolutionCode != undefined && this.selectedResolutionCode != '' ? this.selectedResolutionCode : this.caseResolutionCode;
                    
                }
                if (this.recordTypeName == CASE_FULFILLMENT) {
                    fields.Forecast_Product__c = this.selectedProduct;
                    fields.Version__c = this.selectedVersion === undefined || this.selectedVersion === 'None' ? null : this.selectedVersion;

                    if(this.modalHeader != 'Send RCA')
                    {
                        fields.Component__c = this.selectedComponent === undefined || this.selectedComponent === 'None' ? null : this.selectedComponent;
                        fields.Subcomponent__c = this.selectedSubComponent === undefined || this.selectedSubComponent === 'None' ? null : this.selectedSubComponent;
                    }
                }
            }

            //Start --> Sathish R --> Jira : I2RT-3105
            if (this.handleIsKBActionAvailable() == true)
            {
                fields.KB_Action__c = this.kbSelectedAction === undefined || this.kbSelectedAction === 'None' || this.kbSelectedAction === KB_NONE || this.kbSelectedAction === '' ? null : this.kbSelectedAction;//T14
                if (this.kbSelectedAction == KB_CREATE_NEW) {
                    fields.KB_Template__c = this.kbSelectedTemplate === undefined || this.kbSelectedTemplate === 'None' ? null : this.kbSelectedTemplate;
                    fields.KB_Keyword__c = this.kbCaseKeyword === undefined || this.kbCaseKeyword === 'None' ? null : this.kbCaseKeyword;
                }
            }
            //End --> Sathish R --> Jira : I2RT-3105

            log('showClosingNotesField: '+this.showClosingNotesField);
            if(this.showClosingNotesField){
                log('Closing Notes: '+this.closingnotesvalue);
                if(!this.isValidRichTextInput(this.closingnotesvalue)){ //<T02> //<T03>
                    isError = true;
                    this.showClosingNotesRequired = true;
                } else{
                    fields.Closing_Notes__c = this.closingnotesvalue;
                    this.showClosingNotesRequired = false;
                }
            }

            log('type= ' + JSON.stringify(fields));
            log('Problem Reason_For_Rejection__c= ' + fields.Reason_For_Rejection__c);
            log('currentStatus= ' + this.currentStatus + ' ' + isError);
            if (this.modalHeader == 'Decline Solution') {
                if (fields.Reason_For_Rejection__c == null || fields.Reason_For_Rejection__c == '') {
                    isError = true;
                    log('isError');
                } else {
                    this.caseComment = fields.Reason_For_Rejection__c;
                }
            } else if (this.modalHeader == 'Need More Time') {
                fields.Expected_Date__c = this.selectedExpectedDate;
                if (fields.Reason_For_This_Delay__c == null || fields.Reason_For_This_Delay__c == '') {
                    isError = true;
                    log('isError');
                } else {
                    this.caseComment = '<p>Expected Date: ' + fields.Expected_Date__c + '</p><br/><p>Reason For This Delay: ' + fields.Reason_For_This_Delay__c + '</p><br/>';
                }
            }

            //---------------------------------------<T03>------------------------------

            isError = isError || this.validateRichTextFields(fields);

            //---------------------------------------</T03>-----------------------------
            
            if (this.modalHeader === 'Cancel Delayed Closing') {
                isError = false;
            }

            //Vignesh D: 02-Nov-2021 #I2RT-4419-------START-------
            if(this.modalHeader == 'Send RCA' && fields.RCA_Pending_flag__c != 'No'){
                isError = true;
                this.showToastEvent('Error', INCORRECT_RCA_PENDING, 'error');
            }
            //Vignesh D: 02-Nov-2021 #I2RT-4419-------END---------

            log('isError= ' + isError);
            if (!isError) {
                if (/*fields.Automatic_closure_Date__c !== undefined*/ this.modalHeader == 'Delayed Closing' && this.selectedAutoCloseDate !== undefined) {
                    fields.Automatic_closure_Date__c = this.selectedAutoCloseDate;
                    this.template.querySelector('.updateCaseModal').submit(fields);
                    this.showSpinner = true;
                }
                else if (this.modalHeader == 'Cancel Delayed Closing') {
                    fields.Automatic_closure_Date__c = null;
                    fields.Is_Delay_Close__c = false
                    this.template.querySelector('.updateCaseModal').submit(fields);
                    this.showSpinner = true;
                }               
                else {
                    if(fields.RCA_Pending_flag__c == 'Yes' && this.showProvideSolution && this.modalHeader != 'Send RCA'){
                        this.templateName = 'Provide Solution without RCA';
                    } else if((this.showProvideSolution && fields.RCA_Pending_flag__c != undefined && (fields.RCA_Pending_flag__c == 'No' || fields.RCA_Pending_flag__c == 'Not Applicable')) || this.modalHeader == 'Send RCA') {
                        this.templateName = 'Provide Solution with RCA';
                    }
                    log('template name: '+this.templateName);                   
                    if(this.actionType == 'Decline Solution' || this.actionType == 'Need More Time'){
                        this.currentStatus = this.caseStatus;
                        fields[CASE_Status.fieldApiName] = this.caseStatus;
                    }
                    log('@Log->fields :' + JSON.stringify(fields));
                    if(this.modalHeader == 'Close Case'){
                        completemilestone({ caseId: this.recordId })
                        .then(result => {
                                console.log('updated milestones');
                                this.template.querySelector('.updateCaseModal').submit(fields);
                                this.showSpinner = true;
                            
                        })
                        .catch(error => {
                            log('Error: Unable to complete existing milestones' + JSON.stringify(error));
                            this.template.querySelector('.updateCaseModal').submit(fields);
                            this.showSpinner = true;
                            
                        });

                    } else {
                        log('beforesubmit');
                        this.template.querySelector('.updateCaseModal').submit(fields);
                        this.showSpinner = true;
                    }
                    
                }
            } else {
                
            }
            
        }
        
    }

    handleRTchange(event) {
        this.problemst = event.target.value;
        log('problemst' + this.problemst);
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

    onCaseCreation(event) {
        log('Id= ' + event.detail.id);

        if (this.handleIsKBActionAvailable() == true) {
            if (this.handleKBActionValidation() == true) {
                this.handleKBAction(event);
            }
        }
        /*
        const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'case updated Successfully!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        */
        log('showAutoCloserDate= ' + this.showAutoCloserDate);
        log('isGetEmailBody= ' + this.isGetEmailBody);
        log('caseComment= ' + this.caseComment);
        if (this.caseComment != '') {
            log('inside');
            createCaseCommentRecord({ caseId: event.detail.id, caseComment: this.caseComment, actionType: this.actionType })
                .then(result => {
                    if (result) {
                        notifyRecordUpdateAvailable([{
                            recordId: event.detail.id
                        }]);
                        log('Success!!!' + JSON.stringify(result));
                    }
                })
                .catch(error => {
                    log('Error: createCaseCommentRecord' + JSON.stringify(error));
                    this.showSpinner = false;
                    this.showToastEvent('Error', error.body.message, 'error');
                });
        }
        if (event.detail.id && /* !this.showAutoCloserDate && */ this.isGetEmailBody && this.modalHeader !== 'Cancel Delayed Closing') {
            //log('calling get emailbody- ' + this.selectedLanguage);
                getEmailBody({ caseId: event.detail.id, templateName: this.templateName/*, folderName: this.selectedLanguage*/ })
                    .then(result => {
                        if (result && result !== '') {
                            log('case comment draft ==> ' + result);
                            var caseObj = {};
                            caseObj.Id = null;
                            caseObj.Comment__c = result;
                            caseObj.Visibility__c = 'External';
                            caseObj.Type__c = this.actionType;
                            caseObj.Comment_Category__c = 'General Comments';
                            caseObj.Next_Action__c = this.selectedNextAction;       //<T01>
                            const payload = {
                                source: "Lightnign Web Component",
                                messageBody: caseObj,
                                messageText: 'createCollaboration',
                                caseId: this.recordId //T10
                            };
                            publish(this.context, passEmailTemplate, payload);
                            this.setButtonVisibility();
                            this.dispatchEvent(
                                new CustomEvent("close", {
                                    bubbles: true,
                                    composed: true
                                })
                            );
                            this.showSpinner = false;
                            //this.selectedLanguage = this.defaultLanguage;
                        }
                        else{
                            this.showToastEvent('Error', 'No email templates found!', 'error');
                        }
                    })
                    .catch(error => {
                        log('Error: getEmailBody' + JSON.stringify(error));
                        this.showSpinner = false;
                        this.showToastEvent('Error', error.body.message, 'error');
                    });
                
                
        } else {
            log('Inside else');
            this.dispatchEvent(
                new CustomEvent("close", {
                    bubbles: true,
                    composed: true
                })
            );
            this.showSpinner = false;
        }       
    }

    handleError(event) {
        this.showSpinner = false;
        log('Error: ' + JSON.stringify(event.detail));
        this.showToastEvent('Error', event.detail.message, 'error');
    }

    resetFields(){
        this.showsolclosefields = true;
        this.showClosingNotesField = false;
        this.closingnoteslabel = 'Closing Notes';
        this.caseComment = '';
    }

    //---------------------------------------<T03>------------------------------

    /*
    Method Name : validateRichTextFields
    Description : This method validates all rich text fields.
    Parameters	 : Object, called from submitCase, objFields.
    Return Type : Boolean
    */
    validateRichTextFields(objFields){
        let isNotValid = false;

        if(typeof objFields === 'object'){
            Object.keys(objFields).forEach(field => {
                if(this.objRichTextFields.includes(field) && !this.isValidRichTextInput(objFields[field])){
                    isNotValid = true;
                }
            });
        }

        return isNotValid;
    }

    /*
    Method Name : isValidRichTextInput
    Description : This method validates rich text input.
    Parameters	 : Object, called from validateRichTextFields, strInput.
    Return Type : Boolean
    */
    isValidRichTextInput(strInput){
        return strInput !== null && strInput !== undefined && strInput !== '' && strInput?.replace(/<[^>]+>/g, '')?.trim().length > 0;
    }

    //---------------------------------------</T03>-----------------------------

    //[Vignesh D: Added Product dependency logic from CaseDependentPicklist LWC]
    connectedCallback() {
        //this.getProductValues();
    }
    //track existing product fields on case
    @track caseProduct = [];
    @track caseVersion = [];
    @track caseComponent = [];
    @track caseSubComponent = [];
    @track caseProblemType = [];

    //track user selection of product fields
    @track selectedProduct;
    @track selectedVersion;
    @track selectedComponent;
    @track selectedSubComponent;
    @track selectedProblemType;
    @track selectedNextAction;      //<T01>

    //track map values
    @track componentsMap;
    @track fulfillmentComponentsMap;        //<T13>
    @track versionsMap;
    @track problemsMap;
    @track allProducts;

    @track disabledComponents;
    @track disabledSubComponents;
    @track disabledVersions;
    @track disabledProblems;
    @track showNoneVersion;
    @track showNoneComponent;

    @track showSpinner = false;

    @track caseRecordTypeId;
    @track caseDeliveryMethod;
    @track caseRecordTypeName;

    @track selectedAutoCloseDate;

    getProductValues() {
        let recId = this.recordId;
        getProductAttributes({ caseId: recId })
            .then(result => {
                log('Product Map --> ' + JSON.stringify(result));
                this.componentsMap = result.componentsMap;
                this.fulfillmentComponentsMap = result.fulfillmentComponentsMap;        //<T13>
                this.versionsMap = result.versionsMap;
                this.problemsMap = result.problemsMap;
                this.allProducts = result.allProducts;
                this.selectedProduct = result.caseRecDetails.Forecast_Product__c === undefined ? 'None' : result.caseRecDetails.Forecast_Product__c;
                
                this.selectedComponent = result.caseRecDetails.Component__c === undefined ? 'None' : result.caseRecDetails.Component__c;
                this.selectedSubComponent = result.caseRecDetails.Subcomponent__c === undefined ? 'None' : result.caseRecDetails.Subcomponent__c;
                this.selectedProblemType = result.caseRecDetails.Problem_Type__c === undefined ? 'None' : result.caseRecDetails.Problem_Type__c;
                this.selectedVersion = result.caseRecDetails.Version__c === undefined ? 'None' : result.caseRecDetails.Version__c;

                log(`Case Product: ${this.selectedProduct}`)
                log(`Case Component: ${this.selectedComponent}`);
                log(`Case SubComponent: ${this.selectedSubComponent}`);
                log(`Case ProblemType: ${this.selectedProblemType}`);
                log(`Case Version: ${this.selectedVersion}`);

                this.rerenderDetails();
            })
            .catch(error => {
                log('Error: ' + JSON.stringify(error));
            })
    }

    rerenderDetails() {
        log('inside rerenderDetails');

        var foundVersion = false;
        var foundProblemType = false;

        this.caseProduct = [];
        this.caseComponent = [];
        this.caseSubComponent = [];
        this.caseProblemType = [];
        this.caseVersion = [];
        
        this.disabledComponents = true;
        this.disabledSubComponents = true;
        this.disabledVersions = true;
        this.disabledProblems = true;
        this.showNoneVersion = false;
        this.showNoneComponent = false;

        this.caseComponent.push({ label: 'None', value: 'None' });
        this.caseSubComponent.push({ label: 'None', value: 'None' });
        this.caseProblemType.push({ label: 'None', value: 'None' });
        this.caseVersion.push({ label: 'None', value: 'None' });

        log('Rerender --> ' + JSON.stringify(this.allProducts));
        if(this.isCaseLite){
            this.caseProduct.push({ label: this.selectedProduct, value: this.selectedProduct });
        }else{
            this.allProducts.forEach(prodName => {
                this.caseProduct.push({ label: prodName, value: prodName });
    
                if (this.selectedProduct === prodName) {
                    //let totalComponentsMap = this.componentsMap;
    
                    //<T13>
                    if(this.caseRecordTypeName != CASE_FULFILLMENT)
                    {
                        this.bindComponentsData(this.componentsMap[prodName]);
                    }
                    //</T13>
    
                    /** VersionMap Settings  **/
                    let totalVersionMap = this.versionsMap;
                    log('totalVersionMap new >>> ' + JSON.stringify(totalVersionMap));
                    if (totalVersionMap[prodName] !== null && totalVersionMap[prodName].indexOf('None') > -1) {
                        this.showNoneVersion = true;
                    }
                    if (totalVersionMap[prodName] !== null) {
                        this.disabledVersions = false;
                        totalVersionMap[prodName].forEach(version => {
                            if (this.selectedVersion === version) {
                                foundVersion = true;
                            }
                            if (version !== 'None') {
                                this.caseVersion.push({ label: version, value: version });
                            }
                        });
                    }
    
                    /** ProblemType Settings  **/
                    let totalProblemMap = this.problemsMap;
                    log('totalProblemMap value >>> ' + JSON.stringify(totalProblemMap));
    
                    var key = (this.caseRecordTypeName == CASE_OPERATIONS || this.caseRecordTypeName == CASE_LITE) ? this.caseRecordTypeName : //T05
                        (this.caseRecordTypeName == CASE_TECHNICAL && this.caseDeliveryMethod != null) ? this.caseRecordTypeName + this.caseDeliveryMethod.replace(/\s+/g, '') : '';
                            
                    log('Key : ' + key);
                    log('totalProblemMap : ' + totalProblemMap);
                    log('totalProblemMap.get(key) : ' + totalProblemMap[key]);
    
                    if (totalProblemMap != null && totalProblemMap[key] != null) {
                        this.disabledProblems = false;
                        totalProblemMap[key].forEach(problem => {
                            if (this.selectedProblemType === problem) {
                                foundProblemType = true;
                            }
                            this.caseProblemType.push({ label: problem, value: problem });
                        });
                    }
                }
            });
        }

        //<T13>
        if(this.caseRecordTypeName == CASE_FULFILLMENT)
        {
            this.bindComponentsData(this.fulfillmentComponentsMap[this.caseDeliveryMethod]);
        }
        //</T13>
        
        if (!foundVersion && this.recordTypeName != CASE_LITE) { //<T08>
            this.selectedVersion = 'None';
        }
        if (!foundProblemType) {
            this.selectedProblemType = 'None';
        }
        
        /** To remove the duplicate Options from the Options List */
        this.caseProduct = this.caseProduct.reduce((unique, o) => {
            if (!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
                unique.push(o);
            }
            return unique;
        }, []);

        this.caseComponent = this.caseComponent.reduce((unique, o) => {
            if (!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
                unique.push(o);
            }
            return unique;
        }, []);

        this.caseSubComponent = this.caseSubComponent.reduce((unique, o) => {
            if (!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
                unique.push(o);
            }
            return unique;
        }, []);

        this.caseProblemType = this.caseProblemType.reduce((unique, o) => {
            if (!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
                unique.push(o);
            }
            return unique;
        }, []);

        this.caseVersion = this.caseVersion.reduce((unique, o) => {
            if (!unique.some(obj => obj.label === o.label && obj.value === o.value)) {
                unique.push(o);
            }
            return unique;
        }, []);

        log('this.caseProduct' + JSON.stringify(this.caseProduct));
        log('this.caseComponent' + JSON.stringify(this.caseComponent));
        log('this.caseSubComponent' + JSON.stringify(this.caseSubComponent));
        log('this.caseProblemType' + JSON.stringify(this.caseProblemType));
        log('this.caseVersion' + JSON.stringify(this.caseVersion));

        log('selectedProduct ==> ' + this.selectedProduct);
        log('selectedComponent ==> ' + this.selectedComponent);
        log('selectedSubComponent ==> ' + this.selectedSubComponent);
        log('selectedselectedProblemTypeProduct ==> ' + this.selectedProblemType);
        log('selectedVersion ==> ' + this.selectedVersion);
    }

    //<T13>
    bindComponentsData(componentsDatasourceMap)
    {
        let foundComponent = false;
        let foundSubComponent = false;

        if (componentsDatasourceMap!=null && !componentsDatasourceMap.isEmpty) {

            let sortedCompList;
            let sortedSubCompList;

            var compList = [];
            sortedCompList = [];
            sortedSubCompList = [];

            for (var key in componentsDatasourceMap) {
                compList.push(key);
            }

            compList.sort();
            sortedCompList = compList;

            sortedCompList.forEach(compName => {
                foundComponent = foundComponent ? true : false;

                if (compName !== 'None' || componentsDatasourceMap.has('None')) {
                    if (compName === 'None') {
                        this.showNoneComponent = true;
                    }
                    if (compName !== 'None') {
                        this.caseComponent.push({ label: compName, value: compName });
                    }
                    this.disabledComponents = false;

                    if (this.selectedComponent === compName && componentsDatasourceMap[compName] !== null) {
                        foundComponent = true;
                        var subCompList = [];

                        componentsDatasourceMap[compName].forEach(c => {
                            subCompList.push(c);
                        });
                        
                        subCompList.sort();
                        sortedSubCompList = subCompList;

                        sortedSubCompList.forEach(subCompName => {
                            if (this.selectedSubComponent === subCompName) {
                                foundSubComponent = true;
                            }
                            this.caseSubComponent.push({ label: subCompName, value: subCompName });
                        });
                        this.disabledSubComponents = false;
                        if (this.selectedComponent === compName && 
                            (componentsDatasourceMap[compName] === null 
                                ||(this.caseRecordTypeName == CASE_FULFILLMENT && 
                                    componentsDatasourceMap[compName].length == 1 && 
                                    componentsDatasourceMap[compName][0] == 'None'))) 
                        {
                            foundComponent = true;
                            this.disabledSubComponents = true;
                        }
                    }
                }
                else {
                    this.disabledComponents = true;
                    this.disabledSubComponents = true;
                }
            });
        }

        if (!foundComponent) {
            this.selectedComponent = 'None';
        }
        if (!foundSubComponent) {
            this.selectedSubComponent = 'None';
        }
    }
    //</T13>

    handleChangeSubComponent(event) {
        this.selectedSubComponent = event.target.value;
        if (event.target.value !== 'None') {
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
        this.rerenderDetails();
    }

    handleChangeComponent(event) {
        this.selectedComponent = event.target.value;
        log('Onchange of Component : selectedSubComponent >>>' + this.selectedSubComponent);
        if (event.target.value !== 'None') {
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
        this.rerenderDetails();
    }

    handleChangeProblemType(event) {
        this.selectedProblemType = event.target.value;
        if (event.target.value !== 'None' && event.target.disabled !== true) {
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
        this.rerenderDetails();
    }

    handleChangeVersion(event) {
        this.selectedVersion = event.target.value;
        if (event.target.value !== 'None') {
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
        this.rerenderDetails();
    }

    //<T01>
    handleChangeNextAction(event) {
        this.selectedNextAction = event.target.value;
        // if (event.target.value !== 'None') {
        //     event.target.setCustomValidity("");
        //     event.target.reportValidity();
        // }
        // this.rerenderDetails();
    }
    //</T01>

    handleChangeProduct(event) {
        this.selectedProduct = event.target.value;
        this.selectedComponent = 'None';
        this.selectedSubComponent = 'None';
        this.selectedProblemType = 'None';
        this.selectedVersion = 'None';
        this.rerenderDetails();
    }

    handleAutoCloseDate(event) {
        log('Auto Close Date --> ' + event.detail.value);
        this.selectedAutoCloseDate = event.detail.value;
        let selectedDateTime = new Date(this.selectedAutoCloseDate);
        let currentDateTime = new Date();
        log(`selectedDateTime -> ${selectedDateTime}`);
        log(`currentDateTime -> ${currentDateTime}`);
        if (selectedDateTime < currentDateTime) {
            event.target.setCustomValidity('Please select Date and Time in future.');
            event.target.reportValidity();
        }
        else {
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
    }

    //I2RT-2555: Case Resolution Type and Resolution Code
    @track caseResolutionType;
    @track caseResolutionCode;
    @track caseResolutionTypes = [];
    @track caseResolutionCodes = [];
    @track selectedResolutionType;
    @track selectedResolutionCode;
    resolutionCodes;
    resolutionMap;
    @track showResolutionCode = false;
    @track showRequiredRT = false;
    @track showRequiredRC = false;

    renderCaseResolution() {
        getCaseResolution()
            .then(result => {
                log('case Resolution --> ' + JSON.stringify(result));
                log('caseResolutionType: ' + this.caseResolutionType);
                log('caseResolutionCode: ' + this.caseResolutionCode);
                //reset fields
                this.caseResolutionTypes = [];
                this.caseResolutionCodes = [];
                //this.selectedResolutionType = undefined;
                //this.selectedResolutionCode = undefined;
                this.resolutionCodes = undefined;
                this.resolutionMap = undefined;
                this.showResolutionCode = false;
                this.showRequiredRT = false;
                this.showRequiredRC = false;

                for (const [key, value] of Object.entries(result.resolutionTypes)) {
                    if (this.caseResolutionType === key) {
                        this.caseResolutionTypes.push({ label: key, value: key, helpText: value, checked: true });
                    }
                    else {
                        this.caseResolutionTypes.push({ label: key, value: key, helpText: value, checked: false });
                    }
                }
                this.resolutionCodes = result.resolutionCodes;
                this.resolutionMap = result.resolutionMap;
                if (this.caseResolutionType != undefined && this.caseResolutionType != null) {
                    this.showResolutionCode = true;
                    if (this.resolutionMap[this.caseResolutionType] != undefined) {
                        this.resolutionMap[this.caseResolutionType].forEach(RC => {
                            if (this.resolutionCodes[RC] != undefined) {
                                if (this.caseResolutionCode != undefined && this.caseResolutionCode != null && this.caseResolutionCode === RC) {
                                    this.caseResolutionCodes.push({ label: RC, value: RC, helpText: this.resolutionCodes[RC], checked: true });
                                }
                                else {
                                    this.caseResolutionCodes.push({ label: RC, value: RC, helpText: this.resolutionCodes[RC], checked: false });
                                }
                            }
                        });
                    }
                }
                log('this.caseResolutionTypes --> ' + JSON.stringify(this.caseResolutionTypes));
                log('this.caseResolutionCodes --> ' + JSON.stringify(this.caseResolutionCodes));
            })
            .catch(error => {
                log('case Resolution error --> ' + JSON.stringify(error));
            })
    }

    resolutionTypeChange(event) {
        this.selectedResolutionType = event.target.value;
        this.selectedResolutionCode = undefined;
        this.showRequiredRT = false;
        log('resolution type : ' + this.selectedResolutionType);
        this.caseResolutionTypes.forEach(RT => {
            if (this.selectedResolutionType === RT.label) {
                RT.checked = true;
            }
            else {
                RT.checked = false;
            }
            log('this.caseResolutionTypes --> ' + JSON.stringify(this.caseResolutionTypes));
        });
        this.caseResolutionCodes = [];
        if (this.resolutionMap[this.selectedResolutionType] != undefined) {
            this.resolutionMap[this.selectedResolutionType].forEach(RT => {
                if (this.resolutionCodes[RT] != undefined) {
                    this.caseResolutionCodes.push({ label: RT, value: RT, helpText: this.resolutionCodes[RT] });
                }
            });
            log('caseResolutionCodes' + JSON.stringify(this.caseResolutionCodes));
        }
        this.showResolutionCode = true;                
        this.handleToggleNAFromKBActionSource();//t12     
    }

    resolutionCodeChange(event) {
        this.selectedResolutionCode = event.target.value;
        this.showRequiredRC = false;
        log('resolution code : ' + this.selectedResolutionCode);
        this.caseResolutionCodes.forEach(RC => {
            if (this.selectedResolutionCode === RC.label) {
                RC.checked = true;
            }
            else {
                RC.checked = false;
            }
        });
        log('this.caseResolutionCodes --> ' + JSON.stringify(this.caseResolutionCodes));
        this.handleToggleNAFromKBActionSource();//T12        
    }

    setExpectedDate(event){
        //console.log(`expected date: ${event.detail.value}`);
        //this.selectedExpectedDate = event.detail.value;
        log('Expected Date: '+event.detail.value);
        this.selectedExpectedDate = event.detail.value;
        let selectedDate = new Date(this.selectedExpectedDate);
        let currentDate = new Date();
        log(`selectedDate -> ${selectedDate}`);
        log(`currentDate -> ${currentDate}`);
        if(selectedDate < currentDate){
            event.target.setCustomValidity('Please select a date greater than or equal to today.');
            event.target.reportValidity();
        }
        else{
            event.target.setCustomValidity("");
            event.target.reportValidity();
        }
    }
    get hideSolutionDelayClose(){
        return this.currentStatus !== CASE_STATUS_SOLUTION ? true: false;
    }
    get hideSolutionDelayClose() {
        return this.currentStatus !== CASE_STATUS_SOLUTION ? true : false;
    }

    //Start --> Sathish R --> Jira : I2RT-3105
    showUpdateKBSpace(event) {
        this.showUpdateKBSectionSpinner = true;
        this.showSearchTokenSuccess = false;
        this.showSearchTokenError = false;         
        this.showSearchSuccess = false;
        this.showSearchNoResult = false;
        this.kbSearchData = [];
        this.kbSearchData = [...this.kbSearchData];        
        this.getSearchTokenForLinking();
    }

    getSearchTokenForLinking() {
        try {
            log('this.getSearchTokenForLinking Called');
            getSearchToken({ strCalledFrom: this.searchTokenFor })
                .then((result) => {
                    //log('this.getSearchToken --> '+JSON.stringify(result));                 
                    this.searchtoken = JSON.parse(result).APISearchToken;
                    this.searchhubname = JSON.parse(result).APISearchHub;
                    this.searchorgname = JSON.parse(result).SearchOrgName;
                    this.hideSearchSpaceSpinner();
                    this.showSearchTokenSuccess = true;                  
                })
                .catch((error) => {
                    log('case SearchTokenForLinking error --> ' + JSON.stringify(error));
                    this.hideSearchSpaceSpinner();
                    this.showSearchTokenError = true;
                });
        } catch (error) {
            log('case SearchTokenForLinking error --> ' + JSON.stringify(error));
            this.hideSearchSpaceSpinner();
            this.showSearchTokenError = true;
        }
    
    }

    hideUpdateKBSpace() {
        this.showUpdateKBSectionSpinner = false;
        this.showSearchTokenError = false;
        this.showSearchTokenSuccess = false;
        this.showSearchSuccess = false;
        this.showSearchNoResult = false;
        this.kbSearchData = [];
        this.kbSearchData = [...this.kbSearchData];      
    }

    hideSearchSpaceSpinner() {
        this.showUpdateKBSectionSpinner = false;
        this.showSearchTokenError = false;
        this.showSearchTokenSuccess = false;
    }


    hideSearchSpinner() {
        this.showKBSpaceSearchSpinner = false;                
    }

    showSearchSpinner() {
        this.showSearchSuccess = false;
        this.showSearchNoResult = false;      
        this.showKBSpaceSearchSpinner = true;        
    }
    
    handleSearchClick(event) {
        try {
            log('this.handleSearchClick Called');
            this.showSearchSpinner();
            getSimilarArticle({ strSearchToken: this.searchtoken, strSearchKeyword: this.searchTerm, strArticleNumber: '' })
                .then((result) => {
                    log('case SimilarArticle sucess --> ' + JSON.stringify(result));

                    if (JSON.parse(result).APIResponseStatus == 'OK') {
                        this.hideSearchSpinner();
                        var varSearchDatas = JSON.parse(result).searchKBDataList;
                        //Start --> Sathish R --> Jira : I2RT-7308 - T06
                        for (var k = 0; k < varSearchDatas.length; k++) {
                            var lclLangCode = varSearchDatas[k].athenalanguage;
                            var varLangName = GetKBLanguageFieldValue(lclLangCode, this);
                            varSearchDatas[k].athenalanguage = varLangName;
                            
                        }
                        //End --> Sathish R --> Jira : I2RT-7308 - T06
                        this.kbSearchData = [...varSearchDatas];
                        if (varSearchDatas.length > 0) {
                            this.showSearchSuccess = true;
                            this.showSearchNoResult = false;                            
                        }
                        else {
                            this.showSearchSuccess = false;
                            this.showSearchNoResult = true;                            
                        }
                    }
                    if (JSON.parse(result).APIResponseStatus == 'ERROR')
                        log('case SimilarArticle error --> ' + JSON.stringify(result));
                                                                    
                })
                .catch((error) => {
                    log('case SimilarArticle error --> ' + JSON.stringify(error));
                });
            
        } catch (error) {
            log('case SimilarArticle error --> ' + JSON.stringify(error));
        }
    }

    handleCloseKBSpace() {
        try {
            this.hideUpdateKBSpace();
        } catch (error) {
            log('case handleCloseKBSpace error --> ' + JSON.stringify(error));
        }
    }

    handleChangeSearchTerm(event) {
        try {
            this.searchTerm = event.target.value;
        } catch (error) {
            log('case handleCloseKBSpace error --> ' + JSON.stringify(error));
        }
    }

    handleKBRowActionAdd(event) {
        try {
            log('this.handleRowActionKBSpace Called');
            const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'add':
                    var isPresent = false;
                    for (var i = 0; i < this.kbSelectedData.length; i++) {
                        if (this.kbSelectedData[i].sfid == row.sfid) {
                            isPresent = true;
                            break;
                        }
                    }
                    if (!isPresent)
                        this.kbSelectedData = [...this.kbSelectedData, row];
                    break;
                case 'view':
                    var varUrlToOpen = this.KBRECORDURL.replace('HOSTNAME',document.location.host).replace('RECORDID',row.sfid);
                    window.open(varUrlToOpen, '_blank');      
                    break;
            }
            if (this.kbSelectedData.length > 0) {
                this.showSelectedKBInKBSpace = true;
                this.showErrorInKb = false;
            }
            else {
                this.showSelectedKBInKBSpace = false;
                this.showErrorInKb = true;
            }
        } catch (error) {
            log('case handleRowActionKBSpace error --> ' + JSON.stringify(error));
        }
    }

    handleKBRowActionDeleteUpdate(event) {
        try {
            log('this.handleKBRowActionDeleteUpdate Called');
            const action = event.detail.action;
            const row = event.detail.row;         
            switch (action.name) {
                case 'delete':
                    const rows = this.kbSelectedData;
                    const rowIndex = rows.indexOf(row);    
                    rows.splice(rowIndex, 1);
                    this.kbSelectedData = [...rows];
                    break;
                case 'update':
                    var varUrlToOpen = this.KBRECORDURL.replace('HOSTNAME',document.location.host).replace('RECORDID',row.sfid);
                    window.open(varUrlToOpen, '_blank');      
                    break;
                case 'view':
                    var varUrlToOpen = this.KBRECORDURL.replace('HOSTNAME',document.location.host).replace('RECORDID',row.sfid);
                    window.open(varUrlToOpen, '_blank');      
                    break;
            }
            if (this.kbSelectedData.length > 0) {
                this.showSelectedKBInKBSpace = true;
            }
            else {
                this.showSelectedKBInKBSpace = false;
            }
        } catch (error) {
            log('case handleKBRowActionDeleteUpdate error --> ' + JSON.stringify(error));
        }
    }

    handleRowActionDelete(event) {
        try {
            log('this.handleRowActionDelete Called');
            const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'delete':
                    const rows = this.kbSelectedData;
                    const rowIndex = rows.indexOf(row);
                    rows.splice(rowIndex, 1);
                    this.kbSelectedData = [...rows];
                    break;
                case 'view':
                    var varUrlToOpen = this.KBRECORDURL.replace('HOSTNAME',document.location.host).replace('RECORDID',row.sfid);
                    window.open(varUrlToOpen, '_blank');      
                    break;
            }
            if (this.kbSelectedData.length > 0) {
                this.showAssociatesKB = true;
                this.showErrorInKb = false;
            }
            else {
                this.showAssociatesKB = false;
                this.showErrorInKb = true;
            }
        } catch (error) {
            log('case handleRowActionDelete error --> ' + JSON.stringify(error));
        }
    }

    handleAddKBSpace() {
        try {
            this.kbSelectedData = [...this.kbSelectedData];
            this.hideUpdateKBSpace();
        } catch (error) {
            log('case handleCloseKBSpaceClick error --> ' + JSON.stringify(error));
        }
    }

    handleClearKBSpace() {
        try {
            this.kbSearchData = [...this.kbSearchData];
            this.showSearchSuccess = false;
            //this.template.querySelector('#kbsearchinput').value = '';
        } catch (error) {
            log('case handleCloseKBSpaceClick error --> ' + JSON.stringify(error));
        }
    }

    handleKBActionValidation() {
        var varIsKBActionValid = false;        
        try {
            //Jira : I2RT-4955
            if ((this.handleKBActionValueValid(this.kbSelectedAction) == true)) {
                if (this.kbSelectedAction == KB_CREATE_NEW) {
                    [...this.template.querySelectorAll('lightning-input')].forEach(element => {
                        if (element.name === 'KBKeyword') {
                            if (this.kbCaseKeyword == undefined || this.kbCaseKeyword == null || this.kbCaseKeyword == '') {
                                element.reportValidity();
                            }
                        }
                    });
                    [...this.template.querySelectorAll('lightning-combobox')].forEach(element => {
                        if (element.name === 'KBTemplate') {
                            if (this.kbSelectedTemplate == undefined || this.kbSelectedTemplate == null || this.kbSelectedTemplate == '') {
                                element.reportValidity();
                            }
                            else {
                                varIsKBActionValid = true;                        
                            }
                        }
                    });
                }
                else if (this.kbSelectedAction === KB_USE_EXISTING || this.kbSelectedAction === KB_UPDATE_EXISTING) {
                    if (this.kbSelectedData.length > 0) {
                        for (var i = 0; i < this.kbSelectedData.length; i++) {
                            if (i == 0)
                                this.kbSelectedId = this.kbSelectedData[i].sfid;
                            else
                                this.kbSelectedId = this.kbSelectedId + ';' + this.kbSelectedData[i].sfid;
                        }
                        varIsKBActionValid = true;
                    }                   
                }
                //Jira : I2RT-4955 - Start
                else if (this.kbSelectedAction == NOT_APPLICABLE) {
                    varIsKBActionValid = true;    
                }
                //Jira : I2RT-4955 - End
            }
            else
            {
                varIsKBActionValid = true;
            }
            
        } catch (error) {
            log('case handleKBActionValidation error --> ' + JSON.stringify(error));
        }
        if (varIsKBActionValid == false) {
            this.showErrorInKb = true;
        }
        else
        {
            this.showErrorInKb = false;
        }
        log('handleKBActionValidation completed Status : ' + varIsKBActionValid.toString());
        return varIsKBActionValid;
    }

    handleKBAction(event) {
        try {
            log('handleKBAction Before');
        //Jira : I2RT-4955 - End
            if ((this.handleKBActionValueValid(this.kbSelectedAction) == true)) {
                log('submitKB Before Status : true');
                this.submitKB();
            }
        } catch (error) {
            log('case handleKBAction error --> ' + JSON.stringify(error));
        }
    }

    handleKBActionValueValid(parKBAction)
    {
        var varIsValid = false;
        try {            
        //Jira : I2RT-4955 
            if ((parKBAction != undefined) && (parKBAction != null) && (parKBAction != '') && (parKBAction != KB_NONE))
            {
                varIsValid = true;
            }
            else
            {
                varIsValid = false;
            }
            
        } catch (error) {
            log('case handleKBActionValueValid error --> ' + JSON.stringify(error));
        }
        return varIsValid;
    }

    submitKB() {
        try {
            // if (this.kbSelectedAction == KB_CREATE_NEW) {
                
            // }
            // else if (this.kbSelectedAction === KB_USE_EXISTING || this.kbSelectedAction === KB_UPDATE_EXISTING) {
            //     for (var i = 0; i < this.kbSelectedData.length; i++) {
            //         if (i == 0)
            //             this.kbSelectedId = this.kbSelectedData[i].sfid;
            //         else
            //             this.kbSelectedId = this.kbSelectedId +';' + this.kbSelectedData[i].sfid;
            //     }
            // }

            processKnowledgeBaseArticle({ strRecordId: this.recordId, strKeywords: this.kbCaseKeyword, strArticleType: this.kbSelectedTemplate, strActionType: this.kbSelectedAction, strArticleId: this.kbSelectedId }).then(result => {
                this.showSpinner = false;
                this.showModal = false;
                if (result !== null) {
                    log('this.processKnowledgeBaseArticle --> ' + JSON.stringify(result));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'KB Action Successfully Saved',
                            variant: 'success',
                        }),
                    );
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'KB Action Successfully Saved',
                            variant: 'success',
                        }),
                    );
                }
            })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showModal = false;
                    console.log('Inside catch submit' + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed',
                            variant: 'error',
                        }),
                    );
                });
        } catch (error) {
            this.showSpinner = false;
            this.showModal = false;
            log('case submitKB error --> ' + JSON.stringify(error));
        }
    }

    handleKeywordChange(event) {
        try {
            this.kbCaseKeyword = event.target.value;
        } catch (error) {
            log('case handleKeywordChange error --> ' + JSON.stringify(error));
        }
    }

    handleKBSucess(event) {
        // log('this.handleKBSucess --> '+JSON.stringify(result));   
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Successfully Saved',
                variant: 'success',
            }),
        );
    }

    handleKBTemplateChange(event) {
        try {
            this.kbSelectedTemplate = event.target.value;
            if (event.target.value !== 'None' && event.target.disabled !== true) {
                event.target.setCustomValidity("");
                event.target.reportValidity();
            }
        } catch (error) {
            log('case handleKBTemplateChange error --> ' + JSON.stringify(error));
        }
    }

    //To Make KB Action Readonly
    handleInitKBAction(parModalHeader) {
        //this.kbCaseKeyword = data.fields.Is_Delay_Close__c.value;                            
        try {
            
            if (this.handleKBActionValueValid(this.kbSelectedAction) == true) {
                var selectedValue = this.kbSelectedAction;
                if (selectedValue === 'NA') {
                    this.showNewKbSection = false;
                    this.showUpdateKbSection = false;
                    this.hideUpdateKBSpace();
                } else if (selectedValue === 'Create New') {
                    this.showNewKbSection = true;
                    this.showUpdateKbSection = false;
                    this.hideUpdateKBSpace();
                    this.handleKBActionChangeDataTable();
                    this.setKBActionForDelete();
                } else if (selectedValue === 'Use Existing' || selectedValue === 'Updated Existing') {
                    this.showNewKbSection = false;
                    this.showUpdateKbSection = true;
                    this.showUpdateKBSpace();
                    this.handleKBActionChangeDataTable();
                    this.setKBActionForDeleteUpdate();
                }
                this.getExistingKBLink();
            }
            else {
                this.showNewKbSection = false;
                this.showUpdateKbSection = false;
                this.hideUpdateKBSpace();
                this.getExistingKBLink();
            }
            
        } catch (error) {
            log('case handleInitKBAction error --> ' + JSON.stringify(error));
        }
        
    }

    getExistingKBLink()
    {
        getCaseToKB({ strRecordId: this.recordId }).then((result) => {
            try {
                if (result !== null) {
                    log('this.getCaseToKB --> ' + JSON.stringify(result));

                    if (JSON.parse(result).ResponseStatus == 'OK') {
                        var varSelectedDatas = JSON.parse(result).searchKBDataList;
                        //Start --> Sathish R --> Jira : I2RT-7308 - T06
                        for (var j = 0; j < varSelectedDatas.length; j++) {
                            var lclLangCode = varSelectedDatas[j].athenalanguage;
                            var varLangName = GetKBLanguageFieldValue(lclLangCode, this);
                            varSelectedDatas[j].athenalanguage = varLangName;
                            
                        }
                        //End --> Sathish R --> Jira : I2RT-7308 - T06
                        this.kbSelectedData = [...varSelectedDatas];
                        this.kbExistingSelectedData = varSelectedDatas;
                        log('this.getCaseToKB --> kbSelectedData : ' + JSON.stringify(this.kbSelectedData));
                        if (varSelectedDatas.length > 0) {
                            this.showSelectedKBInKBSpace = true;                            
                        }
                        else {
                            this.showSelectedKBInKBSpace = false;                            
                        }
                    }
                    if (JSON.parse(result).APIResponseStatus == 'ERROR')
                    log('case getCaseToKB error --> ' + JSON.stringify(result));
                
                }
                else {
                
                }
            } catch (error) {
                log('case getCaseToKB error --> ' + JSON.stringify(error));
            }
        }).catch((error) => {
            console.log('handleInitKBAction' + JSON.stringify(error));
        });
    }

    disableKBTable()
    {
        try {
            this.kbcolumnswithdeleteupdate = [
                KBVIEWACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
            this.kbcolumnswithadd = [
                KBVIEWACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
            
        } catch (error) {
            log('case disableKBTable error --> ' + JSON.stringify(error));
        }
    }

    setKBActionForDeleteUpdate() {
        try {
            this.kbcolumnswithadd = [
                KBADDACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
        
            this.kbcolumnswithdeleteupdate = [
                KBDELETEUPDATEACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
        } catch (error) {
            log('case setKBActionForDeleteUpdate error --> ' + JSON.stringify(error));
        }
    }

    setKBActionForDelete() {
        try {
            this.kbcolumnswithadd = [
                KBADDACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
        
            this.kbcolumnswithdeleteupdate = [
                KBDELETEUPDATEACTION,
                { label: 'Title', fieldName: 'title', type: 'string' },
                { label: 'ArticleNumber', fieldName: 'sfarticlenumber', type: 'string' },
                { label: 'Validation status', fieldName: 'infavalidationstatus', type: 'string' },//T06
                { label: 'Article Record Type', fieldName: 'infarecordtypename', type: 'string' },//T14
                { label: 'Language', fieldName: 'athenalanguage', type: 'string' }//T06
            ];
            
        } catch (error) {
            log('case setKBActionForDelete error --> ' + JSON.stringify(error));
        }
    }

    handleToggleKBActionSection(parModalHeader) {
        try {
            if (this.showEditFormFields == 'slds-show' && ((this.showAutoCloserDate) || (this.showCloseCase) || (this.showProvideSolution))) {
                this.showKBActionSection = true;
                this.showKBActionReadOnly = false;
                this.showSelectedKBInKBSpace = false;
                this.showNewKbSection = false;
                this.showUpdateKbSection = false;
                this.showErrorInKb = false;
                this.handleInitKBAction(parModalHeader);
            }
            else {
                this.showKBActionSection = false;
            }
        } catch (error) {
            log('case setKBActionForDelete error --> ' + JSON.stringify(error));
        }
    }

    handleIsKBActionAvailable()
    {
        var varIsValid = false;
        try {
            if (((this.modalHeader == CLOSE_CASE) || (this.modalHeader == PROVIDE_SOLUTION) || (this.modalHeader == DELAYED_CLOSING)) && (this.showKBActionSection == true)) {
                varIsValid = true;
            }
            else
            {
                varIsValid = false;
            }
            
        } catch (error) {
            log('case handleKBActionValueValid error --> ' + JSON.stringify(error));
        }
        return varIsValid;
    }

    handleKBActionChangeDataTable() {
        try {
            this.kbSelectedData = [...this.kbExistingSelectedData];
            if (this.kbSelectedData.length > 0) {
                this.showSelectedKBInKBSpace = true;
            }
            else {
                this.showSelectedKBInKBSpace = false;
            }
        } catch (error) {
            log('case handleKBActionValueValid error --> ' + JSON.stringify(error));
        }
    }

    get handleKBActionSubSection() {
        this.showKBActionSubSection = true;
        return ''
    }
    //End --> Sathish R --> Jira : I2RT-3105
    /*
    Method Name : openSubtab
    Description : This method opens the requested (old) modal in a subtab.
    Parameters	 : Object, called from openSubtab, objEvent Click event.
    Return Type : None
    */
    openSubtab(objEvent) {
        //T11 - get the current tab id and pass it to the sub tab
        objUtilities.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
            if (isConsole) {
                objUtilities.invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
                    console.log("Current Tab Id: ", focusedTab.tabId);
                    objUtilities.openComponentInSubtab({
                        objParent: this,
                        objNavigation: NavigationMixin.Navigate,
                        strComponentName: "c:caseQuickActions",
                        strCaseTabId: focusedTab.tabId, //T11
                        strSubtabLabel: objEvent.target.label,
                        strId: this.recordId + objEvent.target.label,
                        objData: {
                            recordId: this.recordId,
                            boolIsInSubtab: true,
                            strMethodName: objEvent.target.getAttribute("data-method-name"),
                            objEvent: {
                                target: {
                                    label: objEvent.target.label
                                }
                            }
                        }
                    });
                });
            }
        });
    }

    //T12
       /*
    Method Name : handleMessageOnKBActionNASelect
    Description : This method used to give Toast Message on KB Action change.
    Parameters	 : .
    Return Type : None
    */
    handleMessageOnKBActionNASelect()
    {
        if((this.recordTypeName == CASE_TECHNICAL) && (this.showProvideSolution == true) || (this.showCloseCaseButton == true))
        {
            if((this.kbSelectedAction == 'NA') && 
                (((this.selectedResolutionType == UNDOCUMENTED_SOLUTION) && ((this.selectedResolutionCode == ADVANCED_TROUBLESHOOTING) || (this.selectedResolutionCode == CUSTOM_CONFIGURATION))) || 
                ((this.selectedResolutionType == CHANGE_REQUEST) && ((this.selectedResolutionCode == EBF_PATCH) || (this.selectedResolutionCode == WORKAROUND)))))
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Notice',
                        message: KB_ACTION_TOAST_MESSAGE,
                        variant: 'info',
                        mode: "sticky"
                    }),
                );
            }
        }
    }

    /*
    Method Name : handleToggleNAFromKBActionSource
    Description : This method used to Toggle NA Value from KB Action Drop Down.
    Parameters	 : 
    Return Type : None
    */
    handleToggleNAFromKBActionSource()
    {
        if((this.showProvideSolution == true) || (this.showCloseCaseButton == true))
        {
            if((this.selectedResolutionCode == KB) && (this.selectedResolutionType == DOCUMENTED_SOLUTION))
            {
                if(this.kbActionOptions.includes(this.kbActionNAOption))
                {                
                    this.kbActionOptions = [...this.kbActionWithOutNAOptions]; 
                    if(this.kbSelectedAction == NOT_APPLICABLE)
                    {
                        this.processKBActionRelatedDetails(KB_NONE);
                    }
                    else
                    {
                        this.processKBActionRelatedDetails(this.kbSelectedAction);
                    }
                }            
            }
            else
            {
                if(!this.kbActionOptions.includes(this.kbActionNAOption))
                {                
                    this.kbActionOptions = [...this.kbActionWithNAOptions]; 
                } 
                this.processKBActionRelatedDetails(this.kbSelectedAction);   
            }
        }
        else
        {
            if(!this.kbActionOptions.includes(this.kbActionNAOption))
            {                
                this.kbActionOptions = [...this.kbActionWithNAOptions]; 
            } 
            this.processKBActionRelatedDetails(this.kbSelectedAction);   
        }
    }

    
    /*
    Method Name : processKBActionRelatedDetails
    Description : This method used to excute KB Action Dropdonw Value related logic.
    Parameters	 : 
    Return Type : None
    */
    processKBActionRelatedDetails(parselectedValue)
    {        
        var lclSelectedValue = parselectedValue;
        this.kbSelectedAction = parselectedValue;      
        if (lclSelectedValue === 'NA') {
            this.showNewKbSection = false;
            this.showUpdateKbSection = false;
            this.hideUpdateKBSpace();
            this.showErrorInKb = false;   
            this.handleMessageOnKBActionNASelect();//T12         
        } else if (lclSelectedValue === 'Create New') {
            this.showNewKbSection = true;
            this.showUpdateKbSection = false;
            this.hideUpdateKBSpace();
            this.showErrorInKb = false;
            this.handleKBActionChangeDataTable();
            this.setKBActionForDelete();            
        } else if (lclSelectedValue === 'Use Existing' || lclSelectedValue === 'Updated Existing') {
            this.showNewKbSection = false;
            this.showUpdateKbSection = true;
            this.showUpdateKBSpace();            
            this.handleKBActionChangeDataTable();
            this.setKBActionForDeleteUpdate();           
        } else if (lclSelectedValue === KB_NONE) {
            this.kbSelectedAction = undefined;
            this.showNewKbSection = false;
            this.showUpdateKbSection = false;
            this.hideUpdateKBSpace();
            this.showErrorInKb = false;                      
        }

        
        [...this.template.querySelectorAll('lightning-combobox')].forEach(element => {
            if (element.name === 'KB Action') 
            {
                if ((this.kbSelectedAction != undefined) && (this.kbSelectedAction != null) && (this.kbSelectedAction != '') && (this.kbSelectedAction != KB_NONE))
                {
                    element.setCustomValidity("");
                    element.reportValidity();
                }                
            }
        });
        
    }
    //T12
}