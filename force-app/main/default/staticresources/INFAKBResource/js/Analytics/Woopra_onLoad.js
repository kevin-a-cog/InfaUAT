var KBOmnitureDelimiter = "|";

var KBAnonymousUser = "Anonymous User";

//Method returns search keyword from home page and infasearch page

function getSearchKeyWord() {

    var txtboxKeyword = $("[id$='_txtSearchBox']").val().toLowerCase();
    txtboxKeyword = txtboxKeyword.replace('Search the Knowledge Base...', ''); 
    return txtboxKeyword;
}

//Method returns Narrow search keyword from infasearch page
function getNarrowSearchKeyword() {
    var txtboxKeyword = $("[id$='txtSearchKeyword']").val().toLowerCase();
    return txtboxKeyword;
}


//Get total search count
function GetTotalSearchResultsCount() {
    var totalKBCount = "0";
    if ($('#SRST').find('div.srch-stats').length == 1) {
        var divhtmlcontent = $('#SRST').find('div.srch-stats').text();
        var totalKBCount = divhtmlcontent.lastIndexOf("of ") + "of ".length;
        totalKBCount = ((divhtmlcontent.substring(totalKBCount, divhtmlcontent.length)).trim());

        if (totalKBCount.lastIndexOf("results") > -1) {

            var KBPos = totalKBCount.lastIndexOf("results");
            totalKBCount = totalKBCount.substring(0, KBPos).trim();

        }



    }
    return totalKBCount;
}

//Get Narrow Search Keyword from the Filter DIV

function GetRefinerValue(Classname) {
    if (document.getElementsByClassName(Classname).length > 0) {
        var filtersApplied = document.getElementsByClassName(Classname).length;
        var filterValues = "";
        for (var i = 0; i < filtersApplied; i++) {
            filterValues += document.getElementsByClassName(Classname)[i].innerText;
            if (i < filtersApplied - 1) {
                filterValues += ", ";
            }
        }
        return filterValues;
    }
    return "";
};


/*
Get the Cookie name 
Input: name of the Cookie
Returns: Cookie value
*/
function GetWoopraClientEmailId(Name) {

    //Length of the cookie.
    var Len = Name.length;
    var i = 0;
    while (i < document.cookie.length) {
        var j = i + Len + 1;

        if (document.cookie.substring(i, j) == (Name + "=")) {
            if (GetValue(j).trim() == "") {
                return "";
            } else {
                return decodeURIComponent(GetValue(j));
            }
        }
        i = document.cookie.indexOf(" ", i) + 1;
        if (i == 0)
            break;
    }
    return "";
}


/*
Get the Cookie name 
Input: OffSet value
Returns: Cookie value
*/
function GetValue(Offset) {
    //Get the cookie index
    var End = document.cookie.indexOf(";", Offset);
    if (End == -1)
        End = document.cookie.length;

    //Return the cookie value
    return unescape(document.cookie.substring(Offset, End));
}


/*
Get the refiner applied in the search page
Input:HTML Class Name
Output:Refiners applied
*/

function GetRefinerValue(Classname) {
    //alert("inside");

    if (document.getElementsByClassName(Classname).length > 0) {
        var filtersApplied = document.getElementsByClassName(Classname).length;
        var filterValues = "";
        for (var i = 0; i < filtersApplied; i++) {
            filterValues += document.getElementsByClassName(Classname)[i].innerText;
            if (i < filtersApplied - 1) {
                filterValues += ", ";
            }
        }
        return filterValues;
    }
    return "";
};

/*Returns the KB Site FeedBack Radio button values */
function GetSiteFeedBackRdValues(radioSiteFeedback, radioContentFeedback, radioReqNew, radioOthers, ddlFeedbackProducts) {

    var finalRdSelectedValues;
    if (radioSiteFeedback.checked) {
        finalRdSelectedValues = 'Site Feedback';
    }

    else if (radioContentFeedback.checked) {
        finalRdSelectedValues = 'Content Feedback';
    }

    else if (radioReqNew.checked) {
        var siteFeedBaclDrpValue = ddlFeedbackProducts.options[ddlFeedbackProducts.selectedIndex].value;
        finalRdSelectedValues = 'Request New Content';
        finalRdSelectedValues = finalRdSelectedValues.concat('-', siteFeedBaclDrpValue);
    }

    else if (radioOthers.checked) {
        finalRdSelectedValues = 'Other';
    }

    return finalRdSelectedValues;
}


