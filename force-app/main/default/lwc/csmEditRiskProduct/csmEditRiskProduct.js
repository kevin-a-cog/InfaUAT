/* Name		    :	CsmEditRiskProduct
* Author		:	Deva M
* Created Date	: 	6/19/2021
* Description	:	Risk Product Edit/Create page LWC.

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description						Tag
**********************************************************************************************************
Deva M              19-01-2022     	AR-1751        
*/
//Core Imports
import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Imports
import getRecords from '@salesforce/apex/CsmEditRiskProductController.getRecords';
//import lookupSearch from "@salesforce/apex/CsmEditRiskProductController.lookupSearch";
import saveRiskProduct from "@salesforce/apex/CsmEditRiskProductController.saveRiskProduct";
import getOpportunityRecords from "@salesforce/apex/CsmEditRiskProductController.getOpportunityRecords";
//import createRiskCommentFromPAF from "@salesforce/apex/CSMPlanCommsInternalCommentHelper.createRiskCommentFromPAF";

//Import Labels
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';
import Loading from '@salesforce/label/c.Loading';

export default class CsmEditRiskProduct extends NavigationMixin(LightningElement)  {
    //Public variables
    @api recordId;
    @api riskProductId;
    @api fromCreateRiskProduct;
    @api boolFromPAF;  

    //Private Variables
    boolDisplaySpinner;
    boolSaveProductAndNew;  
    initialSelection = [
    ];
     //Labels.
	label = {
        Success,
        Error,
        Loading
    }
    @track objConfiguration={
        lstButtons:[
            {
                keyValue:"1",
                label:'Save & Close',
                variant:'brand',
                title:'Save & Close',
                styleClass:'slds-m-horizontal_x-small',
                name:'save_risk_product',
                showButton: false
            }, {
                keyValue:"2",
                label:'Save & Add New',
                variant:'brand',
                title:'Save & Add New',
                styleClass:'slds-m-horizontal_x-small',
                name:'save_and_new',
                showButton: false
            },
            {
                keyValue: "4",
                label: "Cancel",
                variant: 'Neutral',
                title: "Cancel",
                styleClass: 'slds-m-horizontal_x-small slds-float_left',
                name: 'cancel',
				showButton: false,
            }
        ],
       planProducts:{     
           fieldId:"123",
        fieldApi:"Plan_Product_Alias__c",
        fieldLabel:"Product",
        fieldPlaceHolder:"Select Product",
        showField:true,
        fieldValue:"",
        options:[]
       },
        renewalProbability:{
            fieldId:"456",
            fieldApi:"Renewal_Probability__c",
            fieldLabel:"Renewal Probability",
            fieldPlaceHolder: "Select Probability",
            showField:false,
            fieldValue:"",
            options:[{
                        label: '0%',
                        value: '0%',
                        class: '0%',
                        variant: ''
                    },
                    {
                        label: '25%',
                        value: '25%',
                        class: '25%',
                        variant: ''
                    },
                    {
                        label: '50%',
                        value: '50%',
                        class: '50%',
                        variant: ''
                    },
                    {
                        label: '75%',
                        value: '75%',
                        class: '75%',
                        variant: ''
                    },
                    {
                        label: '100%',
                        value: '100%',
                        class: '100%',
                        variant: ''
                    }]
        },
        opportunity:{
            fieldId:"8910",
            fieldApi:"Opportunity__c",
            fieldLabel:"Opportunity",
            fieldPlaceHolder:"Select Renewal Opportunity",
            showField:false,
            fieldValue:"",
            options:[],
            disabled:false
        }
    }
    get poductClass(){
        return (this.objConfiguration.opportunity.showField === true)?"":"combox_overlay_custom";
    }
    get opportunityClass(){
        return (this.objConfiguration.renewalProbability.showField === true)?"":"combox_overlay_custom";
    }
    get showFooter(){
        let boolShowFooter=false;
         //Set Button Properties
         this.objConfiguration.lstButtons.forEach(objButton => {
            if( objButton.showButton===true){
                boolShowFooter=true;
            }
        });
        return boolShowFooter;
    }
    get modalTitle(){
        return this.fromCreateRiskProduct==true?"Add Risk Product":"Edit Risk Product";
    }
      /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
     connectedCallback(){       
        this.boolDisplaySpinner = false;
        this.boolSaveProductAndNew = false;
        this.loadRecords();
     }
      /*
	 Method Name : loadRecords
	 Description : This method gets executed on load and get product details.
	 Parameters	 : None
	 Return Type : None
	 */
     loadRecords(){
        let objParent = this;  
        objParent.boolDisplaySpinner = true
        getRecords({    
            strRiskId: objParent.recordId,
            strRiskProductId : objUtilities.isNotNull(objParent.riskProductId)?objParent.riskProductId:''
        })
        .then((ojResult) => {
            if(objUtilities.isNotNull(ojResult.lstPlanProdut) && ojResult.lstPlanProdut.length>0){                    
                ojResult.lstPlanProdut.forEach(objRecord => {

                    objParent.objConfiguration.planProducts.options = [...objParent.objConfiguration.planProducts.options ,{value: objRecord.Id , label: objRecord.Name__c} ];

                 });               
            }else{
                //Show success toast to user
                objUtilities.showToast(objParent.label.Error,'No Products available on plan','error',objParent);  
            }     
            if(objUtilities.isNotNull(ojResult.objRiskProduct)){
                //Set record Values for edit page                
                objParent.objConfiguration.planProducts.fieldValue =ojResult.objRiskProduct.Plan_Product_Alias__c;
                //retrieve Opportunity Properties
                objParent.retrieveOpportunities();

                objParent.objConfiguration.renewalProbability.fieldValue =ojResult.objRiskProduct.Renewal_Probability__c;
                objParent.objConfiguration.opportunity.fieldValue =ojResult.objRiskProduct.Opportunity__c;
                objParent.objConfiguration.renewalProbability.showField = true;
                objParent.objConfiguration.opportunity.showField = true;
                objParent.objConfiguration.planProducts.showField = true;
               
                //Set Button Properties
                objParent.objConfiguration.lstButtons.forEach(objButton => {
                    objButton.showButton=true;
                });
            }        
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });

     }

