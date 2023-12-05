/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         12/22/2021  I2RT-5011   T01     to persist the column selection for the Manage Cases table
balajip         01/06/2022  I2RT-5229   T02     show proper error message on saving changes to Escalation Notes
Sandeep         2/17/2022   I2RT-5327           GEMS - UI and Scrollbar issue - Under Manage Escalated Cases for 'Other Cases' tab scrollbar doesn't show all cases
balajip         02/14/2023  I2RT-0000   T04     reset the flag escalatecase on clicking the assign button
Shashikanth     06/16/2023  I2RT-8535   T05     GEMS: Manage Escalated cases to have all cases from that Customer Account
*/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { loadStyle} from 'lightning/platformResourceLoader';    //<T05>

import getCases from '@salesforce/apex/EngagementController.getCases';
import updateEscalationNotes from '@salesforce/apex/EngagementController.updateEscalationNotes';
import updateCases from '@salesforce/apex/EngagementController.updateCases';
import associateCasesToEngagement from '@salesforce/apex/SupportAccountController.associateCasesToEngagement';
import removecasesfromEngagement from '@salesforce/apex/EngagementController.removecasesfromEngagement';
import getTableColumns from '@salesforce/apex/EngagementController.getTableColumns'; //T01
import saveTableColumns from '@salesforce/apex/EngagementController.saveTableColumns'; //T01

import FIELD_ENGAGEMENT_NAME from '@salesforce/schema/Engagement__c.Name';
import FIELD_ENGAGEMENT_TITLE from '@salesforce/schema/Engagement__c.Title__c';
import FIELD_ENGAGEMENT_STATUS from '@salesforce/schema/Engagement__c.Status__c';
import FIELD_ENGAGEMENT_SUPPORT_ACCOUNT from '@salesforce/schema/Engagement__c.Support_Account__c';
import FIELD_ENGAGEMENT_ACCOUNT from '@salesforce/schema/Engagement__c.Support_Account__r.ParentId';    //<T05>

import GCS_RESOURCE from '@salesforce/resourceUrl/gcsSrc';      //<T05>

const actions = [
    { label: 'Add Case Comment', name: 'collaborate' }
];

const ENGAGEMENT_FIELDS = [
    FIELD_ENGAGEMENT_NAME,
    FIELD_ENGAGEMENT_TITLE,
    FIELD_ENGAGEMENT_STATUS,
    FIELD_ENGAGEMENT_SUPPORT_ACCOUNT,
    FIELD_ENGAGEMENT_ACCOUNT                //<T05>
];

const CASE_TABLE_COLUMNS =  [
    { label: 'Support Account', value: 'supportAccountName' },      //<T05>
    { label: 'Product', value: 'product' },
    { label: 'Version', value: 'version' },
    { label: 'Date Opened', value: 'dateOpened' },
    { label: 'Status', value: 'status' },
    { label: 'Priority', value: 'priority' },
    { label: 'Subject', value: 'subject' },
    //{ label: 'Closed Date', value: 'closedDate' },
    { label: 'Closing Notes', value: 'closingNotes'},
    { label: 'Escalation Notes', value: 'escalationNotes'},
    //{ label: 'Case Owner Review', value: 'caseownerreview'},
    { label: 'Case Owner', value: 'caseOwner'},
    { label: 'Owner Manager', value: 'caseOwnerManager'},
    { label: 'Next Action', value: 'nextaction'},
    { label: 'Case Last Activity', value: 'caselastactivity'}
];

const MANDATORY_COLUMNS_BEGIN = [
    { columnName: 'caseNumber', label: 'Case Number', fieldName: 'id', type: 'recordName', typeAttributes: {recId: { fieldName: 'id'}, recordNumber: { fieldName: 'caseNumber'}, isEscalated: {fieldName: 'isEscalated'}, showPreview: true},sortable: true},
    { columnName: 'caseId', label: 'Id', fieldName: 'id', fixedWidth: 1}
];

const MANDATORY_COLUMNS_END = [
    //{ columnName: 'action', type: 'action', typeAttributes: {rowActions: actions}},
];

