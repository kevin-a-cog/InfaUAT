import { api, LightningElement, track, wire } from 'lwc';
import checkEarlyTerminate from '@salesforce/apex/QuoteBannersController.checkEarlyTerminate';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import ERP_SITE_FIELD from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__c';
import ERP_SITE_EXEMPT_STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__r.Exempt_Status__c';
import ERP_SITE_EXEMPT_ONFILE_FIELD from '@salesforce/schema/SBQQ__Quote__c.Sold_to_Account_ERP_Site__r.Exemption_On_File__c';
import CO_TERM_LONG from '@salesforce/schema/SBQQ__Quote__c.Co_Term_Long__c';
import ACCOUNT_HOLD from '@salesforce/schema/SBQQ__Quote__c.Account_Hold__c';
import Quote_Header_Start_Date from '@salesforce/schema/SBQQ__Quote__c.SBQQ__StartDate__c';
import GetQuoteLineItemsStartDate from '@salesforce/apex/QuoteBannersController.getQuoteLineItemsStartDate';
import quoteBannerCoTermLongLabel from '@salesforce/label/c.quoteBannerCoTermLong';
import quoteBannerWarningLabel from '@salesforce/label/c.quoteBannerWarning';
import quoteBannerWarningLabel2 from '@salesforce/label/c.quoteBannerWarning2';
import quoteStartDateWarningLabel from '@salesforce/label/c.quoteStartDateWarning';
import checkInactPBE from '@salesforce/apex/QuoteBannersController.checkInactivePBE';
import ORDERED from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Ordered__c';
import quoteBannerInactivePBE from '@salesforce/label/c.quoteBannerInactivePBE';
import checkParties from '@salesforce/apex/QuoteBannersController.checkParties';
import { refreshApex } from '@salesforce/apex';
import checkAccounts from '@salesforce/apex/QuoteBannersController.checkaccounts';
import quoteLineStartDate from '@salesforce/label/c.Quote_Line_Start_Date_Alert_Message';
import checkQuoteLineStartDate from '@salesforce/apex/QuoteBannersController.checkQuoteLineStartDate';
import quoteBannerAccountMismatchForAmend from '@salesforce/label/c.quoteBannerAccountMismatchForAmend';
import quoteBannerAccountMismatchForNewOrRenewal from '@salesforce/label/c.quoteBannerAccountMismatchForNewOrRenewal';
import QUOTE_TYPE from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Type__c';
import accountHoldLegalCustomerBacklistBanner from '@salesforce/label/c.AccountHoldLegalCustomerBacklistBannerOnOpptynNQuote';
import  ACCOUNT_HOLD_REASON from '@salesforce/schema/SBQQ__Quote__c.Account_Hold_Reason__c';
import  RTM_DETAILS from '@salesforce/schema/SBQQ__Quote__c.Detail_RTM__c';
import  SOLDTO_ACCOUNT_RECORD_TYPE_NAME from '@salesforce/schema/SBQQ__Quote__c.SoldToAccount__r.RecordType.DeveloperName';
import RTM_Details_is_AWS_Via_Partner_Banner_Message from '@salesforce/label/c.RTM_Details_is_AWS_Via_Partner_Banner_Message';
import quoteBannerDefaultQLETerm from '@salesforce/label/c.quoteBannerDefaultQLETerm'; //SALESRT-13539
import TAX_APPLICABLE from '@salesforce/schema/SBQQ__Quote__c.Tax_Applicable__c'; //TAX-298
import getQuoteLineItemsSubTermOutput from '@salesforce/apex/QuoteBannersController.getQuoteLineItemsSubTermOutput';
import checkIPUProd from '@salesforce/apex/QuoteBannersController.checkForIPUProductQuoteOnly';
import checkOutOfSync from '@salesforce/apex/QuoteBannersController.checkOutOfSync';

import BILL_TO_ACCOUNT_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.BillToAccount__r.BillingCountry';
import SHIP_TO_ACCOUNT_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.ShiptToAccount__r.BillingCountry';
import SOLD_TO_ACCOUNT_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.SoldToAccount__r.BillingCountry';
import END_USER_ACCOUNT_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.EndUserAccount__r.BillingCountry';
import BILL_TO_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.SBQQ__BillingCountry__c';
import SHIP_TO_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.SBQQ__ShippingCountry__c';
import SOLD_TO_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.SoldCountry__c';
import END_USER_COUNTRY from '@salesforce/schema/SBQQ__Quote__c.EndUserCountry__c';
import addressCountryMisMatch from '@salesforce/label/c.addressCountryMisMatch';

