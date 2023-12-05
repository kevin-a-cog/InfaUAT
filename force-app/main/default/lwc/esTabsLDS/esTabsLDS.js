/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                           NA
 Amit                   23-Feb-2022     I2RT-5507           updated the column widths to increaase the size of         T01
                                                            case Subject in the list
                                                            */
import { LightningElement, track, api } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc'; 
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';
export default class EsTabsLDS extends LightningElement {

    Filter = ESUPPORT_RESOURCE + '/sort.svg';
    Informatica = ESUPPORT_RESOURCE + '/next_action_infa.svg';
    @track  areDetailsAvailableOpenCase = true;
    @track  areDetailsAvailableAllCase = true; 
    columns;
    @track disableSearch=false;
    @api openCases;
    @api accId;
    @track fullUrl;
    @track translatedVizUrl='https://public.tableau.com/views/Superstore-EN/Overview?:showVizHome=no&amp;:embed=true';
    @api allClosedCases;
    @api allOpenCases;
    //configura the field name with api name (this is used in Download as CSV - functionality)
    @track caseData=[];
    /* I2RT-4421*/  mapFieldVal=new Map([["Priority","Priority"],["Status","Status"],["Type","RecordTypeId"],["Forecast_Product__c","Product"],
      ["Subject","Subject Session Title"],["CaseNumber","CaseNumber"],["NextAction__c","Next Action"],["Description","Description"]]);/* I2RT-4421*/ 
       
      //pass the column names 
      //<T01> starts
    COL_CONTACTS=[
       
          {  
            label: "Case Number",  
            fieldName: "recordLink",  
            type: "url",  sortable: true,
            typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"CaseNumber", target: "_parent", initialWidth: 115 }  
           },  
        {label:"Subject/Session Title", fieldName: "Subject",type: "text",sortable: true,initialWidth: 260}, 
        {label:"Priority", fieldName: "Priority",type: "text",sortable: true,initialWidth: 50},
        {label:"Status", fieldName: "Status",type: "text",sortable: true, initialWidth: 90},
        {label:"Type", fieldName: "RecordTypeId",type: "text",sortable: true,initialWidth: 80},
        {label:"Product", fieldName: "Forecast_Product__c",type: "text",sortable: true,initialWidth: 100},         
        {label:"Next Action", fieldName: "NextAction__c",type: "text",sortable: true, initialWidth: 110, cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }},
        ];
        //<T01> ends
        get isMyCace(){
            var isMycase=false;
            if(this.openCases.length>0)
            isMycase=true;
             return isMycase;
         }
         get isAllCace(){
            var isMycase=false;
            if(this.allOpenCases.length>0)
            isMycase=true;
             return isMycase;
         }
         get isClosedCace(){
            var isMycase=false;
            if(this.allClosedCases.length>0)
            isMycase=true;
             return isMycase;
         }
        get getcaselist() {
           console.log('getcaselist===> ' + JSON.stringify(this.openCases));
            var tempOppList = [];   
            var url = CommunityURL + 'casedetails?caseId='
            for (var i = 0; i < this.openCases.length; i++) {  
                this.areDetailsAvailableOpenCase=true;
                let tempRecord = Object.assign({}, this.openCases[i]); //cloning object  
                tempRecord.recordLink = url+ tempRecord.Id; 
                tempRecord.RecordTypeId= tempRecord.RecordType.Name;
               //alert(tempRecord.imgelogo__c);
               // tempRecord.Confidence='test';
              /*  if(tempRecord.Next_Action__c=='Customer'){
                  //  tempRecord.dynamicIcon='utility:up'; 
                    tempRecord.Next_Action__c='Your Team';//tempRecord.Next_Action__c;
                } 
                else{
                    //tempRecord.dynamicIcon='utility:down'; 
                    tempRecord.Next_Action__c='Informatica';//tempRecord.Next_Action__c; 
                }   */
                tempOppList.push(tempRecord);  
            }      
          //  console.log(' tabs temp==>',tempOppList.length);
            return tempOppList;
        }
        get getAllcaselist() {
            console.log('this.allOpenCases===> ' + JSON.stringify(this.allOpenCases));
            var tempOppList = [];  
            var url = CommunityURL + 'casedetails?caseId='
            for (var i = 0; i < this.allOpenCases.length; i++) { 
                this.areDetailsAvailableAllCase=true; 
                let tempRecord = Object.assign({}, this.allOpenCases[i]); //cloning object  
                tempRecord.recordLink = url+ tempRecord.Id;  
                tempRecord.RecordTypeId= tempRecord.RecordType.Name;
               /* if(tempRecord.Next_Action__c=='Customer')
                    tempRecord.Next_Action__c='Your Team';//tempRecord.Next_Action__c;
                else
                     tempRecord.Next_Action__c='Informatica';//tempRecord.Next_Action__c; */
                tempOppList.push(tempRecord);  
            }      
          //  console.log(' tabsall temp==>',tempOppList.length);
            return tempOppList;
        }
        get getClosedcaselist() { 
          //  this.accId=sessionStorage.getItem("supportAccountId");
          console.log('allClosedCases==> ' + JSON.stringify(this.allClosedCases));
            var tempOppList = [];  
            var url = CommunityURL + 'casedetails?caseId='
            for (var i = 0; i < this.allClosedCases.length; i++) { 
                this.areDetailsAvailableAllCase=true; 
                let tempRecord = Object.assign({}, this.allClosedCases[i]); //cloning object  
                tempRecord.recordLink = url+ tempRecord.Id;  
                tempRecord.RecordTypeId= tempRecord.RecordType.Name;
               /* if(tempRecord.Next_Action__c=='Customer')
                    tempRecord.Next_Action__c='Your Team';//tempRecord.Next_Action__c;
                else
                     tempRecord.Next_Action__c='Informatica';//tempRecord.Next_Action__c; */
                tempOppList.push(tempRecord);  
            }      
          //  console.log(' tabsall temp==>',tempOppList.length);
            return tempOppList;
        }
    connectedCallback(){
        this.columns=this.COL_CONTACTS;
       // console.log('casethis.tab connected ' ,this.openCases.length);
         
       // console.log('openCases= '+JSON.stringify(this.openCases));
    }
    renderedCallback() {
        this.fullUrl='https://dataviz.informatica.com/#/views/OperationalDashboard/OpenMetrics_1?:iid=1';
       // console.log('casethis.tab render ' ,this.openCases.length);
       
    }
}