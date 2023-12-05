/*
 * Name         :   HelpAnonymousAnalytics
 * Author       :   Utkarsh Jain
 * Created Date :   08-March-2022
 * Description  :   This component is used for displaying analytics count for Informatica network site.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5249              Initial version.                                          NA
 */
import { LightningElement, track, wire } from 'lwc';
import getAnalyticsData from "@salesforce/apex/helpCommunityController.getAnalyticsData";

export default class HelpAnonymousAnalytics extends LightningElement {

    @track analyicsCount= [];
    @track showAnalytics = false;
    analyticsNames = ['Active Users', 'Questions Answered', 'Knowledge Base Articles', 'Videos Available'];
    @wire(getAnalyticsData)
    wiredData({ error, data }){
        if (data) {
            if( data.length > 0){ 
                this.showAnalytics = true;
                let counts = data[0].analytics_data__c.split(';');
                for(let i=0; i<4; i++){
                    let obj = {count: counts[i], name: this.analyticsNames[i]};
                    this.analyicsCount.push(obj);
                } 
            }
        } else if (error) {
            this.error = error;
        }
    }
}