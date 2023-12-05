({
	myAction : function(component, event, helper) {
		var action = component.get("c.getisRRatRiskVar");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(data){
            component.set("v.Resource_Request",data.getReturnValue()); 
            //window.alert(data.getReturnValue().Id);
        });
        $A.enqueueAction(action);
	}
})