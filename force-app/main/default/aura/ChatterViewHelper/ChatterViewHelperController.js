({
    doInit : function(component, event, helper) {
        helper.checkForExternalUser(component);
        component.set('v.showSpinner',true);
        var action = component.get("c.checkObjectSupportsFeed");
        var RecId;
        var isFeedMetaNeeded = component.get("v.isFeedMetaNeeded");
        
        if(component.get("v.recordId")){
            RecId = component.get("v.recordId");
        }
        else{
            //Get Id Parameter Value From Community URL
            RecId = helper.getURLParameterValue().id;            
        }
        
        action.setParams({ recordId : RecId, isFeedMetaNeeded : isFeedMetaNeeded });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                console.log('resp ---- '+JSON.stringify(resp));
                component.set('v.isExternalUser',resp.isExternalUser);
                if(!resp.isFeedEnabled){
                    component.set('v.feedEntityId',resp.feedMetaId);
                    component.set('v.doneProcessing',true);
                }
                component.set('v.showSpinner',false);
            } else {
                    component.set('v.showSpinner',false);
                    var errors = response.getError();
                console.log('Test Message='+errors[0].pageErrors[0].message);
                if(errors[0].pageErrors[0].message == 'Duplicate Feed Meta Record'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Access Issue, Please contact Administrator."
                    });
                    toastEvent.fire();
                }
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
            }
        });
        if(!component.get('v.isFeedEnabled')){
            $A.enqueueAction(action);
        }else{
            component.set('v.showSpinner',false);
            component.set('v.doneProcessing',true);
        }
    }
})