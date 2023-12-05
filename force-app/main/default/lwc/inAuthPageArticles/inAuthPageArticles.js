import { LightningElement, wire, track } from 'lwc';
import getDetails from '@salesforce/apex/helpCoveoArticlesController.getDetails';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import searchArticles from '@salesforce/label/c.help_searchArticles';
import userId from '@salesforce/user/Id';
import {
    publish,subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";

export default class InAuthPageArticles extends LightningElement {
    showNoresult = false;
    articles;
    @track searchPage = CommunityURL + searchArticles;
    sessionStorageOptionToken;


    @wire(MessageContext)
    messageContext;

    receivedMessage;
    subscription = null;


    connectedCallback() {
        this.handleSubscribe();
        const isChild = {
            AuthArticlesLoaded: true,
            sessiontoken: null
        };
        publish(this.messageContext, SESSIONID_CHANNEL, isChild);
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }


    handleSubscribe() {
        if (this.subscription) {
            return;
        }

        //Subscribing to the message channel
        this.subscription = subscribe(
            this.messageContext,
            SESSIONID_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.receivedMessage = message ? message : "no message";
        if (this.receivedMessage.sessiontoken) this.getArticles();
    }



    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }



    getArticles() {
        getDetails({ token: this.receivedMessage.sessiontoken })
            .then((result) => {
                if (result) {
                    this.articles = result.coveoResultsWrapper;
                    if (this.articles.length != 0) {
                        this.showNoresult = true;
                    }

                }

            })
            .catch((error) => {
                console.error(JSON.stringify(error.body));
            });
    }

    handleOnClick(event){
        event.preventDefault();
        let title = event.currentTarget.dataset.value;
        let community = event.currentTarget.dataset.community;
        let link = event.currentTarget.dataset.link;
         /** START-- adobe analytics */
         try {
            util.trackLinkClick('Articles - '+ title + ' - ' + community);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(link,'_self');
    }

}