const CASE_COLUMNS = [
    { columnName: 'supportAccountName', label: 'Support Account', fieldName: 'supportAccountName',sortable: true , wrapText: true,cellAttributes: {class:'custom-word-break'}},     //<T05>
    { columnName: 'product', label: 'Product', fieldName: 'product',sortable: true, wrapText: true,cellAttributes: {class:'custom-word-break'} },
    //{ columnName: 'version', label: 'Version', fieldName: 'version',sortable: true },
    { columnName: 'dateOpened', label: 'Date Opened', fieldName: 'dateOpened',sortable: true, wrapText: true,type: "date",typeAttributes:{year: "numeric",month: "short",day: "2-digit"    } ,cellAttributes: {class:'custom-word-break'}},
    { columnName: 'status', label: 'Status', fieldName: 'status',sortable: true, initialWidth: 80, wrapText: true, cellAttributes: {class:'custom-word-break'}},
    { columnName: 'priority', label: 'Priority', fieldName: 'priority',sortable: true, initialWidth: 90 , wrapText: true, cellAttributes: {class:'custom-word-break'}},
    { columnName: 'caseOwner', label: 'Case Owner', fieldName: 'ownerName',sortable: true , wrapText: true,cellAttributes: {class:'custom-word-break'}},
    { columnName: 'caseOwnerManager', label: 'Owner Manager', fieldName: 'ownerManagerName',sortable: true , wrapText: true, cellAttributes: {class:'custom-word-break'}},
    { columnName: 'subject', label: 'Subject', fieldName: 'subject',sortable: true, wrapText: true, initialWidth: 100, cellAttributes: {class:'custom-word-break'}},
    { columnName: 'closingNotes', label: 'Closing Notes', fieldName: 'closingNotes',sortable: true, wrapText: true, cellAttributes: {class:'custom-word-break'} },
    { columnName: 'escalationNotes', label: 'Escalation Notes', fieldName: 'escalationNotes', wrapText: true, editable : 'true',sortable: true},
    //{ columnName: 'caseownerreview', label: 'Case Owner Review', fieldName: 'caseownerreview', wrapText: true,sortable: true },
    { columnName: 'nextaction', label: 'Next Action', fieldName: 'nextaction',sortable: true, wrapText: true, cellAttributes: {class:'custom-word-break'}},
    { columnName: 'caselastactivity', label: 'Case Last Activity', fieldName: 'caselastactivity',sortable: true, wrapText: true, cellAttributes: {class:'custom-word-break'}},
];

const OTHER_CASE_COLUMNS = [
    //{ label: 'Case Owner', fieldName: 'ownerName' },
    { label: 'Case Number', fieldName: 'caseNumber', type: 'recordName', typeAttributes: {recId: { fieldName: 'id'}, recordNumber: { fieldName: 'caseNumber'}, isEscalated: {fieldName: 'isEscalated'}},sortable: true},
    { label: 'Product', fieldName: 'product',sortable: true },
    //{ label: 'Version', fieldName: 'version',sortable: true },
    //{ label: 'Date Opened', fieldName: 'dateOpened' },
    { label: 'Status', fieldName: 'status',sortable: true, initialWidth: 80 },
    { label: 'Priority', fieldName: 'priority',sortable: true, initialWidth: 90 },
    //{ label: 'Subject', fieldName: 'subject' },
    { label: 'Id', fieldName: 'id', fixedWidth: 1,sortable: true}
];

const DEFAULT_COLUMN_NAMES = ['supportAccountName','product', 'status', 'priority', 'caseOwner', 'dateOpened','closingNotes', 'escalationNotes', 'caseownerreview'];

export default class EngagementManageCases extends LightningElement {
    caseTableColumns = CASE_TABLE_COLUMNS;
    @track caseColumns = MANDATORY_COLUMNS_BEGIN;
    otherCaseColumns = OTHER_CASE_COLUMNS;

    @track selectedColumns = DEFAULT_COLUMN_NAMES;
    
    @api recordId;

    @track supportAccountId;
    @track customerAccountId;               //<T05>
    @track cases = [];
    @track draftValues = [];

    @track otherCases = [];
    @track filteredOtherCases = [];

    //<T05>
    @track allCases = [];
    @track filteredAllCases = [];
    //</T05>

    @track showNoCaseMessage=false;
    @track showInProgress=false;

    @track showCollab=false;
    @track showUpdateNotes=false;
    @track showColumnConfig=false;

    @track showConfirmationModal=false;
    @track escalatecase = true;

    @track rowActionCaseId;

    //tab properties
    @track currentTabValue;

    //sort properties
    @track sortBy;
    @track sortDirection;

    @wire(getRecord, { recordId: '$recordId', fields: ENGAGEMENT_FIELDS })
    engagement({ error, data }) {
        if (error) {
            console.log("error fetching engagement details - " + JSON.stringify(error));
        } else if (data) {
            console.log("data.fields - " + JSON.stringify(data.fields));
            this.supportAccountId = getFieldValue(data, FIELD_ENGAGEMENT_SUPPORT_ACCOUNT);
            this.customerAccountId = getFieldValue(data, FIELD_ENGAGEMENT_ACCOUNT);             //<T05>
            console.log("supportAccountId - " + this.supportAccountId);
        
            this.showInProgress = true;
            this.fetchCases();
        }
    }

