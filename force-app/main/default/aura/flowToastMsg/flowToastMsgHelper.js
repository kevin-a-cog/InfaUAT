({
    showToast : function(type, message) {
        console.log('type---> ' + type);
        console.log('message---> ' + message);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type,
            "message": message,
            "type": type
        });
       
        toastEvent.fire();
        
    }
})