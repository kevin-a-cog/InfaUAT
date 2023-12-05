
/*
   JS file Name      : Omniture_DTM.js.
   @created by       : Sathish R
   @created on       : 11-Oct-2016
   @Purpose          : Holds all the function required across the application for the Omniture DTM Reports.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  17-Aug-2023      |  Sathish R                |    I2RT-8631      |   Provide 'Join the Community' option on Knowledge Article detail page. 
 ****************************************************************************************************
 */


/*Global variable used across the application

*/


// var isthisKBExternal = false;
// if ((((document.location.toString()).toLowerCase()).indexOf("/kb.informatica.com/") > -1) || (((document.location.toString()).toLowerCase()).indexOf("/kb-test.informatica.com/") > -1) || (((document.location.toString()).toLowerCase()).indexOf("/kb-uno.informatica.com/") > -1) || (((document.location.toString()).toLowerCase()).indexOf("kbexternal") > -1) || 
// (((document.location.toString()).toLowerCase()).indexOf("kbdev-infa") > -1) ||
// (((document.location.toString()).toLowerCase()).indexOf("sit-infa") > -1) ||
// (((document.location.toString()).toLowerCase()).indexOf("uat-infa") > -1)) {
//     isthisKBExternal = true;
// } else {
//     isthisKBExternal = false;
// }
// if (isthisKBExternal) {

//     var isProd = false;

//     if (document.location.href.indexOf('https://kb.informatica.com') > -1) {
//         isProd = true;
//     }
//     var digitalData = digitalData || {};
//     digitalData.site = { isProduction: isProd, country: "go", language: "en", region: "na", name: "in" };
//     var today = new Date();
//     var month = today.getMonth();
//     var day = today.getDate();
//     var year = today.getFullYear();
//     var hrs = today.getHours();
//     var mins = today.getMinutes();
//     var seconds = today.getSeconds();
//     var offset = today.getTimezoneOffset();
//     var timeOfDay = '';
//     if (hrs > 12) {
//         timeOfDay = 'PM';
//     } else {
//         timeOfDay = 'AM';
//     }
//     var timestamp = month + '/' + day + '/' + year + ' ' + hrs + ':' + mins + ':' + seconds + ' ' + timeOfDay + offset;
//     digitalData.server = { date: timestamp };

//     try {
//         digitalData.page = { section: "kb", subSection1: '', subSection2: window.location.href.substr(window.location.href.lastIndexOf('/')+1), subSection3: "", subSection4: "", subSection5: "", name: document.title, type: "network page" };
//     } catch (ex) {
//         cosnole.log(ex.message)
//     }
// }



//call to set the okta user id 
function fnSetOKatUserID(currentUserOKatUserID) {
      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  digitalData.visitor = { oktaUserId: currentUserOKatUserID, networkStatus: "logged in" };
                  console.log("KB Provides the visitor details to DTM");
            }
      } catch (ex) {
            console.error("Method : fnSetOKatUserID; Error :" + ex.description);
      }
}

//call to  set digitaldata varialbe not to tracked
function fnDisableDigitalDataTrack() {

      try {

            if (typeof digitalData != 'undefined') {

                  digitalData.page = {
                        trackPage: false
                  };
                  console.log("KB disables the digitalData.page.trackPage as false");
            }

      } catch (ex) {
            console.error("Method : fnDisableDigitalDataTrack; Error :" + ex.description);
      }

}

//call to set all the search details like tabName, keyword, visitor, server, site and filters on page load
function fnCaptureAllOnPageLoad() {
      try {

            if (typeof digitalData != 'undefined') {
                  var omnitureVisitor = fnGetVisitorDetails();

                  analytics.track({
                        event: {
                              eventType: "page_view"
                        },
                        page: {
                              section: "kb",
                              subSection1: digitalData.page.subSection1,
                              subSection2: digitalData.page.subSection2,
                              subSection3: "",
                              subSection4: "",
                              subSection5: "",
                              name: digitalData.page.name, // See the page names table
                              type: "network page"
                        },
                        site: {
                              isProduction: digitalData.site.isProduction,
                              country: digitalData.site.country,
                              language: digitalData.site.language,
                              region: digitalData.site.region,
                              name: digitalData.site.name
                        },
                        visitor: omnitureVisitor,
                        server: {
                              date: digitalData.server.date
                        }
                  });
                  console.log("KB Provides the page details to DTM");

            }

      } catch (ex) {
            console.error("Method : fnCaptureAllOnPageLoad; Error :" + ex.description);
      }
}

//called to get the user details
function fnGetVisitorDetails() {
      var visitor = visitor || {};
      try {
            if (typeof digitalData != 'undefined') {
                  if (typeof digitalData.visitor.oktaUserId != 'undefined') {
                        visitor = {
                              networkStatus: digitalData.visitor.networkStatus,
                              oktaUserId: digitalData.visitor.oktaUserId
                        };

                  } else {
                        visitor = {
                              networkStatus: digitalData.visitor.networkStatus
                        };
                  }
                  console.log("KB Provides the visitor details to DTM");
            }
      } catch (e) {
            console.error("Method : fnGetVisitorDetails; Error :" + e.description);
      }
      return visitor;
}