     /*
    Method Name : handleChange
    Description : This method executes on change event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
     handleChange(objEvent){
         let objParent = this;
        switch (objEvent.target.dataset.name) {  
            case '456':
               //Probability
               this.objConfiguration.renewalProbability.fieldValue =  objEvent.detail.value;
               if(objUtilities.isNotNull(objParent.objConfiguration.renewalProbability.fieldValue)){
                    objParent.objConfiguration.lstButtons.forEach(objButton => {
                        objButton.showButton=true;
                    });
               }
            break;
            case '123':
               //Risk PRoduct
               objParent.objConfiguration.planProducts.fieldValue =  objEvent.detail.value;               
               objParent.retrieveOpportunities();
            break;  
            case '8910':
                objParent.objConfiguration.opportunity.fieldValue=objEvent.detail.value;
                //Opportunity
                if(objUtilities.isNotNull(objParent.objConfiguration.opportunity.fieldValue)){
                    objParent.objConfiguration.renewalProbability.showField = true;
                }else{
                    objParent.clearRenewalProbability();
                }
            break;
            default:
            break;
        }

     }

     retrieveOpportunities(){
        let objParent = this;
        objParent.clearOpportunity();
        objParent.boolDisplaySpinner = true;
        getOpportunityRecords({strSelectedProductId : objParent.objConfiguration.planProducts.fieldValue})
        .then(ojResult => {
            let uniqueOpportunities = [];  
            if(objUtilities.isNotNull(ojResult) && ojResult.length===1){ 
                objParent.objConfiguration.opportunity.disabled=false; 
                objParent.objConfiguration.renewalProbability.showField = true;
                ojResult.forEach(objRecord => {
                    objParent.objConfiguration.opportunity.fieldValue=objRecord.Opportunity__c;
                    if(!uniqueOpportunities.includes(objRecord.Opportunity__c)){   //Filter duplicate opportunities 
                        uniqueOpportunities.push(objRecord.Opportunity__c);
                        let strSubHeading ='Type : '+objRecord.Opportunity__r.Type+' , Stage : '+objRecord.Opportunity__r.StageName;
                        objParent.objConfiguration.opportunity.options = [...objParent.objConfiguration.opportunity.options ,{value: objRecord.Opportunity__c , label: objRecord.Opportunity__r.Name,description:strSubHeading} ];
                    }
                 });    
            }else if(objUtilities.isNotNull(ojResult) && ojResult.length>1){  
                objParent.objConfiguration.opportunity.disabled=false; 
                ojResult.forEach(objRecord => {
                    if(!uniqueOpportunities.includes(objRecord.Opportunity__c)){ //Filter duplicate opportunities 
                        uniqueOpportunities.push(objRecord.Opportunity__c);
                        let strSubHeading ='Type : '+objRecord.Opportunity__r.Type+' , Stage : '+objRecord.Opportunity__r.StageName;
                        objParent.objConfiguration.opportunity.options = [...objParent.objConfiguration.opportunity.options ,{value: objRecord.Opportunity__c , label: objRecord.Opportunity__r.Name,description:strSubHeading} ];
                    }
                });               
            }else{
                objParent.objConfiguration.opportunity.disabled=true; 
                //Show success toast to user
                objUtilities.showToast(objParent.label.Error,'No Opportunities available for selected Product','error',objParent);  
            } 
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
     }

     handleClose(){
        this.dispatchEvent(new CustomEvent('close'));
        this.boolDisplaySpinner=false;
        if(objUtilities.isNotNull(this.recordId)){
            this.boolDisplaySpinner = true;
            this[NavigationMixin.Navigate]({
                type:'standard__recordPage',
                attributes:{
                    "recordId": this.recordId,
                    "objectApiName":"Risk_Issue__c",
                    "actionName": "view"
                }
            });
        }
     }


   /*  handleLookupSearch(event){
		const lookupElement = event.target;
		let objParent = this;
        var dataId = event.target.getAttribute('data-id');
		
        lookupSearch({searchTerm :event.detail.searchTerm , 
                    selectedIds : event.detail.selectedIds ,
                     strSelectedProductId : this.objConfiguration.planProducts.fieldValue,
                     strRiskId:this.recordId})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                objUtilities.processException(objError, objParent);
            });
		
	}

	handleLookupSelectionChange(objEvent){
        let objParent = this;  
        let lookupVal = objEvent.detail.values().next().value;
        objParent.objConfiguration.opportunity.fieldValue = lookupVal;
        if(objUtilities.isNotNull(lookupVal)){
            objParent.objConfiguration.renewalProbability.showField = true;
        }else{
            objParent.clearRenewalProbability();
        }		
	}*/

