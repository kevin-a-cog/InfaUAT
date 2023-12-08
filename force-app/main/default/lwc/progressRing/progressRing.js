import { LightningElement, api } from 'lwc';

export default class ProgressRing extends LightningElement {
    @api numerator;
    @api denominator;
    @api progress;

    get completeness(){

        let fillPercent = this.progress > 0 ? (this.progress/100) * -1 : 0; // Make negative so that progress ring drains

        let isLong = this.progress > 50 ? 1 : 0; 
        let arcX = Math.cos(2 * Math.PI * fillPercent);
        let arcY = Math.sin(2 * Math.PI * fillPercent);
        var value = "M 1 0 A 1 1 0 " + isLong + " 0 " + arcX + " " + arcY + " L 0 0";   
        return value;
    
    }


}