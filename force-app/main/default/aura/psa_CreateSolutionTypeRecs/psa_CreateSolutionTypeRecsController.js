({
    doInit  : function(component, event, helper) {
        var recId = component.get("v.OppId");
        var action = component.get("c.createSolutionTypeRecs");
        console.log('recId  ==> '+ recId);
        action.setParams({
            opportunityId : recId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                console.log('INSIDE SUCCESS BLOCK');
				var myEvent = $A.get("e.c:psa_ToastEventforSolutionTypeRecs");
                myEvent.setParams({
                    toastMessage:"Syncing Solution Type records was succesfull",
                    title:"Success",
                    type:"success"
                });
                console.log('firing event from component controller');
                myEvent.fire();
            } else if(state === "ERROR"){
                console.log('INSIDE ERROR BLOCK');
                var errors = action.getError();
                if(errors){
                var myEvent = $A.get("e.c:psa_ToastEventforSolutionTypeRecs");
                myEvent.setParams({
                    toastMessage:errors[0].message,
                    title:"Known – Error",
                    type:"warning"
                });
                console.log('firing event from component controller');
                myEvent.fire();
                }
            }else if (status === "INCOMPLETE") {
                console.log('INSIDE INCOMPLETE BLOCK');
                var myEvent = $A.get("e.c:psa_ToastEventforSolutionTypeRecs");
                myEvent.setParams({
                    toastMessage:"An unknown Error has occured, Please try after sometime",
                    title:"UnKnown – Error",
                    type:"error"
                });
                console.log('firing event from component controller');
                myEvent.fire();
            }
            
            /** For redirecting to the previous page 
            var url = window.location.href; 
            var value = url.substr(0,url.lastIndexOf('/') + 1);
            window.history.back();
            return false;**/
           
        });
        $A.enqueueAction(action);
        
    }
    
})