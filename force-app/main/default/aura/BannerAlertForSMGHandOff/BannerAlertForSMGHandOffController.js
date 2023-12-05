({
	checkCondition : function(component, event, helper) {
		 var recId = component.get( "v.recordId" );
         var action = component.get( "c.getRenewalOpptycloseDate" );
            action.setParam("interlockId",recId);
            
            action.setCallback(this, function(response) {  
                var state = response.getState();  
                if ( state === "SUCCESS" ) {  
                     var res=response.getReturnValue(); 
                    console.log(JSON.stringify(res));
                    
                    if(res==true)
                    {
                        component.set("v.showBanner",true);
                    }else
                    {
                        component.set("v.showBanner",false);
                    }
                }  
            });  
            $A.enqueueAction(action);  
            
	}
})