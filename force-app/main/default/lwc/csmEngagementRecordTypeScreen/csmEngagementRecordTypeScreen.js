import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Engagement_OBJECT from '@salesforce/schema/Engagement__c';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class CsmEngagementRecordTypeScreen extends LightningElement {
    selectedRecordTypeId = '';
    recordstypes;


    @wire(getObjectInfo, { objectApiName: Engagement_OBJECT })
    wiredclass(value) {
        const { data, error } = value;
        if (data) {
            const recordTypes = data.recordTypeInfos;
            let lstRecTypeOpts = [];
            for (let id in recordTypes) {
                if (recordTypes[id].name != 'Master') {
                    if(recordTypes[id].name == 'CMS Request'){ 
                        lstRecTypeOpts.push({ id: recordTypes[id].recordTypeId, label: recordTypes[id].name, value: recordTypes[id].recordTypeId, isChecked:true });
                        this.selectedRecordTypeId = recordTypes[id].recordTypeId;
                    }else{
                        lstRecTypeOpts.push({ id: recordTypes[id].recordTypeId, label: recordTypes[id].name, value: recordTypes[id].recordTypeId, isChecked:false });
                    }
                }
            }
            this.recordstypes = lstRecTypeOpts;
        } else if (error) {
            console.log(JSON.stringify(error));  
        }
    }

    getSelectedRecordtypeId(event) {
        let selectedRecordtype = this.recordstypes.find(data => data.value == this.selectedRecordTypeId);
        alert('@Developer selectedRecordtype====> ' + JSON.stringify(selectedRecordtype));
    }
    
    handleRadioGrpEvent(event) {
        let value = event.target.value;
        let lstRecTypeOpts = [];
        this.recordstypes.forEach(data =>{
            if(data.value == value){
                data.isChecked = true;
            }
           if(data.value != value){
                data.isChecked = false;
            }
            lstRecTypeOpts.push(data);
        });
        this.selectedRecordTypeId = value;
        this.recordstypes = lstRecTypeOpts;
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}