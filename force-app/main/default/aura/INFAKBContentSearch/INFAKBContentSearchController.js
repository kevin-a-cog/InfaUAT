/*
   @created by       : SathishR
   @created on       : 13/04/2021
   @Purpose          : KB Internal Search Component Used by Support Engineers
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  13-Apr-2021      |   Sathish R               |                   |   Initial Version 
 |     2      |  30-Jul-2023      |   Sathish R               |     I2RT-8639     |   IN Search - Click on + Search in any of the filter and left click on the scroll bar to scroll down. It closes immediately, not allowing the user to select a value from the drop down ( EC UAT feedback)
 |     3      |  11-Sep-2023      |   Sathish R               |     I2RT-8963     |   KB Internal search and case details tab getting refreshed every time when user clicks back on either of the tab.
 ****************************************************************************************************
 */
({
    doInit: function (component, event, helper) {
        try {                        
            try {
                if (typeof (Math) != 'undefined' && typeof (Math.floor) != 'undefined' && typeof (Math.random) != 'undefined') {
                    component.set('v.hdnComponentGlobalId', (Math.floor(Math.random() * 10000) + 1).toString());
                    window.InfaKBSearchJsCtrlId = component.get('v.hdnComponentGlobalId');
                    //console.log('window.InfaKBSearchJsCtrlId' + window.InfaKBSearchJsCtrlId);
                }
                else if (typeof (Date) != 'undefined' && typeof (Date.now) != 'undefined') {
                    component.set('v.hdnComponentGlobalId', (Date.now()).toString());
                    window.InfaKBSearchJsCtrlId = component.get('v.hdnComponentGlobalId');
                    //console.log('window.InfaKBSearchJsCtrlId' + window.InfaKBSearchJsCtrlId);
                }
                        
            } catch (ex) {
                console.error('INFAKBContentSearch : Error in method IdGenerator : ' + ex.message);
            }
           

            try {
                if (document.location.href.indexOf(".lightning.force.com") > 0) {
                    setTimeout(function () {
                        var workspaceAPI = component.find('workspace');
                        if(workspaceAPI != undefined && workspaceAPI.getFocusedTabInfo() != undefined ) //Tag 3 //
                        {
                            workspaceAPI.getFocusedTabInfo().then(function (response) {
                        
                                if (response.tabId != undefined) {
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.getTabInfo({
                                        tabId: focusedTabId
                                    }).then(function (response) {
                                        if (response.title == "Loading...") {
                                            workspaceAPI.setTabLabel({
                                                tabId: focusedTabId,
                                                label: 'Search' //set label you want to set
                                            });
                                            workspaceAPI.setTabIcon({
                                                tabId: focusedTabId,
                                                icon: 'standard:search', //set icon you want to set
                                                iconAlt: 'Search' //set label tooltip you want to set
                                            });
                                        }
                                                        
                                    });
                                
                                }
                            }).catch(function (error) {
                                console.log(error);
                            });

                        }
                    }, 2000);
                } else {
                    component.set('v.hdnComponentGlobalId', component.getGlobalId().replace(':', '').replace(';', ''));
                    window.InfaKBSearchJsCtrlId = component.get('v.hdnComponentGlobalId');
                }
                                              
            } catch (e) {
                console.error('INFAKBContentSearch : Error in method doInit : ' + e.message);
            }
            
            try {
                var action = component.get('c.getCurrentSessionId');
                var calledfrom = component.get('v.PlacedIn').toString().trim().toLowerCase();
                action.setCallback(this, function (response) {
                    var result = response.getReturnValue();
                    if ((result != undefined) && (result != null) && (result != '')) {
                        result = result + component.getGlobalId() + calledfrom;
                        component.set('v.hdnCurrentSessionId', result);
                    } else {
                        component.set('v.hdnCurrentSessionId', '');
                        console.error('INFAKBContentSearch : Permission issue');
                    }
                });
                $A.enqueueAction(action);
                window.dispatchEvent(new Event('resize'));
            } catch (e) {
                console.error('INFAKBContentSearch : Error in method onScriptLoaded action callback : ' + e.message);
            }

        } catch (e) {
            console.error('INFAKBContentSearch : Error in method doInit : ' + e.message);
        }
               
    },
    onScriptLoaded: function (component, event, helper) {
        try {
            InfaKBCommonUtilityJs.Log('log', 'onScriptLoaded ');
                                                                                                                                      
            function fnCurrentUserDetailsIsAvailable(execCount) {
                try {
                    if ((component.get('v.hdnCurrentSessionId') != '' && component.get('v.hdnCurrentSessionId') != null) && (component.get('v.hdnSFDCKBExternalHost') != '' && component.get('v.hdnSFDCKBExternalHost') != null) && (component.get('v.hdnComponentGlobalId') != '' && component.get('v.hdnComponentGlobalId') != null) && ($ != undefined && $ != null)) {//T02
                        InfaKBCommonUtilityJs.Log('log', 'v.hdnComponentGlobalId : ' + component.get('v.hdnComponentGlobalId'));
                        var varTabId = window.InfaKBSearchJsCtrlId != undefined ? window.InfaKBSearchJsCtrlId : '';
                        InfaKBSearchScriptLoad.fnInfaKBSearchScriptLoad(varTabId);
                        window['InfaKBSearchJs' + varTabId].varINFAKBContentSearchControllerComponent = component;
                        window['InfaKBSearchJs' + varTabId].varINFAKBContentSearchControllerEvent = event;
                        window['InfaKBSearchJs' + varTabId].varINFAKBContentSearchControllerHelper = helper;
                        window['InfaKBSearchJs' + varTabId].varINFAKBContentSearchControllerAuraFramework = $A;

                        window['InfaKBSearchJs' + varTabId].varSearchUserSessionId = component.get('v.hdnCurrentSessionId');
                        window['InfaKBSearchJs' + varTabId].fnSetGlobalVariables();
                        fnCurrentUserDetailsWhenAvailable();
                    } else if (execCount < 600) {
                        execCount = execCount + 1;
                        window.setTimeout(function () {
                            fnCurrentUserDetailsIsAvailable(execCount);
                        }, 100);
                    } else {
                        //fnHideArticleLayoutInProgressPanel();
                    }
                } catch (ex) {
                    InfaKBCommonUtilityJs.Log('error',
                        'Method : fnCurrentUserDetailsIsAvailable :' + ex.message
                    );
                }
            }

            function fnCurrentUserDetailsWhenAvailable() {
                try {
                    //fnHideArticleLayoutInProgressPanel();
                    InfaKBCommonUtilityJs.Log('log',
                        'Method : fnCurrentUserDetailsWhenAvailable : User Details Available'
                    );
                    //T02 - start
                    if(Coveo.$ == undefined)
                    {
                        Coveo.$ = $;
                    }
                    //T02 - End
                    var varTabId = window.InfaKBSearchJsCtrlId != undefined ? window.InfaKBSearchJsCtrlId : '';
                    window['InfaKBSearchJs' + varTabId].fnDecideAndGetSearchToken();
                } catch (ex) {
                    InfaKBCommonUtilityJs.Log('error',
                        'Method : fnCurrentUserDetailsWhenAvailable :' + ex.message
                    );
                }
            }

            fnCurrentUserDetailsIsAvailable(0);

        } catch (e) {
            console.error('INFAKBContentSearch : Error in method onScriptLoaded : ' + e.message);
        }
    },
    setPageTitle: function (component, event, helper) {
        try {
            var pageTitle = event.getParam("title") || "";
            if (pageTitle && pageTitle == "Widget") {
                document.title = "Search";
            }
        } catch (e) {
            console.error('INFAKBContentSearch : Error in method setPageTitle : ' + e.message);
        }
    },
    setPageDetails: function (component, event, helper) {
        try {
            // Always update page name for consistency
            if (document.title == "Widget") {
                document.title = "Search";
            }
        } catch (e) {
            console.error('INFAKBContentSearch : Error in method setPageDetails : ' + e.message);
        }
    }
});