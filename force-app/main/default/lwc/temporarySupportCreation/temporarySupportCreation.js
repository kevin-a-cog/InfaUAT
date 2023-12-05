/*
 Change History
 **********************************************************************************************************
 Modified By			    Date			    Jira No.		Description							                          Tag
 **********************************************************************************************************
 NA                   NA            UTOPIA      Initial version.                                  NA
 Vignesh Divakaran		10/02/2022		I2RT-5411		Move getUnEntitledProducts to wire method					T01
 */

import { LightningElement, track, wire, api, } from "lwc";
import { getRecord } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import getUnEntitledProducts from "@salesforce/apex/EntitledProductController.getUnEntitledProducts";
import upsertTempSupport from "@salesforce/apex/EntitledProductController.upsertTempSupport";
import ACTIVE from "@salesforce/schema/Account.Active__c";
import ACCOUNT from '@salesforce/schema/Account';
import SUCCESS_OFFERING from '@salesforce/schema/Account.Success_Offering__c';
import {getPicklistValues,getObjectInfo} from 'lightning/uiObjectInfoApi';

const FIELDS = [ACTIVE];

export default class TemporarySupportCreation extends NavigationMixin(LightningElement) {

  @track showProductPicklist = false;
  @track productSelected;
  @track dateSelected;
  @track reasonSelected;
  @track productdropdownValues =[];
   @api recordId;
  @track isLoading = false;
  SupportAccountId;
  @track showMessage = true ;
  supportAccount;
  @track disableSave = true;
  @track disableCancel = false;
  
  
  @track successOfferingdropdownValues =[];
  @track successOfferingSelected;
  @track supportAccountRecoTypeId;

  @wire(getObjectInfo, {
    objectApiName: ACCOUNT
 }) accObjectInfo ({error,data}) {
    if (error) {
    console.log('error>>>', {
        ...error
    });
    } else if (data) {
      console.log('Account Information' + ':' + JSON.stringify(data));
      const rtinfo = data.recordTypeInfos; 
      this.supportAccountRecoTypeId= Object.keys(rtinfo).find(rti => rtinfo[rti].name === 'Support Account');
      console.log('this.supportAccountRecoTypeId :' + this.supportAccountRecoTypeId);
    }
 }
  
  @wire(getPicklistValues, {
        recordTypeId: '$supportAccountRecoTypeId',
        fieldApiName: SUCCESS_OFFERING
    }) getSuccessOffering({error,data}) {
        if (error) {
        console.log('error>>>', {
            ...error
        });
        } else if (data) {
        this.successOfferingdropdownValues = [...data.values];
        console.log('this.successOfferingdropdownValues' + ':' + JSON.stringify(this.successOfferingdropdownValues));
        }
    }

  connectedCallback() {
    console.log('Account Id -> '+ this.recordId);
    this.SupportAccountId =this.recordId;
    console.log(`showMessage-->${this.showMessage}`);

    this.dispatchEvent(
      new ShowToastEvent({
        title: "",
        message: 'Adding Temporary Support will Activate the Support Account'
      })
    );

    /*getUnEntitledProducts({ AccountId: this.recordId })
      .then((result) => {
        let tempData = JSON.parse(JSON.stringify(result));
        console.log("All Asset tempData ==> " + JSON.stringify(tempData));
        if (tempData) {
          for (let i = 0; i < tempData.length; i++) {
            this.productdropdownValues.push({
              label: tempData[i],
              value: tempData[i]
            });
          }
        }
        this.showProductPicklist = true;

      })
      .catch((error) => {
        console.log("Error -->" + error);
      });*/
  }

  //<T01>
  @wire(getUnEntitledProducts, { AccountId: '$recordId' })
  products({ error, data }) {
    if (data) {
      let tempData = data;
      console.log("All Asset tempData ==> " + JSON.stringify(tempData));
      if (tempData) {
        this.productdropdownValues = [];
        for (let i = 0; i < tempData.length; i++) {
          this.productdropdownValues.push({
            label: tempData[i],
            value: tempData[i]
          });
        }
      }
      this.showProductPicklist = true;
    } else if (error) {
      console.log("Error -->" + error);
    }
}
//</T01>

  handleProductChange(event)
  {
    console.log('entry handleProductChange-->'+event.detail.value);
    this.productSelected = event.detail.value;
    this.validateEnableSaveBTN();
  }

  handleDateChange(event)
  {
    console.log('entry handleProductChange-->'+event.detail.value);
    this.dateSelected = event.detail.value;
    this.validateEnableSaveBTN();
  }

  handleSuccessOfferingChange(event){
    console.log('entry handleSuccessOfferingChange-->'+event.detail.value);
    this.successOfferingSelected = event.detail.value;
    this.validateEnableSaveBTN();
  }

  handleReasonChange(event){
    console.log('entry handleProductChange-->'+event.detail.value);
    this.reasonSelected = event.detail.value;
    this.validateEnableSaveBTN();
  }

  handleSave(event) {
      //this.showProductPicklist = false;
      this.isLoading = true;
      this.disableSave = true;
      this.disableCancel = true;
      console.log('productSelected ->'+this.productSelected);
      console.log('dateSelected ->'+this.dateSelected);
      console.log('SupportAccountId->'+this.SupportAccountId);

      upsertTempSupport({AccountId: this.recordId, Product : this.productSelected, EndDate : this.dateSelected,SuccessOffering :this.successOfferingSelected, Reason : this.reasonSelected})
      .then(result=>{
          console.log('Temp Support Added');
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Temporary Support is added Successfully",
              variant: "success"
            })
          );
          this.isLoading = false;
          this.closeAction();

      })
      .catch(error=>{
        console.log("Error -->" + error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error occurred :",
            message: error.body.message,
            variant: "error"
          })
        );
        this.isLoading = false;
        this.disableSave = true;
        this.disableCancel = true;
      });
  }

  validateEnableSaveBTN(){
    this.disableSave = (this.productSelected && this.productSelected !== '') && this.dateSelected && (this.reasonSelected && this.reasonSelected !== '') ? false : true;
  }

  handlecancel(){
    //this.showProductPicklist = false;
    //this.isLoading = true;
    this.closeAction();
  }

  closeAction(){
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: this.recordId,
          objectApiName: 'Account',
          actionName: 'view'
      }
    });
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}