/* Purpose: Get and return the KB Site feedback form values
Returns the KB Site FeedBack Form values delimited by a separator*/
function GetSiteFeedBackFormValues_woopra(txtFeedbackName, txtFeedBackEmail, radioSiteFeedback, radioContentFeedback, radioReqNew, radioOthers, ddlFeedbackProducts, txtcomments) {

    var siteFeedBackFormValues = "";

    var siteFeedBackRdValues = GetSiteFeedBackRdValues(radioSiteFeedback, radioContentFeedback, radioReqNew, radioOthers, ddlFeedbackProducts);
    //siteFeedBackFormValues = siteFeedBackFormValues.concat('FeedBackName:', txtFeedbackName, KBOmnitureDelimiter, 'FeedBackEmail:', txtFeedBackEmail, KBOmnitureDelimiter, 'Category:', siteFeedBackRdValues, KBOmnitureDelimiter, 'SiteFeedBackComments:', txtcomments);
    siteFeedBackFormValues = siteFeedBackFormValues.concat(txtFeedbackName, KBOmnitureDelimiter, txtFeedBackEmail, KBOmnitureDelimiter, siteFeedBackRdValues, KBOmnitureDelimiter, txtcomments);
    return siteFeedBackFormValues;

}


/*
Feedback option in Utility.aspx page. 
Note: For NON KB doucments only.
*/
function FeedbackOptiononUtility(RBID) {

    //Return value
    var UtilityIFeedBackValue = "";
    //Get the Radio button Client ID
    var RB1 = document.getElementById(RBID);
    //Get the Radio Options
    var radio = RB1.getElementsByTagName("input");
    for (var i = 0; i < radio.length; i++) {
        if (radio[i].checked) {
            switch (radio[i].value) {

                case 'This document resolved my issue':
                    UtilityIFeedBackValue = "Resolved";
                    break;

                case 'This document did not resolve my issue':
                    UtilityIFeedBackValue = "Did Not Help";
                    break;

                case 'This document helped but additional information was required to resolve my issue':
                    UtilityIFeedBackValue = "Helpful but incomplete";
                    break;

            }
        }
    }
    //Return the Omniture value for the seleted option.
    return UtilityIFeedBackValue;
}

/*
OnLoad the KB Article.
Input: NA
Returns: KB Article Name
Ex: If the page name is 1234.aspx, this function
will return 1234.
*/
function GetKBName() {

    //Get the current URL
    var currentKBurl = document.URL;
    //Test
    var KBDocID = "";

    //Get the KB Article name.
    //If query string parameters found, trim the URL to find the aspx
    if (currentKBurl.indexOf('?') > 0) {
        currentKBurl = currentKBurl.substring(0, currentKBurl.indexOf('?'));
        KBDocID = currentKBurl.substring(currentKBurl.lastIndexOf('/') + 1);
        KBDocID = KBDocID.replace(".aspx", "");
    }

    //If query string parameters not found, find the URL 
    else {
        var KBArray = [];
        KBArray = currentKBurl.split('/');

        for (var i = 0, length = KBArray.length; i < length; i++) {
            var KBChunk = KBArray[i];
            if (KBChunk.indexOf(".aspx") != -1) {

                var KBstrf = KBChunk;
                KBstrf = KBstrf.replace(".aspx", "");
                KBDocID = KBstrf;
            }
        }
    }
    //returns the KB Article name
    return KBDocID;
}

/* 
Get the Get KB Article Title in the KB Article Page
*/
function GetKBArticleTitle() {
    var KBTitleId = $("#KBTitleID").text();
    /*var KBTitleId = $("#KBTitleID").find('div:first').text(); */
    return $.trim(KBTitleId);
}


