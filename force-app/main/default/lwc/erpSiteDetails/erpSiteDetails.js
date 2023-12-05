import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import QUOTE_SOLD_TO_ACCOUNT_ERP_SITE from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__c';
import QUOTE_EXEMPT_STATUS from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__r.Exempt_Status__c';
import QUOTE_EXEMPTION_ON_FILE from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__r.Exemption_On_File__c';
import QUOTE_LATEST_EXEMPTION_FILE_UPLOAD_DATE from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__r.Latest_Exemption_File_Upload_Date__c';//TAX-238
import EXEMPT_STATUS_FIELD from '@salesforce/schema/ERP_Site__c.Exempt_Status__c';
import EXEMPTION_ON_FILE_FIELD from '@salesforce/schema/ERP_Site__c.Exemption_On_File__c';
import checkStartDate from '@salesforce/apex/QuoteBannersController.checkStartDate';
import LATEST_EXEMPTION_FILE_UPLOAD_DATE_FIELD from '@salesforce/schema/ERP_Site__c.Latest_Exemption_File_Upload_Date__c'; //TAX-238
import ERP_SITE_ID from '@salesforce/schema/ERP_Site__c.Name'; //TAX-238

export default class ErpSiteDetails extends LightningElement {
    @api recordId;
    @track quoteRec;
    @wire(getRecord, { recordId: '$recordId', fields: [QUOTE_SOLD_TO_ACCOUNT_ERP_SITE, QUOTE_EXEMPT_STATUS, QUOTE_EXEMPTION_ON_FILE, QUOTE_LATEST_EXEMPTION_FILE_UPLOAD_DATE] }) quoteRec; //TAX-238

    get soldToAccountERPSiteId() {
        return getFieldValue(this.quoteRec.data, QUOTE_SOLD_TO_ACCOUNT_ERP_SITE);
    }
    get exemptStatus() {
        return getFieldValue(this.quoteRec.data, QUOTE_EXEMPT_STATUS);
    }
    get exemptionOnFile() {
        return getFieldValue(this.quoteRec.data, QUOTE_EXEMPTION_ON_FILE);
    }
    get latestExemptionFileUploadDate() {
        return getFieldValue(this.quoteRec.data, QUOTE_LATEST_EXEMPTION_FILE_UPLOAD_DATE); //TAX-238
    }
    get fields() {
        return [EXEMPT_STATUS_FIELD, EXEMPTION_ON_FILE_FIELD, LATEST_EXEMPTION_FILE_UPLOAD_DATE_FIELD]; //TAX-238
    }
    objApiName = 'ERP_Site__c';

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        //Check date and assign
        checkStartDate({ quoteId: this.recordId })
            .then((result) => {
                if (fields.Exempt_Status__c === 'Exempt' || fields.Exempt_Status__c === 'Override' || fields.Exempt_Status__c === 'Not Exempt') {
                    fields.Exemption_Expiry_Date__c = result;
                }
                fields.Dev_Quote_Id__c = this.recordId;
                this.template.querySelector('lightning-record-form').submit(fields);
            }).catch((error) => { });
    }
}