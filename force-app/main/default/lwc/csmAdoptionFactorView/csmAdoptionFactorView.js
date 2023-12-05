/*
 * Name			:	CsmAdoptionFactorView
 * Author		:	Deva M
 * Created Date	: 	20/09/2021
 * Description	:	CsmAdoptionFactorView controller

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		20/09/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Custom Labels
import Loading from '@salesforce/label/c.Loading';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Methods
import getRiskRecord from "@salesforce/apex/CSMAdoptionFactorViewController.getRiskRecord";

//Class body.
export default class CsmAdoptionFactorView extends LightningElement {
	//API variables.
    @api recordId;

    @api sourceObject;

	//Private variables.
    isPoppedOut = false;
    boolDisplaySpinner;

    //Labels.
	label = {
		Loading
	}

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
        this.isPoppedOut = objEvent.detail.boolIsPopingOut;
    }
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback(){                  
        let objParent = this;
        if(objUtilities.isNotBlank(objParent.sourceObject) && objParent.sourceObject === 'Risk'){
            objParent.boolDisplaySpinner = true;
            objParent.loadPafRecordForRisk();
        }
    }
    /*
	 Method Name : loadPafRecordForRisk
	 Description : This method gets executed on load and set plan record id from risk.
	 Parameters	 : None
	 Return Type : None
	 */
    loadPafRecordForRisk(){        
         let objParent = this;
         getRiskRecord({
            strRiskRecordId: objParent.recordId
        })
        .then((objResult) => {    
            objParent.recordId = objResult.Plan__c;
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        })
        .finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
    }

}