/* Name		    :	CsmRiskEditPage
* Author		:	Deva M
* Created Date	: 	6/17/2021
* Description	:	Risk Edit/Create page LWC.

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description						Tag
**********************************************************************************************************
Deva M              10-01-2022     	AR-1751        
Narpavi Prabu       12-07-2022      AR-2824	  Risk Reason not retained on click of Add Risk Products from Completness T01  
Karthi G            09-10-2023      AR-3444   Critical risk changes 
*/
//Core Imports
import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import largeModal from '@salesforce/resourceUrl/modalWidth';
import { loadStyle} from 'lightning/platformResourceLoader';

//Apex Imports

import getActiveRiskRecord from '@salesforce/apex/CSMRiskEditPageController.getActiveRiskRecord';
//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Loading from '@salesforce/label/c.Loading';
import Remove_Button from '@salesforce/label/c.Remove_Button';

//Fields
import PLAN_NAME from "@salesforce/schema/Plan__c.Name";
import PLAN_ID from "@salesforce/schema/Plan__c.Id";
const PLAN_FIELDS = [PLAN_NAME,PLAN_ID];
import RISK_PLAN_ID from "@salesforce/schema/Risk_Issue__c.Plan__c";
const RISK_FIELDS = [RISK_PLAN_ID];

export default class CsmRiskEditPage extends NavigationMixin(LightningElement)  {
    //Public variables
    @api recordId;
    @api riskRecordId;
    @api boolFromPAF;
    @api fromCreateRisk;
    //Private Variables
    activeSections=["A","B","C"];
    sobjectApiName;
    boolDisplaySpinner;
    boolRiskEditScreen;
    boolManageRiskProductScreen;
    boolSaveAndNextStep;
    boolOnlySaveRiskRecord;
    boolShowRiskEditScreen;
    uiRecordEdit;
    // strReasonMultiSelectPickListValue;
    boolRenderTable;
    boolDisplayActions;
    strMilestoneId;
    initialSelection=[];
    //Labels.
	label = {
        Success,
        Error,
        Loading
    }
    //Wire Plan record to load
	@wire(getRecord, { recordId: "$recordId", fields: PLAN_FIELDS })
	planRecord;

    @wire(getRecord, { recordId: "$recordId", fields: RISK_FIELDS })
	riskRecord;

    //Feature Configuration.
    @track objConfiguration = {
        sobjectApiName: "Risk_Issue__c",
        boolDisplayActions:false,
        //strReasonExistingValue:"",
        lstButtons:[
            {
                keyValue:"1",
                label:'Save & Close',
                variant:'brand',
                title:'Save & Close',
                styleClass:'slds-m-horizontal_x-small',
                name:'submit',
                showButton: true
            }, {
                keyValue:"2",
                label:'Save & Add Opportunity',
                variant:'brand',
                title:'Save & Add Opportunity',
                styleClass:'slds-m-horizontal_x-small',
                name:'save_next',
                showButton: true
            },
            {
                keyValue: "3",
                label: "Save & Next",
                variant: 'Brand',
                title: "Save & Next",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'save_next',
				showButton: false,
            },
            {
                keyValue: "4",
                label: "Cancel",
                variant: 'Neutral',
                title: "Cancel",
                styleClass: 'slds-m-horizontal_x-small slds-float_left',
                name: 'cancel',
				showButton: true,
            },
            {
                keyValue: "6",
                variant: "Brand",
                label: Remove_Button,
                title: Remove_Button,
                styleClass: "slds-m-horizontal_x-small",
                name: 'remove_risk_Opty',
                showButton: false
            },
            {
                keyValue: "7",
                variant: "Brand",
                label: 'Add',
                title: 'Add',
                styleClass: "slds-m-horizontal_x-small",
                name: 'add_risk_Opty',
                showButton: false
            }
        ]
    }

    get modalTitle(){
        let modalTitle=undefined;
        if(this.boolManageRiskProductScreen!==true){
            modalTitle= this.fromCreateRisk==true?"Create Risk":"Edit Risk"
        }else{
            modalTitle="Manage Risk Opportunities";
        }
        return modalTitle;
    }

