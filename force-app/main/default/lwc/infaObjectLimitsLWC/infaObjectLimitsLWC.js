import { LightningElement, track } from 'lwc';
import getObjectLimit from '@salesforce/apex/EntityLimitsDisplayController.getObjectLimit';
import getLimitMonitoringObjectOptions from '@salesforce/apex/EntityLimitsDisplayController.getLimitMonitoringObjectOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Label', fieldName: 'Label' },
    { label: 'Remaining', fieldName: 'Remaining' },
    { label: 'Max', fieldName: 'Max'},
    { label: '% USED', fieldName: 'Percentage'}
];

export default class InfaObjectLimitsLWC extends LightningElement {
    @track value = 'Account';
    @track columns = columns;
    @track objectLimits;
    @track showLoader = false;
    @track UsedLicenses = 0;
    @track RemainingLicenses = 0;
    @track options;
    @track showTable = false;

    

    connectedCallback() {
        
        getLimitMonitoringObjectOptions()
            .then(result => {
                let str = result[0].Parameter_Value__c.split(',');
                let data = [];
                str.map((item) => {
                    data.push({ label: item, value: item })
                })
                this.options = data;
            })
            .catch(error => {
                this.showLoader = false;
                console.log(error)
            });
        
        
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleBtnClick(event){
        this.showLoader = true;
        getObjectLimit({ apiName: this.value })
            .then(result => {
                this.showTable = true;
                let data = []
                result.map((item) => {
                    data.push({Label: item.Label, Remaining: item.Remaining, Max: item.Max, Percentage: `${(((item.Max - item.Remaining) * 100) / item.Max).toFixed(0)}%`})
                })
                this.objectLimits = data;
                this.showLoader = false;
                if(this.objectLimits.length === 0){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching Data',
                            message: 'No Limits data could be retrieved for this object.',
                            variant: 'error',
                        }),
                    );
                }
            })
            .catch(error => {
                this.error = error;
                this.showLoader = false;
                console.log("bgbgb", error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error fetching Data',
                        message: 'No Limits data could be retrieved for this object. An Error Occured. Please try after sometime.',
                        variant: 'error',
                    }),
                );
            });
    }
}