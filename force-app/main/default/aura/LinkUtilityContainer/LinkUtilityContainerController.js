({
    handleSelect: function (component, event, helper) {
        var URL = event.getParam('URL');
        var target = event.getParam('Target');

        console.log('Inside Aura method');
        console.log('URL => ' + URL + '\ntarget => ' + target);
        var workspaceAPI = component.find("workspace");

        if (target == 'New Console tab') {
            workspaceAPI.openTab({
                url: URL,
                focus: true
            })
        }
        else if (target == 'New Browser tab') {
            window.open(URL, '_blank'); 
        }
        else if (target == 'New Browser window') {
            window.open(URL, '_blank','width=auto, height=auto');
        }

		//Now we close the Utility Bar.
        component.find("utilitybar").minimizeUtility();
    },

	/*
	 Method Name : handleActionExecution
	 Description : This method minimizes the Utility Bar Component.
	 Parameters	 : Object, called from handleActionExecution, Component.
	 Return Type : None
	 */
	handleActionExecution: function (objComponent) {

		//Now we close the Utility Bar.
        objComponent.find("utilitybar").minimizeUtility();
	},

	/*
	 Method Name : refresh
	 Description : This method rerenders the LWC component.
	 Parameters	 : Object, called from refresh, Component.
	 Return Type : None
	 */
	refresh: function (objComponent) {
        objComponent.set("v.boolRenderLWC", false);
		setTimeout(function() {
			objComponent.set("v.boolRenderLWC", true);
		}, 10);
	}
})