/* 
To find are we in the search results page or not. If yes,
we get all the values and send it to Omniture.
*/
function isSearchResultsPage() {

    var isKBSearchResultsPage = false;
    var str = (document.URL).toLowerCase();
    var pos = str.indexOf("infasearch.aspx")
    if ((str.indexOf("infasearch.aspx") >= 0) || (str.indexOf("kbdilitesearchresults.aspx") >= 0) || (str.indexOf("infasearchltd.aspx") >= 0)) {
        isKBSearchResultsPage = true;
    }
    else {
        isKBSearchResultsPage = false;
    }
    return isKBSearchResultsPage;
}

/*
Returns the default(HardCoded) page name. 
Note: Make sure we pass some value in this function.
*/
function SetLandingPageName_woopra() {
    var KBLandingPageName;
    //var KBPageLocation = $(location).attr('href');
    var KBPageLocation = window.location.href;
    if (KBPageLocation.toLowerCase().indexOf("/kbexternal/pages/home.aspx") >= 0) {
        KBLandingPageName = "KB:Home Page";
    }
    else if (KBPageLocation.toLowerCase().indexOf("/kbexternal/pages/kbdilite.aspx") >= 0) {

        KBLandingPageName = "KB:DILite Page";
    }

    else if ((KBPageLocation.toLowerCase().indexOf("preview/utilityextended.aspx") > -1) || (KBPageLocation.toLowerCase().indexOf("docid") > -1)) {
        KBLandingPageName = "Document View Page";
    }
    else if (KBPageLocation.toLowerCase().indexOf("/_layouts/productdocumentation/page/productdocumentsearch.aspx") >= 0) {
        KBLandingPageName = "KB:Product Document Search Results Page";
    } else {

        KBLandingPageName = "KB:Search Results Page";
    }
    return KBLandingPageName;
}


/*
Purpose:To check are we Landing Page or not
Returns: true if we are in Landing page else false
*/
function isKBLandingpage() {
    var iSKBLandingPage = false;
    //var ISKBDefaultPage = $(location).attr('href');
    var ISKBDefaultPage = window.location.href;
    if ((ISKBDefaultPage.toLowerCase().indexOf("/kbexternal/pages/home.aspx") >= 0) || (ISKBDefaultPage.toLowerCase().indexOf("/kbexternal/pages/kbdilite.aspx") >= 0)) {
        iSKBLandingPage = true;
    }
    return iSKBLandingPage;
}


/*
Returns of the KB Referral URL
Returns: If not matching with any referral in the function, 
send the default document referral.
*/
function KBReferralURL(KBReferralURL) {

    //We dont depend in document.referral url, hence making it as null. 
    KBReferralURL = "";
    //Variable to return KB Referral URL
    var outReferralURL;

    if (!isBlank(KBReferralURL)) {

        //Test Purpose only---SHOULD BE REMOVED IN UAT AND PROD
        //KBReferralURL = "http://google.com";

        //Convert to Lowercase before starting the comparsion.
        KBReferralURL = KBReferralURL.toLowerCase();

        //My Support
        var MySupport_Test = "kb-test.informatica.com";
        var MySupport_Intg = "kb-uno.informatica.com";
        var MySupport_Prod = "kb.informatica.com";

        //eService
        var eService_Test = "/eserviceldap";

        //Support Flash
        var SupportFlash = "s621.t.en25.com";
        var SupportFlash_URL2 = "s621.t.eloqua.com";

        //CSM
        var CSM = "/nidp/";
        var CSM_URL2 = "/nesp";

        //We are in SupportFlash
        if (((KBReferralURL.indexOf(CSM)) > 0) || ((KBReferralURL.indexOf(CSM)) > 0)) {
            outReferralURL = "SupportFlash";
        }

        //We are in CSM
        else if (((KBReferralURL.indexOf(SupportFlash)) > 0) || ((KBReferralURL.indexOf(SupportFlash_URL2)) > 0)) {
            outReferralURL = "CSM";
        }

        //We are in eService 
        else if ((KBReferralURL.indexOf(eService_Test)) > 0) {
            outReferralURL = "eService";
        }

        //We are in My Support 
        else if (((((KBReferralURL.indexOf(MySupport_Prod)) > 0) || ((KBReferralURL.indexOf(MySupport_Test) > 0)) || ((KBReferralURL.indexOf(MySupport_Intg)) > 0))) && ((KBReferralURL.indexOf(eService_Test)) == -1)) {
            outReferralURL = "My Support";
        }

        //If the Referral URL is still empty try with the actual URL and see if it has Support Flash.
        else if (isBlank(outReferralURL)) {
            outReferralURL = GetSupportFlashReferralURL();
        }

        //If the Referral URL is still empty try with the actual URL and see if it has Support console.
        else if (isBlank(outReferralURL)) {
            outReferralURL = GetSupportConsoleReferralURL();
        }


        //If the Referral URL is still empty try with the actual URL and see if it has eService.
        else if (isBlank(outReferralURL)) {
            outReferralURL = GeteServiceReferralURL();
        }

        //Get the current referral
        else {
            outReferralURL = KBReferralURL;
        }
    }
    else {

        //SupportFlash
        outReferralURL = GetSupportFlashReferralURL();

        //SupportConsole
        if (isBlank(outReferralURL)) {
            outReferralURL = GetSupportConsoleReferralURL();
        }

        //eService
        if (isBlank(outReferralURL)) {
            outReferralURL = GeteServiceReferralURL();
        }

        //CMS
        if (isBlank(outReferralURL)) {
            outReferralURL = GetCSMReferralURL();
        }

        //MySupport
        if (isBlank(outReferralURL)) {
            outReferralURL = GetMySupportReferralURL();
        }
    }
    return outReferralURL;
}


