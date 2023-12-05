import { LightningElement,wire,api, track} from 'lwc';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';
import fetchOverViewData from '@salesforce/apex/SpOverviewController.fetchOverViewData';

export default class SpOverview extends LightningElement {

	//Private variables.
	boolChart1Loaded = false;
	boolChart2Loaded = false;
	boolChart3Loaded = false;
	boolDisplaySpinner = true;

    imgLoaded = false;
    showKnowAboutMeLink = true;
    guageMeterDisplay = 'sp-plan__statistics-img-value slds-hide';

    @api recordId;
  
    csmProfilePicture = sp_resource + '/spResource/images/csm_dp.png';
    mailIcon = sp_resource + '/spResource/icons/envelope.png';
    planHealthLow = sp_resource + '/spResource/images/gmeter_plan_health_low.png';
    planHealthMedium = sp_resource + '/spResource/images/gmeter_plan_health_medium.png';
    planHealthHigh = sp_resource + '/spResource/images/gmeter_plan_health_high.png';
    productHealthLow = sp_resource + '/spResource/images/gmeter_prod_health_low.png';
    productHealthMedium = sp_resource + '/spResource/images/gmeter_prod_health_medium.png';
    productHealthHigh = sp_resource + '/spResource/images/gmeter_prod_health_high.png';
    activeEngagementPassive = sp_resource + '/spResource/images/gmeter_active_eng_passive.png';
    activeEngagementModerate = sp_resource + '/spResource/images/gmeter_active_eng_moderate.png';
    activeEngagementHigh = sp_resource + '/spResource/images/gmeter_active_eng_high.png';

    @track overviewData = {};
    @track sPlanHealthVal = '';
    @track sProductHealthVal = '';
    @track ActiveEngagements = '';
    
    renderedCallback() {
       
    }

    @wire(fetchOverViewData, { 'sPlanId': '$recordId'})
    overviewData({error,data}){
        if(data){ 
            this.overviewData = {};
            this.sPlanHealthVal = '';
            this.sProductHealthVal = '';
            this.ActiveEngagements = '';
            /* {"sPlanHealthLevel":"High",
                "sPlanOwnerDisplayPic":"/success/profilephoto/005/T",
                "sPlanOwnerEmail":"rahulgupta@informatica.com.invalid",
                "sPlanOwnerName":"rahulgupta1.5510993160899023E12"}
            */
            console.log('fetchOverViewData data ===> ' + JSON.stringify(data));        
             let overviewTempData = JSON.parse(JSON.stringify(data));
             overviewTempData.sPlanOwnerEmailTo  = 'mailto:' + overviewTempData.sPlanOwnerEmail;
             this.csmProfilePicture = overviewTempData.sPlanOwnerDisplayPic;
             this.sPlanHealthVal = overviewTempData.sPlanHealthLevel;
             this.sProductHealthVal = overviewTempData.sProductHealthLevel;
             this.ActiveEngagements = overviewTempData.sActiveEngagements;
             this.overviewData = overviewTempData;
             if (this.overviewData.sPlanOwnerAboutMe == '' || this.overviewData.sPlanOwnerAboutMe == undefined){
                this.showKnowAboutMeLink = false;
            }
            else {
                this.showKnowAboutMeLink = true;
            }
        } else{
            console.log('error from fetchOverViewData====> ' + JSON.stringify(error));
        }
    }


    get planHealthScore() {
        let planHealthVal = this.sPlanHealthVal;;
        if (planHealthVal == 'Red') {
            return this.planHealthLow;
        }
        else if (planHealthVal == 'Yellow') {
            return this.planHealthMedium;
        }
        else if (planHealthVal == 'Green') {
            return this.planHealthHigh;
        }
        else{
            return this.planHealthHigh;
        }
    }
    get productHealthScore() {
        let productHealthVal = this.sProductHealthVal;
        if (productHealthVal == 'Good'){
            return this.productHealthHigh ;
        }
        else if (productHealthVal  == 'Average') {
            return this.productHealthMedium;
        }
        else if (productHealthVal == 'Poor') {
            return this.productHealthLow;
        }
        else{
            return this.productHealthHigh ;
        }
    }

    get activeEngagementScore() {
        let activeEngagementVal = this.ActiveEngagements;
        if (activeEngagementVal  == 'Passive') {
            return this.activeEngagementPassive;
        }
        else if (activeEngagementVal == 'Moderate') {
            return this.activeEngagementModerate;
        }
        else if (activeEngagementVal == 'High') {
            return this.activeEngagementHigh;
        }
    }
	/*
	 Method Name : loaded
	 Description : This method removes the spinner once everything has been loaded.
	 Parameters	 : Object, called from loaded, objEvent Event.
	 Return Type : None
	 */
	loaded(objEvent) {
		let objParent = this;
		switch(objEvent.currentTarget.dataset.element) {
			case "1":
				objParent.boolChart1Loaded = true;
			break;
			case "2":
				objParent.boolChart2Loaded = true;
			break;
			case "3":
                objParent.boolChart3Loaded = true;
				this.guageMeterDisplay = objParent.boolChart3Loaded ? 'sp-plan__statistics-img-value slds-show' : 'sp-plan__statistics-img-value slds-hide';
			break;
		}
		if(objParent.boolChart1Loaded && objParent.boolChart2Loaded && objParent.boolChart3Loaded) {
			objParent.boolDisplaySpinner = false;
		}
       
	}
}