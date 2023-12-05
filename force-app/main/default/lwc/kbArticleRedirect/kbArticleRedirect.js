import { LightningElement, api, track } from 'lwc';

import getUrlNameFromArticleNumber from '@salesforce/apex/KBLWCHandler.getUrlNameFromArticleNumber';

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

export default class KbArticleRedirect extends LightningElement {

    @track errorMessage = "";
        
    connectedCallback() {
        try {
            Log('log', 'Method : KbArticleRedirect connectedCallback');
            var varCurrentURL = document.location.href;
            if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/article/') != -1) {
                var varCurrentURLName = document.location.pathname.substring((document.location.pathname.lastIndexOf('/') + 1));

                getUrlNameFromArticleNumber({
                    strArticleNumber: varCurrentURLName
                })
                    .then(result => {
                        if (result != null && result.length > 0) {
                            if (result != varCurrentURLName) {
                                var varNewURL = varCurrentURL.replace(varCurrentURLName, result);
                                window.open(varNewURL, '_self');
                            }
                            else {
                                this.handleAfterPageLoad();
                            }
                        }
                        else {
                            this.handleAfterPageLoad();
                        }
                    })
                    .catch(error => {
                        Log('error', 'Method : connectedCallback getUrlNameFromArticleNumber ; Catch Error :' + error.message + " : " + error.stack);
                        this.handleAfterPageLoad();
                    });
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/?language') != -1) {
                var varDataToFind = 's/global-search/?language';
                var varDataToReplace = 's/global-search/%20?language';
                varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
                window.location.assign(varCurrentURL);
            }
            else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/') != -1) {                
                var varDataToFind = 's/global-search/';
                var varDataToReplace = 's/global-search/%20';
                varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
                window.location.assign(varCurrentURL);
            }
            else {
                this.handleAfterPageLoad();
            }
        }
        catch (error) {
            Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
            this.handleAfterPageLoad();
        }
    }

    renderedCallback() {
        try {
            fnShowArticleLayoutInProgressPanel();
        }
        catch (error) {
            Log('error', 'Method : renderedCallback; Catch Error :' + error.message + " : " + error.stack);
        }        
    }

    handleAfterPageLoad() {
        try {
            this.errorMessage = ERRORMESSAGE;
            document.title = "Error"
            fnHideArticleLayoutInProgressPanel();
        }
        catch (error) {
            Log('error', 'Method : handleAfterPageLoad; Catch Error :' + error.message + " : " + error.stack);
        }
    }
}