/*
Returns of the KB Referral URL if the URL has CSM as querystring 
*/
function GetCSMReferralURL() {

    var outeServiceReferralURL = "";
    var currentpageurl = document.URL;
    //currentpageurl = "https://kb.informatica.com/kbexternal/Pages/KBSearchResults.aspx?k=Support%20Console&fromsource=csm";
    //Get the Query String.
    if (currentpageurl.indexOf('?') > 0) {

        var startcount = currentpageurl.substring(0, currentpageurl.indexOf('?'));

        var urlafterquerystring = currentpageurl.substring(startcount.length, currentpageurl.length);

        if (urlafterquerystring.length > 0) {

            //Convert to lower case before comparing
            var urlafterquerystring = urlafterquerystring.toLowerCase();
            if ((urlafterquerystring.indexOf("fromsource=csm") > 0)) {
                outeServiceReferralURL = "CSM";
            }
        }
    }
    return outeServiceReferralURL;
}



/*
Returns of the KB Referral URL if the URL has support console as querystring 
*/
function GetSupportConsoleReferralURL() {

    var outeServiceReferralURL = "";
    var currentpageurl = document.URL;
    //currentpageurl = "https://kb.informatica.com/kbexternal/Pages/KBSearchResults.aspx?k=Support%20Console&fromsource=eservice&cid=supportconsole";
    //Get the Query String.
    if (currentpageurl.indexOf('?') > 0) {

        var startcount = currentpageurl.substring(0, currentpageurl.indexOf('?'));

        var urlafterquerystring = currentpageurl.substring(startcount.length, currentpageurl.length);

        if (urlafterquerystring.length > 0) {

            //Convert to lower case before comparing
            var urlafterquerystring = urlafterquerystring.toLowerCase();
            if ((urlafterquerystring.indexOf("cid=supportconsole") > 0)) {
                outeServiceReferralURL = "Support Console";
            }
        }
    }
    return outeServiceReferralURL;
}


/*
Returns of the KB Referral URL if the URL has SupportFlash as querystring 
*/
function GetSupportFlashReferralURL() {

    var outSupportFlashReferralURL = "";
    var currentpageurl = document.URL;


    //ex: currenturl = "https://kb-test.informatica.com/whitepapers/2/Pages/109266.aspx?cid=FROM_SF_Feb2012";
    //Get the Query String.
    if (currentpageurl.indexOf('?') > 0) {

        var startcount = currentpageurl.substring(0, currentpageurl.indexOf('?'));

        var urlafterquerystring = currentpageurl.substring(startcount.length, currentpageurl.length);

        if (urlafterquerystring.length > 0) {

            //Convert to lower case before comparing
            var urlafterquerystring = urlafterquerystring.toLowerCase();
            if ((urlafterquerystring.indexOf("cid=from_sf_") > 0)) {
                outSupportFlashReferralURL = "SupportFlash";
            }
        }
    }
    return outSupportFlashReferralURL;
}




