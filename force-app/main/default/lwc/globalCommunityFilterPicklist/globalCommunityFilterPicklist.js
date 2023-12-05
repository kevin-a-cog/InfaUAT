/*
 * Name			:	globalCommunityFilterPicklist
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/26/2022
 * Description	:	This is used to multi-select filter options.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh Divakaran	    9/26/2022		I2RT-6880		Initial version.			N/A
 */

import { LightningElement, api } from 'lwc';

export default class GlobalCommunityFilterPicklist extends LightningElement {

    //API variables
    @api strName;
    @api strLabel;
    @api strPlaceholder;
    @api 
    set lstOptions(lstValues){
        this.lstFilterOptions = lstValues;
        this.lstFilterOptionsCopy = [...lstValues];
    }
    @api
    clearAll(){
        this.lstSelectedOptions = [];
        this.template.querySelectorAll(".slds-is-selected").forEach(boxOptionElement => boxOptionElement.classList.remove('slds-is-selected'));
    }
    @api 
    clearSpecific(strValue){
        this.template.querySelectorAll(`div[data-id="${strValue}"]`).forEach(boxOptionElement => {
            boxOptionElement.classList.remove('slds-is-selected');
        });
        //this.hideDropdown();
    }

    //Private variables
    boolInFocus = false;
    lstFilterOptions;
    lstFilterOptionsCopy;
    lstSelectedOptions;

    /*
      Method Name : openDropdown
      Description : This method opens the filter dropdown.
      Parameters  : None
      Return Type : None
    */
    openDropdown(){
        console.log(this.lstOptions);
        this.template.querySelector('.slds-combobox').classList.toggle('slds-is-open');
    }

    /*
      Method Name : hideDropdown
      Description : This method closes the filter dropdown.
      Parameters  : None
      Return Type : None
    */
    hideDropdown(){
        this.template.querySelector('.slds-combobox').classList.toggle('slds-is-open');
    }

    /*
      Method Name : select
	  Description : This method gets executed when the user clicks on the filter option.
	  Parameters  : Event, called from select, objEvent click event.
	  Return Type : None
    */
    select(objEvent){
        let objParent = this;
        let lstValues = [];
        let strSelectedValue = objEvent.currentTarget.dataset.value;
        let lstBoxOptionElements = objParent.template.querySelectorAll('.slds-is-selected');

        if(lstBoxOptionElements.length === 0){
            objParent.lstSelectedOptions = [];
        }
        
        let boxOptionElement = objEvent.currentTarget.firstChild;
        if(boxOptionElement.classList.contains('slds-is-selected')) {
            objParent.lstSelectedOptions = objParent.lstSelectedOptions.filter(strOption => strOption.strValue !== strSelectedValue);
        } 
        else{
            objParent.lstSelectedOptions.push(objParent.lstFilterOptionsCopy.find(objOption => objOption.strValue === strSelectedValue));
        }
        boxOptionElement.classList.toggle('slds-is-selected');
        objParent.template.querySelector("input").focus();
        objParent.lstSelectedOptions.forEach(objSelectedOption => lstValues.push(objSelectedOption.strValue));

        //Now, we fire the event to parent
        objParent.dispatchEvent(new CustomEvent('valueselection', {
			detail: {
				selectedValues: lstValues,
				name: objParent.strName
			}
		}));
    }

    /*
      Method Name : onBlur
      Description : This method is executed when the focus is moved away from dropdown.
      Parameters  : None
      Return Type : None
    */
    onBlur(){
        if(!this.boolInFocus){
            this.hideDropdown();
        }
    }

    /*
      Method Name : hideDropdown
      Description : This method is executed when the mouse focuses on the dropdown.
      Parameters  : None
      Return Type : None
    */
    mouseEnter(){
        this.boolInFocus = true;
    }

    /*
      Method Name : hideDropdown
      Description : This method is executed when the mouse moves focus away from the dropdown.
      Parameters  : None
      Return Type : None
    */
    mouseLeave(){
        this.boolInFocus = false;
    }

    /* Getter Methods */
    get lstOptions(){
        return this.lstFilterOptions;
    }

}