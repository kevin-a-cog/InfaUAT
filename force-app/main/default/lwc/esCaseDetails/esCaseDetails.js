/*
 Change History
 *************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                          Tag
 *************************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                                     NA
 Amarender              15-Dec-2021     I2RT-5163           Need more time can be confirmed without expected Date                T01
 Vignesh Divakaran      03-Mar-2022     I2RT-5614           UI validation issue on revise priority from P3 to P2                 T02   
 Sandeep Duggi          26-Apr-2022     I2RT-5825           eSupport- Unable to open closed case                                 T03    
 Sandeep Duggi          26-Apr-2022     I2RT-6183           eSupport- Basic Support customers to not have ability to             T04
                                                            Escalate or Raise AR
 Vignesh Divakaran      22-Jul-2022     I2RT-6593           Show Business Impact and Estimated date for Milestone fields         T05
                                                            for Technical and Operations case   
 Vignesh D              08-Aug-2022     I2RT-6864           Checkmarx security fixes                                  T06
 Sandeep D              19-Aug- 2022    I2RT-6869           PayGo: eSupport - My Lite Cases & Case Details page        T07
 balajip                29-Aug-2022     I2RT-7200           PayGo: eSupport - Fixed Accept/Decline Solution 
                                                                and Need More Time actions                                       T08
 Amit Garg              07-Oct- 2022    I2RT-7210           PayGo: eSupport caselite detail page to have Add Alternate 
                                                            contact button                                                       T09
 Vignesh D              25-Oct-2022     I2RT-7256           Added getter method to get the org details page URL                  T10
 Vignesh D              29-Oct-2022     I2RT-7210           Added getter method to display the record type name                  T11
<<<<<<< HEAD
 Vignesh D              16-Dec-2022     I2RT-7604           Case Comment created by logic to be same as console comment timeline T12
=======
balajip                24-Jan-2023     I2RT-7224          	Removed unused reference (CaseController.updateCaseContacts)    T12
>>>>>>> refs/remotes/origin/feature/US-0002539
 
Shashikanth            22-May-2023     I2RT-8140           Attention Requests and Escalations: Avoid multiple requests.         T14
Shashikanth            16-Oct-2023     I2RT-8987           Need to show the escalate button always in eSupport.                 T15
Shashikanth            06-Nov-2023     I2RT-7702           Updated Cancel/Reschedule Appointments success messages              T16
 */
import { LightningElement, track, api, wire } from 'lwc';
import removeFile from '@salesforce/apex/CaseController.removeFile';
import updateDocVersion from '@salesforce/apex/CaseController.updateDocVersion';
import deleteDoc from '@salesforce/apex/CaseController.deleteDoc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import getCaseDetails from '@salesforce/apex/CaseController.getCaseDetails';
import removeCaseContact from '@salesforce/apex/CaseController.removeCaseContact';
import requestAttn from '@salesforce/apex/CaseController.requestAttn';
import reOpenCase from '@salesforce/apex/CaseController.reOpenCase';
import escalateCase from '@salesforce/apex/CaseController.escalateCase';
import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
import getCaseCommentsForEsupport from '@salesforce/apex/CaseCommentController.getCaseCommentsForEsupport';
import addCaseCommentsFromEsupport from '@salesforce/apex/CaseCommentController.addCaseCommentsFromEsupport';
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';
import TIME_ZONE from '@salesforce/i18n/timeZone'; 

import getLiveAssistVisibility from '@salesforce/apex/CaseController.getLiveAssistVisibility';  // Tejasvi Royal -> I2RT-1966: Live Assistance Request
import confirmLiveAssistReason from '@salesforce/apex/CaseController.confirmLiveAssistReason';  // Tejasvi Royal -> I2RT-1966: Live Assistance Request
import { ShowToastEvent } from 'lightning/platformShowToastEvent';                              // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT-2663)
import getESupportMetadataId from '@salesforce/apex/CaseController.getESupportMetadataId';      // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662) -> Metadata Enhancement
import { getRecord } from 'lightning/uiRecordApi';                                              // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662) -> Metadata Enhancement

import trackSolutionStatus from "@salesforce/apex/CaseController.trackSolutionStatus";      //Amarender -> I2RT-1020: eSupport: Solutions Page

import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails'; //Vignesh -> Get contact details of current user 
import getServiceCloudMetadata from '@salesforce/apex/CaseController.getServiceCloudMetadata';   //Vignesh -> Get service cloud metadata
import checkIRCompletion from '@salesforce/apex/CaseController.checkIRCompletion';               //Vignesh -> Check IR completion on the case
import getResponseTime from '@salesforce/apex/CaseController.getResponseTime';                   //Vignesh -> Get Callback/Revise Priority/Escalate action response time
import closeCaseRequest from '@salesforce/apex/CaseController.closeCaseRequest';                 //Vignesh -> Close case request separate method
import getRescheduleSlots from '@salesforce/apex/OperationsSchedulerController.getRescheduleSlots';
import rescheduleSession from '@salesforce/apex/OperationsSchedulerController.rescheduleSession';

import CancelAaeAppointmentHandler from '@salesforce/apex/CaseController.CancelAaeAppointmentHandler';                 //piyush
import generateDownloadUrl from '@salesforce/apex/CaseController.generateDownloadUrl';                 //Amarender
    import { objUtilities, log } from 'c/globalUtilities'; //Vignesh
    import getCaseAccess from '@salesforce/apex/CaseController.getCaseAccess';

    //Custom Labels
    import TECHNICAL from '@salesforce/label/c.Case_RecordType_Technical';
    import OPERATIONS from '@salesforce/label/c.Case_RecordType_Operations';
    import FULFILLMENT from '@salesforce/label/c.Case_RecordType_Fulfillment';
    import ADMININSTRATIVE from '@salesforce/label/c.Case_RecordType_Administrative';
    import ASK_AN_EXPERT from '@salesforce/label/c.Case_RecordType_Ask_an_Expert';
    import CASE_LITE from '@salesforce/label/c.Case_RecordType_Case_Lite';
import Case_Lite_RecordType_Name from '@salesforce/label/c.Case_Lite_RecordType_Name'; //<T11>

// Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662) -> Metadata Enhancement
const METADATA_FIELDS = [
    'Service_Cloud_General_Setting__mdt.Live_Assistance_Request_Success_Message__c',
    'Service_Cloud_General_Setting__mdt.Live_Assistance_Request_Failure_Message__c'
];

const SupportContactPage_MD = 'Support_Contact_Page';
const eSupportAcceptSolutionMessage_MD = 'eSupport_Accept_Solution_Message';
const SCHEDULED_ACTIVITY_TYPE = ['Request an activity/change request'];

/* Display Message on Page when No Access/Error */
const NO_RECORD_ACCESS_MESSAGE = 'You don\'t have access to record.';
const ERROR_MESSAGE = 'An error occurred while fetching data.';

/* Override CreatedBy Name for Case Comments with Default Name from Label */
const INFORMATICA_SUPPORT = 'Informatica Support';

export default class EsCaseDetails extends LightningElement {
    maximize = ESUPPORT_RESOURCE + '/maximize.png';
    @api caseInfo;
    @api caseContacts;
    @api caseDocuments;
    @track isCallBackModal = false;
    @track isCallBackOptionModal = true;
    @track isCallBackConfirmedModal = false;
    @track isRevisePriorityModal = false;
    @track isReviseOptionModal = true;
    @track isReviseConfirmedModal = false;
    @track isEscalateCaseModal = false;
    @track isEscalateOptionModal = true;
    @track isEscalateConfirmedModal = false;
    @track isReopenCaseModal = false;
    @track isReopenOptionModal = true;
    @track isReopenConfirmedModal = false;
    @track isCloseCaseModal = false;
    @track isCloseOptionModal = true;
    @track isCloseConfirmedModal = false;
    @track isCreateContactModal = false;
    @track isAlternateContactModal = false;
    @track isDeleteModal = false;
    @track isEditModal = false;
    @track showDetails = false;
    @track showSpinner = false;
    @track isDeleteContactModal = false;
    @track isAddUpdateAttachment = false;
    @track disableReOpen = true;
    @track showP1Priority = false;
    @track showP2Priority = false;
    @track showPriorityButton = false;
    @track buttonCss = 'es-button es-button--secondary';
    @track showRevisePriorityError = false;
    @track caseDetail = {};
    @track serviceAppointment = {};
    @track nextAction = '';
    @track caseAttachments = [];
    @track contentDownloadUrlMap = {};
    @track contacts = [];
    @track iconName = 'utility:down';
    @track fileToRemove;
    @track newClass;
    @track assessClass;
    @track researchClass;
    @track solutionClass;
    @track closedClass;

    // piyush for AAE start 
    @track scheduleClassAAE;
    @track BookedClassAAE;
    @track DeliveredClassAAE;
    @track CancelledClassAAE;
    // piyush for AAE end 

    @track bShowCancelReason = false;
    @track isCanceled = false;
    @track bCanceledEvent = false;
    @track currentDocId = '';
    @track currentDocument;             //Amarender - Added as part of I2RT-3380
    @track replacedFiles = [];          //Amarender - Added as part of I2RT-3380
    @track uploadedDocId = '';
    @track docPrevDescription;
    @track discardModalTitle;
    @track closedFromModal;
    @track docDescription;
    @track uploadComments;
    @track docComments;
    @track deleteDocumentId;
    @track uploadedFiles = [];
    @track uploadedFileNames = [];
    @track createdDocumentId;
    @track contactIdToDelete;
    @track fileDescription;
    @track reasonForChangePriority;
    @track selectedPriority = '';
    @track reasonForClosingCase;
    @track reasonForReOpenCase;
    @track caseNumber;
    @track reOpenedCaseId;
    @track alternateNumber;
    @track callBackReason;
    @track selectedEscalateReason;
    @track escalateReason;
    @track ogrDetail;
    @track callBackUpdatedPhone = '';
    @track errorRevisePriorityClass = '';
    @track dataNotification = [];
    @track caseCommentByDate = [];

    @track caseRecordId;                                    // Tejasvi Royal -> eSupport Feedback Enhancements
    @track isCommentSortedByEarliest = false;               // Tejasvi Royal -> eSupport Feedback Enhancements
    @track caseCommentSortBy = 'LastModifiedDate DESC';     // Tejasvi Royal -> eSupport Feedback Enhancements
    @track caseCommentSearchBy = '';                        // Tejasvi Royal -> eSupport Feedback Enhancements
    @track isAddCaseCommentModal = false;                   // Tejasvi Royal -> eSupport Feedback Enhancements
    @track caseCommentBody;                                 // Tejasvi Royal -> eSupport Feedback Enhancements
    @track disableAddCommentModalButton = true;             // Tejasvi Royal -> eSupport Feedback Enhancements
    @track addCommentModalButtonCSS = 'es-button es-button--secondary';     // Tejasvi Royal -> eSupport Feedback Enhancements     
    @track metadataRecordId;                        // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662) -> Metadata Enhancement
    @track liveAssistRequest_SuccessMessage = '';   // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662)
    @track liveAssistRequest_FailureMessage = '';   // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662)
    @track liveAssistanceRequestReason;             // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @track isLiveAssistanceEnabled = false;         // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @track isLiveAssistanceModal = false;           // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @track disableLiveAssistConfirmButton = true;   // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @track liveAssistConfirmButtonCSS = 'es-button es-button--secondary';   // Tejasvi Royal -> I2RT-1966: Live Assistance Request

    @track isInSolutionState;                  //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track isNeedMoreTimeModal;                //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track isDeclineSolutionModal;                //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track needMoreTimeReason;                 //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track declineSolutionReason;                 //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track disableConfirmButton = true;        //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track expectedDate;                       //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track isSelectedPastDate = false;                       //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track isClosed = false;                   //Amarender -> I2RT-1020: eSupport: Solutions Page
    @track supportAccountURL;                  //Amarender -> I2RT-636: eSupport: Support Account Details Page
    @track tsftpLocationUrl;                 //Amarender - Added as part of I2Rt-564 
    
    
                
