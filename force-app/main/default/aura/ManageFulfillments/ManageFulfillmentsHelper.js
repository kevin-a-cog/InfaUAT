({
    
    navigateToSobject:function(recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": recordId,
      //"slideDevName": "related"
    });
    navEvt.fire();
       },
    
    checkPermission : function(cmp){
   		var action = cmp.get("c.checkUserPermission");
        return new Promise((resolve, reject) => {
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    //console.log("Is shipping user -> "+response.getReturnValue());
                    resolve(response.getReturnValue());
                }
                else if(state === "ERROR"){
                    reject(new Error(response.getError()));
                }
            });
            
            $A.enqueueAction(action);
            
        });
        
 	}
    
})