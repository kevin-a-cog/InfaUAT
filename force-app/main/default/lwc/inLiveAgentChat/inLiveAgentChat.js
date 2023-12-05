import { api, LightningElement, track, wire } from 'lwc';
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import getCommunityName from '@salesforce/apex/helpUserRelatedList.getCommunityName';
import ChatCommList from '@salesforce/label/c.ChatCommList';

export default class InLiveAgentChat extends LightningElement {

    @api recordId;
    @track isCloudCommunity = false;
    @track isAgentAvailable = false;
    @track flag = true;
    liveAgent = IN_StaticResource + '/live_agent.png';

    @wire(getCommunityName, {commId : '$recordId'})
    GetCommunity(result){
        if(result.data){
            this.communityName = result.data;
            if(ChatCommList.includes(this.communityName)){
                this.isCloudCommunity = true;
            }
            setTimeout(() => {
                var flatButton = $('.flatButton');
                if (flatButton.text().includes('Chat with an Expert')) {
                    this.isAgentAvailable = true;
                }
            }, 10000);
        }
    }

    handleStartChat() {
        let flatButton = $('.flatButton');
        let helpButton = $('.helpButton');
        if (flatButton !== null && flatButton.text().includes('Chat with an Expert')) {
            this.showSpinner = true;
            new Promise(
                (resolve, reject) => {
                    flatButton.trigger("click");
                    setTimeout(() => {
                        resolve();
                    }, 3000);
                }).then(
                    () => this.showSpinner = false
                );
        }
        if (helpButton !== null && helpButton.text().includes('Chat with an Expert')) {
            this.showSpinner = true;
            new Promise(
                (resolve, reject) => {
                    setTimeout(() => {
                        helpButton.trigger("click");
                        resolve();
                    }, 0);
                }).then(
                    () => this.showSpinner = false
                );
        }
    }
}