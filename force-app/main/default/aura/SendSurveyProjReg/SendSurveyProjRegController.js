({
	doInit : function(component, event) {

        var action = component.get("c.SendSurveyProjRegPostValidation");
        action.setParams({
            "projRegID" : component.get("v.recordId")
        }); 
        	action.setCallback(this,function(response){
            var flag = response.getReturnValue();
            	if(response.getState() == "SUCCESS"){
                	if(flag == "user access issue"){
                    	component.set("v.message",$A.get("$Label.c.PRM_Send_Survey_Error_1"));
                    }else if(flag =="Project Reg Not Send Survey"){
                        component.set("v.message",$A.get("$Label.c.PRM_Send_Survey_Error_2"));
                    }else if(flag == "duplicate issue"){
                     	component.set("v.message",$A.get("$Label.c.PRM_Send_Survey_Error_3"));
                    }else if(flag == "customer email null"){
                     	component.set("v.message",$A.get("$Label.c.PRM_Send_Survey_Error_4"));                      
                    }else if(flag == "Success"){
                        //Initialize the Flow and set input variable of flow
 						var flow = component.find("flowSendSurvey");
 						var inputVariables = [
    						{
       							name : "varProjRegId",
       							type : "String",
       							value: component.get("v.recordId")
    						}
                        ];
 						
 						flow.startFlow($A.get("$Label.c.PRM_Send_Survey_Flow_Name"), inputVariables);

                	}else if(response.getState() === "ERROR"){
                 		component.set("v.message",flag);
            		}
           		}
           });
       $A.enqueueAction(action);
	},
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED_SCREEN") {
            component.set("v.message",$A.get("$Label.c.PRM_Send_Survey_Success_Msg"));
   		}
	}  
})