import {LightningElement, api, track} from 'lwc';
export default class MultiSelectPicklist extends LightningElement {

    @api label = "Default label";
    _disabled = false;
    @api
    get disabled(){
        return this._disabled;
    }
    set disabled(value){
        this._disabled = value;
        this.handleDisabled();
    }

    @track inputOptions;
    @api
    get options() {
        return this.inputOptions.filter(option => option.value !== 'All');
    }
    set options(value) {
        console.log('multi select, set options, value = ', JSON.stringify(value));

        this.inputOptions = [];
        this.value = [];
        value.forEach(element => {
            var newElement = {label: element.label, value: element.value, selected: element.selected}
            this.inputOptions.push(newElement);
            if(element.selected){
                var valueElement = {label: element.label, value: element.value}
                this.value.push(valueElement);
            }
        });

        this.setInputValue();
    }

    @api
    clear(){
        
    }

    value = [];
    @track inputValue = '--None--';

    setInputValue(){
        if (this.value.length > 1) {
            this.inputValue = this.value.length + ' options selected';
        }
        else if (this.value.length === 1) {
            this.inputValue = this.value[0].label;
        }
        else {
            this.inputValue = '--None--';
        }
    }

    hasRendered;
    renderedCallback() {
        if (!this.hasRendered) {
            //  we coll the logic once, when page rendered first time
            this.handleDisabled();
        }
        this.hasRendered = true;
    }

    handleDisabled(){
        let input = this.template.querySelector("input");
        if (input){
            input.disabled = this.disabled;
        }
    }

    comboboxIsRendered;
    handleClick() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.toggle("slds-is-open");
        if (!this.comboboxIsRendered){
            this.comboboxIsRendered = true;
        }
    }

    handleSelection(event) {
        console.log('handle selection, event.currentTarget.dataset.value >> ', event.currentTarget.dataset.value);
        console.log('handle selection, event.currentTarget.dataset >> ', JSON.stringify(event.currentTarget.dataset));

        this.handleOption(event);

        let input = this.template.querySelector("input");
        input.focus();
        this.sendValues();
    }

    sendValues(){
        let values = [];
        for (const valueObject of this.value) {
            values.push(valueObject.value);
        }
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: values
        }));
    }
    
    handleOption(event){

        console.log('this.inputOptions >>', JSON.stringify(this.inputOptions));

        let value = event.currentTarget.dataset.value;
        let option = this.inputOptions.find(option => option.value === value);
        console.log('option >>', JSON.stringify(option));

        option.selected = !option.selected;

        var options = this.inputOptions;
        this.inputOptions = [];
        this.inputOptions = options;

        console.log('this.inputOptions >>', JSON.stringify(this.inputOptions));

        if(!option.selected){
            console.log('removing the value');
            this.value = this.value.filter(option => option.value !== value);
        }else {
            console.log('adding the value');
            this.value.push(option);
        }

        this.setInputValue();
    }

    dropDownInFocus = false;
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