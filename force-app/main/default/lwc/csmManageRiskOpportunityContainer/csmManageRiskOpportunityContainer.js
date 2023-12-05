import { LightningElement,api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class CsmManageRiskOpportunityContainer extends LightningElement {

    //API variables.
    @api recordId;
	@api boolDisplayActions;

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
				selectedRows : objEvent.detail.selectedRows,
				tab: objEvent.detail.tab
			}
		}));
	}

	/*
	 Method Name : removeRecords
	 Description : This methodwill deleted selected records.
	 Parameters	 : Event, called from remove action, objEvent dispatched event.
	 Return Type : None
	 */
	 @api
	 processAction(strAction){		
		 let objManageProductComp = this.template.querySelector('c-csm-manage-risk-opportunity');
		 if(objUtilities.isNotNull(objManageProductComp)){
			switch(strAction) {

				//User wants to cancel the table selection.
				case "remove":
					objManageProductComp.removeRecords();
					break;
				case "add":
					objManageProductComp.addRecords();
					break;
				break;
				
			}
			 
		 }
	 }

	handleHide(){
		this.dispatchEvent(new CustomEvent('hidebuttons'));
	}

}