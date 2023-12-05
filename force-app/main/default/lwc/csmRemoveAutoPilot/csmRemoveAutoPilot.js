/*
 * Name			:	CsmRemoveAutoPilot
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/17/2021
 * Description	:	Remove AutoPilot controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description						Tag
 **********************************************************************************************************
 Deva M              12-10-2021      	AR-1751         this controller will remove 	N/A
 														the plan from Autopilot
 */
//Core Imports
import { api, LightningElement } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
//Apex Imports
import removeAutoPilot from '@salesforce/apex/CSMAutoPilotController.removeAutoPilot';

//Import Labels
import Success from '@salesforce/label/c.Success';
import CSM_Remove_Auto_Pilot_Message from '@salesforce/label/c.CSM_Remove_Auto_Pilot_Message';
import Loading from '@salesforce/label/c.Loading';

export default class CsmRemoveAutoPilot extends LightningElement {
	//Public Variables
	@api recordId;
	//Private variables.
	boolDisplaySpinner;    
    //Labels.
	label = {
        Success,
        CSM_Remove_Auto_Pilot_Message,
        Loading
    }
	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
		this.boolDisplaySpinner = false;        
		objParent.updatePlanRecord();
    }

	/*
	 Method Name : updatePlanRecord
	 Description : This method gets executed on load and remove the plan from autopilot.
	 Parameters	 : None
	 Return Type : None
	 */
	updatePlanRecord(){
		let objParent = this;
		//Remove the autopilot 
		if(objUtilities.isNotNull(objParent.recordId)){
			objParent.boolDisplaySpinner=true;
			removeAutoPilot({ planRecordId: objParent.recordId })
			.then((result) => {
				//Show success toast to user
				objUtilities.showToast(objParent.label.Success,objParent.label.CSM_Remove_Auto_Pilot_Message,'success',objParent);
			})
			.catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				objParent.closeQuickAction();
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = true;
			});
		}
	}
	/*
	 Method Name : closeQuickAction
	 Description : This method close the quick action and refresh the page
	 Parameters	 : None
	 Return Type : None
	 */
    closeQuickAction(recordId) {
        var closeQA = new CustomEvent('close');
        if(recordId){
            const filters = [recordId];        
            closeQA = new CustomEvent('close', {
                detail: {filters}
            });    
        }
        this.dispatchEvent(closeQA);
    }   
}