({
	doInit : function(component, event, helper) {   
        helper.getPicklistfieldValues(component, 'Order','Cancel_Debook_Reason__c','orderCancelReason');         
		helper.displayError(component,event,helper);
    },
    closeModalOne : function (component, event, helper) {
		helper.navigateOrderPage (component, event, helper);
	},
    
    displayCancelReasonText: function (component, event, helper) {
         var sel = component.find("orderCancelReason");
         var nav =	sel.get("v.value");
         if (nav == "Other") {     
              component.set("v.showCancelReasonText", true);
         }
        else{
            component.set("v.showCancelReasonText", false);
        }
         
    },

    onClickNext: function (component, event, helper) {                
            //alert('Order Updated successfully');
            helper.save(component, event, helper);
     
    },

    closeInfoModal: function (component, event, helper) {
            component.set('v.showDebookModal', false);
            component.set('v.showCancelModal', false);
            component.set('v.initialLoadModal', true);
        	component.set('v.showDebookModalDirect',false);
    },
    closeCancelModal: function (component, event, helper) {
        //component.set('v.showCancelModal', false);
        helper.cancelOrder(component, event, helper);
    },
    debookSave: function (component, event, helper) {
        //component.set('v.showDebookModal', false);
        helper.debookOrder(component, event, helper);
    },
    debookDirectSave: function (component, event, helper) {
        //component.set('v.showDebookModal', false);
        helper.debookDirectOrder(component, event, helper);
    }
})