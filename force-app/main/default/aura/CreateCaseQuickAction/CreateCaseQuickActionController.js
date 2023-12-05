({
   closeQuickAction : function(component, event, helper) {
        
       
        $A.get('e.force:refreshView').fire();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": event.getParam('caserecordId'),
              "slideDevName": "detail"
            });
            navEvt.fire();
        })

    },
    hideQuickAction : function(component, event, helper) {
        
        var element = document.getElementsByClassName("slds-modal");   
        
        element = Array.from(element); 
        element.forEach(function(e, t) {
            $A.util.addClass(e, 'slds-hide');
        });     

    },
    closeModal: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    closeQA : function(component, event, helper) {
		console.log('Close event received!');

		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": null,
                "listViewName": 'Recent',
                "scope": "Case"
            });
            navEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        })
        .catch(function(error) {
            console.log(error);
        });
	},
getValueFromLwc : function(component, event, helper) {
    component.set("v.inputValue",event.getParam('value'));
    var flow = component.find("flowData");
   // var record = component.get("v.recordId");
    var filters = event.getParam('fromSubmit');
    console.log('param'+event.getParam('activityType'));
   var inputVariables = [
        {
           name : "crecordId",
           type : "SObject",
           value: event.getParam('fromSubmit')
        },
       {
           name : "activityType",
           type : "String",
           value: event.getParam('activityType')
        },
        {
           name : "navigateToRecord",
           type : "Boolean",
           value: event.getParam('navigateToRecord')
        },       
       
    ];
    flow.startFlow("Operations_Activity_window",inputVariables);
   /*  var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();     
			var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": event.getParam('fromSubmit'),
              "slideDevName": "detail"
            });
            navEvt.fire();       
        })*/
}
})