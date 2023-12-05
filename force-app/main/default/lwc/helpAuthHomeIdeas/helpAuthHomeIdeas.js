/*
 * Name         :   HelpAuthHomeIdeas
 * Author       :   Deeksha Shetty
 * Created Date :   17-FEB-2022
 * Description  :   Component used to retrive Recent ideas on Authenticated Home Page

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 Deeksha Shetty       14/6/2022       I2RT-6042             Authenticated Ideas Upvote Grey out and count is 5         T1
 **************************************************************************************************************************
 
 */

 import { LightningElement, wire,track } from 'lwc';
import communityId from '@salesforce/community/Id';
import ideasDisplay from '@salesforce/apex/helpAuthHomeController.ideasDisplay';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import userId from '@salesforce/user/Id';

export default class HelpAuthHomeIdeas extends LightningElement {
    wiredResults;
    viewmore = CommunityURL + 'ideas';
    target = CommunityURL + 'ideas';
    showIdea = false;
    @track IdeaPage = CommunityURL+'ideas?active=1';


    @wire(ideasDisplay, { networkId: communityId,userId: userId})
    wiredData(result) {
        if (result.data) {
            this.wiredResults = result.data;
            if(this.wiredResults.length>0){
                this.showIdea = true;
            }
            console.log('wiredResults='+JSON.stringify(this.wiredResults));
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }

    ideaRedirection(){
        console.log('button clicked')
        window.open(this.target,"_self");
    }

    handleOnClick(event){
        event.preventDefault();
        let title = event.currentTarget.dataset.value;
        let community = event.currentTarget.dataset.community;
        let link = event.currentTarget.dataset.link;
        let target = event.currentTarget.dataset.target;
         /** START-- adobe analytics */
         try {
            util.trackLinkClick('Ideas - '+ title + ' - ' + community);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(link,target);
    }
}