    @track isPrimaryContact = false;
    @track isReadWriteContact = false;
    @track isCasePrimaryContact = false;
    @track loggedInUser = '';
    @track caseclosedmodal = false;
    @track openAcceptmodal = false;

    @track showDiscardConfirmation = false;

    @track suppContactMetadataId;
    @track supportContactURL;
    @track suppAcceptSolutionMetadataId;
    @track acceptSolutionMessage;
    @track notAvailableAltContact=false;
    @track notAvailableCaseAttachments=false;
    
    @track isIRCompleted = false;
    @track responseDateTime;

    //Operations Acitivity reschedule
    @track userTimeZone = TIME_ZONE;
    @track showSessionActionModal = false;
    @track sessionCancelReasonValue;
    @track availableDatesWithSlots;
    @track availableDates;
    @track selectedDate;
    @track availableSlots;
    @track selectedSlot;
    @track contactEmail;
    @track createdByEmail;
    @track createdByName = "";
    slotStartDT;
    slotEndDT;
    richClass;
    requiredMessage;
    isEcommContact;//<T09>
        //Loader
    @track boolDisplaySpinner = true;
    @track boolHasAccess = false;
    @track strMessage = NO_RECORD_ACCESS_MESSAGE;

    @track showMoreFields;
    @track selectedImpact;
    @track doesImpactMilestone = false;
    @track selectedEstimateDate;
    @track  optionsTemp = [
        { label: 'Critical Development Blocker', value: 'Critical Development Blocker' },
        { label: 'Critical Production Service Outage', value: 'Critical Production Service Outage' },
        { label: 'Production Deployment Blocker', value: 'Production Deployment Blocker' },
        { label: 'Upcoming Go Live', value: 'Upcoming Go Live' },
        { label: 'Widespread Production Service Outage', value: 'Widespread Production Service Outage' },
    ];
    @track hasaccess = false;

    RECORD_TYPE = {
        TECHNICAL,
        OPERATIONS,
        FULFILLMENT,
        ADMININSTRATIVE,
        ASK_AN_EXPERT,
        CASE_LITE
    };
    
    //<T14>
    @track isEscalateCaseActionVisible = true;     
    @track caseMileStoneDetails ={'IsActiveARMilestoneExists' : null,
                                    'IsActiveIRMilestoneExists' : false,
                                    'ARSLATime':null,
                                    'IRSLATime':null
                                    };
    //</T14>
    

    connectedCallback() {
        console.log('connected callback');
        let url = new URL(encodeURI(window.location.href)); //<T06>
        log('URL= ' + url);
        let caseId = url.searchParams.get("caseId");
        console.log('caseid***',caseId);
        let emailresp = url.searchParams.get("fromemail");
        
        this.caseRecordId = caseId; // Tejasvi Royal -> eSupport Feedback Enhancements
        
                // I2RT-4421
        getCaseAccess({caseId : this.caseRecordId, strAccessLevel: ''})
        .then(result => {
                this.hasaccess = objUtilities.isBlank(result);
               console.log('@@--resut-->>>',result);                                                     
            if(this.hasaccess == false){
                    this.setDisableAccessError(result); //T07
            //I2RT-4421
            }else{
                getServiceCloudMetadata({ metadataName: eSupportAcceptSolutionMessage_MD }) //Get Accept Solution Message from Service Cloud Custom Metadata
                .then(result => {
                    log('support accept solution metadata Id ==> '+result);
                    this.suppAcceptSolutionMetadataId = result;
                })
                .catch(error => {
                    log('Metadata error ==> '+error);
                })
                if (caseId) {
                        getSupportContactDetails({ caseId: caseId, supportAccountId: ''})
                    .then(result => {
                        log('Contact details => '+JSON.stringify(result));
                        log('Contact length => '+Object.keys(result).length);
                        if(result && Object.keys(result).length > 0){
                            this.isPrimaryContact = result.isPrimary ? true : false;
                            this.isReadWriteContact = result.isReadWrite ? true : false;
                            this.isCasePrimaryContact = result.isCasePrimaryContact ? true : false;
                            this.loggedInUser = result.loggedInUser;
                            this.isEcommContact = result.isEcommContact;//<T09>
                        }
                        else{
                            this.setDisableAccess(false);
                        }
                        return getCaseDetails({ caseId: caseId });
                    })
                    .then(result => { //Promise for getCaseDetails
                        log('caseDetails- ' + JSON.stringify(result));
                        log('caseDetails length: ' +Object.keys(result).length);
                        if(result && Object.keys(result).length > 0){
                            this.caseDetail = result.caseRecord;
                            this.serviceAppointment = result.serviceAppointment;
                            //this.contacts = result.caseContacts;
                            this.processCaseContacts(result);
                            this.tsftpLocationUrl = result.tsftpLocationUrl;                 //Amarender - Added as part of I2Rt-564 
                            this.caseAttachments = [...result.caseDocuments].map(doc =>{
                                doc.canBeEdited = (doc.ContentDocument.CreatedById == this.loggedInUser);
                                doc.canBeDeleted = (doc.ContentDocument.CreatedById == this.loggedInUser);
                                return doc;
                            });
                            this.contentDownloadUrlMap = new Map(Object.entries(result.contentDownloadUrlMap));
                            this.disableReOpen = result.disableReOpen;
                            this.contactEmail = result.caseRecord.ContactEmail;
                            this.createdByEmail = result.caseRecord.CreatedBy.Email;
                            this.isCaseCreatedByUser();
                            if (result.disableReOpen) {
                                this.buttonCss = 'es-button es-button--secondary';
                            } else {
                                this.buttonCss = 'es-button es-button--primary';
                            }
                            this.showDetails = true;
                            this.isInSolutionState = this.caseDetail.Status == 'Solution' ? true : false;        //Amarender -> I2RT-1020: eSupport: Solutions Page
                            this.isClosed = this.caseDetail.Status == 'Closed' ? true : false;                   //Amarender -> I2RT-1020: eSupport: Solutions Page
                            this.isCanceled = this.caseDetail.Status == 'Cancelled' || this.caseDetail.Status == 'Delivered'  ? true : false;                   //Piyush -> 
                            this.supportAccountURL =    'supportaccountdetails';                              //Amarender -> I2RT-636: eSupport: Support Account Details Page
                             localStorage.setItem("supportAccountId",this.caseDetail?.Support_Account__c); //<T10>
                            log('this.supportAccountURL : ' + this.supportAccountURL);
                            log('showDetials= ' + this.showDetails);
                            this.updateStatusTracker(this.caseDetail.Status);
                            this.inItDom();
                            log('case status @:'+this.caseDetail.Status);
                            if(this.caseDetail.Status == 'Closed'){
                                log('closing modal');
                                this.caseclosedmodal = true;
                                }else if(this.caseDetail.Status == 'Solution' && (this.caseDetail.RecordType.DeveloperName !== this.RECORD_TYPE.OPERATIONS || (this.caseDetail.RecordType.DeveloperName === this.RECORD_TYPE.OPERATIONS && this.caseDetail.RCA_Pending_flag__c !== 'Yes'))){
                                if(emailresp != undefined){
                                    this.caseclosedmodal = false;
                                    if(this.isReadWriteContact || this.caseDetail?.RecordType?.Name == 'Case Lite'){ //T08
                                        if(emailresp == 'accept'){
                                            //this.handleAcceptSolutionClick();
                                            this.openAcceptmodal = true;
                                        } else if(emailresp == 'decline'){
                                            this.handleDeclineSolutionClick();
                                        }else if (emailresp == 'moretime'){ //3563 KG updated as per the SendGridGCSController 3563
                                            this.handleNeedMoreTimeClick();
                                        }
                                    }
                                }
                            }

                            //<T14>
                            this.fillCaseMilestoneDetails(result);
                            //</T14>

                            this.setEnableAccess();
                        }
                        else{
                            this.setDisableAccess(false);
                        }
                    })
                    .catch(error => { //Promise for getCaseDetails
                        log("error - " + JSON.stringify(error));
                        this.setDisableAccess(true);
                    })
                    .catch(error => { //Promise for getSupportContactDetails
                        log('Contact details Error => '+JSON.stringify(error));
                        this.setDisableAccess(true);
                    });
                        getLiveAssistVisibility({ caseId: caseId })
                    .then(result => {
                        log('Live Assistance Visibility Result => ' + result);
                        this.isLiveAssistanceEnabled = result;
                    })
                    .catch(error => {
                        log("Live Assistance Visibility Error => " + JSON.stringify(error))
                    });
                        getESupportMetadataId()
                    .then(result => {
                        log('ESupport Metadata Id Result => ' + result);
                        this.metadataRecordId = result;
                    })
                    .catch(error => {
                        log("ESupport Metadata Error => " + JSON.stringify(error))
                    });
                        // Tejasvi Royal -> eSupport Feedback Enhancements
                        this.caseCommentHandler(this.caseRecordId, this.caseCommentSortBy, this.caseCommentSearchBy);
    
                        getServiceCloudMetadata({ metadataName: SupportContactPage_MD })
                    .then(result => {
                        log('support contact metadata Id ==> '+result);
                        this.suppContactMetadataId = result;
                    })
                    .catch(error => {
                        log('Metadata error ==> '+error);
                    })
                this.checkIRCompletionDetails(caseId);
            } else {
                this.caseDetail = this.caseInfo;
                this.contacts = [...this.caseContacts].map(contact => {
                    contact.canBeDeleted = (contact?.Case__r?.ContactId != contact?.Contact__c);
                    return contact;
                });
                this.caseAttachments = this.caseDocuments;
                this.showDetails = true;
                this.updateStatusTracker(this.caseDetail.Status);
                this.inItDom();
            }
        }
                
        })
        .catch(error => {
            console.log('check access method error',error);
        });

            
        
        
    }
        ////T04 Sandeep - added as part of I2RT-6183
    get disableEscalationAndAR() {
            
        return this.caseDetail?.Support_Account__r?.Success_Offering__c == 'Basic Success' ? true : false;
            
    }
    // T07 Sandeep - added as part of I2RT-6869
    get disableOptionsForCaseLite() {
        
        return this.caseDetail?.RecordType?.DeveloperName == this.RECORD_TYPE.CASE_LITE ? true : false;
            
    }

    //<T14>
    fillCaseMilestoneDetails(result)
    {
        this.caseMileStoneDetails.IsActiveARMilestoneExists = result.isActiveARMilestoneExists;
        this.caseMileStoneDetails.IsActiveIRMilestoneExists = result.isActiveIRMilestoneExists;
        this.caseMileStoneDetails.ARSLATime = result.arSLATime;
        this.caseMileStoneDetails.IRSLATime = result.irSLATime;     //<T15>
    }
    //</T14>

    isCaseCreatedByUser(){
        if(this.createdByEmail == this.contactEmail){
            this.createdByName = this.contactEmail;
        }
        else{
            this.createdByName = "Informatica Support";
        }
    }

    setEnableAccess(){
        this.boolDisplaySpinner = false;
        this.boolHasAccess = true;
    }
    //ISd-4421
    setDisableAccessError(msg){
        this.boolDisplaySpinner = false;
        this.boolHasAccess = false;
        this.strMessage =   msg;
    }
    setDisableAccess(isError){
        this.boolDisplaySpinner = false;
        this.boolHasAccess = false;
        this.strMessage = isError ? ERROR_MESSAGE : NO_RECORD_ACCESS_MESSAGE;
    }

    //<T14>

    validateAttentionRequestSubmission()
    {
        if(this.caseMileStoneDetails.IsActiveARMilestoneExists == true)
        {
            let arDetails = this.getActiveAttentionRequestDetails();
            let errorMessage = 'Prior request \''+ arDetails.attentionRequest + '\' is in progress. Please expect the response by ' + arDetails.slaTime + '.';
            this.showCustomToast('Please Note', errorMessage, 'error', 'dismissable');
            return false;
        }
        return true;
    }

