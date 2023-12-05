import { LightningElement,wire,track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import getSupportAccountInfoByContact from '@salesforce/apex/HelpMyCasesController.getSupportAccountInfoByContact';
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';

export default class HelpMyCases extends LightningElement {

@track showCasesTable = false;
@track disableSearch=false;
@track openCases = [];
@track allOpenCases = [];
@track casesLandingPage = CommunityURL ; // I2RT-8842 -MY case URL redirect
@track contactId;
@track offSet = 0;
@track items = []; //it contains all my case records.
@track page = 1; //this will initialize 1st page
@track startingRecord = 1; //start record position per page
@track endingRecord = 0; //end record position per page
@track pageSize =  5 ; //default value we are assigning
@track totalRecountCount = 0; //total record count received from all retrieved records
@track totalPage = 0; //total number of page is needed to display all records
@track sortDirection  ;
@track sortedBy;
@track caseData=[];
    mapFieldVal=new Map([["Priority","Priority"],["Status","Status"],["Type","RecordTypeId"],["Forecast_Product__c","Product"],
    ["Subject","Subject Session Title"],["CaseNumber","CaseNumber"],["NextAction__c","Next Action"]]);

COL_CONTACTS=[
    
    {  
        label: "Case Number",  
        fieldName: "recordLink",  
        type: "url",  sortable: true,
        typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"CaseNumber", target: "_parent", initialWidth: 30 }  
        },  
        
    {label:"Priority", fieldName: "Priority",type: "text",sortable: true,initialWidth: 70},
    {label:"Status", fieldName: "Status",type: "text",sortable: true, initialWidth: 80},
    {label:"Type", fieldName: "RecordTypeId",type: "text",sortable: true, initialWidth: 80},
    {label:"Product", fieldName: "Forecast_Product__c",type: "text",sortable: true, initialWidth: 100},         
    {label:"Subject/Session Title", fieldName: "Subject",type: "text",sortable: true,initialWidth: 500},
    {label:"Next Action", fieldName: "NextAction__c",type: "text",sortable: true, initialWidth: 100, cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }},
];

@wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
userRecord({error,data}){
    if(data){
        this.contactId = getFieldValue(data, CONTACT_ID);
        if(this.contactId != undefined && this.contactId != ''){
            this.getCases();
        }

    }else if(error){
        console.log('error : ' + error);
    }
};


get isMyCase(){
    var isMyCase=false;
    if(this.openCases.length>0)
    isMyCase=true;
        return isMyCase;
}
get isAllCase(){
var isMycase=false;
if(this.allOpenCases.length>0)
isMycase=true;
    return isMycase;
}

get getcaselist() {
    
    var tempOppList = [];   
    var url = CommunityURL + 'casedetails?caseId='
    for (var i = 0; i < this.openCases.length; i++) {  
        this.areDetailsAvailableOpenCase=true;
        let tempRecord = Object.assign({}, this.openCases[i]); //cloning object  
        tempRecord.recordLink = url+ tempRecord.Id; 
        tempRecord.RecordTypeId= tempRecord.RecordType.Name;
        tempOppList.push(tempRecord);  
    }      
    return tempOppList;
}

get showCases(){
    return this.totalRecountCount > 1 ? 'Cases' : 'Case';
}

onHandleSort(event) {
    // console.log('onHandleSort ' + JSON.stringify(event.detail));
    let sortbyField = event.detail.fieldName;
      if(sortbyField == 'recordLink'){
        this.sortBy = 'CaseNumber';
      }else{
        this.sortBy = sortbyField; 
      }
    //   console.log('onHandleSort ' + JSON.stringify(event.detail));
      const { fieldName: sortedBy, sortDirection } = event.detail;     
      this.sortDirection = event.detail.sortDirection;   
      this.sortData(event.detail.fieldName, event.detail.sortDirection);  
      this.sortBy = sortbyField;    
    //   console.log('onHandleSort ' + this.sortBy);
}

