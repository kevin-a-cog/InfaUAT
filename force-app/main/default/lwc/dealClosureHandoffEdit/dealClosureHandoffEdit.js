/*
 * Name			:	DealClosureHandoffEdit
 * Author		:	
 * Created Date	: 	
 * Description	:	

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Anusha Akella          11/23/2022		AR-3036         add the child component for Risk Assessment Form & changes <T01>	
 Anusha Akella          11/23/2022		AR-3037         One Opportunity should have one Engagement form & Navigate to engagement rec in handoff stage <T02>		
 Narpavi Prabu          03/22/2022      AR-3144         DGTT Mandate Readiness Assessment if Opty total is more then $100,000  <T03>										
 */
 import { LightningElement,track ,api,wire} from 'lwc';
 import { getRecord } from 'lightning/uiRecordApi';
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 import { getRecordNotifyChange } from 'lightning/uiRecordApi';
 import fetchOppotunityRecord from '@salesforce/apex/DealClosureHandoffController.fetchOppotunityRecord'; 
 //import postChatterFeed from '@salesforce/apex/DealClosureHandoffController.postChatterFeed';
 import insertRecord from '@salesforce/apex/RiskAssessmentController.saveRecords';
 import dataGovESLlines from '@salesforce/apex/RiskAssessmentController.getEstimatorRec';
 import uploadFile from '@salesforce/apex/DealClosureHandoffController.uploadFile';
 
 import ENGAGEMENT_OBJECT from '@salesforce/schema/Engagement__c';
 import { CloseActionScreenEvent } from 'lightning/actions';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import modalWidthcss from "@salesforce/resourceUrl/modalWidth";
 import { loadStyle } from "lightning/platformResourceLoader";
 import { NavigationMixin } from 'lightning/navigation';
 import { refreshApex } from '@salesforce/apex';

 const MAX_FILE_SIZE = 4194304;
 
 
  const FIELDS = ['Engagement__c.Engagement_Journey__c','Engagement__c.Primary_IPU_Estimator_ID__c','Engagement__c.Status__c','Engagement__c.Opportunity__c'];
 export default class DealClosureHandoffEdit extends NavigationMixin(LightningElement) {
 
 
     @api recordId;
     @track engReordTypeId;
     @track filesData = [];
     @track currentOpp = {};
 
     oppName = '';
     showSpinner = false;
     //<T01>
     currectJourneyValue = '';
     pafData;
     primaryEstimator;
     currentStatus;
     DGlineExist;
     currentEng=null;
     displayChildComp = true;
     loadchildComp = false;
     estimatorId = null;
      oppid;
      stopEditing;
      checkdata;
      opptycheck = false;
      IPUcheck=false;
      optyvaluelesscheck = false;
      dealClosure = false;
      dealClosurePickList = 'Subscription Adoption';
 
     connectedCallback(){
         loadStyle(this, modalWidthcss);  
     }
 
     @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     wiredRecord({ error, data }) {
         if (error) {
             let message = 'Unknown error';
             if (Array.isArray(error.body)) {
                 message = error.body.map(e => e.message).join(', ');
             } else if (typeof error.body.message === 'string') {
                 message = error.body.message;
             }
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error loading contact',
                     message,
                     variant: 'error',
                 }),
             );
         } else if (data) {
             console.log('this.recordid123 -----',this.recordId);
             this.currentEng = data;
             this.currectJourneyValue = this.currentEng.fields.Engagement_Journey__c.value;
             this.primaryEstimator = this.currentEng.fields.Primary_IPU_Estimator_ID__c.value;
             this.currentStatus = this.currentEng.fields.Status__c.value;
              this.oppid = this.currentEng.fields.Opportunity__c.value;
             console.log('this.currectJourneyValue ',this.currectJourneyValue);
             
             //<T02>
             if(this.currentStatus !== 'Information Gathering'){
                 console.log('Enterimg Navigation Mix');
                 this[NavigationMixin.Navigate]({
                     type: 'standard__recordPage',
                     attributes: {
                         recordId: this.recordId,
                         actionName: 'view'
                     }
                 });
                 return refreshApex(this.currentEng);
             } 
             
 
              dataGovESLlines({ primartEstimatorId:this.primaryEstimator, oppId:this.oppid })
             .then((result) => {
                 console.log('result output dealclosure',JSON.stringify(result));
                 this.DGlineExist = result;
 
             if((!this.currectJourneyValue || this.currectJourneyValue == '') && !this.DGlineExist) {
                 this.displayChildComp = false;
             } else {
                 this.displayChildComp = true;
                 this.IPUcheck = true;
             }
              }).catch((error) => {
                  console.log('error', 'Method : loadStyle - loadStyle; Error :' + error.message + " : " + error.stack);
      
              })
              
              //<T03>
              fetchOppotunityRecord({ oppId:this.oppid })
              .then((result) => {
                 this.currentOpp = result;
                     
                    if(this.currentOpp.CurrencyIsoCode !="USD")
                    {
                       this.currentOpp.ConvertedTotalOARR = ` ${Number.parseFloat(this.currentOpp.ConvertedTotalOARR)}`;
                       this.currentOpp.ConvertedARR = ` ${Number.parseFloat(this.currentOpp.ConvertedARR)}`;
                    }else{
                       this.currentOpp.ConvertedTotalOARR = this.currentOpp.Total_OARR__c;
                       this.currentOpp.ConvertedARR = this.currentOpp.ARR__c;
                    }
                    
                    if(this.currentOpp.RecordType.DeveloperName == 'New_Sales_Opportunity' && this.currentOpp.Type=='Direct')
                    {
                        if(this.currentOpp.ConvertedARR  > 100000)
                        {
                            this.opptycheck=true;

                        }else if(this.currentOpp.ConvertedARR < 100000)
                        {
                            this.optyvaluelesscheck = true;
                        }
                    }
                    else if(this.currentOpp.RecordType.DeveloperName == 'Renewal_Opportunity' && this.currentOpp.Type=='Renewal' )
                    {
                        if(this.currentOpp.ConvertedTotalOARR  > 100000)
                        {
                            this.opptycheck=true;
                        }else if(this.currentOpp.ConvertedTotalOARR < 100000)
                        {
                            this.optyvaluelesscheck = true;
                        }
                    }
                 
               }).catch((error) => {
                   console.log('error'+ error.message );
       
               })
              //</T03> 
              //on load check for childs
              /* if((!this.currectJourneyValue || this.currectJourneyValue == '') && !this.DGlineExist) {
                  this.displayChildComp = false;
              } else {
                  this.displayChildComp = true;
              } */
             
         }
 
     }
 
  
     get bShowSource_and_Target_Connectors(){
         return this.currectJourneyValue == 'DW, L & App Modernization' ? true : false;
     }
 
     get bShowData_Volume_processing_needs(){
         return (this.currectJourneyValue == 'DW, L & App Modernization' || this.currectJourneyValue == 'Business 360' || this.currectJourneyValue == 'Data Governance and Privacy')  ? true : false;
     }
 
     get bShowIPU_calculator(){
         return this.currectJourneyValue == 'DW, L & App Modernization' ? true : false;
     }
 
     get bShowScanners_needed(){
         return this.currectJourneyValue == 'Data Governance and Privacy' ? true : false;
     }
 
 
 
     @wire(getObjectInfo, { objectApiName: ENGAGEMENT_OBJECT })
     objectInfo({error, data}) {
         if (error) {
             console.log('Error while fetch object data');
         } else if (data) {
             let objectData = JSON.parse(JSON.stringify(data));
             var dchRtTd; 
             for (const key in objectData.recordTypeInfos) {
                 if (objectData.recordTypeInfos.hasOwnProperty(key)) {
                    var eachRT = objectData.recordTypeInfos[key];
                    console.log('all data ====> ' + JSON.stringify(eachRT));
                    if(eachRT.name == 'Subscription Adoption'){
                     dchRtTd = key;
                     this.dealClosure = true;   
                     break;
                    }
                 }
             }
             console.log('Deal Closure Handoff Id = : ' + dchRtTd);
             this.engReordTypeId =  dchRtTd;            
         }
     }
 
     onjourneychange(event){     
         this.loadchildComp = !this.loadchildComp
         this.displayChildComp = true;
         this.journeychangeHelper(event.detail.value);
     }
 
     journeychangeHelper(value){
         console.log('value change',value);
         this.currectJourneyValue = value;
     }
 
    /* @wire(fetchOppotunityRecord, {'oppId' : '$recordId'})
     lstOpp ({error, data}) {
         if (error) {
             console.log('Error while fetch opportunity record');
         } else if (data) {
             this.currentOpp = JSON.parse(JSON.stringify(data));
             this.oppName = data.Name + ' ' + data.New_Org_Opportunity_Number__c; 
             console.log('recordId===> ' + this.recordId);
             console.log('this.currentOpp===> ' + JSON.stringify(this.currentOpp));
             this.decisionMakerValue = this.currentOpp.Economic_Buyer__c + ';' + this.currentOpp.Champion__c;
         }
     }*/
 
 
 
     onSubmitFormHandler(event){
         this.showSpinner = true;
         event.preventDefault();       // stop the form from submitting
         const fields = event.detail.fields;
         
         //fields.Status__c = 'New';
         //fields.RecordTypeId = this.engReordTypeId;
         console.log('data before submitting===> ' + JSON.stringify(fields));
         // send chatter notification to CSM and CSO group if cEngage with csm checkbox is checked 
         /*if(fields.Engage_with_CSM__c){
         } */
        // console.log('fields.Engage_with_CSM__c===> ' + fields.Engage_with_CSM__c);
        // fields.Engage_with_CSM__c = fields.Engage_with_CSM__c == true ? true : false;
 
 
        var bAllFieldFilled = false;      
        if(this.isBlankHelper(fields.Name) && this.isBlankHelper(fields.Engagement_Journey__c) &&  this.isBlankHelper(fields.Business_Problem_s__c) && this.isBlankHelper(fields.Implementation_milestones_go_live_plan__c) && this.isBlankHelper(fields.Decision_Maker__c) && this.isBlankHelper(fields.Partners_Involved_How__c) ){
             //bAllFieldFilled = true; 
            if(fields.Engagement_Journey__c == 'DW, L & App Modernization'){
                if(this.isBlankHelper(fields.Source_and_Target_Connectors__c) && this.isBlankHelper(fields.Data_Volume_processing_needs__c) ){
                    bAllFieldFilled = true;
                }else{
                    bAllFieldFilled = false;
                }
            }
            else if(fields.Engagement_Journey__c == 'Business 360'){
                if(this.isBlankHelper(fields.Data_Volume_processing_needs__c)){
                    bAllFieldFilled = true;
                }else{
                    bAllFieldFilled = false;
                }
            }
            else if(fields.Engagement_Journey__c == 'Data Governance and Privacy'){
                if(this.isBlankHelper(fields.Data_Volume_processing_needs__c) && this.isBlankHelper(fields.Scanners_needed__c) ){
                    bAllFieldFilled = true;
                    //<T03>
                    if(!this.checkdata &&  this.opptycheck){
                        this.opptycheck = false;
                        }
                        if(this.optyvaluelesscheck && this.checkdata)
                        {
                            this.checkdata = false;
                        }
                    //</T03>
                }else{
                    bAllFieldFilled = false;
                }
            }             
        }
 
        console.log('bAllFieldFilled===> ' + bAllFieldFilled);
       // fields.Status__c = 'Information Gathering';
      		
         if(bAllFieldFilled && !this.checkdata && !this.opptycheck){
              fields.Status__c = 'Handoff Initiated';
        }else{
         fields.Status__c = 'Information Gathering';
         
        }
 
 
         this.template.querySelector('lightning-record-edit-form').submit(fields);     
     }
 
 
     isBlankHelper(sVal){
         var isValid = false;
         if(sVal != null && sVal.trim() != '' && sVal != undefined){
             isValid = true;
         }
         return isValid;
     }
 
     onvalueHandler(event) {
         this.changeHelper(event.detail.value);
     }
 
     onsubmitsuccess(event){
         this.showNotification('Success!', 'Engagement Record has been updated successfully' , 'success');  
         
 
         var newEngRecId = event.detail.id;
           console.log('newEngRecId---> ' + newEngRecId);
 
           getRecordNotifyChange([{ recordId: this.recordId }]);
 
           //AA Changes
         if(this.pafData){
             this.pafInsert(this.pafData,newEngRecId,false);
         }
          
        /*   postChatterFeed({engagementId :newEngRecId})
           .then(results => {
               console.log('Chatter post has been created.' + '-->'  + JSON.stringify(results));
              
           })
           .catch(error => {
               console.log('error- postChatterFeed-> ' + JSON.stringify(error));
        });  */

         //<T03>
         uploadFile({recordId :newEngRecId,filedata : JSON.stringify(this.filesData)})
         .then(result => {
             console.log(result);
             if(result && result == 'success') {
                 this.filesData = [];
                 console.log('Success File Upload');
             } 
         }).catch(error => {             
                 console.log('Error File Upload', error.body.message);
         })      
        //</T03>

        if(!this.pafData){
            this.dispatchEvent(new CloseActionScreenEvent()); 
            //this.doCancel();
            setTimeout(function() {window.location.reload();}, 1000);
         }
 
        this.showSpinner = false;
 
        
     } 
 
     onsubmiterror(event){
         alert(JSON.stringify(event));
         this.showSpinner = false;
     }
 
     /*
      Method Name : pafInsert
      Description : This method gets executed in the success method to insert/Update Risk Assess Record.
      Parameters	 : jsonstring, parid, isnew.
      Return Type : None <T01>
      */
     pafInsert(jsonstring, parid, isnew) {
         insertRecord({
             JSONString: jsonstring,
             parentId: parid,
             isNewRec: isnew
             }).then(() => {
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Success',
                         message: 'Readiness Assessment Record is saved',
                         variant: 'success'
                     })
                 );
                 this.dispatchEvent(new CloseActionScreenEvent()); 
                 this.doCancel();
             }) .catch((error) => {
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error updating or refreshing records',
                         message: error.body.message,
                         variant: 'error'
                     })
                 );
             });
     }
 
     showNotification(stitle,msg,type) {
         const evt = new ShowToastEvent({
             title: stitle,
             message: msg,
             variant: type
         });
         this.dispatchEvent(evt);
     }
 
     onPafSubmitEvent(event) {
         var submitBtn = this.template.querySelector('.submitpaf');
          
          this.pafData = event.detail.payloadData;
          this.checkdata = event.detail.checkdata;
          submitBtn.click();
     }
 
     doCancel(){
         const closeEvent = new CustomEvent('cancel', {});
         this.dispatchEvent(closeEvent);
     }
 
     //<T01>
     displayComp(event) {
 
         if(!event.detail && !this.DGlineExist) {
              this.displayChildComp = false;
          } else {
             this.displayChildComp = true;
         }
     }
     
       // handle file change
     //<T03>
    handleFileChange(event) {
        if (event.target.files.length > 0) {
            this.uploadedFile = event.target.files[0];
            if (this.uploadedFile.size > MAX_FILE_SIZE) {
                let message = 'File size cannot exceed 4 MB';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
                return;
            }
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
    }

    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }
    //</T03>
 
 }