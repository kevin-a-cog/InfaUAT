import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import insertRisk from '@salesforce/apex/ManageRiskProductsController.insertRisk';
import getRiskProducts from '@salesforce/apex/ManageRiskProductsController.getRiskProducts';
import getPlanProducts from '@salesforce/apex/ManageRiskProductsController.getPlanProducts';
import removeRiskProducts from '@salesforce/apex/ManageRiskProductsController.removeRiskProducts';
import addRiskProducts from '@salesforce/apex/ManageRiskProductsController.addRiskProducts';
import PLAN_ID from '@salesforce/schema/Risk_Issue__c.Plan__c';
import RISK_STATUS from '@salesforce/schema/Risk_Issue__c.Status__c';/**<T01>*/
import isCSOUser from '@salesforce/customPermission/CSOUser';
const RISK_PRODUCTS = 'Risk Products';
const PLAN_PRODUCTS = 'Plan Products';

const tabsObj = [
    { tab: RISK_PRODUCTS, helpText: 'All the Risk Products tied to Risk' },
    { tab: PLAN_PRODUCTS, helpText: 'All the plan products under the current plan that have not been associated with this risk' }
]



export default class ManageRiskProducts extends NavigationMixin(LightningElement) {

    //-------------------------------api parameters set from risk create and edit pages ()
    @api fromeditpage;
    @api fromcreatepage;
    @api risksobject;
    @api planidpassed;
    @api recordId;
    @track riskRecId;
    @track riskRecord;
    @track columns;
    @track data;
    @track tabs = tabsObj;
    @track defaultTabOnInitialization = 'Risk Products';
    @track displayDataTableFooter = false;
    @track currentTabValue;
    @track displayRemoveBTN = false;
    @track displayAddBTN = false;
    @track NoDataAfterRendering = false;
    @track selectedRow = [];
    @track draftValues = [];
    @track showErrorMessage ;
    @track disableAddButton = false; /** Pavithra  */

    //get record id
    @wire(getRecord, { recordId: '$recordId', fields: [PLAN_ID,RISK_STATUS] }) riskRecord;/**<T01> Pavithra - AR-1393 Risk cannot be edited after the status is Closed*/


    //--------Start ()
    @track isLoading = false;
    settings = {
        fieldNameRecordName: '__Name',
        fieldNameRecordURL: '__RecordURL',
        fieldNameContractNumber: '__ContractNumber',
        fieldNameContractRecordURL: '__ContractRecordURL',
        fieldNameOpportunityName: '__OpportunityName',
        fieldNameOpportunityRecordURL: '__OpportunityRecordURL',
        fieldNamePlanName: '__PlanName',
        fieldNamePlanRecordURL: '__PlanRecordURL',
        fieldNamePlanProductName: '__PlanProductName',
        fieldNamePlanProductURL: '__PlanProductURL',
        fieldNameAccountProductName: '__AccountProductName'
    };

    //--------End ()


