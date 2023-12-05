/*
 * Name			:	globalToastMessage
 * Author		:	Vignesh Divakaran
 * Created Date	: 	7/24/2023
 * Description	:	This is used to show toast message relative to the component. 

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh Divakaran	    7/24/2023		I2RT-8640		Initial version.			N/A
*/

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { classSet } from 'c/globalUtilities';
import { isWarning, isError } from './utils';

export default class GlobalToastMessage extends LightningElement {

    //API variables
    @api strVariant = 'warning';
    @api strMessage;

    
    /* Getter Methods */
    get showToast(){
        return !!this.strVariant;
    }

    get title(){
        return this.strVariant;
    }

    get alternateText(){
        return this.strVariant;
    }

    get iconName(){
        if(isWarning(this.strVariant))
            return 'utility:warning';
        else if(isError(this.strVariant))
            return 'utility:error';
        else
            return '';
    }
  
  	get computedThemeClassNames(){
        return classSet('slds-notify slds-notify_toast')
                .add({ 'slds-theme_warning': isWarning(this.strVariant) })
                .add({ 'slds-theme_error': isError(this.strVariant) })
                .toString();
    }

    get computedIconClassNames(){
        return classSet('slds-icon_container slds-m-right_small slds-no-flex slds-align-top')
                .add({ 'slds-icon-utility-warning': isWarning(this.strVariant) })
                .add({ 'slds-icon-utility-error': isError(this.strVariant) })
                .toString();
    }
}