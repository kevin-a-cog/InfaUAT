/**************************************************************************
JS file Name: knowledgeUnpublished.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 15-October-2020
Purpose: Holds all the function required for Article Preview Page.
Version: 1.0


Modificaiton History


  Tag       |  Date             |  Modified by              |  Jira reference   |   ChangesMade
   1        |  15-Oct-2020      |  Sathish R                |                   |   Initial Version
   2        |  11-Jan-2021      |  Sathish R                |                   |   Hiding of description field for FAQ, How To and WhitePaper Record Type
   3        |  23-Aug-2021      |  Sathish R                |   I2RT-870        |   "Copy URL" option on Pending Technical Review articles in the Internal Search Results page
   4        |  17-Apr-2023      | Deeksha Shetty            |   I2RT-8162       |    Article Details not showing up on Parameter articles in preview mode.

***************************************************************************/
import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import IS_GUEST from '@salesforce/user/isGuest';

import getArticleForPreview from '@salesforce/apex/KBLWCHandler.getArticleForPreview';
import getArticleByURLName from '@salesforce/apex/KBLWCHandler.getArticleByURLName';
import PendingTRMsg from '@salesforce/label/c.KB_MSG_Pending_TR';
import kbURL from '@salesforce/label/c.KB_URL';
import getloggedinprofile from '@salesforce/apex/KBLWCHandler.getloggedinprofile';

export default class KnowledgeUnpublished extends LightningElement {
    @wire(CurrentPageReference) currentPageReference;

    @track kavId;
    viewArticle =false;
    @track showSpinner = true;
    @track isInternal = false;
    @track isExternal = true;
    @track isPreview = false;

    @track hideDescription = true;
    @track hideAddlInfo = true;
    @track hideAltQuestions = true;
    @track hideInternalNotes = true;
    @track hideAlsoAppliesTo = true;
    @track hideIndustry = true;
    @track hideSolution = true;
    @track hideProductComponent = true;
    @track hideDocumentPriority = true;
    @track hideProblemType = true;
    @track hideProjectPhases = true;
    @track hideUserTypes = true;

    //Tag 4 starts
    @track hideParamName = true;
    @track hideDefinition = true;
    @track hideCompApplicable = true;
    @track hideParamDatatype = true;
    @track hiderecomValue = true;
    @track hideBehavWithDefVal = true;
    @track hideAltVal = true;
    @track hideBehavWithAltVal = true;
    @track hidePossErrSymp = true;
    @track hideErrorSignatures = true;
    @track hideStepsToconfigParam = true;
    @track hideAddInfo2 = true;

    @track paramName='';
    @track definition='';
    @track compApplicable='';
    @track paramDatatype='';
    @track recomValue='';
    @track behavWithDefVal='';
    @track altVal='';
    @track behavWithAltVal='';
    @track possErrSymp='';
    @track errorSignatures='';
    @track stepsToconfigParam='';
    @track addInfo2='';
    //Tag 4 ends

    @track urlName;
    @track recordId;

    @track title='';
    @track description='';
    @track solution='';
    @track addlInfo='';

    @track primaryProduct='';
    @track productVersion='';
    @track productComponent='';
    @track alsoAppliesTo='';

    @track problemType='';
    @track userTypes='';
    @track projectPhases='';
    @track urlValue='';

    @track alternateQuestions='';
    @track internalNotes='';
    @track keywords='';
    @track documentPriority='';
    @track language='';
    @track expiryTerm='';
    @track industry='';

    @track visibleInPkb='';

    @track articleCreatedDate='';
    @track createdBy='';
    @track lastPublishedDate='';
    @track lastModifiedBy='';

    @track pendingTRMsg = PendingTRMsg;

    article;

      paramLang = 'en_US';
      
    isGuest = IS_GUEST;

    @track isCommunityUser = true;
    
    renderedCallback() {
       
    }

