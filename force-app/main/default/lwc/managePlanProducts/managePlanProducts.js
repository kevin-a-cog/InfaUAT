import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getPlanProducts from "@salesforce/apex/ManagePlanProductsController.getPlanProducts";
import removePlanFromPlanProducts from "@salesforce/apex/ManagePlanProductsController.removePlanFromPlanProducts";
import getPlanProducts2 from "@salesforce/apex/ManagePlanProductsController.getPlanProducts2";
import addPlanProductsToPlan from "@salesforce/apex/ManagePlanProductsController.addPlanProductsToPlan";
import getAllPlanProducts from "@salesforce/apex/ManagePlanProductsController.getAllPlanProducts";
import savePlanProducts from "@salesforce/apex/ManagePlanProductsController.savePlanProducts";
import insertplan from "@salesforce/apex/ManagePlanProductsController.insertplan";
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import PLAN_PRODUCT from "@salesforce/schema/Related_Account_Plan__c";
import STAGE_FIELD from "@salesforce/schema/Related_Account_Plan__c.Stage__c";
import ACCOUNT from "@salesforce/schema/Plan__c.Account__c";
//import PP_STAGE from '@salesforce/schema/Related_Account_Plan__c.Stage__c';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

const fields = [ACCOUNT];

const ASSIGNED_PRODUCTS = "Assigned Products";
const UNASSIGNED_PRODUCTS = "UnAssigned Products";
const ALL_PRODUCTS = "All Assigned Plan Products";

const tabsObj = [
  {
    tab: ASSIGNED_PRODUCTS,
    helpText: "All plan products associated with this current plan"
  },
  {
    tab: UNASSIGNED_PRODUCTS,
    helpText:
      "All plan products in the account, not associated to any plan in the account"
  },
  {
    tab: ALL_PRODUCTS,
    helpText: "All assigned plan products under the current account"
  }
];

