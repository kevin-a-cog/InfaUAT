import { LightningElement, wire, track, api } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import { truncateText } from 'c/utils';
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';
import getSupportAccountInfo from '@salesforce/apex/ManageAlltheCase.getSupportAccountInfo';


export default class EsCaseList extends LightningElement {

    caseBanner = ESUPPORT_RESOURCE + '/case.png';
    liveAgent = ESUPPORT_RESOURCE + '/live_agent.png';
    searchKb = ESUPPORT_RESOURCE + '/search_kb.png';
    postQuestions = ESUPPORT_RESOURCE + '/post_questions.png';
    @track showSpinner = true;
    @api caseDetails;
    areDetailsAvailableOpenCase = false;
    areDetailsAvailableAllCase = false; 
    areDetailsAvailableCloseCase=false;
    principal = 200000;
    @track disableSearch=false;
    term = 30;
    data;
    rate = 4;
    @track openCases=[];
    @track allOpenCases=[];
    @track allClosedCases=[];
    monthlyPayment = '';
    sortDirection = 'asc';
    //configura the field name with api name (this is used in Download as CSV - functionality)
    @track caseData=[];
      mapFieldVal=new Map([["Priority","Priority"],["Status","Status"],["Forecast_Product__c","Product"],
      ["Subject","Subject Session Title"],["CaseNumber","CaseNumber"],["Next_Action__c","Next Action"]]);
       
      //pass the column names
    COL_CONTACTS=[
       
          {  
            label: "Case Number",  
            fieldName: "recordLink",  
            type: "url",  sortable: true,
            typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"CaseNumber", target: "_parent" }  
           },  
         
        {label:"Priority", fieldName: "Priority",type: "text",sortable: true},
        {label:"Status", fieldName: "Status",type: "text",sortable: true},
        {label:"Support Account", fieldName: "Support_Account",type: "text",sortable: true},
        {label:"Product", fieldName: "Forecast_Product__c",type: "text",sortable: true},
        {label:"Subject/Session Title", fieldName: "Subject",type: "text",sortable: true},
        {label:"Next Action", fieldName: "NextAction__c",type: "text",sortable: true}
        ];
        
    connectedCallback(){    
        var tempOppList = [];  
        var tempOppAllList = [];
        var tempOppAllClosedList = [];
            var url = CommunityURL + 'casedetails?caseId=';  
        getSupportAccountInfo()
        .then(result => {
           // alert(result.allClosedCases+'= ok==');
            //this.openCases=result.myOpenCases;
            for (var i = 0; i < result.myOpenCases.length; i++) { 
                this.areDetailsAvailableOpenCase=true; 
                let tempRecord = Object.assign({}, result.myOpenCases[i]); //cloning object 
                //alert(JSON.stringify(tempRecord.Support_Account__r.Name)); 
                tempRecord.recordLink = url+ tempRecord.Id; 
                tempRecord.Support_Account= tempRecord.Support_Account__r.Name;
                tempOppList.push(tempRecord);  
            } 
            this.openCases=tempOppList;
            for (var i = 0; i < result.allOpenCases.length; i++) { 
                this.areDetailsAvailableAllCase=true; 
                let tempRecord = Object.assign({}, result.allOpenCases[i]); //cloning object  
                tempRecord.recordLink = url+ tempRecord.Id;  
                tempRecord.Support_Account= tempRecord.Support_Account__r.Name;
                tempOppAllList.push(tempRecord);  
            } 
            this.allOpenCases=tempOppAllList;
            for (var i = 0; i < result.allClosedCases.length; i++) { 
                this.areDetailsAvailableCloseCase=true; 
                let tempRecord = Object.assign({}, result.allClosedCases[i]); //cloning object  
                tempRecord.recordLink = url+ tempRecord.Id;  
                tempRecord.Support_Account= tempRecord.Support_Account__r.Name;
                tempOppAllClosedList.push(tempRecord);  
            } 
            this.allOpenCases=tempOppAllList;
            this.allClosedCases=tempOppAllClosedList;
            this.showSpinner = false;
           // this.allOpenCases=result.allOpenCases;
            
        });
    }
    // text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    // truncatedValue = '';
    // truncatedValue = truncateText(this.text);

     

     

}