    connectedCallback() {
        try {

            getloggedinprofile()
                .then(result => {
                    console.log('External User : ', result);
                    if (result) {
                        this.isCommunityUser = true;
                    }
                    else {
                        this.isCommunityUser = false;
                    }

                })
                .catch(error => {
                    this.error = error;
                    console.log('error while performing Profile Id check' + this.error);
                });
           
        
            //this.urlName = this.currentPageReference.state.number;
            const param = 'c__number';
            this.urlName = this.getUrlParamValue(window.location.href, param);
        
            console.log('urlName=' + this.urlName);

            /*  if(this.currentPageReference.state.lang){
                  this.paramLang = this.currentPageReference.state.lang;
              } */
            if (this.currentPageReference.state.language) {
                this.paramLang = this.currentPageReference.state.language;
            }
            console.log('param language', this.paramLang);
            if (this.currentPageReference.state.internal) {
                this.isInternal = true;
                this.isExternal = false;
            }
            console.log('isInternal=' + this.isInternal);
            console.log('isExternal=' + this.isExternal);

            if (this.currentPageReference.state.preview) {
                this.isPreview = true;
            }
            console.log('isPreview=' + this.isPreview);

            if (this.isPreview) {
        
                console.log('calling getArticleForPreview');
                getArticleForPreview({ kavId: this.urlName })
                    .then(result => {
                        console.log("result - " + JSON.stringify(result));
                        if (result) {
                            this.handleAfterPageLoad();
                            this.parseArticleInfo(result);
                            console.log("article info - " + JSON.stringify(this.article));
                        }
                        else {
                            this.doArticleRedirect(); /*<3>*/
                        }                     
                    })
                    .catch(error => {
                        console.log("error - " + JSON.stringify(error));
                        this.handleAfterPageLoad();
                    });
            } else {
                getArticleByURLName({ urlName: this.urlName, lang: this.paramLang })
                    .then(result => {
                        console.log("result - " + JSON.stringify(result));
                        if (result) {
                            this.handleAfterPageLoad();
                            this.parseArticleInfo(result);
                            if (!this.isCommunityUser)
                                this.viewArticle = true;
                            console.log("article info - " + JSON.stringify(this.article));
                        }
                        else {
                            this.doArticleRedirect(); /*<3>*/
                        }
                        
                    })
                    .catch(error => {
                        console.log("error - " + JSON.stringify(error));
                        this.handleAfterPageLoad();
                    });
            }
        }
        catch (error) {
            console.log('error' + 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
            this.handleAfterPageLoad();
        }
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    getLanguageName(langCode){
        var langName = 'English';
        if(langCode == 'ja'){
            langName = 'Japanese';
        }else if(langCode == 'de'){
            langName = 'German';
        }else if(langCode == 'zh_TW'){
            langName = 'Chinese Traditional';
        }else if(langCode == 'zh_CN'){
            langName = 'Chinese Simplified';
        }
        return langName;
    }
    doArticleOpen(event) {
        var recordurl = kbURL +'/'+ this.recordId + "/view";
        window.location.assign(recordurl);
        
    }
    parseArticleInfo(articleInfo) {            
            var varTitleValue = '';
            var varRecordTypeValue = '';
        var varArticleNumberValue = '';
        var varIsPAMOrSupportOrRelease = false;
            try {
                  varTitleValue = articleInfo.Title;
                  varRecordTypeValue = articleInfo.Article_Type__c;
                  varArticleNumberValue = articleInfo.ArticleNumber;
                  fnSetOmniturePageDetails(varRecordTypeValue, varArticleNumberValue, varTitleValue);
            
                  fnCheckTillUserNameAvailable(0);
            }
            catch (ex) {
                  console.error('Method : parseArticleInfo :' + ex.message);
            }
          
        if (articleInfo.Article_Type__c.trim().toString().toLowerCase() == "pam eol support statement" || articleInfo.Article_Type__c.trim().toString().toLowerCase() == "product release" || articleInfo.Article_Type__c.trim().toString().toLowerCase() == "support guide" || articleInfo.Article_Type__c.trim().toString().toLowerCase() == "rca")
        {
            varIsPAMOrSupportOrReleaseOrRCA = true;
        }
          
        this.article = articleInfo;

        this.recordId = articleInfo.Id;
        console.log('recordId='+this.recordId);

        this.title = articleInfo.Title;
        console.log('title='+this.title);
        
        this.urlValue = articleInfo.UrlName;
       
        if (articleInfo.Solution__c) {
            console.log('display' + articleInfo.Solution__c)
            this.solution = articleInfo.Solution__c;
            this.hideSolution = false;
            
        }

        /*<2>*/
        if(articleInfo.Description__c && articleInfo.Article_Type__c.trim().toString().toLowerCase() != "faq" && articleInfo.Article_Type__c.trim().toString().toLowerCase() != "how to" && articleInfo.Article_Type__c.trim().toString().toLowerCase() != "whitepaper"){
            this.description = articleInfo.Description__c;
            this.hideDescription = false;
        }
        /*</2>*/
        if(articleInfo.Additional_Information__c && (!varIsPAMOrSupportOrRelease)){
            this.addlInfo = articleInfo.Additional_Information__c;
            this.hideAddlInfo = false;
        }
        if(articleInfo.Alternate_Questions__c && (!varIsPAMOrSupportOrRelease)){
            this.alternateQuestions = articleInfo.Alternate_Questions__c;
            this.hideAltQuestions = false;
        }
        if(articleInfo.Internal_Notes__c && (!varIsPAMOrSupportOrRelease)){
            this.internalNotes = articleInfo.Internal_Notes__c;
            this.hideInternalNotes = false;
        }

        /* Tag 4 starts */

        if(articleInfo.Parameter_Name__c && (!varIsPAMOrSupportOrRelease)){
            this.paramName = articleInfo.Parameter_Name__c;
            this.hideParamName = false;
        }
        if(articleInfo.Definition__c && (!varIsPAMOrSupportOrRelease)){
            this.definition = articleInfo.Definition__c;
            this.hideDefinition = false;
        }
        if(articleInfo.Component_Applicable__c && (!varIsPAMOrSupportOrRelease)){
            this.compApplicable = articleInfo.Component_Applicable__c;
            this.hideCompApplicable = false;
        }
        if(articleInfo.Parameter_Data_Type__c && (!varIsPAMOrSupportOrRelease)){
            this.paramDatatype = articleInfo.Parameter_Data_Type__c;
            this.hideParamDatatype = false;
        }
        if(articleInfo.Recommended_Value__c && (!varIsPAMOrSupportOrRelease)){
            this.recomValue = articleInfo.Recommended_Value__c;
            this.hiderecomValue = false;
        }
        if(articleInfo.Behavior_with_Default_Value__c && (!varIsPAMOrSupportOrRelease)){
            this.behavWithDefVal = articleInfo.Behavior_with_Default_Value__c;
            this.hideBehavWithDefVal = false;
        }
        if(articleInfo.Behavior_with_Alternate_value__c && (!varIsPAMOrSupportOrRelease)){
            this.behavWithAltVal = articleInfo.Behavior_with_Alternate_value__c;
            this.hideBehavWithAltVal = false;
        }
        if(articleInfo.Alternate_Value__c && (!varIsPAMOrSupportOrRelease)){
            this.altVal = articleInfo.Alternate_Value__c;
            this.hideAltVal = false;
        }
        if(articleInfo.Possible_Error_Symptoms__c && (!varIsPAMOrSupportOrRelease)){
            this.possErrSymp = articleInfo.Possible_Error_Symptoms__c;
            this.hidePossErrSymp = false;
        }
        if(articleInfo.Error_Signatures__c && (!varIsPAMOrSupportOrRelease)){
            this.errorSignatures = articleInfo.Error_Signatures__c;
            this.hideErrorSignatures = false;
        }
        if(articleInfo.Steps_to_configure_the_parameter__c && (!varIsPAMOrSupportOrRelease)){
            this.stepsToconfigParam = articleInfo.Steps_to_configure_the_parameter__c;
            this.hideStepsToconfigParam = false;
        }
        if(articleInfo.Any_additional_details_like_Screenshots__c && (!varIsPAMOrSupportOrRelease)){
            this.addInfo2 = articleInfo.Any_additional_details_like_Screenshots__c;
            this.hideAddInfo2 = false;
        }
         /* Tag 4 ends */
        
        this.primaryProduct = articleInfo.Primary_Product__c;
        this.productVersion = articleInfo.Product_Version__c;

        if(articleInfo.Product_Component__c && (!varIsPAMOrSupportOrRelease)){
            this.productComponent = articleInfo.Product_Component__c;
            this.hideProductComponent = false;
        }
        
        if(articleInfo.Also_Applies_To__c){
            this.alsoAppliesTo = articleInfo.Also_Applies_To__c;
            this.hideAlsoAppliesTo = false;
        }

        this.keywords = articleInfo.Keywords__c;
        if(articleInfo.Document_Priority__c && (!varIsPAMOrSupportOrRelease)){
            this.documentPriority = articleInfo.Document_Priority__c;
            this.hidDocumentPriority = false;
        }        
        this.language = this.getLanguageName(articleInfo.Language);
        this.expiryTerm = articleInfo.Expiry_Term__c;
        this.visibleInPkb = 'No';
        if(articleInfo.Visible_In_Public_Knowledge_Base__c){
            this.visibleInPkb = 'Yes';
        }
        
        if(articleInfo.Problem_Type__c && (!varIsPAMOrSupportOrRelease)){
            this.problemType = articleInfo.Problem_Type__c;
            this.hidProblemType = false;
        }        
        if(articleInfo.User_Types__c && (!varIsPAMOrSupportOrRelease)){
            this.userTypes = articleInfo.User_Types__c;
            this.hideUserTypes = false;
        }
       
       
        if(articleInfo.Project_Phases__c && (!varIsPAMOrSupportOrRelease)){
            this.projectPhases = articleInfo.Project_Phases__c;
            this.hidProjectPhases = false;
        } 
        if(articleInfo.Industry__c && (!varIsPAMOrSupportOrRelease)){
            this.industry = articleInfo.Industry__c;
            this.hideIndustry = false;
        }

        this.articleCreatedDate = (new Date(articleInfo.ArticleCreatedDate)).toLocaleString();
        this.createdBy = articleInfo.Created_by_Formula__c;
        this.lastPublishedDate = (new Date(articleInfo.LastPublishedDate)).toLocaleString();
        this.lastModifiedBy = articleInfo.Last_Modified_By_Formula__c;
      }
    /*<3>*/
    getParameterByName(name) {
        var url = window.location.href
        name = name.replace(/[\[\]]/g, '\\$&');
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }
    
    doArticleRedirect() {
        try {
            var varCurrentURL = document.location.href;
            if (varCurrentURL.toString().toLowerCase().trim().indexOf('/s/articlepreview') != -1) {
                             
                var varCurrentURLName = this.getParameterByName('c__number');
                var varCurrentURLNameWithAndToRemove = 'c__number=' + varCurrentURLName + '&';
                var varCurrentURLNameToRemove = 'c__number=' + varCurrentURLName;
  
                varCurrentURL = varCurrentURL.replace('/s/articlepreview', '/s/article/' + varCurrentURLName);
                varCurrentURL = varCurrentURL.replace(varCurrentURLNameWithAndToRemove, '');
                varCurrentURL = varCurrentURL.replace(varCurrentURLNameToRemove, '');
  
                var varNewURL = varCurrentURL;
                window.open(varNewURL, '_self');                
            }
        }
        catch (error) {
            console.log('error' + 'Method : doArticleRedirect; Catch Error :' + error.message + ' : ' + error.stack);
            this.handleAfterPageLoad();
        }
    }

    handleAfterPageLoad() {
        try {
            this.showSpinner = false;
        }
        catch (error) {
            console.log('error' + 'Method : handleAfterPageLoad; Catch Error :' + error.message + " : " + error.stack);
        }
    }
    /*</3>*/
}