import QUOTE_IPU_WARNING from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.IPU_Warnings__c';
import OPPORTUNITY_PRIMARY_QUOTE from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c';
import PRIMARY_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Primary__c';
import SOG_ACTIVE from '@salesforce/schema/SBQQ__Quote__c.Price_Holds__c';
import IpuWarningMessage from '@salesforce/label/c.IpuWarningMessage';
import IpuWarningVariancePercent from '@salesforce/label/c.IpuWarningVariancePercent';
import QuoteOutOfSync from '@salesforce/label/c.Quote_Out_Of_Sync';
import OptyPrimaryEstimatorWarningLabel from '@salesforce/label/c.OptyPrimaryEstimatorWarning2';
import AMENDED_CONTRACTED_DATE from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Amendment_Contracted_Date_Time__c';
import PRIMARY_QUOTE_CREATED_DATE from '@salesforce/schema/SBQQ__Quote__c.CreatedDate';
import LEGAL_ACCOUNT_HOLD from '@salesforce/schema/SBQQ__Quote__c.Legal_Account_Hold__c';
import LegalAccountHoldError from '@salesforce/label/c.LegalAccountHoldError';

export default class QuoteBanners extends LightningElement {
    //Labels to Display
    labels = { quoteBannerWarningLabel, quoteBannerWarningLabel2,quoteBannerCoTermLongLabel,quoteBannerInactivePBE, quoteStartDateWarningLabel, quoteLineStartDate, quoteBannerAccountMismatchForAmend, quoteBannerAccountMismatchForNewOrRenewal, accountHoldLegalCustomerBacklistBanner,RTM_Details_is_AWS_Via_Partner_Banner_Message, quoteBannerDefaultQLETerm,addressCountryMisMatch,IpuWarningMessage,IpuWarningVariancePercent,QuoteOutOfSync,OptyPrimaryEstimatorWarningLabel,
        LegalAccountHoldError}; //SALESRT-13539- Added quoteBannerDefaultQLETerm
    @track coTermLongErr = false;     
    @track inactivePBEErr = false;
    @track quoteStartDate = true;  
    @track checkQLIItemDate = false;  
    @api recordId;
    @track newOrRenewalQMismatch = false;
    @track amendQMismatch = false;
    @track isQleTermLessThanAMonth = false; //SALESRT-13539

    ipuWarning = '';
    ipuProd;
    ipuError;
    showOutOfSyncBanner = false;
    callonce = true;

