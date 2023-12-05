/* Name			    :	CsmManageAdoptionFactorFramework
* Author		    :	Deva M
* Created Date	: 20/09/2021
* Description	  :	CsmManageAdoptionFactorFramework controller.

Change History
**********************************************************************************************************
Modified By			Date			    Jira No.	      	Description				                      	Tag
**********************************************************************************************************
Deva M		      20/09/2021		AR-1575				   Initial version.		                    	  N/A
Karthi G        20/09/2022    AR-2919          Updated PAF status and Due date logic     <T01>
Karthi G        09/01/2023    AR-3070          Show warning for PAF duplicates created
                                               after page load by different user.        <T02>
Karthi G        31/03/2023    AR-3141          Add logic for churn forecast              <T03>
*/

//Core imports
import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue, createRecord, updateRecord} from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import LightningAlert from 'lightning/alert'; //<T02>

//Utilities.
import { objUtilities } from "c/globalUtilities";
//Apex Methods
import getAdoptionFactor from "@salesforce/apex/CSMAdoptionFactorViewController.getAdoptionFactor";
import updatePlanRecord from "@salesforce/apex/CSMAdoptionFactorViewController.updatePlanRecord";
import logPafComment from "@salesforce/apex/CSMAdoptionFactorViewController.logPafComment";
import createPafManagerComment from "@salesforce/apex/CSMPlanCommsInternalCommentHelper.createPafManagerComment";
import checkPlanLocked from "@salesforce/apex/CSMAdoptionFactorViewController.checkPlanLocked";
import getDisplayForecast from "@salesforce/apex/CSMChurnForecastController.getDisplayChurnForecast";  //<T03>
import saveButtonType from "@salesforce/apex/IPUConsumptionGoalsController.saveButtonType";

//import static resouces
//import cosmos_icons from '@salesforce/resourceUrl/cosmos_icons';
//Import Fields
import NEXT_EXPECTED_ADOPTION_FACTOR_DATE_FIELD from "@salesforce/schema/Plan__c.Next_Expected_Adoption_Factor_Date__c";
import PAF_FREQUENCY from "@salesforce/schema/Plan__c.PAF_Frequency__c";
import AUTO_PILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import PAF_STATUS from "@salesforce/schema/Plan__c.Status__c";

//Import PAF fields
import CSMCOMMENTS from '@salesforce/schema/Adoption_Factor__c.CSM_Comments__c';
import CSMMANAGERCOMMENTS from '@salesforce/schema/Adoption_Factor__c.CSM_Manager_Comments__c';

const PLAN_FIELDS = [NEXT_EXPECTED_ADOPTION_FACTOR_DATE_FIELD, PAF_FREQUENCY,AUTO_PILOT,PAF_STATUS];

//Custom Labels.
import CSM_PAF_Edit_Modal_Question from "@salesforce/label/c.CSM_PAF_Edit_Modal_Question";
import Warning from "@salesforce/label/c.Warning";
import PAF_Warning_Header from "@salesforce/label/c.PAF_Warning_Header";  //<T02>
import PAF_Duplicate_Message from "@salesforce/label/c.PAF_Duplicate_Message";  //<T02>
import SavePAF from "@salesforce/label/c.SavePAF";
import SaveAndConsumptionGoals from "@salesforce/label/c.SaveAndConsumptionGoals";
import SaveAndChurnForecast from "@salesforce/label/c.SaveAndChurnForecast";

//import custom permissions
import hasCSMManagerPermission from "@salesforce/customPermission/CSMManager";
import hasCSOPermission from "@salesforce/customPermission/CSOUser";
import hasCSMPermission from "@salesforce/customPermission/CSMUser";

export default class CsmManageAdoptionFactorFramework extends LightningElement {
  //Api varaibles
  @api recordId;
  @api isPoppedOut = false;
  //Private Variables
  @track
  adoptionFactorData;
  boolDisplaySpinner;
  adoptionFactorId;
  adoptionFactorIdToEdit;
  adoptionRecordResponse;
  isEdit;
  showConfirmationModal;
  productValue;
  projectValue;
  engagementValue;
  impactValue;
  planHealthScore;
  planHealth;
  csmMangerCommentValue;
  imapactReasonValue;
  csmCommentValue;
  disableInputFields;  
  strPafStatus;
  strAdhocUpdateReason;
  //boolAdhocUpdateReason;
  strProductSliderValue;
  boolShowRiskScreen;
  boolPlanLocked;
  boolDisplayPopOver;
  boolDisplayPreview;
  strPreviousPafRecordId;
  objPreviousPafRecord;
  boolExecutiveSummary;
  boolManagerComments;
  iscassiniOpen=false;
  boolShowChurnForecast =false; //<T03>
  boolShowRisk=false; //<T03>
  boolDisplaySave = false
  //Labels.
  label = {
    CSM_PAF_Edit_Modal_Question,
    Warning,
    PAF_Duplicate_Message,
    PAF_Warning_Header,
    SavePAF
  };

  pafFields = [CSMCOMMENTS,CSMMANAGERCOMMENTS];

  //Private variables.
  boolDisplayIPUConsumptionGoalsModal = false;
  boolIsComingFromModalConfirmation = false;
  intButtonType = 0;
  //strSaveButtonLabel = SavePAF;

