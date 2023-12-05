/*
 * Name			:	gcsCancelZoomMeeting
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/02/2021
 * Description	:	This Aura Bundle cancels a Zoom invite.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/02/2021		N/A				Initial version.			N/A
 */
({
	
	/*
	 Method Name : executeAction
	 Description : This method executes the requested action from the LWC.
	 Parameters	 : Object, called from executeAction, objComponent Component.
	 Return Type : None
	 */
	executeAction : function(objComponent) {
		let objWorkspaceAPI;
        let objCloseQuickAction;
		
		//First we close the quick action.
		objCloseQuickAction = $A.get("e.force:closeQuickAction");
        objCloseQuickAction.fire();

		//Now we close the current tab.
		objWorkspaceAPI = objComponent.find("workspace");
        objWorkspaceAPI.getFocusedTabInfo().then(function(objResponse) {
            objWorkspaceAPI.closeTab({
				tabId: objResponse.tabId
			});
        });
    }
})