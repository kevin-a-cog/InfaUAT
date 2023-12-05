/* Name			    :	CsmOneClickActionContainer
* Author		    :	Deva M
* Created Date	    :   10/08/2021
* Description	    :	CsmOneClickActionContainer controller.

Change History
**********************************************************************************************************************
Modified By			Date			    Jira No.		Description					                                                   Tag
***********************************************************************************************************************
Deva M		        10/08/2021		N/A				  Initial version.			                                                N/A
Narpavi Prabu       01/03/2023     AR-3113      Validate for CSA enagment if no plan conatct with role 
                                            Technical Owner/Contributor                                           T01
Chaitanya T       12/01/2023    AR-3413     Survey icon should disapper when Eng is close without eng status      T02
                                AR-3408
                                                                                        
*/
//Core Imports
import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Utilities.
import { objUtilities } from "c/globalUtilities";
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';

//Apex Imports
import getPlanTeamRecord from "@salesforce/apex/CSMOneClickActionController.getPlanTeamRecord";
import updatePlanTeamMember from "@salesforce/apex/CSMOneClickActionController.updatePlanTeamMember";
import updateSurveyFlagOnPlanContact from "@salesforce/apex/CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact";
import updateSurveyFlagOnEng from "@salesforce/apex/CSMSendSurveyToPlanContacts.updateSurveyFlagOnEng";
import getResendSurveyVisiblity from "@salesforce/apex/CSMOneClickActionController.getResendSurveyVisiblity";
import getPlanRecordId from "@salesforce/apex/CSMOneClickActionController.getPlanRecordId";
import getObjectName from "@salesforce/apex/CSMOneClickActionController.getObjectName";
import CheckPlanContactforCSASurvey from "@salesforce/apex/CSMOneClickActionController.CheckPlanContactforCSASurvey";
import CheckPlanContactforMFASurvey from "@salesforce/apex/CSMOneClickActionController.CheckPlanContactforMFASurvey";

//Import EMP  Api
//import { subscribe, unsubscribe }  from 'lightning/empApi';
//import static resources
import cosmos_icons from '@salesforce/resourceUrl/cosmos_icons';
//Fields
import SUBSTAGE_FIELD from '@salesforce/schema/Plan__c.Sub_Stage__c';
import AUTO_PILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";

import ENG_STATUS from "@salesforce/schema/Engagement__c.Status__c";
import ENG_RECTYPE from "@salesforce/schema/Engagement__c.RecType__c";
import ENG_CSA_SURVEY_STATUS from "@salesforce/schema/Engagement__c.CST_Survey_Sent__c";
import ENG_MFA_SURVEY_STATUS from "@salesforce/schema/Engagement__c.MFA_Survey_Sent__c";
//@Akhilesh 
import hasCSMPermission from "@salesforce/customPermission/CSMUser";
const PLAN_FIELDS = [SUBSTAGE_FIELD,AUTO_PILOT];

import MFASuccessSendMsg from '@salesforce/label/c.MFASuccessSendMsg';
import MFASuccessResendMsg from '@salesforce/label/c.MFASuccessResendMsg';

const engCloseStatus = 'Close without Engagement';//<T02>

export default class CsmOneClickActionContainer extends LightningElement {

  //import icon URLS

  iconUrls = {
      Unsnooze_Notification: cosmos_icons + '/Green_Bell_Notification.png',
      Snooze_Notification: cosmos_icons + '/Mute_Bell_Notification.png',
      OnboardSurveyIcon : cosmos_icons + '/OnboardSurveyIcon.png',
      OutcomeSurveyIcon : cosmos_icons + '/OutcomeSurveyIcon.png',
      CSTSurveyIcon : cosmos_icons + '/CSTSurveyIcon.png',
  };
  //Public variables
  @api recordId;
  label = {MFASuccessSendMsg, MFASuccessResendMsg};
  //private variables
  showSnoozeButton;
  showSnoozeButtonGroup;
  planTeamRecord;
  boolDisplaySpinner;
  planTeamSub;
  showAutoPilotComponent=false;
  //subscription = {};
  strEngRecordId='';
  objectApiName;
  planId;

  /** Resend Survey Attributes */
  showResendOnboardSurvey = false;
  showResendOutcomeSurvey = false;
  showResendCSTSurvey = false;
  showSendCSTSurvey = false;
  showSendMFASurvey = false;
  showResendMFASurvey = false;

