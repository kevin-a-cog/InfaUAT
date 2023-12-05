var isProd = false;
var isthisKBExternal = false;
var digitalData = undefined;
function loadAdobeAnalyticsScipt() {
    if (document.location.href.indexOf('network.informatica.com') > -1) {
        isProd = true;
    }
    digitalData = digitalData || {};
    digitalData.site = { isProduction: isProd, country: "go", language: "en", region: "na", name: "in", page: document.title };
    var today = new Date();
    var month = today.getMonth();
    var day = today.getDate();
    var year = today.getFullYear();
    var hrs = today.getHours();
    var mins = today.getMinutes();
    var seconds = today.getSeconds();
    var offset = today.getTimezoneOffset();
    var timeOfDay = '';
    if (hrs > 12) {
        timeOfDay = 'PM';
    } else {
        timeOfDay = 'AM';
    }
    var timestamp = month + '/' + day + '/' + year + ' ' + hrs + ':' + mins + ':' + seconds + ' ' + timeOfDay + offset;
    digitalData.server = { date: timestamp };

    try {
        if(window.location.href.substr(window.location.href.lastIndexOf('/')+1) == ''){
            digitalData.page = { section: "Informatica Network", subSection1:window.location.href.substr(window.location.href.lastIndexOf('/')+1), name: document.title, type: "network page" };
        }else{
            digitalData.page = { section: "Informatica Network", subSection1: document.title, name: window.location.href.substr(window.location.href.lastIndexOf('/')+1), type: "network page" };
        }
    } catch (ex) {
        console.log(ex.message)
    }


    (function(w){
        var utilMethods = {
                "trackGlobalSearch": trackGlobalSearch,
                "trackPageSection": trackPageSection,
                "trackButtonClick": trackButtonClick,
                "setOktaUserID": setOktaUserID,
                "trackLinkClick": trackLinkClick,
                "trackAnonymousHomePage": trackAnonymousHomePage,
                "trackPageView": trackPageView
            };

        function trackGlobalSearch(searchTerm) {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.event = {};
                    digitalData.event.eventType = 'search_link_tracking';
                    digitalData.search = {};
                    digitalData.search.keyword = searchTerm;
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        function trackPageSection(_section, _subsection) {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.page = {};
                    digitalData.page = { section: "Informatica Network:"+_section+':'+ _subsection, subSection1: document.title, name: window.location.href.substr(window.location.href.lastIndexOf('/')+1), type: "network page" };
                    digitalData.event = {};
                    digitalData.event.eventType = 'page_view';
                    digitalData.link = {};
                    digitalData.link.linkPosition = 'button click';
                    digitalData.link.linkTitle = _subsection;
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        
        function trackAnonymousHomePage() {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.page = {};
                    digitalData.page = { section: "Informatica Network", subSection1: window.location.href.substr(window.location.href.lastIndexOf('/')+1), name: "in portal", type: "network page" };
                    digitalData.event = {};
                    digitalData.event.eventType = 'page_view';
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        
        function trackPageView() {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.event = {};
                    digitalData.event.eventType = 'page_view';
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
    
        function trackButtonClick(action) {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.event = {};
                    digitalData.event.eventType = 'nav_tracking';
                    digitalData.link = {};
                    digitalData.link.linkPosition = 'button click';
                    digitalData.link.linkTitle = action;
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        function trackLinkClick(action) {
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.event = {};
                    digitalData.event.eventType = 'nav_tracking';
                    digitalData.link = {};
                    digitalData.link.linkPosition = 'link click';
                    digitalData.link.linkTitle = action;
                    _satellite.track(digitalData.event.eventType, digitalData);
                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        function setOktaUserID(oktaID) {
            try {
                if (typeof digitalData === 'undefined') {
                } else {
                    if(oktaID) {
                        digitalData.visitor = { };
                        digitalData.visitor.oktaUserId= oktaID;
                        digitalData.visitor.networkStatus= "logged in" ;
                        userData = oktaID;
                    }
                    else {
                        digitalData.visitor = { networkStatus: "anonymous" };
                    }
                }
            } catch (ex) {
                console.log(ex.message);
            }
        }

        w.util = utilMethods;

    })(window);
}

loadAdobeAnalyticsScipt();
