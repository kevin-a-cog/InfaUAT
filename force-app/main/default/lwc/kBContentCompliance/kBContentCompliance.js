/*
 Change History
 **************************************************************************************************************************
|     Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 **************************************************************************************************************************
|     01      |  03-June-2023     |   Sathish                 |    I2RT-8326      |   PROD - KB External Search - In "Article Preview" screen images are not getting displayed to anonymous users if the article status is in Pending Technical Review.
 */
    
import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import INFAKBResource from "@salesforce/resourceUrl/INFAKBResource";
import getArticleGDPRCompliance from "@salesforce/apex/KBContentGovernance.getArticleGDPRCompliance";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { getRecord } from "lightning/uiRecordApi";
import setProcessedVersionKBImageTag from '@salesforce/apex/KBArticleHandler.setProcessedVersionKBImageTag';//01

// const ARTICLE_FIELDS = [
//   "Knowledge__kav.Id",
//   "Knowledge__kav.Title",
//   "Knowledge__kav.ArticleNumber",
//   "Knowledge__kav.Article_Type__c",
//   "Knowledge__kav.Solution__c",
//   "Knowledge__kav.Description__c",
//   "Knowledge__kav.Additional_Information__c",
//   "Knowledge__kav.Internal_Notes__c",
//   "Knowledge__kav.Alternate_Questions__c",
//   "Knowledge__kav.Keywords__c"
// ];

const ARTICLE_FIELDS = [
    "Knowledge__kav.Id",
    "Knowledge__kav.Title",
    "Knowledge__kav.Article_Type__c",
    "Knowledge__kav.ValidationStatus"//<01>
];

const ACTIVETAB = "slds-tabs_scoped__item slds-is-active";
const INACTIVETAB = "slds-tabs_scoped__item";
const ACTIVECONTENT = "slds-tabs_scoped__content slds-show";
const INACTIVECONTENT = "slds-tabs_scoped__content slds-hide";

//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
    try {
        if (ISDEBUGENABLED == true || parType == 'error') {
            if (parType == 'log') {
                console.log(parMessage);
            }
            else if (parType == 'error') {
                console.error(parMessage);
            }
            else if (parType == 'warn') {
                console.warn(parMessage);
            }
        }
    } catch (err) {
        console.log('Utility Log : ' + err.message);
    } finally {

    }
}
//For Loggging in Console

export default class KBContentCompliance extends LightningElement {
    @track lstAdditionalInfo = [ ];

    @api comptitle = "Article Content Quality Checks";    
    @api recordId;
    @track wizardtitle = "Article Content Quality Checks";
    @track complianceTabTitle = "Compliance Violations";
    @track othersTabTitle = "Content Standard Checklist";
    @track titleTabToggle = ACTIVETAB;
    @track othersTabToggle = INACTIVETAB;
    @track titleContentToggle = ACTIVECONTENT;
    @track othersContentToggle = INACTIVECONTENT;
    @track titlePopUpTabToggle = ACTIVETAB;
    @track othersPopUpTabToggle = INACTIVETAB;
    @track titlePopUpContentToggle = ACTIVECONTENT;
    @track othersPopUpContentToggle = INACTIVECONTENT;
    @track gdprFeedbackJSONString = '';
    @track isModalOpen = false;
    @track isDataLoadInProgress = true;
    @track isDataAvailable = false;
    @track gdprJSONStirng = "";
    @track gdprJSONObject = undefined;
    @track gdprFinalOutputHTML = "";
    @track allGDPRJSONFinalOutput = [];
    
