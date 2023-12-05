({
    onDataLoaded : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        var channel = helper.getParameterByName('channel');
        console.log('channel >>' + channel);

        var raiseHandType = component.get("v.raiseHand.Type__c");
        var feedItemId = component.get("v.raiseHand.Feed_Item_Id__c");
        
        if(raiseHandType === 'Get Help'){
            if(channel === 'OMNI'){
                //helper.openChatterPostInNewTab(feedItemId,workspaceAPI);
                helper.openChatterPost(feedItemId,workspaceAPI);
            }else{
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    workspaceAPI.isSubtab({
                        tabId: response.tabId
                    }).then(function(response) {
                        if (response) {
                            console.log("This tab is a subtab.");
                        }else {
                            helper.openChatterPost(feedItemId,workspaceAPI);
                        }
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        }
    },

    openChatterPostInSubTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var feedItemId = component.get("v.raiseHand.Feed_Item_Id__c");
        helper.openChatterPost(feedItemId,workspaceAPI);
    }
})