    COL_RISK_PRODUCTS = [
        {
            label: "Name",
            fieldName: this.settings.fieldNameRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNameRecordName }, target: "_blank" }
        },
        {
            label: 'Plan Product',
            fieldName: this.settings.fieldNamePlanProductURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNamePlanProductName }, target: "_blank" }
        },
        { label: 'Forecast Product', fieldName: 'Forecast_Product__c', initialWidth: 150 },
        { label: 'Delivery Method', fieldName: 'Delivery_Method__c' },
        { label: 'Pricing Business Model', fieldName: 'Pricing_Business_Model__c' },
        { label: 'Offering Type', fieldName: 'Offering_Type__c' },
        { label: ' Product',
         fieldName: this.settings.fieldNameAccountProductName
        },

    ]
    //Unassigned Products tab columns
    COL_PLAN_PRODUCTS = [
        {
            label: "Name",
            fieldName: this.settings.fieldNameRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNameRecordName }, target: "_blank" }
        },
        {
            label: 'Contract Number',
            fieldName: this.settings.fieldNameContractRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNameContractNumber }, target: "_blank" }
        },
        {
            label: 'Opportunity Name',
            fieldName: this.settings.fieldNameOpportunityRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNameOpportunityName }, target: "_blank" }
        },
        {
            label: 'Plan',
            fieldName: this.settings.fieldNamePlanRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: this.settings.fieldNamePlanName }, target: "_blank" }
        },
        { label: 'Forecast Product', fieldName: 'Forecast_Product__c', initialWidth: 150 },
        { label: 'Delivery Method', fieldName: 'Delivery_Method__c' },
        { label: 'Pricing Business Model', fieldName: 'Pricing_Business_Model__c' },
        { label: 'Offering Type', fieldName: 'Offering_Type__c' },
        //{ label: 'ARR', fieldName: 'ARR__c', type: 'currency',typeAttributes: {currencyCode: {fieldName: 'CurrencyIsoCode'}}  },
        { label: 'ARR', fieldName: 'ConvertedARR', type: 'text', initialWidth: 260 },
        { label: 'Stage', fieldName: 'Stage__c' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date-local', typeAttributes: { year: 'numeric', month: 'short', day: 'numeric' } },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Product', fieldName: 'Product__c' }

    ];


    //----Start ()
    connectedCallback() {
       console.log('isCSOUser ===>'+ isCSOUser);
        this.riskRecId = this.recordId;
        if (this.fromcreatepage) {
            this.tabs = [tabsObj[1]];
            this.defaultTabOnInitialization = PLAN_PRODUCTS;
        } else {
            this.defaultTabOnInitialization = RISK_PRODUCTS;
            this.tabs = tabsObj;
        }
    }


    getRecordURL(sObject, Id) {
        return '/lightning/r/' + sObject + '/' + Id + '/view';
    }

    //---------End ()


    //handle tab selection
    handleActiveTab(event) {
        this.currentTabValue = event.target.value;
        this.handleRefresh();
    }

    //handle refresh of the data table
    handleRefresh() {
        this.showErrorMessage = undefined;
        this.NoDataAfterRendering = false;
        const riskId = this.riskRecId;
        if (this.currentTabValue == RISK_PRODUCTS) {

            this.columns = this.COL_RISK_PRODUCTS;
            this.data = undefined;

            getRiskProducts({ riskId: riskId })
                .then(result => {

                    let tempData = JSON.parse(JSON.stringify(result));
                    if (tempData.length > 0) {
                        // console.log('tempData before processing ==> ' + JSON.stringify(tempData));

                        for (let i = 0; i < tempData.length; i++) {
                            
                            tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
                            tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL('Related_Risk_Product__c', tempData[i].Id);

                            if (tempData[i].Plan_Product__c != undefined) {
                                tempData[i][this.settings.fieldNamePlanProductName] = tempData[i].Plan_Product__r.Name;
                                tempData[i][this.settings.fieldNamePlanProductURL] = this.getRecordURL('Related_Account_Plan__c', tempData[i].Plan_Product__c);
                            }
                            if (tempData[i].Account_Product__c != undefined) {
                                tempData[i][this.settings.fieldNameAccountProductName] = tempData[i].Account_Product__r.Forecast_Product__c;
                            }

                        }

                        //   console.log('tempData after processing ==> ' + JSON.stringify(tempData));
                        this.data = tempData;
                        //  console.log('data after processing ==> ' + JSON.stringify(this.data));

                        //set visibiltiy for action buttons in datatable footer based on the active tab
                        this.displayRemoveBTN = true;
                        this.displayAddBTN = false;

                    } else {
                        console.log('NoDataAfterRendering after processing ==> ' + JSON.stringify(this.NoDataAfterRendering));
                        //Show No Products to display message
                        this.NoDataAfterRendering = true;
                    }
                })
                .catch(error => {
                    console.log('error ' + error);
                })
        }

        else if (this.currentTabValue == PLAN_PRODUCTS) {
            this.columns = this.COL_PLAN_PRODUCTS;
            this.data = undefined;
            let planId = '';
            if (this.fromcreatepage) {
                planId = this.planidpassed;
            } else {
                planId = getFieldValue(this.riskRecord.data, PLAN_ID);
            }

            getPlanProducts({ riskId: riskId, planId: planId })
                .then(result => {
                    let tempData = JSON.parse(JSON.stringify(result));
                    // console.log('tempData before processing ==> ' + JSON.stringify(tempData));
                    if (tempData.length > 0) {
                        for (let i = 0; i < tempData.length; i++) {
                            
                            tempData[i][this.settings.fieldNameRecordName] = tempData[i].Name;
                            tempData[i][this.settings.fieldNameRecordURL] = this.getRecordURL('Related_Account_Plan__c', tempData[i].Id);

                            if (tempData[i].Contract__r != undefined) {
                                tempData[i][this.settings.fieldNameContractNumber] = tempData[i].Contract__r.ContractNumber;
                                tempData[i][this.settings.fieldNameContractRecordURL] = this.getRecordURL('Contract', tempData[i].Contract__c);
                            }

                            if (tempData[i].Opportunity__r != undefined) {
                                tempData[i][this.settings.fieldNameOpportunityName] = tempData[i].Opportunity__r.Name;
                                tempData[i][this.settings.fieldNameOpportunityRecordURL] = this.getRecordURL('Opportunity', tempData[i].Opportunity__c);
                            }

                            if (tempData[i].Account_Plan__r != undefined) {
                                tempData[i][this.settings.fieldNamePlanName] = tempData[i].Account_Plan__r.Name;
                                tempData[i][this.settings.fieldNamePlanRecordURL] = this.getRecordURL('Plan__c', tempData[i].Account_Plan__c);
                            }

                            if (tempData[i].ARR__c != undefined) {
                                if (tempData[i].CurrencyIsoCode != 'USD') {
                                    tempData[i].ConvertedARR = `${tempData[i].CurrencyIsoCode} ${Number.parseFloat(tempData[i].ARR__c).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} (USD ${Number.parseFloat(tempData[i].ConvertedARR__c).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')})`;
                                }
                                else {
                                    tempData[i].ConvertedARR = `${tempData[i].CurrencyIsoCode} ${Number.parseFloat(tempData[i].ARR__c).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')}`;
                                }
                            }
                        }
                        //   console.log('tempData after processing ==> ' + JSON.stringify(tempData));
                        this.data = tempData;
                        //   console.log('data after processing ==> ' + JSON.stringify(this.data));

                        //set visibiltiy for action buttons in datatable footer based on the active tab
                        this.displayRemoveBTN = false;
                        this.displayAddBTN = true;

                    }
                    else {
                        console.log('NoDataAfterRendering after processing ==> ' + JSON.stringify(this.NoDataAfterRendering));

                        //Show No Products to display message
                        this.NoDataAfterRendering = true;
                    }

                })
                .catch(error => {
                    console.log('error ' + error);
                })
        }

    }

    handleIconRefresh(event) {
        this.handleRefresh();
    }


    //handler to add plan products to the risk
    handleAdd(event) {
        const riskId = this.recordId;
        const PlanProducts = this.selectedRow;
        this.disableAddButton = true; /** <T03> */
        this.isLoading = true;/** <T03> */

        /**<T01> STARTS*/
        let riskStatus = '';
        riskStatus = getFieldValue(this.riskRecord.data,RISK_STATUS);
        console.log('riskStatus===> '+ riskStatus);
        
        if (PlanProducts != undefined && PlanProducts.length > 0) {

            if (this.fromcreatepage) {                
                insertRisk({ riskRec: this.risksobject })
                    .then(result => {
                        const newRiskId = result;
                        if (newRiskId) {
                            addRiskProducts({ planProducts: PlanProducts, riskId: newRiskId })
                                .then(result => {
                                    console.log('Add risk product results ====> '+result );
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'Risk is created with Risk Products Successfully',
                                            variant: 'success'
                                        })
                                    );
                                    //clear the selected rows
                                    this.selectedRow = [];
                                    this.isLoading = false;/** <T03> */
                                    this.disableAddButton = false; /** <T03> */

                                    //hide the datatable footer
                                    this.displayDataTableFooter = false;

                                    this.navigateToRecordViewPage(newRiskId);

                                })
                                .catch(error => {
                                    this.disableAddButton = false; /** <T03> */
                                    this.isLoading = false;/** <T03> */
                                    console.log(`save error during insert of risk Products--> ${JSON.stringify(error)}`);
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error occurred during insert of Risk Products:',
                                            message: error.body,
                                            variant: 'error'
                                        })
                                    );
                                })
                        } else {
                            this.disableAddButton = false; /** <T03> */
                            this.isLoading = false;/** <T03> */
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error occurred during insert of Risk ',
                                    message: error.body,
                                    variant: 'error'
                                })
                            );

                        }
                    })
                    .catch(error => {
                        console.log(`save error --> ${JSON.stringify(error)}`);
                        this.disableAddButton = false; /** <T03> */
                        this.isLoading = false;/** <T03> */
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error occurred during insert of Risk ',
                                message: '',
                                variant: 'error'
                            })
                        );
                    })
            } else {
                // const riksId = this.recordId;
                // const PlanProducts = this.selectedRow; 
                if(riskStatus == 'Closed' && isCSOUser == undefined){
                    // Show the error message 
                    this.showErrorMessage = 'Risk Products cannot be added when the status is closed';
                    this.isLoading = false;/** <T03> */
                    this.disableAddButton = false; /** <T03> */
                }else{ /**<T01> ENDS*/
                    
                if (PlanProducts != undefined && PlanProducts.length > 0) {
                    addRiskProducts({ planProducts: PlanProducts, riskId: riskId })
                        .then(result => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Risk Products are added to the Risk Successfully',
                                    variant: 'success'
                                })
                            );

                            //clear the selected rows
                            this.selectedRow = [];
                            this.draftValues = [];
                            this.isLoading = false;/** <T03> */
                            this.disableAddButton = false; /** <T03> */

                            //hide the datatable footer
                            this.displayDataTableFooter = false;

                            this.handleRefresh();

                            if (this.fromeditpage) {
                                this.navigateToRecordViewPage(riskId);
                            }

                            return this.handleRefresh();

                        })
                        .catch(error => {
                            console.log(`save error --> ${JSON.stringify(error)}`);
                            this.disableAddButton = false; /** <T03> */
                            this.isLoading = false;/** <T03> */
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error occurred :',
                                    message: error.body,
                                    variant: 'error'
                                })
                            );
                    })

            }
        }
        }
        } else  {
            this.disableAddButton = false; /** <T03> */
            this.isLoading = false;/** <T03> */
            this.showErrorMessage = 'Please select a Product to add to the Risk';
            
        }  
        
    }


    //handler to remove plan products from the plan
    handleRemove(event) {
        const RiskProducts = this.selectedRow;
        this.isLoading = true;/** <T03> */
        /**<T01> STARTS */
        let riskStatus = '';
        riskStatus = getFieldValue(this.riskRecord.data,RISK_STATUS);
        console.log('riskStatus===> '+ riskStatus);        

        if (RiskProducts != undefined && RiskProducts.length > 0) {

            if(riskStatus == 'Closed' && isCSOUser == undefined){
                this.isLoading = false;/** <T03> */
                // Show the error message 
                this.showErrorMessage = 'Risk Products cannot be removed when the status is closed';    
            }else{/**<T01> ENDS*/

            removeRiskProducts({ riskProducts: RiskProducts })
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Risk Products removed from Risk Successfully',
                            variant: 'success'
                        })
                    );

                    //clear the selected rows
                    this.selectedRow = [];
                    this.draftValues = [];
                    this.isLoading = false;/** <T03> */
                    //hide the datatable footer
                    this.displayDataTableFooter = false;

                    return this.handleRefresh();
                })
                .catch(error => {
                    console.log(`save error --> ${JSON.stringify(error)}`);
                    this.isLoading = false;/** <T03> */
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error occurred :',
                            message: error.body,
                            variant: 'error'
                        })
                    );
                })
            }

        } else {
            this.isLoading = false;/** <T03> */
            this.showErrorMessage = 'Please select a Product to remove from the Risk';
        }

    }

    handleRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
      //  console.log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
        this.selectedRow = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedRow.push({ Id: selectedRows[i].Id });
        }
        this.draftValues = selectedRows;

       // console.log('selected row final => ' + JSON.stringify(this.selectedRow));
        if (this.selectedRow.length > 0) {
            this.displayDataTableFooter = true;
            this.showErrorMessage= undefined;
        }
        //this.displayRemoveBTN = true;
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
       // console.log(`draft --> ${JSON.stringify(this.selectedRow)}`);
        this.selectedRow = [];
        this.draftValues = [];
        this.showErrorMessage = undefined;
        this.handleRefresh();

        //hide the datatable footer
        this.displayDataTableFooter = false;
        if (this.fromcreatepage) {
            this.navigateToRecordViewPage(this.planidpassed);
        } else if (this.fromeditpage) {
            this.navigateToRecordViewPage(this.recordId);
        }

    }

    navigateToRecordViewPage(createdRiskId) {
        // Opens the Account record modal
        // to view a particular record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: createdRiskId,
                objectApiName: 'Risk_Issue__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    navigateToRecordEditPage() {
        // Opens the Account record modal
        // to view a particular record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Risk_Issue__c', // objectApiName is optional
                actionName: 'edit'
            }
        });
    }

}