  checkplanteamforCSA = false;
  checkplanteamforMFA = false;

  //Wire Plan record to load
  @wire(getRecord, { recordId: "$recordId", fields: PLAN_FIELDS })
  planRecord;
  
  @wire(getRecord,{recordId: "$strEngRecordId", fields: [ENG_STATUS]})
  handleengagementrefresh(){
    this.boolDisplaySpinner = true ; 
    this.refreshCard();
  }
 

  get isshowResendOnboardSurvey(){
    return this.showResendOnboardSurvey && this.objectApiName === 'Plan__c';
  }

  get isshowResendOutcomeSurvey(){
    return this.showResendOutcomeSurvey && this.objectApiName === 'Plan__c';
  }

  get isshowResendCSTSurvey(){
    return this.showResendCSTSurvey && this.objectApiName === 'Engagement__c';
  }

  get isshowSendCSTSurvey(){
    return this.showSendCSTSurvey && this.objectApiName === 'Engagement__c';
  }

  get isshowSendMFASurvey(){
    return this.showSendMFASurvey && this.objectApiName === 'Engagement__c';
  }

  get isshowResendMFASurvey(){
    return this.showResendMFASurvey && this.objectApiName === 'Engagement__c';
  }

 // @Akhilesh 
  get csmOneClickActionContainerVisibility(){
    const autoPilot = getFieldValue(
      this.planRecord.data,
      AUTO_PILOT
    );
    return (objUtilities.isNotBlank(autoPilot) && autoPilot == true && hasCSMPermission) ? true : false;
  }

  @wire(getRecord, {
    recordId: "$strEngRecordId",
    fields: [ENG_RECTYPE,ENG_STATUS,ENG_MFA_SURVEY_STATUS,ENG_CSA_SURVEY_STATUS]//<T02> added status fields
  })
  engRecType;

