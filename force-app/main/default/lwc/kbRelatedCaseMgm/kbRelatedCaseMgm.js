/*
   @created by       : Sathish R
   @created on       : 26-Jul-2022
   @Purpose          : Provide Case using search on KB Authoring Home.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  26-Jul-2022      |  Sathish R                |                   |   Initial Version
 |     2      |  27-Oct-2022      |  Sathish R                |    I2RT-7302      |   Display only assigned cases to engineers when attaching articles to Cases on article view page and Authoring home related tab.
 ****************************************************************************************************
 */
import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import getSimilarCases from "@salesforce/apex/KBContentSearch.getSimilarCases";
import processCaseKB from "@salesforce/apex/CaseKBCreation.processCaseKB";
import getKBToCase from "@salesforce/apex/CaseKBCreation.getKBToCase";
import updateKBToCase from "@salesforce/apex/CaseKBCreation.updateKBToCase";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ARTICLE_FIELDS = [
    "Knowledge__kav.Id",
    "Knowledge__kav.Title",
    "Knowledge__kav.Article_Type__c",
    "Knowledge__kav.ArticleNumber",
    "Knowledge__kav.PublishStatus",
    "Knowledge__kav.KnowledgeArticleId"
];
  
const KBSELECTACTION =
    { type: 'action', typeAttributes: { rowActions: [{ label: 'Select', name: 'select' }, { label: 'View', name: 'view' }] } };

const KBDELETEACTION = {
    type: 'action', typeAttributes: {
        rowActions: [
            { label: 'Delete', name: 'delete' }, { label: 'View', name: 'view' }
        ]
    }
};



const KB_CREATE_NEW = 'Create New';
const KB_USE_EXISTING = 'Use Existing';
const KB_UPDATED_EXISTING = 'Updated Existing';


const KBACTIONNONPUBLISHSHEDARTICLE =[{ label: 'Use Existing', value: 'Use Existing' },
{ label: 'Updated Existing', value: 'Updated Existing' }];

const KBACTIOPUBLISHSHEDARTICLE = [{ label: 'Use Existing', value: 'Use Existing' },
{ label: 'Updated Existing', value: 'Updated Existing' }];



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

export default class KbRelatedCaseMgm extends LightningElement {
    @api recordId;
    @track isDataAvailableOnLoad = false;
    @track isContentViewable = true;
    @track showSelectedCases = false;
    @track showLinkedCases = false;
    @track isModalOpen = false;
    @track wizardtitle = "New Related Case";
    @track isDataLoadInProgress = true;
    @track showSearchTokenError = false;
    @track showSearchTokenSuccess = false;
    @track showSearchTokenError = false;
    @track showSearchTokenSuccess = false;
    @track isThereAnyDataLinked = false;
    @track showSearchSpinner = false;
    @track showSearchSuccess = false;
    @track showSearchNoResult = false;
    @track isDeleteModalOpen = false;
    @track errorMessage = ''
    @track searchTokenFor = 'kbtocaseassociation';
    @track searchtoken = '';
    @track searchhubname = '';
    @track searchorgname = '';
    @track searchTerm = '';
    @track caseSearchData = [];
    @track caseSelectedData = [];
    @track caseLinkedData = [];
    @track originalCaseLinkedData = [];
    @track selectedCaseTitle = '';
    @track selectedCaseNumber = '';
    @track selectedCaseId = '';
    @track selectedCaseKBAction = '';
    @track searchSpaceHeight = 'height:12rem';
    @track searchResultHeight = 'height:15.5rem;overflow-y: auto;';
    @track currentArticleNumber = '';
    @track currentKnowledgeArticleId = '';
    @track currentArticlePublishStatus;
    @track kbToCaseReferenceCount = '0';
    @track selectedIdForDelete = '';
    @track isDeleteConfirmed = false;
    @track expandminimizeWidgetCss = 'kbrelatedcase-content-minimized';
    @track expandminimizeLinkText = 'Show More';
    
    
    searchPlaceholder = 'Search for Case';
    inputClass = 'slds-form-element';
    CASERECORDURL = 'https://HOSTNAME/lightning/r/Case/RECORDID/view';
    
    
      
