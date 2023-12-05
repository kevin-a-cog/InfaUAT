import { LightningElement, wire, api } from 'lwc';
import getProjectData from '@salesforce/apex/psaStatusReportLWCController.getProjectData';
import insertSRDRecords from  '@salesforce/apex/psaStatusReportLWCController.insertSRDRecords';
import generatePDF from  '@salesforce/apex/psaStatusReportLWCController.generatePDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningAlert from 'lightning/alert';

 
const ISSUECOLUMNS = [       
    {label: 'Issue Name', fieldName: 'issueURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'pse__Issue_Name__c' }, target: '_self'}},
    {label: 'Date Raised', fieldName:'pse__Date_Raised__c', type:'Date', wrapText:true},
    {label: 'Status', fieldName:'PSA_Status__c', type:'String',wrapText:true},
    {label: 'Priority', fieldName:'PSA_Priority__c', type:'String',wrapText:true},
    {label: 'Action Plan', fieldName:'pse__Action_Plan__c', type:'String',wrapText:true}
];

const RISKSCOLUMNS = [   
    {label: 'Risk Name', fieldName: 'riskURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'pse__Risk_Name__c' }, target: '_self'}},
    {label: 'Date Raised', fieldName:'pse__Date_Raised__c', type:'Date', wrapText:true},
    { label: 'Status', fieldName: 'PSA_Status__c', sortable: true },
    { label: 'Impact', fieldName: 'PSA_Impact__c'},
    { label: 'Mitigation Plan', fieldName: 'pse__Mitigation_Plan__c'}

];

const ASSIGNMENTCOLUMNS =[
    {label: 'Resource', fieldName: 'asgmntURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'name' }, target: '_self'}},
    { label: 'Budgeted Hours', fieldName: 'pse__Planned_Hours__c', type:'string', wrapText:true },
    { label: 'Hours Logged', fieldName: 'pse__Billable_Hours_Submitted__c',type:'string', wrapText:true}
];

const PROJECTACTIVITYCOLUMNS  =[
    {label: 'Name', fieldName: 'prjActURL', type: 'url', 
                         typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'}},
    { label: 'Status', fieldName: 'psa_Status__c', type:'string', wrapText:true },
    { label: 'Critical Path', fieldName: 'psa_Critical_Path__c' ,type:'string', wrapText:true}
];

const MILESTONECOLUMNS=[
    {label: 'Accomplished Task', fieldName:'milestoneURL',type:'url',
                        typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
    {label: 'Notes', fieldName:'psa_pm_Project_Manager_Notes__c',type:'String',wrapText:true}
];

export default class Psa_Status_Report extends LightningElement {

    @api recordId;
    loaded = false;
    activeSectionName = '';

    
    hasRecords = false;

    //Issue Properties
    noIssueRecords = false;
    issueColumns = ISSUECOLUMNS;
    issueWrapperData= [];
    selectedIssues=[];
    noIssueRecordsMessage='No Issues found';

    //Risk Properties
    noRiskRecords = false;
    riskColumns  = RISKSCOLUMNS;
    riskWrapperData= [];
    selectedRisks=[];
    noRisKRecordMessage='No Risks found';
    
    //Timecard Properties
    noAsgmntRecords = false;
    asgmntColumns = ASSIGNMENTCOLUMNS;
    asgmntWrapperData=[];
    selectedAssignment=[];
    noAsgmntRecordMessage='No Assignment found';
    
    //Project Activity properties
    noPrjActRecords = false;
    projActColumns = PROJECTACTIVITYCOLUMNS;
    prjActWrapperData = [];
    selectedPrjAct=[];
    noPrjActRecordMessage = 'No Project Activities found';

    //Milestone Properties
    milestoneWrapperData = [];
    milestoneColumns = MILESTONECOLUMNS;
    selectMilestone=[];
    noMilestoneRecord = false;
    noMilestoneRecordMessage = 'No Milestones found';

    disableButton=true;
    handleToggleSection(event){
        const openSections = event.detail.openSections;
        console.log('Cureent Selected Section',openSections);
        
            this.activeSectionName = openSections[openSections.length-1];
    
      
    }

    @wire(getProjectData, {statusRecordId:'$recordId'})
    getId({error,data}){
        this.loaded =false;
        if(data){
            this.hasRecords = true;
            console.log('@@Data',data);


            // ***Issue Data***
                let issueRecords = JSON.parse(JSON.stringify(data['issuesList']));
                issueRecords = issueRecords.map(row => {
                    return{...row};
                })
                this.issueWrapperData = issueRecords;

                this.issueWrapperData.forEach(function(item){
                    item['issueURL'] = '/lightning/r/pse__Issue__c/' + item['Id'] + '/view';
                });

                if(this.issueWrapperData.length <= 0)
                    this.noIssueRecords = true;
                console.log('@@Issue Wrapper',this.issueWrapperData);


            // ***Risk Data***
                let riskRecords = JSON.parse(JSON.stringify(data['risksList']));
                riskRecords = riskRecords.map(row => {
                    return{...row};
                })
                this.riskWrapperData = riskRecords;

                console.log('@@Risk Wrapper',this.riskWrapperData);
                this.riskWrapperData.forEach(function(item){
                    item['riskURL'] = '/lightning/r/pse__Risk__c/' + item['Id'] + '/view';
                });
                if(this.riskWrapperData.length<=0)
                this.noRiskRecords = true;
             
            // ***Assignment Data***
                console.log('@@testing',JSON.stringify(data['assignmentList']));
                let tempRecords = JSON.parse(JSON.stringify(data['assignmentList']));
                
                tempRecords = tempRecords.map(row => {
                    return{...row,name:row.pse__Resource__r.Name};
                })
                this.asgmntWrapperData = tempRecords;
                this.asgmntWrapperData.forEach(function(item){
                    item['asgmntURL'] = '/lightning/r/pse__Assignment__c/' + item['Id'] + '/view';
                });
                if(this.asgmntWrapperData.length<=0)
                this.noAsgmntRecords = true;
                console.log('@@Assignment Wrapper',this.asgmntWrapperData);

                // ***Project Activity Data***
                console.log('@@testing',JSON.stringify(data['prjActList']));
                let prjActRecords = JSON.parse(JSON.stringify(data['prjActList']));
                console.log()
                prjActRecords = prjActRecords.map(row => {
                    return{...row};
                })
                this.prjActWrapperData = prjActRecords;
                this.prjActWrapperData.forEach(function(item){
                    item['prjActURL'] = '/lightning/r/Task/' + item['Id'] + '/view'; 

                });
                if(this.prjActWrapperData.length<=0)
                this.noPrjActRecords = true;
                console.log('@@Project Activity Wrapper',this.prjActWrapperData);

                // *** Milestone Data***
                let milestRec = JSON.parse(JSON.stringify(data['milestoneList']));
                
                milestRec = milestRec.map(row => {
                    return{...row};
                })
                this.milestoneWrapperData = milestRec;
                this.milestoneWrapperData.forEach(function(item){
                    item['milestoneURL'] = '/lightning/r/pse__Milestone__c/' + item['Id'] + '/view';
                });
                if(this.milestoneWrapperData.length<=0)
                this.noMilestoneRecord = true;
                console.log('@@Milestone Wrapper',this.milestoneWrapperData);

        }else{
            this.error = error;
        }
    }
    

    getSelectedIssues(event){
        this.disableButton = true;
        this.selectedIssues = event.detail.selectedRows.map(row => row.Id);
        if(this.selectedIssues.length > 0 || this.selectedRisks.length > 0 || this.selectedAssignment.length > 0 || this.selectMilestone.length>0)
        this.disableButton = false;
        console.log('Selected Issues',this.selectedIssues.length);
    }
    getSelectedRisks(event){
         this.disableButton = true;
         this.selectedRisks = event.detail.selectedRows.map(row => row.Id);
         if(this.selectedIssues.length > 0 || this.selectedRisks.length > 0 || this.selectedAssignment.length > 0 ||this.selectedPrjAct.length>0 || this.selectMilestone.length>0)
         this.disableButton = false;
        console.log('Selected Risks',this.selectedRisks.length);
    }
    getSelectedAssignments(event){
        this.disableButton = true;
         this.selectedAssignment = event.detail.selectedRows.map(row => row.Id);
         if(this.selectedIssues.length > 0 || this.selectedRisks.length > 0 || this.selectedAssignment.length>0 ||this.selectedPrjAct.length>0 || this.selectMilestone.length>0)
         this.disableButton = false;
        console.log('Selected Assignments',this.selectedAssignment.length);
    }
    
    getSelectedProjectActivites(event){
        this.disableButton = true;
        this.selectedPrjAct = event.detail.selectedRows.map(row=>row.Id);
        if(this.selectedIssues.length > 0 || this.selectedRisks.length > 0 || this.selectedAssignment.length>0 ||this.selectedPrjAct.length>0 || this.selectMilestone.length>0)
         this.disableButton = false;
         console.log('Selected Project Activities', this.selectedPrjAct.length);
    }

    getSelectedMilestones(event){
        this.disableButton = true;
        this.selectMilestone = event.detail.selectedRows.map(row=>row.Id);
        if(this.selectedIssues.length > 0 || this.selectedRisks.length > 0 || this.selectedAssignment.length>0 ||this.selectedPrjAct.length>0 || this.selectMilestone.length>0 )
         this.disableButton = false;
         console.log('Selected Milestones', this.selectMilestone.length);
    }

    async handleInsert(){
        await LightningAlert.open({
            message: 'PDF is generating',
            theme:'inverse',
            label:'Success',
        })
        this.loaded =true;
        let insertRec = await insertSRDRecords({statusReportId:this.recordId ,issueRecords: this.selectedIssues,riskRecords :this.selectedRisks, assignmentRecords: this.selectedAssignment, prjActRecords:this.selectedPrjAct, milestoneRecords:this.selectMilestone})
        if(!insertRec) {
            return;
        }
        console.log('insertSRDRecords is called');        
        
        let generatePDFmethod = await generatePDF({statusReportId: this.recordId})
            if(generatePDFmethod){
                this.success = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'PDF Generated Successfully',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else{
                this.error = error;
                // This way you are not to going to see [object Object]
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed',
                        message: 'Please give the error to the Salesforce administrator:'+error.body.message,
                        variant: 'error'
                    })
                );
                console.log('Error is', this.error); 
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        /*
        .catch((error) => {
            console.log('In handleSave error....');
            this.error = error;
            // This way you are not to going to see [object Object]
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: 'Please give the error to the Salesforce administrator:'+error.body.message,
                    variant: 'error'
                })
            );
            console.log('Error is', this.error); 
            this.dispatchEvent(new CloseActionScreenEvent());
        }); 
        */
        
    }

}