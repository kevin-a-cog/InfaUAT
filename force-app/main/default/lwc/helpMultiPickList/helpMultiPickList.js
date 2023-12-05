/*
 * Name         :   HelpMultiPickList
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is a child component for multi select picklist.

 Change History
 **************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                         Tag
 ***************************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     Utopia-ph-3         Initial version.                                                    NA
 Utkarsh Jain           19-JULY-2021    I2RT-6599           Made long filter options in two lines                                1
 Chetan Shetty          30-Oct-2023     I2RT-9454           Dropdown closing function                                            2
 Deeksha Shetty         08-NOV-2023     I2RT-9229           PROD - IN Community - Events - Last filter is not getting removed    3
 */
import { LightningElement, api, track } from "lwc";

export default class HelpMultiPickList extends LightningElement {

    _disabled = false;
    dropDownInFocus = false;
    value = [];
    hasRendered;
    hasFilterRendered;
    comboboxIsRendered;
    allCombobox;

    @track inputOptions;
    @api label = "";
    @api placeholder = "";
    @api selectedfilters;
    filterToRemove;

    @api
    get disabled() {
        return this._disabled;
    }
    set disabled(value) {
        this._disabled = value;
        this.handleDisabled();
    }

    @api
    get options() {
        return this.inputOptions.filter((option) => option.value !== "Select");
    }
    set options(value) {
        this.inputOptions = value;
    }

    @api
    clear() {
        this.handleAllOption();
    }

    @api
    clearSelection() {
        let listBoxOptions = this.template.querySelectorAll(".slds-is-selected");
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
    }

    @api
    clearfilter(dataid) {
        this.handleFilterOption(dataid);
    }

    //added this for Ideas 
    @api
    clearideafilter(dataid) {
        this.handleFilterOptionforIdeas(dataid);
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.handleDisabled();
        }
        this.hasRendered = true;

        if (!this.hasFilterRendered) {
        }
        this.handleSelectFilterValue();

        this.allCombobox = this.template.querySelectorAll(".slds-combobox");
        for (let i = 0; i < this.allCombobox.length; i++) {
            this.allCombobox[i].addEventListener('click', (e) => e.stopPropagation(), false);
        }
        document.addEventListener('click', this.onDocClick.bind(this));
    }

    handleSelectFilterValue() {
        //mark checkbox checked against the selected filter value
        for (let item in this.selectedfilters) {
            let value = this.selectedfilters[item];
            let option = this.options.find((option) => option.value === value);
            if (option != undefined && option != null) {
                this.value.push(option);
            }
            let listBoxOptions = this.template.querySelectorAll('div[data-id="' + value + '"]');
            for (let option of listBoxOptions) {
                option.classList.add("slds-is-selected");
            }
            let liNode = this.template.querySelectorAll('li[data-id="' + value + '"]');
            for (let li of liNode) {
                if (li.getAttribute("data-status")) {
                    li.classList.add("in-li-disable");
                }
            }

        }
        this.hasFilterRendered = true;
    }

    handleDisabled() {
        let input = this.template.querySelector("input");
        if (input) {
            input.disabled = this.disabled;
        }
    }

    handleClick(event) {
        let selector = event.target.closest('.slds-combobox');
        let sldsCombobox = this.template.querySelector(".slds-combobox.slds-is-open");
        // Hide all open comboboxes
        this.hideDropdown(this.allCombobox);
        // Add the 'slds-is-open' class to the clicked combobox element
        selector.classList.add('slds-is-open');
        // Remove the 'slds-is-open' class from any previously open combobox      
        sldsCombobox.classList.remove("slds-is-open");

        if (!this.comboboxIsRendered) {
            let allOption = this.template.querySelector('[data-id="Select"]');
            allOption.firstChild.classList.add("slds-is-selected");
            this.comboboxIsRendered = true;
        }
    }
    //Tag 2 -Dropdown closing function 
    @api
    onDocClick() {
        this.hideDropdown(this.allCombobox);
    }

    hideDropdown(combobox) {
        for (let i = 0; i < combobox.length; i++) {
            if (combobox[i].classList.contains('slds-is-open')) {
                combobox[i].classList.remove('slds-is-open');
            }
        }
    }

    handleSelection(event) {
        let value = event.currentTarget.dataset.value;
        this.handleOption(event, value);
        let input = this.template.querySelector("input");
        input.focus();
        this.sendValues();
    }

    sendValues() {
        let values = [];
        for (let value of this.value) {
            values.push(value.value);
        }
        this.dispatchEvent(
            new CustomEvent("valuechange", {
                detail: values,
            })
        );
    }


    handleAllOption() {
        this.value = [];
        let listBoxOptions = this.template.querySelectorAll(".slds-is-selected");
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
    }

    handleFilterOption(id) {
        this.value = [];
        for (let item of this.selectedfilters) {
            if (item.toLowerCase() != id.toLowerCase()) {
                let selectFilter = {};
                selectFilter.value = item;
                this.value.push(selectFilter);
            }
        }
        let listBoxOptions = this.template.querySelectorAll('div[data-id="' + id + '"]');
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
        this.closeDropbox();
    }

    //added this for Ideas to handle individual filters
    handleFilterOptionforIdeas(id) {
        //this.value = []; //Tag 3
        let listBoxOptions = this.template.querySelectorAll('div[data-id="' + id + '"]');
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
        this.filterToRemove = id;
        this.closeDropbox();
    }

    handleOption(event, value) {
        let listBoxOptions = this.template.querySelectorAll(".slds-is-selected");
        if (listBoxOptions.length == 0) {
            this.value = [];
        }
        let listBoxOption = event.currentTarget.firstChild;
        if (listBoxOption.classList.contains("slds-is-selected")) {
            if (this.value.length > 0) this.value = this.value.filter((option) => option.value !== value);
        } else {
            let option = this.options.find((option) => option.value === value);
            this.value.push(option);
        }
        //Tag 3 - to remove deselected value from selectedfilters
        if (this.value.length > 0 && this.filterToRemove) this.value = this.value.filter((option) => option.value !== this.filterToRemove);
        this.filterToRemove = null;
        listBoxOption.classList.toggle("slds-is-selected");
    }

    handleBlur() {
        if (!this.dropDownInFocus) {
            this.closeDropbox();
        }
    }

    handleMouseleave() {
        this.dropDownInFocus = false;
    }

    handleMouseEnter() {
        this.dropDownInFocus = true;
    }

    closeDropbox() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.remove("slds-is-open");
    }
}