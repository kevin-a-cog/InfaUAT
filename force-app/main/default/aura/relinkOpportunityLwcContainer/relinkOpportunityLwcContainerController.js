({
    cancelClick : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    save : function(component, event, helper) {
        component.find('childlwc').handleSubmit();
    },
    handlevaluechangeevent : function(component,event,helper){
        var filters = event.getParam('eventname');
        var bool = event.getParam('eventvalue');
        if(filters === 'spinner'){
            component.set("v.spinner",bool);
        }
        if(filters === 'closemodal'){
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
        
    }
})