function fnSetOmniturePageDetails(articleSubject, articleID, aticleTitle) {
      //alert(articleSubject+ articleID+ aticleTitle);
      try {
            console.log('analytics called');
            fnLoadAdobeScript();
            if (typeof digitalData === 'undefined') {
            } else {
                  digitalData.page = { section: "kb", subSection1: articleSubject, subSection2: articleID, subSection3: "", subSection4: "", subSection5: "", name: aticleTitle, type: "network page" };
                  console.log("KB Provides the page details to DTM");
            }
      } catch (ex) {
            console.error("Method : fnSetOmniturePageDetails Error :" + e.description);
      }
}

function fnSetOmniturePageDetailsWithDisabledDataTrack(articleSubject, articleID, aticleTitle) {
      //alert(articleSubject+ articleID+ aticleTitle);
      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  digitalData.page = { section: "kb", subSection1: articleSubject, subSection2: articleID, subSection3: "", subSection4: "", subSection5: "", name: aticleTitle, type: "network page", trackPage: false };
            }
      } catch (ex) {
            console.error("Method : fnSetOmniturePageDetailsWithDisabledDataTrack Error :" + e.description);
      }
}



//Called When the Email is submittd
function fnEmailOmnitureDTMSubmit() {

      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  var emailStatus = "started";
                  var emailStepName = "email this document";
                  var emailStepNumber = "1";


                  analytics.track({
                        event: {
                              eventType: "form_step"
                        },
                        form: {
                              platformSystem: "",
                              programName: "",
                              programType: "",
                              formType: "kb share by email",
                              formName: "",
                              formStatus: emailStatus,
                              formRegion: "",
                              formCountry: "go",
                              formDetails: {},
                              formStepNumber: emailStepNumber,
                              formStepName: emailStepName
                        }
                  });

            }
      }
      catch (ex) {
            console.error("Method : fnEmailOmnitureDTMSubmit; Error :" + e.description);
      }
}


//Called When the Email is Completed
function fnEmailOmnitureDTMCompleted() {

      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  var emailStatus = "completed";
                  var emailStepName = "email complete";
                  var emailStepNumber = "2";


                  analytics.track({
                        event: {
                              eventType: "form_step"
                        },
                        page: {
                              name: "email thank you"
                        },
                        form: {
                              platformSystem: "",
                              programName: "",
                              programType: "",
                              formType: "kb share by email",
                              formName: "",
                              formStatus: emailStatus,
                              formRegion: "",
                              formCountry: "go",
                              formDetails: {},
                              formStepNumber: emailStepNumber,
                              formStepName: emailStepName
                        }
                  });

            }
      }
      catch (ex) {
            console.error("Method : fnEmailOmnitureDTMSubmit; Error :" + e.description);
      }
}

//Called When the feebback is submittd
function fnFeedbackOmnitureDTMSubmit(selectedFeedbackOption) {

      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  var feedbackStatus = "started";
                  var feedbackStepName = "feedback submit";
                  var feedbackStepNumber = "1";


                  analytics.track({
                        event: {
                              eventType: "form_step"
                        },
                        feedback: {
                              optionSelected: selectedFeedbackOption
                        },
                        form: {
                              platformSystem: "",
                              programName: "",
                              programType: "",
                              formType: "kb feedback",
                              formName: "",
                              formStatus: feedbackStatus,
                              formRegion: "",
                              formCountry: "go",
                              formDetails: {},
                              formStepNumber: feedbackStepNumber,
                              formStepName: feedbackStepName
                        }
                  });
            }
      }
      catch (ex) {
            console.error("Method : fnEmailOmnitureDTMSubmit; Error :" + e.description);
      }
}


//Called When the feebback is completed
function fnFeedbackOmnitureDTMCompleted() {

      try {
            if (typeof digitalData === 'undefined') {
            } else {
                  var feedbackStatus = "completed";
                  var feedbackStepName = "feedback complete";
                  var feedbackStepNumber = "2";


                  analytics.track({
                        event: {
                              eventType: "form_step"
                        },
                        page: {
                              name: "feedback thank you"
                        },
                        form: {
                              platformSystem: "",
                              programName: "",
                              programType: "",
                              formType: "kb feedback",
                              formName: "",
                              formStatus: feedbackStatus,
                              formRegion: "",
                              formCountry: "go",
                              formDetails: {},
                              formStepNumber: feedbackStepNumber,
                              formStepName: feedbackStepName
                        }
                  });
            }
      }
      catch (ex) {
            console.error("Method : fnFeedbackOmnitureDTMCompleted; Error :" + e.description);
      }
}