    @wire(checkIPUProd, {recordId: '$recordId'})
    ipuProd ({error, data}) { 
        if (data) { 
            this.ipuProd = data;
        } else if (error) { 
            this.ipuError = error;
        }
    }
     
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_HOLD,CO_TERM_LONG,ERP_SITE_FIELD, ERP_SITE_EXEMPT_STATUS_FIELD, ERP_SITE_EXEMPT_ONFILE_FIELD,ORDERED,Quote_Header_Start_Date ,QUOTE_TYPE,ACCOUNT_HOLD_REASON,RTM_DETAILS,SOLDTO_ACCOUNT_RECORD_TYPE_NAME, TAX_APPLICABLE,
        BILL_TO_ACCOUNT_COUNTRY,SHIP_TO_COUNTRY,SOLD_TO_ACCOUNT_COUNTRY,END_USER_ACCOUNT_COUNTRY,BILL_TO_COUNTRY,SHIP_TO_COUNTRY,SHIP_TO_COUNTRY,END_USER_COUNTRY,QUOTE_IPU_WARNING,SOG_ACTIVE,PRIMARY_FIELD,OPPORTUNITY_PRIMARY_QUOTE,AMENDED_CONTRACTED_DATE,PRIMARY_QUOTE_CREATED_DATE,
        LEGAL_ACCOUNT_HOLD] })
    quote;
    accountHold;
    RTMError;
    wiredRecords;
    error;

    //Method for RTM - <SALESRT-13225>
    @wire(checkParties, {quoteId: '$recordId'}) 
    wiredQuote(response) {
        const { data, error } = response;
        this.wiredRecords = response; // track the provisioned value
        this.RTMError = '';  
        if (data) {  
            let message = data;
                this.RTMError = message; 
        }  
        else {
            this.error = error;
        } 
    }

    get optyprimaryEst() {
        return this.ipuProd ;
    }

    get coTermLong() {
        var coTermLong1 = getFieldValue(this.quote.data, CO_TERM_LONG);
        if(coTermLong1 == true){
            checkEarlyTerminate({ quoteId: this.recordId })
            .then((result) => {
                if(result == true){
                    this.coTermLongErr = true;
                }            
            }).catch((error) => {});
        }
        return coTermLong1;
    }

        get checkInactivePBE() {          
            var ordervar = getFieldValue(this.quote.data, ORDERED);            
            if(ordervar == false){
            checkInactPBE({ quoteId: this.recordId })
            .then((result) => {
                this.inactivePBEErr = result;     
               }).catch((error) => {  console.log("error " + error);});           
        }                         
            return !ordervar;
        }

        get checkAccounts() {       
                checkAccounts({ quoteId: this.recordId })
                .then((result) => { if(result == true)
                    {
                      var quoteType = getFieldValue(this.quote.data, QUOTE_TYPE); 
                      if(quoteType == "Quote" || quoteType == "Renewal")
                          this.newOrRenewalQMismatch = true;
                      
                      if(quoteType == "Amendment")
                        this.amendQMismatch = true;
                 
                    } 
               }).catch((error) => {  console.error("error in quoteBanner Account Mismatch");});                                   
            return true;
        }
    
    get erpSite() {
        return getFieldValue(this.quote.data, ERP_SITE_FIELD);
    }
    get status() {
        return getFieldValue(this.quote.data, ERP_SITE_EXEMPT_STATUS_FIELD);
    }
    
    get isAccountHold() {
        const accountHoldVar = getFieldValue(this.quote.data, ACCOUNT_HOLD);
        const accountHoldReasonVar = getFieldValue(this.quote.data, ACCOUNT_HOLD_REASON);
        if(Boolean(accountHoldReasonVar) && !(accountHoldReasonVar === "Legal: Customer Blacklist")){
        if(Boolean(accountHoldVar)){
            this.accountHold = accountHoldVar;
            return true;
        }else{
            return false;
        }        
        }else{
            return false;
        }       
    }
    
    //check for any of account is marked as "Legal: Customer Backlist".
    get isAccountHoldLegalCustomerBacklist() {
       const accountHoldReasonVar = getFieldValue(this.quote.data, ACCOUNT_HOLD_REASON);
        return (Boolean(accountHoldReasonVar) && accountHoldReasonVar.includes("Legal: Customer Blacklist")); 
   }

   //check for any of RTM is MP and Sold To Account is not partner
   get isRTMDetails_Is_AWSPartner() {
    const isAWSPartner = getFieldValue(this.quote.data, RTM_DETAILS);
    const soldToRecordType = getFieldValue(this.quote.data, SOLDTO_ACCOUNT_RECORD_TYPE_NAME);
     return isAWSPartner && soldToRecordType && (isAWSPartner.indexOf("Amazon AWS via Partner") > -1 && (soldToRecordType.indexOf("Partner_Account") === -1 && soldToRecordType.indexOf("Potential_Partner_Account") === -1 )); 
}

    get isStartDateOnQuoteHeaderIsLater() {
        var quoteHeaderStartDate = getFieldValue(this.quote.data, Quote_Header_Start_Date);
        if(quoteHeaderStartDate !== undefined){
            GetQuoteLineItemsStartDate({ quoteId: this.recordId, headerStartDate:  quoteHeaderStartDate}).then((data) => {
                    this.quoteStartDate = data;
               }).catch((error) => {  console.log("error " + error);});  
        
            if(this.quoteStartDate === false){
                return true;
            } else{
                return false;
            }
        }
    }

    get exemptionOnFile() {
        return getFieldValue(this.quote.data, ERP_SITE_EXEMPT_ONFILE_FIELD);
    }
    get taxApplicable() { //TAX-298
        return getFieldValue(this.quote.data, TAX_APPLICABLE);
    }
    //If Exempt Status = Needs Validation
    get StatusContent() {
        return (this.status == 'Needs Validation' && this.taxApplicable)? true : false; //TAX-298 added taxApplicable check
    }
    //If Exempt Status = Exempt AND Exemption On File = false
    get StatusContent2() {
        return this.status == 'Exempt' && this.exemptionOnFile == false && this.taxApplicable ? true : false; //TAX-298 added taxApplicable check
    }


    getCheckQuoteLineStartDate() {          
        checkQuoteLineStartDate({ quoteId: this.recordId })
        .then((result) => {
            this.checkQLIItemDate = result;
            return result;     
        }).catch((error) => {  console.log("error " + error);});
    }
    
    //SALESRT-13539 START
    checkQleTermLessThanAMonth() {
        console.log('inside the methoodd');
        getQuoteLineItemsSubTermOutput({ quoteId: this.recordId}).then((data) => {
                this.isQleTermLessThanAMonth = data;
            }).catch((error) => {  console.log("error in Nishit" + error);});  
    }
    //SALESRT-13539
    
    //To check the change on ERP Site Record
    renderedCallback() {
        var recId = this.erpSite;
        
        if(this.callonce){
            this.checkshowOutOfSyncBanner();
            this.callonce = false;
        }

        window.setInterval(function () {
            getRecordNotifyChange([{ recordId: recId }]);
        }, 3000);
        //refresh the wired method     
        return refreshApex(this.wiredRecords);
    }

    connectedCallback(){
        this.getCheckQuoteLineStartDate();
        this.checkQleTermLessThanAMonth();
    }

    get isCountryMisMatch() {
        let billToAccCountry = getFieldValue(this.quote.data, BILL_TO_ACCOUNT_COUNTRY);
        let shipToAccCountry = getFieldValue(this.quote.data, SHIP_TO_ACCOUNT_COUNTRY);
        let soldToAccCountry = getFieldValue(this.quote.data, SOLD_TO_ACCOUNT_COUNTRY);
        let endUserAccCountry = getFieldValue(this.quote.data, END_USER_ACCOUNT_COUNTRY);

        let billToCountry = getFieldValue(this.quote.data, BILL_TO_COUNTRY);
        let shipToCountry = getFieldValue(this.quote.data, SHIP_TO_COUNTRY);
        let soldToCountry = getFieldValue(this.quote.data, SOLD_TO_COUNTRY);
        let endUserCountry = getFieldValue(this.quote.data, END_USER_COUNTRY);

        if(billToAccCountry !== undefined && billToCountry !== undefined && billToAccCountry !== null && billToCountry !== null && (billToAccCountry.toLowerCase() != billToCountry.toLowerCase()) || 
        shipToCountry !== undefined && shipToAccCountry !== undefined && shipToCountry !== null && shipToAccCountry !== null && (shipToAccCountry.toLowerCase() != shipToCountry.toLowerCase()) || 
        soldToAccCountry !== undefined && soldToCountry !== undefined && soldToAccCountry !== null && soldToCountry !== null && (soldToAccCountry.toLowerCase() != soldToCountry.toLowerCase()) ||
        endUserAccCountry !== undefined && endUserCountry !== undefined && endUserAccCountry !== null && endUserCountry !== null && (endUserAccCountry.toLowerCase() != endUserCountry.toLowerCase())){
            return true;
        }else{
            return false;
        }
    }

    get varianceHigherThanThreshold() {

        let primary = getFieldValue(this.quote.data, PRIMARY_FIELD);
        let sogActive = getFieldValue(this.quote.data, SOG_ACTIVE);
        let opportunityPrimaryQuote = getFieldValue(this.quote.data, OPPORTUNITY_PRIMARY_QUOTE);
        
        if(primary || (sogActive && opportunityPrimaryQuote === null)){
            var ipuWarning = getFieldValue(this.quote.data, QUOTE_IPU_WARNING);
            return ipuWarning === 'Variance for Estimator Higher than Threshold';
        }
    }

    get differentIpuType(){

        let primary = getFieldValue(this.quote.data, PRIMARY_FIELD);
        let sogActive = getFieldValue(this.quote.data, SOG_ACTIVE);
        let opportunityPrimaryQuote = getFieldValue(this.quote.data, OPPORTUNITY_PRIMARY_QUOTE);
        
        if(primary || (sogActive && opportunityPrimaryQuote === null)){
            var ipuWarning = getFieldValue(this.quote.data, QUOTE_IPU_WARNING);
            return ipuWarning === 'IPU Type Difference';
        }
    }

    get ipuErrorMessage(){
        let originalLabel = this.labels.IpuWarningMessage;
        return originalLabel.replace('{0}',this.labels.IpuWarningVariancePercent);
    }

    get hasIPUErrors(){
        return this.differentIpuType || this.varianceHigherThanThreshold;
    }

    //SALESRT-13388
    async checkshowOutOfSyncBanner() {
        
        try {
            let res =  await checkOutOfSync({ quoteId: this.recordId });
            this.showOutOfSyncBanner = res;
        } catch(e) {
          this.showOutOfSyncBanner = false; 
        }
    }

    get legalHoldOnAccount(){
        let holdValue = getFieldValue(this.quote.data, LEGAL_ACCOUNT_HOLD);
        return holdValue;
    }

}