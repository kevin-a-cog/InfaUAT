/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                           NA
 Sathish R              17-Oct-2022     I2RT-4931           CR Feedback for Publishers' published Articles.            T01
 Sathish R              05-Apr-2023     I2RT-5003           Article archival process to come with pre-defined 
                                                            conditions (similar to Sharepoint setup).                   T02
Sathish R               15-May-2023     I2RT-8359           Send email archival notification to author with KB DL in CC T03
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import publishTranslation from '@salesforce/apex/KBLWCHandler.publishTranslation';
import archiveArticle from '@salesforce/apex/KBLWCHandler.archiveArticle';
import extendAndPublish from '@salesforce/apex/KBLWCHandler.extendAndPublish';
import getAllArticles from '@salesforce/apex/KBLWCHandler.getAllArticles';
import checkForDraftArticle from '@salesforce/apex/KBLWCHandler.checkForDraftArticle';
import COMMUNITYURL from '@salesforce/label/c.KB_Community_Internal';
//Start --> Sathish R --> Jira : I2RT-4931 - T01
import KB_OBJECT from '@salesforce/schema/afl__afl_Article_Feedback__c';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import isUserCRFeedbackSubmitter from '@salesforce/apex/KBArticleHandler.isUserCRFeedbackSubmitter';
import sendAlertOnCRFeedbackWrapper from '@salesforce/apex/KBArticleHandler.sendAlertOnCRFeedbackWrapper';
import sendAlertOnArchivalWrapper from '@salesforce/apex/KBArticleHandler.sendAlertOnArchivalWrapper';//T03
import KBID from '@salesforce/schema/afl__afl_Article_Feedback__c.Knowledge__c';
import KBIDTEXT from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Knowledge_Article_Version_Id__c';
import ARTICLELINK from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Link__c';
import FEEDBACKNAME from '@salesforce/schema/afl__afl_Article_Feedback__c.Name';
import STATUS from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Status__c';
import KBTITLE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Title__c';
import ARTICLENUMBER from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Number__c';
import COMMENTS from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_CR_Feedback_Comments__c';
import ISCRFEEDBACK from '@salesforce/schema/afl__afl_Article_Feedback__c.Is_Article_CR_Feedback__c';
import ARTICLE_AUTHOR from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_CR_Feedback_Recepient__c';
import FEEDBACKUSER from '@salesforce/schema/afl__afl_Article_Feedback__c.Feedback_User__c';
import KBARTICLEVERSIONID from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Knowledge_Article_Version_Id__c';
import USER_ID from '@salesforce/user/Id';
import KBURL from '@salesforce/label/c.KB_URL';
//End --> Sathish R --> Jira : I2RT-4931 - T01
import { NavigationMixin } from 'lightning/navigation';
//Start --> Sathish R --> Jira : I2RT-4931 - T01
import getRelatedKBandCase from '@salesforce/apex/KBArticleHandler.getRelatedKBandCase'; //T02

const KBSVIEWACTION =
    { type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } };//T02

const KBFIELDS = [
    'Knowledge__kav.ArticleNumber',
    'Knowledge__kav.Title',
    'Knowledge__kav.Created_By__c',
    'Knowledge__kav.Language',     //T02 
    'Knowledge__kav.ValidationStatus',   //T02
    'Knowledge__kav.KnowledgeArticleId',    //T02
    'Knowledge__kav.Solution__c',   //T02
    'Knowledge__kav.Internal_Notes__c', //T02
    'Knowledge__kav.Description__c',    //T02
    'Knowledge__kav.Additional_Information__c', //T02
    'Knowledge__kav.Question__c',   //T02
    'Knowledge__kav.Answer__c', //T02
    'Knowledge__kav.Alternate_Questions__c',    //T02
    'Knowledge__kav.PublishStatus'  //T02
];

//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
    try {
        if (ISDEBUGENABLED == true || parType == 'error') {
            if (parType == 'log') {
                console.log(parMessage);
            }
            else if (parType == 'error') {
                console.error(parMessage);
            }
            else if (parType == 'warn') {
                console.warn(parMessage);
            }
        }
    } catch (err) {
        console.log('Utility Log : ' + err.message);
    } finally {

    }
}
//For Loggging in Console
//End --> Sathish R --> Jira : I2RT-4931 - T01

