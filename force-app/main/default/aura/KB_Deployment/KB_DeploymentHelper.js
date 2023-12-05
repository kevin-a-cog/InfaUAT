({
    pollApex: function(component, event, helper) {
        helper.callApexMethod(component, helper);

        //execute callApexMethod() again after 5 sec each
        window.setInterval(
            $A.getCallback(function() {
                helper.callApexMethod(component, helper);
            }), 1000
        );
    },
    handleResponse: function(response, component) {
        var retVal = response.getReturnValue();
        var d = new Date();
        var n = d.getTime();
        component.set("v.message", retVal + n.toString());
    },
    callApexMethod: function(component, helper) {
        var action = component.get("c.getStatusOfExecution");
        action.setCallback(this, function(response) {
            this.handleResponse(response, component);
        });
        $A.enqueueAction(action);
    }
})