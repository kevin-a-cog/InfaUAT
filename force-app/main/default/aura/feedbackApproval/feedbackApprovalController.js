({

    doInit : function(component, event, helper) {
        var action = component.get("c.getfeedbackrec");
        action.setParams({
            "fdid" : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var doProceed = false;
            var responseMsg = response.getReturnValue();

            var message = responseMsg;

            if(response.getState() === "SUCCESS"){
                if(responseMsg == "blank"){
                    message =  $A.get("$Label.c.fdmandatory");
                }else if(responseMsg == "New"){
                     message = $A.get("$Label.c.fdnew");
                }else if(responseMsg == "review"){
                     message = $A.get("$Label.c.fdreview");
                }else{
                    doProceed = true;
                }
            }else{
                message = "Unexpected error occurred!";
            }
            component.set("v.message", message);

            if(doProceed){
                component.set("v.showComponent", true);
            }else{
                component.set("v.showMessage", true);
            }
        });
        $A.enqueueAction(action);
    },

    doCancel : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },

    doSubmit : function(component, event, helper) {
        var comments = component.get("v.comments");
        
        var action = component.get("c.submitFeedbackReview");
        action.setParams({
            "fdid" : component.get("v.recordId"),
            "comments" : comments
        });
        
        action.setCallback(this,function(response){
            var responseMsg = response.getReturnValue();

            var message = responseMsg;
            var toastTitle = 'Success!';
            var toastType = "success";
            if(response.getState() === "SUCCESS"){
                if(responseMsg === "SUCCESS"){
                    message = "Successfully submitted for review!";
                }else{
                    toastType = "error";
                    toastTitle = 'Error!';    
                }
            }else if(response.getState() === "ERROR"){
                toastType = "error";
                toastTitle = 'Error!';
                message = "Unexpected error occurred!";
            }

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": toastType,
                "title": toastTitle,
                "message": message
            });
            toastEvent.fire();

            $A.get('e.force:closeQuickAction').fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action); 
    }
})