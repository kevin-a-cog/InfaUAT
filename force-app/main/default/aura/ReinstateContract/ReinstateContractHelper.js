({
	hasSuperUserPermission : function(component, event, helper) {
        //To check if the current User has Super User Permision Set Assigned
		var action = component.get("c.hasSuperUserPermission");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()){
                    component.set('v.errorFlag',true);
                    component.set('v.errorMessage',$A.get("$Label.c.ReinstateContract_InsufficientPermission"));
                	component.set('v.isLoading',false);
                }
                else{
                    helper.checkRenewalQuote(component, event, helper);
                }
            }
            else{
                console.log('Problem in hasSuperUserPermission Method: ' + state);
            }
        });
        $A.enqueueAction(action);
	},
    
	checkRenewalQuote : function(component, event, helper) {
        //To check if any renewal quote exists associated to the contract
		var action = component.get("c.checkRenewalQuote");
        action.setParams({
            contractId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var res = response.getReturnValue();
                //To check for any errors 
                if (res !== 'NO_ERROR') {
                    if (res === 'RENEWAL_QUOTE_NOT_CREATED') {
                        component.set('v.errorFlag', true);
                        component.set('v.errorMessage', $A.get("$Label.c.ReinstateContract_RenewalQuoteError"));                     
                    }
                    else if (res === 'RENEWAL_QUOTE_NOT_PRIMARY') {
                        component.set('v.errorFlag', true);
                        component.set('v.errorMessage', "There is no primary quote associated to the contract.");
                    }                    
                    else if (res === 'RENEWAL_ORDER_NOT_CREATED') {
                        component.set('v.errorFlag', true);
                        component.set('v.errorMessage', $A.get("$Label.c.ReinstateContract_RenewalQuoteNotOrdered"));
                    }
                    else if (res === 'RENEWAL_ORDER_NOT_DEBOOKED') {
                        component.set('v.errorFlag', true);
                        component.set('v.errorMessage', $A.get("$Label.c.ReinstateContract_OrderNotDebooked"));
                    }
                    else if (res === 'DEBOOK_NOT_COMPLETE') {
                        component.set('v.errorFlag', true);
                        component.set('v.errorMessage',$A.get("$Label.c.ReinstateContract_DebookNotComplete"));
                    }            
                }
            }
            else{
                console.log('Problem in checkRenewalOptyQuote Method: ' + state);
            }
            component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
	},
    
    reinstateContract : function(component, event, helper) {
        //To reinstate the contract
		var action = component.get("c.reinstateContract");
        action.setParams({
            contractId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.navigatetoRelatedQuote(component, event, helper);
            }
            else{
                console.log('Problem in reinstateContract Method: ' + state);
            }
        });
        $A.enqueueAction(action);
	},
    
    navigatetoRelatedQuote : function(component, event, helper) {
        //To navigate to the Related Quotes related list on contract
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Quotes__r",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
	}    
    
})