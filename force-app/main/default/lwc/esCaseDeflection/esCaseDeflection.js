import { LightningElement, track, api, wire } from "lwc";
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMin";
import CoveoJsFrameworkOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthers";
import INFAKBSearch from "@salesforce/resourceUrl/INFAKBSearch";

import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";

import { loadStyle, loadScript } from "lightning/platformResourceLoader";

const ISDEBUGENABLED = false;
const ESUPPORTCASEDEFLECTIONTECHNICAL = 'esupportcasedeflectiontechnical';
const ESUPPORTCASEDEFLECTIONGENERALINQUIRY = 'esupportcasedeflectiongeneralinquiry';
const ESUPPORTCASEDEFLECTIONSHIPPING = 'esupportcasedeflectionshipping';
const CASECREATIONEVENTNAME = 'confirmcasecreate';
const INPUTCHANGEEVENTINPUTDETAILS = [
    {
        eventtype: 'inputchange',
        inputCategory: 'product',
        details: {
            input: 'Forecast_Product_for_Coveo__c',
            inputTitle: 'Forcast Product for Coveo'
        },
        placedin: [{ name: ESUPPORTCASEDEFLECTIONTECHNICAL, inputNameUI: 'productDetails', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONSHIPPING, inputNameUI: 'productDetails', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONGENERALINQUIRY, inputNameUI: '', sessionStorageId: '' }]
    },
    {
        eventtype: 'inputchange',
        inputCategory: 'subject',
        details: {
            input: 'Subject',
            inputTitle: 'Subject'
        },
        placedin: [{ name: ESUPPORTCASEDEFLECTIONTECHNICAL, inputNameUI: 'Subject', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONSHIPPING, inputNameUI: 'subject', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONGENERALINQUIRY, inputNameUI: 'subject', sessionStorageId: '' }]
    },
    {
        eventtype: 'inputchange',
        inputCategory: 'description',
        details: {
            input: 'Description',
            inputTitle: 'Description'
        },
        placedin: [{ name: ESUPPORTCASEDEFLECTIONTECHNICAL, inputNameUI: 'description', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONSHIPPING, inputNameUI: 'description', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONGENERALINQUIRY, inputNameUI: 'description', sessionStorageId: '' }]
    },
    {
        eventtype: 'inputchange',
        inputCategory: 'error',
        details: {
            input: 'Error_Code__c',
            inputTitle: 'Error Message'
        },
        placedin: [{ name: ESUPPORTCASEDEFLECTIONTECHNICAL, inputNameUI: 'errorMsg', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONSHIPPING, inputNameUI: '', sessionStorageId: '' },
        { name: ESUPPORTCASEDEFLECTIONGENERALINQUIRY, inputNameUI: '', sessionStorageId: '' }]
    }
];

//For Loggging in Console
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

export default class EsCaseDeflection extends LightningElement {
    
    searchtoken;
    searchhubname;
    searchorgname;
    varCoveoSearchInterface;
    varCoveoAnalytics;

    varlocalproduct = '';
    varlocalsubject = '';
    varlocaldescription = '';
    varlocalerrormessage = '';
    varpreviousproduct = '';
    varprevioussubject = '';
    varpreviousdescription = '';
    varpreviouserrormessage = '';
    varlocalsupportaccountid = '';
    varlocalsupportaccountname = '';
    varSearchKeyword = '';
    varLargeQuery = '';
    varAdvancedQuery = '';
    varConstantQuery = '';
    varCustomAnalyticsData = {};
    varSearchTriggerInputName = '';
    varForAnalyticsInputName = '';
    varForAnalyticsInputTitle = '';
    varForAnalyticsInputCategory = '';
    varForAnalyticsInputValue = '';  
        
    @track triggerforsearch;
    @track placedin;

    fnReNewSearchToken() {
    }

    renderedCallback() {
    }
                
    connectedCallback() {
        try {                      
            this.fnGetSearchToken();
        } catch (error) {
            Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
        }
        return "";
    }
      
