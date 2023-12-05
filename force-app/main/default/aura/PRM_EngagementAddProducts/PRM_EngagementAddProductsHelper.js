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
        action.setCallback(this, function(response)
		{
            var state = response.getState();
            if (state === "SUCCESS")
			{
                var storeResponse = response.getReturnValue();
                
                // set lstProducts list with return value from server.
                component.set("v.lstProducts", storeResponse);
                
                //Re-setting the Pick list values when User serach using Product Search Bar option
                component.find("pForecast").set("v.value", "");
                component.find("pFamily").set("v.value", "");
                component.find("pFamily2").set("v.value", "");

			}  
			else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
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
        var fsName = "PRM_AddProductsFieldSet"; 
        action.setParams({
          typeName: typeName,
          fsName: fsName
        }); 

        action.setCallback(this, function(response)
		{
			var state = response.getState(); 

            if (state === "SUCCESS") 
			{
				var fields = response.getReturnValue();
                
                component.set("v.fieldarray", fields);
                
                // Combine all the fields into a string, to use in Query 
                var fieldStrQuery = ""; 

                for (var key in fields){
                    
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
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
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
		var successMsg = "Products Added Successfully";
		var oppId = component.get("v.recordId");
		var lstProducts = component.get("v.pillsList");
                
		if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts))
		{
			var action = component.get("c.saveSelectedProducts");
			var oppProdRecords = JSON.stringify(lstProducts);
			if(lstProducts.length === 1)
			{successMsg = "Product Added Successfully";}
                    
			action.setParams({
				ProdReqRecords : oppProdRecords,
				EgmtId : oppId
			});
                    
			action.setCallback(this,function(a){
			var state = a.getState();
                        
			if(state === "SUCCESS")
			{
				var StoreResponse = a.getReturnValue();
				component.set("v.pillsList3",StoreResponse);
				var resultset = component.get("v.pillsList3");
				var retMsg;
				for (var i = 0; i < resultset.length; i++) 
				{
					retMsg = resultset[i].statusMsg;
				}
				if(retMsg==='Success')
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
				else if(retMsg==='NeedValidation')
				{                 
					component.set("v.addProductSection1", false);
					component.set("v.addProductSection2", true);                                
				}
				else
				{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Failed!",
						message: retMsg,
						type: "error"
					});
					toastEvent.fire();                            
				}
			}
			else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
			});
			$A.enqueueAction(action);
		}     
    },    
    //Helps in fetching the 1st Level(Product Family and Product Sub-Family) of Controlling and Dependent Values
    fetchPicklistValues: function(component, controllerField, dependentField) 
	{
		// call the server side function  
		var action = component.get("c.getDependentOptionsImpl");
		// pass paramerters [object name , contrller field name ,dependent field name] -
		// to server side function 
 
		action.setParams({
			'objApiName': 'product2',
			'contrfieldApiName': controllerField,
			'depfieldApiName': dependentField
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server (map<string,List<string>>)  
				var StoreResponse = response.getReturnValue();
 
				// once set #StoreResponse to depnedentFieldMap attribute 
				component.set("v.depnedentFieldMap", StoreResponse);
 
				// create a empty array for store map keys(@@--->which is controller picklist values) 
 
				var listOfkeys = []; // for store all map keys (controller picklist values)
				var ControllerField = []; // for store controller picklist value to set on ui field. 
 
				// play a for loop on Return map 
				// and fill the all map key on listOfkeys variable.
				for (var singlekey in StoreResponse) 
				{
					listOfkeys.push(singlekey);
				}
 
				//set the controller field value for ui:inputSelect  
				if (listOfkeys != undefined && listOfkeys.length > 0) 
				{
					ControllerField.push({
					class: "optionClass",
						label: "--- None ---",
						value: "--- None ---"
					});
				}
 
				for (var i = 0; i < listOfkeys.length; i++) 
				{
					ControllerField.push({
					class: "optionClass",
						label: listOfkeys[i],
						value: listOfkeys[i]
					});
				}
				// set the ControllerField variable values to Product Family(controller picklist field)
				component.set("v.productFamily", ControllerField);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
	},
 
 
	fetchDepValues: function(component, ListOfDependentFields)
	{
		// create a empty array var for store dependent picklist values for controller field)  
		var dependentFields = [];
 
		if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) 
		{
			dependentFields.push({
			class: "optionClass",
				label: "--- None ---",
				value: "--- None ---"
			});
		}
		for (var i = 0; i < ListOfDependentFields.length; i++) 
		{
			dependentFields.push({
			class: "optionClass",
				label: ListOfDependentFields[i],
				value: ListOfDependentFields[i]
			});
		}
		// set the dependentFields variable values to Product Sub-Family(dependent picklist field)
		component.set("v.productSubFamily", dependentFields);
		// make disable false for ui:inputselect field 
		component.set("v.isDependentDisable", false);
	},
    
	//Helps in fetching the 2nd Level(Product Sub-Family and Products) of Controlling and Dependent Values
    fetchPicklistValues2: function(component, controllerField, dependentField) 
	{
		// call the server side function  
		var action = component.get("c.getDependentOptionsImpl");
		// pass paramerters [object name , contrller field name ,dependent field name] -
		// to server side function 
 
		action.setParams({
			'objApiName': 'product2',
			'contrfieldApiName': controllerField,
			'depfieldApiName': dependentField
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server (map<string,List<string>>)  
				var StoreResponse = response.getReturnValue();
 
				// once set #StoreResponse to depnedentFieldMap attribute 
				component.set("v.depnedentFieldMap2", StoreResponse);
 
				// create a empty array for store map keys(@@--->which is controller picklist values) 
 
				var listOfkeys = []; // for store all map keys (controller picklist values)
				var ControllerField = []; // for store controller picklist value to set on ui field. 
 
				// play a for loop on Return map 
				// and fill the all map key on listOfkeys variable.
				for (var singlekey in StoreResponse) 
				{
					listOfkeys.push(singlekey);
				}
 
				//set the controller field value 
				if (listOfkeys != undefined && listOfkeys.length > 0) 
				{
					ControllerField.push({
					class: "optionClass",
						label: "--- None ---",
						value: "--- None ---"
					});
				}
 
				for (var i = 0; i < listOfkeys.length; i++) 
				{
					ControllerField.push({
					class: "optionClass",
						label: listOfkeys[i],
						value: listOfkeys[i]
					});
				}
				// set the ControllerField variable values to country(controller picklist field)
				component.set("v.productSubFamily", ControllerField);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
   },
 
 
   fetchDepValues2: function(component, ListOfDependentFields) 
   {
		// create a empty array var for store dependent picklist values for controller field)  
		var dependentFields = [];
 
		if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
		dependentFields.push({
			class: "optionClass",
				label: "--- None ---",
				value: "--- None ---"
			});
		}
		for (var i = 0; i < ListOfDependentFields.length; i++) 
		{
			dependentFields.push({
			class: "optionClass",
				label: ListOfDependentFields[i],
				value: ListOfDependentFields[i]
			});
		}
		// set the dependentFields variable values to Products(dependent picklist field)
		component.set("v.products", dependentFields);
		// make disable false 
		component.set("v.isDependentDisable2", false);
	},
    
    //Helps in fetching the already saved Product Requests and displaying them on the pillList at the bottom.
    pullSavedProducts : function(component,event,helper)
    {
		var action = component.get("c.getSavedProductRequests");
		action.setParams({
			'EgmtId': component.get("v.recordId")
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server 
				var StoreResponse = response.getReturnValue();
 
				// set productList to show the available products
				component.set("v.pillsList2", StoreResponse);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
    },
	//This helper method pulls the picklist values
    fetchSinglePicklistValues : function(component,objectApi,picklistApi)
    {
        var pickListValues = []; 
        pickListValues.push({				 
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });									
        var action = component.get("c.getPicklistValues");
		action.setParams({
			'ObjectAPIName': objectApi,
			'fieldAPIName' : picklistApi										  
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server 
				var StoreResponse = response.getReturnValue();
               
				for (var i = 0; i < StoreResponse.length; i++) 
				{
					pickListValues.push({				 
					class: "optionClass",
						label: StoreResponse[i].label,
						value: StoreResponse[i].value
					});
				}			
			// set productList to show the available products																				
			component.set("v.requestType", pickListValues);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
	},
    
    //Helps in setting the picklist value of product request field Is_this_a_request_for_an_updated_key__c
    fetchSelectPickListVal: function(component,objectApi,picklistApi) 
	{
		var pickListValues = []; 
		pickListValues.push({				 
			class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
			});									
		var action = component.get("c.getPicklistValues");
        action.setParams({
			'ObjectAPIName': objectApi,
			'fieldAPIName' : picklistApi										  
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server 
				var StoreResponse = response.getReturnValue();
               
				for (var i = 0; i < StoreResponse.length; i++) 
				{
					pickListValues.push({				 
						class: "optionClass",
						label: StoreResponse[i].label,
						value: StoreResponse[i].value
					});
				}			
			// set productList to show the available products																				
            component.set("v.reqUpdtKeyPicklistVal", pickListValues);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
	},
    
    //This helper method pulls the org ID URL 
    fetchnewOrgIdURL : function(component,event,helper)
    {
        var action = component.get("c.getNewOrgIdURL");
         
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				//store the return response from server 
				var StoreResponse = response.getReturnValue();
 
				// set productList to show the available products
				component.set("v.orgIdURL", StoreResponse);
			}
            else
			{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: "Failed!",
					message: retMsg,
					type: "error"
				});
				toastEvent.fire();                            
			}
		});
		$A.enqueueAction(action);
    }                
})