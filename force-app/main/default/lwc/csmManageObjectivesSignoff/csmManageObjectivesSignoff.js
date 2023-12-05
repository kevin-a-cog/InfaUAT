/*
 * Name			    :	CSMManageObjectivesSignoff
 * Author		    :	Deva M
 * Created Date	    :   30/11/2021
 * Description	    :	JS controller for Objective Sign off component.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		            30/11/2021		N/A				  Initial version.			N/A
 */

//Core imports.
import { api, LightningElement, track, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMObjectivesSignoffController.getRecords";
import getContactRecords from "@salesforce/apex/CSMObjectivesSignoffController.getContactRecords";
import fetchMergedQuickText from '@salesforce/apex/CSMObjectivesSignoffController.fetchMergedQuickText';
import createObJectivePlanComment from '@salesforce/apex/CSMObjectivesSignoffController.createObJectivePlanComment';

//Custom Labels.
import Loading from '@salesforce/label/c.Loading';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import CSM_Objective_Request_Signoff from '@salesforce/label/c.CSM_Objective_Request_Signoff';
import CSM_Objective_Signon_Behalf from '@salesforce/label/c.CSM_Objective_Signon_Behalf';
import hasCSMPermission from "@salesforce/customPermission/CSMUser";
import INTERNAL_FIELD from '@salesforce/schema/Plan__c.Is_Internal__c';

export default class CsmManageObjectivesSignoff extends LightningElement {
    //Public variables
    @api recordId

    //Private Variables
    boolDisplaySpinner;
    boolDisplayObjtivesTable;
    boolDisplayPlanCommentModal;
    boolDisplaySignOnBehalfScreenOne; 
    boolDisplaySignOffModal;
    strEmailTemplateName;
    strContactValue;
    strPlanName;   
    selectedRecords =[];
    lstContactRecords;

    //Labels.
    label = {
        Loading,
        Cancel_Button,
        Success,
        Error,
        CSM_Objective_Request_Signoff,
        CSM_Objective_Signon_Behalf
    }
    
    //Feature Configuration.
    objContactParameters = {}

    @track 
    objParameters = {
        strTableId: "1",
        strModalTitle:'Get Signoff',
        strTableClass: "assignedTable",
        boolDisplayActions:false,
        allowedRichTxtFormats : ['font', 'size', 'bold', 'italic', 'underline',
        'strike', 'list', 'indent', 'align', 'link',
        'image', 'clean', 'table', 'header', 'color'
        ],
        richTextBody:{
            fieldValue :'',
            showField : false
        },
        lstButtons:[
            {
                keyValue: "1",
                label: "Cancel",
                variant: 'Neutral',
                title: "Cancel",
                styleClass: 'Cancel',
                name: 'Cancel_Modal',
				showButton: true,
            },
            {
                keyValue: "2",
                label: "Request Signoff",
                variant: 'Brand',
                title: "Request Signoff",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'Request_Signoff',
				showButton: false
            },
            {
                keyValue: "3",
                label: "Sign On Behalf",
                variant: 'Brand',
                title: "Sign On Behalf",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'Sign_On_Behalf',
				showButton: false
            },
            {
                keyValue: "4",
                label: "Send",
                variant: 'Brand',
                title: "Send",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'Send_Request_Signoff',
				showButton: false
            },
            {
                keyValue: "5",
                label: "Next",
                variant: 'Brand',
                title: "Next",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'Next_Screen',
				showButton: false
            } ,
            {
                keyValue: "6",
                label: "Save",
                variant: 'Brand',
                title: "Save",
                styleClass: 'slds-m-horizontal_x-small',
                name: 'Save_On_Behalf',
				showButton: false
            } 

        ]
    }
    get richTextHeightClass(){
        return 'lwcrichtext';
    }

     //AR-2491 Show toast  when click on sign off
     @wire(getRecord, { recordId: '$recordId', fields: [INTERNAL_FIELD] })
     planRecord({error, data}){
         if(error){
             
         }else if(data){
             const internalFieldValue = getFieldValue (data, INTERNAL_FIELD);
             if(internalFieldValue == true){
                 objUtilities.showToast('info','Plan in Internal/ hidden from customer. Please write to the Customer to get a formal signoff.','info',this);
             }
         }
    }
    /*
    Method Name : connectedCallback
    Description : This method gets executed on load.
    Parameters	 : None
    Return Type : None
    */
    connectedCallback() {
        let objParent = this;	
        objParent.boolDisplaySpinner = false;
        objParent.boolDisplayObjtivesTable=false;
        objParent.boolDisplayPlanCommentModal=false;
        objParent.boolDisplaySignOnBehalfScreenOne = false;
        objParent.boolDisplaySignOffModal=false;
        objParent.loadContactRecords();
        //First we load the list of records.
        objParent.loadRecords();	
    }
 
    /*
    Method Name : loadRecords
    Description : This method loads the records on the corresponding table.
    Parameters	 : None
    Return Type : None
    */
    loadRecords() {
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        getRecords({
            strPlanId: this.recordId
        }).then((objResult) => {
            this.boolDisplayObjtivesTable=true;
            objParent.objParameters.lstRecords = objResult.lstRecords;						
            objParent.objParameters.lstColumns = objResult.lstColumns;
            if(!hasCSMPermission){
				         this.objParameters.boolHideCheckboxColumn = true;
            }else{
                        this.objParameters.boolHideCheckboxColumn = false;
                }
            if(objUtilities.isNotNull(objResult.lstRecords) && objResult.lstRecords.length>0){
            //Iterate over the list of objectives and set the plan name.
            objResult.lstRecords.forEach(objRecord => {
                if(objUtilities.isNotNull(objRecord) && objUtilities.isNotNull(objRecord.Plan__r.Name)){
                    objParent.strPlanName = objRecord.Plan__r.Name;
                    return;
                }
            }); 
            }
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;				
        });				
    }

     /*
    Method Name : loadContactRecords
    Description : This method loads the contact records
    Parameters	 : None
    Return Type : None
    */
    loadContactRecords() {
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        getContactRecords({
			strPlanId: this.recordId
		}).then((objResult) => {
            if(objUtilities.isNotNull(objResult) ){
                //Logic to build to append the parent fields like contact name
                var updatedRecords=[];						
                if(objUtilities.isNotNull(objResult.lstRecords) && objResult.lstRecords.length>0){
                    objResult.lstRecords.forEach(record => {
                        //Restructered the Json to fetch related phone and Name fields
                        let preparedContactRecord = record;
                        record.Name=objUtilities.isNotBlank(record.Contact_Name__c) ? record.Contact_Name__c : record.Name;
                       	// and so on for other fields
                        updatedRecords.push(preparedContactRecord);
                    });
                    objParent.boolDisplaySignOffModal=true;
                }else{
                    objUtilities.showToast(objParent.label.Error,'Please add a business/technical owner to Contacts before proceeding with Sign Off.','error', objParent);
                    objParent.handleClose();
                }			
                objParent.objContactParameters.lstRecords = updatedRecords;
                objParent.objContactParameters.lstColumns = objResult.lstColumns;
            }
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});				
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
                if(objParent.boolDisplaySignOnBehalfScreenOne===false){		
           	        //The user has selected records.
			        this.selectRecords(objPayload);    
                }else{
                    this.selectContactRecords(objPayload);
                }
            break;
            default:
                break;
        }
    }

    /*
    Method Name : handleClose
    Description : This method executes on close event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    handleClose(objEvent) {
        this.dispatchEvent(new CustomEvent('close'));
    }

    /*
    Method Name : handleClick
    Description : This method executes on click event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    handleClick(objEvent) {
        switch (objEvent.target.dataset.name) {
            case 'closeModal':
                this.handleClose();
                break;
            case 'Cancel_Modal':
                this.handleClose();
            break;
            case 'Request_Signoff':
                this.handleRequestSignOff(objEvent);
            break;
            case 'Sign_On_Behalf':
                this.handleSignOnBehalf(objEvent);
            break;
            case 'Send_Request_Signoff':
                this.savePlanComment();
            break;
            case 'Next_Screen':
               this.handleSignOnBehalfScreenOne(objEvent);
            break;
            case 'Save_On_Behalf':
               this.savePlanComment();
            break;
            default:
            break;
        }
    }

     /*
	 Method Name : handleChange
	 Description : This method gets executed on change.
	 Parameters	 : None
	 Return Type : None
	 */
     handleChange(objEvent) {   
        let objParent = this;   
        switch (objEvent.target.dataset.name) {
            case 'commentBody':
                objParent.objParameters.richTextBody.fieldValue = objEvent.detail.value;
             break;
             case 'contactChange':
                objParent.strContactValue = objEvent.detail.value;
            break;            
             default:
                break;
        }
    }

    /*
    Method Name : handleRequestSignOff
    Description : This method execute on click of request Sign off
    Parameters	 : Object, objEvent Select event.
    Return Type : None
    */
    handleRequestSignOff(objEvent){
        let objParent = this;      
        objParent.boolDisplayObjtivesTable =false;
        //Set the Modal Title
        objParent.objParameters.strModalTitle = 'Request Signoff'  
        //Set the email template name from label
        objParent.strEmailTemplateName=objParent.label.CSM_Objective_Request_Signoff;

         //Set content of the text
         objParent.getProcessedEmailTemplateBody();
    }
    
    /*
    Method Name : handleSignOnBehalf
    Description : This method execute on click of Sign on Behalf
    Parameters	 : Object, objEvent Select event.
    Return Type : None
    */
    handleSignOnBehalf(objEvent){
        let objParent = this;
        objParent.loadContactRecords();
        objParent.boolDisplayObjtivesTable =false;
        objParent.boolDisplayPlanCommentModal =false;
        objParent.boolDisplaySignOnBehalfScreenOne = true;
        //Set the email template name from label
        objParent.strEmailTemplateName=objParent.label.CSM_Objective_Signon_Behalf;
        //Set the Modal Title
        objParent.objParameters.strModalTitle = 'Sign On Behalf'
         //Process dynamic button visibility logic
         objParent.objParameters.lstButtons.forEach(objButton => {
            if(objButton.keyValue ==='1'){
                //Cancel button should visible always
                objButton.showButton=true;
            }else{
                objButton.showButton=false;
            }
        }); 
    }

    /*
    Method Name : handleSignOnBehalfScreenOne
    Description : This method execute on click of next of screen one
    Parameters	: Object, objEvent Select event.
    Return Type : None
    */
    handleSignOnBehalfScreenOne(objEvent){
        let objParent = this;
        objParent.boolDisplayObjtivesTable =false;
        objParent.boolDisplayPlanCommentModal =false;
        objParent.boolDisplaySignOnBehalfScreenOne = false;    

        //Set content of the text
        objParent.getProcessedEmailTemplateBody();

        //Process dynamic button visibility logic   
        objParent.objParameters.lstButtons.forEach(objButton => {
			if(objUtilities.isNotNull(objParent.selectedRecords) && 
             objParent.selectedRecords.length>0 && (objButton.keyValue === '6') ){
                objButton.showButton=true;
            }else if(objButton.keyValue !=='1'){
                //Cancel button should visible always
                objButton.showButton=false;
            }
		}); 
    }

    /*
    Method Name : selectContactRecords
    Description : This method selects records from the table.
    Parameters	: Object, called from selectRecords, objEvent Select event.
    Return Type : None
    */
    selectContactRecords(objEvent) {
        let objParent = this;
        let selectedRecords = objEvent.detail.selectedRows; 
        objParent.lstContactRecords = selectedRecords;
        if(objUtilities.isNotNull(selectedRecords) && selectedRecords.length>1){
            //Show success toast to user
            objUtilities.showToast(objParent.label.Error,'Should not select more than one record','error',objParent);  
        }else{              
            selectedRecords.forEach(objConRecord => {       
                objParent.strContactValue=objConRecord.Contact__c;
                return;
            });
        } 
        //Process dynamic button visibility logic
        objParent.objParameters.lstButtons.forEach(objButton => {
            if(objUtilities.isNotNull(selectedRecords) && 
            selectedRecords.length==1 && (objButton.keyValue === '5') ){
                objButton.showButton=true;
            }else if(objButton.keyValue !=='1'){
                //Cancel button should visible always
                objButton.showButton=false;
            }
        });   
    }
    /*
    Method Name : selectRecords
    Description : This method selects records from the table.
    Parameters	 : Object, called from selectRecords, objEvent Select event.
    Return Type : None
    */
   selectRecords(objEvent) {
       let objParent = this;
       objParent.selectedRecords = objEvent.detail.selectedRows;      
        objParent.objParameters.lstButtons.forEach(objButton => {
            if(objUtilities.isNotNull(objParent.selectedRecords) && 
            objParent.selectedRecords.length>0 && (objButton.keyValue === '2' || objButton.keyValue === '3') ){
                objButton.showButton=true;
            }else if(objButton.keyValue !=='1'){
                objButton.showButton=false;
            }
        });
   }
   
    /*
    Method Name : getProcessedEmailTemplateBody
    Description : This method will be called to prepoulate the text of email template to body of rich tex
    Parameters	: None
    Return Type : None
    */
   getProcessedEmailTemplateBody() {
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        fetchMergedQuickText({  
            strPlanId: objParent.recordId,  
            strEmailTeamplateName: objParent.strEmailTemplateName
        }).then(objResult => {
            if(objUtilities.isNotNull(objResult)){
                let strTeamplateBody=objResult;               
                //Set the Plan name dynamically in the body of tempate
                if(strTeamplateBody.includes('#PlanName#')){
                    strTeamplateBody = strTeamplateBody.replace('#PlanName#', objUtilities.isNotNull(objParent.strPlanName)?objParent.strPlanName:'');
                }
                //Set Contact name 
                if(strTeamplateBody.includes('#ContactName#')){
                    //Set the selected contact name in the body
                    let strcontactName='';
                    if(objUtilities.isNotNull(objParent.lstContactRecords) && objParent.lstContactRecords.length>0 && objUtilities.isNotNull(objParent.strContactValue)){
                        objParent.lstContactRecords.forEach(objRecord => {
                                if(objRecord.Contact__c === objParent.strContactValue){
                                    strcontactName=objRecord.Contact_Name__c;
                                }
                            }); 
                    } 
                    strTeamplateBody = strTeamplateBody.replace('#ContactName#', strcontactName);
                }

                //set objective list to the body
                if(objUtilities.isNotNull(objParent.selectedRecords) && objParent.selectedRecords.length>0){
                    let strObjectiveList='<ul>';
                    objParent.selectedRecords.forEach(objRecord => {
                        strObjectiveList+='<li>'+objRecord.Name+'</li>';
                    }); 
                    strObjectiveList+='</ul>';
                    if(strTeamplateBody.includes('#ObjectivesList#')){
                        strTeamplateBody = strTeamplateBody.replace('#ObjectivesList#', strObjectiveList);
                    }
                }                
                objParent.objParameters.richTextBody.fieldValue=strTeamplateBody;
                objParent.boolDisplayPlanCommentModal=true;
            }
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
    }

     /*
    Method Name : savePlanComment
    Description : This method will create plan comment when send for sign off 
    Parameters	: None
    Return Type : None
    */
    savePlanComment(){
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        //Create plan comment on success
        createObJectivePlanComment({ 
            planRecordId: objParent.recordId , 
            commentBody: objParent.objParameters.richTextBody.fieldValue,
            strContactId: objParent.strContactValue,
            lstSelectedObjectives : objParent.selectedRecords
        })
        .then((result) => {
            objParent.boolDisplayPlanCommentModal=false;
            objParent.boolDisplaySignOnBehalfScreenOne=false;
            objParent.boolDisplayObjtivesTable=false;
            //Show success toast to user
            objUtilities.showToast(objParent.label.Success,'Successfully posted the comment in plan comment channel','success',objParent);                
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;            
        });
    }
}