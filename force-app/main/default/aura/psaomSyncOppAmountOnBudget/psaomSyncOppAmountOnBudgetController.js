({
    doInit  : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.syncOppAmount");
        action.setParams({
            budgId : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                //console.log('INSIDE SUCCESS BLOCK');
                resultsToast.setParams({
                    "title": "Update – Success", 
                    "type": "success",                  
                    "message": "Budget Amount Updated Succesfully"                   
                });
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log('INSIDE ERRIR BLOCK');
                        resultsToast.setParams({
                            "title": "Error",
                            "type": "warning",                   
                            "message": errors[0].message                   
                        });
                    }
                }
            }else if (status === "INCOMPLETE") {
                //console.log('INSIDE INCOMPLETE BLOCK');
                resultsToast.setParams({
                    "title": "UnKnown – Error",
                    "type": "error",                   
                    "message": "An unknown Error has occured, Please reach out to IT support"                   
                });
            }
            resultsToast.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})