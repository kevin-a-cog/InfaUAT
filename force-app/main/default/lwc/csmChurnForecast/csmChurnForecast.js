/* Name			    :	CsmChurnForecast
* Author		    :	Karthi G
* Created Date	    :   31/03/2023
* Description	    :	CsmChurnForecast controller.

Change History
*************************************************************************************************************************
Modified By			Date			  Jira No.	      	Description				                      	Tag
*************************************************************************************************************************
Karthi G         31/03/2023           AR-3141          Initial version                                Initial
*************************************************************************************************************************
*/

import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import CURRENCY from '@salesforce/i18n/currency';
import LOCALE from '@salesforce/i18n/locale';
//Apex methods
import saveChurn from "@salesforce/apex/CSMChurnForecastController.saveChurnForecast";
import getOpty from "@salesforce/apex/CSMChurnForecastController.getOptyRecords";
//Utility import
import { objUtilities } from 'c/globalUtilities';
//Custom Labels
import CloudChurnHelpText from '@salesforce/label/c.CloudChurnHelpText';
import CloudSwingHelpText from '@salesforce/label/c.CloudSwingHelpText';
import OnPremChurnHelpText from '@salesforce/label/c.OnPremChurnHelpText';
import OnPremSwingHelpText from '@salesforce/label/c.OnPremSwingHelpText';

export default class CsmChurnForecast extends LightningElement {
    //API variables
    @api recordId;    
    @api pafRisk;
    //private variables
    showSpinner=true;
    @track optydata=[];
    activeSection =[];
    @track initData;
    showRisk=false;
    rangeMsg = 'Enter a value between 0 and 100';

    label={CloudChurnHelpText,CloudSwingHelpText,OnPremChurnHelpText,OnPremSwingHelpText};

    @api
    refreshCard(){
        refreshApex(this.initData);
    }

    //get renewal opportunity related to the plan
    @wire(getOpty, { planId: '$recordId' })
    wiredOpty(value) {        
        this.initData=value;
        const { data, error } = value;
        if (data) {
            data.forEach((opty)=>{
                let obj=Object.assign({},opty.opty);
                //determine if cloud section to be shown
                obj.displayCloud = obj.OARR_Cloud1__c>0;
                obj.optyURL = '/'+obj.Id;
                //determine if On-Prem section to be shown
                obj.displayonPrem = obj.OARR_OnPrem_Subscription1__c>0;
                obj.showMultiplePlanBanner = opty.showMultiplePlanBanner;
                obj.lastModifiedby = opty.lastModifiedby;
                obj.lastModifieddate = opty.lastModifieddate;
                obj.cloudSwingrequired = obj.Cloud_Churn_Forecast_Percent__c>0;
                obj.opSwingrequired = obj.On_Prem_Churn_Forecast_Percent__c>0;                
                obj.commentrequired  = obj.Cloud_Churn_Forecast__c>0 || obj.On_Premise_Churn_Forecast__c>0;

                //default expanded accordion section         
                this.activeSection.push(obj.Id);
                this.optydata.push(obj);                
            });   
            this.showSpinner=false;
        } else if (error) {
            console.log(error);
            this.showSpinner=false;
        }
    }

    //method to handle close or cancel
    handleCancel(event){
        //event detail to be used to open risk component if invoked from PAF
        const closeEvent = new CustomEvent('closemodal',{ detail: this.showRisk || this.pafRisk });
        this.dispatchEvent(closeEvent);
	}

