/*
 * Name			:	FillRequiredFields
 * Author		:	VENKATESH BALLA
 * Created Date	: 	10/23/2023
 * Description	:	This LWC allows fill field values and save.
 * 
 Change History
 **********************************************************************************************************
 Modified By			    Date			    Jira No.		      Description					Tag
 **********************************************************************************************************
 VENKATESH BALLA		10/23/2023		SALESRT-17407				Initial version.			N/A
 */
 import { LightningElement, api, wire } from 'lwc';
 import {getObjectInfo} from 'lightning/uiObjectInfoApi';
 import { getRecord, getFieldValue } from "lightning/uiRecordApi";
 import { refreshApex } from "@salesforce/apex";
 import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
 import {getPicklistValues} from 'lightning/uiObjectInfoApi';
 import SUBSTAGE_FIELD from '@salesforce/schema/Opportunity.Substage__c';
 import WINLOSSREASON_FIELD from '@salesforce/schema/Opportunity.Stage_Reason__c';
 import { ShowToastEvent } from "lightning/platformShowToastEvent";
 //Apex Controllers.
 import saveData from "@salesforce/apex/FillRequiredFieldsController.saveData";
 
 export default class FillRequiredFields extends LightningElement {
     @api fieldAPI;
     @api objectApiName;
     @api recordId;
     @api subStageName;
     //currently it supports both NNB and Channel record type with same record type id value passed from custom metadata record.
     //in future if winloss reason picklist fields values are not same, then must define two custom metadata records.
     @api recordTypeId;
     @api fieldType;
     showMultiSelectSection = false;
     showSpinner = false;
     selectedValues = [];
     existingWinLossReasons ='';
     @wire(getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT })
     opportunityInfo;
     requiredSelectionMsg = '';
     winlossReasons;
     subStageOptions;
     winlossReasonsData;
     disableSave = true;
 
     @wire(getRecord, { recordId: "$recordId", fields: ["Opportunity.Stage_Reason__c"] })
     wireOppdata(result) {
       this.existingWinLossReasons = result;
       if (result.data) {
         var recordvalue = getFieldValue(result.data, WINLOSSREASON_FIELD);
         this.selectedValues = recordvalue.split(';');
       } else if (result.error) {
       }
     }
 
     get revenue() {
       return getFieldValue(this.opportunity.data, opportunity);
     }
   
     @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: WINLOSSREASON_FIELD })
     winLossReasonFieldInfo({ data, error }) {
         if (data) {
           this.winlossReasonsData = data;
           this.handleSubStageChange(this.subStageName);
         }
     }
 
     @wire(getPicklistValues, {recordTypeId:'$recordTypeId', fieldApiName: SUBSTAGE_FIELD })
     upsellFieldInfo({ data, error }) {
         if (data) this.subStageOptions = data.values;
     }
     
     connectedCallback(){
       if(this.fieldType == 'multiSelect'){
         this.showMultiSelectSection = true;
       }
     }

     handleChangeIP(event){
      const inputVal = event.detail.value;
      if(inputVal == undefined || inputVal.length == 0 || inputVal.trim().length == 0){
        this.disableSave = true;
      }
      else{
        this.disableSave = false;
      }
     }
 
     hanldeSubmission(){
       this.showSpinner = true;
     }
 
     handleSucess(){
       this.showToastMsg("success", "Success", "Saved successfully.");
       this.showSpinner = false;
       this.handleClose();
     }
 
     handleError(event){
       this.showToastMsg("error", "Error", event.detail.detail);
       this.showSpinner = false;
       this.handleClose();
     }
 
     handleClose(){
       if(this.showSpinner == false){
         this.dispatchEvent(new CustomEvent('close'));
       }
       else{
         this.showToastMsg("warning", "Please wait for the current process to complete...");
       }
     }
  
     handleSubStageChange(nextSubStage) {
         let key = this.winlossReasonsData.controllerValues[nextSubStage];
         this.winlossReasons = this.winlossReasonsData.values.filter(opt => opt.validFor.includes(key));
     }
 
     handleChange(e) {
       this.selectedValues = e.detail.value;
       if(this.selectedValues == null || this.selectedValues == undefined || this.selectedValues.length == 0){
        this.disableSave = true;
        }
        else{
          this.disableSave = false;
        }
    }
 
     handleDataSave(){
       this.hanldeSubmission();
       if(this.selectedValues == null || this.selectedValues == undefined || this.selectedValues.length == 0){
         this.requiredSelectionMsg = 'An option must be selected';
         this.showSpinner = false;
       }
       else{
         this.requiredSelectionMsg = '';
         const selectedStr = this.selectedValues.join();
         const strWithSemiColons = selectedStr.replaceAll(',',';');
         saveData({sobjectName : this.objectApiName, fieldAPI : this.fieldAPI, recordId: this.recordId, valueToSave :  strWithSemiColons})
           .then(result => {
             refreshApex(this.existingWinLossReasons);//refresh stagereason field values upon data save
             this.handleSucess();
           })
           .catch(error => {
             this.showToastMsg("error", "Error", error.body.message);
           })
       }
     }
 
     showToastMsg(variantStr, titleStr, messageStr){
       this.dispatchEvent(
         new ShowToastEvent({
           title: titleStr,
           message: messageStr,
           variant: variantStr
         })
       );
     }
 
 }