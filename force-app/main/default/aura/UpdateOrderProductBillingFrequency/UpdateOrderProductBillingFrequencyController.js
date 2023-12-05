/*
@author : Ramya Ravi
@date 	: 12/02/2021
@purpose: I2C-1072 : Enable 'Mass Update' Capability on the Order for Billing Frequency Changes

**********************************************************************************************************************************************************************************************************************
ChangeHistory

ModifiedBy                      Date                     Requested By                     Description                                                                                                     Tag                                                                                                    <T04>
Nishit S						15-JUN-2022				 I2C-1620						  Enable "One Time" Billing on the "Mass Update of Billing Frequency" option on Order							  <I2C-1620>
**********************************************************************************************************************************************************************************************************************
*/
({
	updateCheck : function(component, event, helper) {
         component.set("v.spinneract",true); 
        console.log("get expected frequency : "+component.get("v.ExpectedBlngFreq"));
		var action = component.get("c.UpdateOrderProductBillingFreq");
        action.setParams({
            recordId : component.get("v.recordId"),
            ExpectedBlngFreq : component.get("v.ExpectedBlngFreq"),
            ChargeTypeStatus: component.get("v.CheckBoxValue")
        }); 
          action.setCallback(this, function(response) {
            var state = response.getState();
            var recdId =  component.get("v.recordId");
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                console.log('retVal :'+ retVal);
                component.set("v.spinneract",false);
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/Order/" + recdId+ "/view",
                      "isredirect": "true"
                    });
                   
                    urlEvent.fire();
                    if(retVal =='Empty')
                    {
                        helper.showWarningToast(component,event,helper); 
                    }
                    else if(retVal =='NoChange')
                    {
                        helper.showNoChangeToast(component,event,helper); 
                    }
                    else if(retVal =='Billed')
                    {
                        helper.showBilledToast(component,event,helper); 
                    }
                    else
                    {
                        helper.showToast(component,event,helper); 
                    } 
                }
        	}
        });       
        $A.enqueueAction(action);    
	},
    getOrderLineStatus :  function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        component.set("v.massUpdateBillingDates",false);
        component.set("v.massUpdateBillingFrequency",false);
        component.set("v.menu",true);
        //component.set("v.disableCheckbox",false);
        /*
		var action = component.get("c.CheckOrderProductBillingFreq");
		action.setParams({
            recordId : component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
		 var state = response.getState();
		if (state === "SUCCESS") 
		{
			var retVal = response.getReturnValue();
			console.log("retVal :" + retVal);
			if(retVal == true)
			{
				component.set("v.isBFInvoicePlan",true);
			}
			else if(retVal == false)
			{
			component.set("v.isBFNInvoice",true);
			}
		}
		else
		{
		console.log("Error in getting Data");
		}
		});
		$A.enqueueAction(action);*/
	 },
     navigateOrderPage : function (component, event, helper) {
         component.set("v.spinneract",true); 
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
    //<I2C-1620> START // Making the checkbox greyed out
    updateCheckbox : function(component, event, helper) { 
        if(component.get("v.CheckBoxValue") && (component.get("v.ExpectedBlngFreq") == 'One-Time' || component.get("v.ExpectedBlngFreq") =='Invoice Plan')){
            component.set("v.CheckBoxValue",false);
        }
    },
    //<I2C-1620> ENDS
    gotoUpdateBillingFrequency : function(component, event, helper){
        console.log('helloo from gotoUpdateBillingFrequency');
        component.set("v.menu",false);
        component.set("v.massUpdateBillingFrequency",true);
        component.set("v.massUpdateBillingDates",false);
    },
    gotoUpdateBillingDates : function(component, event, helper){
        console.log('helloo from gotoUpdateBillingDates');
        component.set("v.menu",false);
        component.set("v.massUpdateBillingDates",true);
        component.set("v.massUpdateBillingFrequency",false);
    },
    checkDatesValid : function(component, event, helper){
        console.log('inside onblur'+component.find("onbdField"));
        var onbdFieldValidity = component.find("onbdField").get("v.validity");
        var btdoFieldValidity = component.find("btdoField").get("v.validity");
        if( (component.get("v.overrideNextBillingDate") != null || component.get("v.billThroughDateOverride") != null) && onbdFieldValidity.valid  && btdoFieldValidity.valid){
            component.set("v.proceedDisabled",false);
        }
        else{
            component.set("v.proceedDisabled",true);
        }
    },
    updateBillingDates1 : function(component, event, helper){
        console.log('helloo from updateBillingDates');
        //console.log(component.get("v.billThroughDateOverride"));
        //console.log(component.get("v.overrideNextBillingDate"));
        component.set("v.spinneract",true); 
        var action1 = component.get("c.updateBillingDates");
        action1.setParams({
            recordId : component.get("v.recordId"),
            billThroughDateOverride : component.get("v.billThroughDateOverride"),
            overrideNextBillingDate: component.get("v.overrideNextBillingDate")
        }); 
        action1.setCallback(this, function(response) {
            var state = response.getState();
            var recdId =  component.get("v.recordId");
            if (state === "SUCCESS") {               
                var retVal = response.getReturnValue();
                console.log('retVal :'+ retVal);
                component.set("v.spinneract",false);
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/r/Order/" + recdId+ "/view",
                        "isredirect": "true"
                    });
                    
                    urlEvent.fire();
                    if(retVal =='Empty')
                    {
                        helper.showWarningToast(component,event,helper); 
                    }
                    else if(retVal.includes('Exception'))
                    {
                        helper.showValidationToast(component,event,helper, retVal);
                    }
                        else
                        {
                            helper.showToast(component,event,helper); 
                        } 
                }

            }
        });       
        $A.enqueueAction(action1);
        
    },
})