    //</T14>

    //<T15>
    getActiveAttentionRequestDetails()
    {
        if(this.caseMileStoneDetails.IsActiveARMilestoneExists == true)
        {
            let attentionRequest = (!!this.caseDetail.Attention_Request__c) ? this.caseDetail.Attention_Request__c : '';
            let slaTime = !!this.caseMileStoneDetails.ARSLATime ? new Date(this.caseMileStoneDetails.ARSLATime) : null;
            let formattedSLATime = '';
            if(slaTime != null)
            {
                formattedSLATime = this.getFormattedDateTime(slaTime);
            }

            let arDetails = {};
            arDetails.slaTime = formattedSLATime;
            arDetails.attentionRequest = attentionRequest;

           return arDetails;
        }
        return null;
    }

    getFormattedDateTime(dateTime, timeZoneSidkey){
        let formatOptions = {
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "numeric",
            minute: "2-digit",
            hour12: "true"
        };

        if(!!timeZoneSidkey){
            formatOptions.timeZone = timeZoneSidkey;
        }

        let formatter = new Intl.DateTimeFormat('en', formatOptions);
        let formattedDateTime = (dateTime != null) ? formatter.format(dateTime) : '';
        return formattedDateTime;
    }
    //</T15>


// @piyush 
CancelHandler(){
        var isValidValue = this.validateInputField();
        log('uploadComments====> ' + this.uploadComments);
        if (isValidValue){
            
                this.showSpinner = true;
                log('this.caseRecordId---> ' + this.caseRecordId);
                CancelAaeAppointmentHandler({ caseId: this.caseRecordId , uploadComments : this.uploadComments })
                .then(result => {
                    this.showSpinner = false;
                this.showCustomToast('Success!', 'AAE session has been cancelled.', 'success', 'dismissable');       //<T16>           
                this.updateStatusTracker('Cancelled'); 
                this.bShowCancelReason = false;
                this.uploadComments = '';
                this.refreshCaseComments(); // Tejasvi Royal -> eSupport Feedback Enhancements
                this.reRender();
                })
                .catch(error => {
                    this.showSpinner = false;
                    log("error - " + JSON.stringify(error))
                });      
            }
        else{
            log('required field missing.');
        }  

    }

// @piyush 
    closeAddModalCancelReason(){
        this.bShowCancelReason = false; 
        this.uploadComments = '';
        this.bCanceledEvent = false;
    }

