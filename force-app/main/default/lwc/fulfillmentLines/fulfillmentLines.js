/*
 Change History
 *************************************************************************************************************************
 Modified By			Date			Jira No.		Description								                    Tag
 *************************************************************************************************************************
 N/A		            N/A		        N/A				Initial version.						                    N/A
 Vignesh Divakaran      2/3/2023        F2A-493         Added property to set Provision Org column button label     T01
                                                        dynamically based on child Flex IPU fulfillment line.
 Vignesh Divakaran      2/6/2023        F2A-493         Show Add line button for IPU fulfillment category           T02
 Karthi G               2/9/2023        F2A-523         Add message channel for refreshing OE and OEL list          T03
 Vignesh Divakaran      2/13/2023       F2A-527         Added UI validation to check Org, Org UUID & Pod location   T04
                                                        before provisioning the entitlement
 Vignesh Divakaran      2/28/2023       F2A-476         Carry over consumption model from parent to sandbox line    T05
 Vignesh Divakaran      2/28/2023       F2A-476         Updated logic for IPU 1.0 metering                          T06
 Vignesh Divakaran      4/27/2023       F2A-576         Updated logic for auto refresh on provisioning entitlement  T07
 Vignesh Divakaran      4/27/2023       F2A-576         Hide the Provision Entitlement button                       T08
 Vignesh Divakaran      7/10/2023       F2A-622         show save & provision org button on options without         T09
                                                        parent in amendment order
 */

import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe }  from 'lightning/empApi'; /** T01 */
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import getAllffLines from '@salesforce/apex/FulfillmentData.getAllffLines';
import getFulfillmentLineFieldSet from '@salesforce/apex/FulfillmentData.getFulfillmentLineFieldSet';
import getFulfillmentLinesLWC from '@salesforce/apex/FulfillmentData.getFulfillmentLinesLWC';
import updateFulfillments from '@salesforce/apex/FulfillmentData.updateFulfillments';
import updateProvisionOrg from '@salesforce/apex/FulfillmentData.updateProvisionOrg';/** T01 */
import getPodLocation from '@salesforce/apex/FulfillmentData.getPodLocation';/** T01 */
import getFulfillmentLineDetails from '@salesforce/apex/FulfillmentData.getFulfillmentLineDetails'; //<T03>

import SHIP_CONTACT_COUNTRY from "@salesforce/schema/Fulfillment__c.Ship_To_Contact__r.MailingCountry";

import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomDataTable';

//<T03>
import refreshFulfilments from '@salesforce/messageChannel/refreshFulfilments__c';
import {
    publish,
    MessageContext
} from 'lightning/messageService';
//</T03>

//Custom Labels.
import FLEX_IPU from '@salesforce/label/c.IPU_Product_GTM_Value'; //<T01>
import IPU from '@salesforce/label/c.IPU'; //<T06>

//Utilities.
import { objUtilities } from 'c/globalUtilities'; //<T04>

let fieldSetFields = '';
let PROVISIONING_ENVIRONMENT = 'Provisioning_Environment__c';

export default class FulfillmentLines extends LightningElement {
    @track defaultTabOnInitialization = 'All';
    @track tabs = [];
    @api recordId;
    @track columns;
    @track data;
    @track currentTabValue = 'All'; 

    col =[];/** T01 */
    ffLinesub;/** T01 */

    @wire(CurrentPageReference) pageRef;
    hasRendered = false;

    /**Attributes to track data changed**/
    @track draftValues = [];
    lastSavedData = [];
    @track selectedRow = [];

    lstConsumptionModels = [FLEX_IPU, IPU]; //<T01> //<T06>
    objLooper; //<T03>

    @wire(getRecord, {
		recordId: "$recordId",
		fields: [SHIP_CONTACT_COUNTRY]
	})
	contactData;

    //<T03>
    @wire(MessageContext)
    messageContext;     
    //</T03>
    
