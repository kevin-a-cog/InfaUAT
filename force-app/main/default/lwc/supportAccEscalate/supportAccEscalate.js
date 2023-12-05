import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import getAccounts from '@salesforce/apex/SupportAccountController.getAccounts';
import getEngagements from '@salesforce/apex/SupportAccountController.getEngagements';
import getCases from '@salesforce/apex/SupportAccountController.getCasesOpen';
import getCasesEscalated from '@salesforce/apex/SupportAccountController.getCasesEscalated';
import getCasesNotEscalated from '@salesforce/apex/SupportAccountController.getCasesNotEscalated';
import createEngagement from '@salesforce/apex/SupportAccountController.createEngagement';
import associateCasesToEngagement from '@salesforce/apex/SupportAccountController.associateCasesToEngagement';

import FIELD_ACCOUNT_ID from '@salesforce/schema/Account.Id';
import FIELD_ACCOUNT_RECORDTYPE_ID from '@salesforce/schema/Account.RecordTypeId';
import FIELD_ACCOUNT_RECORDTYPE_NAME from '@salesforce/schema/Account.RecordType.DeveloperName';

import FIELD_CASE_ID from '@salesforce/schema/Case.Id';
import FIELD_CASE_SUPPORTACCOUNTID from '@salesforce/schema/Case.Support_Account__c';



import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Classes.
import isSuccessApp from '@salesforce/apex/SupportAccountController.isSuccessApp';

const ACCOUNT_FIELDS = [
    FIELD_ACCOUNT_ID,
    FIELD_ACCOUNT_RECORDTYPE_ID,
    FIELD_ACCOUNT_RECORDTYPE_NAME
];

const CASE_FIELDS = [
    FIELD_CASE_ID,
    FIELD_CASE_SUPPORTACCOUNTID
];

