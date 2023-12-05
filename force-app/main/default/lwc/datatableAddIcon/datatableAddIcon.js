/*
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								    Tag
 **********************************************************************************************************
 N/A		            N/A		        N/A				Initial version.						    N/A
 Vignesh Divakaran      2/3/2023        I2RT-493        Added public property to get the button     T01
                                                        label from parent component
 Vignesh Divakaran      2/6/2023        I2RT-493        Show orange color for Provision Entitlement T02
*/

import { LightningElement, api } from 'lwc';


export default class DatatableAddIcon extends LightningElement {
    @api context;
    @api cssclass;
    @api label; //<T01>

    createOrg(event) {  
        this.dispatchEvent(new CustomEvent('orgchange', 
        {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                 context: this.context
            }
        }));
        console.log('Event dispatched ' + this.context);
        
    }

    get className() { //<T02>
        return this.label == 'Provision Entitlement' ? 'brand-orange' : this.cssclass;
    }
}