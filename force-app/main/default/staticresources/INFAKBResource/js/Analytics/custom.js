var isthisKBExternal = false;
var digitalData = undefined;
function fnLoadOmnitureAndWoopraScipt() {
      try {
            if (
                  (document.location.toString().toLowerCase().indexOf('/knowledge.informatica.com/') > -1 ||
                  document.location.toString().toLowerCase().indexOf('/kb-test.informatica.com/') > -1 ||
                  document.location.toString().toLowerCase().indexOf('/kb-uno.informatica.com/') > -1 ||
                  document.location.toString().toLowerCase().indexOf('kbexternal') > -1 ||
                  document.location.toString().toLowerCase().indexOf('kbdev-infa') > -1 ||
                  document.location.toString().toLowerCase().indexOf('sit-infa') > -1 ||
                  document.location.toString().toLowerCase().indexOf('uat-infa') > -1 ||
                  document.location.toString().toLowerCase().indexOf('satish-infa')) && ((document.location.toString().toLowerCase().indexOf('/s/article/')> -1) || (document.location.toString().toLowerCase().indexOf('/s/articlepreview')> -1))
            ) {
                  isthisKBExternal = true;
            } else {
                  isthisKBExternal = false;
            }
            if (isthisKBExternal) {
                  var isProd = false;

                  if (document.location.href.indexOf('https://knowledge.informatica.com') > -1) {
                        isProd = true;
                  }
                  digitalData = digitalData || {};
                  digitalData.site = { isProduction: isProd, country: 'go', language: 'en', region: 'na', name: 'in' };
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
                  var timestamp =
                        month + '/' + day + '/' + year + ' ' + hrs + ':' + mins + ':' + seconds + ' ' + timeOfDay + offset;
                  digitalData.server = { date: timestamp };
            }
           
            function getArticleID() {
                  let articleURL = window.location.href;
                  let articleID = articleURL.substr(articleURL.lastIndexOf('/') + 1);
                  return articleID;
            }

            if (isthisKBExternal) {

                  (function () {
                        var t,
                              i,
                              e,
                              n = window,
                              o = document,
                              a = arguments,
                              s = 'script',
                              r = ['config', 'track', 'identify', 'visit', 'push', 'call'],
                              c = function () {
                                    var t,
                                          i = this;
                                    for (i._e = [], t = 0; r.length > t; t++)
                                          (function (t) {
                                                i[t] = function () {
                                                      return i._e.push([t].concat(Array.prototype.slice.call(arguments, 0))), i;
                                                };
                                          })(r[t]);
                              };
                        for (n._w = n._w || {}, t = 0; a.length > t; t++) n._w[a[t]] = n[a[t]] = n[a[t]] || new c();
                        (i = o.createElement(s)),
                              (i.async = 1),
                              (i.src = '//static.woopra.com/js/w.js'),
                              (e = o.getElementsByTagName(s)[0]),
                              e.parentNode.insertBefore(i, e);
                  })('woopra');
      
                  if (document.location.href.indexOf('knowledge.informatica.com') > -1) {
                        woopra.config({
                              domain: 'mysupport.informatica.com',
                              cookie_domain: '.informatica.com',
                              idle_timeout: 10000000,
                              download_tracking: false,
                              outgoing_tracking: false
                        });
                  } else {
                        woopra.config({
                              domain: 'mysupport-test.informatica.com',
                              cookie_domain: '.informatica.com',
                              idle_timeout: 10000000,
                              download_tracking: false,
                              outgoing_tracking: false
                        });
                  }


                  woopra.track('KB Page', {
                        Page_Visited: 'KB:View Documents Page',
                        Pg_lnk_vstd: window.location.href,
                        title: document.title
                  });
                  woopra.track('KB Page View', {
                        PgVw_Art_Ttle: document.title,
                        PgVw_Art_ID: getArticleID(),
                        Art_lnk_Vstd: window.location.href
                  });
            }
      
      
            (function (w) {
                  var utilMethods = {
                        'trackEmail': trackEmail,
                        'trackFollow': trackFollow,
                        'trackExportToPdf': trackExportToPdf,
                        'trackCopyURL': trackCopyURL,
                        'trackPrint': trackPrint,
                        'trackBookmark': trackBookmark,
                        'fnSetOktaUserID': fnSetOktaUserID,
                        'trackExternalFeedback': trackExternalFeedback,
                        'fnSetWoopraDetails': fnSetWoopraDetails
                  
                  };
   

                  function trackEmail() {
                        console.log('Test Email Tracking')
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'successful_activity';
                                    digitalData.activity = {};
                                    digitalData.activity.type = 'Article Action';
                                    digitalData.activity.title = 'Send Email';
                                    _satellite.track(digitalData.event.eventType, digitalData);
                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Email", {
                                    Fllw_Art_Ttle: document.title,
                                    Fllw_Art_ID: getArticleID()
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function trackCopyURL() {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'successful_activity';
                                    digitalData.activity = {};
                                    digitalData.activity.type = 'Article Action';
                                    digitalData.activity.title = 'Copy URL';
                                    _satellite.track(digitalData.event.eventType, digitalData);
                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Copy URL", {
                                    Fllw_Art_Ttle: document.title,
                                    Fllw_Art_ID: getArticleID()
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function trackExportToPdf() {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'successful_activity';
                                    digitalData.activity = {};
                                    digitalData.activity.type = 'Article Action';
                                    digitalData.activity.title = 'Export To PDF';
                                    _satellite.track(digitalData.event.eventType, digitalData);
                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Export to PDF", {
                                    Fllw_Art_Ttle: document.title,
                                    Fllw_Art_ID: getArticleID()
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function trackPrint() {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'successful_activity';
                                    digitalData.activity = {};
                                    digitalData.activity.type = 'Article Action';
                                    digitalData.activity.title = 'Print';
                                    _satellite.track(digitalData.event.eventType, digitalData);
                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Print", {
                                    Fllw_Art_Ttle: document.title,
                                    Fllw_Art_ID: getArticleID()
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function trackBookmark() {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'successful_activity';
                                    digitalData.activity = {};
                                    digitalData.activity.type = 'Article Action';
                                    digitalData.activity.title = 'Bookmark';
                                    _satellite.track(digitalData.event.eventType, digitalData);
                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track('Article Bookmark', {
                                    Bkmrk_Sel: 'Bookmark Added',
                                    PgVw_Art_ID: 'Informatica KB - ' + getArticleID(),
                                    Art_lnk_Vstd: window.location.href,
                                    PgVw_Art_Ttle: document.title
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }

                  function trackFollow() {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'form_step';
                                    digitalData.form = {};
                                    digitalData.form.formType = 'follow-article';
                                    digitalData.form.formStatus = 'completed';
                                    digitalData.form.platformSystem = 'Salesforce';
                                    _satellite.track(digitalData.event.eventType, digitalData);

                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Follow", {
                                    Fllw_Art_Ttle: document.title,
                                    Fllw_Art_ID: getArticleID()
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function fnSetOktaUserID(oktaID) {
                        try {
                              if (typeof digitalData === 'undefined') {
                              } else {
                                    if (oktaID) {
                                          digitalData.visitor = { oktaUserId: oktaID, networkStatus: "logged in" };
                                    }
                                    else {
                                          digitalData.visitor = { networkStatus: "anonymous" };
                                    }
                                    console.log("KB Provides the visitor details to DTM");
                              }
                        } catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function fnSetWoopraDetails(oktaID, email) {
                        try {
                              console.log("Woopra Set Details");
                              if (oktaID) {
                                    woopra.identify({
                                          name: email,
                                          oktaId: oktaID
                                    });
                              }
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                  function trackExternalFeedback(vote, articleComment) {
                        if (typeof digitalData === 'undefined') {
                        } else {
                              try {
                                    console.log('vote', vote)
                                    digitalData.event = {};
                                    digitalData.event.eventType = 'form_step';
                                    digitalData.form = {};
                                    digitalData.form.formType = 'article-feedback';
                                    digitalData.form.formStatus = vote;
                                    digitalData.form.formStepName = 'completed';
                                    digitalData.form.platformSystem = 'Salesforce';
                                    _satellite.track(digitalData.event.eventType, digitalData);

                              }
                              catch (ex) {
                                    console.log(ex.message);
                              }
                        }
                        try {
                              woopra.track("Article Feedback", {
                                    Fdbk_Art_Ttle: document.title,
                                    fdbk_Art_ID: getArticleID(),
                                    Fdbk_sel: vote,
                                    Fdbk_Cnt: articleComment
                              });
                        }
                        catch (ex) {
                              console.log(ex.message);
                        }
                  }
                                   
                  w.util = utilMethods;

            })(window);
      }
      catch (ex) {
            console.error("Method : fnLoadOmnitureAndWoopraScipt; Error :" + ex.description);
      }
}

fnLoadOmnitureAndWoopraScipt();