const KB_CREATE_NEW = 'Create New';//T02
const KB_USE_EXISTING = 'Use Existing';//T02
const KB_UPDATED_EXISTING = 'Updated Existing';//T02
const KB_LIKE = 'Like';//T02

export default class KBArticleActions extends NavigationMixin(LightningElement) {
    @api recordId;
    @api copyButton;
    isStillLoading = false;
    @track article;
    @track isTranslation = false;
    @track publishStatus;
    reasonforArchival = '';
    selectedaction;
    feedbackextension = '';
    errormessage;
    draftArticlePresent;
    publickb;
    showcopyurl = false;
    urlvalue;
    pendingTRArticlePresent;
    publishArticlePresent;
    //Start --> Sathish R --> Jira : I2RT-4931 - T01
    @track showcrfeedback = false;
    @track labelbtncrfeedback = 'CR Feedback';
    @track crFeedbackComment = '';
    @track textareacrfeedback = false;
    kbArticleTitle = '';
    kbArticleNumber = '';
    kbArticleAuthor = '';
    kbArticleVersionId = '';
    userId = USER_ID;
    kbRandomNumber = '0000000000';
    kbCustomTitle = '';
    //End --> Sathish R --> Jira : I2RT-4931 - T01

    //Start --> Sathish R --> Jira : I2RT-5003 - T02
    @track wizardtitle = "Submit for Archival";
    @track isModalOpen = false;
    @track isResponseWithSuccess = false;
    @track isResponseWithError = false;
    @track isDataAvailable = false;
    @track showLinkedKB = false;
    @track archivalMessage = '';
    @track isWarningMsgAvaialble = false;
    isArchivalValidateResponseSuccess = true;
    isArchivalResponseSuccess = true;
    @track responseerror = "";
    @track isArticleReadyForArchival = false;
    @track KBReferredArticleDatas = [];
    kbSolution__c = '';
    kbInternal_Notes__c = '';
    kbDescription__c = '';
    kbAdditional_Information__c = '';
    kbQuestion__c = '';
    kbAlternate_Questions__c = '';

    @track kbcolumnswithselect = [
        KBSVIEWACTION,
        { label: 'Id', fieldName: 'Id', type: 'string' },
        { label: 'Title', fieldName: 'Title', type: 'string' },
        { label: 'ArticleNumber', fieldName: 'ArticleNumber', type: 'string' }
    ];

    classNameDesc = " slds-is-collapsed ";
    classNameSubmit = "slds-m-around--medium  slds-is-collapsed";
    classNameBtnSec = "slds-is-collapsed";
    classNameCancel = "slds-m-around--medium  slds-is-collapsed";
    classNameCard = "slds-m-around--small  slds-is-collapsed";
    articleReferenceMsg = '<div style="font-weight: 400;font-size: 15px;text-align: center;">You cannot perform this action unless you remove the reference in Related Knowledge Article section of the following KBs. Please remove the reference and try again.</div>';
    caseReferenceMsg = '<div style="font-weight: 400;font-size: 15px;text-align: center;">This KB is reused to resolve Case CASENUMBER. Do you want to go ahead and archive this KB?</div>';
    articleUpvoteMsg = '<div style="font-weight: 400;font-size: 15px;text-align: center;">This KB has received LIKECOUNT Likes. Do you want to go ahead and archive this KB?</div>';
    caseReferenceAndarticleUpvoteMsg = '<div style="font-weight: 400;font-size: 15px;text-align: center;">This KB has received LIKECOUNT Likes and is reused to resolve Case CASENUMBER. Do you want to go ahead and archive this KB?</div>';

    KBRECORDURL = 'https://HOSTNAME/lightning/r/Knowledge__kav/RECORDID/view';

    //End --> Sathish R --> Jira : I2RT-5003 - T02

    label = {
        COMMUNITYURL
    };

