/*
 Change History
 ***************************************************************************************************************************
    Modified By	       | 	Date		|	Jira No.		Description					                            Tag
 ***************************************************************************************************************************
    Ankit S          |   24 Aug 2023  |    AR-3366      Global Search functionality is not working when we search   T01
                                                        from experience portal on  My success Plan - fix      
***************************************************************************************************************************

*/

import { api, LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from 'lightning/navigation';
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMin";
import CoveoJsFrameworkJsOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthers";
import CSMCoveoSearch from "@salesforce/resourceUrl/CSMCoveoSearch";
import getSearchToken from "@salesforce/apex/CSMCoveoSearch.getSearchToken";
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import Loading from '@salesforce/label/c.Loading';

export default class CsmCoveoSearch extends LightningElement {
    @api coveoSearchId;
    @track testVar;
    @track boolDisplaySpinner;
    @wire(CurrentPageReference) currentPageReference;
    //Labels.
    label = {
        Loading
    }

    searchtoken;
    searchhubname;
    searchorgname;
    varCoveoSearchInterface;
    varCoveoAnalytics;
    searchBoxRoot;

    

    renderedCallback() {
        console.log('Inside rendered call back : ', Coveo);
    }
    connectedCallback() {
        try {
            this.boolDisplaySpinner = true;
            this.fnGetSearchToken();
        } catch (error) {
            console.error('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    fnReNewSearchToken() {
        window.location.reload();
    }

    fnGetSearchToken() {
        try {
            getSearchToken({ strSessionId: '', strUserEmail: '', strUserId: '', strCalledFrom: 'csmcontentsearch' })
                .then((result) => {
                    try {
                        window.csmDefaultTemplate = this;
                        this.searchtoken = JSON.parse(result).APISearchToken;
                        this.searchhubname = JSON.parse(result).APISearchHub;
                        this.searchorgname = JSON.parse(result).SearchOrgName;
                        this.loadComponentResource();
                    } catch (error) {
                        console.log('error', 'Method : getSearchToken; then Catch Error :' + error.message + " : " + error.stack);
                    }
                })
                .catch((error) => {
                    console.log('error', 'Method : getSearchToken; Catch Error :' + error.message + " : " + error.stack);
                });
        } catch (error) {
            console.log('error', 'Method : fnGetSearchToken; Catch Error :' + error.message + " : " + error.stack);
        }

    }

    loadComponentResource() {
        try {
            this.loadCoveoStyle();
            //this.loadJquery();
        } catch (error) {
            console.log('error', 'Method : loadComponentResource; Error :' + error.message + " : " + error.stack);
        }
    }

    //Style
    loadCoveoStyle() {
        try {

            //Loading CoveoFullSearch CSS
            loadStyle(
                this,
                CoveoJsFrameworkJsOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css"

            ).then(() => {

                this.loadCustomStyle();

            }).catch((error) => {

                console.log('error', 'Method : loadCustomStyle - loadStyle; Error :' + error.message + " : " + error.stack);

            });

            //Loading CoveoFullSearch CSS

        } catch (error) {

            console.log('error', 'Method : loadCustomStyle Error :' + error.message + " : " + error.stack);

        }

    }

    //Style

    loadCustomStyle() {

        try {
            //Loading CoveoFullSearch CSS
            loadStyle(
                this, CSMCoveoSearch + "/coveoStyles.css"
            ).then(() => {
                console.log("Success : coveoStyles.css ")
                this.loadCoveoJs();
            }).catch((error) => {
                console.error('error', 'Method : loadCustomStyle - loadStyle; Error :' + error.message + " : " + error.stack);
            });
            //Loading CoveoFullSearch CSS
        } catch (error) {
            console.error('error', 'Method : loadCustomStyle Error :' + error.message + " : " + error.stack);
        }

    }

    loadCoveoJs() {
        try {
            //Loading CoveoJsSearch JS
            loadScript(
                this,
                CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.js"
            ).then(() => {
                this.loadCustomTemplateJs();
            })
                .catch((error) => {
                    console.log('error', 'Method : loadCoveoJs - loadScript; Error :' + error.message + " : " + error.stack);
                });
            //Loading CoveoJsSearch JS
        } catch (error) {
            console.log('error', 'Method : loadCoveoJs; Error :' + error.message + " : " + error.stack);
        }

    }

    loadCustomTemplateJs() {
        try {
            //Coveo Analytics - Log View Event
            loadScript(this, CSMCoveoSearch + "/csmDefaultTemplateCoveo.js")
                .then(result => {
                    console.log('Coveo Template registration success');
                    this.loadCoveoSearch();
                })
                .catch((error) => {
                    console.log('error', 'Method : loadCustomTemplateJs - loadCoveoJs; Error :' + error.message + " : " + error.stack);
                });
        } catch (error) {
            console.log('error', 'Method : loadCustomTemplateJs; Error :' + error.message + " : " + error.stack);
        }

    }

    loadCoveoSearch() {
        try {

            this.varCoveoAnalytics = this.template.querySelector(
                ".CoveoAnalytics"
            );
            this.varCoveoAnalytics.setAttribute("data-search-hub", "successplansearch");
            this.varCoveoSearchInterface = this.template.querySelector(
                ".CoveoSearchInterface"
            );
            this.varcoveoSearchId = this.template.querySelector(
                "#coveoSearchId"
            );
          
            
            this.varCoveoSearchInterface.setAttribute('data-enable-history', 'true');
            this.configureOldSearchEndPoint();
      
            if (Coveo != 'undefined') {
                Coveo.$$(this.varCoveoSearchInterface).on("buildingQuery", function (e, args) {
                    // Some code to execute when the queryBuilder has just been instantiated...
                    console.log('Inside building query:', args);
                    if (args.queryBuilder.constantExpression.parts.length < 1) {
                        console.log('args : ', args);
                        //args.cancel = true;
                    }
                    var varAdvancedQuery = "@infadocumenttype==successplans";
                    args.queryBuilder.constantExpression.parts.push(varAdvancedQuery);
                });
                this.searchBoxRoot = this.template.querySelector(
                    ".CoveoSearchBox"
                );
                console.log('before coveo init method', this.varCoveoSearchInterface);
                Coveo.init(this.varCoveoSearchInterface, { externalComponents: [this.searchBoxRoot] });
                console.log('After coveo init method', Coveo);

                //T01 - Start
                //Commenting the below piece of code as it was added to read the query term from the url and trigger the Coveo search which is working now OOB
                // Coveo.$$(this.varCoveoSearchInterface).on('afterInitialization', function (e, result) {
                //     if (document.location.pathname.split('/s/global-search/').length > 1) {
                //         if ($('.magic-box-input') != undefined && $('.magic-box-input').find('input').length > 0) {
                //             var searchkeyword = document.location.pathname.split('/s/global-search/')[1];
                //             searchkeyword = decodeURIComponent(searchkeyword);
                //             searchkeyword = searchkeyword.trim();
                //             if (document.location.hash.indexOf('q=') == -1) {							
                //                 Coveo.state(self.varCoveoSearchInterface, 'q', searchkeyword);
                //             }
                //         }
                //     }
                // });
                // Coveo.$$(this.varCoveoSearchInterface).on('deferredQuerySuccess', function (e, result) {
                //     if (document.location.pathname.split('/s/global-search/').length > 1) {
                //         if ($('.magic-box-input') != undefined && $('.magic-box-input').find('input').length > 0) {
                //             var newsearchedWord = Coveo.state(self.varCoveoSearchBox, 'q');
                //             window.location.hash = 'q=' + newsearchedWord;
                //         }
                //     }
                // });
                //T01 - END
            }

        } catch (error) {
            console.log('error', 'Method : loadCoveoSearch; Error :' + error.message + " : " + error.stack);
        }
        finally {
            //Finally, we hide the spinner.
            this.boolDisplaySpinner = false;
        }
    }

    configureOldSearchEndPoint() {
        try {
            console.log('Inside configureOldSearchEndPoint');
            var token = this.searchtoken;
            var endpointURI = "https://platform.cloud.coveo.com/rest/search";
            if (Coveo != 'undefined') {
                if (Coveo.SearchEndpoint.endpoints["default"]) {
                    Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
                    Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = this.fnReNewSearchToken;
                    Coveo.SearchEndpoint.endpoints["default"].options.searchHub = "successplansearch";
                    Coveo.SearchInterface.options.enableHistory = true;

                } else {
                    Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                        restUri: endpointURI,
                        accessToken: token,
                        renewAccessToken: this.fnReNewSearchToken
                    });
                    console.log('Inside configureOldSearchEndPoint : ', Coveo.SearchEndpoint.endpoints.default.accessToken);
                }
            }
            console.log('Inside configureOldSearchEndPoint : coveo :', this.searchhubname);
        } catch (error) {
            console.error('error', 'Method : configureOldSearchEndPoint; Error :' + error.message + " : " + error.stack);
        }
    }

}