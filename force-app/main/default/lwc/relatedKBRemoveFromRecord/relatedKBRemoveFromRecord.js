/*
@created by       : SathishR
@created on       : 08/02/2020
@Purpose          : Related KB Object Custom Action Remove from Record button
@Testclass        :
@JIRA             :


Change History
 **************************************************************************************************************************
|     Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 **************************************************************************************************************************
|     01      |  25-Jul-2023      |   Sathish R               |    I2RT-8611      |   KM User unable to archive article when a KB is linked to the article by another user.

 */

import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import removeRelatedArticlesFromKB from "@salesforce/apex/KBArticleHandler.removeRelatedArticlesFromKB"; 
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from 'lightning/uiRecordApi';

//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
  try {
    if (ISDEBUGENABLED == true || parType == "error") {
      if (parType == "log") {
        console.log(parMessage);
      } else if (parType == "error") {
        console.error(parMessage);
      } else if (parType == "warn") {
        console.warn(parMessage);
      }
    }
  } catch (err) {
    console.log("Utility Log : " + err.message);
  } finally {
  }
}
//For Loggging in Console



const RELATEDKBARTICLE_FIELDS = [
  'Knowledge__kav.Id',
  'Knowledge__kav.Referred_In__c'
];


export default class RelatedKBRemoveFromRecord extends NavigationMixin(LightningElement) {
  @api recordId;

        
  @wire(getRecord, { recordId: '$recordId', fields: RELATEDKBARTICLE_FIELDS })
  relkbarticle;

  closeQuickAction() {
    try {
      this.dispatchEvent(new CloseActionScreenEvent());
    } catch (error) {
      Log("error", "closeQuickAction error --> " + JSON.stringify(error));
    }
  }

  deleteRelatedKB() {
    try {
      console.log("Inside deleteRelatedKB");
      removeRelatedArticlesFromKB({
        relkbId: this.recordId
      })
        .then((result) => {
          if (result != null && JSON.parse(result).ResponseStatus === "SUCCESS") {
            this.dispatchEvent(
              new ShowToastEvent({
                mode: "dismissable",
                title: "Success",
                message: "Record removed successfully",
                variant: "success"
              })
            );
            this.closeQuickAction();            
            if( (typeof (this.relkbarticle.data.fields.Referred_In__c.value) != 'undefined') && ( this.relkbarticle.data.fields.Referred_In__c.value != null) )
            {
              this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  recordId: this.relkbarticle.data.fields.Referred_In__c.value,
                  objectApiName: "Knowledge__kav",
                  actionName: "view",
                },
              });                        
            }            
          }

          if (
            result != null &&
            JSON.parse(result).ResponseStatus === "ALREADY"
          ) {
            this.dispatchEvent(
              new ShowToastEvent({
                mode: "dismissable",
                title: "Warning",
                message: "Record already removed",
                variant: "warning"
              })
            );
            this.closeQuickAction();
            if( (typeof (this.relkbarticle.data.fields.Referred_In__c.value) != 'undefined') && ( this.relkbarticle.data.fields.Referred_In__c.value != null) )
            {
              this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  recordId: this.relkbarticle.data.fields.Referred_In__c.value,
                  objectApiName: "Knowledge__kav",
                  actionName: "view",
                },
              });                        
            }
          }
        })
        .catch((error) => {
          console.log("error " + error);
          console.log("error object", JSON.stringify(error));
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error removing record",
              message: error.message,
              variant: "error"
            })
          );
        });
    } catch (error) {
      Log("error", "deleteRelatedKB error --> " + JSON.stringify(error));
    }
  }
}