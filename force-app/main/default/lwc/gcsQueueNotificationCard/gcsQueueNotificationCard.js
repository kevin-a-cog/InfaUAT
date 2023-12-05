import { LightningElement,api } from 'lwc';

export default class GcsQueueNotificationCard extends LightningElement {
    @api case;

    get caseOwnerName(){
        return this.case.caseOwnerName ? this.case.caseOwnerName : '';
    }

    get subject(){
        return this.case.subject ? this.case.subject : '';
    }

    get timezone(){
        return this.case.timezone ? this.case.timezone : '';
    }

    get product(){
        return this.case.product ? this.case.product : '';
    }

    get supportAccountName(){
        return this.case.supportAccountName ? this.case.supportAccountName : '';
    }
}