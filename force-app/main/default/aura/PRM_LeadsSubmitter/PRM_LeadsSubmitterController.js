({
    doInit : function(component, event, helper) {
        
        
       var dealId = component.get("v.recordId");
         var action = component.get("c.SubmitStatusValidator");
            action.setParams({'DealId':dealId});        
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                
            	if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                    
                    if(retVal != undefined && retVal!=null && retVal!="") 
                    {                       
               			
                        if(retVal==='SUCCESS')
               			{
                   			
						}
                        else 
                        {                        
                            var navEvt = $A.get("e.force:navigateToSObject");
        					navEvt.setParams({
            				"recordId": dealId,
            				"isredirect": "false"
        					});
        					navEvt.fire();
                            var toastEvent = $A.get("e.force:showToast");                          
							toastEvent.setParams({
    						title: "Sorry!",
    						message: retVal,
    						type: "error"
							});
            				toastEvent.fire();
                        }
                    }
                }
            });
        $A.enqueueAction(action);
    },
    
	//Closes the Modal Pop-up and refreshes the detail page
    CloseModalOne : function(component,event,helper){
        var recId =  component.get("v.recordId");
       	
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "isredirect": "false"
        });
        navEvt.fire();
    },
    
    //this function automatic call by aura:waiting event  
 	showSpinner: function(component, event, helper) 
 	{
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
 	},
    
 	// this function automatic call by aura:doneWaiting event 
 	hideSpinner : function(component,event,helper)
 	{
       // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
 	},
    
    submitDR : function(component,event,helper)
    {
       var dealId = component.get("v.recordId");
       var successMsg = "Deal Registration Submitted Successfully.";
       var action = component.get("c.SubmitDealForApproval");
            action.setParams({'DealId':dealId});        
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                
            	if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                    
                    if(retVal != undefined && retVal!=null && retVal!="") 
                    {                       
               			if(retVal==='SUCCESS')
               			{
                   			var navEvt = $A.get("e.force:navigateToSObject");
        					navEvt.setParams({
            				"recordId": dealId,
            				"isredirect": "false"
        					});
        					navEvt.fire();
                            var toastEvent = $A.get("e.force:showToast");                          
							toastEvent.setParams({
    						title: "Success!",
    						message: successMsg,
    						type: "success"
							});
            				toastEvent.fire();
						}
                        else 
                        {                        
                            var navEvt = $A.get("e.force:navigateToSObject");
        					navEvt.setParams({
            				"recordId": dealId,
            				"isredirect": "false"
        					});
        					navEvt.fire();
                            var toastEvent = $A.get("e.force:showToast");                          
							toastEvent.setParams({
    						title: "Sorry!",
    						message: retVal,
    						type: "error"
							});
            				toastEvent.fire();
                        }
                    }
                }
            });
        $A.enqueueAction(action);
       
    }
})