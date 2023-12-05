/*
 * Name         :   SpPlanDetails
 * Author       :   
 * Created Date :   
 * Description  :   

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************     
 Chaitanya T            24-Oct-2023     AR-3467             Removing the default filter based on stage                <T01>
 */
import { LightningElement, wire, track, api } from 'lwc';
import fetchAllPlansForCurrentUser from '@salesforce/apex/spPlanDetailsController.fetchAllPlansForCurrentUser';
import makePlanFav from '@salesforce/apex/spPlanDetailsController.makePlanFav';
import fetchPlanDetail from '@salesforce/apex/spPlanDetailsController.fetchPlanDetail';
import fetchPlanDetailnoncache from '@salesforce/apex/spPlanDetailsController.fetchPlanDetailnoncache';


import checkSignOffStatus from '@salesforce/apex/spPlanDetailsController.checkSignOffStatus';
import updateObjectiveSignOff from '@salesforce/apex/spPlanDetailsController.updateObjectiveSignOff';
import fetchAllSignOffObjecives from '@salesforce/apex/spPlanDetailsController.fetchAllSignOffObjecives';
import planControlAccessInfo from '@salesforce/apex/spPlanDetailsController.planControlAccessInfo';
import fetchPicklistData from '@salesforce/apex/spPlanDetailsController.fetchPicklistData';
import fetchPlanRelatedDetail from '@salesforce/apex/spPlanDetailsController.fetchPlanRelatedDetail';
import lookupCombinedSearch from '@salesforce/apex/spPlanDetailsController.lookupCombinedSearch';
import createRiskPlanComment from '@salesforce/apex/spPlanDetailsController.createRiskPlanComment';
import createContactYourCsm from '@salesforce/apex/spPlanDetailsController.createContactYourCsm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import isGuestUser from '@salesforce/user/isGuest';
import CSMLoginUrl from '@salesforce/label/c.CSMLoginUrl'; 
import AEMEngagementCatalogURL from '@salesforce/label/c.AEMEngagementCatalogURL'; 
import EcButtonLabel from '@salesforce/label/c.EC_Success_ButtonLabel'; 

//Core libraries.
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import doesPlanHasCasesRelatedToItsSupportAccount from '@salesforce/apex/spPlanDetailsController.doesPlanHasCasesRelatedToItsSupportAccount';
import getTimeZoneValues from "@salesforce/apex/GlobalSchedulerController.getTimeZoneValues";
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

const signOffcolumns = [
    { label: 'Name', fieldName: 'Name' }, 
    { label: 'Planned Completion Date', fieldName: 'CSM_Planned_Completion_Date__c' },  
    { label: 'Status', fieldName: 'Status__c' }
];

export default class SpPlanDetails extends NavigationMixin(LightningElement){

	//Track variables.
	@track boolDisplaySpinner = false;
    @track strSuccessPlanSignOffComment = '';
	@track objParameters = {
		strTableId: "1",
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolForceCheckboxes: true
	};
	@track lstUploadedFiles = [];
	@track lstUploadedFileIds = [];

	//Private variables.
	strCurrentUserTimezone = TIME_ZONE;
    selectedReasonMap={}; //added as part of AR-2754
	lstTimeZones;

    accountLogo = sp_resource + '/spResource/images/account_gen_dp.svg';
    @track isMultiplePlans = false;
    @track buttonClicked = true;
    @track iconName = 'utility:down';
    @track className = 'sp-plan__content slds-show';
    @track showMakeFavSpinner = false;
    @track bShowSignOff = false;
    signOffcolumns = signOffcolumns;

    // plan detail access control 
    @track bhasSignOffAccess = false;
    @track bhasManageContactsAccess = false;
    @track bhasObjectivesandMilestonesAccess = false;
    
    @track bShowCreateRiskModal = false;
    @track createRiskComments = '';
    @track reasonPicklistData = [];
    @track selectedReason = [];
    @track riskCreateCaseId = undefined;
    @track bShowCaseLookupForCreateRisk = false;
    @track isCreateRiskConfirmedModal = false;
    @track bShowCsmObjectivesAndMilestones = true;
    @track bshowFileTable = false;
    @track planvalue = '';
    @track productAdoptionQueriesReasonValue = '';
    @track productAdoptionQueriesComment = '';

    @track discussNewInitiativesReasonValue = '';
    @track discussNewInitiativesComment = '';
    
    @track RequestBusinessDatetimeValue = '';
    @track RequestBusinessComments = '';

    catalogbuttonLabel = EcButtonLabel;
    
    /* Jump Tabs */
    renderedCallback() {
        try { 
            window.onscroll = () => {
                let scrollY = window.pageYOffset;
                let sections = this.template.querySelectorAll('section[data-id]');
                sections.forEach(current => {
                    const sectionHeight = current.offsetHeight;
                    const sectionTop = current.offsetTop - 270;
                    let sectionId = current.getAttribute('data-id');
                    if (
                    scrollY > sectionTop &&
                    scrollY <= sectionTop + sectionHeight
                    ){ 
                       let url = new URL(window.location);
                       url.searchParams.set('section_target', `${sectionId}`);
                       window.history.pushState({}, '', url);
                       this.template.querySelector(`[data-target-id="${sectionId}"]`).classList.add('sp-button-tab--active');
                    } else {
                        this.template.querySelector(`[data-target-id="${sectionId}"]`).classList.remove('sp-button-tab--active');
                    }
                });
            }
        } catch (error) {
            console.log('error =>', error);
        }
    }
    