/*
Returns of the KB Referral URL if the URL has eService as querystring 
*/
function GeteServiceReferralURL() {

    var outeServiceReferralURL = "";
    var currentpageurl = document.URL;
    //ex: currenturl = "https://kb-test.informatica.com/KBExternal/Pages/KBSearchResults.aspx?k=Moodambail&fromsource=eservice";
    //Get the Query String.
    if (currentpageurl.indexOf('?') > 0) {

        var startcount = currentpageurl.substring(0, currentpageurl.indexOf('?'));

        var urlafterquerystring = currentpageurl.substring(startcount.length, currentpageurl.length);

        if (urlafterquerystring.length > 0) {

            //Convert to lower case before comparing
            var urlafterquerystring = urlafterquerystring.toLowerCase();
            if ((urlafterquerystring.indexOf("fromsource=eservice") > 0)) {
                outeServiceReferralURL = "eService";
            }
        }
    }
    return outeServiceReferralURL;
}


/*
Returns of the KB Referral URL if the URL  doesnt have any querystring. We assume that 
user is coming via My Support. 
*/
function GetMySupportReferralURL() {

    var outmySupportReferralURL = "";
    var currentpageurl = document.URL;
    currentpageurl = currentpageurl.toLowerCase()
    //ex: currenturl = "https://kb-test.informatica.com/KBExternal/Pages/KBSearchResults.aspx?k=Moodambail&fromsource=eservice";
    //Get the Query String.


    //var QueryChar = currentpageurl.indexOf('?');
    //var KBLandingPageUrl= currentpageurl.indexOf('kbexternal/default.aspx');

    if ((currentpageurl.indexOf('?') == '-1') && (currentpageurl.indexOf('kbexternal/pages/home.aspx') > 0)) {
        outmySupportReferralURL = "My Support";
    }

    if (currentpageurl.indexOf('docid=') > 0) {
        outmySupportReferralURL = "My Support";
    }

    if (isBlank(outmySupportReferralURL)) {

        if ((currentpageurl.indexOf('fromsource=csm') == '-1') && (currentpageurl.indexOf('cid=supportconsole') == '-1') && (currentpageurl.indexOf('cid=from_sf_') == '-1') && (currentpageurl.indexOf('fromsource=eservice') == '-1')) {
            outmySupportReferralURL = "My Support";
        }
    }

    return outmySupportReferralURL;

}



/* 
In Utility Page to capture the page url.
Input:Takes the raw URL 
Returns:Trimmed URL
*/
function TruncatedContentURl(content) {
    //Find the  index of /
    var aPosition = content.indexOf("/");
    var secondPos = content.indexOf("/", aPosition + 2);
    //Trim the URL
    var TruncatedContentURl = content.substring(secondPos);
    return TruncatedContentURl;
}


/* Purpose: Get and return the KB Tab click
Send the seleceted KB tab Name to Omniture */
function KBLandingPageTabNameClick_woopra(KBTabName) {

    if (!isBlank(KBTabName)) {
        return KBTabName;
    }
    else {
        return "";
    }


}

/*
Returns true if the value is not blank else false.
*/
function isBlank(str) {
    return (!str || /^\s*$/.test(str));
}

/* Purpose: Get and return the KB Tab click
Send the seleceted KB tab Name to Omniture */
function KBLandingPageTabNameClick_AfterLoad_woopra(KBTabName) {
    if (!isBlank(KBTabName)) {

        return KBTabName;
    } else {
        return "";
    }
}

