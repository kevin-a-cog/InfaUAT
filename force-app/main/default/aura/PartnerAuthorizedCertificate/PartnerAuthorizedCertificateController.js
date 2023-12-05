({
    doInit : function(component,event,helper){
        //alert('test');
        var action = component.get("c.CurrentUser");
        var alertMessage = $A.get("$Label.c.CertificateErrorMsg");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {              
            	var retVal = response.getReturnValue();
              	//alert(retVal);
                    if(retVal){  
                        	
                        	helper.authorise(component,event,helper);                                               	                        
                    } 
                    else{
                        component.set("v.error", true);
                        component.set("v.message",alertMessage);
                    }                
            }			
		});
        $A.enqueueAction(action);
    }
})