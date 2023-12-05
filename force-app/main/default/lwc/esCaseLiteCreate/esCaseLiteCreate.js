/*
 * Name			:	esCaseLiteCreate
 * Author		:	Vignesh Divakaran
 * Created Date	: 	8/30/2022
 * Description	:	This is the case creation component for Case Lite type in eSupport.

 Change History
 ******************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ******************************************************************************************************************
 Vignesh Divakaran		8/30/2022		N/A				Initial version.			                        N/A
 Vignesh Divakaran		10/21/2022		I2RT-7256		Added changes to show org users instead of ACR		T01
 														under alternate contacts
 Vignesh Divakaran		10/31/2022		I2RT-7296		Remove priority	from case information		        T02
 Vignesh Divakaran		11/25/2022		I2RT-7453		Added session storage logic for Product, Subject,   T03
                                                        Error Message & Description fields to show KB
                                                        recommendations
 */

import { LightningElement, track } from 'lwc';

//Static resources
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
 
//Custom Labels
import AskOurCommunityURL from '@salesforce/label/c.AskOurCommunityURL';
import eSupport_Community_URL from '@salesforce/label/c.eSupport_Community_URL';
import Case_Lite_RecordType_Name from '@salesforce/label/c.Case_Lite_RecordType_Name';
 
//Apex Controllers.
import removeFile from '@salesforce/apex/CaseController.removeFile';
import getUploadedFiles from '@salesforce/apex/CaseController.getUploadedFiles';
import getAcceptedFileFormates from '@salesforce/apex/CaseController.getAcceptedFileFormates';
import getCaseLiteDetails from '@salesforce/apex/CaseController.getCaseLiteDetails';
import getAccountContacts from '@salesforce/apex/CaseController.getAccountContacts';
import createCase from '@salesforce/apex/CaseController.createCase';
 
//Utilities.
import { objUtilities } from 'c/globalUtilities';
 
export default class EsCaseLiteCreate extends LightningElement {
 
    //Track variables
    @track objCase;
    @track lstOrgs;
    @track lstProducts;
    @track strOrgId;
 
    //Private variables
    strFrom;
    strProductName;
    technicalCaseInfo = true;
    additionalInfoTechnical = false;
    alternateContactInfo = false;
    finalSummaryCase = false;
    mapOrgAccountId;
    strDescriptionPlaceholder;
    boolShowCancel;
    boolShowSpinner = true;
    /*Side bar variables*/
    triggerforsearch;
    placedin = 'esupportcasedeflectiontechnical';
    /* File Upload variables */
    uploadedFiles = [];
    showUploadedFiles = false;
    fileToRemove;
    isAttachmentDeletePopup = false;
    contactId;

    label = {
        AskOurCommunityURL,
        eSupport_Community_URL,
        Case_Lite_RecordType_Name
    };
    image = {
        PostQuestions: ESUPPORT_RESOURCE + '/post_questions.png'
    };
    strMessage;
    boolIsLoading;
    boolHasAccess;
    strRedirectURL;
    strCaseCountMessage;
    boolIsCaseLite = true;
    objParameters = {
        strCaseType: this.label.Case_Lite_RecordType_Name,
        strAlternateContactsDescription: 'You can include other contacts from your org to this case so they can view & comment in the case.',
        strCaseAttachmentNumber: '0',
        strContactsAddedMessage: '',
        lstAllContacts: [],
        lstAllSelectedRecordIds: []
    }; //<T01>
    objCaseSummary = {}; //<T01>
 
    /*
      Method Name : connectedCallback
      Description : This method gets executed on load.
      Parameters  : None
      Return Type : None
    */
    connectedCallback() {
 
        //We initialize the components.
        this.initializeComponent();
    }
 