/* 
To find are we in the search results page or not. If yes,
we get all the values and send it to Omniture.
*/
function isSearchResultsPage() {

    var isKBSearchResultsPage = false;
    var str = (document.URL).toLowerCase();
    var pos = str.indexOf("infasearch.aspx")
    if ((str.indexOf("infasearch.aspx") >= 0) || (str.indexOf("kbdilitesearchresults.aspx") >= 0) || (str.indexOf("infasearchltd.aspx") >= 0)) {
        isKBSearchResultsPage = true;
    }
    else {
        isKBSearchResultsPage = false;
    }
    return isKBSearchResultsPage;
}



/*
Purpose:To check are we Landing Page or not
Returns: true if we are in Landing page else false
*/
function isKBLandingpage() {
    var iSKBLandingPage = false;
    //var ISKBDefaultPage = $(location).attr('href');
    var ISKBDefaultPage = window.location.href;
    if ((ISKBDefaultPage.toLowerCase().indexOf("/kbexternal/pages/home.aspx") >= 0) || (ISKBDefaultPage.toLowerCase().indexOf("/kbexternal/pages/kbdilite.aspx") >= 0)) {
        iSKBLandingPage = true;
    }
    return iSKBLandingPage;
}




function GetSelectedTab_woopra(KBTotalResultCount) {
    if (isSearchResultsPage()) {
        var selectedTabName = "";
        if (KBTotalResultCount != '0') {
            //Make sure tab exists before we dig in.
            if ($('.tabPanelbox').find('ul').find('li').length > 1) {

                //Find tab name,with the class name selected.
                $('.tabPanelbox').find('ul').find('li').each(function (index) {
                    if ($(this).find('a').hasClass('selected')) {
                        var selectedvalue = ($(this).find('a.selected').text());
                        selectedTabName = selectedvalue.substring(0, selectedvalue.indexOf('('));
                        return false;


                    }
                });
            }
        }
        return selectedTabName;
    }
}



/* 
Find the KB Refine search Option.
Input: ClientID of the all radio button
*/
function GetKBRefineSearchOption_woopra(rdallWordsID, rdanyWordID, rdexactPhraseID, rdKBID) {

    var KBSelectedRd;
    var KBSearchRefineRadioButton

    if (isSearchResultsPage()) {

        KBSearchRefineRadioButton = document.getElementById(rdallWordsID);
        if (KBSearchRefineRadioButton.checked) {
            KBSelectedRd = 'All Words';
        }


        KBSearchRefineRadioButton = document.getElementById(rdanyWordID);
        if (KBSearchRefineRadioButton.checked) {
            KBSelectedRd = 'Any Word';
        }


        KBSearchRefineRadioButton = document.getElementById(rdexactPhraseID);
        if (KBSearchRefineRadioButton.checked) {
            KBSelectedRd = 'Exact Phrase';
        }

        KBSearchRefineRadioButton = document.getElementById(rdKBID);
        if (KBSearchRefineRadioButton.checked) {
            KBSelectedRd = 'KB ID';
        }
    }
    return KBSelectedRd
}

/* 
Find the Read NonKB FileName
*/
function ReadNonKBFileName_woopra(content) {

    var NonKBFileName;
    if ((content.indexOf("/proddocs/Product%20Documentation/")) > 0) {

        var doc = content.indexOf("/proddocs/Product%20Documentation/");
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);

    }
    // Added to capture the path of the Product documentation 
    else if ((content.indexOf("/productdocumentation/Product%20Documentation/")) >= 0) {

        var doc = content.indexOf("/productdocumentation/Product%20Documentation/");
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);

    }
    // Added to capture the path of the Product documentation 
    else if ((content.indexOf("/productdocumentation/Product Documentation/")) >= 0) {

        var doc = content.indexOf("/productdocumentation/Product Documentation/");
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);

    }
    else if ((content.indexOf("/h2l/H2L%20Doc%20Library/")) > 0) {
        var doc = content.indexOf("/h2l/H2L%20Doc%20Library/");  //("/How-To Library/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }
    else if ((content.indexOf("Product Documentation")) > 0) {
        var doc = content.indexOf("Product Documentation");
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }
    else if ((content.indexOf("H2L Doc Library")) > 0) {
        var doc = content.indexOf("H2L Doc Library");  //("/How-To Library/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }
    return NonKBFileName;
} 
             


