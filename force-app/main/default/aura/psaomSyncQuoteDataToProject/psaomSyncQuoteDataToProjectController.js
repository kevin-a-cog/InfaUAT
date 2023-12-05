({
    doInit  : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.syncQuoteDate");
        action.setParams({
            projId : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log('storeResponse',storeResponse)
                var status = storeResponse.substring(
                    0,storeResponse.indexOf(":")
                );
                console.log('status',status)
                if(status ==="Success"){
                    var toastMsg =  storeResponse.substring(storeResponse.indexOf(":")+1);   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": toastMsg
                    });
                    toastEvent.fire();
                    
                }else if(status ==='Info'){
                   var toastMsg =  storeResponse.substring(storeResponse.indexOf(":")+1); 
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Information!",
                        "type": 'info',
                        "message": toastMsg
                    });
                    toastEvent.fire(); 
                    
                }else{
                    var toastMsg =  'Syncing Quote to Project failed. '+storeResponse.substring(
                        storeResponse.indexOf(":")+1
                    ); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": toastMsg
                    });
                    toastEvent.fire();   
                }
                console.log('toastMsg',toastMsg)
            }
            $A.get('e.force:closeQuickAction').fire();  
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
})