    @track gdprerror = "";
    @track isGDPRCheckEnabled = false;
    @track fnProcessContentForCompliance;
    @track isDataAvailableOnLoad = false;
    @track isThereAnyViolations = true;
    @track isThereAnyGDPRViolations = false;
    @track isThereAnyAdditionalInformation = false;
    @track ArticleDetails = undefined;
    @track popUpAppearanceCount = 0;
    @track expandminimizeWidgetCss = "gdprdata-content-minimized";
    @track showMoreOrLessiconCss = "utility:chevrondown";
    warningIconPath = INFAKBResource + "/images/icon-warning.png";
    qualityIconPath = INFAKBResource + "/images/icon-quality.png";
    checklistIconPath = INFAKBResource + "/images/icon-checklist.png";
    @wire(getRecord, { recordId: "$recordId", fields: ARTICLE_FIELDS })
    article({ error, data }) {        
        if (error) {
            console.log("kBContentCompliance : error - " + JSON.stringify(error));
        } else if (data) {
            this.ArticleDetails = data;
            this.isDataAvailable = false;
            this.isDataAvailableOnLoad = false;
            this.isThereAnyViolations = true;            
            this.loadGDPRData();
            //Start -- /*<01*/
            try {
                if (data.fields.ValidationStatus.value != null && data.fields.ValidationStatus.value == 'Pending Technical Review') {
                    console.log('fnProcessKBImageTag');
                    this.fnProcessKBImageTag();
                }
            } catch (error) {
                console.error('fnProcessKBImageTag');
                Log('error', 'fnProcessKBImageTag error --> ' + JSON.stringify(error));
            }
            //End -- /*<01>*/
        }
    }
    connectedCallback() {
        loadScript(
            this,
            INFAKBResource + "/js/Jquery/3.0.0-rc1/jquery-3.0.0-rc1.min.js"
        )
            .then(() => {
                console.log("success KBContentCompliance Jquery");
                loadScript(this, INFAKBResource + "/js/gdpr_compliance.js")
                    .then(() => {
                        window.KBJ$ = jQuery.noConflict();
                        // this.fnProcessContentForCompliance = gdrp_compliance;
                        console.log("success KBContentCompliance gdpr_compliance");
                    })
                    .catch((error) => {
                        console.error("error KBContentCompliance gdpr_compliance");
                    });
            })
            .catch((error) => {
                console.error("error KBContentCompliance Jquery");
            });
        //Loading CoveoFullSearch CSS
        loadStyle(this, INFAKBResource + "/css/kBContentCompliance.css")
            .then(() => {

            })
            .catch(error => {
                console.error("error KBContentCompliance kBContentCompliance");
            });
        //Loading CoveoFullSearch CSS
    }
    renderedCallback() { }
    loadGDPRData() {
        console.log("success KBContentCompliance loadGDPRData");
        getArticleGDPRCompliance({
            recid: this.recordId
        })
            .then((result) => {
                console.log("getArticleGDPRCompliance");
                console.log("result : " + JSON.stringify(result));
                this.lstAdditionalInfo = [];
                this.allGDPRJSONFinalOutput = []
                this.allGDPRJSONFinalOutput = [...this.allGDPRJSONFinalOutput];
                this.lstAdditionalInfo = [...this.lstAdditionalInfo];
                this.gdprFinalOutputHTML = "";
                this.isThereAnyGDPRViolations = false;
                this.isThereAnyAdditionalInformation = false;
                gdprComplianceMethods['gdprFinalOutputHTMLForOtherComp' + this.recordId] = '';
                gdprComplianceMethods['gdprFeedbackDataForOtherComp' + this.recordId] = '';
                if (JSON.parse(result).APIResponseStatus === "SUCCESS") {
                    this.gdprJSONStirng = JSON.parse(result).GDPRData;
                    this.gdprFeedbackJSONString = JSON.parse(result).GDPRFeedbackData;
                    if (
                        JSON.parse(this.gdprJSONStirng).RESTResponse.payload != undefined
                    ) {
                        this.gdprJSONStirng = JSON.parse(
                            this.gdprJSONStirng
                        ).RESTResponse.payload;
                    }
                    
                    this.allGDPRJSONFinalOutput = gdprComplianceMethods.fnBuildGDPRJSONOutput(
                        this.gdprJSONStirng
                    );
                    var varDataArray = this.allGDPRJSONFinalOutput;
                    for (var j = 0; j < varDataArray.length; j++) {
                        if (varDataArray[j].Type == 'GDPRCompliance') {
                            if (varDataArray[j].Output.Is_Violated.toString() == '0') {
                                console.log('No ' + varDataArray[j].Type);                               
                            }
                            else if (varDataArray[j].Output.Is_Violated.toString() == '1') {
                                var varGDRPOutputJSON = varDataArray[j].Output;
                                var varGDRPOutputHTML = varDataArray[j].Output.HTML_Output;
                                varDataArray[j].Title = 'Compliance Violations';
                                this.gdprFinalOutputHTML = decodeURIComponent(varGDRPOutputHTML);
                                if (this.gdprFinalOutputHTML != '') {
                                    this.isThereAnyGDPRViolations = true;
                                    gdprComplianceMethods['gdprFinalOutputHTMLForOtherComp' + this.recordId] = this.gdprFinalOutputHTML;
                                    var vargdprFeedbackJSONObject = JSON.parse(this.gdprFeedbackJSONString);
                                    vargdprFeedbackJSONObject.GDPR_Compliance_Data_On_Upvote = JSON.stringify(this.allGDPRJSONFinalOutput);
                                    this.gdprFeedbackJSONString = JSON.stringify(vargdprFeedbackJSONObject);
                                    gdprComplianceMethods['gdprFeedbackDataForOtherComp' + this.recordId] = this.gdprFeedbackJSONString;
                                }
                            }
                        }
                        else {
                            if (varDataArray[j].Output.Is_Violated.toString() == "0") {
                                console.log('No ' + varDataArray[j].Type);
                            }
                            else if (varDataArray[j].Output.Is_Violated.toString() == "1") {
                                var varRandomNumber = (Math.floor(Math.random() * 10000) + 1).toString();
                                var varAddiInfoOutputHTML = varDataArray[j].Output.HTML_Output;
                                varAddiInfoOutputHTML = decodeURIComponent(varAddiInfoOutputHTML);
                                varDataArray[j].value = varAddiInfoOutputHTML;
                                if (varAddiInfoOutputHTML != '' && this.isThereAnyAdditionalInformation == false) {
                                    this.isThereAnyAdditionalInformation = true;
                                }
                                varDataArray[j].key = varRandomNumber;
                                this.lstAdditionalInfo.push(varDataArray[j]);
                            }
                        }

                    }
                    if ((this.isThereAnyGDPRViolations) || (this.isThereAnyAdditionalInformation)) {
                        this.isThereAnyViolations = true;
                        if ((!this.isThereAnyGDPRViolations) && (this.isThereAnyAdditionalInformation)) {
                            this.handleOthersTab();
                            this.handlePopUpOthersTab();
                        }
                        else if ((this.isThereAnyGDPRViolations) && (!this.isThereAnyAdditionalInformation)) {
                            this.handleComplianceTab();
                            this.handlePopUpComplianceTab();
                        }
                    }
                    else {
                        this.isThereAnyViolations = false;
                    }

                    this.isResponseWithSuccess = true;
                    this.isResponseWithError = false;
                } else if (JSON.parse(result).APIResponseStatus === "ERROR") {
                    gdprComplianceMethods['gdprFinalOutputHTMLForOtherComp' + this.recordId] = '';
                    gdprComplianceMethods['gdprFeedbackDataForOtherComp' + this.recordId] = '';
                    this.isThereAnyViolations = false;
                    this.gdprFinalOutputHTML = "";
                    this.isResponseWithError = true;
                    this.isResponseWithSuccess = false;
                }
                this.isDataLoadInProgress = false;
                this.isDataAvailableOnLoad = true;
                this.isDataAvailable = true;
                console.log("getArticleGDPRCompliance Last");
                this.popUpMessage();
            })
            .catch((error) => {
                if (error.message != undefined)
                    console.log("error message: " + error.message);
                if (error.stack != undefined)
                    console.log("error stack: " + error.stack);
                this.isThereAnyViolations = false;
                gdprComplianceMethods['gdprFinalOutputHTMLForOtherComp' + this.recordId] = '';
                gdprComplianceMethods['gdprFeedbackDataForOtherComp' + this.recordId] = '';
            });
        // to open modal set isModalOpen tarck value as true
    }
    openModal() {
        this.isModalOpen = true;
    }

