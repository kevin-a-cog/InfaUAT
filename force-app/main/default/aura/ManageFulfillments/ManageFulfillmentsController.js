({
    doInit: function(cmp,event,helper) {
       	helper.checkPermission(cmp)
        .then(result => {
            console.log('Shipping User -> '+result);
            
            if(result){
            	
            	var action = cmp.get("c.createOEAndFulfillment");
                action.setParams({ orderId : cmp.get("v.recordId") });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // Alert the user with the value returned 
                        // from the server
                        console.log("From server: " + response.getReturnValue());
                        // Display the total in a "toast" status message
                        debugger;
        
                        helper.navigateToSobject(response.getReturnValue());
                        /*
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            //"title": "Fulfillment Generated!",
                            "message": "Fulfillment lines have been generated",
                            "type":"success"
                        });
                        resultsToast.fire();
                        // Close the action panel
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        $A.get('e.force:refreshView').fire();
                        dismissActionPanel.fire();
                        */
        
                        // You would typically fire a event here to trigger 
                        // client-side notification that the server-side 
                        // action is complete
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                    errors[0].message);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: ''+errors[0].message,
                                    duration: '5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
        
                $A.enqueueAction(action);
            
        	}
            else{
            	helper.navigateToSobject(cmp.get("v.recordId"));
        	}
        })
        .catch(error => {
            console.log("Error message: "+error);
        });
        
    }
  
})