    get planid(){
        return this.fromCreateRisk?this.recordId:this.riskRecord.Plan__c;
    }
    
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
     connectedCallback(){       

        Promise.all([loadStyle(this,largeModal)]);
        
        this.boolDisplaySpinner = false;
        this.boolManageRiskProductScreen = false;
        this.boolShowRiskEditScreen = false;
        this.boolRiskEditScreen=true;
        this.boolSaveAndNextStep=false;
        this.boolDisplayActions=false;
        let objParent = this; 
       	//First we get the current record id.
        if(objUtilities.isNull(objParent.riskRecordId)){
            let objWindow=window.location.href.match(/(Risk_Issue__c[A-Z//])\w+/g);
            if(objUtilities.isNotNull(objWindow)){
                objWindow.forEach((objElement => {
                    objParent.riskRecordId = objElement.split("/")[1];
                }));
            }
        }
        if(objUtilities.isNull(objParent.riskRecordId)){
            objParent.loadActiveRiskRecord();
        }
        if(objUtilities.isNotNull(objParent.riskRecordId)){
            
             
             //Hide Add products buttons
            objParent.objConfiguration.lstButtons.forEach(objButton => {
                if(objButton.keyValue !== '2' && objButton.keyValue !== '6' && objButton.keyValue !== '7'){
                     objButton.showButton=true;
                 }else {
                     objButton.showButton=false;
                 }
             });
            //objParent.loadRecord();
        }else{
            objParent.boolRenderTable=true;
            //objParent.objConfiguration.strReasonExistingValue="";
        }
       
     }
     

    /*
	 Method Name : loadActiveRiskRecord
	 Description : This method gets executed on load and get active risk record data from completeness .
	 Parameters	 : None
	 Return Type : None
	 */
     loadActiveRiskRecord(){
        let objParent = this; 
        objParent.boolDisplaySpinner = true;
        getActiveRiskRecord({    
            strPlanRecordId: objParent.recordId 
        })
        .then((objResponse) => {
            //<T01>
            if(objUtilities.isNotNull(objResponse) ){
                objParent.riskRecordId= objResponse.Id;
            }
         //</T01>
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
     }
    

    /*
	 Method Name : handleSuccess
	 Description : This method gets executed on scuccess of record edit form
	 Parameters	 : None
	 Return Type : None
	 */
     handleSuccess(objEvent){
        const payload = objEvent.detail;
        let objParent = this;
        if(objUtilities.isNotNull(payload.id)){
            objParent.riskRecordId= payload.id;
        }
        objParent.boolDisplaySpinner = false;
        objUtilities.showToast(objParent.label.Success,'Risk was saved.','success', objParent);
        //To show manage product screen
        if(objParent.boolSaveAndNextStep===true){
            objParent.boolManageRiskProductScreen=true;
            objParent.boolRiskEditScreen = false;
            objParent.objConfiguration.lstButtons.forEach(objButton => {
                if(objButton.keyValue === '4'){
                     objButton.showButton=true;
                 }else {
                     objButton.showButton=false;
                 }
             });
        }else if(objParent.boolOnlySaveRiskRecord===true){
            this.handleClose();
            this.boolShowRiskEditScreen = false;
        }
            
     }
    
    
   /*
	 Method Name : handleSubmit
	 Description : This method gets executed on submit  of record edit form
	 Parameters	 : None
	 Return Type : None
	 */
    handleSubmit(objEvent){
        let objParent = this;
        objParent.boolDisplaySpinner = true;
       // if(objUtilities.isNotNull(objParent.strReasonMultiSelectPickListValue)){
            objEvent.preventDefault();       // stop the form from submitting
            const fields = objEvent.detail.fields;
           // fields.Reason__c =  objParent.strReasonMultiSelectPickListValue;
            if(objUtilities.isNotNull(objParent.strMilestoneId)){
                fields.Milestone__c = objParent.strMilestoneId;
            }
            
            console.log(JSON.stringify(fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
       // }
    }

    handleSelectedRecords(objEvent){
		let selectedRecords=objEvent.detail.selectedRows;
        let tab = objEvent.detail.tab;
        let objParent = this;
		let lstRecords = new Array();
		//this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		selectedRecords.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});
        //Show Remove Button
        if(lstRecords.length>0){
            objParent.objConfiguration.lstButtons.forEach(objButton => {
                if(objButton.keyValue === '4' || (objButton.keyValue === '6' && tab==='1') || (objButton.keyValue === '7' && tab==='2')){
                     objButton.showButton=true;
                 }else {
                     objButton.showButton=false;
                 }
             });	
        }
		
		if(lstRecords.length==0){		
            objParent.objConfiguration.lstButtons.forEach(objButton => {
                if(objButton.keyValue === '4'){
                     objButton.showButton=true;
                 }else {
                     objButton.showButton=false;
                 }
             });
		}
	}
    
    
    /*
	 Method Name : handleClose
	 Description : This usable method calls on other functions to dispatch close event
	 Parameters	 : None
	 Return Type : None
	 */
    handleClose(){   
        this.dispatchEvent(new CustomEvent('close'));  
        this.dispatchEvent(new CloseActionScreenEvent());  
        //this.objConfiguration.strReasonExistingValue="";
        this.riskRecordId=null;
        this.initialSelection = [];
    }

    /*
	 Method Name : handleError
	 Description : This method gets executed on error of record edit form.
	 Parameters	 : objEvent
	 Return Type : None
	 */
     handleError(objEvent){
        let objParent = this;
        objParent.boolDisplaySpinner = false;
        let payLoad = objUtilities.isNotNull(objEvent.detail.detail)?objEvent.detail.detail:objEvent.detail ;
        objUtilities.showToast(objParent.label.Error,payLoad,'error', objParent);
    }

   
    /*
    Method Name : handleClick
    Description : This method executes on click event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    handleClick(objEvent) {
        switch (objEvent.target.dataset.name) {  
            case 'submit':
               this.processSaveRecords(true);
            break;
            case 'save_next':
                this.boolSaveAndNextStep=true;
                this.processSaveRecords(true);
            break; 
            case 'cancel':
                this.handleClose();
            break;
            case 'remove_risk_Opty':
                this.processRecords('remove');
                break;
            case 'add_risk_Opty':
                this.processRecords('add');
                break;
            default:
            break;
        }
    }
     /*
    Method Name : removeRecords
    Description : This method will delete selected records
    Parameters	: None
    Return Type : None
    */
    processRecords(straction){
        let objParent = this;       
        objParent.boolDisplaySpinner = true;
        let objManageProductComp = objParent.template.querySelector('c-csm-manage-risk-opportunity-container');
        if(objUtilities.isNotNull(objManageProductComp)){
            objManageProductComp.processAction(straction);
            
        }
        
        objParent.objConfiguration.lstButtons.forEach(objButton => {
            if(objButton.keyValue === '4'){
                 objButton.showButton=true;
             }else {
                 objButton.showButton=false;
             }
         });
         objParent.boolDisplaySpinner = false;
    }
    
    /*
    Method Name : processSaveRecords
    Description : This method calls on click of save buttons
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    processSaveRecords(boolOnlySaveRiskRecord){
        let objParent = this;
        if (objParent.validate()) {
            if(objUtilities.isNotNull(boolOnlySaveRiskRecord) && boolOnlySaveRiskRecord===true){
                objParent.boolOnlySaveRiskRecord=true;
                objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
            }else{
                objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
            }            
        }
    }
    /*
    Method Name : validate
    Description : This method validate input forms
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    validate() {
        let isValid = true;
        let objParent = this;
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            isValid = ip.reportValidity();
        });
      //  if(objUtilities.isBlank(objParent.strReasonMultiSelectPickListValue)){
      //      objUtilities.showToast(objParent.label.Error,"Please select the reason to save Risk",'error',objParent);
      //      isValid = false;
      //  }
        return isValid;
    }
     /*
	 Method Name : handleCellSelect
	 Description : This method gets executed on cell selection Event .
	 Parameters	 : None
	 Return Type : None
	 

     handleCellSelect(objEvent){
        let objParent = this;
        const { objPayload } = objEvent.detail;
        objParent.strReasonMultiSelectPickListValue = objPayload;
    } */

    handleHide(){
		this.objConfiguration.lstButtons.forEach(objButton => {
            if(objButton.keyValue === '4'){
                 objButton.showButton=true;
             }else {
                 objButton.showButton=false;
             }
         });
	}
}