    /*
      Method Name : initializeComponent
      Description : This method gets executed after load.
      Parameters  : None
      Return Type : None
    */
    initializeComponent() {
        let objParent = this;
 
        //Now, we fetch the parameters from URL
        let url = new URL(encodeURI(window.location.href));
        objParent.strProductName = objUtilities.isNotBlank(url.searchParams.get('product')) ? decodeURI(decodeURI(url.searchParams.get('product'))) : undefined;
        objParent.strFrom = url.searchParams.get('from');
 
        //We now initialize the variables.
        objParent.lstOrgs = [];
        objParent.lstProducts = [];
        objParent.mapOrgAccountId = new Map();
        objParent.boolAccordionItem = true;
        objParent.strDescriptionPlaceholder = 'Share a detailed description of the problem. \nWhat are the problem symptoms? \nWhen did it occur? \nWhat were the actions taken just before the occurrence ?';
        objParent.boolIsLoading = true;
        objParent.boolHasAccess = false;
        objParent.strCaseCountMessage = undefined;
        objParent.objCase = {
            orgId: '',
            secureAgent: '',
            product: objParent.strProductName,
            version: 'Current',
            priority: 'P3',
            subject: '',
            errorMessage: '',
            description: ''
        }
 
        if(objUtilities.isNotBlank(objParent.strProductName)){
            //Now, we validate the user access and fetch the case creation details
            objParent.loadInitialDetails();
        }
        else{
            objParent.boolShowSpinner = false;
            objParent.strMessage = 'Invalid access';
            objParent.boolIsLoading = false;
        }
    }
 
    /*
      Method Name : loadInitialDetails
      Description : This method fetches initial details required for case creation.
      Parameters  : None
      Return Type : None
    */
    loadInitialDetails(){
        let objParent = this;
 
        getCaseLiteDetails({strProductName: objParent.strProductName})
            .then(objResult => {
                let lstOrgs = [];
                let lstProducts = [];

                objParent.contactId = objResult.contactId;
                objParent.lstPriority = [{label: 'P3', value: 'P3'}];
                objResult.lstOrgs.forEach(objOrg => {
                    objParent.mapOrgAccountId.set(`${objOrg.OrgID__c} - ${objOrg.Org_Name__c}`, objOrg);
                    lstOrgs.push({label: `${objOrg.OrgID__c} - ${objOrg.Org_Name__c}`, value: `${objOrg.OrgID__c} - ${objOrg.Org_Name__c}`});
                });
                objResult.objSupportLiteProduct?.Product_Name_on_Support__c.split(';').forEach(strProductName => {
                    if(objUtilities.isNotBlank(strProductName)){
                        lstProducts.push({label: strProductName, value: strProductName})
                    }
                });

                //If there is only one org, we preselect the org and load the contacts
                if(lstOrgs.length == 1){
                    objParent.objCase.orgId = lstOrgs[0].value;
                    objParent.strOrgId = objParent.mapOrgAccountId.get(objParent.objCase.orgId)?.Id;
                    objParent.strCaseCountMessage = objParent.getCaseCountMessage(objParent.mapOrgAccountId.get(lstOrgs[0].value)?.Number_of_Cases_Created__c);
                    objParent.loadContacts();
                }
                //If there is only one product, we preselect the product
                if(lstProducts.length == 1){
                    objParent.objCase.product = lstProducts[0].value;
                }
                else{
                    lstProducts.forEach(objProduct => {
                        if(objProduct.value == objParent.strProductName){
                            objParent.objCase.product = objProduct.value;
                        }
                    });
                }
          		if(objUtilities.isNotBlank(objParent.objCase.product)){ //<T03>
                    sessionStorage.setItem('tech_product', objParent.objCase.product.replace('-PayGo',''));
                    sessionStorage.setItem('fc_product', objParent.objCase.product.replace('-PayGo',''));
                  
                    //We trigger KB search after 2 seconds from load
                    setTimeout(function(){
                        objParent.handleSearchDataOnBlur({target:{name: 'Subject'}});
                    }, 2000);
                }
                objParent.lstOrgs = lstOrgs;
                objParent.lstProducts = lstProducts;
                objParent.strRedirectURL = objResult?.objSupportLiteProduct?.IN_Redirect_URL__c;
                objParent.boolHasAccess = true;
            })
            .catch(objError => {
                objParent.strMessage = objError?.body?.message == 'Insufficient access to create case' ? 'Your Subscription has ended. Please purchase your subscription to make use of Create Case and Manage Case feature' : 'Invalid Access';
            })
            .finally(() => {
                objParent.boolShowSpinner = false;
                objParent.boolIsLoading = false;
            });
    }
 
 
    /*
      Method Name : inputChange
      Description : This method updates the user input to the corresponding case fields.
      Parameters  : Object, called from inputChange, objEvent On change event.
      Return Type : None
    */
    inputChange(objEvent) {
        let inputValue = objEvent.target.value;
        
        switch (objEvent.target.name) {
            case 'OrgID':
                this.objCase.orgId = inputValue;
                this.strOrgId = this.mapOrgAccountId.get(this.objCase.orgId)?.Id;
                this.strCaseCountMessage = this.getCaseCountMessage(this.mapOrgAccountId.get(this.objCase.orgId)?.Number_of_Cases_Created__c);
                this.loadContacts();
                break;
            case 'SecureAgent':
                this.objCase.secureAgent = inputValue;
                break;
            case 'Product':
                this.objCase.product = inputValue;
                sessionStorage.setItem('tech_product', inputValue.replace('-PayGo','')); //<T03>
                sessionStorage.setItem('fc_product', inputValue.replace('-PayGo','')); //<T03>
                break;
            case 'Subject':
                this.objCase.subject = inputValue;
                sessionStorage.setItem('tech_sub', inputValue); //<T03>
                break;
            case 'ErrorMessage':
                this.objCase.errorMessage = inputValue;
                sessionStorage.setItem('tech_message', inputValue); //<T03>
                break;
            case 'Description':
                this.objCase.description = inputValue;
                sessionStorage.setItem('tech_desc', inputValue); //<T03>
                break;
            default:
                //Do nothing
                break;
        }                        
    }

