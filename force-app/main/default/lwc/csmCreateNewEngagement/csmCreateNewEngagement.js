/*
 * Name			:	CSMCreateNewEngagement
 * Author		:	
 * Created Date	: 	
 * Description	:	create new Engagement records

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 Chaitanya T			08/17/2023		AR-3365			new MFA engagement			T01
 Chaitanya T			08/17/2023		AR-3416 		milestone mandatory 
 														for MFA engagement			T02
 Chaitanya T			09/27/2023		AR-3452 		CSA Enhancements			T03
 Chaitanya T			10/25/2023		AR-3467 		Remove the CSA from the 
 														New Engagement Recordtype 	T04
 Chaitanya T			11/07/2023		AR-3537 		Map Engagement Requested
 														for values using metadata	T05
 **********************************************************************************************************
 
 */
import { LightningElement,api,wire, track } from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { objUtilities } from 'c/globalUtilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import LightningAlert from 'lightning/alert';
import {getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import ENG_OBJECT from '@salesforce/schema/Engagement__c';
//import ENGModel_FIELD from '@salesforce/schema/Engagement__c.Engagement_Model__c';

import lookupSearch from "@salesforce/apex/CSMPlanEngagementController.lookupSearch";
import getRecordTypes from "@salesforce/apex/CSMPlanEngagementController.getRecordTypes";
import getRecordsInserted from "@salesforce/apex/CSMPlanEngagementController.getRecordsInserted";
import getDefaultRecords from "@salesforce/apex/CSMPlanEngagementController.getDefaultRecords";
import checkRenewalOppty from "@salesforce/apex/CSMPlanEngagementController.checkRenewalOppty";
import logComment from "@salesforce/apex/CSMPlanEngagementController.logComment";
import NoProjectMsg from '@salesforce/label/c.CSM_NoBillableProjectMsg';
import DescriptionPlaceholder from '@salesforce/label/c.DescriptionPlaceholder';
import CSM_NoBillableProjectComment from '@salesforce/label/c.CSM_NoBillableProjectComment';
import CSMProjectExistingComment from '@salesforce/label/c.CSMProjectExistingComment';
import CSMProjectExistingMsg from '@salesforce/label/c.CSMProjectExistingMsg';
import getPlanContacts from "@salesforce/apex/CSMPlanEngagementController.getPlanContacts";
import getPlanMilestones from "@salesforce/apex/CSMPlanEngagementController.getPlanMilestones";
import getEngagementRequestedFor from "@salesforce/apex/CSMPlanEngagementController.getEngagementRequestedFor";

import EC_Coveo_NoofRecords from '@salesforce/label/c.EC_Coveo_NoofRecords';
import EC_Coveo_RequestButton from '@salesforce/label/c.EC_Coveo_RequestButton';
import EC_Coveo_Path from '@salesforce/label/c.EC_Coveo_Path';
import EC_Coveo_Products from '@salesforce/label/c.EC_Coveo_Products';
import EC_Coveo_Stage from '@salesforce/label/c.EC_Coveo_Stage';
import EC_Coveo_FocusArea from '@salesforce/label/c.EC_Coveo_FocusArea';
import EC_Coveo_EngagementType from '@salesforce/label/c.EC_Coveo_EngagementType';
import EC_Coveo_EngagementCategory from '@salesforce/label/c.EC_Coveo_EngagementCategory';
import EC_Coveo_Placeholder from '@salesforce/label/c.EC_Coveo_Placeholder';
import EC_Coveo_UseTags from '@salesforce/label/c.EC_Coveo_UseTags';
import SA_ApprovalSub_CSM from '@salesforce/label/c.SA_ApprovalSub_CSM';
import CSMRepeatableTitleMsg from '@salesforce/label/c.CSMRepeatableTitleMsg';


//Fields
const FIELDS = ['Plan__c.Account__c','Plan__c.COE_Group__c'];

export default class CSMCreateNewEngagement extends NavigationMixin(LightningElement) {
    @api recordId;
	@api milestoneRecordId;
	@api engagementModel;
	@api isRepeatable=false;
	@api selectedEC;
    headerName ='New Engagement';
    @api showRecordTypeSelection = false;
    options = [];
	selectedMilestone;
	selectedContact;

	recordTypeOptions =[];
	selectedRecordType;
	selectedTypeName;
	recordTypeMap;
    recordTypeArray =[];

	isIPSJumpstart = false;
	@api isCST = false;
	isGEMSEscation = false;

	accountId;
	planDetails;

	showSpinner = false;
    openEngagementModal = false;

    selectedOpptyId;
    selectedRenewalOppty;
    selectedPlanContactId;

	isRenewalOpptyAvailable = false;
	isPC2IICS=false;
	selectedProjectId;
	defaultProj=[];
	engagementId;
	description;
	@api showCoveoCmp=false;//<T04> added api decorator to open this directly from csmManagePlanEngagement component
	timeZone='';
	recType='';
	//CSAengId;
	engRequestFor = '';//<T05>

	coveoLabel = {EC_Coveo_NoofRecords, EC_Coveo_RequestButton, EC_Coveo_Path, EC_Coveo_Products, EC_Coveo_Stage, EC_Coveo_FocusArea, EC_Coveo_EngagementType, EC_Coveo_EngagementCategory, EC_Coveo_Placeholder, EC_Coveo_UseTags};

	get displayProject(){
		return this.selectedOpptyId!==null && this.selectedOpptyId!==undefined && this.isPC2IICS;
	}

	get descPlaceholder(){
		return this.isPC2IICS?DescriptionPlaceholder:'';
	}

	//<T02> start
	get mileStoneRequired(){
		if(this.recType == 'MFA'){
			return true;
		}else{
			return false;
		}
	}//</T02> end

	//<T03> start
	get repeatableMsgTitle(){
		return CSMRepeatableTitleMsg;
	}//</T03> end

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
			console.log(JSON.stringify(data));
			this.planDetails = data;
			this.accountId = data.fields.Account__c.value;
			this.isPC2IICS = data.fields.COE_Group__c.value==='PC2IICS';
		}
	}

	@wire(getObjectInfo, { objectApiName: ENG_OBJECT })
    objectInfo;
	

    connectedCallback(){
        	this.getEngagementRecordTypes();
    }

	planContacts;
	planMilestones;
	@wire(getPlanContacts,{planId: '$recordId'})
	planContacts;

	@wire(getPlanMilestones,{planId: '$recordId'})
	planMilestones;

	get contactOptions(){
		let opList=[{label:'--None--',value:''}];
        if(this.planContacts.data){
          //  const fields = this.objectInfo.data.fields;
		  this.planContacts.data.forEach(element => {
                opList.push({value:element.Contact__c,label:element.Contact__r.Name});
            });
        }
        return opList;
	}

	get milestoneOptions(){
		let opList=[{label:'--None--',value:''}];
        if(this.planMilestones.data){
            //const fields = this.objectInfo.data.fields;
            this.planMilestones.data.forEach(element => {
                opList.push({label:element.Name,value:element.Id});
            });
        }
        return opList;
	}

	get journey(){
		let journeyList=this.selectedEC?.infajourneyvalue;
		let val = (journeyList && journeyList.length>0)?journeyList[0]:'';
		return val;
	}


	get ecName(){
		return this.selectedEC?.title;
	}

	get csaRequestedFor(){
		let type = this.selectedEC?.engagementinternaltype;
		if(type && type.length>1){
			let index = type.indexOf('Best Practice');
			type= index>0? type.splice(index, 1):type;
			index = type.indexOf('Best Practices');
			type = index>0? type.splice(index, 1):type[0];
		}
		if(type !=null && type !=undefined && type !=''){//<T05> start
			getEngagementRequestedFor({engRequestedFor:type?.toString()})
			.then(result =>{
				this.engRequestFor = result;
			})
			.catch(error=>{
				console.log('error reading csaRequestedFor ',JSON.stringify(error));
			})
	}
		return this.engRequestFor;//</T05> end
	}


    getEngagementRecordTypes(){
		//get Engagement RecordTypes
		getRecordTypes()
		.then(result =>{
			this.recordTypeMap = result;
			for(var key in result){
				if(result[key].DeveloperName==='CST'){//<T01> start
					const cloneResult = JSON.parse(JSON.stringify(result));
					cloneResult[key].Name = 'MFA';
					this.recordTypeArray.push(cloneResult[key]);//<T01> end
				}else{//<T04> start
					this.recordTypeOptions.push({label:result[key].Name,value:key});
					this.showRecordTypeSelection = !this.isRepeatable;
					this.recordTypeArray.push(result[key]);
				}//</T04> end
				if(this.isRepeatable && result[key].DeveloperName==='CST'){
					this.selectedRecordType = key;
					this.headerName = 'New CSA Engagement';	
					this.recType = 'CSA';//<T01> -- isRepeatable will be true only when it is invoked from PAF component Success Accelerator
				}
			}
			this.sortRecordTypes();
		})
		.catch(error=>{
			console.log(JSON.stringify(error));
		})
	}

	sortRecordTypes(){
		this.recordTypeArray.sort((a,b) => (a.Name > b.Name) ? 1 : ((b.Name > a.Name) ? -1 : 0));
	}

    /*
	 Method Name : handleCancel
	 Description : This method is to Close the Modal popup
	 Parameters	 : None
	 Return Type : None
	 */
	handleCancel(event){
		//this.openEngagementModal = false;
		this.showRecordTypeSelection = false;
        const closeEvent = new CustomEvent('closemodal', { detail: this.openEngagementModal });
        this.dispatchEvent(closeEvent);
	}

	/*
	 Method Name : handleRecordTypeChange
	 Description : This method is to get the RecordType Value
	 Parameters	 : None
	 Return Type : None
	 */
	handleRecordTypeChange(event){
		this.selectedRecordType = event.currentTarget.value;
		this.selectedTypeName = event.currentTarget.name;
        this.template.querySelectorAll("input").forEach(input=>{
            if(input.type ==="radio"){  
                if(input.name === this.selectedTypeName){
                    input.checked = true;
                }else{
                    input.checked = false;
                }
            }
        })

		switch(this.selectedTypeName){
			case 'IPS':
				this.isIPSJumpstart = true;
				this.isCST = false;
				this.isGEMSEscation = false;
			break;

			case 'CSA':
				this.isCST = true;
				this.recType = 'CSA';//<T01>
				this.isIPSJumpstart = false;
				this.isGEMSEscation = false;
				this.engagementModel = 'Customized';
			break;

			case 'Support Escalation':
				this.isGEMSEscation = true;
				this.isIPSJumpstart = false;
				this.isCST = false;
			break;

			case 'MFA':
				this.isCST = true;
				this.recType = 'MFA';//<T01>
				this.isRepeatable = true;
				this.isIPSJumpstart = false;
				this.isGEMSEscation = false;
				this.engagementModel = 'Customized';
			break;

		}
		
	}

	handleNext(event){
        let objParent = this;
        if(this.selectedRecordType === undefined || this.selectedRecordType === null){
            objUtilities.showToast('Error','Please select any one RecordType','error',objParent);
            this.showSpinner=false;
        }else{
            this.showRecordTypeSelection = false;	
            this.headerName = 'New '+ this.selectedTypeName +' Engagement';	
        }		
	}
	
	/**Record Edit Form Methods */
	handleSubmit(event){

		event.preventDefault(); 
		//<T02> start
		let comboboxValidity = true;
		this.template.querySelectorAll('[data-validate]').forEach(element => {
			element.reportValidity();
			if (element.validity.valid === false) {
			comboboxValidity = false;
			}
		});
		if(comboboxValidity == false){
			return;
		}//</T02> end

		//let objEngagement = {};
		let objParent = this;
		
		const fields = event.detail.fields;
		fields.RecordTypeId = this.selectedRecordType;
        fields.Key_Customer_Contact__c = this.selectedPlanContactId;
        fields.Opportunity__c = this.selectedOpptyId;
        fields.Renewal_Opportunity__c = this.selectedRenewalOppty;
		fields.Milestone__c = this.milestoneRecordId;
		fields.IPS_Project__c = this.selectedProjectId;
		fields.Description__c = this.description;
		if(this.recordTypeMap[this.selectedRecordType].DeveloperName === 'CST' && this.recType ==='CSA'){
			fields.Engagement_Model__c = this.engagementModel;
			fields.Primary_Contact__c = this.selectedContact;
			fields.Milestone__c = this.selectedMilestone;
			fields.Requested_By_Group__c = 'CSM';
			fields.Approval_Subject_Dev__c = SA_ApprovalSub_CSM;
			//fields.Customer_Time_Zone__c = this.planContacts.data.find(opt => opt.Contact__c === this.selectedContact)?.Contact__r?.TimeZone_Lookup__r?.Timezone__c;
			if(this.selectedEC){
				fields.Engagement_ID__c = this.selectedEC.infajourneyid;
				fields.AEM_EC_Id__c = this.selectedEC.engagementid;
				fields.Title__c = this.selectedEC.title;			
				fields.Is_Internal_Engagement__c = this.selectedEC.isinternalengagement;
				fields.Engagement_Category__c = this.selectedEC.engagementinternalcategory?.toString();//array
				fields.Adoption_Stage__c = this.selectedEC.engagementinternalstage?.toString(); //array
				fields.Engagement_Products__c = this.selectedEC.engagementinternalproducts?.toString(); //array
				fields.Focus_Area__c = this.selectedEC.engagementinternalfocusarea?.toString(); //array
				fields.Use_case_and_Tags__c = this.selectedEC.engagementinternalusecasetags?.toString(); //array
				fields.Content_Type__c = this.selectedEC.infacontenttype?.toString(); //array
				fields.Engagement_Units__c = this.selectedEC.engagementunit; 
				fields.Catalog_URL__c = this.selectedEC.uri; 
			}
		}else if(this.recordTypeMap[this.selectedRecordType].DeveloperName === 'CST' && this.recType ==='MFA'){//<T01> start
			fields.Primary_Contact__c = this.selectedContact;
			fields.Milestone__c = this.selectedMilestone;
			fields.Requested_By_Group__c = 'CSM';
			fields.Engagement_Model__c = this.engagementModel;
		}//<T01> end
		
        console.log('objEngagement >> '+ JSON.stringify(fields));

		//Check if the Opportunity has Renewal Oppty created
		if(objUtilities.isNotNull(this.selectedOpptyId)){				
			/*objParent.isRenewalOpptyAvailable = false;
			checkRenewalOppty({opptyId:this.selectedOpptyId})
			.then(result =>{
				objParent.isRenewalOpptyAvailable = result;
			})
			.catch(objError=>{
				objUtilities.processException(objError, objParent);
				objParent.showSpinner = false;
			})
			.finally(() => {
				//Finally, we hide the spinner.
				objParent.showSpinner = false;
			});*/
		}
		
		//AR-2189 - Make opportunity mandatatory when csr requested for is Rescue
		if(objUtilities.isNull(this.selectedOpptyId) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'CST' && this.recType ==='CSA' && fields.CST_Requested_for__c ==='Rescue'){
			objUtilities.showToast('Error','Select an Opportunity with Renewal Opportunity if the Engagement requested for is Rescue','error',objParent);
            this.showSpinner=false;
		}else if(objUtilities.isNull(this.selectedOpptyId) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'CST' && this.recType ==='MFA' && (fields.CST_Requested_for__c ==='Modernization - Churn Swing assistance' || fields.CST_Requested_for__c ==='Modernization - IPU Expansion' || fields.CST_Requested_for__c ==='Modernization - IPU Consumption')){//<T01> start
			objUtilities.showToast('Error','Select an Opportunity if the Engagement requested for is '+fields.CST_Requested_for__c,'error',objParent);
			objParent.showSpinner=false;//<T01> end
		}else if( objUtilities.isBlank(this.selectedPlanContactId) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'IPS_Jumpstart'){
            objUtilities.showToast('Error','Please select the Key Customer Contact','error',objParent);
            this.showSpinner=false;
        }else if(objUtilities.isBlank(this.selectedOpptyId) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'IPS_Jumpstart'){
            objUtilities.showToast('Error','Please select the Opportunity','error',objParent);
            this.showSpinner=false;
        }
		else if(objUtilities.isBlank(this.selectedProjectId) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'IPS_Jumpstart' && this.isPC2IICS){
            objUtilities.showToast('Error','Please select the Project','error',objParent);
            this.showSpinner=false;
        }
		else if(objUtilities.isBlank(this.description) && this.recordTypeMap[this.selectedRecordType].DeveloperName === 'IPS_Jumpstart' ){
            objUtilities.showToast('Error','Please enter the Description','error',objParent);
            this.showSpinner=false;
        }
				
		else{
			this.showSpinner = true;
		getRecordsInserted({engagement : Object.assign({ 'SobjectType' : 'Engagement__c' }, fields)})
		.then(result=>{
			if(result){
				this.engagementId = result;
			}
			console.log(this.engagementId);
			var engagementId = this.engagementId;
			this.showRecordTypeSelection = false;
			
			//Now we display the success message.
			objUtilities.showToast('Success!', 'Engagement is created successfully !', 'success', objParent);
			
			//Navigate to new record
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: engagementId,
					actionName: 'view'
				}
			});

			/**Close the Modal */			
            const closeEvent = new CustomEvent('closemodal', { detail:{close:this.openEngagementModal , success:true}});
            this.dispatchEvent(closeEvent);

			const closecoveo = new CustomEvent('closecoveo');
			this.dispatchEvent(closecoveo);
		})
		.catch(objError=>{
			objUtilities.processException(objError, objParent);
			objParent.showSpinner = false;
		})
		.finally(() => {
			//Finally, we hide the spinner.
			objParent.showSpinner = false;
		});

		//------------------//
    }
	}
	
	handleError(event){
		this.showSpinner = false;
		console.log('error'+JSON.stringify(event.detail));
	}	

	handleLookupSearch(event){
		const lookupElement = event.target;
		let objParent = this;
        var dataId = event.target.getAttribute('data-id');
        console.log('dataId >> '+ dataId);
        console.log('dataId >> '+ JSON.stringify(event.detail));
		let recid=this.recordId;
		if(this.isPC2IICS && dataId==='pse__Proj__c'){
			recid=this.selectedOpptyId;
		}
		
        lookupSearch({searchTerm :event.detail.searchTerm , selectedIds : event.detail.selectedIds , objectName : dataId, planId : recid})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                objUtilities.processException(objError, objParent);
            });
		
	}

	handleLookupSelectionChange(event){
		let objParent = this;
        var dataId = event.target.getAttribute('data-id');
        console.log('dataId >> '+ dataId);
        console.log('detail >> '+ JSON.stringify(event.detail));
		
        switch(dataId){
			case 'Opportunity':
				this.selectedProjectId = null;
				this.defaultProj = [];
                this.selectedOpptyId = event.detail.values().next().value;				 
				objParent.isRenewalOpptyAvailable = false;
				checkRenewalOppty({opptyId:this.selectedOpptyId})
				.then(result =>{
					objParent.isRenewalOpptyAvailable = result;
				})
				.catch(objError=>{
					objUtilities.processException(objError, objParent);
					objParent.showSpinner = false;
				})
				.finally(() => {
					//Finally, we hide the spinner.
					objParent.showSpinner = false;
				});			 
            break;

            case 'Contact':
                this.selectedPlanContactId = event.detail.values().next().value;
            break;
            case 'Renewal_Opportunity__c':
                this.selectedRenewalOppty = event.detail.values().next().value;
            break;
            case 'pse__Proj__c':
                this.selectedProjectId = event.detail.values().next().value;
            break;
        }
	}

	//load default plan contacts on focus

	handleLoadDefault(objEvent){
		var dataId = objEvent.target.getAttribute('data-id');
		let objParent = this;
		const lookupElement = objEvent.target;
		let recid=this.recordId;	
		if(this.isPC2IICS && dataId==='pse__Proj__c'){			
			recid=this.selectedOpptyId;
		}
		getDefaultRecords({ strRecordId:  recid, objectName : dataId })
		.then((results) => {   				
			//this.selectedProjectId=null;
			if(results.length===0 && this.isPC2IICS && dataId==='pse__Proj__c'){
										/**Close the Modal */			
				const closeEvent = new CustomEvent('closemodal', { detail: this.openEngagementModal });
				this.dispatchEvent(closeEvent);
				LightningAlert.open({
					message: NoProjectMsg,
					theme : 'error',
					label: 'Error'
				}).then((result) => {
					logComment({strPlanId: this.recordId , message: CSM_NoBillableProjectComment});
				});
			}
			else if(results.length===1 && this.isPC2IICS && dataId==='pse__Proj__c' && results[0].title==='EngagementExist'){
				const closeEvent = new CustomEvent('closemodal', { detail: this.openEngagementModal });
				this.dispatchEvent(closeEvent);
				LightningAlert.open({
					message: CSMProjectExistingMsg,
					theme : 'error',
					label: 'Error'
				}).then((result) => {
					logComment({strPlanId: this.recordId , message: CSMProjectExistingComment +' '+results[0].subtitle});
				});
			}
			else if(results.length===1 && this.isPC2IICS && dataId==='pse__Proj__c'){
				this.selectedProjectId=results[0].id;
				this.defaultProj = results;
			}
			lookupElement.setSearchResults(results);           
		})
		.catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			//objParent.showSpinner = false;
		});
	}

	handleChange( event ) {
        this.description = event.detail.value;
    }

	handleECFocus(){
		
		this.isCST=false;
		this.showCoveoCmp = true;
	}

	handleCoveoClose(){
		const closeEvent = new CustomEvent('closemodal', { detail: true });
		this.dispatchEvent(closeEvent);
	}

	handleMilestoneChange(event){
		this.selectedMilestone = event.detail.value;
	}

	handleContactChange(event){
		this.selectedContact = event.detail.value;		
		let pcon = this.planContacts.data.find(opt => opt.Contact__c === this.selectedContact);
		if(pcon!==undefined && pcon!==null && pcon.Contact__c!==undefined && pcon.Contact__c!==null && pcon.Contact__r.TimeZone_Lookup__c!==null && pcon.Contact__r.TimeZone_Lookup__c!==undefined){
			this.timeZone = pcon.Contact__r.TimeZone_Lookup__r.Timezone__c;
		}
	}

	
}