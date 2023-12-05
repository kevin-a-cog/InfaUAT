/*
 * Name			:	esOrgDetails
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/21/2022
 * Description	:	This LWC displays org related details

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran      10/21/2022		I2RT-7256		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { esUtilities } from 'c/esUtilities';

//Custom Labels
import Invalid_Access from '@salesforce/label/c.Invalid_Access';

//Apex Controllers.
import getOrgDetails from "@salesforce/apex/OrgDetailController.getOrgDetails";

export default class EsOrgDetails extends LightningElement {

    //Track variables
    @track objOrg;
    @track lstAllOrgUsers = [];

    //Private variables
    strRecordId;
    strSearchTerm;
    strIconName = 'utility:down';
    strSortDirection = 'asc';
    strSortedBy;
    objLabel = {
        Org_Name: 'ORG Name',
        Org_Id: 'Org ID',
        Pod_Location: 'POD Location',
        Pod_Name: 'POD Name',
        Pod_Region: 'POD Region'
    };
    label = {
        Invalid_Access
    };
    lstColumns = [
        { label: 'First Name', fieldName: 'strFirstName', type: 'text', sortable: true },
        { label: "Last Name", fieldName: "strLastName", type: "text", sortable: true },
        { label: "Email Address", fieldName: "strEmail", type: "text", sortable: true },
        { label: "Phone Number", fieldName: "strPhoneNumber", type: "text", sortable: true },
        { label: "Contact Time Zone", fieldName: "strTimezone", type: "text", sortable: true },
        { label: "Language", fieldName: "strLanguage", type: "text", sortable: true }
    ]; 
    intCurrentPage = 1;
    intTotalPages = 0;
    intTotalRecords = 0;
    intRecordPerPage = 10;
    boolIsLoading = true;
    boolHasAccess = false;
    

    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters  : None
     Return Type : None
    */
    connectedCallback() {
        let objParent = this;

        //Now, we fetch the parameters from URL
        let url = new URL(encodeURI(window.location.href));
        objParent.strRecordId = url.searchParams.get('orgId');
        objParent.loadInitialDetails();
    }

    /*
     Method Name : loadInitialDetails
     Description : This method fetches initial details.
     Parameters  : None
     Return Type : None
    */
    loadInitialDetails(){
        let objParent = this;

        //Now, we query the data
        getOrgDetails({ orgId : objParent.strRecordId })
        .then(objResult => {
            if(!objResult.boolShowInvalidAccessMessage){
                objParent.objOrg = objResult.objOrg;
                objParent.lstAllOrgUsers = objParent.parseData(objResult.lstOrgUsers);
                objParent.resetPaginationValues();
                objParent.boolHasAccess = true;
            }
         })
         .catch(objError => {
            objUtilities.processException(objError, objParent);
         })
         .finally(() => {
            objParent.boolIsLoading = false;
         });
    }

    /*
     Method Name : parseData
     Description : This method constructs org users data to be used in the datatable.
     Parameters  : Array, called from loadInitialDetails, lstOrgUsers
     Return Type : None
    */
    parseData(lstOrgUsers){
        let lstOrgUsersParsed = [];

        lstOrgUsers.forEach(objOrgUser => {
            if(objUtilities.isObject(objOrgUser.Contact__r)){
                lstOrgUsersParsed.push({
                    strFirstName: objOrgUser.Contact__r?.FirstName, 
                    strLastName: objOrgUser.Contact__r?.LastName, 
                    strEmail: objOrgUser.Contact__r?.Email, 
                    strPhoneNumber: objOrgUser.Contact__r?.Phone, 
                    strTimezone: objOrgUser.Contact__r?.TimeZone_Lookup__r?.Name, 
                    strLanguage: objOrgUser.Contact__r?.INFA_Language__c,
                    boolIsVisible: true
                });
            }
            else{
                lstOrgUsersParsed.push({
                    strFirstName: objOrgUser?.FirstName__c, 
                    strLastName: objOrgUser?.LastName__c, 
                    strEmail: objOrgUser?.Email__c, 
                    strPhoneNumber: objOrgUser?.PhoneNumber__c, 
                    strTimezone: '', 
                    strLanguage: '',
                    boolIsVisible: true
                });
            }
        });

        return lstOrgUsersParsed;
    }

    /*
     Method Name : resetPaginationValues
     Description : This method resets pagination values based on the visible records .
     Parameters  : None
     Return Type : None
    */
    resetPaginationValues(){
        let objParent = this;
        let intDataLength = objParent.lstAllOrgUsers.filter(obj => obj.boolIsVisible === true).length;

        objParent.intCurrentPage = intDataLength >= 1 ? 1 : 0;
        objParent.intTotalRecords = intDataLength;
        objParent.intTotalPages = Math.ceil(objParent.intTotalRecords/objParent.intRecordPerPage);
    }

    /*
     Method Name : toggle
     Description : This method toggles the icon and hide the section .
     Parameters  : Object, called from toggle, objEvent On click event.
     Return Type : None
    */
    toggle(objEvent) {
        let currentDivElement = objEvent.target;
        let divElement = this.template.querySelector(`[data-id="${objEvent.target.dataset.targetId}"]`);
        divElement.buttonClicked = !divElement.buttonClicked;
        divElement.className = divElement.buttonClicked ? 'slds-media slds-media_center es-slds-media slds-hide' : 'slds-media slds-media_center es-slds-media slds-show';
        currentDivElement.iconName = divElement.buttonClicked ? 'utility:right' : 'utility:down';
    }

    /*
	 Method Name : search
	 Description : This method searches across records.
	 Parameters	 : Event, called from search, objEvent Event.
	 Return Type : None
	*/
    search(objEvent){
        let objParent = this;
        objParent.strSearchTerm = objEvent.target.value?.toLocaleLowerCase();
        objParent.lstAllOrgUsers.forEach(objOrgUser => {
            let strSearchValue = Object.values(objOrgUser).join(' ').toLocaleLowerCase();
            if(objUtilities.isBlank(objParent.strSearchTerm) || strSearchValue.includes(objParent.strSearchTerm)) {
				objOrgUser.boolIsVisible = true;
			} else {
				objOrgUser.boolIsVisible = false;
			}
        });
        objParent.resetPaginationValues();
    }

    /*
	 Method Name : sort
	 Description : This method sorts the data.
	 Parameters	 : Event, called from sort, objEvent On click Event.
	 Return Type : None
	*/
    sort(objEvent){
        let objParent = this;
        let lstClonedData = [...objParent.lstAllOrgUsers];
        const { fieldName: sortedBy, sortDirection } = objEvent.detail;

        objParent.lstAllOrgUsers = lstClonedData.sort(esUtilities.sortBy(objParent.strSortedBy, objParent.strSortDirection === 'asc' ? 1 : -1));
        objParent.strSortedBy = sortedBy;
        objParent.strSortDirection = sortDirection;
    }

    /*
	 Method Name : first
	 Description : This method sets the current page to the first page.
	 Parameters	 : None
	 Return Type : None
	*/
    first(){
        this.intCurrentPage = this.intTotalPages >= 1 ? 1 : 0;
    }

    /*
	 Method Name : last
	 Description : This method sets the current page to the last page.
	 Parameters	 : None
	 Return Type : None
	*/
    last(){
        this.intCurrentPage = this.intTotalPages >= 1 ? this.intTotalPages : 0;
    }

    /*
	 Method Name : next
	 Description : This method sets the current page to the next page.
	 Parameters	 : None.
	 Return Type : None
	*/
    next(){
        this.intCurrentPage = (this.intTotalPages >= 1 && this.intCurrentPage >= 1 && this.intCurrentPage != this.intTotalPages) ? (this.intCurrentPage + 1) : this.intCurrentPage;
    }

    /*
	 Method Name : previous
	 Description : This method sets the current page to the previous page.
	 Parameters	 : None.
	 Return Type : None
	*/
    previous(){
        this.intCurrentPage = (this.intTotalPages >= 1 && this.intCurrentPage >= 1 && this.intCurrentPage !== 1) ? (this.intCurrentPage - 1) : this.intCurrentPage; 
    }

    /* Getter Methods */
    get startingRecord(){
        return this.intCurrentPage > 0 ? (this.intCurrentPage * this.intRecordPerPage) - this.intRecordPerPage + 1 : 0;
    }

    get endingRecord(){
        return this.intCurrentPage === this.intTotalPages && (this.intTotalRecords % this.intRecordPerPage) >= 1 ? this.intTotalRecords : (this.intCurrentPage * this.intRecordPerPage);
    }

    get lstOrgUsers(){
        return this.lstAllOrgUsers?.filter(obj => obj.boolIsVisible === true)?.slice((this.intCurrentPage * this.intRecordPerPage) - this.intRecordPerPage, this.intCurrentPage * this.intRecordPerPage);
    }

}