    expandminimizeWidget() {
        if (this.expandminimizeWidgetCss == "gdprdata-content-minimized") {
            this.expandminimizeWidgetCss = "gdprdata-content-expanded";
            this.showMoreOrLessiconCss = "utility:chevronup";
        } else {
            this.expandminimizeWidgetCss = "gdprdata-content-minimized";
            this.showMoreOrLessiconCss = "utility:chevrondown";
        }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    popUpMessage() {
        if (!this.isThereAnyViolations) {
            
            this.popUpAppearanceCount++;
            if (this.popUpAppearanceCount === 1) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message:
                            "No GDPR violations detected within the Knowledge article. Please proceed.",
                        variant: "success"
                    })
                );
            }
        } else {
            
        }
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
    fnToggleComplianceData() {
        console.log("success KBContentCompliance fnToggleComplianceData");
    }
    get articledetails() {
        var varTitleValue = "";
        var varRecordTypeValue = "";
        var varArticleNumberValue = "";
        try {
            varTitleValue = this.ArticleDetails.fields.Title.value;
            varRecordTypeValue = this.ArticleDetails.fields.Article_Type__c.value;
            varArticleNumberValue = this.ArticleDetails.fields.ArticleNumber.value;
        } catch (ex) {
            console.error("Method : articledetails; Error :" + ex.description);
        }
        return "";
    }

    fnGDPRClick(event) {
        console.log("success KBContentCompliance fnGDPRClick");
    }

    handleToggleSection(event)
    {
       
    }
    handleOthersTab(event)
    {
        try
        {
            this.titleTabToggle = INACTIVETAB;
            this.othersTabToggle = ACTIVETAB;
            this.titleContentToggle = INACTIVECONTENT;
            this.othersContentToggle = ACTIVECONTENT;
            Log('log', 'Method : handleOthersTab;');
        }
        catch (error) {
            Log('error', 'Method : handleOthersTab; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    handleComplianceTab(event)
    {
        try
        {
            this.titleTabToggle = ACTIVETAB;
            this.othersTabToggle = INACTIVETAB;
            this.titleContentToggle = ACTIVECONTENT;
            this.othersContentToggle = INACTIVECONTENT;
            Log('log', 'Method : handleComplianceTab;');
        }
        catch (error) {
            Log('error', 'Method : handleComplianceTab; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    handlePopUpOthersTab(event) {
        try {
            this.titlePopUpTabToggle = INACTIVETAB;
            this.othersPopUpTabToggle = ACTIVETAB;
            this.titlePopUpContentToggle = INACTIVECONTENT;
            this.othersPopUpContentToggle = ACTIVECONTENT;
            Log('log', 'Method : handleOthersTab;');
        }
        catch (error) {
            Log('error', 'Method : handleOthersTab; Catch Error :' + error.message + " : " + error.stack);
        }
    }
    
    handlePopUpComplianceTab(event) {
        try {
            this.titlePopUpTabToggle = ACTIVETAB;
            this.othersPopUpTabToggle = INACTIVETAB;
            this.titlePopUpContentToggle = ACTIVECONTENT;
            this.othersPopUpContentToggle = INACTIVECONTENT;
            Log('log', 'Method : handleComplianceTab;');
        }
        catch (error) {
            Log('error', 'Method : handleComplianceTab; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    
    //Start --> Sathish R --> Jira : I2RT-8359 - 01
    fnProcessKBImageTag() {
        setProcessedVersionKBImageTag({
            kavId: this.recordId,            
        }).then(result => {
            console.log('result setProcessedVersionKBImageTag ' + result);
        }).catch(error => {
            console.log('error setProcessedVersionKBImageTag is: ' + JSON.stringify(error));
        });
    }
    //End --> Sathish R --> Jira : I2RT-8359 - 01

}