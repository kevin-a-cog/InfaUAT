/*Controller for Custom Popup Modal Window (Include footer buttons + window customed size) for the hybrid deal management(Opportunity)*/
({
	defaultCloseAction : function(component, event, helper) {
		component.set("v.isHidden", true);
	},

	fireSaveEvent : function(component, event, helper) {
		var event = component.getEvent("onSaveClick");
        event.fire();
	},

	fireCancelEvent : function(component, event, helper) {
		var event = component.getEvent("onCancelClick");
        event.fire();
	},

	changeVisibility: function(component, event, helper) {
		var isShow = event.getParam('arguments').isShow;
		console.log("isShow ==>",isShow);
		component.set("v.isHidden", !isShow);
	}
})