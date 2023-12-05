/*
* Name			:	changeOwner
* Author		:	Isha Bansal
* Created Date	: 	27/03/2023
* Description	:	This LWC is used to change ownership of a record to another user or queue

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description							Tag
**********************************************************************************************************
Isha Bansal		27/03/2023		I2RT-6727		Initial version.					N/A
*/

//Core imports.
import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference ,NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord,notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

//Utilities.
import { objUtilities, log } from 'c/globalUtilities';

//Apex Controllers.
import lookupCombinedSearch from '@salesforce/apex/RaiseHandController.lookupCombinedSearch';
import getObjectSpecificLabel  from '@salesforce/apex/ChangeRecordOwner.getObjectSpecificLabel';

//Import CSS from static resources
import global_styles from '@salesforce/resourceUrl/eSupportRrc';
import { loadStyle } from 'lightning/platformResourceLoader';

// Import custom labels
import ChangeOwnerSuccessMsg from '@salesforce/label/c.ChangeOwnerSuccessMsg';

export default class ChangeOwner extends NavigationMixin(LightningElement) {

  //API variables.
  @api recordId;
  @api objectApiName;

  //Private Variables 
  isLoading=false;       
  changedOwnerId;    
  label;


   //Labels.
	labels = {
    ChangeOwnerSuccessMsg
};
/*
	 Method Name : getStateParameters 
	 Description : This is a LWC predefined menthod being used to fetch recordid 
                in quick action call during component load.
	*/ 
@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
    }
    this.isLoading = true; 
    getObjectSpecificLabel({
  recordId: this.recordId  
    })
  .then((result) => {   		
  this.label=result.changeOwnerLabel;  
  this.objectApiName=result.objAPIName;
  }) .catch((err) => {  
    objUtilities.showToast("Error!", err.body.message, "error",this);
  }).finally(() => {
    this.isLoading = false;
  });
}

renderedCallback() {
  Promise.all([
  loadStyle(this, global_styles + '/css/changeowner.css'),
  ])
  .then(() => {
      console.log("CSS loaded.");
      
  })
  .catch(() => {
      console.log("CSS not loaded");
      
  });
}
    /*
  Method Name : handleCombinedLookupSearch
  Description : This method changes the owner id of the record 
*/ 
  handleCombinedLookupSearch(event) {
      const lookupElement = event.target; 
      lookupCombinedSearch(event.detail)
          .then(results => { //apex method result                
              lookupElement.setSearchResults(results); //call method of customlookupfield.
          })
          .catch(error => {
              log('Combined Lookup Failed -> ' + error);
          });
    }
    handleCombinedLookupSelectionChange(event) {                 
        const selectedId = event.detail?.values().next().value;        
        this.changedOwnerId = selectedId;
        
    }
    /*
  Method Name : Save
  Description : This method saves the record with new owner Id
*/
    save(){        
  this.isLoading = true;	
  const fields = {}; /// Create the recordInput object for uirecordapi- updateRecord
  fields['Id'] = this.recordId;
  fields['OwnerId']=this.changedOwnerId;
  const recordInput = { fields };

  updateRecord(recordInput)
              .then(() => {
                objUtilities.showToast('Success!', this.labels.ChangeOwnerSuccessMsg, 'success', this);  
                this.cancel();   
              })
              .catch(error => {
                this.isLoading = false;
                objUtilities.showToast('Error!', error.body.message, 'error', this); 
                
              });
    }

/*
  Method Name : cancel
  Description : This method closes the modal.
  Parameters	 : None
  Return Type : None
  */
    cancel(){
      let objParent = this;
      objParent[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: objParent.recordId,
              objectApiName: objParent.objectApiName,
              actionName: 'view'
          }
      });
      notifyRecordUpdateAvailable([{recordId: this.recordId}]);
      objParent.dispatchEvent(new CloseActionScreenEvent());
  }
  

  //Getters  
  get booldisplayftotable() {
    return (objUtilities.isNotBlank(this.changedOwnerId) && this.changedOwnerId.startsWith('005'));
  }

  get booldisableSave(){
    return (objUtilities.isNotBlank(this.changedOwnerId) && !this.isLoading)?false:true;
  }


}