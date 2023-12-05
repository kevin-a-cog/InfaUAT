({
    invoke : function(component, event, helper) {
        console.log('invoke--> ' );
        //var args = event.getParam("arguments");
        var message = component.get("v.messageText");
        var type = component.get("v.type");
        console.log('type---> ' + type);
        console.log('message---> ' + message);
        helper.showToast(type, message);

    }
})