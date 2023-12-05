({
    clickAdd : function(component, event, helper) {
        console.log('Click add entry');
        var emessageId=component.get( "v.recordId" );
        var action = component.get( "c.fetchAttachments");
        action.setParam("emessageId",emessageId);
        
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            if ( state === "SUCCESS" ) {
                var res = response.getReturnValue();   
                
                
                console.log('response'+JSON.stringify(res));
                component.set("v.Parsed",res);
                component.set("v.downloaded","true");
            }  
        });  
        $A.enqueueAction(action);  
        
        
        
    }
})