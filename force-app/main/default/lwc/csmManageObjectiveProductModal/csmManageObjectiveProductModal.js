/*
 * Name			:	CsmManageObjectiveProductModal
 * Author		:	Deva M
 * Created Date	: 	14/09/2021
 * Description	:	CsmManageObjectiveProductModal Controller

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		            14/09/2021		N/A				Initial version.			N/A
 */
 import { api, LightningElement } from 'lwc';
import createObjectiveProducts from '@salesforce/apex/CSMManageObjectiveProducts.getRecordsRelated';
 import getRecordsDeleted from "@salesforce/apex/CSMManageObjectiveProducts.getRecordsDeleted";
 //Utilities.
 import { objUtilities } from 'c/globalUtilities';
 //Custom Labels
 import Manage_Plan_Objective_Product_Title from '@salesforce/label/c.CSM_Manage_Objective_Product';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Success from '@salesforce/label/c.Success';
 export default class CsmManageObjectiveProductModal extends LightningElement {
     @api objectiveId;
     @api planId;
     objectiveProducts;
     hideSaveButtons;
     hideDeleteButton;
     boolDisplaySpinner;
     connectedCallback() {
       this.hideSaveButtons=false;
       this.hideDeleteButton=false;
     }
     //Labels.
     label = {
         Manage_Plan_Objective_Product_Title,
         Cancel_Button,
         Remove_Button,
         Add_Button,
         Success
     }
     handleClick(event) {
         switch (event.target.dataset.name) {
             case 'cancel':
                 this.dispatchEvent(new CustomEvent('close'));
                 break;
             case 'delete':
                this.removeRecords();
                 break;
             case 'saveandclose':
             this.updateSelectedProducts(false);                
             break;
             default:
                 break;
         }
     }
 

     removeRecords() {
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;
		
		objParent.objectiveProducts.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord
			});
		});

		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {
           //Refresh records post updated
           this.template.querySelector('c-csm-manage-objective-products').refreshCard();
           objUtilities.showToast(objParent.label.Success,'Objectives Products removed Successully','success',objParent);
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });    
	}
  
     updateSelectedProducts(isSaveAction){
         let objParent=this;
         objParent.boolDisplaySpinner=true;
         createObjectiveProducts({
            strRecordId: this.objectiveId,
            lstRecords: this.objectiveProducts    
         }).then((objResult) => {           
            // if(isSaveAction === true){            
                 this.template.querySelector('c-csm-manage-objective-products').refreshCard();
            // }else{
                 // this.dispatchEvent(new CustomEvent('close'));
            // }
            objUtilities.showToast(objParent.label.Success,'Objectives Products added Successully','success',objParent);
         }).catch((objError) => {
             objUtilities.processException(objError, objParent);
         }).finally(() => {
             //Finally, we hide the spinner.
             objParent.boolDisplaySpinner = false;
         });
     }

     handleProductSelect(objEvent){
        if(objUtilities.isNotNull(objEvent.detail.selectedRows)){
            let lstRecords = new Array();

            objEvent.detail.selectedRows.forEach(objSelectedRecord => {
                lstRecords.push(
                    objSelectedRecord.Id
                );
            });
            this.objectiveProducts = lstRecords;
             if(objUtilities.isNotNull(this.objectiveProducts) && this.objectiveProducts.length>0){
                this.hideSaveButtons=(objEvent.detail.action=="save");
                this.hideDeleteButton=(objEvent.detail.action=="delete");
             }else{
                this.hideSaveButtons=false;
                this.hideDeleteButton =false;
             }           
        }else{
            this.hideSaveButtons=false;
            this.hideDeleteButton =false;
         }       
     }   
 }