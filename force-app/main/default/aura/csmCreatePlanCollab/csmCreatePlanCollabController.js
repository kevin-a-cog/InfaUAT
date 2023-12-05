({
    handleAddComment : function(component, event, helper) {
        component.set("v.isAddComment", true);        
    },
   
    handleClose: function (component, event, helper) {
        component.set("v.isPoppedOut", false);
        component.set("v.isAddComment", false);        
    }, 
   
	/*
	 Method Name : handleCommentSectionChange
	 Description : This method gets executed upon Comment Section picklist change.
	 Parameters	 : Object, called from handleCommentSectionChange, objComponent Component.
	 			   Object, called from handleCommentSectionChange, objEvent Change event.
	 Return Type : None
	 */
    handleCommentSectionChange: function(objComponent, objEvent) {
		objComponent.set("v.boolDisplayCommentSection", false);
		objComponent.set("v.boolDisplayChatterSection", false);
		objComponent.set("v.boolDisplayEmailSection", false);
        switch(objEvent.getParam('value')) {
			case "1":
				objComponent.set("v.boolDisplayCommentSection", true);
			break;
			case "2":
				objComponent.set("v.boolDisplayChatterSection", true);
			break;
			case "3":
				objComponent.set("v.boolDisplayEmailSection", true);
			break;
		}       
    },

    popOut:function (objComponent) {
		let strPredefinedBody;
		let objReference;

		//We extract first the Body from the Email Composer.
		if(objComponent.get("v.isPoppedOut")) {
			objReference = objComponent.find('globalEmailComposerInline');
			if(typeof objReference !== "undefined" && objReference !== null) {
				strPredefinedBody = objReference.getBody();
			}
		} else {
			objReference = objComponent.find('globalEmailComposerPopOut');
			if(typeof objReference !== "undefined" && objReference !== null) {
				strPredefinedBody = objReference.getBody();
			}
		}
		objComponent.set("v.strPredefinedBody", strPredefinedBody);

		//Now we update the component view.
        objComponent.set("v.isPoppedOut", !objComponent.get("v.isPoppedOut"));
    },
    doInit:function (component, event, helper) {

          // create a one-time use instance of the checkPlanAutoPilot action
        // in the server-side controller
        var checkPlanAutoPilot = component.get("c.checkPlanAutoPilot");
        checkPlanAutoPilot.setParams({ strPlanId : component.get("v.recordId") });
         // Create a callback that is executed after 
        // the server-side action returns
        checkPlanAutoPilot.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               let boolResult =  response.getReturnValue();
                if(boolResult!==undefined && boolResult){
                    component.set("v.showAddButton", true);
                }else{
                    component.set("v.showAddButton", false);
                }
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
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });        
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(checkPlanAutoPilot);
        component.set("v.isAddComment", false);
        component.set("v.isPoppedOut", false);
    },

	/*
	 Method Name : updateEmailBody
	 Description : This method updates the body of the Global Email Composer.
	 Parameters	 : Object, called from updateEmailBody, objComponent Component.
	 			   Object, called from updateEmailBody, objEvent Event.
	 Return Type : None
	 */
	updateEmailBody : function(objComponent, objEvent) {
		let objRequest = {
			target: {
				value: objEvent.getParam('strHTMLBody')
			}
		};
		objComponent.set("v.strPredefinedBody", objEvent.getParam('strHTMLBody'));
		if(objComponent.get("v.isPoppedOut")) {
			objComponent.find('globalEmailComposerInline').saveBody(objRequest);
		} else {
			objComponent.find('globalEmailComposerPopOut').saveBody(objRequest);
		}
    }
})