const engagementColumns = [
    //{ label: 'Name', fieldName: 'name' },
    //{ label: 'Number', fieldName: 'engagementNumber' },
    { label: 'Number', fieldName: 'engagementLink', type: 'url', typeAttributes: { label: { fieldName: 'engagementNumber' }, target: '_blank' },sortable: true },
    { label: 'Priority', fieldName: 'priority',sortable: true },
    { label: 'Status', fieldName: 'status',sortable: true },
    { label: 'Severity', fieldName: 'severity',sortable: true },
    { label: 'Owner', fieldName: 'ownerName',sortable: true },
    { label: 'Title', fieldName: 'title',sortable: true, wrapText: true },
    { label: 'Plan', fieldName: 'planLink', type: 'url', typeAttributes: { label: { fieldName: 'planNumber' }, target: '_blank' }, cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Id', fieldName: 'id', fixedWidth: 1}
];

const escalatedCaseColumns = [
    //{ label: 'Case Number', fieldName: 'caseNumber', cellAttributes: { class: { fieldName: 'cssClass' }, iconName: { fieldName: 'escalationIcon' }, iconPosition: 'left'} },
    { label: 'Case Number', fieldName: 'caseNumber', type: 'recordName', typeAttributes: {recId: { fieldName: 'id'}, recordNumber: { fieldName: 'caseNumber'}, isEscalated: {fieldName: 'isEscalated'}, showPreview: true},sortable: true},
    { label: 'Priority', fieldName: 'priority', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Status', fieldName: 'status', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Product', fieldName: 'product', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Owner', fieldName: 'ownerName', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Engagement', fieldName: 'engagementLink', type: 'url', typeAttributes: { label: { fieldName: 'engagementNumber' }, target: '_blank' }, cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Subject', fieldName: 'subject', cellAttributes: { class: { fieldName: 'cssClass' }}, wrapText: true,initialWidth: 360,sortable: true },
    { label: 'Plan', fieldName: 'planLink', type: 'url', typeAttributes: { label: { fieldName: 'planNumber' }, target: '_blank' }, cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Id', fieldName: 'id', fixedWidth: 1}
];

const caseColumns = [
    //{ label: 'Case Number', fieldName: 'caseNumber', cellAttributes: { class: { fieldName: 'cssClass' }, iconName: { fieldName: 'escalationIcon' }, iconPosition: 'left'} },
    { label: 'Case Number', fieldName: 'caseNumber', type: 'recordName', typeAttributes: {recId: { fieldName: 'id'}, recordNumber: { fieldName: 'caseNumber'}, isEscalated: {fieldName: 'isEscalated'}, showPreview: true},sortable: true},
    { label: 'Priority', fieldName: 'priority', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Status', fieldName: 'status', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Product', fieldName: 'product', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Owner', fieldName: 'ownerName', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Subject', fieldName: 'subject', cellAttributes: { class: { fieldName: 'cssClass' }}, wrapText: true,initialWidth: 360,sortable: true },
    //{ label: 'Version', fieldName: 'version', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    //{ label: 'Record Type', fieldName: 'recordType', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
    { label: 'Id', fieldName: 'id', fixedWidth: 1}
];

const CASES_WITH_ESCALATION = "Cases linked to Escalation";
const CASES_WITHOUT_ESCALATION = "Cases not linked to Escalation";
const CASES_WITH_ESCALATION_SUCCESS = "Cases/Plan linked to Escalation";
const tabsObj = [
    {
      tab: CASES_WITHOUT_ESCALATION,
      helpText: "",
      showCheckboxCol: true,
      dataId: "caseList"
    },
    {
        tab: CASES_WITH_ESCALATION,
        helpText: "",
        showCheckboxCol: false,
        dataId: "escalateList"
    }
];

function log(message){
    if(DEBUG !== undefined && DEBUG !== null && DEBUG === 'true'){
        console.log(message);
    }
}

export default class SupportAccEscalate extends NavigationMixin(LightningElement) {

	//Track variables.
	@track boolIsSuccessApp;
	@track boolSelectedLinkedCases;
	@track strDetailPlaceholder = "Summary:<br>Business Justification:<br>Expectation:<br>Priority (P1/P2/P3):";
	@track objParameters = {
		boolDisplayNoRecordsFound: false,
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		intMaximumRowSelection: 1,
		strTableId: "1",
		lstRecords: new Array(),
		lstColumns: [
			{ label: 'Name', fieldName: 'name',sortable: true },
			{ label: 'Account Number', fieldName: 'accountNumber' ,sortable: true},
			{ label: 'Status', fieldName: 'status',sortable: true },
			{ label: 'Owner', fieldName: 'ownerName',sortable: true },
			{ label: 'Id', fieldName: 'id', fixedWidth: 1,sortable: true}
		]
	}

	//Private variables.

    engagementColumns = engagementColumns;
    caseColumns = caseColumns;


    @api recordId;

    @track customerAccountId;
    @track supportAccountId;
    //Deva Added for Cosmos
    @api sobjectRecordId;
    accountId;
    caseId;
    pageTitle;
    reason;

    @track cases = [];
    @track casesAll = [];
    selectedCaseIds = [];

    @track engagements = [];
    selectedEngagementId;

    @track newEngagement = {};
    @track engTitle;
    @track priority;
    @track severity;
    @track source;
    @track details;
    @track Contact;
    @track category;

    @track createNewEngagement = false;
     
    @track showInProgress=false;
    
    @track currentStep=0;

    //tab properties
    @track tabs = tabsObj;
    @track defaultTabOnInitialization = CASES_WITHOUT_ESCALATION;
    @track currentTabValue;
    @track NoDataAfterRendering = false;
    @track showDataRenderLoader = false;

    //sort properties
    @track sortBy;
    @track sortDirection;

    @wire(getRecord, { recordId: '$accountId', fields: ACCOUNT_FIELDS })
    acc({ error, data }) {
        if (error) {
            log("error fetching account details - " + JSON.stringify(error));
        } else if (data) {
            log("data.fields - " + JSON.stringify(data.fields));

            var accRecordType = getFieldValue(data, FIELD_ACCOUNT_RECORDTYPE_NAME);
            log('Account Record Type - ', accRecordType)
            if('Support_Account'==accRecordType){
                this.supportAccountId = this.accountId;
                this.fetchCasesAndEngagements();

                this.currentStep = 2;
            }else if('Customer_Account'==accRecordType){
                this.customerAccountId = this.accountId;
                this.fetchSupportAccounts();

                this.currentStep = 1;
            }

            log("supportAccountId - " + this.supportAccountId);
            log("customerAccountId - " + this.customerAccountId);
        }
    }

    @wire(getRecord, { recordId: '$caseId', fields: CASE_FIELDS })
    cse({ error, data }) {
        if (error) {
            log("error fetching account details - " + JSON.stringify(error));
        } else if (data) {
            log("data.fields - " + JSON.stringify(data.fields));

            this.supportAccountId = getFieldValue(data, FIELD_CASE_SUPPORTACCOUNTID);

            this.fetchEngagements();
            
            this.selectedCaseIds = [this.caseId];
            this.currentStep = 3;
            this.createNewEngagement = true;

            log("accountId - " + this.accountId);
        }
    }

    connectedCallback() {
		let objParent = this;
        //console.log('DEBUG: '+DEBUG);
        
        console.log("recordId >> ", this.recordId);
        if(String(this.recordId).startsWith('500')){
            this.caseId = this.recordId;
            this.reason = '';
            this.pageTitle = 'Create Engagement';
        }else{
            this.accountId = this.recordId;
            this.reason = 'Escalated by CSM/Sales';
            this.pageTitle = 'Escalate Case';
        }

		//Now we check if we are in the Success App.
		isSuccessApp().then(boolResult => {
			objParent.boolIsSuccessApp = boolResult;

			//If we are in the Success app.
			if(boolResult) {
				objParent.tabs = [
					{
					  tab: CASES_WITHOUT_ESCALATION,
					  helpText: "",
					  showCheckboxCol: true,
					  dataId: "caseList"
					},
					{
						tab: CASES_WITH_ESCALATION_SUCCESS,
						helpText: "",
						showCheckboxCol: true,
						dataId: "escalateList"
					}
				];
			}
		});
    }

    get showStep1(){
        return (this.currentStep==1);
    }

    get showStep2(){
        return (this.currentStep==2);
    }
    
    get showStep3(){
        return (this.currentStep==3);
    }

    get showBackButton(){
        return ((this.currentStep==3 && !this.caseId) || (this.customerAccountId && this.currentStep==2));
    }

    get submitButtonLabel(){
        if(this.currentStep==3){
            return 'Submit';
        }else{
            return 'Next';
        }
    }

    get showToggleButton(){
        return (this.engagements.length > 0 && this.selectedCaseIds.length > 0 && this.currentStep == 3);
    }

    get toggleButtonName(){
        if(this.createNewEngagement){
            return 'Select an Engagement';
        }else{
            return 'Create new Engagement';
        }
    }

    get sectionTitle(){
        if(this.createNewEngagement){
            return 'New Engagement';
        }else{
            return 'Add to an existing Engagement';
        }
    }

    get showSelectEngSection(){
        return !this.createNewEngagement;
    }

    get showCreateEngSection(){
        return this.createNewEngagement;
    }

    get showSupportAccounts(){
        return this.objParameters.lstRecords.length > 0;
    }

    /*get showCases(){
        return this.casesAll.length > 0;
    }*/

    handleActiveTab(event){
        this.currentTabValue = event.target.value;
        this.fetchCasesAndEngagements();
    }

    updateSearch(event) {
        var cases = [];
        this.casesAll.forEach(row => {
            var allRowValue = '';
            this.caseColumns.forEach( columnInfo => {
                log('columnInfo = '+columnInfo);

                if(columnInfo.type != 'url'){
                    allRowValue += row[columnInfo.fieldName] + '---';
                }
            })
            allRowValue += row['engagementTitle'] + '---';
            allRowValue = allRowValue.toLowerCase();
            log('allRowValue = '+allRowValue);
            if(allRowValue.indexOf(event.target.value.toLowerCase()) >= 0){
                cases.push(row);
            }
        });
        this.cases = cases;
    }

    fetchSupportAccounts(){
        this.showInProgress = true;
        console.log('Test Account');
        getAccounts({ 
            customerAccountId: this.customerAccountId 
        })
        .then(result => {
            this.objParameters.lstRecords = this.parseAccounts(result);
            if(this.objParameters.lstRecords.length==1){
                this.supportAccountId = this.objParameters.lstRecords[0].id;
            }
            this.showInProgress = false;
        })
        .catch(error => {
            this.showInProgress = false;
            log('error occurred - ' + JSON.stringify(error));
        });
    }

    fetchCasesAndEngagements(){
        //this.showInProgress = true;
        this.showDataRenderLoader = true;
        let tabValue;
        if(this.currentTabValue != undefined && this.currentTabValue != null && this.currentTabValue != ''){
            tabValue = this.currentTabValue;
        }
        else{
            tabValue = this.defaultTabOnInitialization;
        }
        this.NoDataAfterRendering = false;
        if(tabValue === CASES_WITH_ESCALATION || tabValue === CASES_WITH_ESCALATION_SUCCESS) {
            this.caseColumns = escalatedCaseColumns;
			if(this.boolIsSuccessApp) {
				this.caseColumns = [
					{ label: 'Case Number', fieldName: 'caseNumber', type: 'recordName', typeAttributes: {recId: { fieldName: 'id'}, recordNumber: { fieldName: 'caseNumber'}, isEscalated: {fieldName: 'isEscalated'}, showPreview: true},sortable: true},
					{ label: 'Priority', fieldName: 'priority', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Status', fieldName: 'status', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Product', fieldName: 'product', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Owner', fieldName: 'ownerName', cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Engagement', fieldName: 'engagementLink', type: 'url', typeAttributes: { label: { fieldName: 'engagementNumber' }, target: '_blank' }, cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Plan', fieldName: 'planLink', type: 'url', typeAttributes: { label: { fieldName: 'planNumber' }, target: '_blank' }, cellAttributes: { class: { fieldName: 'cssClass' }},sortable: true },
					{ label: 'Subject', fieldName: 'subject', cellAttributes: { class: { fieldName: 'cssClass' }}, wrapText: true,initialWidth: 360,sortable: true },
					{ label: 'Id', fieldName: 'id', fixedWidth: 1}
				]
			}
            getCasesEscalated({ 
                supportAccountId: this.supportAccountId 
            })
            .then(result => {
                log('cases result - ' + JSON.stringify(result));
                
                this.casesAll = this.parseCases(result);
                this.cases = this.casesAll;
                log('cases - ' + JSON.stringify(this.cases));
                if(result.length <= 0){
                    this.NoDataAfterRendering = true;
                }
                this.showDataRenderLoader = false;
            })
            .catch(error => {
                //this.showInProgress = false;
                this.showDataRenderLoader = false;
                log('error occurred - ' + JSON.stringify(error));
            });
        }
        else if(tabValue === CASES_WITHOUT_ESCALATION){
            this.caseColumns = caseColumns;
            getCasesNotEscalated({ 
                supportAccountId: this.supportAccountId 
            })
            .then(result => {
                log('cases result - ' + JSON.stringify(result));
                
                this.casesAll = this.parseCases(result);
                this.cases = this.casesAll;
                log('cases - ' + JSON.stringify(this.cases));
                if(result.length <= 0){
                    this.NoDataAfterRendering = true;
                }
                this.showDataRenderLoader = false;
            })
            .catch(error => {
                //this.showInProgress = false;
                this.showDataRenderLoader = false;
                log('error occurred - ' + JSON.stringify(error));
            });
        }
        
        this.fetchEngagements();
    }

    fetchEngagements(){
        getEngagements({ 
            supportAccountId: this.supportAccountId 
        })
        .then(result => {
            log('engagements result - ' + JSON.stringify(result));

            this.engagements = this.parseEngagements(result);
            log('engagements - ' + JSON.stringify(this.engagements));

            if(this.engagements.length==0){
                this.createNewEngagement = true;
            }else{
                //this.createNewEngagement = false;
            }
            //this.showInProgress = false;
            //this.showDataRenderLoader = false;
        })
        .catch(error => {
            //this.showInProgress = false;
            //this.showDataRenderLoader = false;
            log('error occurred - ' + JSON.stringify(error));
        });
    }

    parseCases(data){
        var cases = [];

        data.forEach(element => {
            log('case element - ' + JSON.stringify(element));

            var cssClass = '';
            var engagementId;
            var engagementTitle;
            var engagementLink;
            var engagementNumber;
            var planLink;
            var planNumber;
            if(element.Engagement__c){
                cssClass = 'slds-theme_shade';
                engagementId = element.Engagement__c;
                if(element.Engagement__r.Title__c){
                    engagementTitle = element.Engagement__r.Title__c;
                }else{
                    engagementTitle = element.Engagement__r.Engagement_Number__c;
                }
				if(element.Engagement__r.Plan__c){
					 planLink = '/lightning/r/' + element.Engagement__r.Plan__c + '/view';
					planNumber = element.Engagement__r.Plan__r.Name;
				}
                engagementLink = '/lightning/r/' + engagementId + '/view';'';
                engagementNumber = element.Engagement__r.Engagement_Number__c;
            }
            
            var escalationIcon='';
            if(element.IsEscalated){
                escalationIcon = 'utility:up';
            }

            var cse = {
                id: element.Id,
                engagementId: engagementId,
                engagementTitle: engagementTitle,
                engagementNumber: engagementNumber,
                engagementLink: engagementLink,
                priority: element.Priority,
                product: element.Forecast_Product__c,
                version: element.Version__c,
                caseNumber: element.CaseNumber,
                subject: element.Subject,
                status: element.Status,
                recordType: element.RecordType.Name,
                ownerName: element.Owner.Name,
                cssClass : cssClass,
                escalationIcon : escalationIcon,
                isEscalated: element.IsEscalated,
				planLink: planLink,
				planNumber: planNumber
            };
            cases.push(cse);
        });

        return cases;
    }

    parseEngagements(data){
        var engagements = [];
        
        data.forEach(element => {
            log('engagement element - ' + JSON.stringify(element));

            var engagement = {
                id: element.Id,
                name: element.Name,
                engagementLink: '/lightning/r/' + element.Id + '/view',
                engagementNumber: element.Engagement_Number__c,
                title: element.Title__c,
                priority: element.Priority__c,
                status: element.Status__c,
                severity: element.Severity__c,
                recordType: element.RecordType.Name,
                ownerName: element.Owner.Name
            };
			if(objUtilities.isNotBlank(element.Plan__c)) {
				engagement.planLink = '/lightning/r/' + element.Plan__c + '/view';
				engagement.planNumber = element.Plan__r.Name;
			}
            engagements.push(engagement);
        });

        return engagements;
    }

    parseAccounts(data){
        var accounts = [];

        data.forEach(element => {
            var account = {
                id: element.Id,
                name: element.Name,
                accountNumber: element.New_Org_Account_Number__c,
                status: element.Support_Account_Status__c,
                ownerName: element.Owner.Name,
				objFullData: element
            };
            accounts.push(account);
        });

        return accounts;
    }

    doSorting(event){
        log('called doSorting');
        log( 'label'+ JSON.stringify(event.detail));

        var fname= event.detail.fieldName;
        if(fname.includes('engagementLink')){
            fname= fname.replace('engagementLink','engagementNumber')
        }
        log('doSorting-->fname'+fname);
        this.sortBy = fname;
        this.sortDirection = event.detail.sortDirection;
        if(this.currentStep === 2){
            this.cases = this.sortData(this.sortBy, this.sortDirection, this.cases);
        }
        else if(this.currentStep === 3){
            this.engagements = this.sortData(this.sortBy, this.sortDirection, this.engagements);
        }
        this.sortBy = event.detail.fieldName;
    }

    sortData(fieldname, direction, data) {
        //let parseData = JSON.parse(JSON.stringify(this.cases));
        let parseData = JSON.parse(JSON.stringify(data));
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
        //this.cases = parseData;
        return parseData;
    }

    toggleCreate(event){
        this.createNewEngagement = !(this.createNewEngagement);
    }

    /*newEngagement() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Engagement__c',
                actionName: 'new'                
            }
        });
    }*/
    
    handleFieldChange(event) {
        this.newEngagement[event.currentTarget.dataset.field] = event.target.value;
        log("newEngagement - " + JSON.stringify(this.newEngagement));
    }

    goBack(event){
        this.currentStep--;
    }

    submit(event){
		let objParent = this;
        //event.target.disabled = true;
        //log('event.target.disabled start--> '+event.target.disabled);
        if(this.currentStep == 1){
            var supportAccountSelected = this.template.querySelector('c-global-data-table').getSelectedRecords();
            log("supportAccountSelected - " + JSON.stringify(supportAccountSelected));

            if(supportAccountSelected.length>0){
                this.supportAccountId = supportAccountSelected[0].id;
                this.fetchCasesAndEngagements();
                this.currentStep=2;
                this.sortBy = undefined;
                this.sortDirection = undefined;
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select one Support Account!',
                        variant: 'error',
                    })
                );
            }
        }else if(this.currentStep == 2){
            log('supportAccountId='+this.supportAccountId);
            this.sortBy = undefined;
            this.sortDirection = undefined;
			this.boolSelectedLinkedCases = false;

            var caseIds=[];
            if(this.casesAll.length > 0){
                if(this.template.querySelector('[data-id="caseList"]') !== undefined && this.template.querySelector('[data-id="caseList"]') !== null){
                    var cases = this.template.querySelector('[data-id="caseList"]').getSelectedRows();
                    log("selected cases - " + JSON.stringify(cases));
            
                    cases.forEach(element => {
                        caseIds.push(element.id);
                    });
                }
            }

            log("caseIds - " + JSON.stringify(caseIds));
            var proceed = false;
            if(caseIds === undefined || caseIds === null || caseIds.length==0){
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select atleast one Case!',
                        variant: 'error',
                    })
                );*/
				if(this.boolIsSuccessApp) {
					if(this.template.querySelector('[data-id="escalateList"]') !== undefined && this.template.querySelector('[data-id="escalateList"]') !== null) {
						this.template.querySelector('[data-id="escalateList"]').getSelectedRows().forEach(element => {
							caseIds.push(element.id);
						});
					}
					if(caseIds === undefined || caseIds === null || caseIds.length==0) {
						this.createNewEngagement = true;
						proceed = confirm('No cases selected, click OK to proceed!');
					} else {
						this.createNewEngagement = false;
						this.boolSelectedLinkedCases = true;
						proceed = confirm('Do you still want to continue associating the Plan with the existing Engagement?');
					}
				} else {
					this.createNewEngagement = true;
                	var proceed = confirm('No cases selected, click OK to proceed!');
				}
            }else{

				//If the user selected more than 5 cases, we throw an error message.
				if(caseIds.length > 5) {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error',
							message: 'Please select 5 or less Cases for Escalation',
							variant: 'error',
						})
					);
				} else {
					if(this.engagements.length==0){
						this.createNewEngagement = true;
					}else{
						this.createNewEngagement = false;
					}
					proceed = true;
				}
            }

            if(proceed){
                this.selectedCaseIds = caseIds;
                this.currentStep = 3;
            }
        }else if(this.currentStep == 3){
            event.target.disabled = true;
            log("newEngagement - " + JSON.stringify(this.newEngagement));
        
            this.sortBy = undefined;
            this.sortDirection = undefined;

            if(this.createNewEngagement){
                if(!this.newEngagement.Title || this.newEngagement.Title=='' 
                    //|| !this.newEngagement.Priority || this.newEngagement.Priority==''
                    //|| !this.newEngagement.Severity || this.newEngagement.Severity=='' 
                    || !this.newEngagement.Source || this.newEngagement.Source==''
                    || !this.newEngagement.Details || this.newEngagement.Details==''){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter the required field values',
                            variant: 'error',
                        })                       
                    );
                    event.target.disabled = false;
                }else{
                    //this.showInProgress=true;
                    log('create engagement');
                    createEngagement({
                        supportAccountId: this.supportAccountId,
                        //engName: this.newEngagement.Name,
                        engTitle: this.newEngagement.Title,
                        //priority: this.newEngagement.Priority,
                        //severity: this.newEngagement.Severity,
                        source: this.newEngagement.Source,
                        category: 'Escalation',
                        detail: this.newEngagement.Details,
                        contact: this.newEngagement.Contact,
                        caseIds: JSON.stringify(this.selectedCaseIds),
                        reason: this.reason,
                        sobjectRecordId :this.sobjectRecordId
                    })
                    .then(result => {
                        log("result - " + JSON.stringify(result));
                    
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Engagement created successfully!',
                                variant: 'success',
                            })
                        );
                        this.showInProgress=false;
                        event.target.disabled = false;
                        if(result != ''){
                            this.handleNavigation(result);
                        }
                        this.closeQuickAction();
                    })
                    .catch(error => {
                        log("error - " + JSON.stringify(error));
                        var errorvalue = JSON.stringify(error);
                        var messagevalue;
                        if(errorvalue.includes('Primary_Escalation_Contact__c')){
                            messagevalue = 'Primary Escalation Contact should be associated to Account on Engagement';
                        } else{
                            messagevalue = 'Error creating the Engagement!';
                        }
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: messagevalue,
                                message: error.body.message,
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                        this.showInProgress=false;
                        event.target.disabled = false;
                        this.closeQuickAction();
                    });
                }
            }else{
                var proceed = true;

                var engagements = this.template.querySelector('[data-id="engagementList"]').getSelectedRows();
                log("selected engagement - " + JSON.stringify(engagements));
                if(engagements.length>0){
                    this.selectedEngagementId = engagements[0].id;
                    
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please select one Engagement!',
                            variant: 'error',
                        })
                    );
                    proceed=false;
                }

                if(proceed){
                    this.showInProgress=true;
                    associateCasesToEngagement({
                        engagementId: this.selectedEngagementId,
                        caseIds: JSON.stringify(this.selectedCaseIds),
                        reason: this.reason,
						strPlanId: this.sobjectRecordId,
						boolIsSuccessApp: this.boolIsSuccessApp
                    })
                    .then(result => {
                        log("result - " + JSON.stringify(result));
                    
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Cases associated to the Engagement successfully!',
                                variant: 'success',
                            }),
                        );
                        this.showInProgress=false;
                        event.target.disabled = false;
                        this.handleNavigation(this.selectedEngagementId);
                        this.closeQuickAction();
                    })
                    .catch(error => {
                        log("error - " + JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error associating the Cases to the Engagement!',
                                message: error.body.message,
                                variant: 'error',
                            }),
                        );
                        this.showInProgress=false;
                        event.target.disabled = false;
                        this.closeQuickAction();
                    });
                }else{
                    this.showInProgress=false;
                    event.target.disabled = false;
                }
            }
        }
        //event.target.disabled = false;
    }

    handleNavigation(recId){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: recId,
              objectApiName: "Engagement__c",
              actionName: "view"
            }
          });
    }

    cancel(){
        this.closeQuickAction();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		this.template.querySelector("c-global-data-table").searchRecord(objEvent);
	}
}