import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

/** The delay used when debouncing event handdlers before invoking functions. */
const delay = 350;

export default class spCustomDropdownWithFavAndSearch extends LightningElement {
    @api options;
    @api optionsAll;

    @api fieldLabel;
    @api disabled = false;
    @track openDropDown = false;
    @track inputValue = "";
    @api placeholder = "";
    @track optionsToDisplay;
    @track optionsToDisplayAll;
    @api value = "";
    @track label = "";
    @track favSupportAcc = [];
    delaytimeout;
   
    Accountoptions= [];

	//Private variables.
	boolHasOptionsToDisplay = false;

    //constructor
    constructor() {
        super();
    }

    connectedCallback() {
        this.setOptionsAndValues();
        this.setOptionVAlues();
    }

    renderedCallback() {
        if (this.openDropDown) {
            this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                inputElem.focus();
            });
            //this.template.querySelector('[data-id="' + this.value + '"]').className = 'slds-listbox__item add-bg';
        }
    }
    @api setOptionVAlues(){
        console.log('this.optionsAll===-=> ' + JSON.stringify(this.optionsAll));
        this.Accountoptions = (this.optionsAll && this.optionsAll.length > 0 ? this.optionsAll : []);
        if (this.value && this.value != "") {
            //alert(this.value);
            let label = this.getLabel(this.value);
            // alert(label);
            if (label && label != "") {
                this.label = label;
            }
        }
        else {
            this.label = "";
        }
     }

    //Public Method to set options and values
    @api setOptionsAndValues() {
        this.optionsToDisplay = (this.options && this.options.length > 0 ? this.options : []);
        this.setValues(this.options[0].value, this.options[0].label);
        if (this.value && this.value != "") {
            let label = this.getLabel(this.value);
            if (label && label != "") {
                this.label = label;
            }
        }
        else {
            this.label = "";
        }
    }

    //Method to get Label for value provided
    getLabel(value) {
        let selectedObjArray = this.options.filter(obj => obj.value === value);
        if (selectedObjArray && selectedObjArray.length > 0) {
            return selectedObjArray[0].label;
        }
        return null;
    }

    //Method to open listbox dropdown
    openDropDown(event) {
        this.toggleOpenDropDown(true);
    }

    //Method to close listbox dropdown
    closeDropdown(event) {
        if (event.relatedTarget && event.relatedTarget.tagName == "UL" && event.relatedTarget.className.includes('customClass')) {
            console.log(JSON.stringify(event.relatedTarget.className));
            if (this.openDropDown) {
                this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                    inputElem.focus();
                });
            }
        }
        else {
            window.setTimeout(() => {
                this.toggleOpenDropDown(false);
            }, 300);
        }
    }

    //Method to handle readonly input click
    handleInputClick(event) {
        this.resetParameters();
        this.toggleOpenDropDown(true);
    }

    //Method to handle key press on text input
    handleKeyPress(event) {
        const searchKey = event.target.value;
        this.setInputValue(searchKey);
        if (this.delaytimeout) {
            window.clearTimeout(this.delaytimeout);
        }

        this.delaytimeout = setTimeout(() => {
            //filter dropdown list based on search key parameter
            this.filterDropdownList(searchKey);
        }, delay);
    }

    makefav(event){
        //event.preventDefault();
        var ACrID=event.target.name;    
        //this.favSupportAcc.forEach();
        this.dispatchEvent(new CustomEvent('myfav',{ detail: {'planConId' : event.target.name, 'state' : event.target.variant}}));
        var tempSuppAccList =[];  
            this.optionsAll.forEach(data=> {
             var tempdata=  JSON.parse(JSON.stringify(data));
             console.log('tempdata===> ' + JSON.stringify(tempdata));
            
            if(tempdata.PlanContactId == event.target.name && !tempdata.isBlnSUpportAccFav){
                tempdata.isBlnSUpportAccFav=true;    
               // alert(JSON.stringify( data)+'acc=='+data.AccConRel.Account.Id);
            }else{
                tempdata.isBlnSUpportAccFav=false;    
            }
           /// let tempRecord = Object.assign({}, {tempdata});
           tempSuppAccList.push(tempdata);
          //  alert(JSON.stringify( tempSuppAccList) +' iniside'+JSON.stringify( tempRecord));
         } );
         console.log('####====> ' + JSON.stringify( tempSuppAccList));
        this.optionsToDisplayAll=tempSuppAccList;
        this.optionsAll=tempSuppAccList;
        this.toggleOpenDropDown(true);

		//Now we display the "No results" message, if needed.
	 	this.hasOptionsToDisplay();
    }
    //Method to filter dropdown list
    filterDropdownList(key) {
         //alert(this.optionsAll);
       console.log('=='+JSON.stringify( this.optionsAll));
       const filteredOptions = this.optionsAll.filter(item => item.label.toLowerCase().includes(key.toLowerCase())); 
       this.optionsToDisplayAll = filteredOptions;

	   	//Now we display the "No results" message, if needed.
		this.hasOptionsToDisplay();
    }

    //Method to handle selected options in listbox
    optionsClickHandler(event) {
        var list = this.template.querySelectorAll('li.slds-listbox__item');
        for(let i=0; i< list.length; i++) {
            list[i].className = 'slds-listbox__item';
        }
        const value = event.target.closest('li').dataset.value;
        const label = event.target.closest('li').dataset.label;
        this.setValues(value, label);
        this.toggleOpenDropDown(false);
        const detail = {};
        detail["value"] = value;
        detail["label"] = label;
        this.template.querySelector(`[data-id="${value}"]`).className = 'slds-listbox__item sp-dropdown-item--selected';
        this.dispatchEvent(new CustomEvent('change', { detail: detail }));
    }
    // navigatetoSuppoAcc(event) {
    //     let url=CommunityURL+'supportaccountdetails?accountid='+event.target.value;
    //      window.open(url,'_blank');
    // }
    //Method to reset necessary properties
    resetParameters() {
        this.setInputValue("");
        this.optionsToDisplay = this.options;
        this.optionsToDisplayAll = this.optionsAll;

		//Now we display the "No results" message, if needed.
	 	this.hasOptionsToDisplay();
    }

    //Method to set inputValue for search input box
    setInputValue(value) {
        this.inputValue = value;
    }

    //Method to set label and value based on
    //the parameter provided
    setValues(value, label) {
        this.label = label;
        this.value = value;
    }

    //Method to toggle openDropDown state
    toggleOpenDropDown(toggleState) {
        this.openDropDown = toggleState;

        if(this.value != ''){
            setTimeout(() => {
                if(toggleState){        
                    this.template.querySelector("[data-id=" + this.value +"]").className = 'slds-listbox__item sp-dropdown-item--selected';        
                }            
            }, 500);   
        }
    }

    //getter setter for labelClass
    get labelClass() {
        return (this.fieldLabel && this.fieldLabel != "" ? "slds-form-element__label slds-show" : "slds-form-element__label slds-hide")
    }

    //getter setter for dropDownClass
    get dropDownClass() {
        return (this.openDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
    }

    //getter setter for isValueSelected
    get isValueSelected() {
        return (this.label && this.label != "" ? true : false);
    }

    get isDropdownOpen() {
        return (this.openDropDown ? true : false);
    }
    
	/*
	 Method Name : hasOptionsToDisplay
	 Description : This method displays the No Results message if there are no records to display.
	 Parameters	 : None
	 Return Type : None
	 */
	hasOptionsToDisplay() {
	 	this.boolHasOptionsToDisplay = true;
		if(objUtilities.isNull(this.optionsToDisplayAll) || this.optionsToDisplayAll.length <= 0) {
		 	this.boolHasOptionsToDisplay = false;
		}
    }
}