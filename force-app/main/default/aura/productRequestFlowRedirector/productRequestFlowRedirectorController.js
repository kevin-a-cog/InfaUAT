({
    init : function(component, event, helper) {

        var baseUrl = $A.get("$Label.c.PRM_CommunityUrl");
        let finalUrl = baseUrl + 'newproductrequest?c__recordId=' + component.get('v.recordId');
        window.open(finalUrl,'_self');
        $A.get("e.force:closeQuickAction").fire();
    } 
})