import { LightningElement, track, api } from 'lwc';
import ReportDataByGrouping from '@salesforce/apex/ReportsController.casesByGroupFilter';
export default class ReportChart extends LightningElement {
    @track chartConfiguration;
    @api chartType;
    //@api accountId;
    @api label;
    @api filter;
    @api chartColor;
    inititalized = false;
    selectedAccount;
    @api get accountId() {
    }
    set accountId(value) {
      this.setAttribute('accountId', value);
      this.selectedAccount = value;
      if(this.inititalized == true){
        this.reportData();
      }
    }
    openstartdate;
    @api get openstart() {
    }
    set openstart(value) {
      this.setAttribute('openstart', value);
      this.openstartdate = value;
      if(this.inititalized == true){
        this.reportData();
      }
    }
    closestartdate;
    @api get closestart() {
    }
    set closestart(value) {
      this.setAttribute('closestart', value);
      this.closestartdate = value;
      if(this.inititalized == true){
        this.reportData();
      }
    }
    opendateend;
    @api get openend() {
    }
    set openend(value) {
      this.setAttribute('openend', value);
      this.opendateend = value;
      if(this.inititalized == true){
        this.reportData();
      }
    }
    closedateend;

    @api get closeend() {
    }
    set closeend(value) {
      this.setAttribute('closeend', value);
      this.closedateend = value;
      if(this.inititalized == true){
        this.reportData();
      }
    }
    showError = false
    connectedCallback(){
        this.reportData();
    }
    reportData(){
        this.inititalized = true;
        if(this.chartColor.indexOf(',') > -1){
            this.chartColor = this.chartColor.split(',');
        }
        if(this.chartColor ==  null || this.chartColor === undefined){
            this.chartColor = [ "#52BE80",
            "#76D7C4",
            "#1E8449",
            "#2ECC71",
            "#FFB74D",
            "#E67E22",
            "#F8C471",
            "#3498DB",
            "#00BCD4",
            "#D32F2F",
            "#82E0AA",
            "#AFB42B"];
        }
        console.log('@@-->>', this.chartColor);
        ReportDataByGrouping({supportaccount:this.selectedAccount,fieldfilter:this.filter,opendatestart : this.openstartdate, opendateend:this.opendateend,
            closedatestart : this.closestartdate,closedateend:this.closedateend})
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
            this.chartConfiguration = {
                type: this.chartType,
                data: {
                 labels: chartLabels,
                 datasets: [
                  {
                   label: this.label,
                   barPercentage: 0.5,
                   barThickness: 6,
                   maxBarThickness: 8,
                   minBarLength: 2,
                   data: chartData,
                   backgroundColor:  this.chartColor
                    
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
                                beginAtZero: (this.chartType == 'Pie') ? false : true,
                                precision: 0
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
               if(this.chartType == 'pie'){
                this.chartConfiguration.options = [];
               }
               console.log('@@--this.chartConfiguration.options-->>',this.chartConfiguration.options);
               console.log('@@---this.chartConfiguration--->>',this.chartConfiguration);
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }
}