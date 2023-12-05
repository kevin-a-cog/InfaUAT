import {LightningElement, api, track} from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartjs';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class chartComp extends LightningElement {
 @api loaderVariant = 'base';
// @api chartConfig;
 chartData;
 @api isChartJsInitialized;
 @api get chartConfig() {
  }
  set chartConfig(value) {
    this.setAttribute('chartConfig', value);
    this.chartData = [];
    this.chartData = value;
    if (this.isChartJsInitialized) {
      const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
      this.chart.destroy();// = new window.Chart(ctx, {});
      
      var newCTX = this.template.querySelector('canvas.barChart').getContext('2d');
      this.chart = new window.Chart(newCTX, JSON.parse(JSON.stringify(this.chartData)));
    }
   // this.handleValueChange(value);
}
 renderedCallback() {
   console.log('--->>>'+this.isChartJsInitialized);
  if (this.isChartJsInitialized) {
   return;
  }
  // load static resources.
  Promise.all([loadScript(this, chartjs)])
   .then(() => {
    this.isChartJsInitialized = true;
    const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
    this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartData)));
    this.chart.canvas.parentNode.style.height = 'auto';
    this.chart.canvas.parentNode.style.width = '100%';
   })
   .catch(error => {
    this.dispatchEvent(
     new ShowToastEvent({
      title: 'Error loading ChartJS',
      message: error.message,
      variant: 'error',
     })
    );
   });
 }
}