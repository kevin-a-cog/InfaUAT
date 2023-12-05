/* Name		    :	CsmRiskEditPage
* Author		:	Deva M
* Created Date	: 	17/01/2021 
* Description	:	Risk Edit/Create page LWC.

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description						Tag
**********************************************************************************************************
Deva M              17/01/2021      AR-2132/1572            Initial Version      
*/
//Core Imports
import { api, LightningElement, track } from 'lwc';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Imports
import getRecords from '@salesforce/apex/CSMRiskEditPageController.getRecords';

//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Loading from '@salesforce/label/c.Loading';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';

export default class CsmGenerateRiskFromPAF extends LightningElement {
    //Public variables
    @api recordId;

    //Private Variables
    boolDisplaySpinner;
    boolRiskTable;
    boolFromRisk;
    riskRecordId;
    //Labels.
    label = {
        Success,
        Error,
        Loading
    }
    get boolFromCreateRiskPage(){
        return objUtilities.isNull(this.riskRecordId)?true:false;
    }
    //Feature Configuration.    
    @track objParameters = {
		boolDisplayActions : false,	
        modalTitle:"Select Risk To Edit",	
        lstActionButtons: [ {
            keyValue: "3",
            label: "Edit Risk",
            variant: 'Brand',
            title: "Edit Risk",
            styleClass: 'slds-m-horizontal_x-small',
            name: 'edit_risk',
            showButton: false,
        },
        {
            keyValue: "4",
            label: Cancel_Button,
            variant: 'Neutral',
            title: Cancel_Button,
            styleClass: 'slds-m-horizontal_x-small slds-float_left',
            name: 'cancel',
            showButton: true,
        }]
    }

    /*
    Method Name : handleClick
    Description : This method executes on click event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    handleClick(objEvent) {
        switch (objEvent.target.dataset.name) { 
            case 'edit_risk':
               this.boolRiskPage = true;
               this.boolRiskTable=false;
            break;      
            case 'cancel':
                this.boolRiskTable=false;
                this.boolRiskPage=false;
            break;
            default:
            break;
        }
    }
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback(){       
        this.boolDisplaySpinner = true;
        this.boolFromRisk=true;
        this.loadRecords();
    }  
    /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
        let objParent = this;
        getRecords({
            strPlanId: objParent.recordId,
            filterCloseRisk:true
        }).then((objResult) => {
            if(objResult.lstRecords.length>1){//Show Table if more than one risk recor on plan
                objParent.boolRiskTable = true;                    
                objParent.objParameters.lstRecords = objResult.lstRecords;						
                objParent.objParameters.lstColumns = objResult.lstColumns;
            }else if(objResult.lstRecords.length==1){ 
                //Show Risk edit page if only one risk assocaited to Plan
                objParent.boolRiskPage = true;
                objParent.riskRecordId = objResult.lstRecords[0].Id
            }else{
                //Show Risk create page if only one risk assocaited to Plan
                objParent.boolRiskPage = true;
            }
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;				
        });	
    } 

    /*
	 Method Name : handleClose
	 Description : This usable method calls on other functions to dispatch close event
	 Parameters	 : None
	 Return Type : None
	 */
     handleClose(){
        this.dispatchEvent(new CustomEvent('close'));  
        this.boolRiskPage=false;
        this.boolRiskTable=false;
    }

        /*
    Method Name : executeAction
    Description : This method executes the corresponding action requested by the Data Tables components.
    Parameters	 : Object, called from executeAction, objEvent Select event.
    Return Type : None
    */
    executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;
        let objParent = this;
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

     /*
    Method Name : selectRecords
    Description : This method selects records from the table.
    Parameters	 : Object, called from selectRecords, objEvent Select event.
    Return Type : None
    */
   selectRecords(objEvent) {
        let objParent = this;
        let selectedRecords = objEvent.detail.selectedRows;      
        if(objUtilities.isNotNull(selectedRecords) && selectedRecords.length>1){
            //Show success toast to user
            objUtilities.showToast(objParent.label.Error,'Should not select more than one record','error',objParent);  
            //Hide Add products buttons
            objParent.objParameters.lstActionButtons.forEach(objButton => {
                if(objButton.keyValue === '3'){
                    objButton.showButton=false;
                }
            });
        }else if(objUtilities.isNotNull(selectedRecords) && selectedRecords.length>0){
                 //Hide Add products buttons
                objParent.objParameters.lstActionButtons.forEach(objButton => {
                    if(objButton.keyValue === '3'){
                        objButton.showButton=true;
                    }
                });
                objParent.riskRecordId = selectedRecords[0].Id;            
        }else{
            //Hide Add products buttons
            objParent.objParameters.lstActionButtons.forEach(objButton => {
                if(objButton.keyValue === '3'){
                    objButton.showButton=false;
                }
            });
        }
    }

}