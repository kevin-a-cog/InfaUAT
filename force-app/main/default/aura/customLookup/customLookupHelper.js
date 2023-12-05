({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'recordId' : component.get("v.recordId")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    setDRValue : function(component,event){
        var dealRecord = component.get("v.selectedRecord");
    	var action = component.get("c.DRValue");    
        // set param to method  
        action.setParams({
            'dealNumber': dealRecord.Id,
            'prRecordId' : component.get("v.recordId")
          });
        // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
          var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse                 }
                if (storeResponse === "SUCCESS") {
                    //alert('Record Updated Successfully');
                    $A.get("e.force:showToast").fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    //component.set("v.Message", 'Record Updated Successfully');
                } else {
                    component.set("v.errorMessage", storeResponse);
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }                            
        });
      // enqueue the Action  
        $A.enqueueAction(action);    
	},
})