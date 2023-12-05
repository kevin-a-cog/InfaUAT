import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getArticleAllLanguages from "@salesforce/apex/KBArticleHandler.getArticleAllLanguages";
import KB_Language from '@salesforce/label/c.KB_Language';

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


function GetLanguageFieldValue(parLanguageCode,thislcl) {
    var varLanguage = '';
    try {
        var varFieldValue = parLanguageCode.trim();
        if (varFieldValue == '') {
            varLanguage = '';
        }
        else {
            varFieldValue = varFieldValue.toLowerCase();                        
            var len = thislcl.AllLanguages.length;
            while (len--) {
                if (len != 0) {
                    var varLangDetails = thislcl.AllLanguages[len - 1].split('$$');
                    if (varLangDetails.length > 0) {
                        if (varLangDetails[1].toLowerCase() == varFieldValue) {
                            varLanguage = varLangDetails[0];
                        }
                    }
                }
            }                      
        }

    } catch (error) {
        Log('error', 'GetLanguageFieldValue error --> ' + JSON.stringify(error, Object.getOwnPropertyNames(error)));
    }
        
    return varLanguage;
}
  
export default class KBLanguageSelector extends LightningElement {
    @api recordId;
    error;
    @track articleAllLanguageList;
    @api selectedLanguage;
    @track selectedUrlName;
    @track selectOptions = [];
    @track isMultiLanguageArticle = false;
    @track AllLanguages = KB_Language.toString().split(';');


    connectedCallback() {
        //this.AllLanguages = KB_Language.toString().split(';');
        getArticleAllLanguages({ kbArticleId: this.recordId })
            .then(result => {
                
                this.articleAllLanguageList = result;
                if (result) {
                   
                    if (result.length > 1) {
                        for (const list of result) {
                            Log('log', 'getArticleAllLanguages');
                            var varLangName = GetLanguageFieldValue(list.Language, this);
                            if (varLangName != '') {
                                const option = {
                                    label: varLangName,
                                    value: list.Language + '$$##$$' + list.UrlName
                                };
                                this.selectOptions = [...this.selectOptions, option];
                                if (this.recordId == list.Id) {
                                    this.selectedLanguage = list.Language + '$$##$$' + list.UrlName;
                                }
                            }
                        }
                        if (this.selectOptions.length > 1)
                            this.isMultiLanguageArticle = true;
                    }
                    else {
                        this.isMultiLanguageArticle = false;
                    }
                    
                                       
                } else if (error) {
                    Log('error', 'getArticleAllLanguages' + JSON.stringify(error, Object.getOwnPropertyNames(error)));
                }

            })
            .catch(error => {
                this.error = error;
                Log('error', 'getArticleAllLanguages' + JSON.stringify(error, Object.getOwnPropertyNames(error)));
                this.articleAllLanguageList = undefined;
            })
    }

    handleChange(event) {
        try {
            var selectedLang = event.detail.value.split('$$##$$')[0];
            var selectedUrlName = event.detail.value.split('$$##$$')[1];
            var previousLang = this.selectedLanguage.split('$$##$$')[0];
            var previousUrlName = this.selectedLanguage.split('$$##$$')[1];
            this.selectedLanguage = event.detail.value;
            
            var varCurrentURL = window.location.href;
            if (varCurrentURL.toLowerCase().indexOf('language=') > -1) {
                varCurrentURL = varCurrentURL.replace('language=' + previousLang, 'language=' + selectedLang);
            
                if (varCurrentURL.trim().indexOf(previousLang) != -1) {
                    varCurrentURL = varCurrentURL.replace('=' + previousLang, '=' + selectedLang);
                }
            }
            else {
                if (varCurrentURL.toLowerCase().indexOf('?') > -1) {
                    varCurrentURL = varCurrentURL.replace('?', '?language=' + selectedLang);
                }
                else {
                    varCurrentURL = varCurrentURL + ('?language=' + selectedLang);
                }
            }
            varCurrentURL = varCurrentURL.replace('/' + previousUrlName, '/' + selectedUrlName);
            window.location.assign(varCurrentURL);           
        }
        catch (error) {
            Log('error', 'Method : renderedCallback; Catch Error :' + error.message + " : " + error.stack);
        }
    }
    
}