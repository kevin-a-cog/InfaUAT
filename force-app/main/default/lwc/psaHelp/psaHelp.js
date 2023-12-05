import { LightningElement, track } from 'lwc';
import getHelpItems from '@salesforce/apex/psa_HelpController.getHelpItems';

export default class PsaHelp extends LightningElement {

    @track helpItems = [];

    connectedCallback(){
        console.log('connectedcallback...');

        getHelpItems().then(result => {           
            console.log('help items = ' + JSON.stringify(result));
            result.forEach(item => {
                this.helpItems.push({id:item.Id,label:item.Item_Label__c,url:item.URL__c,sortOrder:item.Item_Order__c});
            });
            sortHelpItems();
            console.log('this.helpItems = ' + JSON.stringify(this.helpItems));
        }).catch(error => {
            console.log('error =' + JSON.stringify(error));
        });
    }

    sortHelpItems() {
        prop = 'sortOrder';
        this.helpItems.sort(function(a, b) {
            return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
        });
    }

    handleSelect(event) {
        const selectedName = event.detail.name;
        console.log('name - ' + selectedName);
        
        var helpItemURL='';
        this.helpItems.forEach(item =>{
            if(item.id === selectedName){
                helpItemURL = item.url;
            }
        });
        if(helpItemURL != ''){
            window.open(helpItemURL);
        }
    }
}