    connectedCallback() {
        loadStyle(this, CustomDataTableResource);

        this.subscribeToffLineDataChange();/**Auto Refresh FFlines */

        this.col =[];
        let fulfillmentHeaderId = this.recordId;
        /**1. Get the tab details */
        getAllffLines({ fulfillmentHeaderId })
            .then(result => {
                for (let key in result) {
                    if (result.hasOwnProperty(key)) {
                        let tempStr = key +' ('+result[key]+')';
                        this.tabs.push({ key: key, label: tempStr });
                    }
                }
                console.log(`connectedCallback 000--> tabs -->  ${JSON.stringify(this.tabs)}`);
            })
            .catch(error => {
                console.log(`connectedCallback --> getAllffLines(Apex Method) returned the following error: ${error}`);
            })
        
        /**2.Get the fulfillmentLines FieldSet and set the columns*/
        getFulfillmentLineFieldSet({ fieldSetName: this.defaultTabOnInitialization })
            .then(result => {
                console.log(`***** ConnectedCallBack result ********* ---> ${JSON.stringify(result)}`);                
                
                if(this.defaultTabOnInitialization === 'Cloud'){
                    this.col.push({ label: 'Add Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' } ,cssclass:{ fieldName: 'addFFlineCss' }}, initialWidth: 80,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                }

                for (let key in result) {
                    let fieldAPIName = key;
                    fieldSetFields = fieldSetFields + ',' + fieldAPIName;
                    let labelName = result[key][0];
                    let fieldType = result[key][1].toLowerCase();
                    //Mark the field as required in Fieldset to mark it as editable in the datatable
                    let isFieldEditable = result[key][2] === 'true' ? true : false;   
                    
                    if (fieldAPIName === PROVISIONING_ENVIRONMENT) {
                        this.col.push({
                            label: labelName, fieldName: fieldAPIName, type: 'picklist', typeAttributes: { 
                                placeholder: 'Select', options: [
                                    { label: 'Informatica Hosted', value: 'Informatica Hosted' },
                                    { label: 'AWS', value: 'AWS' },
                                    { label: 'Azure', value: 'Azure' },
                                    { label: 'Google Cloud', value: 'Google Cloud' },
                                    { label: 'Other', value: 'Other' },
                                    { label: 'CSOD', value: 'CSOD' }, /**Pavithra - F2A-313 */
                                ] // list of all picklist options
                                , value: { fieldName: 'Provisioning_Environment__c' } // default value for picklist
                                , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
                        }, editable: true, initialWidth: 170,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                    }
                    else if (fieldType.toLowerCase() === 'string') {
                        if(fieldAPIName === 'Org_UUID__c'){
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type:'orgUUID',editable:true,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }, typeAttributes: { value: { fieldName: fieldAPIName },context: { fieldName: 'Id' }}, initialWidth: 250}});
                        }else{                       
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 230,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                    else if (fieldType.toLowerCase() === 'boolean') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 65, cellAttributes: { alignment: 'center' },class: { fieldName: 'cellAttributesCSS' }});
                    }
                    else if (fieldType.toLowerCase() === 'date') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'date-local', editable: isFieldEditable, typeAttributes:{year: 'numeric',month: 'short',day: 'numeric'}, cellAttributes: { class: { fieldName: 'cellAttributesCSS' }},initialWidth: 135});
                    }
                    /**T01*/
                    else if (fieldType.toLowerCase() === 'number') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'number', editable: isFieldEditable,  initialWidth: 65,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }
                    else if (fieldType.toLowerCase() === 'reference') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'reference', editable: true, 
                        typeAttributes: { 
                            fieldapi: fieldAPIName,
                            value: { fieldName: fieldAPIName },
                            context: { fieldName: 'Id' },
                            disable: !isFieldEditable
                        },
                        initialWidth: 200,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    } /**T01*/
                    else {
                        if(fieldAPIName === 'Ship_Status__c'){
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' },class:{fieldName : 'fontcolor'}}});
                        }else{
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                }
                            
                /** Pavithra - F2A-364 - Changes in Fulfillment Screen */ /**T01*/
                if(this.defaultTabOnInitialization === 'Cloud'){
                    //this.col.push({ label: 'Add Fulfillment Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' } ,cssclass:{ fieldName: 'addFFlineCss' }}, initialWidth: 160,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                    this.col.push({ label: 'Provision Org', type: 'addicon', typeAttributes: { context: { fieldName: 'Id' }, cssclass: { fieldName: 'cssClass' }, label: { fieldName: 'provisionOrgLabel' } }, initialWidth: 180,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}}); //<T01>
                }  
                this.col.push({ label: 'View Order Products', type: 'vieworderproducts', typeAttributes: { rowid: { fieldName: 'Id' } }, initialWidth: 160 ,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                               
                this.columns = this.col;
                
                console.log(`col --> ${JSON.stringify(this.col)}`);
                console.log(`typeof(fieldSetFields) --> ${typeof (fieldSetFields)}`);
                console.log(`fieldSetFields --> ${fieldSetFields}`);
            })
            .catch(error => {
                console.log(`connectedCallback --> getFulfillmentLineFieldSet(Apex Method) returned the following error: ${error}`);
            })
        
            /**3. Get the FFline Data */

            let fulfillmentSystem = this.defaultTabOnInitialization;
            let lstString = [];
            lstString.push(fulfillmentHeaderId);
            lstString.push(fulfillmentSystem);

            let queryFields = fieldSetFields;
            console.log(`queryFields --> ${queryFields}`);
            console.log(`lstString --> ${lstString}`);

            getFulfillmentLinesLWC({ lstString })
                .then(result => {
                    var replacer = function(key, value) {
                        return typeof value === 'undefined' ? null : value;
                    }
                    this.data = JSON.parse(JSON.stringify(result, replacer));
                    this.data.forEach(ffline => {
                        if(ffline.License_Generation__c !== 'Options'){
                            ffline.cssClass = 'showActionButton';
                        }else{
                            ffline.cssClass = 'hideActionButton';
                        }
                        if(ffline.Ship_Status__c === 'API Error'){
                            ffline.fontcolor = 'error-font';
                        }
                        if(ffline.License_Generation__c === 'Production' || ffline.License_Generation__c === 'IPU'){ //<T02>
                            ffline.addFFlineCss = 'showActionButton';
                        }else{
                            ffline.addFFlineCss = 'hideActionButton';
                        }
                        ffline.provisionOrgLabel = this.lstConsumptionModels.includes(ffline.GTM_Model__c) && ffline.License_Generation__c == 'Options' && objUtilities.isNotBlank(ffline.Parent_ID__c) ? '' : 'Save & Provision Org'; //<T01> //<T06> //<T08> //<T09>
                        if(objUtilities.isNotBlank(ffline.provisionOrgLabel)) { //<T09>
                            ffline.cssClass = 'showActionButton';
                        }
                    });                
                    this.lastSavedData = JSON.parse(JSON.stringify(this.data, replacer));
                    console.log(`connectedCallback --> @track data --> after fetching records --> ${JSON.stringify(this.data)}`);
                })
                .catch(error => {
                    console.log(`connectedCallback --> getFulfillmentLinesLWC(Apex Method) returned the following error: ${error}`);
                })      
        
    }
    
    handleActiveTab(event) {
        this.currentTabValue = event.target.value;
        console.log(`this.currentTabValue -> ${this.currentTabValue}`);

        /**1.Get the fulfillmentLines FieldSet and set the columns*/
        this.col = [];
        fieldSetFields = '';
        getFulfillmentLineFieldSet({ fieldSetName: this.currentTabValue })
            .then(result => {
                console.log(`*********result********* ---> ${JSON.stringify(result)}`);

                if(this.currentTabValue === 'Cloud'){
                    this.col.push({ label: 'Add Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' } ,cssclass:{ fieldName: 'addFFlineCss' }}, initialWidth: 80,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                }

                for (let key in result) {
                    
                    let fieldAPIName = key;
                    fieldSetFields = fieldSetFields + ',' + fieldAPIName;
                    let labelName = result[key][0];
                    let fieldType = result[key][1].toLowerCase();
                   
                    let isFieldEditable = result[key][2] === 'true' ? true : false;
                    console.log(`typeof(isFieldEditable) --> ${typeof (isFieldEditable)}`);                    
                    
                    if (fieldAPIName === PROVISIONING_ENVIRONMENT) {
                        this.col.push({
                            label: labelName, fieldName: fieldAPIName, type: 'picklist', typeAttributes: { 
                                placeholder: 'Select', options: [
                                    { label: 'Informatica Hosted', value: 'Informatica Hosted' },
                                    { label: 'AWS', value: 'AWS' },
                                    { label: 'Azure', value: 'Azure' },
                                    { label: 'Google Cloud', value: 'Google Cloud' },
                                    { label: 'Other', value: 'Other' },
                                    { label: 'CSOD', value: 'CSOD' }, /**Pavithra - F2A-313 */
                                ] // list of all picklist options
                                , value: { fieldName: 'Provisioning_Environment__c' } // default value for picklist
                                , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
                        },editable: true, initialWidth: 180 ,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }
                    
                    else if (fieldType.toLowerCase() === 'string') {
                        if(fieldAPIName === 'Org_UUID__c'){
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type:'orgUUID', editable:true, typeAttributes: { value: { fieldName: fieldAPIName },context: { fieldName: 'Id' }}, initialWidth: 250,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }else{                       
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 230,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                    else if (fieldType.toLowerCase() === 'boolean') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 65, cellAttributes: { alignment: 'center' },class: { fieldName: 'cellAttributesCSS' }});
                    }
                    else if (fieldType.toLowerCase() === 'date') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'date-local', editable: isFieldEditable, typeAttributes:{year: 'numeric',month: 'short',day: 'numeric'}, initialWidth: 135,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }
                    /**Pavithra - F2A-313 */
                    else if (fieldType.toLowerCase() === 'number') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'number', editable: isFieldEditable,  initialWidth: 65,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }/**Pavithra - F2A-313 */
                    /** Pavithra - F2A-364 - Changes in Fulfillment Screen */
                    else if (fieldType.toLowerCase() === 'reference') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'reference', editable: true, 
                        typeAttributes: { 
                            fieldapi: fieldAPIName,
                            value: { fieldName: fieldAPIName },
                            context: { fieldName: 'Id' },
                            disable: !isFieldEditable 
                        },
                        initialWidth: 220,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }
                    else {
                        if(fieldAPIName === 'Ship_Status__c'){
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' },class: { fieldName: 'fontcolor' }}});
                        }else{
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                }                
                /** Pavithra - F2A-364 - Changes in Fulfillment Screen */
                if(this.currentTabValue === 'Cloud'){
                    //this.col.push({ label: 'Add Fulfillment Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' },cssclass:{ fieldName: 'addFFlineCss' } }, initialWidth: 160,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                    this.col.push({ label : 'Provision Org', type : 'addicon', typeAttributes: { context: { fieldName: 'Id' },cssclass:{fieldName:'cssClass'}, label: { fieldName: 'provisionOrgLabel' }}, initialWidth: 180,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}}); //<T01>
                }
                this.col.push({ label: 'View Order Products', type: 'vieworderproducts', typeAttributes: { rowid: { fieldName: 'Id' } }, initialWidth: 160,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                this.columns = this.col;
                console.log(`col --> ${JSON.stringify(this.col)}`);
            })
            .catch(error => {
                console.log(`generalCallback --> getFulfillmentLineFieldSet(Apex Method) returned the following error: ${error}`);
            })
        
        /**3. Get the FFline Data */

        let fulfillmentHeaderId = this.recordId;
        let fulfillmentSystem = this.currentTabValue;
        let lstString = [];
        lstString.push(fulfillmentHeaderId);
        lstString.push(fulfillmentSystem);
        let queryFields = fieldSetFields;
        console.log(`queryFields --> ${queryFields}`);
        
        console.log(`lstString --> ${lstString}`);
        getFulfillmentLinesLWC({ lstString })
            .then(result => {
                var replacer = function(key, value) {
                    return typeof value === 'undefined' ? null : value;
                }
                this.data = JSON.parse(JSON.stringify(result,replacer));
                this.data.forEach(ffline => {
                    if(ffline.License_Generation__c !== 'Options'){
                        ffline.cssClass = 'showActionButton';
                    }else{
                        ffline.cssClass = 'hideActionButton';
                    }
                    if(ffline.Ship_Status__c === 'API Error'){
                        ffline.fontcolor = 'error-font';
                    }
                    if(ffline.License_Generation__c === 'Production' || ffline.License_Generation__c === 'IPU'){ //<T02>
                        ffline.addFFlineCss = 'showActionButton';
                    }else{
                        ffline.addFFlineCss = 'hideActionButton';
                    }
                    ffline.provisionOrgLabel = this.lstConsumptionModels.includes(ffline.GTM_Model__c) && ffline.License_Generation__c == 'Options' && objUtilities.isNotBlank(ffline.Parent_ID__c) ? '' : 'Save & Provision Org'; //<T01> //<T06> //<T08> //<T09>
                    if(objUtilities.isNotBlank(ffline.provisionOrgLabel)) { //<T09>
                        ffline.cssClass = 'showActionButton';
                    }
                });
                this.lastSavedData = JSON.parse(JSON.stringify(this.data,replacer));
                console.log(`generalCallback --> @track data --> after fetching records --> ${JSON.stringify(this.data)}`);
            })
            .catch(error => {
                console.log(`generalCallback --> getFulfillmentLinesLWC(Apex Method) returned the following error: ${error}`);
            })

        this.getRelatedFFLinesrendered();
    }

    getRelatedFFLinesrendered() {
        let lstString = [];
        lstString.push(this.recordId);
        lstString.push(this.currentTabValue);
        console.log(`getRelatedFFLinesrendered--> lstString --> ${lstString}`);
        fireEvent(this.pageRef, 'reRenderAllRelatedFFLines', lstString);
    }
  
    handleShipComplete(event) {
        console.log(`selectedRow --> ${JSON.stringify(this.selectedRow)}`);
        let updateItems = JSON.parse(JSON.stringify(this.selectedRow));

        updateItems.forEach(item => {
            let updatedItem = { Id: item.Id, Ship_Status__c: 'Provisioning Complete' };
            this.updateDraftValues(updatedItem);
            this.updateDataValues(updatedItem);
        });

    }

    handleRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        console.log(`SelectedRows --> ${JSON.stringify(selectedRows)}`);
        this.selectedRow = [];
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedRow.push({ Id: selectedRows[i].Id });
        }

    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
    }

    updateDraftValues(updateItem) {
        console.log('DRAFT 0>> '+ JSON.stringify(this.draftValues));
        console.log('DRAFT 1>> '+ JSON.stringify(updateItem));
        
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            console.log('DRAFT 2>> '+ item.Id);
            console.log('DRAFT 3>> '+ updateItem.Id);
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            //this.draftValues = [...copyDraftValues, updateItem];     
            this.draftValues.push(updateItem);
            this.draftValues = [...this.draftValues];       
        }
        console.log('DRAFT 4>> '+ JSON.stringify(this.draftValues));
        console.log('DRAFT 5>> '+ draftValueChanged);
    }

    picklistChanged(event) {
        /**listener handler to get the context and data && updates datatable**/
        event.stopPropagation();        
        let updatedItem = { Id: event.detail.context, Provisioning_Environment__c: event.detail.value };
        console.log(`updatedItem --> ${JSON.stringify(updatedItem)}`);
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    handleCellChange(event) {
        /** handler to handle cell changes & update values in draft values */
        for (let i = 0; i < event.detail.draftValues.length; i++){
            this.updateDraftValues(event.detail.draftValues[i]);
            console.log(`draft values --> ${JSON.stringify(event.detail.draftValues[i])}`);
        }
        
    }

    handleSave(event) {
        console.log('Updated items', this.draftValues);
        console.log(JSON.stringify(this.draftValues));
        console.log('this.data ==> ', JSON.stringify(this.data));

        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        console.log(`this.lastSavedData --> ${JSON.stringify(this.lastSavedData)}`);
        let fulfillmentLines = JSON.stringify(this.draftValues);
        console.log(`saving --> ${fulfillmentLines != undefined}`);
        if (fulfillmentLines != undefined) {
            /** F2A-309- Updated the logic to check that ship date should not be NULL for the
                Fulfillments lines which are provisioning completed  ***/
            
            
            
        var errorMsg ='';
        for (var x of this.draftValues) {
            for(var y of this.lastSavedData){
                var draftVal = JSON.stringify(x);  
                if((( x.Ship_Date__c === null && draftVal.includes('Ship_Date__c')) && ( y.Ship_Date__c !=='' && y.Ship_Date__c !== null )) && (x.Id == y.Id) && (y.Ship_Status__c == 'Provisioning Complete') ){
                    errorMsg = 'Please enter the Fulfillment Date';
                    break;
                }
            }
        }
        
        if(errorMsg !=''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMsg,
                        variant: 'error'
                    })
                );
            }else{
                /** F2A-309 - Updated the logic to check that ship date should not be NULL for the
                    Fulfillments lines which are provisioning completed ENDS ***/
            updateFulfillments({ fulfillmentLines })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Fulfillment Lines updated successfully!',
                        variant: 'success'
                    })
                );

                this.getAllffLines(event); // Update the tab name                 

                // Clear all draft values
                this.draftValues = [];
                this.selectedRow =[];
                
            /* refresh the data after successful save */
                this.col = undefined;
                this.data = undefined;
               return this.handleRefresh();
            })
            .catch(error => {
                console.log(`save error --> ${(error)}`);
                console.log(`save error --> ${JSON.stringify(error)}`);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        
        }
        }
    }

    handleRefresh() {
        console.log(`this.currentTabValue -> ${this.currentTabValue}`);

        let fulfillmentHeaderId = this.recordId;
        
        /**1. Get the tab details */

        this.col = [];
        fieldSetFields = '';
        getFulfillmentLineFieldSet({ fieldSetName: this.currentTabValue })
            .then(result => {
                console.log(`*********result********* ---> ${JSON.stringify(result)}`);

                if(this.currentTabValue === 'Cloud'){
                    this.col.push({ label: 'Add Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' } ,cssclass:{ fieldName: 'addFFlineCss' }}, initialWidth: 80,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                }

                for (let key in result) {
                    
                    let fieldAPIName = key;
                    fieldSetFields = fieldSetFields + ',' + fieldAPIName;
                    let labelName = result[key][0];
                    let fieldType = result[key][1].toLowerCase();
                    
                    let isFieldEditable = result[key][2] === 'true' ? true : false;
                    console.log('fieldType'+ fieldType);
                    
                    if (fieldAPIName === PROVISIONING_ENVIRONMENT) {
                        this.col.push({
                            label: labelName, fieldName: fieldAPIName, type: 'picklist', typeAttributes: { 
                                placeholder: 'Select', options: [
                                    { label: 'Informatica Hosted', value: 'Informatica Hosted' },
                                    { label: 'AWS', value: 'AWS' },
                                    { label: 'Azure', value: 'Azure' },
                                    { label: 'Google Cloud', value: 'Google Cloud' },
                                    { label: 'Other', value: 'Other' },
                                    { label: 'CSOD', value: 'CSOD' }, /**Pavithra - F2A-313 */
                                ] // list of all picklist options
                                , value: { fieldName: 'Provisioning_Environment__c' } // default value for picklist
                                , context: { fieldName: 'Id' } // binding Id with context variable to be returned back
                        },editable: true, initialWidth: 180,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                    }
                    else if (fieldType.toLowerCase() === 'string') {
                        if(fieldAPIName === 'Org_UUID__c'){
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type:'orgUUID',editable:true, typeAttributes: { value: { fieldName: fieldAPIName },context: { fieldName: 'Id' }}, initialWidth: 250,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }else{  
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 230,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                    else if (fieldType.toLowerCase() === 'boolean') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: fieldType, editable: isFieldEditable, initialWidth: 65, cellAttributes: { alignment: 'center',class: { fieldName: 'cellAttributesCSS' } }});
                    }
                    else if (fieldType.toLowerCase() === 'date') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'date-local', editable: isFieldEditable, typeAttributes:{year: 'numeric',month: 'short',day: 'numeric'}, initialWidth: 135,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }
                    /**Pavithra - F2A-313 */
                    else if (fieldType.toLowerCase() === 'number') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'number', editable: isFieldEditable,  initialWidth: 65,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }/**Pavithra - F2A-313 */
                    /**PV - F2A-345 - Ability to provision cloud org/instance from fulfillment object */
                    else if (fieldType.toLowerCase() === 'reference') {
                        this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'reference', editable: true, 
                        typeAttributes: { 
                            fieldapi: fieldAPIName,
                            value: { fieldName: fieldAPIName },
                            context: { fieldName: 'Id' },
                            disable: !isFieldEditable 
                        },
                        initialWidth: 220,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                    }/**PV - F2A-345 - Ability to provision cloud org/instance from fulfillment object */
                   
                    else {
                        if(fieldAPIName === 'Ship_Status__c'){
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' },class:{fieldName : 'fontcolor'}}});
                        }else{
                            this.col.push({ label: labelName, fieldName: fieldAPIName, type: 'text', editable: isFieldEditable, initialWidth: 150,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}});
                        }
                    }
                }
                
                
                /** Pavithra - F2A-364 - Changes in Fulfillment Screen */
                if(this.currentTabValue === 'Cloud'){
                    //this.col.push({ label: 'Add Fulfillment Line', type: 'addffline', typeAttributes: { context: { fieldName: 'Id' },cssclass:{ fieldName: 'addFFlineCss' } }, initialWidth: 160,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });
                    this.col.push({ label : 'Provision Org', type : 'addicon', typeAttributes: { context: { fieldName: 'Id' },cssclass:{ fieldName: 'cssClass' }, label: { fieldName: 'provisionOrgLabel' }}, initialWidth: 180,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }}}); //<T01>
                }  
                this.col.push({ label: 'View Order Products', type: 'vieworderproducts', typeAttributes: { rowid: { fieldName: 'Id' } }, initialWidth: 160,cellAttributes: { class: { fieldName: 'cellAttributesCSS' }} });              
                this.columns = this.col;
                console.log(`col --> ${JSON.stringify(this.col)}`);
            })
            .catch(error => {
                console.log(`generalCallback --> getFulfillmentLineFieldSet(Apex Method) returned the following error: ${error}`);
            })
        /**3. Get the FFline Data */
        
        //let fulfillmentHeaderId = this.recordId;
        let fulfillmentSystem = this.currentTabValue;
        let lstString = [];
        lstString.push(fulfillmentHeaderId);
        lstString.push(fulfillmentSystem);
        let queryFields = fieldSetFields;
        console.log(`queryFields --> ${queryFields}`);
        let strChildFlexFulfillmentLineId; //<T07>
        
        console.log(`lstString --> ${lstString}`);
        getFulfillmentLinesLWC({ lstString })
            .then(result => {
                var replacer = function(key, value) {
                    return typeof value === 'undefined' ? null : value;
                }
                this.data = JSON.parse(JSON.stringify(result,replacer));
                this.data.forEach(ffline => {
                    if(ffline.License_Generation__c !== 'Options'){
                        ffline.cssClass = 'showActionButton';
                    }else{
                        ffline.cssClass = 'hideActionButton';
                    }
                    if(ffline.Ship_Status__c === 'API Error'){
                        ffline.fontcolor = 'error-font';
                    }
                    if(ffline.License_Generation__c === 'Production' || ffline.License_Generation__c === 'IPU'){ //<T02>
                        ffline.addFFlineCss = 'showActionButton';
                    }else{
                        ffline.addFFlineCss = 'hideActionButton';
                    }
                    ffline.provisionOrgLabel = this.lstConsumptionModels.includes(ffline.GTM_Model__c) && ffline.License_Generation__c == 'Options' && objUtilities.isNotBlank(ffline.Parent_ID__c) ? '' : 'Save & Provision Org'; //<T01> //<T06> //<T08> //<T09>
                    if(objUtilities.isNotBlank(ffline.provisionOrgLabel)) { //<T09>
                        ffline.cssClass = 'showActionButton';
                    }
                    if (objUtilities.isNotBlank(ffline.Parent_ID__c) && ffline.Ship_Status__c === 'Invoking API' && ffline.License_Generation__c !== 'Sandbox') { //<T07>
                        strChildFlexFulfillmentLineId = ffline.Id;
                    }
                });
                this.lastSavedData = JSON.parse(JSON.stringify(this.data,replacer));
                console.log('Last Saved Data >> '+ this.lastSavedData);
                console.log(`generalCallback --> @track data --> after fetching records --> ${JSON.stringify(this.data)}`);
                if (objUtilities.isNotBlank(strChildFlexFulfillmentLineId)) { //<T07>
                    this.reviewFulfillmentLineDetails(strChildFlexFulfillmentLineId);
                }
            })
            .catch(error => {
                console.log(`generalCallback --> getFulfillmentLinesLWC(Apex Method) returned the following error: ${error}`);
            })       
    }

    handleCancel(event) {        
        
        /** T01 *//** Remove draftValues & revert data changes - refresh datatable **/
        this.draftValues = [];
        this.selectedRow=[];
        this.col = undefined;
        this.data = undefined;
        return this.handleRefresh();
        
    }
   
    handlelookupchange(event){ 
         /** T01 */// handle the lookup field value change 
              
        event.stopPropagation();
        let fieldApi = event.detail.fieldapi;
        if(fieldApi === 'Org__c'){
            var orgId;
            if(event.detail.value[0]=== undefined || event.detail.value[0]==='' || event.detail.value[0]=== null){
                orgId = null;
            }else{
                orgId = event.detail.value[0];
            }

            if(orgId){
                getPodLocation({orgId : orgId})
                .then(result => {
                    let updatedItem = { Id: event.detail.context, Org__c:orgId,Pod_Location__c:result};
                    console.log(`Org__c with Podlocation--> ${JSON.stringify(updatedItem)}`);
                    this.updateDraftValues(updatedItem);
                    this.updateDataValues(updatedItem);
                })
                .catch(error => {

                })
            }else{
                    let updatedItem = { Id: event.detail.context, Org__c:orgId};
                    console.log(`Org__c --> ${JSON.stringify(updatedItem)}`);
                    this.updateDraftValues(updatedItem);
                    this.updateDataValues(updatedItem);
            }
        }
        if(fieldApi === 'Pod_Location__c'){
            var podLocation;
            if(event.detail.value[0]=== undefined || event.detail.value[0]==='' || event.detail.value[0]=== null){
                podLocation = null;
            }else{
                podLocation = event.detail.value[0];
            }
            let updatedItem = { Id: event.detail.context, Pod_Location__c: podLocation};
            console.log(`Pod_Location__c --> ${JSON.stringify(updatedItem)}`);
            this.updateDraftValues(updatedItem);
            this.updateDataValues(updatedItem);

        }
        
    }
    
    handleorgchange(event){
        /** T01 */
        var ffLineId = event.detail.context;
        var errorMsg='';
        var shipContactCountry = getFieldValue(this.contactData.data, SHIP_CONTACT_COUNTRY);
        console.log('shipContactCountry >> '+ shipContactCountry);

        this.data.forEach(data => {
            if(data.Id === ffLineId && this.lstConsumptionModels.includes(data?.GTM_Model__c) && data?.License_Generation__c === 'Options' && (objUtilities.isBlank(data?.Pod_Location__c) || objUtilities.isBlank(data?.Org__c) || objUtilities.isBlank(data?.Org_UUID__c))) { //<T04> //<T06>
                errorMsg = 'Please enter the Org, Org UUID and Pod Location before provisioning the Entitlement';
            }
            else if(data.Id === ffLineId && (data.Pod_Location__c === undefined ||data.Pod_Location__c === null || data.Pod_Location__c === '')){
                errorMsg ='Please enter the Pod Location before provisioning the Org';                
            }else if(data.Id === ffLineId && (data.Edition__c === undefined ||data.Edition__c === null || data.Edition__c === '')){
                errorMsg ='Please enter the edition before provisioning the Org';
            }
            else if(shipContactCountry === undefined ||shipContactCountry === null || shipContactCountry === ''){
                errorMsg ='Please enter the Country of the Ship to Contact before provisioning the Org';
            }
        })
        
        /**Check if the fulfillment Date is null for a provisioning completed record*/
        for (var x of this.draftValues) {
            for(var y of this.lastSavedData){
                var draftVal = JSON.stringify(x);  
                if((( x.Ship_Date__c === null && draftVal.includes('Ship_Date__c')) && ( y.Ship_Date__c !=='' && y.Ship_Date__c !== null )) && (x.Id == y.Id) && (y.Ship_Status__c == 'Provisioning Complete') ){
                    errorMsg = 'Please enter the Fulfillment Date';
                    break;
                }
            }
        }

        if(errorMsg !== ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMsg,
                    variant: 'error'
                })
            );
        }
        else{

            let fulfillmentLines = JSON.stringify(this.draftValues);
            
            //update the Provision Org flag to true to invoke the CAI process
            updateProvisionOrg({ffLineId : ffLineId, fulfillmentLines : fulfillmentLines})
            .then(result =>{
                const evt = new ShowToastEvent({
                    title: 'Provisioning In Progress',
                    message: 'Org Provisioning is in progress. Please wait...',
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

                this.getAllffLines(event); // Update tab label if new line is added

                this.draftValues =[];
                this.col = undefined;
                this.data = undefined;
                this.reviewFulfillmentLineDetails(ffLineId); //<T03>
                return this.handleRefresh();
            })
            .catch(error =>{
                console.log('Error in updateProvisionOrg >> '+ JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
       
    }

    subscribeToffLineDataChange(){
        /** T01 Refresh the datatable for any field updates */
        console.log('subscribeToffLineDataChange    ......');
        if (this.ffLinesub) {
            return;
        }

        // Callback invoked whenever a new event message is received
        var thisReference = this;

        const messageCallback = function(response) {
            console.log('Fulfillment created/updated: ', JSON.stringify(response));

            var changeType = response.data.payload.ChangeEventHeader.changeType;
            console.log('change types : ', changeType);

            var changedFields = response.data.payload.ChangeEventHeader.changedFields;
            console.log('change fields : '+changedFields);

            if(changeType === 'UPDATE' && (changedFields.includes('Org__c') || changedFields.includes('Pod_Location__c') || changedFields.includes('Org_UUID__c') || changedFields.includes('Ship_Status__c') || changedFields.includes('Ship_Date__c'))){
               //Refresh the datatable            
               thisReference.col = undefined;
               thisReference.handleRefresh(); 
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        var channelName = '/data/Fulfillment_Line__ChangeEvent';
        this.ffLinesub = subscribe(channelName, -1, messageCallback);
    }

    addRow(event){
        var parentId = event.detail.context;        
        var today = new Date();
        var uniqueIdentifier = 'FFL'+this.createUUID();
        console.log('uniqueIdentifier : '+uniqueIdentifier);

        var newItem ={Id:uniqueIdentifier};

            for(var i=0 ; i < this.data.length; i++){
                if(this.data[i].Id === parentId){
                    var index = i;
                    newItem ={
                        Id : uniqueIdentifier, /**Unique Identifier for saving the draft values */
                        Parent_ID__c: parentId,
                        Org__c : null,
                        Name:this.data[i].License_Screen_Type2__c,
                        Skip_Fulfillment__c : this.data[i].Skip_Fulfillment__c,
                        Org_UUID__c: null,
                        Pod_Location__c : null,
                        License_Generation__c : 'Sandbox',
                        Comment__c: '',
                        Edition__c : this.data[i].Edition__c,
                        End_Date__c : this.data[i].End_Date__c,
                        Start_date__c : this.data[i].Start_date__c,
                        Ship_Status__c : 'Ready for Provisioning',
                        Provisioning_Environment__c : this.data[i].Provisioning_Environment__c,
                        License_Screen_Type2__c : this.data[i].License_Screen_Type2__c,
                        Fullfillment__c : this.data[i].Fullfillment__c,
                        License_Serial_Number__c : this.data[i].License_Serial_Number__c,
                        GTM_Model__c : objUtilities.isNotBlank(this.data[i]?.GTM_Model__c) ? this.data[i].GTM_Model__c : '', //<T05>
                        addFFlineCss:'hideActionButton',
                        cellAttributesCSS : 'bgcolor-grey',
                        fontcolor : 'bgcolor-grey'                        
                    }; 
                    break;         
                 }
            }
        console.log('newItem >> '+ JSON.stringify(newItem));
        console.log('index >> '+ index);
        console.log('this.data >> '+ JSON.stringify(this.data));

        //this.selectedRow.push({ Id: newItem.Id });

        this.updateDraftValues(newItem);
        this.data.splice(index+1,0,newItem);        
        this.data = [...this.data];
        console.log('this.data >> '+ JSON.stringify(this.data));
        console.log('this.draftValues >> '+ JSON.stringify(this.draftValues));
        
    }

    renderedCallback() {
        if (this.hasRendered) {
            return;
        }
        this.hasRendered = true;
        
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => { })
    }

    createUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
          });
    }

    getAllffLines(event){
        let fulfillmentHeaderId = this.recordId;
        getAllffLines({ fulfillmentHeaderId })
                    .then(result => {
                        for (let key in result) {
                            if (result.hasOwnProperty(key)) {
                                let tempStr = key +' ('+result[key]+')';
                                this.tabs.forEach(tabs =>{
                                    if(tabs.key === key){
                                        tabs.label = tempStr;
                                    }
                                })
                            }
                        }
                        console.log(`Save tabs -->  ${JSON.stringify(this.tabs)}`);
                    })
                    .catch(error => {
                        console.log(`connectedCallback --> getAllffLines(Apex Method) returned the following error: ${error}`);
                    })
    
    }
    
    /*
	 Method Name : reviewFulfillmentLineDetails
	 Description : This method checks the Fulfillment Line record, in a recursive way, so it verifies the Ship Status change to Provisioning Complete.
	 Parameters	 : String, called from handleOrgChange, strFulfillmentLineId Fulfillment Line Id.
	 Return Type : None
	 */
    reviewFulfillmentLineDetails(strFulfillmentLineId) { //<T03>
        let objParent = this;
        objParent.objLooper = setTimeout(function () {
            getFulfillmentLineDetails({ 
                strRecordId: strFulfillmentLineId
            }).then((objFulfillmentLine) => {
                if (objUtilities.isNotNull(objFulfillmentLine) && objFulfillmentLine?.Ship_Status__c === 'Provisioning Complete') {
                    objParent.refresh();
                }
                else {
                    //We check again in 1 second.
					objParent.reviewFulfillmentLineDetails(strFulfillmentLineId);
                }
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            })
        }, 3000);
    }

    /*
	 Method Name : refresh
	 Description : This method refreshes the component and also publishes a message on the channel for cross components to refresh.
	 Parameters	 : None
	 Return Type : None
	 */
    refresh() { //<T03>
        this.handleCancel();
        publish(this.messageContext, refreshFulfilments, { data: 'refreshed'});
    }

    /*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
    disconnectedCallback() { //<T03>
        clearTimeout(this.objLooper);
    }
}