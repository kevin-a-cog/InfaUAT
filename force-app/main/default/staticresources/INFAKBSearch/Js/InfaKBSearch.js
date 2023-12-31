
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
 |     2      |  25-Apr-2022      |   Ankit Saxena            |     I2RT-7586     |   Add Article Number for coveo reporting 
 |     3      |  30-Jul-2023      |   Sathish R               |     I2RT-8639     |   IN Search - Click on + Search in any of the filter and left click on the scroll bar to scroll down. It closes immediately, not allowing the user to select a value from the drop down ( EC UAT feedback) 
 |     4      |  22-Aug-2023      |   Sathish R               |     I2RT-8817     |   Remove the pre-defined Product filters (Open Cases) applied on Internal search load. 
 |     5      |  22-Aug-2023      |   Sathish R               |     I2RT-8818     |   New left-side filters on KB Internal Search.
 |     6      |  11-Sep-2023      |   Sathish R               |     I2RT-8963     |   KB Internal search and case details tab getting refreshed every time when user clicks back on either of the tab.
 ****************************************************************************************************
 */

(function (win) {
      try {

            function fnInfaKBSearchScriptLoad(parId) {

                  (function (w) {

                        try {
                       
                              // Below JS global variables are used in ajax calls
                              // and getting search token for Coveo Js framework
                              // and getting recent result from Coveo and getting
                              // product filter for the user
                              var varSearchInstanceId = 'InfaKBSearchJs' + parId;
                              var varSearchOrgName = '';

                              var varSearchFacetValueDefferred;

                              var varUserFilterValueOnSaveDefferred;

                              var varSearchFacetValueObject;

                              var varRecentContentValueObject;

                              var varQueryURLBuildFromString = '';

                              var varQueryURLBasedOnCondition = '';

                              var varIsAllRequiredContentAvailable = false;

                              var varIsCustomEventHandlerHookedToCoveoFramework = false;

                              var varIsCustomFilterEventHandlerHookedToCoveoFramework = false;

                              var varIsCoveoSearchTokenRetrived = false;

                              var varIsCoveoRecentContentRetrived = false;

                              var varIsCoveoUserFilterRetrived = false;

                              var varIsCoveoSearchTemplateRetrived = false;

                              var varIsSearchResultTemplateRetrived = false;

                              var varIsNoSearchResultTemplateRetrived = false;

                              var varSearchUserEmail = '';

                              var varSearchUserId = '';

                              var varSearchUserSessionId = '';
      
                              var varSearchToken = '';
      
                              var varSearchHub = '';

                              var varINFAKBContentSearchControllerComponent = undefined;

                              var varINFAKBContentSearchControllerEvent = undefined;

                              var varINFAKBContentSearchControllerHelper = undefined;

                              var varINFAKBContentSearchControllerAuraFramework = undefined;

                              var varCoveoSearchInterface = undefined;

                              var varSearchTokenDefferred;

                              var varRenewSearchTokenDefferred;

                              var varUserFilterValueOnLoadDefferred;

                              var varRecentContentValueDefferred;

                              var varathenaresourcepath;

                              var varhelptexthtmlresourcepath;

                              var searchInterfaceID = '#searchinfakbcs' + parId;

                              var searchinfakbcsdummywin = '#searchinfakbcsdummywin' + parId;

                              var searchinfakbcsdummytextarea = '#searchinfakbcsdummytextarea' + parId;

                              var varCustomCoveoAnimation = '#CustomCoveoAnimation' + parId;

                              var searchInterfaceWrapper = '#searchinfakbcswrapper' + parId;

                              var varsscontentsearchfilteronrefresh = '__contentsearch__filter__'; //Tag 6//
                        
                              var searchInterfaceElement = [document.querySelector(searchInterfaceID)];

                              var searchInterfaceCoveoResultList = document.querySelector('.CoveoResultList')

                              var SFDCKBInternalHost = ''

                              var SFDCKBExternalHost = ''

                              var SFDCEsupportHost = ''

                              var KBCommunityNameInURL = ''

                              var eSupportCommunityNameInURL = ''

                              var varSearchUserType = ''

                              var IsUserAuthenticated = 'false';

                              var endpointURI = 'https://platform.cloud.coveo.com/rest/search';
      
                              var varSearchTokenResponseJSON = '';

                              var varRandomNumber = '10000000000';

                              var varCalledFrom = '';

                              var varUserFilterString = '';

                              var ESUPPORTSEARCH = 'esupportsearch';

                              var CONTENTSEARCH = 'contentsearch';

                              var KBSEARCH = 'kbsearch';

                              var ATHENAKBSEARCHINTERNAL = 'AthenaKBSearchInternal'

                              var ATHENAPANELFORCASES = 'AthenaPanelForCases'

                              var ESUPPORTGLOBALSEARCH = 'eSupportGlobalSearch'
            
                              var varObjectDataFromURL = [];
            
           
                              /*Custom Filter in KB SEARCH Page - Start*/
                              /********************************************************************************/
                              //Coveo Facet Mapping.
                              //Based on the below specified values , the Coveo facet will apeear accordingly
                              //['Display Name','fieldname','tabid'] - This is format followed
                              var COVEO_FACET_MAPPING_FOR_EXTERNAL = [
                                    ['AllContent', '@athenatabname', 'All'],
                                    ['AllContent', '@athenaproduct', 'All'],
                                    ['AllContent', '@sysdate', 'All'],
                                    ['Knowledge Base', '@athenatabname', 'KB'],
                                    ['Knowledge Base', '@athenaproduct', 'KB'],
                                    ['Knowledge Base', '@athenaproductversion', 'KB'],
                                    ['Knowledge Base', '@infakeywords', 'KB'],
                                    ['Knowledge Base', '@athenatemplate', 'KB'],
                                    ['Knowledge Base', '@athenalanguage', 'KB'],
                                    ['Knowledge Base', '@athenaDate', 'KB'],
                                    ['Product Docs', '@athenatabname', 'ProdDocs'],
                                    ['Product Docs', '@athenaproduct', 'ProdDocs'],
                                    ['Product Docs', '@athenaproductversion', 'ProdDocs'],
                                    ['Product Docs', '@booktitle', 'ProdDocs'],
                                    ['Product Docs', '@productlanguage', 'ProdDocs'],
                                    ['Product Docs', '@athenaDate', 'ProdDocs'],
                                    ['How-to Library', '@athenatabname', 'HowTo'],
                                    ['How-to Library', '@athenaproduct', 'HowTo'],
                                    ['How-to Library', '@athenaproductversion', 'HowTo'],
                                    ['How-to Library', '@booktitle', 'HowTo'],
                                    ['How-to Library', '@athenaDate', 'HowTo'],
                                    ['Discussion & Blogs', '@athenatabname', 'Blog'],
                                    ['Discussion & Blogs', '@athenaproduct', 'Blog'],
                                    ['Discussion & Blogs', '@csitemtype', 'Blog'],
                                    ['Discussion & Blogs', '@jivestatus', 'Blog'],
                                    ['Discussion & Blogs', '@group', 'Blog'],
                                    ['Discussion & Blogs', '@jivecategories', 'Blog'],
                                    ['Discussion & Blogs', '@author', 'Blog'],
                                    ['Discussion & Blogs', '@athenaDate', 'Blog'],
                                    ['Informatica University', '@athenatabname', 'Trainings'],
                                    ['Informatica University', '@trainingroles', 'Trainings'],
                                    ['Informatica University', '@sysdate', 'Trainings'],
                                    ['Support Video', '@athenatabname', 'SupportVideo'],
                                    ['Support Video', '@athenaproduct', 'SupportVideo'],
                                    ['Support Video', '@jivecategories', 'SupportVideo'],
                                    ['Support Video', '@athenaDate', 'SupportVideo'],
                                    ['Learning Path', '@athenatabname', 'Expert'],
                                    ['Learning Path', '@athenaproduct', 'Expert'],
                                    ['Learning Path', '@infacontenttype', 'Expert'],
                                    ['Learning Path', '@athenaDate', 'Expert'],
                                    ['PAM & EoL', '@athenatabname', 'PAM'],
                                    ['PAM & EoL', '@athenaproduct', 'PAM'],
                                    ['PAM & EoL', '@athenaproductversion', 'PAM'],
                                    ['PAM & EoL', '@athenahotfix', 'PAM'],
                                    ['PAM & EoL', '@athenacategory', 'PAM'],
                                    ['PAM & EoL', '@athenaDate', 'PAM'],
                                    ['Cases & Comments', '@athenatabname', 'Cases'],
                                    ['Cases & Comments', '@athenaproduct', 'Cases'],
                                    ['Cases & Comments', '@sfownername', 'Cases'],
                                    ['Cases & Comments', '@sfcasestatus', 'Cases'],
                                    ['Cases & Comments', '@sfcreateddate', 'Cases'],
                                    ['Product Bugs', '@athenatabname', 'Bugs'],
                                    ['Product Bugs', '@filesharetabname', 'Bugs'],
                                    ['Product Bugs', '@athenaproduct', 'Bugs'],
                                    ['Product Bugs', '@filshareproduct', 'Bugs'],
                                    ['Product Bugs', '@bugstatus', 'Bugs'],
                                    ['Product Bugs', '@crtype', 'Bugs'],
                                    ['Product Bugs', '@athenaDate', 'Bugs'],
                                    ['Velocity', '@athenatabname', 'Velocity'],
                                    ['Velocity', '@athenaproduct', 'Velocity'],
                                    ['Velocity', '@athenacategory', 'Velocity'],
                                    ['Velocity', '@infatagname', 'Velocity'],
                                    ['Velocity', '@sysdate', 'Velocity'],
                                    ['Cases', '@athenatabname', 'Cases'],
                                    ['Cases', '@athenaproduct', 'Cases'],
                                    ['Cases', '@sfsupport_account__rname', 'Cases'],
                                    ['Cases', '@sfcaserecordtypename', 'Cases'],
                                    ['Cases', '@sfpriority', 'Cases'],
                                    ['Cases', '@sfownername', 'Cases'],
                                    ['Cases', '@sfcasestatus', 'Cases'],
                                    ['Cases', '@sfcreateddate', 'Cases'],
                                    ['Cases', '@sfcontactname', 'Cases'],
                                    ['Change Request', '@athenatabname', 'Change Request'],
                                    ['Change Request', '@athenaproduct', 'Change Request']
                              ];

                              var COVEO_FACET_MAPPING_FOR_ESUPPORT_SEARCH = [
                                    ['AllContent', '@athenatabname', 'All'],
                                    ['AllContent', '@athenaproduct', 'All'],
                                    ['AllContent', '@sysdate', 'All'],
                                    ['Cases', '@athenatabname', 'Cases'],
                                    ['Cases', '@athenaproduct', 'Cases'],
                                    ['Cases', '@sfsupport_account__rname', 'Cases'],
                                    ['Cases', '@sfcaserecordtypename', 'Cases'],
                                    ['Cases', '@sfpriority', 'Cases'],
                                    ['Cases', '@sfownername', 'Cases'],
                                    ['Cases', '@sfcasestatus', 'Cases'],
                                    ['Cases', '@sfcreateddate', 'Cases'],
                                    ['Cases', '@sfcontactname', 'Cases']
                              ];

                              var COVEO_FACET_MAPPING_FOR_INTERNAL = [
                                    ['AllContent', '@athenatabname', 'All'],
                                    ['AllContent', '@athenaproduct', 'All'],
                                    ['AllContent', '@sysdate', 'All'],
                                    ['Knowledge Base', '@athenatabname', 'KB'],
                                    ['Knowledge Base', '@athenaproduct', 'KB'],
                                    ['Knowledge Base', '@athenaproductversion', 'KB'],
                                    ['Knowledge Base', '@infaproductcomponent', 'KB'],//Tag 5//
                                    ['Knowledge Base', '@athenatemplate', 'KB'],
                                    ['Knowledge Base', '@infapermissiontype', 'KB'],
                                    ['Knowledge Base', '@infavalidationstatus', 'KB'], //Tag 5//
                                    ['Knowledge Base', '@athenaauthor', 'KB'],
                                    ['Knowledge Base', '@infaproblemtypes', 'KB'], //Tag 5//
                                    ['Knowledge Base', '@athenaDate', 'KB'],
                                    ['Product Docs', '@athenatabname', 'ProdDocs'],
                                    ['Product Docs', '@athenaproduct', 'ProdDocs'],
                                    ['Product Docs', '@athenaproductversion', 'ProdDocs'],
                                    ['Product Docs', '@productfamily', 'ProdDocs'],
                                    ['Product Docs', '@booktitle', 'ProdDocs'],
                                    ['Product Docs', '@productlanguage', 'ProdDocs'],
                                    ['Product Docs', '@athenaauthor', 'ProdDocs'],
                                    ['Product Docs', '@athenaDate', 'ProdDocs'],
                                    ['How-to Library', '@athenatabname', 'HowTo'],
                                    ['How-to Library', '@athenaproduct', 'HowTo'],
                                    ['How-to Library', '@athenaproductversion', 'HowTo'],
                                    ['How-to Library', '@booktitle', 'HowTo'],
                                    ['How-to Library', '@athenaDate', 'HowTo'],
                                    ['Discussion & Blogs', '@athenatabname', 'Blog'],
                                    ['Discussion & Blogs', '@athenaproduct', 'Blog'],
                                    ['Discussion & Blogs', '@athenaDate', 'Blog'],
                                    ['Support Video', '@athenatabname', 'SupportVideo'],
                                    ['Support Video', '@athenaproduct', 'SupportVideo'],
                                    ['Support Video', '@jivecategories', 'SupportVideo'],
                                    ['Support Video', '@athenaDate', 'SupportVideo'],
                                    ['Learning Path', '@athenaproduct', 'Expert'],
                                    ['Learning Path', '@athenatabname', 'Expert'],
                                    ['Learning Path', '@athenaDate', 'Expert'],
                                    ['PAM & EoL', '@athenatabname', 'PAM'],
                                    ['PAM & EoL', '@athenaproduct', 'PAM'],
                                    ['PAM & EoL', '@athenaproductversion', 'PAM'],
                                    ['PAM & EoL', '@athenahotfix', 'PAM'],
                                    ['PAM & EoL', '@athenacategory', 'PAM'],
                                    ['PAM & EoL', '@athenaDate', 'PAM'],
                                    ['Cases & Comments', '@athenatabname', 'Cases'],
                                    ['Cases & Comments', '@athenaproduct', 'Cases'],
                                    ['Cases & Comments', '@sfownername', 'Cases'],
                                    ['Cases & Comments', '@sfcasestatus', 'Cases'],
                                    ['Cases & Comments', '@sfcreateddate', 'Cases'],
                                    ['Product Bugs', '@athenatabname', 'Bugs'],
                                    ['Product Bugs', '@filesharetabname', 'Bugs'],
                                    ['Product Bugs', '@athenaproduct', 'Bugs'],
                                    ['Product Bugs', '@filshareproduct', 'Bugs'],
                                    ['Product Bugs', '@bugstatus', 'Bugs'],
                                    ['Product Bugs', '@crtype', 'Bugs'],
                                    ['Product Bugs', '@athenaDate', 'Bugs'],
                                    ['Velocity', '@athenatabname', 'Velocity'],
                                    ['Velocity', '@athenaproduct', 'Velocity'],
                                    ['Velocity', '@athenacategory', 'Velocity'],
                                    ['Velocity', '@infatagname', 'Velocity'],
                                    ['Velocity', '@sysdate', 'Velocity'],
                                    ['Cases', '@athenatabname', 'Cases'],
                                    ['Cases', '@athenaproduct', 'Cases'],
                                    ['Cases', '@sfsupport_account__rname', 'Cases'],
                                    ['Cases', '@sfcaserecordtypename', 'Cases'],
                                    ['Cases', '@sfpriority', 'Cases'],
                                    ['Cases', '@sfownername', 'Cases'],
                                    ['Cases', '@sfcasestatus', 'Cases'],
                                    ['Cases', '@sfcreateddate', 'Cases'],
                                    ['Cases', '@component', 'Cases'],
                                    ['Cases', '@sfresolution_code__c', 'Cases'],
                                    ['Get Help', '@athenatabname', 'Get Help'],
                                    ['Get Help', '@athenaproduct', 'Get Help'],
                                    ['Get Help', '@infafeeditemcreatedbyname', 'Get Help'],
                                    ['Get Help', '@sysdate', 'Get Help']
                              ];
         
                              /**
                                * This function used to attached the event handler for the custom filter window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.
                                */
                              function fnHookCustomFilterMethodToEvent() {
                                    try {
                       

                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnHookCustomFilterMethodToEvent; Error :' + ex.message);
                                    }
                              }

                              function fnFunctionForArray() {
                                    try {
                                          // Array.prototype.contains = function (v) {
                                          //       for (var i = 0; i < this.length; i++) {
                                          //             if (this[i] === v) return true;
                                          //       }
                                          //       return false;
                                          // };

                                          // Array.prototype.unique = function () {
                                          //       var arr = [];
                                          //       for (var i = 0; i < this.length; i++) {
                                          //             if (!arr.contains(this[i])) {
                                          //                   arr.push(this[i]);
                                          //             }
                                          //       }
                                          //       return arr;
                                          // };
                                          try {
                                                jQuery.support.cors = true;
                                          } catch (error) {
                                                InfaKBCommonUtilityJs.Log('error', 'Method : fnFunctionForArray; Error :' + error.message);
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnFunctionForArray; Error :' + ex.message);
                                    }
                              }
                              fnFunctionForArray();
            
                              function fnArrayContains(parArray, parValue) {
                                    var varResult = false;
                                    try {
                                          for (var i = 0; i < parArray.length; i++) {
                                                if (parArray[i] === parValue) {
                                                      varResult = true;
                                                      break;
                                                }
                                          }
                        
                       
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnArrayContains; Error :' + ex.message);
                                    }
                                    return varResult;
                              }

                              function fnArrayUnique(parArray) {
                                    var varResult = parArray;
                                    try {
                                          var arr = [];
                                          for (var i = 0; i < parArray.length; i++) {
                                                if (!fnArrayContains(arr, parArray[i])) {
                                                      arr.push(parArray[i]);
                                                }
                                          }
                                          varResult = arr;
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnArrayUnique; Error :' + ex.message);
                                    }
                                    return varResult;
                              }

                              function fnInitialiseVariables() {
                                    try {
                                          varRandomNumber = (Math.floor(Math.random() * 10000) + 1).toString();
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnInitialiseVariables; Error :' + ex.message);
                                    }
                              }
                              fnInitialiseVariables();


                              /**
                               * Function used to decide the facet appearance, based on the content type selected. 
                               * Even the collection of facet is also decided on the searchhib name.
                               * This will make sure only the required faced is available in the UI
                               * @param {Contains the value of the selected content type} parCurrentSelectedContentType
                               */
      
                              function fnToggleCoveoFacet(parCurrentSelectedContentType) {
                                    try {

                                          var varAllContentTypeName = ['AllContent'];

                                          var varFacetForParticularTab = window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ATHENAKBSEARCHINTERNAL || window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ATHENAPANELFORCASES ? COVEO_FACET_MAPPING_FOR_INTERNAL.filter(function (x) {
                                                if (x != undefined && x[0] != undefined) {
                                                      return fnArrayContains(parCurrentSelectedContentType, x[0]);
                                                } else {
                                                      return false;
                                                }

                                          }) : (window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ESUPPORTGLOBALSEARCH ? COVEO_FACET_MAPPING_FOR_ESUPPORT_SEARCH.filter(function (x) {
                                                if (x != undefined && x[0] != undefined) {
                                                      return fnArrayContains(parCurrentSelectedContentType, x[0]);
                                                } else {
                                                      return false;
                                                }

                                          }) : COVEO_FACET_MAPPING_FOR_EXTERNAL.filter(function (x) {
                                                if (x != undefined && x[0] != undefined) {
                                                      return fnArrayContains(parCurrentSelectedContentType, x[0]);
                                                } else {
                                                      return false;
                                                }

                                          }));

                                          if (Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\']').length != 0) {
                                                var varAllFacet = Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\']');
                                                if (varFacetForParticularTab.length != 0) {
                                                      for (var k = 0; k < varAllFacet.length; k++) {
                                                            if (varAllFacet[k].getAttribute('data-field') != undefined) {
                                                                  var varActualFacet = varFacetForParticularTab.filter(function (x) { return x[1] == varAllFacet[k].getAttribute('data-field'); });
                                                                  //this line will check with data-tab attribute to check and add to show
                                                                  //if (varActualFacet.length != 0 && ($(varAllFacet[k])[0].getAttribute('data-tab').indexOf(varActualFacet[0][2]) != -1)) {
                                                                  if (varActualFacet.length != 0) {
                                                                        if (Coveo.$(varAllFacet[k]).attr('class').indexOf('coveo-tab-disabled') > -1) {
                                                                              Coveo.$(varAllFacet[k]).removeClass('coveo-tab-disabled');
                                                                        }

                                                                  } else {
                                                                        if (Coveo.$(varAllFacet[k]).attr('class').indexOf('coveo-tab-disabled') == -1) {
                                                                              Coveo.$(varAllFacet[k]).addClass('coveo-tab-disabled');
                                                                        }
                                                                  }
                                                            }
                                                      }

                                                } else {
                                                      fnToggleCoveoFacet(varAllContentTypeName);
                                                }
                                          }


                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnTriggerControlsMethod; Error :' + e.message + ' : ' + e.stack);
                                    }

                              }

                              function fnReBuildFacetBasedOnContentTypeFacetHandler(arg) {
                                    try {
                                          fnReBuildFacetBasedOnContentTypeFacet(this);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnReBuildFacetBasedOnContentTypeFacetHandler; Error :' + ex.message);
                                    }
                              }

                              /**
                               * Fucntion to attach eventhandler to Coveo Facet content, every time 
                               * when the content gets refereshed
                               */
                              function fnHookCustomFilterEventHandler() {
                                    try {
                                          //Assign event to capture the filter selection
                                          if (Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').length != 0) {
                                                Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').unbind('change', fnReBuildFacetBasedOnContentTypeFacetHandler);
                                                Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').bind('change', fnReBuildFacetBasedOnContentTypeFacetHandler);
                                          }

                                          // if (Coveo.$(searchInterfaceID).find('[class^='fa fa-chain'][data-html='true']').length != 0) {

                                          //       Coveo.$(searchInterfaceID).find('[class^='fa fa-chain'][data-html='true']').popover({
                                          //             placement: 'auto',
                                          //             trigger: 'click hover',
                                          //             delay: { show: 50, hide: 400 }
                                          //       });
                                          //       Coveo.$(searchInterfaceID).find('[class^='fa fa-chain'][data-html='true']').popover('disable');
                                          //       Coveo.$(searchInterfaceID).find('[class^='fa fa-chain'][data-html='true']').attr('title', $('[class^='fa fa-chain'][data-html='true']').attr('data-custom-tooltiptext'));
                                          // }


                                          InfaKBCommonUtilityJs.Log('log', 'called fnHookCustomFilterEventHandler');
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnHookCustomFilterEventHandler; Error :' + ex.message);
                                    }
                              }

                              /**
                              * Fuction will build all the facet based on the selected content type
                              * @param {Actual selected content type className} parCurrentItem 
                              * athenatabname is the value compared with the array and provided
                              */

                              function fnReBuildFacetBasedOnContentTypeFacet(parCurrentItem) {
                                    try {

                                          var varAllContentContentType = ['AllContent'];
                                          var varCurrentSelectedContentType = [];

                                          if (Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').length != 0) {

                                                if (Coveo.$(parCurrentItem).find('[class^=\'coveo-facet-value coveo-facet-selectable coveo-with-hover coveo-selected\']').length != 0) {
                                                      var varSelectedItems = Coveo.$(parCurrentItem).find('[class^=\'coveo-facet-value coveo-facet-selectable coveo-with-hover coveo-selected\']');

                                                      for (var j = 0; j < varSelectedItems.length; j++) {
                                                            varCurrentSelectedContentType.push(varSelectedItems[j].getAttribute('data-value'));
                                                      }

                                                      if (varCurrentSelectedContentType.length != 0) {
                                                            fnToggleCoveoFacet(varCurrentSelectedContentType);
                                                      } else {
                                                            fnToggleCoveoFacet(varAllContentContentType);
                                                      }

                                                } else {
                                                      fnToggleCoveoFacet(varAllContentContentType);
                                                }

                                          }
                                          InfaKBCommonUtilityJs.Log('log', 'called fnReBuildFacetBasedOnContentTypeFacet');
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnReBuildFacetBasedOnContentTypeFacet; Error :' + ex.message);
                                    }
                              }
                              /*Custom Filter in KB SEARCH Page - End*/
                              /********************************************************************************/


                              /*Copy URL in KB SEARCH Page - Start*/
                              /********************************************************************************/

                              /**
                               * Fucntion use to copy the public url of the current selected item
                               * @param {current selected item} parCurrentItem 
                               */

                              function fnClickCopyURLToClipboard(parCurrentItem) {
                                    try {
                       
                                          var varimgCopyUrl = $(parCurrentItem);
                                          var varCurrentItemURL = $(varimgCopyUrl).attr('data-custom-publicurl');

                                          //var test = InfaKBCommonUtilityJs.fnGetElementPosition(parCurrentItem);

                                          //test.top = (test.top - 310);
                                          //test.left = (test.left - 400);
                                          // test.bottom = (test.botom - 350);
                                          // test.right = (test.right - 350);

                                          // var varPopOver = parCurrentItem.parentElement.children[1];                        
                                          // varPopOver.style.top = test.top + 'px';
                                          // varPopOver.style.left = test.left + 'px';
                                          // //varPopOver.style.bottom = test.bottom + 'px';
                                          // //varPopOver.style.right = test.right + 'px';
                                          // varPopOver.style.display = 'block';


                                          // // $(varimgCopyUrl).attr('disabled', 'disabled');

                                          // // $(varimgCopyUrl).attr('title', '');
                                          // // $(varimgCopyUrl).attr('data-popover', 'true');

                                          var textArea = document.querySelector(searchinfakbcsdummytextarea);
                        
                      
                                          textArea.value = varCurrentItemURL;
                                          textArea.select();
                                          try {
                           
                                                var successful = document.execCommand('copy');
                                                var msg = successful ? 'successful' : 'unsuccessful';
                                                InfaKBCommonUtilityJs.Log('log', 'Copying text command was ' + msg);
                                                $(varimgCopyUrl).attr('title', 'URL Copied');
                             
                                                setTimeout(function () { $(varimgCopyUrl).attr('title', 'Copy public link'); /*varPopOver.style.display = 'none';*/ }, 2000);

                                          } catch (err) {
                                                InfaKBCommonUtilityJs.Log('error', 'Oops, unable to copy');
                                          }
                        

                                          //TAG 01
                                          fnCopyURLClicked(parCurrentItem);
                                          //TAG 01
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method fnClickCopyURLToClipboard Error : ' + e.message);
                                    }
                              }

                              function fnInitializeCopyEvent() {
                                    var clipboard =
                                    {
                                          data: 'test',
                                          intercept: false,
                                          hook: function (evt) {
                                                if (clipboard.intercept) {
                                                      evt.clipboardData.setData('text/plain', clipboard.data);
                                                      evt.preventDefault();

                                                      clipboard.intercept = false;
                                                      clipboard.data = '';
                                                }
                                          }
                                    };
                                    window.addEventListener('copy', clipboard.hook);
                              }

                              /**
                               * Futction restores the tool tips after poping the URL copy content. 
                               * @param {Actual URL of the content} parvarimgCopyUrl 
                               */

                              function fnRestoreCopyURLToolTip(parvarimgCopyUrl) {
                                    try {

                                          if (Coveo.$(parvarimgCopyUrl).next().attr('class') == 'popover fade top in') {
                                                Coveo.$(parvarimgCopyUrl).next().remove();

                                                InfaKBCommonUtilityJs.Log('log', 'removed the popup element');
                                          }

                                          Coveo.$(parvarimgCopyUrl).popover('disable');

                                          if (Coveo.$(parvarimgCopyUrl).attr('title') == '') {
                                                Coveo.$(parvarimgCopyUrl).attr('title', Coveo.$(parvarimgCopyUrl).attr('data-custom-tooltiptext'));
                                                InfaKBCommonUtilityJs.Log('log', 'restored the tooltip');
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method fnRestoreCopyURLToolTip Error : ' + e.message);
                                    }
                              }
                              /*Copy URL in KB SEARCH Page - End*/
                              /********************************************************************************/


                              /*Search Framework in KB SEARCH Page - Start*/
                              /********************************************************************************/


                              /**
                               * Function, whihc is the trigerring point for all the Coveo related action processes.
                               */
                              function fnDecideAndGetSearchToken() {
                                    try {
                                          //fnGetFacetValuesCoveoSearch('athenaproduct');

               
                                          InfaKBCommonUtilityJs.Log('log', 'fnDecideAndGetSearchToken');
                                          Coveo.$(document).ready(function () {

                                                //fnSetCoveoContext();
                                                            
                                                //fnToggleInProgressAnimation();

                                                //this is used to load content in the preference pop up
                                                //fnBuildCustomFacet();
                             
                                                //Load SearchToken, SearchHub and other data are loaded from local storage 
                                                //using the session id
                                                fnLoadSearchCoreDetails();
                                              
                                                InfaKBCommonUtilityJs.Log('log', 'fnDecideAndGetSearchToken Coveo Ready Function');
                                                                                             
                                                if ((window[varSearchInstanceId].varSearchUserSessionId != '') || (window[varSearchInstanceId].varSearchUserSessionId.trim() != '')) {
                                                      fnHookCustomEventHandlerToCoveoSearchFramwwork();
                                                      fnCheckAndRetriveSearchToken();
                                                }

                                                fnDecideToLoadContentForSearch(0);

                                          });


                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnDecideAndGetSearchToken : Error Occured in Method fnDecideAndGetSearchToken Error : ' + ex.message);
                                    }
                              }

                              function fnCheckAndRetriveSearchToken() {
                                    try {
                                          //Call is made based on token present or not
                                          if (window[varSearchInstanceId].varSearchToken != undefined && window[varSearchInstanceId].varSearchToken.trim() != '' && window[varSearchInstanceId].varSearchToken.length > 5) {

                                                InfaKBCommonUtilityJs.Log('log', 'Search Token Already Present');
                                                fnConfigureAllSearchRelatedItems();

                                          } else {
                                                fnGetSearchToken()
                                                      .then(function (data) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetSearchToken then');
                                                            fnConfigureAllSearchRelatedItems();
                                                      })
                                                      .fail(function (err) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetSearchToken fail');
                                                            InfaKBCommonUtilityJs.Log('log', err);
                                                      });
                                          }

                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnCheckAndRetriveSearchToken : Error Occured in Method fnCheckAndRetriveSearchToken Error : ' + ex.message);
                                    }
                              }

                              function fnConfigureAllSearchRelatedItems() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnConfigureAllSearchRelatedItems');
                        
                                          // var token = window[varSearchInstanceId].varSearchToken;
                                          // var endpointURI = 'https://platform.cloud.coveo.com/rest/search/';
                                          // var root = document.querySelector(searchInterfaceID);
                                          // var orginternalName = varSearchOrgName;

                                          // fnBlockSearchWithoutKeyword();
            
                                          //fnConfigureOldSearchEndPoint();
               
                                          //This function is no longer needed as the 
                                          //recent content is loaded from aura component
                                          fnBuildRecentContentValue();

                                          //Filter on load, by building the url for the facet based on the cases open for the current user
                                          //fnProcessFilterOnLoad(); //Tag 4//
                        
                                          fnLoadSearchTemplate();

                                          fnSetSearchHubForSearch();

                                          //fnConfigureSearchEndPoint();
                                          fnConfigureOldSearchEndPoint();

                                          varIsCoveoSearchTokenRetrived = true;
                                          varIsCustomEventHandlerHookedToCoveoFramework = true;
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnConfigureAllSearchRelatedItems : Error Occured in Method fnConfigureAllSearchRelatedItems Error : ' + ex.message);
                                    }
                              }

                              /**
                               * Fucntion used to check on the availability of the element on DOM
                               * @param {second to wait for the next call} milliseconds 
                               */

                              function sleep(milliseconds) {
                                    var timeStart = new Date().getTime();
                                    while (true) {
                                          var elapsedTime = new Date().getTime() - timeStart;
                                          if (elapsedTime > milliseconds) {
                                                break;
                                          }
                                    }
                              }

                              /**
                               * Function to create Coveo search token on load of the page when the token is not available.
                               */
                              function fnHookCustomEventHandlerToCoveoSearchFramwworkWhenNoToken() {
                                    try {
                 
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnHookCustomEventHandlerToCoveoSearchFramwworkWhenNoToken Message : ' + ex.message);
                                    }
                              }

                              function fnConfigureSearchEndPoint() {
                                    try {
                             
                             
                                          varSearchOrgName = fnGetSearchOrg();

            
                                          Coveo.SearchEndpoint.configureCloudV2Endpoint(
                                                varSearchOrgName,
                                                window[varSearchInstanceId].varSearchToken,
                                                endpointURI,
                                                { renewAccessToken: fnReNewSearchToken }
                                          );
                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnConfigureSearchEndPoint Message : ' + error.message);
                                    }
                              }

                              function fnConfigureOldSearchEndPoint() {
                                    try {
                                          var token = window[varSearchInstanceId].varSearchToken;
                                          var endpointURI = "https://platform.cloud.coveo.com/rest/search";
      
                                          if (Coveo.SearchEndpoint.endpoints["default"]) {
                                                Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
                                                Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = fnReNewSearchToken;
                                          } else {
                                                Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                                                      restUri: endpointURI,
                                                      accessToken: token,
                                                      renewAccessToken: fnReNewSearchToken
                                                });
                                          }
                  
                                    } catch (error) {
                                          console.log('SearchPage : Error Occured in Method fnConfigureOldSearchEndPoint Message : ' + error.message);
                                    }
                              }
   
                              /**
                               * This function called once the search token is retrived from server
                               *
                               * @param {string} parResultJsonString Containd information of search token and others
                               */
                              function fnSetSearchCoreDetails(parResultJsonString) {
                                    try {
                                          fnGetSearchRelatedDataFromJson(parResultJsonString);
                                    } catch (err) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnSetSearchCoreDetails : ' + err.message);
                                    } finally {
                 
                                    }
                              }

                              /**
                               * This function load the search token on load of the page from cache.
                               *
                               */
                              function fnLoadSearchCoreDetails() {
                                    try {
                                          varSearchTokenResponseJSON = '';
                                          if (window[varSearchInstanceId].varSearchUserSessionId != undefined) {
                                                varSearchTokenResponseJSON = InfaKBCommonUtilityJs.fnGetLocalStorageDataByID(window[varSearchInstanceId].varSearchUserSessionId, 'KBContentSearchToken');
                                          }
                                    
                                          if (varSearchTokenResponseJSON != undefined) {
                                                fnGetSearchRelatedDataFromJson(varSearchTokenResponseJSON);
                                          }
                                                                     
                                    } catch (err) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnLoadSearchCoreDetails : ' + err.message);
                                    } finally {
                 
                                    }
                              }
      
                              function fnGetSearchOrg() {
                                    varSearchOrgName = 'informaticasandbox';
                                    try {
                                          if (window[varSearchInstanceId].SFDCKBExternalHost.toString().toLowerCase() == 'knowledge.informatica.com') {
                                                varSearchOrgName = 'informaticaprod';
                                          }
                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetCoveoOrg Message : ' + error.message);
                                    }
                                    return varSearchOrgName;
                              }

                              function fnBlockSearchWithoutKeyword() {
                                    try {
                                          Coveo.$(searchInterfaceID)[0].setAttribute('data-allow-queries-without-keywords', 'false');
          
                                          Coveo.$(searchInterfaceID)[0].setAttribute('data-auto-trigger-query', 'true')

                                          Coveo.$(searchInterfaceID)[0].setAttribute('data-hide-until-first-query', 'true')
                                    }
                                    catch (ex) {
                                          InfaKBCommonUtilityJs.Log('log', 'SearchPage : Error Occured in Method fnBlockSearchWithoutKeyword Message : ' + ex.message);
                                    }
                              }

                              function fnRemoveUnnecessaryTags() {
                                    try {
                                          if (Coveo.$(searchInterfaceID).find('.CoveoSearchAlerts')[0] != undefined)
                                                Coveo.$(searchInterfaceID).find('.CoveoSearchAlerts')[0].remove();
                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRemoveUnnecessaryTags Message : ' + error.message);
                                    }
                              }

                              function fnSetSearchHubForSearch() {
                                    try {
                                          if (Coveo.$(searchInterfaceID).find('.CoveoAnalytics')[0] != undefined)
                                                Coveo.$(searchInterfaceID).find('.CoveoAnalytics')[0].setAttribute('data-search-hub', window[varSearchInstanceId].varSearchHub);
                                          //Tag 6// Start 
                                          //'data-enable-history' = 'true' capture facet in url
                                          //'data-use-local-storage-for-history' = 'false' capture facet in url 
                                          //'data-enable-history', 'false' capture facet in localstorage
                                          //'data-use-local-storage-for-history' = 'true' capture facet in localstorage 
                                          if (((window[varSearchInstanceId].varCalledFrom == KBSEARCH) || (window[varSearchInstanceId].varCalledFrom == ESUPPORTSEARCH)) && Coveo.$(searchInterfaceID)[0] != undefined) { //URL will Change
                                                Coveo.$(searchInterfaceID)[0].setAttribute('data-enable-history', 'true');
                                                Coveo.$(searchInterfaceID)[0].setAttribute('data-use-local-storage-for-history', 'false');
                                          }
                                          else if ((window[varSearchInstanceId].varCalledFrom == CONTENTSEARCH) && Coveo.$(searchInterfaceID)[0] != undefined) {//URL will not Change
                                                Coveo.$(searchInterfaceID)[0].setAttribute('data-enable-history', 'false');
                                                Coveo.$(searchInterfaceID)[0].setAttribute('data-use-local-storage-for-history', 'true');
                                          }  
                                          //Tag 6// End                                         
                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetSearchHubForSearch Message : ' + error.message);
                                    }
                              }

                              function fnSetObjectDataFromURL() {
                                    try {
                                          if (((window[varSearchInstanceId].varCalledFrom == CONTENTSEARCH)) && Coveo.$(searchInterfaceID)[0] != undefined) {
                                                window[varSearchInstanceId].varObjectDataFromURL = InfaKBCommonUtilityJs.fnQuerystring();
                                                InfaKBCommonUtilityJs.fnRemoveQuerystring('c__recordFields', window[varSearchInstanceId].varObjectDataFromURL);
                                                InfaKBCommonUtilityJs.fnRemoveQuerystring('c__sObjectName', window[varSearchInstanceId].varObjectDataFromURL);
                                                InfaKBCommonUtilityJs.fnRemoveQuerystring('c__debug', window[varSearchInstanceId].varObjectDataFromURL);
                                                InfaKBCommonUtilityJs.fnRemoveQuerystring('c__t', window[varSearchInstanceId].varObjectDataFromURL);
                                                InfaKBCommonUtilityJs.fnRemoveQuerystring('c__q', window[varSearchInstanceId].varObjectDataFromURL);
                                          }
                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetObjectDataFromURL Message : ' + error.message);
                                    }
                              }

                              function fnReplaceUnneededQueryString() {
                                    try {
                                          var varCurentURL = window.location;
                                          var varmatchresult = window.location.toString().match(/(uid).*(view#)+/igm);
                                          if (varmatchresult != null) {
                                                if (varmatchresult.length > 0) {
                                                      document.location.href = window.location.href.replace(varmatchresult[0], 'uid=1634607695168#');
                                                }
                                          }

                                    } catch (error) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnReplaceUnneededQueryString Message : ' + error.message);
                                    }
                              }

                              function fnShowSearchBoxWithoutKeyword() {
                                    try {
                                          $(searchInterfaceID + '>*').css({ 'display': 'block' });
                                          $('.coveo-tab-section').css({ 'display': 'none' });
                                    }
                                    catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnShowSearchBoxWithoutKeyword Message : ' + ex.message);
                                    }
                              }


                              /**
                               * Function to create Coveo search token on load of the page when the token is already available.
                               */
                              function fnHookCustomEventHandlerToCoveoSearchFramwwork() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnHookCustomEventHandlerToCoveoSearchFramwwork');

                                          //Tag 02 : Start : I2RT-7586 : Adding Article Number for Coveo Reporting(Internal and External)
                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('changeAnalyticsCustomData', function(e, args) {
                                                console.log('KB Internal : Updating Meta Object for article number', args);
                                                if (args.type == 'ClickEvent') {
                                                      var articleNo = args.resultData.raw.infaarticlenumber;
                                                      if (articleNo != undefined) {
                                                            console.log('ClickEvent : Article Number : ', articleNo);
                                                            args.metaObject.ArticleNumber = articleNo;
                                                      }                                    
                                                }
                                            });
                                            //Tag 02 : End : I2RT-7586

                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('afterInitialization', function (e, result) {
                                                if (document.location.pathname.split('/s/global-search/').length > 1) {
                                    
                                                      if ($('.magic-box-input') != undefined && $('.magic-box-input').find('input').length > 0) {
                                                            var searchkeyword = document.location.pathname.split('/s/global-search/')[1];
                                                            searchkeyword = decodeURIComponent(searchkeyword);
                                                            searchkeyword = searchkeyword.trim();
                                                            if (document.location.hash.indexOf('q=') == -1) {
                                                                  Coveo.state(Coveo.$$(document).find(searchInterfaceID), 'q', searchkeyword);
                                                            }
                                                      }
                                                }
                                                if (document.querySelector('.es-container-fluid--grey') != null) {
                                                      document.querySelector('.es-container-fluid--grey').style.display = 'none';
                                                }
                                                //Used to load the filter when the filter the available.
                                                fnBuildCoveoStateFromString();

                                                //fnBuildCoveoStateFromStringForRefresh();//Tag 06 //URL will Change

                                                fnLoginToKBCommunity();

                                                fnRegisterCoveoTemplateHelper();
                                          });

                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('preprocessMoreResults', function (e, data) {
                                                InfaKBCommonUtilityJs.Log('log', 'preprocessMoreResults');
                                                var _this = this;
                                                setTimeout(function () {
                                                      InfaKBCommonUtilityJs.Log('log', 'preprocessMoreResults setTimeout');
                                                      InfaKBCommonUtilityJs.Log('log', Coveo.$(searchInterfaceID).find('.CoveoResultFolding').length.toString());
                                                      if (Coveo.$(searchInterfaceID).find('.CoveoResultFolding').length != 0) {
                                                            Coveo.$(searchInterfaceID).find('.CoveoResultFolding').find('.CoveoIcon').removeClass('coveo-icon').addClass('search-kb-icon');
                                                      }
                                                }, 500);

                                          });

                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('preprocessResults', function (e, data) {
                                                InfaKBCommonUtilityJs.Log('log', 'preprocessResults');
                                                fnModifyKBUURLBasedOnEnvironment(data);
                                          });
                       
                                          // Coveo.$$(document.querySelector(searchInterfaceID)).on('querySuccess', function (e, result) {
                                          //       fnAssignSearchTemplateForResult(result);
                      
                                          // });

                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('newResultDisplayed', function (e, data) {
                                                InfaKBCommonUtilityJs.Log('log', 'newResultDisplayed');
                                                //Content Visited Feature
                                                InfaKBContentVisitedFeatureJs.fnDisplayVisitedContentDetailsForShowMore(e, data);
                                                CustomCoveoTemplateFrameworkJs.fnBuildHtmlBasedOnMetaData(data);
                                                fnBuildCustomResultItem(data);
                                                fnBuildShowMoreContent(data);
                                          });

                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('newResultsDisplayed', function (e, data) {
                                                InfaKBCommonUtilityJs.Log('log', 'newResultsDisplayed');
                                                fnHookCustomFilterEventHandler();
                                                fnBuildDetailsContent(e.target);
                                                fnBuildSingleLineContent(e.target);
                                                // fnBuildCopyURLContent(e.target);
                                          });
                                                                              
                                          Coveo.$$(document.querySelector(searchInterfaceID)).on('deferredQuerySuccess', function (e, result) {

                                                //Content Visited Feature
                                                InfaKBContentVisitedFeatureJs.fnDecideToLoadContentVisitedData(0);
                        
                                                fnReBuildFacetBasedOnContentTypeFacet(Coveo.$(searchInterfaceID).find('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']'));

                                                fnAssignSearchTokenForAnalytics();
                                                
                                                //fnSetFilterInSessionData(); //Tag 6//

                                          });

                                          //fnToCheckBootStrap(0);
                             
                                          varIsCustomFilterEventHandlerHookedToCoveoFramework = true;

                                                     
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnHookCustomEventHandlerToCoveoSearchFramwwork Message : ' + ex.message);
                                    }
                              }

                              function fnCreateCoveoCustomCompForNoResult() {
                                    try {
                                          var CustomNoResults = (function (_super) {
                                                __extends(CustomComponent, Coveo.Component);
                                                function CustomComponent(element, options, bindings) {
                                                      _super.call(this, element, CustomComponent.ID, bindings);
                                                      this.type = 'CustomComponent';
                                                      Coveo.Component.bindComponentToElement(element, this);
                                                      this.element = element;
                                                      this.options = options;
                                                      this.bindings = bindings;
                                                      this.options = Coveo.ComponentOptions.initComponentOptions(element, CustomNoResults, options);
                                                      if (this.options.noResultsTemplate == null) {
                                                            this.options.noResultsTemplate = new Coveo.Template(Coveo._.template('<div>Your No Result Custom Msg</div>'));
                                                      }
                                                }
                                                CustomNoResults.ID = 'CustomComponent';
                                                Coveo.Initialization.registerAutoCreateComponent(CustomNoResults);
                                          })(Coveo.Component);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnCreateCoveoCustomCompForNoResult Message : ' + ex.message);
                                    }
      
                              }

                              function fnBuildCustomResultItem(data) {
                                    try {
                                          if (/(\bpdf\b|\bxls\b|\btxt\b|\bhtml\b|\bzip\b|\bxml\b|\bcs\w+\b)/i.test(data.result.raw.sysfiletype)) {
                                                Coveo.$(data.item).find('.CoveoIcon').removeClass('coveo-icon').addClass('search-kb-icon');
                                          }

                                          if (data.result.raw.sysfiletype === 'html') {
                                                Coveo.$(data.item).find('.CoveoQuickview').hide();
                                          }

                                          if (window[varSearchInstanceId].varRecentContentValueObject != undefined && fnArrayContains(window[varSearchInstanceId].varRecentContentValueObject, data.result.raw.infadocid)) {
                                                if (Coveo.$(data.item).find('.Latest').length > 0) {
                                                      Coveo.$(data.item).find('.Latest')[0].parentElement.style.display = 'inline';
                                                }

                                          }
                                          //TAG 02
                                          if (Coveo.$(data.item).find('.kbAvgRating').length > 0) {
                                                var varkbAvgRatingParentElement = Coveo.$(data.item).find('.kbAvgRating')[0];
                                                if (Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakbaveragerating\']').length > 0) {
                                                      var varAvgRating = Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakbaveragerating\']')[0].childNodes[0].innerHTML;
                                                      if (varAvgRating != undefined && varAvgRating != '' && parseInt(varAvgRating) > 0) {
                                                            for (var k = 0; k < varAvgRating; k++) {
                                                                  varkbAvgRatingParentElement.children[k].setAttribute('class', 'ratingStar filledRatingStar');
                                                            }
                                                      }
                                                }

                                          }

                                          if (Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']').length > 0) {
                                                var varLifeTimeViews = Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']')[0].childNodes[0].innerHTML;
                                                if (varLifeTimeViews != undefined && varLifeTimeViews != '' && parseInt(varLifeTimeViews) > 0) {
                                                      varLifeTimeViews = fnformatCommaSeperatedNumber(varLifeTimeViews);
                                                      Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']')[0].childNodes[0].innerHTML = varLifeTimeViews;
                                                }
                                          }

                                          //TAG 02
                                          Coveo.$(data.item).find('.CoveoIcon').addClass(data.result.raw.infadocumenttype ? data.result.raw.infadocumenttype : '');
                
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildCustomResultItem Message : ' + ex.message);
                                    }
                              }

                              function fnModifyKBUURLBasedOnEnvironment(data) {
                                    try {
                        
                                          for (var i = 0; i < data.results.results.length; ++i) {
                                                var r = data.results.results[i];

                                                var infa_docType = r.raw.infadocumenttype ? r.raw.infadocumenttype : '';
                                                var infa_permissionType = r.raw.infapermissiontype ? r.raw.infapermissiontype.toLowerCase() : '';
                                                var infa_moderationStatus = r.raw.infamoderationstatus ? r.raw.infamoderationstatus : '';
                                                var isInternalSearchEnv = false;
                                                var varSearchUserFedID = '';
                                                if (window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier') != undefined) {
                                                      varSearchUserFedID = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier');
                                                }
                                                var infa_validationstatus = r.raw.infavalidationstatus ? r.raw.infavalidationstatus.toLowerCase() : '';
                                                var infa_publishstatus = r.raw.infapublishstatus ? r.raw.infapublishstatus.toLowerCase() : '';
                                                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'KB') {
                                                      var internalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                      var internaldrafturlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                      var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&type=external'
                                                      var externaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&type=external'
                                                      var inernaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                      var inernaltdraftechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
            
                                                      //IsUserAuthenticated == true means the logged user is not a guest user thus we are on Internal KB page                                    
                                                      // isInternalSearchEnv = window[varSearchInstanceId].IsUserAuthenticated == 'true' && window[varSearchInstanceId].UserType == 'Standard' ?
                                                      //       true : ((infa_permissionType == 'internal' || (infa_permissionType == 'public' && infa_moderationStatus != 0)) ? true : false);
                                                      isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
            
                                                      if (isInternalSearchEnv == true && infa_validationstatus == 'pending technical review') {
                                                            r.clickUri = inernaltechnicalreviewurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                                      }
                                                      else if (isInternalSearchEnv == false && infa_validationstatus == 'pending technical review') {
                                                            r.clickUri = externaltechnicalreviewurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                                                      }
                                                      else if (isInternalSearchEnv == true && infa_publishstatus == 'draft') {
                                                            r.clickUri = internaldrafturlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                                      }
                                                      else if (isInternalSearchEnv == true) {
                                                            r.clickUri = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                                      }
                                                      else if (isInternalSearchEnv == false) {
                                                            r.clickUri = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                                                      }
            
                                                      r.ClickUri = r.clickUri;
                                                      r.PrintableUri = r.printableUri = r.clickUri;
            
                                                }

                                                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceCase') {

                                                      isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                                      var internalurlformat = '/lightning/r/Case/%%CASEID$$/view'
                                                      var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].eSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'

                                                      if (isInternalSearchEnv == true) {
                                                            r.clickUri = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                                                      }
                                                      else if (isInternalSearchEnv == false) {
                                                            r.clickUri = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                                                      }

                                                      r.ClickUri = r.clickUri;
                                                      r.PrintableUri = r.printableUri = r.clickUri;
                                                }

                                                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceAccount') {

                                                      isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                                      var internalurlformat = '/lightning/r/Account/%%ACCOUNTID$$/view'
                                                      var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].eSupportCommunityNameInURL + '/s/supportaccountdetails?accountid=%%ACCOUNTID$$'

                                                      if (isInternalSearchEnv == true) {
                                                            r.clickUri = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                                                      }
                                                      else if (isInternalSearchEnv == false) {
                                                            r.clickUri = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                                                      }

                                                      r.ClickUri = r.clickUri;
                                                      r.PrintableUri = r.printableUri = r.clickUri;
                                                }

                                                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforcebCase_Comment__c') {

                                                      var infa_sfcase__c = r.raw.sfcase__c ? r.raw.sfcase__c : '';

                                                      isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                                      var internalurlformat = '/lightning/r/Case/' + infa_sfcase__c + '/view#q=%%CASECOMMENTID$$'
                                                      var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].eSupportCommunityNameInURL + '/s/casedetails?caseId=' + infa_sfcase__c + '&q=%%CASECOMMENTID$$'

                                                      if (isInternalSearchEnv == true) {
                                                            r.clickUri = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASECOMMENTID$$', r.raw.sfid)
                                                      }
                                                      else if (isInternalSearchEnv == false) {
                                                            r.clickUri = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASECOMMENTID$$', r.raw.sfid)
                                                      }

                                                      r.ClickUri = r.clickUri;
                                                      r.PrintableUri = r.printableUri = r.clickUri;
                                                }
                                          }
                 
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnModifyKBUURLBasedOnEnvironment Message : ' + e.message);
                                    }
                              }

                              function fnSetGlobalVariables() {
                                    try {
                        
                                          var host = window.location.hostname;
                                          window[varSearchInstanceId].varCalledFrom = (window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.PlacedIn').toString().trim().toLowerCase());
                                          window[varSearchInstanceId].SFDCKBInternalHost = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnSFDCKBInternalHost');
                                          window[varSearchInstanceId].SFDCKBExternalHost = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnSFDCKBExternalHost');
                                          window[varSearchInstanceId].SFDCEsupportHost = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnSFDCEsupportHost');
                                          window[varSearchInstanceId].KBCommunityNameInURL = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnKBCommunityNameInURL') == 'none' ? '' : window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnKBCommunityNameInURL');
                                          window[varSearchInstanceId].eSupportCommunityNameInURL = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdneSupportCommunityNameInURL') == 'none' ? '' : window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdneSupportCommunityNameInURL');

                                                
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetGlobalVariables Message : ' + e.message);
                                    }
                              }

                              /**
                               * Used to show the progress icon on ajax call
                               */
                              function fnToggleInProgressAnimation() {
                                    try {
                                          var varAnimationElement = Coveo.$(varCustomCoveoAnimation);
                                          if (varAnimationElement.length > 0) {
                                                if (varAnimationElement[0].style.display == 'none') {
                                                      varAnimationElement[0].style.display = 'block';
                                                } else if (varAnimationElement[0].style.display == 'block') {
                                                      varAnimationElement[0].style.display = 'none';
                                                      Coveo.$(searchInterfaceWrapper).find('.slds-card')[0].style.display = 'block'
                                                }
                                          }
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnToggleInProgressAnimation : ' + e.message);
                                    }
                              }


                              /**
                               * Intilizes the Coveo framework on load of the page
                               */
                              function fnIntializeCoveoSearchFramwwork() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnActualIntializeCoveoSearchFramwwork');

                                          fnToggleInProgressAnimation();

                                          Coveo.init(document.querySelector(searchInterfaceID));

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnActualIntializeCoveoSearchFramwwork Message : ' + e.message);
                                    }
                              }


                              /**
                               * Funtction will wait for all the requried are content availalbe,
                               * before it start triggering the search query to Coveo on load of the page
                               * @param {count to wait} execCount 
                               */

                              function fnDecideToLoadContentForSearch(execCount) {

                                    try {
                                          //if ((varIsCustomEventHandlerHookedToCoveoFramework == true) && (varIsCustomFilterEventHandlerHookedToCoveoFramework == true) && (varIsCoveoSearchTokenRetrived == true) && (window[varSearchInstanceId].varIsCoveoRecentContentRetrived == true) && (varIsCoveoUserFilterRetrived == true) && (varIsNoSearchResultTemplateRetrived == true) && (varIsSearchResultTemplateRetrived == true)) { // Tag 4 //
                                          if ((varIsCustomEventHandlerHookedToCoveoFramework == true) && (varIsCustomFilterEventHandlerHookedToCoveoFramework == true) && (varIsCoveoSearchTokenRetrived == true) && (window[varSearchInstanceId].varIsCoveoRecentContentRetrived == true) && (varIsNoSearchResultTemplateRetrived == true) && (varIsSearchResultTemplateRetrived == true)) {  // Tag 4//
                                                InfaKBCommonUtilityJs.Log('log', 'fnDecideToLoadContentForSearch : All Field available to initialize coveo')
                                                varIsAllRequiredContentAvailable = true;
                                                fnIntializeCoveoSearchFramwwork();
                                          } else if (execCount < 600) {
                                                execCount = execCount + 1;
                                                window.setTimeout(function () { fnDecideToLoadContentForSearch(execCount); }, 100);
                                          }
                  
                                    } catch (exTwo) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnDecideToLoadContentForSearch Message : ' + exTwo.message);
                                    }
                              }


                              /**
                               * Function to update the content in the folding content
                               */
                              function fnHookEventToFoldingElement() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnHookEventToFoldingElement');
                                          Coveo.$(searchInterfaceID).find('[class^=\'CoveoResultFolding\']').bind('change', function (args) {
                                                fnUpdateFoldingResultICon(this);
                                          });
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnHookEventToFoldingElement Message : ' + ex.message);
                                    }
                              }

                              /**
                               * Retrive the Coveo Facet values on load
                               * @param {Content the array of facet elemets} parAllCustomFacetElement 
                               */

                              function fnGetFacetValuesCoveoSearch(parAllCustomFacetElement) {

                                    try {

                                          InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch');

                 
                                          var varstrFacetFieldName = '';

                                          for (var o = 0; o < parAllCustomFacetElement.length; o++) {
                                                if (o == 0) {
                                                      varstrFacetFieldName += parAllCustomFacetElement[o].getAttribute('data-custom-coveo-field');
                                                } else {
                                                      varstrFacetFieldName += ',' + parAllCustomFacetElement[o].getAttribute('data-custom-coveo-field');
                                                }

                                          }

                                          var varRequestParameters = { strSessionToken: varSearchUserSessionId, strUserEmail: varSearchUserEmail, strUserID: varSearchUserId, strFacetFieldName: varstrFacetFieldName };
                                          var varRequestParamsAfterStringify = JSON.stringify(varRequestParameters);


                                          Coveo.$.ajax({
                                                url: '/_layouts/InformaticaKBSearchPageControls/SearchTokenGen/WebService/DataService.asmx/GetFacetValues',
                                                method: 'post',
                                                dataType: 'json',
                                                contentType: 'application/json;charset=utf-8',
                                                data: varRequestParamsAfterStringify,
                                                success: function (response) {
                                                      try {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch success');

                                                            var data = jQuery.parseJSON(response.d);


                                                            Coveo.$(data).each(function (index, topitem) {
                                                                  InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch Status : ' + topitem.APIResponseStatus);
                                                                  InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch Error : ' + topitem.ErrorMessage);

                                                                  if (data.APIResponseStatus == 'OK') {
                                                
                                                                        varSearchFacetValueObject = topitem.groupByResults;
                                                                        varSearchFacetValueDefferred.resolve(varSearchFacetValueObject);
                                                                  } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                                        varSearchFacetValueDefferred.reject(topitem.groupByResults);
                                                                  }
                                                                  else if (data.APIResponseStatus == 'ERROR') {
                                                                        varSearchFacetValueDefferred.reject(data);
                                                                  }

                                                            });
                                                      } catch (ex) {
                                                            var obj = { error: ex };
                                                            InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetFacetValuesCoveoSearch Inner Catch Message : ' + obj);
                                                            varSearchFacetValueDefferred.reject(ex);

                                                      }

                                                },
                                                error: function (err) {
                                                      InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetFacetValuesCoveoSearch Message : ' + err);
                                                      varSearchFacetValueDefferred.reject(err);
                                                }
                                          });

                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetFacetValuesCoveoSearch Message : ' + ex.message);
                                    }
                                    varSearchFacetValueDefferred = Coveo.$.Deferred();
                                    return varSearchFacetValueDefferred;
                              }

                              /**
                               * Used for filtering based on the user 
                               */

                              function fnSetMyFilterCoveoSearch() {

                                    try {

                                          InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch');
               
                                          var varstrFilter = '';


                                          var varRequestParameters = { strSessionToken: varSearchUserSessionId, strUserEmail: varSearchUserEmail, strUserID: varSearchUserId, strFilter: varstrFilter };
                                          var varRequestParamsAfterStringify = JSON.stringify(varRequestParameters);


                                          Coveo.$.ajax({
                                                url: '/_layouts/InformaticaKBSearchPageControls/SearchTokenGen/WebService/DataService.asmx/InsertOrUpdateMyFilter',
                                                method: 'post',
                                                dataType: 'json',
                                                contentType: 'application/json;charset=utf-8',
                                                data: varRequestParamsAfterStringify,
                                                success: function (response) {
                                                      try {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch success');

                                                            var data = JSON.parse(response.d);

                                                            Coveo.$(data).each(function (index, topitem) {
                                                                  InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch Status : ' + topitem.APIResponseStatus);
                                                                  InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch Error :  ' + topitem.ErrorMessage);

                                                                  if (data.APIResponseStatus == 'OK') {
                                                                        if (data.APIResponseData != null) {
                                                                              var varFilterData = jQuery.parseJSON(topitem.APIResponseData);
                                                                              var varFilterDataJSONString = varFilterData.UserFilterDetails.Filters;
                                                                              document.getElementById(Coveo.$(searchInterfaceID).find('[id*=\'hdnUserFilter\']')[0].id).value = varFilterDataJSONString;

                                                                              varUserFilterValueOnSaveDefferred.resolve(topitem.APIResponseData);
                                                                        } else {
                                                                              InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch success : No User Filter avaialble');
                                                                        }

                                                                  } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                                        varUserFilterValueOnSaveDefferred.reject(topitem.APIResponseData);
                                                                  }
                                                                  else if (data.APIResponseStatus == 'ERROR') {
                                                                        varUserFilterValueOnSaveDefferred.reject(data);
                                                                  }
                                                            });
                                                      } catch (ex) {
                                                            var obj = { error: ex };
                                                            InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetMyFilterCoveoSearch Inner Catch Message : ' + obj);
                                                            varUserFilterValueOnSaveDefferred.reject(obj);
                                                      }

                                                },
                                                error: function (err) {
                                                      InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetMyFilterCoveoSearch Message : ' + err);
                                                      varUserFilterValueOnSaveDefferred.reject(err);
                                                }
                                          });

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnSetMyFilterCoveoSearch : ' + e.message);
                                    }
                                    varUserFilterValueOnSaveDefferred = Coveo.$.Deferred();
                                    return varUserFilterValueOnSaveDefferred;
                              }

                              /**
                               * Used to build the filter
                               * @param {Current Query String} parCurrentItem 
                               */

                              function fnFormatQueryFromString(parCurrentItem) {
                                    try {
                                          if (parCurrentItem.indexOf(' ') > -1) {
                                                return '\'' + parCurrentItem + '\'';
                                          } else {
                                                return parCurrentItem;
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnFormatQueryFromString Message : ' + ex.message);
                                    }
                                    return parCurrentItem;
                              }

                              /**
                               * Used to build the facet querysting based on the cases product respective to the user
                               */

                              function fnBuildQueryFromString() {
                                    try {
                                          var varActualQueryArray = [];
                                          var varUserFilter = document.getElementById(Coveo.$(searchInterfaceID).find('[id*=\'hdnUserFilter\']')[0].id).value;
                                          var varUserFilterJSONObject = jQuery.parseJSON(varUserFilter);
                                          for (var r = 0; r < varUserFilterJSONObject.length; r++) {
                                                var varQuery = varUserFilterJSONObject[r].field + '==';
                                                for (var s = 0; s < varUserFilterJSONObject[r].values.length; s++) {
                                                      if (varUserFilterJSONObject[r].values.length == 1) {
                                                            varQuery += fnFormatQueryFromString(varUserFilterJSONObject[r].values[s]);
                                                      } else {
                                                            if (s == 0) {
                                                                  varQuery += '(' + (fnFormatQueryFromString(varUserFilterJSONObject[r].values[s]));
                                                            } else if (s == (varUserFilterJSONObject[r].values.length - 1)) {
                                                                  varQuery += ',' + (fnFormatQueryFromString(varUserFilterJSONObject[r].values[s])) + ')';
                                                            } else {
                                                                  varQuery += ',' + (fnFormatQueryFromString(varUserFilterJSONObject[r].values[s]));
                                                            }

                                                      }

                                                }
                                                varActualQueryArray.push(varQuery);
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildQueryFromString Message : ' + ex.message);
                                    }
                                    return varActualQueryArray;
                              }


                              /**
                               * Encode the url 
                               * @param {URL with filter in place} parCurrentItem 
                               */

                              function fnFormatURLFromString(parCurrentItem) {
                                    try {
                                          return encodeURIComponent(parCurrentItem);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnFormatURLFromString Message : ' + ex.message);
                                    }
                                    return parCurrentItem;
                              }

                              /**
                               * Used to the get the exsting Filter value, before the value gets modified
                               * @param {Currnet query string} parFacetFieldName 
                               */

                              function fnGetFacetFieldValueFromURL(parFacetFieldName) {
                                    var varFieldvalue = [];
                                    try {
                                          var varCurrentPageQueryString = window.location.hash;
                                          if (varCurrentPageQueryString.indexOf(parFacetFieldName) != -1) {
                                                var varSubString = varCurrentPageQueryString.substring(varCurrentPageQueryString.indexOf(parFacetFieldName));
                                                varFacetURL = varSubString.substring(0, varSubString.indexOf(']') + 1);
                                                var varFieldvalueString = varFacetURL.substring(varFacetURL.indexOf('[') + 1, varFacetURL.indexOf(']'));
                                                varFieldvalueString = decodeURIComponent(varFieldvalueString);
                                                varFieldvalue = varFieldvalueString.split(',');
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetFacetFieldValueFromURL Message : ' + ex.message);
                                    }
                                    return varFieldvalue;
                              }

                              /**
                               * Used to get the filter from URL
                               * @param {Selected filter name} parFacetFieldName 
                               */

                              function fnGetFacetFilterFromURL(parFacetFieldName) {
                                    var varFacetURL = '';
                                    try {
                                          var varCurrentPageQueryString = window.location.hash;
                                          if (varCurrentPageQueryString.indexOf(parFacetFieldName) != -1) {
                                                var varSubString = varCurrentPageQueryString.substring(varCurrentPageQueryString.indexOf(parFacetFieldName));
                                                varFacetURL = varSubString.substring(0, varSubString.indexOf(']') + 1);
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetFacetFilterFromURL Message : ' + ex.message);
                                    }
                                    return varFacetURL;
                              }

                              /**
                               * Get the distinct from the filter
                               * @param {User Filter Vlaue} parUserFilterFacetValue 
                               * @param {Current URL} parUrlFilterFacetValue 
                               */

                              function fnGetDistinctValues(parUserFilterFacetValue, parUrlFilterFacetValue) {
                                    var varFilteredValue = [];

                                    try {
                                          var allFilterValue = parUserFilterFacetValue.concat(parUrlFilterFacetValue);
                                          varFilteredValue = fnArrayUnique(allFilterValue);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRemoveDuplicateValues Message : ' + ex.message);
                                    }
                                    return varFilteredValue;
                              }


                              function fnBuildURLFromString() {
                                    var varResultURL = '';
                                    try {
                                          var varCurrentPageQueryString = window.location.hash;
                                          var varUserFilter = window[varSearchInstanceId].varUserFilterString;
                                          var varUserFilterJSONObject = jQuery.parseJSON(varUserFilter);
                                          for (var r = 0; r < varUserFilterJSONObject.length; r++) {
                                                var varQuery = 'f:' + varUserFilterJSONObject[r].field + '=';
                                                var varFacetFieldFilterFromURL = fnGetFacetFilterFromURL(varQuery);
                                                var varFacetFieldValueArrayFromURL = fnGetFacetFieldValueFromURL(varQuery);
                                                varUserFilterJSONObject[r].values = fnGetDistinctValues(varUserFilterJSONObject[r].values, varFacetFieldValueArrayFromURL);
                                                if (varUserFilterJSONObject[r].values.length != 0) {
                                                      for (var s = 0; s < varUserFilterJSONObject[r].values.length; s++) {
                                                            if (varUserFilterJSONObject[r].values.length == 1) {
                                                                  varQuery += '[' + fnFormatURLFromString(varUserFilterJSONObject[r].values[s]) + ']';

                                                            } else {
                                                                  if (s == 0) {
                                                                        varQuery += '[' + (fnFormatURLFromString(varUserFilterJSONObject[r].values[s]));
                                                                  } else if (s == (varUserFilterJSONObject[r].values.length - 1)) {

                                                                        varQuery += ',' + (fnFormatURLFromString(varUserFilterJSONObject[r].values[s])) + ']';
                                                                  } else {
                                                                        varQuery += ',' + (fnFormatURLFromString(varUserFilterJSONObject[r].values[s]));
                                                                  }

                                                            }

                                                      }
                                                } else {
                                                      varQuery = '';
                                                }


                                                if (varFacetFieldFilterFromURL != '') {
                                                      varCurrentPageQueryString = varCurrentPageQueryString.replace(varFacetFieldFilterFromURL, varQuery);
                                                } else if (varQuery != '') {
                                                      if (varCurrentPageQueryString.indexOf('#') > -1) {

                                                            varCurrentPageQueryString = varCurrentPageQueryString + '&' + varQuery;
                                                      } else {

                                                            varCurrentPageQueryString = varCurrentPageQueryString + '#' + varQuery;
                                                      }
                                                }
                                          }
                                          varResultURL = varCurrentPageQueryString;
                                          varQueryURLBuildFromString = varCurrentPageQueryString;
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildURLFromString Message : ' + ex.message);
                                    }
                                    return varResultURL;
                              }

                              function fnBuildCoveoStateFromString() {
                                    try {
                                          var varUserFilter = window[varSearchInstanceId].varUserFilterString;
                                          if (varUserFilter != undefined && varUserFilter != '') {
                                                var varUserFilterJSONObject = JSON.parse(varUserFilter);
                                                for (var r = 0; r < varUserFilterJSONObject.length; r++) {
                                                      if (varUserFilterJSONObject[r].values != undefined && varUserFilterJSONObject[r].values.length != 0) {
                                                            //Coveo.state(document.querySelector(searchInterfaceID), 'f:' + varUserFilterJSONObject[r].field, varUserFilterJSONObject[r].values);//Tag 04
                                                      }
                                                }
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildCoveoStateFromString Message : ' + ex.message);
                                    }
                              }
			      
                              //Tag 06//URL will Change
                              function fnBuildCoveoStateFromStringForRefresh() {                                    
                                    try {
                                          if ((window[varSearchInstanceId].varCalledFrom == CONTENTSEARCH) && Coveo.$(searchInterfaceID)[0] != undefined) {                                               
                                                var varBeforeRefreshFilter =  fnGetFilterInSessionData();
                                                if (varBeforeRefreshFilter != undefined && varBeforeRefreshFilter != '') {                                                
                                                     document.location.hash = varBeforeRefreshFilter;                               
                                                }
                                          }  
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildCoveoStateFromString Message : ' + ex.message);
                                    }
                              }
                              //Tag 06//URL will Change

                              function fnLoginToKBCommunity() {
                                    try {
                                          //var varNetworkSwitchLogin = window[varSearchInstanceId].InternalNetworkSwitchLogInURL;				
                                          //var varFinalURL = varNetworkSwitchLogin + '/s/article';                        
                                          //var TheNewWin = window.open(varFinalURL, "ForceLogin", "menubar=no,location=no,resizable=no,scrollbars=no,status=no,width=1,height=1");
                                          //var TheNewWin = window.open(varFinalURL, "ForceLogin", "menubar=no,location=no,resizable=no,scrollbars=no,status=no,top=3000,left=0,width=1,height=1");
                                          //setTimeout(function () { TheNewWin.close(); }, 10000);
                                          setTimeout(function () { try { document.querySelector(searchinfakbcsdummywin).remove();} catch (ex) {} }, 10000);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnLoginToKBCommunity Message : ' + ex.message);
                                    }
                              }

                              function fnRegisterCoveoTemplateHelper() {
                                    try {
                                          // Coveo.TemplateHelpers.registerTemplateHelper("jiveanswerDisplay", (value, options) => {
                                          //       console.log('jiveanswerDisplay');
                                          // });
                                          // Coveo.TemplateHelpers.registerTemplateHelper("jivehelpfulDisplay", (value, options) => {
                                          //       console.log('jivehelpfulDisplay');
                                          // });

                                          Coveo.TemplateHelpers.registerTemplateHelper("jiveanswerDisplay", function (value) {
                                                if (value == 'True') {
                                                      return '<span class="jive-badge jive-status jive-status-green" style="margin-left:5px;margin-right:5px;">Correct Answer</span>';
                                                }
                                                else {
                                                      return '';
                                                }
                                          });

                                          Coveo.TemplateHelpers.registerTemplateHelper("jivehelpfulDisplay", function (value) {
                                                if (value == 'True') {
                                                      return '<span class="jive-badge jive-status" style="margin-left:5px;">Helpful</span>';
                                                }
                                                else {
                                                      return '';
                                                }
                                          });


                                          Coveo.TemplateHelpers.registerTemplateHelper("sfdcChatterBestAnswerDisplay", function (value) {
                                                return '<span class="custom-coveo-child-result-badge">' + value + '</span>';
                                          });
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRegisterCoveoTemplateHelper Message : ' + ex.message);
                                    }
                              }

                              function fnRemovePersonalizedFilter() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnRemovePersonalizedFilter');
                                          Coveo.$(searchInterfaceID).find('.CoveoSearchButton').click();

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnRemovePersonalizedFilter : ' + e.message);

                                    }
                              }

                              function fnApplyPersonalizedFilter() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnApplyPersonalizedFilter');
                                          Coveo.$(searchInterfaceID).find('.CoveoSearchButton').click();

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnApplyPersonalizedFilter : ' + e.message);

                                    }
                              }

                              function fnTogglePersonalizedFilter(parCurrentElement) {
                                    try {
                                          //if condition for - on click to collapse the content
                                          var iconElement = Coveo.$(parCurrentElement)[0];
                                          if (Coveo.$(iconElement.parentNode).find('#chkbkPersonalizedFilterSwitch').length > 0) {
                                                if (Coveo.$(searchInterfaceID).find('#chkbkPersonalizedFilterSwitch')[0].checked == false) {
                                                      if (this.window.location.hash.indexOf('#') > -1) {
                                                            varQueryURLBasedOnCondition = '&' + varQueryURLBuildFromString;
                                                      } else {
                                                            varQueryURLBasedOnCondition = '#' + varQueryURLBuildFromString;
                                                      }

                                                      Coveo.$(iconElement).attr('data-ishighlited', 'true');

                                                      this.window.location.hash += varQueryURLBasedOnCondition;

                                                      //fnApplyPersonalizedFilter();
                                                      // $('.personalization-wizard-header').css('border-bottom', '0px solid #BCC3CA');
                                                }
                                                //if condition for - on click to expand the content
                                                else if (Coveo.$(searchInterfaceID).find('#chkbkPersonalizedFilterSwitch')[0].checked == true) {
                                                      this.window.location.hash = this.window.location.hash.replace(varQueryURLBasedOnCondition, '');
                                                      Coveo.$(iconElement).attr('data-ishighlited', 'false');
                                                      //fnRemovePersonalizedFilter();
                                                }
                                          }
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnTogglePersonalizedFilter : ' + e.message);
                                    }
                              }

                              function fnToggleFilterCheckBox(parCurrentElement) {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnToggleFilterCheckBox');
                                          //if condition for - on click to collapse the content
                                          var iconElement = Coveo.$(parCurrentElement)[0];
                                          if ((Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption').attr('data-original-value') != undefined) && ($(parCurrentElement).find('.data-custom-coveo-facet-value-caption').attr('data-original-value').length > 0)) {
                                                if (Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked == false) {
                                                      Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked = true;
                                                      Coveo.$(parCurrentElement).attr('data-custom-coveo-ischecked', 'true');
                                                      var varCheckBoxIcon = document.createElement('li');
                                                      varCheckBoxIcon.setAttribute('class', 'fa fa-check');
                                                      varCheckBoxIcon.setAttribute('style', 'position: absolute;left: 23px;top: 9px;');
                                                      Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption')[0].parentNode.appendChild(varCheckBoxIcon);
                                                      //fnApplyPersonalizedFilter();
                                                      // $('.personalization-wizard-header').css('border-bottom', '0px solid #BCC3CA');
                                                }
                                                //if condition for - on click to expand the content
                                                else if (Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked == true) {
                                                      Coveo.$(parCurrentElement).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked = false;
                                                      Coveo.$(parCurrentElement).attr('data-custom-coveo-ischecked', 'false');
                                                      Coveo.$(parCurrentElement).find('.fa-check').remove();
                                                      //fnRemovePersonalizedFilter();
                                                }
                                          }
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnTogglePersonalizedFilter : ' + e.message);
                                    }
                              }

                              function fnProcessFilterOnLoad() {
                                    try {
                                          if (window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ATHENAKBSEARCHINTERNAL) {
                                                fnGetFilterOnLoad()
                                                      .then(function (data) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnProcessFilterOnLoad then');
                                                            varIsCoveoUserFilterRetrived = true;
                                                      })
                                                      .fail(function (err) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnProcessFilterOnLoad fail');
                                                            InfaKBCommonUtilityJs.Log('log', err);
                                                            varIsCoveoUserFilterRetrived = true;
                                                      });
                                          }
                                          else {
                                                varIsCoveoUserFilterRetrived = true;
                                          }
                        
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnProcessFilterOnLoad : ' + e.message);
                                    }
                              }

                              function fnAssignFilterOnWizardLoad() {
                                    try {

                                          if ((Coveo.$(searchInterfaceID).find('.CustomCoveoFacet').length > 0) && (document.getElementById(Coveo.$(searchInterfaceID).find('[id*=\'hdnUserFilter\']')[0].id).value != '')) {

                                                var varAllFacet = Coveo.$(searchInterfaceID).find('.CustomCoveoFacet').toArray();

                                                var varUserFilter = document.getElementById(Coveo.$(searchInterfaceID).find('[id*=\'hdnUserFilter\']')[0].id).value;

                                                var varUserFilterJSONObject = jQuery.parseJSON(varUserFilter);

                                                for (var m = 0; m < varUserFilterJSONObject.length; m++) {
                                                      var varSelectedFacet = varAllFacet.filter(function (x) {
                                                            return varUserFilterJSONObject[m].field.trim().toString().toLowerCase() == x.getAttribute('data-custom-coveo-field').trim().toString().toLowerCase();
                                                      });
                                                      //.filter(function(x) { return x[0] == parContentTypeName; });
                                                      if (varSelectedFacet.length != 0) {
                                                            var UserSelectedItemValues = varUserFilterJSONObject[m].values;
                                                            var AllFacetItem = Coveo.$(varSelectedFacet[0]).find('.data-custom-coveo-facet-value.custom-coveo-facet-selectable.data-custom-coveo-with-hover').toArray();
                                                            if (AllFacetItem.length != 0) {
                                                                  for (var n = 0; n < UserSelectedItemValues.length; n++) {
                                                                        var UserSelectedFacetItems = AllFacetItem.filter(function (x) {
                                                                              return UserSelectedItemValues[n].trim().toString().toLowerCase() == x.getAttribute('data-custom-coveo-value').trim().toString().toLowerCase();
                                                                        });
                                                                        if (UserSelectedFacetItems.length != 0) {
                                                                              if ((Coveo.$(UserSelectedFacetItems[0]).find('.data-custom-coveo-facet-value-caption').attr('data-original-value') != undefined) && ($(UserSelectedFacetItems[0]).find('.data-custom-coveo-facet-value-caption').attr('data-original-value').length > 0)) {
                                                                                    if (Coveo.$(UserSelectedFacetItems[0]).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked == false) {
                                                                                          Coveo.$(UserSelectedFacetItems[0]).find('.data-custom-coveo-facet-value-caption')[0].parentNode.childNodes[0].checked = true;
                                                                                          Coveo.$(UserSelectedFacetItems[0]).attr('data-custom-coveo-ischecked', 'true');
                                                                                          var varCheckBoxIcon = document.createElement('li');
                                                                                          varCheckBoxIcon.setAttribute('class', 'fa fa-check');
                                                                                          varCheckBoxIcon.setAttribute('style', 'position: absolute;left: 23px;top: 9px;');
                                                                                          Coveo.$(UserSelectedFacetItems[0]).find('.data-custom-coveo-facet-value-caption')[0].parentNode.appendChild(varCheckBoxIcon);
                                                                                          //fnApplyPersonalizedFilter();
                                                                                          // $('.personalization-wizard-header').css('border-bottom', '0px solid #BCC3CA');
                                                                                    }
                                                                              }
                                                                        }
                                                                  }
                                                            }

                                                      }
                                                      InfaKBCommonUtilityJs.Log('log', varUserFilterJSONObject);
                                                }
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnAssignFilterOnWizardLoad : ' + e.message);
                                    }
                              }

                              function fnSaveFilterForUser() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnSaveFilterForUser');
                                          var varAllFilter = [];
                                          var varFilter = [];
                                          if (Coveo.$(searchInterfaceID).find('.CustomCoveoFacet').length > 0) {

                                                var varAllFacet = Coveo.$(searchInterfaceID).find('.CustomCoveoFacet');
                                                for (var j = 0; j < varAllFacet.length; j++) {
                                                      varFilter = [];
                                                      if (Coveo.$(varAllFacet[j]).find('[data-custom-coveo-ischecked=true]').length > 0) {
                                                            var varAllSelectedItemsByUser = Coveo.$(varAllFacet[j]).find('[data-custom-coveo-ischecked=true]');
                                                            for (var i = 0; i < varAllSelectedItemsByUser.length; i++) {
                                                                  if (i == 0) {
                                                                        varFilter.push(varAllSelectedItemsByUser[i].getAttribute('data-custom-coveo-value'));
                                                                  } else {
                                                                        varFilter.push(varAllSelectedItemsByUser[i].getAttribute('data-custom-coveo-value'));
                                                                  }
                                                            }
                                                            varAllFilter.push({ field: Coveo.$(varAllFacet[j]).attr('data-custom-coveo-field'), values: varFilter });
                                                      }
                                                }


                                                document.getElementById(Coveo.$(searchInterfaceID).find('[id*=\'hdnUserFilter\']')[0].id).value = JSON.stringify(varAllFilter);

                                          }

                                          fnSetMyFilterCoveoSearch().then(function (data) {
                                                InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch then');

                                          })
                                                .fail(function (err) {
                                                      InfaKBCommonUtilityJs.Log('log', 'fnSetMyFilterCoveoSearch fail');
                                                      InfaKBCommonUtilityJs.Log('log', err);
                                                });
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnSaveFilterForUser : ' + e.message);
                                    }
                              }

                              function fnBuildRecentContentValue() {
                                    try {

                                          if (window[varSearchInstanceId].varCalledFrom == CONTENTSEARCH) {
                                                fnGetRecentContentCoveoSearch()
                                                      .then(function (data) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch then');
                                                            window[varSearchInstanceId].varIsCoveoRecentContentRetrived = true;
                                                      })
                                                      .fail(function (err) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch fail');
                                                            InfaKBCommonUtilityJs.Log('log', err);
                                                            window[varSearchInstanceId].varIsCoveoRecentContentRetrived = true;
                                                      });
                                          }
                                          else {
                                                window[varSearchInstanceId].varIsCoveoRecentContentRetrived = true;
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                                    }
                              }

                              function fnBuildCustomFacet() {
                                    try {
                                          if (Coveo.$(searchInterfaceID).find('.CustomCoveoFacet').length > 0) {
                                                fnGetFacetValuesCoveoSearch(Coveo.$(searchInterfaceID).find('.CustomCoveoFacet'))
                                                      .then(function (data) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch then');

                                                            var varAllCustomFacet = Coveo.$(searchInterfaceID).find('.CustomCoveoFacet');
                                                            for (var i = 0; i < varAllCustomFacet.length; i++) {
                                                                  fnBuildCustomFacetHeader(varAllCustomFacet[i]);
                                                                  fnBuildCustomFacetBody(varAllCustomFacet[i]);

                                                            }


                                                      })
                                                      .fail(function (err) {
                                                            InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch fail');
                                                            InfaKBCommonUtilityJs.Log('log', err);
                                                      });
                                          }


                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                                    }
                              }

                              function fnBuildCustomFacetHeader(parCurrentItem) {
                                    try {
                                          var varFacerHeaderTitle = document.createElement('div');
                                          varFacerHeaderTitle.setAttribute('class', 'coveo-facet-header-title');
                                          varFacerHeaderTitle.innerHTML = parCurrentItem.getAttribute('data-custom-coveo-title');

                                          var varFacerHeaderTitleSection = document.createElement('div');
                                          varFacerHeaderTitleSection.setAttribute('class', 'coveo-facet-header-title-section');
                                          varFacerHeaderTitleSection.appendChild(varFacerHeaderTitle);

                                          var varFacerHeaderParent = document.createElement('div');
                                          varFacerHeaderParent.setAttribute('class', 'coveo-facet-header');
                                          varFacerHeaderParent.appendChild(varFacerHeaderTitleSection);

                                          parCurrentItem.style.margin = '10px 0';
                                          parCurrentItem.style.padding = '0';
                                          parCurrentItem.style.border = 'thin solid #bcc3ca';
                                          parCurrentItem.appendChild(varFacerHeaderParent);



                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                                    }
                              }

                              function fnBuildCustomFacetItem(parCurrentItem, parParentElement) {
                                    try {

                                          var varFacetItemValueSpan = document.createElement('span');
                                          varFacetItemValueSpan.setAttribute('class', 'data-custom-coveo-facet-value-caption');
                                          varFacetItemValueSpan.setAttribute('title', parCurrentItem);
                                          varFacetItemValueSpan.setAttribute('data-original-value', parCurrentItem);
                                          varFacetItemValueSpan.innerHTML = parCurrentItem;

                                          var varFacetItemValueCheckBoxDiv = document.createElement('div');
                                          varFacetItemValueCheckBoxDiv.setAttribute('class', 'data-custom-coveo-facet-value-checkbox');


                                          var varFacetItemValueinput = document.createElement('input');
                                          varFacetItemValueinput.setAttribute('type', 'checkbox');

                                          var varFacetItemValuediv = document.createElement('div');
                                          varFacetItemValuediv.setAttribute('class', 'data-custom-coveo-facet-value-label-wrapper');
                                          varFacetItemValuediv.appendChild(varFacetItemValueinput);
                                          varFacetItemValuediv.appendChild(varFacetItemValueCheckBoxDiv);
                                          varFacetItemValuediv.appendChild(varFacetItemValueSpan);

                                          var varFacetItemValuelabel = document.createElement('label');
                                          varFacetItemValuelabel.setAttribute('class', 'data-custom-coveo-facet-value-label');
                                          varFacetItemValuelabel.setAttribute('onclick', 'return false;');
                                          varFacetItemValuelabel.appendChild(varFacetItemValuediv);

                                          var varFacetItemValueli = document.createElement('li');
                                          varFacetItemValueli.setAttribute('class', 'data-custom-coveo-facet-value custom-coveo-facet-selectable data-custom-coveo-with-hover');
                                          varFacetItemValueli.setAttribute('data-custom-coveo-ischecked', 'false');
                                          varFacetItemValueli.setAttribute('onclick', 'javascript:fnToggleFilterCheckBox(this);');
                                          varFacetItemValueli.setAttribute('data-custom-coveo-value', parCurrentItem);
                                          varFacetItemValueli.appendChild(varFacetItemValuelabel);


                                          parParentElement.appendChild(varFacetItemValueli);

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                                    }
                              }

                              function fnBuildCustomFacetBody(parCurrentItem) {
                                    try {
                                          var varFacetValuesParent = document.createElement('ul');
                                          varFacetValuesParent.setAttribute('class', 'data-custom-coveo-facet-values');

                                          // var varJsonObjectFilter


                                          var varCustomFacetFieldName = parCurrentItem.getAttribute('data-custom-coveo-field');

                                          if (varSearchFacetValueObject != undefined) {
                                                for (var l = 0; l < varSearchFacetValueObject.length; l++) {
                                                      if (varSearchFacetValueObject[l].field.trim().toString().toLowerCase() == varCustomFacetFieldName.trim().toString().toLowerCase()) {
                                                            for (var m = 0; m < varSearchFacetValueObject[l].values.length; m++) {
                                                                  fnBuildCustomFacetItem(varSearchFacetValueObject[l].values[m], varFacetValuesParent);
                                                            }
                                                      }

                                                }
                                          }

                                          parCurrentItem.appendChild(varFacetValuesParent);


                                          // parCurrentItem.appendChild(varParentDiv);

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                                    }
                              }

                              function fnBuildShowMoreContent(data) {
                                    try {

                                          var varCustomCoveoFieldTable = Coveo.$(data.item).find('[class=\'CustomCoveoFieldTableShowMoreSection\']');

                                          for (var j = 0; j < varCustomCoveoFieldTable.length; j++) {
                                                //                    varCustomFieldValue[j]

                                                var varCustomFieldValue = Coveo.$(varCustomCoveoFieldTable[j]).find('[data-custom-coveo-field]');

                                                if (varCustomFieldValue.length == 0) {
                                                      varCustomCoveoFieldTable[j].setAttribute('style', 'display:none');
                                                } else {

                                                      for (var k = 0; k < varCustomFieldValue.length; k++) {
                                                            var varFieldValueTRParent = document.createElement('tr');
                                                            varFieldValueTRParent.setAttribute('class', 'CustomCoveoValueRow');

                                                            var varFieldValueTDParent = document.createElement('td');

                                                            var varFieldValueTHName = document.createElement('th');
                                                            if (varCustomFieldValue[k].getAttribute('data-custom-coveo-caption') != null)
                                                                  varFieldValueTHName.innerHTML = varCustomFieldValue[k].getAttribute('data-custom-coveo-caption');

                                                            var varFieldValueParent = document.createElement('div');

                                                            var varFinalFieldValue = varCustomFieldValue[k].innerText.trim();
                                                            if (varCustomFieldValue[k].getAttribute('data-field') == '@sfcase_kbs__rcase__rcasenumber') {
                                                                  varFinalFieldValue = fnCustomCoveoEvaluvateShowMoreCaseLinkGetHtml(data);
                                                            }

                                                            if (varCustomFieldValue[k].getAttribute('data-field') == '@sfcase_kbs__rknowledge__rarticlenumber') {
                                                                  varFinalFieldValue = fnCustomCoveoEvaluvateShowMoreKBLinkGetHtml(data);
                                                            }

                                                            if (varCustomFieldValue[k].getAttribute('data-field') == '@infajiraname') {
                                                                  varFinalFieldValue = fnCustomCoveoEvaluvateShowMoreJiraLinkGetHtml(data);
                                                            }

                                                            //Value
                                                            var varFieldValueConent = document.createElement('div');
                                                            varFieldValueConent.setAttribute('class', 'data-custom-coveo-field-value data-custom-coveo-field-value-collapsed');
                                                            var varFieldValueSpanValue = document.createElement('span');
                                                            varFieldValueSpanValue.innerHTML = varFinalFieldValue;
                                                            //varFieldValueSpanValue.innerText = varFieldValueSpanValue.innerText.trim();                    
                                                            varFieldValueConent.appendChild(varFieldValueSpanValue);
                                                            //Value


                                                            //Show More
                                                            var varFieldValueShowMore = document.createElement('div');
                                                            varFieldValueShowMore.setAttribute('class', 'data-custom-coveo-field-value');
                                                            var varFieldValueAnchor = document.createElement('a');
                                                            //varFieldValueAnchor.setAttribute('href', 'javascript:void(0);');
                                                            varFieldValueAnchor.addEventListener('click', function () { fnToggleShowMoreShowLess(this); });
                                                            varFieldValueAnchor.setAttribute('style', 'cursor:pointer;height:20px;font-size:12px;');
                                                            varFieldValueAnchor.setAttribute('class', 'CustomCoveoShowMoreLink');
                                                            varFieldValueAnchor.innerHTML = 'Show More';
                                                            varFieldValueShowMore.appendChild(varFieldValueAnchor);
                                                            //Show More


                                                            //Added Value and ShowMore to its parent div
                                                            varFieldValueParent.appendChild(varFieldValueConent);
                                                            varFieldValueParent.appendChild(varFieldValueShowMore);


                                                            //Added this parent div to td
                                                            varFieldValueTDParent.appendChild(varFieldValueParent);

                                                            //Added td and th to its parent tr
                                                            varFieldValueTRParent.appendChild(varFieldValueTHName);
                                                            varFieldValueTRParent.appendChild(varFieldValueTDParent);

                                                            //Added Value and ShowMore as one to its parent div
                                                            varCustomFieldValue[k].parentElement.appendChild(varFieldValueTRParent);

                                                            varCustomFieldValue[k].setAttribute('style', 'display:none');
                                                      }

                                                }
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildShowMoreContent : ' + e.message);
                                    }
                              }

                              function fnBuildCopyURLContent(currentResultItems) {
                                    try {

                                          var varCustomCoveoFieldCopyURL = Coveo.$(currentResultItems).find('[data-custom-onclick=\'fnClickCopyURLToClipboard\']');

                                          for (var j = 0; j < varCustomCoveoFieldCopyURL.length; j++) {
                                                varCustomCoveoFieldCopyURL.addEventListener('click', function () { fnClickCopyURLToClipboard(this); });
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCopyURLContent : ' + e.message);
                                    }
                              }

                              function fnBuildSingleLineContent(currentResultItems) {
                                    try {

                                          var varCustomCoveoFieldTable = Coveo.$(currentResultItems).find('[class=\'CustomCoveoFieldTableSingleLineSection\']');

                                          for (var j = 0; j < varCustomCoveoFieldTable.length; j++) {
                                                //                    varCustomFieldValue[j]

                                                var varCustomFieldValue = Coveo.$(varCustomCoveoFieldTable[j]).find('[data-custom-coveo-field]');

                                                if (varCustomFieldValue.length == 0) {
                                                      varCustomCoveoFieldTable[j].setAttribute('style', 'display:none');
                                                } else {

                                                      for (var k = 0; k < varCustomFieldValue.length; k++) {
                                                            var varFieldValueTRParent = document.createElement('tr');
                                                            varFieldValueTRParent.setAttribute('class', 'CustomCoveoValueRow');

                                                            var varFieldValueTDParent = document.createElement('td');
                                                            var varFieldValueSpanValue = document.createElement('span');
                                                            varFieldValueSpanValue.innerHTML = varCustomFieldValue[k].innerText.trim();
                                                            varFieldValueTDParent.appendChild(varFieldValueSpanValue);

                                                            var varFieldValueTHName = document.createElement('th');
                                                            if (varCustomFieldValue[k].getAttribute('data-custom-coveo-caption') != null)
                                                                  varFieldValueTHName.innerHTML = varCustomFieldValue[k].getAttribute('data-custom-coveo-caption');

                                                            //Added td and th to its parent tr
                                                            varFieldValueTRParent.appendChild(varFieldValueTHName);
                                                            varFieldValueTRParent.appendChild(varFieldValueTDParent);

                                                            //Added Value and ShowMore as one to its parent div
                                                            varCustomFieldValue[k].parentElement.appendChild(varFieldValueTRParent);

                                                            varCustomFieldValue[k].setAttribute('style', 'display:none');
                                                      }

                                                }
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildSingleLineContent : ' + e.message);
                                    }
                              }

                              function fnBuildDetailsContent(currentResultItems) {
                                    try {

                                          var varCustomCoveoFieldTable = Coveo.$(currentResultItems).find('[class=\'CustomCoveoFieldTableDetailsSection\']');

                                          for (var j = 0; j < varCustomCoveoFieldTable.length; j++) {
                                                //                    varCustomFieldValue[j]

                                                var varCustomFieldValue = Coveo.$(varCustomCoveoFieldTable[j]).find('[data-custom-coveo-field]');

                                                if (varCustomFieldValue.length == 0) {
                                                      varCustomCoveoFieldTable[j].setAttribute('style', 'display:none');
                                                } else {
                                                      for (var k = 0; k < varCustomFieldValue.length; k++) {

                                                            var varFieldValueSpanValue = varCustomFieldValue[k].children[0];

                                                            varCustomFieldValue[k].innerHTML = '';

                                                            var varFieldValueTRParent = document.createElement('tr');
                                                            varFieldValueTRParent.setAttribute('class', 'CustomCoveoValueRow');

                                                            var varFieldValueTDParent = document.createElement('td');
                                                            //Value                                                                        
                                                            varFieldValueTDParent.appendChild(varFieldValueSpanValue);
                                                            //Value

                                                            var varFieldValueTHName = document.createElement('th');
                                                            if (varCustomFieldValue[k].getAttribute('data-custom-coveo-caption') != null)
                                                                  varFieldValueTHName.innerHTML = varCustomFieldValue[k].getAttribute('data-custom-coveo-caption');

                                                            //Added td and th to its parent tr
                                                            varCustomFieldValue[k].appendChild(varFieldValueTHName);
                                                            varCustomFieldValue[k].appendChild(varFieldValueTDParent);

                                    
                                                            //                        varCustomFieldValue[k].parentElement.appendChild(varFieldValueTRParent);

                                                            //                        varCustomFieldValue[k].setAttribute('style', 'display:none');
                                                      }
                                                }
                                          }

                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildDetailsContent : ' + e.message);
                                    }
                              }

                              function fnToggleShowMoreShowLess(parCurrentItem) {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnToggleShowMoreShowLess');
                                          if (parCurrentItem.parentElement.parentElement.children[0].className == 'data-custom-coveo-field-value data-custom-coveo-field-value-expanded') {
                                                parCurrentItem.parentElement.parentElement.children[0].className = 'data-custom-coveo-field-value data-custom-coveo-field-value-collapsed'
                                                parCurrentItem.innerHTML = 'Show More';
                                          } else if (parCurrentItem.parentElement.parentElement.children[0].className == 'data-custom-coveo-field-value data-custom-coveo-field-value-collapsed') {
                                                parCurrentItem.parentElement.parentElement.children[0].className = 'data-custom-coveo-field-value data-custom-coveo-field-value-expanded'
                                                parCurrentItem.innerHTML = 'Show Less';
                                                //TAG 01
                                                fnShowMoreClicked(parCurrentItem);
                                                //TAG 01
                                          }

                                    } catch (Ex) {
                                    }
                              }
                              //T03 - Start
                              function fnAssignSearchTokenForAnalytics() {
                                    try {
                                          if (Coveo.$(searchInterfaceID).length > 0) {
                                                if (Coveo.$(searchInterfaceID)[0].CoveoSearchInterface.options.endpoint.accessToken.token != Coveo.$(searchInterfaceID).find('[class=\'CoveoAnalytics\']')[0].CoveoAnalytics.accessToken.token) {
                                                      Coveo.$(searchInterfaceID)[0].CoveoSearchInterface.usageAnalytics.endpoint.endpointCaller.options.accessToken = window[varSearchInstanceId].varSearchToken;
                                                }
                                          }
                                    }
                                    catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnAssignSearchTokenForAnalytics : ' + e.message);
                                    }
                              }
                              //T03 - End

                              function fnCustomCoveoEvaluvateShowMoreKBLinkGetHtml(parResult) {
                                    var infa_resaultstring = '';
                                    try {
                     
                      
                                          var r = parResult.result;
      
                                          if (r.raw.sfcase_kbs__rknowledge__rarticlenumber != undefined) {
                          
                          
                                                var infa_validationstatusarray = r.raw.sfcase_kbs__rknowledge__rvalidationstatus ? r.raw.sfcase_kbs__rknowledge__rvalidationstatus.toLowerCase().split(';') : '';
                                                var infa_publishstatusarray = r.raw.sfcase_kbs__rknowledge__rpublishstatus ? r.raw.sfcase_kbs__rknowledge__rpublishstatus.toLowerCase().split(';') : '';
                                                var infa_urlnamearray = r.raw.sfcase_kbs__rknowledge__rurlname ? r.raw.sfcase_kbs__rknowledge__rurlname.split(';') : '';
                                                var infa_langaugearray = r.raw.sfcase_kbs__rknowledge__rlanguage ? r.raw.sfcase_kbs__rknowledge__rlanguage.split(';') : '';
                                                var infa_articlenumberarray = r.raw.sfcase_kbs__rknowledge__rarticlenumber.split(';');
                            
      
                                                for (var i = 0; i < infa_articlenumberarray.length; ++i) {
                             
                                                      if (infa_articlenumberarray[i] != '') {
                                                            var isInternalSearchEnv = false;
                                                            var varSearchUserFedID = '';
                                                            if (window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier') != undefined) {
                                                                  varSearchUserFedID = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier');
                                                            }
                                                            var infa_validationstatus = infa_validationstatusarray[i];
                                                            var infa_publishstatus = infa_publishstatusarray[i];
                                                            var infa_urlname = infa_urlnamearray[i];
                                                            var infa_langauge = infa_langaugearray[i];
                                                            var infa_articlenumber = infa_articlenumberarray[i];
                                                            var infa_kbclickurl = '';
                            
                                                            var internalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                            var internaldrafturlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                            var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&type=external'
                                                            var externaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&type=external'
                                                            var inernaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                                            var inernaltdraftechnicalreviewurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                
                                                            //IsUserAuthenticated == true means the logged user is not a guest user thus we are on Internal KB page                                    
                                                            // isInternalSearchEnv = window[varSearchInstanceId].IsUserAuthenticated == 'true' && window[varSearchInstanceId].UserType == 'Standard' ?
                                                            //       true : ((infa_permissionType == 'internal' || (infa_permissionType == 'public' && infa_moderationStatus != 0)) ? true : false);
                                                            isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
                
                                                            if (isInternalSearchEnv == true && infa_validationstatus == 'pending technical review') {
                                                                  infa_kbclickurl = inernaltechnicalreviewurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', infa_urlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', infa_langauge);
                                                            }
                                                            else if (isInternalSearchEnv == false && infa_validationstatus == 'pending technical review') {
                                                                  infa_kbclickurl = externaltechnicalreviewurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', infa_urlname).replace('%%LANG%%', infa_langauge);
                                                            }
                                                            else if (isInternalSearchEnv == true && infa_publishstatus == 'draft') {
                                                                  infa_kbclickurl = internaldrafturlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', infa_urlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', infa_langauge);
                                                            }
                                                            else if (isInternalSearchEnv == true) {
                                                                  infa_kbclickurl = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', infa_urlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', infa_langauge);
                                                            }
                                                            else if (isInternalSearchEnv == false) {
                                                                  infa_kbclickurl = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCKBExternalHost).replace('%%KBURLNAME$$', infa_urlname).replace('%%LANG%%', infa_langauge);
                                                            }
          
                                                            if (infa_resaultstring == '') {
                                                                  infa_resaultstring = '<a href="' + infa_kbclickurl + '" target="_blank">' + infa_articlenumber + '</a>';
                                                            }
                                                            else {
                                                                  infa_resaultstring += ', <a href="' + infa_kbclickurl + '" target="_blank">' + infa_articlenumber + '</a>';
                                                            }
      
                                                      }
      
                                                }
      
                              
                                          }
                                              
                     
                                                                                                                                                  
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnCustomCoveoEvaluvateShowMoreKBLinkGetHtml; Error : ' + ex.message + '||' + ex.stack);
                                    }
                                    return infa_resaultstring;
               
                              }
      
                              function fnCustomCoveoEvaluvateShowMoreCaseLinkGetHtml(parResult) {
                                    var infa_resaultstring = '';
                                    try {
      
                                          var r = parResult.result;
      
                                          if (r.raw.sfcase_kbs__rcase__rcasenumber != undefined) {
      
                                                var infa_caseIdarray = r.raw.sfcase_kbs__rcase__c ? r.raw.sfcase_kbs__rcase__c.split(';') : '';
                                                var infa_casenumberarray = r.raw.sfcase_kbs__rcase__rcasenumber ? r.raw.sfcase_kbs__rcase__rcasenumber.split(';') : '';
                                                var infa_resaultstring = '';
                 
                                                for (var i = 0; i < infa_caseIdarray.length; ++i) {
      
                                                      if (infa_caseIdarray[i] != '') {
                                                            var isInternalSearchEnv = false;
      
                                                            var infa_caseclickurl = '';
                                                            var infa_caseId = infa_caseIdarray[i];
                                                            var infa_casenumber = infa_casenumberarray[i];
                         
                                                            isInternalSearchEnv = window[varSearchInstanceId].varSearchHub == 'AthenaKBSearchInternal' || window[varSearchInstanceId].varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                                            var internalurlformat = '/lightning/r/Case/%%CASEID$$/view'
                                                            var externalurlformat = 'https://%%DOMAIN$$' + window[varSearchInstanceId].eSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'
          
                                                            if (isInternalSearchEnv == true) {
                                                                  infa_caseclickurl = internalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASEID$$', infa_caseId);
                                                            }
                                                            else if (isInternalSearchEnv == false) {
                                                                  infa_caseclickurl = externalurlformat.replace('%%DOMAIN$$', window[varSearchInstanceId].SFDCEsupportHost).replace('%%CASEID$$', infa_caseId);
                                                            }
      
                                                            if (infa_resaultstring == '') {
                                                                  infa_resaultstring = '<a href="' + infa_caseclickurl + '" target="_blank">' + infa_casenumber + '</a>';
                                                            }
                                                            else {
                                                                  infa_resaultstring += ', <a href="' + infa_caseclickurl + '" target="_blank">' + infa_casenumber + '</a>';
                                                            }
      
                                                      }
                                                      
                                                }
                                                                                          
                                          }
                                     
                                                                           
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnCustomCoveoEvaluvateShowMoreCaseLinkGetHtml; Error : ' + ex.message + '||' + ex.stack);
                                    }
                                    return infa_resaultstring;
                              }

                              function fnCustomCoveoEvaluvateShowMoreJiraLinkGetHtml(parResult) {
                                    var infa_resaultstring = '';
                                    try {
      
                                          var r = parResult.result;
      
                                          if (r.raw.infajiraname != undefined) {
      
                                                var infa_JiraSFIdarray = r.raw.infajiraname ? r.raw.infajiraname.split(';') : '';
                                                var infa_JiraNamearray = r.raw.infajiraname ? r.raw.infajiraname.split(';') : '';
                                                var infa_resaultstring = '';
                 
                                                for (var i = 0; i < infa_JiraSFIdarray.length; ++i) {
      
                                                      if (infa_JiraSFIdarray[i] != '') {
                                                            var isInternalSearchEnv = false;
      
                                                            var infa_caseclickurl = '';
                                                            var infa_jirasfid = infa_JiraSFIdarray[i];
                                                            var infa_jiraname = infa_JiraNamearray[i];
                         
                                                            isInternalSearchEnv = InfaKBSearchJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                                            var internalurlformat = 'https://infajira.informatica.com/browse/%%JIRASFID$$'
                                                            var externalurlformat = 'https://infajira.informatica.com/browse/%%JIRASFID$$'
          
                                                            if (isInternalSearchEnv == true) {
                                                                  infa_caseclickurl = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%JIRASFID$$', infa_jirasfid);
                                                            }
                                                            else if (isInternalSearchEnv == false) {
                                                                  infa_caseclickurl = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%JIRASFID$$', infa_jirasfid);
                                                            }
      
                                                            if (infa_resaultstring == '') {
                                                                  infa_resaultstring = '<a href="' + infa_caseclickurl + '" target="_blank">' + infa_jiraname + '</a>';
                                                            }
                                                            else {
                                                                  infa_resaultstring += ', <a href="' + infa_caseclickurl + '" target="_blank">' + infa_jiraname + '</a>';
                                                            }
      
                                                      }
                                                      
                                                }
                                                                                          
                                          }
                                     
                                                                           
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnCustomCoveoEvaluvateShowMoreCaseLinkGetHtml; Error : ' + ex.message + '||' + ex.stack);
                                    }
                                    return infa_resaultstring;
                              }

            
     

      
                              /*Search Framework in KB SEARCH Page - End*/
                              /********************************************************************************/



                              //Help link script - start
                              function fnLoadHelpLink() {
                  
                                    varathenaresourcepath = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnStaticResourceAthenaPath');
                                    varhelptexthtmlresourcepath = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('v.hdnStaticResourceAthenaHelpTextHTMLPath');

                                    var varcssresourcepath = fnGetResourcePathCode(varathenaresourcepath);
                                    //New Help link added - <T02> <T03>
                                    var helplinkdropdowncontent = '<div id=\'kbhelppopcontent\' ><a id=\'helplinkone\' href=\'' + varhelptexthtmlresourcepath + '?resourceid=' + varcssresourcepath + '\'  class=\'video-trigger popup-iframe\' >Using Search Operators to Improve Search Results</a></br></div>';
                                    //New Help link added - </T02> </T03>

                                    Coveo.$(searchInterfaceID).find('.anchorhelplink').attr('data-content', helplinkdropdowncontent);
                                    Coveo.$(searchInterfaceID).find('.anchorhelplink').mouseover(function () {
                                          var execCountForHandler = 0;
                                          window.setTimeout(function () { fnAddYouTubePopHandler(execCountForHandler); }, 100);
                                    });
                                    fnToCheckBootStrap(0);
                              }

                              function fnToCheckBootStrap(execCount) {
                                    try {
                                          var present = false;
                                          if (typeof (Coveo.$.fn.popover) != 'undefined') {
                                                present = true;
                                          }


                                          if (present) {

                                                var originalLeave = Coveo.$.fn.popover.Constructor.prototype.leave;
                                                Coveo.$.fn.popover.Constructor.prototype.leave = function (obj) {
                                                      var self = obj instanceof this.constructor ?
                                                            obj : Coveo.$(obj.currentTarget)[this.type](this.getDelegateOptions()).data('bs.' + this.type)
                                                      var container, timeout;

                                                      originalLeave.call(this, obj);

                                                      if (obj.currentTarget) {
                                                            container = Coveo.$(obj.currentTarget).siblings('.popover')
                                                            timeout = self.timeout;
                                                            container.one('mouseenter', function () {
                                                                  //We entered the actual popover - call off the dogs
                                                                  clearTimeout(timeout);
                                                                  //Let's monitor popover content instead
                                                                  container.one('mouseleave', function () {
                                                                        Coveo.$.fn.popover.Constructor.prototype.leave.call(self, self);
                                                                  });
                                                            });
                                                      }

                                                };

                                                Coveo.$(searchInterfaceID).find('.anchorhelplink[data-popover=true]').popover({
                                                      trigger: 'hover',
                                                      placement: 'auto',
                                                      delay: { show: 50, hide: 400 }
                                                });
                                          }

                                          if ((execCount < 0) && (present == false)) {
                                                execCount = execCount + 1;
                                                window.setTimeout(function () { fnToCheckBootStrap(execCount); }, 100);
                                          }
                                    } catch (exThree) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error on fnToCheckBootStrap');
                                    }
                              }

                              function fnAddYouTubePopHandler(execCount) {
                                    try {
                                          var present = false;
                                          for (var i = 0; i < Coveo.$(searchInterfaceID).find('.popup-iframe').length; i++) {
                                                if (Coveo.$(searchInterfaceID).find('.popup-iframe')[i].id == 'helplinkone') {
                                                      present = true;
                                                }
                                          }
                                          if (present) {
                                                Coveo.$(searchInterfaceID).find('.popup-iframe').magnificPopup({
                                                      type: 'iframe'
                                                });
                                          }

                                          if ((execCount < 20) && (present == false)) {
                                                execCount = execCount + 1;
                                                window.setTimeout(function () { fnAddYouTubePopHandler(execCount); }, 1);
                                          }
                                    } catch (exThree) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error on fnAddYouTubePopHandler');
                                    }
                              }

                              function fnGetResourcePathCode(path) {
                                    try {
                                          var splitedpath = path.split('/');
                                          if (splitedpath[2] != 'undefined') {
                                                return splitedpath[2];
                                          }
                                    } catch (exThree) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error on fnGetResourcePathCode');
                                    }
                                    return '';
                              }

                              //Help link script - end
                              // Coveo.$(document).ready(function () {
                              //       fnLoadHelpLink();
                              // });
                              //<TAG O1>
                              /**
                               * Used to capture the coveo analytics on clicking the Additional Field Expansion
                               * @param {Clicked additional Field expand item} parCurrentItem 
                               */

                              function fnShowMoreClicked(parCurrentItem) {
                                    try {
                                          //Details - name,  Type - type, Cause - cause
                                          var element = Coveo.$(searchInterfaceID)[0];
                                          var elements = Coveo.$(parCurrentItem).closest('.CoveoResult').find('.CoveoResultLink');
                                          var docDocIdClicked = '';
                                          var docURLClicked = '';
                                          if (elements.length > 0) {
                                                docDocIdClicked = Coveo.$(parCurrentItem).closest('.CoveoResult')[0].CoveoResult.raw.infadocid;
                                                docURLClicked = Coveo.$(parCurrentItem).closest('.CoveoResult')[0].CoveoResult.raw.clickableuri;
                                                if (docURLClicked == null) {
                                                      docURLClicked = '';
                                                }
                                                if (docDocIdClicked == null) {
                                                      docDocIdClicked = '';
                                                }
                                          }
                                          var customEventCause = { name: docDocIdClicked + ' ' + docURLClicked, type: 'ShowMore' };
                                          var metadata = {
                                          };
                                          Coveo.logCustomEvent(element, customEventCause, metadata);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnShowMoreClicked : ' + ex.message);
                                    }
                              }
                              /**
                               * Used to capture the coveo analytics on clicking CopyURL
                               * @param {Clicked additional Field expand item} parCurrentItem 
                               */
                              function fnCopyURLClicked(parCurrentItem) {
                                    try {
                                          //Details - name,  Type - type, Cause - cause
                                          var element = Coveo.$(searchInterfaceID)[0];
                                          var elements = Coveo.$(parCurrentItem).closest('.CoveoResult').find('.CoveoResultLink');
                                          var docDocIdClicked = '';
                                          var docURLClicked = '';
                                          if (elements.length > 0) {
                                                docDocIdClicked = Coveo.$(parCurrentItem).closest('.CoveoResult')[0].CoveoResult.raw.infadocid;
                                                docURLClicked = Coveo.$(parCurrentItem).closest('.CoveoResult')[0].CoveoResult.raw.clickableuri;
                                                if (docURLClicked == null) {
                                                      docURLClicked = '';
                                                }
                                                if (docDocIdClicked == null) {
                                                      docDocIdClicked = '';
                                                }
                                          }
                                          var customEventCause = { name: docDocIdClicked + ' ' + docURLClicked, type: 'CopyURL' };
                                          var metadata = {
                                          };
                                          Coveo.logCustomEvent(element, customEventCause, metadata);
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnCopyURLClicked : ' + ex.message);
                                    }
                              }
                              //</TAG O1>
                              //TAG 02
                              function fnformatCommaSeperatedNumber(num) {
                                    var varNum = num;
                                    try {
                                          varNum = varNum.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
                                    }
                                    catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnformatCommaSeperatedNumber : ' + ex.message);
                                    }
                                    return varNum;
                              }
                              //TAG 02

                              //Function Related KB Internal Search which work with the Search Aura Component

                              function fnGetSearchToken() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetSearchToken');

                        

                                          var getSearchTokenaction = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.getSearchToken');
                                          getSearchTokenaction.setParams({
                                                strCalledFrom: window[varSearchInstanceId].varCalledFrom
                                          });

                                          getSearchTokenaction.setCallback(this, function (response) {
                                                var result = response.getReturnValue();
                                                try {
                                                      InfaKBCommonUtilityJs.Log('log', 'fnGetSearchToken success');
                                                      var data = JSON.parse(result);
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'Coveo Search Token API Status : ' + data.APIResponseStatus
                                                      );
                                                      InfaKBCommonUtilityJs.Log('log', 'Coveo Search Token API Error : ' + data.ErrorMessage);
                                                      if (data.APIResponseStatus == 'OK') {
                                    
                                                            InfaKBCommonUtilityJs.Log('log', 'Search Token Freshly Retrived');
                                                            fnSetSearchCoreDetails(result);
                                                            if (window[varSearchInstanceId].varSearchUserSessionId != undefined) {
                                                                  InfaKBCommonUtilityJs.fnLocaStorageInsertOrUpdate(window[varSearchInstanceId].varSearchUserSessionId, 'KBContentSearchToken', result);
                                                            }
                                                                        
                                                            varSearchTokenDefferred.resolve(data.APISearchToken);
                                                      } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                            varSearchTokenDefferred.reject(data);
                                                      } else if (data.APIResponseStatus == 'ERROR') {
                                                            varSearchTokenDefferred.reject(data);
                                                      }
                                                } catch (ex) {
                                                      InfaKBCommonUtilityJs.Log('error',
                                                            'SearchPage : Error Occured in Method fnGetSearchToken Inner Catch Message : ' +
                                                            ex.message
                                                      );
                                                }
                                          });
                                          window[varSearchInstanceId].varINFAKBContentSearchControllerAuraFramework.enqueueAction(getSearchTokenaction);
                                          InfaKBCommonUtilityJs.fnRefresh();
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error',
                                                'SearchPage : Error Occured in Method fnGetSearchToken Message : ' +
                                                ex.message
                                          );
                                    }
                                    varSearchTokenDefferred = Coveo.$.Deferred();
                                    return varSearchTokenDefferred;
                              }
    
                              function fnReNewSearchToken() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnReNewSearchToken');
                        

                                          var getSearchTokenaction = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.getSearchToken');
                                          getSearchTokenaction.setParams({
                                                strCalledFrom: window[varSearchInstanceId].varCalledFrom
                                          });
    
                                          getSearchTokenaction.setCallback(this, function (response) {
                                                var result = response.getReturnValue();
                                                try {
                                                      InfaKBCommonUtilityJs.Log('log', 'fnReNewSearchToken success');
                                                      var data = JSON.parse(result);
                                    
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'Coveo Search Token API Status : ' + data.APIResponseStatus
                                                      );
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'Coveo Search RenewToken API Error : ' + data.ErrorMessage
                                                      );
                                                      if (data.APIResponseStatus == 'OK') {
                                  
                                                            InfaKBCommonUtilityJs.Log('log', 'Search Token Renewed');
                                                            fnSetSearchCoreDetails(result);
                                                            if (window[varSearchInstanceId].varSearchUserSessionId != undefined) {
                                                                  InfaKBCommonUtilityJs.fnLocaStorageInsertOrUpdate(window[varSearchInstanceId].varSearchUserSessionId, 'KBContentSearchToken', result);
                                                            }
                                                                                                            
                                                            varRenewSearchTokenDefferred.resolve(data.APISearchToken);
                                                      } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                            varRenewSearchTokenDefferred.reject(data);
                                                      } else if (data.APIResponseStatus == 'ERROR') {
                                                            varRenewSearchTokenDefferred.reject(data);
                                                      }
                                    
                                                } catch (ex) {
                                                      InfaKBCommonUtilityJs.Log('error',
                                                            'SearchPage : Error Occured in Method fnReNewSearchToken Inner Catch Message : ' +
                                                            ex.message
                                                      );
                                                }
                                          });
                                          window[varSearchInstanceId].varINFAKBContentSearchControllerAuraFramework.enqueueAction(getSearchTokenaction);
                                          InfaKBCommonUtilityJs.fnRefresh();
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error',
                                                'SearchPage : Error Occured in Method fnReNewSearchToken Message : ' +
                                                ex.message
                                          );
                                    }
                                    varRenewSearchTokenDefferred = Coveo.$.Deferred();
                                    return varRenewSearchTokenDefferred;
                              }


                              /**
                               * All the Search Realted Data in initialized after getting the token
                               *
                               * @param {*} parJsonString
                               */
                              function fnGetSearchRelatedDataFromJson(parJsonString) {
                                    try {
                                          if (parJsonString != '') {
                                                var data = JSON.parse(parJsonString);
                                                if (data.APIResponseStatus == 'OK') {
                                                      window[varSearchInstanceId].varSearchHub = data.APISearchHub;
                                                      window[varSearchInstanceId].varSearchToken = data.APISearchToken;
                                                      window[varSearchInstanceId].varSearchUserType = data.UserType;
                                                      window[varSearchInstanceId].varSearchUserId = data.UserId;
                                                      window[varSearchInstanceId].IsUserAuthenticated = window[varSearchInstanceId].varSearchUserType == 'Guest' ? 'false' : 'true';
                                                }
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error',
                                                'SearchPage : Error Occured in Method fnGetSearchRelatedDataFromJson Message : ' +
                                                ex.message
                                          );
                                    }
                              }
    
                              function fnGetFilterOnLoad() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetFilterOnLoad');
                                   
                                          var action = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.getUserFilter');
                            
                                          action.setCallback(this, function (response) {
                                                var result = response.getReturnValue();
                                                try {
                                                      InfaKBCommonUtilityJs.Log('log', 'fnGetFilterOnLoad success');
                                                      // response = Coveo.$(searchInterfaceID).find('<div>').html(response)[0].innerText;
                                                      var data = jQuery.parseJSON(result);
    
                                   
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'SearchPage Personalization : ' + data.APIResponseStatus
                                                      );
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'SearchPage Personalization : ' + data.ErrorMessage
                                                      );
    
                                                      if (data.APIResponseStatus == 'OK') {
                                                            if (data.groupByResults != null) {
                                                                  window[varSearchInstanceId].varUserFilterString = JSON.stringify(data.groupByResults);
                                                                  varUserFilterValueOnLoadDefferred.resolve(
                                                                        data.groupByResults
                                                                  );
                                                            } else {
                                                                  InfaKBCommonUtilityJs.Log('log',
                                                                        'fnGetFilterOnLoad success : No User Filter avaialble'
                                                                  );
                                                            }
                                                      } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                            varUserFilterValueOnLoadDefferred.reject(
                                                                  data.APIResponseData
                                                            );
                                                      } else if (data.APIResponseStatus == 'ERROR') {
                                                            varUserFilterValueOnLoadDefferred.reject(
                                                                  data.APIResponseData
                                                            );
                                                      }
                                   
                                                } catch (ex) {
                                                      var obj = { error: ex };
                                                      InfaKBCommonUtilityJs.Log('error',
                                                            'SearchPage : Error Occured in Method fnGetFilterOnLoad Inner Catch Message : ' +
                                                            obj
                                                      );
                                                      varUserFilterValueOnLoadDefferred.reject(obj);
                                                }
                                          }
                                          );
                                          InfaKBSearchJs.varINFAKBContentSearchControllerAuraFramework.enqueueAction(action);
                                          InfaKBCommonUtilityJs.fnRefresh();
                                    } catch (e) {
                                          InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnGetFilterOnLoad : ' + e.message);
                                    }
                                    varUserFilterValueOnLoadDefferred = Coveo.$.Deferred();
                                    return varUserFilterValueOnLoadDefferred;
                              }
    
                              function fnGetRecentContentCoveoSearch() {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch');
                                      
                                          var varstrSearchToken = window[varSearchInstanceId].varSearchToken;
               
                        
                                          var action = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.getSearchResultRecenttData');
                                          action.setParams({
                                                strSearchToken: varstrSearchToken
                                          });
                      
                                          action.setCallback(this, function (response) {
                                                var result = response.getReturnValue();
                                                try {
                                                      InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch success');
                                                      var data = JSON.parse(result);
    
                                                      Coveo.$(data).each(function (index, topitem) {
                                                            InfaKBCommonUtilityJs.Log('log',
                                                                  'fnGetRecentContentCoveoSearch Status : ' +
                                                                  topitem.APIResponseStatus
                                                            );
                                                            InfaKBCommonUtilityJs.Log('log',
                                                                  'fnGetRecentContentCoveoSearch Error : ' + topitem.ErrorMessage
                                                            );
    
                                                            if (data.APIResponseStatus == 'OK') {
                                                                  window[varSearchInstanceId].varRecentContentValueObject = null;
                                                                  if (topitem.searchDataList != null) {
                                                                        window[varSearchInstanceId].varRecentContentValueObject = [];
                                                                        Coveo.$(topitem.searchDataList).each(function (
                                                                              childindex,
                                                                              childitem
                                                                        ) {
                                                                              window[varSearchInstanceId].varRecentContentValueObject.push(childitem.infadocid);
                                                                        });
                                                                  }
                                                                  varRecentContentValueDefferred.resolve(
                                                                        window[varSearchInstanceId].varRecentContentValueObject
                                                                  );
                                                            } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                                  varRecentContentValueDefferred.reject(topitem.groupByResults);
                                                            } else if (data.APIResponseStatus == 'ERROR') {
                                                                  varRecentContentValueDefferred.reject(data);
                                                            }
                                                      });
                                                } catch (ex) {
                                                      var obj = { error: ex };
                                                      InfaKBCommonUtilityJs.Log('error',
                                                            'SearchPage : Error Occured in Method fnGetRecentContentCoveoSearch Inner Catch Message : ' +
                                                            obj
                                                      );
                                                      varRecentContentValueDefferred.reject(ex);
                                                }
                                          }
                                          );
                        
                                          window[varSearchInstanceId].varINFAKBContentSearchControllerAuraFramework.enqueueAction(action);
                                          InfaKBCommonUtilityJs.fnRefresh();
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error',
                                                'SearchPage : Error Occured in Method fnGetRecentContentCoveoSearch Message : ' +
                                                ex.message
                                          );
                                    }
                                    varRecentContentValueDefferred = Coveo.$.Deferred();
                                    return varRecentContentValueDefferred;
                              }
           
                              function fnGetRecentContentFromJson(parResult) {
                                    try {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentFromJson');
                                          try {
                                                InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentFromJson success');
                                                var data = JSON.parse(parResult);

                                                Coveo.$(data).each(function (index, topitem) {
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'fnGetRecentContentFromJson Status : ' +
                                                            topitem.APIResponseStatus
                                                      );
                                                      InfaKBCommonUtilityJs.Log('log',
                                                            'fnGetRecentContentFromJson Error : ' + topitem.ErrorMessage
                                                      );

                                                      if (data.APIResponseStatus == 'OK') {
                                                            window[varSearchInstanceId].varRecentContentValueObject = null;
                                                            if (topitem.searchDataList != null) {
                                                                  window[varSearchInstanceId].varRecentContentValueObject = [];
                                                                  Coveo.$(topitem.searchDataList).each(function (
                                                                        childindex,
                                                                        childitem
                                                                  ) {
                                                                        window[varSearchInstanceId].varRecentContentValueObject.push(childitem.infadocid);
                                                                  });
                                                            }
                                        
                                                      } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                                            window[varSearchInstanceId].varRecentContentValueObject = null;
                                                      } else if (data.APIResponseStatus == 'ERROR') {
                                                            window[varSearchInstanceId].varRecentContentValueObject = null;
                                                      }
                                                });
                                          } catch (ex) {
                                                var obj = { error: ex };
                                                InfaKBCommonUtilityJs.Log('error',
                                                      'SearchPage : Error Occured in Method fnGetRecentContentFromJson Inner Catch Message : ' +
                                                      obj
                                                );
                                                window[varSearchInstanceId].varRecentContentValueObject = null;
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error',
                                                'SearchPage : Error Occured in Method fnGetRecentContentFromJson Message : ' +
                                                ex.message
                                          );
                                    }
                                    window[varSearchInstanceId].varIsCoveoRecentContentRetrived = true;
                              }

                              //Tag 6//URL will Change
                              function fnSetFilterInSessionData() {                                    
                                    try {
                                          if ((window[varSearchInstanceId].varCalledFrom == CONTENTSEARCH) && Coveo.$(searchInterfaceID)[0] != undefined) {                                               
                                                var mysessionStorageforfilter = window.sessionStorage;                                          
                                                mysessionStorageforfilter.setItem(varsscontentsearchfilteronrefresh, document.location.hash);    
                                          }                                                                           
                                    } catch (err) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnSetFilterInSessionData : ' + err.message);
                                    }                                    
                              }

                              function fnGetFilterInSessionData() {
                                    var varResultFilter = ''
                                    try {
                                          var mysessionStorageforfilter = window.sessionStorage;                                          
                                          var mysessionStoragefilterData = mysessionStorageforfilter.getItem(varsscontentsearchfilteronrefresh);
                                         
                                          if (mysessionStoragefilterData == undefined || mysessionStoragefilterData == null || mysessionStoragefilterData == '') {                                                                                                                                                                                    
                                                varResultFilter = '';
                                          }
                                          else
                                          {
                                                varResultFilter = mysessionStoragefilterData;
                                          }
                                          
                                    } catch (err) {
                                          InfaKBCommonUtilityJs.Log('error', 'fnGetFilterInSessionData : ' + err.message);
                                    }
                                    return varResultFilter;
                              }
                              //Tag 6//URL will Change

                              // function fnGetCurrentUserDetails() {
            
                              //       var action = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.getCurrentUsersDetails');

                              //       action.setCallback(this, function (response) {
                              //             var result = response.getReturnValue();
                              //             InfaKBCommonUtilityJs.Log('log','getCurrentUsersDetails : ' + result);
                              //             if (result != undefined) {
                              //                   window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.set('v.currentUsersDetails', result);
                              //             } else {
                              //                   var varDefaultValue =
                              //                         '{'FirstName':'','UserId':'','UserName':'','UserType':'Guest','Email':'','SessionId':''}';
                              //                   window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.set('v.currentUsersDetails', JSON.parse(varDefaultValue));
                              //             }
                              //             var vardoAfterUserInfoLoaded = window[varSearchInstanceId].varINFAKBContentSearchControllerComponent.get('c.fnGetSearchToken');
                              //             window[varSearchInstanceId].varINFAKBContentSearchControllerAuraFramework.enqueueAction(vardoAfterUserInfoLoaded);
                              //InfaKBCommonUtilityJs.fnRefresh();
                              //       });
                              //       window[varSearchInstanceId].varINFAKBContentSearchControllerAuraFramework.enqueueAction(action);
                              //InfaKBCommonUtilityJs.fnRefresh();
                              // }
      
                              function fnLoadSearchTemplate() {
                                    try {
                                          if (window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ESUPPORTGLOBALSEARCH) {
                                                document.querySelector('.KBContentSearchExternalTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchInternalTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalFacet' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchInternalFacet' + parId).innerHTML = '';
                                                fnLoadESupportSearchTemplate();
                                          }
                                          else if (window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ATHENAKBSEARCHINTERNAL || window[varSearchInstanceId].varSearchHub == window[varSearchInstanceId].ATHENAPANELFORCASES) {
                                                document.querySelector('.KBContentSearchExternalTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalForeSupportTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalFacet' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalForeSupportFacet' + parId).innerHTML = '';
                                                fnLoadInternalSearchTemplate();
                                          }
                                          else {
                                                document.querySelector('.KBContentSearchInternalTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalForeSupportTemplate' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchInternalFacet' + parId).innerHTML = '';
                                                document.querySelector('.KBContentSearchExternalForeSupportFacet' + parId).innerHTML = '';
                                                fnLoadExternalSearchTemplate();
                                          }
                                         
                                          varIsSearchResultTemplateRetrived = true;
                                          varIsNoSearchResultTemplateRetrived = true;
                  
  
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnGetKBHtmlContentFile :' + ex.message);
                                    }
                              }

                              function fnLoadInternalSearchTemplate() {
                                    try {
                                          //For Internal Users    
                                          if (document.querySelector('.KBContentSearchInternalTemplate' + parId) != null) {
                                                Coveo.TemplateCache.registerTemplate('SalesforceCase', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceCase').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Case'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Chatter', Coveo.HtmlTemplate.fromString(document.querySelector('.Chatter').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceAccount', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceAccount').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Account'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceContact', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceContact').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Contact'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('LearningPath', Coveo.HtmlTemplate.fromString(document.querySelector('.LearningPath').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Learning Paths'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Expert', Coveo.HtmlTemplate.fromString(document.querySelector('.Expert').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Expert Assistant'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Velocity', Coveo.HtmlTemplate.fromString(document.querySelector('.Velocity').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Velocity'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SupportVideo', Coveo.HtmlTemplate.fromString(document.querySelector('.SupportVideo').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['insupportvideos','SupportVideo'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProdDocs', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Documentation', 'H2L', 'PAMEOL'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('DocPortal', Coveo.HtmlTemplate.fromString(document.querySelector('.DocPortal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['DocPortal'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBInternal', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBInternal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Internal'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBDraft', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBDraft').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['1', '2', '3', '4'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBPublic', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBPublic').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['0'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Jive', Coveo.HtmlTemplate.fromString(document.querySelector('.Jive').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Jive','UserFeed','CollaborationGroupFeed', 'Event', 'Idea'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Cases', Coveo.HtmlTemplate.fromString(document.querySelector('.Cases').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Cases'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Bugs', Coveo.HtmlTemplate.fromString(document.querySelector('.Bugs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'athenatabname', 'values': ['Product Bugs'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Default', Coveo.HtmlTemplate.fromString(document.querySelector('.Default').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('CaseComment', Coveo.HtmlTemplate.fromString(document.querySelector('.CaseComment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('FeedComment', Coveo.HtmlTemplate.fromString(document.querySelector('.FeedComment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProdDocsAttachment', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocsAttachment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProductDocChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.ProductDocChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('JiveChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.JiveChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('CaseCommentC', Coveo.HtmlTemplate.fromString(document.querySelector('.CaseCommentC').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('CoveoCustomNoResults', Coveo.HtmlTemplate.fromString(document.querySelector('.CoveoCustomNoResults').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                //document.querySelector('.CustomTemplateForCoveo').innerHTML = '';
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnLoadInternalSearchTemplate :' + ex.message);
                                    }
                              }

                              function fnLoadExternalSearchTemplate() {
                                    try {
                                          //For External Users
                                          if (document.querySelector('.KBContentSearchExternalTemplate' + parId) != null) {
                                                Coveo.TemplateCache.registerTemplate('ChangeRequest', Coveo.HtmlTemplate.fromString(document.querySelector('.ChangeRequest').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['ChangeRequest'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('LearningPath', Coveo.HtmlTemplate.fromString(document.querySelector('.LearningPath').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Learning Paths'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Expert', Coveo.HtmlTemplate.fromString(document.querySelector('.Expert').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Expert Assistant'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Velocity', Coveo.HtmlTemplate.fromString(document.querySelector('.Velocity').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Velocity'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SupportVideo', Coveo.HtmlTemplate.fromString(document.querySelector('.SupportVideo').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['insupportvideos','SupportVideo'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProdDocs', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Documentation', 'H2L', 'PAMEOL'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('DocPortal', Coveo.HtmlTemplate.fromString(document.querySelector('.DocPortal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['DocPortal'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBInternal', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBInternal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Internal'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBDraft', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBDraft').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['1', '2', '3', '4'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceKBPublic', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBPublic').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['0'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Jive', Coveo.HtmlTemplate.fromString(document.querySelector('.Jive').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Jive','UserFeed','CollaborationGroupFeed', 'Event', 'Idea', 'Blog'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Trainings', Coveo.HtmlTemplate.fromString(document.querySelector('.Trainings').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Trainings'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Default', Coveo.HtmlTemplate.fromString(document.querySelector('.Default').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProdDocsAttachment', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocsAttachment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('ProductDocChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.ProductDocChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('TrainingsChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.TrainingsChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('JiveChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.JiveChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('CoveoCustomNoResults', Coveo.HtmlTemplate.fromString(document.querySelector('.CoveoCustomNoResults').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                //document.querySelector('.CustomTemplateForCoveo').innerHTML = '';
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnLoadExternalSearchTemplate :' + ex.message);
                                    }
                              }

                              function fnLoadESupportSearchTemplate() {
                                    try {
                                          //For Esupport Users                            
                                          if (document.querySelector('.KBContentSearchExternalForeSupportTemplate' + parId) != null) {
                                                Coveo.TemplateCache.registerTemplate('SalesforceCase', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceCase').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Case'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceAccount', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceAccount').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Account'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('SalesforceContact', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceContact').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['Contact'] }], 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('Default', Coveo.HtmlTemplate.fromString(document.querySelector('.Default').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                Coveo.TemplateCache.registerTemplate('CoveoCustomNoResults', Coveo.HtmlTemplate.fromString(document.querySelector('.CoveoCustomNoResults').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                                                //document.querySelector('.CustomTemplateForCoveo').innerHTML = '';
                                          }
                                    } catch (ex) {
                                          InfaKBCommonUtilityJs.Log('error', 'Method : fnLoadESupportSearchTemplate :' + ex.message);
                                    }
                              }

                              function fnSetCoveoSearchInterface(parCoveoSearchInterface) {
                                    varCoveoSearchInterface = parCoveoSearchInterface.firstElementChild;
                              }

                 
                              var InfaKBSearchJs = {
          
                                    'fnHookCustomEventHandlerToCoveoSearchFramwwork': fnHookCustomEventHandlerToCoveoSearchFramwwork,

                                    'fnHookCustomEventHandlerToCoveoSearchFramwworkWhenNoToken': fnHookCustomEventHandlerToCoveoSearchFramwworkWhenNoToken,

                                    'fnDecideAndGetSearchToken': fnDecideAndGetSearchToken,

                                    'varSearchOrgName': varSearchOrgName,

                                    'varSearchFacetValueDefferred': varSearchFacetValueDefferred,
      
                                    'varUserFilterValueOnSaveDefferred': varUserFilterValueOnSaveDefferred,
      
                                    'varSearchFacetValueObject': varSearchFacetValueObject,
      
                                    'varRecentContentValueObject': varRecentContentValueObject,
      
                                    'varQueryURLBuildFromString': varQueryURLBuildFromString,
      
                                    'varQueryURLBasedOnCondition': varQueryURLBasedOnCondition,
      
                                    'varIsAllRequiredContentAvailable': varIsAllRequiredContentAvailable,
      
                                    'varIsCustomEventHandlerHookedToCoveoFramework': varIsCustomEventHandlerHookedToCoveoFramework,
      
                                    'varIsCustomFilterEventHandlerHookedToCoveoFramework': varIsCustomFilterEventHandlerHookedToCoveoFramework,
      
                                    'varIsCoveoSearchTokenRetrived': varIsCoveoSearchTokenRetrived,
      
                                    'varIsCoveoRecentContentRetrived': varIsCoveoRecentContentRetrived,
      
                                    'varIsCoveoUserFilterRetrived': varIsCoveoUserFilterRetrived,
      
                                    'varSearchUserEmail': varSearchUserEmail,
      
                                    'varSearchUserId': varSearchUserId,

                                    'varSearchUserType': varSearchUserType,
            
                                    'varSearchUserSessionId': varSearchUserSessionId,

                                    'varSearchToken': varSearchToken,

                                    'varSearchHub': varSearchHub,

                                    'SFDCKBInternalHost': SFDCKBInternalHost,
            
                                    'SFDCKBExternalHost': SFDCKBExternalHost,

                                    'SFDCEsupportHost': SFDCEsupportHost,
            
                                    'KBCommunityNameInURL': KBCommunityNameInURL,
            
                                    'eSupportCommunityNameInURL': eSupportCommunityNameInURL,
            
                                    'IsUserAuthenticated': IsUserAuthenticated,

                                    'endpointURI': endpointURI,

                                    'varRandomNumber': varRandomNumber,

                                    'varCalledFrom': varCalledFrom,

                                    'ESUPPORTSEARCH': ESUPPORTSEARCH,

                                    'CONTENTSEARCH': CONTENTSEARCH,

                                    'ATHENAKBSEARCHINTERNAL': ATHENAKBSEARCHINTERNAL,

                                    'ATHENAPANELFORCASES': ATHENAPANELFORCASES,

                                    'ESUPPORTGLOBALSEARCH': ESUPPORTGLOBALSEARCH,

                                    'varObjectDataFromURL': varObjectDataFromURL,

                                    'varSearchTokenResponseJSON': varSearchTokenResponseJSON,
                  
                                    'varUserFilterString': varUserFilterString,
                  
                                    'searchInterfaceID': searchInterfaceID,
                                                            
                                    'varINFAKBContentSearchControllerComponent': varINFAKBContentSearchControllerComponent,

                                    'varINFAKBContentSearchControllerEvent': varINFAKBContentSearchControllerEvent,

                                    'varINFAKBContentSearchControllerHelper': varINFAKBContentSearchControllerHelper,
            
                                    'varINFAKBContentSearchControllerAuraFramework': varINFAKBContentSearchControllerAuraFramework,

                                    'fnSetCoveoSearchInterface': fnSetCoveoSearchInterface,

                                    'fnToggleInProgressAnimation': fnToggleInProgressAnimation,

                                    'fnSetGlobalVariables': fnSetGlobalVariables,

                                    'fnSetSearchCoreDetails': fnSetSearchCoreDetails,
                  
                                    'fnLoadSearchCoreDetails': fnLoadSearchCoreDetails,
                  
                                    'fnConfigureAllSearchRelatedItems': fnConfigureAllSearchRelatedItems,

                                    'fnClickCopyURLToClipboard': fnClickCopyURLToClipboard,
                  
                                    'fnInitializeCopyEvent': fnInitializeCopyEvent,

                                    'fnSetFilterInSessionData': fnSetFilterInSessionData,//Tag 6//

                                    'fnGetFilterInSessionData' : fnGetFilterInSessionData //Tag 6//
            
        
                              };
      
                              w[varSearchInstanceId] = InfaKBSearchJs;
                              // w["window[varSearchInstanceId]" + varRandomNumber] = window[varSearchInstanceId];
                        } catch (error) {
                              console.error('error', 'InfaKBSearchJs' + parId + ' onInit : ' + error.message);
                        }
   
      

                  })(win);

            }

            var InfaKBSearchScriptLoad = {
                  'fnInfaKBSearchScriptLoad': fnInfaKBSearchScriptLoad
            }
                   
            win.InfaKBSearchScriptLoad = InfaKBSearchScriptLoad;
            
      } catch (error) {
            console.error('error', 'InfaKBSearchScriptLoad onInit : ' + error.message);
      }

})(window);
