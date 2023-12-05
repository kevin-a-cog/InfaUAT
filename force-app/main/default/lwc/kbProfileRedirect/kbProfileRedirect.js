import KB_Network_Host from '@salesforce/label/c.KB_Network_Host';
import KB_Community_Name_In_URL from '@salesforce/label/c.KB_Community_Name_In_URL';

import { LightningElement, api, track } from 'lwc';

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



export default class KbProfileRedirect extends LightningElement {

    connectedCallback() {
        try {
            Log('log', 'Method : KbProfileRedirect connectedCallback');
            var varCurrentURL = document.location.href;
            if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/profile/') != -1) {                
                var varDataToFind = document.location.origin + KB_Community_Name_In_URL;
                var varDataToReplace = 'https://' + KB_Network_Host;
                varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
                document.location.replace(varCurrentURL);
            }
        }
        catch (error) {
            Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
            this.handleAfterPageLoad();
        }
    }
}