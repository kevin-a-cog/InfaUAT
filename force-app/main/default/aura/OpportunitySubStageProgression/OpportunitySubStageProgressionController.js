({
    doInit: function(component, event, helper) {
        //with no refresh upon substage update
        helper.getCurrentSubStage(component, event);
        helper.fetchSubStagePicklistVals(component, event);
        helper.showProgressionDetails(component, ''); 
        //below lines for refreshing the component data upon substage update.        
        //executes 3 sec each
        var substagesToHide = component.get("v.substagesToHide");
        if(substagesToHide == 'Yes'){
            window.setInterval(
                $A.getCallback(function() { 
                    var subStageVal = component.get("v.currentSubStageName");
                    helper.checkForRefresh(component, event); //verified if substage value changes - then invokes all functions to refresh UI
                }), 3000
            );       
        }
    },
    handleOptionSelected: function (component, event, helper) {
        //Get the string of the "value" attribute on the selected option
        var selectedValue = event.getParam("value");
        helper.showProgressionDetails(component, selectedValue);
    }
})