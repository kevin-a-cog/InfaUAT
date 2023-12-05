/**************************************************************************
JS file Name: Omniture_OnLoad.js.
Author: RaviChandra
Company: Informatica\Aditi
Date: 15-July-2012
Purpose: Holds all the function required across the application for the Omniture Reports.
Version: NA
Update: RaviChandra  updated the file to suite DI Lite requirments. Date: 08-Feb-2013
Update: RaviChandra  updated the file to Omniture Phase 2 . Date: 04-March-2013
Update: RaviChandra  updated the file to Fast Upgrade. Date: 18-Oct-2013
***************************************************************************/


/*Global variable used across the application
while setting the page name.
*/
var KBPrefix = "kb:";

var KBOmnitureDelimiter = "|";

var KBAnonymousUser = "Anonymous User";

/*
Get the LoggedIn User Display Name.
Input: NA
Returns: Returns the Display Name
Note: This method is Depreciated as we are using
Client Email id instead of login name.
Note: Currently no one calling it.
*/
function LoggedInUser() {

    //Get the Display name from HTML
    var Loginname = document.getElementById("zz8_Menu").innerHTML;
    var end = Loginname.indexOf("<");

    //Pick only the display name
    var nameOnly = Loginname.substring(8, end);

    return nameOnly;
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
Get the Cookie name 
Input: name of the Cookie
Returns: Cookie value
Note: No one calling it.
*/
function GetCookie(Name) {

    //Test Purpose only---SHOULD BE REMOVED IN UAT AND PROD
    return "test@infomatica.com";

    //Length of the cookie.
    var Len = Name.length;
    var i = 0;
    while (i < document.cookie.length) {
        var j = i + Len + 1;

        if (document.cookie.substring(i, j) == (Name + "="))
            return GetValue(j);
        i = document.cookie.indexOf(" ", i) + 1;
        if (i == 0)
            break;
    }
    return "";
}



/*
Get the Cookie name 
Input: name of the Cookie
Returns: Cookie value
*/
function GetClientEmailId(Name) {

    //Length of the cookie.
    var Len = Name.length;
    var i = 0;
    while (i < document.cookie.length) {
        var j = i + Len + 1;

        if (document.cookie.substring(i, j) == (Name + "="))
            if (GetValue(j).trim() == "") {
                return KBAnonymousUser;
            } else {
                return decodeURIComponent(GetValue(j));
            }
        i = document.cookie.indexOf(" ", i) + 1;
        if (i == 0)
            break;
    }
    return KBAnonymousUser;
}


/*
OnClick of FeedBack Button in the KB Article.
Input: NA
Returns: KB Feed Value
*/
function FeedbackOption(FeedbackRadioButtonId) {

    //Return value
    var iconvalue = "";
    //Get the Radio button Client ID
    var RB1 = document.getElementById(FeedbackRadioButtonId);
    //Get the Radio Options
    var radio = RB1.getElementsByTagName("input");
    for (var i = 0; i < radio.length; i++) {
        if (radio[i].checked) {
            switch (radio[i].value) {

                case 'This document resolved my issue':
                    iconvalue = "Resolved";
                    break;

                case 'This document did not resolve my issue':
                    iconvalue = "Did Not Help";
                    break;

                case 'This document helped but additional information was required to resolve my issue':
                    iconvalue = "Helpful but incomplete";
                    break;

            }
        }
    }
    //Return the Omniture value for the seleted option.
    return iconvalue;
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
OnClick event of Facebook and Twitter icon the KB Article.
Input: Takes the icon paramater to identify the Onclick event,
Returns: Omniture FaceBook and Twitter value
*/
function articleShareMedium(SocialClickIcon) {
    var articleShareMediumValue = "";
    switch (SocialClickIcon) {
        case 'Facebook': articleShareMediumValue = "Facebook";
            break;
        case 'Twitter': articleShareMediumValue = "Twitter";
            break;
        default: articleShareMediumValue = "";
    }
    //return the omniture value for the social click.
    return articleShareMediumValue;
}



/*
OnClick PDF Icon on the KB Article.
Returns: Returns  the PDF file name in the below format.
ex: KB-1234.pdf
*/
function KBArticlePDFFileName() {
    //Get the Current URL
    var currenturl = document.URL;
    var strDocID = "";
    var filepdf = "";
    //Get the PDF file name from KB Article Name
    if (currenturl.indexOf('?') > 0) {
        currenturl = currenturl.substring(0, currenturl.indexOf('?'));
        strDocID = currenturl.substring(currenturl.lastIndexOf('/') + 1);
        strDocID = strDocID.replace(".aspx", "");
    }

    else {
        var sa = [];
        sa = currenturl.split('/');

        for (var i = 0, length = sa.length; i < length; i++) {
            var chunk = sa[i];
            if (chunk.indexOf(".aspx") != -1) {

                var strf = chunk;
                strf = strf.replace(".aspx", "");
                strDocID = strf;
            }
        }
    }

    filepdf = "KB-" + strDocID.concat(".pdf");

    //return the pdf file name.
    return filepdf;
}



/*
Returns true if the value is not blank else false.
*/
function isBlank(str) {
    return (!str || /^\s*$/.test(str));
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
        var MySupport_Dev = "kb.informatica.com";

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
        else if (((((KBReferralURL.indexOf(MySupport_Test)) > 0) || ((KBReferralURL.indexOf(MySupport_Dev)) > 0))) && ((KBReferralURL.indexOf(eService_Test)) == -1)) {
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


    //ex: currenturl = "https://mysupport-test.informatica.com/infakb/whitepapers/2/Pages/109266.aspx?cid=FROM_SF_Feb2012";
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
    //ex: currenturl = "https://mysupport-test.informatica.com/infakb/KBExternal/Pages/KBSearchResults.aspx?k=Moodambail&fromsource=eservice";
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
    //ex: currenturl = "https://mysupport-test.informatica.com/infakb/KBExternal/Pages/KBSearchResults.aspx?k=Moodambail&fromsource=eservice";
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

/* 
Find the Read NonKB Documentation Type
*/
function ReadNonKBDocumentationType(content) {

    var doucumenttype;

    /*  if ((content.indexOf("/Product%20Documentation/")) > 0) {
    doucumenttype = "Documentation";
    }
    else if ((content.indexOf("/Product Documentation/")) > 0) {
    doucumenttype = "Documentation";
    }
    else if ((content.indexOf("/H2L%20Doc%20Library/")) > 0) {
    doucumenttype = "How-To Library";
    }  
    else if ((content.indexOf("H2L Doc Library")) > 0) {
    doucumenttype = "How-To Library";
    } */

    if ((content.indexOf("H2L Doc Library")) > 0) {
        doucumenttype = "How-To Library";
    }
    else if ((content.indexOf("/productdocumentation/PAM%20and%20EOL/")) >= 0) {
        doucumenttype = "PAM and EOL";
    }
    else if ((content.indexOf("/h2l/HowTo%20Library/")) >= 0) {
        doucumenttype = "How-To Library";
    }
    else if ((content.indexOf("/productdocumentation/Product%20Documentation/")) >= 0) {
        doucumenttype = "Product Documentation";
    }


    return doucumenttype;
}

/* 
Find the Read NonKB FileName
*/
function ReadNonKBFileName(content) {

    var NonKBFileName;
    if ((content.indexOf("/proddocs/Product%20Documentation/")) > 0) {
        var doc = content.indexOf("/proddocs/Product%20Documentation/");
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);

    }
    // Added to capture the path of the Product documentation 
    else if ((content.indexOf("/productdocumentation/Product%20Documentation/")) >= 0) {

        /*var doc = content.indexOf("/productdocumentation/Product%20Documentation/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
        */

        var doc = content.substring(content.lastIndexOf("/") + 1);
        var pdfname = doc;
        NonKBFileName = doc;

    }
    // Added to capture the path of the Product documentation 
    else if ((content.indexOf("/productdocumentation/Product Documentation/")) >= 0) {

        /*var doc = content.indexOf("/productdocumentation/Product%20Documentation/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
        */

        var doc = content.substring(content.lastIndexOf("/") + 1);
        var pdfname = doc;
        NonKBFileName = doc;

    }
    else if ((content.indexOf("/h2l/H2L%20Doc%20Library/")) > 0) {
        var doc = content.indexOf("/h2l/H2L%20Doc%20Library/") //("/How-To Library/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }

    else if ((content.indexOf("/productdocumentation/PAM%20and%20EOL/")) >= 0) {
        var doc = content.substring(content.lastIndexOf("/") + 1);
        var pdfname = doc;
        NonKBFileName = doc;
    }
    else if ((content.indexOf("/h2l/HowTo%20Library/")) >= 0) {
        var doc = content.substring(content.lastIndexOf("/") + 1);
        var pdfname = doc;
        NonKBFileName = doc;
    }
    else if ((content.indexOf("Product Documentation")) > 0) {
        var doc = content.indexOf("Product Documentation")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }
    else if ((content.indexOf("H2L Doc Library")) > 0) {
        var doc = content.indexOf("H2L Doc Library") //("/How-To Library/")
        var pdfname = content.indexOf("/", doc + 1);
        NonKBFileName = content.substring(pdfname + 1);
    }
    return NonKBFileName;
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
Get the Document type in the KB Article Page
*/
function ReadKBDocumentType() {
    var ArticleDocumentType = $("#td_Applies_To #DocTypeforOmniture").text();

    if ((ArticleDocumentType.indexOf("IPSKB")) > 0) {
        doucumenttype = "IPS KB";
    }

    else if ((ArticleDocumentType.indexOf("IPSDLHelp")) > 0) {
        doucumenttype = "IPS DL Help";
    }

    else if ((ArticleDocumentType.indexOf("SupportTV")) > 0) {
        doucumenttype = "Support TV";
    }

    else if ((ArticleDocumentType.indexOf("ExpertAssistant")) > 0) {
        doucumenttype = "Expert Assistant";
    }
    else {
        doucumenttype = "KB";
    }

    return $.trim(doucumenttype);
}


/* 
Get the KB Product in the KB Article Page
*/
function ReadKBProducts() {
    //var KBPrds = $("#KBMetaDataTable #KBProducts").text();
    // var KBPrds = $("#td_Applies_To #ProdNameforOmniture").text();
    return $('#td_INFA_Applies_To_Products').text().trim();
    // return $.trim(KBPrds);

}


/* 
Get the Search Count from All Documents Tab.

function GetTotalKBSearchCount(KBTotalResultCount) {

//Default set to zero.
var totalsearchcount = "zero";


if (isSearchResultsPage()) {

if (KBTotalResultCount != '0') {
//Make sure tab exists before we dig in.
if ($('div.communities').find('ul.tabs').find('li').length > 1) {
var AlldocumentTab = $('div.communities').find('ul.tabs').find('li:first').find('a').text();

//Get the number inside the round brackets
var AllDocPos = AlldocumentTab.indexOf("(") + 1;
totalsearchcount = AlldocumentTab.slice(AllDocPos, AlldocumentTab.lastIndexOf(")"));

}
//If not found, no results found. 
else {
totalsearchcount = 'zero';
}

}
}


return totalsearchcount;
}
*/



/* 
Get the Search Count from All Documents Tab.
*/
function GetTotalKBSearchCount(KBTotalResultCount) {

    //Default set to zero.
    var totalsearchcount = "zero";


    if (isSearchResultsPage()) {

        if (KBTotalResultCount != '0') {
            //Make sure tab exists before we dig in.
            if ($('.tabPanelbox').find('ul').find('li').length > 1) {
                var AlldocumentTab = $('.tabPanelbox').find('ul').find('li:first').find('a').text();

                //Get the number inside the round brackets
                var AllDocPos = AlldocumentTab.indexOf("(") + 1;
                totalsearchcount = AlldocumentTab.slice(AllDocPos, AlldocumentTab.lastIndexOf(")"));

            }
            //If not found, no results found. 
            else {
                totalsearchcount = 'zero';
            }

        }
    }


    return totalsearchcount;
}





/* 
Get the GetSelectedTab from the Search Results page.

function GetSelectedTab(KBTotalResultCount) {
if (isSearchResultsPage()) {
var selectedTabName = "";
if (KBTotalResultCount != '0') {
//Make sure tab exists before we dig in.
if ($('div.communities').find('ul.tabs').find('li').length > 1) {

//Find tab name,with the class name selected.
$('div.communities').find('ul.tabs').find('li').each(function (index) {
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
} */



function GetSelectedTab(KBTotalResultCount) {
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







/* Before Upgrade
Get the Count from the Knowledge Base Tab in Search Results page.

function GetKnowledgebaseTabItemCount(KBTotalResultCount) {
//Defualt will be zero.
var KBTabItemCount = "zero";
if (isSearchResultsPage()) {

if (KBTotalResultCount != '0') {

//Make sure tab exists before we dig in.
if ($('div.communities').find('ul.tabs').find('li').length > 1) {

//Loop through all the li tabs
$('div.communities').find('ul.tabs').find('li').each(function (index) {
{
//If the text is matching with Knowledge Base', get the count 
if (($(this).find('a').text().search('Knowledge Base')) > -1) {

var KBTabFullText = ($(this).text());
var KBTabDocPos = KBTabFullText.indexOf("(") + 1;
KBTabItemCount = KBTabFullText.slice(KBTabDocPos, KBTabFullText.lastIndexOf(")"));
if (KBTabItemCount == '0') {
KBTabItemCount = 'zero';
}
}
}
});
}
}

return KBTabItemCount
}
} */



/* 
Get the Count from the Knowledge Base Tab in Search Results page.
*/
function GetKnowledgebaseTabItemCount(KBTotalResultCount) {
    //Defualt will be zero.
    var KBTabItemCount = "zero";
    if (isSearchResultsPage()) {

        if (KBTotalResultCount != '0') {

            //Make sure tab exists before we dig in.
            if ($('.tabPanelbox').find('ul').find('li').length > 1) {

                //Loop through all the li tabs
                var KBTabFullText = $('.tabPanelbox').find('ul').find('li:nth-child(2)').text()

                if (KBTabFullText.lastIndexOf("Knowledge Base") > -1) {

                    var KBTabDocPos = KBTabFullText.indexOf("(") + 1;
                    KBTabItemCount = KBTabFullText.slice(KBTabDocPos, KBTabFullText.lastIndexOf(")"));
                    if (KBTabItemCount == '0') {
                        KBTabItemCount = 'zero';
                    }

                }
            }
        }

        return KBTabItemCount
    }
}



/* 
Find the Search Keyword from the Search Results page.
Input: ClientID.
*/
function GetKBSearchTerm(searchkeyword) {

    var KBSearchTerm;
    if (isSearchResultsPage()) {

        KBSearchTerm = document.getElementById(searchkeyword).value;
        KBSearchTerm = KBSearchTerm.replace('Search the Knowledge Base...', '');       
    }
    return KBSearchTerm;
}


/* 
Find the KB Refine search Option.
Input: ClientID of the all radio button
*/
function GetKBRefineSearchOption(rdallWordsID, rdanyWordID, rdexactPhraseID, rdKBID) {

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
Find the DocumentType in the search results.
Input: ClientID of the dropdown.
*/

function GetKBDocumentType(KBDocType) {

    var KBddlSelectedValue;

    if (isSearchResultsPage()) {

        var KBddlDocTypeID = document.getElementById(KBDocType);
        var KBddlSelectedValue = KBddlDocTypeID.options[KBddlDocTypeID.selectedIndex].text;

    }
    return KBddlSelectedValue;
}

/* 
Find the Basic/Advance Option in the search results.
Input: ClientID  of the div tag.

function GetKBToggleState(KBToggleState) {

var KBSearchOption;
if (isSearchResultsPage()) {

if (KBToggleState == "none") {
KBSearchOption = 'Simple';
}
else {
KBSearchOption = 'Advanced';
}
}
return KBSearchOption;
}
*/


/* 
Find the Basic/More Criteria option in the search results.
Input: ClientID  of the div tag.
*/
function GetKBToggleState(KBToggleState) {

    var KBSearchOption;
    if (isSearchResultsPage()) {

        if (KBToggleState == "none") {
            KBSearchOption = 'Simple';
        }
        else {
            KBSearchOption = 'More Criteria';
        }
    }
    return KBSearchOption;
}



/* 
Find the Product name under the advance filter.
Input: ClientID  of the dropdown.
*/
function GetKBProducts(KBProducts) {

    var KBProdName;
    if (isSearchResultsPage()) {
        var KBDDLProducts = document.getElementById(KBProducts);
        KBProdName = KBDDLProducts.options[KBDDLProducts.selectedIndex].text;
    }
    return KBProdName;
}


/* 
Find the Search DateRange under the advance filter.
Input: ClientID of the dropdown.
*/
function GetKBSearchDateRange(KBSeachDateRangeID) {

    var KBSearchDateRange;
    if (isSearchResultsPage()) {
        var DateRange = document.getElementById(KBSeachDateRangeID);
        KBSearchDateRange = DateRange.options[DateRange.selectedIndex].text;

    }
    return KBSearchDateRange;
}

/* 
Find the Search Results per page under the advance filter.
Input: ClientID of the dropdown.
*/
function GetKBSearchResultsPerPage(KBSearchResultsPerPageID) {

    var KBSearchResultsPage;
    if (isSearchResultsPage()) {

        var ddlResultsPerPage = document.getElementById(KBSearchResultsPerPageID);
        KBSearchResultsPage = ddlResultsPerPage.options[ddlResultsPerPage.selectedIndex].text;
    }
    return KBSearchResultsPage;
}



/* 
Find the Synonym and Lemmatization under the advance filter.
Input: ClientID of the checkbox.
*/
function GetKBSearchSynonym_Lemmatization(rdexactPhraseID, KBSearchSynonymID, KBSearchLemmatizationID) {

    var KBSynonym_Lemmatization_Selection = "";

    //Find the ExactPhrase radio button. If it is selected, don't send
    //Synonym and Lemmatization to Omniture
    KBSearchRefineExactPhraseID = document.getElementById(rdexactPhraseID);

    if ((isSearchResultsPage()) && (KBSearchRefineExactPhraseID.checked == 0)) {

        var KBSynonymCtrlID = document.getElementById(KBSearchSynonymID);

        var KBLemmatizationCtrlID = document.getElementById(KBSearchLemmatizationID);

        if ((KBSynonymCtrlID.checked) && (KBLemmatizationCtrlID.checked)) {
            KBSynonym_Lemmatization_Selection = 'Synonym,Lemmatization';
        }

        else if (KBSynonymCtrlID.checked) {
            KBSynonym_Lemmatization_Selection = 'Synonym';
        }

        else if (KBLemmatizationCtrlID.checked) {
            KBSynonym_Lemmatization_Selection = 'Lemmatization';
        }
    }
    return KBSynonym_Lemmatization_Selection;
}

/* 
Collects all the Search Events for Omniture.
If the search count is zero, event6 will be added
else it will be skipped. 
*/
function GetKBSeachResultsEvents(KBTotalResultCount, KBfilterValue) {
    var KBSearchResultsEvents = "";
    if (isSearchResultsPage()) {

        var KBTotalSearchItemsCount = GetTotalKBSearchCount(KBTotalResultCount);
        var KBTabSearchItemsCount = GetKnowledgebaseTabItemCount(KBTotalResultCount);

        //If total count is zero or KBTabSearchItems count is zero, add event5
        if ((KBTotalSearchItemsCount == 'zero') || (KBTabSearchItemsCount == 'zero')) {
            KBSearchResultsEvents = "event5,event6,event22,event23";
        }

        else if (KBTotalSearchItemsCount > 0) {
            KBSearchResultsEvents = "event5,event22,event23";
        }

        if (!isBlank(KBfilterValue)) {
            KBSearchResultsEvents = KBSearchResultsEvents.concat(',', "event40");
        }

    }
    else {
        KBSearchResultsEvents = "";
    }
    return KBSearchResultsEvents
}




/* 
Collects all the Search Events for DI Lite Omniture.
If the search count is zero, event6 will be added
else it will be skipped. 
*/
function GetKBDILiteSeachResultsEvents(totalResults) {
    var KBSearchResultsEvents;
    if (isSearchResultsPage()) {
        var KBTotalSearchItemsCount = totalResults;

        //If total count is zero or KBTabSearchItems count is zero, add event5
        if (KBTotalSearchItemsCount == '0') {
            KBSearchResultsEvents = "event5,event6,event22,event23";
        }

        else if (KBTotalSearchItemsCount > 0) {
            KBSearchResultsEvents = "event5,event22,event23";
        }
    }
    else {
        KBSearchResultsEvents = "";
    }
    return KBSearchResultsEvents
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
function SetLandingPageName() {
    var KBLandingPageName;
    //var KBPageLocation = $(location).attr('href');
    var KBPageLocation = window.location.href;
    if (KBPageLocation.toLowerCase().indexOf("/kbexternal/pages/home.aspx") >= 0) {
        KBLandingPageName = "KB:Home";
    } else if (KBPageLocation.toLowerCase().indexOf("/kbexternal/pages/kbdilite.aspx") >= 0) {

        KBLandingPageName = "KB:DILite";
    } else if ((KBPageLocation.toLowerCase().indexOf("preview/utilityextended.aspx") > -1) || (KBPageLocation.toLowerCase().indexOf("docid") > -1)) {
        KBLandingPageName = "Document View Page";
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
function GetSiteFeedBackFormValues(txtFeedbackName, txtFeedBackEmail, radioSiteFeedback, radioContentFeedback, radioReqNew, radioOthers, ddlFeedbackProducts, txtcomments) {

    var siteFeedBackFormValues = "";

    var siteFeedBackRdValues = GetSiteFeedBackRdValues(radioSiteFeedback, radioContentFeedback, radioReqNew, radioOthers, ddlFeedbackProducts);
    siteFeedBackFormValues = siteFeedBackFormValues.concat('FeedBackName:', txtFeedbackName, KBOmnitureDelimiter, 'FeedBackEmail:', txtFeedBackEmail, KBOmnitureDelimiter, 'Category:', siteFeedBackRdValues, KBOmnitureDelimiter, 'SiteFeedBackComments:', txtcomments);
    return siteFeedBackFormValues;

}

/* Purpose: Get and return the KB advance search filter values
Returns the KB Advanced search option values delimited by a separator*/
function KBAdvanceSearchFilter(ddlDocType, KBRefineSearchOption, ddlProducts, KBSearchDateRange, KBSearchResultsPerPage, GetKBSearchSynonym_Lemmatization) {
    var KBAdvanceFilterCombvalue = "";
    KBAdvanceFilterCombvalue = KBAdvanceFilterCombvalue.concat(ddlDocType, KBOmnitureDelimiter, KBRefineSearchOption, KBOmnitureDelimiter, ddlProducts, KBOmnitureDelimiter, KBSearchDateRange, KBOmnitureDelimiter, KBSearchResultsPerPage, KBOmnitureDelimiter, GetKBSearchSynonym_Lemmatization);
    return KBAdvanceFilterCombvalue;
}


/* Purpose: Get and return the KB Tab click
Send the seleceted KB tab Name to Omniture */
function KBLandingPageTabNameClick(KBTabName) {

    if (!isBlank(KBTabName)) {
        return KBTabName;
    }
    else {
        return "";
    }


}


/* Purpose: Get and return the Article selected in side the tab.
Send the seleceted KB article title to Omniture*/

function KBLandingPageArticleClickSendData(KBLandingArticleTitleVal) {
    if (!isBlank(KBLandingArticleTitleVal)) {
        var s = s_gi(s_account1);

        s.pageName = SetLandingPageName();

        //Client User ID
        s.eVar8 = GetClientEmailId("kbemail");

        //Document type KB, Doc, H2L, Velocity
        s.eVar34 = "";

        //Velocity Article Title
        s.eVar20 = "";

        //Referral URL
        s.eVar39 = KBReferralURL(document.referrer);

        //Get the selected KB Document Type
        s.eVar26 = "";

        //Get the selected Radio button
        s.eVar27 = "";

        //Get the Advance/Basic filter Type
        s.eVar28 = "";

        //Get the Product drop down  value
        s.eVar29 = "";

        //Get the Search Date Range value
        s.eVar30 = "";

        //Get the Search Results per page value
        s.eVar31 = "";

        //Get the Synonym, Lemmatization value.
        s.eVar32 = "";

        //Get the Selected search term
        s.prop7 = "";

        //Get the Total Count
        s.prop8 = "";

        //KB Tab Name
        s.eVar27 = KBLandingArticleTitleVal;

        s.events = "event42,event9";

        /****for Dynamic Account Selection     ******/
        s.dynamicAccountSelection = true
        s.dynamicAccountList = "informatica-mysupport-dev=kb-uno.informatica.com;informatica-mysupport-test=kb-test.informatica.com;informatica-mysupport-prod=kb.informatica.com";
        s.dynamicAccountMatch = window.location.host + window.location.pathname
        var s_code = s.t(); if (s_code) document.write(s_code)
    }
}


/* Purpose: Get and return the KB Tab click
Send the seleceted KB tab Name to Omniture */
function KBLandingPageTabNameClick_AfterLoad(KBTabName) {
    if (!isBlank(KBTabName)) {

        var s = s_gi(s_account1);

        s.pageName = SetLandingPageName();

        //Client User ID
        s.eVar8 = GetClientEmailId("kbemail");

        //Document type KB, Doc, H2L, Velocity
        s.eVar34 = "";

        //Velocity Article Title
        s.eVar20 = "";

        //Referral URL
        s.eVar39 = KBReferralURL(document.referrer);

        //Get the selected KB Document Type
        s.eVar26 = "";

        //Get the selected Radio button
        s.eVar27 = "";

        //Get the Advance/Basic filter Type
        s.eVar28 = "";

        //Get the Product drop down  value
        s.eVar29 = "";

        //Get the Search Date Range value
        s.eVar30 = "";

        //Get the Search Results per page value
        s.eVar31 = "";

        //Get the Synonym, Lemmatization value.
        s.eVar32 = "";

        //Get the Selected search term
        s.prop7 = "";

        //Get the Total Count
        s.prop8 = "";

        //KB Tab Name
        s.eVar26 = KBTabName;

        s.events = "event41,event9";

        /****for Dynamic Account Selection     ******/
        s.dynamicAccountSelection = true
        s.dynamicAccountList = "informatica-mysupport-dev=kb-uno.informatica.com;informatica-mysupport-test=kb-test.informatica.com;informatica-mysupport-prod=kb.informatica.com";
        s.dynamicAccountMatch = window.location.host + window.location.pathname
        var s_code = s.t(); if (s_code) document.write(s_code)

    }
}


/*Before Fast Upgrade
function KBLeftNavFilterValue() {

var KBLeftNavValue = "";
if ($('#innerCol1').find('div.greyBlock').find('a').length > 1) {
//Make sure we have the Filters before digging in.
var filterCount = $('#innerCol1').find('div.greyBlock').find('a').length;
$("#innerCol1").find('div.greyBlock').find('a').each(function (index) {
if ($(this).attr('title') == "Remove") {
KBLeftNavValue = KBLeftNavValue.concat(($(this).text()));
//Remove any spaces.
KBLeftNavValue = KBLeftNavValue.replace(/\s/g, "");
//To track the filters used.
filterCount = filterCount - 1;
if (filterCount > 1) {
KBLeftNavValue = KBLeftNavValue.concat('|');
}
}
})



}
return KBLeftNavValue;
} */



function KBLeftNavFilterValue() {

    var KBLeftNavValue = "";
    if ($('.gvSearchCSS').text().length > 0) {
        var filterCount = $('.gvSearchCSS').find('a').length;
        $(".gvSearchCSS").find('a').each(function (index) {
            if ($(this).attr('title') == "Remove") {

                KBLeftNavValue = KBLeftNavValue.concat(($(this).text()));
                //Remove any spaces.
                KBLeftNavValue = KBLeftNavValue.replace(/\s/g, "");

                filterCount = filterCount - 1;
                if (filterCount > 0) {
                    KBLeftNavValue = KBLeftNavValue.concat('|');
                }
            }
        })

    }
    return KBLeftNavValue;
}


//Fired when the form opens.
function KBSiteFeedBackStart() {
    s.eVar21 = "";
    s.eVar20 = "";
    s.eVar34 = "";
    s.eVar26 = "";
    s.eVar39 = "";
    s.pageName = "KBSiteFeedback";
    s.eVar8 = GetClientEmailId("kbemail");
    s.events = "event8,event38";
    /****for Dynamic Account Selection     ******/
    s.dynamicAccountSelection = true
    s.dynamicAccountList = "informatica-mysupport-dev=kb-uno.informatica.com;informatica-mysupport-test=kb-test.informatica.com;informatica-mysupport-prod=kb.informatica.com";
    s.dynamicAccountMatch = window.location.host + window.location.pathname
    var s_code = s.t(); if (s_code) document.write(s_code)
}

//On Click of PDF Export button the KB External Search Results page.
function PDFExportSelected() {
    s.eVar21 = "";
    s.eVar20 = "";
    s.eVar34 = "";
    //Get the Selected tab
    s.eVar33 = "";
    //Get the Selected search term
    s.prop7 = "";
    //Get the All Tabs Total Count
    s.prop8 = "";
    //Get KB Search Results tab count.
    s.prop24 = "";
    //Get the Advance/Basic filter Type
    s.eVar28 = "";
    //Get the Product drop down  value
    s.eVar29 = "";
    s.list1 = "";
    s.eVar50 = "";
    s.eVar39 = "";
    s.pageName = "kb:searchresults";
    s.eVar30 = "PDF Export"
    s.eVar8 = GetClientEmailId("kbemail");
    s.events = "event8,event44";
    /****for Dynamic Account Selection     ******/
    s.dynamicAccountSelection = true
    s.dynamicAccountList = "informatica-mysupport-dev=kb-uno.informatica.com;informatica-mysupport-test=kb-test.informatica.com;informatica-mysupport-prod=kb.informatica.com";
    s.dynamicAccountMatch = window.location.host + window.location.pathname
    var s_code = s.t(); if (s_code) document.write(s_code)

}