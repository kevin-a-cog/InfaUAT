({
    onInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Shift Management"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:shift_pattern_entry",
                iconAlt: "Shift Management"
            });
        }).catch(function (error) {
            console.log(error);
        });
    }
})