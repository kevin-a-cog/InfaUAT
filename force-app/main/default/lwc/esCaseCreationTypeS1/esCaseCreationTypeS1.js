import { LightningElement, wire, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import getCaseCreatedCount from '@salesforce/apex/CaseController.getCaseCreatedCount_S1';   // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
import getESupportMetadataId from '@salesforce/apex/CaseController.getESupportMetadataId';  // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';
import { getRecord } from 'lightning/uiRecordApi';                                          // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
import { ShowToastEvent } from 'lightning/platformShowToastEvent';                          // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails';

const METADATA_FIELDS = [                                                                   // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    'Service_Cloud_General_Setting__mdt.Case_Count_Maximum_Limit__c',
    'Service_Cloud_General_Setting__mdt.Case_Count_Warning_Limit__c'
];

export default class EsCaseCreationTypeS1 extends LightningElement {
    caseCreationPng = ESUPPORT_RESOURCE + '/kb.png';
    caseCreationSvg = ESUPPORT_RESOURCE + '/create_case.svg';
    caseCreationTechnical = ESUPPORT_RESOURCE + '/tech_case.svg';
    caseCreationAdmin = ESUPPORT_RESOURCE + '/admin_case.svg';
    caseCreationProduct = ESUPPORT_RESOURCE + '/prod_case.svg';

    @track accId = '';                                          // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track metadataRecordId = '';                               // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track caseCount;                                           // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track maxCaseCountLimit;                                   // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track warnCaseCountLimit;                                  // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track isProceedButtonVisible = false;                      // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track isTechCaseProceedButtonEnabled = false;              // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track isCaseCountVisible = false;                          // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    @track caseCountString = '';                                // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
    @track isTechCaseProceedButtonDisabledForMaxLimit = false;  // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
    @track prevPageURL = CommunityURL;
    @track hasReadWriteAccess = false;

    connectedCallback() {
        let url = new URL(window.location.href);
        console.log('URL = ' + url);

        let accountId = url.searchParams.get("accountId");
        console.log('AccountId = ' + accountId);

        this.accId = accountId;
        console.log('accId = ' + this.accId);

        // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
        getESupportMetadataId()
            .then(result => {
                console.log('ESupport Metadata Id Result => ' + result);
                this.metadataRecordId = result;
            })
            .catch(error => {
                console.log("ESupport Metadata Error => " + JSON.stringify(error));
            });
        // Tejasvi Royal -> I2RT-3407: Reducing Proceed Button Latency (Fix)
        getCaseCreatedCount({ accId: this.accId })
            .then(result => {
                this.caseCount = parseInt(result);
                console.log("Case Counts Data -> " + this.caseCount);
            })
            .catch(error => {
                console.log("Case Counts error => " + JSON.stringify(error));
            });       
        
        // Clear case creation drafted data 
        if (!(document.referrer.includes('newadmincase') || document.referrer.includes('newfulfillmentcase') || document.referrer.includes('newtechnicalcase'))){
            this.clearCaseCreationSessionData();
        }

        getSupportContactDetails({ caseId: '', supportAccountId: accountId })
        .then(result => {
            if(result != undefined && result != null){
                this.hasReadWriteAccess = result.isReadWrite;
            }
        })
        .catch(error => {
            console.log('Contact details Error => '+JSON.stringify(error))
        });
    }

    renderedCallback() {}

    @wire(getRecord, { recordId: '$metadataRecordId', fields: METADATA_FIELDS })
    metadataRecord({ error, data }) {
        if (data) {
            console.log("Watch: metadataRecord data -> " + JSON.stringify(data));

            this.maxCaseCountLimit = parseInt(data.fields.Case_Count_Maximum_Limit__c.value); // UPPER LIMIT
            console.log("Watch: maxCaseCountLimit -> " + this.maxCaseCountLimit);

            this.warnCaseCountLimit = parseInt(data.fields.Case_Count_Warning_Limit__c.value); // LOWER LIMIT
            console.log("Watch: warnCaseCountLimit -> " + this.warnCaseCountLimit);

            if((this.caseCount == 0 || this.caseCount) && this.maxCaseCountLimit && this.warnCaseCountLimit) { // IF: All counts present
                this.handleCaseCountAndProceedButton();                               // THEN: call handleCaseCountAndProceedButton()
            }
        } else if (error) {
            console.log("Watch: metadataRecord error -> " + JSON.stringify(error));
        }
    }

    // Tejasvi Royal -> I2RT-3434: Case Count Calc. (Enhancement Clone)
    handleUpgradeMessage() {
        let msg = 'WARNING: You are approaching maximum case limit for your product entitlement. For more information, please email iCare@informatica.com.';
        if (this.caseCount >= this.maxCaseCountLimit) {
            msg = 'WARNING: You have reached the maximum limit for your product entitlement. For more information, please email iCare@informatica.com.';
        }
        const event = new ShowToastEvent({
            title: 'Informatica says:',
            message: msg,
            variant: 'warning',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    // Tejasvi Royal -> I2RT-3407: Reducing Proceed Button Latency (Fix)
    handleCaseCountAndProceedButton() {
            this.isTechCaseProceedButtonEnabled = this.caseProceedButtonEnabled(this.caseCount, this.maxCaseCountLimit);
            this.isProceedButtonVisible = ((this.caseCount == 0 || this.caseCount) && this.maxCaseCountLimit && this.warnCaseCountLimit) ? true : false;
            this.isCaseCountVisible = this.caseCountVisible(this.caseCount, this.warnCaseCountLimit, this.maxCaseCountLimit);
            if(this.caseCount >= this.warnCaseCountLimit && this.caseCount < this.maxCaseCountLimit) {
                this.caseCountString = this.caseCount + ' of ' + this.maxCaseCountLimit + ' cases opened in this year.';
            }
            if (this.caseCount >= this.maxCaseCountLimit) {
                this.caseCountString = 'You have reached the maximum limit for your product entitlement. For more information, please email iCare@informatica.com.';
                this.isTechCaseProceedButtonDisabledForMaxLimit = true;
            }

            console.log('Counts finally persisted -> ' + this.caseCount + ', ' + this.maxCaseCountLimit + ', ' + this.warnCaseCountLimit);
            console.log('Enabled: Tech Case Proceed Button -> ' + this.isTechCaseProceedButtonEnabled);
            console.log('Visibility: Proceed Button -> ' + this.isProceedButtonVisible);
            console.log('Visibility: Case Count -> ' + this.isCaseCountVisible);
            console.log("Count Logging -> " + this.caseCountConsoleLogging(this.caseCount, this.warnCaseCountLimit, this.maxCaseCountLimit));
    }

    // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    caseProceedButtonEnabled(caseCount, maxCaseCountLimit) {
        if (caseCount >= maxCaseCountLimit) return false;
        return true;
    }

    // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    caseCountVisible(caseCount, warnCaseCountLimit, maxCaseCountLimit) {
        if (caseCount >= warnCaseCountLimit && caseCount <= maxCaseCountLimit) return true;
        if (caseCount < warnCaseCountLimit || caseCount > maxCaseCountLimit) return false;
        return false;
    }

    // Tejasvi Royal -> I2RT-2136: Case Count Calc. (Original)
    caseCountConsoleLogging(caseCount, warnCaseCountLimit, maxCaseCountLimit) {
        if (caseCount === -2) return 'caseCount -> Not a Basic Support Account.';
        //if (caseCount === -3) return 'caseCount -> Basic Support Selected, but Multiple Support Accounts Present.';
        if (caseCount < warnCaseCountLimit || caseCount > maxCaseCountLimit) return 'caseCount -> Not in range of Warn & Max Limits.';
        if (caseCount >= warnCaseCountLimit && caseCount <= maxCaseCountLimit) return 'caseCount -> Should be visible on screen.';
        return '--Log Default--';
    }

    backButton() {
        this.clearCaseCreationSessionData();
        window.open(this.prevPageURL, '_self');
    }

    cases = [
        {
            Id: 1,
            Title: 'Technical',
            Items: ['Product usage', 'Troubleshooting', 'Compatibility', 'Documentation', 'PAM', 'Milestone Support'],
            //Items: ['Product usage','Troubleshooting','Compatibility','Documentation'],
            Upgrade: true,
            Img: this.caseCreationTechnical,
            Multicolumn: 'es-card__list es-card__list--multicolumn',
            Link: 'newtechnicalcase',
            CaseTypeTechnical: true
        },
        {
            Id: 2,
            Title: 'Product Download & License Request',
            Items: ['License Keys', 'Org IDs', 'Product/Software Download', 'POC Product'],
            Upgrade: false,
            Img: this.caseCreationAdmin,
            Multicolumn: 'es-card__list',
            Link: 'newfulfillmentcase',
            CaseTypeTechnical: false
        },
        {
            Id: 3,
            Title: 'Support Account Administration',
            Items: ['Contact Changes', 'Support Account', 'Entitlements', 'Access to the Portal', 'End of Support'],
            Upgrade: false,
            Img: this.caseCreationProduct,
            Multicolumn: 'es-card__list es-card__list--multicolumn',
            Link: 'newadmincase',
            CaseTypeTechnical: false
        }
    ];

    clearCaseCreationSessionData(){
        // Technical case creation info
        sessionStorage.removeItem('tech_account');
        sessionStorage.removeItem('tech_product');
        sessionStorage.removeItem('tech_version');
        sessionStorage.removeItem('tech_orgName');
        sessionStorage.removeItem('tech_secureAgent');
        sessionStorage.removeItem('tech_activity');
        sessionStorage.removeItem('tech_env');
        sessionStorage.removeItem('tech_relatedComp');
        sessionStorage.removeItem('tech_priority');
        sessionStorage.removeItem('tech_sub');
        sessionStorage.removeItem('tech_desc');
        sessionStorage.removeItem('tech_message');
        sessionStorage.removeItem('tech_impact');
        sessionStorage.removeItem('tech_milestone');
        sessionStorage.removeItem('tech_date');
        
        // Product case creation info
        sessionStorage.removeItem('prod_account');
        sessionStorage.removeItem('prod_product');
        sessionStorage.removeItem('prod_priority');
        sessionStorage.removeItem('prod_env');
        sessionStorage.removeItem('prod_sub');
        sessionStorage.removeItem('prod_desc');

        // Admin case creation info
        sessionStorage.removeItem('admin_account');
        sessionStorage.removeItem('admin_priority');
        sessionStorage.removeItem('admin_area');
        sessionStorage.removeItem('admin_sub');
        sessionStorage.removeItem('admin_desc');


    }

    createCase(event){
        if(this.hasReadWriteAccess){
             /** START-- adobe analytics */
            try {
                let caseType = event.target.dataset.name;
                util.trackCreateCase(caseType, "Started");
            }
            catch(ex) {
                console.log(ex.message);
            }
            /** END-- adobe analytics*/
            return true;
        }
        else{
            event.preventDefault();
            this.showToastEvent('Error', 'You do not have access to create case for this Support Account.', 'error', 'dismissable');
        }
    }

    showToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(event);
    }
}