    fnGetSearchToken() {
        try {            
            getSearchToken({ strSessionId: '', strUserEmail: '', strUserId: '', strCalledFrom: this.placedin })
                .then((result) => {
                    try {
                        window.esCaseDeflectionTemplate = this;
                        this.searchtoken = JSON.parse(result).APISearchToken;
                        this.searchhubname = JSON.parse(result).APISearchHub;
                        this.searchorgname = JSON.parse(result).SearchOrgName;
                        this.loadComponentResource();
                    } catch (error) {
                        Log('error', 'Method : getSearchToken; then Catch Error :' + error.message + " : " + error.stack);
                    }
                })
                .catch((error) => {
                    Log('error', 'Method : getSearchToken; Catch Error :' + error.message + " : " + error.stack);
                });
        } catch (error) {
            Log('error', 'Method : fnGetSearchToken; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    //Script
    loadComponentResource() {
        try {
            this.loadCoveoStyle();            
        } catch (error) {
            Log('error', 'Method : loadComponentResource; Error :' + error.message + " : " + error.stack);
        }
    }
       
    //Style
    loadCoveoStyle() {
        try {
            //Loading CoveoFullSearch CSS
            loadStyle(
                this,
                CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css"
            ).then(() => {
                this.loadCustomStyle();
            }).catch((error) => {
                Log('error', 'Method : loadCustomStyle - loadStyle; Error :' + error.message + " : " + error.stack);
            });
            //Loading CoveoFullSearch CSS
        } catch (error) {
            Log('error', 'Method : loadCustomStyle Error :' + error.message + " : " + error.stack);
        }
    }
   
    //Style
    loadCustomStyle() {
        try {
            //Loading CoveoFullSearch CSS
            loadStyle(
                this,
                INFAKBSearch + "/Css/esCaseDeflection.css"
            )
                .then(() => {
                    this.loadJquery();
                })
                .catch((error) => {
                    Log('error', 'Method : loadCustomStyle - loadScript; Error :' + error.message + " : " + error.stack);
                });
            //Loading CoveoFullSearch CSS
        } catch (error) {
            Log('error', 'Method : loadCustomStyle; Error :' + error.message + " : " + error.stack);
        }
      
    }
              
    //Script
    loadJquery() {
        try {
            //Loading CoveoJsSearch JS
            loadScript(this, INFAKBSearch + "/Js/Jquery/3.0.0-rc1/jquery-3.0.0-rc1.min.js")
                .then(() => {
                    this.loadCoveoJs();
                })
                .catch((error) => {
                    Log('error', 'Method : loadJquery - loadScript; Error :' + error.message + " : " + error.stack);
                });
            //Loading CoveoJsSearch JS
        } catch (error) {
            Log('error', 'Method : loadJquery Error :' + error.message + " : " + error.stack);
        }
       
    }
   
    //Script
    loadCoveoJs() {
        try {
            //Loading CoveoJsSearch JS
            loadScript(
                this,
                CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.js"
            )
                .then(() => {
                    this.loadCustomTemplateJs();
                })
                .catch((error) => {
                    Log('error', 'Method : loadCoveoJs - loadScript; Error :' + error.message + " : " + error.stack);
                });
            //Loading CoveoJsSearch JS
        } catch (error) {
            Log('error', 'Method : loadCoveoJs; Error :' + error.message + " : " + error.stack);
        }
       
    }
      
    //Script
    loadCustomTemplateJs() {
        try {
            //Coveo Analytics - Log View Event
            loadScript(this, INFAKBSearch + "/Js/InfaESupportCaseDeflectionTemplate.js")
                .then(result => {
                    this.loadCoveoSearch();
                })
                .catch((error) => {
                    Log('error', 'Method : loadCustomTemplateJs - loadCoveoJs; Error :' + error.message + " : " + error.stack);
                });
        } catch (error) {
            Log('error', 'Method : loadCustomTemplateJs; Error :' + error.message + " : " + error.stack);
        }
       
    }

    //Coveo Case Deflection Function
    loadCoveoSearch() {
        try {
            
            var varLoadingFirstTime = true;
            var varLoadingSecondTime = true;            
            this.varCoveoAnalytics = this.template.querySelector(
                ".CoveoAnalytics"
            );
            this.varCoveoAnalytics.setAttribute("data-search-hub", this.searchhubname);
            this.configureOldSearchEndPoint();
        
            this.varCoveoSearchInterface = this.template.querySelector(
                ".CoveoSearchInterface"
            );
            window.CustomCoveoCaseDflection = this.template.querySelector(
                ".CoveoSearchInterface"
            );

            var currentctrl = this;

            Coveo.init(this.varCoveoSearchInterface);
               
            Coveo.$$(this.varCoveoSearchInterface).on(
                "afterInitialization",
                function (e, args) {
                    try {
                        this.CoveoQueryController.usageAnalytics.setOriginContext("CaseCreation");
                    } catch (error) {
                        Log('error', 'Method : afterInitialization; Error :' + error.message + " : " + error.stack);
                    }
                }
            );

            Coveo.$$(this.varCoveoSearchInterface).on(
                "changeAnalyticsCustomData",
                function (e, data) {
                    Log('log', 'Method : changeAnalyticsCustomData ');
                    if (currentctrl.varCustomAnalyticsData.casesubject != undefined && currentctrl.varCustomAnalyticsData.casesubject != 'undefined')
                        data.metaObject.casesubject = currentctrl.varCustomAnalyticsData.casesubject;
                    
                    if (currentctrl.varCustomAnalyticsData.casedescription != undefined && currentctrl.varCustomAnalyticsData.casedescription != 'undefined')
                        data.metaObject.casedescription = currentctrl.varCustomAnalyticsData.casedescription;
                                                           
                    if (currentctrl.varCustomAnalyticsData.accountName != undefined && currentctrl.varCustomAnalyticsData.accountName != 'undefined')
                        data.metaObject.accountName = currentctrl.varCustomAnalyticsData.accountName;
                    
                    if (currentctrl.varCustomAnalyticsData.accountId != undefined && currentctrl.varCustomAnalyticsData.accountId != 'undefined')
                        data.metaObject.accountId = currentctrl.varCustomAnalyticsData.accountId;
                    
                    if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONTECHNICAL) {                         
                        if (currentctrl.varCustomAnalyticsData.product != undefined && currentctrl.varCustomAnalyticsData.product != 'undefined')
                            data.metaObject.product = currentctrl.varCustomAnalyticsData.product;
                
                        if (currentctrl.varCustomAnalyticsData.caseerrormessage != undefined && currentctrl.varCustomAnalyticsData.caseerrormessage != 'undefined')
                            data.metaObject.caseerrormessage = currentctrl.varCustomAnalyticsData.caseerrormessage;
                    }
                    else if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONSHIPPING) {
                        if (currentctrl.varCustomAnalyticsData.product != undefined && currentctrl.varCustomAnalyticsData.product != 'undefined')
                            data.metaObject.product = currentctrl.varCustomAnalyticsData.product;
                    }
                    else if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
                        
                    }

                    //Tag 03 : Start : I2RT-7586 : Adding Article Number for Coveo Reporting(Internal and External)                                        
                    if (data.type == 'ClickEvent' && data.resultData.raw != undefined && data.resultData.raw.infaarticlenumber != undefined) {
                            var articleNo = data.resultData.raw.infaarticlenumber;
                            if (articleNo != undefined) {
                                console.log('ClickEvent : Article Number : ', articleNo);
                                data.metaObject.ArticleNumber = articleNo;
                            }                                    
                    }                    
                    //Tag 03 : End : I2RT-7586
                                                                                                                             
                }
            );

            Coveo.$$(this.varCoveoSearchInterface).on(
                "buildingQuery",
                function (e, data) {
                    try {
                        if (varLoadingFirstTime) {
                            varLoadingFirstTime = false;
                            data.cancel = true;
                        }
                                                
                        data.queryBuilder.fieldsToExclude = ['allfieldvalues', 'infainternalnotes'];

                        if (currentctrl.varlocalsubject != undefined && currentctrl.varlocalsubject !== '') {                           
                            currentctrl.varSearchKeyword = currentctrl.varlocalsubject;
                        }
                        
                        if (currentctrl.varAdvancedQuery.length > 0 && currentctrl.varAdvancedQuery !== '') {
                            currentctrl.varIsQueryPresent = true;
                            data.queryBuilder.advancedExpression.parts.push(currentctrl.varAdvancedQuery);
                        }
                        else {
                            currentctrl.varAdvancedQuery = "$sort(criteria: relevancy)";
                        }
                                         
                        if (currentctrl.varLargeQuery.length > 0 && currentctrl.varLargeQuery !== '') {
                            currentctrl.varIsQueryPresent = true;
                            data.queryBuilder.longQueryExpression.parts.push(currentctrl.varLargeQuery);
                        }
    
                        if (currentctrl.varSearchKeyword.length > 0 && currentctrl.varSearchKeyword !== '') {
                            currentctrl.varIsQueryPresent = true;
                            if (data.queryBuilder.expression.parts.length > 0)
                                data.queryBuilder.expression.parts[0] = currentctrl.varSearchKeyword + ' ' + data.queryBuilder.expression.parts[0];
                            else
                                data.queryBuilder.expression.parts.push(currentctrl.varSearchKeyword);
                        }

                        if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONTECHNICAL) {
                            
                        }
                        else if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONSHIPPING) {
                            if (currentctrl.varConstantQuery.length > 0 && currentctrl.varConstantQuery !== '') {
                                currentctrl.varIsQueryPresent = true;
                                data.queryBuilder.constantExpression.parts.push(currentctrl.varConstantQuery);
                            }                
                        }
                        else if (currentctrl.placedin == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
                            if (currentctrl.varConstantQuery.length > 0 && currentctrl.varConstantQuery !== '') {
                                currentctrl.varIsQueryPresent = true;
                                data.queryBuilder.constantExpression.parts.push(currentctrl.varConstantQuery);
                            }  
                        }
                        
                    } catch (error) {
                        Log('error', 'Method : buildingQuery; Error :' + error.message + " : " + error.stack);
                    }
                    
                }
            );

