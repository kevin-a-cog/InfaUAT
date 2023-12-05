({  
    
    handleClick : function( component, event, helper ) {
        console.log('event.getAttribute("v.label") ===> ' + event.getSource().get("v.label"));
        helper.updateCollabHelper(component,event,event.getSource().get("v.label"));
     }

    
    
})