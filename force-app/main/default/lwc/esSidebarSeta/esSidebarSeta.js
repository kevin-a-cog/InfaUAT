import { LightningElement, api, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsSidebarSeta extends LightningElement {

    @api accountMembers;
    @api accountMembersWrp;
    @api supportGuide;
    @api primaryContacts;
    @api successOffering;
    @api signatureSuccesssIcon;
    @api supportAccId;
    connectedCallback(){
        var accountMembers = this.accountMembers;
       // console.log("connectedCallback sets==>",accountMembers);
        if(accountMembers.length>0)
            this.offeringMethod = accountMembers[0].Account.Success_Offering__c;
        console.log('Offering method= '+this.offeringMethod);
        console.log('signature success= '+this.signatureSuccesssIcon);
    }

    renderedCallback() {
        //console.log("Rendered icon==>"+signatureSuccesssIcon);
        console.log("Rendered renderedCallback sets ==>",JSON.stringify(this.accountMembersWrp));
       /* var primcon=this.primaryContacts;
        if(primcon.length>0){             
            this.supportAccId=this.primaryContacts[0].AccountId;
            console.log("Rendered ==>",this.supportAccId);
        }*/
    }
}