    // @piyush 
    CancelAppointmentClick(){ 
        this.bShowCancelReason = true; 
        this.bCanceledEvent = true;
        /** START-- adobe analytics */
            try {
            util.trackButtonClick("Cancel Appointment");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }


    RescheduleAppointmentHandler(){
        var isValidValue = this.validateInputField();
        log('uploadComments====> ' + this.uploadComments);
        if (isValidValue){
            this.showSpinner = true;
            log('this.caseRecordId---> ' + this.caseRecordId);
            CancelAaeAppointmentHandler({ caseId: this.caseRecordId , uploadComments : this.uploadComments })
            .then(result => {
                this.showSpinner = false;
                this.showCustomToast('Success!', 'AAE session has been cancelled.', 'success', 'dismissable');           //<T16>
                this.updateStatusTracker('Cancelled');             
                this.caseDetail.Support_Account__c;
    
                this.bShowCancelReason = false;
                this.uploadComments = '';
                this.refreshCaseComments(); // Tejasvi Royal -> eSupport Feedback Enhancements
                this.reRender();
                /** START-- adobe analytics */
                try {
                    util.trackButtonClick("Reschedule Appointment");
                }
                catch(ex) {
                    log(ex.message);
                }
                /** END-- adobe analytics*/
                var url = CommunityURL + 'askanexpert?supportaccountid=' + this.caseDetail.Support_Account__c;
                window.open(url, '_self');
            })
            .catch(error => {
                this.showSpinner = false;
                log("error - " + JSON.stringify(error))
            });   
        }
        
    }


    RescheduleAppointmentClick(){
        this.bCanceledEvent = false;
        this.bShowCancelReason = true; 
    }

    inItDom() {
        if (this.caseDetail.Priority === 'P1') {
            this.showPriorityButton = false;
        } else {
            this.showPriorityButton = true;
            if (this.caseDetail.Priority === 'P3') {
                this.showP1Priority = true;
                this.showP2Priority = true;
            } else if (this.caseDetail.Priority === 'P2') {
                this.showP2Priority = false;
                this.showP1Priority = true;
            }
        }
        // T03 added Safe navigator operator to handle nullish value  
        this.callBackUpdatedPhone = this.caseDetail?.Contact?.Phone;

            //@Akhilesh 5 June 2021 -- start
            log('@Log=> this.caseDetail.Next_Action__c:' + this.caseDetail.Next_Action__c);
        if(this.caseDetail.Next_Action__c != 'Customer'){
            this.nextAction = 'Informatica';
        }
        else{
            this.nextAction = this.caseDetail.Next_Action__c;
        }
            //@Akhilesh 5 June 2021 -- end
    }

    renderedCallback(){

        if(this.showSpinner == true){
            document.body.setAttribute('style', 'overflow: hidden;');
        }
        else{
            document.body.removeAttribute('style', 'overflow: hidden;');
        }
        if (this.contacts.length == 0){
            this.notAvailableAltContact = true;
        }
        else{
            this.notAvailableAltContact = false;
        }
        if (this.caseAttachments.length == 0){
            this.notAvailableCaseAttachments = true;
        }else{
            this.notAvailableCaseAttachments = false;
        }
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

    updateStatusTracker(caseStatus) {
        log('caseStatus= ' + caseStatus);
        if (caseStatus == 'New') {
            this.newClass = 'es-chevron__item es-chevron__item--current';
            this.assessClass = 'es-chevron__item es-chevron__item--incomplete';
            this.researchClass = 'es-chevron__item es-chevron__item--incomplete';
            this.solutionClass = 'es-chevron__item es-chevron__item--incomplete';
            this.closedClass = 'es-chevron__item es-chevron__item--incomplete';
        } else if (caseStatus == 'Assess') {
            this.newClass = 'es-chevron__item es-chevron__item--completed';
            this.assessClass = 'es-chevron__item es-chevron__item--current';
            this.researchClass = 'es-chevron__item es-chevron__item--incomplete';
            this.solutionClass = 'es-chevron__item es-chevron__item--incomplete';
            this.closedClass = 'es-chevron__item es-chevron__item--incomplete';
        } else if (caseStatus == 'Research') {
            this.newClass = 'es-chevron__item es-chevron__item--completed';
            this.assessClass = 'es-chevron__item es-chevron__item--completed';
            this.researchClass = 'es-chevron__item es-chevron__item--current';
            this.solutionClass = 'es-chevron__item es-chevron__item--incomplete';
            this.closedClass = 'es-chevron__item es-chevron__item--incomplete';
        } else if (caseStatus == 'Solution') {
            this.newClass = 'es-chevron__item es-chevron__item--completed';
            this.assessClass = 'es-chevron__item es-chevron__item--completed';
            this.researchClass = 'es-chevron__item es-chevron__item--completed';
            this.solutionClass = 'es-chevron__item es-chevron__item--current';
            this.closedClass = 'es-chevron__item es-chevron__item--incomplete';
        } else if (caseStatus == 'Closed') {
            this.newClass = 'es-chevron__item es-chevron__item--completed';
            this.assessClass = 'es-chevron__item es-chevron__item--completed';
            this.researchClass = 'es-chevron__item es-chevron__item--completed';
            this.solutionClass = 'es-chevron__item es-chevron__item--completed';
            this.closedClass = 'es-chevron__item es-chevron__item--current';
        }
        // for AAE
        

        else if (caseStatus == 'Booked') {
            
            this.BookedClassAAE = 'es-chevron__item es-chevron__item--current';
            this.scheduleClassAAE = 'es-chevron__item es-chevron__item--incomplete';
            this.DeliveredClassAAE = 'es-chevron__item es-chevron__item--incomplete';
            this.CancelledClassAAE = 'es-chevron__item es-chevron__item--incomplete';
        }

        else if (caseStatus == 'Scheduled') { 
            this.BookedClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.scheduleClassAAE = 'es-chevron__item es-chevron__item--current';
            
            this.DeliveredClassAAE = 'es-chevron__item es-chevron__item--incomplete';
            this.CancelledClassAAE = 'es-chevron__item es-chevron__item--incomplete';
        }

        else if (caseStatus == 'Delivered') {
            this.scheduleClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.BookedClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.DeliveredClassAAE = 'es-chevron__item es-chevron__item--current';
            this.CancelledClassAAE = 'es-chevron__item es-chevron__item--incomplete';
        }

        else if (caseStatus == 'Cancelled') {
            this.scheduleClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.BookedClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.DeliveredClassAAE = 'es-chevron__item es-chevron__item--completed';
            this.CancelledClassAAE = 'es-chevron__item es-chevron__item--current';
        }




    }
    openCallBackModal() {
        //<T14>
        let isValid = this.validateAttentionRequestSubmission();
        if(!isValid)
        {
            return;
        }
        //</T14>

        this.isCallBackModal = true;
        this.isCallBackOptionModal = true;
        this.isCallBackConfirmedModal = false;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Call Back from Engineer");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }

    closeCallBackModal() {
        this.isCallBackModal = false;
        this.isCallBackOptionModal = true;
        this.isCallBackConfirmedModal = false;
        document.body.classList -= ' modal-open';
    }

    showContactSection() {
        this.showContactEditForm = true;
        this.isCallBackOptionModal = false;
        this.isCallBackConfirmedModal = false;
    }

    openRevisePriorityModal() {
        //<T14>
        let isValid = this.validateAttentionRequestSubmission();
        if(!isValid)
        {
            return;
        }
        //</T14>
        this.showMoreFields = false;
        this.reasonForChangePriority = '';
        this.isRevisePriorityModal = true;
        this.isReviseOptionModal = true;
        this.isReviseConfirmedModal = false;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Revise Priority");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/

    }
    closeRevisePriorityModal() {
        this.isRevisePriorityModal = false;
        document.body.classList -= ' modal-open';
    }

    openReopenCaseModal() {
        this.isReopenCaseModal = true;
        this.isReopenOptionModal = true;
        this.isReopenConfirmedModal = false;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Reopen case modal");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    handleCaseCommentSortBy(event) {
        this.caseCommentSortBy = event.detail;
        this.caseCommentHandler(this.caseRecordId, this.caseCommentSortBy, this.caseCommentSearchBy);
        if (this.caseCommentSortBy === 'LastModifiedDate DESC') {
            this.isCommentSortedByEarliest = false;
        }
        if (this.caseCommentSortBy === 'LastModifiedDate ASC') {
            this.isCommentSortedByEarliest = true;
        }
        log('In handleCaseCommentSortBy -> ');
        log('caseRecordId -> ' + this.caseRecordId);
        log('caseCommentSortBy -> ' + this.caseCommentSortBy);
        log('caseCommentSearchBy -> ' + this.caseCommentSearchBy);
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    handleCaseCommentSearchBy(event) {
        this.caseCommentSearchBy = event.detail;
        this.caseCommentHandler(this.caseRecordId, this.caseCommentSortBy, this.caseCommentSearchBy);
        log('In handleCaseCommentSearchBy -> ');
        log('caseRecordId -> ' + this.caseRecordId);
        log('caseCommentSortBy -> ' + this.caseCommentSortBy);
        log('caseCommentSearchBy -> ' + this.caseCommentSearchBy);
    }    

    // Tejasvi Royal -> eSupport Feedback Enhancements
    closeAddCaseCommentModal() {
        this.isAddCaseCommentModal = false;
        this.caseCommentBody = '';
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    handleOpenAddCaseCommentModal() {
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isValidValue){
            this.isAddCaseCommentModal = true;
            this.addCommentModalButtonCSS = (this.addCaseCommentValidator()) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
            this.disableAddCommentModalButton = (this.addCaseCommentValidator()) ? false : true;
        }
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    handleCaseCommentChange(event) {
        this.caseCommentBody = event.detail.value;
        this.addCommentModalButtonCSS = (this.addCaseCommentValidator()) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
        this.disableAddCommentModalButton = (this.addCaseCommentValidator()) ? false : true;
    }

    addCaseCommentValidator() {
        if (this.caseCommentBody && this.caseCommentBody.trim().length != 0) return true;
        if (!this.caseCommentBody || this.caseCommentBody.trim().length === 0) return false;
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    addCaseComment() {
        this.showSpinner = true;
        // IF: Case Comment -> Body value is "Valid" AND Add Comment Button is NOT disabled
        if (this.addCaseCommentValidator() && !this.disableAddCommentModalButton) {
            addCaseCommentsFromEsupport({ caseRecordId: this.caseRecordId, commentBody: this.caseCommentBody })
                .then(result => {
                    this.showSpinner = false;
                    this.closeAddCaseCommentModal();
                    this.showCustomToast('Success!', 'Comment added.', 'success', 'dismissable');
                    log("Add Case Comments Success - " + JSON.stringify(result));
                    this.refreshCaseComments(); // Tejasvi Royal -> eSupport Feedback Enhancements
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.closeAddCaseCommentModal();
                    this.showCustomToast('Failed!', 'Please login again. If issue persists, contact the Admin.', 'error', 'dismissable');
                    log("Add Case Comments Error - " + JSON.stringify(error));
                });
        }
        // IF: Case Comment -> Body value is "Invalid" OR Add Comment Button is disabled
        if (!this.addCaseCommentValidator() || this.disableAddCommentModalButton) {
            this.showSpinner = false;
            this.closeAddCaseCommentModal();
            this.showCustomToast('Failed!', 'Comment is blank or not valid.', 'error', 'dismissable');
        }     
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    refreshCaseComments() {
        // Toggling the Case Comments for a Refresh
        if (this.caseCommentSortBy === 'LastModifiedDate DESC') {
            this.caseCommentHandler(this.caseRecordId, 'CreatedDate DESC', '');
            this.caseCommentHandler(this.caseRecordId, 'LastModifiedDate DESC', '');
        }
        if (this.caseCommentSortBy === 'LastModifiedDate ASC') {
            this.caseCommentHandler(this.caseRecordId, 'LastModifiedDate DESC', '');
        }
        // Refresh of Case Comments will always default to Latest Comments first.
        this.isCommentSortedByEarliest = false;
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    caseCommentHandler(caseId, sort, search) {
        log('Sortby :: ' + sort);
        getCaseCommentsForEsupport({ caseRecordId: caseId, sortBy: sort, searchKey: search})
            .then(result => {
                log('@@Comments= ' + JSON.stringify(result));
                if (result) {
                    let commentInfo = [];
                    let commentByDate = new Map();
                    let childCommentsByParentId = new Map();

                    for (let j in result) {
                        let dataCaseUpdatesObject = {};
                        let dataCaseUpdates = [];
                        let mapKey = '';
                        if (result[j].childComment !== undefined) {
                            mapKey = result[j].childComment.comment.Parent_Comment__c;
                            log('ParentId= ' + mapKey);
                            dataCaseUpdatesObject.id = result[j].childComment.comment.Id;
                            //@Akhilesh 13 July 2021 --start
                            //dataCaseUpdatesObject.CreatedBy = result[j].childComment.comment.CreatedBy.Name;
                            dataCaseUpdatesObject.CreatedBy = objUtilities.isNotBlank(result[j].childComment.comment.Created_By__c) ? result[j].childComment.comment.Created_By__c : result[j].childComment.comment.CreatedBy.Name.toLowerCase() == 'infa support' ? 'Informatica Support' : result[j].childComment.comment.CreatedBy.Name; //<T12>
                            //@Akhilesh 13 July 2021 -- end

                            dataCaseUpdatesObject.time = result[j].childComment.comment.LastModifiedDate;
                            dataCaseUpdatesObject.role = 'Test';
                            dataCaseUpdatesObject.countdown = '10Mins';
                            dataCaseUpdatesObject.header = result[j].childComment.comment.Comment_Category__c;
                            dataCaseUpdatesObject.commentType = result[j].childComment.comment.Type__c;
                            //@Akhilesh 2 June 2021 -- start [I2RT-2896]
                            //dataCaseUpdatesObject.userPhoto = result[j].childComment.comment.CreatedBy.SmallPhotoUrl;
                            if (result[j].childComment.comment.CreatedBy.SmallPhotoUrl != undefined) {
                                dataCaseUpdatesObject.userPhoto = result[j].childComment.comment.CreatedBy.SmallPhotoUrl;
                            }
                            else {
                                dataCaseUpdatesObject.userPhoto = '/profilephoto/005/T';
                            }
                            //@Akhilesh 2 June 2021 -- end [I2RT-2896]

                            dataCaseUpdatesObject.inbound = result[j].childComment.comment.Inbound__c;
                            dataCaseUpdatesObject.comment = result[j].childComment.comment.Comment__c;

                            if (childCommentsByParentId.get(mapKey) !== undefined) {
                                dataCaseUpdates = childCommentsByParentId.get(mapKey);
                                dataCaseUpdates.push(dataCaseUpdatesObject);
                                childCommentsByParentId.set(mapKey, dataCaseUpdates);
                            } else {
                                dataCaseUpdates.push(dataCaseUpdatesObject);
                                childCommentsByParentId.set(mapKey, dataCaseUpdates);
                            }
                        }

                    }
                    log('@@childCommentsByParentId= ' + JSON.stringify(childCommentsByParentId));
                    for (let i in result) {
                        let dataCaseUpdatesObject = {};
                        let dataCaseUpdates = [];
                        let caseType = result[i].comment.Type__c;

                        /*let modifiedDate = result[i].comment.LastModifiedDate;
                        let indexOfT = modifiedDate.indexOf('T');
                        modifiedDate = modifiedDate.substring(0, indexOfT);
                        log('@@modifiedDate= ' + modifiedDate);*/

                        //Vignesh D: 18-Oct-2021 -------START-------

                            //Convert datetime to User's system timezone & then use it for grouping case comments
                            let modifiedDate = result[i].comment.LastModifiedDate;
                            let convertedDateTime = new Date(modifiedDate);
                            let convertedDate = `${convertedDateTime.getFullYear()}-${(convertedDateTime.getMonth()+1).toString().padStart(2,'0')}-${convertedDateTime.getDate().toString().padStart(2,'0')}`; //'2021-10-18'
                            modifiedDate = convertedDate;
                            log('ModifiedDate: '+modifiedDate);

                        //Vignesh D: 18-Oct-2021 -------END---------

                        dataCaseUpdatesObject.id = result[i].comment.Id;

                        //@Akhilesh 13 July 2021 --start
                        //dataCaseUpdatesObject.CreatedBy = result[i].comment.CreatedBy.Name;
                        dataCaseUpdatesObject.CreatedBy = objUtilities.isNotBlank(result[i].comment.Created_By__c) ? result[i].comment.Created_By__c : result[i].comment.CreatedBy.Name.toLowerCase() == 'infa support' ? 'Informatica Support' : result[i].comment.CreatedBy.Name; //<T12>
                        //@Akhilesh 13 July 2021 --end
                        if(result[i].comment.Sub_Type__c && result[i].comment.Sub_Type__c == 'Initial Response'){
                            dataCaseUpdatesObject.CreatedBy = INFORMATICA_SUPPORT;
                        }

                        dataCaseUpdatesObject.time = result[i].comment.LastModifiedDate;
                        dataCaseUpdatesObject.role = 'Test';
                        dataCaseUpdatesObject.countdown = '10Mins';
                        dataCaseUpdatesObject.header = result[i].comment.Comment_Category__c;
                        dataCaseUpdatesObject.commentType = result[i].comment.Type__c;
                        if (caseType === 'Revise Priority') {
                            // dataCaseUpdatesObject.iconName = 'standard:einstein_replies';
                            dataCaseUpdatesObject.iconName = ESUPPORT_RESOURCE + '/revise_priority.png';
                            dataCaseUpdatesObject.className ="es-timeline__icon es-timeline__icon--critical";
                        } else if (caseType === 'Escalation') {
                            // dataCaseUpdatesObject.iconName = 'standard:data_streams';
                            dataCaseUpdatesObject.iconName = ESUPPORT_RESOURCE + '/escalate.png';
                            dataCaseUpdatesObject.className ="es-timeline__icon es-timeline__icon--critical";
                        } else if (caseType === 'Callback') {
                            // dataCaseUpdatesObject.iconName = 'standard:call';
                            dataCaseUpdatesObject.iconName = ESUPPORT_RESOURCE + '/call_from_eng.png';
                            dataCaseUpdatesObject.className ="es-timeline__icon es-timeline__icon--regular";
                        } else {
                            // dataCaseUpdatesObject.iconName = 'standard:case';
                            dataCaseUpdatesObject.iconName = ESUPPORT_RESOURCE + '/new_case.png';
                            dataCaseUpdatesObject.className ="es-timeline__icon es-timeline__icon--regular";
                        }
                        //@Akhilesh 2 June 2021 -- start [I2RT-2896]
                        //dataCaseUpdatesObject.userPhoto = result[i].comment.CreatedBy.SmallPhotoUrl;
                        if (result[i].comment.CreatedBy.SmallPhotoUrl != undefined) {
                            dataCaseUpdatesObject.userPhoto = result[i].comment.CreatedBy.SmallPhotoUrl;
                        }
                        else {
                            dataCaseUpdatesObject.userPhoto = '/profilephoto/005/T';
                        }
                        //@Akhilesh 2 June 2021 -- end [I2RT-2896]

                        dataCaseUpdatesObject.inbound = result[i].comment.Inbound__c;
                        dataCaseUpdatesObject.comment = result[i].comment.Comment__c;
                        if (childCommentsByParentId.get(result[i].comment.Id) !== undefined) {
                            dataCaseUpdatesObject.isChildCommentAvailable = true;
                            dataCaseUpdatesObject.childComments = [];
                            dataCaseUpdatesObject.childComments = childCommentsByParentId.get(result[i].comment.Id);
                        } else {
                            dataCaseUpdatesObject.isChildCommentAvailable = false;
                        }

                        if (commentByDate.get(modifiedDate) !== undefined) {
                            dataCaseUpdates = commentByDate.get(modifiedDate);
                            dataCaseUpdates.push(dataCaseUpdatesObject);
                            commentByDate.set(modifiedDate, dataCaseUpdates);
                        } else {
                            dataCaseUpdates.push(dataCaseUpdatesObject);
                            commentInfo.push({ value: dataCaseUpdates, key: modifiedDate });
                            commentByDate.set(modifiedDate, dataCaseUpdates);
                        }

                    }
                    log('@@commentInfo= ' + JSON.stringify(commentInfo));
                    this.caseCommentByDate = commentInfo;

                    log('@@datainAttribute= ' + JSON.stringify(this.caseCommentByDate));
                }
            })
            .catch (error => {
                log("Case Comments Error - " + JSON.stringify(error))
            });
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT - 2662) -> Metadata Enhancement
    @wire(getRecord, { recordId: '$metadataRecordId', fields: METADATA_FIELDS })
    metadataRecord({ error, data }) {
        if (data) {
            log("Watch: metadataRecord data -> " + JSON.stringify(data));

            this.liveAssistRequest_SuccessMessage = data.fields.Live_Assistance_Request_Success_Message__c.value; // LAR Success Message
            log("Watch: metadata liveAssistRequest_SuccessMessage -> " + this.liveAssistRequest_SuccessMessage);

            this.liveAssistRequest_FailureMessage = data.fields.Live_Assistance_Request_Failure_Message__c.value; // LAR Failure Message
            log("Watch: metadata liveAssistRequest_SuccessMessage -> " + this.liveAssistRequest_FailureMessage);
        } else if (error) {
            log("Watch: metadataRecord error -> " + JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: '$suppContactMetadataId', fields: 'Service_Cloud_General_Setting__mdt.eSupport_Contact_Page__c' })
    metaRecord({ error, data }) {
        if(data){
            log('metaRecord data ==> '+JSON.stringify(data));
            this.supportContactURL = data.fields.eSupport_Contact_Page__c.value;
        }
        else if(error){
            log('metaRecord error => '+error);
        }
    }

    @wire(getRecord, { recordId: '$suppAcceptSolutionMetadataId', fields: 'Service_Cloud_General_Setting__mdt.eSupport_Accept_Solution_Message__c' })
    metaRecord({ error, data }) {
        if(data){
            log('metaRecord data ==> '+JSON.stringify(data));
            this.acceptSolutionMessage = data.fields.eSupport_Accept_Solution_Message__c.value;
        }
        else if(error){
            log('metaRecord error => '+error);
        }
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request (Bug: I2RT-2663)
    showCustomToast(t, msg, v, mde) {
        const toast = new ShowToastEvent({
            title: t,
            message: msg,
            variant: v,
            mode: mde
        });
        this.dispatchEvent(toast);
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    openLiveAssistanceModal() {
        this.isLiveAssistanceModal = true;
        this.addCommentModalButtonCSS = (this.addCaseCommentValidator()) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
        this.disableLiveAssistConfirmButton = (this.liveAssistReasonValidator()) ? false : true;
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Live Assistance");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    closeLiveAssistanceModal() {
        this.isLiveAssistanceModal = false;
        this.liveAssistanceRequestReason = '';
    }

    liveAssistReasonValidator() {
        if (this.liveAssistanceRequestReason && this.liveAssistanceRequestReason.trim().length != 0) return true;
        if (!this.liveAssistanceRequestReason || this.liveAssistanceRequestReason.trim().length === 0) return false;
    }

    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    handleLiveAssistReasonChange(event) {
        this.liveAssistanceRequestReason = event.detail.value;
        this.liveAssistConfirmButtonCSS = (this.liveAssistReasonValidator()) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
        this.disableLiveAssistConfirmButton = (this.liveAssistReasonValidator()) ? false : true;
    }

    // Tejasvi Royal -> I2RT - 1966: Live Assistance Request
    confirmLiveAssistanceReason() {
        this.showSpinner = true;
        // IF: Live Assistance Request -> Reason value is "Valid" AND Confirm Button is NOT disabled
        if (this.liveAssistReasonValidator() && !this.disableLiveAssistConfirmButton) {
            confirmLiveAssistReason({ caseId: this.caseDetail.Id, requestReason: this.liveAssistanceRequestReason })
                .then(result => {
                    this.showSpinner = false;
                    this.closeLiveAssistanceModal();
                    log('Live Assistance Result => ' + result);
                    if (this.liveAssistRequest_SuccessMessage) { // IF: LAR Success Message value is "Truthy"
                        this.showCustomToast('Confirmed!', this.liveAssistRequest_SuccessMessage, 'success', 'dismissable');
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.closeLiveAssistanceModal();
                    log("Live Assistance Error => " + JSON.stringify(error));
                    if (this.liveAssistRequest_FailureMessage) { // IF: LAR Failure Message value is "Truthy"
                        this.showCustomToast('Failed to Confirm!', this.liveAssistRequest_FailureMessage, 'error', 'dismissable');
                    }                  
                });
        } 
        // IF: Live Assistance Request -> Reason value is "Invalid" OR Confirm Button is disabled
        if (!this.liveAssistReasonValidator() || this.disableLiveAssistConfirmButton) {
            this.showSpinner = false;
            this.closeLiveAssistanceModal();
            log("Live Assistance Error => " + "Values were attempted to be modified and submitted.");
            if (this.liveAssistRequest_FailureMessage) { // IF: LAR Failure Message value is "Truthy"
                this.showCustomToast('Failed to Confirm!', this.liveAssistRequest_FailureMessage, 'error', 'dismissable');   
            }
        }
    }

    closeReopenCaseModal() {
        this.isReopenCaseModal = false;
        this.isReopenOptionModal = true;
        this.isReopenConfirmedModal = false;
    }

    openCloseCaseModal() {
        this.isCloseCaseModal = true;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Close Case");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }
    closeCloseCaseModal() {
        this.isCloseCaseModal = false;
        this.isCloseOptionModal = true;
        this.isCloseConfirmedModal = false;
        document.body.classList -= ' modal-open';
    }

    openAlternateContactModal() {
        this.isAlternateContactModal = true;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Add Alternate Contact");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }
    openCreateContactModal() {
        this.isCreateContactModal = true;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Create New Contact");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }
    closeCreateContactModal() {
        this.isCreateContactModal = false;
        document.body.classList -= ' modal-open';
    }
    closeAlternateContactModal() {
        document.body.classList -= ' modal-open';
        this.isAlternateContactModal = false;
    }
    openDeleteModal() {
        this.isDeleteModal = true;
        document.body.classList += ' modal-open';
    }
    closeDeleteModal() {
        this.isDeleteModal = false;
        document.body.classList -= ' modal-open';
    }
    
    openEscalateCaseModal() {

        //<T15>
        let isValidEscalateClick = this.validateEscalateClick();
        if(isValidEscalateClick == false)
        {
            return;
        }
        //</T15>

        this.checkIRCompletionDetails(this.caseRecordId);
        this.isEscalateCaseModal = true;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Escalate Case");
        }
        catch(ex) {
            log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
    }

    //<T15>

    validateEscalateClick()
    {
        let arDetails = this.getActiveAttentionRequestDetails();
        if(arDetails != null)
        {
            let errorMessage = 'Please be advised that the prior request - '+ arDetails.attentionRequest + ' is in progress.';
            errorMessage+= ' Kindly anticipate receiving the response by ' + arDetails.slaTime + ' , and there is no need for any additional steps to be taken.';
            this.showCustomToast('Please Note', errorMessage, 'error', 'sticky');
            return false;
        }

        if(this.caseMileStoneDetails.IsActiveIRMilestoneExists == true)
        {
            let slaTime = !!this.caseMileStoneDetails.IRSLATime ? new Date(this.caseMileStoneDetails.IRSLATime) : null;

            let formattedSLATime = '';
            if(slaTime != null)
            {
                formattedSLATime = this.getFormattedDateTime(slaTime, this.caseDetail?.Case_Timezone__r?.TimeZoneSidKey__c);
            }

            let errorMessage = 'Please be informed that the ongoing work on the support case\'s initial response is underway.';
            errorMessage+= ' Kindly anticipate receiving the response by ' + formattedSLATime + ' , and there is no need for any additional steps to be taken.';
            this.showCustomToast('Please Note', errorMessage, 'error', 'sticky');
            return false;
        }

        if(this.caseMileStoneDetails.IsActiveARMilestoneExists == null)
        {
            let errorMessage = '';

            if(this.caseDetail.Priority == 'P1')
            {
                errorMessage = 'Please consider using the \'Callback Engineer\' option before proceeding with escalation.';
            }
            else
            {
                errorMessage = 'Please consider using the \'Callback Engineer\' or \'Revise Priority\' options before proceeding with escalation.';
            }

            this.showCustomToast('Please Note', errorMessage, 'error', 'sticky');
            return false;
        }
        return true;
    }

    //</T15>

    escalateCaseUpdate() {
        this.showSpinner = true;
        this.template.querySelector('.escalateEngineerContact').click();
    }

    closeEscalateCaseModal() {
        this.isEscalateCaseModal = false;
        this.isEscalateOptionModal = true;
        this.isEscalateConfirmedModal = false;
        document.body.classList -= ' modal-open';  
    }

    openEditModal(event) {
        this.isEditModal = true;
        let row = event.target.value
        this.currentDocId = row.ContentDocumentId;
        this.currentDocument = row.ContentDocument;         //Amarender - Added as part of I2RT-3380
        this.docDescription = row.ContentDocument.Description;
        this.docPrevDescription = row.ContentDocument.Description;
        this.discardModalTitle = this.isAddUpdateAttachment ? 'Add Updates/Files' : 'Edit Files';
        log('currentDocId : ' + this.currentDocId);
        log('docDescription : ' + this.docDescription);
    }

    closeEditModal(event) {
        this.isEditModal = false;
        event.target.name= 'editFiles';
        this.closeAddAttachment(event);
    }

    // handleToggle(event) {
    //     this.buttonClicked = !this.buttonClicked;
    //     let currentSection = event.target;
    //     let targetSection = event.target.dataset.targetId;
    //     this.template.querySelector(`[data-id="${targetSection}"]`).classList.toggle('slds-hide');
    //     currentSection.iconName = this.buttonClicked ? 'utility:right' : 'utility:down';
    // }
    @track buttonClicked = true;
    @track iconName = 'utility:down';
    @track className = 'slds-media slds-media_center es-slds-media slds-show';
    handleToggle(event) {
        let currentDiv = event.target;
        let targetIdentity = event.target.dataset.targetId;
        let targetDiv = this.template.querySelector(`[data-id="${targetIdentity}"]`);
        targetDiv.buttonClicked = !targetDiv.buttonClicked;
        targetDiv.className = targetDiv.buttonClicked ? 'slds-media slds-media_center es-slds-media slds-hide' : 'slds-media slds-media_center es-slds-media slds-show';
        currentDiv.iconName = targetDiv.buttonClicked ? 'utility:right' : 'utility:down';
    }

    get aaeTask(){
        if(this.caseDetail.RecordType.DeveloperName == this.RECORD_TYPE.ASK_AN_EXPERT){
        return true;
        }
        else{ 
        return false;
        }
    }
    get operationalTask(){
        if(this.caseDetail.RecordType.DeveloperName == this.RECORD_TYPE.OPERATIONS){
        return true;
        }
        else{ 
        return false;
        }
    }

    get optionsEscalate() {
        if(this.isIRCompleted){
            return [
                //{ label: 'Initial Response Too Slow', value: 'Initial Response Too Slow' },
                { label: 'No resolution received', value: 'No resolution received' },
                { label: 'Solution Provided Unacceptable', value: 'Solution Provided Unacceptable' },
                { label: 'Lack of On-going communication', value: 'Lack of On-going communication' },
                { label: 'Quality Of Service', value: 'Quality Of Service' }
            ]
        }
        else{
            return [
                { label: 'Initial Response Too Slow', value: 'Initial Response Too Slow' },
                { label: 'No resolution received', value: 'No resolution received' },
                { label: 'Solution Provided Unacceptable', value: 'Solution Provided Unacceptable' },
                { label: 'Lack of On-going communication', value: 'Lack of On-going communication' },
                { label: 'Quality Of Service', value: 'Quality Of Service' }
            ]
        }
    }
    removeAttachmentDetails(event) {
        this.fileToRemove = event.target.value;
        this.isDeleteModal = true;
    }

    confirmFileRemoveDetail() {
        this.showSpinner = true;
        log('called' + this.fileToRemove);
        removeFile({ documentId: this.fileToRemove, caseId: this.caseDetail.Id })
            .then(result => {
                if (result) {
                    log('result= ' + JSON.stringify(result));
                    this.caseAttachments = result;
                    this.isDeleteModal = false;
                    this.refreshCaseComments();
                    const toast = new ShowToastEvent({
                        title: 'Deleted Successfully',
                        message: result,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toast); 
                }
                this.showSpinner = false;
            });
    }

    cancelFileRemoveDetail(event) {
        this.fileToRemove = '';
        this.isDeleteModal = false;
        this.closeAddAttachment(event);
    }

    deleteContact(event) {
        this.contactIdToDelete = event.target.value;
        this.isDeleteContactModal = true;
    }

    confirmDeleteContact() {
        log('caseContactId= ' + this.contactIdToDelete);
        removeCaseContact({ caseContactId: this.contactIdToDelete, caseId: this.caseDetail.Id }) //<T09>
            .then(result => {
                this.reRender();
                this.showSpinner = false;
                this.isDeleteContactModal = false;
                this.showCustomToast('', 'Removed Successfully!', 'success', 'dismissable');
            })
            .catch(error => {
                log('Error on removing: '+JSON.stringify(error));
                this.showCustomToast('Failed to Remove!', 'An error occurred while removing Case Contact', 'error', 'dismissable');
            });
    }

    closeDeleteContactModal() {
        this.isDeleteContactModal = false;
    }

    handleDocDescriptionChange(event) {
        this.docDescription = event.detail.value;
    }
    
    

    //Amarender - I2RT-3151 - Added as part of eSupport Demo
    handleCommentsChange(event) {
        
        this.uploadComments = event.detail.value;
        this.docComments=event.detail.value;
    }

    handleUploadFinished(event) {
        log('@@@---this.uploadedFiles---->>>',JSON.stringify(this.uploadedFiles));
        if(this.uploadedFiles.length > 0){
            for(var i=0;i<event.detail.files.length;i++){
                this.uploadedFiles.push(event.detail.files[i]);
            }
            
        }else{
            this.uploadedFiles = event.detail.files;
        }
        log(this.uploadedFiles);
        log('@@@---this.uploadedFiles--After add-->>>',JSON.stringify(this.uploadedFiles));
        this.uploadedFileNames = [...this.uploadedFiles].map(file => {
            return file.name;
        });
        log('fileDetails= ' + JSON.stringify(this.uploadedFiles));
        this.uploadedDocId = this.uploadedFiles[0].documentId;
        log('docId= ' + this.uploadedDocId);
        if(this.currentDocId != null && this.currentDocId != '' && this.currentDocId != 'undefined'){
            //Amarender - Added as part of I2RT-3380
            this.replacedFiles = [...this.uploadedFiles].map(file =>{
                return file.name;
            });
            //Amarender - Added as part of I2RT-3380
            this.deleteDocumentId = this.currentDocId;
        }
        log('fileDetails2= ' + JSON.stringify(this.uploadedFiles));
        log(this.uploadedFiles);
    }

    handleRemove(event){
        this.showSpinner = true;
        log('handleRemove  clicked:  ');
        log('event.detail.value :  ' + event.target.name);
        let deleteDocumentId = event.target.name;
        let deleteDocumentsLst = [];
        deleteDocumentsLst.push(deleteDocumentId);
        if(deleteDocumentId != null && deleteDocumentId != '' && deleteDocumentId != 'undefined'){
            deleteDoc({deleteDocuments : deleteDocumentsLst}).then(result =>{
                log('result : ' + result);
                log('this.uploadedFiles length :' + this.uploadedFiles.length);
                let afterdeletedFiles =[];
                [...this.uploadedFiles].map(record =>{
                    if(record.documentId == deleteDocumentId){
                        delete this.uploadedFiles[record];
                    }else{
                        afterdeletedFiles.push(record);
                    }
                });
                this.uploadedFiles = afterdeletedFiles;
                log('this.uploadedFiles  :' + this.uploadedFiles);
                if(this.uploadedFiles.length == 0){
                    this.uploadedFiles = [];
                }
                this.showSpinner = false;
                const toast = new ShowToastEvent({
                    title: 'Deleted Successfully',
                    message: result,
                    variant: 'success',
                    mode: 'dismissable'
                });
                // this.dispatchEvent(toast);     
            }).catch(error =>{
                log('Error : ' + error);
                this.showSpinner = false;
                const toast = new ShowToastEvent({
                    title: 'Error Occurred',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                // this.dispatchEvent(toast);                
            });
        }
        
    }

    updateDoc() {
        this.showSpinner = true;
        log(' this.currentDocId : ' + this.currentDocId);
        //Amarender - Added as part of I2RT-3380
        if(this.replacedFiles != null && this.replacedFiles != undefined && this.replacedFiles != '' && this.replacedFiles.length >0){
            let previousFileName = this.currentDocument.Title;
            this.uploadComments = previousFileName + ' is replaced with ' + this.replacedFiles.join(',') ;
            if(this.docDescription != '' && this.docDescription != undefined){
                this.uploadComments = this.uploadComments + "<br>File description : " + this.docDescription;
            }
        }else if(this.uploadedFileNames.length > 0){
            //  let tempComments = 'File Name(s) : ' + this.uploadedFileNames.join(',') + ' uploaded.'+  '<br>Comments : ' + this.uploadComments;
            //  this.uploadComments = tempComments;
            let tempComments = 'File Name(s) : ' + this.uploadedFileNames.join(',') + ' uploaded.';
            if(this.uploadComments != '' && this.uploadComments != undefined){
            this.uploadComments = tempComments + '<br>Comments : ' + this.uploadComments;
            }
        }
        //Amarender - Added as part of I2RT-3380
        log(' this.currentDocId : ' + this.currentDocId);
        let updateDocumentIds = [];
        if(this.uploadedFiles != null && this.uploadedFiles.length > 0){
            log('if');
            updateDocumentIds = [...this.uploadedFiles].map(record =>{
                return record.documentId;
            });
        }else{
            log('else');
            updateDocumentIds.push(this.currentDocId);
        }
        log('updateDocumentIds : ' + updateDocumentIds);
        log('docDescription : ' + this.docDescription);
        //Amarender - I2RT-3151 - Added uploadComments parameter to the updateDocVersion Method Syntax
        updateDocVersion({ docToDelete: this.deleteDocumentId, docToUpdate: updateDocumentIds, docDescription: this.docDescription,uploadComments: this.uploadComments, caseId: this.caseDetail.Id })
            .then(result => {
                if (result) {
                    let toastMessage ;
                    if(this.docDescription != '' && this.docDescription != undefined){
                        toastMessage = 'File Description Updated Successfully';
                    }else if(updateDocumentIds != '' && updateDocumentIds != undefined && updateDocumentIds.length > 0 ){
                        toastMessage = 'File Uploaded Successfully';
                    }else if(this.uploadComments != null &&  this.uploadComments != '' && this.uploadComments != undefined){
                        toastMessage = 'Comments Added Successfully';
                    }
                    this.caseAttachments = [...result.caseDocuments].map(doc =>{
                        doc.canBeEdited = (doc.ContentDocument.CreatedById == this.loggedInUser);
                        doc.canBeDeleted = (doc.ContentDocument.CreatedById == this.loggedInUser);
                        return doc;
                    });
                    this.contentDownloadUrlMap = new Map(Object.entries(result.contentDownloadUrlMap));
                    this.uploadedDocId = '';
                    this.currentDocId = '';
                    this.docDescription = '';
                    this.uploadComments = '';
                    this.uploadedFiles = [];
                    this.deleteDocumentId = '';
                    this.replacedFiles = [];
                    const toast = new ShowToastEvent({
                        title: 'Case Updated',
                        message: toastMessage,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toast); 
                }
                this.isEditModal = false;
                this.showSpinner = false;
                this.refreshCaseComments(); // Tejasvi Royal -> eSupport Feedback Enhancements
                this.reRender();
            }).catch(error =>{
                this.showSpinner = false;
                log('error : '+JSON.stringify(error) );
                const toast = new ShowToastEvent({
                    title: 'Error Occurred',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toast);                
            });
    }

    handleAlternateContacts() {
        this.showSpinner = true;
            this.refreshCaseComments();
            this.reRender();
            this.showSpinner = false; 
            this.isAlternateContactModal = false;
        document.body.classList -= ' modal-open';
    }

    handleNewContacts() {
        this.closeCreateContactModal();
        this.showSpinner = true;
        this.refreshCaseComments();
        this.reRender();
    }

    handleAddAttachmentClick() {
        this.isAddUpdateAttachment = true;
        document.body.classList += ' modal-open';
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Add Updates/Files");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    handleFileDescription(event) {
        this.fileDescription = event.detail.value;
    }

    closeAddModal(event){
        event.target.name = 'addupdateAttachment';
        document.body.classList -= ' modal-open';
        this.closeAddAttachment(event);
    }

    closeAddAttachment(event) {
        this.closedFromModal = event.target.name === 'addupdateAttachment' ? 'addupdateAttachment' : 'editFiles';
        this.closedFromModal == 'addupdateAttachment' ? this.discardModalTitle =  'Add Updates/Files' : this.discardModalTitle = 'Edit Files';
        if ((this.docDescription != '' && this.docDescription != undefined && this.docPrevDescription != this.docDescription) || (this.uploadedDocId != '' && this.uploadedDocId != undefined)){
            this.showDiscardConfirmation = true;
            this.isAddUpdateAttachment = false;
            // this.isAddUpdateAttachment = true;
            log("Doc description", this.docDescription);
            log("Uploaded Doc", this.uploadedDocId);
        }
        else{
            this.isAddUpdateAttachment = false;
            this.uploadComments = null;
            // alert('closeAddAttachment else'+this.docDescription);        // -- Amarender - Added as part of SIT Observed issues
        }
        document.body.classList -= ' modal-open';
    }

    updateFileDetails() {
        var isValidValue = this.validateInputField();
        let isCommentAvailable = this.validateCommentBody();
        if (isValidValue && isCommentAvailable){
            this.updateDoc();
            this.isAddUpdateAttachment = false;
            document.body.classList -= ' modal-open';
        }
    }

    validateCommentBody(){
        const commentBody = this.template.querySelector("[data-name='commentBody']");
        let commentBodyValue = commentBody.value;
        let sCommentData = '';
        log('commentBodyValue : ' + commentBodyValue);
        if(commentBodyValue != '' && commentBodyValue != null && commentBodyValue != undefined){
            let content = '';
            if(commentBodyValue.includes('<p>')){
                const parser = new DOMParser();
                let commentRichText = parser.parseFromString(commentBodyValue,"text/html");
                content = commentRichText.body.getElementsByTagName("p").item(0).innerHTML.trim();
            }else{
                content = commentBodyValue.trim();
            }
            sCommentData = (content != null && content != undefined && content != "") ? commentBodyValue : content;
        }
            if (sCommentData == '' || sCommentData == undefined || sCommentData == null) {
            if (commentBody != undefined) {
                commentBody.focus();
            }
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Comment Body required!',
                variant: 'error'
            }));
            return false;
            }
            return true;
        }

    closeConfirmationDialog(){
        this.showDiscardConfirmation = false;
        this.closedFromModal == 'addupdateAttachment' ? this.isAddUpdateAttachment = true : this.isEditModal = true;
    }

    //Amarender - I2Rt-3151 - Deletion of Multiple Files
    discardAddAttachment(){
        log('Calling delete Doc for bulk deletion - this.uploadedFiles :' + this.uploadedFiles);
        // this.showSpinner = true;
        let deletDocumentsList = [...this.uploadedFiles].map(record =>{
            if(record != null && record != '' && record != 'undefined'){
                return record.documentId;
            }
                
        });
        log('Calling delete Doc for bulk deletion :' + deletDocumentsList);
        deleteDoc({deleteDocuments : deletDocumentsList}).then(result =>{
            log('Bulk Deletion : ' + result);
            this.uploadedFiles = [];
            this.uploadedDocId = '';
            // this.showSpinner = false;
            const toast = new ShowToastEvent({
                title: 'Deleted Successfully',
                message: result,
                variant: 'success',
                mode: 'dismissable'
            });
            // this.dispatchEvent(toast);     
        }).catch(error =>{
            log('Bulk Deletion  error: ' + error);
            this.showSpinner = false;
            const toast = new ShowToastEvent({
                title: 'Error Occurred',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            // this.dispatchEvent(toast);                
        });
        this.isAddUpdateAttachment = false; 
        this.showDiscardConfirmation = false;
        this.docDescription = undefined;
        this.uploadComments = null;             //Amarender -- resetting comments when discarded
    }

    validateInputField(){
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isValidValue;
    }


    handleReasonForPriorityRevison(event) {
        this.reasonForChangePriority = event.detail.value;
        this.showRevisePriorityError = false;
        this.errorRevisePriorityClass = '';
    }

    priorityChange(event) {
        log(event.target.value);
        this.selectedPriority = event.target.value;
        if(this.selectedPriority == 'P1'){
            this.showMoreFields = true;
        }else{
            this.showMoreFields = false;
        }
    }

    updateCasePriority() { 
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea,[data-id="businessImpact"]')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        
        /* Commented as part of <T02>
        if(this.selectedImpact === undefined || this.selectedImpact == null){
            this.selectedImpact = null;
            let target = this.template.querySelector(`[data-id="businessImpact"]`);
            //console.log(target);
            //alert(isValidValue);
            isValidValue = [...this.template.querySelectorAll(`[data-id="businessImpact"]`)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            //alert(isValidValue);
            isValidValue = false;
        }*/
        //alert(this.selectedImpact);
        //alert(isValidValue);
        
        if(isValidValue){
            this.showSpinner = true;
            log('@@caseId= ' + this.caseDetail.Id);
            log('@@reasonForChangePriority= ' + this.reasonForChangePriority);
            var priority = ' : ' + this.selectedPriority + '<br/> ';
            var commentDescription = priority + this.reasonForChangePriority;
            if (this.reasonForChangePriority !== '' && this.reasonForChangePriority !== undefined) {
                this.showRevisePriorityError = false;
                this.errorRevisePriorityClass = '';
                //<T02>
                if(this.selectedPriority == 'P2'){
                    this.selectedImpact = null;
                    this.selectedEstimateDate = null;
                }
                //</T02>
                    requestAttn({ caseId: this.caseDetail.Id, requestType: 'Revise Priority', comment: commentDescription ,
    /*I2RT-4421*/ selectedImapact: this.selectedImpact, estimateDate: this.selectedEstimateDate})/*I2RT-4421*/ 
                    .then(result => {
                        log('result== ' + result);
                        this.getResponseTimeDetails('Revise Priority');
                        this.isReviseOptionModal = false;
                        this.isReviseConfirmedModal = true;
                        this.showSpinner = false;
                        this.refreshCaseComments();
                        this.reRender();                //<T14>
                    })
                    .catch(error => {
                        log("error - " + JSON.stringify(error));
                        this.showCustomToast('Error', 'An error occurred, please try again later.', 'error', 'dismissable');
                        this.showSpinner = false;
                    });
            } else {
                this.showRevisePriorityError = true;
                this.errorRevisePriorityClass = 'slds-has-error';
                this.showSpinner = false;
            }
        document.body.classList -= ' modal-open';
        }
    }

    handleCloseCaseReasonChange(event) {
        this.reasonForClosingCase = event.detail.value;
    }

    createCloseCaseRequest() {
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if(isValidValue){
            this.showSpinner = true;
            /*
            requestAttn({ caseId: this.caseDetail.Id, requestType: '', comment: this.reasonForClosingCase })
                .then(result => {
                    log('result== ' + result);
                    this.showSpinner = false;
                    this.isCloseOptionModal = false;
                    this.isCloseConfirmedModal = true;
                })
                .catch(error => {
                    log("error - " + JSON.stringify(error))
                });
            */
            closeCaseRequest({ caseId: this.caseDetail.Id, comment: this.reasonForClosingCase })
                .then(result => {
                    log(result);
                    this.showSpinner = false;
                    this.isCloseOptionModal = false;
                    this.isCloseConfirmedModal = true;
                    this.refreshCaseComments();
                })
                .catch(error => {
                    this.showCustomToast('Error', 'An error ocurred, please try again later.', 'error', 'dismissable');
                    this.showSpinner = false;
                })
            document.body.classList -= ' modal-open';
        }
    }

    handleReOpenReasonChange(event) {
        this.reasonForReOpenCase = event.detail.value;
    }

    reOpenCase() {
        this.showSpinner = true;
        var commnet=this.reasonForReOpenCase;
        if (typeof commnet == "undefined") {
            commnet='';
            this.showSpinner = false;
            return;
        }
        
        /*
        requestAttn({ caseId: this.caseDetail.Id, requestType: '', comment: this.reasonForReOpenCase })
            .then(result => {
                log('reOpenCaseCOmment== ' + result);
                reOpenCase({ caseId: this.caseDetail.Id })
                    .then(result => {
                        log('CreateReopenCase== ' + JSON.stringify(result));
                        if (result) {
                            var caseObj = result;
                            this.caseNumber = caseObj.CaseNumber;
                            this.reOpenedCaseId = caseObj.Id;
                            this.showSpinner = false;
                            this.isReopenOptionModal = false;
                            this.isReopenConfirmedModal = true;
                        }
                    })
                    .catch(error => {
                        log("ReOpen Case process - " + JSON.stringify(error))
                    });
            })
            .catch(error => {
                log(" - " + JSON.stringify(error))
            });
        */
            reOpenCase({ caseId: this.caseDetail.Id, reopenReason: commnet })
                .then(result => {
                    log('CreateReopenCase== ' + JSON.stringify(result));
                    if (result) {
                        var caseObj = result;
                        this.caseNumber = caseObj.CaseNumber;
                        this.reOpenedCaseId = caseObj.Id;
                        this.showSpinner = false;
                        this.isReopenOptionModal = false;
                        this.isReopenConfirmedModal = true;
                        this.refreshCaseComments();
                    }
                })
                .catch(error => {
                    log("ReOpen Case process - " + JSON.stringify(error));
                    this.showCustomToast('Error', 'An error occurred while reopening case.', 'error', 'dismissable');
                    this.showSpinner = false;
                });
    }

    reDirectToReOpenedCase() {
        var url = CommunityURL + 'casedetails?caseId=' + this.reOpenedCaseId;
        window.open(url, '_self');
    }

    handleCallBackCaseUpdate() {
        this.showContactEditForm = false;
        this.isCallBackOptionModal = true;
        this.isCallBackConfirmedModal = false;
        this.showSpinner = false;
    }

    handleAlternateNumberChange(event) {
        this.alternateNumber = event.detail.value;
    }

    handleCallBackReasonChange(event) {
        this.callBackReason = event.detail.value;
    }

    handleNoClick(event){        
        this.isEditModal = false;
        this.closeAddAttachment(event);
            
    }

    confirmCallBackCaseModal() {
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if(isValidValue){
            var comment = '';
            if(this.alternateNumber !== undefined && this.alternateNumber != null){
                comment = '<br><b>Alternate Contact: </b>' + this.alternateNumber;  
            }
            comment = comment + '<br>' + this.callBackReason;

            this.showSpinner = true;
            requestAttn({ caseId: this.caseDetail.Id, requestType: 'Callback', comment: comment })
                .then(result => {
                    log('result== ' + result);
                    this.getResponseTimeDetails('Callback');
                    this.showSpinner = false;
                    this.isCallBackOptionModal = false;
                    this.isCallBackConfirmedModal = true;
                    this.reRender();                //<T14>
                    this.refreshCaseComments(); 
                })
                .catch(error => {
                    log("error - " + JSON.stringify(error));
                    this.showCustomToast('Error', 'An error occurred, please try again later.', 'error', 'dismissable');
                    this.showSpinner = false;
                });
        }
    }

    handleCallbackPhoneOnChange(event) {
        this.callBackUpdatedPhone = event.detail.value;
    }

    updateCallBackContact() {
        this.showSpinner = true;
        document.body.classList -= ' modal-open';
        this.template.querySelector('.callBackEngineerContact').click();
    }

    handleAlternateNumberChange(event) {
        this.alternateNumber = event.detail.value;
    }

    handleEscalateReasonOptionChange(event) {
        this.selectedEscalateReason = event.detail.value;
    }

    handleEscalateReasonChange(event) {
        this.escalateReason = event.detail.value;
    }

    backToEscalateModal() {
        this.showSpinner = false;
        this.isEscalateOptionModal = true;
        this.showContactEditForm = false;
        this.isEscalateConfirmedModal = false;
    }

    showEscalateContactForm() {
        this.isEscalateOptionModal = false;
        this.showContactEditForm = true;
        this.isEscalateConfirmedModal = false;
    }
    isValidInput(input){
        return (input && input?.replace(/<[^>]+>/g, '')?.trim().length > 0) ? true : false;
    }
    confirmEscalateCaseModal() {
        var isValidValue = [...this.template.querySelectorAll('lightning-textarea,lightning-radio-group')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        this.richClass = '';
        this.requiredMessage = '';
        log('@@00this.escalateReason-->>'+this.escalateReason);
        if(!this.isValidInput(this.escalateReason)){
            isValidValue = false;
            this.richClass = 'required';
            this.requiredMessage ='This field is required.';
        }
        
        if(isValidValue){
            
            this.showSpinner = true;
            var comment = '';
            if(this.alternateNumber !== undefined && this.alternateNumber != null){
                comment = '<br><b>Alternate Contact: </b>' + this.alternateNumber;
            }
            comment = comment + ' <br/>' + this.escalateReason;
            escalateCase({ caseIds: this.caseDetail.Id, reason: this.selectedEscalateReason, comment: comment })
                .then(result => {
                    log('result== ' + result);
                    this.getResponseTimeDetails('Escalation');
                    this.showSpinner = false;
                    this.isEscalateOptionModal = false;
                    this.isEscalateConfirmedModal = true;
                    this.reRender();                //<T14>
                    this.refreshCaseComments(); // Tejasvi Royal -> eSupport Feedback Enhancements
                })
                .catch(error => {
                    log("error - " + JSON.stringify(error));
                    this.showCustomToast('Error', 'An error occurred while escalating case.', 'error', 'dismissable');
                    this.showSpinner = false;
                });
        }
        
    }

    //Vignesh D: I2RT-2847
    getResponseTimeDetails(action){
        this.responseDateTime = undefined;
        getResponseTime({caseId: this.caseDetail.Id, type: action})
            .then(result => {
                log(`Response Time: ${result}`);
                this.responseDateTime = result ? result : undefined;
            })
            .catch(error => {
                log('Error getting response time: '+JSON.stringify(error));
            });
    }

    checkIRCompletionDetails(caseId){
        checkIRCompletion({caseId: caseId})
            .then(result => {
                log('IR= '+result);
                this.isIRCompleted = result;
            })
            .catch(error => {
                log('error: '+JSON.stringify(error));
            })
    }

    //@Amarender 06 May 2021 -- start
    //Track Solution Status on Case Solution Stage
    //I2RT-1020: eSupport: Solutions Page
    handleAcceptSolutionClick() {
        this.showSpinner = true;
        log('handleAcceptSolutionClick');
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Accept Solution");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
        trackSolutionStatus({ caseId: this.caseDetail.Id, decision: 'Accepted', comments: 'Customer Accepted the Soultion and case will be closed', expectedDate: null })
            .then(result => {
                this.showSpinner = false;
                log('result= ' + result);
                if (result != null && result == 'Closed') {
                    this.isInSolutionState = false;
                    this.updateStatusTracker(result);
                    const toast = new ShowToastEvent({
                        title: 'Solution Accepted',
                        message: 'Thank you for the update. The Case is Closed now.',
                        variant: 'success',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toast);
                    this.isClosed = true;
                    this.buttonCss = (this.isClosed) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
                }
                this.openAcceptmodal = false;
                this.refreshCaseComments();
                this.reRender();
            }).catch(error => {
                this.showSpinner = false;
                this.openAcceptmodal = false;
                log('error= '+JSON.stringify(error));
                const toast = new ShowToastEvent({
                    title: 'Server Error',
                    message: error,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toast);
            });
    }

    handleNeedMoreTimeClick() {
        this.isNeedMoreTimeModal = true;
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Need More Time");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }
    
    handleDeclineSolutionClick() {
        this.isDeclineSolutionModal = true;
            /** START-- adobe analytics */
            try {
            util.trackButtonClick("Decline Solution");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    handleExpectedDateChange(event) {
        this.isSelectedPastDate = false;
        var today =  new Date();
        var selectedDate = new Date(event.detail.value);
        var isItToday = today.toString().includes(selectedDate.toString().substr(0,15));

        this.isSelectedPastDate = (selectedDate < today && !isItToday)? true : false;

        if (this.isSelectedPastDate ) {
            this.isSelectedPastDate = true;
            this.validateNeedMoreTimeConfirmButton();
            log('Selected Past Date');
            return;
        }
        this.expectedDate = event.detail.value;
        this.validateNeedMoreTimeConfirmButton();
    }

    validateNeedMoreTimeConfirmButton(){
        this.buttonCss = (this.needMoreTimeReason  && !this.isSelectedPastDate && this.expectedDate) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
        this.disableConfirmButton = (this.needMoreTimeReason  && !this.isSelectedPastDate && this.expectedDate) ? false : true;     //<T01>
    }

    handleNeedMoreTimeReasonChange(event) {
        this.needMoreTimeReason = event.detail.value;
        this.validateNeedMoreTimeConfirmButton();
    }

    handleDeclineSolutionReasonChange(event) {
        this.declineSolutionReason = event.detail.value;
        this.buttonCss = (this.declineSolutionReason) ? 'es-button es-button--primary' : 'es-button es-button--secondary';
        this.disableConfirmButton = (this.declineSolutionReason) ? false : true;
    }

    closeNeedMoreTimeModal() {
        this.isNeedMoreTimeModal = false;
    }

    closeDeclineSolutionModal() {
        this.isDeclineSolutionModal = false;
    }

    closecaseModal() {
        this.caseclosedmodal = false;
    }

    closeAcceptModal(){
        this.openAcceptmodal = false;
    }

    confirmAccept(){
        this.handleAcceptSolutionClick();
    }

    confirmNeedMoreTimeReason() {
        this.closeNeedMoreTimeModal();
        this.showSpinner = true;
        let needMoreTimeComments = '<b>Need More Time :</b> '+'<br>Expected Date : ' + this.expectedDate + '<br>Reason for Delay : ' + this.needMoreTimeReason ;
        trackSolutionStatus({ caseId: this.caseDetail.Id, decision: 'NeedMoreTime', comments: needMoreTimeComments, expectedDate: this.expectedDate })
            .then(result => {
                this.showSpinner = false;
                log('result= ' + result);
                if (result != null && result == 'Solution') {
                    this.isInSolutionState = true;
                    this.updateStatusTracker(result);
                }
                this.refreshCaseComments();
            }).catch(error => {
                this.showSpinner = false;
                this.openAcceptmodal = false;
                log('error= '+JSON.stringify(error));
                const toast = new ShowToastEvent({
                    title: 'Server Error',
                    message: error,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toast);
            });
    }

    confirmDeclineSolutionReason() {
        this.closeDeclineSolutionModal();
        this.showSpinner = true;
        let solutionDeclinedComments = '<b> Solution Declined : </b>'+'<br>Reason for Decline : ' +this.declineSolutionReason;
        trackSolutionStatus({ caseId: this.caseDetail.Id, decision: 'Declined', comments: solutionDeclinedComments, expectedDate: null })
        .then(result => {
            this.showSpinner = false;
            log('result= ' + result);
            if (result != null && result == 'Research') {
                this.isInSolutionState = false;
                this.updateStatusTracker(result);
                const toast = new ShowToastEvent({
                    title: 'Solution Declined',
                    message: 'Thank you for the update. The Support Engineer will review your comments and get back to you.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toast);
            }
            this.refreshCaseComments();
        }).catch(error => {
            this.showSpinner = false;
            this.openAcceptmodal = false;
            log('error= '+JSON.stringify(error));
            const toast = new ShowToastEvent({
                title: 'Server Error',
                message: error,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toast);
        });
    }
    //@Amarender 06 May 2021 -- end

    processCaseContacts(result){
        let accountContacts = new Map();
        result.accountContacts.forEach(accContact => {
            accountContacts.set(accContact.ContactId, accContact?.Access_Level__c);
        });
        let caseContacts = result.caseContacts;
        caseContacts.forEach(caseContact => {
            if(caseContact?.Contact__c){
                caseContact.AccessLevel = accountContacts.has(caseContact.Contact__c) && accountContacts.get(caseContact.Contact__c) ? accountContacts.get(caseContact.Contact__c) : undefined;
                caseContact.canBeDeleted = (caseContact?.Case__r?.ContactId != caseContact?.Contact__c);
            }else {
                caseContact.canBeDeleted = (caseContact?.Contact__c == null && caseContact?.Email_Formula__c != null);
            }
        });

        this.contacts = caseContacts;
        this.showSpinner = false;
    }

    reRender(){
        getCaseDetails({ caseId: this.caseRecordId })
                .then(result => {
                    this.caseDetail = result.caseRecord;
                    this.disableReOpen = result.disableReOpen;
                    this.isCanceled = this.caseDetail.Status == 'Cancelled' ? true : false;                   //Piyush ->
                    this.isInSolutionState = this.caseDetail.Status == 'Solution' ? true : false;        //Amarender -> I2RT-1020: eSupport: Solutions Page
                    this.isClosed = this.caseDetail.Status == 'Closed' ? true : false;                   //Amarender -> I2RT-1020: eSupport: Solutions Page
                    this.isCanceled = this.caseDetail.Status == 'Cancelled' || this.caseDetail.Status == 'Delivered'  ? true : false;                   //Piyush ->
                    if (result.disableReOpen) {
                        this.buttonCss = 'es-button es-button--secondary';
                    } else {
                        this.buttonCss = 'es-button es-button--primary';
                    }
                    this.processCaseContacts(result);
                    this.updateStatusTracker(this.caseDetail.Status);
                    this.fillCaseMilestoneDetails(result);                      //<T14>
                })
                .catch(error => {
                    log("error - " + JSON.stringify(error))
                });
    }

    get showReOpenCase(){
        return !this.disableReOpen && this.isReadWriteContact;
    }

    get showAddAlternateContactBTN(){
        return !this.isClosed && (this.isEcommContact || (this.isReadWriteContact && (this.isPrimaryContact || this.isCasePrimaryContact)));//<T09>
    }
    get showCreateNewContactBTN(){
        return !this.isClosed && this.isReadWriteContact && this.isPrimaryContact;
    }

    get showCaseActionBTNs(){
        return (!this.isClosed && (this.isReadWriteContact || this.caseDetail.RecordType.DeveloperName == this.RECORD_TYPE.CASE_LITE)) && (this.caseDetail.Status && this.caseDetail.Status !== 'Cancelled' && this.caseDetail.Status !== 'Delivered');        //T07
    }

    get showSolutionBTNS(){
            return this.caseDetail?.RecordType?.DeveloperName === this.RECORD_TYPE.OPERATIONS && this.caseDetail?.RCA_Pending_flag__c === 'Yes' ? false : true;
    }

    get showAddCommentBTN(){
        return (!this.isClosed && (this.isReadWriteContact || this.caseDetail.RecordType.DeveloperName == this.RECORD_TYPE.CASE_LITE)) && (this.caseDetail.Status && this.caseDetail.Status !== 'Cancelled' && this.caseDetail.Status !== 'Delivered');        //T07
    }
    
    get showAaeCancelStatus(){ //added by piyush
        return this.caseDetail.Status == 'Cancelled' ? true : false;
    }

    get isTechnicalOrOperations(){ //<T05>
        return this.caseDetail?.RecordType?.DeveloperName === this.RECORD_TYPE.TECHNICAL || this.caseDetail?.RecordType?.DeveloperName === this.RECORD_TYPE.OPERATIONS ? true : false;
    }

    downloadDoc(event){
        log('row details : ' + event.detail);
        log(event.currentTarget.dataset.id);
        let contentDocumentId = event.currentTarget.dataset.id;
        // let url = '/sfc/servlet.shepherd/document/download/' + event.currentTarget.dataset.id;
        let downloadUrl = '';
        this.contentDownloadUrlMap.forEach(function(value, key) {
            if(key == contentDocumentId){
                downloadUrl = value;
            }
        })
        log('downloadUrl' + downloadUrl);
        if(downloadUrl == ''){
            this.showSpinner = true;
            generateDownloadUrl({contentDocumentId : contentDocumentId}).then(
                generatedDownloadUrl => {
                    this.showSpinner = false;
                    log('generatedDownloadUrl' + generatedDownloadUrl);
                    window.open(generatedDownloadUrl,'_self');
                }
            )
        }else{
            window.open(downloadUrl,'_self');
        }
        
    }

    get isAdminCase(){
            return this.caseDetail.RecordType.DeveloperName == this.RECORD_TYPE.ADMININSTRATIVE;
    }

    //Vignesh D: Operations Activity Window cancel & reschedule session
    get showSessionActionBTN(){
            return this.caseDetail?.RecordType?.DeveloperName === this.RECORD_TYPE.OPERATIONS && SCHEDULED_ACTIVITY_TYPE.includes(this.caseDetail?.Activity_Type__c)? true : false;
    }

    showSessionActionClick(){
        this.clearDateSlotFieldValues();
        this.getAvailableSlots();
        this.showSessionActionModal = true;
        /** START-- adobe analytics */
        try {
            util.trackButtonClick("Reschedule Session");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    closeShowSessionActionModal(){
        this.showSessionActionModal = false;
        this.clearDateSlotFieldValues();
    }

    getAvailableSlots(){
        getRescheduleSlots({ caseId: this.caseDetail.Id })
            .then(objSlotsMap => {
                log('available slots >> '+JSON.stringify(objSlotsMap));
                this.processAvailableSlots(objSlotsMap);
            })
            .catch(error => {
                log('error getting available slots >> '+JSON.stringify(error));
            })
    }

    rescheduleSession(){
        var isValidValue = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isValidValue){
            this.showSpinner = true;
            var slot = [];
            slot.push(this.slotStartDT);
            slot.push(this.slotEndDT);
            //call apex class to Reschedule Session
            rescheduleSession({ caseId: this.caseDetail.Id, slotSelected: slot })
                .then(result => {
                    log('reschedule session: '+result);
                    this.showCustomToast('Success!', 'Your Session has been rescheduled successfully.', 'success', 'dismissable');
                    this.showSessionActionModal = false;
                    this.showSpinner = false;
                    this.refreshCaseComments();
                    this.closeShowSessionActionModal();
                    this.reRender();
                })
                .catch(error => {
                    log('reschedule session error: '+JSON.stringify(error));
                    this.showSpinner = false;
                    this.showCustomToast('Error', 'An error ocurred, please try again later.', 'error', 'dismissable');
                });
        }
    }

    clearDateSlotFieldValues(){
        this.selectedDate = undefined;
        this.selectedSlot = undefined;
        this.slotStartDT = undefined;
        this.slotEndDT = undefined;
        this.availableDates = undefined;
        this.availableSlots = undefined;
    }

    handleDateSelect(event){
        this.selectedDate = event.detail.value;
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
    // I2RT-4421
    handleImpactChange(event){
        this.selectedImpact = event.detail.value;
    }
    handleTick(event) {
        this.doesImpactMilestone = event.target.checked;
        if(!this.doesImpactMilestone){
            this.selectedEstimateDate = undefined;
        }
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
        }
    }
    // I2RT-4421

   get orgDetailsURL(){ //<T10>
        return `orgdetails?orgId=${this.caseDetail.Org__c}`;
   }

   get recordTypeName(){ //<T11>
        return this.caseDetail?.RecordType?.DeveloperName == this.RECORD_TYPE.CASE_LITE ? Case_Lite_RecordType_Name : this.caseDetail?.RecordType?.Name; 
   }

}