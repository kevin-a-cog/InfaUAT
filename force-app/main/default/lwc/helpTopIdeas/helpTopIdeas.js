/*
 * Name         :   HelpTopIdeas
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   Component used to retrive top ideas on community detail's page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     Utopia-ph-3         Initial version.                                          NA
 */
import { LightningElement, track, wire,api } from 'lwc';
import communityId from '@salesforce/community/Id';
import getTopIdeas from '@salesforce/apex/helpUserRelatedList.getTopIdeas';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';

export default class HelpTopIdeas extends LightningElement {
    @api recordId;
    @track wiredResults;
    @track viewmore = CommunityURL + 'ideas?active=2';
    showNoresult = false;

    

    @wire(getTopIdeas, { networkId: communityId, topicId:'$recordId'})
    TopIdeas(result) {
        if (result.data) {
            console.log('top Ideas='+JSON.stringify(result.data))
            this.wiredResults = result.data;
            if (!this.wiredResults.length) {
                this.showNoresult = true;
            }
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }

}