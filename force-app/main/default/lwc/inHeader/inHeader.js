/*
 Change History
 ***************************************************************************************************************************
    Modified By	       | 	Date		|	Jira No.		Description					                            Tag
 ***************************************************************************************************************************
    NA                 |    NA          |    NA      		Initial version.			                            N/A
    Vignesh Divakaran  |    10/25/2022	|	I2RT-7276		Added isSupportLite__c & isCustomer__c fields to be     T01
                                                            fetched from LDS to redirect paygo users to IN and
                                                            customer users to esupport

    Deeksha Shetty     |   01/27/2023   |    I2RT-7545	    Spammed words are getting posted in product community	T02
    Deeksha Shetty     |   08 May 2023  |    I2RT-8345      Ask a Question - Email Notification - Issue observed    T03
                                                            in New and Update Notification email template     
    Sathish R          |   13 July 2023 |    I2RT-8663      KB Autologin for Customer  - fix                        T04   
    Utkarsh Jain       |   18 July 2023 |    I2RT-8605      Tech_Debt : Assign Search hub to Global Search Box 
                                                            in IN and KB.                                           T05  
    Utkarsh Jain       |   19 July 2023 |    I2RT-8561      Provision to search community name from the global 
                                                            search bar                                              T06   
    Sathish R          |   13 Aug 2023  |    I2RT-8601      Global Search Bar not taking the user to respective 
                                                            community search page on the  - fix                     T07         
***************************************************************************************************************************

*/
import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import NICKNAME_FIELD from '@salesforce/schema/User.CommunityNickname';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import Email_FIELD from '@salesforce/schema/User.Email';
import Photo_FIELD from '@salesforce/schema/User.MediumPhotoUrl';
import IS_SUPPORT_LITE from '@salesforce/schema/User.isSupportLite__c'; //<T01>
import IS_CUSTOMER from '@salesforce/schema/User.isCustomer__c'; //<T01>

import isguest from '@salesforce/user/isGuest';

import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import IN2_StaticResource from '@salesforce/resourceUrl/InformaticaNetwork2';

import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import AccountURL from '@salesforce/label/c.IN_account_login';
import helpFeedbackLink from '@salesforce/label/c.helpFeedbackLink';
import helpSearchPage from '@salesforce/label/c.helpSearchPage';
import getHeaderData from "@salesforce/apex/helpHeaderController.getHeaderData";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import eSupportURL from '@salesforce/label/c.eSupport_Community_URL';
import eSupportLoginURL from '@salesforce/label/c.eSupport_Login_URL';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMin";
import CoveoJsFrameworkOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthers";
import bootstrap from "@salesforce/resourceUrl/bootstrap";
import IN_LogoutURL from '@salesforce/label/c.IN_LogoutURL';
import IN_ChangePassword from '@salesforce/label/c.IN_ChangePassword';
import communityId from "@salesforce/community/Id";
import Okta_Me_Api_Url from '@salesforce/label/c.Okta_Me_Api_Url';
import saveQuestionPost from "@salesforce/apex/helpQuestions.saveQuestionPost";


// import KBPreviewurl from '@salesforce/label/c.KBPreviewurl';
import KB_Community_Saml_Url from '@salesforce/label/c.KB_Community_Saml_Url';
import KB_Community_Name_In_URL from '@salesforce/label/c.KB_Community_Name_In_URL';
import KB_Internal_Network_Switch_LoginURL from '@salesforce/label/c.KB_Internal_Network_Switch_LoginURL';
import CustomerSupportInternalLoginURL from '@salesforce/label/c.CustomerSupportInternalLoginURL';
import checkUserExistence from "@salesforce/apex/KBLWCHandler.checkUserExistence";
import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import getCurrentUsersDetails from "@salesforce/apex/KBContentSearch.getCurrentUsersDetails";
import CustomerSupportLoginURL from '@salesforce/label/c.CustomerSupportLoginURL';
import CustomerSupportSignupURL from '@salesforce/label/c.CustomerSupportSignupURL';

import Success_LogoUrl from '@salesforce/label/c.Success_LogoUrl'; //@19 April,2022 -> SUCCESS Community -> Akhilesh Soni
import isCSMSuccessCommunity from "@salesforce/apex/helpHeaderController.isCSMSuccessCommunity"; //@19 April,2022 -> SUCCESS Community -> Akhilesh Soni
import geteSupportURL from "@salesforce/apex/helpHeaderController.geteSupportURL";
import helpSearchBarSuggestionsNumResults from '@salesforce/label/c.helpSearchBarSuggestionsNumResults';
import helpSearchBarNoResultsText from '@salesforce/label/c.helpSearchBarNoResultsText';
import helpSearchBarNoResultsCtaLabel from '@salesforce/label/c.helpSearchBarNoResultsCtaLabel';
import helpSearchBarSuggestionsHeaderText from '@salesforce/label/c.helpSearchBarSuggestionsHeaderText';
import helpSearchBarCreateDiscCtaLabel from '@salesforce/label/c.helpSearchBarCreateDiscCtaLabel';
import helpSearchBarCreateDiscNoResultsText from '@salesforce/label/c.helpSearchBarCreateDiscNoResultsText';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