            Coveo.$$(this.varCoveoSearchInterface).on(
                "deferredQuerySuccess",
                function (e, response) {
                    try {
                        if (response.results.totalCount > 0) {
                            Log('log', "ESupport Case Defelction Result  Count :" + response.results.totalCount);
                        }
                       
                        if ((e.currentTarget.parentElement.className == 'divcustomcoveocasedefelction') && (currentctrl.varIsQueryPresent == true)) {
                            e.currentTarget.parentElement.parentElement.firstChild.style.display = "none";
                            e.currentTarget.parentElement.style.display = "block";
                            //divcustomcoveocasedefelctionmessage
                        }
                        
                    } catch (error) {
                        Log('error', 'Method : deferredQuerySuccess; Error :' + error.message + " : " + error.stack);
                    }
                }
            );         
          
            // Coveo.$$(this.varCoveoSearchInterface).on(
            //     "analyticsEventReady",
            //     function(e, args) {
            //         Log('log',JSON.stringify(args));              
            //     }
            // );           
        } catch (error) {
            Log('error', 'Method : loadCoveoSearch; Error :' + error.message + " : " + error.stack);
        }
    }
          
    triggerSearch() {
        try {
            if (this.varCoveoSearchInterface != null) {
                
                this.varSearchKeyword = '';
                this.varLargeQuery = '';
                this.varAdvancedQuery = '';
                this.varForAnalyticsInputName = '';
                this.varForAnalyticsInputTitle = '';
                this.varForAnalyticsInputCategory = '';
                this.varForAnalyticsInputValue = '';

                if (this.placedin == ESUPPORTCASEDEFLECTIONTECHNICAL) {
                    fnBuildAnalyticAndQueryForTechnicalCase(this);
                }
                else if (this.placedin == ESUPPORTCASEDEFLECTIONSHIPPING) {
                    fnBuildAnalyticsAndQueryForShippingCase(this);
                }
                else if (this.placedin == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
                    fnBuildAnalyticsAndQueryForGeneralCase(this);
                }
            }


            function fnBuildAnalyticAndQueryForTechnicalCase(ctrl) {
                try {
                    ctrl.varCustomAnalyticsData = {};
                    ctrl.varglobalproduct = window.sessionStorage["tech_product"]
                    ctrl.varlocalproduct = window.sessionStorage["fc_product"];
                    ctrl.varlocalsubject = window.sessionStorage["tech_sub"];
                    ctrl.varlocaldescription = window.sessionStorage["tech_desc"];
                    ctrl.varlocalerrormessage = window.sessionStorage["tech_message"];
                    ctrl.varlocalsupportaccountid = window.sessionStorage["tech_account"];
                    ctrl.varlocalsupportaccountname = window.sessionStorage["tech_accountName"];

                    if (ctrl.decideToTriggerSearch() == true) {

                        fnSetAnalyticsInputChangeSource(ctrl);
                        
                        ctrl.varSearchKeyword = '';
                        
                        if (ctrl.varlocalerrormessage != undefined && ctrl.varlocalerrormessage !== '') {
                            if (ctrl.varLargeQuery.length > 0) {
                                ctrl.varLargeQuery += ' ' + ctrl.varlocalerrormessage;
                            }
                            else {
                                ctrl.varLargeQuery = ctrl.varlocalerrormessage;
                            }
                        }
    
                        if (ctrl.varlocaldescription != undefined && ctrl.varlocaldescription !== '') {
                            if (ctrl.varLargeQuery.length > 0) {
                                ctrl.varLargeQuery += ' ' + ctrl.varlocaldescription;
                            }
                            else {
                                ctrl.varLargeQuery = ctrl.varlocaldescription;
                            }
                        }
                       
                        if (ctrl.varglobalproduct != undefined && ctrl.varglobalproduct !== '' && ctrl.varglobalproduct.indexOf("Entitled Products") == -1) {
                            if (ctrl.varlocalproduct != undefined && ctrl.varlocalproduct !== '' && ctrl.varlocalproduct.indexOf("Entitled Products") == -1) {
                                if (ctrl.varLargeQuery.length > 0) {
                                    ctrl.varLargeQuery += ' ' + ctrl.varlocalproduct;
                                }
                                else {
                                    ctrl.varLargeQuery = ctrl.varlocalproduct;
                                }
        
                                ctrl.varAdvancedQuery = "($qre(expression: @athenaProduct=\"" + ctrl.varlocalproduct + "\", modifier: 50)) ($sort(criteria: relevancy))";
                                                            
                                Log('log', 'ESupport Case Defelction buildingQuery');
                            }
                        }
                                     
                        var searchEventCause = { name: 'inputChange', type: 'caseCreation' };
                        var metadata = {};
                        if (ctrl.varForAnalyticsInputName != '') {
                            metadata.input = ctrl.varForAnalyticsInputName;
                            metadata.inputTitle = ctrl.varForAnalyticsInputTitle;
                            metadata.value = ctrl.varForAnalyticsInputValue;
                        }
    
                        ctrl.varCustomAnalyticsData.product = ctrl.varlocalproduct;
                        ctrl.varCustomAnalyticsData.casesubject = ctrl.varlocalsubject;
                        ctrl.varCustomAnalyticsData.casedescription = ctrl.varlocaldescription;
                        ctrl.varCustomAnalyticsData.caseerrormessage = ctrl.varlocalerrormessage;
                        ctrl.varCustomAnalyticsData.accountName = ctrl.varlocalsupportaccountname;
                        ctrl.varCustomAnalyticsData.accountId = ctrl.varlocalsupportaccountid;
                   
                                                                                    
                        Coveo.logSearchEvent(ctrl.varCoveoSearchInterface, searchEventCause, metadata);
                        Coveo.executeQuery(ctrl.varCoveoSearchInterface);
                    }
                } catch (error) {
                    Log('error', 'Method : fnBuildQueryForTechnicalCase Error :' + error.message + " : " + error.stack);
                }
            }
            
            function fnBuildAnalyticsAndQueryForShippingCase(ctrl) {
                try {
                    ctrl.varCustomAnalyticsData = {};
                    ctrl.varglobalproduct = window.sessionStorage["prod_product"]
                    ctrl.varlocalproduct = fnGetForeCaseProduct(ctrl);
                    ctrl.varlocalsubject = window.sessionStorage["prod_sub"];
                    ctrl.varlocaldescription = window.sessionStorage["prod_desc"];
                    ctrl.varlocalerrormessage = '';
                    ctrl.varpreviouserrormessage = '';
                    ctrl.varlocalsupportaccountid = window.sessionStorage["prod_account"];
                    ctrl.varlocalsupportaccountname = window.sessionStorage["prod_accountName"];

                    if (ctrl.decideToTriggerSearch() == true) {

                        fnSetAnalyticsInputChangeSource(ctrl);
                                                                                                         
                        if (ctrl.varlocaldescription != undefined && ctrl.varlocaldescription !== '') {
                            if (ctrl.varLargeQuery.length > 0) {
                                ctrl.varLargeQuery += ' ' + ctrl.varlocaldescription;
                            }
                            else {
                                ctrl.varLargeQuery = ctrl.varlocaldescription;
                            }
                        }
                       
                        if (ctrl.varglobalproduct != undefined && ctrl.varglobalproduct !== '' && ctrl.varglobalproduct.indexOf("Entitled Products") == -1) {
                            if (ctrl.varlocalproduct != undefined && ctrl.varlocalproduct !== '' && ctrl.varlocalproduct.indexOf("Entitled Products") == -1) {
                                if (ctrl.varLargeQuery.length > 0) {
                                    ctrl.varLargeQuery += ' ' + ctrl.varlocalproduct;
                                }
                                else {
                                    ctrl.varLargeQuery = ctrl.varlocalproduct;
                                }
        
                                ctrl.varAdvancedQuery = "($qre(expression: @athenaProduct=\"" + ctrl.varlocalproduct + "\", modifier: 50)) ($sort(criteria: relevancy))";
                                                            
                                Log('log', 'ESupport Case Defelction buildingQuery');
                            }
                        }

                        ctrl.varConstantQuery = '@infaothersoftware==Shipping';
                                     
                        var searchEventCause = { name: 'inputChange', type: 'caseCreation' };
                        var metadata = {};
                        if (ctrl.varForAnalyticsInputName != '') {
                            metadata.input = ctrl.varForAnalyticsInputName;
                            metadata.inputTitle = ctrl.varForAnalyticsInputTitle;
                            metadata.value = ctrl.varForAnalyticsInputValue;
                        }
    
                        ctrl.varCustomAnalyticsData.product = ctrl.varlocalproduct;
                        ctrl.varCustomAnalyticsData.casesubject = ctrl.varlocalsubject;
                        ctrl.varCustomAnalyticsData.casedescription = ctrl.varlocaldescription;
                        ctrl.varCustomAnalyticsData.accountName = ctrl.varlocalsupportaccountname;
                        ctrl.varCustomAnalyticsData.accountId = ctrl.varlocalsupportaccountid;
                                                            
                        Coveo.logSearchEvent(ctrl.varCoveoSearchInterface, searchEventCause, metadata);
                        Coveo.executeQuery(ctrl.varCoveoSearchInterface);
                    }
                  
                } catch (error) {
                    Log('error', 'Method : fnBuildQueryForTechnicalCase Error :' + error.message + " : " + error.stack);
                }
            }
            
            function fnBuildAnalyticsAndQueryForGeneralCase(ctrl) {
                try {
                    ctrl.varCustomAnalyticsData = {};
                    ctrl.varglobalproduct = ''
                    ctrl.varlocalproduct = '';
                    ctrl.varpreviousproduct = '';
                    ctrl.varlocalsubject = window.sessionStorage["admin_sub"];
                    ctrl.varlocaldescription = window.sessionStorage["admin_desc"];
                    ctrl.varlocalerrormessage = '';
                    ctrl.varpreviouserrormessage = '';
                    ctrl.varlocalsupportaccountid = window.sessionStorage["tech_account"];
                    ctrl.varlocalsupportaccountname = window.sessionStorage["tech_accountName"];

                    if (ctrl.decideToTriggerSearch() == true) {

                        fnSetAnalyticsInputChangeSource(ctrl);
                                                                                                          
                        if (ctrl.varlocaldescription != undefined && ctrl.varlocaldescription !== '') {
                            if (ctrl.varLargeQuery.length > 0) {
                                ctrl.varLargeQuery += ' ' + ctrl.varlocaldescription;
                            }
                            else {
                                ctrl.varLargeQuery = ctrl.varlocaldescription;
                            }
                        }
                       
                        // if (ctrl.varglobalproduct != undefined && ctrl.varglobalproduct !== '' && ctrl.varglobalproduct.indexOf("Entitled Products") == -1) {
                        //     if (ctrl.varlocalproduct != undefined && ctrl.varlocalproduct !== '' && ctrl.varlocalproduct.indexOf("Entitled Products") == -1) {
                        //         if (ctrl.varLargeQuery.length > 0) {
                        //             ctrl.varLargeQuery += ' ' + ctrl.varlocalproduct;
                        //         }
                        //         else {
                        //             ctrl.varLargeQuery = ctrl.varlocalproduct;
                        //         }
        
                        //         ctrl.varAdvancedQuery = "($qre(expression: @athenaProduct=\"" + ctrl.varlocalproduct + "\", modifier: 50)) ($sort(criteria: relevancy))";
                                                            
                        //         Log('log', 'ESupport Case Defelction buildingQuery');
                        //     }
                        // }

                        ctrl.varConstantQuery = '@infaothersoftware==("General Inquiry")';
                                     
                        var searchEventCause = { name: 'inputChange', type: 'caseCreation' };
                        var metadata = {};
                        if (ctrl.varForAnalyticsInputName != '') {
                            metadata.input = ctrl.varForAnalyticsInputName;
                            metadata.inputTitle = ctrl.varForAnalyticsInputTitle;
                            metadata.value = ctrl.varForAnalyticsInputValue;
                        }
    
                        //ctrl.varCustomAnalyticsData.product = ctrl.varlocalproduct;
                        ctrl.varCustomAnalyticsData.casesubject = ctrl.varlocalsubject;
                        ctrl.varCustomAnalyticsData.casedescription = ctrl.varlocaldescription;
                        ctrl.varCustomAnalyticsData.accountName = ctrl.varlocalsupportaccountname;
                        ctrl.varCustomAnalyticsData.accountId = ctrl.varlocalsupportaccountid;
                                                            
                        Coveo.logSearchEvent(ctrl.varCoveoSearchInterface, searchEventCause, metadata);
                        Coveo.executeQuery(ctrl.varCoveoSearchInterface);
                    }
                } catch (error) {
                    Log('error', 'Method : fnBuildQueryForTechnicalCase Error :' + error.message + ' : ' + error.stack);
                }
            }

            function fnGetForeCaseProduct(ctrl) {
                var varForecaseProduct = ctrl.varglobalproduct;
                try {
                    if (ctrl.varglobalproduct != undefined && ctrl.varglobalproduct != null && ctrl.varglobalproduct != '' && ctrl.varglobalproduct != '----Unentitled Products----------') {
                        if (!ctrl.varglobalproduct.includes('(On Premise)') && !ctrl.varglobalproduct.includes('(Hosted Single Tenant)') && !ctrl.varglobalproduct.includes('(Hosted Multi Tenant)') && !ctrl.varglobalproduct.includes('(Perpetual)')) {
                            varForecaseProduct = ctrl.varglobalproduct;
                        } else if (ctrl.varglobalproduct.includes('(On Premise)')) {
                            varForecaseProduct = ctrl.varglobalproduct.substring(0, ctrl.varglobalproduct.indexOf('(On Premise)'));
                        } else if (ctrl.varglobalproduct.includes('(Hosted Single Tenant)')) {
                            varForecaseProduct = ctrl.varglobalproduct.substring(0, ctrl.varglobalproduct.indexOf('(Hosted Single Tenant)'));
                        } else if (ctrl.varglobalproduct.includes('(Hosted Multi Tenant)')) {
                            varForecaseProduct = ctrl.varglobalproduct.substring(0, ctrl.varglobalproduct.indexOf('(Hosted Multi Tenant)'));
                        } else if (ctrl.varglobalproduct.includes('(Perpetual)')) {
                            varForecaseProduct = ctrl.varglobalproduct.substring(0, ctrl.varglobalproduct.indexOf('(Perpetual)'));
                        }
                    }
                } catch (error) {
                    Log('error', 'Method : fnGetForeCaseProduct; Error :' + error.message + " : " + error.stack);
                }
                return varForecaseProduct;
            }
            
            function fnSetAnalyticsInputChangeSource(ctrl) {
                try {
                    Log('log', 'Method : fnSetAnalyticsInputChangeSource');
                    if (ctrl.triggerforsearch != '') {
                        var varInputNameArray = ctrl.triggerforsearch.split('###$$$$####');
                        if (varInputNameArray.length > 1) {
                            var varIsFieldFound = false;
                            var varTriggeredInputNameUI = varInputNameArray[1].toString().toLowerCase().trim();
                            for (var i = 0; i < INPUTCHANGEEVENTINPUTDETAILS.length; i++) {
                                if (varIsFieldFound)
                                    break;
                                var varParent = INPUTCHANGEEVENTINPUTDETAILS[i];
                                for (var j = 0; j < varParent.placedin.length; j++) {
                                    var varInputNameUI = varParent.placedin[j].inputNameUI.toString().toLowerCase().trim();
                                    var varName = varParent.placedin[j].name;
                                    if (varInputNameUI == varTriggeredInputNameUI && ctrl.placedin == varName) {
                                        ctrl.varForAnalyticsInputName = varParent.details.input;
                                        ctrl.varForAnalyticsInputTitle = varParent.details.inputTitle;
                                        ctrl.varForAnalyticsInputCategory = varParent.inputCategory;
                                        if (ctrl.varForAnalyticsInputCategory == 'product') {
                                            ctrl.varForAnalyticsInputValue = ctrl.varlocalproduct;
                                        } else if (ctrl.varForAnalyticsInputCategory == 'subject') {
                                            ctrl.varForAnalyticsInputValue = ctrl.varlocalsubject;
                                        } else if (ctrl.varForAnalyticsInputCategory == 'description') {
                                            ctrl.varForAnalyticsInputValue = ctrl.varlocaldescription;
                                        } else if (ctrl.varForAnalyticsInputCategory == 'error') {
                                            ctrl.varForAnalyticsInputValue = ctrl.varlocalerrormessage;
                                        }
                                        varIsFieldFound = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                                            
                } catch (error) {
                    Log('error', 'Method : getInputChangeFieldName; Error :' + error.message + " : " + error.stack);
                }
            }
                       
        } catch (error) {
            Log('error', 'Method : triggerSearch; Error :' + error.message + " : " + error.stack);
        }
    }

    logCaseSubmit() {
        try {
            var submitEventCause = { name: 'submitButton', type: 'caseCreation' };
            var metadata = {};
            Coveo.logCustomEvent(this.varCoveoSearchInterface, submitEventCause, metadata);
            
            // if (this.varCustomAnalyticsData.casesubject != undefined && this.varCustomAnalyticsData.casesubject != 'undefined')
            //     metadata.casesubject = this.varCustomAnalyticsData.casesubject;
        
            // if (this.varCustomAnalyticsData.casedescription != undefined && this.varCustomAnalyticsData.casedescription != 'undefined')
            //     metadata.casedescription = this.varCustomAnalyticsData.casedescription;
                                               
            // if (this.varCustomAnalyticsData.accountName != undefined && this.varCustomAnalyticsData.accountName != 'undefined')
            //     metadata.accountName = this.varCustomAnalyticsData.accountName;
        
            // if (this.varCustomAnalyticsData.accountId != undefined && this.varCustomAnalyticsData.accountId != 'undefined')
            //     metadata.accountId = this.varCustomAnalyticsData.accountId;
        
            // if (this.placedin == ESUPPORTCASEDEFLECTIONTECHNICAL) {
            //     if (this.varCustomAnalyticsData.product != undefined && this.varCustomAnalyticsData.product != 'undefined')
            //         metadata.product = this.varCustomAnalyticsData.product;
    
            //     if (this.varCustomAnalyticsData.caseerrormessage != undefined && this.varCustomAnalyticsData.caseerrormessage != 'undefined')
            //         metadata.caseerrormessage = this.varCustomAnalyticsData.caseerrormessage;
            // }
            // else if (this.placedin == ESUPPORTCASEDEFLECTIONSHIPPING) {
            //     if (this.varCustomAnalyticsData.product != undefined && this.varCustomAnalyticsData.product != 'undefined')
            //         metadata.product = this.varCustomAnalyticsData.product;
            // }
            // else if (this.placedin == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
            
            // }
        } catch (error) {
            
        }
    }


    decideToTriggerSearch() {
        var varIsSearchRequired = false;
        try {
                      
            if (this.placedin == ESUPPORTCASEDEFLECTIONTECHNICAL) {                    
                if (this.varlocalproduct != this.varpreviousproduct) {
                    this.varpreviousproduct = this.varlocalproduct;
                    varIsSearchRequired = true;
                }
    
                if (this.varprevioussubject != this.varlocalsubject) {
                    this.varprevioussubject = this.varlocalsubject;
                    varIsSearchRequired = true;
                }
    
                if (this.varpreviousdescription != this.varlocaldescription) {
                    this.varpreviousdescription = this.varlocaldescription;
                    varIsSearchRequired = true;
                }
    
                if (this.varpreviouserrormessage != this.varlocalerrormessage) {
                    this.varpreviouserrormessage = this.varlocalerrormessage;
                    varIsSearchRequired = true;
                }
            }
            else if (this.placedin == ESUPPORTCASEDEFLECTIONSHIPPING) {
                if (this.varlocalproduct != this.varpreviousproduct) {
                    this.varpreviousproduct = this.varlocalproduct;
                    varIsSearchRequired = true;
                }
    
                if (this.varprevioussubject != this.varlocalsubject) {
                    this.varprevioussubject = this.varlocalsubject;
                    varIsSearchRequired = true;
                }
    
                if (this.varpreviousdescription != this.varlocaldescription) {
                    this.varpreviousdescription = this.varlocaldescription;
                    varIsSearchRequired = true;
                }
                
            }
            else if (this.placedin == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
                if (this.varlocalproduct != this.varpreviousproduct) {
                    this.varpreviousproduct = this.varlocalproduct;
                    varIsSearchRequired = true;
                }
    
                if (this.varprevioussubject != this.varlocalsubject) {
                    this.varprevioussubject = this.varlocalsubject;
                    varIsSearchRequired = true;
                }
    
                if (this.varpreviousdescription != this.varlocaldescription) {
                    this.varpreviousdescription = this.varlocaldescription;
                    varIsSearchRequired = true;
                }
            }                                            
        } catch (error) {
            Log('error', 'Method : decideToTriggerSearch; Error :' + error.message + " : " + error.stack);
        }
        return varIsSearchRequired;
    }

    configureSearchEndPoint() {
        try {
            var token = this.searchtoken;
            var endpointURI = "https://platform.cloud.coveo.com/rest/search";
            var orginternalName = this.searchorgname;
                        
            Coveo.SearchEndpoint.configureCloudV2Endpoint(
                orginternalName,
                token,
                endpointURI,
                { renewAccessToken: function () { } }
            );
        } catch (error) {
            Log('error', 'Method : configureSearchEndPoint; Error :' + error.message + " : " + error.stack);
        }
    }

    configureOldSearchEndPoint() {
        try {
            var token = this.searchtoken;
            var endpointURI = "https://platform.cloud.coveo.com/rest/search";
    
            if (Coveo.SearchEndpoint.endpoints["default"]) {
                Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
                Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = this.fnReNewSearchToken;
            } else {
                Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                    restUri: endpointURI,
                    accessToken: token,
                    renewAccessToken: this.fnReNewSearchToken
                });
            }
                
        } catch (error) {
            Log('error', 'Method : configureOldSearchEndPoint; Error :' + error.message + " : " + error.stack);
        }
    }
  
    @api get escasedeflectionsearch() {        
        Log('log', 'esCaseDeflection escasedeflectionsearch Get Method');
        return this.triggerforsearch;
    }

    set escasedeflectionsearch(value) {
        Log('log', 'esCaseDeflection escasedeflectionsearch Set Method');
        this.triggerforsearch = value;
        if (value != undefined && value.indexOf(CASECREATIONEVENTNAME) > -1) {
            this.logCaseSubmit();
         }
        else if (value != undefined) {
            this.triggerSearch();
        }       
    }

    @api get escasedeflectionplacedin() {        
        Log('log', 'esCaseDeflection escasedeflectionplacedin Get Method');
        return this.placedin;
    }

    set escasedeflectionplacedin(value) {
        Log('log', 'esCaseDeflection escasedeflectionplacedin Set Method');
        this.placedin = value;        
    }
   
}