import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getPanopataIncidents from '@salesforce/apex/panoptaIncidentController.getPanopataIncidents';
import checkuser from '@salesforce/apex/GetInfoPanoptaAPI.checkuser';
import getCaseIncidents from '@salesforce/apex/panoptaIncidentController.getCaseIncidents';
import attachIncidentToCase from '@salesforce/apex/panoptaIncidentController.attachIncidentToCase';
import detachIncidentFromCase from '@salesforce/apex/panoptaIncidentController.detachIncidentFromCase';
import SUBJECT from "@salesforce/schema/Case.Subject";
import DESCRIPTION from "@salesforce/schema/Case.Description";
import OWNERID from "@salesforce/schema/Case.OwnerId";
import Panopta from '@salesforce/resourceUrl/Panopta';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PanoptaIntegration from '@salesforce/label/c.PanoptaIntegration';
import json2 from '@salesforce/resourceUrl/json2';


/* CASE Fields */
const fields = [SUBJECT, DESCRIPTION, OWNERID];
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search
const MINIMAL_SEARCH_TERM_LENGTH = 3; // Min number of chars required to search
const columns = ['Instance_Name__c', 'Incident_Id', 'Metric', 'Status', 'Incident_Start', 'Duration'];

export default class PanotpaIncidents extends NavigationMixin(LightningElement) {
    @api recordId;
    label = {PanoptaIntegration};


    urlvalue = "https://my.panopta.com/outage/IncidentDetails?incident_id";
    /* Search Query by user */
    queryTerm;
    @track disableSearch = false;

    /* Repro Environments and Case Repro Environments properties */
    @track overallIncidents;
    @track incidents;
    @track overallAttIncidents;
    @track attIncidents;
    attIncidentIds = [];
    @track NoDataAfterRendering = false;
    @track NoDataAfterRendering_ATT = false;
    showSpinner = false;
    @track popin = true;

    /* Tab properties */
    @track showAllTab = false;
    @track showAttResultsTab = true;

    /* All TAB Pagination properties */
    totalPages;
    firstPage;
    @track currentPage;
    lastPage;
    @track hidePreviousBTN;
    @track hideNextBTN;
    @track recordDispLimit = 5;
    @track showsearchresults = false;
    @track hideIncidentPagination;
    _searchThrottlingTimeout;

    /* Attached Results TAB Pagination properties */
    totalPages_ATT;
    firstPage_ATT;
    @track currentPage_ATT;
    lastPage_ATT;
    @track hidePreviousBTN_ATT;
    @track hideNextBTN_ATT;
    @track recordDispLimit_ATT = 5;
    @track hideIncidentPagination_ATT;

    @track caseowner;

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

    /* Get Case fields values */
    @wire(getRecord, { recordId: "$recordId", fields })
    caseRecord;


    get selectedSort() {
        return this.filters.filter(fil => fil.isSelected)[0].label;
    }

    get sortBy() {
        return this.filters.filter(fil => fil.isSelected)[0].value;
    }

    /* Edit Distance between two strings */
    levenshteinDistance = (str1 = '', str2 = '') => {
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
    };

    handlepopout(event) {
        this.popin = false;
        const custEvent = new CustomEvent('callpanopta');
        this.dispatchEvent(custEvent);
        console.log('handlepopout2 function'); console.log('popout value' + this.popin);
    }

    @api
    handlepopin() {
        console.log('called child component');
        this.popin = true;
    }

    handleSelect(event) {
        this.filters.forEach(fil => {
            fil.isSelected = fil.value == event.detail.value
        });

        let params = {
            sortBy: this.sortBy
        };

        this.handleClick();

        console.log('this.filters>>', JSON.parse(JSON.stringify(this.filters)));
    }

    /* When user provides term to search, update queryTerm property */
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        this.queryTerm = evt.target.value;
        console.log('event type:' + evt.type);
        console.log('queryTerm' + this.queryTerm);
        if (this.queryTerm != ' ' && this.queryTerm != undefined && this.queryTerm.length > 0) {
            this.showsearchresults = true;
            console.log('result' + this.showsearchresults);
        } else {
            this.showsearchresults = false;
            console.log('result else' + this.showsearchresults);
        }

