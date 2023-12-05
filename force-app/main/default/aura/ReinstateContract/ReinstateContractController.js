({
	doInit : function(component, event, helper) {
        helper.hasSuperUserPermission(component, event, helper);
	},
    clickProceed : function(component, event, helper){
        helper.reinstateContract(component, event, helper);
    },
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }   
})