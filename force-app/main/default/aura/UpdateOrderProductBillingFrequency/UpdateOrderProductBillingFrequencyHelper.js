({
	  
    showToast :  function(component, event, helper) { 
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        "title": "Success!",
            "type" : "success",
        "message": "The record has been updated successfully."
    });
    toastEvent.fire();
    }, 
     showWarningToast :  function(component, event, helper) { 
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
         "title": "Warning!",
        "type" : "warning",
        "message": "No order product records to update. "
    });
    toastEvent.fire();
    }, 
    showNoChangeToast :  function(component, event, helper) { 
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
         "title": "No Update Required",
        "type" : "error",
        "message": "Order products are already moved to 'Invoice Plan'."
    });
    toastEvent.fire();
    }, 
    showBilledToast :  function(component, event, helper) { 
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
         "title": "Cannot Update Order Products",
        "type" : "error",
        "message": "Order products are partially/completely billed."
    });
    toastEvent.fire();
    }, 
    showValidationToast :  function(component, event, helper, message) { 
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
         "title": "Error updating Order Products",
        "type" : "error",
        "message": message
    });
    toastEvent.fire();
    }
})