        if (this._searchThrottlingTimeout) {
            clearTimeout(this._searchThrottlingTimeout);
        }

        this._searchThrottlingTimeout = setTimeout(() => {
            let dosearch;
            if (this.queryTerm != undefined && this.queryTerm != ' ' && this.queryTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                dosearch = true;
            } else {
                dosearch = false;
            }
            console.log('searching');
            this.doSorting();
            this._searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    /*
    let caseSubject = getFieldValue(this.caseRecord.data, SUBJECT);
    let caseDescription = getFieldValue(this.caseRecord.data, DESCRIPTION);
    */


    /* When All TAB is selected add class 'tab-selected' to the element and show only the results corresponding to All TAB */
    handleAll(evt) {
        this.disableSearch = false;
        this.queryTerm = ' ';
        if (!evt.currentTarget.classList.contains('tab-selected')) {
            let attachedResults = this.template.querySelector('.AttachedResultsTab');
            if (attachedResults.classList.contains('tab-selected')) {
                attachedResults.classList.remove('tab-selected');
            }
            evt.currentTarget.classList.add('tab-selected');
        }
        if (this.showAllTab != false) {
            this.showAllTab = false;
            this.showAttResultsTab = true;
        }

        this.populateresults();

    }


    /* 
    When Attached Results TAB is selected add class 'tab-selected' to the element and show only results corresponding to Attached TAB 
    Render Case Repro Environments everytime, Attached Results TAB is selected.
    */
    handleAttachedResult(evt) {
        this.disableSearch = true;
        this.queryTerm = ' ';
        if (!evt.currentTarget.classList.contains('tab-selected')) {
            let allTab = this.template.querySelector('.AllTab');
            if (allTab.classList.contains('tab-selected')) {
                allTab.classList.remove('tab-selected');
            }
            evt.currentTarget.classList.add('tab-selected');
        }
        if (this.showAttResultsTab != false) {
            this.showAttResultsTab = false;
            this.showAllTab = true;
        }
        this.caseincidents();
    }

    caseincidents() {
        //console.log('sort by'+this.sortBy);
        getCaseIncidents({ caseId: this.recordId, sortorder: this.sortBy })
            .then((result) => {
                //console.log('case Repro Environments --> '+JSON.stringify(result));

                result.forEach(row => {
                    row['attachedToCase'] = true;


                    if (row['Incident__r'] != undefined) {
                        if (row['Incident__r']['Instance_Name__c'] != undefined) {
                            row['Incident__r___Name'] = row['Incident__r']['Instance_Name__c'];
                        }
                        if (row['Incident__r']['Status__c'] != undefined) {
                            row['Incident__r___Status'] = row['Incident__r']['Status__c'];
                        }
                        if (row['Incident__r']['Incident_Summary__c'] != undefined) {
                            row['Incident__r___Summary'] = row['Incident__r']['Incident_Summary__c'];
                        }
                        if (row['Incident__r']['Metric_Tags__c'] != undefined) {
                            row['Metric'] = row['Incident__r']['Metric_Tags__c'];
                        } else {
                            row['Metric'] = 'No Metrics Tagged';
                        }
                        if (row['Incident__r']['Incident_Start_Time__c'] != undefined) {
                            row['Incident__r___StartTime'] = row['Incident__r']['Incident_Start_Time__c'];
                        }
                        if (row['Incident__r']['Incident_Id__c'] != undefined) {
                            row['url'] = this.urlvalue + '=' + row['Incident__r']['Incident_Id__c'];
                        }
                        if (row['Incident__r']['Incident_Id__c'] != undefined) {
                            row['Incident_Id'] = row['Incident__r']['Incident_Id__c'];
                            row['url'] = this.urlvalue + '=' + row['Incident__r']['Incident_Id__c'];
                        }
                        row['Incident__c'] = row['Incident__c'];
                        if (row['Incident__r']['Account__r'] != undefined) {
                            if (row['Incident__r']['Account__r']['Name'] != undefined) {
                                row['Account__r___Name'] = row['Incident__r']['Account__r']['Name'];
                            }
                        }
                    }
                    row['backgroundimage'] = Panopta;

                    if (row['Case__r'] != undefined) {
                        if (row['Case__r']['CaseNumber'] != undefined) {
                            row['Case__r_casenumber'] = row['Case__r']['CaseNumber'];
                        }
                    }


                });

                // console.log('After processing --> '+JSON.stringify(result));
                this.overallAttIncidents = result;
                //console.log('repro environments length --> '+this.overallAttIncidents.length);
                this.handlePaginationATT(this.overallAttIncidents);
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            })
    }

    /* onMouseOver: Display the Menu Options */
    showMenuActions(evt) {
        let target = evt.currentTarget;
        let resultFrame = target.children[0];
        let resultActionsMenu = resultFrame.children[0];

        if (!resultActionsMenu.classList.contains('show-actions')) {
            resultActionsMenu.classList.add('show-actions');
        }
    }

    /* onMouseOut: Hide the Menu Options */
    hideMenuActions(evt) {
        let target = evt.currentTarget;
        let resultFrame = target.children[0];
        let resultActionsMenu = resultFrame.children[0];

        if (resultActionsMenu.classList.contains('show-actions')) {
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
    handleAttach(evt) {
        let coveoAttach = evt.currentTarget;
        let ReproEnvId = coveoAttach.getAttribute('data-id');
        let coveoAttachChildren = coveoAttach.children.length;
        let coveoAttachIcon;
        let coveoLoading;
        let iconCaption;

        if (coveoAttachChildren > 0) {
            for (var i = 0; i < coveoAttachChildren; i++) {
                if (coveoAttach.children[i].classList.contains('coveo-attach-icon')) {
                    coveoAttachIcon = coveoAttach.children[i];
                }
                if (coveoAttach.children[i].classList.contains('coveo-loading-icon')) {
                    coveoLoading = coveoAttach.children[i];
                }
                if (coveoAttach.children[i].classList.contains('coveo-caption-for-icon')) {
                    iconCaption = coveoAttach.children[i];
                }
            }
        }

        if (!coveoLoading.classList.contains('coveo-load')) {
            coveoAttachIcon.classList.contains('hide') ? 'Do nothing' : coveoAttachIcon.classList.add('hide');
            coveoLoading.classList.add('coveo-load');
        }


        if (!coveoAttachIcon.classList.contains('coveo-attached')) {
            this.caseowner = getFieldValue(this.caseRecord.data, OWNERID);
            //console.log('this.caseowner'+this.caseowner);
            if (this.caseowner != 'undefined' && !this.caseowner.includes('00G')) {
                checkuser({ caseownerid: this.caseowner })
                    .then((result) => {
                        console.log('result checkuser'+JSON.stringify(result));
                        if (!result.includes('ERROR')) {
                            // console.log('user url'+result);
                            attachIncidentToCase({ caseId: this.recordId, incidentId: ReproEnvId, userurl: result })
                                .then((result) => {
                                    console.log('attachIncidentToCase --> '+JSON.stringify(result));
                                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                                    coveoAttachIcon.classList.add('coveo-attached');
                                    //iconCaption.innerHTML = 'Detach';

                                    if (result && result.length > 0) {
                                        let caseReproId = [];

                                        result.forEach(row => {
                                            caseReproId.push({ Incident__c: row['Incident__c'], attachedToCase: true });
                                        });

                                        //console.log('after processing caseReproId --> '+JSON.stringify(caseReproId));

                                        this.overallIncidents.forEach(row => {
                                            if (row['Id'] == ReproEnvId) {
                                                row['attachedToCase'] = true;
                                            }
                                            caseReproId.forEach(col => {
                                                if (row['Id'] == col['Incident__c']) {
                                                    row['attachedToCase'] = true;
                                                }
                                            });
                                        });
                                        this.incidents.forEach(row => {
                                            if (row['Id'] == ReproEnvId) {
                                                row['attachedToCase'] = true;
                                            }
                                            caseReproId.forEach(col => {
                                                if (row['Id'] == col['Incident__c']) {
                                                    row['attachedToCase'] = true;
                                                }
                                            });
                                        });
                                    }

                                    //console.log('after attach --> '+JSON.stringify(this.incidents));

                                })
                                .catch((error) => {
                                    console.log(JSON.stringify(error));
                                    console.log('Exception1');
                                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                                    this.showNotification('Exception While updating case' + JSON.stringify(error));
                                })
                        } else {
                            checkuser({ caseownerid: label.PanoptaIntegration})
                                .then((result) => {
                                    console.log('result checkuser'+JSON.stringify(result));
                                    if (!result.includes('ERROR')) {
                                        // console.log('user url'+result);
                                        attachIncidentToCase({ caseId: this.recordId, incidentId: ReproEnvId, userurl: result })
                                            .then((result) => {
                                                console.log('attachIncidentToCase --> '+JSON.stringify(result));
                                                coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                                                coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                                                coveoAttachIcon.classList.add('coveo-attached');
                                                //iconCaption.innerHTML = 'Detach';

                                                if (result && result.length > 0) {
                                                    let caseReproId = [];

                                                    result.forEach(row => {
                                                        caseReproId.push({ Incident__c: row['Incident__c'], attachedToCase: true });
                                                    });

                                                    //console.log('after processing caseReproId --> '+JSON.stringify(caseReproId));

                                                    this.overallIncidents.forEach(row => {
                                                        if (row['Id'] == ReproEnvId) {
                                                            row['attachedToCase'] = true;
                                                        }
                                                        caseReproId.forEach(col => {
                                                            if (row['Id'] == col['Incident__c']) {
                                                                row['attachedToCase'] = true;
                                                            }
                                                        });
                                                    });
                                                    this.incidents.forEach(row => {
                                                        if (row['Id'] == ReproEnvId) {
                                                            row['attachedToCase'] = true;
                                                        }
                                                        caseReproId.forEach(col => {
                                                            if (row['Id'] == col['Incident__c']) {
                                                                row['attachedToCase'] = true;
                                                            }
                                                        });
                                                    });
                                                }

                                                //console.log('after attach --> '+JSON.stringify(this.incidents));

                                            })
                                            .catch((error) => {
                                                console.log(JSON.stringify(error));
                                                console.log('Exception1');
                                                coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                                                coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                                                this.showNotification('Exception While updating case' + JSON.stringify(error));
                                            })

                                        }
                        
                    })
                    .catch((error) => {
                        console.log(JSON.stringify(error));
                        console.log('Exception2');
                        coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                        coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                        this.showNotification('Exception While updating case' + JSON.stringify(error));
                    })
            } 
        }).catch((error) => {
            console.log(JSON.stringify(error));
            console.log('Exception2');
            coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
            coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
            this.showNotification('Exception While updating case' + JSON.stringify(error));
        })
    }else {
                coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                this.showNotification('Owner should be a person befor attaching');
            }
        }
        else if (coveoAttachIcon.classList.contains('coveo-attached')) {
            detachIncidentFromCase({ caseId: this.recordId, incidentId: ReproEnvId })
                .then((result) => {
                    console.log('detachIncidentFromCase --> ' + result);
                    console.log('reproid:' + ReproEnvId);
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                    coveoAttachIcon.classList.remove('coveo-attached');
                    //iconCaption.innerHTML = 'Attach';
                    var indexvalue = 0;
                    if (!result.includes('Error:')) {
                        indexvalue = 0;
                        console.log('detach');
                        this.overallIncidents.forEach(row => {
                            if (row['Id'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                console.log('overall');
                                //this.overallIncidents.splice(indexvalue,1);
                            }
                            indexvalue = indexvalue + 1;
                        });
                        indexvalue = 0;
                        this.incidents.forEach(row => {
                            if (row['Id'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                console.log('page');
                                // this.incidents.splice(indexvalue,1)
                            }
                            indexvalue = indexvalue + 1;
                        });
                    }


                    if (!result.includes('Error:')) {
                        var indexvalue = 0;
                        this.overallAttIncidents.forEach(row => {
                            console.log('row:' + row);
                            if (row['Incident__c'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                this.overallAttIncidents.splice(indexvalue, 1);
                                console.log('overallattach');
                            }
                            indexvalue = indexvalue + 1;
                        });
                        indexvalue = 0;
                        this.attIncidents.forEach(row => {
                            if (row['Incident__c'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                this.attIncidents.splice(indexvalue, 1);
                                console.log('pageattach');
                            }
                            indexvalue = indexvalue + 1;
                        });

                    }



                    console.log('after detach --> ' + JSON.stringify(this.incidents));

                })
                .catch((error) => {

                    console.log('error' + JSON.stringify(error));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                })
        }

    }

    showNotification(toastmessagevalue) {
        //console.log('notification message'+toastmessagevalue);
        const evt = new ShowToastEvent({
            title: 'Error Occured',
            message: toastmessagevalue,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    /* 
        Attach/Detach functionality for Attached Results TAB
        
        Attach: Get the respective Repro Environment ID, hide the attachment icon from the Repro Environment, 
                   show loader icon, on SUCCESS hide loader icon, show attachment icon again albeit in 
                   yellow color to indicate Repro Environment is attached to CASE . 
        Detach: Get the respective Repro Environment ID, hide the attachement icon from the Repro Environment,
                   show loader icon, on SUCCESS - hide loader icon, show attachment icon again albeit in 
                   black color to indicate Repro Environment is not attached to CASE. 
    */
    handleAttach_ATT(evt) {
        let coveoAttach = evt.currentTarget;
        let ReproEnvId = coveoAttach.getAttribute('data-id');
        let coveoAttachChildren = coveoAttach.children.length;
        let coveoAttachIcon;
        let coveoLoading;
        let iconCaption;

        if (coveoAttachChildren > 0) {
            for (var i = 0; i < coveoAttachChildren; i++) {
                if (coveoAttach.children[i].classList.contains('coveo-attach-icon')) {
                    coveoAttachIcon = coveoAttach.children[i];
                }
                if (coveoAttach.children[i].classList.contains('coveo-loading-icon')) {
                    coveoLoading = coveoAttach.children[i];
                }
                if (coveoAttach.children[i].classList.contains('coveo-caption-for-icon')) {
                    iconCaption = coveoAttach.children[i];
                }
            }
        }

        if (!coveoLoading.classList.contains('coveo-load')) {
            coveoAttachIcon.classList.contains('hide') ? 'Do nothing' : coveoAttachIcon.classList.add('hide');
            coveoLoading.classList.add('coveo-load');
        }

        if (!coveoAttachIcon.classList.contains('coveo-attached')) {

            attachIncidentToCase({ caseId: this.recordId, incidentId: ReproEnvId })
                .then((result) => {
                    // console.log('attachIncidentToCase --> '+result);
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';

                    if (!result.includes('Error:')) {
                        let caseReproId = [];

                        result.forEach(row => {
                            caseReproId.push({ Incident__c: row['Incident__c'], attachedToCase: true });
                        });

                        this.overallAttIncidents.forEach(row => {
                            if (row['Repro_Environment__c'] == ReproEnvId) {
                                row['attachedToCase'] = true;
                            }
                            caseReproId.forEach(col => {
                                if (row['Incident__c'] == col['Incident__c']) {
                                    row['attachedToCase'] = true;
                                }
                            });
                        });
                        this.attIncidents.forEach(row => {
                            /*if(row['Repro_Environment__c'] == ReproEnvId){
                                row['attachedToCase'] = true;
                            }*/
                            caseReproId.forEach(col => {
                                if (row['Incident__c'] == col['Incident__c']) {
                                    row['attachedToCase'] = true;
                                }
                            });
                        });
                    }

                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                })
        }
        else if (coveoAttachIcon.classList.contains('coveo-attached')) {
            detachIncidentFromCase({ caseId: this.recordId, incidentId: ReproEnvId })
                .then((result) => {
                    //console.log('detachIncidentFromCase --> '+result);
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';

                    if (!result.includes('Error:')) {
                        var indexvalue = 0;
                        this.overallAttIncidents.forEach(row => {

                            if (row['Incident__c'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                this.overallAttIncidents.splice(indexvalue, 1);
                            }
                            indexvalue = indexvalue + 1;
                        });
                        indexvalue = 0;
                        this.attIncidents.forEach(row => {
                            if (row['Incident__c'] == ReproEnvId) {
                                row['attachedToCase'] = false;
                                this.attIncidents.splice(indexvalue, 1);
                            }
                            indexvalue = indexvalue + 1;
                        });

                    }

                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    coveoLoading.classList.contains('coveo-load') ? coveoLoading.classList.remove('coveo-load') : 'Do nothing';
                    coveoAttachIcon.classList.contains('hide') ? coveoAttachIcon.classList.remove('hide') : 'Do nothing';
                })
        }
    }


    /* All TAB pagination functionality */
    prevPage(evt) {
        if (this.currentPage > 0 && this.currentPage != 1 && this.totalPages != 1) {
            this.currentPage = this.currentPage - 1;
            this.incidents = this.overallIncidents.slice((this.currentPage * this.recordDispLimit) - this.recordDispLimit, this.currentPage * this.recordDispLimit)
        }
        if (this.currentPage == 1) {
            this.hidePreviousBTN = true;
        }
        if (this.currentPage == this.totalPages) {
            this.hideNextBTN = true;
        }
        else {
            this.hideNextBTN = false;
        }
    }
    nextPage(evt) {
        if (this.currentPage > 0 && this.currentPage < this.totalPages) {
            this.currentPage = this.currentPage + 1;
            if (this.currentPage != this.totalPages) {
                this.incidents = this.overallIncidents.slice((this.currentPage * this.recordDispLimit) - this.recordDispLimit, this.currentPage * this.recordDispLimit);
            }
            else if (this.currentPage == this.totalPages) {
                let incidentLength = this.overallIncidents.length;
                this.incidents = this.overallIncidents.slice((incidentLength - (this.lastPage == 0 ? this.recordDispLimit : this.lastPage)), incidentLength);
            }
        }
        if (this.currentPage == 1) {
            this.hidePreviousBTN = true;
        }
        else {
            this.hidePreviousBTN = false;
        }
        if (this.currentPage == this.totalPages) {
            this.hideNextBTN = true;
        }
    }

    /* Attached Results TAB pagination functionality */
    prevPage_ATT(evt) {
        if (this.currentPage_ATT > 0 && this.currentPage_ATT != 1 && this.totalPages_ATT != 1) {
            this.currentPage_ATT = this.currentPage_ATT - 1;
            this.attIncidents = this.overallAttIncidents.slice((this.currentPage_ATT * this.recordDispLimit_ATT) - this.recordDispLimit_ATT, this.currentPage_ATT * this.recordDispLimit_ATT)
        }
        if (this.currentPage_ATT == 1) {
            this.hidePreviousBTN_ATT = true;
        }
        if (this.currentPage_ATT == this.totalPages_ATT) {
            this.hideNextBTN_ATT = true;
        }
        else {
            this.hideNextBTN_ATT = false;
        }
    }
    nextPage_ATT(evt) {
        if (this.currentPage_ATT > 0 && this.currentPage_ATT < this.totalPages_ATT) {
            this.currentPage_ATT = this.currentPage_ATT + 1;
            if (this.currentPage_ATT != this.totalPages_ATT) {
                this.attIncidents = this.overallAttIncidents.slice((this.currentPage_ATT * this.recordDispLimit_ATT) - this.recordDispLimit_ATT, this.currentPage_ATT * this.recordDispLimit_ATT);
            }
            else if (this.currentPage_ATT == this.totalPages_ATT) {
                let incidentLength = this.overallAttIncidents.length;
                this.attIncidents = this.overallAttIncidents.slice((incidentLength - (this.lastPage_ATT == 0 ? this.recordDispLimit_ATT : this.lastPage_ATT)), incidentLength);
            }
        }
        if (this.currentPage_ATT == 1) {
            this.hidePreviousBTN_ATT = true;
        }
        else {
            this.hidePreviousBTN_ATT = false;
        }
        if (this.currentPage_ATT == this.totalPages_ATT) {
            this.hideNextBTN_ATT = true;
        }
    }

    handleClick() {
        this.showSpinner = true;
        if (this.showAllTab) {
            this.caseincidents();
        } else {
            this.populateresults();
        }
    }

    connectedCallback() {
        this.populateresults();
        this.caseowner = getFieldValue(this.caseRecord.data, OWNERID);
        //console.log('caseowner'+this.caseowner);
    }
    populateresults() {
        console.log('sort by' + this.sortBy);
        let sortby = this.sortBy;
        getCaseIncidents({ caseId: this.recordId, sortorder: this.sortBy })
            .then((result) => {

                console.log('case Incidents --> ' + JSON.stringify(result));
                this.attIncidentIds = [];
                result.forEach(row => {
                    console.log('incidentids' + row['Incident__r']);
                    this.attIncidentIds.push(row['Incident__r']['Incident_Id__c']);
                });
                console.log('attached Incident Ids --> ' + this.attIncidentIds);
                //return getPanopataIncidents({ caseId : this.recordId });
                //console.log('sort by order'+JSON.stringify(result));
                return getPanopataIncidents({ caseId: this.recordId, sortorder: sortby, searchTerm: '' });
            })
            .then((result) => {
                //Promise for getPanopataIncidents()
                console.log('Incidents --> '+JSON.stringify(result));
                console.log('Att Repro Environments --> '+this.attIncidentIds);
                result.forEach(row => {


                    if (this.attIncidentIds.includes(row['Incident_Id__c'])) {
                        row['attachedToCase'] = true;
                    }
                    else {
                        row['attachedToCase'] = false;
                    }
                    if (row['Account__r'] != undefined) {
                        if (row['Account__r']['Name'] != undefined) {
                            row['Account__r___Name'] = row['Account__r']['Name'];
                        }

                    } else {
                        row['Account__r___Name'] = 'No Support Account Defined';
                    }


                    row['Instance_Name'] = row['Instance_Name__c'];
                    row['Status'] = row['Status__c'];
                    row['Incident_Summary'] = row['Incident_Summary__c'];
                    row['Incident_Start'] = row['Incident_Start_Time__c'];
                    row['Server_ID'] = row['Server_ID__c'];
                    row['Incident_Id'] = row['Incident_Id__c'];
                    row['Metric'] = row['Metric_Tags__c'];
                    row['backgroundimage'] = Panopta;
                    row['url'] = this.urlvalue + '=' + row['Incident_Id__c'];
                    //row['Server_ID'] = row['Server_ID__c'];


                    var d1 = new Date();
                    var d2 = new Date(d1.getUTCFullYear(), d1.getUTCMonth() + 1, d1.getUTCDate(), d1.getUTCHours(), d1.getUTCMinutes(), d1.getUTCSeconds());
                    //console.log(d2);
                    row['Duration'] = this.datediff(row['Incident_Start_Time__c'], d2);
                    //console.log('duration:'+ row['Duration']);
                });
                console.log('After processing --> ' + JSON.stringify(result));
                this.overallIncidents = result;
                console.log('repro environments length --> ' + this.overallIncidents.length);
                this.handlePagination(this.overallIncidents);
                this.showSpinner = false;
            })
            .catch((error) => {
                //Promise for getPanopataIncidents()
                console.log(JSON.stringify(error));
            })
            .catch((error) => {
                //Promise for getCaseIncidents()
                console.log(JSON.stringify(error));
            })
    }

    datediff(createdate, datenow) {

        if(createdate){
            //console.log('entering datediff');
            var year = createdate.slice(0, 4);
            var month = createdate.slice(5, 7);
            var day = createdate.slice(8, 10);
            var hour = createdate.slice(11, 13);
            var minute = createdate.slice(14, 16);
            var second = createdate.slice(17, 19);

            var createdate_a = new Date(year, month, day, hour, minute, second);




            var utc_a = new Date(datenow.toUTCString());
            var utc_b = new Date(createdate_a.toUTCString());
            //console.log(utc_a);
            //console.log(utc_b);
            var diff = (utc_a - utc_b);
            //console.log('diff'+diff); 

            var days = Math.floor(diff / (1000 * 60 * 60 * 24));
            var hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var min = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            var sec = Math.floor((diff % (1000 * 60)) / 1000);

            return days + " Days " + hours + " Hours " + min + " Minutes " + sec + " Seconds";
        }
        else{
            return '';
        }


    }

    handlePagination(data){
        let incidentsLength = data.length;
        if (incidentsLength != undefined && incidentsLength > 0) {
            this.lastPage = incidentsLength % this.recordDispLimit;
            this.firstPage = incidentsLength - this.lastPage >= this.recordDispLimit ? this.recordDispLimit : this.lastPage;
            this.totalPages = this.lastPage > 0 ? ((incidentsLength - (this.lastPage % this.recordDispLimit)) / this.recordDispLimit) + 1 : (incidentsLength / this.recordDispLimit);
            console.log('First Page --> '+this.firstPage);
            console.log('Last Page --> '+this.lastPage);
            console.log('Total Pages --> '+this.totalPages);
            if (incidentsLength > this.recordDispLimit) {
                this.incidents = this.overallIncidents.slice(0, this.recordDispLimit);
            }
            else if (incidentsLength <= this.recordDispLimit) {
                this.incidents = this.overallIncidents.slice(0, incidentsLength);
            }
            this.NoDataAfterRendering = false;
        }
        else {
            this.NoDataAfterRendering = true;
            this.incidents = undefined;
        }
        this.currentPage = 1;
        if (this.totalPages == 1 || this.totalPages == undefined || this.totalPages <= 0) {
            this.hidePreviousBTN = true;
            this.hideNextBTN = true;
            this.hideIncidentPagination = true;
        }
        else if (this.totalPages >= 2) {
            this.hidePreviousBTN = true;
            this.hideNextBTN = false;
            this.hideIncidentPagination = false;
        }
        console.log('incident after pagination: '+JSON.stringify(this.incidents));
        console.log('overall after pagination: '+JSON.stringify(this.overallIncidents));
    }

    handlePaginationATT(data){
        let incidentsLength = data.length;
        if (incidentsLength != undefined && incidentsLength > 0) {
            this.lastPage_ATT = incidentsLength % this.recordDispLimit_ATT;
            this.firstPage_ATT = incidentsLength - this.lastPage_ATT >= this.recordDispLimit_ATT ? this.recordDispLimit_ATT : this.lastPage_ATT;
            this.totalPages_ATT = this.lastPage_ATT > 0 ? ((incidentsLength - (this.lastPage_ATT % this.recordDispLimit_ATT)) / this.recordDispLimit_ATT) + 1 : (incidentsLength / this.recordDispLimit_ATT);
            // console.log('First Page --> '+this.firstPage_ATT);
            // console.log('Last Page --> '+this.lastPage_ATT);
            // console.log('Total Pages --> '+this.totalPages_ATT);
            if (incidentsLength > this.recordDispLimit_ATT) {
                this.attIncidents = this.overallAttIncidents.slice(0, this.recordDispLimit_ATT);
            }
            else if (incidentsLength <= this.recordDispLimit_ATT) {
                this.attIncidents = this.overallAttIncidents.slice(0, incidentsLength);
            }
            this.NoDataAfterRendering_ATT = false;
        }
        else {
            this.NoDataAfterRendering_ATT = true;
            this.attIncidents = undefined;
        }
        this.currentPage_ATT = 1;
        if (this.totalPages_ATT == 1 || this.totalPages_ATT == undefined || this.totalPages_ATT <= 0) {
            this.hidePreviousBTN_ATT = true;
            this.hideNextBTN_ATT = true;
            this.hideIncidentPagination_ATT = true;
        }
        else if (this.totalPages_ATT >= 2) {
            this.hidePreviousBTN_ATT = true;
            this.hideNextBTN_ATT = false;
            this.hideIncidentPagination_ATT = false;
        }
    }

    doSorting(){
        console.log('showAllTab: '+this.showAllTab);
        console.log('overallIncidents: '+this.overallIncidents);
        console.log('overallAttIncidents: '+this.overallAttIncidents);
        var data = this.showAllTab ? this.overallAttIncidents : this.overallIncidents;
        var searchedData = [];
 
        console.log('sortdata --> '+JSON.stringify(data));
        data.forEach(row => {
            var allRowValue = '';
            columns.forEach(column => {
                if(column && row[column]) {
                    allRowValue += row[column] + '---';
                }
            })
            allRowValue = allRowValue.toLowerCase();
            console.log('allRowValue = ' + allRowValue);
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


}