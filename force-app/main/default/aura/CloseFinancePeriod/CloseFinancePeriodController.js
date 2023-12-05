({  
    //to check if the user has Revision PS
    doInit: function (component, event, helper) {
        component.set("v.isLoading",true);
        var action = component.get("c.onLoad");
        var recordId = component.get("v.recordId");
        action.setParams({ 'FPId': recordId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.FPList",storeResponse);
                console.log(response.getReturnValue());
                component.set("v.isLoading",false);
            }
        });
        $A.enqueueAction(action);
    },
    //When user clicks on proceed, calls the method to early terminate
    closeAndMove: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var valueCloseDate = component.find("CloseDate").get("v.value");
        var FPListClose = component.get("v.FPList");
        var action = component.get("c.closeAndMoveOrders");
        action.setParams({ 'FPId': recordId,'CloseDate' : valueCloseDate});
        action.setCallback(this, function (response) {
            var state = response.getState();            
            component.set("v.isProcessing",false);
            component.set("v.ProceedButton",false);
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
               component.set("v.goToFP",true);
               component.set("v.message",'The Finance Period is Closed Successfully. A job is scheduled to move the backlog orders to next open Finance Period.');
            }
            if(response.getState() === "ERROR")
            {
                component.set("v.message",response.getError()[0].message);
            }
        });
        
        
        if(valueCloseDate != null && valueCloseDate != "" && valueCloseDate != undefined && valueCloseDate > FPListClose[0].blng__PeriodEndDate__c)
        {
             component.set("v.isProcessing",true);   
       		 	$A.enqueueAction(action);
        }
        else if(valueCloseDate == null || valueCloseDate == "" || valueCloseDate == undefined)
            alert('Please input Finance Close Date for the Finance Period.');
        else
            alert('Finance Close Date should be after Finance Period End Date.');
    },
    goToFPController: function(component,event,helper){
        var FPListClose = component.get("v.FPList");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+FPListClose[1].Id+'/view';
        var device = $A.get("$Browser.formFactor");
        
        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    },
    
    //To close the modal
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})