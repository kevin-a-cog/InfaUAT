({
	   
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var actionType;
        var objectType;
        var optionselected = component.get("v.value");
        var optionselected1 = component.get("v.value1");
        var optionselected2 = component.get("v.value2");
        component.set("v.isProcessing",true);
        
        if(optionselected == "QuotePrimary")
        {
            actionType = "Primary";
            objectType = "Quote";
        }
        if(optionselected == "Ordered")
        {
            actionType = "Ordered";
            objectType = "Quote";
        }
        if(optionselected == "SubmitApproval")
        {
            actionType = "Approval";
            objectType = "Quote";
        }
        if(optionselected == "RecallApproval")
        {
            actionType = "RecallApproval";
            objectType = "Quote";
        }
        
        if(optionselected == "FullDebook")
        {
            actionType = "FullDebook";
            objectType = "Quote";
        }
        
        if(optionselected1 == "Contracted")
        {
            actionType = "Contracted";
            objectType = "Order";
        }
        if(optionselected1 == "Activation")
        {
            actionType = "Activation";
            objectType = "Order";
        }
        if(optionselected1 == "ActivationAmend")
        {
            actionType = "ActivationAmendCustomBilling";
            objectType = "Order";
        }
        if(optionselected1 == "RunBatchRevAgrr")
        {
            actionType = "RunBatchRevAgrr";
            objectType = "Order";
        }
        if(optionselected1 == "RunBatchPONum")
        {
            actionType = "RunBatchPONum";
            objectType = "Order";
        }
        
        if(optionselected2 == "RenewalQuote")
        {
            actionType = "RenewalQuote";
            objectType = "Contract";
        }
        if(optionselected2 == "Amend")
        {
            actionType = "Amend";
            objectType = "Contract";
        }
        if(optionselected2 == "RenewalOppty")
        {
            actionType = "RenewalOppty";
            objectType = "Contract";
        }
        
        
        var action = component.get("c.fromLight");
        action.setParams({
            "recordId": recordId,
            "actionType": actionType,
            "objectType": objectType
        });
        
            action.setCallback(this, function(response) {
            var state = response.getState();
			var Message = response.getReturnValue() ;
            
            component.set("v.isProcessing",false);
                
            if(actionType == "ActivationAmendCustomBilling")
            	helper.goToRelatedHelper(component,event,helper);
        	else
            	helper.goToRecordHelper(component,event,helper);
	
        });


                
		$A.enqueueAction(action);
       
//        component.set("v.info",true);
        
    },
    onLoad: function(component, event, helper){
      var recordId = component.get("v.recordId");
        
        if(recordId.indexOf("a1q")==0)
            component.set("v.posQuote",true);
        if(recordId.indexOf("801")==0)
        	component.set("v.posOrder", true);
        if(recordId.indexOf("800")==0)
        	component.set("v.posContract", true);
        
        //var action = component.get("c.currentUser");
        //$A.enqueueAction(action);
        
        var action = component.get("c.currentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
			var userType = response.getReturnValue() ;
           
            if(userType == "SOG" || (userType == "Finance" && recordId.indexOf("801") == 0))
				component.set("v.SOG",true);
	
        });

        $A.enqueueAction(action);
        
        
    },
    onSelect: function(component,event,helper){
        component.set("v.buttonLabel",true);
        if(component.get("v.value") == "Ordered")
	        component.set("v.createorder",true);
        if(component.get("v.value1") == "ActivationAmend")
            component.set("v.activateAmend",true);
    },
    proceed: function(component,event,helper){
       component.set("v.createorder",false); 
       component.set("v.activateAmend",false);
    },
    goToRecord: function(component,event,helper){
        helper.goToRecordHelper(component,event,helper);
    },
    goToRelated : function(component,event,helper){
        helper.goToRelatedHelper(component,event,helper);
    }
    
})