    fetchCases(){
        var cases = [];
        var otherCases = [];
        var allCases = [];                                  //<T05>

        getCases({ 
            engagementId: this.recordId,
            supportAccountId: this.supportAccountId,
            customerAccountId: this.customerAccountId           //<T05>
        })
        .then(result => {
            console.log('result - ' + JSON.stringify(result));

            result.forEach(element => {
                console.log('element - ' + JSON.stringify(element));

                var createdDate = element.CreatedDate.substr(0, 10);
                /*var closedDate = '';
                if(element.ClosedDate){
                    element.ClosedDate.substr(0, 10);
                }*/

                var escalationIcon='';
                if(element.IsEscalated){
                    escalationIcon = 'utility:up';
                }
                var closingNotes = '';
                if(element.Closing_Notes__c){
                    closingNotes = element.Closing_Notes__c.replace( /(<([^>]+)>)/ig, '');
                }
                var ownerManagerName = '';
                if(element.Case_Owner_Manager__c){
                    ownerManagerName = element.Case_Owner_Manager__r.Name;
                }

                //<T05>
                let supportAccountName = '';
                if(element.Support_Account__c){
                    supportAccountName = element.Support_Account__r.Name;
                }
                //</T05>
                var cse = {
                    id: element.Id,
                    caseNumber: element.CaseNumber,
                    priority: element.Priority,
                    product: element.Forecast_Product__c,
                    dateOpened: createdDate,
                    subject: element.Subject,
                    status: element.Status,
                    //closedDate: closedDate,
                    closingNotes: closingNotes,
                    isEscalated: element.IsEscalated,
                    escalationNotes: element.Escalation_Notes__c,
                    escalationIcon: escalationIcon,
                    caseownerreview: element.Engineer_Review_Comments__c,
                    ownerName: element.Owner.Name,
                    ownerManagerName: ownerManagerName,
                    caselastactivity: element.Case_Last_Activity__c,
                    nextaction: element.Next_Action__c,
                    supportAccountName: supportAccountName          //<T05>
                };

                if(element.Engagement__c==this.recordId){
                    cases.push(cse);
                }//<T05>
                else if(element.Status != 'Closed')
                {
                    allCases.push(cse);
                    if(element.Support_Account__c == this.supportAccountId){
                            otherCases.push(cse);
                    }
                }
                //</T05>
            });
            this.cases = cases;
            this.otherCases = otherCases;
            this.filteredOtherCases = this.otherCases;

            //<T05>
            this.allCases = allCases;
            this.filteredAllCases = allCases;
            //</T05>

            console.log('cases - ' + JSON.stringify(this.cases));
            console.log('otherCases - ' + JSON.stringify(this.otherCases));
            //if(this.cases.length==0){
            //    this.showNoCaseMessage = true;
            //}
            this.showInProgress = false;
        })
        .catch(error => {
            this.showInProgress = false;
            console.log('error occurred while getting the list of cases - ' + JSON.stringify(error));
        });
    }

    connectedCallback(){
        //T01
        getTableColumns()
        .then(result => {
            if(result && result.length > 0){
                this.selectedColumns = result;
            }
            this.setupCaseColumns(this.selectedColumns);
        });

        loadStyle(this, GCS_RESOURCE + '/overrideLWC.css');
    }

    configureColumns(event){
        this.showColumnConfig = true;
    }
    
    saveColumnConfig(event){
        var selectedColumns = this.template.querySelector('[data-id="selectedColumns"]').value;
        console.log('selected columns >> ', selectedColumns);

        this.setupCaseColumns(selectedColumns);
        this.showColumnConfig = false;
    }

    cancelColumnConfig(event){
        this.showColumnConfig = false;
    }

    setupCaseColumns(selectedColumns){
        var caseColumns = [];

        selectedColumns.forEach(element => {
            console.log('column ', element);
            CASE_COLUMNS.forEach(caseColumn => {
                if(caseColumn.columnName == element){
                    caseColumns.push(caseColumn);
                }
            })
        });
        
        this.selectedColumns = selectedColumns;
        this.caseColumns = MANDATORY_COLUMNS_BEGIN.concat(caseColumns.concat(MANDATORY_COLUMNS_END));

        //T01
        saveTableColumns({
            lstColumnName : this.selectedColumns
        });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        console.log('action: ' + JSON.stringify(action));
        console.log('row: ' + JSON.stringify(row));

        switch (action.name) {
            case 'collaborate':
                console.log('collaborate action: ');
                this.rowActionCaseId = row.id;
                this.showCollab=true;
                break;

            default:
                break;
        }
    }

