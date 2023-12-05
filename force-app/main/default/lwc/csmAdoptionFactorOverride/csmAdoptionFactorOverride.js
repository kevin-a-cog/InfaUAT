/* Name		    :	CsmAdoptionFactorOverride
* Author		:	Deva M
* Created Date	: 	22/03/20222
* Description	:	this will override the edit button of adoption factor 

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description						Tag
**********************************************************************************************************
Deva M              10-01-2022     	AR-1751        
*/
import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

import Error from '@salesforce/label/c.Error';

export default class CsmAdoptionFactorOverride extends  NavigationMixin(LightningElement) {
    @api recordId;
    _recordId;
    //Labels.
	label = {
        Error
    }
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
     connectedCallback(){ 
        let objParent = this;
        let objWindow=window.location.href.match(/(Plan__c[A-Z//])\w+/g);
		if(objUtilities.isNotNull(objWindow)){
			objWindow.forEach((objElement => {
				objParent._recordId = objElement.split("/")[1];
			}));
		}else{
            objParent._recordId = objParent.recordId;
        }
        objParent.dispatchEvent(new CloseActionScreenEvent()); 
        
        objUtilities.showToast(objParent.label.Error,'Please update Adoption Factor record from Plan Page','error', objParent);
     }
}