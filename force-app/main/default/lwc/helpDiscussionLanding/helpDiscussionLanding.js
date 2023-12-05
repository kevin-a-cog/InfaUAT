/*
 * Name         :   HelpDiscussionLanding
 * Author       :   Ankit Saxena
 * Created Date :   20-August-2022
 * Description  :   LWC component to display the all the discussion on discussion landing page

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           20-SEPT-2022    I2RT-7026           Bringing quick links in the blue banner for 
                                                            all the product community detail page                     1
 Ankit Saxena           20-Oct-2022     I2RT-7285           My discussion to show created date of 
                                                            the user instead of discussion last modified date.        2
 Ankit Saxena           02-11-2022      I2RT-7297           Bringing indicator in the discussion landing page 
                                                            for all the best answers                                  3
 Ankit Saxena           23-11-2022      I2RT-7298           Discussion: Recommended discussions to show               
                                                            more relevant data                                        4 
 Chetan Shetty          24-11-2022      I2RT-7487           Coveo Dropdown Collapse on blur                           5
 
 Deeksha Shetty        27-01-2023       I2RT-7545			Spammed words are getting posted in product community	  6
 Deeksha Shetty        08 May 2023      I2RT-8345             Ask a Question - Email Notification - Issue observed    7
                                                            in New and Update Notification email template 
 Chetan/Prashanth      26 Oct 2023      I2RT-9228           Added Pagination logic and related dynamic css and 
                                                            Redundent code cleanup                                    8
 */

import { LightningElement, api, track } from 'lwc';
import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import USER_ID from '@salesforce/user/Id';
import communityId from "@salesforce/community/Id";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import IN_account_login from '@salesforce/label/c.IN_account_login';
import saveQuestionPost from "@salesforce/apex/helpQuestions.saveQuestionPost";
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";

export default class HelpDiscussionLanding extends LightningElement {
    @api title;
    @api numOfItems;
    @api coveoSearchId;
    @api placedin;
    discussionLogo = IN_StaticResource + "/Icon_Social.png";
    searchtoken;
    searchhubname;
    searchorgname;
    varCoveoSearchInterface;
    varCoveoAnalytics;
    isGuestUser = false;
    varFilterBar;
    @track isAskQuestionModal = false;
    @track heading = 'Ask A Question';
    @api recordId;
    @track myDiscTabFilter = "@infadocumenttype==(UserFeed,FeedComment) @sfcreatedbyid==" + USER_ID + " OR @infadocumenttype==(UserFeed) @sffeedlikescreatedbyid==" + USER_ID;
    @track recommendedTabFilter = "@infadocumenttype==(UserFeed) NOT(@sfcreatedbyid==" + USER_ID + ") NOT(@sffeedlikescreatedbyid==" + USER_ID + ") NOT(@sffeedcommentscreatedbyid=" + USER_ID + ")";
    trophyIcon = IN_StaticResource3 + "/helpDiscussionLanding/icons/trophy-small.png";
    allDropdown;
    isSpinnerLoading = false; //Tag 6
    @track showFilters = false;
    renderedCallback() {
        this.allDropdown = this.template.querySelectorAll(".dropdown");
        for (let i = 0; i < this.allDropdown.length; i++) {
            this.allDropdown[i].addEventListener('click', (e) => e.stopPropagation(), false);
        }
        document.addEventListener('click', this.onDocClick.bind(this));
    }

