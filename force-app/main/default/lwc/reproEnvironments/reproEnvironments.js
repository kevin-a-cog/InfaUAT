import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import Docker from '@salesforce/resourceUrl/Docker';
import iserver from '@salesforce/resourceUrl/iserver';

/* Utilities */
import { log,objUtilities } from 'c/globalUtilities';

/* Case Fields */
import OWNERID from "@salesforce/schema/Case.OwnerId";
import SUBJECT from "@salesforce/schema/Case.Subject";
import VERSION from "@salesforce/schema/Case.Version__c";
import DESCRIPTION from "@salesforce/schema/Case.Description";
import PRODUCT from "@salesforce/schema/Case.Forecast_Product__c";

/* Repro Environment Fields */
import REPRO_PRODUCT from '@salesforce/schema/Repro_Environment__c.Product__c';
import REPRO_VERSION from '@salesforce/schema/Repro_Environment__c.Version__c';
import REPRO_REGION from '@salesforce/schema/Repro_Environment__c.Region__c';

/* Apex Methods */
import getSearchFilters from '@salesforce/apex/reproEnvironmentController.getSearchFilters';
import getReproEnvironments from '@salesforce/apex/reproEnvironmentController.getReproEnvironments';
import searchReproEnvironments from '@salesforce/apex/reproEnvironmentController.searchReproEnvironments';
import getCaseReproEnvironments from '@salesforce/apex/reproEnvironmentController.getCaseReproEnvironments';
import attachReproEnvironmentToCase from '@salesforce/apex/reproEnvironmentController.attachReproEnvironmentToCase';
import detachReproEnvironmentFromCase from '@salesforce/apex/reproEnvironmentController.detachReproEnvironmentFromCase';

/* Constants */
const FIELDS = [SUBJECT,DESCRIPTION,OWNERID,PRODUCT,VERSION];
const COLUMNS = ['Repro_Environment__r___Name', 'Name__c', 'Account__r___Name', 'case__r__Supportname', 'Region__c', 'CaseOwner', 'idvalue'];

/* Count number of characters similar between two strings */
/*function getSameCount(str1, str2){
    let count = 0;
    const obj = str2.split("");
    for(let str of str1){
      let idx = obj.findIndex(s => s === str);
      if(idx >= 0){
        count++;
        obj.splice(idx, 1);
      }
    }
    return count;
}*/

export default class ReproEnvironments extends NavigationMixin(LightningElement) {
    @api recordId;
    //label = {DOCKER_RECORDTYPE,ISERVER_RECORDTYPE};
    
    urlvalue = "/lightning/r/Repro_Environment__c";
    urlvalue2 = "/lightning/r/Case_Repro_Environment__c";
    /* Search Query by user */
    queryTerm;
    @track disableSearch = false;

    /* Repro Environments and Case Repro Environments properties */
    @track overallReproEnvironments;
    @track reproEnvironments;
    @track overallAttReproEnvironments;
    @track attReproEnvironments;
    attReproEnvironmentIds = [];
    attPendingApprovalReproIds = [];
    @track NoDataAfterRendering = false;
    @track NoDataAfterRendering_ATT = false;

    /* Tab properties */
    @track showAllTab = true;
    @track showAttResultsTab = false;

    /* All TAB Pagination properties */
    totalPages;
    firstPage;
    @track currentPage;
    lastPage;
    @track hidePreviousBTN;
    @track hideNextBTN;
    @track recordDispLimit = 5;
    @track hideIncidentPagination;
    @track popin = true;

    /* Attached Results TAB Pagination properties */
    totalPages_ATT;
    firstPage_ATT;
    @track currentPage_ATT;
    lastPage_ATT;
    @track hidePreviousBTN_ATT;
    @track hideNextBTN_ATT;
    @track recordDispLimit_ATT = 5;
    @track hideIncidentPagination_ATT;
    showSpinner = false;

    @track
    filters = [{
        label: 'Latest',
        value: 'LastModifiedDate DESC',
        isSelected: true
    }, {
        label: 'Oldest',
        value: 'LastModifiedDate ASC',
        isSelected: false
    }];

    get selectedSort() {
        return this.filters.filter(fil => fil.isSelected)[0].label;
    }

    /* Edit Distance between two strings */
    /*levenshteinDistance = (str1 = '', str2 = '') => {
        const track = Array(str2.length + 1).fill(null).map(() =>
        Array(str1.length + 1).fill(null));
        for (let i = 0; i <= str1.length; i += 1) {
           track[0][i] = i;
        }
        for (let j = 0; j <= str2.length; j += 1) {
           track[j][0] = j;
        }
        for (let j = 1; j <= str2.length; j += 1) {
           for (let i = 1; i <= str1.length; i += 1) {
              const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1;
              track[j][i] = Math.min(
                 track[j][i - 1] + 1, // deletion
                 track[j - 1][i] + 1, // insertion
                 track[j - 1][i - 1] + indicator, // substitution
              );
           }
        }
        return track[str2.length][str1.length];
    };*/