    /*
     Method Name : getCaseCountMessage
     Description : This method returns the cases created count message
     Parameters	 : Integer, called from loadInitialDetails, intNumber
     Return Type : String
    */
    getCaseCountMessage(intNumber){
        return `${isNaN(intNumber) ? 1 : intNumber + 1} of 10 cases opened in this year.`;
    }
 
     /*
      Method Name : loadContacts
      Description : This method fetches the account contacts based on the Org selected.
      Parameters  : None
      Return Type : None
      */
    loadContacts(){ //<T01>
        let objParent = this;
 
        getAccountContacts({orgId : objParent.strOrgId})
            .then(lstOrgUsers => {
                console.log(lstOrgUsers);            
                objParent.objParameters.lstAllContacts = objParent.parseData(lstOrgUsers);
                console.log(objParent.objParameters.lstAllContacts);
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            });
     }

    /*
     Method Name : parseData
     Description : This method constructs org users data to be used in the datatable.
     Parameters  : Array, called from loadContacts, lstOrgUsers
     Return Type : None
    */
    parseData(lstOrgUsers){ //<T01>
        let lstOrgUsersParsed = [];
        lstOrgUsers.forEach(objOrgUser => {
            if(objUtilities.isObject(objOrgUser?.Contact__r)){
                lstOrgUsersParsed.push({
                    strId: objOrgUser?.Id,
                    strContactId: objOrgUser?.Contact__c,
                    strFirstName: objOrgUser?.Contact__r?.FirstName,
                    strLastName: objOrgUser?.Contact__r?.LastName,
                    strEmail: objOrgUser?.Contact__r?.Email,
                    strPhone: objOrgUser?.Contact__r?.Phone,
                    boolIsVisible: true
                });
            }
            else{
                lstOrgUsersParsed.push({
                    strId: objOrgUser?.Id,
                    strContactId: '',
                    strFirstName: objOrgUser?.FirstName__c,
                    strLastName: objOrgUser?.LastName__c,
                    strEmail: objOrgUser?.Email__c,
                    strPhone: objOrgUser?.PhoneNumber__c,
                    boolIsVisible: true
                });
            }
        });
        return lstOrgUsersParsed;
    }
 
 
    showAdditionalInfoTechnical(){
        let isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input, lightning-textarea')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if(isValidValue){
            this.objParameters.strCaseInformation = 'Subject : ' + this.objCase.subject; //<T02>
            this.technicalCaseInfo = false;
            this.additionalInfoTechnical = true;
            this.alternateContactInfo = false;
            this.finalSummaryCase = false;
        }
    }
 
    handleSearchDataOnBlur(event) {
        try {
            var varTargetName = '';
            if (event.target.name != undefined)
                varTargetName = event.target.name;
            this.triggerforsearch = Math.random().toString() + '###$$$$####' + varTargetName;
        } catch (error) {
            console.error('Method : handleSearchDataOnBlur; Error :' + error.message + ' : ' + error.stack);
        }
    }
 
    handleUploadFinished(event) {
        //Get the list of uploaded files
        this.boolShowSpinner = true;
        const uploadedFiles = event.detail.files;
         
        getUploadedFiles()
            .then(result => {
                if (result) {
                    this.uploadedFiles = result;
                    let message = ' File is attached';
                    if (this.uploadedFiles.length > 1) {
                        message = ' Files are attached';
                    }
                    this.objParameters.strCaseAttachmentNumber = this.uploadedFiles.length + message; //<T01>
                    this.showUploadedFiles = true;
                }
                this.boolShowSpinner = false;
            });
    }
 
    downloadDoc(event){
        let url = '/sfc/servlet.shepherd/document/download/' + event.currentTarget.dataset.id;
        window.open(url,'_self');
    }
 
    removeAttachment(event) {
        this.fileToRemove = event.target.value;
        this.isAttachmentDeletePopup = true;
    }
 
    cancelFileRemove() {
        this.fileToRemove = '';
        this.isAttachmentDeletePopup = false;
    }
 
    confirmFileRemove() {
        this.boolShowSpinner = true;
        removeFile({ documentId: this.fileToRemove, isDetailPage: false })
            .then(result => {
                if (result) {
                    this.uploadedFiles = result;
                    if (this.uploadedFiles.length === 0) {
                        this.showUploadedFiles = false;
                    }
                    this.isAttachmentDeletePopup = false;
                    let message = ' File is attached';
                    if (this.uploadedFiles.length > 1) {
                        message = ' Files are attached';
                    }
                    this.objParameters.strCaseAttachmentNumber = this.uploadedFiles.length + message; //<T01>
                }
                this.boolShowSpinner = false;
            });
    }
 
    backToTechnicalCaseInfo() {
        this.technicalCaseInfo = true;
        this.additionalInfoTechnical = false;
        this.alternateContactInfo = false;
        this.finalSummaryCase = false;
        window.scrollTo(0, 0);
    }
 
    showAlternateContact() {
        this.technicalCaseInfo = false;
        this.additionalInfoTechnical = false;
        this.alternateContactInfo = true;
        this.finalSummaryCase = false;
        window.scrollTo(0, 0);
    }
 
    backToAdditionalInfoTechnical(objEvent) { //<T01>
        this.objParameters.lstAllSelectedRecordIds = [...objEvent.detail.lstAllSelectedRecordIds];
        this.technicalCaseInfo = false;
        this.additionalInfoTechnical = true;
        this.alternateContactInfo = false;
        this.finalSummaryCase = false;
        window.scrollTo(0, 0);
    }
 
    showFinalSummaryPage(objEvent) { //<T01>
        let objParent = this;

        objParent.objParameters.lstAllSelectedRecordIds = [...objEvent.detail.lstAllSelectedRecordIds];
        objParent.objParameters.strContactsAddedMessage = objParent.objParameters.lstAllSelectedRecordIds.length > 1 ? `${objParent.objParameters.lstAllSelectedRecordIds.length} Contacts` : `${objParent.objParameters.lstAllSelectedRecordIds.length} Contact`;
        objParent.objCaseSummary.strCategory = objParent.label.Case_Lite_RecordType_Name;
        objParent.objCaseSummary.strOrgId = objParent.objCase.orgId
        objParent.objCaseSummary.strProduct = objParent.objCase.product;
        objParent.objCaseSummary.strSecureAgent = objParent.objCase.secureAgent;
        objParent.objCaseSummary.strSubject = objParent.objCase.subject;
        objParent.objCaseSummary.strDescription = objParent.objCase.description;
        objParent.technicalCaseInfo = false;
        objParent.additionalInfoTechnical = false;
        objParent.alternateContactInfo = false;
        objParent.finalSummaryCase = true;
        window.scrollTo(0, 0);
    }
 
    backToAlternateContact(objEvent) { //<T01>
        this.objParameters.lstAllSelectedRecordIds = [...objEvent.detail.lstAllSelectedRecordIds];        
        this.technicalCaseInfo = false;
        this.additionalInfoTechnical = false;
        this.alternateContactInfo = true;
        this.finalSummaryCase = false;
        window.scrollTo(0, 0);
    }
 
    /*
      Method Name : saveCase
      Description : This method creates case and redirects to the case detail page.
      Parameters  : Object, called from saveCase, objEvent On click event.
      Return Type : None
    */
    saveCase(objEvent){
        let objParent = this;
         
        objParent.boolShowSpinner = true;
        document.body.setAttribute('style', 'overflow: hidden;');
         
        let objCaseFinal = {
            Forecast_Product__c: objParent.objCase.product,
            Version__c: objParent.objCase.version,
            Priority: objParent.objCase.priority,
            Secure_Agent__c: objParent.objCase.secureAgent,
            Subject: objParent.objCase.subject,
            Error_Message__c: objParent.objCase.errorMessage,
            Description: objParent.objCase.description
        };
        let lstCaseContacts = objEvent.detail.lstContactsToAdd || [];
        console.log(JSON.stringify(objCaseFinal));          
        console.log(JSON.stringify(lstCaseContacts));          
         
        createCase({ caseJson: JSON.stringify(objCaseFinal), recordTypeName: 'Case_Lite', caseRelatedContacts: [], lstCaseContactsToAdd: lstCaseContacts, strOrgUUID: objParent.objCase.orgId.split(' ')[0] })
            .then(strCaseId => {
                objUtilities.showToast("Success", 'Case has been created successfully', "success", objParent);
                objParent.navigateToURL(objParent.label.eSupport_Community_URL + 'casedetails?caseId=' + strCaseId, '_self');
            })
            .catch( objError => {
                objUtilities.processException(objError, objParent);
            })
            .finally(() => {
                objParent.boolShowSpinner = false;
                document.body.removeAttribute('style', 'overflow: hidden;');
            });
    }
 
    /*
      Method Name : accordionCollapse
      Description : This method toggles the accordion.
      Parameters  : None
      Return Type : None
    */
    accordionCollapse() {
        this.boolAccordionItem = !this.boolAccordionItem;
    }
 
    /*
      Method Name : showCancel
      Description : This method displays the case creation cancel modal.
      Parameters  : None
      Return Type : None
    */
    showCancel(){
        this.boolShowCancel = true;
    }
 
    /*
      Method Name : hideCancel
      Description : This method closes the case creation cancel modal.
      Parameters  : None
      Return Type : None
    */
    hideCancel(){
        this.boolShowCancel = false;
    }
 
    /*
      Method Name : redirect
      Description : This method redirects user to the origin page.
      Parameters  : None
      Return Type : None
    */
    redirect(){
        let strRedirectURL = objUtilities.isNotBlank(this.strFrom) && this.strFrom === '1' ? `managecases?product=${encodeURIComponent(this.strProductName)}` : this.strRedirectURL;
        if(objUtilities.isNotBlank(strRedirectURL)){
            this.navigateToURL(strRedirectURL, '_self');
        }
    }
 
    /*
      Method Name : navigateToURL
      Description : This method navigates user to the specified URL.
      Parameters  : String, called from saveCase & redirect, strURL
                    String, called from saveCase & redirect, strTarget
      Return Type : None
    */
    navigateToURL(strURL, strTarget){
        window.open(strURL, strTarget);
    }
  
    /*
      Method Name : clearSessionData
      Description : This method removes session storage data.
      Parameters  : None
      Return Type : None
    */
    clearSessionData(){ //<T03>
        sessionStorage.removeItem('tech_product');
        sessionStorage.removeItem('tech_sub');
        sessionStorage.removeItem('tech_desc');
        sessionStorage.removeItem('tech_message');               
    }
 
    //Getter Methods
    get accordionIcon() {
        return this.boolAccordionItem ? 'utility:down' : 'utility:right';
    }
 
    get acceptedFormats() {
        let lstAcceptedFileFormats = [];
        getAcceptedFileFormates()
            .then(result => {
                lstAcceptedFileFormats = result;
            });
        return lstAcceptedFileFormats;
    }
     
}