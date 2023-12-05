import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIssuesAndRisk from '@salesforce/apex/StatusReportGeneratePDF.getIssuesAndRisk';
import attachIssuesAndRisks from '@salesforce/apex/StatusReportGeneratePDF.attachIssuesAndRisks';
import removeIssuesAndRisks from '@salesforce/apex/StatusReportGeneratePDF.removeIssuesAndRisks';
import getTimecards from '@salesforce/apex/StatusReportGeneratePDF.getTimecards';
import attachTimecards from '@salesforce/apex/StatusReportGeneratePDF.attachTimecards';
import removeTimecards from '@salesforce/apex/StatusReportGeneratePDF.removeTimecards';
import {getRecordNotifyChange } from 'lightning/uiRecordApi';

const issueColumns = [
{label: 'Issue Name', fieldName: 'issueURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'pse__Issue_Name__c' }, target: '_self'}}, 
{ label: 'Issue Description', fieldName: 'pse__Issue_Description__c' },
{ label: 'Date Raised', fieldName: 'pse__Date_Raised__c',type: 'date', sortable: true },
{ label: 'Status', fieldName: 'PSA_Status__c', sortable: true },
{ label: 'Priority', fieldName: 'PSA_Priority__c'},
{ label: 'Action Plan', fieldName: 'pse__Action_Plan__c' }];

const riskColumns = [
{label: 'Risk Name', fieldName: 'riskURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'pse__Risk_Name__c' }, target: '_self'}}, 
{ label: 'Risk Description', fieldName: 'pse__Risk_Description__c' },
{ label: 'Date Raised', fieldName: 'pse__Date_Raised__c',type: 'date', sortable: true },
{ label: 'Status', fieldName: 'PSA_Status__c', sortable: true },
{ label: 'Impact', fieldName: 'PSA_Impact__c'},
{ label: 'Mitigation Plan', fieldName: 'pse__Mitigation_Plan__c'}];

const timeCardColumns = [
    {label: 'Resource', fieldName: 'resource'},
    { label: 'Role', fieldName: 'role' },
    { label: 'Billable', fieldName: 'isBillable'},
    { label: 'Start Date', fieldName: 'startDate',type: 'date'},
    { label: 'End Date', fieldName: 'endDate',type: 'date'},
    { label: 'Total Hours', fieldName: 'totalHours'}];

export default class DatatableWithRowActions extends LightningElement {

// common related property
@api recordId;
@api componentType = 'Issues and Risks';
visibility;
currentTab ='Unattached Issues';
showAttach;
disableAttach=true;
disableRemove=true;
errorMessage;
successMessage;

// Issue related property
issueData = [];
issueColumns = issueColumns;
attachedIssueData = [];
selectedIssues = [];
attachedIssueIds;
selectAllIssues=[];
removeIssues=[];
hasIssues = false;
hasAttachedIssues = false;

// Risk related property
riskData = [];
riskColumns = riskColumns;
attachedRiskData = [];
selectedRisks = [];
attachedRiskIds;
selectAllRisks=[];
removeRisks=[];
hasRisks = false;
hasAttachedRisks = false;

//Timecard related property
unAttachedTimecardData = [];
attachedTimecardData = [];
timeCardColumns = timeCardColumns;
selectedTimeCards = [];
removeTimecardData =[];
hasAttachedTimecard = false;
hasTimecard =false;



// Sorting related property
defaultSortDirection='desc';
sortDirectionUnAttachIssue;
sortedByUnAttachIssue;
sortDirectionUnAttachRisk;
sortedByUnAttachRisk;
sortDirectionAttachIssue;
sortedByAttachIssue;
sortDirectionAttachRisk;
sortedByAttachRisk;
sortingData;
sortedBy;
sortDirection;


connectedCallback(){
if(this.componentType === 'Issues and Risks'){
    this.disableAttach=true;
    this.disableRemove=true;
    this.visibility=true;
    getIssuesAndRisk({                     
        srRecordId: this.recordId             
    })
    .then(result => {
        console.log('Result obtained is',result)
        this.riskData = result.lstOfUnattachedRisks;
        console.log('Risk data obtained',this.riskData)
        this.issueData = result.lstOfUnattchedIssues;
        console.log('Issue data obtained',this.issueData)
        this.attachedRiskData = result.lstOfAttachedRisks;
        console.log('Issue data obtained',this.attachedRiskData)
        this.attachedIssueData = result.lstOfAttachedIssues;
        console.log('Issue data obtained',this.attachedIssueData)
        
        if(this.riskData.length>0){
            this.hasRisks = true;
            // To open the reords in a new console tab
            this.riskData.forEach(function(item){
                item['riskURL'] = '/lightning/r/pse__Risk__c/' + item['Id'] + '/view';
            });
        }else{
            this.hasRisks = false;
        }
        if(this.issueData.length>0){
            this.hasIssues = true;
            // To open the reords in a new console tab
            this.issueData.forEach(function(item){
                item['issueURL'] = '/lightning/r/pse__Issue__c/' + item['Id'] + '/view';
              });
        }else{
            this.hasIssues = false;
        }
        if(this.attachedRiskData.length>0){
            this.hasAttachedRisks = true;
            // To open the reords in a new console tab
            this.attachedRiskData.forEach(function(item){
                item['riskURL'] = '/lightning/r/pse__Risk__c/' + item['Id'] + '/view';
              });
        }else{
            this.hasAttachedRisks = false;
        }
        if(this.attachedIssueData.length>0){
        this.hasAttachedIssues = true;
            // To open the reords in a new console tab
            this.attachedIssueData.forEach(function(item){
                item['issueURL'] = '/lightning/r/pse__Issue__c/' + item['Id'] + '/view';
              });
        }else{
            this.hasAttachedIssues = false;
        }

    })
    .catch(error => {
        this.error = error;
        console.log('connectedcallback error:'+this.error);
    });
    }else{
        this.visibility=false;
        getTimecards({                     
            srRecordId: this.recordId             
        })
        .then(result => {
            this.unAttachedTimecardData = result.unAttachedTimecards;
            this.attachedTimecardData = result.attachedTimecards;
            if(this.attachedTimecardData.length>0){
                this.hasAttachedTimecard = true;
            }
            if(this.unAttachedTimecardData.length>0){
                this.hasTimecard = true;
            }
            console.log('This Time card value',JSON.stringify(this.timeCardData));
            console.log('Obtained Result value is',JSON.stringify(result));
    
        })
        .catch(error => {
            this.error = error;
            console.log('connectedcallback error:'+this.error);
        });
    }

}
attach(){
    this.disableAttach=true;
    if(this.componentType === 'Issues and Risks'){
console.log('Inside Attach');
console.log('selected issues',this.selectAllIssues);
console.log('selected risk',this.selectAllRisks);
this.attachIssuesAndRisks();
    }else{
this.attachTimecards();
    }
}

attachIssuesAndRisks(){
    
    attachIssuesAndRisks({                     
        srRecordId: this.recordId,
        selectedRisks : this.selectedRisks,
        selectedIssues : this.selectedIssues          
        })
        .then(result => {
            if(result){
                console.log('Attached successfully');
                this.successMessage='Issues/Risks attached successfully to the Status Report.'
                this.showSuccessToast();
                //this.disableAttach=true;
                window.location.assign(window.location.href);
            }else{
                this.errorMessage='Error attaching the Issues/Risks to the Status Report.'
                this.showErrorToast();
                this.disableAttach=false;
            }
        })
        .catch(error => {
        this.error = error;
        this.disableAttach=false;
        console.log('connectedcallback error:'+this.error);
        this.errorMessage='Error attaching the Issues/Risks to the Status Report.'
                this.showErrorToast();
        });

}

attachTimecards(){
    attachTimecards({                     
        srRecordId: this.recordId,
        selectedTimecards : this.selectedTimecards,      
        })
        .then(result => {
            if(result){
                console.log('Attached successfully');
                this.successMessage='Timecards attached successfully to the Status Report.'
                this.showSuccessToast();
                //this.disableAttach=true;
                window.location.assign(window.location.href);
            }else{
                this.errorMessage='Error attaching the timecards to the Status Report.'
                this.showErrorToast();
                this.disableAttach=false;
            }
        })
        .catch(error => {
        this.error = error;
        this.disableAttach=false;
        console.log('connectedcallback error:'+this.error);
        this.errorMessage='Error attaching the Issues/Risks to the Status Report.'
                this.showErrorToast();
        });
}

remove(){
    this.disableRemove=true;
    if(this.componentType === 'Issues and Risks'){
    console.log('Inside remove');
    console.log('selected issues',this.selectAllIssues);
    console.log('selected risk',this.selectAllRisks);
    this.removeIssuesAndRisks();
    }else{
        this.removeTimecards();
    }
   
    }
    removeTimecards(){
        removeTimecards({                     
            srRecordId: this.recordId,
            selectedTimecards : this.removeTimecardData  
            })
            .then(result => {
                if(result){
        this.successMessage='Timecards removed successfully from the Status Report.'
                this.showSuccessToast();
                console.log('Removed successfully');
                    window.location.assign(window.location.href);
                    //this.disableRemove=false;
                }else{
                    console.log('Removal failed');
                    this.disableRemove=false;
                    this.errorMessage='Timecards not removed successfully from the Status Report.'
                this.showErrorToast();
                    
                }
            })
            .catch(error => {
            this.error = error;
            this.disableRemove=false;
            console.log('connectedcallback error:'+this.error);
            this.errorMessage='Timecards not removed successfully from the Status Report.'
            this.showErrorToast();
            });
    }
    removeIssuesAndRisks(){
        removeIssuesAndRisks({                     
            srRecordId: this.recordId,
            selectedRisks : this.removeRisks,
            selectedIssues : this.removeIssues          
            })
            .then(result => {
                if(result){
        this.successMessage='Issues/Risks removed successfully from the Status Report.'
                this.showSuccessToast();
                
                    console.log('Removed successfully');
                    window.location.assign(window.location.href);
                    //this.disableRemove=false;
                }else{
                    console.log('Removal failed');
                    this.disableRemove=false;
                    this.errorMessage='Issues/Risks not removed successfully from the Status Report.'
                this.showErrorToast();
                    
                }
            })
            .catch(error => {
            this.error = error;
            this.disableRemove=false;
            console.log('connectedcallback error:'+this.error);
            this.errorMessage='Issues/Risks not removed successfully from the Status Report.'
            this.showErrorToast();
            });
    }

getSelectedName(event) {
    const selectedRows = event.detail.selectedRows;
    if(this.componentType === 'Issues and Risks'){
    if(this.currentTab ==='Unattached Issues'){
        this.selectedIssues = selectedRows;
        console.log('Selected Issues',this.selectedIssues);
    }else if(this.currentTab ==='Unattached Risks'){
        this.selectedRisks = selectedRows;
        console.log('Selected Risk',this.selectedRisks);
    }else if(this.currentTab ==='Issues Attached'){
      this.removeIssues = selectedRows;
    }else if(this.currentTab ==='Risks Attached'){
        this.removeRisks = selectedRows;
    }
    console.log('inside issues/selected',this.selectedIssues.length)
    console.log('inside issues/selected',this.selectedRisks.length)
    if(this.selectedIssues.length>0 || this.selectedRisks.length>0){
        console.log('inside issues/selected')
this.disableAttach=false;
    }else{
        console.log('inside issues/selected')
this.disableAttach=true;
    }
    console.log('inside issues/selected',this.disableAttach)
    if(this.removeIssues || this.removeRisks){
        console.log('inside issues/selected')
this.disableRemove=false;
    }else{
        console.log('inside issues/selected')
       this.disableRemove=true; 
    }
    console.log('inside issues/selected',this.disableRemove)
}else{
    if(this.currentTab ==='Unattached Timecards'){
        this.selectedTimecards = selectedRows;
        if(this.selectedTimecards.length>0){
            this.disableAttach=false;
        }else{
            this.disableAttach=true;
        }
        console.log('Selected timecards',this.selectedTimecards);
    }else if(this.currentTab ==='Attached Timecards'){
        this.removeTimecardData = selectedRows;
        if(this.removeTimecardData.length>0){
            this.disableRemove=false;
        }else{
            this.disableRemove=true;
        }
        console.log('Timecards to remove',this.removeTimecardData);
    }
} 
}
handleActiveTab(event){
    this.currentTab = event.target.label;
    if(this.componentType === 'Issues and Risks'){
    console.log('current tab selected',this.currentTab);
    if(this.currentTab ==='Unattached Issues'){
this.showAttach=true;
    this.sortingData = this.issueData;
    }else if(this.currentTab ==='Unattached Risks'){
        this.showAttach=true;
        this.sortingData = this.riskData;
    }else if(this.currentTab ==='Issues Attached'){
        this.showAttach=false;
        this.sortingData = this.attachedIssueData;
    }else if(this.currentTab ==='Risks Attached'){
        this.showAttach=false;
        this.sortingData = this.attachedRiskData;
    }
     } else{
        if(this.currentTab ==='Unattached Timecards'){
            this.showAttach=true;
        }else if(this.currentTab ==='Attached Timecards'){
            this.showAttach=false;
        }
     }
}
cancel(event){
    this.selectedIssues=[];
    this.selectAllIssues=[];
    this.selectedRisks=[];
this.selectAllRisk=[];
console.log('inside cancel');
}

onHandleSort( event ) {

    const { fieldName: sortedBy, sortDirection } = event.detail;
    console.log('sortedBy',sortedBy);
    console.log('sortDirection',sortDirection);
    const cloneData = [...this.sortingData];
    console.log('cloneData',cloneData);
    cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
    if(this.currentTab ==='Unattached Issues'){
        this.issueData = cloneData;
        this.sortDirectionUnAttachIssue = sortDirection;
    this.sortedByUnAttachIssue = sortedBy;
        console.log(' this.issueData', this.issueData)
    }else if(this.currentTab ==='Unattached Risks'){
        this.riskData = cloneData;
        this.sortDirectionUnAttachRisk = sortDirection;
    this.sortedByUnAttachRisk = sortedBy;
    }else if(this.currentTab ==='Issues Attached'){
        this.attachedIssueData = cloneData;
        this.sortDirectionAttachIssue = sortDirection;
    this.sortedByAttachIssue = sortedBy;
    }else if(this.currentTab ==='Risks Attached'){
        this.attachedRiskData = cloneData;
        this.sortDirectionAttachRisk = sortDirection;
    this.sortedByAttachRisk = sortedBy;
    }
    
    

}
sortBy( field, reverse, primer ) {

    const key = primer
        ? function( x ) {
              return primer(x[field]);
          }
        : function( x ) {
              return x[field];
          };

    return function( a, b ) {
        a = key(a);
        b = key(b);
        return reverse * ( ( a > b ) - ( b > a ) );
    };

}
showErrorToast() {
    const showError = new ShowToastEvent({
        title: 'Error!!',
        message: this.errorMessage,
        variant: 'error',
    });
    this.dispatchEvent(showError);
}
showSuccessToast() {
    const showError = new ShowToastEvent({
        title: 'Success!!',
        message: this.successMessage,
        variant: 'success',
    });
    this.dispatchEvent(showError);
}
}