    handleSelect(event) {
        this.filters.forEach(fil => {
            fil.isSelected = fil.value == event.detail.value
        });

        let params = {                    
            sortBy: this.sortBy            
        };

        this.handleClick();
        
        log('this.filters>>', JSON.parse(JSON.stringify(this.filters)));
    }


    handlepopout(event){
        this.popin = false;
        const custEvent = new CustomEvent('callrepro');
        this.dispatchEvent(custEvent);
        log('handlepopout2 function');
    }


    @api
    handlepopin(){
        log('called child component');
        this.popin = true;
    }

    handleClick(){
        this.showSpinner = true;
        if(this.showAllTab){
            this.caserepro();
        } else {
            this.populateresults();
        }
    }

    /* When user provides term to search, update queryTerm property */
    /*handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            
            let totalData;
            let totalDataLength;
            let dataMap = new Map();
            let limit = 50000;
            let editThreshold = 80;
            let count = 0;
            let dataLimit = 150;

            getReproEnvironments({ lmt : 100, caseId : this.recordId})
                .then((result) => {
                    //Promise for getReproEnvironments()
                    if(result.length > 0){

                        totalData = result;
                        totalDataLength = result.length;

                        totalData.forEach(row => {
                            if(row['Name'] != undefined && row['Name'] != ''){
                                if(count <= dataLimit){
                                    let nameLength = row['Name'].length;
                                    let editDistance = this.levenshteinDistance(row['Name'], this.queryTerm);
                                    if(editDistance <= 0){
                                        editDistance = 0;
                                        dataMap.set(row, editDistance);
                                        count++;
                                    }
                                    else{
                                        editDistance = (editDistance / nameLength) * 100;
                                        if(editDistance < editThreshold){
                                            dataMap.set(row, editDistance);
                                            count++;
                                        }
                                    }
                                    // log('Name --> '+row['Name']+'\t edit Distance --> '+editDistance);
                                    // log('typeof edit distance --> '+typeof(editDistance));
                                }                            
                            }

                        });

                        let finalData = [];

                        if(dataMap != undefined){
                            let tempData = new Map([...dataMap.entries()].sort((a, b) => a[1] - b[1]));
                            for(let key of tempData.keys()){
                                finalData.push(key);
                            }
                        }

                        finalData.forEach(row => {
                            if(this.attPendingApprovalReproIds.includes(row['Id'])){
                                row['isApprovalPending'] = true;
                                row['attachedToCase'] = true;
                            }
                            else if(this.attReproEnvironmentIds.includes(row['Id'])){
                                row['isApprovalPending'] = false;
                                row['attachedToCase'] = true;
                            }
                            else {
                                row['isApprovalPending'] = false;
                                row['attachedToCase'] = false;
                            }
                            if(row['Account__r'] != undefined){
                                if(row['Account__r']['Name'] != undefined){
                                    row['Account__r___Name'] = row['Account__r']['Name'];
                                }
    
                            }
                        });

                        this.overallReproEnvironments = finalData;
                        let incidentsLength = this.overallReproEnvironments.length;

                        if(incidentsLength != undefined && incidentsLength > 0){
                            this.lastPage = incidentsLength % this.recordDispLimit;
                            this.firstPage = incidentsLength - this.lastPage >= this.recordDispLimit ? this.recordDispLimit : this.lastPage;
                            this.totalPages = this.lastPage > 0 ? ((incidentsLength - (this.lastPage % this.recordDispLimit)) / this.recordDispLimit) + 1 : (incidentsLength / this.recordDispLimit);
                            if(incidentsLength > this.recordDispLimit){
                            this.reproEnvironments = this.overallReproEnvironments.slice(0,this.recordDispLimit); 
                            }
                            else if(incidentsLength <= this.recordDispLimit){
                                this.reproEnvironments = this.overallReproEnvironments.slice(0,incidentsLength);
                            }
                            this.currentPage = 1;
                            if(this.totalPages == 1 || this.totalPages == undefined || this.totalPages <= 0){
                                this.hidePreviousBTN = true;
                                this.hideNextBTN = true;
                                this.hideIncidentPagination = true;
                            }
                            else if(this.totalPages >= 2){
                                this.hidePreviousBTN = true;
                                this.hideNextBTN = false;
                                this.hideIncidentPagination = false;
                            }
                        }
                        else{
                            this.NoDataAfterRendering = true;
                            this.reproEnvironments = [];
                            this.hideIncidentPagination = true;
                        }
                    }
                    else{
                        this.NoDataAfterRendering = true;
                        this.reproEnvironments = [];
                        this.hideIncidentPagination = true;
                    }
                    
                })
                .catch((error) => {
                    //Promise for getReproEnvironments()
                    log(JSON.stringify(error));
                })
            //this.handleClick();
            this.doSorting();
        }
    }*/

    /* Get Case fields values */
    @wire(getRecord, { recordId: "$recordId", FIELDS })
    caseRecord;

