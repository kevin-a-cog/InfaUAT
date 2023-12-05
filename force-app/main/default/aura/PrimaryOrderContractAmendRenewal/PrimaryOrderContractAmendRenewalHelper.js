({
	goToRecordHelper : function(component,event,helper){
        var recordId = component.get("v.recordId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      "recordId": recordId,
      "slideDevName": "related"
    });
    navEvt.fire();
    },
    goToRelatedHelper : function(component,event,helper){
        
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
    relatedListEvent.setParams({
        "relatedListId": "OrderItems",
        "parentRecordId": component.get("v.recordId")
    });
    relatedListEvent.fire();
    }
})