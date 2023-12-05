({
	getOpportunityLineItems : function(component, event, helper) {
		// debugger; 
		var opportunityId = component.get("v.recordId");
		var action = component.get("c.getOpportunityLineItemsWrapper"); 

		action.setParams({
			opportunityID : opportunityId
		});

		action.setCallback(this, function(response) {
			var state = response.getState(); 

			if (state === "SUCCESS") {
				// debugger; 

				var oliWrapperListServer = response.getReturnValue(); 
				component.set("v.oliWrapperList", oliWrapperListServer); 
			}
			else {
				debugger; 
			}
		}); 

		$A.enqueueAction(action); 
	},

	deleteOpportunityLineItem : function (component, event, helper, deleteID) {
		// debugger; 
		var opportunityId = component.get("v.recordId");
		var action = component.get("c.deleteOpportunityLineItemServer"); 

		action.setParams({
			toBeDeletedOLI_ID : deleteID,
			opportunityID : opportunityId 
		}); 

		action.setCallback(this, function(response){
			var state = response.getState(); 

			if (state === "SUCCESS") {
				// debugger; 

				var oliWrapperListServer = response.getReturnValue(); 
                console.log('oliWrapperList old-- > ' + JSON.stringify(component.get("v.oliWrapperList")));
                console.log('oliWrapperListServer-- > ' + JSON.stringify(oliWrapperListServer));
                
				component.set("v.oliWrapperList", oliWrapperListServer); 
			}
			else {
				alert(state);
                //debugger; 
			}
		}); 

		$A.enqueueAction(action); 
	},

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
						if(component.find("editPriceInput").length > 0)
							component.find("editPriceInput")[0].set("v.class" , "slds-input");
					}
					else {
						if(component.find("editPriceInput")[key].length > 0)
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

		var oliListToSave = component.get("v.oliWrapperList"); 
		var oliListToSave_Serialized = JSON.stringify(oliListToSave);
		var opportunityId = component.get("v.recordId");
        console.log('Developer--> oliListToSave_Serialized' + oliListToSave_Serialized); 
		var action = component.get("c.saveOpportunityLineItem");
		action.setParams({
            oliWrapperList : oliListToSave_Serialized,
            opportunityID : opportunityId
        });

        action.setCallback(this,function(response){
        	var state = response.getState(); 

        	if (state === "SUCCESS") {
        		// debugger; 

				var retVal = response.getReturnValue();
				if(retVal !== 'true'){
					this.showNotification(component,event,this,retVal,'error');
				}
				else{
					var recId =  component.get("v.recordId");                  
					var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';

					var device = $A.get("$Browser.formFactor");

					if (device === "DESKTOP") {
						window.location.assign(sURL);
					}
					else {
						sforce.one.navigateToURL(sURL);
					}
				}
        	}
        	else {
        		debugger; 
        	}
        }); 

        $A.enqueueAction(action);
        component.set("v.saveBtnClicked", false);
	},

	getTransTypeOptions : function (component, event, helper) {
		var action = component.get("c.getTransTypeSelect"); 

		action.setCallback(this,function(response){
        	var state = response.getState(); 

        	if (state === "SUCCESS") {
        		// debugger; 

        		var opts = response.getReturnValue(); 
        		component.set("v.transactionTypeOptions", opts); 
        	}
        	else {
        		debugger; 
        	}
        }); 

        $A.enqueueAction(action);
	},

	showNotification : function(component, event, helper,message,type) {
        var vfMethod = component.get("v.VfPageMethod");
        vfMethod(message,20000,type,function(){});
    }
})