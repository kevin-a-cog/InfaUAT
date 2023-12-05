({
    doinIt : function(component, event, helper) {
        component.set("v.hideSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.supportAccountRollup");
        action.setParams({
            SupportAccountId :recId
        });
        action.setCallback(this, function (response) {
            var retVal = response.getReturnValue();
            if(retVal == 'SUCCESS'){
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'success',
                    message:'Support Recalculation Completed'
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else{
                component.set("v.hideSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    Title:'title',
                    type:'info_alt',
                    message:'Some error occured'+retVal
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})