/* Helper Class for Add Products Page*/
({
    //Helps in fetching the Products based on the keyword entered in the searchbar by the user.
    searchProdRecords : function(component,event,helper)
    {
        var action = component.get("c.productSearchBar");
        action.setStorable();
        var fieldQueryString = component.get("v.fieldStrQry"); 
        var lstProducts = JSON.stringify(component.get("v.pillsList"));
         
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'pillsList' : lstProducts,
            'fieldQry'  : fieldQueryString
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var storeResponse = response.getReturnValue();
                // set lstProducts list with return value from server.
                component.set("v.lstProducts", storeResponse);

             }  
             else 
             {
                 var navEvt = $A.get("e.force:navigateToSObject");
						navEvt.setParams({
							"recordId": engId,
            				"isredirect": "false"
        					});
						navEvt.fire();
						var toastEvent = $A.get("e.force:showToast");                          
						toastEvent.setParams({
    						title: "Sorry!",
    						message: storeResponse,
    						type: "error"
							});
						toastEvent.fire();
             }
        });
        
        $A.enqueueAction(action);
    },
    
    //Helps in setting up the fieldSet to display the appropriate columns in the Product Resultset.
    getFields : function (component, event, helper)
    {
        var action = component.get("c.getFields"); 
        var self = this; 
        var typeName = "Product2"; 
        var fsName = "AddProductsFieldSet"; 
        action.setParams({
            typeName: typeName,
            fsName: fsName
        }); 

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var fields = response.getReturnValue();
                
                component.set("v.fieldarray", fields);
                
                // Combine all the fields into a string, to use in Query 
                var fieldStrQuery = ""; 

                for (var key in fields)
                {
                    if (!fields.hasOwnProperty(key)) continue;
                    var obj = fields[key];
                    fieldStrQuery += (obj.fieldPath + ","); 
                }
                // Remove comma at the end of fieldStrQuery
                fieldStrQuery = fieldStrQuery.replace(/,\s*$/, "");
                component.set("v.fieldStrQry", fieldStrQuery);
            }
            else 
            {
                var navEvt = $A.get("e.force:navigateToSObject");
						navEvt.setParams({
							"recordId": engId,
            				"isredirect": "false"
        					});
						navEvt.fire();
						var toastEvent = $A.get("e.force:showToast");                          
						toastEvent.setParams({
    						title: "Sorry!",
    						message: fields,
    						type: "error"
							});
						toastEvent.fire();
            }
        });
        $A.enqueueAction(action);  
    },
    
    //Helps in Saving the Selected Products to the DealRegistration Product Object.
	save : function(component) 
    {
        debugger;
        var successMsg = $A.get("$Label.c.PRM_DealProductAddSuccess1");
        var dealId = component.get("v.recordId");
        var lstProducts = component.get("v.pillsList");
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts))
        {
            var action = component.get("c.saveSelectedProducts");
            var oppProdRecords = JSON.stringify(lstProducts);
            if(undefined !== lstProducts.length && lstProducts.length === 1)
            {
                successMsg = $A.get("$Label.c.PRM_DealProductAddSuccess2");
            }
            action.setParams({
                dealProdRecords : oppProdRecords,
                dealRegId : dealId
            });
            action.setCallback(this,function(a){
                var state = a.getState();
                if(state === "SUCCESS")
                {
                    debugger;
                    var StoreResponse = a.getReturnValue();
                    if(StoreResponse==='Success')
                    {
                        var recId =  component.get("v.recordId");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: successMsg,
    						type: "success"
                        });
                        toastEvent.fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recId,
                            "isredirect": "true",
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }
                    else
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Failed!",
                            message: StoreResponse,
                            type: "error"
                        });
                        toastEvent.fire();
                        this.showFailedAction(component, event, StoreResponse);
                    }
                }
                else
                {
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Failed!",
                            message: StoreResponse,
                            type: "error"
                        });
                        toastEvent.fire();
                        this.showFailedAction(component, event, StoreResponse);
                }
            });
            $A.enqueueAction(action);
        }
    },

    //Helps in fetching the already saved DealRegistration products and displaying them on the pillList at the bottom.
    pullSavedProducts : function(component,event,helper)
    {
        var action = component.get("c.getSavedDealRegProducts");
        action.setParams({
            'DealRegId': component.get("v.recordId")
        });
        //set callback
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS")
            {
                //store the return response from server 
                var StoreResponse = response.getReturnValue();
                // set productList to show the available products
                component.set("v.pillsList2", StoreResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Helps in navigating to the detailed view of the Sobject
    goToDetailView : function(component,event,recId) 
    {
        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recId,
            				"isredirect": "false"
                        });
                        navEvt.fire();
    },
    
    //Helps in navigating to the related view of the Sobject
    goToRelatedView : function(component,event,recId) 
    {
        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recId,
                            "isredirect": "true",
                            "slideDevName": "related"
                        });
                        navEvt.fire();
    },
    
    //Helps in displaying the Validation Errors
    showValidationError : function(component,event,errorMsg) 
    {
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
    						title: "Sorry!",
    						message: errorMsg,
    						type: "error"
						});
            			toastEvent.fire();
    },
    
    //Helps in displaying the failed action message
    showFailedAction : function(component,event,failedMsg) 
    {
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Failed!",
                        message: failedMsg,
                        type: "error"
                    });
                    toastEvent.fire();
    },
    
    //Helps in displaying the success Message
    showSuccessMsg : function(component,event,successMsg) 
    {
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: successMsg,
    						type: "success"
                        });
                        toastEvent.fire();
    }
})