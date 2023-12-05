/**************************************************************************
JS file Name: Omniture_Old.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 01-October-2016
Purpose: Holds all the function required across the application for the Omniture Old mysupport.informatica.com.
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

            var varEnvironmentType = 'NOTREQUIRED';
    
            //Search Related Function----------------Start-------------------------------------------------------/

            function fnLoadOmnitureOldScript() {
                  try {
                        InfaKBCommonUtilityJs.Log('log','Method : fnLoadOmnitureOldScript');
                        varIsThisKBExternal = InfaKBCommonUtilityJs.fnIsThisExternal();

                        if (varIsThisKBExternal) {
                              var isProd = false;
                                         
                              if (document.location.href.indexOf('knowledge.informatica.com') > -1) {
                                    isProd = true;
                                    varEnvironmentType = 'PRODUCTION';

                              } else if (document.location.href.indexOf('ttps://uat-infa') > -1) {
                                    varEnvironmentType = 'UAT';
                                   
                              } else if ((document.location.href.indexOf('ttps://sit-infa') > -1) || (document.location.href.indexOf('ttps://kbdev-infa') > -1) || (document.location.href.indexOf('ttps://satish-infa') > -1)) {
                                    varEnvironmentType = 'DEV';
                              }
                             
                        }                                                                                                                                                                     
                  }
                  catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : fnLoadOmnitureOldScript; Error :' + ex.message);
                  }
            }

            function fnCaptureSearchDataOnQuerySuccess(result) {
                  try {
                        if (varIsThisKBExternal) {
                              var s = s_gi(s_account1);
                              s.linkTrackVars = 'events,eVar9,eVar8,eVar33,eVar29,eVar50,eVar54';
                              s.linkTrackEvents = 'event9,event22,event5,event21,event40,event6';
                              s.pageName = '';
                              s.eVar8 = '';
                              s.eVar9 = '';
                              s.eVar33 = '';
                              s.eVar29 = '';
                              s.eVar50 = '';
                              s.prop7 = '';
                              s.prop8 = '';
                              s.eVar54 = '';
                              s.events = 'event9,event22,event5';
                              s.pageName = 'kb:searchresults';
                              s.eVar19 = window.location.href;
                              if (InfaKBSearchOldJs.IsUserAuthenticated == 'true') {
                                    s.eVar9 = 'Logged In';
                                    s.eVar8 = InfaKBSearchOldJs.varSearchUserId
                              }
                              else {
                                    s.eVar8 = 'Anonymous User';
                                    s.eVar9 = 'Guest';
    
                              }
    
                              var ProductSelected = 'NotSelected';
    
                              if (result.query.aq != undefined) {
                                    var varfilters = result.query.aq;
                                    if (varfilters.indexOf('@athenaproduct') != -1) {
                                          ProductSelected = fnGetFilterValue('@athenaproduct', varfilters);
                                          s.eVar29 = ProductSelected;
                                          s.eVar50 = ProductSelected;
                                          s.events += ',event40';
                                          //alert(s.events);
                                          //alert(s.eVar50);
                                          //alert(ProductSelected);            
                                    }
                              }
    
                              //InfaKBCommonUtilityJs.Log('**All Result ' + JSON.stringify(result));
                              searchTerm = result.query.q;
    
                              totalResults = result.results.totalCount;
    
                              // Search Keyword
                              if (result.query.q != undefined) {
                                    s.prop7 = result.query.q;
    
                              }
                              else {
                                    //alert('Search keyword Else Entered');
                                    s.prop7 = 'DefaultEmptySearch';
    
                              }
                              //Tab Selected
                              if (result.query.tab != undefined) {
                                    //s.eVar33 = result.query.tab;
                                    if (result.query.tab == 'All') {
                                          s.eVar33 = 'All Content';
    
                                    } else if (result.query.tab == 'KB') {
                                          s.eVar33 = 'Knowledge Base';
    
                                    } else if (result.query.tab == 'ProdDocs') {
                                          s.eVar33 = 'Product Documents';
    
                                    } else if (result.query.tab == 'HowTo') {
                                          s.eVar33 = 'How-To Library';
    
                                    } else if (result.query.tab == 'Blog') {
                                          s.eVar33 = 'Discussions & Blogs';
    
                                    } else if (result.query.tab == 'SupportTV') {
                                          s.eVar33 = 'Support Video';
    
                                    } else if (result.query.tab == 'Expert') {
                                          s.eVar33 = 'Expert Assistant';
    
                                    }
                              }
    
                              //Filters Selected
                              if (result.query.aq != undefined) {
                                    //alert(result.query.aq);  
                                    //var productFilterIndex = str.indexOf('f:@athenaproduct');            
                                    //var filterSplit = result.query.aq.split('==');
                                    //var filterSelected = filterSplit[1];
                                    //s.eVar29 = filterSelected;
                                    //s.eVar50 = filterSelected;
                                    //s.events += ',event40';
                              }
    
    
                              //Number of results displayed
                              if (result.results.totalCount != 0) {
                                    s.prop8 = result.results.totalCount;
                                    s.eVar54 = result.results.totalCount;
                              }
    
                              if (result.results.totalCount == 0) {
                                    s.prop7 = '';
                                    s.prop7 = result.query.q;
                                    s.prop8 = 'zero';
                                    s.eVar54 = 'zero';
                                    s.events += ',event6';
                              }
    
                              /****  for Dynamic Account Selection     ******/
                              s.dynamicAccountSelection = true
                              s.dynamicAccountList = 'informatica-mysupport-dev=DEV;informatica-mysupport-test=UAT;informatica-mysupport-prod=PRODUCTION';
                              s.dynamicAccountMatch = varEnvironmentType
    
                              var s_code = s.t(); if (s_code) document.write(s_code)
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error','Method : InfaKBSearchOldJsOmnitureOld fnCaptureSearchDataOnQuerySuccess; Error :' + ex.message);
                  }
            }

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
          
    
            //Search Related Function----------------End-------------------------------------------------------/
    
    
            var InfaKBSearchOldJsOmnitureOld = {
                  'fnLoadOmnitureOldScript': fnLoadOmnitureOldScript,
                  'fnCaptureSearchDataOnQuerySuccess':fnCaptureSearchDataOnQuerySuccess,
                  'varIsThisKBExternal': varIsThisKBExternal,
                  'varEnvironmentType':varEnvironmentType
            };

            w.InfaKBSearchOldJsOmnitureOld = InfaKBSearchOldJsOmnitureOld;
      } catch (error) {
            InfaKBCommonUtilityJs.Log('error','InfaKBSearchOldJsOmnitureOld onInit : ' + error.message);
      }

})(window);