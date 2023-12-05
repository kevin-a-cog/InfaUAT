({
	doInit : function(component, event, helper) {
        var orderId = component.get("v.recordId");
		var url = $A.get("$Label.c.PRM_Org_Url")+'apex/order_pdf?Id='+orderId;
        component.set("v.iframeUrl",url);
	}
})