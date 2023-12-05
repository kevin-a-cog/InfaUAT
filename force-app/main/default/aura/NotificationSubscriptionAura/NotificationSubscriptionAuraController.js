/*
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal     03/10/2023  I2RT-8669   T01     Regression-SF-8498-Infinite spinner 
*/
({
    closeTab: function(component, event) {
        console.log('closeTab');


        var workspaceAPI = component.find("workspace"); //T01
        workspaceAPI.getFocusedTabInfo().then(function(response) { //T01
            var focusedTabId = response.tabId; //T01
            workspaceAPI.closeTab({tabId: focusedTabId}); //T01
            //Redirect to the list view 
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/lightning/o/Notification_Criteria__c/list?filterName=Recent"
                });
            urlEvent.fire();
        }).catch(function(error) {
            console.log(error);
        });
    
        
        
		/*
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
            if(response.isSubtab){
                workspaceAPI.closeTab({tabId: focusedTabId});
            }
            else{
                var params;
                if(recordId){
                    params = {
                        recordId: recordId,
                        focus: true
                    }
                }else{
                    params = {
                        url: "/lightning/o/Notification_Criteria__c/list",
                        focus: true
                    }
                }
                workspaceAPI.openTab(params)
                .then(function(response) {
                    console.log('response in openTab >>',response);
                    workspaceAPI.refreshTab({
                        tabId: response,
                        includeAllSubtabs: true
                    });
                    workspaceAPI.closeTab({tabId: focusedTabId});
                }).catch(function(error) {
                    console.log('error in openTab >>',error);
                }); 
            }
        })
        .catch(function(error) {
            console.log('error in getFocusedTabInfo >>',error);
        });*/
    }
})