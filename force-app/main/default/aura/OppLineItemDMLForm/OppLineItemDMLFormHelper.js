({
	salesPriceValidate : function (component, event) {
		// debugger; 

		var fieldsValidated = true; 
		var oliWrapperList = component.get("v.oliWrapperList"); 
		var errorMessage = []; 

		if (oliWrapperList.length > 0) {
			for (var key in oliWrapperList) {
				if (!oliWrapperList.hasOwnProperty(key)) continue; 

				var oliWrapper = oliWrapperList[key]; 
				
				if (oliWrapper.UnitPrice == null) {
					// Add error class onto input box 
					if (oliWrapperList.length == 1) {
						component.find("editPriceInput").set("v.class", "slds-input slds-has-error"); 
					}
					else {
						component.find("editPriceInput")[key].set("v.class", "slds-input slds-has-error"); 
					}
					
					// Show errorPopUp Box 
					$A.util.addClass(component.find("errorPopUpBox"), 'slds-show');

					// Display error msg at the bottom
					var errString = 'Item ' + (parseInt(key) + 1 ) + ' has errors in these fields: Sales Price.';
	                errorMessage.push(errString);
	                 
	                component.set("v.ErrorMsgList", errorMessage);    
	               
	                fieldsValidated = false;
				}
				else {
					
					if (oliWrapperList.length == 1) {
						component.find("editPriceInput").set("v.class" , "slds-input");
					}
					else {
						component.find("editPriceInput")[key].set("v.class" , "slds-input");
					}
					
					if (fieldsValidated) {
						$A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');
                    	$A.util.removeClass(component.find("errorPopUpBox"), 'slds-show');  
					}
				}
			}
		}

		component.set("v.saveBtnClicked", false);
		return fieldsValidated; 
	},

	saveRecords : function (component, event) {
		// debugger; 
       
        var localOLI = component.get("v.oli");
        var recOpportunityLineItem = JSON.stringify(localOLI);
       console.log('@Developer-->recOpportunityLineItem-->' + recOpportunityLineItem);
        var action = component.get("c.saveOpportunityLineItem"); 

        action.setParams({
            "recOppLineItem" : recOpportunityLineItem 
        }); 

        action.setCallback(this, function(response){
            var state = response.getState(); 

            if (state === "SUCCESS") {
            	// debugger; 
				var resp = response.getReturnValue();
				if(resp === 'true'){
					var closeModalEvt = $A.get("e.c:closeModalEvent"); 
					closeModalEvt.setParams({
						"type" : "saveclose" 
					}); 
					closeModalEvt.fire(); 
				}
				else{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title : 'Error',
						message: resp,
						duration:' 5000',
						key: 'info_alt',
						type: 'error',
						mode: 'pester'
					});
					toastEvent.fire();
				}
                
            }
            else {
                debugger; 
            }
        }); 

        $A.enqueueAction(action);
        component.set("v.saveBtnClicked", false);
	}
})