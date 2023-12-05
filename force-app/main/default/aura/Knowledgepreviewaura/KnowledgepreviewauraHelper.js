({
	closemodal: function (component, event, helper) {
        console.log('close modal');
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            	dismissActionPanel.fire();
        
    }
})