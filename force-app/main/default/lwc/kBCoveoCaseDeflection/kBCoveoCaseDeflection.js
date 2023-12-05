import { LightningElement, track, api, wire } from "lwc";
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMin";
import CoveoJsFrameworkOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthers";

import getSearchToken from "@salesforce/apex/CoveoKBSearch.getSearchToken";

import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class KBCoveoCaseDeflection extends LightningElement {

    @api comptitle = "Recommended Solutions";
    @api compname = "communityCaseDeflectionCoveo";
    @api compsearchhub = "CaseCreationTechnical";

    searchtoken;
    varCaseDeflection;

    connectedCallback() {

        //Loading CoveoFullSearch CSS
        loadStyle(this, CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css")
            .then(() => {

            })
            .catch(error => {
                console.error("error kBCoveoCaseDeflection CoveoFullSearch");
            });
        //Loading CoveoFullSearch CSS


        getSearchToken()
            .then(result => {
                this.searchtoken = JSON.parse(result).APISearchToken;
                var varcontentIDKey = '@sysclickableuri';
                var varcontentIDValue = document.location.href;
                var varcontentType = 'Knowledge';
                var varToken = this.searchtoken;

                //Coveo Analytics - Log View Event
                loadScript(this, CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/templates/templatesNew.js")
                    .then(result => {

                        // if (varToken != "") {
                        //     coveoua('init', varToken);
                        // }
                        // coveoua('send', 'pageview', {
                        //     anonymous: true,
                        //     contentIdKey: varcontentIDKey,
                        //     contentIdValue: varcontentIDValue,
                        //     contentType: varcontentType
                        // });
                        
                        //Loading CoveoJsSearch JS
                        loadScript(this, CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.min.js")
                            .then(() => {
                                try {                                
                                    var endpointURI = "https://platform.cloud.coveo.com/rest/search";

                                    Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                                        restUri: endpointURI,
                                        accessToken: varToken,                                      
                                        renewAccessToken: function () {                                        
                                        }
                                    });

                                    this.varCaseDeflection = this.template.querySelector(".CoveoSearchInterface")

                                    Coveo.init(this.varCaseDeflection);

                                    Coveo.$$(this.varCaseDeflection).on("deferredQuerySuccess", function (e, response) {
                                        if (response.results.totalCount > 0) {
                                            if (e.currentTarget.parentElement.className == "divcoveocasedeflection") {
                                                e.currentTarget.parentElement.style.display = "block";
                                            }
                                            console.log("KB reveal recommendation deferredQuerySuccess Count :" + response.results.totalCount);
                                        }

                                    });

                                }
                                catch (e) {
                                    console.error("error kBCoveoCaseDeflection Then method CoveoJsSearch ");
                                }

                            })
                            .catch(error => {
                                console.error("error kBCoveoCaseDeflection CoveoJsSearch");
                            });
                        //Loading CoveoJsSearch JS



                    })
                    .catch(error => {
                        console.error("error kBCoveoCaseDeflection logCoveoAnalyticsArticleView");
                    });

            })
            .catch(error => {
                console.error("error kBCoveoCaseDeflection getSearchToken");
            });

    }   
}