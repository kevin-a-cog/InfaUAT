({
	  
    onLoad: function(component, event, helper){
      var recordId = component.get("v.recordId");
        
        var action = component.get("c.onLoadCmp");
        action.setParams({
            "orderId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			var InvMessage = response.getReturnValue() ;
			component.set("v.InvMessage",response.getReturnValue());
            if(!InvMessage)
            {
                component.set("v.goNext",true);
                component.set("v.goBack",false);
            }
            else
            {
                component.set("v.goNext",false);
                component.set("v.goBack",true);
            }
	
        });

        $A.enqueueAction(action);
        
    },
    
    goToOrder: function(component, event, helper){
        var recordId = component.get("v.recordId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      "recordId": recordId,
      "slideDevName": "detail"
    });
    navEvt.fire();
    },
    
    doAction: function(component, event, helper){
        
    var recordId = component.get("v.recordId");
        component.set("v.spinneract",true);
        var action = component.get("c.createBillingScheduleTransaction");
        var state;
        var type;
        type = "New";
        action.setParams({
            "orderId": recordId,
            "type": type
        });
        action.setCallback(this, function(response) {
            state = response.getState();
            var CreateMessage = response.getReturnValue() ;
            
            if(!CreateMessage){
            if(response.getState() == 'SUCCESS')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",true);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.goBack",false);
                component.set("v.BSBTCANSUC",false);
                component.set("v.BSBTCANFAIL",false);
                
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        		"title": "Success!",
        		"message": "Billing Transactions has been created successfully."
    			});
    
            }
        }
              else{
				component.set("v.spinneract",false);
                component.set("v.InvMessage",response.getReturnValue());
                component.set("v.goBack",true);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.BSBTCANSUC",false);
                component.set("v.BSBTCANFAIL",false);
                  
                  }
            
                
            if(response.getState() == 'ERROR')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",true);
                component.set("v.goNext",false);
                component.set("v.goBack",false);
                component.set("v.BSBTCANSUC",false);
                component.set("v.BSBTCANFAIL",false);
               // alert(response.getError()[0].message);
                component.set("v.ErrorMessage",response.getError()[0].message);
                
            }
            
        });

        $A.enqueueAction(action);
        
		if(state == 'SUCCESS'){
            toastEvent.fire();
		}
    },
    
    gotoBS : function (component, event, helper) {
    var relatedListEvent = $A.get("e.force:navigateToRelatedList");
    relatedListEvent.setParams({
        "relatedListId": "Billing_Schedules__r",
        "parentRecordId": component.get("v.recordId")
    });
    relatedListEvent.fire();
},
    cancelBS : function(component, event, helper){
       var recordId = component.get("v.recordId"); 
        component.set("v.spinneract",true);
        var action = component.get("c.cancelBillingScheduleTransaction");
        var state;
        action.setParams({
            "orderId": recordId
        });
        action.setCallback(this, function(response) {
            state = response.getState();
            var CancelMessage = response.getReturnValue() ;
            if(!CancelMessage){
            if(response.getState() == 'SUCCESS')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.BSBTCANSUC",true);
                component.set("v.BSBTCANFAIL",false);
                
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        		"title": "Success!",
        		"message": "Pending Billing Transactions has been cancelled successfully."
    			});
                
    
            }
            }
            
            else{
              component.set("v.spinneract",false);
              component.set("v.InvMessage",response.getReturnValue());
              component.set("v.goBack",true);
              component.set("v.BSBTSUC",false);
              component.set("v.BSBTFAIL",false);
              component.set("v.goNext",false);
              component.set("v.BSBTCANSUC",false);
              component.set("v.BSBTCANFAIL",false);
                  }
            
            if(response.getState() == 'ERROR')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.BSBTCANSUC",false);
                component.set("v.BSBTCANFAIL",true);
                
                component.set("v.ErrorMessage",response.getError()[0].message);
                
            }
            
        });

        $A.enqueueAction(action);
        if(state == 'SUCCESS')
            toastEvent.fire();
    },
     cancelBSRebill : function(component, event, helper){
       var recordId = component.get("v.recordId"); 
        component.set("v.spinneract",true);
        var action = component.get("c.cancelandRegenerate");
        var state;
        action.setParams({
            "orderId": recordId
        });
        action.setCallback(this, function(response) {
            state = response.getState();
            var CancelMessage = response.getReturnValue() ;
            if(!CancelMessage){
            if(response.getState() == 'SUCCESS')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.BSBTCANSUC",true);
                component.set("v.BSBTCANFAIL",false);
                
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        		"title": "Success!",
        		"message": "Billing Transactions created as per new Bill Plan."
    			});
                
    
            }
            }
            
            else{
              component.set("v.spinneract",false);
              component.set("v.InvMessage",response.getReturnValue());
              component.set("v.goBack",true);
              component.set("v.BSBTSUC",false);
              component.set("v.BSBTFAIL",false);
              component.set("v.goNext",false);
              component.set("v.BSBTCANSUC",false);
              component.set("v.BSBTCANFAIL",false);
                  }
            
            if(response.getState() == 'ERROR')
            {
                component.set("v.spinneract",false);
                component.set("v.BSBTSUC",false);
                component.set("v.BSBTFAIL",false);
                component.set("v.goNext",false);
                component.set("v.BSBTCANSUC",false);
                component.set("v.BSBTCANFAIL",true);
                
                component.set("v.ErrorMessage",response.getError()[0].message);
                
            }
            
        });

        $A.enqueueAction(action);
        if(state == 'SUCCESS')
            toastEvent.fire();
    }
    
    
})