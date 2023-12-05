/**************************************************************************
JS file Name: Woopra_Old.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 01-October-2016
Purpose: Holds all the function required across the application for the Woopra Old.
Version: 1.0


Modificaiton History

Date      |  Modified by    |  Jira reference      |ChangesMade     

1/6/2017    Sathish Rajalingam      JIRA: KB-2129        UAT base URL update

***************************************************************************/


/*Global variable used across the application
 
*/


(function (w) {

      try {
          
            var varIsThisKBExternal = false;
    
            //Search Related Function----------------Start-------------------------------------------------------/

            function fnLoadWoopraOldScript() {
                  try {
                        InfaKBCommonUtilityJs.Log('log','Method : fnLoadWoopraOldScript');
                        varIsThisKBExternal = InfaKBCommonUtilityJs.fnIsThisExternal();

                        if (varIsThisKBExternal) {
                                                          
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
                              } else if (document.location.href.indexOf('ttps://uat-infa') > -1) {
                                    woopra.config({
                                          domain: 'mysupport-test.informatica.com',
                                          cookie_domain: '.force.com',
                                          idle_timeout: 10000000,
                                          download_tracking: false,
                                          outgoing_tracking: false
                                    });
                              } else if ((document.location.href.indexOf('ttps://sit-infa') > -1) || (document.location.href.indexOf('ttps://kbdev-infa') > -1) || (document.location.href.indexOf('ttps://satish-infa') > -1)) {
                                    woopra.config({
                                          domain: 'kb-dev.informatica.com',
                                          cookie_domain: '.force.com',
                                          idle_timeout: 10000000,
                                          download_tracking: false,
                                          outgoing_tracking: false
                                    });
                              }
                              fnSetWoopraUserID(InfaKBSearchOldJs.varSearchUserFirstName,InfaKBSearchOldJs.IsUserAuthenticated);
                              fnLogSearchPageView();
                        }
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnLoadWoopraOldScript; Error :' + ex.message);
                  }
            }

            function fnLogSearchPageView() {
                  try {
                        if (isthisKBExternal) {
                              woopra.track('KB Search', {
                                    Page_Visited: 'KB:View Search Page',
                                    Pg_lnk_vstd: window.location.href,
                                    title: document.title
                              });                             
                        }
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnLogSearchPageView; Error :' + ex.message);
                  }
            }

            //Called to get the total number of results
            function fnGetTotalNumberofResults(parTotalCount) {
                  try {
                        if (parTotalCount == 0) {
                              return 'zero';
                        } else {
                              return parTotalCount;
                        }

                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnGetTotalNumberofResults; Error :' + ex.message);
                  }
                  return parTotalCount;
            }

            //called to get tab name 
            function fnGetTabName(parTab) {
                  var tabName = '';
                  try {
                        if (typeof parTab != 'undefined') {
                              switch (parTab) {
                                    case 'All':
                                          tabName = 'all content';
                                          break;
                                    case 'KB':
                                          tabName = 'knowledge base';
                                          break;
                                    case 'ProdDocs':
                                          tabName = 'product docs';
                                          break;
                                    case 'HowTo':
                                          tabName = 'how-to-library';
                                          break;
                                    case 'Blog':
                                          tabName = 'discussions and blogs';
                                          break;
                                    case 'SupportTV':
                                          tabName = 'support video';
                                          break;
                                    case 'Expert':
                                          tabName = 'expert assistant';
                                          break;
                                    case 'PAM':
                                          tabName = 'pam and eol';
                                          break;
                                    case 'Training':
                                          tabName = 'informatica university';
                                          break;
                                    default:
                                          tabName = parTab;
                                          break;
                              }
                        }

                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnGetTabName; Error :' + ex.message);
                  }
                  return tabName;
            }


            function fnCaptureSearchDataOnQuerySuccess(result) {
                  try {                        
                        var woopraTotalNumberOfResults = (fnGetTotalNumberofResults(result.results.totalCount)).toString();                        
                        var woopraTabName = fnGetTabName(result.query.tab);
                        var ProductSelected = 'NotSelected';
                        if (result.query.aq != undefined) {
                              var varfilters = result.query.aq;
                              if (varfilters.indexOf('@athenaproduct') != -1) {
                                  ProductSelected = fnGetFilterValue('@athenaproduct', varfilters);
                                 
                                  //alert(s.events);
                                  //alert(s.eVar50);
                                  //alert(ProductSelected);            
                              }
                        }
                        
                        woopra.track('KB Search', {
                              Srch_Kywrd: GetSearchKeyword(result.query.q),
                              Srch_Rslt_No: woopraTotalNumberOfResults,
                              Srch_Tab_Clk: woopraTabName,
                              Fltr_Prod: ProductSelected
                        });
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnCaptureSearchDataOnQuerySuccess; Error :' + ex.message);
                  }
            }

            function fnSetWoopraUserID(parFirtName, parIsKBUserAuthenticated) {
                  try {                        
                        InfaKBCommonUtilityJs.Log('log','Woopra Set Details');                        
                        if (parIsKBUserAuthenticated == 'true') {
                              woopra.identify({
                                    name: parFirtName,
                                    email: parFirtName
                              });

                        } else {
                              woopra.identify({
                                    name: '',
                                    email: ''
                              });
                        }
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : InfaKBSearchOldJsWoopraOld fnCaptureSearchDataOnQuerySuccess; Error :' + ex.message);
                  }
            }

                
             //-----------------Woopra Script  - Start ----------------//
          
                                                      
            function fnGetFilterValue(FilterValueToGet, SearchFilters) {
                  var varReturn = '';
                  try {
                        var filterArray = SearchFilters.split(') (');
                        for (i = 0; i < filterArray.length; i++) {
                              if (filterArray[i].indexOf(FilterValueToGet) != -1) {
                                    var filterpair = filterArray[i].split('==');
                                    varReturn = filterpair[1];
                              }
                        }
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : fnGetFilterValue :' + ex.message);
                  }                
                  return varReturn;
            }

            function GetSearchKeyword(searchterm) {
                  var varReturn = 'DefaultEmptySearch';
                  try {
                        if (searchterm != undefined) {
                              varReturn = searchterm;
                        }
                        else {
                      
                        }
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : GetSearchKeyword :' + ex.message);
                  }
                  return varReturn
            }

          //-----------------Woopra Script  - Ends ----------------//

                
            //Search Related Function----------------End-------------------------------------------------------/
    
    
            var InfaKBSearchOldJsWoopraOld = {
                  'fnLoadWoopraOldScript': fnLoadWoopraOldScript,
                  'fnLogSearchPageView': fnLogSearchPageView,
                  'fnCaptureSearchDataOnQuerySuccess': fnCaptureSearchDataOnQuerySuccess,
                  'fnSetWoopraUserID':fnSetWoopraUserID,
                  'varIsThisKBExternal':varIsThisKBExternal
            };

            w.InfaKBSearchOldJsWoopraOld = InfaKBSearchOldJsWoopraOld;
      } catch (error) {
            InfaKBCommonUtilityJs.Log('error','error', 'InfaKBSearchOldJsWoopraOld onInit : ' + error.message);
      }

})(window);