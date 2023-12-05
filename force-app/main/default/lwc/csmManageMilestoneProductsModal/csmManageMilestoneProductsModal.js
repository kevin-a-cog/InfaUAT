/*
 * Name			:	CsmManageMilestoneProductsModal
 * Author		:	Deva M
 * Created Date	: 	31/08/2021
 * Description	:	CsmManageMilestoneProductsModal controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		31/08/2021		N/A				Initial version.			N/A
 */
//Core imports
import { wire,LightningElement,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

//milestone object fields
import OBJECTIVE from '@salesforce/schema/Milestone__c.Objective__c';

//Apex imports
import getRecordsRelated from '@salesforce/apex/CSMManageMilestoneProducts.getRecordsRelated';
import getRecordsDeleted from "@salesforce/apex/CSMManageMilestoneProducts.getRecordsDeleted";

//import Labels
import Manage_Milestone_Product_Title from '@salesforce/label/c.CSM_Manage_Milestone_Product';
import Loading from '@salesforce/label/c.Loading';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Success from '@salesforce/label/c.Success';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class CsmManageMilestoneProductsModal extends LightningElement {
    //Api Variables
    @api planRecordId;
    @api milestoneRecordId;
    @api strDefaultTab;
    @api boolPreSelect;
    boolDisplaySpinner;
    //Private Variables
    milestoneProducts;
    hideSaveButton;
    objectiveId;
    showMilestoneScreen;
    hideDeleteButton;
    //Labels.
	label = {
		Manage_Milestone_Product_Title,
        Loading,
        Cancel_Button,
        Remove_Button,
        Add_Button,
        Success
	}

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback(){
        this.hideSaveButton=false;
        this.hideDeleteButton=false;
        this.showMilestoneScreen=false;
        if(objUtilities.isNull(this.tabValue)){
            this.tabValue="1";
        }
    }


    @wire(getRecord, { recordId: '$milestoneRecordId', fields: [OBJECTIVE] })
    milestoneRecord({ error, data }) {
        if (error) {
        } else if (data) {
            this.objectiveId = data.fields.Objective__c.value    
        }
    }

    /*
	 Method Name : handleCancel
	 Description : This method will dispatch close event on cancel.
	 Parameters	 : None
	 Return Type : None
	 */
    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

     /*
	 Method Name : handleClick
	 Description : This method will call onc
	 Parameters	 : onlcick event
	 Return Type : None
	 */
    handleClick(event) {
        switch (event.target.dataset.name) {
            case 'cancel':
                this.dispatchEvent(new CustomEvent('close'));
                break;
            case 'save':
                this.updateSelectedProducts(false);
                break;            
            case 'saveandaddmilestone':
                this.tabValue="2";
                this.updateSelectedProducts(true);
                break;
            case 'delete':
                this.removeRecords(false);
            break;
            case 'deleteandaddmilestone':
                this.removeRecords(true);
            break;
            default:
                break;
        }
    }


     /*
	 Method Name : updateSelectedProducts
	 Description : This method will update the selected products
	 Parameters	 : mileStoneAtt
	 Return Type : None
	 */
    updateSelectedProducts(mileStoneAtt){
        this.boolDisplaySpinner=true;
        let objParent=this;        
        getRecordsRelated({
            strRecordId: this.milestoneRecordId,
            lstRecords: this.milestoneProducts    
        }).then((objResult) => {    
         //   if(mileStoneAtt==true){
            //    this.showMilestoneScreen=true;
           // }else{
            //     this.dispatchEvent(new CustomEvent('close'));
            //}
            //Refresh records post updated
            objParent.template.querySelector('c-csm-manage-milestone-products').refreshCard();
           //Show success toast to user
           objUtilities.showToast(objParent.label.Success,'Milestone products added successfully','success',objParent);
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            this.boolDisplaySpinner=false;
        });
    }

      /*
	 Method Name : handleProductSelect
	 Description : This method call from select on list 
	 Parameters	 : objEvent
	 Return Type : None
	 */
    handleProductSelect(objEvent){
        if(objUtilities.isNotNull(objEvent.detail.selectedRows)){
            let lstRecords = new Array();
            objEvent.detail.selectedRows.forEach(objSelectedRecord => {
                lstRecords.push(
                    objUtilities.isNotNull(objSelectedRecord.Id) ? objSelectedRecord.Id : objSelectedRecord
                );
            });
            this.milestoneProducts = lstRecords;
            if(objUtilities.isNotNull(this.milestoneProducts) && this.milestoneProducts.length>0){
               this.hideSaveButton=(objEvent.detail.action=="save");
               this.hideDeleteButton=(objEvent.detail.action=="delete");
            }else{
               this.hideSaveButton=false;
               this.hideDeleteButton =false;
            }           
        }else{
            this.hideSaveButton=false;
            this.hideDeleteButton =false;
        }       
    }  
    /*
	 Method Name : removeRecords
	 Description : This method will delete records associated
	 Parameters	 : objEvent
	 Return Type : None
	 */
    removeRecords(mileStoneAtt) {
	
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;
		
		objParent.milestoneProducts.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord
			});
		});

		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {
           /* if(mileStoneAtt==true){
                this.showMilestoneScreen=true;
            }else{
                 this.dispatchEvent(new CustomEvent('close'));
            }*/
            //Refresh records post updated
            objParent.template.querySelector('c-csm-manage-milestone-products').refreshCard();
           //Show success toast to user
           objUtilities.showToast(objParent.label.Success,'Milestone products removed successfully','success',objParent);
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });    
    }
}