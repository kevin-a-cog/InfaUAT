/*
 * Name			:	esManageCases
 * Author		:	Chetan Shetty
 * Created Date	: 	9/23/2022
 * Description	:	This is used to show & manage cases in eSupport.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					        Tag
 **********************************************************************************************************
 Chetan Shetty		    9/23/2022		I2RT-6880		Initial version.			        N/A
 Vignesh Divakaran	    9/24/2022		I2RT-6880		Initial version.			        T01
 balajip        		1/12/2023		I2RT-7537		Updated the sorting order logic     T02
*/

//Core imports.
import { LightningElement, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Static Resource
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

//Custom Labels
import Invalid_Access from '@salesforce/label/c.Invalid_Access';
import Case_Lite_Subscription_ended_Message from '@salesforce/label/c.Case_Lite_Subscription_ended_Message';

//Apex Controllers.
import getFilters from "@salesforce/apex/ManageCasesController.getFilters";
import getRecords from "@salesforce/apex/ManageCasesController.getRecords";

export default class EsManageCases extends LightningElement {

    //Track variables
    @track lstRecords;
    @track lstSelectedOrgs = [];
    @track lstSelectedStatus = [];
    @track lstAllFilters = [];

    //Private variables
    lstOrgs;
    mapOrgIdToUUID;
    lstStatus;
    intSearchType;
    strSearchTerm;
    strProductName;
    intLastViewedRecordCount; //T02
    boolShowSupportAccount = false;
    boolHasRecords;
    boolShowTileView = false;
    boolDisplaySpinner;
    boolInitialLoad;
    strCaseNumberSorting = ''; //T02
    boolShowDownload = false;
    boolShowViewMore;
    boolLoadingMoreRecords;
    boolShowInvalidAccessMessage;
    boolShowExpiredSubscriptionMessage;
    image = {
        Case_Banner: ESUPPORT_RESOURCE + '/case.png',
        Tile_Grey: ESUPPORT_RESOURCE + "/tile-grey.svg",
        Tile_Orange: ESUPPORT_RESOURCE + "/tile-color.svg",
        List_Grey: ESUPPORT_RESOURCE + "/list-grey.svg",
        List_Orange: ESUPPORT_RESOURCE + "/list-color.svg",
    };
    label = {
        My_Cases: 'My Cases',
        All_Cases: 'All Cases',
        No_Records_Found: 'No records found',
        Clear_All_Filters: 'Clear All Filters',
        Invalid_Access,
		Case_Lite_Subscription_ended_Message
    };

    //T02 add None value which indicates default sorting
    lstSortValues = [
		{
			label: "None",
            value: ""
		},{
			label: "Ascending",
            value: "ASC"
		}, {
			label: "Descending",
			value: "DESC"
		}
	];

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		objParent.boolInitialLoad = true;
        objParent.mapOrgIdToUUID = new Map();

        //Now, we fetch the parameters from URL
        let url = new URL(encodeURI(window.location.href));
        objParent.strProductName = url.searchParams.get('product')?.replaceAll('%20', ' ');
        
        //We load the filter values.
		getFilters().then(objResponse => {
            let lstOrgs = [];

            objResponse.lstOrgs.forEach(objOption => {
                if(!objParent.mapOrgIdToUUID.has(objOption.strLabel)){
                    objParent.mapOrgIdToUUID.set(objOption.strLabel, objOption.strValue);
                }
                lstOrgs.push({strLabel: objOption.strLabel, strValue: objOption.strLabel});
            }) 
            objParent.lstOrgs = lstOrgs;
            objParent.lstStatus = objParent.processFilter(objResponse.lstStatus);
            objParent.loadRecords();
			
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
    }

    /*
	 Method Name : loadRecords
	 Description : This method loads the backend data.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let objParent = this;
        let objRequest;
        let lstSelectedOrgs = [];
        
        //Now, we clear the array and display spinner when we're not loading more records
        if(!objParent.boolLoadingMoreRecords){
            objParent.lstRecords = [];
            objParent.boolDisplaySpinner = true;
            objParent.intLastViewedRecordCount = 0; //T02
        }

        //Now, we get replace the Org UUID with Org record id.
        objParent.lstSelectedOrgs.forEach(strOrgUUID => {
            if(objParent.mapOrgIdToUUID.has(strOrgUUID)){
                lstSelectedOrgs.push(objParent.mapOrgIdToUUID.get(strOrgUUID));
            }
        });

        objRequest = {
			objRequest: {
				intSearchType: objParent.intSearchType,
                strCaseNumberSorting: objParent.strCaseNumberSorting, //T02
                lstOrgs: lstSelectedOrgs,
                lstStatus: objParent.lstSelectedStatus,
                intLastViewedRecordCount: objParent.intLastViewedRecordCount //T02
			}
		};

        //Now, we query the data
        getRecords(objRequest).then(objResult => {

            objParent.boolShowInvalidAccessMessage = objResult.boolShowInvalidAccessMessage;
            objParent.boolShowExpiredSubscriptionMessage = objResult.boolShowExpiredSubscriptionMessage;
            
            if(Array.isArray(objResult?.lstRecords) && objResult?.lstRecords.length >= 1){
                objResult?.lstRecords.forEach(objRecord => {
                    //Now, we default Next Action values to Informatica if it's anything other than Customer
                    objRecord.Next_Action__c = objUtilities.isNotBlank(objRecord?.Next_Action__c) && objRecord?.Next_Action__c !== 'Customer' ? 'Informatica' : objRecord?.Next_Action__c;
                    objParent.lstRecords.push({
                        ...objRecord,
                        boolIsVisible: true,
                        strSearchValue: (objRecord.Status + " " + objRecord.Forecast_Product__c + " " + objRecord.Org_Formula_Id__c + " " + objRecord.CaseNumber + " " + objRecord.Subject + " " + objRecord.Priority).toLocaleLowerCase()
                    });
                });
                objParent.boolShowViewMore = objResult.boolShowViewMore;
                objParent.intLastViewedRecordCount = objResult.boolShowViewMore ? objResult.intLastViewedRecordCount : 0; //T02
                objParent.boolHasRecords = true;
            }
            else{
                objParent.boolHasRecords = false;
            }

        }).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
            objParent.boolInitialLoad = false;
            objParent.boolDisplaySpinner = false;
            objParent.boolLoadingMoreRecords = false;
        });

    }

    /*
     Method Name : processFilter
     Description : This method returns processed filters options as an array of objects.
     Parameters	 : Array, called from processFilter, lstOptions.
     Return Type : Array
     */
    processFilter(lstOptions){
        let lstOptionsFormatted = [];
        lstOptions.forEach(objOption => lstOptionsFormatted.push({strLabel: objOption.strLabel, strValue: objOption.strValue}));
        return lstOptionsFormatted;
    }

    /*
     Method Name : toggleView
     Description : This method toggles between tile & list view.
     Parameters	 : Object, called from toggleView, objEvent On click event.
     Return Type : None
     */
    toggleView(objEvent){
        let intView = parseInt(objEvent.currentTarget.dataset.id);
        if((intView == 1 && !this.boolShowTileView) || (intView == 2 && this.boolShowTileView)){
            this.boolShowTileView = !this.boolShowTileView;
        }
    }

    /*
	 Method Name : setActiveTab
	 Description : This method sets the active tab.
	 Parameters	 : Event, called from setActiveTab, objEvent Event.
	 Return Type : None
	 */
	setActiveTab(objEvent) {
        this.intSearchType = parseInt(objEvent.target.value);
		this.clearFilters();
	}

    /*
	 Method Name : setSortDirection
	 Description : This method sets the sorting direction.
	 Parameters	 : Event, called from setSortDirection, objEvent Event.
	 Return Type : None
	 */
	setSortDirection(objEvent) {
        this.strCaseNumberSorting = objEvent.detail.value; //T02
		this.loadRecords();
	}

    /*
	 Method Name : loadMore
	 Description : This method loads more cases.
	 Parameters	 : None
	 Return Type : None
	 */
    loadMore(){
        this.boolLoadingMoreRecords = true;
        this.loadRecords();
    }
    
    /*
	 Method Name : search
	 Description : This method searches across records.
	 Parameters	 : Event, called from search, objEvent Event.
	 Return Type : None
	 */
	search(objEvent) {
		let objParent = this;
		objParent.strSearchTerm = objEvent.target.value.toLocaleLowerCase();
		objParent.lstRecords.forEach(objRecord => {
			if(objUtilities.isBlank(objParent.strSearchTerm) || objRecord.strSearchValue.includes(objParent.strSearchTerm)) {
				objRecord.boolIsVisible = true;
			} else {
				objRecord.boolIsVisible = false;
			}
		});
	}

    /*
     Method Name : filterSelect
     Description : This method updates the selected filter options and reloads the records.
     Parameters	 : Object, called from filterSelect, objEvent On valueselection event.
     Return Type : None
     */
    filterSelect(objEvent){
        let objParent = this;
        let lstAllFilters = [];
        
        switch (objEvent.detail.name) {
            case 'ORG ID':
                objParent.lstSelectedOrgs = [...objEvent.detail.selectedValues];
                break;
            case 'Status':
                objParent.lstSelectedStatus = [...objEvent.detail.selectedValues];
                break;
            default:
                //Do nothing
                break;
        }
        objParent.lstSelectedStatus.forEach(strValue => lstAllFilters.push({strName: 'Status',strValue: strValue}));
        objParent.lstSelectedOrgs.forEach(strValue => lstAllFilters.push({strName: 'ORG ID',strValue: strValue}));
        objParent.lstAllFilters = lstAllFilters;
        objParent.loadRecords();
    }

    /*
     Method Name : removeSelection
     Description : This method removes a specific selected filter based on the filter name & then reloads the records.
     Parameters	 : Object, called from removeSelection, objEvent On removeselection event.
     Return Type : None
     */
    removeSelection(objEvent){
        let objParent = this;
        let strName = objEvent?.detail?.objOption?.strName;
        let strValue = objEvent?.detail?.objOption?.strValue;

        if(objUtilities.isNotBlank(strValue)){
            let filterComponent = objParent.template.querySelector(`c-global-community-filter-picklist[data-name="${strName}"]`);
            if(filterComponent){
                filterComponent.clearSpecific(strValue);
            }
            if(strName === 'ORG ID'){
                objParent.lstSelectedOrgs = objParent.lstSelectedOrgs.filter(strSelectedValue => strSelectedValue !== strValue);
            }
            else if(strName === 'Status'){
                objParent.lstSelectedStatus = objParent.lstSelectedStatus.filter(strSelectedValue => strSelectedValue !== strValue);
            }
            objParent.lstAllFilters = objParent.lstAllFilters.filter(objOption => objOption.strValue !== strValue);
            objParent.loadRecords();
        }
    }

    /*
     Method Name : clearFilters
     Description : This method removes all selected filters from the LWC & then reloads the records.
     Parameters	 : None
     Return Type : None
     */
    clearFilters(){
        let objParent = this;
        objParent.strSearchTerm = undefined;
        objParent.lstAllFilters = [];
        objParent.lstSelectedOrgs = [];
        objParent.lstSelectedStatus = [];
        objParent.strCaseNumberSorting = ''; //T02
        objParent.template.querySelectorAll('c-global-community-filter-picklist').forEach(filterComponent => {
            filterComponent.clearAll();
        });
        objParent.loadRecords();
    }

    /*
     Method Name : download
     Description : This method opens the case download widget
     Parameters	 : None
     Return Type : None
     */
    openDownload(){
        this.boolShowDownload = true;
    }

    /*
     Method Name : download
     Description : This method closes the case download widget
     Parameters	 : None
     Return Type : None
     */
    closeDownload(){
        this.boolShowDownload = false;
    }

    /*
     Method Name : redirectToCaseCreation
     Description : This method redirects user to Case Lite case creation page.
     Parameters	 : None
     Return Type : None
    */
    redirectToCaseCreation(){
        if(objUtilities.isNotBlank(this.strProductName)){
            window.open(`newcaselite?product=${this.strProductName}&from=1`, '_blank');
        }
    }

    /* Getter Methods */
    get tileImage(){
        return this.boolShowTileView ? this.image.Tile_Orange : this.image.Tile_Grey;
    }

    get listImage(){
        return this.boolShowTileView ? this.image.List_Grey : this.image.List_Orange;
    }

    get showSelectedFilters(){
        return this.lstAllFilters.length >= 1 ? true : false;
    }

    get showErrorMessage(){
        return this.boolShowExpiredSubscriptionMessage || this.boolShowInvalidAccessMessage;
    }

    get strErrorMessage(){
        let strMessage;
        if(this.boolShowExpiredSubscriptionMessage){
            strMessage = this.label.Case_Lite_Subscription_ended_Message;
        }
        else if(!this.boolHasRecords){
            strMessage = this.label.Invalid_Access;
        }
        else{
            strMessage = this.label.Invalid_Access;
        }
		return strMessage;
	}

    get showViewMore(){
        return this.boolShowViewMore && objUtilities.isBlank(this.strSearchTerm);
    }
}