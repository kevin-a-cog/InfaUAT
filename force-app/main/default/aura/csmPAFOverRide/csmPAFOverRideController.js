({
	doInit : function(component, event, helper) {
       var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo({
            callback : function(error, response){
                console.log(response);
            }
        });
    }
})