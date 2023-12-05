({
	updateCollabHelper : function( component, event, yesOrNo ) {
        var bFlag = false;        
        if (yesOrNo == 'Yes') {
            bFlag = true;
        } 
        let action = component.get( "c.updateCollab" );  
        action.setParams({  
            recId: component.get( "v.recordId" ),
            RemoveTeamMember : bFlag
        });  
        action.setCallback(this, function(response) {  
            let state = response.getState();  
            if ( state === "SUCCESS" ) {  
                let showToast = $A.get( "e.force:showToast" );
                showToast.setParams({
                    title : 'Update Successfull',
                    message : 'Record Updated Successfully' ,
                    type : 'success',
                });
                 
                showToast.fire();
                $A.get("e.force:closeQuickAction").fire();  
                  $A.get('e.force:refreshView').fire();   
                
            }  else {
                
                let showToast = $A.get( "e.force:showToast" );
                showToast.setParams({
                    title : 'Testing Toast!!!',
                    message : 'Record Not Saved due to error.' ,
                    type : 'error',
                
                });
                showToast.fire();
                
                
            }
        });  
        $A.enqueueAction( action );         
        
    }
})