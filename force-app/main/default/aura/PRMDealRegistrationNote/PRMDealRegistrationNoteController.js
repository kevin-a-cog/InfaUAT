({
    doInit : function(component, event, helper) {
        // Get a reference to the newStatusCheckDR() function defined in the Apex controller
        var dealId = component.get("v.recordId");
        var action = component.get("c.newStatusCheckDR");
        action.setParams({'DealId':dealId});
        // Register the callback function       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                console.log(retVal);
                component.set("v.font", retVal);
                if(retVal != undefined && retVal!=null && retVal!="" && retVal==='NEW') {                       
                    
                    // Set the component attributes using values returned by the API call
                    component.set("v.renderText", "True"); 
                    
                }
            }
        });
        
        // Invoke the service
        $A.enqueueAction(action);
    }
    
})