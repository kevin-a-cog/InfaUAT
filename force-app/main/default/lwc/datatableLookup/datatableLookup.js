import { LightningElement,api,track,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { subscribe }  from 'lightning/empApi'; /** T01 */

export default class DatatableLookup extends LightningElement {
    @api fieldapi;
    @api value;
    @api context;
    @api disable;
    selectedValue;
    @track showEditForm = false;

    @track recordURL;
    @track recordLabel;

    ffLinesub;    

    connectedCallback(){
        this.showEditForm = false; 
        this.subscribeToffLineDataChange();/**Auto Refresh FFlines */
    }    

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }
    
    handleEdit(event){
        this.showEditForm = true;
    }

    handleBlur(event){
        this.showEditForm = false;
    }

    handleLookupChange(event){
        //show the selected value on UI
        this.selectedValue = event.detail.value;
        console.log('selectedValue >> '+ this.selectedValue);        

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('lookupchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                 context: this.context, value: this.selectedValue , fieldapi : this.fieldapi
            }
        }));
    }

    subscribeToffLineDataChange(){
        /** T01 Refresh the datatable for any field updates */
        console.log('subscribeToffLineDataChange -->Lookup......');
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

            if(changeType === 'UPDATE' && (changedFields.includes(thisReference.fieldapi))){
                var recordIds = response.data.payload.ChangeEventHeader.recordIds;
                if(recordIds.includes(thisReference.context)){
                    thisReference.updateRecordView(thisReference.context);
                }
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        var channelName = '/data/Fulfillment_Line__ChangeEvent';
        this.ffLinesub = subscribe(channelName, -1, messageCallback);
    }
}