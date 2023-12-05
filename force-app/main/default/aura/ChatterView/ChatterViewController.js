({
    
  
    closeModel: function(component, event, helper) {
       
        var payload={description:"refresh"+component.get('v.calledFrom')};
        component.find('openChatter').publish(payload);
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        
    },
    handleMessage : function(component,message){
       
        if(message && message.getParam('description') =='OpenChatter'){
            var recordId=message.getParam('recordId');
            var publisherContext=message.getParam('publisherContext');
            var feedType=message.getParam('feedType');
            var isFeedEnabled=message.getParam('isFeedEnabled');
            var calledFrom=message.getParam('calledFrom');
            component.set('v.isFeedEnabled',isFeedEnabled);
            component.set('v.recordId',recordId);
            component.set('v.publisherContext',publisherContext);
            component.set('v.calledFrom',calledFrom)
            component.set('v.feedType',feedType);
			component.set('v.isModalOpen',true);  
        }
    }
    
   
})