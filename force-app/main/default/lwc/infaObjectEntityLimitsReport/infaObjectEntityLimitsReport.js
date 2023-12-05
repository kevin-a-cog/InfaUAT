import { LightningElement,wire,track,api } from 'lwc';
import getObjectEntityLimits from '@salesforce/apex/ObjectEntityLimitsReportController.getObjectLimit';

/*
const limitsColumns = [
    {label: 'Object', fieldname: 'ObjectName'},
    {label: 'Label', fieldname: 'Label'},
    {label: 'Remaining' ,fieldname: 'Remaining'},
    {label: 'Max Limit', fieldname: 'MaxLimits'},
    {label: '%Used', fieldname: 'PercentgeUsed'},

]; */

const columns = [
    { label: 'Object', fieldName: 'EntityDefinitionId'},
    { label: 'Label', fieldName: 'Label' },
    { label: 'Remaining', fieldName: 'Remaining' },
    { label: 'Max', fieldName: 'Max'},
    { label: '% Used', fieldName: 'UsedPercentage'}

];

export default class InfaObjectEntityLimitsReport extends LightningElement {

    entityLimitsData;
    columns = columns;

    @track LimitsData;
    @wire(getObjectEntityLimits)
    wiredLimitsData({ error, data }) {
        this.showLoader = true;
        if (data) {
            console.log(data);
            this.LimitsData = data;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
        this.showLoader = false;
    }








}