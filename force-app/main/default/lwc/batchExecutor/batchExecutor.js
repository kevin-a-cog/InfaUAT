import { LightningElement, wire } from 'lwc';
import getApexClasses from '@salesforce/apex/BatchExecutorhelper.getApexClasses';
import executeclass from '@salesforce/apex/BatchExecutorhelper.executeclass';
import getStatus from '@salesforce/apex/BatchExecutorhelper.getStatus';

export default class BatchExecutor extends LightningElement {
    value='';
    result;
    executeDisabled=true;
    disableStatus=true;
    batchId;
    
    @wire(getApexClasses)
    batchclassList;

    get options() {
        let opt = [{label : '--None--', value : ''}];
        if(this.batchclassList.data){
            this.batchclassList.data.forEach(ele=>{
                opt.push({ label: ele, value: ele });
            });
        }
        return opt;
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.disableStatus = true;
        this.executeDisabled = !(this.value!==undefined && this.value!=='');
        this.result = '';
    }

    executeBatch(){
        this.executeDisabled = true;
        executeclass({ className: this.value })
        .then((result) => {
           this.disableStatus = false;
           this.batchId = result;
           this.result = 'Batch scheduled with Id : '+result;
        })
        .catch((error) => {
            this.result = 'An error occured : '+JSON.stringify(error);
        });
    }

    getStatus(){
        getStatus({ batchId: this.batchId })
        .then((result) => {
           this.result = 'Batch scheduled with Id : '+this.batchId +'\r\n'+ result;
        })
        .catch((error) => {
            this.result = 'An error occured in getting Status: '+JSON.stringify(error);
        });
    }
}