window.trackEmail = function () {
      console.log('Test Email Tracking')
      if (typeof digitalData === 'undefined') {
      } else {
            // //if (typeof (analytics) !== "undefined" && typeof (analytics.track) !== "undefined") {
            //     analytics.track({
            //         event: {
            //             eventType: "Send Email"
            //         },
            //         page: {
            //             name: window.location.href
            //         },
            //     });
            // //}   
            digitalData.event = {};
            digitalData.event.eventType = 'successful_activity';
            digitalData.page = {};
            digitalData.page.name = window.location.href;
            console.log(digitalData);

            try {
                  console.log(_satellite);
                  _satellite.track("successful_activity", digitalData);
            }
            catch (ex) {
                  console.error('Method : trackEmail :' + ex.message);
            }
      }
}
//Called When the rating is submittd and completed
function fnRatingOmnitureDTM(currentRating, averageRating, numberOfRating) {
      try {
            //alert(currentRating + averageRating + numberOfRating);
            if (typeof digitalData === 'undefined') {
            } else {
                  analytics.track({
                        event: {
                              eventType: "successful_activity"
                        },
                        activity: {
                              type: "kb",
                              title: "rate it"
                        },
                        rate: {
                              value: currentRating,
                              averageRating: averageRating,
                              numberRates: numberOfRating
                        }
                  });
            }
      }
      catch (ex) {
            console.error('Method : fnRatingOmnitureDTM :' + ex.message);
      }

}


function fnGetFeedbackOptionName(FeedbackRadioButtonId) {
      //Return value
      var iconvalue = "";
      try {

            //Get the Radio button Client ID
            var RB1 = document.getElementById(FeedbackRadioButtonId);
            //Get the Radio Options
            var radio = RB1.getElementsByTagName("input");
            for (var i = 0; i < radio.length; i++) {
                  if (radio[i].checked) {
                        switch (radio[i].value) {

                              case 'This document resolved my issue':
                                    iconvalue = "This document resolved my issue";
                                    break;

                              case 'This document did not resolve my issue':
                                    iconvalue = "This document did not resolve my issue";
                                    break;

                              case 'This document helped but additional information was required to resolve my issue':
                                    iconvalue = "This document helped but additional information was required to resolve my issue";
                                    break;

                        }
                  }
            }
            //Return the Omniture value for the seleted option.

      }
      catch (ex) {
            console.error('Method : fnGetFeedbackOptionName :' + ex.message);
      }
      return iconvalue;
}


function fnCheckTillUserNameAvailable(execCount) {
      try {
            if ($('.user-progress-icon.user-login-info-hide').length > 0) {
                  fnToBeCalledOnceUserNameAvailable();
            } else if (execCount < 600) {
                  execCount = execCount + 1;
                  window.setTimeout(function () { fnCheckTillUserNameAvailable(execCount); }, 100);
            }
      } catch (ex) {
            console.error('Method : fnCheckTillItsAvailable :' + ex.message);
      }
}

function fnToBeCalledOnceUserNameAvailable() {
      try {

            var firstName = '';
            var userid = undefined;
            var userType = undefined;
            try {
                  firstName = document.getElementById('authenticated-firstName').innerText;
                  userid = document.getElementById('authentication-userId').innerText;
                  userType = document.getElementById('authentication-userType').innerText;
            } catch (exsub) { }

            if (userType == undefined || userType == 'Guest') {
                  userid = undefined;
            }

            util.fnSetOktaUserID(userid);
            util.fnSetWoopraDetails(userid, firstName);
            fnLoadAdobeScript();
            // if (document.location.href.indexOf('https://knowledge.informatica.com') > -1) {
            //       varOmnitureAnalytics = document.createElement('script');
            //       varOmnitureAnalytics.src =
            //             '//assets.adobedtm.com/75780ca42467931140f0faa235f03d9dd145eb96/satelliteLib-53c18c53e3988a1ec3f454426ebc0b97c7ee28b0.js';
            //       document.body.appendChild(varOmnitureAnalytics);
            // } else {
            //       varOmnitureAnalytics = document.createElement('script');
            //       varOmnitureAnalytics.src =
            //             '//assets.adobedtm.com/302a2f5d5463/a43eaf1d7428/launch-ce06de9b21ed-staging.min.js';
            //       document.body.appendChild(varOmnitureAnalytics);
            // }
      } catch (ex) {
            console.error('Method : fnToBeCalledOnceUserNameAvailable :' + ex.message);
      }
}

function fnLoadAdobeScript(){
      if (document.location.href.indexOf('https://knowledge.informatica.com') > -1) {
                  varOmnitureAnalytics = document.createElement('script');
                  varOmnitureAnalytics.src =
                        '//assets.adobedtm.com/75780ca42467931140f0faa235f03d9dd145eb96/satelliteLib-53c18c53e3988a1ec3f454426ebc0b97c7ee28b0.js';
                  document.body.appendChild(varOmnitureAnalytics);
            } else {
                  console.log('adobe script called');
                  varOmnitureAnalytics = document.createElement('script');
                  varOmnitureAnalytics.src =
                        '//assets.adobedtm.com/302a2f5d5463/a43eaf1d7428/launch-ce06de9b21ed-staging.min.js';
                  document.body.appendChild(varOmnitureAnalytics);
            }
}
//Start <Tag 1>
function fnAskACommunityOmnitureDTM(action) {
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
            console.error('Method : fnAskACommunityOmnitureDTM :' + ex.message);
          }
      }
}
//End <Tag 1>