    @track casecolumnswithselect = [
        KBSELECTACTION,
        { label: 'Case', fieldName: 'sfcasenumber', type: 'string' },
        { label: 'Title', fieldName: 'title', type: 'string' }
    ];
    
    @track casecolumnswithdelete = [
        KBDELETEACTION,        
        { label: 'Case Number', fieldName: 'CaseNumber', type: 'string' },
        { label: 'Subject', fieldName: 'Subject', type: 'string' },
        { label: 'KB action', fieldName: 'Type', type: 'string' }
    ];
   
    
    @track kbActionType = KBACTIONNONPUBLISHSHEDARTICLE;
    

    @wire(getRecord, { recordId: "$recordId", fields: ARTICLE_FIELDS })
    article({ error, data }) {
        try {
            if (error) {
                Log("log", "KbRelatedCaseMgm : error - " + JSON.stringify(error));
            } else if (data) {
                Log("log", "KbRelatedCaseMgm : log - " + JSON.stringify(data));
                this.currentKnowledgeArticleId = data.fields.KnowledgeArticleId.value;
                this.currentArticleNumber = data.fields.ArticleNumber.value;
                this.isDataAvailableOnLoad = true;                
                this.currentArticlePublishStatus = data.fields.PublishStatus.value;
                if (this.currentArticlePublishStatus.toString().trim().toLowerCase() == 'online') {
                    this.kbActionType = KBACTIOPUBLISHSHEDARTICLE;
                }
                if (this.currentArticlePublishStatus.toString().trim().toLowerCase() == 'archived') {
                    this.isContentViewable = false;
                }
                
            }
        } catch (error) {
            Log('error', 'case getRecord error --> ' + JSON.stringify(error));
        }
    }

    connectedCallback() {
        Log('log', 'thislcl.getKBToCase relatedcase --> connectedCallback');
        this.getExistingCaseLink();
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    openModal() {
        this.handleResetOnNew();//<2>
        this.isModalOpen = true;
        this.getSearchTokenForLinking();
    }

    getSearchTokenForLinking() {
        try {
            Log('log', 'this.getSearchTokenForLinking Called');
            getSearchToken({ strCalledFrom: this.searchTokenFor })
                .then((result) => {
                    //log('this.getSearchToken --> '+JSON.stringify(result));                 
                    this.searchtoken = JSON.parse(result).APISearchToken;
                    this.searchhubname = JSON.parse(result).APISearchHub;
                    this.searchorgname = JSON.parse(result).SearchOrgName;
                    this.hideSearchSpaceSpinner();		    
                    this.handleSearchClick(undefined);//<2>
                })
                .catch((error) => {
                    Log('log', 'case SearchTokenForLinking error --> ' + JSON.stringify(error));
                    this.hideSearchSpaceSpinner();
                });
        } catch (error) {
            Log('error', 'case SearchTokenForLinking error --> ' + JSON.stringify(error));
            this.hideSearchSpaceSpinner();
        }
    }

    hideSearchSpaceSpinner() {
        this.isDataAvailable = true;
        this.isDataLoadInProgress = false;
        this.showSearchTokenSuccess = true;
        this.showSearchTokenError = false;
    }

    handleOnSearchSuccess() {
        this.showSearchSuccess = true;
        this.showSearchNoResult = false;
        this.showSearchSpinner = false;
    }

    handleOnSearchError() {
        this.showSearchSuccess = false;
        this.showSearchNoResult = true;
        this.showSearchSpinner = false;
    }

    handleOnSearchNoResult() {
        this.showSearchSuccess = false;
        this.showSearchNoResult = true;
        this.showSearchSpinner = false;
    }
    
    handleSearchClick(event) {
        try {
            Log('log', 'this.handleSearchClick Called');
            this.showSearchSuccess = false;
            this.showSearchNoResult = false;
            this.showSearchSpinner = true;    
	    //<2>      
            var varIsOnLoad = '0';
            if (typeof event === 'undefined') {
                varIsOnLoad = '1';
            }
            //</2>        
            getSimilarCases({ strSearchToken: this.searchtoken, strSearchKeyword: this.searchTerm, strCaseNumber: '', strIsOnload: varIsOnLoad })//<2>
                .then((result) => {
                    Log('log', 'case SimilarArticle sucess --> ' + JSON.stringify(result));

                    if (JSON.parse(result).APIResponseStatus == 'OK') {
                        var varSearchDatas = JSON.parse(result).searchCaseDataList;
                        this.caseSearchData = [...varSearchDatas];
                        if (varSearchDatas.length > 0) {
                            this.handleOnSearchSuccess();
                        }
                        else {
                            this.handleOnSearchNoResult();
                        }
                    }
                    if (JSON.parse(result).APIResponseStatus == 'ERROR')
                        Log('log', 'case SimilarArticle error --> ' + JSON.stringify(result));
                                                                       
                })
                .catch((error) => {
                    Log('log', 'case SimilarArticle error --> ' + JSON.stringify(error));
                });
            
        } catch (error) {
            Log('error', 'case SimilarArticle error --> ' + JSON.stringify(error));
        }
    }

    handleClearCase() {
        try {
            this.caseSearchData = [...this.caseSearchData];
            this.showSearchSuccess = false;
            this.searchTerm = '';
            //this.template.querySelector('#casesearchinput').value = '';
        } catch (error) {
            Log('error', 'case handleCloseKBSpaceClick error --> ' + JSON.stringify(error));
        }
    }

    handleChangeSearchTerm(event) {
        try {
            this.searchTerm = event.target.value;
        } catch (error) {
            Log('error', 'case handleCloseKBSpace error --> ' + JSON.stringify(error));
        }
    }
    
    handleCaseRowActionSelect(event) {
        try {
            Log('log', 'this.handleCaseRowActionSelect Called');
            const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'select':
                    var isPresent = false;
                    for (var i = 0; i < this.caseSelectedData.length; i++) {
                        if (this.caseSelectedData[i].sfid == row.sfid) {
                            isPresent = true;
                            break;
                        }
                    }
                    if (!isPresent)
                        this.caseSelectedData = [...this.caseSelectedData, row];
                    this.selectedCaseTitle = row.title;
                    this.selectedCaseNumber = row.sfcasenumber;
                    this.selectedCaseId = row.sfid;
                    break;
                case 'view':
                    var varUrlToOpen = this.CASERECORDURL.replace('HOSTNAME', document.location.host).replace('RECORDID', row.sfid);
                    window.open(varUrlToOpen, '_blank');
                    break;
            }
            if (this.caseSelectedData.length > 0) {
                this.showSelectedCases = true;
                this.showErrorInKb = false;
            }
            else {
                this.showSelectedCases = false;
                this.showErrorInKb = true;
            }
        } catch (error) {
            Log('error', 'case handleCaseRowActionSelect error --> ' + JSON.stringify(error));
        }
    }

