({
	doInit : function(component, event) {
        var action = component.get("c.LeadchangeOwnerShip");
        action.setParams({
            "leadID" : component.get("v.recordId")
        }); 
        	action.setCallback(this,function(response){
            var flag = response.getReturnValue();
            	if(response.getState() === "SUCCESS"){
                	if(flag == "same owner"){
                    	component.set("v.message","You are already owner of the record.");
                	}else if(flag == "cannot change ownership"){
                     	component.set("v.message","You cannot take ownership of this record. Please contact record owner.");
                	}else if(flag == "success"){
                 	 	component.set("v.message","Success");
                		var dismissActionPanel = $A.get("e.force:closeQuickAction");
       					dismissActionPanel.fire();
                		var refreshPage = $A.get("e.force:refreshView");
                		refreshPage.fire();
                		}else{
                         component.set("v.message",flag);
                        }
                }else if(response.getState() === "ERROR"){
                 component.set("v.message",flag);
            }
           });
       $A.enqueueAction(action);
	}
})