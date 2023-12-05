({
	doInit : function(component, event, helper) {
		
        var action = component.get("c.currentUser");
        var errorMessage = $A.get("$Label.c.Admin_Amend_Error_Message");   
        var alertMessage = $A.get("$Label.c.Admin_Amend_Alert_Message");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(state);
            	var retVal = response.getReturnValue() ;
                //alert("First Before If "+retVal);
                    if(!retVal){  
                        	//alert("Second Inside IF "+ retVal);
                        	component.set("v.error",true);                       		
                            component.set("v.message",errorMessage);                                               	                        
                    } 
                    else{
                        //alert("Inside Else Part when TRUE " +retVal);
                        component.set("v.error",false);
                        component.set("v.message",alertMessage);
                        
                    }                
            }			
			//component.set("v.AdminUser",response.getReturnValue());
		});
        $A.enqueueAction(action);
    },
    
    onClickNext: function (component, event, helper) {                           
            helper.adminAmendContract(component, event, helper);     
    },
    
    closeModalOne : function (component, event, helper) {
		helper.navigateContractPage (component, event, helper);
	}
})