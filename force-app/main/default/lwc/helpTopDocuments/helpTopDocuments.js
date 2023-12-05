/*
* Name : HelpTopDocuments
* Author : Deeksha Shetty
* Created Date :  Feb 9 2022
* Description : This Component displays Recent Documents
Change History
*******************************************************************************************************************
Modified By              Date       Jira No.                 Description                                                               Tag
Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components in the Product community              T1
*******************************************************************************************************************

*/

import { LightningElement, api, wire } from 'lwc';
import displayDocs from '@salesforce/apex/helpArticles_Documents.displayDocs';
import userId from '@salesforce/user/Id';
import {
  publish, subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";


export default class HelpTopDocuments extends LightningElement {
  @api recordId;
  wiredResults;
  showNoresult = true;
  viewmore;

  @wire(MessageContext)
  messageContext;

  receivedMessage;
  subscription = null;

  connectedCallback() {
    //T1 starts
    this.handleSubscribe();
    const isChild = {
      isDocLoaded: true,
      sessiontoken: null

    };
    publish(this.messageContext, SESSIONID_CHANNEL, isChild);
    //T1 ends

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
    if (this.receivedMessage.sessiontoken && this.recordId) this.DocsDisplay();
  }



  handleUnsubscribe() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }



  DocsDisplay() {
    displayDocs({ topicId: this.recordId, token: this.receivedMessage.sessiontoken })
      .then((result) => {
        if (result) {
          this.wiredResults = result;
          if (this.wiredResults.length > 0) {
            this.showNoresult = false;
          }
          this.viewmore = result[0].LearnMoreUrl;
        }

      })
      .catch((error) => {
        console.error(error.body);

      });
  }
}