  //Icons
  //import icon URLS
  /*iconUrls = {
      lowPriority: cosmos_icons + '/lowPriority.png',
      mediumPriority: cosmos_icons + '/mediumPriority.png',
      highPriority : cosmos_icons + '/highPriority.png'
  };*/
  /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
  connectedCallback() {
    this.boolDisplaySpinner = true;
    this.showConfirmationModal = false;
    this.isEdit = false;
    this.disableInputFields = false;
    //this.boolAdhocUpdateReason = false;
    this.strPafStatus='';
    this.boolPlanLocked = false;
    this.boolShowRiskScreen = false;
    this.boolDisplayPreview=false;
    this.boolExecutiveSummary = false;
    this.boolManagerComments = false;
    this.loadRecords();
  }

  /*
	 Method Name : loadRecords
	 Description : This method loads initial component or refresh.
	 Parameters	 : None
	 Return Type : None
	 */
  loadRecords(){
    let objParent = this;

	//We load the Save button type.
    saveButtonType({
		idRecord: this.recordId
	}).then(intResult => {
		objParent.intButtonType = intResult;

		//We define the button type.
		switch(objParent.intButtonType) {
			//case 0:
			//	objParent.strSaveButtonLabel = SavePAF;
		//	break;
			case 1:
        this.boolDisplaySave=true;
				objParent.strSaveButtonLabel = SaveAndConsumptionGoals;
			break;
			case 2:
        this.boolDisplaySave=true;
				objParent.strSaveButtonLabel = SaveAndChurnForecast;
			break;
		}

		//Now we load the rest of the data.
		return checkPlanLocked({
      strPlanId: this.recordId
		});
    }).then((objResult) => {
      objParent.boolPlanLocked = objResult;
    }).catch((objError) => {
      objUtilities.processException(objError, objParent);
    }).finally(() => {
      //Finally, we hide the spinner.
      objParent.boolDisplaySpinner = false;				
    });
  }
  get productDefaultValue(){
    let intProductValue='';
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Product__c)){
      if(this.adoptionFactorData.Product__c==='Good'){
        intProductValue=0;
      }
      if(this.adoptionFactorData.Product__c==='Average'){
        intProductValue=50;
      }
      if(this.adoptionFactorData.Product__c==='Poor'){
        intProductValue=100;
      }
    }
    return intProductValue;
  }
  get projectDefaultValue(){
    let intProjectValue='';
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Project__c)){
      if(this.adoptionFactorData.Project__c==='Good'){
        intProjectValue=0;
      }
      if(this.adoptionFactorData.Project__c==='Average'){
        intProjectValue=50;
      }
      if(this.adoptionFactorData.Project__c==='Poor'){
        intProjectValue=100;
      }
    }    
    return intProjectValue;
  }

  get engagementDefaultValue(){
    let intEngagementtValue='';
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Engagement__c)){
      if(this.adoptionFactorData.Engagement__c==='Good'){
        intEngagementtValue=0;
      }
      if(this.adoptionFactorData.Engagement__c==='Average'){
        intEngagementtValue=50;
      }
      if(this.adoptionFactorData.Engagement__c==='Poor'){
        intEngagementtValue=100;
      }
    }
    return intEngagementtValue;
  }

  get impactDefaultValue(){
    let intImpactValue='';
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Impact__c)){
      if(this.adoptionFactorData.Impact__c==='Low'){
        intImpactValue=0;
      }
      if(this.adoptionFactorData.Impact__c==='Medium'){
        intImpactValue=50;
      }
      if(this.adoptionFactorData.Impact__c==='High'){
        intImpactValue=100;
      }
    }
    if(objUtilities.isBlank(intImpactValue)){
      if(objUtilities.isNotNull(this.adoptionFactorData) && 
        objUtilities.isNotNull(this.adoptionFactorData.Prior_Adoption_Factor__c) && objUtilities.isNotNull(this.adoptionFactorData.Prior_Adoption_Factor__r) && 
        objUtilities.isNotNull(this.adoptionFactorData.Prior_Adoption_Factor__r.Impact__c) &&  
        objUtilities.isNotNull(hasCSMManagerPermission)){
        var previousImpactValue = this.adoptionFactorData.Prior_Adoption_Factor__r.Impact__c;
        if(previousImpactValue==='Low'){
          intImpactValue=0;
        }
        if(previousImpactValue==='Medium'){
          intImpactValue=50;
        }
        if(previousImpactValue==='High'){
          intImpactValue=100;
        }
      }
    }
    return intImpactValue;
  }

  get productImage(){   
    let productParameters={
    };
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Product__c)){
      if(this.adoptionFactorData.Product__c==='Good'){
        productParameters.iconName="utility:like";
        productParameters.iconVariant="success";
        productParameters.iconClass="actionButton";
      }
      if(this.adoptionFactorData.Product__c==='Average'){
        productParameters.iconName="utility:like";
        productParameters.iconVariant="warning";
        productParameters.iconClass="actionButton rotate-like-icon";
      }
      if(this.adoptionFactorData.Product__c==='Poor'){
        productParameters.iconName="utility:dislike";
        productParameters.iconVariant="error";
        productParameters.iconClass="actionButton";
      }
    }
    return productParameters;
  }
  get projectImage(){
    let projectParameters={};
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Project__c)){
      if(this.adoptionFactorData.Project__c==='Good'){
        projectParameters.iconName="utility:like";
        projectParameters.iconVariant="success";
        projectParameters.iconClass="actionButton";
      }
      if(this.adoptionFactorData.Project__c==='Average'){
        projectParameters.iconName="utility:like";
        projectParameters.iconVariant="warning";
        projectParameters.iconClass="actionButton rotate-like-icon";
      }
      if(this.adoptionFactorData.Project__c==='Poor'){
        projectParameters.iconName="utility:dislike";
        projectParameters.iconVariant="error";
        projectParameters.iconClass="actionButton";
      }
    }
    return projectParameters;
  }

  get engagementImage(){
    let engagementParameters={};
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Engagement__c)){
      if(this.adoptionFactorData.Engagement__c==='Good'){
        engagementParameters.iconName="utility:like";
        engagementParameters.iconVariant="success";
        engagementParameters.iconClass="actionButton";
      }
      if(this.adoptionFactorData.Engagement__c==='Average'){
        engagementParameters.iconName="utility:like";
        engagementParameters.iconVariant="warning";
        engagementParameters.iconClass="actionButton rotate-like-icon";
      }
      if(this.adoptionFactorData.Engagement__c==='Poor'){
        engagementParameters.iconName="utility:dislike";
        engagementParameters.iconVariant="error";
        engagementParameters.iconClass="actionButton";
      }
    }
    return engagementParameters;
  }


  get impactImage(){
    let impactParameters={};
    if(objUtilities.isNotNull(this.adoptionFactorData) && objUtilities.isNotNull(this.adoptionFactorData.Impact__c)){
      if(this.adoptionFactorData.Impact__c==='Low'){
        impactParameters.iconName="utility:like";
        impactParameters.iconVariant="success";
        impactParameters.iconClass="actionButton";
      }
      if(this.adoptionFactorData.Impact__c==='Medium'){
        impactParameters.iconName="utility:like";
        impactParameters.iconVariant="warning";
        impactParameters.iconClass="actionButton rotate-like-icon";
      }
      if(this.adoptionFactorData.Impact__c==='High'){
        impactParameters.iconName="utility:dislike";
        impactParameters.iconVariant="error";
        impactParameters.iconClass="actionButton";
      }
    }
    return impactParameters;
  }

  //Wire Plan record to load
  @wire(getRecord, { recordId: "$recordId", fields: PLAN_FIELDS })
  planRecord;
  //Get param of style class to blink last modified date
  get lastModifiedDateClass() {
    const nextExpectedAdoptionFactorDate = getFieldValue(this.planRecord.data, NEXT_EXPECTED_ADOPTION_FACTOR_DATE_FIELD);
    const autoPilot = objUtilities.isNotBlank(getFieldValue(this.planRecord.data,AUTO_PILOT))?getFieldValue(this.planRecord.data,AUTO_PILOT): false;
    const isComplete = objUtilities.isNotBlank(getFieldValue(this.planRecord.data,PAF_STATUS))?getFieldValue(this.planRecord.data,PAF_STATUS)==='Complete': false;
    //<T01>
    return nextExpectedAdoptionFactorDate && (new Date()).getTime() > (new Date(nextExpectedAdoptionFactorDate)).getTime() && this.adoptionFactorData!==undefined && this.adoptionFactorData.Status__c !== "Final" && !autoPilot && !isComplete
      ? "informationIcon blink_text"
      : "informationIcon";
  }


  //Get paf status for overdue paf
  get pafStatus() {
    //<T01>
    return this.adoptionFactorData.Status__c;
  }

  get updateDueDate() {
    return getFieldValue(
      this.planRecord.data,
      NEXT_EXPECTED_ADOPTION_FACTOR_DATE_FIELD
    );
  }

  get editButtonVisibility(){
    if(!hasCSMPermission){
      return true;
    }

    const autoPilot = objUtilities.isNotBlank(getFieldValue(this.planRecord.data,AUTO_PILOT))?getFieldValue(this.planRecord.data,AUTO_PILOT): false;
    const isComplete = objUtilities.isNotBlank(getFieldValue(this.planRecord.data,PAF_STATUS))?getFieldValue(this.planRecord.data,PAF_STATUS)==='Complete': false;
    //return (objUtilities.isNotBlank(autoPilot) && autoPilot == true && hasCSMPermission) ? true : false;
    return (autoPilot || isComplete);
  }
  get healthScoreClass() {
      let planHealthColor = this.planHealth;
      let planHealthColorClass;
      if(planHealthColor == "Green"){
        planHealthColorClass="slds-m-right_x-small fallback-color-green";
      }
      if(planHealthColor == "Red"){
        planHealthColorClass="slds-m-right_x-small fallback-color-red";
      }
      if(planHealthColor == "Yellow"){
        planHealthColorClass="slds-m-right_x-small fallback-color-yellow";
      }
    return planHealthColorClass;
  }
  /*
	 Method Name : validate
	 Description : this methiod will validate the input values
	 Parameters	 : None
	 Return Type : None
	 */
  validate() {
    let isValid = true;
    this.template.querySelectorAll("lightning-input-field").forEach((ip) => {
      ip.reportValidity();
      if(isValid){
        isValid = ip.reportValidity();  
      }
    });
    this.boolDisplaySpinner = isValid;
    return isValid;
  }

  /*
	 Method Name : getAdoptionFactorData
	 Description : This wire method will fetch the adoption factor record and set the visibility logic
	 Parameters	 : strPlanId, current plan record id
	 Return Type : None
	 */
  @wire(getAdoptionFactor, { strPlanId: "$recordId" })
  getAdoptionFactorData(response) {
    this.boolDisplaySpinner = true;
        
    this.adoptionRecordResponse = response;
    if (response.error) {
      objUtilities.processException(response.error, this);
    } else if (response.data) {
      const data = response.data;
      //if we have record
      if (objUtilities.isNotNull(data) && data.length > 0) {
        let _adoptionFactorData = [];
        //Iterate over the response
        data.forEach((factor) => {
          if (
            objUtilities.isNotNull(factor) && objUtilities.isNotNull(factor.Prior_Adoption_Factor__r)
          ) {
            
            this.strPreviousPafRecordId = factor.Prior_Adoption_Factor__c;
            this.objPreviousPafRecord = factor.Prior_Adoption_Factor__r;
          }
          //if blank adoption record set view record id as previous ADF record adn for edit set the latest record
          if (
            objUtilities.isNotNull(factor) && objUtilities.isBlank(factor.Product__c)
          ) {
              if(objUtilities.isNotNull(factor.Prior_Adoption_Factor__r)){
                this.adoptionFactorId = factor.Prior_Adoption_Factor__c;                
                this.planHealthScore = factor.Prior_Adoption_Factor__r.Plan_Health_Score__c;
                this.planHealth = factor.Prior_Adoption_Factor__r.Health_Color__c;
              }else{
                this.adoptionFactorId = factor.Id;
                this.planHealthScore = factor.Plan_Health_Score__c;
                this.planHealth = factor.Health_Color__c;
              }
            this.adoptionFactorIdToEdit = factor.Id;
            
          } else {
            // If not blank meaning in currecnly in PAF flow then set the latest id
            this.adoptionFactorId = factor.Id;
            this.adoptionFactorIdToEdit = factor.Id;
            this.planHealthScore = factor.Plan_Health_Score__c;
            this.planHealth = factor.Health_Color__c;
          }
          _adoptionFactorData = factor;
        });
        
        this.adoptionFactorData = _adoptionFactorData;
      }
    }
  }

  //<T03>
  @wire(getDisplayForecast, { planId: '$recordId' })
  showForecast;

  //</T03>
  /*
	 Method Name : processEditVisibilityLogic
	 Description : This method will be  seting visibility logic of popup
	 Parameters	 : None
	 Return Type : None
	 */
  processEditVisibilityLogic() {
    //<T02>
    this.boolDisplaySpinner = true;
    let oldAdoptionId=this.adoptionFactorData.Id;
    //Get latest PAF data before editing
    refreshApex(this.adoptionRecordResponse)
            .then(() => {
                if(oldAdoptionId !== this.adoptionFactorData.Id){ // check if any new record created after page loaded
                  LightningAlert.open({ //show warning if record not matches with backend
                    message: this.label.PAF_Duplicate_Message,                    
                    theme: 'warning', 
                    label: this.label.PAF_Warning_Header,
                  });
                }else{ //</T02>
                  //Get the plan next adotion factor date values
                  const nextExpectedAdoptionFactorDate = getFieldValue(this.planRecord.data, NEXT_EXPECTED_ADOPTION_FACTOR_DATE_FIELD);
                  let adoptionFactorRecord = this.adoptionFactorData;
                  //if the PAF record is in final and next adoption factod date is greater than today show popup to confirm or else show edit record directly
                  this.showConfirmationModal = objUtilities.isNotNull(adoptionFactorRecord) && objUtilities.isNotBlank(adoptionFactorRecord.Status__c) &&  adoptionFactorRecord.Status__c == "Final" && nextExpectedAdoptionFactorDate && (new Date()).getTime() < (new Date(nextExpectedAdoptionFactorDate)).getTime();
                  this.boolDisplaySpinner=!this.showConfirmationModal;
                  if(objUtilities.isNotNull(this.showConfirmationModal) && !this.showConfirmationModal &&  adoptionFactorRecord.Status__c !== "Final") {
                    this.isEdit = true;
                    this.boolDisplaySpinner = false;
                  }else if(objUtilities.isNotNull(adoptionFactorRecord) && objUtilities.isNotBlank(adoptionFactorRecord.Status__c) && adoptionFactorRecord.Status__c == "Final" && objUtilities.isNotNull(this.showConfirmationModal) && !this.showConfirmationModal){      
                    this.strPreviousPafRecordId=this.adoptionFactorData.Id;
                    this.objPreviousPafRecord = this.adoptionFactorData;
                    this.isEdit = true;      
                    this.adoptionFactorIdToEdit=null;
                  }else{
                    this.isEdit = false;
                  }
                }
            });
  }
  /*
	 Method Name : handleClick
	 Description : This method will be called from html on click
	 Parameters	 : None
	 Return Type : None
	 */
  handleClick(event) {
    let objParent = this;
    switch (event.target.dataset.name) {
      case "copySummary":
        objParent.copySelectedTextToClipboard(objParent.objPreviousPafRecord.CSM_Comments__c);
        break;
        case "copyManagerComment":
          objParent.copySelectedTextToClipboard(objParent.objPreviousPafRecord.CSM_Manager_Comments__c);
          break;
      case "previewSummary":
        objParent.boolExecutiveSummary = true;
        objParent.boolManagerComments = false;
        if(!objParent.boolDisplayPreview){
          objParent.handlePreview("previewSummary");
        }else{
          objParent.handleStopPreview();
        }
      break;
      case "previewManagerComment":
        objParent.boolManagerComments = true;
        objParent.boolExecutiveSummary = false;
        if(!objParent.boolDisplayPreview){
          objParent.handlePreview("previewManagerComment");
        }else{
          objParent.handleStopPreview();
        }
        break;
      case "edit":               
        this.strPafStatus='';
        //Call the method to show popup or not
        this.processEditVisibilityLogic(); 
        break;
      case "cancelmodal":
        this.isEdit = false;        
        this.boolDisplaySpinner = true;
        refreshApex(this.adoptionRecordResponse);
        this.showConfirmationModal = false;
        break;
      case "confirmmodal":        
        this.strPreviousPafRecordId=this.adoptionFactorData.Id;
        this.objPreviousPafRecord = this.adoptionFactorData;
        this.adoptionFactorIdToEdit=null;
        this.isEdit = true;
        objParent.showConfirmationModal = false;        
        objParent.boolDisplaySpinner = false;
        break;
      case "close":
        this.isEdit = false;
        this.boolDisplaySpinner = true;
        this.handleStopPreview();
        break;
      case "refresh":
        this.boolDisplaySpinner = true;
        refreshApex(this.adoptionRecordResponse);
        refreshApex(this.planRecord);
        refreshApex(this.showForecast); //<T03>
        this.boolDisplaySpinner = true;
        this.loadRecords();
        this.handleStopPreview();
        break;
      case "save":
        this.handleSave();      
        break;
      case "save0":
        this.intButtonType=0;
        this.handleSave();      
        break;
      default:
        this.handleStopPreview();
        break;
    }
  }

  handleSave(){
    this.handleStopPreview();
    //<T02>
    this.boolDisplaySpinner = true;
    let oldAdoptionId=this.adoptionFactorData.Id;
    //Get latest PAF data before editing
    refreshApex(this.adoptionRecordResponse)
      .then(() => {
          if(oldAdoptionId !== this.adoptionFactorData.Id){ // check if any new record created after page loaded
            LightningAlert.open({ //show warning if record not matches with backend
              message: this.label.PAF_Duplicate_Message,                    
              theme: 'warning', 
              label: this.label.PAF_Warning_Header,
            });
            this.isEdit = false;
          }else{ 
            if(this.validate()) {
              this.template
                .querySelector('[data-name="pafforSubmitButton"]')
                .click();
            }
          }
        }); 
        //</T02>
  }

  /*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
  popOut(objEvent) {
    let boolIsPopingOut;
    //First we define the operation.
    switch (objEvent.target.dataset.name) {
      case "popOut":
        boolIsPopingOut = true;
        break;
      case "popIn":
        boolIsPopingOut = false;
        break;
    }
    //Now we send the event.
    this.dispatchEvent(
      new CustomEvent("popout", {
        detail: {
          boolIsPopingOut: boolIsPopingOut
        }
      })
    );
  }
  /*
	 Method Name : handleSuccess
	 Description : This method gets executed when record save success of record-edit-form via LDS and update plan
	 Parameters	 : Event,
	 Return Type : None
	 */
  handleSuccess(event) {
    const payload = event.detail;
    let objParent = this;
    objParent.adoptionFactorId = payload.id;    
    objParent.isEdit = false;
    objParent.updatePlan();
    this.adoptionFactorIdToEdit = payload.id;    
    refreshApex(objParent.adoptionRecordResponse);

    if(objUtilities.isNotBlank(objParent.strPafStatus)){
      if(objParent.strPafStatus=='Waiting for CSM Manager Input'){
        objParent.createPlanCommentRecord('CSM has graded the PAF scalars. PAF Health is '+this.planHealthScore+'. CSM Comments: '+this.csmCommentValue,'Please grade the impact for Predictive Adoptive Framework');   
      }
      if(objParent.strPafStatus=='Final'){             
        //objParent.createPlanCommentRecord('CSM Manager has completed PAF Impact analysis and PAF score is generated',''); 
        objParent.boolDisplaySpinner = true;     
        createPafManagerComment({
          strPAFId: payload.id,
          strPlanId:objParent.recordId
        }).then(() => {
                  
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;

        });
      }
     
      //Logic to Show Risk Edit page
      if((objParent.strPafStatus=='Final' || objParent.strPafStatus=='Waiting for CSM Manager Input') && objUtilities.isNotBlank(objParent.planHealth) && 
      (objParent.planHealth ==='Red' || objParent.planHealth ==='Yellow') &&
      objParent.imapactReasonValue.includes("Financial Impact") ) {   
        objParent.boolShowRisk= true; //<T03>
      }
     
    }    
    
    //We display the IPU Consumption Goals modal, if needed.
    objParent.displayIPUConsumptionGoalsModal();
    objParent.boolDisplaySpinner = false;    
  }
  /*
	 Method Name : handleSubmit
	 Description : This method gets executed when record submit of record-edit-form via LDS and set values on PAF record
	 Parameters	 : Event,
	 Return Type : None
	 */
  handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    this.boolShowRiskScreen=false;
    let objParent = this;
    const fields = event.detail.fields;
    
    if(objUtilities.isNull(this.productValue)){
      this.productValue = this.getSliderRangeValue(this.productDefaultValue);
    }
    if(objUtilities.isNull(this.engagementValue)){
      this.engagementValue = this.getSliderRangeValue(this.engagementDefaultValue);
    }
    if(objUtilities.isNull(this.projectValue)){
      this.projectValue = this.getSliderRangeValue(this.projectDefaultValue);
    }
    if(objUtilities.isNull(this.impactValue)){
      this.impactValue = this.getImpactSliderRangeValue(this.impactDefaultValue);
    }
    
    fields.Product__c = this.productValue;
    fields.Engagement__c = this.engagementValue;
    fields.Project__c = this.projectValue;
    fields.Impact__c = this.impactValue;
    this.csmCommentValue = this.template.querySelector('[data-id="CSM_Comments__c"').value;
    this.imapactReasonValue = this.template.querySelector('[data-id="Impact_Reason__c"').value;
    this.csmMangerCommentValue = this.template.querySelector('[data-id="CSM_Manager_Comments__c"').value;
    //if CSM update the PAF set status as waiting for CSM Manager input
    if (
      objUtilities.isNotBlank(this.productValue) &&
      objUtilities.isNotBlank(this.projectValue) &&
      objUtilities.isNotBlank(this.engagementValue) &&
      objUtilities.isNotBlank(this.csmCommentValue) &&
      objUtilities.isNotBlank(this.impactValue) &&
      objUtilities.isNotBlank(this.imapactReasonValue) &&
      objUtilities.isBlank(this.csmMangerCommentValue)
    ) {
      fields.Status__c = "Waiting for CSM Manager Input";       
      this.strPafStatus = "Waiting for CSM Manager Input";  
      this.calculatePlanHealth();
    }
    //if CSM Manager update the PAF set status as final
    if (
      objUtilities.isNotBlank(this.productValue) &&
      objUtilities.isNotBlank(this.projectValue) &&
      objUtilities.isNotBlank(this.engagementValue) &&
      objUtilities.isNotBlank(this.csmCommentValue) &&
      objUtilities.isNotBlank(this.impactValue) &&
      objUtilities.isNotBlank(this.imapactReasonValue) &&
      objUtilities.isNotBlank(this.csmMangerCommentValue)
    ) {
      fields.Status__c = "Final";
      this.strPafStatus = "Final";    
      this.calculatePlanHealth();
    }
    //Show Warning on removing Financial impact on update
    if(objUtilities.isNotNull(objParent.adoptionFactorData) && objUtilities.isNotNull(objParent.adoptionFactorData.Impact_Reason__c) && 
      objParent.adoptionFactorData.Impact_Reason__c.includes("Financial Impact") && objUtilities.isNotNull(objParent.imapactReasonValue) && 
      !objParent.imapactReasonValue.includes("Financial Impact") ){
      objUtilities.showToast(objParent.label.Warning,'Please review your risks for renewal impact','warning',objParent);
    }
    if (objUtilities.isNotBlank(this.planHealthScore)) {
      fields.Plan_Health_Score__c = this.planHealthScore;
    }
    //Map Plan Health Color
    if (objUtilities.isNotBlank(this.planHealth)) {
      fields.Health_Color__c = this.planHealth;
    }
    if (this.adoptionFactorIdToEdit==undefined) {
      fields.Prior_Adoption_Factor__c  = this.adoptionFactorData.Id;
    }
    this.template.querySelector("lightning-record-edit-form").submit(fields);
    this.boolDisplaySpinner = true;
  }
  /*
	 Method Name : handleLoad
	 Description : This method gets executed when record on load of record-edit-form via LDS and disable fields for CSM
	 Parameters	 : None
	 Return Type : None
	 */
  handleLoad() {
    this.boolDisplaySpinner = true;
    const mangerCommentField = this.template.querySelector('[data-id="CSM_Manager_Comments__c"]');
    const csmCommentField = this.template.querySelector('[data-id="CSM_Comments__c"]');
    if(objUtilities.isNotNull(mangerCommentField) && objUtilities.isNotNull(this.adoptionFactorData.CSM_Manager_Comments__c)){
      //mangerCommentField.value = this.adoptionFactorData.CSM_Manager_Comments__c ;
    }
    if(objUtilities.isNotNull(csmCommentField) && objUtilities.isNotNull(this.adoptionFactorData.CSM_Comments__c)){
     // csmCommentField.value = this.adoptionFactorData.CSM_Comments__c ;
    }
    //Disabling the input fields for CSM user/CSM Manager and CSO can edit all fields.
    if (
      objUtilities.isNull(hasCSMManagerPermission) &&
      objUtilities.isNull(hasCSOPermission)     
    ) {
      this.disableInputFields = true;
    }else{
      this.disableInputFields = false;
    }
    this.boolDisplaySpinner = false;
  }

  handleviewLoad(){
    this.boolDisplaySpinner = true;
    this.boolDisplaySpinner = false;
  }
  /*
	 Method Name : updatePlan
	 Description : This method update plan of next adoption date by adding frequency and plan health
	 Parameters	 : None
	 Return Type : None
	*/
  updatePlan() {
    if(objUtilities.isNotBlank(this.planHealth)){
      this.boolDisplaySpinner = true;
      let objParent = this;
      let planHealthReasonValue = '';
      if(objUtilities.isNotNull(objParent.csmCommentValue)){
        planHealthReasonValue+="<b>Executive Summary : </b>" + objParent.csmCommentValue +"<br>";
      }
      //Capture the plan health reason once PAF submitted
      if(objUtilities.isNotNull(objParent.csmMangerCommentValue) ){
        //AR-1967: Bug fix - Added space after colon(:) on Plan Reason format
        planHealthReasonValue += "<b>Manager Review: </b>" + objParent.csmMangerCommentValue;
      }
      
      updatePlanRecord({
        strPlanId: objParent.recordId,
        strPlanFrequency: getFieldValue(objParent.planRecord.data, PAF_FREQUENCY),
        planHealthValue: objParent.planHealth,
        planHealthReason : planHealthReasonValue
      })
        .then(() => {
          refreshApex(objParent.adoptionRecordResponse);
          refreshApex(objParent.planRecord);         
        })
        .catch((objError) => {
          objUtilities.processException(objError, objParent);
        })
        .finally(() => {
          //Finally, we hide the spinner.
          objParent.boolDisplaySpinner = false;
        });
    }
  }

  createPlanCommentRecord(strCommentValue,strChatterCommentValue){
    if(objUtilities.isNotNull(strCommentValue)){
      let objParent = this;
      objParent.boolDisplaySpinner = true;
      logPafComment({
        strPlanId: objParent.recordId,
        planComment : strCommentValue,
        strChatterMessageValue : strChatterCommentValue
      })
      .then(() => {
        
      })
      .catch((objError) => {
        objUtilities.processException(objError, objParent);
      })
      .finally(() => {
        //Finally, we hide the spinner.
        objParent.boolDisplaySpinner = false;
      });
    }
  }
  
  //Series of methods will call on input change and capture the updated value
  hangleProductChange(objEvent) {
    const { intRangeValue } = objEvent.detail;
    this.productValue = this.getSliderRangeValue(intRangeValue);
  }
  handleProjectChange(objEvent) {
    const { intRangeValue } = objEvent.detail;
    this.projectValue = this.getSliderRangeValue(intRangeValue);//objEvent.target.value;
  }
  handleEngagementChange(objEvent) {
    const { intRangeValue } = objEvent.detail;
    this.engagementValue = this.getSliderRangeValue(intRangeValue);//objEvent.target.value;
  }
  handleImpactChange(objEvent) {
    const { intRangeValue } = objEvent.detail;
    this.impactValue = this.getImpactSliderRangeValue(intRangeValue);//objEvent.target.value;
  }
  handleCsmCommentChange(objEvent) {
    this.csmCommentValue = objEvent.target.value;
  }
  handleImpactReasonChange(objEvent) {
    this.imapactReasonValue = objEvent.target.value;
  }
  handleCsmManagerCommentsChange(objEvent) {
    this.csmMangerCommentValue = objEvent.target.value;
  }
  hangleAdhocUpdateReason(objEvent) {
    this.strAdhocUpdateReason = objEvent.target.value;
  }
  //Based on Slider range it will set the value
  getSliderRangeValue(intRangeValue){
    var strValue = 'Good';
    if(objUtilities.isNotNull(intRangeValue) && intRangeValue == 50){
      strValue = 'Average';
    }else if(objUtilities.isNotNull(intRangeValue) && intRangeValue == 100){
      strValue = 'Poor';
    } 
    return strValue;
  }

   //Based on Impact Slider range it will set the value
   getImpactSliderRangeValue(intRangeValue){
    var strValue = 'Low';
    if(objUtilities.isNotNull(intRangeValue) && intRangeValue == 50){
      strValue = 'Medium';
    }else if(objUtilities.isNotNull(intRangeValue) && intRangeValue == 100){
      strValue = 'High';
    } 
    return strValue;
  }

   /*
	 Method Name : calculatePlanHealth
	 Description : This method will calulate plan health based on 9 BOX modal
	 Parameters	 : None
	 Return Type : None
	*/
  //9 box model is based on number of scalars graded medium/high and overall adoption impact.
  //The number of medium/high scalars are plotted on the x-axis and the overall adoption
  //impact is plotted on the y-axis and the intersection gives the 9 box score.
  //Outcome of the 9-box model gives the plan health.
  calculatePlanHealth() {
    let lowCounter = 0;
    let mediumCounter = 0;
    let highCounter = 0;        
    //increase the counter based on product Value
    if (this.productValue && this.productValue == "Good") {
      lowCounter++;
    }
    if (this.productValue && this.productValue == "Average") {
      mediumCounter++;
    }
    if (this.productValue && this.productValue == "Poor") {
      highCounter++;
    }
    //increase the counter based on project Value
    if (this.projectValue && this.projectValue == "Good") {
      lowCounter++;
    }
    if (this.projectValue && this.projectValue == "Average") {
      mediumCounter++;
    }
    if (this.projectValue && this.projectValue == "Poor") {
      highCounter++;
    }
    //increase the counter based on engagement Value
    if (this.engagementValue && this.engagementValue == "Good") {
      lowCounter++;
    }
    if (this.engagementValue && this.engagementValue == "Average") {
      mediumCounter++;
    }
    if (this.engagementValue && this.engagementValue == "Poor") {
      highCounter++;
    }
    var sumofPoorMid = highCounter + mediumCounter;
    
    if (this.impactValue && this.impactValue == "Low") {
      if (sumofPoorMid == 1 || sumofPoorMid == 0) {
        this.planHealthScore = "1A";
      }
      if (sumofPoorMid == 2) {
        this.planHealthScore = "2A";
      }
      if (sumofPoorMid == 3) {
        this.planHealthScore = "3A";
      }
    }
    if (this.impactValue && this.impactValue == "Medium") {
      if (sumofPoorMid == 1 || sumofPoorMid == 0) {
        this.planHealthScore = "1B";
      }
      if (sumofPoorMid == 2) {
        this.planHealthScore = "2B";
      }
      if (sumofPoorMid == 3) {
        this.planHealthScore = "3B";
      }
    }
    if (this.impactValue && this.impactValue == "High") {
      if (sumofPoorMid == 1 || sumofPoorMid == 0) {
        this.planHealthScore = "1C";
      }
      if (sumofPoorMid == 2) {
        this.planHealthScore = "2C";
      }
      if (sumofPoorMid == 3) {
        this.planHealthScore = "3C";
      }
    }
    
    if (
      objUtilities.isNotNull(this.planHealthScore) &&
      (this.planHealthScore == "2C" ||
        this.planHealthScore == "3C" ||
        this.planHealthScore == "3B")
    ) {
      //Red
      this.planHealth = "Red";
    } else if (
      objUtilities.isNotNull(this.planHealthScore) &&
      (this.planHealthScore == "1C" ||
        this.planHealthScore == "2B" ||
        this.planHealthScore == "3A")
    ) {
      //Yellow
      this.planHealth = "Yellow";
    }else if (
      objUtilities.isNotNull(this.planHealthScore) &&
      (this.planHealthScore == "1B" ||
        this.planHealthScore == "1A" ||
        this.planHealthScore == "2A")
    ) {
      //Green
      this.planHealth = "Green";
    }  else {
      //if paf score is undefined then set the plan health as Green; bascially for all lows
      //Green
      this.planHealth = "Green";
      this.planHealthScore = "1A";
    }
  }
  
  handleClose(objEvent){
    this.boolShowRisk = false;
    this.boolShowRiskScreen=false;
  }
 //<T03> 
  handleCloseChurn(event){    
   // this.boolShowRiskScreen=event.detail;
    this.boolShowChurnForecast = false;
  }
  //</T03> 

  /*
	 Method Name : handleMouseOver
	 Description : This method catches the Mouse Over event on icon.
	 Parameters	 : Object, called from mouseOVer, objEvent Select event.
	 Return Type : None
	 */
   handleMouseOver(objEvent) {
		let objParentReference;

    let objPosition = this.template.querySelector('[data-id="informationtag"]').getBoundingClientRect();
		let objCoordinates = {
			x: objPosition.left,
			y: objPosition.top
		}
		let intPosition = 60;
    switch(window.innerWidth) {
      case 1280:
         intPosition = 50;
      break; 
      case 1600:
         intPosition = 20;
      break; 
      case 1920:
        intPosition = 80;
      break;
    }
    this.boolDisplayPopOver = true;
		objParentReference = this.template.querySelector(".informationIcon").getBoundingClientRect();
		this.template.querySelector(".compactLayout").style = "top: " + (objCoordinates.y + 30) + "px; left: " + objCoordinates.x + 
					"px; position: fixed; z-index: 9999999;transform: translate(-" + (objParentReference.y-intPosition) + "px, 0px);";
  }

  /*
	 Method Name : handleMouseOut
	 Description : This method catches the Mouse Out event on icon.
	 Parameters	 : None.
	 Return Type : None
	 */
	handleMouseOut() {
		this.boolDisplayPopOver = false;
  }

  /*
	 Method Name : handlePreview
	 Description : This method show preview dialog
	 Parameters	 : None.
	 Return Type : None
	 */
   handlePreview(keyParam) {
    let objParentReference;
    let objPosition = this.template.querySelector('[data-id="' + keyParam + '"]').getBoundingClientRect();
		let objCoordinates = {
			x: objPosition.left,
			y: objPosition.top
		}
		let intPosition = 30;
    this.boolDisplayPreview = true;
		objParentReference = this.template.querySelector(".customGeneralCSS").getBoundingClientRect();
		this.template.querySelector(".compactLayoutPreview").style = "top: " + (objCoordinates.y +30) + "px; left: " + (objCoordinates.x-150) + 
					"px; position: fixed; z-index: 9999999;transform: translate(-" + (objParentReference.y-intPosition) + "px, 0px);";
  }

  /*
	 Method Name : handleStopPreview
	 Description : This stop preview dialog
	 Parameters	 : None.
	 Return Type : None
	 */
	handleStopPreview() {
		this.boolDisplayPreview = false;
    this.boolExecutiveSummary = false;
    this.boolManagerComments = false;
  }  

  /*
	 Method Name : copySelectedTextToClipboard
	 Description : This method copies the text to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
  copySelectedTextToClipboard(strText){
    let objInputField = this.template.querySelector('.clipboard');
    this.handleStopPreview();
    objInputField.value = strText;
		objInputField.select();
		document.execCommand('copy', false, strText);
  }

  openCassini(){
    this.iscassiniOpen=true;
  }

  closeCassini(){
    this.iscassiniOpen=false;
  }

	/*
	Method Name : displayIPUConsumptionGoalsModal
	Description : This method displays the IPU Consumption Goals modal, if needed.
	Parameters  : None
	Return Type : None
	*/
	displayIPUConsumptionGoalsModal() {
		if(this.intButtonType === 1) {
			this.boolDisplayIPUConsumptionGoalsModal = true;
		}
    else if(this.intButtonType === 2){
      this.boolShowChurnForecast = true;
    }//<T03> 
   // else if(this.boolShowRisk){
      //this.boolShowRiskScreen=true;
   // }
    //</T03> 
	}

	/*
	 Method Name : hideIPUConsumptionGoalsModal
	 Description : This method hides the IPU Consumption Goals modal.
	 Parameters  : Object, called from hideIPUConsumptionGoalsModal, objEvent Event.
	 Return Type : None
	 */
	hideIPUConsumptionGoalsModal(objEvent) {

		//We close the current modal.
		this.boolDisplayIPUConsumptionGoalsModal = false;
		this.boolShowChurnForecast = false;

    if(objUtilities.isNotNull(objEvent) && objUtilities.isNotNull(objEvent.detail) && typeof objEvent.detail === "boolean") {
			this.boolShowRisk = objEvent.detail;
		}
		//Now, depending on the data received, we take the next action.
		if(this.showForecast.data) {

			//We open the Churn Forecast component.
			this.boolShowChurnForecast = true;
		}
   // else if(this.boolShowRisk){
     // this.boolShowRiskScreen=true;
  //  }
	}

	handleError(event) {
        this.boolDisplaySpinner = false;
		objUtilities.showToast('Error', event.detail.message + " " + event.detail.detail, 'error',this);
    }
}