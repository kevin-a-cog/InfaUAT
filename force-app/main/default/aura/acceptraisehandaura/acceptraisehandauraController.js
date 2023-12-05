({
	closeQA : function(component, event, helper) {
		console.log('Close event received!');

		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
				tabId: focusedTabId,
				includeAllSubtabs: true 
            });
			$A.get("e.force:closeQuickAction").fire();
		})
        .catch(function(error) {
            console.log(error);
        });
	}
})