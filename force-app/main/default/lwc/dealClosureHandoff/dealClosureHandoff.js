/*
 * Name			:	DealClosureHandoff
 * Author		:	
 * Created Date	: 	
 * Description	:	

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Anusha Akella          11/23/2022		AR-3036         add the child component for Risk Assessment Form & changes <T01>	
 Anusha Akella          11/23/2022		AR-3037         One Opportunity should have one Engagement form <T02>	
 Narpavi Prabu          03/22/2022      AR-3144         DGTT Mandate Readiness Assessment if Opty total is more then $100,000  <T03>											
 */
 import { LightningElement,track ,api,wire} from 'lwc';
 import { getRecord } from 'lightning/uiRecordApi';
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 import fetchOppotunityRecord from '@salesforce/apex/DealClosureHandoffController.fetchOppotunityRecord';
 import postChatterFeed from '@salesforce/apex/DealClosureHandoffController.postChatterFeed';
 import getselectOptions from '@salesforce/apex/DealClosureHandoffController.getselectOptions';
 import fetchExistingSubAdopRecords from '@salesforce/apex/DealClosureHandoffController.fetchExistingSubAdopRecords';
 import fetchExistingSubAdopRecordswithoutsharing from '@salesforce/apex/DealClosureHandoffController.fetchExistingSubAdopRecordswithoutsharing';
 import inserteng from '@salesforce/apex/DealClosureHandoffController.inserteng';
 import insertRecord from '@salesforce/apex/RiskAssessmentController.saveRecords';
 import dataGovESLlines from '@salesforce/apex/RiskAssessmentController.getEstimatorRec';
 import uploadFile from '@salesforce/apex/DealClosureHandoffController.uploadFile';
 
 
 import ENGAGEMENT_OBJECT from '@salesforce/schema/Engagement__c';
 import { CloseActionScreenEvent } from 'lightning/actions';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { NavigationMixin } from 'lightning/navigation';
 import modalWidthcss from "@salesforce/resourceUrl/modalWidth";
 import { loadStyle } from "lightning/platformResourceLoader";
 const MAX_FILE_SIZE = 4194304;
 
 export default class DealClosureHandoff extends NavigationMixin(LightningElement) {
     @api recordId;
     @track engReordTypeId;
     @track currentOpp = {};
     @track decisionMakerValue = '';
     @track filesData = [];
     EngagewithCSMVal = true;
     oppName = '';
     showSpinner = false;
     currectJourneyValue = '';
     bNewRecord = true;
     navigationrecord= true;
     sEditEngId = '';
     //<T01>	
     pafData;
     utilityEdit= false;
     displayChildComp = true;
      DGlineExist;
      checkdata;

      opptycheck = false;
      IPUcheck= false;
      uploadedFile;
      optyvaluelesscheck = false;
      dealClosure = false;
      dealClosurePickList = 'Subscription Adoption';
     

     //parentid = '';
 
 
 
     connectedCallback(){
         loadStyle(this, modalWidthcss);
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
             console.log('objectData',JSON.stringify(objectData));
             var dchRtTd; 
             //<T01>
             
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
 
             this.engReordTypeId =  dchRtTd;            
         }
     }
 
   /*  connectedCallback(){
         this.fetchsubadoprec();
     }*/
 
 
     /*fetchsubadoprec(){
         console.log('opp record ID >>> ' + this.recordId);
         fetchExistingSubAdopRecordswithoutsharing({oppId2 : this.recordId})
             .then(results => {
     
             console.log('fetchExistingSubAdopRecords----> ||' + results + '||');
           console.log('fetchExistingSubAdopRecords--JSON --> ||' + JSON.stringify(results) + '||' + 'Id== ' + results.Id);
           console.log('fectch record '+ this.recordId);
           
            
           if(results.Id != undefined){
  
             if(results.Status__c == 'Information Gathering'){
               // edit mode 
               this.sEditEngId = results.Id;
               this.bNewRecord = false;
 
             }else{
                 // navigate to engagement record.
                 var engegementRef = {
                     type: 'standard__recordPage',
                     attributes: {
                         recordId: results.Id,
                         objectApiName: 'Engagement__c',
                         actionName: 'view'
                     }
                     };
                    this[NavigationMixin.Navigate](engegementRef); 
 
             }                  
         }
         }).catch(error => {
             console.log('error- fetchPicklistMap-> ' + JSON.stringify(error));
      });
     }*/
 
 
    @wire(fetchExistingSubAdopRecords, {'oppId' : '$recordId'})
     lstExistingRec ({error, data}) {
         if (error) {
             console.log('Error while fetch fetchExistingSubAdopRecords ' , error); 
         } else if (data) {
             console.log('fetchExistingSubAdopRecords----> ||' + data + '||');
           console.log('fetchExistingSubAdopRecords--JSON --> ||' + JSON.stringify(data) + '||' + 'Id== ' + data.Id);
           //<T02>	
           if(data.Id != undefined){
             if(data.Status__c == 'Information Gathering' || data.Status__c == 'Handoff Initiated' || data.Status__c == 'Handoff In-Progress' || data.Status__c == 'Handoff Completed'){
 
               // edit mode 
               this.sEditEngId = data.Id;
               this.bNewRecord = false;
 
             }                
         }
         }
     }
 
     
     @wire(fetchOppotunityRecord, {'oppId' : '$recordId'})
     lstOpp ({error, data}) {
         if (error) {
         } else if (data) {
             
             this.currentOpp = JSON.parse(JSON.stringify(data));
             this.currectJourneyValue = this.currentOpp.Sales_Journey__c;
              if(this.currectJourneyValue === undefined) {
                 this.currectJourneyValue = null;
              }
              this.oppid = this.currentOpp.Primary_IPU_Estimator__c;
              console.log('this.currectJourneyValue new Opp',this.currectJourneyValue );

          /*  //<T03>
              if(this.currentOpp.CurrencyIsoCode !="USD"){
                this.currentOpp.ConvertedTotalOARR = ` ${Number.parseFloat(this.currentOpp.ConvertedTotalOARR)}`;
                this.currentOpp.ConvertedARR = ` ${Number.parseFloat(this.currentOpp.ConvertedARR)}`;
              }else{
                this.currentOpp.ConvertedTotalOARR = this.currentOpp.Total_OARR__c;
                this.currentOpp.ConvertedARR = this.currentOpp.ARR__c;
              }
             //</T03> 
               
              console.log('Currency Value ConvertedTotalOARR'+ this.currentOpp.ConvertedTotalOARR);
              console.log('Currency Value ConvertedARR'+ this.currentOpp.ConvertedARR);*/
 
              dataGovESLlines({ primartEstimatorId:null, oppId:this.recordId})
              .then((result) => {
                  console.log('result output dealclosure',JSON.stringify(result));
                  this.DGlineExist = result;
 
                  if((!this.currectJourneyValue || this.currectJourneyValue == '' || this.currectJourneyValue === null) && !this.DGlineExist) {
                     
                 this.displayChildComp = false;
             } else {
                 this.displayChildComp = true;
                 this.IPUcheck = true;
             }
                  
              }).catch((error) => {
                  console.log('error', 'Method : loadStyle - loadStyle; Error :' + error.message + " : " + error.stack);
      
              })
 
             var opp = data.Name + ' ' + data.New_Org_Opportunity_Number__c; 
             var length = 80;
             this.oppName = opp.length > length ? 
                                 opp.substring(0, length) : 
                                 opp;
             console.log('recordId===> ' + this.recordId);
             console.log('this.currentOpp===> ' + JSON.stringify(this.currentOpp));
             
             this.decisionMakerValue = 'Economic Buyer: ' + this.currentOpp.Economic_Buyer__c + ';' + '\n' + 'Champion: ' + this.currentOpp.Champion__c;
             this.fetchPicklistMap(this.currentOpp.Competitors__c);
           //<T03>  
             
                if(this.currentOpp.CurrencyIsoCode !="USD")
                 {
                    this.currentOpp.ConvertedTotalOARR = ` ${Number.parseFloat(this.currentOpp.ConvertedTotalOARR)}`;
                    this.currentOpp.ConvertedARR = ` ${Number.parseFloat(this.currentOpp.ConvertedARR)}`;
                 }else{
                    this.currentOpp.ConvertedTotalOARR = this.currentOpp.Total_OARR__c;
                    this.currentOpp.ConvertedARR = this.currentOpp.ARR__c;
                 }
                
            //</T03> 
         }
     }
 
 
     onjourneychange(event){   
         this.loadchildComp = !this.loadchildComp
         this.displayChildComp = true;
         this.journeychangeHelper(event.detail.value);
     }
 
     journeychangeHelper(value){
        this.currectJourneyValue = value;   
     }
 
 
 
     fetchPicklistMap(Competitor){
         if(Competitor != undefined){
             getselectOptions({'objObject' : null , 'fld' : 'Competitors__c'})
             .then(results => {
                 var lstCom = Competitor.split(';');
                 var sCompetitor = '';
                   for(var i=0; i < lstCom.length; i++){
                       for(var x in results){
                         if(x == lstCom[i]){
                             sCompetitor += results[x];
                             sCompetitor += ';';
                         }
                       }
                   }
 
                   sCompetitor = sCompetitor.slice(0, -1);
                   this.currentOpp.Competitors__c = sCompetitor;         
             })
             .catch(error => {
                 console.log('error- fetchPicklistMap-> ' + JSON.stringify(error));
          });
         }        
     }
 
     onSubmitFormHandler(event){
         this.showSpinner = true;
         event.preventDefault();       // stop the form from submitting
         const fields = event.detail.fields;
         fields.Status__c = 'Information Gathering';
         fields.RecordTypeId = this.engReordTypeId;
         console.log('data before submitting===> ' + JSON.stringify(fields));
         // send chatter notification to CSM and CSO group if cEngage with csm checkbox is checked 
         /*if(fields.Engage_with_CSM__c){
         } */
         console.log('fields.Engage_with_CSM__c===> ' + fields.Engage_with_CSM__c);
         fields.Engage_with_CSM__c = fields.Engage_with_CSM__c == true ? true : false;
         if(this.currentOpp !==undefined && this.currentOpp.OpportunityTeamMembers !==undefined && this.currentOpp.OpportunityTeamMembers.length>0){
             fields.Account_Manager__c = this.currentOpp.OpportunityTeamMembers[0].UserId;
         }
 
        console.log('Rcord type current opty'+this.currentOpp.RecordType.DeveloperName) ;
 
         console.log('fields===> + ' + JSON.stringify(fields));
  
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
             else if(fields.Engagement_Journey__c == 'Data Governance and Privacy')
             {
                 if(this.isBlankHelper(fields.Data_Volume_processing_needs__c) && this.isBlankHelper(fields.Scanners_needed__c) )
                {
                     bAllFieldFilled = true;
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
                        
                else if(this.currentOpp.RecordType.DeveloperName == 'Renewal_Opportunity' && this.currentOpp.Type=='Renewal')
                {
                    if(this.currentOpp.ConvertedTotalOARR  > 100000)
                    {
                        this.opptycheck=true;
                    }else if(this.currentOpp.ConvertedTotalOARR < 100000)
                    {
                        this.optyvaluelesscheck = true;
                    }
                }
                    
                 }else{
                     bAllFieldFilled = false;
                 }

                 
             }             
         }
        /* if(fields.Engagement_Journey__c == 'Data Governance and Privacy'){
             bAllFieldFilled = true;
         }*/
 
         console.log('bAllFieldFilled===> ' + bAllFieldFilled);
          console.log('checkdata 291 submit', this.checkdata);

        // fields.Status__c = 'Information Gathering';
        //<T03>
        if(!this.checkdata &&  this.opptycheck){
            this.opptycheck = false;
        }
        console.log('optyvaluelesscheck --'+this.optyvaluelesscheck);
        if(this.optyvaluelesscheck && this.checkdata)
        {
            this.checkdata = false;
        }
        //</T03>

        if(bAllFieldFilled && !this.checkdata && !this.opptycheck){
               fields.Status__c = 'Handoff Initiated';
         }else{
             fields.Status__c = 'Information Gathering';
         }
 
         console.log('fields before submit ===> + ' + JSON.stringify(fields));

    
        // this.template.querySelector('lightning-record-edit-form').submit(fields);   
        var engrecstring = JSON.stringify(fields);  
 
 
        inserteng({engrec :engrecstring})
 
        .then(results => {
 
 
            this.onsubmitsuccess(results.Id);
 
        })
 
        .catch(error => {
 
            console.log('error- postChatterFeed-> ' + JSON.stringify(error));
 
        });  
     }
 
     isBlankHelper(sVal){
         var isValid = false;
         if(sVal != null && sVal.trim() != '' && sVal != undefined){
             isValid = true;
         }
         return isValid;
     }
 
     onsubmitsuccess(newEngRecId){
         this.showNotification('Success!', 'Engagement Record has been created successfully' , 'success');  
         
         //Insert or update of Risk Assessment Record.<T01>
         if(this.pafData){
             this.pafInsert(this.pafData,newEngRecId,true);
         }
 
         //var newEngRecId = event.detail.id;
           console.log('newEngRecId---> ' + newEngRecId);
 
           postChatterFeed({engagementId :newEngRecId})
           .then(results => {
               console.log('Chatter post has been created.' + '-->'  + JSON.stringify(results));
              
           })
           .catch(error => {
               console.log('error- postChatterFeed-> ' + JSON.stringify(error));
        });  

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
 
               /* var engegementRef = {
                 type: 'standard__recordPage',
                 attributes: {
                     recordId: newEngRecId,
                     objectApiName: 'Engagement__c',
                     actionName: 'view'
                 }
         };
          this[NavigationMixin.Navigate](engegementRef); */  
          
         //window.location.href='/'+newEngRecId;
          if(!this.pafData){
             this.dispatchEvent(new CloseActionScreenEvent()); 
             //this.doCancel();
             setTimeout(function() {window.location.reload();}, 1000);
          }
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
 
                 setTimeout(function() {window.location.reload();}, 1000);
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
 
     onsubmiterror(event){
         alert(JSON.stringify(event));
         this.showSpinner = false;
     }
 
     
     showNotification(stitle,msg,type) {
         const evt = new ShowToastEvent({
             title: stitle,
             message: msg,
             variant: type
         });
         this.dispatchEvent(evt);
     }
 
     /*
      Method Name : onPafSubmitEvent
      Description : This method executes save engagement first, later insert/Update Risk Assess Record.
      Parameters	 : jsonstring, parid, isnew.
      Return Type : None
      */
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
                this.uploadedFile = event.target.files[i].size;
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