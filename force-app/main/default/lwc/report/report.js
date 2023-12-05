import { LightningElement, wire, track, } from 'lwc';
//import { loadScript } from 'lightning/platformResourceLoader';
import casesData from '@salesforce/apex/ReportsController.CasesInfo';
import AverageCloseddays from '@salesforce/apex/ReportsController.AverageDaysToClose';
import monthlyCases from '@salesforce/apex/ReportsController.MonthlyCases';
import allSupportAccounts from '@salesforce/apex/CaseController.allSupportAccountswrp';
import { objUtilities } from 'c/globalUtilities';
//import chartScript from '@salesforce/resourceUrl/chartjs';
export default class Report extends LightningElement {
    @track title;
    @track caseData;
    @track supportAccounts = [];
    totalCases;
    showError = false;
    showErrorMonthly = false;
    templateClass = 'hideClass';
    OpenCases;
    showDefault = false;
    ClosedCases;
    Escalations;
    AvgDays;
    CSAT;
    accName;
    opendatestart;
    opendateend;
    closedatestart;
    closedateend;
    functioncalled = true;
    accountId;
    chartConfiguration;
    chartConfigurationForIssueType;
    chartConfigurationForProduct;
    chartConfigurationForAvgDays;
    chartConfigurationFormonthly;
    @track supportAllAccounts = [];
    renderedCallback() {
       
    }
    @wire(allSupportAccounts, {})
    supportAccountOptions({data, error}){
        if(data != null) {
            let supportAccountOptions = [];
            this.supportAccounts = [];
            this.supportAllAccounts=data;
            var url = new URL(window.location.href);
            if (url.searchParams.get("accountid") != null){
                this.accountId = url.searchParams.get("accountid");
            }else{
                this.accountId = sessionStorage.getItem("supportAccountId");
            }
            this.accountId = (this.accountId == null) ? localStorage.getItem("supportAccountId") : this.accountId;
            for(var i in data){
                
                var record = data[i]; 
               
               // alert(JSON.stringify(this.supportAllAccounts));
                for (var key in record) {
                    var value = record[key];
                   // console.log('suppo    cc==> ',value +' key '+key);
                    if('isBlnSUpportAccFav'==key){
                        if(value){
                            //this.selectedFavAcc.push(record['AccConRel'].Id);
                            //this.isPinned = true;
                            //myFavSupportAccounts.push(record['AccConRel'].AccountId+'-'+record['AccConRel'].Id);
                        }
                      //  console.log('suppo fav  cc==> ',record['AccConRel'].AccountId +' key '+key);
                        }else{                          
                            //makefavnewSupportAccounts.push(value.AccountId+'-'+value.Id);
                            supportAccountOptions.push({label: value.Account.Name , value : value.AccountId});  
                        }  
                   // console.log('suppo cc==> ',value);
                   if(this.accountId == data[i].value){
                       this.accName = data[i].value;
                   }
                supportAccountOptions.push({label: data[i].label , value : data[i].value});
                }
            }
            this.supportAccounts = supportAccountOptions;
        }
    }
    handleAccountSelect(event){
        this.accountId = event.detail.value;
        this.getAllData();
        this.getReportDataForAvgCloseDays();
        this.getReportDataForMonthWise();
    }
    connectedCallback(){   
        console.log('@@--ses-->>',sessionStorage);
        var url = new URL(window.location.href);
        if (url.searchParams.get("accountid") != null){
            this.accountId = url.searchParams.get("accountid");
        }else{
            this.accountId = sessionStorage.getItem("supportAccountId");
        }
        this.accountId = (this.accountId == null) ? localStorage.getItem("supportAccountId") : this.accountId;
        var d = new Date();
        var startDate = new Date(d.getFullYear(), 0, 1);
        
        //d.setMonth(d.getMonth() - 6);
        this.opendatestart = startDate;
        
        
        
        this.getAllData();
        if(this.functioncalled == true){
            this.getReportDataForAvgCloseDays();
            this.getReportDataForMonthWise();
        }
        
    }  
    getReportDataForMonthWise(){
        var objParent = this;
        monthlyCases({supportaccount:this.accountId,opendatestart : this.opendatestart, opendateend:this.opendateend,
            closedatestart : this.closedatestart,closedateend:this.closedateend})
        .then(data => {

            this.functioncalled = false;
            var chartData = [];
            var chartLabels = [];
            if(data.values.length > 0){
                chartLabels = data.labels;
                chartData = data.values;
            }
           
            if(chartData.length > 0){
                this.showErrorMonthly = false;
            }else{
                this.showErrorMonthly = true;
            }
            this.chartConfigurationFormonthly = {
                type: 'bar',
                data: {
                 labels: chartLabels,
                 datasets: [
                  {
                   label: 'Cases By Primary Contact',
                   barPercentage: 0.5,
                   barThickness: 6,
                   maxBarThickness: 8,
                   minBarLength: 2,
                   data: chartData,
                   backgroundColor:   "#4b76ab"
                    
                  },
                 ],
                },
                options: {
                    
                    scales:  {
                        yAxes: [{
                            ticks: {
                                beginAtZero: (this.chartType == 'Pie') ? false : true,
                                precision: 0
                            },
                            gridLines: {
                                drawBorder: false,
                            },
                            gridLines: {
                                display: false,
                              },
                        }],

                        xAxes: [{
                            ticks: {
                                beginAtZero: (this.chartType == 'Pie') ? false : true
                            },
                            gridLines: {
                                drawBorder: false,
                            },gridLines: {
                                display: false,
                              },
                        }]
                    },
                   
                    legend: {
                        display: false
                    },
                   
                },
               };
        })
        .catch(error => {
            objUtilities.processException(error, objParent);
        })
    }
    getReportDataForAvgCloseDays(){
        var objParent = this;
        AverageCloseddays({supportaccount:this.accountId,opendatestart : this.opendatestart, opendateend:this.opendateend,
            closedatestart : this.closedatestart,closedateend:this.closedateend})
        .then(data => {

            this.functioncalled = false;
            var chartData = [];
            var chartLabels = [];
            if(data.values.length > 0){
                chartLabels = data.labels;
                chartData = data.values;
            }
           
            if(chartData.length > 0){
                this.showError = false;
            }else{
                this.showError = true;
            }
            this.chartConfigurationForAvgDays = {
                type: 'bar',
                data: {
                 labels: chartLabels,
                 datasets: [
                  {
                   label: 'Cases By Primary Contact',
                   barPercentage: 0.5,
                   barThickness: 6,
                   maxBarThickness: 8,
                   minBarLength: 2,
                   data: chartData,
                   backgroundColor:   "#4b76ab"
                    
                  },
                 ],
                },
                options: {
                    
                    scales:  {
                        yAxes: [{
                            ticks: {
                                beginAtZero: (this.chartType == 'Pie') ? false : true,
                                precision: 0
                            },
                            gridLines: {
                                drawBorder: false,
                            },
                            gridLines: {
                                display: false,
                              },
                        }],

                        xAxes: [{
                            ticks: {
                                beginAtZero: (this.chartType == 'Pie') ? false : true
                            },
                            gridLines: {
                                drawBorder: false,
                            },gridLines: {
                                display: false,
                              },
                        }]
                    },
                   
                    legend: {
                        display: false
                    },
                   
                },
               };
        })
        .catch(error => {
            objUtilities.processException(error, objParent);
        })
    }
    
