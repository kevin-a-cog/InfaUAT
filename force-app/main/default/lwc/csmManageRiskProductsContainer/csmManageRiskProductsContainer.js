/*
 * Name			:	csmManageRiskProductsContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Manage Risk Products Container Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Class body.
export default class CsmManageRiskProductsContainer extends LightningElement {

	//API variables.
    @api recordId;
	@api boolDisplayActions;
	@api boolNoModal;
	//Private variables.
    isPoppedOut = false;

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
        this.isPoppedOut = objEvent.detail.boolIsPopingOut;
    }

	handleSelectedRecords(objEvent){
		//Now we send the event.
        this.dispatchEvent(new CustomEvent('select', {
			detail: {
				selectedRows : objEvent.detail.selectedRows
			}
		}));
	}
	handleCreate(objEvent){
		//Now we send the event.
		this.dispatchEvent(new CustomEvent('create')); 
	}
	/*
	 Method Name : removeRecords
	 Description : This methodwill deleted selected records.
	 Parameters	 : Event, called from remove action, objEvent dispatched event.
	 Return Type : None
	 */
	@api
	removeRecords(objEvent){		
        let objManageProductComp = this.template.querySelector('c-csm-manage-risk-products');
		if(objUtilities.isNotNull(objManageProductComp)){
            objManageProductComp.removeRecords();
        }
	}
}