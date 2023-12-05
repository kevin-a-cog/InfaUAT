({
    //Get the fields from the fieldset defined
    getFields : function (component, event, helper){
        // debugger; 
        var action = component.get("c.getFields"); 
        var self = this; 
        var typeName = "SBQQ__Subscription__c"; 
        var fsName = "ReleaseLinesFieldSet"; 
        action.setParams({
            typeName: typeName,
            fsName: fsName
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                var fields = response.getReturnValue();
                component.set("v.fieldarray", fields);
                console.log("Dynamic fields: " + JSON.stringify(fields)); 
                // Combine all the fields into a string, to use in Query 
                var fieldStrQuery = ""; 
                for (var key in fields){
                    if (!fields.hasOwnProperty(key)) continue; 
                    var obj = fields[key]; 
                    fieldStrQuery += (obj.fieldPath + ","); 
                }
                
                // Remove comma at the end of fieldStrQuery
                fieldStrQuery = fieldStrQuery.replace(/,\s*$/, "");
                component.set("v.fieldStrQry", fieldStrQuery); 
                
                // added for load default records in products 
                helper.fetchParentSubscriptions(component,event);
            }
            else {
                debugger; 
            }
            
        });
        $A.enqueueAction(action);  
    },
    
    fetchParentSubscriptions: function(component, event) {
        var errorLabel = $A.get("$Label.c.Error_ReactivateLines");
        console.log('onLoad call:fetchParentSubscription');
        //call apex class method
        var action = component.get('c.fetchParentSubscriptionProducts');
        
        // Get arrays of dynamic fields from FieldSet
        var fieldStrQuery = component.get("v.fieldStrQry"); 
        
        action.setParams({
            'ContractId' : component.get("v.recordId"),
            'queryString': fieldStrQuery
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != '') {
                    //set response value in ListOfContact attribute on component.
                    component.set('v.ListOfSubscriptions', response.getReturnValue());
                    // set deafult count and select all checkbox value to false on load 
                    component.set("v.selectedCount", 0);
                    //set the flag to true to display the records retrieved
                    component.set("v.loaded","True");
                } else {
                    // set deafult count and select all checkbox value to false on load 
                    //component.set("v.selectedCount", 0);
                    //set the flag to true to display the records retrieved
                    component.set("v.loaded","True");
                    component.set("v.message",errorLabel);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    releaseSelectedHelper: function(component, event, RecordsIds) {
        var action = component.get("c.transferRecords");
        var errorLabel = $A.get("$Label.c.Error_ReactivateLines");
        action.setParams({
            "lstRecordId" : RecordsIds,
            "contractId" : component.get("v.recordId")
        });
        debugger;
        action.setCallback(this,function(response){
            var flag = response.getReturnValue();
            if(response.getState() === "SUCCESS"){
                debugger;
                if(flag === 'Fail'){
                    debugger;
                    component.set("v.loaded","True");
                    component.set("v.isReleasedClicked","False");
                    component.set("v.message",errorLabel);
                }else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                }
            }else if(response.getState() === "ERROR"){
                component.set("v.loaded","True");
                component.set("v.isReleasedClicked","False");
                component.set("v.message",flag);
            }
        });
        $A.enqueueAction(action);
    }
})