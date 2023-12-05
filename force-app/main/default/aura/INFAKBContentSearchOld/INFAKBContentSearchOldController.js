/*
   @created by       : SathishR
   @created on       : 13/04/2021
   @Purpose          : KB and IN Search Component Used by Customers
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  13-Apr-2021      |   Sathish R               |                   |   Initial Version
 |     2      |  30-Jul-2023      |   Sathish R               |     I2RT-8639     |   IN Search - Click on + Search in any of the filter and left click on the scroll bar to scroll down. It closes immediately, not allowing the user to select a value from the drop down ( EC UAT feedback)
 |     3      |  10-Nov-2023      |   Sathish R               |     I2RT-9499      |   Customer facing "Something went wrong" issue every few hours in search
 ****************************************************************************************************
 */

({
    doInit: function (component, event, helper) {
        try {
            try {
                
                var workspaceAPI = component.find('workspace');
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    
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

                        workspaceAPI.getAllTabInfo().then(function (response) {
                            
                            if (JSON.stringify(response).indexOf('c__INFAKBContentSearchOld') > -1) {
                                var varTabInfo = JSON.parse(JSON.stringify(response));
                                for (var i = 0; i < varTabInfo.length; i++) {
                                    if (varTabInfo[i].url.indexOf('c__INFAKBContentSearchOld') > -1 && varTabInfo[i].tabId != focusedTabId) {
                                        workspaceAPI.closeTab({ tabId: varTabInfo[i].tabId });
                                    }
                                }
                            }
                        })
                            .catch(function (error) {
                                console.log(error);
                            });
                        
                    });
                    
                }).catch(function (error) {
                    console.log(error);
                });
                                              
            } catch (e) {
                console.error('INFAKBContentSearchOld : Error in method doInit : ' + e.message);
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
                        console.error('INFAKBContentSearchOld : Permission issue');
                    }
                });
                $A.enqueueAction(action);
                window.dispatchEvent(new Event('resize'));
            } catch (e) {
                console.error('INFAKBContentSearchOld : Error in method onScriptLoaded action callback : ' + e.message);
            }

        } catch (e) {
            console.error('INFAKBContentSearchOld : Error in method doInit : ' + e.message);
        }
               
    },

    onScriptLoaded: function (component, event, helper) {
        try {
            //T02 - start
            if(document.getElementsByClassName("cCenterPanel").length > 0)
            {
                document.getElementsByClassName("cCenterPanel")[0].removeAttribute("tabindex");
            }
            //T02 - End
            InfaKBCommonUtilityJs.Log('log', 'onScriptLoaded ');
                                                                                                                          
            InfaKBSearchOldJs.varINFAKBContentSearchOldControllerComponent = component;
            InfaKBSearchOldJs.varINFAKBContentSearchOldControllerEvent = event;
            InfaKBSearchOldJs.varINFAKBContentSearchOldControllerHelper = helper;
            InfaKBSearchOldJs.varINFAKBContentSearchOldControllerAuraFramework = $A;
           
            function fnCurrentUserDetailsIsAvailable(execCount) {
                try {
                    if ((component.get('v.hdnCurrentSessionId') != '' && component.get('v.hdnCurrentSessionId') != null) && (component.get('v.hdnSFDCKBExternalHost') != '' && component.get('v.hdnSFDCKBExternalHost') != null) && ($ != undefined && $ != null)) { //T02
                        InfaKBSearchOldJs.varSearchUserSessionId = component.get('v.hdnCurrentSessionId');
                        InfaKBSearchOldJs.varSearchTokenValidity = component.get('v.hdnKBSearchTokenValidity');//T03
                        InfaKBSearchOldJs.fnSetGlobalVariables();
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
                    InfaKBSearchOldJs.fnDecideAndGetSearchToken();
                } catch (ex) {
                    InfaKBCommonUtilityJs.Log('error',
                        'Method : fnCurrentUserDetailsWhenAvailable :' + ex.message
                    );
                }
            }

            fnCurrentUserDetailsIsAvailable(0);

        } catch (e) {
            console.error('INFAKBContentSearchOld : Error in method onScriptLoaded : ' + e.message);
        }
    },
});