/*
 * Name			:	GlobalLightningSlider
 * Author		:	Deva M
 * Created Date	: 	9/2/2021
 * Description	:	This LWC exposes the generic Lightning-Slider

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		            17/12/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
//Utilities.
import { objUtilities } from "c/globalUtilities";

export default class GlobalLightningSlider extends LightningElement {
    //public variables
    @api defaultValue;
    @api sliderLabel;
    @api minRange;
    @api maxRange;
    @api stepRange;
    @api boolDisableSlider;
    	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
        if(objUtilities.isNull(this.boolDisableSlider)){
            this.boolDisableSlider=false;
        }
        this.defaultValue=objUtilities.isNull(this.defaultValue)?0:this.defaultValue;
    }
	/*
	 Method Name : hangleOnChange
	 Description : This method gets executed on change.
	 Parameters	 : None
	 Return Type : None
	 */
    hangleOnChange(objEvent) {
        //dispatch slider change value
        this.dispatchEvent(new CustomEvent('rangechange', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				intRangeValue: objEvent.target.value
			}
		}));
    }
}