    /*
    let caseSubject = getFieldValue(this.caseRecord.data, SUBJECT);
    let caseDescription = getFieldValue(this.caseRecord.data, DESCRIPTION);
    */

    /* Create new Repro Environment record */
    createReproEnv(evt){
        const defaultValues = encodeDefaultFieldValues({
            Case__c: this.recordId,
            Product__c: getFieldValue(this.caseRecord.data, PRODUCT),
            Version__c: getFieldValue(this.caseRecord.data, VERSION)
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Repro_Environment__c',
                actionName: 'new'                
            },
            state : {
                defaultFieldValues: defaultValues
            }
        });
    }

    /* Request Repro Environment --> JIRA Integration through Zagile app */
    reqReproEnv(event){

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {       
                apiName: 'Create New Issue',         
                url: '/apex/zsfjira__ZCreateOrEditIssue?id=' + this.recordId,
            }
        });     
    }

    /* When All TAB is selected add class 'tab-selected' to the element and show only the results corresponding to All TAB */
    handleAll(evt){
        this.disableSearch = false;
        if(!evt.currentTarget.classList.contains('tab-selected')){
            let attachedResults = this.template.querySelector('.AttachedResultsTab');
            if(attachedResults.classList.contains('tab-selected')){
                attachedResults.classList.remove('tab-selected');
            }
            evt.currentTarget.classList.add('tab-selected');
        }
        if(this.showAllTab != false){
            this.showAllTab = false;
            this.showAttResultsTab = true;
        }

        this.populateresults();
    }
        
   
    /* 
    When Attached Results TAB is selected add class 'tab-selected' to the element and show only results corresponding to Attached TAB 
    Render Case Repro Environments everytime, Attached Results TAB is selected.
    */
   handleAttachedResult(evt){
       this.disableSearch = true;
        if(!evt.currentTarget.classList.contains('tab-selected')){
            let allTab = this.template.querySelector('.AllTab');
            if(allTab.classList.contains('tab-selected')){
                allTab.classList.remove('tab-selected');
            }
            evt.currentTarget.classList.add('tab-selected');
        }
        if(this.showAttResultsTab != false){
            this.showAttResultsTab = false;
            this.showAllTab = true;
        }

        this.caserepro();
    }

    caserepro(){
        return new Promise((resolve, reject) => {
            getCaseReproEnvironments({ caseId : this.recordId })
            .then((result) => {
                log('case Repro Environments --> '+JSON.stringify(result));
                resolve(result);

                var tempResult = [];
                result.forEach(row => {
                    row['attachedToCase'] = true;
                    
                    if(row['Approval_Status__c'] && row['Approval_Status__c'] != 'Rejected' && row['Approval_Status__c'] == 'Approved'){
                        row['isApprovalPending'] = false;
                        row['attachedToCase'] = true;
                    }
                    if(row['Approval_Status__c'] && row['Approval_Status__c'] == 'Requested'){
                        row['isApprovalPending'] = true;
                        row['attachedToCase'] = true;
                    }
                    if(row['Repro_Environment__r'])
                      if(row['Repro_Environment__r']['RecordType'])
                        if(row['Repro_Environment__r']['RecordType']['DeveloperName'] == 'Docker')
                        row['backgroundStyle'] = Docker;                    
                    else{ 
                        row['backgroundStyle'] = iserver;
                    }
                   
                    if(row['Repro_Environment__r']){
                        if(row['Repro_Environment__r']['Name__c']){
                            row['Repro_Environment__r___Name'] = row['Repro_Environment__r']['Name__c'];
                        }
                        if(row['Case__r']['Support_Account__r']){
                            if(row['Case__r']['Support_Account__r']['Name'] != undefined){
                                row['Account__r___Name'] = row['Case__r']['Support_Account__r']['Name'];
                            }
                        }
                    }
                    
                    if(row['Repro_Environment__r']){
                        if(row['Repro_Environment__r']['Owner']){
                            if(row['Repro_Environment__r']['Owner']['Name']){
                                row['CaseOwner'] = row['Repro_Environment__r']['Owner']['Name'];
                            } else {
                                row['CaseOwner'] = 'No Owner defined';
                            }

                        } else {
                            row['CaseOwner'] = 'No Owner defined';
                        }
                    } else {
                        row['CaseOwner'] = 'No Owner defined';
                    }
                   
                    if(row['Repro_Environment__r']['Region__c']){                        
                            row['Region__c'] = row['Repro_Environment__r']['Region__c'];
                    } else {
                        row['Region__c'] = ' ';
                    }

                    
                    row['url'] = this.urlvalue2 +'/'+ row['Id']+'/view';
                    row['Approval_Status__c'] && row['Approval_Status__c'] == 'Approved' ? tempResult.push(row) : '';
                });

                log('After processing --> '+JSON.stringify(tempResult));
                this.overallAttReproEnvironments = tempResult;
                log('repro environments length --> '+this.overallAttReproEnvironments.length);
                this.handlePaginationATT(this.overallAttReproEnvironments);
                this.showSpinner = false;
            })
            .catch((error) => {
                log(JSON.stringify(error));
                reject(error);
            })
        });
    }

    handlePaginationATT(data){
        let incidentsLength = data.length;
        if(incidentsLength != undefined && incidentsLength > 0){
            this.NoDataAfterRendering_ATT = false;
            this.lastPage_ATT = incidentsLength % this.recordDispLimit_ATT;
            this.firstPage_ATT = incidentsLength - this.lastPage_ATT >= this.recordDispLimit_ATT ? this.recordDispLimit_ATT : this.lastPage_ATT;
            this.totalPages_ATT = this.lastPage_ATT > 0 ? ((incidentsLength - (this.lastPage_ATT % this.recordDispLimit_ATT)) / this.recordDispLimit_ATT) + 1 : (incidentsLength / this.recordDispLimit_ATT);
            log('First Page --> '+this.firstPage_ATT);
            log('Last Page --> '+this.lastPage_ATT);
            log('Total Pages --> '+this.totalPages_ATT);
            if(incidentsLength > this.recordDispLimit_ATT){
            this.attReproEnvironments = data.slice(0,this.recordDispLimit_ATT); 
            }
            else if(incidentsLength <= this.recordDispLimit_ATT){
                this.attReproEnvironments = data.slice(0,incidentsLength);
            }
        }
        else{
            this.NoDataAfterRendering_ATT = true;
            this.attReproEnvironments = undefined;
        }
        this.currentPage_ATT = 1;
        if(this.totalPages_ATT == 1 || this.totalPages_ATT == undefined || this.totalPages_ATT <= 0){
            this.hidePreviousBTN_ATT = true;
            this.hideNextBTN_ATT = true;
            this.hideIncidentPagination_ATT = true;
        }
        else if(this.totalPages_ATT >= 2){
            this.hidePreviousBTN_ATT = true;
            this.hideNextBTN_ATT = false;
            this.hideIncidentPagination_ATT = false;
        }
    }

    /* onMouseOver: Display the Menu Options */
    showMenuActions(evt){
        let target = evt.currentTarget;
        let resultFrame = target.children[0];
        let resultActionsMenu = resultFrame.children[0];

        if(!resultActionsMenu.classList.contains('show-actions')){
            resultActionsMenu.classList.add('show-actions');
        }
    }

    /* onMouseOut: Hide the Menu Options */
    hideMenuActions(evt){
        let target = evt.currentTarget;
        let resultFrame = target.children[0];
        let resultActionsMenu = resultFrame.children[0];

        if(resultActionsMenu.classList.contains('show-actions')){
            resultActionsMenu.classList.remove('show-actions');
        }
    }


    /* 
        Attach/Detach functionality for All TAB

        Attach: Get the respective Repro Environment ID, hide the attachment icon from the Repro Environment, 
                   show loader icon, on SUCCESS hide loader icon, show attachment icon again albeit in 
                   yellow color to indicate Repro Environment is attached to CASE . 
        Detach: Get the respective Repro Environment ID, hide the attachement icon from the Repro Environment,
                   show loader icon, on SUCCESS - hide loader icon, show attachment icon again albeit in 
                   black color to indicate Repro Environment is not attached to CASE. 
    */
    handleAttach(evt){
        let coveoAttach = evt.currentTarget;
        let ReproEnvId = coveoAttach.getAttribute('data-id');
        let ownerval = coveoAttach.getAttribute('data-owner');
        let coveoAttachChildren = coveoAttach.children.length;
        let coveoAttachIcon;
        let coveoLoading;
        let iconCaption;
        
        log('ownerval: '+ownerval);
        if(ownerval === 'false' || ownerval == undefined || ownerval == null){

        if(coveoAttachChildren > 0){
            for(var i = 0; i<coveoAttachChildren; i++){
                if(coveoAttach.children[i].classList.contains('coveo-attach-icon')){
                    coveoAttachIcon = coveoAttach.children[i];
                }
                if(coveoAttach.children[i].classList.contains('coveo-loading-icon')){
                    coveoLoading = coveoAttach.children[i];
                }
                if(coveoAttach.children[i].classList.contains('coveo-caption-for-icon')){
                    iconCaption = coveoAttach.children[i];
                }
            }
        }

        if(!coveoLoading.classList.contains('coveo-load')){
            coveoAttachIcon.classList.contains('hide') ? 'Do nothing' : coveoAttachIcon.classList.add('hide');
            coveoLoading.classList.add('coveo-load');
        }

        if(!coveoAttachIcon.classList.contains('coveo-attached')){

            attachReproEnvironmentToCase({ caseId : this.recordId, reproEnvironmentId : ReproEnvId, caseOwnerId : getFieldValue(this.caseRecord.data, OWNERID) })
                .then((result) => {
                    log('attachReproEnvironmentToCase --> '+JSON.stringify(result));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                    //coveoAttachIcon.classList.add('coveo-attached');
                    //iconCaption.innerHTML = 'Detach';
                    
                    try {
                        if(result){
                            let caseReproId = [];
    
                            result.forEach(row => {
                                if(row['Approval_Status__c'] == 'Requested'){
                                    caseReproId.push({ReproEnv : row['Repro_Environment__c'], isApprovalPending : true});
                                }
                                else if(row['Approval_Status__c'] == 'Approved'){
                                    caseReproId.push({ReproEnv : row['Repro_Environment__c'], isApprovalPending : false});
                                }
                            });
                            
                            log('after processing caseReproId --> '+JSON.stringify(caseReproId));
    
                            this.overallReproEnvironments.forEach(row => {
                                /*if(row['Id'] == ReproEnvId){
                                    row['attachedToCase'] = true;
                                }*/
                                caseReproId.forEach(col => {
                                    if(row['Id'] == col['ReproEnv']){
                                        if(col['isApprovalPending']){
                                            row['isApprovalPending'] = true;
                                            row['attachedToCase'] = true;
                                        }
                                        else if(!col['isApprovalPending']){
                                            row['isApprovalPending'] = false;
                                            row['attachedToCase'] = true;
                                        }
                                    }
                                });
                            });  
                            this.reproEnvironments.forEach(row => {                           
                                caseReproId.forEach(col => {
                                    if(row['Id'] == col['ReproEnv']){
                                        if(col['isApprovalPending']){
                                            row['isApprovalPending'] = true;
                                            row['attachedToCase'] = true;
                                        }
                                        else if(!col['isApprovalPending']){
                                            row['isApprovalPending'] = false;
                                            row['attachedToCase'] = true;
                                        }
                                    }
                                });
                            });
                            this.overallAttReproEnvironments.forEach(row => {                           
                                caseReproId.forEach(col => {
                                    if(row['Id'] == col['ReproEnv']){
                                        if(col['isApprovalPending']){
                                            row['isApprovalPending'] = true;
                                            row['attachedToCase'] = true;
                                        }
                                        else if(!col['isApprovalPending']){
                                            row['isApprovalPending'] = false;
                                            row['attachedToCase'] = true;
                                        }
                                    }
                                });
                            });
                            this.attReproEnvironments.forEach(row => {                           
                                caseReproId.forEach(col => {
                                    if(row['Id'] == col['ReproEnv']){
                                        if(col['isApprovalPending']){
                                            row['isApprovalPending'] = true;
                                            row['attachedToCase'] = true;
                                        }
                                        else if(!col['isApprovalPending']){
                                            row['isApprovalPending'] = false;
                                            row['attachedToCase'] = true;
                                        }
                                    }
                                });
                            });
                            if(this.reproEnvironments.length == 0){
                                this.NoDataAfterRendering = true;
                                this.reproEnvironments = undefined;
                            }
                            if(this.attReproEnvironments.length == 0){
                                this.NoDataAfterRendering_ATT = true;
                                this.attReproEnvironments = undefined;
                            }
                        }
                    } catch (error) {
                        log('attach-->try-->catch: '+JSON.stringify(error));
                    }

                    //log('after attach --> '+JSON.stringify(this.reproEnvironments));
                    
                })
                .catch((error) => {
                    log('Error on attach: '+JSON.stringify(error));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                    this.showToastEvent('Error Occured', error?.body?.message, 'error', 'dismissable');
                })
        }
        else if(coveoAttachIcon.classList.contains('coveo-attached')){
            detachReproEnvironmentFromCase({ caseId : this.recordId, reproEnvironmentId : ReproEnvId })
                .then((result) => {
                    log('detachReproEnvironmentFromCase --> '+result);
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                    //coveoAttachIcon.classList.remove('coveo-attached');
                    //iconCaption.innerHTML = 'Attach';
                    
                    try {
                        if(result){
                            log('ReproEnvId: '+ReproEnvId);
                            var indexvalue = 0;
                            this.overallReproEnvironments.forEach(row => {
                                if(row['Id'] == ReproEnvId){
                                    row['isApprovalPending'] = false;
                                    row['attachedToCase'] = false;
                                    //this.overallReproEnvironments.splice(indexvalue,1);                                                               
                                }
                                indexvalue = indexvalue + 1;
                            });
                            indexvalue = 0;
                            this.reproEnvironments.forEach(row => {
                                if(row['Id'] == ReproEnvId){
                                    row['isApprovalPending'] = false;
                                    row['attachedToCase'] = false;
                                    //this.reproEnvironments.splice(indexvalue,1);   
                                }
                                indexvalue = indexvalue + 1;
                            });
                            indexvalue = 0;
                            this.overallAttReproEnvironments.forEach(row => {
                                if(row['Repro_Environment__c'] == ReproEnvId){
                                    row['isApprovalPending'] = false;
                                    row['attachedToCase'] = false;
                                    this.overallAttReproEnvironments.splice(indexvalue,1); 
                                }
                                indexvalue = indexvalue + 1;
                            });
                            indexvalue = 0;
                            this.attReproEnvironments.forEach(row => {
                                if(row['Repro_Environment__c'] == ReproEnvId){
                                    row['isApprovalPending'] = false;
                                    row['attachedToCase'] = false;
                                    this.attReproEnvironments.splice(indexvalue,1); 
                                }
                                indexvalue = indexvalue + 1;
                            });
                            if(this.reproEnvironments.length == 0){
                                this.NoDataAfterRendering = true;
                                this.reproEnvironments = undefined;
                            }
                            if(this.attReproEnvironments.length == 0){
                                this.NoDataAfterRendering_ATT = true;
                                this.attReproEnvironments = undefined;
                            }
                            log('detached1: '+JSON.stringify(this.attReproEnvironments));
                            log('detached2: '+this.attReproEnvironments);
                        }
                    } catch (error) {
                        log('detach-->try-->catch: '+JSON.stringify(error));
                    }

                    //log('after detach --> '+JSON.stringify(this.reproEnvironments));
                    
                })
                .catch((error) => {
                    log('Error on detach: '+JSON.stringify(error));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                    this.showToastEvent('Error Occured', error?.body?.message, 'error', 'dismissable');
                })
        }      
    } else {
        this.showNotification();
    }
    }


    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Error Occured',
            message: 'You cannot attach Case when owner is a Queue',
            variant: 'error',
        });
        this.dispatchEvent(evt);
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

    /* All TAB pagination functionality */
    prevPage(evt){
        if(this.currentPage > 0 && this.currentPage != 1 && this.totalPages != 1){
            this.currentPage = this.currentPage - 1;
            this.reproEnvironments = this.overallReproEnvironments.slice((this.currentPage*this.recordDispLimit) - this.recordDispLimit,this.currentPage*this.recordDispLimit)
        }
        if(this.currentPage == 1){
            this.hidePreviousBTN = true;
        }
        if(this.currentPage == this.totalPages){
            this.hideNextBTN = true;
        }
        else{
            this.hideNextBTN = false;
        }
    }
    nextPage(evt){
        if(this.currentPage > 0 && this.currentPage < this.totalPages){
            this.currentPage = this.currentPage + 1;
            if(this.currentPage != this.totalPages){
               this.reproEnvironments = this.overallReproEnvironments.slice((this.currentPage*this.recordDispLimit) - this.recordDispLimit, this.currentPage*this.recordDispLimit); 
            }
            else if(this.currentPage == this.totalPages){
                let incidentLength = this.overallReproEnvironments.length;
                this.reproEnvironments = this.overallReproEnvironments.slice((incidentLength-(this.lastPage == 0 ? this.recordDispLimit : this.lastPage)), incidentLength);
            }
        }
        if(this.currentPage == 1){
            this.hidePreviousBTN = true;
        }
        else{
            this.hidePreviousBTN = false;
        }
        if(this.currentPage == this.totalPages){
            this.hideNextBTN = true;
        }
    }

    /* Attached Results TAB pagination functionality */
    prevPage_ATT(evt){
        if(this.currentPage_ATT > 0 && this.currentPage_ATT != 1 && this.totalPages_ATT != 1){
            this.currentPage_ATT = this.currentPage_ATT - 1;
            this.attReproEnvironments = this.overallAttReproEnvironments.slice((this.currentPage_ATT*this.recordDispLimit_ATT) - this.recordDispLimit_ATT, this.currentPage_ATT*this.recordDispLimit_ATT)
        }
        if(this.currentPage_ATT == 1){
            this.hidePreviousBTN_ATT = true;
        }
        if(this.currentPage_ATT == this.totalPages_ATT){
            this.hideNextBTN_ATT = true;
        }
        else{
            this.hideNextBTN_ATT = false;
        }
    }
    nextPage_ATT(evt){
        if(this.currentPage_ATT > 0 && this.currentPage_ATT < this.totalPages_ATT){
            this.currentPage_ATT = this.currentPage_ATT + 1;
            if(this.currentPage_ATT != this.totalPages_ATT){
               this.attReproEnvironments = this.overallAttReproEnvironments.slice((this.currentPage_ATT*this.recordDispLimit_ATT) - this.recordDispLimit_ATT, this.currentPage_ATT*this.recordDispLimit_ATT); 
            }
            else if(this.currentPage_ATT == this.totalPages_ATT){
                let incidentLength = this.overallAttReproEnvironments.length;
                this.attReproEnvironments = this.overallAttReproEnvironments.slice((incidentLength-(this.lastPage_ATT == 0 ? this.recordDispLimit_ATT : this.lastPage_ATT)), incidentLength);
            }
        }
        if(this.currentPage_ATT == 1){
            this.hidePreviousBTN_ATT = true;
        }
        else{
            this.hidePreviousBTN_ATT = false;
        }
        if(this.currentPage_ATT == this.totalPages_ATT){
            this.hideNextBTN_ATT = true;
        }
    }

    


    connectedCallback(){
        log('recid'+this.recordId);
        this.orderedExecution();
        this.initialize();        
    }

    async orderedExecution(){
        let promiseValue = await this.caserepro();
        if(promiseValue){
            log('this.attReproEnvironments: '+this.attReproEnvironments);
            let attachedResults = this.template.querySelector('.AttachedResultsTab');
            let allTab = this.template.querySelector('.AllTab');
            if(!this.attReproEnvironments){
                if(this.showAllTab){
                    if(attachedResults.classList.contains('tab-selected')){
                        attachedResults.classList.remove('tab-selected');
                        if(!allTab.classList.contains('tab-selected')){
                            allTab.classList.add('tab-selected');
                        }
                    }
                    else{
                        if(!allTab.classList.contains('tab-selected')){
                            allTab.classList.add('tab-selected');
                        }
                    }
                    this.showAllTab = false; 
                    this.showAttResultsTab = true;
                    this.populateresults();
                }
                log('show All tab');
            }
            else{
                log('show attached tab');
                if(allTab.classList.contains('tab-selected')){
                    allTab.classList.remove('tab-selected');
                    if(!attachedResults.classList.contains('tab-selected')){
                        attachedResults.classList.add('tab-selected');
                    }
                }
                else{
                    if(!attachedResults.classList.contains('tab-selected')){
                        attachedResults.classList.add('tab-selected');
                    }
                }
                this.showAllTab = true; 
                this.showAttResultsTab = false;
            }
        }
    }

    populateresults(){
        this.attReproEnvironmentIds = [];
        this.attPendingApprovalReproIds = [];
        getCaseReproEnvironments({ caseId : this.recordId })
            .then((result) => {
                
                log('case Repro Environments --> '+JSON.stringify(result));
                result.forEach( row => {
                    
                    if(row['Approval_Status__c'] && row['Approval_Status__c'] != 'Rejected' && row['Approval_Status__c'] == 'Approved'){
                        this.attReproEnvironmentIds.push(row['Repro_Environment__c']);
                    }
                    if(row['Approval_Status__c'] && row['Approval_Status__c'] == 'Requested'){
                        this.attPendingApprovalReproIds.push(row['Repro_Environment__c']); 
                    }
                });
                //log('attached Repro Environment Ids --> '+this.attReproEnvironmentIds);
                //return getReproEnvironments({ caseId : this.recordId });
                log('recid'+this.recordId);
                return getReproEnvironments({ lmt : 100, caseId : this.recordId});
            })
            .then((result) => {
                //Promise for getReproEnvironments()
                this.processAllReproEnvironments(result);
            })
            .catch((error) => {
                //Promise for getReproEnvironments()
                log(JSON.stringify(error));
            })
            .catch((error) => {
                //Promise for getCaseReproEnvironments()
                log(JSON.stringify(error));
            })
    }

    handlePagination(data){
        let incidentsLength = data.length;
        if(incidentsLength != undefined && incidentsLength > 0){
            this.NoDataAfterRendering = false;
            this.lastPage = incidentsLength % this.recordDispLimit;
            this.firstPage = incidentsLength - this.lastPage >= this.recordDispLimit ? this.recordDispLimit : this.lastPage;
            this.totalPages = this.lastPage > 0 ? ((incidentsLength - (this.lastPage % this.recordDispLimit)) / this.recordDispLimit) + 1 : (incidentsLength / this.recordDispLimit);
            //log('First Page --> '+this.firstPage);
            //log('Last Page --> '+this.lastPage);
            //log('Total Pages');
            if(incidentsLength > this.recordDispLimit){
                this.reproEnvironments = data.slice(0,this.recordDispLimit); 
            }
            else if(incidentsLength <= this.recordDispLimit){
                this.reproEnvironments = data.slice(0,incidentsLength);
            }
        }
        else{
            this.NoDataAfterRendering = true;
            this.reproEnvironments = undefined;
        }
        this.currentPage = 1;
        if(this.totalPages == 1 || this.totalPages == undefined || this.totalPages <= 0){
            this.hidePreviousBTN = true;
            this.hideNextBTN = true;
            this.hideIncidentPagination = true;
        }
        else if(this.totalPages >= 2){
            this.hidePreviousBTN = true;
            this.hideNextBTN = false;
            this.hideIncidentPagination = false;
        }
    }

   doSorting(){
       log('showAllTab: '+this.showAllTab);
       log('overallReproEnvironments: '+this.overallReproEnvironments);
       log('overallAttReproEnvironments: '+this.overallAttReproEnvironments);
       var data = this.showAllTab ? this.overallAttReproEnvironments : this.overallReproEnvironments;
       var searchedData = [];

       log('sortdata --> '+JSON.stringify(data));
       data.forEach(row => {
           var allRowValue = '';
           COLUMNS.forEach(column => {
               if(column && row[column]) {
                   allRowValue += row[column] + '---';
               }
           })
           allRowValue = allRowValue.toLowerCase();
           log('allRowValue = ' + allRowValue);
           if(allRowValue.indexOf(this.queryTerm?.toLowerCase()) >= 0) {
                searchedData.push(row);
           }
       });

       if(this.showAllTab){
           //this.attReproEnvironments = searchedData;
           this.handlePaginationATT(searchedData);
       }
       else{
           //this.reproEnvironments = searchedData;
           this.handlePagination(searchedData);
       }
   }

   //Vignesh D: 08-Nov-2021 #I2RT-4457 -------START-------

   showFilter = true;
   value = [];
   filterOptions = [];

   get showSearchFilter(){
       return this.filterOptions?.length ? true : false;
   }

   get searchFilters(){
       return this.filterOptions; 
   }
   
   get filterIcon(){
       return this.showFilter ? 'utility:filterList' : 'utility:close';
   }

   get filterVariant(){
       return this.showFilter ? 'border-filled' : 'brand';
   }

   filterHandler(){
       this.showFilter = !this.showFilter;
       const filterDropdown = this.template.querySelector('[data-id="filterDropdown"]');
       filterDropdown.classList.toggle('slds-is-open');
   }

   filterSelectHandler(objEvent){
       this.value = objEvent.detail.value;
   }

   handleKeyUp(objEvent) {
       const isEnterKey = objEvent.keyCode === 13;
       if (isEnterKey) {
           this.queryTerm = objEvent.target.value;
           if(this.showAllTab){
               this.doSorting();
           }
           else{
              this.search();
           }
       }
    }

    search(){
        let objParent = this;
        objParent.showSpinner = true;

        searchReproEnvironments({ caseId: objParent.recordId, searchTerm: objParent.queryTerm, filters: this.value.toString() })
        .then(lstReproEnvironments => {
            objParent.processAllReproEnvironments(lstReproEnvironments);
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
            objParent.showSpinner = false;
        })
    }

    processAllReproEnvironments(allReproEnvironments){
        log('Repro Environments --> '+JSON.stringify(allReproEnvironments));
        //log('Att Repro Environments --> '+this.attReproEnvironmentIds);
        allReproEnvironments.forEach(row => {
            row['url'] = this.urlvalue +'/'+ row['Id'] +'/view';
            if(this.attPendingApprovalReproIds.includes(row['Id'])){
                row['isApprovalPending'] = true;
                row['attachedToCase'] = true;
            }
            else if(this.attReproEnvironmentIds.includes(row['Id'])){
                row['isApprovalPending'] = false;
                row['attachedToCase'] = true;
            }
            else {
                row['isApprovalPending'] = false;
                row['attachedToCase'] = false;
            }
            if(row['Account__r']){
                if(row['Account__r']['Name']){
                    row['Account__r___Name'] = row['Account__r']['Name'];
                }

            }
            //log('supportaccoutnname'+row['case__r']['Support_account__r']['Name']);
            if (row['Case__r']){
               if (row['Case__r']['Support_Account__r']){
                  if (row['Case__r']['Support_Account__r']['Name']){
                        row['case__r__Supportname'] = row['Case__r']['Support_Account__r']['Name'];
                    } else{
                        row['case__r__Supportname'] = 'No Support Account Defined';
                    }
                 } else{
                        row['case__r__Supportname'] = 'No Support Account Defined';
                }   
            } else{
                row['case__r__Supportname'] = 'No Support Account Defined';
                row['CaseOwner'] = 'No Owner defined';
                row['ownerqueue'] = true;
            }
            
            if(row['OwnerId']){
                if(row['Owner']['Name']){
                    row['CaseOwner'] = row['Owner']['Name'];
                } else {
                    row['CaseOwner'] = 'No Owner defined';
                }
                var ownervalue = row['OwnerId'];
                log('owner value'+ownervalue);
                if(ownervalue.startsWith("00G")){
                    row['ownerqueue'] = true;
                }
                else if(ownervalue.startsWith("005")){
                    row['ownerqueue'] = false;
                } 

            } else {
                row['CaseOwner'] = 'No Owner defined';
                row['ownerqueue'] = true;
            }
            
           if(row['RecordType']){
            log('rectype:'+row['RecordType']['DeveloperName'] );
               if(row['RecordType']['DeveloperName'] == 'Docker'){                 
                log('docker set');
                row['backgroundStyle'] = Docker;
                row['title__c'] = 'Docker';
                row['idtype'] = 'ContainerId:';
                row['idvalue'] = row['ContainerId__c'];
               }
            else {
                log('iserverset');
                row['title__c'] = 'iServer';
                row['idtype'] = 'iServer MetadataKey:';
                row['idvalue'] = row['iServerMetaDataKey__c'];
                row['backgroundStyle'] = iserver;
           }
           }

        });
        log('After processing --> '+JSON.stringify(allReproEnvironments));
        this.overallReproEnvironments = allReproEnvironments;
        this.handlePagination(this.overallReproEnvironments);
        this.showSpinner = false;
    }

    initialize(){
        let objParent = this;
        objParent.filterOptions = [];

        getSearchFilters()
        .then(filtersMap => {
            Object.keys(filtersMap).forEach(filter => {objParent.filterOptions.push({label: filtersMap[filter], value: filter})});
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        })
    }

   //Vignesh D: 08-Nov-2021 #I2RT-4457 -------END---------
}