    //Start --> Sathish R --> Jira : I2RT-4931 - T01
    @wire(getRecord, { recordId: '$recordId', fields: KBFIELDS })
    kbrecord({ error, data }) {
        if (error) {
            this.error = error;
            console.log('error', JSON.stringify(error))
        } else if (data) {
            this.kbArticleTitle = data.fields.Title.value;
            this.kbArticleNumber = data.fields.ArticleNumber.value;
            this.kbArticleAuthor = data.fields.Created_By__c.value;
            this.kbArticleVersionId = data.fields.KnowledgeArticleId.value;
            this.kbSolution__c = data.fields.Solution__c.value;//T02
            this.kbInternal_Notes__c = data.fields.Internal_Notes__c.value;//T02
            this.kbDescription__c = data.fields.Description__c.value;//T02
            this.kbAdditional_Information__c = data.fields.Additional_Information__c.value;//T02
            this.kbQuestion__c = data.fields.Question__c.value;//T02
            this.kbAlternate_Questions__c = data.fields.Alternate_Questions__c.value;//T02

            console.log('data from CR feedback', JSON.stringify(data));
        }
    }
    //End --> Sathish R --> Jira : I2RT-4931 - T01
    connectedCallback() {
        this.getCRFeedBackVisibility(); //T01
        console.log('recordId' + this.recordId);
        getAllArticles({
            articleId: this.recordId
        })
            .then(result => {
                console.log('result in Article action', result);
                console.log('result in Article action', result[0].Id);
                if (result != null && result.length > 0) {
                    for (var i = 0; i < result.length; i++) {
                        console.log('result in Article action', result[i].Id);
                        console.log('Is_Pending_TR_Version_Published__c', result[i].Is_Pending_TR_Version_Published__c);

                        if (result[i].Id === this.recordId) {
                            this.knowledgeArticleId = result[i].KnowledgeArticleId;
                            this.publishStatus = result[i].PublishStatus;
                            this.language = result[i].Language;
                            this.validationStatus = result[i].ValidationStatus;
                            this.pendingTRArticlePresent = result[i].Is_Pending_TR_Version_Published__c;
                            this.publickb = result[i].IsVisibleInPkb;
                            this.urlvalue = result[i].UrlName;
                        }
                        if (result[i].PublishStatus === 'Draft' && result[i].Id != this.recordId) {
                            this.draftArticlePresent = true;
                            this.publishArticlePresent = true;
                        }
                        if (result[i].PublishStatus === 'Online' && result[i].Id != this.recordId) {
                            this.publishArticlePresent = true;
                        }

                    }
                }
                if (this.publishStatus === 'Online') {
                    this.publishArticlePresent = true;
                    this.showExtendBtn = true;
                    console.log('publickb' + this.publickb);
                    if (this.publickb) {
                        this.showcopyurl = true;
                    }
                }

                console.log('KnowledgeArticleId' + this.knowledgeArticleId);
                console.log('publish Status' + this.publishStatus);
                console.log('language' + this.language);
            })
            .catch(error => {
                this.error = error;
                console.log('connectedcallback error:' + this.error);
            });
    }

    handlecopy() {
        this.classNameCard = 'slds-card  slds-is-collapsed';//T02
        this.classNameBtnSec = 'slds-is-collapsed';//T02
        //Start --> Sathish R --> Jira : I2RT-4931 - T01
        this.crFeedbackComment = '';
        this.textareacrfeedback = false;
        //End --> Sathish R --> Jira : I2RT-4931 - T01
        var hiddencopy = document.createElement("input");
        let kbcommunityurl = COMMUNITYURL + '/' + this.urlvalue;
        hiddencopy.setAttribute("value", kbcommunityurl);
        document.body.appendChild(hiddencopy);
        hiddencopy.select();
        document.execCommand("copy");
        document.body.removeChild(hiddencopy);
        const showmessage = new ShowToastEvent({
            title: 'Success',
            message: 'Copied to clipboard',
            variant: 'success',
        });
        this.dispatchEvent(showmessage);
    }
    showErrorToast() {
        const showError = new ShowToastEvent({
            title: 'Error!!',
            message: this.errormessage,
            variant: 'error',
        });
        this.dispatchEvent(showError);
    }

    showsuccessToast() {
        const showError = new ShowToastEvent({
            title: 'Success',
            message: this.errormessage,
            variant: 'success',
        });
        this.dispatchEvent(showError);
    }

    get extendterm() {
        return [
            { label: '06 months', value: '06 months' },
            { label: '12 months', value: '12 months' },
            { label: '18 months', value: '18 months' },
            { label: '24 months', value: '24 months' },
        ];
    }

