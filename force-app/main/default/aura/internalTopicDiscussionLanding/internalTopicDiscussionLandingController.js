({
    doInit : function(component, event, helper) {
        var siteName = $A.get("$Label.c.help_SiteName");
        console.log('siteName > ' , siteName);
        component.set("v.siteName", siteName);
        helper.getNetworkId(component, event, helper);
        
    },
    
    handleCreateStreams : function(component, event, helper) {
        helper.createNewStreams(component, event, helper);
    },
    
    handleStreamChange : function(component, event, helper){
        
        console.log("You selected: " + event.target.dataset.num);
        component.set("v.selectedStream", event.target.dataset.num);
        component.set("v.selectedStreamName", event.target.dataset.streamname);
        console.log('val > ' , component.get("v.selectedStream"));
        helper.addFeedComponent(component, event, helper, 'Streams', component.get("v.selectedStream"));
    }
})