({
	myAction : function(component, event, helper) {
        var QuoteOrderDiffAmount = $A.get("$Label.c.Quote_Order_Diff_Amount_Message");
        var PaymentTermMissing = $A.get("$Label.c.Payment_Term_Missing_Msg");
        var BillPlansMissing = $A.get("$Label.c.NoInvSch");
        var BSBTMissing = $A.get("$Label.c.Billing_Schedule_Transaction_Missing");
        var TaxNeedsValidation = $A.get("$Label.c.TaxExemptNeedsValidation");
        var AdjustCodeMissing = $A.get("$Label.c.AdjustmentReasonCodeMissing");
        
		var action = component.get("c.getDifferenceAmount");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'GREATERTHAN1'){  
                            component.set("v.msg",QuoteOrderDiffAmount);
                        	component.set("v.error",true);
                        
                    } 
                    else if(retVal === 'LESSTHAN1'){                        
                        component.set("v.error",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action);
        
        //Call action 2 on INIT - Payment Term
        var action2 = component.get("c.checkPaymentTerm");
        action2.setParams({
            recordId : component.get("v.recordId")
        });
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'NOTAVAILABLE'){  
                            component.set("v.payTermMsg",PaymentTermMissing);
                        	component.set("v.payTermError",true);
                        
                    } 
                    else if(retVal === 'AVAILABLE'){                        
                        component.set("v.payTermError",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action2);
        
        //Call action 3 on INIT - Bill Plans or Invoice Schedules
        var action3 = component.get("c.checkBillPlans");
        action3.setParams({
            recordId : component.get("v.recordId")
        });
        action3.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'NOTEXIST'){  
                            component.set("v.invSchMsg",BillPlansMissing);
                        	component.set("v.invSchError",true);
                        
                    } 
                    else if(retVal === 'EXIST'){                        
                        component.set("v.invSchError",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action3);
        
        //Call action 4 on INIT - Billing Schedules and Billing Transactions
        var action4 = component.get("c.checkBSBT");
        action4.setParams({
            recordId : component.get("v.recordId")
        });
        action4.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'NOTEXIST'){  
                            component.set("v.BSBTMsg",BSBTMissing);
                        	component.set("v.BSBTError",true);
                        
                    } 
                    else if(retVal === 'EXIST'){                        
                        component.set("v.BSBTError",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action4);
        
        //Call action 5 on INIT - Exempt Status is Needs Validation 
        var action5 = component.get("c.checkExemptStatus");
        action5.setParams({
            recordId : component.get("v.recordId")
        });
        action5.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'NEEDSVALIDATION'){  
                            component.set("v.exemptMsg",TaxNeedsValidation);
                        	component.set("v.exemptError",true);
                        
                    } 
                    else if(retVal === 'OTHER'){                        
                        component.set("v.exemptError",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action5); 
        
        //Call action 6 on INIT - Adjustment Reason Code
        var action6 = component.get("c.checkAdjustCode");
        action6.setParams({
            recordId : component.get("v.recordId")
        });
        action6.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                     
                    if(retVal === 'NOTEXIST'){  
                            component.set("v.AdjustCodeMsg",AdjustCodeMissing);
                        	component.set("v.AdjustCodeErr",true);
                        
                    } 
                    else if(retVal === 'EXIST'){                        
                        component.set("v.AdjustCodeErr",false); 
                    }
                    else{                        
                    }                    
                }
        	}
        });
        $A.enqueueAction(action6);
	}
})