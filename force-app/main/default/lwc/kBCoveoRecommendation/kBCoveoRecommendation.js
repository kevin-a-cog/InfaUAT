import { LightningElement, api, wire } from "lwc";
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMin";
import CoveoJsFrameworkOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthers";
import getSearchToken from "@salesforce/apex/CoveoKBSearch.getSearchToken";
import getArticle from '@salesforce/apex/KBLWCHandler.getArticle';
import getArticleDetailsFromCoveo from '@salesforce/apex/CoveoKBSearch.getArticleDetails'; //I2RT-553
import getloggedinprofile from '@salesforce/apex/KBLWCHandler.getloggedinprofile'; //I2RT-553
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
const ARTICLE_FIELDS = [
    'Knowledge__kav.Id',
    'Knowledge__kav.Title',
    'Knowledge__kav.ArticleNumber',
    'Knowledge__kav.Article_Type__c'
];
export default class KBCoveoRecommendation extends LightningElement {
    @api recordId;
    articleno;
    searchtoken;
    varRecommendation;
    kbrecords; //I2RT-553
    isInternaluser = false;
    

    connectedCallback() {
        console.log('kbcoveoRecommendation : recordid : ', this.recordId);
        //Loading CoveoFullSearch CSS
        loadStyle(this, CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css")
            .then(() => {

            })
            .catch(error => {
                console.error("error kBCoveoRecommendations CoveoFullSearch");
            });
        //Loading CoveoFullSearch CSS
        //Start : I2RT-7586 : Adding Article Number for Coveo Reporting(Internal and External)
        // get article field values
        getArticle({articleId: this.recordId}).then(result => {           
            console.log('kBCoveoRecommendations : result value', result);
            this.articleno = result.ArticleNumber; 
            console.log('Article Number : ',result.ArticleNumber);          
        })
        .catch(error => {
            this.error = error;
            console.log('connectedcallback : getArticle : error:', this.error);
        });    
        //End : I2RT-7586

        
        getSearchToken()
            .then(result => {
                this.searchtoken = JSON.parse(result).APISearchToken;
                var varcontentIDKey = '@sysclickableuri';
                var varcontentIDValue = document.location.href;
                var varcontentType = 'Knowledge';
                var varToken = this.searchtoken;

                //Start : I2RT-553 : Article Views, Likes, Case Deflection labels on Search Results page 
                //Check Internal User or not
                getloggedinprofile().then(result => {
                    console.log('getloggedinprofile value', result);
                    if (result != undefined && result == true) {
                        this.template.querySelector('.ArticleMetaDataIsInternalUser').innerHTML = 'NO';
                        document.querySelector(".article-type").parentElement.innerHTML =  document.querySelector(".article-type").parentElement.innerHTML + this.template.querySelector('.ArticleMetaDataCaseDefViewLikeHTML').innerHTML
                        this.isInternaluser = false;
                    }
                    else {
                        this.template.querySelector('.ArticleMetaDataIsInternalUser').innerHTML = 'YES';
                        this.isInternaluser = true;
                        console.log('getArticleDetailsFromCoveo');
                
                        //Start : I2RT-553 : Article Views, Likes, Case Deflection labels on Search Results page                           
                        getArticleDetailsFromCoveo({
                            strSessionToken: this.searchtoken,
                            recid: this.recordId,
                            numOfArticles: '1',
                            viewFilter: 'Internal'
                        })
                            .then(result => {
                    
                                if (JSON.parse(result).APIResponseStatus === 'SUCCESS') {
                                    this.kbrecords = JSON.parse(result).searchDataList;
                                    if (this.kbrecords.length == 0) {
                                        console.log('No KB Articles Found');
                                    }
                                    else {
                                        if (this.kbrecords[0].infakblikes != '')
                                            this.template.querySelector('.ArticleMetaDataLike').innerHTML = this.kbrecords[0].infakblikes;
                                        if (this.kbrecords[0].infakbcasedeflected != '')
                                            this.template.querySelector('.ArticleMetaDataCaseDef').innerHTML = this.kbrecords[0].infakbcasedeflected;
                                        if (this.kbrecords[0].infakblifetimeviews != '')
                                            this.template.querySelector('.ArticleMetaDataView').innerHTML = this.kbrecords[0].infakblifetimeviews;
                            
                                        this.template.querySelector('.ArticleMetaDataCaseDefViewLikeIsComplete').innerHTML = 'YES';

                                        document.querySelector(".article-type").parentElement.innerHTML =  document.querySelector(".article-type").parentElement.innerHTML + this.template.querySelector('.ArticleMetaDataCaseDefViewLikeHTML').innerHTML
                                    }
                                } else {
                                    this.error = JSON.parse(result).ErrorMessage;
                                }
                    
                    
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('error' + JSON.stringify(error));
                            });
                        //End : I2RT-553
                    }
                })
                    .catch(error => {
                        this.error = error;
                        console.log('getloggedinprofile : error:', this.error);
                    }); 
                //End : I2RT-553

                //Coveo Analytics - Log View Event
                loadScript(this, "https://static.cloud.coveo.com/coveo.analytics.js/coveoua.js")
                    .then(result => {

                        if (varToken != "") {
                            coveoua('init', varToken);
                        }
                        coveoua('send', 'pageview', {
                            anonymous: true,
                            contentIdKey: varcontentIDKey,
                            contentIdValue: varcontentIDValue,
                            contentType: varcontentType,
                            ArticleNumber: this.articleno
                        });
                        
                        //Loading CoveoJsSearch JS
                        loadScript(this, CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.js")
                            .then(() => {
                                try {
                                    var endpointURI = "https://platform.cloud.coveo.com/rest/search";

                                    Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                                        restUri: endpointURI,
                                        accessToken: varToken,
                                        renewAccessToken: function () {

                                        }
                                    });

                                    this.varRecommendation = this.template.querySelector(".CoveoRecommendation")

                                    Coveo.initRecommendation(this.varRecommendation);

                                    Coveo.$$(this.varRecommendation).on("deferredQuerySuccess", function (e, response) {
                                        if (response.results.totalCount > 0) {
                                            if (e.currentTarget.parentElement.className == "divrevealrecommendation") {
                                                e.currentTarget.parentElement.style.display = "block";
                                            }
                                            console.log("KB reveal recommendation deferredQuerySuccess Count :" + response.results.totalCount);
                                        }

                                    });

                                }
                                catch (e) {
                                    console.error("error kBCoveoRecommendations Then method CoveoJsSearch ");
                                }

                            })
                            .catch(error => {
                                console.error("error kBCoveoRecommendations CoveoJsSearch");
                            });
                        //Loading CoveoJsSearch JS



                    })
                    .catch(error => {
                        console.error("error kBCoveoRecommendations logCoveoAnalyticsArticleView");
                    });

            })
            .catch(error => {
                console.error("error kBCoveoRecommendations getSearchToken");
            });

    }
}