    handleClick(event) {
        let targetTabId = event.currentTarget.dataset.targetId;
        let targetTabDiv = this.template.querySelector(`[data-id="${targetTabId}"]`);
        //let clickedTabDiv = this.template.querySelector(`[data-target-id="${targetTabId}"]`);
        // this.template.querySelector('.sp-button-tab--active').classList.remove('sp-button-tab--active');
        // clickedTabDiv.classList.add('sp-button-tab--active');
        let tempScrollTop = window.scrollTo({
            /*Fixed plan switcher+tab section */
            top: targetTabDiv.offsetTop - 266,
            /*Non fixed plan switcher+tab section */
            //top: targetTabDiv.offsetTop - 100,
            behavior: "smooth",
        })
    }

    
    @api recordId;
    isPoppedOut = false;
    popOut(objEvent) {
        this.isPoppedOut = objEvent.detail.boolIsPopingOut;
    }

    /*** Plan dropdown ***/
    @track allPlans = [];
    @track supportAccounts = [];
    @track planRecord;
    @track bShowPlanDropDown = false;
    selectedSignOffObjectives = [];
    
    onfavHandler(event){
     this.showMakeFavSpinner = true;
     var objSelectedPlan = event.detail;
     
     var isSelected = false;
      if(objSelectedPlan.state == 'warning'){
        isSelected = false;
      }else{
        isSelected = true;
      }
        /** START-- adobe analytics */
        try {
            util.trackFavAccount();
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
      makePlanFav({'planConId' : objSelectedPlan.planConId, 'favValue' : isSelected})
      .then(result => {
          this.showMakeFavSpinner = false;
          
          if(isSelected){
            this.showNotification('Success!','Plan has been successfully marked as favorite.' , 'success');
          }
          else{
            this.showNotification('Success!','Plan has been successfully removed as favorite.' , 'success');
          }
      })
      .catch(error => {
        
          this.showNotification('Error!', JSON.stringify(error) , 'error');
          this.error = error;
      }); 
   
      //{"planConId":"a6R010000004HETEA2","state":""}
      //alert('Popup'); 
    }

    signOffPlanHandler(){
        
		let objParent = this;
		objParent.boolDisplaySpinner = true;
        
        var lstObjIds = [];
        if(objUtilities.isBlank(this.strSuccessPlanSignOffComment)) {
			this.showNotification('Required fields missing', 'Add Additional Comments', 'error');            
		    objParent.boolDisplaySpinner = false;
		} else {
        for(var i=0; i < this.selectedSignOffObjectives.length; i++){
            lstObjIds.push(this.selectedSignOffObjectives[i].Id);
        }

        updateObjectiveSignOff({'lstObjectiveToSignOff' : lstObjIds, 'selectedPlanId': this.recordId, "strComments": this.strSuccessPlanSignOffComment, "lstFileIds": this.lstUploadedFileIds})
        .then(result => {                        
            this.showNotification('Success!','Selected objective successfully signed off.' , 'success');
            this.closeSignoffModal();
            this.processRecords(result);
            this.template.querySelector('c-sp-plan-comments').refreshPlanComments();
        })
        .catch(error => {
            
            this.showNotification('Error!', JSON.stringify(error) , 'error');
         //   this.error = error;
        }).finally(() => {
            objParent.boolDisplaySpinner = false;
            
			
		}); 
         /** START-- adobe analytics */
         try {
            util.trackButtonClick("Sign off confirm");
        }
        catch(ex) {
            log(ex.message);
        }
    }
        /** END-- adobe analytics*/
    }

    @wire(fetchPicklistData, { 'objObject': 'Plan_Comment__c', 'fld' : 'Customer_Risk_Reason__c'})
    picklistData({error,data}){
        if(data){
            
            this.reasonPicklistData = data;            
        }else{
            console.log('error from fetchPicklistData====> ' + JSON.stringify(error));
        }       
    }

    @wire(fetchPlanRelatedDetail, { 'sPlanId': '$recordId'})
    planDetaildata({error,data}){
        if(data){                      
            this.bShowCaseLookupForCreateRisk = data.bPlanContactSameAsSupportContact;
        }else{
            console.log('error from fetchPlanRelatedDetail====> ' + JSON.stringify(error));
        }       
    }

    handleCombinedLookupSearch(event) {
        const lookupElement = event.target;
        let objParent = this;
        let details = event.detail;
          
		//Now we check if the Support Account has Cases related.  
		lookupElement.setNoRecordsFoundMessage("");
        doesPlanHasCasesRelatedToItsSupportAccount({
            'strPlanId' : objParent.recordId
        }).then(boolResult => {
			if(boolResult) {

				//Now we do the actual search.
				lookupCombinedSearch({
					'searchTerm' : details.searchTerm,
					'selectedIds': details.selectedIds,
					'sPlanId' : objParent.recordId
				}).then(results => {
					lookupElement.setNoRecordsFoundMessage("No results.");
					lookupElement.setSearchResults(results);
				}).catch(objError => {
					objUtilities.processException(objError, objParent);
				});
			} else {
				lookupElement.setNoRecordsFoundMessage("Please create the Case in Customer Support");
				lookupElement.setSearchResults([]);
			}
        }).catch(objError => {
			objUtilities.processException(objError, objParent);
        });
    }

    handleCombinedLookupSelectionChange(event) {
        this.riskCreateCaseId = event.detail.values().next().value;   
    }

    handleReasonChange(e){
        //Added as part of AR-2754 Starts here
        this.selectedReason = e.detail.value;
        let selectLabel = this.selectedReason.map(option => this.reasonPicklistData.find(o => o.value === option).label);
        let count=0;
        let selectedReasonMapIn={};
        for(let i=0;i<selectLabel.length;i++){ 
            selectedReasonMapIn[e.detail.value[i]]=selectLabel[i];//map of value=label
            count++;
        }   
        this.selectedReasonMap=selectedReasonMapIn;
        //Added as part of AR-2754 ends here
    }

    @wire(fetchAllPlansForCurrentUser)
    plans({error,data}){
        if(data){
            if(data.length > 0){    
            var plansData = JSON.parse(JSON.stringify(data));
            var lstAccountoptions = [];
            var hasFavourite = false;
            var favPlanId ;
            var defaultPlan = [] ;

            // plan Id from URL 
            let url = new URL(window.location.href);
            let planId = url.searchParams.get("planid");
            let tabid = url.searchParams.get("tabid");
             
            var planFromUrl = undefined;           
            let planAccesible=false;
            for(var i=0; i < plansData.length;i++ ){
                var obj = {
                    "label": plansData[i].Plan__r.Name ,
                    "value": plansData[i].Plan__c,
                    "PlanContactId" : plansData[i].Id  ,
                    'isBlnSUpportAccFav' :  plansData[i].Is_Favourite__c                    

                  };

                if(planId != null && plansData[i].Plan__c == planId ){
                    planAccesible=true;                    
                    planFromUrl = obj;
                }
              
                if(plansData[i].Is_Favourite__c){
                    hasFavourite = true;
                    favPlanId = plansData[i].Plan__c;
                    defaultPlan.push(obj);
                }                
                lstAccountoptions.push(obj);
            }      
            if(!planAccesible){
                planFromUrl = undefined;
                planId = null;
            }  
            //this.allPlans = lstAccountoptions;
            this.allPlans = lstAccountoptions.sort((a, b) => (a.label.toLowerCase() > b.label.toLowerCase()) ? 1 : -1);
                      
            this.getPlanInfo(this.allPlans[0].label);
           
             /*2738-start*/
             if (sessionStorage.getItem("getPlanId") != null) {
                let getPlanId = sessionStorage.getItem("getPlanId");
                let getIndex = this.allPlans.findIndex(object => {
                    return object.value === getPlanId;
                });
                this.supportAccounts = [this.allPlans[getIndex]];
            } else {
                this.supportAccounts = [this.allPlans[0]];
            }
              /*2738-end*/

            if(favPlanId != undefined && planId == null){
                 /*2738-start*/
                if (sessionStorage.getItem("getPlanId") != null) {
                    let getPlanId = sessionStorage.getItem("getPlanId");
                    let getIndex = this.allPlans.findIndex(object => {
                        return object.value === getPlanId;
                    });
                    this.recordId = getPlanId;
                    if(planId == null){
                        this.supportAccounts = [this.allPlans[getIndex]];
                    }
                } else {
                    this.recordId = favPlanId;
                    if(planId == null){
                        this.supportAccounts = defaultPlan;
                    }
                }
                //if(planId == null){
                    // this.supportAccounts = defaultPlan;
                //} 
                /*2738-end*/
            }
            if((plansData.length == 1 || hasFavourite == false) && planId == null){
                /*2738-start*/
                if (sessionStorage.getItem("getPlanId") != null) {
                    let getPlanId = sessionStorage.getItem("getPlanId");
                    let getIndex = this.allPlans.findIndex(object => {
                        return object.value === getPlanId;
                    });
                    this.recordId = plansData[getIndex].Plan__c;
                }
                else if(hasFavourite == false && plansData.length >1) {//AR-2984 start
                    this.recordId = this.allPlans[0].value;
                }//AR-2984 end
                else {
                    this.recordId = plansData[0].Plan__c;
                }
                /*2738-end*/
            }

            if(planFromUrl==undefined){
                planId=this.recordId;
                let index = this.allPlans.findIndex(object => {
                    return object.value === this.recordId;
                });
                planFromUrl=this.allPlans[index];
            }
            
            if(planId != null){
               defaultPlan = [];
                setTimeout(() => {   
                    this.recordId = planId;    
                    if(planFromUrl != undefined){
                        this.planvalue = planFromUrl.label;
                        defaultPlan.push(planFromUrl);
                    }
                    this.supportAccounts = defaultPlan;                                      
                    this.bShowPlanDropDown = true;
                }, 
                    2000);
            }else{
                this.bShowPlanDropDown = true;
            }
            
            this.bshowFileTable = true;
            //   this.template.querySelector('c-sp-file-data-table').filesDataHelper();
        }
        else{
            this.allPlans = [];
            this.bShowPlanDropDown = true;
        }
           
        }else{
            console.log('error from fetchAllPlansForCurrentUser====> ' + JSON.stringify(error));
        }       
    }

    getPlanInfo(){
        if (this.allPlans.length == 1){
            this.isMultiplePlans = false;
        }else{
            this.isMultiplePlans = true;
        }
        var planNameObj1=this.allPlans[0].label;
        this.planToDisplay = planNameObj1;
    }
    
    updatePlanHandler(event){
       this.recordId = event.detail.value;
       /*2738-start*/
        var getPlanId = this.recordId;
        sessionStorage.setItem("getPlanId", getPlanId);
       /*2738-end*/
       this.bShowCsmObjectivesAndMilestones = false;
       this.planupdatehandle();
       getRecordNotifyChange([{recordId: this.recordId}]);
      // window.history.replaceState(null, null, "?planid=" + this.recordId);
      /*27042022*/
    //   const url = new URL(window.location);
    //   url.searchParams.set('planid', event.detail.value);
    //   window.history.pushState({}, '', url);
        /** START-- adobe analytics */
        try {
            util.trackButtonClick("Plan change dropdown");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/

       setTimeout(() => {   
        this.template.querySelector('c-sp-contact-data-table').fetchContactHelper();
        this.template.querySelector('c-sp-file-data-table').filesDataHelper();
        this.template.querySelector('c-sp-plan-comments').refreshPlanComments();
        this.bShowCsmObjectivesAndMilestones = true;
        
    }, 
        1000);
    }


    fileDataRefresh(event){
        
        this.template.querySelector('c-sp-file-data-table').filesDataHelper();
    } 

    @wire(checkSignOffStatus, { selectedPlanId: '$recordId'})
    signOffStatus ({ error, data }) {
        if (data) {
			this.processRecords(data);
        } else if (error) {
            console.log('Error in checkSignOffStatus' + JSON.stringify(error));
        } 
    }

    @wire(planControlAccessInfo, { selectedPlanId: '$recordId'})
    planControlAccessData ({ error, data }) {
        if (data) {                       
            //{"hasManageContactsAccess":true,"hasObjectivesandMilestonesAccess":true,"hasSignOffAccess":true} 
            this.bhasManageContactsAccess  = data.hasManageContactsAccess;
            this.bhasObjectivesandMilestonesAccess  = data.hasObjectivesandMilestonesAccess;
            this.bhasSignOffAccess  = data.hasSignOffAccess;
        } else if (error) {
            console.log('Error in planControlAccessInfo' + JSON.stringify(error));
        } 
    } 

    @wire(fetchPlanDetail, { recordId: '$recordId'})
    planObj ({ error, data }) {
        if (data) {
            this.planRecord = JSON.parse(JSON.stringify(data));
            this.planId = data.Id;
            const url = new URL(window.location);
            url.searchParams.set('planid', this.planId);
            window.history.pushState({}, '', url);
            this.updateStatusTracker(data.Stage__c != undefined ? data.Stage__c : '');
        } else if (error) {
          console.log('Error in fetch plan record' + JSON.stringify(error));
        }
    };

    planupdatehandle(){
        fetchPlanDetailnoncache({'recordId' : this.recordId})
    .then(data => {
        
            this.planRecord = JSON.parse(JSON.stringify(data));
            this.planId = data.Id;
            const url = new URL(window.location);
            url.searchParams.set('planid', this.planId);
            window.history.pushState({}, '', url);
            this.updateStatusTracker(data.Stage__c != undefined ? data.Stage__c : '');
        }) 
        .catch(error => {
            let refferURL = window.location.href;
            let loginLink = CSMLoginUrl + "?RelayState=" + encodeURIComponent(refferURL);
            window.location.assign(loginLink);
            console.log('Error in fetch plan record' + JSON.stringify(error));
        }); 
    }
    get sPlan_Description() {
        return this.planRecord != undefined ? this.planRecord.Description__c.replaceAll('\n','</br>') : '';        
    }
    
    get sPlan_CreatedDate() {
        return this.planRecord != undefined ? this.planRecord.CreatedDate : '';        
    }

    get sPlan_LastModifiedDate() {
        return this.planRecord != undefined ? this.planRecord.LastModifiedDate : '';        
    }

    get sPlan_ClosureDate() {
        return this.planRecord != undefined ? this.planRecord.Closure_Date__c : '';        
    }

    get sPlan_Name() {
        return this.planRecord != undefined ? this.planRecord.Name : '';        
    }

    get sPlan_AccountName() {
        return this.planRecord != undefined && this.planRecord.Account__r != undefined ? this.planRecord.Account__r.Name : '';        
    }

    get sPlan_AccountId() {
        return this.planRecord != undefined ? this.planRecord.Account__c : '';        
    }

    handleToggle(event) {
        let currentDiv = event.target;
        let targetIdentity = event.target.dataset.targetId;
        let targetDiv = this.template.querySelector(`[data-section-id="${targetIdentity}"]`);
        targetDiv.buttonClicked = !targetDiv.buttonClicked;
        targetDiv.className = targetDiv.buttonClicked ? 'sp-plan__content slds-hide' : 'sp-plan__content slds-show';
        currentDiv.iconName = targetDiv.buttonClicked ? 'utility:right' : 'utility:down';
    }

    connectedCallback() {
		let objParent = this;
        let url = new URL(window.location.href);
        let planId = url.searchParams.get("planid");
        let tabId = url.searchParams.get("section_target");
        url.searchParams.set('section_target', 'overview');
        window.history.pushState({}, '', url);
        
        // if(planId != null ){
        //  //this.recordId = planId;  
        // }
        // if(tabId != null){
        //     setTimeout(() => {   
        //         this.scrollToSection(tabId);
        //     }, 
        //         2000);
        // }

		//Setting initial values.
		objParent.lstTimeZones = new Array();

		//Now we get the time zones.
		getTimeZoneValues().then((objTimeZones) => {
			Object.entries(objTimeZones).map(objTimeZone => {
				objParent.lstTimeZones.push({
					value: objTimeZone[0],
					label: objTimeZone[1]
				});
			});
		});
    }
    
    updateStatusTracker(caseStatus) {
        if (caseStatus == 'Plan') {
            this.purchaseClass = 'sp-chevron__item sp-chevron__item--current';
            this.implementClass = 'sp-chevron__item sp-chevron__item--incomplete';
            this.valueClass = 'sp-chevron__item sp-chevron__item--incomplete';
            this.scaleClass = 'sp-chevron__item sp-chevron__item--incomplete';
        } else if (caseStatus == 'Implement') {
            this.purchaseClass = 'sp-chevron__item sp-chevron__item--completed';
            this.implementClass = 'sp-chevron__item sp-chevron__item--current';
            this.valueClass = 'sp-chevron__item sp-chevron__item--incomplete';
            this.scaleClass = 'sp-chevron__item sp-chevron__item--incomplete';
        } else if (caseStatus == 'Value') {
            this.purchaseClass = 'sp-chevron__item sp-chevron__item--completed';
            this.implementClass = 'sp-chevron__item sp-chevron__item--completed';
            this.valueClass = 'sp-chevron__item sp-chevron__item--current';
            this.scaleClass = 'sp-chevron__item sp-chevron__item--incomplete';
        } else if (caseStatus == 'Scale') {
            this.purchaseClass = 'sp-chevron__item sp-chevron__item--completed';
            this.implementClass = 'sp-chevron__item sp-chevron__item--completed';
            this.valueClass = 'sp-chevron__item sp-chevron__item--completed';
            this.scaleClass = 'sp-chevron__item sp-chevron__item--current';
        } 
    }

    showNotification(stitle,msg,type) {
        const evt = new ShowToastEvent({
            title: stitle,
            message: msg,
            variant: type
        });
        this.dispatchEvent(evt);
    }
    @track isSignOffModal = false;
    openSignOffModal() {
        this.isSignOffModal = true;
        document.body.classList += ' modal-open';

        fetchAllSignOffObjecives({'selectedPlanId': this.recordId})
        .then(result => {
            this.processRecords(result);
        })
        .catch(error => {
            console.log('error==>  ' + JSON.stringify(error));
            this.showNotification('Error!', JSON.stringify(error) , 'error');
        }); 
        /** START-- adobe analytics */
        try {
            util.trackButtonClick("Sign Off Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    signoffBtn = false;

    closeSignoffModal() {
        this.isSignOffModal = false;
        this.template.querySelector('c-sp-plan-comments').refreshPlanComments();
        document.body.classList -= ' modal-open';
        this.selectedSignOffObjectives = [];
        this.signoffBtn = false;
    }

    handleRowSelected(event) {
        const selectedRows = event.detail.objPayload.detail.selectedRows;
        this.selectedSignOffObjectives = selectedRows;
        if(this.selectedSignOffObjectives.length > 0){
            this.signoffBtn = true;
        }else{
            this.signoffBtn = false;
        }
    }

    CreateRiskHelper(){
       this.bShowCreateRiskModal = true;
       document.body.classList += ' modal-open';
       this.isCreateRiskConfirmedModal = false;
       this.riskCreateCaseId = undefined;
       this.selectedReason = [];
       this.createRiskComments = '';
       /** START-- adobe analytics */
       try {
        util.trackButtonClick("Create Risk Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    createRiskConfirmBtn(){
		let objParent = this;
        var selectedReason = this.selectedReason.join(';') 
        var caseId = this.riskCreateCaseId; 
        var currentPlanId = this.recordId;
        var comments = this.createRiskComments;
        var reasonMap = JSON.stringify(this.selectedReasonMap); //added as part of AR-2754

		if(objUtilities.isBlank(comments)) {
			this.showNotification('Required fields missing', 'Add Comments', 'error');
		} else {
			objParent.boolDisplaySpinner = true;
			createRiskPlanComment({'strComments':comments, 'strCaseId' :caseId, 'strReason' : selectedReason, 'strReasonMap' :reasonMap, 'planId' : currentPlanId, "lstFileIds": this.lstUploadedFileIds})
			.then(result => {                        
			   
				// this.showNotification('Success!', 'Risk has been created successfully.' , 'success');
				this.bRiskConfimrationMsg = 'Risk has been created.';
	
				if(this.bShowCaseLookupForCreateRisk && caseId == undefined){
					this.bRiskConfimrationMsg = 'Risk has been created just create a case.';
				}
	
				this.isCreateRiskConfirmedModal = true;
				this.template.querySelector('c-sp-plan-comments').refreshPlanComments();
				this.template.querySelector('c-sp-file-data-table').filesDataHelper();
				this.closeCreateRiskModal();
				this.showNotification('Success!', 'Your request has been noted; CSM will contact you shortly.', 'success');
			})
			.catch(error => {
				console.log('error==>  ' + JSON.stringify(error));
				this.showNotification('Error!', JSON.stringify(error) , 'error');
			}).finally(() => {
				objParent.boolDisplaySpinner = false;
			});
		}
        
        /** START-- adobe analytics */
       try {
        util.trackButtonClick("Create Risk Confirm");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }

    handleCreateRiskCommentChange(event){        
      this.createRiskComments = event.target.value;
    }

    closeCreateRiskModal(){
        this.bShowCreateRiskModal = false;
        document.body.classList -= ' modal-open';
    }
    /*** Contact your csm start ***/
    get contactCsmOptions() {
        return [
            { label: 'Adoption Related Queries', value: 'Adoption Related Queries' },
            { label: 'Discuss Current Project Challenges', value: 'Discuss Current Project Challenges' },
            { label: 'Discuss New Initiatives', value: 'Discuss New Initiatives' },
            { label: 'Provide Success plan signoff', value: 'Provide Success plan signoff' },
            { label: 'Request for meeting', value: 'Request for meeting' }
        ];
    }
    get productAdoptionQueries() {
        return [
            {label:'Training and Certification related queries',value:'Training and Certification related queries'},
            {label:'Request Product roadmap review',value:'Request Product roadmap review'},
            {label:'Questions regarding Success Offerings',value:'Questions regarding Success Offerings'},
            {label:'IPU usage and analytics',value:'IPU usage and analytics'},
            {label:'Others',value:'Others'}
        ]
    }
    get currentProjectChallenges() {
        return [
            {label:'Attention Request',value:'Attention Request'}
        ]
    }
    get discussNewInitiatives() {
        return [
            {label:'Discuss New Use-cases',value:'Discuss new use-cases'},
            {label:'Add New Objective/Milestone',value:'Add new objective or milestones'},
            {label:'Others',value:'Others'}
        ]
    }
    get provideSuccessPlanSignoff() {
        return [
            {label:'Sign-off ',value:'Sign-off flow'},
        ]
    }
    selectedItemValue;
    handleSelect(event) {
        this.selectedItemValue = event.detail.value;
        this.lstUploadedFiles = [];
		this.lstUploadedFileIds = [];
        switch (this.selectedItemValue) {
            case 'Adoption Related Queries':
            this.openAdoptionRelatedQueriesModal();
            break;
            
            case 'Discuss Current Project Challenges':
            //this.openCurrentProjectChallengesModal();  
            this.CreateRiskHelper();
            break;

            case 'Discuss New Initiatives':
            this.openDiscussNewInitiativesModal(); 
            break;
            
            case 'Provide Success plan signoff':
            //this.openProvideSuccessPlanSignoffModal(); 
            this.openSignOffModal();
            break;

            case 'Request for Meeting':
            this.openRequestBusinessReviewMeetingModal(); 
            break;
            case 'NavigatetoEngagementCatalog':
            this.navigatetoEngagementCatalogPage(); 
            break;
        }
    }
    isAdoptionRelatedQueriesModal = false;
    openAdoptionRelatedQueriesModal() {
        this.isAdoptionRelatedQueriesModal = true;
        this.productAdoptionQueriesReasonValue = '';
        this.productAdoptionQueriesComment = '';
        document.body.classList += ' modal-open';
        
        /** START-- adobe analytics */
        try {
            util.trackButtonClick("Adoption Related Queries Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }
    closeAdoptionRelatedQueriesModal() {
        this.isAdoptionRelatedQueriesModal = false;
        document.body.classList -= ' modal-open';
    }

    isDiscussNewInitiativesModal = false;
    openDiscussNewInitiativesModal() {
        this.isDiscussNewInitiativesModal = true;
        document.body.classList += ' modal-open';
        this.discussNewInitiativesReasonValue = '';
        this.discussNewInitiativesComment = '';
        /** START-- adobe analytics */
         try {
            util.trackButtonClick("Discuss New Initiatives Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }
    closeDiscussNewInitiativesModal() {
        this.isDiscussNewInitiativesModal = false;
        
        document.body.classList -= ' modal-open';
        
    }

    isRequestBusinessReviewMeetingModal = false;
    openRequestBusinessReviewMeetingModal() {
        this.isRequestBusinessReviewMeetingModal = true;
        this.RequestBusinessDatetimeValue=null;
        this.RequestBusinessComments='';
        document.body.classList += ' modal-open';
        /** START-- adobe analytics */
        try {
            util.trackButtonClick("Request Business Review Meeting Modal");
        }
        catch(ex) {
            log(ex.message);
        }
        /** END-- adobe analytics*/
    }
    closeRequestBusinessReviewMeetingModal() {
        this.isRequestBusinessReviewMeetingModal = false;
        document.body.classList -= ' modal-open';
    }
    /***Contact your csm end ***/

     valueChangeHandler(event){
         var whichField = event.target.name;
         if(whichField == 'productAdoptionReason_Name'){
            this.productAdoptionQueriesReasonValue = event.target.value;  
         }
         else if(whichField == 'productAdoptioncommentBody_Name'){
            this.productAdoptionQueriesComment = event.target.value;
         }
         else if(whichField == 'discussNewInitiativesReasonName'){
            this.discussNewInitiativesReasonValue = event.target.value;
         }
         else if(whichField == 'discussNewInitiativesCommentName'){
            this.discussNewInitiativesComment = event.target.value;
         } 
         else if(whichField == 'RequestBusinessDatetimeName'){
            this.RequestBusinessDatetimeValue = event.target.value;
         } 
         else if(whichField == 'RequestBusinessCommentName'){
            this.RequestBusinessComments = event.target.value;
         } 
         else if(whichField == 'strSuccessPlanSignOffCommentName'){
            this.strSuccessPlanSignOffComment = event.target.value;
         } else if(whichField == 'RequestBusinessDatetimeTimezoneName'){
			this.strCurrentUserTimezone = event.target.value;
        }
     } 

    adoptionRelatedQueriesSubmit(){
		let objParent = this;
        var productAdoptionQueriesReasonValue = this.productAdoptionQueriesReasonValue;
        var productAdoptionQueriesComment = this.productAdoptionQueriesComment;
        
        if(productAdoptionQueriesReasonValue != '' && productAdoptionQueriesComment != '' ){
			objParent.boolDisplaySpinner = true;
            var currentPlanId = this.recordId;
            createContactYourCsm({'planId' : currentPlanId,'strComments':productAdoptionQueriesComment, 'strReason' : productAdoptionQueriesReasonValue, 'category' : 'Adoption Related Queries', 
					"lstFileIds": this.lstUploadedFileIds})
            .then(result => {                                                  
                this.template.querySelector('c-sp-plan-comments').refreshPlanComments(); 
				this.template.querySelector('c-sp-file-data-table').filesDataHelper();                   
                this.closeAdoptionRelatedQueriesModal();
				this.showNotification('Success!', 'Your request has been noted; CSM will contact you shortly.', 'success');
            })
            .catch(error => {
                console.log('error=adoptionRelatedQueriesSubmit=>  ' + JSON.stringify(error));
                this.showNotification('Error adoptionRelatedQueriesSubmit!', JSON.stringify(error) , 'error');
            }).finally(() => {
				objParent.boolDisplaySpinner = false;
			});
        }
		if(objUtilities.isBlank(productAdoptionQueriesComment)) {
			this.showNotification('Required fields missing', 'Add Comments', 'error');
		}
        else if(objUtilities.isBlank(productAdoptionQueriesReasonValue)){
            this.showNotification('Required fields missing', 'Reason', 'error');
        }
    }

    discussNewInitiativesSubmit(){
		let objParent = this;
        var discussNewInitiativesReasonValue = this.discussNewInitiativesReasonValue;
        var discussNewInitiativesComment = this.discussNewInitiativesComment;
        
        if(discussNewInitiativesComment != '' && discussNewInitiativesReasonValue != '' ){
			objParent.boolDisplaySpinner = true;
            var currentPlanId = this.recordId;
            createContactYourCsm({'planId' : currentPlanId,'strComments':discussNewInitiativesComment, 'strReason' : discussNewInitiativesReasonValue, 'category' : 'Discuss New Initiatives', 
					"lstFileIds": this.lstUploadedFileIds})
            .then(result => {                                                  
                this.template.querySelector('c-sp-plan-comments').refreshPlanComments();   
				this.template.querySelector('c-sp-file-data-table').filesDataHelper();                 
                this.closeDiscussNewInitiativesModal();
				this.showNotification('Success!', 'Your request has been noted; CSM will contact you shortly.', 'success');
            })
            .catch(error => {
                console.log('error=adoptionRelatedQueriesSubmit=>  ' + JSON.stringify(error));
                this.showNotification('Error adoptionRelatedQueriesSubmit!', JSON.stringify(error) , 'error');
            }).finally(() => {
				objParent.boolDisplaySpinner = false;
			});
        }
		if(objUtilities.isBlank(discussNewInitiativesComment)) {
			this.showNotification('Required fields missing', 'Add Comments', 'error');
		}
    }

    RequestBusinessReviewMeetingSubmit(){
		let objParent = this;
		let strFormatteddate = "";
		let strTimeZone = objParent.strCurrentUserTimezone;
		let datTRequestedBusinessDateTimeValue;
        var RequestBusinessDatetimeValue = objParent.RequestBusinessDatetimeValue;
        var RequestBusinessComments = objParent.RequestBusinessComments;
        
        
        if(objUtilities.isNotBlank(RequestBusinessComments) && objUtilities.isNotBlank(RequestBusinessDatetimeValue)){
            var currentPlanId = objParent.recordId;
			datTRequestedBusinessDateTimeValue = new Date(RequestBusinessDatetimeValue);

			//Now we make sure the provided date is in the future only.
			if(datTRequestedBusinessDateTimeValue > new Date()) {
				objParent.boolDisplaySpinner = true;
				strFormatteddate = objParent.formatDate(datTRequestedBusinessDateTimeValue);
				objParent.lstTimeZones.forEach( objTimeZone => {
					if(objTimeZone.value === strTimeZone) {
						strTimeZone = objTimeZone.label
					}
				});
				RequestBusinessComments = '</br></br>'+strFormatteddate + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + strTimeZone + '</br>'+ RequestBusinessComments ;
				createContactYourCsm({'planId' : currentPlanId,'strComments':RequestBusinessComments, 'strReason' : '', 'category' : 'Request for meeting', "lstFileIds": objParent.lstUploadedFileIds})
				.then(result => {                                                  
					objParent.template.querySelector('c-sp-plan-comments').refreshPlanComments();  
					objParent.template.querySelector('c-sp-file-data-table').filesDataHelper();                  
					objParent.closeRequestBusinessReviewMeetingModal();
					objParent.showNotification('Success!', 'Your request has been noted; CSM will contact you shortly.', 'success');
				})
				.catch(error => {
					console.log('error=adoptionRelatedQueriesSubmit=>  ' + JSON.stringify(error));
					objParent.showNotification('Error adoptionRelatedQueriesSubmit!', JSON.stringify(error) , 'error');
				}).finally(() => {
					objParent.boolDisplaySpinner = false;
				});
			} else {
				objParent.showNotification('Incorrect value', 'Date Time value can only be in the future', 'error');
			}
        }else if(objUtilities.isBlank(RequestBusinessComments)) {
			objParent.showNotification('Required fields missing', 'Add Comments', 'error');
		}
        else if(objUtilities.isBlank(RequestBusinessDatetimeValue)) {
			objParent.showNotification('Required fields missing', 'Add Date Time', 'error');
		}
    }

	formatDate(date) {
		let p = new Intl.DateTimeFormat('en',{
			year:'numeric',
			month:'numeric',
			day:'numeric',
			hour:'2-digit',
			minute:'2-digit',
			hour12: true,
			timeZone: TIME_ZONE
		}).formatToParts(date).reduce((acc, part) => {
			acc[part.type] = part.value;
			return acc;
		}, {});
		return `${p.month}/${p.day}/${p.year} ${p.hour}:${p.minute} ${p.dayPeriod}`; 
	}

	/*
	 Method Name : acceptedFormats
	 Description : This method defines the accepted file formats.
	 Parameters	 : None
	 Return Type : None
	 */
	 /*get acceptedFormats() {
        return ['.pdf', '.png'];
    }*/
	
	/*
	 Method Name : handleUploadAttachmentFinished
	 Description : This method saves the uploaded files.
	 Parameters	 : Object, called from valueChangeHandler, objEvent Event.
	 Return Type : None
	 */
    handleUploadAttachmentFinished(objEvent) {
		this.lstUploadedFileIds = [];
        if(this.lstUploadedFiles.length > 0) {
            for(var i = 0; i < objEvent.detail.files.length; i++) {
                this.lstUploadedFiles.push(objEvent.detail.files[i]);
            }
        } else {
            this.lstUploadedFiles = objEvent.detail.files;
        }
		for(var i = 0; i < this.lstUploadedFiles.length; i++) {    
		   this.lstUploadedFileIds.push(this.lstUploadedFiles[i].documentId);
		}
    }

	/*
	 Method Name : handleRemoveAttachment
	 Description : This method removes uploaded files.
	 Parameters	 : Object, called from valueChangeHandler, objEvent Event.
	 Return Type : None
	 */
    handleRemoveAttachment(objEvent) {
        this.lstUploadedFiles = this.lstUploadedFiles.filter(item => item.name !== objEvent.target.name);
		this.lstUploadedFileIds = [];
		for(var i = 0; i < this.lstUploadedFiles.length; i++) {    
		   this.lstUploadedFileIds.push(this.lstUploadedFiles[i].documentId);
		}
    }

	/*
	 Method Name : processRecords
	 Description : This method processes the results.
	 Parameters	 : Object, called from processRecords, objResult Results.
	 Return Type : None
	 */
    processRecords(objResult) {

		//First we process the data.
        this.objParameters.lstRecords = objResult.lstRecords;
		this.objParameters.lstColumns = JSON.parse(JSON.stringify(objResult.lstColumns));

		//Now we enable / disable the sign off button.
		if(this.objParameters.lstRecords.length > 0) {
			this.bShowSignOff = true;  
		} else {
			this.bShowSignOff = false;  
		}

        //Now we set the custom parameters.
		this.objParameters.lstColumns.forEach(objColumn => {
			if(objColumn.strFieldName === "Name") {
				objColumn.label = 'Name';
                objColumn.wrapText=true;
                objColumn.type= 'text' ;
                objColumn.subtype = 'text'
			}
		});
    }

	/*
	 Method Name : openSignOffComponent
	 Description : This method opens the Sign Off component.
	 Parameters	 : None
	 Return Type : None
	 */
	openSignOffComponent() {
		if(this.bhasSignOffAccess && this.bShowSignOff) {
			this.handleSelect({
				detail: {
					value: 'Provide Success plan signoff'
				}
			});
		}
	}

    navigatetoEngagementCatalogPage(){
        //<T01> start
        /*let stage = this.planRecord.Stage__c==='Implement'?'Implement,Design':this.planRecord.Stage__c;
        let urlforNavigate = AEMEngagementCatalogURL +'/?planId='+this.planId+'#f:engagementadoptionstage=['+stage+']';*/ 
        let urlforNavigate = AEMEngagementCatalogURL +'/?planId='+this.planId
        //</T01> end
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: urlforNavigate
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}