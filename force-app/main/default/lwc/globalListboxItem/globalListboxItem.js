/**
 * BSD 3-Clause License
 *
 * Copyright (c) 2020, Justin Lyon
 * All rights reserved.
 Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal     30/06/2023  I2RT-8234   T01    Modified sublabel getter to ignorecase while retrieving subtitle
 */
import { LightningElement, api } from 'lwc'

export default class globalListboxItem extends LightningElement {
  @api record
  @api title
  @api subtitle
  @api iconName
  @api activeId

  @api
  selectItem (currentId) {
    if (this.isActive || currentId === this.record.Id) this.clickRecord()
  }

  get label () { return this.record[this.title] }
  get subLabel () {  //T01 return this.record[this.subtitle] }
    const subtitleLowerCase = this.subtitle.toLowerCase();//T01
      for (const key in this.record) {//T01
        if (key.toLowerCase() === subtitleLowerCase) {
          return this.record[key];
        }
      }
    }

    
  get isActive () { return this.activeId === this.record.Id }

  get itemClasses () {
    const classes = [
      'slds-media',
      'slds-listbox__option',
      'slds-listbox__option_entity',
      'slds-listbox__option_has-meta' ]

    if (this.isActive) {
      classes.push('slds-has-focus')
    }

    return classes.join(' ')
  }

  clickRecord () {
    const selected = new CustomEvent('selected', {
      detail: this.record.Id
    })
    this.dispatchEvent(selected)
  }
}