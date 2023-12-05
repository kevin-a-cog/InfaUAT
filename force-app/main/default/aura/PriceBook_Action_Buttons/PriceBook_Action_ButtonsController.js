({
    
	clonePricebook : function(component, event, helper) {
       component.set("v.spinneract",true);
        component.set("v.actionType","clone");
        helper.validateCurrPBE(component, event, helper);
        
	},

    onLoad: function(component, event, helper){
        helper.onLoadInit(component, event, helper);
        
    },
    
    updatePricebookEntries : function(component, event, helper){
        component.set("v.spinneract",true);
        component.set("v.actionType","update");
        helper.validateCurrPBE(component, event, helper);
        
          },
    
    getUpdateallPriceBooks : function(component, event, helper){
        component.set("v.showAllPBWarning", false);
        component.set("v.showAllPB", true);
        helper.refreshAllPBhelper(component);
    },
    showAllPBRefresh : function(component, event, helper){
        component.set("v.showAllPBWarning", true);
        
    },
    
    
    handleSelectAllPB: function(component, event, helper) {
        var getID = component.get("v.allPriceBook");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkPB = component.find("checkPB"); 
        if(checkvalue == true){
            for(var i=0; i<checkPB.length; i++){
                checkPB[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkPB.length; i++){
                checkPB[i].set("v.value",false);
            }
        }
        
    },
    
    updateAllPBController : function(component, event, helper) {
        var selectedPB = [];
        var checkvalue = component.find("checkPB");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedPB.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedPB.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selected PriceBooks -' + selectedPB);
        console.log('selected PB length -' + selectedPB.length);
        component.set("v.selectedPB",selectedPB);
        if(selectedPB.length > 0){
            helper.updateAllPBhelper(component, event, helper);}
        else
        {
            helper.messageToast('ERROR!', 'error', 'Please Select atleast one PriceBook to Submit the request.');
        }
    },
    
    
    closeTab : function(component, event, helper){
        helper.closeTab(component);
    },
    
    
    navigateToPricebook : function(component, event, helper){
        helper.navigateToSObject(component, event, component.get("v.recordId"));
    },
    
    navigateToMultiCurrencyMaster : function(component, event, helper){
        helper.navigateToSObject(component, event, component.get("v.pricebookObj.Multi_Currency_Master__c"));
    },
    
    addPricebookUplift : function(component, event, helper){
      
			helper.addPricebookUpliftHelper(component, event, helper);
        	
    },
    
    AddRow : function(component, event, helper){
        helper.AddRow(component, event);
    },
    
    removeRow : function(component, event, helper){
        var index = event.getSource().get("v.tabindex");
        var AllRowsList = component.get("v.lstPricebookUplift");
        AllRowsList.splice(index, 1);
        component.set("v.lstPricebookUplift", AllRowsList);
    },
    
    backtoEdit : function(component, event, helper){
        component.set("v.showPricebookUpliftCard", false);
        component.set("v.showClonePricebookPage", true);
        component.set("v.showAllPB",false);
    },
    
    cancelFlow : function(component, event, helper){
        component.set("v.showPricebookUpliftCard", false);
        component.set("v.showAllPB",false);
        component.set("v.showAllPBWarning", false);
        component.set("v.errMsg", false);
        component.set("v.showClonePricebookPage", false);
    },
    
    //This method is validating the form of Product Uplifts and then calling the save method in helper
    savePricebook : function(component, event, helper){
        //valiadtion of missing fields
        var validation = helper.validation(component, event, 'required');
        //validation of round up to value
        var roundupValidation = helper.validation(component, event, 'roundup');
        var duplicateRecordValidation = helper.validation(component, event, 'duplicate');
        var duplicatePriorityvalidation = helper.validation(component, event, 'duplicatepriority');
        if(validation){
            
                if(duplicatePriorityvalidation){
                    if(duplicateRecordValidation){
                        var spinner = component.find('lx-spinner1');
                        $A.util.removeClass(spinner, "slds-hide");
                        $A.util.addClass(spinner, "slds-show");
                        helper.savePricebookHelper(component, event, helper);
                    }
                else{
                    helper.messageToast('ERROR!', 'error', 'Duplicate Records');
                }
            }
                 else{
                        helper.messageToast('ERROR!', 'error', 'Duplicate Priority');
                    }   
            }
            
        else{
            helper.messageToast('ERROR!', 'error', 'There are missing required fields, please review.');
        }
    },
    
    savePricebookUpliftController : function(component, event, helper){
        var validation = helper.validation(component, event, 'required');
        //validation of round up to value
        var roundupValidation = helper.validation(component, event, 'roundup');
        var duplicateRecordValidation = helper.validation(component, event, 'duplicate');
        var duplicatePriorityvalidation = helper.validation(component, event, 'duplicatepriority');
        if(validation){
            
                if(duplicatePriorityvalidation){
                    if(duplicateRecordValidation){
                        var spinner = component.find('lx-spinner1');
                        $A.util.removeClass(spinner, "slds-hide");
                        $A.util.addClass(spinner, "slds-show");
                        helper.savePricebookUpliftHelper(component, event, helper);
                    }
                else{
                    helper.messageToast('ERROR!', 'error', 'Duplicate Records');
                }
                }
                    else{
                        helper.messageToast('ERROR!', 'error', 'Duplicate Priority');
                    }   
             }
            
        
        else{
            helper.messageToast('ERROR!', 'error', 'There are missing required fields, please review.');
        }
    }
})