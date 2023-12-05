({
	closeQA : function(component, event, helper) {
		console.log('closeTab');

		$A.get("e.force:closeQuickAction").fire();

        var filters = event.getParam('filters');
        console.log('filters = ' + JSON.stringify(filters));
        var recordId = filters[0];
        console.log('recordId = ' + recordId);

        var focusedTabId;

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo()
        .then(function(response) {
            //console.log('response = ' + JSON.stringify(response));
            focusedTabId = response.tabId;
            console.log('focusedTabId = ' + focusedTabId);

			workspaceAPI.openSubtab({
				parentTabId: response.parentTabId,
				recordId: recordId,
				focus: true
			})
			.then(function(response) {
				console.log('response in openTab >>',response);
				
				workspaceAPI.closeTab({tabId: focusedTabId});
			}).catch(function(error) {
				console.log('error in openTab >>',error);
			}); 
        })
        .catch(function(error) {
            console.log('error in getFocusedTabInfo >>',error);
        });

		var omniAPI = component.find("omniToolkit");
        omniAPI.getAgentWorks().then(function(result) {
            var works = JSON.parse(result.works);
			works.forEach(work => {
				console.log('Work ID is: ' +  work.workId);
				console.log('Assigned Entity Id: ' + work.workItemId);
				console.log('Is Engaged: ' + work.isEngaged);

				if(work.workId == recordId){
					omniAPI.closeAgentWork({workId: work.workId}).then(function(res) {
						if (res) {
							console.log("Closed work successfully");
						} else {
							console.log("Close work failed");
						}
					}).catch(function(error) {
						console.log('error in closeAgentWork >>',error);
					});
				}
			});
        }).catch(function(error) {
            console.log('error in getAgentWorks >>',error);
        });
    }
})