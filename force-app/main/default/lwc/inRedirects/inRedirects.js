import { LightningElement, track } from 'lwc';

import IN_CommunityName from '@salesforce/label/c.IN_CommunityName';
import eSupport_Community_URL from '@salesforce/label/c.eSupport_Community_URL';
import IN_OnlineHelp_Url from '@salesforce/label/c.IN_OnlineHelp_Url';

//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
    try {
        if (ISDEBUGENABLED == true || parType == 'error') {
            if (parType == 'log') {
                console.log(parMessage);
            }
            else if (parType == 'error') {
                console.error(parMessage);
            }
            else if (parType == 'warn') {
                console.warn(parMessage);
            }
        }
    } catch (err) {
        console.log('Utility Log : ' + err.message);
    } finally {

    }
}
//For Loggging in Console

const ERRORMESSAGE = "Invalid Page";
export default class InRedirects extends LightningElement {

    @track errorMessage = "";

    connectedCallback() {
        try {
            Log('log', 'Method : inRedirects connectedCallback');
            var varCurrentURL = document.location.href;
            if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/ideas/') != -1) {
                
                var varNewURL = IN_CommunityName + 'ideas';
                window.open(varNewURL, '_self');
                
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/thread/') != -1) {
                var varNewURL = IN_CommunityName + 'global-search/%20#t=Blog&f:@incontenttype=[Discussion]';
                window.open(varNewURL, '_self');
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/message/') != -1) {
                var varNewURL = IN_CommunityName + 'global-search/%20#t=Blog&f:@incontenttype=[Message]';
                window.open(varNewURL, '_self');
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/events/') != -1) {
                var varNewURL = IN_CommunityName + 'event-landing';
                window.open(varNewURL, '_self');
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/downloadsview.jspa') != -1) {
                var varNewURL = eSupport_Community_URL + 'hotfix-downloads';
                window.open(varNewURL, '_self');
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/onlinehelp/') != -1) {
                var urlPart = document.location.pathname.substring((document.location.pathname.lastIndexOf('/') + 1));
                var varNewURL = IN_OnlineHelp_Url + '/' + urlPart;
                window.open(varNewURL, '_self');
            }
        }
        catch (error) {
            Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
            this.handleAfterPageLoad();
        }
    }
}