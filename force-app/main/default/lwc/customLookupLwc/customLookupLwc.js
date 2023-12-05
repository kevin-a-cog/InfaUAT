import { LightningElement,api,wire} from 'lwc';
import fetchLookupData from '@salesforce/apex/CustomLookupLwcController.fetchLookupData';

const DELAY = 300;

export default class CustomLookupLwc extends LightningElement {
    // public properties 
    @api sLabel = 'custom lookup label'
    @api sLookupPlaceholder = 'search...';
    @api iconName = 'standard:account';
    @api sObjectApiName = 'Account';
    // private properties 
    lstResult = []; // to store list of returned records   
    wiredProvisionedData; // to store provisioned data for wire method
    hasRecords=true;
    searchKey='';    
    isSearchLoading = false;
    delayTimeout;
    selectedRecord = {};

    handleKeyChange(event) {
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }

    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName' })
     searchResult(value) {
        // Hold on to the provisioned value so we can refresh it later.
        this.wiredProvisionedData = value; // track the provisioned value
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true;
             this.lstResult = JSON.parse(JSON.stringify(data));
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       

    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined);
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
  }

handelSelectedUser(event){   
     var objId = event.target.getAttribute('data-userid');
     this.selectedRecord = this.lstResult.find(data => data.Id === objId);
     this.lookupUpdatehandler(this.selectedRecord);
     this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');     
}

lookupUpdatehandler(value){    
    const oEvent = new CustomEvent('lookupupdate',
    {
        'detail': {
            selectedRecord: value
        }
    }
);
this.dispatchEvent(oEvent);


}


}