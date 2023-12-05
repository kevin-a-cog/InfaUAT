/*
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								 Tag
 **********************************************************************************************************
 N/A		            N/A		        N/A				Initial version.						 N/A
 Vignesh Divakaran      2/3/2023        I2RT-493        Added label attribute                    T01
*/
import LightningDatatable from 'lightning/datatable';
import relatedOrderProducts from './relatedOrderProductsTemplate.html';
import DatatablePicklistTemplate from './picklistTemplate.html';
import DatatableLookupTemplate from './lookupTemplate.html';
import DatatableAddIconTemplate from './addIconTemplate.html';
import DatatableorgUUIDTemplate from './orgUUIDTemplate.html';
import DatatableCloneFflineTemplate from './cloneFflineTemplate.html';

export default class MyCustomDatatable extends LightningDatatable {
    //hasRendered = false;
    static customTypes = {
        vieworderproducts: {
            template: relatedOrderProducts,
            // Provide template data here if needed
            typeAttributes: ['rowid'],
        },
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context'],
        },
        /**PV - F2A-345 - Ability to provision cloud org/instance from fulfillment object */
        addicon: {
            template: DatatableAddIconTemplate,
            typeAttributes: ['context','cssclass', 'label'],  //<T01>          
        },
        reference: {
            template: DatatableLookupTemplate,            
            typeAttributes: ['fieldapi', 'value','context','disable'],            
        },
        orgUUID:{
            template: DatatableorgUUIDTemplate,
            typeAttributes: ['value','context'],  
        },
        /**PV - F2A-345 - Ability to provision cloud org/instance from fulfillment object */
        addffline :{
            template: DatatableCloneFflineTemplate,
            typeAttributes: ['value','context','cssclass'], 
        }
       //more custom types here
    };

    
   }