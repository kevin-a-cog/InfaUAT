({
    debookOrder: function (component, event, orderId) {
        //alert('In debook Order');
        component.set("v.spinneract",true); 
        var orderId = component.get("v.recordId");
        var action = component.get("c.debookOrder");
        var cancelReason = component.get("v.picklistvalue");
        var cancelReasonText = component.get("v.cancelReasonTextValue");
        //alert('Cancel Reason value'+ cancelReason);
        //alert('Cancel Reason Text value'+ cancelReasonText);
        
        action.setParams({'OrderId':orderId,
                           'CancelReason':cancelReason,
                           'CancelReasonText':cancelReasonText
                         });
       // action.setParams({'OrderId':orderId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                component.set("v.spinneract",false);
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/Contact/" + retVal+ "/related/SBQQ__AmendmentOpportunities__r/view",
                      "isredirect": "true"
                    });
                    urlEvent.fire();
                    
                    /*var relatedListEvent = $A.get("e.force:navigateToRelatedList");
    				relatedListEvent.setParams({
       					 "relatedListId": "Cases",
        				 "parentRecordId": component.get("v.recordId")
    				});
    				relatedListEvent.fire();*/
                }
        	}
        });
        
        $A.enqueueAction(action);
    },  
    
    
    
    debookDirectOrder: function (component, event, orderId) {
        //alert('In debook Order');
        component.set("v.spinneract",true); 
        var orderId = component.get("v.recordId");
        var action = component.get("c.debookDirectOrder");
        var cancelReason = component.get("v.picklistvalue");
        var cancelReasonText = component.get("v.cancelReasonTextValue");
        //alert('Cancel Reason value'+ cancelReason);
        //alert('Cancel Reason Text value'+ cancelReasonText);
        
        action.setParams({'OrderId':orderId,
                           'CancelReason':cancelReason,
                           'CancelReasonText':cancelReasonText
                         });
       // action.setParams({'OrderId':orderId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                component.set("v.spinneract",false);
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": retVal,
                    "slideDevName": "related"
                });
                navEvt.fire();
                }
        	}
        });
        
        $A.enqueueAction(action);
    },  
    
    
    
    
    cancelOrder : function(component, event, orderId) {
       component.set("v.spinneract",true);
       var action = component.get("c.cancelOrder");
        var orderId = component.get("v.recordId");
        var cancelReason = component.get("v.picklistvalue");
        var cancelReasonText = component.get("v.cancelReasonTextValue");
        //alert('Cancel Reason value'+ cancelReason);
        //alert('Cancel Reason Text value'+ cancelReasonText);
        
        action.setParams({'OrderId':orderId,
                           'CancelReason':cancelReason,
                           'CancelReasonText':cancelReasonText
                         });
        action.setCallback(this, function(response) {
            var flag = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showCancelModal',true);
                component.set("v.spinneract",false);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": flag,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getPicklistfieldValues : function(component, objectName, fieldName, elementId) {
        var action = component.get("c.getPickListValues");
        action.setParams({
            "objectType": objectName,
            "selectedField": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                //alert('allValues' + allValues);
                if (allValues != undefined && allValues.length > 0) {                    
                    
                    opts.push({
                        class: "option",
                        label: "--- None ---",
                        value: "None"
                    });
                }    
                //alert('options' + opts);
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(['option', { label: allValues[i], value: allValues[i] }]);
                    //alert(opts);
                }
               // alert('options' + opts);
                component.set("v.picklistOption", allValues);
                component.find(elementId).set("v.picklistOption", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    
    navigateOrderPage : function (component, event, helper) {
        var recId =  component.get("v.recordId");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
        var device = $A.get("$Browser.formFactor");
        
        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    },
    showDebookWindow: function (component, event, helper) {
        component.set('v.showDebookModal', true);
        component.set('v.initialLoadModal', false);
    },
    showCancelWindow: function (component, event, helper) {
        component.set('v.showCancelModal', true);
        component.set('v.initialLoadModal', false);
    },  
    showDebookWindowDirect: function (component, event, helper) {
        component.set('v.showDebookModalDirect', true);
        component.set('v.initialLoadModal', false);
    },
    /*
    updateCancelReasonValues : function(component, event, helper){
        var obj = new Object();
        obj['Id']=component.get("v.recordId");
        obj['Cancel_Debook_Reason__c'] = component.find("orderCancelReason").get("v.value");
        if (component.find("orderCancelReason").get("v.value") === 'Other') {
            obj['Cancel_Debook_Reason_text__c'] = component.find("cancelReasonTextId").get("v.value");
        }
        var action = component.get("c.updateCancelReason");
        action.setParams({ 'obj': obj });
        action.setCallback(this, function (response) {  
            var state = response.getState();
        }); 
        $A.enqueueAction(action);
    },
    */
    save: function (component, event, helper) {
        var cancelreasonvalue = component.find("orderCancelReason").get("v.value");
        component.set('v.picklistvalue',cancelreasonvalue);
        
        
        if (component.find("orderCancelReason").get("v.value") === 'Other') {
            var cancelreasonTextvalue = component.find("cancelReasonTextId").get("v.value");
            component.set('v.cancelReasonTextValue', cancelreasonTextvalue)
       
        }
        
        var orderId = component.get("v.recordId");
        var action = component.get("c.getOrderStatus");
        action.setParams({ 'OrderId': orderId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                if(retVal === 'ACTIVATED') { 
                    helper.showDebookWindow(component, event, helper);
                } 
                else if(retVal === 'ACTIVATEDDIRECT')
                {
                     helper.showDebookWindowDirect(component, event, helper);
                }                
                else {
                    helper.showCancelWindow(component, event, helper);
                }                
            }
        });
        $A.enqueueAction(action);
    }, 
    displayError: function (component, event, helper) {
        var orderId = component.get("v.recordId");
        var action = component.get("c.getOrderStatus");
        var cancelDebookErrorLabel = $A.get("$Label.c.Cancel_Debook_Error_Message");
        var debookNotContractedErrorLabel = $A.get("$Label.c.Debook_Order_Not_Contracted_Error");
        var debookContractNotForecastedErrorLabel = $A.get("$Label.c.Debook_Order_Contract_Not_Forecasted_Error");
        var CancelDebookNoProducts = $A.get("$Label.c.Cancel_Debook_No_Products");
        var debookAmendOrder = $A.get("$Label.c.Debook_Amendment_Error");
        
        action.setParams({ 'OrderId': orderId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                                
                if (retVal != undefined && retVal != null && retVal != "") {
                    if(retVal === 'CANCELLEDDEBOOKED'){  
                            component.set("v.message",cancelDebookErrorLabel);
                        	component.set("v.error",true);
                        
                    } 
                    else if(retVal === 'NOTCONTRACTED'){
                        component.set("v.message",debookNotContractedErrorLabel);
                        component.set("v.error",true);
                    }
                    else if(retVal === 'NORENWLOPPTY'){
                        component.set("v.message",debookContractNotForecastedErrorLabel);
                        component.set("v.error",true);
                    }
                    else if(retVal === 'NOORDERPRODUCTS')
                    {
                        component.set("v.message",CancelDebookNoProducts);
                        component.set("v.error",true);
                    }
                    else if(retVal === 'AMENDMENT'){
                        component.set("v.message",debookAmendOrder);
                        component.set("v.error",true);
                    }
                    else{                        
                    }
                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})