({  
    //to check if the user has Revision PS
    doInit: function (component, event, helper) {
        component.set("v.isLoading",true);
        var action = component.get("c.onLoad");
        var recordId = component.get("v.recordId");
        action.setParams({ 'orderId': recordId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse === "Proceed to Merge Screen")
                {
                    component.set("v.notsearchScreen",false);
                }
                else
                {
                 	component.set("v.notsearchScreen",true);
                    component.set("v.message",storeResponse);   
                }
            }
            if (state === "ERROR"){
                component.set("v.notsearchScreen",true);
                component.set("v.hasError",true)
                component.set("v.errorMessage",response.getError()[0].message);
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);
        
    },
    //When user clicks on proceed, calls the method to early terminate
    SearchRAController: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var searchNum = component.find("searchId").get("v.value");
        component.set("v.isLoading",true);
        var action = component.get("c.SearchRA");
        action.setParams({ 'orderId': recordId,'SearchNumber' : searchNum});
        action.setCallback(this, function (response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set("v.RAROCList",retVal);
                component.set("v.RAList",retVal.RAList);
                component.set("v.ROCList",retVal.ROCList);
                component.set("v.hasError",false)
                component.set("v.searchMessage",retVal.searchresultsmessage);
                component.set("v.hasNoAmend",retVal.hasNoAmendment);
                if(component.get("v.searchMessage") === "NULL_MESSAGE"){
                    component.set("v.showDetails",true);
                	component.set("v.ProceedButton",true);
                }
                 else
                 {
                     component.set("v.showDetails",false);
                	component.set("v.ProceedButton",false);
                 }
                }
            if(response.getState() === "ERROR")
            {
                component.set("v.errorMessage",response.getError()[0].message);
                
                component.set("v.showDetails",false);
                component.set("v.ProceedButton",false);
                component.set("v.hasError",true)
            }
            component.set("v.isLoading",false);
            
        });
        
         if(searchNum != null && searchNum != "" && searchNum != undefined)
        {
               $A.enqueueAction(action);
        }
        else
        {
            alert('Please input Order Number or SFDC Revenue Agreement Name to search');
        }
       	
        
       
    },
    mergeAndCancel : function(component,event,helper){
        component.set("v.isProcessing",true);
        var action = component.get("c.mergeRSAndCancelRA");
        var recordId = component.get("v.recordId");
        var RAROC_WrapperData = component.get("v.RAROCList");
        action.setParams({ 'orderId': recordId,'wrapperData':RAROC_WrapperData});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.notsearchScreen",true);
                component.set("v.message",storeResponse);   
                component.set("v.showDetails",false);
                component.set("v.ProceedButton",false);
                component.set("v.goToRA",true);
            }
            if(state === "ERROR"){
                
                component.set("v.hasError",true);
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.notsearchScreen",false);
                component.set("v.showDetails",false);
                component.set("v.ProceedButton",false);
               
            }
            component.set("v.isProcessing",false);
        });
        $A.enqueueAction(action);
        
   
    },
    //To close the modal
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    goToRACon: function (component,event,helper){
        var recId =  component.get("v.RAList");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId[0].Id+'/view';
        var device = $A.get("$Browser.formFactor");
        
        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    }
})