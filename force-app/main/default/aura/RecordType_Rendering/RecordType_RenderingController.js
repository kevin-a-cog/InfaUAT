({
       doInit : function ( component, event, helper){
       
       //to fetch the record types
        helper.fetchListOfRecordTypes(component, event, helper);
        
        //to fetch the related account
        var action= component.get("c.FetchAccData");
        action.setParams({
			"planId" : component.get("v.recordId"),
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                component.set("v.Account", result['Account__c']);
                component.set("v.AccountLOB", result['Line_of_Business__c']);
            }
            else {
                console.log('Problem in FetchAccData Method: ' + state);
        	}
            
    	});
        $A.enqueueAction(action);
  	},
        
    CloseModalOne : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
       
    },
    isRefreshed: function(cmp,event,helper){
        
    },
    handleClick : function(component,event,helper){
       	$A.enqueueAction(component.get('c.CloseModalOne'));
        //to show the record specific page layout for record creation
       	helper.showCreateRecordPage(component, component.get("v.radioGrpValue"), component.get("v.objToCreate"));
       
    }
})