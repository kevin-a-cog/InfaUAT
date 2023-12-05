/*
 * Name			:	globalVisualPickerText
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/12/2023
 * Description	:	This LWC shows list of options as visual picker text.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran	    9/12/2023		I2RT-9063		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class GlobalVisualPickerText extends LightningElement {

    //API variables
    @api 
    set lstOptions(lstValues){
        this._lstOptions = [...lstValues];
    };
    @api strPreselectedKey;

    //Private variables
    _lstOptions = [];
    boolIsRendered = false;
    
    /*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	*/
    renderedCallback(){
        let objParent = this;

        if(!objParent.boolIsRendered){
            objParent.boolIsRendered = true;

            //Now, we pre-select the option
            if(objUtilities.isNotBlank(objParent.strPreselectedKey)){
                let inputElement = objParent.template.querySelector(`input[data-id='${objParent.strPreselectedKey}']`);
                inputElement.checked = true;
            }
        }
    }

    /*
	 Method Name : select
	 Description : This dispatches event to the parent.
	 Parameters	 : None
	 Return Type : None
	*/
    select(objEvent){
        let objParent = this;
        const objSelectedOption = objParent._lstOptions.find(objOption => objOption.strKey == objEvent.currentTarget.value);

        //Now, we send a message to the parent
        objParent.dispatchEvent(
            new CustomEvent(
                "select",
                { detail: objSelectedOption}
            )
        );
    }

    //Getter methods
    get show(){
        return !objUtilities.isEmpty(this._lstOptions);
    }

    get lstOptions(){
        return this._lstOptions;
    }
}