import {
    publish, subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";

export default class InHeader extends LightningElement {

    @track appLogo;
    @track cssSearchClass = "infa-navbar-search-form-wrapper";
    @track cssNavListClass = "collapse navbar-collapse";
    @track cssNotificationsClass = "notif-mobile infa-hide";
    @track cssHamburgerClass = "hamburgermenu";
    @track stickyClass = "container infa-app-header";
    @track headerNavList;
    searchIconClicked;
    closeIconClicked;
    hamburgerIconClicked;
    firstName;
    @track profileIcon;
    @track searchField;
    @track userName;
    @track email;
    @track communityName;
    @track navBarData;
    @track successLinks;
    @track helpCenterLinks;
    @track discoverLinks;
    @track learnLinks;
    @track resourcesLinks;
    @track showSpinner = true;
    @track destopHeaderSearhCssClass = "navbar-nav infa-header-navbar-nav desktop-nav";
    profileUrl;
    changePwURL = IN_ChangePassword;
    logoutURL = IN_LogoutURL;

    @track boolIsCSMCommunity = false;
    boolIsEsupportCommunity;
    @track isKBPortal = false;
    @track searchPlaceHolder = 'Search product videos, help resources, documents, discussions etc';
    showtooltext;

    receivedMessage;
    subscription = null;
    @track isAskQuestionModal = false;
    @track heading = 'Ask A Question';
    @api recordId;
    boolIsSupportLiteUser = false; //<T01>
    boolIsCustomerUser = false; //<T01>
    isSpinnerLoading = false; //T02
    finalHelpSearchPage = helpSearchPage;//<T07>


    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, Email_FIELD, Photo_FIELD, FIRST_NAME_FIELD, NICKNAME_FIELD, IS_SUPPORT_LITE, IS_CUSTOMER] //<T01>
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.CommunityNickname.value;
            this.profileIcon = data.fields.MediumPhotoUrl.value;
            this.firstName = data.fields.CommunityNickname.value.split(" ")[0];
            this.email = data.fields.Email.value;
            this.boolIsSupportLiteUser = data.fields?.isSupportLite__c.value; //<T01>
            this.boolIsCustomerUser = data.fields?.isCustomer__c.value; //<T01>
        }
    }

    connectedCallback() {
        console.log('#');
        let url = new URL(encodeURI(window.location.href));
        //Start - <T07>
        try {
            var communityName = document.location.href.replace(document.location.origin,"").substring(0,document.location.href.replace(document.location.origin,"").indexOf("/s/")).trim();
            if(typeof(communityName) != 'undefined' && communityName != '')
            {
                this.finalHelpSearchPage = communityName + helpSearchPage;
            }
            else
            {
                this.finalHelpSearchPage = helpSearchPage;
            }
        } catch (error) {
            this.finalHelpSearchPage = helpSearchPage;
        }
        //End - <T07>

        //Added for KB Community
        if (window.location.href.includes('knowledge.informatica.com') || window.location.href.includes('/support/s/')) {
            this.isKBPortal = true;
        }

        //For eSupport, we check if the user is unauthenticated and redirect to the SAML URL with referrer
        if (isguest && (url.href.includes('support.informatica.com') || url.href.includes('/eSupport/s/') || url.href.includes('esupport-test.informatica.com'))) {
            let strNewURL = `${eSupportLoginURL}?RelayState=${encodeURIComponent(url.href)}`;
            window.location.assign(encodeURI(strNewURL));
        }

        Promise.all([
            loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.theme.default.min.css"),
            loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
            loadStyle(this, bootstrap + "/bootstrap-4.5.3-dist/css/bootstrap.min.css"),
            loadScript(this, bootstrap + "/bootstrap-4.5.3-dist/js/bootstrap.min.js"),
            loadScript(this, 'https://www.informatica.com/content/dam/informatica-aglets/clientlibs/aglets.min.js'),
            loadStyle(this, 'https://www.informatica.com/content/dam/informatica-aglets/clientlibs/aglets.min.css'),
            loadStyle(this, IN_StaticResource + "/css/global.css"),
            loadStyle(this, IN_StaticResource + "/css/overrides.css"),
            loadStyle(this, IN_StaticResource + "/css/fonts.css"),
            loadStyle(this, IN_StaticResource + "/css/fontawesome.min.css"),
            loadScript(this, IN_StaticResource + "/js/fontawesome.min.js"),
        ])
            .then(() => {
                if (isguest && document.title.includes('Home')) {
                    /** START-- adobe analytics */
                    try {
                        util.trackAnonymousHomePage();
                    }
                    catch (ex) {
                        console.log(ex.message);
                    }
                    /** END-- adobe analytics*/
                }
            })
            .catch((error) => {
                console.error("Error Occured", error);
            });
        //@19 April,2022 -> SUCCESS Community -> Akhilesh Soni
        isCSMSuccessCommunity().then(boolIsCSMCommunity => {
            this.boolIsCSMCommunity = boolIsCSMCommunity;
            if (boolIsCSMCommunity) {
                this.searchPlaceHolder = 'Search here';
            }
        });
        geteSupportURL().then(boolIsEsupportCommunity => {
            this.boolIsEsupportCommunity = boolIsEsupportCommunity;
            if (this.boolIsEsupportCommunity) {
                this.searchPlaceHolder = 'Search for Cases';
            }
        });
        //@20 May April,2022 -> Knowledge Base Community -> Utkarsh Jain
        if (window.location.href.includes('knowledge.informatica.com') || window.location.href.includes('/support/s/')) {
            this.isKBPortal = true;

            getCurrentUsersDetails()
                .then((result) => {
                    var userid = result.UserId;
                    var varCurrentUserType = result.UserType;
                    var varCommunityUserName = result.UserName;     
                    //T04 Srart//
                    if (varCurrentUserType == 'Guest') {
                        this.checkAndAutoLoginKBExternalUser();
                    }
                    //T04 End//
                    this.loadUserLogin(userid, varCurrentUserType, varCommunityUserName);                    
                })
                .catch((error) => {
                    console.error('getCurrentUsersDetails errror ', error);
                })

        }

        if (!window.location.href.includes('global-search')) {
            Promise.all([
                loadStyle(this, CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css"),
                loadScript(this, CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.js")//T07
            ])
                .then(() => {
                    let searchBoxRoot;
                    if (window.screen.width > 769) {
                        searchBoxRoot = this.template.querySelector("[data-id='searchbox']");
                    } else {
                        searchBoxRoot = this.template.querySelector("[data-id='searchbox-mobile']");
                    }

                    var varlclCalledFrom = 'infanetworksearch'
                    if ((url.href.includes('support.informatica.com') || url.href.includes('/eSupport/s/') || url.href.includes('esupport-test.informatica.com'))) {
                        varlclCalledFrom = 'esupportsearch'
                    }
                    // Tag 5 Start
                    if ((url.href.includes('knowledge.informatica.com') || url.href.includes('/support/s/') || url.href.includes('infa--uat.sandbox.my.site.com'))) {
                        varlclCalledFrom = 'kbsearchold'
                    }
                    if ((url.href.includes('network.informatica.com') || url.href.includes('informaticaNetwork/s/') || url.href.includes('network-test.informatica.com/s'))) {
                        varlclCalledFrom = 'infanetworksearchbar'
                    }
                    // Tag 5 End

                    getSearchToken({ strCalledFrom: varlclCalledFrom })
                        .then((result) => {
                            try {
                                
                                this.searchtoken = JSON.parse(result).APISearchToken;
                                this.searchhubname = JSON.parse(result).APISearchHub;
                                this.searchorgname = JSON.parse(result).SearchOrgName;
                                
                                var varCoveoAnalytics = this.template.querySelector(".CoveoAnalytics");
                                varCoveoAnalytics.setAttribute("data-search-hub", this.searchhubname);
                                
                                var token = this.searchtoken;
                                var endpointURI = "https://platform.cloud.coveo.com/rest/search";
                                var orginternalName = this.searchorgname;

                                if (this.searchtoken) {
                                    const message = {
                                        sessiontoken: this.searchtoken,

                                    };
                                    publish(this.messageContext, SESSIONID_CHANNEL, message);
                                    this.handleSubscribe();
                                }

                                if (USER_ID == undefined) {
                                    this.invokeAutoLogin();
                                    sessionStorage.setItem('coveoTokenAnonymous', token); //storing the token in Session Storage
                                }
                                else {
                                    sessionStorage.setItem('coveoTokenAuthenticated', token); //storing the token in Session Storage
                                }
                                Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                                    restUri: endpointURI,
                                    accessToken: token,
                                    queryStringArguments: { organizationId: orginternalName, filterField: '@foldfoldingfield', numberOfResults: helpSearchBarSuggestionsNumResults },
                                    renewAccessToken: function () { }
                                });

                                modifySearchSuggestions(searchBoxRoot);

                                handlePopulateOmniBox(this.template.querySelector('.OmniboxSuggestions').innerHTML, searchBoxRoot);

                                Coveo.initSearchbox(
                                    searchBoxRoot,
                                    this.finalHelpSearchPage//<T07>
                                );

                                Coveo.$$(searchBoxRoot).on("afterInitialization", function () {
                                    Coveo.$$(searchBoxRoot).on('doneBuildingQuery', function (e, args) {
                                        /** START-- adobe analytics */
                                        try {
                                            util.trackGlobalSearch(args.queryBuilder.expression.parts[0]);
                                        }
                                        catch (ex) {
                                            console.log(ex.message);
                                        }
                                        /** END-- adobe analytics*/
                                    });
                                });
                            } catch (error) {
                                Log('error', 'Method : getSearchToken; then Catch Error :' + error.message + " : " + error.stack);
                            }
                        })
                        .catch((error) => {
                            Log('error', 'Method : getSearchToken; Catch Error :' + error.message + " : " + error.stack);
                        });
                })
                .catch((error) => {
                    console.error("Error Occured", error);
                });
        } else {
            this.destopHeaderSearhCssClass = "navbar-nav infa-header-navbar-nav desktop-nav in-search-bar-hide";
        }

        if (document.location.pathname.indexOf("global-search") > -1) {
            document.body.removeAttribute('style', 'overflow: hidden;');
        }
        this.getHeader(); //Fetches metadata Records

        function handlePopulateOmniBox(omniboxDivObj, searchBoxRoot) {
            var content;

            Coveo.$$(searchBoxRoot).on('populateOmnibox', function (e, populateOmniboxObj) {

                /************** To call only when the search term is more than 4 characters ***********/
                var searchterm = populateOmniboxObj.completeQueryExpression.word;
                searchterm = searchterm.trim();
                if (searchterm.length < 4) {
                    return false;
                }
                /************** To call only when the search term is more than 4 characters ***********/

                var searchInterface = Coveo.get(searchBoxRoot, Coveo.SearchInterface);

                var query = new Coveo.QueryBuilder();
                query.expression.add(populateOmniboxObj.completeQueryExpression.word);

                // Tag 6 Start
                var promise = new Promise(function (resolve, reject) {
                    Coveo.SearchEndpoint.endpoints['default'].search(query.build())
                        .then(function (results) {
                            var res = [];
                            var itemNumber = 0;
                            var lastItemContentType = '';
                            var currentItemContentType = '';
                            var isheadingAssigned = false;
                            if (results.results.length) {
                                var sortedTopicResult = [];
                                var sortedKBResult = [];
                                var finalSortedArray = [];
                                _.each(results.results, function (result) {
                                    if(result.raw.infadocumenttype == 'Topic'){
                                        sortedTopicResult.push(result);
                                    }else{
                                        sortedKBResult.push(result);
                                    }
                                });
                                finalSortedArray = sortedTopicResult.concat(sortedKBResult);
                                _.each(finalSortedArray, function (result) {
                                    var resultElement = '';
                                    currentItemContentType = result.raw.infadocumenttype;
                                    if((currentItemContentType == 'Topic' && itemNumber == 0) || (currentItemContentType != 'Topic' && itemNumber == 0) || (currentItemContentType != 'Topic' && lastItemContentType == 'Topic') ){
                                        var r = buildHTMLResult(searchBoxRoot, result, itemNumber, currentItemContentType, lastItemContentType, isheadingAssigned);
                                        isheadingAssigned = true;
                                        res.push(r);
                                    }
                                    itemNumber += 1;
                                    resultElement = buildHTMLResult(searchBoxRoot, result, itemNumber, currentItemContentType, lastItemContentType, isheadingAssigned);
                                    isheadingAssigned = false;
                                    if (resultElement != null) {
                                        res.push(resultElement);
                                    }
                                    lastItemContentType = currentItemContentType;
                                });
                                resolve({ element: renderSuggestedResults(res, "") });
                            } else {
                                var x = {
                                    "noResults": "true",
                                    "title": "",
                                    "Title": "",
                                    "ClickUri": ""
                                };
                                var noResultElement = buildHTMLResult(searchBoxRoot, x, itemNumber, currentItemContentType, lastItemContentType, isheadingAssigned);
                                res.push(noResultElement);
                                resolve({ element: renderSuggestedResults(res, x) });
                            }
                        }, function (reason) {
                            resolve({ element: undefined });
                        });
                });
                populateOmniboxObj.rows.push({
                    deferred: promise,
                    element: content
                });
                // Tag 6 End
            });
        }

        function modifySearchSuggestions(searchBoxRoot) {
            Coveo.$$(searchBoxRoot).on('populateOmniboxSuggestions', function (e, populateOmniboxObj) {
                try {
                    if (populateOmniboxObj.omnibox.magicBox.onSuggestions.length == 1) {
                        var reOrderSuggestion = function (suggestions) {
                            if (suggestions.length > 1) {
                                if (suggestions[0].dom != undefined) {
                                    var temp = suggestions[0];
                                    suggestions.push(temp);
                                    suggestions.splice(0, 1);
                                }
                            }
                        };
                        populateOmniboxObj.omnibox.magicBox.onsuggestions = reOrderSuggestion;
                    }
                } catch (e) {
                    console.error('error in modifySearchSuggestion' + e.message);
                }
            });
        }

        var self = this;

        function renderSuggestedResults(results, checkNoResults) {
            var content = document.createElement('div');
            content.setAttribute("style", "display:block");
            if (checkNoResults.noResults) {
                content.appendChild(Coveo.$$('div', { className: 'coveo-omnibox-result-list-header' }, Coveo.$$('span', { className: 'coveo-caption bottom-footer' }, helpSearchBarSuggestionsHeaderText).el).el);
                Coveo._.each(results, function (resultElement) {
                    resultElement.setAttribute("style", "display:none");
                    resultElement.setAttribute("href", self.finalHelpSearchPage);//<T07>
                    content.appendChild(resultElement);
                });
                content = setSuggestionsFooter(content, self);

            } else {
                content.appendChild(Coveo.$$('div', { className: 'coveo-omnibox-result-list-header' }, Coveo.$$('span', { className: 'coveo-icon-omnibox-result-list' }).el, Coveo.$$('span', { className: 'coveo-caption' }, helpSearchBarSuggestionsHeaderText).el).el);
                var hrefDiv = document.createElement('div');
                hrefDiv.setAttribute("style", "display:block");
                //var spanElement = document.createElement('div');
                Coveo._.each(results, function (resultElement) {
                    resultElement.setAttribute("style", "display:block");
                    hrefDiv.appendChild(resultElement);
                });
                content.appendChild(hrefDiv);
                content = setSuggestionsFooter(content, self);
            }
            return content;
        }
        function setSuggestionsFooter(content, self) {
            if (self.isKBPortal) {
                content.appendChild(Coveo.$$('div', { className: 'bottom-footer', style: "width:100%;padding:10px;color: #1d4f76;text-align:center;" }, Coveo.$$('span', { className: 'no-results-text' }, helpSearchBarNoResultsText + " ", Coveo.$$('a', { 'className': 'search-community', 'href': self.finalHelpSearchPage }, helpSearchBarNoResultsCtaLabel).el).el).el);//<T07>
            } else {
                var createDisc = createDiscEventHandle(self, USER_ID);
                content.appendChild(Coveo.$$('div', { className: 'bottom-footer', style: "width:100%;padding:10px;color: #1d4f76;text-align:center;" }, Coveo.$$('span', { className: 'no-results-text' }, helpSearchBarCreateDiscNoResultsText + " ", Coveo.$$(createDisc).el).el).el);
            }
            return content;
        }
        function createDiscEventHandle(self, USER_ID) {
            var createDisc = document.createElement('a');
            createDisc.text = helpSearchBarCreateDiscCtaLabel;
            createDisc.setAttribute('class', 'create-discussion');
            createDisc.addEventListener('click', function (event) {
                try {
                    util.trackButtonClick('ask - new discussion - header search bar - Form started');
                }
                catch (ex) {
                    console.log(ex.message);
                }
                if (USER_ID == undefined) {
                    let url = new URL(window.location.href);
                    let params = new URLSearchParams(url.search);
                    //Adding asked parameter.
                    params.append("asked", true);
                    let redirectUrl = url.toString().concat("?").concat(params.toString());
                    window.location.assign(AccountURL + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(redirectUrl));
                } else if (USER_ID != undefined) {
                    self.isAskQuestionModal = true;
                    document.body.classList += ' modal-open';
                }
            });
            return createDisc;
        }
        function fetchTitle(result) {
            var title = '';
            if (result != null && result.noResults) {
                return title;
            }

            if (result.raw.infadocumenttype == "DocPortal") {
                if (result.raw.guidelandingpage == "Y") {
                    title = result.raw.title;
                } else {
                    title = result.raw.title + ' > ' + result.raw.booktitle;
                    if (typeof (result.raw.athenaproduct) !== 'undefined') {
                        title = title + ' > ' + result.raw.athenaproduct;
                    }
                    if (typeof (result.raw.athenaproductversion) !== 'undefined') {
                        title = title + ' > ' + result.raw.athenaproductversion;
                    }
                    if (typeof (result.raw.hotfix) !== 'undefined') {
                        title = title + ' > ' + result.raw.hotfix;
                    }
                }
            } else if (result.raw.infadocumenttype == "FeedComment") {
                title = "Re: " + result.title.substring(result.title.indexOf("replied on ") + ("replied on ").length);
            } else {
                title = result.title;
            }

            return title;
        }
        // Tag 6 Start
        function buildHTMLResult(searchBoxRoot, result, itemNumber, currentItemContentType, lastItemContentType, isheadingAssigned) {
            var root = Coveo.get(searchBoxRoot, Coveo.SearchInterface);
            var resultElement = "";
            if (resultElement != null && !result.checkNoResults) {
                if(currentItemContentType == 'Topic' && itemNumber == 0 && !isheadingAssigned){
                    resultElement = document.createElement('p');
                    Coveo.Component.bindResultToElement(resultElement, result);
                    Coveo.$$(resultElement).addClass('help-searchbar-result-title');
                    const node = document.createTextNode("Product Communities");
                    resultElement.appendChild(node);
                } else if((currentItemContentType != 'Topic' && lastItemContentType == 'Topic' && !isheadingAssigned) || (currentItemContentType != 'Topic' && itemNumber == 0 && !isheadingAssigned)){
                    resultElement = document.createElement('p');
                    Coveo.Component.bindResultToElement(resultElement, result);
                    Coveo.$$(resultElement).addClass('help-searchbar-result-title');
                    const node = document.createTextNode("Knowledge Base");
                    resultElement.appendChild(node);
                } else {
                    resultElement = document.createElement('a');
                    Coveo.Component.bindResultToElement(resultElement, result);
                    Coveo.$$(resultElement).addClass('');
                    var title = document.createAttribute('title');
                    title.value = result.title;
                    var href = document.createAttribute('href');
                    href.value = result.clickUri;
                    resultElement.setAttributeNode(href);
                    var target = document.createAttribute('target');
                    target.value = '_blank';
                    resultElement.setAttributeNode(target);
                    var hrefText = fetchTitle(result);
                    resultElement.text = hrefText;
                }
            }
            // Tag 6 End

            var bindings = Coveo._.extend({}, root.getBindings(), {
                resultElement: resultElement
            });

            Coveo.Initialization.automaticallyCreateComponentsInside(resultElement, {
                options: root.options.originalOptionsObject,
                bindings: bindings,
                result: result
            });

            if (!result.noResults) {
                Coveo.$$(resultElement).addClass('coveo-omnibox-selectable');
                Coveo.$$(resultElement).on('keyboardSelect', function () {
                    Coveo.logClickEvent(resultElement, Coveo.analyticsActionCauseList.documentOpen, { author: Coveo.Utils.getFieldValue(result, 'author') }, result);
                    window.location.href = result.clickUri;
                });
            } else {
                Coveo.$$(resultElement).addClass('coveo-omnibox-selectable noResultSection');
            }
            Coveo.$$(resultElement).addClass('coveo-omnibox-selectable');

            Coveo.$$(resultElement).on('keyboardSelect', function () {
                Coveo.logClickEvent(resultElement, Coveo.analyticsActionCauseList.documentOpen, { author: Coveo.Utils.getFieldValue(result, 'author') }, result);
                window.location.href = result.clickUri;
            });
            return resultElement;
        }

        if (!this.isKBPortal) {
            try {
                const param = 'asked';
                var paramValue = this.getUrlParamValue(window.location.href, param);
                paramValue = paramValue != null ? decodeURIComponent(paramValue) : null;
                if (paramValue != null && paramValue == 'true') {
                    this.handleAskQuestion();
                }
            } catch (ex) {
                console.error(ex.message);
            }
        }
    }


    disconnectedCallback() {
        this.handleUnsubscribe();
    }


    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        //Subscribing to the message channel
        this.subscription = subscribe(
            this.messageContext,
            SESSIONID_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.receivedMessage = message ? message : "no message";
        if (this.receivedMessage.sessiontoken == null && (this.receivedMessage.isArticleLoaded || this.receivedMessage.isVideoLoaded ||
            this.receivedMessage.isBlogLoaded || this.receivedMessage.isDocLoaded || this.receivedMessage.AuthArticlesLoaded
            || this.receivedMessage.AuthDiscussionLoaded || this.receivedMessage.AuthHomeVideosLoaded || this.receivedMessage.AnonyVideosLoaded
            || this.receivedMessage.CRTLoaded)) {
            const message = {
                sessiontoken: this.searchtoken,
            };
            publish(this.messageContext, SESSIONID_CHANNEL, message);
        }
    }


    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    loadUserLogin(userid, varCurrentUserType, varCommunityUserName) {
        if (userid == "") {
            userid = undefined;
        }
        let communityUserNameEndWith = "";
        var currentURL = window.location.href;

        var oktaBaseUrl;

        let logOutURL = "";
        if (window.location.hostname.includes("knowledge.informatica.com")) {
            communityUserNameEndWith = ".community";
            logOutURL = "/secur/logout.jsp";
            oktaBaseUrl = "https://infapassport.okta.com";
        } else {
            communityUserNameEndWith = ".community.uat";
            logOutURL = "/customersupport/secur/logout.jsp";
            oktaBaseUrl = "https://infportalsb.oktapreview.com";
        }

        let entireLoginURL = CustomerSupportInternalLoginURL.split("=");
        let internalLoginLink;
        let ssoLink = entireLoginURL[0];
        let articleLink = entireLoginURL[1];

        //In this caondition Guest and Authenticated User will get satisfied
        if (userid != undefined) {

            if (varCurrentUserType == "Guest") {
                //*check user existence
                if (currentURL.includes("internal=1") && currentURL.includes("fid=")) {
                    const queryString = window.location.search;
                    const urlParams = new URLSearchParams(queryString);
                    const language = urlParams.get("language");
                    const fedId = urlParams.get("fid");
                    if (fedId != null && fedId != "") {
                        checkUserExistence({ fedId: fedId })
                            .then((result) => {
                                console.error("result from check user existence ", result);
                            })
                            .error((error) => {
                                console.error("result from check user existence ", result);
                            })
                        checkUserAction.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var userPresent = response.getReturnValue();
                                if (userPresent) {
                                    if (
                                        currentURL.includes("internal=1") &&
                                        (userid == undefined ||
                                            (userid != undefined &&
                                                varCommunityUserName.endsWith(
                                                    communityUserNameEndWith
                                                )) ||
                                            varCurrentUserType == "Guest")
                                    ) {
                                        if (currentURL.includes("articlepreview")) {
                                            const cNumber = urlParams.get("c__number");
                                            let temp = currentURL.substring(
                                                currentURL.lastIndexOf("?") + 1,
                                                currentURL.indexOf("&")
                                            );
                                            internalLoginLink =
                                                ssoLink +
                                                "=" +
                                                encodeURIComponent(
                                                    articleLink +
                                                    "articlepreview?language=" +
                                                    language +
                                                    "&c__number=" +
                                                    cNumber +
                                                    "&internal=1"
                                                );
                                        } else {
                                            internalLoginLink =
                                                ssoLink +
                                                "=" +
                                                encodeURIComponent(
                                                    articleLink +
                                                    "article/" +
                                                    currentURL.substring(
                                                        currentURL.lastIndexOf("/") + 1,
                                                        currentURL.indexOf("?")
                                                    ) +
                                                    "?language=" +
                                                    language
                                                );
                                        }
                                        doInternalLogin();
                                    }
                                }
                            }
                        });

                    }
                } else if (
                    userid != undefined &&
                    currentURL.includes("type=external") &&
                    !varCommunityUserName.endsWith(communityUserNameEndWith) &&
                    varCurrentUserType != "Guest"
                ) {
                    //Non Community User and Non Guest User.
                    let salesforceLogOutURL =
                        "https://" + window.location.hostname + logOutURL;
                    $.ajax({
                        url: salesforceLogOutURL,
                        success: function (resp) {
                            console.log("Header Internal" + resp);
                        },
                        error: function (e) {
                            console.error("Header Internal Error: " + e);
                        },
                    });
                    window.location.reload();
                }
            } else {
                if (
                    currentURL.includes("internal=1") &&
                    (userid == undefined ||
                        (userid != undefined &&
                            varCommunityUserName.endsWith(communityUserNameEndWith)))
                ) {
                    const queryString = window.location.search;
                    const urlParams = new URLSearchParams(queryString);
                    const language = urlParams.get("language");

                    let internalLoginLink;
                    if (currentURL.includes("articlepreview")) {
                        const cNumber = urlParams.get("c__number");
                        let temp = currentURL.substring(
                            currentURL.lastIndexOf("?") + 1,
                            currentURL.indexOf("&")
                        );
                        internalLoginLink =
                            ssoLink +
                            "=" +
                            encodeURIComponent(
                                articleLink +
                                "articlepreview?language=" +
                                language +
                                "&c__number=" +
                                cNumber +
                                "&internal=1"
                            );
                    } else {
                        internalLoginLink =
                            ssoLink +
                            "=" +
                            encodeURIComponent(
                                articleLink +
                                "article/" +
                                currentURL.substring(
                                    currentURL.lastIndexOf("/") + 1,
                                    currentURL.indexOf("?")
                                ) +
                                "?language=" +
                                language
                            );
                    }
                    doInternalLogin();
                } else if (
                    userid != undefined &&
                    currentURL.includes("type=external") &&
                    !varCommunityUserName.endsWith(communityUserNameEndWith)
                ) {
                    let salesforceLogOutURL =
                        "https://" + window.location.hostname + logOutURL;

                    $.ajax({
                        url: salesforceLogOutURL,
                        success: function (resp) {
                            location.reload();
                        },
                        error: function (e) {
                            console.error("Header Internal Error: " + e);
                        },
                    });
                }
            }
        } else {
            //*check user existence
            if (currentURL.includes("internal=1") && currentURL.includes("fid=")) {
                const queryString = window.location.search;
                const urlParams = new URLSearchParams(queryString);
                const language = urlParams.get("language");
                const fedId = urlParams.get("fid");
                if (fedId != null && fedId != "") {
                    checkUserAction.setParams({ fedId: fedId });
                    checkUserAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var userPresent = response.getReturnValue();
                            if (userPresent) {
                                if (
                                    currentURL.includes("internal=1") &&
                                    (userid == undefined ||
                                        (userid != undefined &&
                                            varCommunityUserName.endsWith(communityUserNameEndWith)))
                                ) {
                                    if (currentURL.includes("articlepreview")) {
                                        const cNumber = urlParams.get("c__number");
                                        let temp = currentURL.substring(
                                            currentURL.lastIndexOf("?") + 1,
                                            currentURL.indexOf("&")
                                        );
                                        internalLoginLink =
                                            ssoLink +
                                            "=" +
                                            encodeURIComponent(
                                                articleLink +
                                                "articlepreview?language=" +
                                                language +
                                                "&c__number=" +
                                                cNumber +
                                                "&internal=1"
                                            );
                                    } else {
                                        internalLoginLink =
                                            ssoLink +
                                            "=" +
                                            encodeURIComponent(
                                                articleLink +
                                                "article/" +
                                                currentURL.substring(
                                                    currentURL.lastIndexOf("/") + 1,
                                                    currentURL.indexOf("?")
                                                ) +
                                                "?language=" +
                                                language
                                            );
                                    }
                                    doInternalLogin();
                                }
                            }
                        }
                    });
                }
            } else if (
                currentURL.includes("type=external") &&
                !varCommunityUserName.endsWith(communityUserNameEndWith)
            ) {
                let salesforceLogOutURL =
                    "https://" + window.location.hostname + logOutURL;
                $.ajax({
                    url: salesforceLogOutURL,
                    success: function (resp) {
                        console.log("Header Internal" + resp);
                    },
                    error: function (e) {
                        console.error("Header Internal Error: " + e);
                    },
                });
                window.location.reload();
            }
        }
    }

    doInternalLogin() {
        try {
            var varRelativeURL = window.location.href.substring(
                window.location.href.indexOf("/", "https://".length)
            );
            var varKBCommunityNameInURL = KB_Community_Name_In_URL;
            varRelativeURL = varRelativeURL.replace(varKBCommunityNameInURL, "");
            var varCurrentURL = encodeURIComponent(varRelativeURL);
            var varNetworkSwitchLogin = KB_Internal_Network_Switch_LoginURL;
            var varFinalURL = varNetworkSwitchLogin + varCurrentURL;
            window.location.assign(varFinalURL);
        } catch (ex) {
            console.error(
                "error Method : doInternalLogin; Error : " +
                ex.message +
                "||" +
                ex.stack
            );
        }
    }

    renderedCallback() {
        this.showSpinner = false;
    }

    getHeader() {
        getHeaderData()
            .then((result) => {
                if (result) {
                    this.navBarData = result;
                }
            })
            .then(() => {
                //Now, we update URLs & logo based on the community
                if (this.boolIsEsupportCommunity) {
                    this.appLogo = ESUPPORT_RESOURCE + '/eSupportLogo.png';
                    //let subMenuItemMyCase = this.template.querySelector("[data-subsection='My Cases']");
                    //console.log('subMenuItemMyCase',subMenuItemMyCase);
                    //if (subMenuItemMyCase) {
                    //    subMenuItemMyCase.setAttribute('data-id' , subMenuItemMyCase.dataset.id + '/caselist');
                    //}

                    let subMenuItemMySupportAccount = this.template.querySelector("[data-subsection='My Support Account']");
                    if (subMenuItemMySupportAccount) {
                        subMenuItemMySupportAccount.setAttribute('data-id', subMenuItemMySupportAccount.dataset.id + '/supportaccountdetails');
                    }
                } else {
                    this.appLogo = IN_StaticResource + '/Logo.png';
                }
            })
            .catch((error) => {
                console.error('ERROR=' + JSON.stringify(error.body));
            });

    }

    handleOnClick(event) {
        event.preventDefault();
        let section = event.currentTarget.dataset.section;
        let subsection = event.currentTarget.dataset.subsection;
        let link = event.currentTarget.dataset.id;
        let target = event.currentTarget.dataset.value;
        /** START-- adobe analytics */
        try {
            util.trackPageSection(section, subsection);
            util.trackLinkClick(subsection);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(link, target);
    }

    gotofeedbackLink(event) {
        event.preventDefault();
        window.open(helpFeedbackLink, "_self");
    }

    goToUserProfile(event) {
        event.preventDefault();
        this.profileUrl = CommunityURL + 'profile/' + USER_ID;
        window.open(this.profileUrl, "_self");
    }

    goTochangePwURL() {
        window.open(this.changePwURL, "_self");
    }

    goTologoutURL() {
        window.open(this.logoutURL, "_self");
    }

    handleSearchInput(event) {
        this.searchText = event.target.value;
    }

    handleSearchClick() {
        window.location.assign("global-search/" + this.searchText);
    }

    openSubList(event) {
        let navItem = event.target.dataset.item;
        let text = 'ul[data-menu="' + navItem + '"]';
        let navMenu = this.template.querySelector(text);
        let mainMenu = this.template.querySelector('.parent-list');
        mainMenu.style.display = 'none';
        navMenu.classList.add('active');
        navMenu.style.display = 'block';

    }

    openMainMenu() {
        let openedItem = this.template.querySelector('.subList.active');
        openedItem.style.display = 'none';
        openedItem.classList.remove('active');
        let mainMenu = this.template.querySelector('.parent-list');
        mainMenu.style.display = 'block';

    }

    openProfileSubList() {
        let mainMenu = this.template.querySelector('.parent-list');
        let profileMenu = this.template.querySelector('.subList.profile');
        mainMenu.style.display = 'none';
        profileMenu.style.display = 'block';
        profileMenu.classList.add('active');

    }

    handleCloseToggleClick() {
        this.closeIconClicked = !this.closeIconClicked;
        this.cssSearchClass = this.closeIconClicked ? "infa-navbar-search-form-wrapper infa-hide" : "infa-navbar-search-form-wrapper infa-block";
        this.searchIconClicked = !this.searchIconClicked;
        this.closeIconClicked = !this.closeIconClicked;
    }

    handleHamburgerClick() {
        this.handleHamburgerClick = !this.handleHamburgerClick;
        this.cssNavListClass = this.handleHamburgerClick ? "navbar-collapse infa-hide" : "navbar-collapse infa-block";
        this.cssHamburgerClass = this.handleHamburgerClick ? "hamburgermenu" : "infa-navbar-close-icon";
    }

    openNotifications() {
        this.openNotifications = !this.openNotifications;
        this.cssNotificationsClass = this.openNotifications ? "infa-hide notif-mobile" : "infa-block notif-mobile";
    }

    openLoginPage() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Login');
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        var currentUrl = this.updateCurrentPageUrl();
        if (this.isKBPortal) {
            var redirectURI = CustomerSupportLoginURL + encodeURIComponent('?RelayState=') + encodeURIComponent(currentUrl);
        } else {
            var redirectURI = AccountURL + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(currentUrl);
        }
        window.open(redirectURI, '_self');
    }

    openRegisterPage() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Sign Up');
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        if (this.isKBPortal) {
            var redirectURI = CustomerSupportSignupURL;
        } else {
            var redirectURI = AccountURL + "/registration.html?fromURI=" + encodeURIComponent(Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        }

        window.open(redirectURI, '_self');
    }

    get getSearchIcon() {
        return 'background-image: url(' + IN_StaticResource + '/searchIcon.svg)';
    }

    get getAuthIcon() {
        return 'background-image: url(' + IN2_StaticResource + '/lock-black.svg)';
    }

    openDashboard() {
        var sUrl = CommunityURL;
        var target = '_self';
        if (this.boolIsCSMCommunity) {
            sUrl = Success_LogoUrl;
            target = '_blank'
        }

        if (this.boolIsEsupportCommunity) {
            sUrl = this.boolIsSupportLiteUser && !this.boolIsCustomerUser ? CommunityURL : eSupportURL; //<T01>
        }

        // if (this.isKBPortal) {
        //     sUrl = KBPreviewurl;
        //     target = '_self'
        // }
        window.open(sUrl, target);
        //window.open(CommunityURL, '_self'); 
    }

    showtooltip(event) {
        let disable = JSON.parse(JSON.stringify(this.navBarData));
        disable.forEach(ele => {
            ele.level2.featuredLinks.forEach(element => {
                if (element.title.toLowerCase() == event.currentTarget.dataset.name.toLowerCase()) {
                    element.tooltip = true;
                }
            })
        });
        this.navBarData = disable;
    }

    invokeAutoLogin() {

        if (window.location.href.includes('knowledge.informatica.com') || window.location.href.includes('/support/s/')) {
            //window.location.assign(KB_Community_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        } else {
            $.ajax({
                url: Okta_Me_Api_Url,
                type: "GET",
                cache: false,
                crossDomain: true,
                dataType: "json",
                accept: 'application/json',
                xhrFields: {
                    withCredentials: true
                },
                success: function (resp) {
                    if (window.location.href.includes('knowledge.informatica.com') || window.location.href.includes('/support/s/')) {
                    } else {
                        window.location.assign(Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
                    }
                },
                error: function (e) {
                    console.error('Auto login call error : ' + e);
                }
            });
        }
    }

    //T04 Srart//
    checkAndAutoLoginKBExternalUser() {
        try {
            console.log('KB Ex AutoLog - Called');
            $.ajax({
                url: Okta_Me_Api_Url,
                type: "GET",
                cache: false,
                crossDomain: true,
                dataType: "json",
                accept: 'application/json',
                xhrFields: {
                    withCredentials: true
                },
                success: function (resp) {
                    if (window.location.href.includes('knowledge.informatica.com') || window.location.href.includes('/support/s/')) {
                        window.location.assign(KB_Community_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
                    }
                    console.log('KB Ex AutoLog - Success');
                },
                error: function (e) {
                    console.error('checkAndAutoLoginKBExternalUser ajax call error : ' + e);                    
                }
            });
        } catch (ex) {
            console.error('Method : checkAndAutoLoginKBExternalUser :' + ex.message);
        }
    }
    //T04 End//

    updateCurrentPageUrl() {
        var varCurrentURL = document.location.href;
        if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20?language') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/%20?language', 's/global-search/?language');
        }
        else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ ?language') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/ ?language', 's/global-search/?language');
        }
        else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ #') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/ #', 's/global-search/#');
        }
        else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20#') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/%20#', 's/global-search/#');
        }
        else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ ') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/ ', 's/global-search/');
        }
        else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20') != -1) {
            varCurrentURL = varCurrentURL.replace('s/global-search/%20', 's/global-search/');
        }
        return varCurrentURL;
    }

    handleAskQuestion() {
        try {
            util.trackButtonClick('ask - new discussion - header search bar - Form started');
        }
        catch (ex) {
            console.log(ex.message);
        }

        if (USER_ID == undefined) {
            window.location.assign(AccountURL + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(this.updateCurrentPageUrl()));
        } else if (USER_ID != undefined) {
            this.isAskQuestionModal = true;
            document.body.classList += ' modal-open';
        }
    }

    closeAskQuestionModal() {
        this.isAskQuestionModal = false;
        document.body.classList -= ' modal-open';
    }

    saveData(event) {
        this.isSpinnerLoading = true; //T02
        let fileData = event.detail.file;
        try {
            util.trackButtonClick('ask - new discussion - header search bar - Form completed - ' + event.detail.label);
        }
        catch (ex) {
            console.log(ex.message);
        }

        saveQuestionPost({ userId: USER_ID, networkId: communityId, parentId: event.detail.comm, title: event.detail.title, body: event.detail.desc,fileList: JSON.stringify(fileData) })
            .then((data) => {
                let questionId = data;
                if (questionId != '') {
                    /** T03 starts */
                    console.log('questionId>>>>>>', questionId);
                    this.closeAskQuestionModal();
                    window.location.assign(CommunityURL + 'question/' + questionId);
                    //                 window.location.assign(CommunityURL + 'question/' + questionId);
                    //creating attachment for post
                    // uploadFile({ fileList: JSON.stringify(fileData), recordId: questionId })
                    //     .then((data) => {
                    //         saveQuestionPostToTopic({ entityId: questionId, networkId: communityId, topicId: event.detail.comm })
                    //             .then((data) => {
                    //                 this.closeAskQuestionModal();
                    //                 window.location.assign(CommunityURL + 'question/' + questionId);
                    //             })
                    //             .catch((error) => {
                    //                 this.isSpinnerLoading = false; //Tag 4
                    //             })
                    //     })
                    //     .catch((error) => {
                    //         console.log('file attachment error > ', error);
                    //         this.isSpinnerLoading = false; //Tag 4
                    //     })
                }
                /** T03 ends */
            })
            .catch((error) => {
                this.isSpinnerLoading = false;//T02 starts
                console.error("error", error);
                if (error.body.message.includes('INVALID_MARKUP')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Please copy and paste plain text.');
                } else if (error.body.message.includes('STRING_TOO_LONG')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Character limit is exceeded');
                }
                else if (error.body.message.includes('FIELD_MODERATION_RULE_BLOCK')) {
                    let bmOne = error.body.message.split('FIELD_MODERATION_RULE_BLOCK,')[1];
                    bmOne = bmOne.split('[RawBody]')[0];
                    bmOne = bmOne.split('[Title, RawBody]')[0];
                    bmOne = bmOne.split(':')[0];
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage(bmOne);
                } else {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Error in Saving this Discussion.');
                } //T02 ends
            });
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
}