    connectedCallback() {
        try {
            if (USER_ID == undefined) {
                this.isGuestUser = true;
            }
            this.fnGetSearchToken();
        } catch (error) {
            console.error('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
        }
    }

    fnGetSearchToken() {
        let sessionToken = undefined;
        window.helpDiscLandingTemplate = this;
        if (USER_ID == undefined) {
            sessionToken = sessionStorage.getItem('coveoTokenAnonymous'); //fetching the token from Session Storage
            this.isGuestUser = true;
            this.searchhubname = "InfaNetworkGlobalSearch";
        } else {
            sessionToken = sessionStorage.getItem('coveoTokenAuthenticated'); //fetching the token from Session Storage
            this.searchhubname = "InfaNetworkGlobalSearchAuthenticated";
        }
        if (sessionToken != undefined) {
            this.searchtoken = sessionToken;
            this.loadComponentResource();
        } else {
            getSearchToken({ strCalledFrom: this.placedin })
                .then((result) => {
                    this.searchtoken = JSON.parse(result).APISearchToken;
                    this.searchhubname = JSON.parse(result).APISearchHub;
                    this.searchorgname = JSON.parse(result).SearchOrgName;
                    this.loadComponentResource();
                })
                .catch((error) => {
                    console.error("Error Help Discussion Landing : getSearchToken : result is :" + JSON.parse(error));
                });
        }
    }

    //Script
    loadComponentResource() {
        try {
            this.loadCustomStyle();
        } catch (error) {
            console.log('error', 'helpDiscussionLanding : Method : loadComponentResource; Error :' + error.message + " : " + error.stack);
        }
    }

    //Style
    loadCustomStyle() {
        try {
            //Loading CoveoFullSearch CSS
            Promise.all([
                loadStyle(this, IN_StaticResource3 + "/helpDiscussionLanding/css/discussionLanding.css")
            ])
                // loadStyle(
                //     this,
                //     IN_StaticResource3 + "/helpDiscussionLanding/css/discussionLanding.css")
                .then(() => {
                    this.loadCustomTemplateJs();
                })
                .catch((error) => {
                    Log('error', 'helpDiscussionLanding : Method : loadCustomStyle - loadScript; Error :' + error.message + " : " + error.stack);
                });
            //Loading CoveoFullSearch CSS
        } catch (error) {
            Log('error', 'helpDiscussionLanding : Method : loadCustomStyle; Error :' + error.message + " : " + error.stack);
        }

    }


    //Script
    loadCustomTemplateJs() {
        try {
            loadScript(this, IN_StaticResource3 + "/helpDiscussionLanding/js/InfaHelpDiscussionTemplate.js")
                .then(result => {
                    this.loadCoveoSearch();
                })
                .catch((error) => {
                    console.log('error', 'Method : loadCustomTemplateJs - loadCoveoJs; Error :' + error.message + " : " + error.stack);
                });
        } catch (error) {
            console.log('error', 'Method : loadCustomTemplateJs; Error :' + error.message + " : " + error.stack);
        }

    }

    //Coveo load Function
    loadCoveoSearch() {
        try {

            this.varCoveoAnalytics = this.template.querySelector(".CoveoAnalytics");

            this.varCoveoAnalytics.setAttribute("data-search-hub", this.searchhubname);

            this.configureOldSearchEndPoint();

            this.varCoveoSearchInterface = this.template.querySelector(
                "[data-id='" + this.coveoSearchId + "']"
            );

            window.CoveoSearchInterfaceSelector = this.template.querySelector(
                ".CoveoSearchInterface"
            );

            if (Coveo != 'undefined') {

                const loadMoreSelector = Coveo.$$(this.varCoveoSearchInterface).find(".load-more");
                const filterBr = Coveo.$$(this.varCoveoSearchInterface).find(".help-filter-bar");

                Coveo.$$(this.varCoveoSearchInterface).on("afterInitialization", () => {

                    const coveoDynamicFacetSelector = Coveo.$$(this.varCoveoSearchInterface).find(".disc-product");


                    const coveoDynamicFacetUl = Coveo.$$(this.varCoveoSearchInterface).closest(".coveo-dynamic-facet-values");
                    let dynFacet = Coveo.get(coveoDynamicFacetSelector);

                    var elements = Coveo.$(coveoDynamicFacetSelector).find('.coveo-dynamic-facet-values');

                    Coveo.$(elements).blur(function () {
                        Coveo.$(coveoDynamicFacetSelector).addClass('coveo-dynamic-facet-collapsed');
                    });

                    Coveo.$(coveoDynamicFacetSelector).blur(function (args) {
                        Coveo.$(coveoDynamicFacetSelector).addClass('coveo-dynamic-facet-collapsed');
                    });

                    Coveo.TemplateHelpers.registerTemplateHelper("helpDiscLandingProdDisplay", function (value) {
                        if (value !== undefined) {
                            return value;
                        }
                        else {
                            return '';
                        }
                    });

                    Coveo.TemplateHelpers.registerTemplateHelper("helpDiscGetLikes", function (value) {
                        if (value > 0) {
                            return value;
                        }
                        else {
                            return 0;
                        }
                    });

                    Coveo.TemplateHelpers.registerTemplateHelper("helpDiscGetComments", function (value) {
                        if (value > 0) {
                            return value;
                        }
                        else {
                            return 0;
                        }
                    });

                    let trophyImg = this.trophyIcon;
                    Coveo.TemplateHelpers.registerTemplateHelper("helpBestAnswered", function (value) {
                        if (value != null) {
                            return '<img src=' + trophyImg + ' alt="Best Answered" class="trophy-icon" title="Best Answered"/>';
                        }
                        else {
                            return '';
                        }
                    });

                    Coveo.$(filterBr).show();

                });

                Coveo.$$(this.varCoveoSearchInterface).on('preprocessResults', function (e, args) {
                    if (args.results.totalCount > (args.query.firstResult + args.query.numberOfResults)) {
                        Coveo.$(loadMoreSelector).show();
                    } else {
                        Coveo.$(loadMoreSelector).hide();
                    }
                    Coveo.$(filterBr).show();
                });

                Coveo.$$(this.varCoveoSearchInterface).on('noResults', function (e, args) {
                    //help-filter-bar
                    try {
                        Coveo.$(filterBr).hide();
                    } catch (e) {
                        console.log('helpDiscLanding : noResults Exception : e :', e.message);
                    }
                });

                Coveo.init(this.varCoveoSearchInterface);

            }

        } catch (error) {
            console.log('error', 'helpDiscussionLanding : Method : loadCoveoSearch; Error :' + error.message + " : " + error.stack);
        }
    }

    configureOldSearchEndPoint() {
        try {
            var token = this.searchtoken;
            var endpointURI = "https://platform.cloud.coveo.com/rest/search";
            if (Coveo != 'undefined') {
                if (Coveo.SearchEndpoint.endpoints["default"]) {
                    Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
                    Coveo.SearchEndpoint.endpoints["default"].options.queryStringArguments.numberOfResults = this.numOfItems;
                    Coveo.SearchEndpoint.endpoints["default"].options.queryStringArguments.filterField = 'foldfoldingfield';
                    Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = function () { window.reload(); };
                } else {
                    Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                        restUri: endpointURI,
                        accessToken: token,
                        filterField: '@foldfoldingfield',
                        renewAccessToken: function () { window.reload(); }
                    });
                }
            }
        } catch (error) {
            console.error('error', 'helpDiscussionLanding : Method : configureOldSearchEndPoint; Error :' + error.message + " : " + error.stack);
        }
    }

    handleAskQuestion() {
        try {
            util.trackButtonClick('ask - new discussion - discussion landing page - Form started');
        }
        catch (ex) {
            console.log(ex.message);
        }

        if (USER_ID == undefined) {
            window.location.assign(IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
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
        this.isSpinnerLoading = true; //Tag 6
        let fileData = event.detail.file;
        try {
            util.trackButtonClick('ask - new discussion - discussion landing page - Form completed - ' + event.detail.label);
        }
        catch (ex) {
            console.log(ex.message);
        }

        saveQuestionPost({ userId: USER_ID, networkId: communityId, parentId: event.detail.comm, title: event.detail.title, body: event.detail.desc, fileList: JSON.stringify(fileData) })
            .then((data) => {
                let questionId = data;
                if (questionId != '') {
                    /** Tag 7 starts */
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
                /** Tag 7 ends */
            })
            .catch((error) => {
                this.isSpinnerLoading = false;//Tag 6 starts
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
                } //Tag 6 ends
            });
    }

    checkDropdown(event) {
        let selector = event.target.closest('.dropdown');
        let sldsCombobox = this.template.querySelector(".dropdown.show");
        this.hideDropdown(this.allDropdown);
        selector.classList.add('show');
        sldsCombobox.classList.remove('show');
    }
    onDocClick() {
        this.hideDropdown(this.allDropdown);
    }
    hideDropdown(getDropdown) {
        for (let i = 0; i < getDropdown.length; i++) {
            if (getDropdown[i].classList.contains('show')) {
                getDropdown[i].classList.remove('show');
            }
        }
    }
    handleShowFilters() {
        let filterBar = this.template.querySelector(".help-disc-filterbar-wrapper");
        if (this.showFilters == false) {
            filterBar.classList.toggle('hidden');
        }
    }
}