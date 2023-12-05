import { LightningElement } from 'lwc';
import getScheduledJobs from '@salesforce/apex/ObjectEntityLimitsReportController.getAllScheduledJobs';

const jobColumns =[
    {label: 'Job Name', fieldName:'cronjobDetailName', type:'text'},
    {label: 'Created By', fieldName:'CreatedBy', type:'text'},
    {label: 'CreatedDate', fieldName:'CreatedDate', type:'text'},
    {label: 'CronJobDetailId', fieldName:'CronJobDetailId', type:'text'},
    {label: 'NextFireTime', fieldName:'NextFireTime', type:'text'},
    {label: 'OwnerId', fieldName:'OwnerId', type:'text'},
    {label: 'State', fieldName:'State', type:'text'},
    {label: 'TimesTriggered', fieldName:'TimesTriggered', type:'text'},

    
];


export default class InfaScheduledJobsReport extends LightningElement {
    data = [];
    temp = [];
    jobColumns = jobColumns;
    searchKey = '';

    async connectedCallback() {
        this.data = await getScheduledJobs({});
        this.temp = this.data;
    }
    
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        let filteredData = this.temp.filter(function (e) {
            return e.cronjobDetailName.toLowerCase().includes(event.target.value.toLowerCase());
        });
        this.data = filteredData;
    }



}