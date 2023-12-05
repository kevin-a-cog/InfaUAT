/*
   @created by       : SathishR
   @created on       : 20/02/2020
   @Purpose          : Holds all the function required  for Content Visited Feature.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  13-Apr-2021      |   Sathish R               |     KB-145        |   Initial Version 
 |     2      |  05-May-2023      |   Sathish R               |     I2RT-7586     |   Tech Debt : Coveo JS UI version upgrade in eSupport Case Creation page, Global Search Bar and KB Internal Search.
 ****************************************************************************************************
 */

(function (w) {

      try {
            
      
   
            jQuery.support.cors = true;

      
            //-------------------------------------------------------------------------------<T02>
            //this is the first function called to hook the eventhandler for the result items.
            //for the content visited feature
            //Event handler for Click event hooked to all the reuslt link
            //Event handler for newResultDisplayed event hooked to show more replies link
            function fnDisplayVisitedContentDetails() {
                  try {
                        //-------------------------------------------------------------------------------<T05>
                        Coveo.$$(document.querySelector('#searchinfakbcs')).on('deferredQuerySuccess', function (e, result) {
  
                              fnDecideToLoadContentVisitedData(0); // this function is actually placed in the deferredQuerySuccess method in InfaSearch.js
  
                        });
  
                        $('.CoveoResultList').on('newResultDisplayed', fnDisplayVisitedContentDetailsForShowMore); // this function is actually placed in the deferredQuerySuccess method in InfaSearch.js
                        //-------------------------------------------------------------------------------<T05>
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnDisplayVisitedContentDetails : ' + err.message);
                  }
            }
  
            //-------------------------------------------------------------------------------<T05>
            function fnIntializeContentVisitedFeature() {
                  try {
                        InfaKBCommonUtilityJs.Log('log', 'fnIntializeContentVisitedFeature called');
                        //Assign event to capture the click
                        if ($("[class^='CoveoResultLink']").length != 0) {
                              $("[class^='CoveoResultLink']").bind('click', fnContentVistedInsertOrUpdateData);
                        }
  
                        var elements = $('.CustomContentVisited');
  
                        for (var k = 0; k < elements.length; k++) {
                              if ($(elements[k]).attr('data-customContentURL').length > 0) {
                                    var itemURL = $(elements[k]).attr('data-customContentURL').trim().toString().toLowerCase();
                                    //itemURL = itemURL.split(/[?#]/)[0];
				    //Change Realted to New Coveo Framework - v2.10104.0//T02
                                    var varVisitorId = fnGetContentVistorId();
                                    if (varVisitorId != undefined)
                                          fnGetVisitedContentDetails(itemURL, elements[k], varVisitorId);
                                    else
                                          InfaKBCommonUtilityJs.Log('log', 'fnIntializeContentVisitedFeature ContentVisited Feature Will not work as VisitorId is not available');
				    //Change Realted to New Coveo Framework - v2.10104.0//T02
                              }
                        }
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnIntializeContentVisitedFeature : ' + err.message);
                  }
            }
            //-------------------------------------------------------------------------------<T05>
  
            //This fucntion will fill the data with visted date and time for all the reuslt items from local store
            function fnGetVisitedContentDetails(parContentURL, parCurrentElement, parCurrentCoveoVisitorID) {
                  try {
  
                        if ($(parCurrentElement).attr('data-isChildContent').trim().toString().toLowerCase() == 'true') {
                              return;
                        }
                        var mylocalstorage = window.localStorage;
                        if (mylocalstorage.getItem("KBSearchContentVisited") === null) {
  
                        } else {
                              var varContentVisitedArray = JSON.parse(mylocalstorage.getItem('KBSearchContentVisited'));
                              var varParseddata = fnContentVisitedGetVisitedDataByID(varContentVisitedArray, parContentURL)
                              if (varParseddata != null) {
                                    var d = new Date(varParseddata.TimeStamp);
                                    $(parCurrentElement).text("You last visited this page on " + fnContentVistedgetCustomMonth(d) + " " + fnContentVistedgetCustomDate(d) + ", " + d.getFullYear());
                                    $(parCurrentElement).css({
                                          display: 'block',
                                          color: '#BCC3CA'
                                    });
                              }
                        }
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnGetVisitedContentDetails : ' + err.message);
                  } finally {
  
                  }
            }
  
            //This function will only be called when the show more replies link is clicked 
            //this is very specific to jive content for now. It will get applied to others
            //if the folding feature is used in other template as well.
            function fnDisplayVisitedContentDetailsForShowMore(e,args) {
                  try {
  
                        if ((Coveo.$(args.item).attr('class') != undefined) && (Coveo.$(args.item).attr('class').indexOf('coveo-result-folding-child-result') > -1)) {
                              //InfaKBCommonUtilityJs.Log('log','fnDisplayVisitedContentDetailsForShowMore -Its show more event');
  
                              var elementsCoveoResultLink = Coveo.$(args.item).find('.CoveoResultLink');
                              Coveo.$(elementsCoveoResultLink).bind('click', fnContentVistedInsertOrUpdateData);
                        } else {
                              //InfaKBCommonUtilityJs.Log('log','fnDisplayVisitedContentDetailsForShowMore -Its not show more event');
                        }
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnDisplayVisitedContentDetailsForShowMore : ' + err.message);
                  } finally {
  
                  }
            }
  
  
            //This fucntion will be called, when the result link is clicked.
            //It will update the currently clicked link details and its time stamp to the 
            //local store. 
            function fnContentVistedInsertOrUpdateData() {
                  try {
                        InfaKBCommonUtilityJs.Log('log', 'fnContentVistedInsertOrUpdateData called');
                        var varcustomContentURL = "";
                        var mylocalstorage = window.localStorage;
                        var elements = $($(this)[0]).closest('.CoveoResult').find('.CustomContentVisited');
                        if (elements.length > 0) {
  
                              if ($(elements[0]).attr('data-customContentURL').length > 0) {
                                    varcustomContentURL = $(elements[0]).attr('data-customContentURL').trim().toString().toLowerCase();
                              }
  
  
                        }
  
                        var currentTimeStamp = new Date();
                        var currentTimeStampString = fnContentVistedgetMonth(currentTimeStamp) + '/' + fnContentVistedgetDate(currentTimeStamp) + '/' + currentTimeStamp.getFullYear() + ' ' + fnContentVistedgetHours(currentTimeStamp) + ':' + fnContentVistedgetMinutes(currentTimeStamp) + ':' + fnContentVistedgetSeconds(currentTimeStamp);
                        var varCurrentLocalUserID = fnGetContentVistorId(); //Change Realted to New Coveo Framework - v2.10104.0//T02

                        if (varCurrentLocalUserID == undefined) {
                              InfaKBCommonUtilityJs.Log('log', 'fnContentVistedInsertOrUpdateData ContentVisited Feature Will not work as VisitorId is not available');
                              return;
                        }
  
                        if (varcustomContentURL.length <= 0 || varcustomContentURL.length <= 0) {
                              return;
                        }
  
  
  
                        //check key is present or not in local storage.
                        if (mylocalstorage.getItem("KBSearchContentVisited") === null) {
  
                              var varContentVisitedArray = [{
                                    UserLocalID: varCurrentLocalUserID,
                                    ContentURL: varcustomContentURL,
                                    TimeStamp: currentTimeStampString
                              }];
                              mylocalstorage.setItem('KBSearchContentVisited', JSON.stringify(varContentVisitedArray));
                        } else {
  
                              var oldestTimeStamp = currentTimeStamp;
                              var oldestTiemStampIndex = 0;
                              var hasMatch = false;
                              var varContentVisitedArray = JSON.parse(mylocalstorage.getItem('KBSearchContentVisited'));
  
                              if (varContentVisitedArray.length > 100) {
  
                                    for (var index = 0; index < varContentVisitedArray.length; ++index) {
  
                                          var contentVistedDetails = varContentVisitedArray[index];
  
                                          if ((new Date(contentVistedDetails.TimeStamp)) < oldestTimeStamp) {
  
                                                oldestTimeStamp = contentVistedDetails.TimeStamp;
                                                oldestTiemStampIndex = index;
                                          }
                                    }
  
                                    varContentVisitedArray.splice(oldestTiemStampIndex, 1);
  
                              }
  
  
  
                              for (var index = 0; index < varContentVisitedArray.length; ++index) {
  
                                    var contentVistedDetails = varContentVisitedArray[index];
  
                                    if (contentVistedDetails.ContentURL == varcustomContentURL) {
                                          hasMatch = true;
                                          varContentVisitedArray[index].TimeStamp = currentTimeStampString;
                                          break;
                                    }
                              }
  
                              if (!hasMatch) {
                                    var varCurrentClickDetials = {
                                          UserLocalID: varCurrentLocalUserID,
                                          ContentURL: varcustomContentURL,
                                          TimeStamp: currentTimeStampString
                                    };
                                    varContentVisitedArray[varContentVisitedArray.length] = varCurrentClickDetials
                              }
  
                              window.localStorage.setItem('KBSearchContentVisited', JSON.stringify(varContentVisitedArray));
  
                        }
  
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedInsertOrUpdateData : ' + err.message);
                  }
            }
	    //Change Realted to New Coveo Framework - v2.10104.0//T02
            function fnGetContentVistorId() {
                  var varResultUserID = Coveo.QueryUtils.createGuid();
                  try {
                        var mylocalstorageforvisit = window.localStorage;
                        var varvisitorId = localStorage.getItem("visitorId");
                        var varKBSearchContentVisitorDummyId = localStorage.getItem("KBSearchContentVisitorDummyId");

                        if (varvisitorId == undefined || varvisitorId == null || varvisitorId == '') {
                              if (varKBSearchContentVisitorDummyId == undefined || varKBSearchContentVisitorDummyId == null || varKBSearchContentVisitorDummyId == '') {
                                    varResultUserID = Coveo.QueryUtils.createGuid();
                                    varKBSearchContentVisitorDummyId = varResultUserID;
                                    mylocalstorageforvisit.setItem('KBSearchContentVisitorDummyId', varResultUserID);
                              }
                              else {
                                    varResultUserID = varKBSearchContentVisitorDummyId;
                              }
                        }
                        else {
                              varResultUserID = varvisitorId;
                        }
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnGetContentVistorId : ' + err.message);
                  }
                  return varResultUserID;
            }
	    //Change Realted to New Coveo Framework - v2.10104.0//T02
  
            //fuction to convert the month string to two digit string
            function fnContentVistedgetMonth(pardate) {
                  try {
                        var month = pardate.getMonth() + 1;
                        return month < 10 ? '0' + month : '' + month;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetMonth : ' + err.message);
                  }
            }
  
            //fuction to convert the date string to two digit string
            function fnContentVistedgetDate(pardate) {
                  try {
                        var date = pardate.getDate();
                        return date < 10 ? '0' + date : '' + date;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetDate : ' + err.message);
                  }
            }
  
            //fuction to convert the hours string to two digit string
            function fnContentVistedgetHours(pardate) {
                  try {
                        var hours = pardate.getHours();
                        return hours < 10 ? '0' + hours : '' + hours;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetHours : ' + err.message);
                  }
            }
  
            //fuction to convert the minutes string to two digit string
            function fnContentVistedgetMinutes(pardate) {
                  try {
                        var minutes = pardate.getMinutes();
                        return minutes < 10 ? '0' + minutes : '' + minutes;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetMinutes : ' + err.message);
                  }
            }
  
            //fuction to convert the seconds string to two digit string
            function fnContentVistedgetSeconds(pardate) {
                  try {
                        var seconds = pardate.getSeconds();
                        return seconds < 10 ? '0' + seconds : '' + seconds;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetSeconds : ' + err.message);
                  }
            }
  
            //fuction to convert the month to custom format
            function fnContentVistedgetCustomMonth(pardate) {
                  try {
                        var months = ['January', 'February', 'March', 'April', 'May', 'June',
                              'July', 'August', 'September', 'October', 'November', 'December'
                        ];
  
                        return months[pardate.getMonth()];
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetCustomMonth : ' + err.message);
                  }
            }
  
            //fuction to convert the date to custom format
            function fnContentVistedgetCustomDate(pardate) {
                  try {
                        var onlydate = pardate.getDate();
  
                        return onlydate;
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVistedgetCustomDate : ' + err.message);
                  }
            }
  
            //fuction gets the content details from local store using its id and returns it to 
            //the caller.
            function fnContentVisitedGetVisitedDataByID(parContentVisitedArray, parURL) {
                  try {
                        var hasMatch = false;
  
                        for (var index = 0; index < parContentVisitedArray.length; ++index) {
  
                              var contentVistedDetails = parContentVisitedArray[index];
  
                              if (contentVistedDetails.ContentURL == parURL) {
                                    hasMatch = true;
                                    return contentVistedDetails;
                              }
                        }
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVisitedGetVisitedDataByID : ' + err.message);
                  } finally {
                        if (!hasMatch) {
                              return null;
                        }
                  }
            }

            function fnDecideToLoadContentVisitedData(execCount) {
                  try {
                        if ($("[class^='CoveoResultLink']").length != 0) {
                              fnIntializeContentVisitedFeature();
                        } else if (execCount < 300) {
                              execCount = execCount + 1;
                              window.setTimeout(function () { InfaKBContentVisitedFeatureJs.fnDecideToLoadContentVisitedData(execCount); }, 100);
                        }
                  } catch (exTwo) {
                        InfaKBCommonUtilityJs.Log('log', 'fnDecideToLoadContentVisitedData : ' + exTwo.message);
                  }
            }
            //-------------------------------------------------------------------------------<T02>
  
            var InfaKBContentVisitedFeatureJs = {
                      
                  'fnDisplayVisitedContentDetails': fnDisplayVisitedContentDetails,
                  'fnDecideToLoadContentVisitedData': fnDecideToLoadContentVisitedData,
                  'fnDisplayVisitedContentDetailsForShowMore':fnDisplayVisitedContentDetailsForShowMore
                  
            };
      
            w.InfaKBContentVisitedFeatureJs = InfaKBContentVisitedFeatureJs;
      } catch (error) {
            console.error('error', 'InfaKBContentVisitedFeatureJs onInit : ' + error.message);
      }

})(window);