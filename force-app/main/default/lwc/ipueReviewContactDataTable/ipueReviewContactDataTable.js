/*
Component Name:  IpueReviewContactDataTable
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156
*/
import accessTypeRender from './accessTypeRender.html';
import LightningDatatable from 'lightning/datatable';

export default class IpueReviewContactDataTable extends LightningDatatable {
    //Component created to extended datatable to enable picklist
    static customTypes = {   
        picklist: { 
            template: accessTypeRender, 
            typeAttributes: ['value','disabled'],
        }
    };
}