    getAllData(){
        var objParent = this;
        casesData({supportaccount:this.accountId,opendatestart : this.opendatestart, opendateend:this.opendateend,
            closedatestart : this.closedatestart,closedateend:this.closedateend})
        .then(data => {
            this.totalCases = data.totalCases;
            this.OpenCases = data.OpenCases;
            this.ClosedCases = data.ClosedCases;
            this.Escalations = data.Escalations;
            this.AvgDays = data.AvgDays;
            this.CSAT = data.CSAT;
           
            this.accName = data.AccountName;
            this.templateClass = 'showClass';
            if(this.showDefault == false){
                this.template.querySelectorAll('lightning-input').forEach(input => {
                    if(input.name === 'OpenStartDate'){
                        var d = new Date();
                        
                        var selected = d.getUTCFullYear() + '-01-01' ;
                        input.value = selected; 
                        this.showDefault = true;
                    }          
                });
            }
           
        })
        .catch(error => {
            objUtilities.processException(error, objParent);
        })
    }
    handleDateChange(event){
       
        if(event.target.name == 'OpenStartDate'){
            this.opendatestart = event.target.value;
        }
        if(event.target.name == 'OpenEndDate'){
            this.opendateend = event.target.value;
        }
        if(event.target.name == 'CloseStartDate'){
            this.closedatestart = event.target.value;
        }
        if(event.target.name == 'CloseEndDate'){
            this.closedateend = event.target.value;
        }

        this.getAllData();    
        this.getReportDataForAvgCloseDays();
        this.getReportDataForMonthWise();
    }
}