  /*
 Method Name : connectedCallback
 Description : This method Called when the element is inserted into a document.
 Parameters	 : None
 Return Type : None
 */
  connectedCallback() {
    let objParent = this;
    
    getObjectName({recordId : this.recordId})
    .then(result =>{
      this.objectApiName = result;      
        if(this.objectApiName === 'Plan__c'){
          this.planId = this.recordId;
          this.refreshCard();
        }else if(this.objectApiName === 'Engagement__c'){
          this.strEngRecordId = this.recordId;
          //let objParent = this;
          getPlanRecordId({recordId : this.recordId})
          .then(result=>{
            console.log('result ' + result);
            this.planId = result;
            this.refreshCard();         
          })
          .catch((error) => {
            objUtilities.processException(error, objParent);
          }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
          });
        }

    })
    .catch(error=>{
      objUtilities.processException(error, objParent);
    })
    .finally(() => {
      //Finally, we hide the spinner.
      objParent.boolDisplaySpinner = false;

    });
  
     
  }
  refreshCard(){
    if(this.objectApiName === 'Plan__c'){//Display snooze/unsnooze only for Plan records
      this.processButtonVisibilityLogic();
    }
    this.processSurveyButtonsVisiblityLogic(); 
    this.showSnoozeButton = false;
    this.showSnoozeButtonGroup = false;
    this.boolDisplaySpinner = false;    
  }
  /*subscribeToPlanTeamDataChange() {
      if (this.planTeamSub) {
          return;
      }
      // Callback invoked whenever a new event message is received
      var thisReference = this;
      const messageCallback = function(response) {
          thisReference.processButtonVisibilityLogic();
      };
      // Invoke subscribe method of empApi. Pass reference to messageCallback
      var channelName = '/data/Plan_Team__ChangeEvent';
      // Invoke subscribe method of empApi. Pass reference to messageCallback
      subscribe(channelName, -1, messageCallback).then(response => {
        // Response contains the subscription information on subscribe call
        console.log('Subscription request sent to: ', JSON.stringify(response.channel));
        this.subscription = response;
    });
  }

  handleUnsubscribe() {
    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, response => {
        console.log('unsubscribe() response: ', JSON.stringify(response));
        // Response is true for successful unsubscribe
    });
  }*/
  /*
 Method Name : processButtonVisibilityLogic
 Description : This method Called on load and set  button visibiility logic
 Parameters	 : None
 Return Type : None
 */
  processButtonVisibilityLogic() {
    this.boolDisplaySpinner = true;
    let objParent = this;
    getPlanTeamRecord({ planRecordId : this.planId,
    engRecordId:this.strEngRecordId
    })
      .then((result) => {
        if (
          objUtilities.isNotNull(result) &&
          objUtilities.isNotNull(result.User__c)
        ) {
          this.planTeamRecord = result;
          this.showSnoozeButton = result.CSM_Receive_Notifications__c;         
          this.showSnoozeButtonGroup = true;
        }
      })
      .catch((error) => {
        objUtilities.processException(error, objParent);
      }).finally(() => {
        //Finally, we hide the spinner.
        objParent.boolDisplaySpinner = false;
      });
  }
  //Handle the logic for oncick button
  handleButtonClick(event) {
    this.boolDisplaySpinner = true;
    switch (event.target.getAttribute('data-id')) {
      case "snooze":
        this.updatePlanTeamRecord(true);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Notfications have been enabled",
            variant: "success"
          })
        );
        break;
      case "unsnooze":
        this.updatePlanTeamRecord(false);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Notifications have been disabled",
            variant: "success"
          })
        );
        break;
      default:
        break;
    }
  }

  updatePlanTeamRecord(receive_Notifications) {    
    let objParent = this;
      //Now Update teh plan team member with relavant values
    updatePlanTeamMember({ planTeamMemberId : this.planTeamRecord.Id,snoozeNotification : receive_Notifications })
    .then((result) => {
        objParent.showSnoozeButton = !objParent.showSnoozeButton ;
       /* if(this.subscription){
          this.handleUnsubscribe();
        }*/
    })
    .catch((error) => {
        objUtilities.processException(error, objParent);
    }).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
      objParent.showSnoozeButtonGroup=false;
		});
  }

  mouseOver (event) {
    var dataId = event.target.getAttribute('data-id');
      switch(dataId) {
          case "snooze":
              this.template.querySelector(`[data-id="${dataId}"]`).src = this.iconUrls.Unsnooze_Notification;
            break;
          case "unsnooze":
              this.template.querySelector(`[data-id="${dataId}"]`).src = this.iconUrls.Snooze_Notification;
            break;
      }
  }

  mouseOut (event) {
    var dataId = event.target.getAttribute('data-id');
    switch(dataId) {
        case "snooze":
            this.template.querySelector(`[data-id="${dataId}"]`).src = this.iconUrls.Snooze_Notification;
          break;
        case "unsnooze":
            this.template.querySelector(`[data-id="${dataId}"]`).src = this.iconUrls.Unsnooze_Notification;
          break;
    }
  } 

  get recType() {
    return getFieldValue(this.engRecType.data, ENG_RECTYPE);
  }

  processSurveyButtonsVisiblityLogic(){
    let objParent = this;
    getResendSurveyVisiblity({recordId : this.planId, engRecordId : this.strEngRecordId})//<T02> added engRecordId parameter
    .then(result=>{
      console.log('result >> '+ JSON.stringify(result));
      this.showResendOnboardSurvey = result.showResendOnboardSurvey;
      this.showResendOutcomeSurvey = result.showResendOutcomeSurvey;
      //Reset the survey flags //<T02> start
      this.showResendCSTSurvey = false;
      this.showSendCSTSurvey = false;
      this.showSendMFASurvey = false;
      this.showResendMFASurvey = false;//</T02> end
      if(this.objectApiName === 'Engagement__c' && this.recType === 'CSA' && getFieldValue(this.engRecType.data, ENG_STATUS) != engCloseStatus){//<T02> added status condition
        this.showResendCSTSurvey = result.showResendCSTSurvey;
        this.showSendCSTSurvey = result.showSendCSTSurvey;
      }else if(this.objectApiName === 'Engagement__c' && this.recType === 'MFA' && getFieldValue(this.engRecType.data, ENG_STATUS) != engCloseStatus){//<T02> added status condition
        this.showSendMFASurvey = result.showSendMFASurvey;
        this.showResendMFASurvey = result.showResendMFASurvey;
      }
    })
    .catch(error=>{
      objUtilities.processException(error, objParent);
    })
  }

  
  handleResendSurvey(event){
    let objParent = this;
    var dataId = event.target.getAttribute('data-id');
    var planIds = [];
    planIds.push(this.planId);
    //validate();
    switch(dataId) {

      case "ResendOnboardSurvey":
        updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'ONBOARDING_SURVEY'})
        .then(result =>{
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Onboarding survey has been resent!",
              variant: "success"
            })
          );
        })
        .catch(error=>{
          objUtilities.processException(error, objParent);
        })
        break;

      case "ResendOutcomeSurvey":
        updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'OUTCOME_SURVEY'})
        .then(result =>{
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Business Outcome survey has been resent!",
                variant: "success"
              })
            );
        })
        .catch(error=>{
          objUtilities.processException(error, objParent); 
        })
          
        break;

      //<T01>
      case "ResendCSTSurvey":
      CheckPlanContactforCSASurvey({planRecordId : this.planId})
        .then(result =>{
          console.log('result >> '+ JSON.stringify(result));
          //this.refreshCard();
          this.checkplanteamforCSA = result;         
          if(this.checkplanteamforCSA)
          {
              if(this.showSendCSTSurvey) 
              {    
                  updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'CST_SURVEY'})
                  .then(result =>{
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Success",
                        message: "CSA survey has been sent!",
                        variant: "success"
                      })
                    );
                    this.updateEngSurveyFlag();//<T02>
                    this.refreshCard();
                  })
                  .catch(error=>{
                    objUtilities.processException(error, objParent);
                  })
                  
              } else{
                  updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'CST_SURVEY'})
                  .then(result =>{
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: "Success",
                        message: "CSA survey has been resent!",
                        variant: "success"
                      })
                    );
                    this.updateEngSurveyFlag();//<T02>
                  })
                  .catch(error=>{
                    objUtilities.processException(error, objParent);
                  })
              }                           
        }else {
          console.log('ERROR'+'else');
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error ",
              message: "Please add Plan Contact with the role 'Technical Contributor' or 'Technical Owner' before Sending the Survey. ",
              variant: "Error"
            })
          );
            }
    
        })
        .catch(error=>{
          objUtilities.processException(error, objParent);
        })
        break;
       //</T01>

       //<T02> start
      case "ResendMFASurvey":
        CheckPlanContactforMFASurvey({planRecordId : this.planId})
          .then(result =>{
            console.log('result >> '+ JSON.stringify(result));
            //this.refreshCard();
            this.checkplanteamforMFA = result;
            if(this.checkplanteamforMFA)
            {
                if(this.showSendMFASurvey) 
                {    
                    updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'MFA_SURVEY'})
                    .then(result =>{
                      this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Success",
                          message: this.label.MFASuccessSendMsg,
                          variant: "success"
                        })
                      );
                      this.updateEngSurveyFlag();//<T02>
                      this.refreshCard();
                    })
                    .catch(error=>{
                      objUtilities.processException(error, objParent);
                    })
                    
                } else{
                    updateSurveyFlagOnPlanContact({ planList: planIds,surveyType:'MFA_SURVEY'})
                    .then(result =>{
                      this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Success",
                          message: this.label.MFASuccessResendMsg,
                          variant: "success"
                        })
                      );
                      this.updateEngSurveyFlag();//<T02>
                    })
                    .catch(error=>{
                      objUtilities.processException(error, objParent);
                    })
                }                           
          }else {
            console.log('ERROR'+'else');
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error ",
                message: "Please add Plan Contact with the role 'Technical Contributor' or 'Technical Owner' before Sending the Survey. ",
                variant: "Error"
              })
            );
              }
      
          })
          .catch(error=>{
            objUtilities.processException(error, objParent);
          })
          break;
         //</T02> end
          
      
    }
  }

  //<T02> start
  /*
  Method Name : updateEngSurveyFlag
  Description : This method is called when eng survey is sent to update the flag on eng to true
  Parameters	: None
  Return Type : None
  */
  updateEngSurveyFlag(){
    let engSurveyFlagStatus = false;

    if(this.recType == 'CSA'){
      engSurveyFlagStatus = getFieldValue(this.engRecType.data, ENG_CSA_SURVEY_STATUS);
    }else if(this.recType == 'MFA'){
      engSurveyFlagStatus = getFieldValue(this.engRecType.data, ENG_MFA_SURVEY_STATUS);
    }

    if(engSurveyFlagStatus == false){
      updateSurveyFlagOnEng({ engRecId: this.strEngRecordId, engRecType : this.recType})
      .then(result =>{
        this.refreshCard();
      })
      .catch(error =>{
        console.log('unable to update the eng survey flag', error);
      })
    }
  }
  //</T02> end

}