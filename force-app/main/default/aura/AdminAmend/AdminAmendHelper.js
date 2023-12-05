({
	adminAmendContract : function(component, event, recordId) {
		var recordId = component.get("v.recordId");
        var action = component.get("c.adminAmend");
        action.setParams({'contractId':recordId
                         });
            action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();                                                                   
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/" + recordId+ "/related/SBQQ__CoTerminatedQuotes__r/view",
                      "isredirect": "true"
                    });
                    urlEvent.fire();                                                      
            }            
        });
        $A.enqueueAction(action);
    },
    
    //Once clicked OK navigate the user back to Contract record . 
    navigateContractPage : function (component, event, helper) {
        var recId =  component.get("v.recordId");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
        var device = $A.get("$Browser.formFactor");
        
        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    }
})