    handlepublish() {

        publishTranslation({
            articleId: this.recordId
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Article Published Successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch((error) => {
                this.errormessage = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.message;//T02
            });
    }

    handleextend() {
        console.log('inside extend function')
        this.selectedaction = 'Extend';
        this.reasonforArchival = '';
        this.classNameCard = 'slds-card  slds-is-collapsed';//T02
        this.classNameBtnSec = 'slds-is-collapsed';//T02
        if (!this.draftArticlePresent) {
            this.template.querySelector('[data-id="extensioncombobox"]').className = 'slds-visible';
            this.classNameSubmit = 'slds-is-expanded  slds-m-left_x-small';//T02
            this.classNameCancel = 'slds-is-expanded  slds-m-left_x-small';//T02
            this.classNameDesc = ' slds-is-collapsed';//T02
            this.classNameBtnSec = 'slds-is-expanded  slds-m-left_x-small';//T02
            this.classNameCard = 'slds-card slds-m-around--small';//T02
            //Start --> Sathish R --> Jira : I2RT-4931 - T01
            this.crFeedbackComment = '';
            this.textareacrfeedback = false;
            //End --> Sathish R --> Jira : I2RT-4931 - T01

        } else {
            this.errormessage = 'There is already a draft article present.';
            this.showErrorToast();
        }


    }
    handlearchive(event) {

        try {


            this.feedbackextension = '';
            this.classNameCard = 'slds-card  slds-is-collapsed';//T02
            this.classNameBtnSec = 'slds-is-collapsed';//T02
            if (!this.draftArticlePresent) {
                //Start --> Sathish R --> Jira : I2RT-5003 - T02
                this.isStillLoading = true;
                this.isArticleReadyForArchival = false;
                getRelatedKBandCase({
                    kbArticleId: this.recordId
                })
                    .then(result => {
                        if (result != null && JSON.parse(result).ResponseStatus === "SUCCESS") {

                            this.isDataAvailable = true;
                            this.isResponseWithSuccess = true;
                            var varArchivalValidateResponseParsed = JSON.parse(result);
                            var varIsArticleReferredinCases = false;
                            var varIsArticleContainsExternalLink = false;
                            var varIsArticleHasLikes = false;
                            var varReferredCaseNumber = '';
                            var varLikeCount = 0;
                            if (varArchivalValidateResponseParsed.KBReferredArticleDatas.length > 0) {
                                var varLinkedKBDatas = varArchivalValidateResponseParsed.KBReferredArticleDatas;
                                this.KBReferredArticleDatas = [...varLinkedKBDatas];
                                this.showLinkedKB = true;
                                this.isWarningMsgAvaialble = false;
                                this.isStillLoading = false;
                                this.openModal();
                            }
                            else {

                                if (varArchivalValidateResponseParsed.KBToCaseResponse != undefined && varArchivalValidateResponseParsed.KBToCaseResponse != null && varArchivalValidateResponseParsed.KBToCaseResponse != '') {
                                    var varKBToCaseResponseParsed = JSON.parse(varArchivalValidateResponseParsed.KBToCaseResponse);
                                    if (varKBToCaseResponseParsed.searchCaseDataList != undefined && varKBToCaseResponseParsed.searchCaseDataList.length > 0) {
                                        for (var i = 0; i < varKBToCaseResponseParsed.searchCaseDataList.length; i++) {
                                            if ((varKBToCaseResponseParsed.searchCaseDataList[i].Type == KB_USE_EXISTING) || (varKBToCaseResponseParsed.searchCaseDataList[i].Type == KB_UPDATED_EXISTING)) {
                                                varIsArticleReferredinCases = true;
                                                if (varReferredCaseNumber == '')
                                                    varReferredCaseNumber = varKBToCaseResponseParsed.searchCaseDataList[i].CaseNumber;
                                                else
                                                    varReferredCaseNumber += ',' + varKBToCaseResponseParsed.searchCaseDataList[i].CaseNumber;
                                            }
                                        }

                                    }
                                }

                                if (varArchivalValidateResponseParsed.KBArticleFeedbackDatas.length > 0) {
                                    for (var i = 0; i < varArchivalValidateResponseParsed.KBArticleFeedbackDatas.length; i++) {
                                        if ((varArchivalValidateResponseParsed.KBArticleFeedbackDatas[i].Like_Dislike__c == KB_LIKE)) {
                                            varIsArticleHasLikes = true;
                                            varLikeCount++;
                                        }
                                    }
                                }

                                // if ((this.fnGetLinkFromString(this.kbSolution__c).length > 0) || (this.fnGetLinkFromString(this.kbInternal_Notes__c).length > 0) || (this.fnGetLinkFromString(this.kbDescription__c).length > 0) || (this.fnGetLinkFromString(this.kbAdditional_Information__c).length > 0) || (this.fnGetLinkFromString(this.kbQuestion__c).length > 0) || (this.fnGetLinkFromString(this.kbAlternate_Questions__c).length > 0)) {
                                //     varIsArticleContainsExternalLink = true;
                                // }


                                this.showLinkedKB = false;
                                this.isStillLoading = false;

                                if (varIsArticleHasLikes == false && varIsArticleReferredinCases == false) {
                                    this.archivalMessage = '';
                                    this.isWarningMsgAvaialble = false;
                                    this.isArticleReadyForArchival = true;
                                }
                                else {
                                    this.archivalMessage = '';
                                    var varStartMsg = '<div>';
                                    var varEndMsg = '</div>';
                                    var varActualMsg = '';
                                    if (varIsArticleReferredinCases == true) {
                                        varActualMsg = this.caseReferenceMsg.replace('CASENUMBER', varReferredCaseNumber);
                                    }

                                    if (varIsArticleHasLikes == true) {
                                        if (varIsArticleReferredinCases == true) {
                                            varActualMsg = this.caseReferenceAndarticleUpvoteMsg.replace('LIKECOUNT', varLikeCount).replace('CASENUMBER', varReferredCaseNumber);
                                        }
                                        else {
                                            varActualMsg = this.articleUpvoteMsg.replace('LIKECOUNT', varLikeCount);
                                        }
                                    }

                                    if ((varIsArticleReferredinCases == true) || (varIsArticleHasLikes == true)) {
                                        this.archivalMessage = varStartMsg + varActualMsg + varEndMsg;
                                        this.isWarningMsgAvaialble = true;
                                        this.openModal();
                                    }
                                    else {
                                        this.isArticleReadyForArchival = true;
                                    }
                                }

                            }

                        }

                        if (this.isArticleReadyForArchival) {

                            this.classNameDesc = 'slds-visible';
                            this.classNameSubmit = 'slds-is-expanded  slds-m-left_x-small';
                            this.classNameBtnSec = 'slds-is-expanded  slds-m-left_x-small';
                            this.classNameCancel = 'slds-is-expanded slds-m-left_x-small';
                            this.classNameCard = 'slds-card slds-m-around--small';
                            this.selectedaction = 'Archive';
                        }
                    })
                    .catch((error) => {
                        this.isStillLoading = false;
                        this.errormessage = 'Error received: code ' + error.errorCode + ', ' +
                            'message ' + error.message;
                        this.showErrorToast();
                    });


                this.template.querySelector('[data-id="extensioncombobox"]').className = ' slds-is-collapsed';
                //End --> Sathish R --> Jira : I2RT-5003 - T02
                //Start --> Sathish R --> Jira : I2RT-4931 - T01
                this.crFeedbackComment = '';
                this.textareacrfeedback = false;
                //End --> Sathish R --> Jira : I2RT-4931 - T01
            } else {
                this.errormessage = 'There is already a draft article present.';
                this.showErrorToast();
            }
        } catch (error) {
            console.error('handlearchive');
            Log('error', 'handlearchive error --> ' + JSON.stringify(error));
        }

    }
    //Start --> Sathish R --> Jira : I2RT-5003 - T02
    handlearchivefrompopup(event) {
        try {
            this.closeModal();
            this.classNameDesc = 'slds-visible';
            this.classNameSubmit = 'slds-is-expanded  slds-m-left_x-small';
            this.classNameBtnSec = 'slds-is-expanded  slds-m-left_x-small';
            this.classNameCancel = 'slds-is-expanded slds-m-left_x-small';
            this.classNameCard = 'slds-card slds-m-around--small';
            this.selectedaction = 'Archive';

        } catch (error) {
            console.error('handlearchivefrompopup');
            Log('error', 'handlearchive error --> ' + JSON.stringify(error));
        }
    }
    //End --> Sathish R --> Jira : I2RT-5003 - T02
    handleextension(event) {
        this.feedbackextension = event.detail.value;

    }
    getReasonForArchival(event) {
        this.reasonforArchival = event.detail.value;

    }

    handlecancel() {
        this.classNameCard = 'slds-card  slds-is-collapsed';//T02
        this.classNameBtnSec = 'slds-is-collapsed';//T02

    }

    handlesubmit() {

        var inp = this.reasonforArchival;
        console.log('Reason for archival', inp);

        console.log(this.feedbackextension.length);
        console.log(this.selectedaction);
        if (this.feedbackextension.length === 0 && this.selectedaction == 'Extend') {
            console.log(this.feedbackextension.length);
            this.errormessage = 'Please select extension period';
            this.showErrorToast();
        } else if (this.selectedaction == 'Archive' && inp.length === 0) {
            this.errormessage = 'Please enter comments';
            this.showErrorToast();
        } else {
            if (this.selectedaction == 'Extend') {
                this.isStillLoading = true;
                extendAndPublish({
                    articleId: this.recordId,
                    extendterm: this.feedbackextension
                })
                    .then(result => {
                        this.isStillLoading = false;
                        console.log('result' + result);
                        if (result !== null) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Article Extended Successfully',
                                    variant: 'success',
                                }),
                            );
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    "recordId": result,
                                    "objectApiName": "Knowledge__kav",
                                    "actionName": "view"
                                },
                            });
                            this.classNameCard = 'slds-card  slds-is-collapsed';//T02
                            this.classNameBtnSec = 'slds-is-collapsed';//T02
                        } else {
                            this.errormessage = 'Error while extending article. Please contact your administrator';
                            this.showErrorToast();
                        }

                    })
                    .catch((error) => {
                        this.isStillLoading = false;
                        console.log('Inside catch' + JSON.stringify(error));
                        this.errormessage = 'Error while extending article: Please contact your system administrator';
                        this.showErrorToast();
                    });
            } else if (this.selectedaction == 'Archive') {
                this.isStillLoading = true;
                archiveArticle({
                    articleId: this.recordId,
                    comments: inp
                })
                    .then(() => {
                        //Start --> Sathish R --> Jira : I2RT-8359 - T03
                        sendAlertOnArchivalWrapper({
                            strKBRecordId: this.recordId,
                            strArchivalComment: inp                            
                        }).then(result => {
    
                            console.log('result sendAlertOnArchival ' + result);
    
                        }).catch(error => {
                            console.log('error is: ' + JSON.stringify(error));
                        });
                        //End --> Sathish R --> Jira : I2RT-8359 - T03

                        this.isStillLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Article Archived Successfully',
                                variant: 'success',
                            }),
                        );
                        this.classNameCard = 'slds-card  slds-is-collapsed';//T02
                        this.classNameBtnSec = 'slds-is-collapsed';//T02
                    })
                    .catch((error) => {
                        this.isStillLoading = false;
                        console.log('Inside catch submit' + JSON.stringify(error));
                        this.errormessage = 'Error while archiving article: Please contact your system administrator';
                        this.showErrorToast();
                    });
            }
        }

    }

    //Start --> Sathish R --> Jira : I2RT-4931 - T01
    getCRFeedBackVisibility() {
        try {
            isUserCRFeedbackSubmitter({
                kbArticleId: this.recordId
            }).then(result => {
                this.showcrfeedback = JSON.parse(result);

                console.log('result getCRFeedBackVisibility ' + result);

            }).catch(error => {
                console.log('error is: ' + JSON.stringify(error));
            });
        } catch (error) {
            Log('error', 'getCRFeedBackVisibility error --> ' + JSON.stringify(error));
        }
    }

    handlecrfeedback() {
        try {
            this.textareacrfeedback = true;
            this.classNameCard = 'slds-card  slds-is-collapsed';//T02
            this.classNameBtnSec = 'slds-is-collapsed';//T02
        } catch (error) {
            Log('error', 'handlecrfeedback error --> ' + JSON.stringify(error));
        }
    }

    handlecrfeedbackreset() {
        try {
            this.crFeedbackComment = '';
            this.textareacrfeedback = false;
        } catch (error) {
            Log('error', 'handlecrfeedbackreset error --> ' + JSON.stringify(error));
        }
    }

    handlecrfeedbacksubmit() {
        try {
            var inp = this.crFeedbackComment;
            if (inp == undefined || inp.length === 0) {
                this.errormessage = 'Please enter your comments';
                this.showErrorToast();
            }
            else {
                this.createFeedback();
            }
        } catch (error) {
            Log('error', 'handlecrfeedbacksubmit error --> ' + JSON.stringify(error));
        }

    }

    handlecrfeedbackcancel() {
        try {
            this.crFeedbackComment = '';
            this.textareacrfeedback = false;
        } catch (error) {
            Log('error', 'handlecrfeedbackcancel error --> ' + JSON.stringify(error));
        }
    }

    getCRFeedback(event) {
        try {
            this.crFeedbackComment = event.detail.value;
        } catch (error) {
            Log('error', 'getCRFeedback error --> ' + JSON.stringify(error));
        }

    }

    createFeedback() {
        try {

            // if (typeof (Math) != 'undefined' && typeof (Math.floor) != 'undefined' && typeof (Date) != 'undefined') {
            //     this.kbRandomNumber = Math.floor(Date.now() / 1000).toString();
            // }

            const fields = {};
            fields[KBID.fieldApiName] = this.recordId;
            fields[KBIDTEXT.fieldApiName] = this.recordId;
            fields[ARTICLENUMBER.fieldApiName] = this.kbArticleNumber;
            fields[KBTITLE.fieldApiName] = this.labelbtncrfeedback + '- ArticleNumber -' + this.kbArticleNumber;
            fields[FEEDBACKNAME.fieldApiName] = this.labelbtncrfeedback + '- ArticleNumber -' + this.kbArticleNumber;
            fields[STATUS.fieldApiName] = 'Closed';
            fields[ARTICLE_AUTHOR.fieldApiName] = this.kbArticleAuthor;
            fields[FEEDBACKUSER.fieldApiName] = this.userId;
            fields[ISCRFEEDBACK.fieldApiName] = true;
            fields[COMMENTS.fieldApiName] = this.crFeedbackComment;
            fields[KBARTICLEVERSIONID.fieldApiName] = this.kbArticleVersionId;
            fields[ARTICLELINK.fieldApiName] = KBURL + '/' + this.recordId + '/view';

            const recordInput = { apiName: KB_OBJECT.objectApiName, fields };

            this.createFeedbackRecord(recordInput);
        } catch (error) {
            Log('error', 'createFeedback error --> ' + JSON.stringify(error));
        }

    }

    createFeedbackRecord(recordInput) {
        try {
            console.log('Inside Create');
            createRecord(recordInput)
                .then(afl__afl_Article_Feedback__c => {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            mode: 'dismissable',
                            title: 'Success',
                            message: 'CR Feedback submitted successfully',
                            variant: 'success',
                        }),
                    );

                    sendAlertOnCRFeedbackWrapper({
                        strKBRecordId: this.recordId,
                        strCRFeedbackComment: this.crFeedbackComment
                    }).then(result => {

                        console.log('result sendAlertOnCRFeedback ' + result);

                    }).catch(error => {
                        console.log('error is: ' + JSON.stringify(error));
                    });

                    this.crFeedbackComment = '';
                    this.textareacrfeedback = false;
                })
                .catch(error => {
                    console.log('error ' + error)
                    console.log('error object', JSON.stringify(error))
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } catch (error) {
            Log('error', 'createFeedbackRecord error --> ' + JSON.stringify(error));
        }
    }
    //End --> Sathish R --> Jira : I2RT-4931 - T01


    //Start --> T02

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        console.log('to close modal set isModalOpen tarck value as false');
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    handleKBRowAction(event) {
        try {
            Log('log', 'this.handleKBRowAction Called');
            const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'view':
                    var varUrlToOpen = this.KBRECORDURL.replace('HOSTNAME', document.location.host).replace('RECORDID', row.Id);
                    window.open(varUrlToOpen, '_blank');
                    break;
            }
        } catch (error) {
            Log('error', 'handleKBRowAction error --> ' + JSON.stringify(error));
        }

    }

    fnGetLinkFromString(parFieldString) {
        var varmatchresult = [];
        var valocalresult = [];
        try {

            // var varCustomreg = new RegExp('<a.*?>(.*)?</a>', 'gi');
            // while ((valocalresult = varCustomreg.exec(parFieldString)) !== null) {
            //     varmatchresult.push(valocalresult);
            // };
            if (parFieldString != null && parFieldString != undefined) {
                var varmatchresult = parFieldString.match(/(<a).*?(>).*?(<\/a>)+/gim);
                if (varmatchresult == null) {
                    varmatchresult = [];
                }
            }
        }
        catch (error) {
            Log('error', 'fnGetFieldNameFromString error --> ' + JSON.stringify(error));
        }
        return varmatchresult;
    }
    //End --> T02
}