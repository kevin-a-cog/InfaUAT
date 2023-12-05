/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              30-Sep-2022     I2RT-6880           Added properties and methods related to case download     T01
                                                            widget
 */
import { LightningElement, api, wire, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import CommunityURL from '@salesforce/label/c.KBPreviewurl';
import { registerListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
const Delay=400;
export default class EsCaseTable extends LightningElement {
    Informatica = ESUPPORT_RESOURCE + '/next_action_infa.svg';
    YourTeam = ESUPPORT_RESOURCE + '/next_action_user.svg';
    showModal = false;
    @track hrefdata;
    @track frameURL='https://trailblazer.salesforce.com/answersHome_1?id=9063A000000aFJYQA2';
    @api caseDetails;
    @api mapFields;
    @api tabName;
    @api accId;
    @api openCases=[];
    @api infaNetwork = false;
    @track caseList = [];
    @track informaticaAction = ESUPPORT_RESOURCE + '/next_action_infa.svg';
    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all my case records.
    @track Allitems = []; //it contains all   case records.
    @track Allcaseitems = []; //it contains all   case records
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = this.infaNetwork ?  5 : 10; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @api ischeckboxOn; 
    @api columns; 
    @api disableSearch;
    @track Casedata;
    @track data;
    @track isOneRecord=false;
    @track isSuppoAccChanged=false;
    @track acrIdMap= new Map();
    defaultSortDirection = 'asc';
    //sortDirection = 'asc';
    @track sortDirection  ;
    @track sortedBy;
    @track buttonSearchClass = "d-flex align-items-center justify-content-end mb-3";

    boolShowSupportAccount = true; //<T01>
    
    @wire(CurrentPageReference) pageRef;
   
    get getcaselist() {
        
       this.items=this.openCases;
      console.log( this.isSuppoAccChanged+' 1 getcaselist ==>'+this.items.length);
      // console.log('data ===>',this.Allcaseitems.length);
       if(this.Allcaseitems.length<=0){
        this.Allcaseitems=this.openCases;
      //console.log(' Allcaseitems getter ==>',this.Allcaseitems.length);
       }
       if(this.isSuppoAccChanged){
        this.Allcaseitems=this.openCases;
       }
       this.isSuppoAccChanged=false;
      // console.log(' Allcaseitems getter ==>',this.Allcaseitems.length);
     //  console.log(this.startingRecord+' start 1 end ==> '+this.endingRecord);
       var inp=this.template.querySelector("lightning-input");//get search text field
       //console.log(' input val ==> '+inp);
       
      if( inp!=null){
        var inpVal=inp.value;
        var firstTime = localStorage.getItem("first_timeVal");
      // console.log(' inpVal  end ==> '+inpVal.length); 
       if(inp.value!=''){
        if(firstTime==null) {
           // console.log(' firstTime not null  end ==> '+firstTime);
            this.startingRecord=1;
            this.endingRecord=this.infaNetwork? 5: 10;
            if(inpVal.length>10){
                this.page=2;
            }
        }
       
       localStorage.clear();
     //  console.log(' firstTime end line  end ==> '+firstTime);
    }else{
        console.log(' firstTime null  end ==> '+firstTime); 
      
    }
    }
   // console.log(this.startingRecord+' start 2 end ==> '+this.endingRecord);
      // alert(this.endingRecord+' end ==start '+this.startingRecord+' pgsize '+this.pageSize);
       if(this.startingRecord>1){
           //alert(this.startingRecord+' srt more records' +this.endingRecord);
             this.Allitems= this.items.slice((this.startingRecord-1),this.endingRecord); 
       }else{
      //  alert('start records'+this.endingRecord);
        this.Allitems= this.items.slice(0,this.pageSize); 
       }
      // console.log(' return  ==>',this.Allitems.length);
       if(this.Allitems.length>1){
        this.isOneRecord=false;
       // alert(this.Allcaseitems.length +'tble'+inpVal);
        if(this.Allcaseitems.length<10){
           // alert(this.Allcaseitems.length +'tble'+firstTime);
           //if(firstTime==null)
             this.endingRecord=this.Allitems.length;
        }
        
        if(inpVal!=''&& inpVal!=undefined){
           // alert(this.Allcaseitems.length +'tble'+inpVal.length);
            if(this.Allitems.length<10){
               //  alert(this.Allcaseitems.length +'tble'+inpVal);
                // if(firstTime==null)
                  this.endingRecord=this.Allitems.length;
             }  
        }
        //console.log(' return isOneRecord  ==>',this.isOneRecord);
       }else{
        this.isOneRecord=true;
       }
         
        return this.Allitems;
    }
    
    connectedCallback(){
        var width = (window.innerWidth > 0) ? window.innerWidth : screen.width;
        if (width < 420){
            this.buttonSearchClass = 'd-flex align-items-center mb-2';
        }
     //   console.log('connectedCallback casetableinfo==>');
        this.endingRecord = this.pageSize;
        registerListener('getAccountDetails', this.handleResponse, this);
        //console.log('connectedCallback2 caseinfo==>');
    }
    handleResponse(supportAccountId) {
      //  console.log('handleResponse==> ' + supportAccountId);
        var inp=this.template.querySelector("lightning-input");//get search text field
        inp.value='';
        this.startingRecord=1;
            this.endingRecord=this.infaNetwork? 5: 10;           
                this.page=1;
                this.isSuppoAccChanged =true;     
                this.items=[]; 
                this.openCases=[];
                this.Allcaseitems=[];
     // console.log( this.isSuppoAccChanged+' 2 handleResponse ==>'+this.openCases.length);
      // console.log('data ===>',this.Allcaseitems.length);
             
    }
     //clicking on first  button this method will be called
     firstHandler() {
        localStorage.setItem("first_timeVal","2");
        this.startingRecord=1;
        this.page =2;
       // alert(this.page );
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //clicking on last button this method will be called
    lastHandler() {
        localStorage.setItem("first_timeVal","2");
      //  alert(this.totalPage+' ==last' +this.page );
        this.page=this.totalPage;
       if (this.page > 1) {
          // this.page = this.page - 1; //decrease page by 1
           this.displayRecordPerPage(this.page);
       }
   }
       //clicking on previous button this method will be called
       previousHandler() {
        localStorage.setItem("first_timeVal","2");
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
      //  console.log(this.page+' next page==>'+this.totalPage);
       
        localStorage.setItem("first_timeVal","2");
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }
  //this method displays records page by page
  displayRecordPerPage(page){
 
    this.startingRecord = ((page -1) * this.pageSize) ;
    this.endingRecord = (this.pageSize * page);
    this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                        ? this.totalRecountCount : this.endingRecord; 
    
    this.startingRecord = this.startingRecord + 1;
   // console.log('displayRecordPerPage ==>'+page)
   // getcaselist();
}  
    renderedCallback() {       
       // console.log( ' renderedCallback caseinfo==>'+mapFieldVal);       
        if(this.items<=0){ 
        this.items = this.openCases;
        this.data=this.openCases;
      //  this.Allcaseitems=this.openCases;
      // console.log('renderer record render==>',this.items);
        //this.Allitems=this.openCases;                 
        this.endingRecord = this.pageSize;
    }
   // console.log(this.mapFields+'map fields  record render==>',this.items);
    this.totalRecountCount = this.openCases.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5  
    }
    handleSearchText(event) {
        this.searchText = event.target.value;
        this.openCases=this.Allcaseitems;
         /** START-- adobe analytics */
         try {
            util.trackCaseSearch();
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
       // console.log('filter==>',Number.isInteger(12));       
       if ( this.searchText.length >= 2) {
            var filteredRecords = [];
            let chcknmber=Number(this.searchText);
         //   alert(this.searchText +' seerach');
            for (var index in this.openCases) {
                var record = this.openCases[index];
               // console.log('index record==>',JSON.stringify(record));
                let value=JSON.stringify(record);
                if (value && value.length > 0 && value.toLowerCase().includes(this.searchText.toLowerCase())) {
                    filteredRecords.push(record);
                    //console.log('add record==>',record);
                }              
            }
            this.openCases=filteredRecords;
          //  console.log('record==>',filteredRecords.length);
           //you  alert(filteredRecords.length+ ' txt '+this.searchText);
        
 }else{
           // this.openCases=this.items;
        this.openCases=this.Allcaseitems ;
           // eval("$A.get('e.force:refreshView').fire();");
           // console.log('record else==>',this.openCases.length);
        }
    }
    goToCaseDetail(event){
       // console.log('event= '+event.currentTarget.dataset.value);
        var url = CommunityURL + 'casedetails?caseId='+event.currentTarget.dataset.value;
        window.open(url,'_self');
    }
    onHandleSort(event) {
      //  console.log('onHandleSort'); 
       
        const { fieldName: sortedBy, sortDirection } = event.detail;     
        this.sortData(event.detail.fieldName, event.detail.sortDirection);  
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
       /* const { fieldName: sortedBy, sortDirection } = event.detail;
        console.log('event.detail'+sortedBy+sortDirection);
        const cloneData = [...this.openCases];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.openCases = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;*/
      //  console.log('onHandleSort',this.openCases);
    }
    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.openCases));
        let isReverse = direction === 'asc' ? 1: -1;
        let keyValue = (a) => {
            return a[fieldname];
        };
       // console.log(fieldname+' fieldname==> '+isReverse); 
       
//console.log(direction+' isReverse==> '+isReverse);
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
       // console.log('isReverse==>264 '+isReverse);
        this.openCases = parseData;
    }
    sortBy(field, reverse, primer) {
        //console.log('sortBy',field);
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
    handleRowAction(event){
       /* const dataRow = event.detail.row;         
        var recid='';
        for(var  key in dataRow){
            if(key=='Id'){
                recid=dataRow[key];
            } 
        }
        if(recid!=''){
        var url = CommunityURL + 'casedetails?caseId='+recid;
        window.open(url,'_self');
       // alert(recid);
        }*/
    }
    handleProgressValueChange(event){
      //  this.accId=sessionStorage.getItem("supportAccountId");
        this.showModal = event.detail;
    }
    // this method validates the data and creates the csv file to download
    downloadCSVFile() {
        this.accId=sessionStorage.getItem("supportAccountId");
        this.showModal = true;
        /*if(this.tabName == 'All Closed Cases'){
            this.showModal = true;
        }else{
            let rowEnd = '\n';
            var columnEnd = ',';
            let csvString = '';
            let allcasesdata=[];
            var data=this.Allcaseitems;
            var inp=this.template.querySelector("lightning-input");//get search text field
        
        var xdata=data.length;
        var ydata=this.openCases.length;
            console.log(data.length+' inut==>'+this.openCases.length);
            console.log( 'inp val ==>'+inp);
            if((xdata!=ydata )&& (inp.value=='')){
                data=this.openCases;
                console.log('inut inside ==>',inp.value);
            } 
        // let mapFieldVal=new Map([["Priority","Priority"],["Status","Status"],["Forecast_Product__c","Product"],["Subject","Subject Session Title"]]);
            //this.mapFields=mapFieldVal; 
            console.log('map fields ==>', this.mapFields);
            // this set elminates the duplicates if have any duplicate keys
            let rowData = new Set();
            let rowDatacolm = new Set()
            let mymap=new Map();
        
            mymap=this.mapFields;
        // console.log('download rowData ==>'+data);
            // getting keys from data
            data.forEach(function (record) {             
                Object.keys(record).forEach(function (key) {
                //  console.log(mymap+' map inside fields ==>'+mymap.has(key));
                    if(mymap.has(key)){
                    rowData.add(key);
                    var coldata=mymap.get(key);
                    rowDatacolm.add(coldata); 
                    }
                });
            });
        
            // Array.from() method returns an Array object from any object with a length property or an iterable object.
            rowData = Array.from(rowData);
            rowDatacolm=Array.from(rowDatacolm);
            console.log(' download  212 rowData ==>'+JSON.stringify(rowDatacolm));
            // splitting using ',' rowDatacolm
            csvString += rowDatacolm.join(',');
            //csvString += rowData.join(',');
            csvString += rowEnd;
            var headerrow=csvString;
            var mycasedata;
        // console.log('download  216 rowData ==>'+JSON.stringify(csvString));
        //  alert('All cases '+data.length); 
            // main for loop to get the data based on key value
            for(let i=0; i < data.length; i++){
                let colValue = 0;           
                // validating keys in data
                for(let key in rowData) {
                //  console.log('download loop data ==>'+rowData);
                    if(rowData.hasOwnProperty(key)) {
                        // Key value     // Ex: Id, Name
                        let rowKey = rowData[key];
                        // add , after every value except the first.
                        if(colValue > 0){
                            csvString += ',';
                            mycasedata+= ',';
                        }
                        // If the column is undefined, it as blank in the CSV file.
                        let value = data[i][rowKey] === undefined ? '' : data[i][rowKey];
                    // console.log('val==>'+value);
                        var actulval=JSON.stringify(value);
                        if('CaseNumber'==rowKey){
                        // actulval="\'"+String(value)+"\'";                       
                            actulval="\\ '"+String(value);
                            console.log(rowKey+'==val==>'+actulval);  
                        }//else{
                        
                        actulval = actulval.replace(/[&\/\\#,+()$~%.'":*?<>{}]/g,"");
                    // }
                        csvString += '"'+ actulval +'"';
                    // mycasedata+= '"'+ value +'"';
                        colValue++;
                    }
                }
            // console.log(' col val data ==>'+colValue );
            
                csvString += rowEnd;
                allcasesdata.push(mycasedata);
            }
        
            // Creating anchor element to download
            let downloadElement = document.createElement('a');
        console.log(allcasesdata.length+' prepare data ==>' );
            // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        // downloadElement.href = 'application/vnd.ms-excel;charset=utf-8,' + encodeURI(headerrow);
            downloadElement.target = '_self';
            // CSV File Name
            downloadElement.download = 'AllCases.csv';
        // downloadElement.download = 'AllCases.xls';
            
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
        // console.log(csvString+' click data ==>');
            // click() Javascript function to download CSV file
            downloadElement.click(); 
        }*/
    }

    closeDownload(){ //<T01>
        this.showModal = false;
    }

}