/*
 * Name			    :	CsmCreateMilestoneWithProductModal
 * Author		    :	Deva M
 * Created Date	    :   17/09/2021
 * Description	    :	CsmCreateMilestoneWithProductModal.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		        17/09/2021		N/A				  Initial version.			N/A
 */

import { api, LightningElement,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

//Custom Labels
import Loading from '@salesforce/label/c.Loading';
//Apex Controllers.
import getRecords from "@salesforce/apex/CSMManageObjectiveProducts.getRecords";
import getRecordsRelated from '@salesforce/apex/CSMManageMilestoneProducts.getRecordsRelated';
import isCSMSuccessCommunity from "@salesforce/apex/CSMObjectivesAndMilestonesController.isCSMSuccessCommunity";

import IS_INTERNAL from '@salesforce/schema/Objective__c.Is_Internal__c';
//Utilities.
import { objUtilities } from 'c/informaticaUtilities';

export default class CsmCreateMilestoneWithProductModal extends LightningElement {
    @api objectiveId;
    @api planId;
    @api strDefaultTab;
	@api boolPreSelect;
    
    milestoneId;
    milestones = [];
    objectiveProducts = [];
    saveAndAddMilestone;
    showMileStoneProducts; 
    showSecondMilestoneModal;
    showMileStoneModal;   
    milestoneProducts;
    boolDisplaySpinner;
    createObjective;
    saveOnlyMilestone;
    objParameters = {
        strTableId: "1" ,
        strTableClass: "assignedTable"
    };
    label={
        Loading
    }
    isObjectiveInternal;

	//Private variables.
	boolIsCSMCommunity = false;

    connectedCallback() {
		let objParent = this;
        this.saveAndAddMilestone=false;
        this.boolDisplaySpinner=true;
        this.showMileStoneProducts=false;
        this.showMileStoneModal=false;
        this.createObjective=false;
        this.saveOnlyMilestone=false;
        this.showSecondMilestoneModal=false;
        this.isObjectiveInternal=true;
        this.loadRecords();

		//We check if the current user is a Community User.
		isCSMSuccessCommunity().then(boolIsCSMCommunity => {
			objParent.boolIsCSMCommunity = boolIsCSMCommunity;
		});
    }

    @wire(getRecord, { recordId: "$objectiveId", fields:[IS_INTERNAL] })
	objectiveRecordDetails({data,error}){
        if(data){
            this.isObjectiveInternal = data.fields.Is_Internal__c.value;
        }
    }
    
    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
     selectRecords(objEvent) {
        let objParent = this;      
        objParent.template.querySelector('.assignedTable').hideButtons();
        this.milestoneProducts = objEvent.detail.selectedRows.map(record => record.Plan_Product__c); 
     }

         /*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
            default:
			break;
		}
    }
    loadRecords(){
        if(objUtilities.isNotNull(this.objectiveId)){
            let objParent = this;
            getRecords({
                strPlanId : this.planId,
                boolGetAssingedRecords : true,
                strObjectiveId: this.objectiveId
            })
            .then(objResult => {
                //We build the tables.			
                objParent.objParameters.lstRecords = objResult.lstRecords;
                objParent.objParameters.lstColumns = objResult.lstColumns;
                //Finally, we hide the spinner.
                objParent.boolDisplaySpinner = false;
                if(objUtilities.isNotNull(objResult.lstRecords) && objResult.lstRecords.length>0){
                    objParent.showMileStoneProducts=true;
                }
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                //Finally, we hide the spinner.
                objParent.boolDisplaySpinner = false;
            });
        }
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleClick(event) {
       switch (event.target.dataset.name) {
            case 'cancel':
                this.dispatchEvent(new CustomEvent('close'));
                break;
            case 'save':    
                if(this.validate){  
                    this.saveAndAddMilestone=false;
                    this.saveOnlyMilestone=true;
                    this.template.querySelector('[data-name="milestoneFormSubmitButton"]').click();
                }
                break;
            case 'saveAndAddMilestone':
                if(this.validate){
                    this.milestoneId=null;
                    this.saveAndAddMilestone=true;
                    this.template.querySelector('[data-name="milestoneFormSubmitButton"]').click();
                }
                break;
            case 'saveAndAddMilestoneProducts':
                if(this.validate){
                    this.template.querySelector('[data-name="milestoneFormSubmitButton"]').click();
                }
            break;
            case 'saveandcreateobjective':
                if(this.validate){
                    this.createObjective=true;
                    this.template.querySelector('[data-name="milestoneFormSubmitButton"]').click();
                }
            break;
            default:
                break;
        }
    }
    handleError(){
        this.boolDisplaySpinner=false;
    }
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        let objParent = this;
        const fields = event.detail.fields;
        fields.Plan__c = this.planId;
        this.template.querySelector("lightning-record-edit-form").submit(fields);
        this.boolDisplaySpinner=true;
    }
    handleLoad(){
        this.boolDisplaySpinner=false; 
    }
    handleMilestoneSuccess(event){  
        let objParent = this;        
        objUtilities.showToast('Success','Record(s) Created successfully!','success',objParent); 
       this.milestoneId= event.detail.id; 
       //On Obnly SAve milestone close the modal screen
       if(this.saveOnlyMilestone === true){
            this.handleCancel();
       }  
       //If user din't click on create objective button then enter this logic
       if(this.createObjective===false){
             if(this.saveAndAddMilestone && this.saveAndAddMilestone == true){       
                this.saveAndAddMilestone=false;        //Allow users to create another milestone
                this.milestoneId=null;
                this.showSecondMilestoneModal=true;
            }else if(this.showMileStoneProducts === true && objUtilities.isNotNull(this.milestoneId)){
                this.showMileStoneModal=true;//Show Milestone Product screen
            }else{
                this.showMileStoneModal=false; 
            }
            if(objUtilities.isNotNull(this.milestoneId) && !this.showMileStoneModal){
                this.saveAndAddMilestone=false;
                this.showSecondMilestoneModal=false;
           }
       }else{
           this.saveAndAddMilestone=null;
           this.showMileStoneModal=null;
           this.milestoneId=null;
           this.saveAndAddMilestone=null;
           this.showSecondMilestoneModal=null;
       }   
      
       this.boolDisplaySpinner=false;
    }

    createMilestoneProducts(){
        let objParent = this;
        getRecordsRelated({
            strRecordId: this.milestoneId,
            lstRecords: this.milestoneProducts    
        }).then((objResult) => {
            objUtilities.showToast('Success!','Milestone Porducts added Successully','success',objParent);
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
    }
    

   validate() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            isValid = ip.reportValidity();
        });        
        return isValid;
    }

}