export default class ManagePlanProducts extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  //-------------------------------api parameters set from plan create and edit pages
  @api fromcreatepage;
  @api plansobject;
  @api accountlobid;
  @api planrectypeid;
  @api accountidpassed;
  @api fromeditpage;

  //-----------------End of api parameters

  @track accountId;
  @track tabs = tabsObj;
  @track defaultTabOnInitialization = ASSIGNED_PRODUCTS;
  @track columns;
  @track data;
  @track NoDataAfterRendering = false;
  value;
  @track isStageModalOpen = false;
  @track isMoveModalOpen = false;
  @track displayDataTableFooter = false;
  @track currentTabValue;
  @track displayRemoveBTN = false;
  @track displayAddBTN = false;
  @track displayMoveBTN = false;
  @track PlanSelected;
  @track movelabel = "Move";
  @track planrecid;
  displaycancel = false;
  @track showNotApplicableProds = false;
  @track showCheckBox;
  @track containsRiskProduct = false;
  @track showErrorMessage;
  @track picklist = [];
  @track countAssignedProducts;

  //--------Start
  @track isLoading = false;
  settings = {
    fieldNameRecordName: "__Name",
    fieldNameRecordURL: "__RecordURL",
    fieldNameContractNumber: "__ContractNumber",
    fieldNameContractRecordURL: "__ContractRecordURL",
    fieldNameOpportunityName: "__OpportunityName",
    fieldNameOpportunityRecordURL: "__OpportunityRecordURL",
    fieldNamePlanName: "__PlanName",
    fieldNamePlanRecordURL: "__PlanRecordURL"
  };

  //--------End

  //Assigned Products tab columns
  COL_ASSIGNED_PRODUCTS = [
    {
      label: "Name",
      fieldName: this.settings.fieldNameRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameRecordName },
        target: "_blank"
      }
    },
    {
      label: "Contract Number",
      fieldName: this.settings.fieldNameContractRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameContractNumber },
        target: "_blank"
      }
    },
    {
      label: "Opportunity Name",
      fieldName: this.settings.fieldNameOpportunityRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameOpportunityName },
        target: "_blank"
      }
    },
    {
      label: "Plan",
      fieldName: this.settings.fieldNamePlanRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNamePlanName },
        target: "_blank"
      }
    },
    {
      label: "Forecast Product",
      fieldName: "Forecast_Product__c",
      initialWidth: 150
    },
    { label: "Delivery Method", fieldName: "Delivery_Method__c" },
    { label: "Pricing Business Model", fieldName: "Pricing_Business_Model__c" },
    { label: "Offering Type", fieldName: "Offering_Type__c" },
    //{ label: 'ARR', fieldName: 'ARR__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } } },
    {
      label: "ARR",
      fieldName: "ConvertedARR",
      type: "text",
      initialWidth: 260
    },
    { label: "Stage", fieldName: "Stage__c" },
    {
      label: "End Date",
      fieldName: "End_Date__c",
      type: "date-local",
      typeAttributes: { year: "numeric", month: "short", day: "numeric" }
    },
    { label: "Status", fieldName: "Status__c" },
    { label: "Product", fieldName: "Product__c" },
    { label: "Risk", fieldName: "Risk_formula__c", type: "boolean" }
  ];

  //Unassigned Products tab columns
  COL_UNASSIGNED_PRODUCTS = [
    {
      label: "Name",
      fieldName: this.settings.fieldNameRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameRecordName },
        target: "_blank"
      }
    },
    {
      label: "Contract Number",
      fieldName: this.settings.fieldNameContractRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameContractNumber },
        target: "_blank"
      }
    },
    {
      label: "Opportunity Name",
      fieldName: this.settings.fieldNameOpportunityRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameOpportunityName },
        target: "_blank"
      }
    },
    {
      label: "Forecast Product",
      fieldName: "Forecast_Product__c",
      initialWidth: 150
    },
    { label: "Delivery Method", fieldName: "Delivery_Method__c" },
    { label: "Pricing Business Model", fieldName: "Pricing_Business_Model__c" },
    { label: "Offering Type", fieldName: "Offering_Type__c" },
    //{ label: 'ARR', fieldName: 'ARR__c', type: 'currency', typeAttributes: {currencyCode: {fieldName: 'CurrencyIsoCode'}} },
    {
      label: "ARR",
      fieldName: "ConvertedARR",
      type: "text",
      initialWidth: 260
    },
    { label: "Stage", fieldName: "Stage__c" },
    {
      label: "End Date",
      fieldName: "End_Date__c",
      type: "date-local",
      typeAttributes: { year: "numeric", month: "short", day: "numeric" }
    },
    { label: "Status", fieldName: "Status__c" },
    { label: "Risk", fieldName: "Risk_formula__c", type: "boolean" }
  ];

  //All Products tab columns
  COL_All_PRODUCTS = [
    {
      label: "Name",
      fieldName: this.settings.fieldNameRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameRecordName },
        target: "_blank"
      }
    },
    {
      label: "Contract Number",
      fieldName: this.settings.fieldNameContractRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameContractNumber },
        target: "_blank"
      }
    },
    {
      label: "Opportunity Name",
      fieldName: this.settings.fieldNameOpportunityRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNameOpportunityName },
        target: "_blank"
      }
    },
    {
      label: "Plan",
      fieldName: this.settings.fieldNamePlanRecordURL,
      type: "url",
      sortable: true,
      typeAttributes: {
        label: { fieldName: this.settings.fieldNamePlanName },
        target: "_blank"
      }
    },
    {
      label: "Forecast Product",
      fieldName: "Forecast_Product__c",
      initialWidth: 150
    },
    { label: "Delivery Method", fieldName: "Delivery_Method__c" },
    { label: "Pricing Business Model", fieldName: "Pricing_Business_Model__c" },
    { label: "Offering Type", fieldName: "Offering_Type__c" },
    //{ label: 'ARR', fieldName: 'ARR__c', type: 'currency', typeAttributes: {currencyCode: {fieldName: 'CurrencyIsoCode'}} },
    {
      label: "ARR",
      fieldName: "ConvertedARR",
      type: "text",
      initialWidth: 260
    },
    { label: "Stage", fieldName: "Stage__c" },
    {
      label: "End Date",
      fieldName: "End_Date__c",
      type: "date-local",
      typeAttributes: { year: "numeric", month: "short", day: "numeric" }
    },
    { label: "Status", fieldName: "Status__c" },
    { label: "Risk", fieldName: "Risk_formula__c", type: "boolean" }
  ];

  @wire(getRecord, { recordId: "$recordId", fields })
  plan;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: STAGE_FIELD
  })
  StagePicklistValues({ data, error }) {
    if (data) {
     // console.log("pciklist values" + JSON.stringify(data.values));
      this.picklist = JSON.parse(JSON.stringify(data.values));
    }
    if (error) {
      console.log("picklist values returned error" + JSON.stringify(error));
    }
  }

  //have this attribute to track data change
  @track draftValues = [];
  lastSavedData = [];
  selectedRow = [];
  selectedRecordsList = [];

  connectedCallback() {
    this.planrecid = this.recordId;
    console.log("connected" + this.planrecid);
    console.log("fromeditpage" + this.fromeditpage);

    if (this.fromcreatepage) {
      this.tabs = [tabsObj[1], tabsObj[2]];
      console.log("tabs => " + JSON.stringify(this.tabs));
      this.defaultTabOnInitialization = UNASSIGNED_PRODUCTS;
      this.movelabel = "Add";
      this.displaycancel = true;
    } else if (this.fromeditpage) {
      console.log("displaycancel");
      this.displaycancel = true;
    } else {
      this.tabs = tabsObj;
    }
  }

  getRecordURL(sObject, Id) {
    return "/lightning/r/" + sObject + "/" + Id + "/view";
  }

  //handle tab selection
  handleActiveTab(event) {
    console.log(
      "picklistvalues --> " + JSON.stringify(this.StagePicklistValues)
    );
    console.log("handleactive" + this.planrecid);
    this.currentTabValue = event.target.value;
    console.log("currentTabValue => " + this.currentTabValue);
    if (this.currentTabValue == UNASSIGNED_PRODUCTS) {
      this.showCheckBox = true;
      console.log('**showNotApplicableProds'+this.showNotApplicableProds);
     // this.showNotApplicableProds = false;
    } else {
      this.showCheckBox = false;
    }
    this.handleRefresh();
  }

  //handle refresh of the data table
  handleRefresh() {
    this.NoDataAfterRendering = false;
    this.displayDataTableFooter = false;
    this.showErrorMessage = undefined;
    this.countAssignedProducts = undefined;
    console.log("this.recordId" + this.recordId);
    console.log('**showNotApplicableProds'+ this.showNotApplicableProds);
    let planid = this.planrecid;
    if (this.currentTabValue == ASSIGNED_PRODUCTS) {
      this.columns = this.COL_ASSIGNED_PRODUCTS;
      this.data = undefined;
      getPlanProducts({ planId: planid })
        .then((result) => {
          let tempData = JSON.parse(JSON.stringify(result));
          // console.log('tempData before processing ==> ' + JSON.stringify(tempData));
          if (tempData.length > 0) {
            for (let i = 0; i < tempData.length; i++) {
              //tempData[i].ContractNumber = tempData[i].Contract__r != undefined ? tempData[i].Contract__r.ContractNumber : undefined;
              //tempData[i].OpportunityName = tempData[i].Opportunity__r != undefined ? tempData[i].Opportunity__r.Name : undefined;
              //tempData[i].PlanName = tempData[i].Account_Plan__r != undefined ? tempData[i].Account_Plan__r.Name : undefined;
              console.log("tempData[i]");
              console.log(tempData[i][this.settings.fieldNameRecordName]);
              tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
              tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL(
                "Related_Account_Plan__c",
                tempData[i].Id
              );

              if (tempData[i].Contract__r != undefined) {
                tempData[i][this.settings.fieldNameContractNumber] =
                  tempData[i].Contract__r.ContractNumber;
                tempData[i][
                  this.settings.fieldNameContractRecordURL
                ] = this.getRecordURL("Contract", tempData[i].Contract__c);
              }

              if (tempData[i].Opportunity__r != undefined) {
                tempData[i][this.settings.fieldNameOpportunityName] =
                  tempData[i].Opportunity__r.Name;
                tempData[i][
                  this.settings.fieldNameOpportunityRecordURL
                ] = this.getRecordURL(
                  "Opportunity",
                  tempData[i].Opportunity__c
                );
              }

              if (tempData[i].Account_Plan__r != undefined) {
                tempData[i][this.settings.fieldNamePlanName] =
                  tempData[i].Account_Plan__r.Name;
                tempData[i][
                  this.settings.fieldNamePlanRecordURL
                ] = this.getRecordURL("Plan__c", tempData[i].Account_Plan__c);
              }

              if (tempData[i].ARR__c != undefined) {
                if (tempData[i].CurrencyIsoCode != "USD") {
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(
                      /\d(?=(\d{3})+\.)/g,
                      "$&,"
                    )} (USD ${Number.parseFloat(tempData[i].ConvertedARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")})`;
                } else {
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")}`;
                }
              }
            }
           // console.log("tempData after processing ==> " + JSON.stringify(tempData));
            this.data = tempData;
            this.countAssignedProducts = tempData.length;
            //set visibiltiy for action buttons in datatable footer based on the active tab
            this.displayRemoveBTN = true;
            this.displayAddBTN = false;
            this.displayMoveBTN = false;

            this.lastSavedData = JSON.parse(JSON.stringify(this.data));

            console.log("**countAssignedProducts" + this.countAssignedProducts);
          } else {
            //Show No Products to display message
            this.NoDataAfterRendering = true;
          }
        })
        .catch((error) => {
          console.log("error " + error);
        });
    } else if (this.currentTabValue == UNASSIGNED_PRODUCTS) {
      this.columns = this.COL_UNASSIGNED_PRODUCTS;
      this.data = undefined;
      let accountid = getFieldValue(this.plan.data, ACCOUNT);

      //-----Start (VKOTAPATI)
      if (this.fromcreatepage) {
        accountid = this.accountidpassed;
        planid = " ";
      }

      //------End (VKOTAPATI)
      getAllPlanProducts({
        AccountId: accountid,
        showNotApplicable: this.showNotApplicableProds
      })
        .then((result) => {
          let tempData = JSON.parse(JSON.stringify(result));
          //console.log('tempData before processing ==> ' + JSON.stringify(tempData));
          if (tempData.length > 0) {
            for (let i = 0; i < tempData.length; i++) {
              //tempData[i].ContractNumber = tempData[i].Contract__r != undefined ? tempData[i].Contract__r.ContractNumber : undefined;
              //tempData[i].OpportunityName = tempData[i].Opportunity__r != undefined ? tempData[i].Opportunity__r.Name : undefined;
              //tempData[i].PlanName = tempData[i].Account_Plan__r != undefined ? tempData[i].Account_Plan__r.Name : undefined;
              tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
              tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL(
                "Related_Account_Plan__c",
                tempData[i].Id
              );

              if (tempData[i].Contract__r != undefined) {
                tempData[i][this.settings.fieldNameContractNumber] =
                  tempData[i].Contract__r.ContractNumber;
                tempData[i][
                  this.settings.fieldNameContractRecordURL
                ] = this.getRecordURL("Contract", tempData[i].Contract__c);
              }

              if (tempData[i].Opportunity__r != undefined) {
                tempData[i][this.settings.fieldNameOpportunityName] =
                  tempData[i].Opportunity__r.Name;
                tempData[i][
                  this.settings.fieldNameOpportunityRecordURL
                ] = this.getRecordURL(
                  "Opportunity",
                  tempData[i].Opportunity__c
                );
              }

              if (tempData[i].Account_Plan__r != undefined) {
                tempData[i][this.settings.fieldNamePlanName] =
                  tempData[i].Account_Plan__r.Name;
                tempData[i][
                  this.settings.fieldNamePlanRecordURL
                ] = this.getRecordURL("Plan__c", tempData[i].Account_Plan__c);
              }

              if (tempData[i].ARR__c != undefined) {
                if (tempData[i].CurrencyIsoCode != "USD") {
                  //console.log(`${tempData[i].ARR__c.toFixed(2)}`);
                  //console.log(`${Number.parseFloat(tempData[i].ARR__c).toFixed(2)}`);
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(
                      /\d(?=(\d{3})+\.)/g,
                      "$&,"
                    )} (USD ${Number.parseFloat(tempData[i].ConvertedARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")})`;
                } else {
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")}`;
                }
              }
            }
            //console.log("tempData after processing ==> " + JSON.stringify(tempData));
            this.data = tempData;

            //set visibiltiy for action buttons in datatable footer based on the active tab
            this.displayRemoveBTN = false;
            this.displayAddBTN = true;
            this.displayMoveBTN = false;

            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
          } else {
            //Show No Products to display message
            this.NoDataAfterRendering = true;
          }
        })
        .catch((error) => {
          console.log("error " + JSON.stringify(error));
        });
    } else if (this.currentTabValue == ALL_PRODUCTS) {
      this.columns = this.COL_All_PRODUCTS;
      this.data = undefined;
      let accountid = getFieldValue(this.plan.data, ACCOUNT);

      //-------- Start (VKOTAPATI)
      if (this.fromcreatepage) {
        accountid = this.accountidpassed;
        planid = " ";
      }
      //--------End (VKOTAPATI)

      //copy of accountId to pass to Lookup component
      this.accountId = accountid;

      getPlanProducts2({ planId: this.plan.Id, AccountId: accountid })
        .then((result) => {
          let tempData = JSON.parse(JSON.stringify(result));
          //console.log('tempData before processing ==> ' + JSON.stringify(tempData));
          if (tempData.length > 0) {
            for (let i = 0; i < tempData.length; i++) {
              //tempData[i].ContractNumber = tempData[i].Contract__r != undefined ? tempData[i].Contract__r.ContractNumber : undefined;
              //tempData[i].OpportunityName = tempData[i].Opportunity__r != undefined ? tempData[i].Opportunity__r.Name : undefined;
              //tempData[i].PlanName = tempData[i].Account_Plan__r != undefined ? tempData[i].Account_Plan__r.Name : undefined;
              tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
              tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL(
                "Related_Account_Plan__c",
                tempData[i].Id
              );

              if (tempData[i].Contract__r != undefined) {
                tempData[i][this.settings.fieldNameContractNumber] =
                  tempData[i].Contract__r.ContractNumber;
                tempData[i][
                  this.settings.fieldNameContractRecordURL
                ] = this.getRecordURL("Contract", tempData[i].Contract__c);
              }

              if (tempData[i].Opportunity__r != undefined) {
                tempData[i][this.settings.fieldNameOpportunityName] =
                  tempData[i].Opportunity__r.Name;
                tempData[i][
                  this.settings.fieldNameOpportunityRecordURL
                ] = this.getRecordURL(
                  "Opportunity",
                  tempData[i].Opportunity__c
                );
              }

              if (tempData[i].Account_Plan__r != undefined) {
                tempData[i][this.settings.fieldNamePlanName] =
                  tempData[i].Account_Plan__r.Name;
                tempData[i][
                  this.settings.fieldNamePlanRecordURL
                ] = this.getRecordURL("Plan__c", tempData[i].Account_Plan__c);
              }

              if (tempData[i].ARR__c != undefined) {
                if (tempData[i].CurrencyIsoCode != "USD") {
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(
                      /\d(?=(\d{3})+\.)/g,
                      "$&,"
                    )} (USD ${Number.parseFloat(tempData[i].ConvertedARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")})`;
                } else {
                  tempData[i].ConvertedARR = `${
                    tempData[i].CurrencyIsoCode
                  } ${Number.parseFloat(tempData[i].ARR__c)
                    .toFixed(2)
                    .replace(/\d(?=(\d{3})+\.)/g, "$&,")}`;
                }
              }
            }
           // console.log("tempData after processing ==> " + JSON.stringify(tempData));
            this.data = tempData;

            //set visibiltiy for action buttons in datatable footer based on the active tab
            this.displayRemoveBTN = false;
            this.displayAddBTN = false;
            this.displayMoveBTN = true;

            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
          } else {
            //Show No Products to display message
            this.NoDataAfterRendering = true;
          }
        })
        .catch((error) => {
          console.log("error " + error);
        });
    }
  }

  handleIconRefresh(event) {
    this.handleRefresh();
  }

  get stagePicklistValues() {
    const tempData = this.picklist;
    let tempPicklist = [];
    for (let i = 0; i < tempData.length; i++) {
      tempPicklist.push({ label: tempData[i].label, value: tempData[i].value });
    }

    return tempPicklist;
  }

  openStageModal() {
    //alert('accountId -> ' + getFieldValue(this.plan.data, ACCOUNT));
    this.value = "Select Stage";
    if (this.selectedRow.length > 0) {
      this.isStageModalOpen = true;
    }
  }

  handleStageSelected(event) {
    this.value = event.detail.value;
    console.log("selected value =>" + this.value);
  }

  closeStageModal() {
    this.value = "Select Stage";
    this.isStageModalOpen = false;
  }

  updateStage() {
    if (this.value != undefined && this.value != "Select Stage") {
      this.isLoading = true;
      const tempPlanProducts = JSON.parse(JSON.stringify(this.selectedRow));
      console.log("tempPlanProducts -> " + JSON.stringify(tempPlanProducts));
      console.log("tempPlanProducts.length -> " + tempPlanProducts.length);
      const PlanProducts = [];

      for (let i = 0; i < tempPlanProducts.length; i++) {
        PlanProducts.push({ Id: tempPlanProducts[i].Id, Stage__c: this.value });
      }

      console.log(
        `List of Plan Products to Update stage ${JSON.stringify(PlanProducts)}`
      );

      savePlanProducts({ planProducts: PlanProducts })
        .then((result) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Plan Products are updated successfully!",
              variant: "success"
            })
          );
          // Clear all draft values
          this.draftValues = [];

          //hide the datatable footer
          this.displayDataTableFooter = false;

          if (this.fromcreatepage || this.fromeditpage)
            this.displaycancel = true;
          else this.displaycancel = false;

          //close the modal
          this.closeStageModal();

          this.isLoading = false;

          return this.handleRefresh();
        })
        .catch((error) => {
          console.log(`save error --> ${error}`);
          console.log(`save error --> ${JSON.stringify(error)}`);
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error creating record",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    }
  }

  /*
   **** Move Plan Products Functionality - start ****
   */

  handleMove(event) {
    this.PlanSelected = undefined;
    if (this.selectedRow.length > 0) {
      if (this.containsRiskProduct) {
        this.showErrorMessage ="One of the Plan Product is associated to Risk, please disassociate";
      } else {
        if (this.fromcreatepage) {
          this.isMoveModalOpen = false;
          this.handleAdd(event);
        } else {
          this.isMoveModalOpen = true;
        }
      }
    }
  }

  handlePlanSelection(event) {
    console.log("plan selected = " + event.detail);
    this.PlanSelected = event.detail;
  }

  handlePlanRemoval(event) {
    this.PlanSelected = undefined;
  }

  updateMove() {
    const planid = this.PlanSelected;
    const PlanProds = this.selectedRow;
    if (planid != undefined) {
      addPlanProductsToPlan({ planProducts: PlanProds, planId: planid })
        .then((result) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Plan Products added to the Plan Successfully",
              variant: "success"
            })
          );

          //clear the selected rows
          this.selectedRow = [];

          //hide the datatable footer
          this.displayDataTableFooter = false;

          if (this.fromcreatepage || this.fromeditpage)
            this.displaycancel = true;
          else this.displaycancel = false;

          //close the modal
          this.closeMoveModal();

          return this.handleRefresh();
        })
        .catch((error) => {
          console.log(`save error --> ${JSON.stringify(error)}`);
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

  closeMoveModal() {
    this.PlanSelected = undefined;
    this.isMoveModalOpen = false;
  }

  /*
   **** Move Plan Products Functionality - end ****
   */

  /*
   **** Datatable inline edit functionality - start ****
   */

  handleRowSelected(event) {
    this.containsRiskProduct = false;
    const selectedRows = event.detail.selectedRows;
    this.selectedRecordsList = selectedRows;
    console.log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
    this.selectedRow = [];
    for (let i = 0; i < selectedRows.length; i++) {
      this.selectedRow.push({ Id: selectedRows[i].Id });
      if (selectedRows[i].Risk_formula__c == true) {
        this.containsRiskProduct = true;
      }
    }

    console.log("selected row final => " + JSON.stringify(this.selectedRow));
    if (this.selectedRow.length > 0) {
      this.displayDataTableFooter = true;
      this.displaycancel = true;
      this.showErrorMessage = undefined;
    }
    //this.displayRemoveBTN = true;

    //this.containsRiskProduct();
    console.log("contains risk product = " + this.containsRiskProduct);
  }

  updateDataValues(updateItem) {
    let copyData = JSON.parse(JSON.stringify(this.data));
    copyData.forEach((item) => {
      if (item.Id === updateItem.Id) {
        for (let field in updateItem) {
          item[field] = updateItem[field];
        }
      }
    });

    //write changes back to original data
    this.data = [...copyData];
  }

  updateDraftValues(updateItem) {
    let draftValueChanged = false;
    let copyDraftValues = [...this.draftValues];
    //store changed value to do operations
    //on save. This will enable inline editing &
    //show standard cancel & save button
    copyDraftValues.forEach((item) => {
      if (item.Id === updateItem.Id) {
        for (let field in updateItem) {
          item[field] = updateItem[field];
        }
        draftValueChanged = true;
      }
    });

    if (draftValueChanged) {
      this.draftValues = [...copyDraftValues];
    } else {
      this.draftValues = [...copyDraftValues, updateItem];
    }
  }

  //handler to handle cell changes & update values in draft values
  handleCellChange(event) {
    this.displayDataTableFooter = true;
    this.displaycancel = true;
    for (let i = 0; i < event.detail.draftValues.length; i++) {
      this.updateDraftValues(event.detail.draftValues[i]);
      console.log(
        `draft values --> ${JSON.stringify(event.detail.draftValues[i])}`
      );
    }
  }

  //handler to save the changes to the database

  //Disabled inline edit saving
  /*
    handleSave(event) {
        console.log('$$$$$$$$$ In SAVE $$$$$$$$$');
        console.log(`Updated items ${JSON.stringify(this.draftValues)}`);
        
        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        console.log(`this.lastSavedData --> ${JSON.stringify(this.lastSavedData)}`);

        let PlanProducts = this.draftValues;

        if (PlanProducts != undefined) {
            savePlanProducts({ planProducts: PlanProducts })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Plan Products are updated successfully!',
                        variant: 'success'
                    })
                );
                // Clear all draft values
                this.draftValues = [];

                //hide the datatable footer
                this.displayDataTableFooter = false;

               return this.handleRefresh();
            })
            .catch(error => {
                console.log(`save error --> ${(error)}`);
                console.log(`save error --> ${JSON.stringify(error)}`);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
    }

*/
  //handler to cancel the changes made in the UI
  handleCancel(event) {
    console.log("$$$$$$$$$ In CANCEL $$$$$$$$$");
    this.showErrorMessage = undefined;
    //remove draftValues & revert data changes
    this.data = JSON.parse(JSON.stringify(this.lastSavedData));
    console.log(`draft --> ${JSON.stringify(this.draftValues)}`);
    this.draftValues = [];

    //hide the datatable footer
    this.displayDataTableFooter = false;
    this.displaycancel = false;
    if (this.fromcreatepage) {
      this.navigateToRecordViewPage(this.accountlobid);
    } else if (this.fromeditpage) {
      this.navigateToRecordViewPage(this.recordId);
    }
  }

  //handler to remove plan products from the plan
  handleRemove(event) {
    const PlanProds = this.selectedRow;

    console.log("**add Plan Products size = " + PlanProds.length);
    console.log("countAssignedProducts = " + this.countAssignedProducts);

    if (PlanProds != undefined && PlanProds.length > 0) {
      if (PlanProds.length == this.countAssignedProducts) {
        this.showErrorMessage = "Cannot remove all Products from the Plan";
      } else if (!this.containsRiskProduct) {
        this.isLoading = true;
        removePlanFromPlanProducts({ planProducts: PlanProds })
          .then((result) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Plan Products removed from Plan Successfully",
                variant: "success"
              })
            );

            //clear the selected rows
            this.selectedRow = [];

            //hide the datatable footer
            this.displayDataTableFooter = false;

            if (this.fromcreatepage || this.fromeditpage)
              this.displaycancel = true;
            else this.displaycancel = false;

            this.isLoading = false;

            return this.handleRefresh();
          })
          .catch((error) => {
            console.log(`save error --> ${JSON.stringify(error)}`);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error occurred :",
                message: error.body.message,
                variant: "error"
              })
            );
            this.isLoading = false;
          });
      } else if (this.containsRiskProduct) {
        this.showErrorMessage =
          "One of the Plan Product is associated to Risk, please disassociate";
      }
    } else {
      this.showErrorMessage = "Please select a Product to remove from the Plan";
    }
  }

  //---------Start (VKOTAPATI)

  navigateToRecordEditPage() {
    // Opens the Account record modal
    // to view a particular record.
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Plan__c", // objectApiName is optional
        actionName: "edit"
      }
    });
  }

  navigateToRecordViewPage(createdplanid) {
    // Opens the Account record modal
    // to view a particular record.
    console.log("inside navigation");
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: createdplanid,
        objectApiName: "Plan__c", // objectApiName is optional
        actionName: "view"
      }
    });
  }

  //---------End (VKOTAPATI)

  //handler to add plan products to the plan
  handleAdd(event) {
    var planid = this.recordId;
    const PlanProds = this.selectedRow;
    this.showErrorMessage = undefined;
    console.log("handleadd");
    if (this.fromcreatepage) {
      if (PlanProds.length > 0) {
        this.isLoading = true;
        insertplan({
          planRec: this.plansobject,
          planRecTypeId: this.planrectypeid
        })
          .then((result) => {
            console.log("result from insertplan" + result);
            planid = result;
            addPlanProductsToPlan({ planProducts: PlanProds, planId: planid })
              .then((result) => {
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Success",
                    message: "Plan Products added to the Plan Successfully",
                    variant: "success"
                  })
                );

                //clear the selected rows
                this.selectedRow = [];

                //hide the datatable footer
                this.displayDataTableFooter = false;

                if (this.fromcreatepage || this.fromeditpage)
                  this.displaycancel = true;
                else this.displaycancel = false;

                //this.handleRefresh();
                console.log("planid = " + planid);
                console.log("navigating to view page");
                this.isLoading = false;
                this.navigateToRecordViewPage(planid);
              })
              .catch((error) => {
                console.log(`save error --> ${JSON.stringify(error)}`);
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Error occurred :",
                    message: error.body.message,
                    variant: "error"
                  })
                );
                this.isLoading = false;
              });
          })
          .catch((error) => {
            console.log(`save error --> ${JSON.stringify(error)}`);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error occurred :",
                message: error.body.message,
                variant: "error"
              })
            );
          });
      } else if (PlanProds.length < 1) {
        this.showErrorMessage = "Please select a Product to add to the Plan";
      }
    } else {
      console.log("planid" + planid);
      if (PlanProds != undefined && PlanProds.length > 0) {
        this.isLoading = true;
        addPlanProductsToPlan({ planProducts: PlanProds, planId: planid })
          .then((result) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Plan Products added to the Plan Successfully",
                variant: "success"
              })
            );

            //clear the selected rows
            this.selectedRow = [];

            //hide the datatable footer
            this.displayDataTableFooter = false;

            if (this.fromcreatepage || this.fromeditpage)
              this.displaycancel = true;
            else this.displaycancel = false;

            this.isLoading = false;

            console.log("fromeditpage = " + this.fromeditpage);
            if (this.fromeditpage) {
              this.navigateToRecordViewPage(planid);
            }

            return this.handleRefresh();
          })
          .catch((error) => {
            console.log(`save error --> ${JSON.stringify(error)}`);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error occurred :",
                message: error.body.message,
                variant: "error"
              })
            );
            this.isLoading = false;
          });
      } else {
        this.showErrorMessage = "Please select a Product to add to the Plan";
      }
    }
  }

  /*
   **** Datatable inline edit functionality - end ****
   */

  showNotApplicableProducts(event) {
    this.showNotApplicableProds = event.target.checked;
    console.log("show NA Products = " + this.showNotApplicableProds);
    this.handleRefresh();
  }

  get showError() {
    return this.showErrorMessage;
  }

  //Validation
  /*
    containsRiskProduct() {
        let returnMessage = false;
        let tempData = JSON.parse(JSON.stringify(this.selectedRows));
            for (let i = 0; i < tempData.length; i++) {
                if (tempData[i].Risk_formula__c == true) {
                    returnMessage = true;
                }
            }
        console.log('selection contains risk --> ' + returnMessage);
        return returnMessage;
    }
    */
}