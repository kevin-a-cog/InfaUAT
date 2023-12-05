({
    doInit1 : function(component, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.generatePDF");
        action.setParams({ srRecordId : component.get("v.recordId") });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                console.log('attachment Record',JSON.stringify(response.getReturnValue()));
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "PDF generated successfully."
                });
                toastEvent.fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else{
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "message": "Error occurred. Please contact system administrator."
                });
                toastEvent.fire();
            }
              $A.get('e.force:closeQuickAction').fire();  
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    doInit : function(component, event, helper) {
     // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.generatePDF");
        action.setParams({ srRecordId : component.get("v.recordId") });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                console.log('attachment Record',JSON.stringify(response.getReturnValue()));
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "PDF generated successfully."
                });
                toastEvent.fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else{
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "message": "Error occurred. Please contact system administrator."
                });
                toastEvent.fire();
            }
              $A.get('e.force:closeQuickAction').fire();  
           $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    closeQuickAction : function(component, event, helper) {
       $A.get('e.force:closeQuickAction').fire();  
    },
    openModal : function(component, event, helper){
    
}
})