    //Handle % value changes on the input field to calculate amount
    handleChange(event){
        this.showSpinner=true;        
        let oppId=event.target.dataset.id;
        let field=event.target.dataset.field;
        let val=(field==='CSM_Comments__c' || event.target.value==='')?event.target.value : parseFloat(event.target.value);
        
        let tempArray =  [];
        this.optydata.forEach((opty)=>{
            if(opty.Id==oppId){
                opty[field]=val;
                //const desiredString = `USD ${result.Price__c} (${CURRENCY} ${result.ConvertedPrice__c})`;
                if(field!=='CSM_Comments__c'){
                    if(field==='Cloud_Churn_Forecast_Percent__c' && (opty.Cloud_Churn_Forecast_Percent__c===undefined || opty.Cloud_Churn_Forecast_Percent__c===0 || opty.Cloud_Churn_Forecast_Percent__c==='')){
                        opty.Cloud_Swing_Forecast_Percent__c=opty.Cloud_Churn_Forecast_Percent__c;
                    }

                    if(field==='On_Prem_Churn_Forecast_Percent__c' && (opty.On_Prem_Churn_Forecast_Percent__c===undefined || opty.On_Prem_Churn_Forecast_Percent__c===0 || opty.On_Prem_Churn_Forecast_Percent__c==='')){
                        opty.On_Prem_Swing_Forecast_Percent__c=opty.On_Prem_Churn_Forecast_Percent__c;
                    }
                    //DOLLAR Fields Calculation
                    opty.Cloud_Churn_Forecast__c = parseFloat((opty.OARR_Cloud1__c*opty.Cloud_Churn_Forecast_Percent__c/100).toFixed(2));
                    opty.On_Premise_Churn_Forecast__c = parseFloat((opty.OARR_OnPrem_Subscription1__c*opty.On_Prem_Churn_Forecast_Percent__c/100).toFixed(2));
                    opty.Cloud_Swing_Forecast__c = parseFloat((opty.Cloud_Churn_Forecast__c*opty.Cloud_Swing_Forecast_Percent__c/100).toFixed(2));
                    opty.On_Premise_Swing_Forecast__c = parseFloat((opty.On_Premise_Churn_Forecast__c*opty.On_Prem_Swing_Forecast_Percent__c/100).toFixed(2));

                    //Locale currency fields calcauation
                    opty.cloudChurn_converted = parseFloat((opty.cloudOARR_converted*opty.Cloud_Churn_Forecast_Percent__c/100).toFixed(2));
                    opty.onPremChurn_converted = parseFloat((opty.onPremOARR_converted*opty.On_Prem_Churn_Forecast_Percent__c/100).toFixed(2));
                    opty.cloudSwing_converted = parseFloat((opty.cloudChurn_converted*opty.Cloud_Swing_Forecast_Percent__c/100).toFixed(2));
                    opty.onPremSwing_converted = parseFloat((opty.onPremChurn_converted*opty.On_Prem_Swing_Forecast_Percent__c/100).toFixed(2));

                    //prepare formatted field to display
                    if(opty.CurrencyIsoCode===CURRENCY){
                        opty.cloudChurn_format = isNaN(opty.cloudChurn_converted) || isNaN(opty.Cloud_Churn_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.Cloud_Churn_Forecast__c)}`;
                        opty.onPremChurn_format = isNaN(opty.onPremChurn_converted) || isNaN(opty.On_Premise_Churn_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.On_Premise_Churn_Forecast__c)}`;
                        opty.cloudSwing_format = isNaN(opty.cloudSwing_converted) || isNaN(opty.Cloud_Swing_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.Cloud_Swing_Forecast__c)}`;
                        opty.onPremSwing_format = isNaN(opty.onPremSwing_converted) || isNaN(opty.On_Premise_Swing_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.On_Premise_Swing_Forecast__c)}`;
                    }
                    else{
                        opty.cloudChurn_format = isNaN(opty.cloudChurn_converted) || isNaN(opty.Cloud_Churn_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.Cloud_Churn_Forecast__c)} (${CURRENCY} ${new Intl.NumberFormat(LOCALE).format(opty.cloudChurn_converted)})`;
                        opty.onPremChurn_format = isNaN(opty.onPremChurn_converted) || isNaN(opty.On_Premise_Churn_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.On_Premise_Churn_Forecast__c)} (${CURRENCY} ${new Intl.NumberFormat(LOCALE).format(opty.onPremChurn_converted)})`;
                        opty.cloudSwing_format = isNaN(opty.cloudSwing_converted) || isNaN(opty.Cloud_Swing_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.Cloud_Swing_Forecast__c)} (${CURRENCY} ${new Intl.NumberFormat(LOCALE).format(opty.cloudSwing_converted)})`;
                        opty.onPremSwing_format = isNaN(opty.onPremSwing_converted) || isNaN(opty.On_Premise_Swing_Forecast__c)?'':`${opty.CurrencyIsoCode} ${new Intl.NumberFormat(LOCALE).format(opty.On_Premise_Swing_Forecast__c)} (${CURRENCY} ${new Intl.NumberFormat(LOCALE).format(opty.onPremSwing_converted)})`;
                    }
                    
                }
                
                opty.cloudSwingrequired = opty.Cloud_Churn_Forecast_Percent__c>0;
                opty.opSwingrequired = opty.On_Prem_Churn_Forecast_Percent__c>0;
                opty.commentrequired = opty.Cloud_Churn_Forecast__c>0 || opty.On_Premise_Churn_Forecast__c>0;
                
            }
            tempArray.push(opty);
        });
        this.optydata =tempArray;
                
        this.showSpinner=false;
    }

    //Handle save churn fields 
    handleSave(){
        this.showSpinner=true; 

        let isValid = true;
        this.template.querySelectorAll("lightning-input").forEach((ip) => {
            ip.reportValidity();
            if(isValid && !ip.reportValidity()){
              isValid = ip.reportValidity();              
              this.showSpinner=false;  
            }
        });
        this.template.querySelectorAll("lightning-textarea").forEach((ip) => {
            ip.reportValidity();
            if(isValid && !ip.reportValidity()){
              isValid = ip.reportValidity();              
              this.showSpinner=false;  
            }
        });
        this.showRisk = false;
        this.optydata.forEach((opty)=>{
            if(!this.showRisk){
                this.showRisk = opty.Cloud_Churn_Forecast__c>0 || opty.On_Premise_Churn_Forecast__c>0;
            }            
        });        

        if(isValid){
            saveChurn({
                optyList: this.optydata
            }).then(() => {
                refreshApex(this.initData);
                objUtilities.showToast('Success','Churn and Swing details are updated successfully','success',this);
                const closeEvent = new CustomEvent('closemodal',{ detail: this.showRisk  || this.pafRisk});
                this.dispatchEvent(closeEvent);
                this.showSpinner=false; 
            }).catch((objError) => {
                this.showSpinner=false; 
                objUtilities.processException(objError, this);
            });
        }
    }

    handlemouseover(event){
        let oppId=event.target.dataset.id;
        let tempArray =  [];
        this.optydata.forEach((opty)=>{
            if(opty.Id==oppId){
                opty.displayPopover=true;
                
            }
            tempArray.push(opty);
        });
        this.optydata =tempArray;
    }

    handlemouseout(event){
        let oppId=event.target.dataset.id;
        let tempArray =  [];
        this.optydata.forEach((opty)=>{
            if(opty.Id==oppId){
                opty.displayPopover=false;
                
            }
            tempArray.push(opty);
        });
        this.optydata =tempArray;
    }
}