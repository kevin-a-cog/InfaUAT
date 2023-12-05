import { LightningElement,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getECActions from '@salesforce/apex/EngagementCatalogueController.getECActions';
import getAEMParameterDetails from '@salesforce/apex/EngagementCatalogueController.getAEMParameterDetails';
import isEUPresent from '@salesforce/apex/EngagementCatalogueController.isEUPresent';
import createCSAEngagement from '@salesforce/apex/EngagementCatalogueController.createCSAEngagement';
import getUserDetails from '@salesforce/apex/EngagementCatalogueController.getUserDetails';
import getECUrl from '@salesforce/apex/EngagementCatalogueController.getECUrl';
import hasActiveExternalPlan from '@salesforce/apex/EngagementCatalogueController.hasActiveExternalPlan';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';

import EC_EUNotPresentErrorMsg from '@salesforce/label/c.EC_EUNotPresentErrorMsg';
import EC_HasNoActiveExternalPlanMsg from '@salesforce/label/c.EC_HasNoActiveExternalPlanMsg';
import EC_SuccessEngagementMsg from '@salesforce/label/c.EC_SuccessEngagementMsg';
import EC_EngCreationFailedTitleMsg from '@salesforce/label/c.EC_EngCreationFailedTitleMsg';
import EC_EngCreationFailedBodyMsg from '@salesforce/label/c.EC_EngCreationFailedBodyMsg';

export default class EngagementItemParentContainer extends NavigationMixin(LightningElement) {
	
    @track actions;
    @track questionsList;
    EUAvailable;
    EUNotAvailable;
    EngagementType = 'Success';
    uploadedFiles = [];
    contactId;
    hasExternalPlanAccess;
    hasNoExternalPlanAccess;
    planId='';
    accountId;
    timezone;
    timeZoneSIDKey;
    @track userDetails;
    isLoading = true;
    @track actionsData;
    engagementUnit;
    isInternalEngagement;
    milestoneId;
    ECUrlLink;
    label = {EC_EUNotPresentErrorMsg, EC_HasNoActiveExternalPlanMsg,EC_SuccessEngagementMsg,EC_EngCreationFailedTitleMsg,EC_EngCreationFailedBodyMsg};
    

    connectedCallback(){
        let urlParams = new URLSearchParams(decodeURIComponent(window.location.search));
        this.EC_AEMUrl = urlParams.get('engagementId');
        this.planId = urlParams.get('planId');
        this.milestoneId = urlParams.get('milestoneId');
        console.log('this.planId ', this.planId);
    }
    
    /*
	 Method Name : uploadFiles
	 Description : This method gets the uploaded files from child component
	 Parameters	 : event.
	 Return Type : None
	 */
    uploadFiles(event){
        this.uploadedFiles = event.detail.message;
    }

    /*
	 Method Name : displayForm
	 Description : This method displays the question form when EU and contact has external active plan
	 Parameters	 : none
	 Return Type : Boolean
	 */
    get displayForm(){
        return this.EUAvailable && this.hasExternalPlanAccess;
    }

    /*
	 Method Name : displaySingleError
	 Description : This method displays the external active plan error message if both EU & active plan error
	 Parameters	 : none
	 Return Type : Boolean
	 */
    get displaySingleError(){
        return this.EUNotAvailable && this.hasNoExternalPlanAccess;
    }

    @track
    EC_AEMUrl='';
    
    @wire(hasActiveExternalPlan, {idContact:'$contactId',idPlan:'$planId'})
    wiredhasActiveExternalPlan({data, error}){
        if(data == true){
            this.hasExternalPlanAccess = true;
        }else if(data == false){
            this.hasNoExternalPlanAccess = true;
        }
        else if (error) {
            console.log('hasActiveExternalPlan error ', error);
        }
    }


    @wire(getUserDetails)
    wiredGetUserDetails({data, error}){
        if(data){
            this.userDetails = data;
            console.log('this.userDetails ',this.userDetails);
            this.accountId = data.Contact.AccountId;
            this.contactId = data.ContactId;
            this.timeZoneSIDKey = data.TimeZoneSidKey;
            if(data.Contact.TimeZone_Lookup__c){
                this.timezone = data.Contact.TimeZone_Lookup__r.Timezone__c;
            }
        }
        else if (error) {
            console.log('feteching of user details from okta user id has failed' , error);
        }
    }

    EC_AEMdata;

    @wire(getAEMParameterDetails, {engagementId:'$EC_AEMUrl'})
    wiredAEMDetails({data, error}){
        if(data){
            this.EC_AEMdata = JSON.parse(JSON.stringify(data));
            this.EC_AEMdataDuplicate = this.EC_AEMdata;
            this.engagementUnit = this.EC_AEMdata.engagementUnit;
            this.isInternalEngagement = this.EC_AEMdata.isInternalEngagement;
            console.log('this.EC_AEMdata ' , this.EC_AEMdata);
        }
        else if (error) {
            console.log('getAEMParameterDetails error ', error);
        }
    }

    @wire(getECActions, {actionId:'$EC_AEMdata.engagementActionId'})
    wiredActionWrapper({data, error}){
        if(data){
            this.actionsData = data;
            this.actionLabel = data.label;
            this.questionsList = data.questions;
            this.isLoading = false;
        }
        else if (error) {
            console.log('getECActions error ', error);
            this.isLoading = false;
        }
    }


    @wire(isEUPresent, {idAccount:'$accountId',strType:'$EngagementType',EC_AEMData:'$EC_AEMdata'})
    wiredIsEUPresent({data, error}){
        if(data == true){
            this.EUAvailable = true;
        }else if(data == false){
            console.log('EU have been exhausted');
            this.EUNotAvailable = true;
            this.isLoading = false;
        }
        else if (error) {
            console.log('checking of EU points has failed' , error);
            this.isLoading = false;
            this.questionsList = undefined;
        }
    }

    @wire(getECUrl, {EC_AEMData:'$EC_AEMdata'})
    wiredgetECUrl({data, error}){
        if(data){
            this.ECUrlLink = data;
        }
        else if (error) {
            console.log('fetching of EU Url has failed' , error);
        }
    }

    /*
	 Method Name : handleSave
	 Description : This method gets called on click of save button and validates all required fields and create the Engagement record
	 Parameters	 : None
	 Return Type : None
	*/
    handleSave(){
        var allChildren = this.template.querySelectorAll('c-engagement-item-child-component');
        var eachAns;
        let allAnswers = [];
        let isValid = true;
        allChildren.forEach(eachChild =>{
            let isEachAnsValid = eachChild.validateInputFields();
            if(!isEachAnsValid){
                isValid = false;
            }
            eachAns = eachChild.getAnswer();
            allAnswers.push(eachAns);
        });
        if(isValid){
            this.createRecord(allAnswers);
        }
    }

    /*
	 Method Name : createRecord
	 Description : This method will call the createCSAEngagement method which creates the record
	 Parameters	 : allAnswers, The responses given by user
	 Return Type : None
	*/
    createRecord(allAnswers){
        this.isLoading = true;
        if(this.actionsData.sobjectAPIName == 'Engagement__c'){//how to know which Engagement type needs to be created?(like CSA/IPS etc)
            this.createCSAEngagement(allAnswers);
        }
    }

    /*
	 Method Name : createCSAEngagement
	 Description : This method will create the engagement record
	 Parameters	 : allAnswers, The responses given by user
	 Return Type : None
	*/
    createCSAEngagement(allAnswers){
        createCSAEngagement({idAccount:this.accountId,idContact:this.contactId,idPlan:this.planId,timezone:this.timezone,timeZoneSIDKey:this.timeZoneSIDKey,ecActions:this.actionsData,EC_AEMData:this.EC_AEMdataDuplicate,EC_userResponses:allAnswers,uploadedFileIds:this.uploadedFiles})
        .then(result => {
            if(result == true){
            this.isLoading = false;
                this.handleSuccessClick(this.label.EC_SuccessEngagementMsg);
            }else if(result == false) {
                this.creationOfEngFailed(this.label.EC_EngCreationFailedBodyMsg);
            }
            
        })
        .catch(error => {
            this.creationOfEngFailed(error);
        });
    }

    creationOfEngFailed(error){
            console.log('creation of engagement failed ' , error);
            this.isLoading = false;
            let event = new ShowToastEvent({
            title: this.label.EC_EngCreationFailedTitleMsg,
                message: error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
    }

    /*
	 Method Name : navigateToMySuccessPlanDetailsPage
	 Description : This method will redirect the page to My success page if the Engagement units are not available
	 Parameters	 : None
	 Return Type : None
	*/
    navigateToMySuccessPlanDetailsPage(){
        let urlToNavigate = '/s/plan-details';
        if(this.planId){
            urlToNavigate = '/s/plan-details?planid='+this.planId;
        }
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: urlToNavigate
                //url: '/success/s/plan-details'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl,'_top');
        });
    }

    /*
	 Method Name : handleCancel
	 Description : This method will be called on click of cancel button - redirects to Engagement details page
	 Parameters	 : None
	 Return Type : None
	*/
    handleCancel(){
        this.navigateToMySuccessPlanDetailsPage();
    }

    handleBack(){
        window.history.back();
    }

    /*
	 Method Name : handleSuccessClick
	 Description : This method will display the success message
	 Parameters	 : String - successMsg
	 Return Type : None
	*/
    async handleSuccessClick(successMsg) {
        await LightningAlert.open({
            message: successMsg,
            theme: 'success',
            label: 'Success!',
        });
        this.navigateToMySuccessPlanDetailsPage();
    }

}