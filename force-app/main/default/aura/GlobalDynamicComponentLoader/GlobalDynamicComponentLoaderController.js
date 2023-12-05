/*
 * Name			:	GlobalDynamicComponentLoader
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/6/2022
 * Description	:	This component loads Aura / LWC components, dynamically.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description                                     Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/6/2022		N/A				Initial version.                                N/A
 balajip				11/25/2022		I2RT-7519		added new component variable strCaseTabId		T01
*/
({
	
	/*
	 Method Name : doInit
	 Description : This method initialize the component.
	 Parameters	 : Object, called from doInit, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
    doInit : function(objComponent) {
		var objBody;
		var objWorkspace = objComponent.find("workspace");
		var objState = objComponent.get("v.pageReference").state;
		var objAttributes = objState.c__objData;

		//We set the additional attributes.
		objAttributes.onclose = objComponent.getReference("c.close");

		//We set the subtab label.
        objWorkspace.getEnclosingTabId().then(function(strTabId) {
            objWorkspace.setTabLabel({
                tabId: strTabId,
                label: objState.c__strSubtabLabel
            });
        })

		//Now we create the component.
		objComponent.set("v.strComponentName", objState.c__strComponentName);
		objComponent.set("v.strCaseTabId", objState.c__strCaseTabId); //T01
		$A.createComponent(objState.c__strComponentName, objAttributes, function(objCreatedComponent, strStatus) {
			if(strStatus === "SUCCESS") {
                objBody = objComponent.get("v.body");
                objBody.push(objCreatedComponent);
				objComponent.set("v.body", objBody);
            }
		});

		//We set the intial CSS.
		objComponent.set("v.lstCSS", [
			".container.cGlobalDynamicComponentLoader {",
			"	top: 0px;",
			"	z-index: 99999 !important;",
			"	position: fixed;",
			"	height: 100% !important;",
			"	width: 100% !important;",
			"	margin-left: -24px;",
			"	background-color: white;",
			"}"
		]);
    },

	/*
	 Method Name : popOut
	 Description : This method pops out the component.
	 Parameters	 : Object, called from popOut, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
	popOut : function(objComponent) {
		objComponent.find('customCSSComponent').setCSS(objComponent.get("v.lstCSS"));
		objComponent.set("v.boolIsPoppedOut", true);
    },

	/*
	 Method Name : popOut
	 Description : This method pops in the component.
	 Parameters	 : Object, called from popIn, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
	popIn : function(objComponent) {
		objComponent.find('customCSSComponent').setCSS([""]);
		objComponent.set("v.boolIsPoppedOut", false);
    },

	/*
	 Method Name : close
	 Description : This method closes the current tab.
	 Parameters	 : Object, called from close, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
	close : function(objComponent) {
        var objWorkspace = objComponent.find("workspace");
        objWorkspace.getFocusedTabInfo().then(function(objResponse) {
            console.log('focusing the tab:', objComponent.get("v.strCaseTabId"));
			objWorkspace.focusTab({
                //T01 set the focus to the given Tab Id
				tabId : objComponent.get("v.strCaseTabId")
			});
            objWorkspace.closeTab({
				tabId: objResponse.tabId
			});

			//Now we close all the subtabs around same functionality.
			objWorkspace.getAllTabInfo().then(function(objAllTabInfoResponse) {
				objAllTabInfoResponse.forEach(objTab => {
					if(objTab.tabId === objResponse.parentTabId && typeof objTab.subtabs !== "undefined" && objTab.subtabs !== null && objTab.subtabs.length > 0) {
						objTab.subtabs.forEach(objSubtab => {
							if(objSubtab.pageReference.state.c__strComponentName === objComponent.get("v.strComponentName")) {
								objWorkspace.closeTab({
									tabId: objSubtab.tabId
								});
							}
						});
					}
				});
		   	});
        });
    }
})