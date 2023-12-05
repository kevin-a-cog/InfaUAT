import { LightningElement,wire,track,api } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
//Utilities.
import { objUtilities } from 'c/globalUtilities';
import getOptyRecordID from "@salesforce/apex/UtilityTrackerController.getOptyRecordID";
import getTrackedRecord from "@salesforce/apex/UtilityTrackerController.getTrackedRecord";


export default class UtilityTrackercmp extends LightningElement {
    @api recordId;
    @api sourceObject;
    @api header;

    data = [];
    error;
    offSetCount = 0;
    loadMoreStatus;
    targetDatatable;
    totalRecords;
    displayrecords = false;
    displaymessage = false;


   @track columns = [
       {
           label: 'Date',
           fieldName: 'LastModifiedDate',
           type: 'date',
           typeAttributes:{
               day:'2-digit',
               month:'2-digit',
               year:'2-digit',
               hour:'2-digit',
               minute:'2-digit',
               hour12:true},
               hideDefaultActions: 'true'
       },  
       {
           
           label: 'Field',
           fieldName: 'Field_Name__c',
           type: 'text',
           hideDefaultActions: 'true'
       },
       {
           label: 'User',
           fieldName: 'LastModifiedBy',
           type: 'text',
           hideDefaultActions: 'true'
       },
       {
           label: 'Original Value',
           fieldName: 'Old_Value__c',
           type: 'text',
           hideDefaultActions: 'true'
       },
       {
           label: 'New Value',
           fieldName: 'New_Value__c',
           type: 'text',
           hideDefaultActions: 'true'
       } 

];

    connectedCallback(){                  
        let objParent = this;
        if(objUtilities.isNotBlank(objParent.sourceObject) ){
            console.log('objParent.sourceObject-->'+objParent.sourceObject);
           objParent.boolDisplaySpinner = true;
            objParent.getOptyRecord();
        }else if(objUtilities.isBlank(objParent.sourceObject) ) 
        {
            this.getRecords();
        }

    }

    getOptyRecord(){   
        let objParent = this; 
        console.log(' this.recordId'+ objParent.recordId);
        getOptyRecordID({
           strRecordId: objParent.recordId
       })
       .then((objResult) => {    
        console.log('objResult '+ objResult.Opportunity__c);
        this.optyrecordId  = objResult.Opportunity__c;
        this.getRecords();
          
       })
       .catch((objError) => {
           objUtilities.processException(objError, objParent);
       })
   }

 
    getRecords() {
        if(this.optyrecordId !=null){
            this.trackrecordId=this.optyrecordId;          
        }else {
            this.trackrecordId=this.recordId;  
        }
        getTrackedRecord({recordId :  this.trackrecordId, offSetCount : this.offSetCount})
            .then(result => {
                this.totalRecords = result.length;               
            let newArray = [];
            result.forEach(tracking => {
            let newTracking = {};
            newTracking.LastModifiedDate = tracking.LastModifiedDate;
            newTracking.Field_Name__c = tracking.Field_Name__c;
            newTracking.LastModifiedBy = tracking.LastModifiedBy.Name;
            newTracking.Old_Value__c = tracking.Old_Value__c;
            newTracking.New_Value__c = tracking.New_Value__c;
            newArray.push(newTracking);
        });

                this.data = [...this.data, ...newArray];
                this.error = undefined;
                this.loadMoreStatus = '';
                console.log('this.data'+this.data);
                console.log('data length'+this.data.length);
                if(this.data.length >0){
                    this.displayrecords=true;
                }
                if(this.data.length == 0){
                    this.displaymessage=true;
                }
                if (this.targetDatatable && this.data.length >= this.totalRecords) {
                  
                    this.targetDatatable.enableInfiniteLoading = false;
                    this.loadMoreStatus = 'No more data to load';
                }
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.data = undefined;
                console.log('error : ' + JSON.stringify(this.error));
            });
    }
 
    // Event to handle onloadmore on lightning datatable markup
    handleLoadMore(event) {
        console.log('Loadmore')
        event.preventDefault();
        this.offSetCount = this.offSetCount + 20;
        event.target.isLoading = true;
        this.targetDatatable = event.target;
        this.loadMoreStatus = 'Loading';
        this.getRecords();
        console.log('handle more get records');
    }


}