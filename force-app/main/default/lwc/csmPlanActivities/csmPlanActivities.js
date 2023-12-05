/*
 * Name			:	CsmPlanActivities
 * Author		:	Deva M
 * Created Date	: 	05-April-2022
 * Description	:	Manage Plan activity 

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		05-April-2022		N/A				Initial version.			N/A
 */
//Core imports.
import { api, LightningElement } from 'lwc';

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import Loading from '@salesforce/label/c.Loading';
import Error from '@salesforce/label/c.Error';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMPlanActivitiesController.getRecords";

//Utilities.
import { objUtilities } from 'c/globalUtilities';
export default class CsmPlanActivities extends LightningElement {
    //API variables.
	@api recordId;
    @api isPoppedOut = false;
    //Private variables.
	boolDisplaySpinner;

    //Labels.
	label = {
		Refresh_Button,		
		Loading,
		Error
	}

    //Feature Configuration.
    objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: "Plan Activities",
		strSearchPlaceholder: "Search activity",
        boolDisplayActions:false,
        strTableClass:"managePlanActivity",
        boolEnablePopOver:false,
        boolHideCheckboxColumn:true
	}

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.boolDisplaySpinner = true;
		//Now we load the list of records.
		this.loadRecords();	
	}

    /*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

    /*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		this.template.querySelector('.' + this.objConfiguration.objParameters.strTableClass).searchRecord(objEvent);
	}
    /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let objParent = this;		
		//Now we fetch the data.
		getRecords({
			strRecordId: this.recordId
		}).then((objResult) => {	
            objResult.lstColumns.forEach(objCol => {
                if(objCol.strFieldName==="WhatId"){
                    objCol.label = "Related To";
                }
            });
            
			//We build the tables.
			objParent.objConfiguration.lstRecords = objResult.lstRecords;
			objParent.objConfiguration.lstColumns = objResult.lstColumns;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

    /*
    Method Name : refreshCard
    Description : This method reloads all the data in the card.
    Parameters	 : Event, called from popOut, objEvent click event.
    Return Type : None
    */
    refreshCard(objEvent) {
        if(typeof objEvent !== "undefined" && objEvent !== null) {
            objEvent.preventDefault();
        }

        //We refresh the table.
        this.boolDisplaySpinner = true;
        this.template.querySelector('.searchField').value = "";
        this.loadRecords();
        return false;
    }
}