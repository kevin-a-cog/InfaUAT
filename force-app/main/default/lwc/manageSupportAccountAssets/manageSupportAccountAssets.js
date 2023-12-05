import {LightningElement, track, api, wire } from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import CUSTOMERACCOUNT from "@salesforce/schema/Account.ParentId";
import {getRecord,getFieldValue} from "lightning/uiRecordApi"
import getAssignedAssets from "@salesforce/apex/ManageSupportAccountAssetsController.getAssignedAssets"
import getAllAssets from "@salesforce/apex/ManageSupportAccountAssetsController.getAllAssets";
import shareAssets from "@salesforce/apex/ManageSupportAccountAssetsController.shareAssets";
import transferAssets from "@salesforce/apex/ManageSupportAccountAssetsController.transferAssets";


const ASSIGNED_ASSETS = "Assigned Assets";
const ALL_ASSETS = "All Assets";
const fields = [CUSTOMERACCOUNT];

const tabsObj = [
  {
    tab: ASSIGNED_ASSETS,
    helpText: "All Assets associated with this Support Account"
  },
  {
    tab: ALL_ASSETS,
    helpText: "All Assets under the Customer Account"
  }
];

export default class ManageSupportAccountAssets extends LightningElement {
  @api recordId;
  @track tabs = tabsObj;
  @track defaultTabOnInitialization = ASSIGNED_ASSETS;
  @track NoDataAfterRendering = false;
  @track columns;
  @track data;
  @track selectedRecords =[];
  @track isMoveModalOpen = false;
  @track displayDataTableFooter = false;
  @track currentTabValue;
  @track displayShareBTN = false;
  @track displayTransferBTN = false;
  @track displaycancel = false;
  @track showErrorMessage;
  @track sortBy;
  @track sortDirection;
  @track recordsToDisplay =[];
  @track rowNumberOffset;
  assetShare ;
  assetTransfer; 
  AccountSelected ;

  //[Vignesh D: added public property to show popout modal]
  @api showpopicon = false;
  @track showPopOut = false;

  settings = {
    fieldNameRecordName: "__AssetName",
    fieldNameRecordURL: "__AssetRecordURL",
    fieldNameProductName: "__ProductName",
    fieldNameProductRecordURL: "__ProductRecordURL",
    fieldNameContractNumber: "__ContractName",
    fieldNameContractRecordURL: "__ContractRecordURL",
    fieldNameCustomerAccountName: "__CustomerAccountName",
    fieldNameCustomerAccountRecordURL: "__CustomerAccountRecordURL",
    fieldNameSupportAccountName: "__SupportAccountName",
    fieldNameSupportAccountRecordURL: "__SupportrAccountRecordURL",
    fieldNameEntitledProductName: "__EntitledProductName",
    fieldNameEntitledProductRecordURL: "__EntitledProductRecordURL"
  };

