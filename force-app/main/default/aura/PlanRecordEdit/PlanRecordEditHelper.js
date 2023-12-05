({
	navigatehelper : function(event) {
        var urlEvent = $A.get("e.force:navigateToURL");
       var recid = component.get("v.recordId", true);
        urlEvent.setParams({
          "url": '/lightning/r/Plan__c/' + recid + '/view' 
        });
        urlEvent.fire();
		
	}
})