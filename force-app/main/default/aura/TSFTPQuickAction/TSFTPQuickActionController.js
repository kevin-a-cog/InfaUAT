({
	onInit : function(component, event, helper) {
        var rec = component.get("v.recordId");
        //alert(rec);
        var getLink = component.get("c.getQuickActionLink");
        getLink.setParams({ 
            'recordId' : rec, 
            'type':'TSFTP' 
        });
        getLink.setCallback(this, response => {
            var state = response.getState();
            if (state === "SUCCESS") {
            	
                const returnValue = response.getReturnValue();
            	window.open(returnValue);	
            	$A.get("e.force:closeQuickAction").fire();
            }else{
                    alert('error');            
                            }
        });
        $A.enqueueAction(getLink);
	}
})