import { LightningElement } from 'lwc';
import userId from "@salesforce/user/Id";
import IN_account_login from "@salesforce/label/c.IN_account_login";
import Accounts_Saml_Url from "@salesforce/label/c.Accounts_Saml_Url";

export default class HelpUserLogin extends LightningElement {
    connectedCallback(){
        if (userId == undefined) {
            var redirectURI = IN_account_login+"/login.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));
            window.location.assign(redirectURI);
        }
    }
}