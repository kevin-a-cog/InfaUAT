({
showCreateRecordPage : function(component, recordTypeId, entityApiName) {

        debugger;
        var createRecordEvent = $A.get("e.force:createRecord");
    
        if(createRecordEvent){ //checking if the event is supported
            
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                
                createRecordEvent.setParams({
                    
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                    
                    "defaultFieldValues": {
                        
                        "Account__c": component.get("v.Account"),
                        "Account_LOB__c": component.get("v.AccountLOB"),
                        "Plan__c": component.get("v.recordId"),

                    }          

                });

            } 
            createRecordEvent.fire();
        } else{

            alert('This event is not supported');

        }

    },
     fetchListOfRecordTypes: function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeValues");
		action.setParams({
            "objectName" : component.get("v.objToCreate")
        });
        

        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                
				var mapOfRecordTypes = response.getReturnValue();
				//converting the map obtained into the desirable map form
                var Options = [];
                for(var key in mapOfRecordTypes){
                    var mapData = {};
					mapData['label']=mapOfRecordTypes[key];
					mapData['value']=key;
                    Options.push(mapData);
				}
                var defaultData =Options[0];
                component.set("v.radioGrpValue",defaultData['value']);                
                component.set("v.options", Options);

            }
			else{
				console.log('Error in fetchListOfRecordTypes');
			}
        });
		$A.enqueueAction(action);
}
})