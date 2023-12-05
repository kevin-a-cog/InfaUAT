/**
 * BSD 3-Clause License
 * Copyright (c) 2020, Justin Lyon
 * All rights reserved.

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal     30/06/2023  I2RT-8234   T01    Removed label, handled default value ,icon population and null checks  
*/

import { LightningElement, api, track, wire } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getOneRecordById from '@salesforce/apex/GlobalLookupController.getOneRecordById'
import getRecent from '@salesforce/apex/GlobalLookupController.getRecent'
import getRecords from '@salesforce/apex/GlobalLookupController.getRecords'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';//T01

const ARROW_UP = 'ArrowUp'
const ARROW_DOWN = 'ArrowDown'
const ENTER = 'Enter'
const ESCAPE = 'Escape'
const ACTIONABLE_KEYS = [ ARROW_UP, ARROW_DOWN, ENTER, ESCAPE ]

export default class globalLookup extends LightningElement {
  @track inputValue = '';
  
  @track records = []
  @track focused = false
  @track selected = ''
  @track record
  @track error
  @track activeId = ''
  

  @track _value
  @api
  get value () { return this._value }
  set value (val) {
    this._value = val
    if (val) {
      this.requestOneById()
    }
  }

  @api sobjectName
  @track iconName='';
  @api name

  @api fieldLabel = 'Search'
  @api title = 'Name'
  @api subtitle = 'Name'
  @api readOnly = false
  @api required = false
  @api messageWhenInputError = 'This field is required.'
  @api placeholder="Search...";
  @api fieldvalueid;

  @api checkValidity () {
    return !this.required || (this.value && this.value.length > 14)
  }

  @api reportValidity () {
    const isValid = this.checkValidity()
    this.error = isValid ? {} : { message: this.messageWhenInputError }
    return isValid
  }

  connectedCallback () { //T01      
    if(this.fieldvalueid){
      this._value=this.fieldvalueid;
      this.requestOneById()  
      this.fieldvalueid=''; //make it null post connected
    } else {
      this.record = null
      this.inputValue='';       
      this.requestRecent()
    }    
  }

  renderedCallback(){ //T01
   
    }


  @wire(getObjectInfo, { objectApiName: "$sobjectName" })
  handleResult({error, data}) { //T01 -> to fetch icon name for object on run time.
      if(data) {
          let objectInformation = data;
         let iconUrl  = objectInformation.themeInfo.iconUrl ;
          
          if (iconUrl && iconUrl.trim() !== '') {
            const urlList = iconUrl.split('/');
            if (urlList.length > 2) {
              const iconSvg = urlList[urlList.length - 1];
              const iconName = iconSvg.substring(0, iconSvg.lastIndexOf('_'));
              this.iconName = `${urlList[urlList.length - 2]}:${iconName}`;
              
            }
          }
      }
      if(error) {
         console.error("You do not have the rights to object or object api name is invalid: " + this.sobjectName);         
      }
  }
  get isReadOnly () { return this.readOnly || this.record }
  get showListbox () { return this.focused && this.records.length > 0 && !this.record }
  get showClear () { return !this.readOnly && (this.record || (!this.record && this.inputValue.length > 0)) }
  get hasError () { return this.error ? this.error.message : '' }
  get recordIds () { return this.records.map(r => r.Id) }

  get containerClasses () {
    const classes = [ 'slds-combobox_container' ]

    if (this.record) {
      classes.push('slds-has-selection')
    }

    return classes.join(' ')
  }

  get inputClasses () {
    const classes = [
      'slds-input',
      'slds-combobox__input' ]

    if (this.record) {
      classes.push('slds-combobox__input-value')
    }

    return classes.join(' ')
  }

  get comboboxClasses () {
    const classes = [
      'slds-combobox',
      'slds-dropdown-trigger',
      'slds-dropdown-trigger_click' ]

    if (this.showListbox) {
      classes.push('slds-is-open')
    }
    if (this.hasError) {
      classes.push('slds-has-error')
    }

    return classes.join(' ')
  }

  input(event){
    this.inputValue = event.target.value;
  }
   
