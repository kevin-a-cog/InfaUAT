import { LightningElement, track, api, wire } from 'lwc';
import getAllRelatedFFLines from '@salesforce/apex/FulfillmentData.getAllRelatedFFLines';

let col = [ 
       
    {label: 'Product Name', type: 'navigation', typeAttributes:
        {
            rowid: {fieldName: 'Id'},
            label: {fieldName:'Order_Product_Name__c'},
            
        },
        initialWidth: 500
    },
    {label: 'Order Product Number', type: 'navigation', typeAttributes:
        {
            rowid: {fieldName: 'Order_Product__c'},
            label: {fieldName:'OrderItemNumber'},
            
        },
        initialWidth: 200,
        cellAttributes: { alignment: 'center' }
    },
    { label: 'Quantity', fieldName: 'Quantity__c', type: 'number', initialWidth: 150,cellAttributes: { alignment: 'center' } }
];

export default class AllRelatedOrderProducts extends LightningElement {
    @track columns = col;
    @track data;
    @api recordId;
    
    connectedCallback() {
            /** Display all the unique Related Order Products */
            let lstString = [];
            lstString.push(this.recordId);
            lstString.push('All');

        getAllRelatedFFLines({ lstString : lstString})
            .then(result => {
                console.log(`related order products -> data ---> ${JSON.stringify(result)}`);
                let tempData = JSON.parse(JSON.stringify(result));
                for(let i=0;i<tempData.length;i++){
                    tempData[i].OrderItemNumber = tempData[i].Order_Product__r.OrderItemNumber;
                }
                console.log(`related order products -> tempData ---> ${JSON.stringify(tempData)}`);
                this.data = tempData;
            })
            .catch(error => {
                console.log(`reRenderROP --> getRelatedFulfillmentLines --> error: ${error}`);
            })
    }


}