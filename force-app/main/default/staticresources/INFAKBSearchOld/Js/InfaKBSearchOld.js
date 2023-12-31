
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
 |     2      |  03-Sep-2023      |   Sathish R               |    I2RT-9005      |   Customer not able to do search in KB Search Page.
 |     3      |  10-Nov-2023      |   Sathish R               |    I2RT-9499      |   Customer facing "Something went wrong" issue every few hours in search
 ****************************************************************************************************
 */

(function (w) {

      try {
            
            // Below JS global variables are used in ajax calls
            // and getting search token for Coveo Js framework
            // and getting recent result from Coveo and getting
            // product filter for the user
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

            var varSearchTokenValidity = '240';//T03

            var varRefreshCount = '0';//T03
      
            var varSearchToken = '';
      
            var varSearchHub = '';

            var varINFAKBContentSearchOldControllerComponent = undefined;

            var varINFAKBContentSearchOldControllerEvent = undefined;

            var varINFAKBContentSearchOldControllerHelper = undefined;

            var varINFAKBContentSearchOldControllerAuraFramework = undefined;

            var varCoveoSearchInterface = undefined;

            var varSearchTokenDefferred;

            var varRenewSearchTokenDefferred;

            var varUserFilterValueOnLoadDefferred;

            var varRecentContentValueDefferred;

            var varathenaresourcepath;

            var varhelptexthtmlresourcepath;

            var searchInterfaceID = '#searchinfakbcs';
                        
            var searchInterfaceElement = [document.querySelector(searchInterfaceID)];

            var searchInterfaceCoveoResultList = document.querySelector('.CoveoResultList')

            var SFDCKBInternalHost = ''

            var SFDCKBExternalHost = ''

            var KBCommunityNameInURL = ''

            var eSupportCommunityNameInURL = ''

            var varSearchUserType = ''

            var varSearchUserFirstName = ''

            var IsUserAuthenticated = 'false';

            var endpointURI = 'https://platform.cloud.coveo.com/rest/search';
      
            var varSearchTokenResponseJSON = '';
            
            var varRandomNumber = '10000000000';

            var varCalledFrom = '';

            var varUserFilterString = '';

            var varIsThisKBExternal = false;

            var ESUPPORTSEARCH = 'esupportsearch';

            var CONTENTSEARCH = 'contentsearch';

            var KBSEARCH = 'kbsearch';
            var KBSEARCHOLD = 'kbsearchold';

            var INSEARCHNEW = 'infanetworksearch';

            var ATHENAKBSEARCHINTERNAL = 'AthenaKBSearchInternal'

            var ATHENAPANELFORCASES = 'AthenaPanelForCases'

            var ESUPPORTGLOBALSEARCH = 'eSupportGlobalSearch' 

            var varRandomNumberForSnippet = '10000000000';
            
                
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
                  ['Knowledge Base', '@sysdate', 'KB'],
                  ['Product Docs', '@athenatabname', 'ProdDocs'],
                  ['Product Docs', '@athenaproduct', 'ProdDocs'],
                  ['Product Docs', '@athenaproductversion', 'ProdDocs'],
                  ['Product Docs', '@booktitle', 'ProdDocs'],
                  ['Product Docs', '@productlanguage', 'ProdDocs'],
                  ['Product Docs', '@sysdate', 'ProdDocs'],
                  ['How-to Library', '@athenatabname', 'HowTo'],
                  ['How-to Library', '@athenaproduct', 'HowTo'],
                  ['How-to Library', '@athenaproductversion', 'HowTo'],
                  ['How-to Library', '@booktitle', 'HowTo'],
                  ['How-to Library', '@sysdate', 'HowTo'],
                  ['Discussion & Blogs', '@athenatabname', 'Blog'],
                  ['Discussion & Blogs', '@athenaproduct', 'Blog'],
                  ['Discussion & Blogs', '@csitemtype', 'Blog'],
                  ['Discussion & Blogs', '@jivestatus', 'Blog'],
                  ['Discussion & Blogs', '@group', 'Blog'],
                  ['Discussion & Blogs', '@jivecategories', 'Blog'],
                  ['Discussion & Blogs', '@author', 'Blog'],
                  ['Discussion & Blogs', '@sysdate', 'Blog'],
                  ['Discussion & Blogs', '@incontenttype', 'Blog'],
                  ['Discussion & Blogs', '@ingroups', 'Blog'],
                  ['Informatica University', '@athenatabname', 'Trainings'],
                  ['Informatica University', '@trainingroles', 'Trainings'],
                  ['Informatica University', '@sysdate', 'Trainings'],
                  ['Support Video', '@athenatabname', 'SupportVideo'],
                  ['Support Video', '@athenaproduct', 'SupportVideo'],
                  ['Support Video', '@jivecategories', 'SupportVideo'],
                  ['Support Video', '@sysdate', 'SupportVideo'],
                  ['Success Accelerators', '@athenatabname', 'SuccessAccelerators'],
                  ['Success Accelerators', '@engagementcategory', 'SuccessAccelerators'],
                  ['Success Accelerators', '@athenaproduct', 'SuccessAccelerators'],
                  ['Success Accelerators', '@engagementtype', 'SuccessAccelerators'],
                  ['Success Accelerators', '@engagementadoptionstage', 'SuccessAccelerators'],
                  ['Success Accelerators', '@engagementfocusarea', 'SuccessAccelerators'],
                  ['Success Accelerators', '@engagementusecasetags', 'SuccessAccelerators'],
                  ['Success Accelerators', '@sysdate', 'SuccessAccelerators'],
                  ['Learning Path', '@athenatabname', 'Expert'],
                  ['Learning Path', '@athenaproduct', 'Expert'],
                  ['Learning Path', '@infacontenttype', 'Expert'],
                  ['Learning Path', '@sysdate', 'Expert'],
                  ['PAM & EoL', '@athenatabname', 'PAM'],
                  ['PAM & EoL', '@athenaproduct', 'PAM'],
                  ['PAM & EoL', '@athenaproductversion', 'PAM'],
                  ['PAM & EoL', '@athenahotfix', 'PAM'],
                  ['PAM & EoL', '@athenacategory', 'PAM'],
                  ['PAM & EoL', '@sysdate', 'PAM'],
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
                  ['Product Bugs', '@sysdate', 'Bugs'],
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
                  ['Change Request', '@athenatabname', 'CR'],
                  ['Change Request', '@athenaproduct', 'CR'],
                  ['Change Request', '@sysdate', 'CR']
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
                  ['Knowledge Base', '@athenatemplate', 'KB'],
                  ['Knowledge Base', '@infapermissiontype', 'KB'],
                  ['Knowledge Base', '@athenaauthor', 'KB'],
                  ['Knowledge Base', '@athenaDate', 'KB'],
                  ['Product Docs', '@athenatabname', 'ProdDocs'],
                  ['Product Docs', '@athenaproduct', 'ProdDocs'],
                  ['Product Docs', '@athenaproductversion', 'ProdDocs'],
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
                  ['Learning Path', '@athenatabname', 'Expert'],
                  ['Learning Path', '@athenaproduct', 'Expert'],
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
                  ['Cases', '@sfownername', 'Cases'],
                  ['Cases', '@sfcasestatus', 'Cases'],
                  ['Cases', '@sfcreateddate', 'Cases'],
            ];
         
            /**
              * This function used to attached the event handler for the custom filter InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.
              */
            function fnHookCustomFilterMethodToEvent() {
                  try {
                        

                                        
                       

                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : fnHookCustomFilterMethodToEvent; Error :' + ex.message);
                  }
            }
            //Tag - 2
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
	      //Tag - 2

            // function fnInitialiseVariables() {
            //       try {
            //             varRandomNumber = (Math.floor(Math.random() * 10000) + 1).toString();
            //       } catch (ex) {
            //             InfaKBCommonUtilityJs.Log('error', 'Method : fnInitialiseVariables; Error :' + ex.message);
            //       }
            // }
            // fnInitialiseVariables();


            /**
             * Function used to decide the facet appearance, based on the content type selected. 
             * Even the collection of facet is also decided on the searchhib name.
             * This will make sure only the required faced is available in the UI
             * @param {Contains the value of the selected content type} parCurrentSelectedContentType
             */
      
            function fnToggleCoveoFacet(parCurrentSelectedContentType) {
                  try {

                        var varAllContentTypeName = ['AllContent'];

                        var varFacetForParticularTab = InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAKBSEARCHINTERNAL || InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAPANELFORCASES ? COVEO_FACET_MAPPING_FOR_INTERNAL.filter(function (x) {
                              if (x != undefined && x[0] != undefined) {
                                    return parCurrentSelectedContentType.contains(x[0]);
                              } else {
                                    return false;
                              }

                        }) : (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ESUPPORTGLOBALSEARCH ? COVEO_FACET_MAPPING_FOR_ESUPPORT_SEARCH.filter(function (x) {
                              if (x != undefined && x[0] != undefined) {
                                    return parCurrentSelectedContentType.contains(x[0]);
                              } else {
                                    return false;
                              }

                        }) : COVEO_FACET_MAPPING_FOR_EXTERNAL.filter(function (x) {
                              if (x != undefined && x[0] != undefined) {
                                    return parCurrentSelectedContentType.contains(x[0]);
                              } else {
                                    return false;
                              }

                        }));

                        if (Coveo.$('[class^=\'CoveoFacet\']').length != 0) {
                              var varAllFacet = Coveo.$('[class^=\'CoveoFacet\']');
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

           
            function fnHookCustomFilterEventHandler(data) {
                  try {
                        // //Assign event to capture the filter selection
                        // if (Coveo.$('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').length != 0) {
                        //       Coveo.$('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').unbind('change', fnReBuildFacetBasedOnContentTypeFacetHandler);
                        //       Coveo.$('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').bind('change', fnReBuildFacetBasedOnContentTypeFacetHandler);
                        // }

                        // if (Coveo.$('[class^='fa fa-chain'][data-html='true']').length != 0) {

                        //       Coveo.$('[class^='fa fa-chain'][data-html='true']').popover({
                        //             placement: 'auto',
                        //             trigger: 'click hover',
                        //             delay: { show: 50, hide: 400 }
                        //       });
                        //       Coveo.$('[class^='fa fa-chain'][data-html='true']').popover('disable');
                        //       Coveo.$('[class^='fa fa-chain'][data-html='true']').attr('title', $('[class^='fa fa-chain'][data-html='true']').attr('data-custom-tooltiptext'));
                        // }

                        // if (/(\bpdf\b|\bxls\b|\btxt\b|\bhtml\b|\bzip\b|\bxml\b|\bcs\w+\b)/i.test(data.result.raw.sysfiletype)) {
                        //       Coveo.$(data.item).find('.CoveoIcon').removeClass('coveo-icon');
                        //   }
                  
                        //   if (data.result.raw.sysfiletype === 'html') {
                        //       Coveo.$(data.item).find('.CoveoQuickview').hide();
                        //   }
                  
                        //   Coveo.$(data.item).find('.CoveoIcon').addClass(data.result.raw.infadocumenttype ? data.result.raw.infadocumenttype : '');


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

                        if (Coveo.$('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']').length != 0) {

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

                        // $(varimgCopyUrl).attr('disabled', 'disabled');

                        // $(varimgCopyUrl).attr('title', '');
                        // $(varimgCopyUrl).attr('data-popover', 'true');

                        var textArea = document.createElement('textarea');
                        textArea.style.position = 'fixed';
                        textArea.style.top = 0;
                        textArea.style.left = 0;
                        textArea.style.width = '2em';
                        textArea.style.height = '2em';
                        textArea.style.padding = 0;
                        textArea.style.border = 'none';
                        textArea.style.outline = 'none';
                        textArea.style.boxShadow = 'none';
                        textArea.style.background = 'transparent';
                        textArea.value = varCurrentItemURL;
                        document.body.appendChild(textArea);
                        textArea.select();
                        try {
                              var successful = document.execCommand('copy');
                              var msg = successful ? 'successful' : 'unsuccessful';
                              InfaKBCommonUtilityJs.Log('log', 'Copying text command was ' + msg);

                              $(varimgCopyUrl).attr('title', '');
                              $(varimgCopyUrl).popover('enable');
                              $(varimgCopyUrl).popover('show');


                              setTimeout(function () { fnRestoreCopyURLToolTip(varimgCopyUrl); }, 2000);

                        } catch (err) {
                              InfaKBCommonUtilityJs.Log('error', 'Oops, unable to copy');
                        }
                        document.body.removeChild(textArea);

                        //TAG 01
                        fnCopyURLClicked(parCurrentItem);
                        //TAG 01
                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Method fnClickCopyURLToClipboard Error : ' + e.message);
                  }
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

               
                       
                        if (Coveo.$ != undefined) {
                              Coveo.$(document).ready(function () {
                                    InfaKBCommonUtilityJs.Log('log', 'fnDecideAndGetSearchToken On Coveo.$(document)');
                                    fnToBeCalledOnDocumentReady();

                              });
                        }
                        else {
                              $(document).ready(function () {
                                    InfaKBCommonUtilityJs.Log('log', 'fnDecideAndGetSearchToken On $(document)');
                                    fnToBeCalledOnDocumentReady();

                              });
                        }


                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'fnDecideAndGetSearchToken : Error Occured in Method fnDecideAndGetSearchToken Error : ' + ex.message);
                  }
            }

            function fnToBeCalledOnDocumentReady() {
                  try {
                        //fnSetCoveoContext();
                              
                        InfaKBContentVisitedFeatureJs.fnDisplayVisitedContentDetails();

                        //fnToggleInProgressAnimation();

                        //this is used to load content in the preference pop up
                        //fnBuildCustomFacet();
                        
                        //Load SearchToken, SearchHub and other data are loaded from local storage 
                        //using the session id
                        fnLoadSearchCoreDetails();
                                                                                                                                                         
                        if ((InfaKBSearchOldJs.varSearchUserSessionId != '') || (InfaKBSearchOldJs.varSearchUserSessionId.trim() != '')) {
                              fnHookCustomEventHandlerToCoveoSearchFramwwork();
                              fnCheckAndRetriveSearchToken();
                        }
                        fnDecideToLoadContentForSearch(0);
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'fnToBeCalledOnDocumentReady : Error Occured in Method fnToBeCalledOnDocumentReady Error : ' + ex.message);
                  }
            }

            function fnCheckAndRetriveSearchToken() {
                  try {
                        //Call is made based on token present or not
                        if (InfaKBSearchOldJs.varSearchToken != undefined && InfaKBSearchOldJs.varSearchToken.trim() != '' && InfaKBSearchOldJs.varSearchToken.length > 5) {

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

            //This is the method where all the user information will be available by this time.
            function fnConfigureAllSearchRelatedItems() {
                  try {
                        InfaKBCommonUtilityJs.Log('log', 'fnConfigureAllSearchRelatedItems');
                        
                        // var token = InfaKBSearchOldJs.varSearchToken;
                        // var endpointURI = 'https://platform.cloud.coveo.com/rest/search/';
                        // var root = document.querySelector(searchInterfaceID);
                        // var orginternalName = varSearchOrgName;

                        // fnBlockSearchWithoutKeyword();
            
                        //fnConfigureOldSearchEndPoint();
               
                        //This function is no longer needed as the 
                        //recent content is loaded from aura component
                        fnBuildRecentContentValue();

                        //Filter on load, by building the url for the facet based on the cases open for the current user
                        fnProcessFilterOnLoad();
                        
                        fnLoadSearchTemplate();

                        fnSetSearchHubForSearch();

                        fnInitializeAllSearchAnalytics();

                        //fnConfigureSearchEndPoint();
                        fnConfigureOldSearchEndPoint();
                                              
                        varIsCoveoSearchTokenRetrived = true;
                        varIsCustomEventHandlerHookedToCoveoFramework = true;
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'fnConfigureAllSearchRelatedItems : Error Occured in Method fnConfigureAllSearchRelatedItems Error : ' + ex.message);
                  }
            }

            function fnInitializeAllSearchAnalytics()
            {
                  try {
                        varIsThisKBExternal = InfaKBCommonUtilityJs.fnIsThisExternal();
                        if (varIsThisKBExternal) {
                              InfaKBSearchOldJsOmnitureDTM.fnLoadOmnitureDTMScript();
                              InfaKBSearchOldJsOmnitureDTM.fnHookMethodToEvent();
                              InfaKBSearchOldJsWoopraOld.fnLoadWoopraOldScript();
                              InfaKBSearchOldJsOmnitureOld.fnLoadOmnitureOldScript();
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'fnInitializeAllSearchAnalytics : Error Occured in Method fnInitializeAllSearchAnalytics Error : ' + ex.message);
                  }
            }

            function fnCaptureSearchAnalyticsOnQuerySuccess(result)
            {
                  try {                        
                        if (varIsThisKBExternal) {
                              InfaKBSearchOldJsOmnitureDTM.fnCaptureSearchDataOnQuerySuccess(result);
                              InfaKBSearchOldJsWoopraOld.fnCaptureSearchDataOnQuerySuccess(result);
                              InfaKBSearchOldJsOmnitureOld.fnCaptureSearchDataOnQuerySuccess(result);
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'fnCaptureSearchAnalyticsOnQuerySuccess : Error Occured in Method fnCaptureSearchAnalyticsOnQuerySuccess Error : ' + ex.message);
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
                              InfaKBSearchOldJs.varSearchToken,
                              endpointURI,
                              { renewAccessToken: fnReNewSearchToken }
                        );
                  } catch (error) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnConfigureSearchEndPoint Message : ' + error.message);
                  }
            }

            function fnConfigureOldSearchEndPoint() {
                  try {
                        var token = InfaKBSearchOldJs.varSearchToken;
                        var endpointURI = "https://platform.cloud.coveo.com/rest/search";  
                        var isUserAnonymous = InfaKBSearchOldJs.IsUserAuthenticated == 'true' ? false : true;
      
                        if (Coveo.SearchEndpoint.endpoints["default"]) {
                              Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
                              Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = fnReNewSearchToken;
                              //Coveo.SearchEndpoint.endpoints["default"].options.isGuestUser = isUserAnonymous;  //Tag - 2
                        } else {
                              Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                                    restUri: endpointURI,
                                    accessToken: token,
                                    renewAccessToken: fnReNewSearchToken                                   
                                    //isGuestUser : isUserAnonymous  //Tag - 2
                              });
                        }
                  
                  } catch (error) {
                         InfaKBCommonUtilityJs.Log('error','SearchPage : Error Occured in Method fnConfigureOldSearchEndPoint Message : ' + error.message);
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
		  	      //T03 - Start
                        var varlclSearchTokenResponseJSON = '';
                        if (InfaKBSearchOldJs.varSearchUserSessionId != undefined && InfaKBSearchOldJs.varSearchUserSessionId.trim() != '' && InfaKBSearchOldJs.varSearchUserSessionId.length > 0) {
                              varlclSearchTokenResponseJSON = InfaKBCommonUtilityJs.fnGetLocalStorageDataByID(InfaKBSearchOldJs.varSearchUserSessionId, 'KBContentSearchToken');
                        }
                                    
                        if (varlclSearchTokenResponseJSON != undefined && varlclSearchTokenResponseJSON.trim() != '' && varlclSearchTokenResponseJSON.length > 0) {
                              fnGetSearchRelatedDataFromJson(varlclSearchTokenResponseJSON);
                        }
                   	//T03 - End                                           
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error', 'fnLoadSearchCoreDetails : ' + err.message);
                  } finally {
                 
                  }
            }
      
            function fnGetSearchOrg() {
                  varSearchOrgName = 'informaticasandbox';
                  try {
                        if (InfaKBSearchOldJs.SFDCKBExternalHost.toString().toLowerCase() == 'knowledge.informatica.com') {
                              varSearchOrgName = 'informaticaprod';
                        }
                  } catch (error) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnGetCoveoOrg Message : ' + error.message);
                  }
                  return varSearchOrgName;
            }
	    
	      //T03 - Start
            /**
             * This function refreshes the page on something wnet wrong error
             *            
             */
            function fnExecuteRefreshSetErrorRefreshCount() {
                  try {
                        var varJsonString = InfaKBSearchOldJs.varSearchTokenResponseJSON;
                        if (varJsonString != '') {
                              var data = JSON.parse(varJsonString);                                                     
                              var varlclCurrentRefreshCount = 0;
                              var varlclNewRefreshCount = 0;
                              if (InfaKBSearchOldJs.varRefreshCount != undefined && InfaKBSearchOldJs.varRefreshCount.trim() != '' && InfaKBSearchOldJs.varRefreshCount.length > 0) 
                              {
                                    var varJSONRefreshCount = '\"RefreshCount\":\"**COUNT**\"';                                    
                                    varlclCurrentRefreshCount =  parseInt(InfaKBSearchOldJs.varRefreshCount);
                                    if(varlclCurrentRefreshCount < 2)
                                    {                                          
                                          varlclNewRefreshCount = varlclCurrentRefreshCount + 1;
                                          InfaKBSearchOldJs.varRefreshCount = String(varlclNewRefreshCount);
                                          varJsonString = varJsonString.replace(varJSONRefreshCount.replace('**COUNT**',String(varlclCurrentRefreshCount)),varJSONRefreshCount.replace('**COUNT**',String(varlclNewRefreshCount)));
                                          InfaKBSearchOldJs.varSearchTokenResponseJSON = varJsonString;
                                          if (InfaKBSearchOldJs.varSearchUserSessionId != undefined) {
                                                InfaKBCommonUtilityJs.fnLocaStorageInsertOrUpdate(InfaKBSearchOldJs.varSearchUserSessionId, 'KBContentSearchToken', InfaKBSearchOldJs.varSearchTokenResponseJSON);
                                          }
                                          window.location.reload();
                                          //alert();
                                    }                                    
                              }
                        }                                                                  
                  } catch (err) {
                        InfaKBCommonUtilityJs.Log('error',
                                    'SearchPage : Error Occured in Method fnExecuteRefreshSetErrorRefreshCount Message : ' +
                                    err.message);
                  } finally {
                 
                  }
            }
	      //T03 - End

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
                        if (Coveo.$('.CoveoSearchAlerts')[0] != undefined)
                              Coveo.$('.CoveoSearchAlerts')[0].remove();
                  } catch (error) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRemoveUnnecessaryTags Message : ' + error.message);
                  }
            }

            function fnSetSearchHubForSearch() {
                  try {
                        if (Coveo.$('.CoveoAnalytics')[0] != undefined) {
                              Coveo.$('.CoveoAnalytics')[0].setAttribute('data-search-hub', InfaKBSearchOldJs.varSearchHub);
                              //Coveo.$('.CoveoAnalytics')[0].setAttribute('data-anonymous', (InfaKBSearchOldJs.IsUserAuthenticated == 'true' ? false : true)); //Tag - 2
                        }
                        // if (((InfaKBSearchOldJs.varCalledFrom == KBSEARCH) || (InfaKBSearchOldJs.varCalledFrom == ESUPPORTSEARCH)) && Coveo.$(searchInterfaceID)[0] != undefined) {
                        //          Coveo.$(searchInterfaceID)[0].setAttribute('data-enable-history', 'true')    
                        // }
                        if (((InfaKBSearchOldJs.varCalledFrom == KBSEARCHOLD) || (InfaKBSearchOldJs.varCalledFrom == INSEARCHNEW)) && Coveo.$(searchInterfaceID)[0] != undefined) {
                              Coveo.$(searchInterfaceID)[0].setAttribute('data-enable-history', 'true')    
                        }
                  } catch (error) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetSearchHubForSearch Message : ' + error.message);
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

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('beforeInitialization', function (e, result) {
                              fnPopupIntegration();                              
                        });

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('afterInitialization', function (e, result) {
                              Coveo.get(document.querySelector(".CoveoAnalytics")).enable();
                              if (document.location.pathname.split('/s/global-search/').length > 1) {
                                    //InfaKBSearchOldJs['searchkeywordfirsttime'] = document.location.pathname.split('/eSupport/s/global-search/')[1];
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

                              fnRegisterCoveoTemplateHelper();   

                             
                                                                                                                                                                              
                        });
                
                       
                        Coveo.$$(document.querySelector(searchInterfaceID)).on('preprocessResults', function (e, data) {
                              InfaKBCommonUtilityJs.Log('log', 'preprocessResults');
                              fnModifyKBUURLBasedOnEnvironment(data);
                              //CustomCoveoTemplateFrameworkJs.fnBuildChildHtmlBasedOnMetaData(data);
                        });
                                               
                       //preprocessMoreResults

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('querySuccess', function (e, result) {
                              //fnAssignSearchTemplateForResult(result);                             
                        });

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('newResultDisplayed', function (e, data) {
                              InfaKBCommonUtilityJs.Log('log', 'newResultDisplayed');
                              //Content Visited Feature
                              InfaKBContentVisitedFeatureJs.fnDisplayVisitedContentDetailsForShowMore(e, data);
                              CustomCoveoTemplateFrameworkJs.fnBuildHtmlBasedOnMetaData(data);
                              fnBuildCustomResultItem(data);
                        });

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('newResultsDisplayed', function (e, data) {
                              InfaKBCommonUtilityJs.Log('log', 'newResultsDisplayed');                             
                              fnBuildShowMoreContent(e.target);
                              fnBuildDetailsContent(e.target);
                              fnBuildSingleLineContent(e.target);
                              fnBuildCopyURLContent(e.target);
                        });
                        
                        //Start : I2RT-7586 : Adding Article Number for Coveo Reporting(Internal and External)
                        Coveo.$$(document.querySelector(searchInterfaceID)).on('changeAnalyticsCustomData', function(e, args) {                              
                              if (args.type == 'ClickEvent') {
                                    var articleNo = args.resultData.raw.infaarticlenumber;
                                    if (articleNo != undefined) {
                                          console.log('ClickEvent : Article Number : ', articleNo);
                                          args.metaObject.ArticleNumber = articleNo;
                                    }                                    
                              }
                          });
                        //End : I2RT-7586

                       

                        Coveo.$$(document.querySelector(searchInterfaceID)).on('deferredQuerySuccess', function (e, result) {
                               // To remove the facet based on the content type logic
                              //Content Visited Feature
                              InfaKBContentVisitedFeatureJs.fnDecideToLoadContentVisitedData(0);
                              //fnReBuildFacetBasedOnContentTypeFacet(Coveo.$('[class^=\'CoveoFacet\'][data-field=\'@athenatabname\']'));

                              fnAssignNoResultHtml(result);

                              fnAssignSearchTokenForAnalytics();
                              
                              fnCaptureSearchAnalyticsOnQuerySuccess(result);

                              fnAssignToolTipForTabs();

                              fnSmartSnippetInitialiseVariables();

                              if (result.results.questionAnswer != undefined && result.results.questionAnswer != null && result.results.questionAnswer.answerFound != undefined && result.results.questionAnswer.answerFound != null && result.results.questionAnswer.answerFound == true) {
                                    if (result.results.questionAnswer.question == '') {
                                          if (result.results.questionAnswer.relatedQuestions.length > 0) {
                                                fnToggleInProgressSnippetAnimation('block');
                                                result.results.questionAnswer.relatedQuestions[0].answerSnippet += '<div style=\"display:none;\">' + varRandomNumberForSnippet + '</div>';
                                                fnCheckTillSnippetContentAvailable(0,true);
                                          }
                                    }
                                    else {
                                          fnToggleInProgressSnippetAnimation('block');
                                          result.results.questionAnswer.answerSnippet += '<div style=\"display:none;\">' + varRandomNumberForSnippet + '</div>';
                                          fnCheckTillSnippetContentAvailable(0,false);
                                    }
                              }
                        });

                        //T03 : Start
                        Coveo.$$(document.querySelector(searchInterfaceID)).on('queryError', function(e, args) {
                              try
                              {                                    
                                    console.log('queryError - ' + Date.now().toString());
                                    console.log('queryError - error.message - ' + args.error.message.toString());
                                    console.log('queryError - error.name - ' + args.error.name.toString());
                                    console.log('queryError - error.type - ' + args.error.type.toString());
                                    fnExecuteRefreshSetErrorRefreshCount();
                              }
                              catch (ex) {                                     
                                    InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method Coveo Event QueryError Message : ' + ex.message);
                              }                                                           
                        });
                        //T03 : End

                        varIsCustomFilterEventHandlerHookedToCoveoFramework = true;                                                       

                  } catch (ex) {
                        fnToggleInProgressSnippetAnimation('none');   
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnHookCustomEventHandlerToCoveoSearchFramwwork Message : ' + ex.message);
                  }
            }

            function fnSmartSnippetInitialiseVariables() {
                  try {
                        varRandomNumberForSnippet = (Math.floor(Math.random() * 10000) + 1).toString();
                        varRandomNumberForSnippet = '##$$' + varRandomNumberForSnippet;
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : fnSmartSnippetInitialiseVariables; Error :' + ex.message);
                  }
            }

             /**
             * Used to show the progress icon on snippet record update
             */
             function fnToggleInProgressSnippetAnimation(parDisplayType) {
                  try {
                        var varSnippetAnimationElement = Coveo.$('.CustomCoveoSmartSnippetAnimation');
                        if (varSnippetAnimationElement.length > 0) {
                              varSnippetAnimationElement[0].style.display = parDisplayType;
                        }                                               
                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnToggleInProgressSnippetAnimation : ' + e.message);
                  }
            }

            
            function fnCheckTillSnippetContentAvailable(execCount,isAnswerEmpty) {
                  try {
                       
                        if ((document.querySelector('.CustomCoveoSmartSnippetParentNode') != null) && (document.querySelector('.CustomCoveoSmartSnippetParentNode').innerHTML.length > 0) && (document.querySelector('.CustomCoveoSmartSnippetParentNode').innerHTML.indexOf(varRandomNumberForSnippet) > -1)) {                                
                              fnToBeCalledOnceSnippetContentAvailable(isAnswerEmpty);                                                            
                              InfaKBCommonUtilityJs.Log('log', 'fnCheckTillSnippetContentAvailable done');
                        } else if (execCount < 300) {
                              execCount = execCount + 1;
                              window.setTimeout(function () { fnCheckTillSnippetContentAvailable(execCount,isAnswerEmpty); }, 100);
                              InfaKBCommonUtilityJs.Log('log', 'fnCheckTillSnippetContentAvailable looping');
                        }
                  } catch (exTwo) {
                        fnToggleInProgressSnippetAnimation('none');     
                        InfaKBCommonUtilityJs.Log('error', 'fnCheckTillSnippetContentAvailable : ' + exTwo.message);
                  }
            }

            function fnToBeCalledOnceSnippetContentAvailable(parisAnswerEmpty) {
                  try {                       

                        if (parisAnswerEmpty == false) {
                              var varParentsParentDiv = document.createElement('div');
                              varParentsParentDiv.setAttribute('class', 'coveo-result-row');

                              var varParentDiv = document.createElement('div');
                              varParentDiv.style = 'padding-top:8px;';
                              varParentDiv.setAttribute('class', 'coveo-result-cell');

                              var varParentSpan = document.createElement('span');
                              varParentSpan.setAttribute('class', 'CustomCoveoFieldValue');
                              varParentSpan.setAttribute('data-field', '@infadocid');
                              varParentSpan.style = 'padding-right: 10px;';

                              var varChildSpan = document.createElement('span');
                              varChildSpan.innerHTML = document.querySelector('.coveo-smart-snippet-source-title').innerHTML;
                        
                              var varChildDiv = document.createElement('div');
                              varChildDiv.setAttribute('class', 'CustomCoveoSnippetTitle');
                              varChildDiv.innerHTML = document.querySelector('.coveo-smart-snippet-question').innerHTML;
                              varChildDiv.addEventListener('click', function () { fnToBeCalledOnceSnippetContentClicked(this); });
                        
                              varParentSpan.appendChild(varChildSpan);
                              varParentDiv.appendChild(varParentSpan);
                              varParentDiv.appendChild(varChildDiv);
                              varParentsParentDiv.appendChild(varParentDiv);
                              document.querySelector('.coveo-smart-snippet-source').appendChild(varParentsParentDiv);
                        }
                        
                        var varSnippetSuggestionQuestionElement = document.querySelectorAll('.coveo-smart-snippet-suggestions-question');
                        for (var k = 0; k < varSnippetSuggestionQuestionElement.length; k++) {
                              
                              var varSuggestionTitleElement = Coveo.$(varSnippetSuggestionQuestionElement[k]).find('.coveo-smart-snippet-suggestions-question-source-title');
                              var varSuggestionTitleElementInnerHTML = '';
                              if (varSuggestionTitleElement.length > 0)
                              {
                                    varSuggestionTitleElementInnerHTML = varSuggestionTitleElement[0].innerHTML;
                              }

                              var varSuggestionQuestionElement = Coveo.$(varSnippetSuggestionQuestionElement[k]).find('.coveo-smart-snippet-suggestions-question-title-label');
                              var varSuggestionQuestionElementInnerHTML = '';
                              if (varSuggestionQuestionElement.length > 0)
                              {
                                    varSuggestionQuestionElementInnerHTML = varSuggestionQuestionElement[0].innerHTML;
                              }

                              var varSubParentsParentDiv = document.createElement('div');    
                              varSubParentsParentDiv.setAttribute('class', 'coveo-result-row');
      
                              var varSubParentDiv = document.createElement('div');                        
                              varSubParentDiv.style = 'padding-top:8px;padding-bottom: 16px;padding-left:16px;';
                              varSubParentDiv.setAttribute('class', 'coveo-result-cell');
                                   
                              var varSubParentSpan = document.createElement('span');
                              varSubParentSpan.setAttribute('class', 'CustomCoveoFieldValue');
                              varSubParentSpan.setAttribute('data-field', '@infadocid');
                              varSubParentSpan.style = 'padding-right: 10px;';
      
                              var varSubChildSpan = document.createElement('span');
                              varSubChildSpan.innerHTML = varSuggestionTitleElementInnerHTML;
                              
                              var varSubChildDiv = document.createElement('div');
                              varSubChildDiv.setAttribute('class', 'CustomCoveoSnippetTitle');
                              varSubChildDiv.innerHTML = varSuggestionQuestionElementInnerHTML;
                              varSubChildDiv.addEventListener('click', function () { fnToBeCalledOnceSnippetSuggestionContentClicked(this); });
                              
                              varSubParentSpan.appendChild(varSubChildSpan);
                              varSubParentDiv.appendChild(varSubParentSpan);
                              varSubParentDiv.appendChild(varSubChildDiv);
                              varSubParentsParentDiv.appendChild(varSubParentDiv);

                              var varSuggestionContentainerElement = Coveo.$(varSnippetSuggestionQuestionElement[k]).find('.coveo-smart-snippet-suggestions-question-snippet-container');                              
                              if (varSuggestionContentainerElement.length > 0)
                              {
                                    varSuggestionContentainerElement[0].appendChild(varSubParentsParentDiv);
                              }

                        }
                        fnToggleInProgressSnippetAnimation('none'); 
                  } catch (exTwo) {
                        fnToggleInProgressSnippetAnimation('none');    
                        InfaKBCommonUtilityJs.Log('error','fnToBeCalledOnceSnippetContentAvailable : ' + exTwo.message);
                  }
            }

            function fnToBeCalledOnceSnippetContentClicked(parCurrentItem) {
                  try {
                        var varSnippetTitleElement = Coveo.$(parCurrentItem.parentNode.parentNode.parentNode).find('.coveo-smart-snippet-source-title');                        
                        if (varSnippetTitleElement.length > 0) {
                              varSnippetTitleElement[0].click();
                        }
                       // console.log('fnToBeCalledOnceSnippetContentClicked');
                  } catch (exTwo) {
                        InfaKBCommonUtilityJs.Log('error', 'fnToBeCalledOnceSnippetContentClicked : ' + exTwo.message);
                  }
            }

            function fnToBeCalledOnceSnippetSuggestionContentClicked(parCurrentItem) {
                  try {
                        var varSuggestionTitleElement = Coveo.$(parCurrentItem.parentNode.parentNode.parentNode).find('.coveo-smart-snippet-suggestions-question-source-title');                        
                        if (varSuggestionTitleElement.length > 0) {
                              varSuggestionTitleElement[0].click();
                        }
                        //console.log('fnToBeCalledOnceSnippetSuggestionContentClicked');
                  } catch (exTwo) {
                        InfaKBCommonUtilityJs.Log('error', 'fnToBeCalledOnceSnippetSuggestionContentClicked : ' + exTwo.message);
                  }
            }


            function fnCheckCoveoFoldingToggled(execCount) {
                  try {
                        if (Coveo.$('.CoveoResultFolding').find('.coveo-loading-spinner').length == 0) {
                              InfaKBCommonUtilityJs.Log('log', 'preprocessMoreResults setTimeout');
                              InfaKBCommonUtilityJs.Log('log', Coveo.$('.CoveoResultFolding').length.toString());
                              if (Coveo.$('.CoveoResultFolding').length != 0) {
                                    Coveo.$('.CoveoResultFolding').find('.CoveoIcon').removeClass('coveo-icon');
                              }
                        } else if (execCount < 300) {
                              execCount = execCount + 1;
                              window.setTimeout(function () { fnCheckCoveoFoldingToggled(execCount); }, 100);
                        }
                  } catch (exTwo) {
                         InfaKBCommonUtilityJs.Log('error','fnCheckCoveoFoldingToggled : ' + exTwo.message);
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
                        // if (/(\bpdf\b|\bxls\b|\btxt\b|\bhtml\b|\bzip\b|\bxml\b|\bcs\w+\b)/i.test(data.result.raw.sysfiletype)) {
                        //       Coveo.$(data.item).find('.CoveoIcon').removeClass('coveo-icon');
                        // }
                        

                        if (data.result.raw.sysfiletype === 'html') {
                              Coveo.$(data.item).find('.CoveoQuickview').hide();
                        }
                        Coveo.$(data.item).find('.CoveoIcon').addClass(data.result.raw.infadocumenttype ? data.result.raw.infadocumenttype : '');

                        if (InfaKBSearchOldJs.varRecentContentValueObject != undefined && InfaKBSearchOldJs.varRecentContentValueObject.contains(data.result.raw.infadocid)) {
                              if (Coveo.$(data.item).find('.Latest').length > 0) {
                                    Coveo.$(data.item).find('.Latest')[0].parentElement.style.display = 'inline';
                              }

                        }
                        // //TAG 02
                        // if (Coveo.$(data.item).find('.kbAvgRating').length > 0) {
                        //       var varkbAvgRatingParentElement = Coveo.$(data.item).find('.kbAvgRating')[0];
                        //       if (Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakbaveragerating\']').length > 0) {
                        //             var varAvgRating = Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakbaveragerating\']')[0].childNodes[0].innerHTML;
                        //             if (varAvgRating != undefined && varAvgRating != '' && parseInt(varAvgRating) > 0) {
                        //                   for (var k = 0; k < varAvgRating; k++) {
                        //                         varkbAvgRatingParentElement.children[k].setAttribute('class', 'ratingStar filledRatingStar');
                        //                   }
                        //             }
                        //       }

                        // }

                        // if (Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']').length > 0) {
                        //       var varLifeTimeViews = Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']')[0].childNodes[0].innerHTML;
                        //       if (varLifeTimeViews != undefined && varLifeTimeViews != '' && parseInt(varLifeTimeViews) > 0) {
                        //             varLifeTimeViews = fnformatCommaSeperatedNumber(varLifeTimeViews);
                        //             Coveo.$(data.item).find('.CoveoFieldValue[data-field=\'@infakblifetimeviews\']')[0].childNodes[0].innerHTML = varLifeTimeViews;
                        //       }
                        // }

                        // //TAG 02
                        // Coveo.$(data.item).find('.CoveoIcon').addClass(data.result.raw.infadocumenttype ? data.result.raw.infadocumenttype : '');
                
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
                              if (InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.currentUserFedId.FederationIdentifier') != undefined) {
                                    varSearchUserFedID = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.currentUserFedId.FederationIdentifier');
                              }
                              var infa_validationstatus = r.raw.infavalidationstatus ? r.raw.infavalidationstatus.toLowerCase() : '';
                              var infa_publishstatus = r.raw.infapublishstatus ? r.raw.infapublishstatus.toLowerCase() : '';
                              if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'KB') {
                                    var internalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&internal=1&fid=%%FLD%%'
                                    var internaldrafturlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&type=external'
                                    var externaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&type=external'
                                    var inernaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                                    var inernaltdraftechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
            
                                    //IsUserAuthenticated == true means the logged user is not a guest user thus we are on Internal KB page                                    
                                    // isInternalSearchEnv = InfaKBSearchOldJs.IsUserAuthenticated == 'true' && InfaKBSearchOldJs.UserType == 'Standard' ?
                                    //       true : ((infa_permissionType == 'internal' || (infa_permissionType == 'public' && infa_moderationStatus != 0)) ? true : false);
                                    isInternalSearchEnv = InfaKBSearchOldJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchOldJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
            
                                    if (isInternalSearchEnv == true && infa_validationstatus == 'pending technical review') {
                                          r.clickUri = inernaltechnicalreviewurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                    }
                                    else if (isInternalSearchEnv == false && infa_validationstatus == 'pending technical review') {
                                          r.clickUri = externaltechnicalreviewurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                                    }
                                    else if (isInternalSearchEnv == true && infa_publishstatus == 'draft') {
                                          r.clickUri = internaldrafturlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                    }
                                    else if (isInternalSearchEnv == true) {
                                          r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                                    }
                                    else if (isInternalSearchEnv == false) {
                                          r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                                    }
            
                                    r.ClickUri = r.clickUri;
                                    r.PrintableUri = r.printableUri = r.clickUri;
            
                              }

                              if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceCase') {

                                    isInternalSearchEnv = InfaKBSearchOldJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchOldJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                    var internalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.eSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'
                                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.eSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'

                                    if (isInternalSearchEnv == true) {
                                          r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBInternalHost).replace('%%CASEID$$', r.raw.sfid)
                                    }
                                    else if (isInternalSearchEnv == false) {
                                          r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%CASEID$$', r.raw.sfid)
                                    }

                                    r.ClickUri = r.clickUri;
                                    r.PrintableUri = r.printableUri = r.clickUri;
                              }

                              if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceAccount') {

                                    isInternalSearchEnv = InfaKBSearchOldJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchOldJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
                              
                                    var internalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.eSupportCommunityNameInURL + '/s/supportaccountdetails?accountid=%%ACCOUNTID$$'
                                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchOldJs.eSupportCommunityNameInURL + '/s/supportaccountdetails?accountid=%%ACCOUNTID$$'

                                    if (isInternalSearchEnv == true) {
                                          r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBInternalHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                                    }
                                    else if (isInternalSearchEnv == false) {
                                          r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchOldJs.SFDCKBExternalHost).replace('%%ACCOUNTID$$', r.raw.sfid)
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
                        InfaKBSearchOldJs.varCalledFrom = (InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.PlacedIn').toString().trim().toLowerCase());                        
                        InfaKBSearchOldJs.SFDCKBInternalHost = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnSFDCKBInternalHost');
                        InfaKBSearchOldJs.SFDCKBExternalHost = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnSFDCKBExternalHost');
                        InfaKBSearchOldJs.KBCommunityNameInURL = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnKBCommunityNameInURL') == 'none' ? '' : InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnKBCommunityNameInURL');
                        InfaKBSearchOldJs.eSupportCommunityNameInURL = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdneSupportCommunityNameInURL') == 'none' ? '' : InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdneSupportCommunityNameInURL');
                        InfaKBSearchOldJs.KBNetworkSignUpURL = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnKBNetworkSignUpURL');
                        InfaKBSearchOldJs.KBNetworkLoginURL = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnKBNetworkLoginURL');
                                                
                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnSetGlobalVariables Message : ' + e.message);
                  }
            }

            /**
             * Used to show the progress icon on ajax call
             */
            function fnToggleInProgressAnimation() {
                  try {
                        var varAnimationElement = Coveo.$('.CustomCoveoAnimation');
                        if (varAnimationElement.length > 0) {
                              if (varAnimationElement[0].style.display == 'none') {
                                    varAnimationElement[0].style.display = 'block';
                              } else if (varAnimationElement[0].style.display == 'block') {
                                    varAnimationElement[0].style.display = 'none';
                                    Coveo.$('.slds-card')[0].style.display = 'block'
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
                        // Coveo.init(document.querySelector(searchInterfaceID));
                        Coveo.init(Coveo.$$(document).find(searchInterfaceID), {
                              ResultLink: {
                                onClick: (e, result) => {
                                  e.preventDefault();
                                  e.currentTarget['CoveoResultLink'].openLinkInNewWindow();
                                  InfaKBSearchOldJsOmnitureDTM.fnTrackResultLinks(result.raw.athenatabname[0] + " || " + result.raw.title, result.raw.athenaproduct);
                                }
                              }
                            })

                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnActualIntializeCoveoSearchFramwwork Message : ' + e.message);
                  }
            }

            function fnPopupIntegration()
            {
                  try {
                        

                        var originalLeave = $.fn.popover.Constructor.prototype.leave;
                        Coveo.$.fn.popover.Constructor.prototype.leave = function (obj) {
                              var self = obj instanceof this.constructor ?
                                    obj : Coveo.$(obj.currentTarget)[this.type](this.getDelegateOptions()).data('bs.' + this.type)
                              var container, timeout;

                              originalLeave.call(this, obj);

                              if (obj.currentTarget) {
                                    container = Coveo.$(obj.currentTarget).siblings('.popover')
                                    timeout = self.timeout;
                                    container.one('mouseenter', function () {
                                          //We entered the actual popover call off the dogs
                                          clearTimeout(timeout);
                                          //Let's monitor popover content instead
                                          container.one('mouseleave', function () {
                                                Coveo.$.fn.popover.Constructor.prototype.leave.call(self, self);
                                          });
                                    });
                              }
                        };
                        
                        if (InfaKBSearchOldJs.IsUserAuthenticated == 'false') {
                              InfaKBCommonUtilityJs.Log('log', '***After Checking User - Non Auth');
                              var varCurrentURL = document.location.href;
                              if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20?language') != -1) {
                                    var varDataToFind = 's/global-search/%20?language';
                                    var varDataToReplace = 's/global-search/?language';
                                    varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);                                   
                              }
                              else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ ?language') != -1) {
                                    var varDataToFind = 's/global-search/ ?language';
                                    var varDataToReplace = 's/global-search/?language';
                                    varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);                           
                              } else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20') != -1) {
                                    var varDataToFind = 's/global-search/%20';
                                    var varDataToReplace = 's/global-search/';
                                    varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);                                   
                              }
                              Coveo.$('.CoveoTab[data-popover=true]').popover({
                                    trigger: 'click hover',
                                    placement: 'auto',
                                    delay: { show: 50, hide: 400 },
                                    content: "<a href='" + InfaKBSearchOldJs.KBNetworkLoginURL + encodeURIComponent("?RelayState=") + encodeURIComponent(encodeURIComponent(referrerURL)) + "' target='_self' >Log In</a> or <a href='" + InfaKBSearchOldJs.KBNetworkSignUpURL + "' target='_self' >Sign Up</a> to view"
                              });
                        } else {
                              InfaKBCommonUtilityJs.Log('log', '***After Checking User - Auth');
                              Coveo.$('.CoveoTab[data-popover=true]').popover('disable');
                        }
                  } catch (error) {
                        
                  }
            }


            /**
             * Funtction will wait for all the requried are content availalbe,
             * before it start triggering the search query to Coveo on load of the page
             * @param {count to wait} execCount 
             */

            function fnDecideToLoadContentForSearch(execCount) {
                  try {
                        if ((varIsCustomEventHandlerHookedToCoveoFramework == true) && (varIsCustomFilterEventHandlerHookedToCoveoFramework == true) && (varIsCoveoSearchTokenRetrived == true) && (InfaKBSearchOldJs.varIsCoveoRecentContentRetrived == true) && (varIsCoveoUserFilterRetrived == true) && (varIsNoSearchResultTemplateRetrived == true) && (varIsSearchResultTemplateRetrived == true)) {
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
                        Coveo.$('[class^=\'CoveoResultFolding\']').bind('change', function (args) {
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
                                                            document.getElementById(Coveo.$('[id*=\'hdnUserFilter\']')[0].id).value = varFilterDataJSONString;

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
                        var varUserFilter = document.getElementById(Coveo.$('[id*=\'hdnUserFilter\']')[0].id).value;
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
                        varFilteredValue = allFilterValue.unique();
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRemoveDuplicateValues Message : ' + ex.message);
                  }
                  return varFilteredValue;
            }


            function fnBuildURLFromString() {
                  var varResultURL = '';
                  try {
                        var varCurrentPageQueryString = window.location.hash;
                        var varUserFilter = InfaKBSearchOldJs.varUserFilterString;
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
                        var varUserFilter = InfaKBSearchOldJs.varUserFilterString;
                        if (varUserFilter != undefined && varUserFilter != '') {
                              var varUserFilterJSONObject = JSON.parse(varUserFilter);
                              for (var r = 0; r < varUserFilterJSONObject.length; r++) {
                                    if (varUserFilterJSONObject[r].values != undefined && varUserFilterJSONObject[r].values.length != 0) {
                                          Coveo.state(document.querySelector(searchInterfaceID), 'f:' + varUserFilterJSONObject[r].field, varUserFilterJSONObject[r].values);
                                    }
                              }
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnBuildCoveoStateFromString Message : ' + ex.message);
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
                                    return '<span class="jive-badge jive-status">Helpful</span>';
                              }
                              else {
                                    return '';
                              }
                        });
                        Coveo.TemplateHelpers.registerTemplateHelper("inbestanswerDisplay", function (value) {
                              if (value == 'True' ) {
                                    return '<span class="jive-badge jive-status jive-status-green" style="margin-left:5px;margin-right:5px;">Best Answer</span>';
                              }
                              else {
                                    return '';
                              }
                        });
                        Coveo.TemplateHelpers.registerTemplateHelper("inansweredDisplay", function (value) {
                              if (value == 'True' ) {
                                    return '<span style="color:#999;">This question has been <span class="text-success">Answered</span></span>';
                              }
                              else {
                                    return '';
                              }
                        });
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnRegisterCoveoTemplateHelper Message : ' + ex.message);
                  }
            }

            function fnRemovePersonalizedFilter() {
                  try {
                        InfaKBCommonUtilityJs.Log('log', 'fnRemovePersonalizedFilter');
                        Coveo.$('.CoveoSearchButton').click();

                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnRemovePersonalizedFilter : ' + e.message);

                  }
            }

            function fnApplyPersonalizedFilter() {
                  try {
                        InfaKBCommonUtilityJs.Log('log', 'fnApplyPersonalizedFilter');
                        Coveo.$('.CoveoSearchButton').click();

                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnApplyPersonalizedFilter : ' + e.message);

                  }
            }

            function fnTogglePersonalizedFilter(parCurrentElement) {
                  try {
                        //if condition for - on click to collapse the content
                        var iconElement = Coveo.$(parCurrentElement)[0];
                        if (Coveo.$(iconElement.parentNode).find('#chkbkPersonalizedFilterSwitch').length > 0) {
                              if (Coveo.$('#chkbkPersonalizedFilterSwitch')[0].checked == false) {
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
                              else if (Coveo.$('#chkbkPersonalizedFilterSwitch')[0].checked == true) {
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
                        if (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAKBSEARCHINTERNAL) {
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

                        if ((Coveo.$('.CustomCoveoFacet').length > 0) && (document.getElementById(Coveo.$('[id*=\'hdnUserFilter\']')[0].id).value != '')) {

                              var varAllFacet = Coveo.$('.CustomCoveoFacet').toArray();

                              var varUserFilter = document.getElementById(Coveo.$('[id*=\'hdnUserFilter\']')[0].id).value;

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
                        if (Coveo.$('.CustomCoveoFacet').length > 0) {

                              var varAllFacet = Coveo.$('.CustomCoveoFacet');
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


                              document.getElementById(Coveo.$('[id*=\'hdnUserFilter\']')[0].id).value = JSON.stringify(varAllFilter);

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

                        if (InfaKBSearchOldJs.varCalledFrom == CONTENTSEARCH) {
                              fnGetRecentContentCoveoSearch()
                                    .then(function (data) {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch then');
                                          InfaKBSearchOldJs.varIsCoveoRecentContentRetrived = true;
                                    })
                                    .fail(function (err) {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetRecentContentCoveoSearch fail');
                                          InfaKBCommonUtilityJs.Log('log', err);
                                          InfaKBSearchOldJs.varIsCoveoRecentContentRetrived = true;
                                    });
                        }
                        else {
                              InfaKBSearchOldJs.varIsCoveoRecentContentRetrived = true;
                        }

                  } catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnBuildCustomFacet : ' + e.message);
                  }
            }

            function fnBuildCustomFacet() {
                  try {
                        if (Coveo.$('.CustomCoveoFacet').length > 0) {
                              fnGetFacetValuesCoveoSearch(Coveo.$('.CustomCoveoFacet'))
                                    .then(function (data) {
                                          InfaKBCommonUtilityJs.Log('log', 'fnGetFacetValuesCoveoSearch then');

                                          var varAllCustomFacet = Coveo.$('.CustomCoveoFacet');
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

            function fnBuildShowMoreContent(currentResultItems) {
                  try {

                        var varCustomCoveoFieldTable = Coveo.$(currentResultItems).find('[class=\'CustomCoveoFieldTableShowMoreSection\']');

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


                                          //Value
                                          var varFieldValueConent = document.createElement('div');
                                          varFieldValueConent.setAttribute('class', 'data-custom-coveo-field-value data-custom-coveo-field-value-collapsed');
                                          var varFieldValueSpanValue = document.createElement('span');
                                          varFieldValueSpanValue.innerHTML = varCustomFieldValue[k].innerText.trim();
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

            function fnAssignSearchTokenForAnalytics() {
                  try {
                        if (searchInterfaceElement.length > 0) {
                              if (searchInterfaceElement[0].CoveoSearchInterface.options.endpoint.accessToken.token != document.querySelector('.CoveoAnalytics').CoveoAnalytics.accessToken.token) {
                                    searchInterfaceElement[0].CoveoSearchInterface.usageAnalytics.endpoint.endpointCaller.options.accessToken = InfaKBSearchOldJs.varSearchToken;
                              }
                        }
                  }
                  catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnAssignSearchTokenForAnalytics : ' + e.message);
                  }
            }

            function fnAssignNoResultHtml(parResult) {
                  try {
                        if (parResult.results.totalCount == 0)
                        {                              
                              if (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ESUPPORTGLOBALSEARCH)
                              {
                                   
                              }
                              else if (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAKBSEARCHINTERNAL || InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAPANELFORCASES) 
                              {
                                  
                              }
                              else
                              {
                                    var varInnerHTMl = document.querySelector('.CoveoCustomNoResults').innerHTML;
                                    var varAllContentTabLink = '';
                                    var varQuery = (parResult.query.q) ? parResult.query.q : '';
                                    var varTabName = parResult.query.tab;
                                    var regExp = /(<|>|"|;|&|:|\/|%3E|%3C|%22|%3B|%3A|%2F)/g;
                                    if (varTabName != 'All' && varQuery != '') {
                                          varAllContentTabLink = '<li><a href="#t=All&q=' + encodeURIComponent(varQuery) + '">Try All Content Tab</a></li>';
                                          var displayQuery = varQuery.replace(regExp, "");
                                          varInnerHTMl = varInnerHTMl.replace('SEARCHKEYWORD', displayQuery);
                                          varInnerHTMl = varInnerHTMl.replace('ALLCONTENTTABLINK', varAllContentTabLink);
                                          document.querySelector('.coveo-query-summary-no-results-string').innerHTML = varInnerHTMl;
                                    }
                                    else if (varTabName != 'All' && varQuery == '') {
                                          varAllContentTabLink = '<li><a href="#t=All>Try All Content Tab</a></li>';
                                          varInnerHTMl = varInnerHTMl.replace('SEARCHKEYWORD', '');
                                          varInnerHTMl = varInnerHTMl.replace('ALLCONTENTTABLINK', varAllContentTabLink);
                                          document.querySelector('.coveo-query-summary-no-results-string').innerHTML = varInnerHTMl;
                                    }
                                    else if (varTabName == 'All' && varQuery == '') {
                                          varInnerHTMl = varInnerHTMl.replace('SEARCHKEYWORD', '');
                                          varInnerHTMl = varInnerHTMl.replace('ALLCONTENTTABLINK', '');
                                          document.querySelector('.coveo-query-summary-no-results-string').innerHTML = varInnerHTMl;
                                    }
                                    else if (varTabName == 'All' && varQuery != '') {                 
                                          var displayQuery = varQuery.replace(regExp, "");                         
                                          varInnerHTMl = varInnerHTMl.replace('SEARCHKEYWORD', displayQuery);
                                          varInnerHTMl = varInnerHTMl.replace('ALLCONTENTTABLINK', '');
                                          document.querySelector('.coveo-query-summary-no-results-string').innerHTML = varInnerHTMl;
                                    }
                                  
                                    
                              }
                        }
                  }
                  catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnAssignNoResultHtml : ' + e.message);
                  }
            }


            function fnAssignToolTipForTabs() {
                  try {
                        if (InfaKBSearchOldJs.IsUserAuthenticated == 'false') {
                              var varCoveoTabElements = Coveo.$(searchInterfaceID).find('.CoveoTab[data-custom-title=\'Login to view Content\']')
                              for (var p = 0; p < varCoveoTabElements.length; p++) {
                                    varCoveoTabElements[p].setAttribute('title', 'Login to view Content');
                              }
                        }
                  }
                  catch (e) {
                        InfaKBCommonUtilityJs.Log('error', 'Error Occured in Method fnAssignToolTipForTabs : ' + e.message);
                  }
            }

      
            /*Search Framework in KB SEARCH Page - End*/
            /********************************************************************************/



            //Help link script - start
            function fnLoadHelpLink() {
                  
                  varathenaresourcepath = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnStaticResourceAthenaPath');
                  varhelptexthtmlresourcepath = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('v.hdnStaticResourceAthenaHelpTextHTMLPath');

                  var varcssresourcepath = fnGetResourcePathCode(varathenaresourcepath);
                  //New Help link added - <T02> <T03>
                  var helplinkdropdowncontent = '<div id=\'kbhelppopcontent\' ><a id=\'helplinkone\' href=\'' + varhelptexthtmlresourcepath + '?resourceid=' + varcssresourcepath + '\'  class=\'video-trigger popup-iframe\' >Using Search Operators to Improve Search Results</a></br></div>';
                  //New Help link added - </T02> </T03>

                  Coveo.$('.anchorhelplink').attr('data-content', helplinkdropdowncontent);
                  Coveo.$('.anchorhelplink').mouseover(function () {
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

                              Coveo.$('.anchorhelplink[data-popover=true]').popover({
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
                        for (var i = 0; i < Coveo.$('.popup-iframe').length; i++) {
                              if (Coveo.$('.popup-iframe')[i].id == 'helplinkone') {
                                    present = true;
                              }
                        }
                        if (present) {
                              Coveo.$('.popup-iframe').magnificPopup({
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
             *
             *
             * @param {*} parCurrentItem
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

                        

                        var getSearchTokenaction = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.getSearchToken');
                        getSearchTokenaction.setParams({
                              strCalledFrom: InfaKBSearchOldJs.varCalledFrom
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
                                          if (InfaKBSearchOldJs.varSearchUserSessionId != undefined) {
                                                InfaKBCommonUtilityJs.fnLocaStorageInsertOrUpdate(InfaKBSearchOldJs.varSearchUserSessionId, 'KBContentSearchToken', result);
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
                        InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(getSearchTokenaction);
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
                        

                        var getSearchTokenaction = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.getSearchToken');
                        getSearchTokenaction.setParams({
                              strCalledFrom: InfaKBSearchOldJs.varCalledFrom
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
                                          if (InfaKBSearchOldJs.varSearchUserSessionId != undefined) {
                                                InfaKBCommonUtilityJs.fnLocaStorageInsertOrUpdate(InfaKBSearchOldJs.varSearchUserSessionId, 'KBContentSearchToken', result);
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
                        InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(getSearchTokenaction);
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
                                    InfaKBSearchOldJs.varSearchHub = data.APISearchHub;
                                    InfaKBSearchOldJs.varSearchToken = data.APISearchToken;
                                    InfaKBSearchOldJs.varSearchUserType = data.UserType;
                                    InfaKBSearchOldJs.varSearchUserFirstName = data.FirstName;
                                    InfaKBSearchOldJs.varSearchUserId = data.UserId;                                    
                                    InfaKBSearchOldJs.IsUserAuthenticated = InfaKBSearchOldJs.varSearchUserType == 'Guest' ? 'false' : 'true';
                                    InfaKBSearchOldJs.varSearchTokenResponseJSON = parJsonString;//T03
                                    InfaKBSearchOldJs.varRefreshCount = data.RefreshCount;//T03
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
                                   
                        var action = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.getUserFilter');
                            
                        action.setCallback(this, function (response) {
                              var result = response.getReturnValue();
                              try {
                                    InfaKBCommonUtilityJs.Log('log', 'fnGetFilterOnLoad success');
                                    // response = Coveo.$('<div>').html(response)[0].innerText;
                                    var data = jQuery.parseJSON(result);
    
                                   
                                          InfaKBCommonUtilityJs.Log('log',
                                                'SearchPage Personalization : ' + data.APIResponseStatus
                                          );
                                          InfaKBCommonUtilityJs.Log('log',
                                                'SearchPage Personalization : ' + data.ErrorMessage
                                          );
    
                                          if (data.APIResponseStatus == 'OK') {
                                                if (data.groupByResults != null) {
                                                      InfaKBSearchOldJs.varUserFilterString = JSON.stringify(data.groupByResults);
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
                        InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(action);
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
                                      
                        var varstrSearchToken = InfaKBSearchOldJs.varSearchToken;
               
                        
                        var action = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.getSearchResultRecenttData');
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
                                                InfaKBSearchOldJs.varRecentContentValueObject = null;
                                                if (topitem.searchDataList != null) {
                                                      InfaKBSearchOldJs.varRecentContentValueObject = [];
                                                      Coveo.$(topitem.searchDataList).each(function (
                                                            childindex,
                                                            childitem
                                                      ) {
                                                            InfaKBSearchOldJs.varRecentContentValueObject.push(childitem.infadocid);
                                                      });
                                                }
                                                varRecentContentValueDefferred.resolve(
                                                      InfaKBSearchOldJs.varRecentContentValueObject
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
                        
                        InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(action);
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
                                          InfaKBSearchOldJs.varRecentContentValueObject = null;
                                          if (topitem.searchDataList != null) {
                                                InfaKBSearchOldJs.varRecentContentValueObject = [];
                                                Coveo.$(topitem.searchDataList).each(function (
                                                      childindex,
                                                      childitem
                                                ) {
                                                      InfaKBSearchOldJs.varRecentContentValueObject.push(childitem.infadocid);
                                                });
                                          }
                                        
                                    } else if (data.APIResponseStatus == 'UNAUTHORIZED') {
                                          InfaKBSearchOldJs.varRecentContentValueObject = null;
                                    } else if (data.APIResponseStatus == 'ERROR') {
                                          InfaKBSearchOldJs.varRecentContentValueObject = null;
                                    }
                              });
                        } catch (ex) {
                              var obj = { error: ex };
                              InfaKBCommonUtilityJs.Log('error',
                                    'SearchPage : Error Occured in Method fnGetRecentContentFromJson Inner Catch Message : ' +
                                    obj
                              );
                              InfaKBSearchOldJs.varRecentContentValueObject = null;
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error',
                              'SearchPage : Error Occured in Method fnGetRecentContentFromJson Message : ' +
                              ex.message
                        );
                  }
                  InfaKBSearchOldJs.varIsCoveoRecentContentRetrived = true;
            }

            // function fnGetCurrentUserDetails() {
            
            //       var action = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.getCurrentUsersDetails');

            //       action.setCallback(this, function (response) {
            //             var result = response.getReturnValue();
            //             InfaKBCommonUtilityJs.Log('log','getCurrentUsersDetails : ' + result);
            //             if (result != undefined) {
            //                   InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.set('v.currentUsersDetails', result);
            //             } else {
            //                   var varDefaultValue =
            //                         '{'FirstName':'','UserId':'','UserName':'','UserType':'Guest','Email':'','SessionId':''}';
            //                   InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.set('v.currentUsersDetails', JSON.parse(varDefaultValue));
            //             }
            //             var vardoAfterUserInfoLoaded = InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent.get('c.fnGetSearchToken');
            //             InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(vardoAfterUserInfoLoaded);
            //InfaKBCommonUtilityJs.fnRefresh();
            //       });
            //       InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework.enqueueAction(action);
            //InfaKBCommonUtilityJs.fnRefresh();
            // }
      
            function fnLoadSearchTemplate() {
                  try {
                        if (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ESUPPORTGLOBALSEARCH)
                        {
                              document.querySelector('.KBContentSearchExternalTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchInternalTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalFacet').innerHTML = '';
                              document.querySelector('.KBContentSearchInternalFacet').innerHTML = '';
                              fnLoadESupportSearchTemplate();
                        }
                        else if (InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAKBSEARCHINTERNAL || InfaKBSearchOldJs.varSearchHub == InfaKBSearchOldJs.ATHENAPANELFORCASES) 
                        {
                              document.querySelector('.KBContentSearchExternalTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalForeSupportTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalFacet').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalForeSupportFacet').innerHTML = '';
                              fnLoadInternalSearchTemplate();
                        }
                        else
                        {
                              document.querySelector('.KBContentSearchInternalTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalForeSupportTemplate').innerHTML = '';
                              document.querySelector('.KBContentSearchInternalFacet').innerHTML = '';
                              document.querySelector('.KBContentSearchExternalForeSupportFacet').innerHTML = '';
                              fnLoadExternalSearchTemplate();
                        }
                                         
                        varIsSearchResultTemplateRetrived = true;
                        varIsNoSearchResultTemplateRetrived = true;
                  
  
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : fnGetKBHtmlContentFile :' + ex.message);
                  }
            }

            function fnLoadInternalSearchTemplate()
            {
                  try {
                         //For Internal Users    
                        if (document.querySelector('.KBContentSearchInternalTemplate') != null) {                                    
                              Coveo.TemplateCache.registerTemplate('SalesforceCase', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceCase').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'sfcasenumber' }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Chatter', Coveo.HtmlTemplate.fromString(document.querySelector('.Chatter').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem', 'FeedComment'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Accounts', Coveo.HtmlTemplate.fromString(document.querySelector('.Accounts').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem', 'FeedComment'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Contacts', Coveo.HtmlTemplate.fromString(document.querySelector('.Contacts').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem', 'FeedComment'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('LearningPath', Coveo.HtmlTemplate.fromString(document.querySelector('.LearningPath').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Learning Paths'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Expert', Coveo.HtmlTemplate.fromString(document.querySelector('.Expert').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infacontenttype', 'values': ['Expert Assistant'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Velocity', Coveo.HtmlTemplate.fromString(document.querySelector('.Velocity').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Velocity'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SupportVideo', Coveo.HtmlTemplate.fromString(document.querySelector('.SupportVideo').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['SupportVideo'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('ProdDocs', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Documentation', 'H2L', 'PAMEOL'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('DocPortal', Coveo.HtmlTemplate.fromString(document.querySelector('.DocPortal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['DocPortal'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBInternal', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBInternal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Internal'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBDraft', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBDraft').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['1', '2', '3', '4'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBPublic', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBPublic').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['0'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Jive', Coveo.HtmlTemplate.fromString(document.querySelector('.Jive').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['UserFeed','CollaborationGroupFeed', 'Event', 'Idea'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Cases', Coveo.HtmlTemplate.fromString(document.querySelector('.Cases').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Cases'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Bugs', Coveo.HtmlTemplate.fromString(document.querySelector('.Bugs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'athenatabname', 'values': ['Product Bugs'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Default', Coveo.HtmlTemplate.fromString(document.querySelector('.Default').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('CaseComment', Coveo.HtmlTemplate.fromString(document.querySelector('.CaseComment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('ProdDocsAttachment', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocsAttachment').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('ProductDocChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.ProductDocChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('JiveChildResult', Coveo.HtmlTemplate.fromString(document.querySelector('.JiveChildResult').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('CoveoCustomNoResults', Coveo.HtmlTemplate.fromString(document.querySelector('.CoveoCustomNoResults').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': null, 'mobile': null, 'role': null }), true, true);
                              //document.querySelector('.CustomTemplateForCoveo').innerHTML = '';
                        }
                  } catch (ex) {
                        InfaKBCommonUtilityJs.Log('error', 'Method : fnLoadInternalSearchTemplate :' + ex.message);
                  }
            }

            function fnLoadExternalSearchTemplate()
            {
                  try {
                        //For External Users
                        if (document.querySelector('.KBContentSearchExternalTemplate') != null) {                                    
                              Coveo.TemplateCache.registerTemplate('ChangeRequest', Coveo.HtmlTemplate.fromString(document.querySelector('.ChangeRequest').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['ChangeRequest'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SuccessAccelerators', Coveo.HtmlTemplate.fromString(document.querySelector('.SuccessAccelerators').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['SuccessAccelerators'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('LearningPath', Coveo.HtmlTemplate.fromString(document.querySelector('.LearningPath').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['learningpath'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Expert', Coveo.HtmlTemplate.fromString(document.querySelector('.Expert').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['ExpertAssistant'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Velocity', Coveo.HtmlTemplate.fromString(document.querySelector('.Velocity').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Velocity'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SupportVideo', Coveo.HtmlTemplate.fromString(document.querySelector('.SupportVideo').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['insupportvideos'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('ProdDocs', Coveo.HtmlTemplate.fromString(document.querySelector('.ProdDocs').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['Documentation', 'H2L', 'PAMEOL'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('DocPortal', Coveo.HtmlTemplate.fromString(document.querySelector('.DocPortal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['DocPortal'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBInternal', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBInternal').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Internal'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBDraft', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBDraft').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['1', '2', '3', '4'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('SalesforceKBPublic', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceKBPublic').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'connectortype', 'values': ['Salesforce2'] }, { 'field': 'infapermissiontype', 'values': ['Public'] }, { 'field': 'infamoderationstatus', 'values': ['0'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Jive', Coveo.HtmlTemplate.fromString(document.querySelector('.Jive').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'infadocumenttype', 'values': ['UserFeed','CollaborationGroupFeed', 'Event', 'Idea', 'Blog'] }], 'mobile': null, 'role': null }), true, true);                                                                                          
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

            function fnLoadESupportSearchTemplate()
            {
                  try {
                         //For Esupport Users                            
                        if (document.querySelector('.KBContentSearchExternalForeSupportTemplate') != null) {                                    
                              Coveo.TemplateCache.registerTemplate('SalesforceCase', Coveo.HtmlTemplate.fromString(document.querySelector('.SalesforceCase').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'sfcasenumber' }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Accounts', Coveo.HtmlTemplate.fromString(document.querySelector('.Accounts').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem', 'FeedComment'] }], 'mobile': null, 'role': null }), true, true);
                              Coveo.TemplateCache.registerTemplate('Contacts', Coveo.HtmlTemplate.fromString(document.querySelector('.Contacts').innerHTML.replace('href=\'javascript:void(0);\'></a>', '></a>').replace('href=\"javascript:void(0);\"></a>', '></a>').replace('href=\"javascript:void(0);\"', ''), { 'condition': null, 'layout': 'list', 'fieldsToMatch': [{ 'field': 'objecttype', 'values': ['FeedItem', 'FeedComment'] }], 'mobile': null, 'role': null }), true, true);
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
            
                 
            var InfaKBSearchOldJs = {
          
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

                  'varSearchUserFirstName' :varSearchUserFirstName,
            
                  'varSearchUserSessionId': varSearchUserSessionId,

                  'varSearchTokenValidity': varSearchTokenValidity, //T03

                  'varRefreshCount': varRefreshCount, //T03

                  'varSearchToken': varSearchToken,

                  'varSearchHub': varSearchHub,

                  'SFDCKBInternalHost': SFDCKBInternalHost,
            
                  'SFDCKBExternalHost': SFDCKBExternalHost,
            
                  'KBCommunityNameInURL': KBCommunityNameInURL,
            
                  'eSupportCommunityNameInURL': eSupportCommunityNameInURL,
            
                  'IsUserAuthenticated': IsUserAuthenticated,

                  'endpointURI': endpointURI,

                  'varRandomNumber': varRandomNumber,

                  'varRandomNumberForSnippet': varRandomNumberForSnippet,

                  'varCalledFrom': varCalledFrom,

                  'ESUPPORTSEARCH': ESUPPORTSEARCH,

                  'CONTENTSEARCH': CONTENTSEARCH,

                  'ATHENAKBSEARCHINTERNAL': ATHENAKBSEARCHINTERNAL,

                  'ATHENAPANELFORCASES': ATHENAPANELFORCASES,

                  'ESUPPORTGLOBALSEARCH': ESUPPORTGLOBALSEARCH,

                  'varSearchTokenResponseJSON': varSearchTokenResponseJSON,
                  
                  'varUserFilterString' : varUserFilterString,
                                                            
                  'varINFAKBContentSearchOldControllerComponent': varINFAKBContentSearchOldControllerComponent,

                  'varINFAKBContentSearchOldControllerEvent': varINFAKBContentSearchOldControllerEvent,

                  'varINFAKBContentSearchOldControllerHelper': varINFAKBContentSearchOldControllerHelper,
            
                  'varINFAKBContentSearchOldControllerAuraFramework': varINFAKBContentSearchOldControllerAuraFramework,

                  'varIsThisKBExternal' : varIsThisKBExternal,

                  'fnSetCoveoSearchInterface': fnSetCoveoSearchInterface,

                  'fnToggleInProgressAnimation': fnToggleInProgressAnimation,

                  'fnToggleInProgressSnippetAnimation': fnToggleInProgressSnippetAnimation,

                  'fnSetGlobalVariables': fnSetGlobalVariables,

                  'fnSetSearchCoreDetails': fnSetSearchCoreDetails,
                  
                  'fnLoadSearchCoreDetails': fnLoadSearchCoreDetails,
                  
                  'fnConfigureAllSearchRelatedItems': fnConfigureAllSearchRelatedItems,
                  
                  'fnInitializeAllSearchAnalytics': fnInitializeAllSearchAnalytics,

                  'fnCaptureSearchAnalyticsOnQuerySuccess': fnCaptureSearchAnalyticsOnQuerySuccess,

                  'fnExecuteRefreshSetErrorRefreshCount' : fnExecuteRefreshSetErrorRefreshCount //T03
                                                
        
            };
      
            w.InfaKBSearchOldJs = InfaKBSearchOldJs;
            // w["InfaKBSearchOldJs" + InfaKBSearchOldJs] = InfaKBSearchOldJs;
      } catch (error) {
             InfaKBCommonUtilityJs.Log('error', 'InfaKBSearchOldJs onInit : ' + error.message);
      }
   
      

})(window);
