({
    searchHelper : function(component,event,getInputkeyWord) {
        
        console.log('Searchhelper called');
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
            console.log ('response'+response.getReturnValue())
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
                //console.log('listOfSearchRecords'+ component.get('v.listOfSearchRecords')[0].Name);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    showselected : function(component){
        var selectedRec =  component.get("v.selectedRecord" );
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');        
    }    
    
})