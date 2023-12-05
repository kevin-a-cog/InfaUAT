var isProd = false;
var isthisKBExternal = false;
var digitalData = undefined;
function loadAdobeAnalyticsScipt() {

    if (document.location.href.indexOf('experience.informatica.com') > -1) {
        isProd = true;
    }
    digitalData = digitalData || {};
    digitalData.site = { isProduction: isProd, country: "go", language: "en", region: "na", name: "in" };
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
        digitalData.page = { section: "experience", subSection1: '', subSection2: window.location.href.substr(window.location.href.lastIndexOf('/')+1), subSection3: "", subSection4: "", subSection5: "", name: document.title, type: "network page" };
    } catch (ex) {
        console.log(ex.message)
    }


    (function(w){
        var utilMethods = {
                "trackFavAccount": trackFavAccount,
                "trackButtonClick": trackButtonClick,
                "setOktaUserID": setOktaUserID
            };

        function trackFavAccount() {
            console.log('Calling track fav');
            if (typeof digitalData === 'undefined') {
            } else {   
                try {
                    digitalData.event = {};
                    digitalData.event.eventType = 'successful_activity';
                    digitalData.activity = {};
                    digitalData.activity.type = 'make fav';
                    digitalData.activity.title = 'Make fav support account';
                    _satellite.track(digitalData.event.eventType, digitalData);

                }
                catch(ex) {
                    console.log(ex.message);
                }
            }
        }
        // function trackGlobalSearch() {
        //     if (typeof digitalData === 'undefined') {
        //     } else {   
        //         try {
        //             digitalData.event = {};
        //             digitalData.event.eventType = 'successful_activity';
        //             digitalData.activity = {};
        //             digitalData.activity.type = 'global search click';
        //             digitalData.activity.title = 'GlobalSearch';
        //             _satellite.track(digitalData.event.eventType, digitalData);
        //         }
        //         catch(ex) {
        //             console.log(ex.message);
        //         }
        //     }
        // }
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
        function setOktaUserID(oktaID) {
            try {
                if (typeof digitalData === 'undefined') {
                } else {
                    if(oktaID) {
                        digitalData.visitor = { };
                        digitalData.visitor.oktaUserId= oktaID;
                        digitalData.visitor.networkStatus= "logged in" ;
                    }
                    else {
                        digitalData.visitor = { networkStatus: "anonymous" };
                    }
                    console.log("Provides the details");
                }
            } catch (ex) {
                console.log(ex.message);
            }
        }

        w.util = utilMethods;

    })(window);
}

loadAdobeAnalyticsScipt();
