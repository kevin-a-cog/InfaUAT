({
    //This method is to get current Pricebook details
	getCurrentPricebookDetails : function(component, event) {
		var action1 = component.get("c.getCurrentPriceBook");
        var today = new Date();
        today = String(today.getMonth() + 1).padStart(2, '0') + '/' + String(today.getDate()).padStart(2, '0') + '/' + today.getFullYear();

        action1.setParams({
            priceBookId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.pricebookObj", response.getReturnValue());
               	component.set("v.clonedPriceBookName", 'Archived__' + component.get("v.pricebookObj.Name") + '__' + today);
                var spinner = component.find('mySpinner-Tiers');
                $A.util.addClass(spinner, "slds-hide"); 
                $A.util.removeClass(spinner, "slds-show"); 
            }
        });
        $A.enqueueAction(action1);
	},
    
    
    //This method is to get current Pricebook details
	onLoadInit : function(component, event, helper) {
        
		var action1 = component.get("c.onLoadCurrent");
        action1.setParams({
            priceBookId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.pricebookObjCurr", response.getReturnValue());
               	if((component.get("v.pricebookObjCurr.IsActive") && component.get("v.pricebookObjCurr.IsStandard")) ||(component.get("v.pricebookObjCurr.IsActive") && !component.get("v.pricebookObjCurr.IsStandard") && component.get("v.pricebookObjCurr.Primary__c")) )
                    component.set("v.refreshPriceBook",true);
                if(component.get("v.pricebookObjCurr.IsActive") && !component.get("v.pricebookObjCurr.IsStandard") && component.get("v.pricebookObjCurr.Primary__c"))
                    component.set("v.customPriceBook",true);
                if(component.get("v.pricebookObjCurr.Sync_Status__c") == "Completed")
                    component.set("v.syncStatus",true);
                if(component.get("v.pricebookObjCurr.IsActive") && component.get("v.pricebookObjCurr.IsStandard"))
                    component.set("v.standardPriceBook",true);
                 
            }
        });
        $A.enqueueAction(action1);
        
       
	},
    
    validateCurrPBE : function(component,event,helper){
    	 var action2 = component.get("c.getCurrencyRates");
        action2.setParams({
            priceBookId : component.get("v.recordId")
        });
       
        action2.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnMsg = response.getReturnValue();
                component.set("v.retmsg", response.getReturnValue());
                if(returnMsg == "Clone and Refresh" && component.get("v.actionType") == "clone")
                	helper.clonePricebookHelper(component, event, helper);
                else if((returnMsg == "Clone and Refresh" || returnMsg == "Refresh") && component.get("v.actionType") == "update")
                    helper.updatePricebookEntriesHelper(component, event, helper);
                else if(returnMsg == "CurrencyNotAvailable")
                    helper.messageToast('ERROR!', 'error', 'One of the currency added under Currency Conversion Rate of the PriceBook is not added in Standard PriceBook. Please add the currency under Standard PriceBook and try again.');
                else{
                    if(returnMsg == "Refresh")
                        returnMsg = "There are no PriceBook Entries under the PriceBook. So you cannot Clone this PriceBook.";
                    helper.messageToast('ERROR!', 'error', returnMsg);
                	}
        		component.set("v.spinneract",false);
            }
        });
         $A.enqueueAction(action2);
        
    }, 
    
    
    
    clonePricebookHelper : function(component, event, helper) {
        
              helper.getCurrentPricebookDetails(component, event);
              component.set("v.showClonePricebookPage", true);
        	var today = new Date();
        	component.set('v.startDate', today.getFullYear() + "-" + today.getMonth()  + "-" + today.getDate());
       
        component.set('v.endDate', today.getFullYear() + "-" + (today.getMonth() + 3) + "-" + today.getDate());
            
    },
    
    addPricebookUpliftHelper : function(component, event, helper) {
        var action = component.get("c.checkPriceBookName");
            action.setParams({
                newPricebook : component.get("v.clonedPriceBookName")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == "SUCCESS"){
                    if(response.getReturnValue())
                    {
                        helper.messageToast('Warning!', 'warning', 'Duplicate PriceBook Name.');
                    }
                    else
                    {
                        helper.getPricebookUpliftFields(component, event);
                        component.set("v.showClonePricebookPage", false);
                        component.set("v.showPricebookUpliftCard", true);
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    updatePricebookEntriesHelper : function(component, event, helper) {
    
        if(!component.get("v.standardPriceBook"))
        {   
        
        	helper.getCurrentPricebookDetails(component, event);
        	helper.getPricebookUpliftFields(component, event);
           
            component.set("v.showPricebookUpliftCard", true);
        	component.set("v.showOnlyPricebookUpliftCard", true);
            
    	}
        else
        	helper.refreshStandardPBHelper(component, event, helper);
        
            },
    
    //This method is to close the tab
    closeTab: function(component) {
        component.set("v.showClonePricebookPage", false);
        component.set("v.showPricebookUpliftCard", false);
        component.set("v.showAllPB",false);
        component.set("v.showAllPBWarning", false);
        component.set("v.errMsg", false);
    },
    
    //This method is to navigate to given SObject according to the ID received in parameters
    navigateToList : function(component, event, listViewId, sObject){
        var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listViewId,
                "listViewName": null,
                "scope": sObject
            });
            navEvent.fire();
    },
    
    navigateToSObject : function(component, event, recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
        });
        navEvt.fire();
    },
    
    refreshAllPBhelper : function(component, event, helper){
        var action7 = component.get("c.getRefreshAllPB");
        
        action7.setParams({
            priceBookId : component.get("v.recordId")
        });
        action7.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.allPriceBook", response.getReturnValue());
               	var spinner = component.find('lx-spinner1');
                $A.util.addClass(spinner, "slds-hide"); 
                $A.util.removeClass(spinner, "slds-show"); 
            }
            else
            {
                component.set("v.errMsg",true);
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.showClonePricebookPage", false);
                component.set("v.showPricebookUpliftCard", false);
                component.set("v.showAllPB",false);
                component.set("v.showAllPBWarning", false);
            }
        });
        $A.enqueueAction(action7);
    },
    
    updateAllPBhelper : function(component, event, helper){
        var action8 = component.get("c.updateAllPB");
        
        action8.setParams({
            PBIds : component.get("v.selectedPB")
        });
        action8.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.navigateToList(component, event, "00B3f000000smx0EAA","Pricebook2");
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                component.set("v.errMsg",true);
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.showClonePricebookPage", false);
                component.set("v.showPricebookUpliftCard", false);
                component.set("v.showAllPB",false);
                component.set("v.showAllPBWarning", false);
            }
        });
        $A.enqueueAction(action8);
    },
    
    //This method is to get picklist values from the fields of Pricebook Uplift object
    getPricebookUpliftFields : function(component, event){
        var picklist_fields = ["Product_Family__c","Pricing_Business_Model__c","Family__c","Forecast_Product__c","Processing_Engine__c","Delivery_Method__c"];
        var cmp_attributes = ["v.Product_Family__c","v.Pricing_Business_Model__c","v.Family__c","v.Forecast_Product__c","v.Processing_Engine__c","v.Delivery_Method__c"];
        var action2 = component.get("c.getPage");
        action2.setCallback(this, function(response){
			var state = response.getState();
            if(state === "SUCCESS"){
                var values = response.getReturnValue();
                for(var k=0;k < picklist_fields.length;k++){
                    var picklist_field_values = values.optionsMap[picklist_fields[k]];
                    var picklist_values = [];
                    picklist_values.push({value : '', label : 'All', selected : Boolean('TRUE')});
                    for(var key in picklist_field_values) {
                        picklist_values.push({value: key, label:picklist_field_values[key]});
                    }
                    component.set(cmp_attributes[k], picklist_values); 
                }
                var action5 = component.get("c.getPricebookUplifts");
                action5.setParams({
                    priceBookId : component.get("v.recordId")
                });
                action5.setCallback(this, function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        component.set("v.lstPricebookUplift", response.getReturnValue());
                        if(component.get("v.lstPricebookUplift").length == 0){
                            this.AddRow(component, event);
                        }
                        var spinner = component.find('lx-spinner1');
                        $A.util.removeClass(spinner, "slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                });
                $A.enqueueAction(action5);
            }            
        });
        $A.enqueueAction(action2);
    },
    
    refreshStandardPBHelper : function(component, event, helper){
        
        var action5 = component.get("c.refreshStandardPB");
        action5.setParams({
            priceBookId : component.get("v.recordId")
        });
        action5.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.messageToast('SUCCESS!', 'success', 'The Refresh request is submitted successfully !!!');
                helper.navigateToSObject(component, event, response.getReturnValue());
                $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action5);
    },
    
    //THis method is to save the cloned pricebook and pricebook uplift records
    savePricebookHelper : function(component, event, helper){
        component.set("v.pricebookObj.Name", component.get("v.clonedPriceBookName"));
        var action3 = component.get("c.savePricebookAddPricebookUplift");
        action3.setParams({
            newPricebook : component.get("v.pricebookObj"),
            lstPricebookUpliftString : JSON.stringify(component.get("v.lstPricebookUplift"))
        });
        action3.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.navigateToSObject(component, event, response.getReturnValue());
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                component.set("v.errMsg",true);
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.showClonePricebookPage", false);
                component.set("v.showPricebookUpliftCard", false);
                component.set("v.showAllPB",false);
                component.set("v.showAllPBWarning", false);
                var spinner = component.find('lx-spinner1');
                $A.util.addClass(spinner, "slds-hide");
                $A.util.removeClass(spinner, "slds-show");
            }
        });
        $A.enqueueAction(action3);
    },
    
    //This method is to save Pricebook Uplift and edit existing pricebook and create new pricebook entries
    savePricebookUpliftHelper : function(component, event, helper){
        var action4 = component.get("c.savePricebookUplift");
        action4.setParams({
            oldPricebookId : component.get("v.recordId"),
            newPricebook : component.get("v.pricebookObj"),
            lstPricebookUpliftString : JSON.stringify(component.get("v.lstPricebookUplift"))
        });
        action4.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                helper.navigateToSObject(component, event, response.getReturnValue());
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                component.set("v.errMsg",true);
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.showClonePricebookPage", false);
                component.set("v.showPricebookUpliftCard", false);
                component.set("v.showAllPB",false);
                component.set("v.showAllPBWarning", false);
                var spinner = component.find('lx-spinner1');
                $A.util.addClass(spinner, "slds-hide");
                $A.util.removeClass(spinner, "slds-show");
            }
        });
        $A.enqueueAction(action4);
    },
    
    //THis method is to add rows for Pricebook Uplift
    AddRow : function(component, event){
        var RowItemList = component.get("v.lstPricebookUplift");
        RowItemList.push({
            'sobjectType': 'Pricebook_Uplift__c   ',
            'Product_Family__c' : '',
            'Pricing_Business_Model__c' : '',
            'Family__c' : '',
            'Forecast_Product__c' : '',
            'Processing_Engine__c' : '',
            'Percentage__c' : 0,
            'Round_up_To__c' : 10,
            'Priority__c' : 1,
        });
        component.set("v.lstPricebookUplift", RowItemList);
    },
    
    //This method is to validate any kind of scenario according to the type of the validation
    validation : function(component, event, type){
        if(type == 'required'){
            for(var key in component.get("v.lstPricebookUplift")){
                var productUplift = component.get("v.lstPricebookUplift")[key];
                if((component.get("v.lstPricebookUplift")[key].Percentage__c === '' || component.get("v.lstPricebookUplift")[key].Percentage__c === null)|| (component.get("v.lstPricebookUplift")[key].Round_up_To__c === '' || component.get("v.lstPricebookUplift")[key].Round_up_To__c === null) || (component.get("v.lstPricebookUplift")[key].Priority__c === '' || component.get("v.lstPricebookUplift")[key].Priority__c === null)){
                    return false;
                }
        	}
        }
        if(type == 'roundup'){
            for(var key in component.get("v.lstPricebookUplift")){
                var productUplift = component.get("v.lstPricebookUplift")[key];
                if(component.get("v.lstPricebookUplift")[key].Round_up_To__c != 1 && (Math.log10(component.get("v.lstPricebookUplift")[key].Round_up_To__c)) != Math.ceil(Math.log10(component.get("v.lstPricebookUplift")[key].Round_up_To__c)) || component.get("v.lstPricebookUplift")[key].Round_up_To__c > 10000){
                    return false;
                }
        	}
        }
        if(type == 'duplicate'){
            for(var key in component.get("v.lstPricebookUplift")){
                for(var key2 in component.get("v.lstPricebookUplift")){
                    if(key != key2){
                      //if((component.get("v.lstPricebookUplift")[key2].Family__c == component.get("v.lstPricebookUplift")[key].Family__c || component.get("v.lstPricebookUplift")[key].Family__c == '' || component.get("v.lstPricebookUplift")[key2].Family__c == '') && (component.get("v.lstPricebookUplift")[key2].Forecast_Product__c == component.get("v.lstPricebookUplift")[key].Forecast_Product__c || component.get("v.lstPricebookUplift")[key].Forecast_Product__c == '' || component.get("v.lstPricebookUplift")[key2].Forecast_Product__c == '') && (component.get("v.lstPricebookUplift")[key2].Product_Family__c == component.get("v.lstPricebookUplift")[key].Product_Family__c || component.get("v.lstPricebookUplift")[key].Product_Family__c == '' || component.get("v.lstPricebookUplift")[key2].Product_Family__c == '') && (component.get("v.lstPricebookUplift")[key2].Pricing_Business_Model__c == component.get("v.lstPricebookUplift")[key].Pricing_Business_Model__c || component.get("v.lstPricebookUplift")[key].Pricing_Business_Model__c == '' || component.get("v.lstPricebookUplift")[key2].Pricing_Business_Model__c == '') && (component.get("v.lstPricebookUplift")[key2].Processing_Engine__c == component.get("v.lstPricebookUplift")[key].Processing_Engine__c || component.get("v.lstPricebookUplift")[key].Processing_Engine__c == '' || component.get("v.lstPricebookUplift")[key2].Processing_Engine__c == '') && (component.get("v.lstPricebookUplift")[key2].Delivery_Method__c == component.get("v.lstPricebookUplift")[key].Delivery_Method__c || component.get("v.lstPricebookUplift")[key].Delivery_Method__c == '' || component.get("v.lstPricebookUplift")[key2].Delivery_Method__c == '')){
                        if(component.get("v.lstPricebookUplift")[key2].Family__c == component.get("v.lstPricebookUplift")[key].Family__c && component.get("v.lstPricebookUplift")[key2].Forecast_Product__c == component.get("v.lstPricebookUplift")[key].Forecast_Product__c && component.get("v.lstPricebookUplift")[key2].Product_Family__c == component.get("v.lstPricebookUplift")[key].Product_Family__c && component.get("v.lstPricebookUplift")[key2].Pricing_Business_Model__c == component.get("v.lstPricebookUplift")[key].Pricing_Business_Model__c && component.get("v.lstPricebookUplift")[key2].Processing_Engine__c == component.get("v.lstPricebookUplift")[key].Processing_Engine__c && component.get("v.lstPricebookUplift")[key2].Delivery_Method__c == component.get("v.lstPricebookUplift")[key].Delivery_Method__c ){     
                           return false;
                        }
                    }
                }
            }
        }
        if(type == 'duplicatepriority'){
            for(var key in component.get("v.lstPricebookUplift")){
                for(var key2 in component.get("v.lstPricebookUplift")){
                    if(key != key2){
                        if(component.get("v.lstPricebookUplift")[key2].Priority__c == component.get("v.lstPricebookUplift")[key].Priority__c ){     
                           return false;
                        }
                    }
                }
            }
        }
        return true;
    },
    
    //THis method is to view the messages in the page
    messageToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
})