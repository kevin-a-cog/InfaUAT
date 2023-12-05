import { LightningElement,api,wire } from 'lwc';
import {publish,MessageContext,APPLICATION_SCOPE} from 'lightning/messageService';
import openChatter from '@salesforce/messageChannel/openChatter__c';

export default class ActivityTimelineChildRenderer extends LightningElement {
    
    @api showChild;
    @api currIndex;
    @api activity={};
    @api iconCss;
    showCollapse=true;


    //handle message content for the lms
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.applyCSSClass();
    }

    applyCSSClass(){
        document.styleSheets[0].insertRule(`.iconCSS svg{
            fill:white !important;padding: 5px;
        }`);
    }

    handlePostClick(event){
        const payload = { recordId:event.currentTarget.dataset.value ,publisherContext:'RECORD',feedType:'Record',description: 'OpenChatter',isFeedEnabled:true,calledFrom:'Activity'};
        //firing lms to open chatter.
        publish(this.messageContext, openChatter, payload);
    }

    handleToggle(event){
       if(this.activity.childList.length>0){
           var act=JSON.parse(JSON.stringify(this.activity));
           act.showChild=!act.showChild;
           this.activity=JSON.parse(JSON.stringify(act));
       } 
       var divblockId= event.currentTarget.dataset.value;
       var divblock = this.template.querySelector('[data-id="'+divblockId+'"]');
       if(divblock){
        if(divblock.style.display=='none'){
            divblock.style.display='block';
        }
        else{
            divblock.style.display='none';
        }
       }
    }
}