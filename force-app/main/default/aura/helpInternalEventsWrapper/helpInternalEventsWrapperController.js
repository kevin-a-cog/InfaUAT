({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var rId = pageReference.state.c__crecordId;
        console.log('rId='+rId);
        component.set("v.crecordId", rId);
    }
})