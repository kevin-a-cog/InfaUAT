({
	    authorise : function(component, event, helper) {
        	var accountId = component.get("v.recordId");
			var url = $A.get("$Label.c.PRMCommunityURL")+'apex/PartnerCertificate?Id='+accountId;
        	//alert(url);
        	component.set("v.iframeUrl",url);
	}
})