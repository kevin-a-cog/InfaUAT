import { LightningElement,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
//Labels
import QuoteOrderDiffAmount from '@salesforce/label/c.Quote_Order_Diff_Amount_Message';
import PaymentTermMissing from '@salesforce/label/c.Payment_Term_Missing_Msg';
import BillPlansMissing from '@salesforce/label/c.NoInvSch';
import BSBTMissing from '@salesforce/label/c.Billing_Schedule_Transaction_Missing';
import TaxNeedsValidation from '@salesforce/label/c.TaxExemptNeedsValidation';
import AdjustCodeMissing from '@salesforce/label/c.AdjustmentReasonCodeMissing';
import AmendErr from '@salesforce/label/c.AmendTypeBlankError';
import termForConvenience from '@salesforce/label/c.termForConvenience';
import MaterialRightsBannerMessage from '@salesforce/label/c.MaterialRightsBannerMessage';
import relRevOrderMissingBanner from '@salesforce/label/c.RelRevOrderMissingBanner';
import relRevOrderCalculatingBanner from '@salesforce/label/c.RelRevOrderCalculatingBanner';
import validateBillingBanner from '@salesforce/label/c.validateBillingBanner';
//Apex
import loadOrderData from '@salesforce/apex/QuoteOrderAmountDifferenceBanner.loadOrderData';


export default class OrderAmountDifferenceBannerLWC extends LightningElement {
    @api recordId;
    wiredOrderData;
    errorMsg;
    orderObj;
    loadUI = false; 
        
    @wire(loadOrderData, {recordId: '$recordId'}) 
    wiredloadOrderData(response) {
        const { data, errorMsg } = response;
        this.wiredOrderData = response; // track the provisioned value
        if (data){
            this.orderObj = [];
            this.orderObj.push({key: 'QuoteOrderDiffAmount', label: QuoteOrderDiffAmount, display: data.diffAmtGreaterThanOne});
            this.orderObj.push({key: 'PaymentTermMissing', label: PaymentTermMissing, display: data.ptNotAvailable});
            this.orderObj.push({key: 'BillPlansMissing', label: BillPlansMissing, display: data.bpNotExists});
            this.orderObj.push({key: 'BSBTMissing', label: BSBTMissing, display: data.bsbtNotExist});
            this.orderObj.push({key: 'TaxNeedsValidation', label: TaxNeedsValidation, display: data.exemptNeedsValidation});
            this.orderObj.push({key: 'AdjustCodeMissing', label: AdjustCodeMissing, display: data.adjCodeNotExist});
            this.orderObj.push({key: 'AmendErr', label: AmendErr, display: data.amendTypeBlank});
            this.orderObj.push({key: 'termForConvenience', label: termForConvenience, display: data.termForConvenience});
            this.orderObj.push({key: 'MaterialRightsBannerMessage', label: MaterialRightsBannerMessage, display: data.MaterialRightsBannerMessage});
            this.orderObj.push({key: 'relRevOrderMissingBanner', label: relRevOrderMissingBanner, display: data.RelRevOrderBannerMessage});
            this.orderObj.push({key: 'relRevOrderCalculatingBanner', label: relRevOrderCalculatingBanner, display: data.RelRevOrderCalculatingMessage});
            this.orderObj.push({key: 'validateBillingBanner', label: validateBillingBanner, display: data.validateBillingMessage});
            this.loadUI = true;
        }  
        else {
            this.errorMsg = errorMsg;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Amendment_Type__c'] })
    getorderRecord({ data, error }) {
        if (data) {
            refreshApex(this.wiredOrderData);
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }
    
}