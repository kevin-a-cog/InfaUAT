({
	doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            component.set("v.isConsole", response);
            if(response){
                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    console.log(tabId);
                    component.set("v.currentTabId", tabId);
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        })
        .catch(function(error) {
            console.log(error);
        });
	},
    handleCloseModal : function(component, event, helper) {
        let isInConsole = component.get("v.isConsole");
        let workspaceAPI = component.find("workspace");
        let tabId = component.get("v.currentTabId");
 
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'home'
            }
        };
        component.set("v.pageReference", pageReference);
        var defaultUrl = "/lightning/o/Account/home";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
        if(isInConsole){
            workspaceAPI.closeTab({tabId: tabId});
        }
        navService.navigate(pageReference);
        
        
    },
    onRender : function(component, event, helper) {
        //component.set("v.showCustom", true);
    },
    handleSuccess : function(component, event, helper) {
        console.log(JSON.stringify(event)); 
        console.log('accountId in aura '+event.getParam('value'));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam('value')
        });
        navEvt.fire();
    }
})