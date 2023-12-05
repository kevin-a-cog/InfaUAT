({  
    
    onInit : function( component, event, helper ) {    
        
        let action = component.get( "c.cloneCollab" );  
        action.setParams({  
            recId: component.get( "v.recordId" )
        });  
        action.setCallback(this, function(response) {  
            let state = response.getState();  
            if ( state === "SUCCESS" ) {  
                let showToast = $A.get( "e.force:showToast" );
                showToast.setParams({
                    title : 'Clone Successfull',
                    message : 'Record Clone Successfully' ,
                    type : 'success',
                });
               
                showToast.fire();
                 $A.get("e.force:closeQuickAction").fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                  
            }  else {
                
                let showToast = $A.get( "e.force:showToast" );
                showToast.setParams({
                    title : 'Testing Toast!!!',
                    message : 'Record Not Saved due to error.' ,
                    type : 'error',
                    mode : 'sticky',
                    message : 'Some error occured'
                });
                showToast.fire();
                
                
            }
        });  
        $A.enqueueAction( action );         
        
    }
    
})