    clearOpportunity(){
        let objParent = this;  
        objParent.objConfiguration.opportunity.showField = true;     
        objParent.objConfiguration.opportunity.disabled = false;     
        objParent.objConfiguration.opportunity.fieldValue = null;
        objParent.objConfiguration.opportunity.options = [];
        objParent.clearRenewalProbability();
    }
    clearRenewalProbability(){
        let objParent = this;  
        objParent.objConfiguration.renewalProbability.showField = false;            	
        objParent.objConfiguration.renewalProbability.fieldValue = '';	
        objParent.objConfiguration.lstButtons.forEach(objButton => {
            objButton.showButton=false;
        });
    }

    saveRiskProduct(saveAndNew){
        let objParent = this;  
        objParent.boolDisplaySpinner = true
        saveRiskProduct({    
            strRiskId: objParent.recordId,
            strProductId:objParent.objConfiguration.planProducts.fieldValue,
            strOpportunityId:objParent.objConfiguration.opportunity.fieldValue,
            strProbability:objParent.objConfiguration.renewalProbability.fieldValue,
            strRiskProductId:objUtilities.isNotNull(objParent.riskProductId)?objParent.riskProductId:''
        })
        .then((objResult) => {
            if(objUtilities.isNotNull(objResult) && objUtilities.isNotBlank(objResult.strErrorMessage)){                    
                //Show success toast to user
                objUtilities.showToast(objParent.label.Error,objResult.strErrorMessage,'error',objParent);       
            }else{
                if(saveAndNew === true){
                    this.boolSaveProductAndNew = true;
                }else{
                    this.handleClose();
                }
                if(objUtilities.isNotNull(objResult) && objUtilities.isNotBlank(objResult.recordId)){
                   //objParent.createRiskComment(objResult.recordId);        
                }
            }   
             
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
    }
    createRiskComment(recordId){
        let objParent = this;
        objParent.boolDisplaySpinner = true
        if(objUtilities.isNotNull(objParent.boolFromPAF) && objParent.boolFromPAF){
            createRiskCommentFromPAF({    
                strRiskRecordId: objParent.recordId,
                strRiskProductId: recordId,
            })
            .then((result) => {
            })
            .catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                //Finally, we hide the spinner.
                objParent.boolDisplaySpinner = false;
            });
        }
    }
    /*
    Method Name : handleClick
    Description : This method executes on click event
    Parameters	: objEvent onclick event.
    Return Type : None
    */
    handleClick(objEvent) {
        switch (objEvent.target.dataset.name) {  
            case 'save_risk_product':
              this.saveRiskProduct(false);
            break;
            case 'save_and_new':
                this.initialSelection=[];
                this.saveRiskProduct(true);
            break;   
            case 'cancel':
               this.handleClose();
            break;  
            default:
            break;
        }
    }
     
}