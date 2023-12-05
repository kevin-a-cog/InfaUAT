import { api, LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import COUNT_CLOUD_PRODUCT from '@salesforce/schema/Opportunity.Count_Cloud_Product__c';
import PRIMARY_QUOTE from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__c';
import PROVISIONING_ENVIRONMENT from '@salesforce/schema/Opportunity.Provisioning_Environment__c';
import ROUTE_TO_MARKET from '@salesforce/schema/Opportunity.Route_To_Market__c';
import OPP_RECORD_TYPE_NAME from "@salesforce/schema/Opportunity.RecordType.DeveloperName";
import ERP_SITE_FIELD from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__r.Sold_to_Account_ERP_Site__c';
import TAX_APPLICABLE from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__r.Tax_Applicable__c';
import ERP_SITE_EXEMPT_STATUS_FIELD from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__r.Sold_to_Account_ERP_Site__r.Exempt_Status__c';
import ERP_SITE_EXEMPT_ONFILE_FIELD from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__r.Sold_to_Account_ERP_Site__r.Exemption_On_File__c';
import ACCOUNT_HOLD from '@salesforce/schema/Opportunity.Account_Hold__c';
import NEW_LOGO_SPIFF from '@salesforce/schema/Opportunity.New_Logo_SPIFF__c';
import IPU_WARNINGS from '@salesforce/schema/Opportunity.IPU_Warnings__c';
import OPTY_STAGENAME from '@salesforce/schema/Opportunity.StageName';
import quoteBannerWarningLabel from '@salesforce/label/c.quoteBannerWarning';
import quoteBannerWarningLabel2 from '@salesforce/label/c.quoteBannerWarning2';
import opportunityWarningLabel from '@salesforce/label/c.opportunityWarningLabel';
import opptyBannerAccountMismatch from '@salesforce/label/c.quoteBannerAccountMismatch';
import opportunitySPIFF from '@salesforce/label/c.OpportunitySPIFF';
import OptyPrimaryEstimatorWarningLabel from '@salesforce/label/c.OptyPrimaryEstimatorWarning';
import OptyPrimaryEstimatorWarningLabel2 from '@salesforce/label/c.OptyPrimaryEstimatorWarning2';
import checkIPUProd from '@salesforce/apex/QuoteBannersController.checkForIPUProduct';
import accountHoldLegalCustomerBacklistBanner from '@salesforce/label/c.AccountHoldLegalCustomerBacklistBannerOnOpptynNQuote';
import  ACCOUNT_HOLD_REASON from '@salesforce/schema/Opportunity.Account.Account_Hold_Reasons__c';
import IpuWarningMessage from '@salesforce/label/c.IpuWarningMessage';
import IpuWarningVariancePercent from '@salesforce/label/c.IpuWarningVariancePercent';
import checkAllocationPR from '@salesforce/apex/OpportunityBannersController.checkAllocationPR';
import opptyBannerWarningLabel from '@salesforce/label/c.opptyBannerWarningLabel';
import checkOutOfSync from '@salesforce/apex/OpportunityBannersController.checkOutOfSync';

import OpportunityOutOfSync from '@salesforce/label/c.Opportunity_Out_Of_Sync';
import AMENDED_CONTRACTED_DATE from '@salesforce/schema/Opportunity.SBQQ__RenewedContract__r.Amendment_Contracted_Date_Time__c';
import PRIMARY_QUOTE_CREATED_DATE from '@salesforce/schema/Opportunity.SBQQ__PrimaryQuote__r.CreatedDate';

export default class OpportunityBanners extends LightningElement {

    //Labels to Display
    labels={quoteBannerWarningLabel,quoteBannerWarningLabel2,opportunityWarningLabel,opptyBannerAccountMismatch,OptyPrimaryEstimatorWarningLabel,OptyPrimaryEstimatorWarningLabel2,opportunitySPIFF,accountHoldLegalCustomerBacklistBanner,IpuWarningMessage,IpuWarningVariancePercent,opptyBannerWarningLabel,OpportunityOutOfSync};
    @track accountMismatch = false;    
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_HOLD,PRIMARY_QUOTE,ERP_SITE_FIELD,ERP_SITE_EXEMPT_STATUS_FIELD,ERP_SITE_EXEMPT_ONFILE_FIELD,ROUTE_TO_MARKET,COUNT_CLOUD_PRODUCT,PROVISIONING_ENVIRONMENT,OPP_RECORD_TYPE_NAME,TAX_APPLICABLE]})
    quote; 
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_HOLD,ROUTE_TO_MARKET,COUNT_CLOUD_PRODUCT,PROVISIONING_ENVIRONMENT,OPP_RECORD_TYPE_NAME,NEW_LOGO_SPIFF,OPTY_STAGENAME,ACCOUNT_HOLD_REASON,IPU_WARNINGS,AMENDED_CONTRACTED_DATE,PRIMARY_QUOTE_CREATED_DATE]})
    opportunity;
    accountHold;
    ipuProd;
    ipuError;
    checkAllocation = false;
    allocationError;
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
    
    @wire(checkAllocationPR, {recordId: '$recordId'})
    checkAllocation ({error, data}) { 
        if (data) { 
            this.checkAllocation = data;
        } else if (error) { 
            this.allocationError = error;
        }
    };

    get isAccountHold() {
        var accountHoldVar = getFieldValue(this.opportunity.data, ACCOUNT_HOLD);
        const accountHoldReasonVar = getFieldValue(this.opportunity.data, ACCOUNT_HOLD_REASON);
        if(Boolean(accountHoldReasonVar) && !(accountHoldReasonVar==="Legal: Customer Blacklist")){
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
        const accountHoldReasonVar = getFieldValue(this.opportunity.data, ACCOUNT_HOLD_REASON);
        return (Boolean(accountHoldReasonVar) && accountHoldReasonVar.includes("Legal: Customer Blacklist")); 
     }
     

    //IPUE-213 --> //SALESRT-15083
    get optyprimaryEst() {
        return this.ipuProd === 'FromOpportunity' ;
    }

    get optyprimaryEstFromQuote() {
        return this.ipuProd === 'FromQuote' ;
    }


    get isOppRecTypeNNBOrChannel(){
        var opptyRecordTypeName = getFieldValue(this.opportunity.data, OPP_RECORD_TYPE_NAME);
        return opptyRecordTypeName == 'New_Sales_Opportunity' || opptyRecordTypeName == 'Channel_Opportunity' ? true : false;
    }
    get isProvisioningEnvironment(){
        let provisioningEnvironmentValue = getFieldValue(this.opportunity.data, PROVISIONING_ENVIRONMENT);
        return provisioningEnvironmentValue == null ? true : false;
    }

    get isRouteToMarket(){
        let routeToMarketValue = getFieldValue(this.opportunity.data, ROUTE_TO_MARKET);
        return  routeToMarketValue == null || routeToMarketValue != 'Market Place Private' ? true : false;
    }

    get isCountCloudProduct(){
        let countCloudProductValue = getFieldValue(this.opportunity.data, COUNT_CLOUD_PRODUCT);
        return countCloudProductValue >= 1 ? true : false;
    }

    get primaryQuote(){
        return getFieldValue(this.quote.data, PRIMARY_QUOTE);
    }
    get erpSite(){
        return getFieldValue(this.quote.data, ERP_SITE_FIELD);
    }
    get status(){
        return getFieldValue(this.quote.data, ERP_SITE_EXEMPT_STATUS_FIELD);
    }

    get exemptionOnFile(){
        return getFieldValue(this.quote.data, ERP_SITE_EXEMPT_ONFILE_FIELD);
    }

    get taxApplicable(){
        return getFieldValue(this.quote.data, TAX_APPLICABLE);
    }

    get newLogoSpiff(){
        return getFieldValue(this.opportunity.data,NEW_LOGO_SPIFF);
    }

    //Set to true if Exempt Status = Needs Validation
    get StatusContent(){
        return (this.status == 'Needs Validation' && this.taxApplicable)? true : false; //TAX-362 added taxApplicable check
    }
    //Set to true if Exempt Status = Exempt and Exemption on File is False
    get StatusContent2(){
        return this.status == 'Exempt' && this.exemptionOnFile == false && this.taxApplicable ? true : false; //TAX-362 added taxApplicable check
    }

    get provisionEnvMissingBanner(){
        return this.isOppRecTypeNNBOrChannel && this.isProvisioningEnvironment && this.isRouteToMarket && this.isCountCloudProduct ? true : false;
    }

    get varianceHigherThanThreshold() {
        var ipuWarning = getFieldValue(this.opportunity.data, IPU_WARNINGS);

        return ipuWarning === 'Variance for Estimator Higher than Threshold';
    }

    get differentIpuType(){

        var ipuWarning = getFieldValue(this.opportunity.data, IPU_WARNINGS);

        return ipuWarning === 'IPU Type Difference';
    }

    get ipuErrorMessage(){
        let originalLabel = this.labels.IpuWarningMessage;
        return originalLabel.replace('{0}',this.labels.IpuWarningVariancePercent);
    }

    get hasIPUErrors(){
        return this.differentIpuType || this.varianceHigherThanThreshold;
    }

   
     
    //To check for the changes on ERP Site Record
    renderedCallback(){
        var recId = this.erpSite;

        if(this.callonce){
            this.checkshowOutOfSyncBanner();
            this.callonce = false;
        }

        window.setInterval(function(){
            getRecordNotifyChange([{recordId: recId}]);
        }, 3000);
    } 

    //SALESRT-13388
    async checkshowOutOfSyncBanner() {

        try {
            let res =  await checkOutOfSync({ opportunityId: this.recordId });
            this.showOutOfSyncBanner = res;
        } catch(e) {
          this.showOutOfSyncBanner = false; 
        }
    }

}