/*
 * Name			:	globalCommunitySelectedFilters
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/26/2022
 * Description	:	This is used to show the selected filters and options to clear them.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh Divakaran	    9/26/2022		I2RT-6880		Initial version.			N/A
 */

import { LightningElement, api } from 'lwc';

export default class GlobalCommunitySelectedFilters extends LightningElement {

    //API variables
    @api strLabel;
    @api lstFilters;

    /*
      Method Name : removeSelection
	  Description : This method fires an event to the parent to remove the selected filter.
	  Parameters  : Event, called from removeSelection, objEvent click event.
	  Return Type : None
    */
    removeSelection(objEvent){
        this.dispatchEvent(new CustomEvent('removeselection', {
			detail: {
				objOption: {strName: objEvent.currentTarget.dataset.name, strValue: objEvent.currentTarget.dataset.value}
			}
		}));
    }

    /*
      Method Name : clearAllFilters
	  Description : This method fires an event to the parent to clear all filters.
	  Parameters  : None
	  Return Type : None
    */
    clearAllFilters(){
        this.dispatchEvent(new CustomEvent('clearall', {
			detail: {
				boolClearAllFilters: true
			}
		}));
    }
}