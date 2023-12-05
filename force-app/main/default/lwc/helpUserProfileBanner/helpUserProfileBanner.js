import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';

export default class HelpUserProfileBanner extends LightningElement {
    @api recordId;
    profileTitle;
    urlId;

    constructor() {
        super();
        if (window.location.pathname.includes('/informaticaNetwork/s/')) {
            this.urlId = window.location.pathname.toString().split('/')[4];
        }
        else {
            this.urlId = window.location.pathname.toString().split('/')[3];
        }
        console.log('URL Id='+this.urlId)

        if (userId == undefined) {
            this.profileTitle = 'User Profile';
        }
        else if (userId == this.urlId) {
            this.profileTitle = 'My Profile';
        }
        else {
            this.profileTitle = 'User Profile';
        }

    }

}