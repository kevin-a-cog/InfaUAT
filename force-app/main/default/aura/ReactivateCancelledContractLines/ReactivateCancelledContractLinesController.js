({
    doInit : function(component, event, helper) {
        //Fetching the fields from field set and later fetching the suisbcription records
        debugger;
        helper.getFields(component, event, helper); 
        
    },
    
    // For count the selected checkboxes. 
    checkboxSelect: function(component, event, helper) {
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1     
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
    },
    
    //For Delete selected records 
    releaseSelected: function(component, event, helper) {
        // create var for store record id's for selected checkboxes
        debugger;
        //Showing the loading screen when the release button is clicked
        component.set("v.isReleasedClicked","True");
        
        var recId = [];
        // get all checkboxes 
        var getAllId = component.find("boxPack");
        console.log('getAllId ::'+getAllId);
        // If the local ID is unique[in single record case], find() returns the component. not array
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                recId.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in recId var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    recId.push(getAllId[i].get("v.text"));
                }
            }
        } 
        console.log('recId'+recId);
        // call the helper function and pass all selected record id's.    
        helper.releaseSelectedHelper(component, event, recId);
        
    },
    
    CloseModalOne : function(component,event,helper){        
        $A.get("e.force:closeQuickAction").fire();
    },
})