    handleChangekbActionType(event) {
        try {
            this.selectedCaseKBAction = event.target.value;
            if (event.target.value !== 'None' && event.target.disabled !== true) {
                event.target.setCustomValidity("");
                event.target.reportValidity();
            }
        } catch (error) {
            Log('error', 'case handleKBTemplateChange error --> ' + JSON.stringify(error));
        }
    }

    handleUnSelectClick() {
        this.showSelectedCases = false;
        this.caseSelectedData = [];
        this.caseSelectedData = [...this.caseSelectedData];
        this.selectedCaseTitle = '';
        this.selectedCaseNumber = '';
        this.selectedCaseId = '';
        this.SelectedCaseKBAction = '';
        this.kbActionType = [{ label: KB_CREATE_NEW, value: KB_CREATE_NEW },
        { label: KB_USE_EXISTING, value: KB_USE_EXISTING },
        { label: KB_UPDATED_EXISTING, value: KB_UPDATED_EXISTING }];
    }

    handleSaveClick() {
        try {
            Log('log', 'this.processCaseKB --> ' + 'handleSaveClick');
            var isRequiredFieldsFilled = true;
            [...this.template.querySelectorAll('lightning-combobox')].forEach(element => {
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
           
            if (isRequiredFieldsFilled) {
                processCaseKB({ strCaseRecordId: this.selectedCaseId, strKBRecordId: this.recordId, strKBArticleNumber: this.currentArticleNumber, strKBActionType: this.selectedCaseKBAction }).then(result => {
                    this.showSpinner = false;
                    this.showModal = 'slds-hide';
                    if (result !== null) {
                        Log('log', 'this.processCaseKB --> ' + JSON.stringify(result));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Case KB Successfully Saved',
                                variant: 'success',
                            }),
                        );
                        this.handleResetOnSave();
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Case KB Successfully Saved',
                                variant: 'success',
                            }),
                        );
                        this.handleResetOnSave();
                    }
                })
                    .catch((error) => {
                        Log('log', 'Inside catch handleSaveClick' + JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed',
                                variant: 'error',
                            }),
                        );
                        this.handleResetOnSave();
                    });
            }
        } catch (error) {
            Log('error', 'case handleSaveClick error --> ' + JSON.stringify(error));
        }
    }

    handleResetOnSave() {
        Log('log', 'thislcl.getKBToCase relatedcase --> handleResetOnSave');
        this.getExistingCaseLink();
        this.showSelectedCases = false;
        this.caseSelectedData = [];
        this.caseSelectedData = [...this.caseSelectedData];
        this.selectedCaseTitle = '';
        this.selectedCaseNumber = '';
        this.selectedCaseId = '';
        this.selectedCaseKBAction = '';
        this.closeModal();
    }

    handleCaseRowActionDelete(event) {
        try {
            Log('log', 'this.handleCaseRowActionDelete Called');
            const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'delete':
                    this.selectedIdForDelete = row.Id;
                    this.openDeleteModal();
                    break;
                case 'view':
                    var varUrlToOpen = this.CASERECORDURL.replace('HOSTNAME', document.location.host).replace('RECORDID', row.CaseId);
                    window.open(varUrlToOpen, '_blank');
                    break;
            }
            if (this.caseLinkedData.length > 0) {
                this.showLinkedCases = true;
            }
            else {
                this.showLinkedCases = false;
            }
        } catch (error) {
            Log('error', 'case handleCaseRowActionDelete error --> ' + JSON.stringify(error));
        }
    }

    getExistingCaseLink() {

        //Added to disable to route login page when user opens the PAM EOL Support Statement and Support Guide Article
        function fnCheckTillSourceAvailable(execCount, thislcl) {
            try {
        
                if (thislcl.isDataAvailableOnLoad == true) {
                    fnToBeCalledOnceSourceAvailable(thislcl);
                } else if (execCount < 600) {
                    execCount = execCount + 1;
                    window.setTimeout(function () { fnCheckTillSourceAvailable(execCount, thislcl); }, 100);
                }
            } catch (ex) {
                console.error('Method : fnCheckTillSourceAvailable - kbrcm:' + ex.message);
            }
        }

        function fnToBeCalledOnceSourceAvailable(thislcl) {
            try {
                getKBToCase({ strKAVRecordId: thislcl.recordId, strKARecordId: thislcl.currentKnowledgeArticleId, strKAVArticleNumber: thislcl.currentArticleNumber }).then((result) => {
                    try {
                        if (result !== null) {
                            Log('log', 'thislcl.getKBToCase --> ' + JSON.stringify(result));
    
                            if (JSON.parse(result).ResponseStatus == 'OK') {
                                thislcl.caseLinkedData = [];
                                thislcl.originalCaseLinkedData = [];
                                var varLinkedDatas = JSON.parse(result).searchCaseDataList;
                                var varFinalLinkedDatas = []
                                thislcl.caseLinkedData = [...varLinkedDatas];
                                thislcl.originalCaseLinkedData = [...varLinkedDatas];
                                Log('log', 'thislcl.getKBToCase --> caseSelectedData : ' + JSON.stringify(thislcl.caseLinkedData));
                                if (varLinkedDatas.length > 0) {
                                    thislcl.kbToCaseReferenceCount = varLinkedDatas.length.toString();
                                    var varLength = varLinkedDatas.length;
                                    if (varLength > 5) {
                                        varLength = 5;
                                    }
                                    for (var i = 0; i < varLength; i++) {
                                        varFinalLinkedDatas.push(varLinkedDatas[i]);
                                    }
                                    thislcl.caseLinkedData = [...varFinalLinkedDatas];
                                    thislcl.showLinkedCases = true;
                                }
                                else {
                                    thislcl.showLinkedCases = false;
                                    thislcl.kbToCaseReferenceCount = varLinkedDatas.length.toString();
                                }
                            }
                            if (JSON.parse(result).APIResponseStatus == 'ERROR')
                                Log('log', 'case getKBToCase error --> ' + JSON.stringify(result));
                    
                        }
                        else {
                    
                        }
                    } catch (error) {
                        Log('error', 'case getKBToCase error --> ' + JSON.stringify(error));
                    }
                }).catch((error) => {
                    Log('error', 'getKBToCase' + JSON.stringify(error));
                });
        
            } catch (ex) {
                console.error('Method : fnToBeCalledOnceSourceAvailable  - kbrcm:' + ex.message);
            }
        }

        fnCheckTillSourceAvailable(0, this);
    }

    closeDeleteModal() {
        this.isDeleteModalOpen = false;
        this.selectedIdForDelete = '';
        this.isDeleteConfirmed = false;
    }
    
    openDeleteModal() {
        this.isDeleteModalOpen = true;
    }

    handleDeleteClick() {
        try {
            this.isDeleteConfirmed = true;
            updateKBToCase({ strCaseKBRecordId: this.selectedIdForDelete, strKBRecordId: this.recordId }).then((result) => {
                try {
                    if (result !== null) {
                        Log('log', 'this.updateKBToCase --> ' + JSON.stringify(result));
        
                        if (JSON.parse(result).ResponseStatus == 'OK') {
                            this.caseLinkedData = [];
                            var varLinkedDatas = JSON.parse(result).searchCaseDataList;
                            this.caseLinkedData = [...varLinkedDatas];
                            Log('log', 'this.updateKBToCase --> caseSelectedData : ' + JSON.stringify(this.caseLinkedData));
                            if (varLinkedDatas.length > 0) {
                                this.showLinkedCases = true;
                                this.kbToCaseReferenceCount = varLinkedDatas.length.toString();
                            }
                            else {
                                this.showLinkedCases = false;
                                this.kbToCaseReferenceCount = varLinkedDatas.length.toString();
                            }
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Case KB Deleted Successfully',
                                    variant: 'success',
                                }),
                            );
                        }
                        if (JSON.parse(result).APIResponseStatus == 'ERROR') {
                            Log('log', 'case updateKBToCase error --> ' + JSON.stringify(result));
                        }
                        
                        this.closeDeleteModal();
                        
                    }
                    else {
                        this.closeDeleteModal();
                    }
                } catch (error) {
                    Log('error', 'case updateKBToCase error --> ' + JSON.stringify(error));
                    this.closeDeleteModal();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed',
                            variant: 'error',
                        }),
                    );
                }
            }).catch((error) => {
                Log('error', 'updateKBToCase' + JSON.stringify(error));
                this.closeDeleteModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed',
                        variant: 'error',
                    }),
                );
            });
        } catch (error) {
            Log('error', 'case handleDeleteClick error --> ' + JSON.stringify(error));
        }
    }

    expandminimizeWidget() {
        try {                    
            if (this.expandminimizeWidgetCss == 'kbrelatedcase-content-minimized') {
                this.expandminimizeWidgetCss = 'kbrelatedcase-content-expanded';
                this.expandminimizeLinkText = 'Show Less';
                var varFinalLinkedDatas = []
                for (var i = 0; i < this.originalCaseLinkedData.length; i++) {
                    varFinalLinkedDatas.push(this.originalCaseLinkedData[i]);
                }
                this.caseLinkedData = [...varFinalLinkedDatas];
            } else {
                this.expandminimizeWidgetCss = 'kbrelatedcase-content-minimized';
                this.expandminimizeLinkText = 'Show More';
                var varFinalLinkedDatas = []
                var varLength = this.originalCaseLinkedData.length;                            
                if (varLength > 5)
                {
                    varLength = 5;
                }
                for (var i = 0; i < varLength; i++) {
                    varFinalLinkedDatas.push(this.originalCaseLinkedData[i]);
                }
                this.caseLinkedData = [...varFinalLinkedDatas];
            }
        } catch (error) {
            Log('error', 'case expandminimizeWidget error --> ' + JSON.stringify(error));
        }
    }
    //<2>	
    handleResetOnNew() {
        this.caseSearchData = [];
        this.searchTerm = '';
        this.isDataAvailable = false;
        this.isDataLoadInProgress = true;        
        this.showSearchSuccess = false;
        this.showSearchNoResult = false;
        this.showSearchSpinner = true;
    }
    //</2>

}