  onKeyup (event) {
    if (this.readOnly) return;  
   
    this.error = null

    const keyAction = {
      ArrowUp: () => { this.cycleActive(false) },
      ArrowDown: () => { this.cycleActive(true) },
      Enter: () => { this.selectItem() },
      Escape: () => { this.clearSelection() }
    }

    if (ACTIONABLE_KEYS.includes(event.code)) {
      keyAction[event.code]()

    } else {
      if (this.inputValue.length > 2) {        
        this.debounceSearch()
      } else if (this.inputValue.length === 0) {
        this.records = []
        this.requestRecent()
      } else {
        this.error = {
          message: 'Minimum 2 characters'
        }
      }
    }
  }

  handleSelected (event) {
    this.selected = event.detail
    this.record = this.records.find(record => record.Id === this.selected)
    this.inputValue = this.record[this.title]
    this.fireSelected()
  }

  search () {
    const searcher = this.getSearcher()
    this.error = null

    getRecords({ searcher })
      .then(data => {
        const newData = JSON.parse(data)
        this.records = newData.flat().sort((a, b) => this.sortAlpha(a, b))
               
        if (this.records.length === 0) { //this.isEmptySearchResults=true;
          this.error = {
            message: 'No records found, please refine your search'
          }        
        }else{ this.error = null;         
        }
      })
      .catch(error => {
        console.error('Error searching records: ', error)
        this.error = error
      })
  }
  
  debounceSearch () {
    window.clearTimeout(this.delaySearch)
    this.delaySearch = setTimeout(() => {
      this.search()
    }, 300)
  }

  requestOneById () {
    const searcher = this.getSearcher()
    this.error = null

    getOneRecordById({ searcher, recordId: this.value })
      .then(data => {
        const records = JSON.parse(data)
        this.records = records
        this.record = records[0]
        this.selected = this.record.Id
        this.inputValue = this.record[this.title]
      })
      .catch(error => {
        console.error('Error getting record by Id', error)
        this.error = error
      })
  }

  requestRecent () {
    const searcher = this.getSearcher()
    this.error = null

    getRecent({ searcher })
      .then(data => {
        this.records = JSON.parse(data);
        //console.log('Records getRecent'+JSON.stringify(this.records));//T01
      })
      .catch(error => {
        console.error('Error requesting recents', error)
        this.error = error
      })
  }

  clearSelection () {
    console.log('Clear selection');
    this.selected = ''
    this.record = null
    this.inputValue = ''
    this.error = null
    this.requestRecent()
    this.fireSelected()
  }

  fireSelected () {
    const selected = new CustomEvent('selected', {
      detail: this.selected
    })
    this.dispatchEvent(selected)
  }

  cycleActive (forwards) {
    const currentIndex = this.recordIds.indexOf(this.activeId)
    if (currentIndex === -1 || currentIndex === this.records.length) {
      this.activeId = this.recordIds[0]
    } else if (!forwards && currentIndex === 0) {
      this.activeId = this.recordIds[this.recordIds.length - 1]
    } else if (forwards) {
      this.activeId = this.recordIds[currentIndex + 1]
    } else {
      this.activeId = this.recordIds[currentIndex - 1]
    }
  }

  selectItem () {
    if (!this.records || this.records.length === 0) return

    const listbox = this.template.querySelector('c-global-listbox')
    listbox.selectItem()
  }

  setFocus (event) {
    this.focused = event.type === 'focus'
    if (event.type === 'blur') {
      this.reportValidity()
    }
  }

  getSearcher () {    
    return {
      searchTerm: this.inputValue,
      objectName: this.sobjectName,
      fields: [ this.title, this.subtitle ]
    }
  }

  sortAlpha (a, b) {
    const aName = a[this.title]?.toLowerCase() //T01 - handled null check
    const bName = b[this.title]?.toLowerCase() //T01 - handled null check

    if (aName < bName) return -1
    if (aName > bName) return 1

    return 0
  }

  fireToast (notification) {
    const toast = new ShowToastEvent(notification)
    this.dispatchEvent(toast)
  }
}