    handleAddComment(event){

    }        
    
    handleClose(event){
        this.showCollab = false;
    }
    
    handleCancel(event){
        var proceed = confirm('All the changes will be reset, click OK to proceed!');

        if(proceed){
            this.draftValues = [];
        }
    }

    handleSave(event){
        console.log("draft values >> " , JSON.parse(JSON.stringify(event.detail.draftValues)));
        this.showInProgress = true;

        updateCases({
            data : event.detail.draftValues
        })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Successfully updated the case(s)!',
                    variant: 'success',
                })
            );

            this.cases.forEach(element => {
                event.detail.draftValues.forEach(draftValue => {
                    if(element.id == draftValue.id){
                        if(draftValue.escalationNotes){
                            element.escalationNotes = draftValue.escalationNotes;
                        }
                        if(draftValue.closingNotes){
                            element.closingNotes = draftValue.closingNotes;
                        }
                    }
                })
            });
            this.draftValues = [];
            this.showInProgress = false;
        })
        .catch(error => {
            console.log("error>>", JSON.stringify(error));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message, //T02 //'Error occurred trying to update the Escalation Notes on the cases!',
                    variant: 'error',
                })
            );
            this.showInProgress = false;
        })
    }

    assignCases(event){
        var cases = this.template.querySelector('[data-id="otherCaseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));
        this.escalatecase = true; //T04
        if(cases.length==0){
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a case to assign!',
                    variant: 'error',
                })
            );
        }else{
            this.showConfirmationModal = true;
        }
    }

    //<T05>
    assignAllCasesSelected(event){
        var cases = this.template.querySelector('[data-id="allCaseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));
        this.escalatecase = true;
        if(cases.length==0){
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a case to assign!',
                    variant: 'error',
                })
            );
        }else{
            this.showConfirmationModal = true;
        }
    }
    //</T05>

    removecases(event){
        var cases = this.template.querySelector('[data-id="caseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));
        this.escalatecase = false;
        if(cases.length==0){
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a case to remove!',
                    variant: 'error',
                })
            );
        }else{
            this.showConfirmationModal = true;
        }
    }

    //I2RT-4422
    onOtherCaseSearch(event) {
        var cases = [];
        this.otherCases.forEach(row => {
            var allRowValue = '';
            this.caseColumns.forEach( columnInfo => {
                //console.log('columnInfo = '+columnInfo);

                if(columnInfo.type != 'url'){
                    allRowValue += row[columnInfo.fieldName] + '---';
                }
            })
            allRowValue += row['caseNumber'] + '---';
            allRowValue = allRowValue.toLowerCase();
            console.log('allRowValue = '+allRowValue);
            if(allRowValue.indexOf(event.target.value.toLowerCase()) >= 0){
                cases.push(row);
            }
        });
        this.filteredOtherCases = cases;
    }  

    //<T05>
    onAllCaseSearch(event) {
        var cases = [];
        this.allCases.forEach(row => {
            var allRowValue = '';
            this.caseColumns.forEach( columnInfo => {
                //console.log('columnInfo = '+columnInfo);

                if(columnInfo.type != 'url'){
                    allRowValue += row[columnInfo.fieldName] + '---';
                }
            })
            allRowValue += row['caseNumber'] + '---';
            allRowValue = allRowValue.toLowerCase();
            console.log('onAllCaseSearch -- allRowValue = '+allRowValue);
            if(allRowValue.indexOf(event.target.value.toLowerCase()) >= 0){
                cases.push(row);
            }
        });
        this.filteredAllCases = cases;
    }
     //</T05>

    /**Object change */
    cancelAssignCases(){
        this.showConfirmationModal = false;
    }

    continueAssignCases(){
      if(this.escalatecase){
        this.showConfirmationModal = false;
        this.showInProgress=true;

        //<T05>
        var cases = null;
        
        if(this.currentTabValue === "Other Cases")
        {
            cases = this.template.querySelector('[data-id="otherCaseList"]').getSelectedRows();
        }
        else if(this.currentTabValue === "All Customer Cases")
        {
            cases = this.template.querySelector('[data-id="allCaseList"]').getSelectedRows();
        }
        //</T05>

        console.log("selected cases - " + JSON.stringify(cases));

        var caseIds = [];
        cases.forEach(element => {
            caseIds.push(element.id);
        });    
        console.log("caseIds - " + JSON.stringify(caseIds));
        
        associateCasesToEngagement({
            engagementId: this.recordId,
            caseIds: JSON.stringify(caseIds),
            reason: 'Escalated from Engagement'
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected cases associated to the Engagement successfully!',
                    variant: 'success',
                }),
            );
            //refreshApex(this.engagement);
            this.showInProgress=false;
            this.fetchCases();
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error associating the Cases to the Engagement!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.showInProgress=false;
        });
    } else{
        console.log('Removing engagement on case');
        this.showConfirmationModal = false;
        this.showInProgress=true;

        var cases = this.template.querySelector('[data-id="caseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));

        var caseIds = [];
        cases.forEach(element => {
            caseIds.push(element.id);
        });    
        console.log("caseIds - " + JSON.stringify(caseIds));
        
        removecasesfromEngagement({            
            caselist: JSON.stringify(caseIds),            
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected cases has been disassociated to the Engagement successfully!',
                    variant: 'success',
                }),
            );
            //refreshApex(this.engagement);
            this.showInProgress=false;
            this.fetchCases();
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error associating the Cases to the Engagement!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.showInProgress=false;
        });

    }
    }

    updateCaseNotes(event){
        var cases = this.template.querySelector('[data-id="caseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));

        if(cases.length==0){
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select atleast one case',
                    variant: 'error',
                })
            );
        }else{
            this.showUpdateNotes=true;
        }
    }

    cancelModal(event){
        this.showUpdateNotes=false;
    }
    
    saveModal(event) {
        this.showSpinner = true;

        var cases = this.template.querySelector('[data-id="caseList"]').getSelectedRows();
        console.log("selected cases - " + JSON.stringify(cases));

        var caseIds = [];
        cases.forEach(element => {
            caseIds.push(element.id);
        });    
        console.log("caseIds - " + JSON.stringify(caseIds));

        var escalationNotes = this.template.querySelector('[data-id="escalationNotes"]').value;
        console.log("escalationNotes - " + escalationNotes);

        if(!escalationNotes || escalationNotes==''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter the notes',
                    variant: 'error',
                })
            );
        }else{
            updateEscalationNotes({
                caseIds : JSON.stringify(caseIds),
                notes : escalationNotes
            })
            .then(result => {
                var casesAll = this.cases;
                console.log("casesAll - " + JSON.stringify(casesAll));

                console.log("escalationNotes 2 - " + escalationNotes);

                casesAll.forEach(element => {
                    console.log('element.id >>', element.id);
                    caseIds.forEach(caseId => {
                        console.log('caseId >>', caseId);
                        if(element.id == caseId){
                            console.log('match found');
                            console.log("escalationNotes 3 - " + element.escalationNotes);
                            element.escalationNotes = escalationNotes;
                        }
                    })
                });
                this.cases = [];
                this.cases = casesAll;
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully updated the Escalation Notes on the selected cases!',
                        variant: 'success',
                    })
                );

                this.showSpinner = false;
                this.showUpdateNotes=false;
            })
            .catch(error => {
                console.log("error>>", JSON.stringify(error));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error occurred trying to update the Escalation Notes on the selected cases!',
                        variant: 'error',
                    })
                );
                this.showSpinner = false;
                this.showUpdateNotes=false;
            })
        }   
    }

    handleActiveTab(event){
        this.currentTabValue = event.target.value;
        this.sortBy = undefined;
        this.sortDirection = undefined;
    }
    doSorting(event){
        console.log('called doSorting');
        console.log( 'label'+ JSON.stringify(event.detail));

        var fname= event.detail.fieldName;
        console.log('doSorting-->fname'+fname);
        this.sortBy = fname;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
        this.sortBy = event.detail.fieldName;
    }

    sortData(fieldname, direction) {
        let parseData; 
        if(this.currentTabValue === "Escalated Cases"){
            parseData = JSON.parse(JSON.stringify(this.cases));
        }
        else if(this.currentTabValue === "Other Cases"){
            parseData = JSON.parse(JSON.stringify(this.filteredOtherCases));
        }
        //<T05>
        else if(this.currentTabValue === "All Customer Cases"){
            parseData = JSON.parse(JSON.stringify(this.filteredAllCases));
        }
        //</T05>
        // Return the value stored in the field
        let keyValue = (a) => {
        return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
        });
        if(this.currentTabValue === "Escalated Cases"){
            this.cases = parseData;
        }
        else if(this.currentTabValue === "Other Cases"){
            this.filteredOtherCases = parseData;
        }//<T05>
        else if(this.currentTabValue === "All Customer Cases"){
            this.filteredAllCases = parseData;
        }
        //</T05>
    }
}