  COL_ASSIGNED_ASSETS = [
    {
      label: "Entitled Product",
      fieldName: this.settings.fieldNameEntitledProductRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameEntitledProductName },
        target: "_self"
      }
    },
    {
      label: "Name",
      fieldName: this.settings.fieldNameRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameRecordName },
        target: "_self"
      }
    },
    {
      label: "Contract Number",
      fieldName: this.settings.fieldNameContractRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameContractNumber },
        target: "_self"
      }
    },
    {
      label: "Start Date",
      fieldName: "SBQQ__SubscriptionStartDate__c",
      type: "date-local",
      sortable: true,
      typeAttributes: { year: "numeric", month: "short", day: "numeric" }
    },
    {
      label: "End Date",
      fieldName: "SBQQ__SubscriptionEndDate__c",
      type: "date-local",
      sortable: true,
      typeAttributes: { year: "numeric", month: "short", day: "numeric" }
    },
    {
      label: "Quantity",
      fieldName: "Quantity",
      type: "decimal",
      sortable: true
    },
    {
      label: "Status",
      fieldName: "Status",
      type: "text",
      sortable: true
    },
    {
      label: "Support Account",
      fieldName: this.settings.fieldNameSupportAccountRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameSupportAccountName },
        target: "_self"
      }
    },
    {
      label: "Customer Account",
      fieldName: this.settings.fieldNameCustomerAccountRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameCustomerAccountName },
        target: "_self"
      }
    },
    {
      label: "Product Name",
      fieldName: this.settings.fieldNameProductRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameProductName },
        target: "_self"
      }
    }
  ];

  getRecordURL(sObject, Id) {
    return "/lightning/r/" + sObject + "/" + Id + "/view";
  }

  @wire(getRecord, { recordId: "$recordId", fields }) supportAccount;

  connectedCallback() {
    console.log('connectedCallback()');
    this.tabs = tabsObj;
    this.defaultTabOnInitialization = ASSIGNED_ASSETS;
  }

  handleActiveTab(event){
    console.log("handleactive" + this.recordId);
    this.currentTabValue = event.target.value;
    console.log("currentTabValue => " + this.currentTabValue);
    this.handleRefresh();
  }

  handleIconRefresh(event) {
    console.log('handleIconRefresh()');
    this.handleRefresh();
  }

  //handle refresh of the data table
  handleRefresh() {
    console.log('handleRefresh()');
    this.NoDataAfterRendering = false;
    this.displayDataTableFooter = false;
    this.showErrorMessage = undefined;
    if (this.currentTabValue == ASSIGNED_ASSETS) {
      this.columns = this.COL_ASSIGNED_ASSETS;
      this.data = undefined;
      console.log("Assigned Asset Account Id ==>" + this.recordId);
      getAssignedAssets({ AccountId: this.recordId })
        .then((result) => {
         // console.log('Assigned Asset Result ==> ' + JSON.stringify(result));
          let tempData = JSON.parse(JSON.stringify(result));
         // console.log('Assigned Asset tempData ==> ' + JSON.stringify(tempData));
          if (tempData) {
            for (let i = 0; i < tempData.length; i++) {
             // console.log('tempData before processing ==> ' + JSON.stringify(tempData[i]));

              if(tempData[i].Name){
              tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
              tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL("Asset",tempData[i].Id);
              }
              
              if(tempData[i].Product2){
              tempData[i][this.settings.fieldNameProductName] = tempData[i].Product2.Name;
              tempData[i][this.settings.fieldNameProductRecordURL] = this.getRecordURL("Product2", tempData[i].Product2Id);
              }

              if(tempData[i].Entitled_Product__c){
              tempData[i][this.settings.fieldNameEntitledProductName] = tempData[i].Entitled_Product__r.Name;
              tempData[i][this.settings.fieldNameEntitledProductRecordURL] = this.getRecordURL("Entitled_Product__c", tempData[i].Entitled_Product__c);
              }

              if(tempData[i].SBQQ__CurrentSubscription__c){
              tempData[i][this.settings.fieldNameContractNumber] =tempData[i].SBQQ__CurrentSubscription__r.SBQQ__Contract__r.ContractNumber;
              tempData[i][this.settings.fieldNameContractRecordURL] = this.getRecordURL("Contract",tempData[i].SBQQ__CurrentSubscription__r.SBQQ__Contract__c);
              }
              
              if(tempData[i].Account){
              tempData[i][this.settings.fieldNameCustomerAccountName] =tempData[i].Account.Name;
              tempData[i][this.settings.fieldNameCustomerAccountRecordURL] = this.getRecordURL("Account", tempData[i].AccountId);
              }
              
              if(tempData[i].Support_Account__c){
              tempData[i][this.settings.fieldNameSupportAccountName] =tempData[i].Support_Account__r.Name;
              tempData[i][this.settings.fieldNameSupportAccountRecordURL] = this.getRecordURL("Account", tempData[i].Support_Account__c);
              }
            }
            this.data = tempData;
            this.displayShareBTN = true;
            this.displayTransferBTN = true;
      
           // console.log('tempData After processing ==> ' + JSON.stringify(tempData[0]));
      
          } else {
            //Show No Assets to display message
            this.NoDataAfterRendering = true;
          }
        })
        .catch((error) => {
          console.log("error " + error);
        });
    } else if (this.currentTabValue == ALL_ASSETS) {
      this.columns = this.COL_ASSIGNED_ASSETS;
      this.data = undefined;
      console.log("All Asset Account Id ==>" + this.recordId);
      const customerAccountId = getFieldValue(this.supportAccount.data,CUSTOMERACCOUNT);
      console.log("All Asset Parent Account Id ==>" + customerAccountId);
      getAllAssets({AccountId: this.recordId,ParentAccountId: customerAccountId})
        .then((result) => {
          console.log('All Asset Result ==> ' + JSON.stringify(result));
          let tempData = JSON.parse(JSON.stringify(result));
          console.log('All Asset tempData ==> ' + JSON.stringify(tempData));
          if (tempData) {
            for (let i = 0; i < tempData.length; i++) {
              console.log('tempData before processing ==> ' + JSON.stringify(tempData[i]));
             
                if(tempData[i].Name){
                tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
                tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL("Asset",tempData[i].Id);
                }
                
                if(tempData[i].Product2){
                tempData[i][this.settings.fieldNameProductName] = tempData[i].Product2.Name;
                tempData[i][this.settings.fieldNameProductRecordURL] = this.getRecordURL("Product2", tempData[i].Product2Id);
                }
  
                if(tempData[i].Entitled_Product__c){
                tempData[i][this.settings.fieldNameEntitledProductName] = tempData[i].Entitled_Product__r.Name;
                tempData[i][this.settings.fieldNameEntitledProductRecordURL] = this.getRecordURL("Entitled_Product__c", tempData[i].Entitled_Product__c);
                }
  
                if(tempData[i].SBQQ__CurrentSubscription__c){
                tempData[i][this.settings.fieldNameContractNumber] =tempData[i].SBQQ__CurrentSubscription__r.SBQQ__Contract__r.ContractNumber;
                tempData[i][this.settings.fieldNameContractRecordURL] = this.getRecordURL("Contract",tempData[i].SBQQ__CurrentSubscription__r.SBQQ__Contract__c);
                }
                
                if(tempData[i].Account){
                tempData[i][this.settings.fieldNameCustomerAccountName] =tempData[i].Account.Name;
                tempData[i][this.settings.fieldNameCustomerAccountRecordURL] = this.getRecordURL("Account", tempData[i].AccountId);
                }
                
                if(tempData[i].Support_Account__c){
                tempData[i][this.settings.fieldNameSupportAccountName] =tempData[i].Support_Account__r.Name;
                tempData[i][this.settings.fieldNameSupportAccountRecordURL] = this.getRecordURL("Account", tempData[i].Support_Account__c);
                }
            }
            this.data = tempData;
            this.displayShareBTN = true;
            this.displayTransferBTN = true;
      
            console.log('tempData After processing ==> ' + JSON.stringify(tempData[0]));
      
          } else {
            //Show No Assets to display message
            this.NoDataAfterRendering = true;
          }

        })
        .catch((error) => {
          console.log("error " + error);
        });
    }
    console.log('Data table ==> ' + JSON.stringify(this.data));
 
  }

  handleRowSelected(event) {
    this.selectedRecords = [];
    this.selectedRecords = event.detail.selectedRows;
    console.log('handleRowSelected()-->'+'selectedRecords.length -->'+ JSON.stringify(this.selectedRecords.length));
    if (this.selectedRecords.length > 0) {
      this.displayDataTableFooter = true;
      this.displaycancel = true;
      this.showErrorMessage = undefined;
    }
  }


  doSorting(event) {
    console.log('doSorting()-->'+ 'sortby -->' + event.detail.fieldName  +' Sortdirection-->'+event.detail.sortDirection);
    var fname= event.detail.fieldName;
    if(fname.includes('RecordURL')){
      fname= fname.replace('RecordURL','Name')
    }
    this.sortBy = fname
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
    this.sortBy = event.detail.fieldName;

  }
  
  
  sortData(fieldname, direction) {
    console.log('sortData()-->'+'this.data.length'+ this.data.length);
   // console.log('sortData()-->'+'this.recordsToDisplay.lenghth'+ this.data.recordsToDisplay.length);

    let parseData = JSON.parse(JSON.stringify(this.data));
    // Return the value stored in the field
    let keyValue = (a) => {
    return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1: -1;
    // sorting data
    parseData.sort((x, y) => {
    x = keyValue(x) ? keyValue(x) : ''; // handling null values
    y = keyValue(y) ? keyValue(y) : '';
    // sorting values based on direction
    return isReverse * ((x > y) - (y > x));
    });
    this.data = parseData;
    this.template.querySelector("c-paginator").setRecordsToDisplay();

  }

  handleCancel(event) {
    this.handleRefresh();
  }

  handleShare(event) {
    this.AccountSelected = undefined;
    if (this.selectedRecords.length > 0) {
      this.isMoveModalOpen = true;
      this.assetShare =true;
      this.assetTransfer =false;
    } else {
      this.showErrorMessage = "Select atleast one or more Assets";
    }
  }

  handleTransfer(event) {
    this.AccountSelected = undefined;
    if (this.selectedRecords.length > 0) {
      this.isMoveModalOpen = true;
      this.assetShare =false;
      this.assetTransfer =true;
    } else {
      this.showErrorMessage = "Select atleast one or more Assets";
    }
  }

  handleAccountSelection(event) {
    console.log("event.detail--> " + event.detail);
    this.AccountSelected = event.detail;
    console.log("Account selected --> " + this.AccountSelected);

  }

  handleAccountRemoval(event){
    this.AccountSelected = undefined;
  }

  updateMove() {
    const accountId = this.AccountSelected.toString();
    const assets = this.selectedRecords;
    console.log('accountId'+ typeof accountId);
    if (accountId) {
      if(this.assetShare){
        shareAssets({ Assets: assets, AccountId: accountId })
          .then((result) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Assets are shared with the Support Account Successfully",
                variant: "success"
              })
            );
            this.selectedRecords = [];
            this.displayDataTableFooter = false;
            this.displaycancel = false;
            this.closeMoveModal();
            return this.handleRefresh();
          })
          .catch((error) => {
            console.log("save error --> ${JSON.stringify(error)}");
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error occurred :",
                message: error.body.message,
                variant: "error"
              })
            );
          });
      }
      else if(this.assetTransfer){
        transferAssets({ Assets: assets, NewAccountId: accountId,  OldAccountId :this.recordId })
          .then((result) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Assets are transfered to the Support Account Successfully",
                variant: "success"
              })
            );
            this.selectedRecords = [];
            this.displayDataTableFooter = false;
            this.displaycancel = false;
            this.closeMoveModal();
            return this.handleRefresh();
          })
          .catch((error) => {
            console.log("save error --> ${JSON.stringify(error)}");
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error occurred :",
                message: error.body.message,
                variant: "error"
              })
            );
          });
      }
    }
  }

  closeMoveModal() {
    this.AccountSelected = undefined;
    this.isMoveModalOpen = false;
  }


  handlePaginatorChange(event){
    console.log('recordsToDisplay size'+event.detail.length);

    this.recordsToDisplay = event.detail;

    if( this.recordsToDisplay.length>0 ){
      console.log('rowNumberOffset '+this.recordsToDisplay[0].rowNumber);

      this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1 ;
    }else{
      this.rowNumberOffset =0;
    }
  }

  //[Vignesh D: added modal logic]
  openModal(event){
    console.log('show->'+this.recordId);
    this.showPopOut = true;
  }
  closepopout(event){
    this.showPopOut = false;
  }
}