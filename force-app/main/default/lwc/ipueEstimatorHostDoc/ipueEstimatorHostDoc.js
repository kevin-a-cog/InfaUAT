import { LightningElement, api, wire, track } from 'lwc';
import fetchDocFormData from '@salesforce/apex/IPUE_FormControllerDoc.fetchDocFormData';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import {MessageContext} from 'lightning/messageService';
import LOGO_URL from '@salesforce/contentAssetUrl/INFLogoHorFCRGBpng';

const columns = [
    { label: 'Service name', fieldName: 'Service_Name__c', type: 'text' },
    {
        label: 'Required IPUs',
        fieldName: 'Required_IPUs__c',
        type: 'number',
    },
];


//export default class IpueEstimatorHost extends LightningElement {
export default class IpueEstimatorHostDoc extends NavigationMixin(LightningElement) {

    // Api properties
    recordId;
    formId;

    columns = columns;
    estimationLinesdata;

    // Private properties
    // Front-end things
    logoUrl = LOGO_URL;

    // Data
    @track formData = {};
    accountName;
    ownerName;
    estimationName;
    currentDate;
    currentDatePlus30;
    totalIPUs;

    isClosed;
    totalEstimation;
    integrationCount;
    pageSectionIds = [];

    // State management
    formLoaded = false;
    loadingRows = false;
    isCalculate = false;
    get fullyLoaded() {
        return this.formLoaded;
    }
    //for chatter functionality
    summaryChatterIconClass;
    isInternalUser;
    // Debouncing
    pendingSectionUpdates;
    pendingUpdate;
    apexRunning = false;
    apexRunningMessage;

    pageIndex;
    frameIndex;
    sectionIndex;

    error = false;
    @api errorTitle;
    @api errorMessage;

    firstLoad = true;
    currentPageIndex;
    currentPage;
    currentPageReference;
    
    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        let params = {};
        if (pageRef && pageRef.state) {
            this.recordId = pageRef.state.c__recordId;
        }
    }
    //handle message content for the lms
    @wire(MessageContext)
    messageContext;

    /************ Initialization *************/


    connectedCallback() {
        this.getCurrentDate();
        this.applyCssStyleSheet();
        this.loadForm();
        
    }

    //applying custom css
    applyCssStyleSheet(){
        document.styleSheets[0].insertRule(`.svgClass svg{
            fill:#f3f3f3;}`);

        document.styleSheets[0].insertRule(`.svgClass button{
            background:#0171d2;
        }`);
    }
    // Show the first page once the form is rendered for the first time
    renderedCallback() {
        if (this.firstLoad && this.fullyLoaded) {
            this.firstLoad = false;
        }
    }

    loadForm(){

        fetchDocFormData({
            recordId: this.recordId
        })
        .then((result) => {

            if (result) {
                //this.formData = JSON.parse(JSON.stringify(result.formWrapper.form));
                this.formData = { ...result.formWrapper.form };
                this.estimationLines = JSON.parse(JSON.stringify(result.estimationLines));

                this.formData.pages.forEach((page) => {
                    page.frames.splice(1);
                    page.hasSelectedSections = false;
                });

                this.formData.pages.forEach((page) => {
                    let pageHasSelectedSections = false;

                    page.frames.forEach((frame) => {
                      frame.pageSections.forEach((section) => {
                        section.sectionItems.forEach((item) => {
                          section.isTable = item.isTable;
                          section.isSchedule = item.isSchedule;
                          if(pageHasSelectedSections != true && section.selectedPageSection){
                            pageHasSelectedSections = section.selectedPageSection;
                          }
                        });
                      });
                    });
                    page.hasSelectedSections = pageHasSelectedSections;
                });
                
                this.accountName = result.accountName;
                this.ownerName = result.ownerName;
                this.estimationName = result.estimationName;
                this.totalIPUs = result.totalIPUs;
                this.estimationLinesdata = JSON.parse(JSON.stringify(result.estimationLines));
                this.totalEstimation = result.totalIPUs ? result.totalIPUs : 0;
                this.formLoaded = true;
                
            } else {
                this.error = true;
                this.errorMessage = 'This page is not available for manually uploaded estimations. Please navigate to the "Details" tab for the total IPU and the “Related” tab for the IPU estimated for each service.';
            }

        })
        .catch(error => {
            console.error('Error Loading IPU Estimator: ', error);
            let message = error;

            // If a more specific error can be found, return it
            if (error.body && error.body.message) {
                message = error.body.message;
            }

            this.error = true;
            this.errorTitle = 'Error Loading IPU Estimator';
            this.errorMessage = message;
        });

    }

    getCurrentDate(){
        let currentDate = new Date();
        let year = currentDate.getFullYear();
        let month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
        let day = currentDate.getDate().toString().padStart(2, '0');
        this.currentDate = year + '-' + month + '-' + day;


        const currentDatePlus30 = new Date();
        currentDatePlus30.setDate(currentDatePlus30.getDate() + 30);

        const yearNew = currentDatePlus30.getFullYear();
        const monthNew = String(currentDatePlus30.getMonth() + 1).padStart(2, '0');
        const dayNew = String(currentDatePlus30.getDate()).padStart(2, '0');

        this.currentDatePlus30 = `${yearNew}-${monthNew}-${dayNew}`;
    }
}