import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
//import checkUnSubscribe from '@salesforce/apex/iNotifyController.checkUnSubscribe';
//import checkAlerts from '@salesforce/apex/iNotifyController.checkAlerts';

export default class EmpApiLWC extends LightningElement {
    @api channelName;
    subscription = {};
    data;

    connectedCallback(){
        window.addEventListener("beforeunload", this.beforeUnloadHandler);
        console.log("connectedCallback executed");
      
        this.registerErrorListener(); 
        
        // Callback invoked whenever a new event message is received
        const messageCallback = function(response) {
            console.log('New message received: ', JSON.stringify(response));
            //this.puhEvent(response);
            var result = [];
            let finalResult = [];
            result.push(response);

            result.forEach(row => {
                if(row['data']['sobject'] != undefined){
                    var sobjectRecords = [];
                    sobjectRecords.push(row['data']['sobject']);
                    sobjectRecords.forEach(col => {
                        if(col.Id != undefined){
                            finalResult.push({Id: col.Id});
                        }
                    });
                }
            });

            console.log('finalResult --> '+JSON.stringify(finalResult));
            this.data = finalResult;
            console.log('this.data --> '+JSON.stringify(this.data));
            
            const pushAlertEvent = new CustomEvent('pushAlert', { detail: { data: finalResult } });
            this.dispatchEvent(pushAlertEvent);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback.bind(this)).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        window.removeEventListener("beforeunload", this.beforeUnloadHandler);
        console.log("disconnectedCallback executed");
    }

    puhEvent(){
        console.log(JSON.stringify(this.data));
    }

    beforeUnloadHandler(ev) {

        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });

        /*
        var message = 'Welxcomeeee';
        checkUnSubscribe({ testM: message })
            .then((result) => {
                console.log('Success');
            })
            .catch((error) => {
                console.log('Error');
            })
        */
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

}