sortData(fieldname, direction){
      let parseData = JSON.parse(JSON.stringify(this.openCases));
      let isReverse = direction === 'asc' ? 1: -1;
      let keyValue = (a) => {
          return a[fieldname];
      };
         parseData.sort((x, y) => {
          x = keyValue(x) ? keyValue(x) : ''; 
          y = keyValue(y) ? keyValue(y) : '';
         
          return isReverse * ((x > y) - (y > x));
      });
      this.openCases = parseData;
}
sortBy(field, reverse, primer) {
      const key = primer
          ? function(x) {
                return primer(x[field]);
            }
          : function(x) {
                return x[field];
            };

      return function(a, b) {
          a = key(a);
          b = key(b);
          return reverse * ((a > b) - (b > a));
      };
  }

//clicking on first  button this method will be called
firstHandler() {
    // console.log('firstHandler ');
    // console.log(this.page+' next page==>'+this.totalPage);
    // console.log('firstHandler== before||  offSet==>'+this.offSet);
    this.startingRecord=1;
    this.offSet = 0;
    this.page =2;
    // alert(this.page );
    if (this.page > 1) {
        this.page = this.page - 1; //decrease page by 1
        this.displayRecordPerPage(this.page);
    }
    // console.log('firstHandler == after|| offSet==>'+this.offSet);   
}
//clicking on last button this method will be called
lastHandler() {
    // console.log('lastHandler ');
    // console.log(this.page+' next page==>'+this.totalPage);
    // console.log('lastHandler== before||  offSet==>'+this.offSet);
    this.page=this.totalPage;
    this.offSet = this.totalPage >0 ? (this.totalPage - 1) * 5 : 0;
    if (this.page < this.totalPage) {
        // this.page = this.page - 1; //decrease page by 1
        this.displayRecordPerPage(this.page);
    }
    // console.log('lastHandler == after|| offSet==>'+this.offSet);   
}
    //clicking on previous button this method will be called
    previousHandler() {
    //     console.log('previousHandler ');
    // console.log(this.page+' next page==>'+this.totalPage);
    // console.log('previousHandler== before||  offSet==>'+this.offSet);
    if (this.page > 1) {
        this.page = this.page - 1; //decrease page by 1
        this.offSet = this.offSet - 5;
        this.displayRecordPerPage(this.page);
    }
    // console.log('previousHandler == after|| offSet==>'+this.offSet);   
}

//clicking on next button this method will be called
nextHandler() {
    // console.log('nextHandler ');
    // console.log(this.page+' next page==>'+this.totalPage);
    // console.log('nextHandler== before||  offSet==>'+this.offSet);
    
    if((this.page<this.totalPage) && this.page !== this.totalPage){
        this.page = this.page + 1; //increase page by 1
        this.offSet = this.offSet + 5;
        this.displayRecordPerPage(this.page);            
    }   
    // console.log('nextHandler == after|| offSet==>'+this.offSet);         
}

//this method displays records page by page
displayRecordPerPage(page){

this.startingRecord = ((page -1) * this.pageSize) ;
this.endingRecord = (this.pageSize * page);
this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                    ? this.totalRecountCount : this.endingRecord; 

this.startingRecord = this.startingRecord + 1;
if(this.contactId != undefined && this.contactId != ''){
    this.getCases();
}
}  
renderedCallback() {             
    if(this.items<=0){ 
    this.items = this.openCases;
    this.data=this.openCases;               
    this.endingRecord = this.pageSize;
}
this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5  
// console.log('Total Records :: ' + this.totalRecountCount);
// console.log('Total Pages :: ' + this.totalPage);
}

getCases(){
    getSupportAccountInfoByContact({contactId:this.contactId,offset:this.offSet}).then(result =>{
        if(result != null){
            // console.log('Result :: ' + JSON.stringify(result));
            this.openCases = result.myOpenCases;
            this.totalRecountCount = result.totalNumberOfRecords;
            this.showCasesTable = true;
            // console.log('Total Records :: ' + this.totalRecountCount);
        }
    }).catch(error =>{

    });
}
}