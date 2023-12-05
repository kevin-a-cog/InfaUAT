/*controller for the  Custom Popup Modal Window (does not include footer buttons) for the HybridDeal Manangement*/
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
		if(isShow){
			//Code to set focus on first element
			var firstClose = component.find("PopupWindowClose");
			setTimeout(function() { firstClose.getElement().focus(); },100);
			firstClose.getElement().focus();
		}
	},

	// event listener for keyup, tab pressed from
	//last control put focus on first control
	focusOnFirst: function(component, event, helper) {
	    var e = event;
	    var kCode = (e.keyCode ? e.keyCode : e.which);
	    if (kCode === 9) {
	    	var firstClose = component.find("PopupWindowClose");
	    	setTimeout(function() { firstClose.getElement().focus(); },100);
			firstClose.getElement().focus();
	    }
	},

	// event listener for keyup, shift+tab pressed from
	//first control put focus on last control
	focusOnLast: function(component, event, helper) {
	    var e = event;
	    var kCode = (e.keyCode ? e.keyCode : e.which);
	    if (kCode === 9 && e.shiftKey) {
	    	var lastSaveAndClose = component.find("ModalConfirmButton");
	    	setTimeout(function() { lastSaveAndClose.getElement().focus(); },100);
			lastSaveAndClose.getElement().focus();
	    }
	}
})