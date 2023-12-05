import { LightningElement, track, api, wire } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getRelatedFulfillmentLines from '@salesforce/apex/FulfillmentData.getRelatedFulfillmentLines';
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

export default class RelatedOrderProducts extends LightningElement {
    @track columns = col;
    @track data;
    @api fulfillId;
    @wire(CurrentPageReference) pageRef;

    
    connectedCallback() {

        //event listener for rendering all the related fulfillment lines corresponding to the Active Tab on "fulfillmentLines" component
        //registerListener('reRenderAllRelatedFFLines', this.reRenderAllROP, this);

        //event listener for rendering related fulfillment lines related a particular fulfillment line
        //registerListener('fulfillmentChange', this.reRenderROP, this);

        this.reRenderROP(this.fulfillId);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    reRenderAllROP(lstString) {
        getAllRelatedFFLines({ lstString })
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

    reRenderROP(ffl_Id) {
        
        this.fulfillId = ffl_Id;

        console.log(`this.fulfillId --> ${this.fulfillId}`);
        console.log(`typeof(this.fulfillId) --> ${typeof (this.fulfillId)}`);

        getRelatedFulfillmentLines({ fulfillmentLineId: this.fulfillId })
            .then(result => {
                //this.data = result;
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

    closepopup(event){
        //custom event
        const passEvent = new CustomEvent('closepopup', {
            detail:{recordId:this.fulfillId} 
        });
       this.dispatchEvent(passEvent);
    }
}