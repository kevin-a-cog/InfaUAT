
/*
   @created by       : SathishR
   @created on       : 20/02/2020
   @Purpose          : Holds all the function required  for Coveo JS Framework customization.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  13-Apr-2021      |   Sathish R               |     KB-145        |   Initial Version
 |     2      |  10-Nov-2023      |   Sathish R               |    I2RT-9499      |   Customer facing "Something went wrong" issue every few hours in search
 ****************************************************************************************************
 */

(function (w) {

      try {
            var varIsDebugLogEnabled = false;

            /********************************************/
            //Local Storage Value Manipulation - Start - Local Storage Value Manipulation//

            function fnLocaStorageInsertOrUpdate(parDataId, parLocalStorageId, parActualData) {
                  InfaKBCommonUtilityJs.Log('log', 'fnLocaStorageInsertOrUpdate called');
                  try {
                        var varcustomContentURL = document.location.href;
                        var currentTimeStamp = new Date();
                        var currentTimeStampString = fnLocalStorageGetMonth(currentTimeStamp) + '/' + fnLocalStorageGetDate(currentTimeStamp) + '/' + currentTimeStamp.getFullYear() + ' ' + fnLocalStorageGetHours(currentTimeStamp) + ':' + fnLocalStorageGetMinutes(currentTimeStamp) + ':' + fnLocalStorageGetSeconds(currentTimeStamp);
                        //check key is present or not in local storage.
                        var mylocalstorage = window.localStorage;
                        if (mylocalstorage.getItem(parLocalStorageId) === null) {
  
                              var varLocalStorageDataArray = [{
                                    UniqueId: parDataId,
                                    ContentURL: varcustomContentURL,
                                    TimeStamp: currentTimeStampString,
                                    Data: parActualData
                              }];
                              mylocalstorage.setItem(parLocalStorageId, JSON.stringify(varLocalStorageDataArray));
                        } else {
  
                              var oldestTimeStamp = currentTimeStamp;
                              var oldestTiemStampIndex = 0;
                              var hasMatch = false;
                              var varLocalStorageDataArray = JSON.parse(mylocalstorage.getItem(parLocalStorageId));
  
                              if (varLocalStorageDataArray.length > 10) {
  
                                    for (var index = 0; index < varLocalStorageDataArray.length; ++index) {
  
                                          var varLocalDataDetails = varLocalStorageDataArray[index];
  
                                          if ((new Date(varLocalDataDetails.TimeStamp)) < oldestTimeStamp) {
  
                                                oldestTimeStamp = varLocalDataDetails.TimeStamp;
                                                oldestTiemStampIndex = index;
                                          }
                                    }
  
                                    varLocalStorageDataArray.splice(oldestTiemStampIndex, 1);
  
                              }
  
  
  
                              for (var index = 0; index < varLocalStorageDataArray.length; ++index) {
  
                                    var varLocalDataDetails = varLocalStorageDataArray[index];
  
                                    if (varLocalDataDetails.UniqueId == parDataId) {
                                          hasMatch = true;
                                          varLocalStorageDataArray[index].ContentURL = varcustomContentURL;                                          
					  //varLocalStorageDataArray[index].TimeStamp = currentTimeStampString;
                                          varLocalStorageDataArray[index].Data = parActualData;
                                          break;
                                    }
                              }
  
                              if (!hasMatch) {
                                    var varCurrentLocalDataDetials = {
                                          UniqueId: parDataId,
                                          ContentURL: varcustomContentURL,
                                          TimeStamp: currentTimeStampString,
                                          Data: parActualData
                                    };
                                    varLocalStorageDataArray[varLocalStorageDataArray.length] = varCurrentLocalDataDetials
                              }
  
                              window.localStorage.setItem(parLocalStorageId, JSON.stringify(varLocalStorageDataArray));
  
                        }
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocaStorageInsertOrUpdate : ' + err.message);
                  }
            }
      
            //fuction to convert the month string to two digit string
            function fnLocalStorageGetMonth(pardate) {
                  try {
                        var month = pardate.getMonth() + 1;
                        return month < 10 ? '0' + month : '' + month;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetMonth : ' + err.message);
                  }
            }
  
            //fuction to convert the date string to two digit string
            function fnLocalStorageGetDate(pardate) {
                  try {
                        var date = pardate.getDate();
                        return date < 10 ? '0' + date : '' + date;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetDate : ' + err.message);
                  }
            }
  
            //fuction to convert the hours string to two digit string
            function fnLocalStorageGetHours(pardate) {
                  try {
                        var hours = pardate.getHours();
                        return hours < 10 ? '0' + hours : '' + hours;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetHours : ' + err.message);
                  }
            }
  
            //fuction to convert the minutes string to two digit string
            function fnLocalStorageGetMinutes(pardate) {
                  try {
                        var minutes = pardate.getMinutes();
                        return minutes < 10 ? '0' + minutes : '' + minutes;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetMinutes : ' + err.message);
                  }
            }
  
            //fuction to convert the seconds string to two digit string
            function fnLocalStorageGetSeconds(pardate) {
                  try {
                        var seconds = pardate.getSeconds();
                        return seconds < 10 ? '0' + seconds : '' + seconds;
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetSeconds : ' + err.message);
                  }
            }
  
            //fuction to convert the month to custom format
            function fnLocalStorageGetCustomMonth(pardate) {
                  try {
                        var months = ['January', 'February', 'March', 'April', 'May', 'June',
                              'July', 'August', 'September', 'October', 'November', 'December'
                        ];
  
                        return months[pardate.getMonth()];
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetCustomMonth : ' + err.message);
                  }
            }
  
            //fuction to convert the date to custom format
            function fnLocalStorageGetCustomDate(pardate) {
                  try {
                        var onlydate = pardate.getDate();
  
                        return onlydate;
  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLocalStorageGetCustomDate : ' + err.message);
                  }
            }
  
            //fuction gets the content details from local store using its id and returns it to 
            //the caller.
            function fnGetLocalStorageDataByID(parDataId, parLocalStorageId) {
                  var varReturnData = '';
                  try {
                        var hasMatch = false;
                        var mylocalstorage = window.localStorage;
                        if (mylocalstorage.getItem(parLocalStorageId) === null) {
                              console.log('nd , ntwbc - ' + parLocalStorageId + '-c-' + Date.now().toString()); //T02
                        }
                        else {
                              var varLocalStorageDataArray = JSON.parse(mylocalstorage.getItem(parLocalStorageId));
                              for (var index = 0; index < varLocalStorageDataArray.length; ++index) {
  
                                    var varLocalDataDetails = varLocalStorageDataArray[index];
				            //T02 - Start
                                    var varTokenValidity = 240;
                                    
                                    if(InfaKBSearchOldJs != undefined && InfaKBSearchOldJs.varSearchTokenValidity != undefined && parseInt(InfaKBSearchOldJs.varSearchTokenValidity) > 0)
                                    {
                                          varTokenValidity =  parseInt(InfaKBSearchOldJs.varSearchTokenValidity);
                                    }
                                    
                                    if (varLocalDataDetails.UniqueId == parDataId && ((new Date(varLocalDataDetails.TimeStamp)) > (new Date(new Date().setMinutes(new Date().getMinutes() - varTokenValidity))))) {
                                          hasMatch = true;
                                          return varLocalDataDetails.Data;
                                    }                                    
                              }
                              if(hasMatch == false)
                              {
                                    console.log('ntwbc-' + parLocalStorageId + '-c-' + Date.now().toString());
                              }
			      //T02 - End
                        }
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnContentVisitedGetVisitedDataByID : ' + err.message);
                  } finally {
                 
                  }
                  return varReturnData;
            }
      
            //Local Storage Value Manipulation - End - Local Storage Value Manipulation//
            /********************************************/


            //For Refreshing the UI Partially
            function fnRefresh() {
                  try {
                        window.dispatchEvent(new Event('resize'));
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnRefresh : ' + err.message);
                  } finally {
                 
                  }
            }
            
            //For Refreshing the UI Partially
            
            //For Loggging in Console
            function Log(parType, parMessage) {
                  try {
                        if (InfaKBCommonUtilityJs.varIsDebugLogEnabled == true || parType == 'error') {
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

            //Get QueryString 
            function fngetQueryStringsValue(param) {

                  //It will get all query string value from the URL
                  var myParam = undefined;
                  var decode = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); };
                  var varReturnQueryString = fnQuerystring(null);
              
                  if (varReturnQueryString == undefined) {
              
                  } else {
                      if (varReturnQueryString[param] == undefined) {
              
                      } else {
                          myParam = varReturnQueryString[param];
                          if (myParam.trim().length == 0)
                              myParam = undefined;
                          else
                              myParam = decode(myParam);
                      }
                  }
                  return myParam;
            }

            function fnQuerystring(qs) {
                  // optionally pass a querystring to parse
                  var varQueryString = new Array();
              
                  if (qs == null)
                        qs = location.search.substring(1, location.search.length);
              
                  if (qs.length == 0)
                        return;
              
                  // Turn <plus> back to <space>
                  qs = qs.replace(/\+/g, ' ');
              
                  var args = qs.split('&'); // parse out name/value pairs separated via &
              
                  // split out each name=value pair
                  for (var i = 0; i < args.length; i++) {
                        var pair = args[i].split('=');
                        var name = decodeURIComponent(pair[0]);
              
                        var value = (pair.length == 2)
                              ? decodeURIComponent(escape(pair[1]))
                              : name;
              
                        varQueryString[name] = value;
                  }
              
                  return varQueryString;
            }
            //Get QueryString

            function fnIsThisExternal() {
                  var varReturn = false;
                  try {                      
                        if (
                              (document.location.toString().toLowerCase().indexOf('/knowledge.informatica.com/') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('/kb-test.informatica.com/') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('/kb-uno.informatica.com/') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('kbexternal') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('ttps://kbdev-infa') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('ttps://sit-infa') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('ttps://uat-infa') > -1 ||
                                    document.location.toString().toLowerCase().indexOf('ttps://satish-infa')) && (document.location.toString().toLowerCase().indexOf('/s/global-search/') > -1)
                        ) {
                            
                              varReturn = true;
                        } else {
                              varReturn = false;
                        }
                  } catch (ex) {
                        console.log("Method : fnIsThisExternal; Error :" + ex.description);
                  }
                  return varReturn;
            }
      
  

            var InfaKBCommonUtilityJs = {
                      
                  'fnLocaStorageInsertOrUpdate': fnLocaStorageInsertOrUpdate,
                  'fnGetLocalStorageDataByID': fnGetLocalStorageDataByID,
                  'Log': Log,
                  'fnRefresh': fnRefresh,
                  'fngetQueryStringsValue': fngetQueryStringsValue,
                  'fnQuerystring': fnQuerystring,
                  'fnIsThisExternal':fnIsThisExternal,
                  'varIsDebugLogEnabled':varIsDebugLogEnabled
            };
      

            w.InfaKBCommonUtilityJs = InfaKBCommonUtilityJs;

      } catch (error) {
            console.error('error', 'InfaKBCommonUtilityJs onInit : ' + error.message);
      }
            
})(window);