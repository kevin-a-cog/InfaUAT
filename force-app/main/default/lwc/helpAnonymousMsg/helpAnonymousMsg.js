import { LightningElement, track } from 'lwc';
import IN_account_login from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import USER_ID from '@salesforce/user/Id';

export default class HelpAnonymousMsg extends LightningElement {
    @track loginUrl = IN_account_login+"/login.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));
    @track registerUrl = IN_account_login+"/registration.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));

    @track isLoggedInUserId = USER_ID;
}