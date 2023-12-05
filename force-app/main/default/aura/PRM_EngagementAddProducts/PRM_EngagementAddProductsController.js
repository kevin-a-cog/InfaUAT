/* Controller for Add Products Page*/
//Init Method helps in initializing the picklist values and fieldsets to be displayed based on user actions.
({
    doInit : function(component, event, helper) 
	{   
        var engId = component.get("v.recordId");
        var action = component.get("c.StatusValidator");
		action.setParams({'EgmtId':engId});        
		action.setCallback(this, function(response) 
		{
			var state = response.getState();
                
			if (state === "SUCCESS") 
			{
				var retVal = response.getReturnValue();
				if(retVal != undefined && retVal!=null && retVal!="") 
				{
					if (retVal==="SUCCESS") 
					{
						component.set("v.NoErrors",true);
						try
						{    
							helper.getFields(component, event, helper); 
							helper.fetchPicklistValues(component, 'PRM_Product_Family__c', 'PRM_Product_Sub_Family__c');
							helper.fetchPicklistValues2(component, 'PRM_Product_Sub_Family__c', 'PRM_Products__c');
							helper.fetchSinglePicklistValues(component, 'Product_Request__c', 'Is_this_a_new_request__c');
							helper.fetchSelectPickListVal(component, 'Product_Request__c', 'Is_this_a_request_for_an_updated_key__c');
							helper.pullSavedProducts(component, event, helper);
							helper.fetchnewOrgIdURL(component,event,helper);
						}
						catch(e){
							console.log(e);
						}
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
    						message: retVal,
    						type: "error"
							});
						toastEvent.fire();
					}
				}
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
    				message: retVal,
    				type: "error"
				});
				toastEvent.fire();
            }
		});
        $A.enqueueAction(action);
    },
    
    //Calls the helper method to search the Product details based on the keyword entered by the user.
    searchProdcut2 : function(component,event,helper)
	{
		if(component.get("v.searchKeyword").length > 0)
		{
			helper.searchProdRecords(component,event,helper);
        }
	},
    
    //Closes the Modal Pop-up and refreshes the detail page
    CloseModalOne : function(component,event,helper)
	{
		var recId =  component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "isredirect": "false"
        });
		navEvt.fire();
    },
    
	
    //Helps in fetching the the Products based on the value selected in 'Products; picklist by the user.
    onSelectProductFamily : function(component, event, helper)
	{
		var selectedvalueFamily = component.find("prods").get("v.value");
        var fieldString = component.get("v.fieldStrQry"); 
        var action = component.get("c.searchProducts");
        var pillsList = JSON.stringify(component.get("v.pillsList")); 
        
        action.setParams({  'family' : selectedvalueFamily,                             
                            'pillsList' : pillsList,
                            'fieldsStrQry' : fieldString
                        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") {        
                
                var returnValue = a.getReturnValue();                         
                
                component.set("v.lstProducts",returnValue);  

                // Re-setting productForecast ( Product Search Bar) for On-slect options
                 component.find("searchId").set("v.value", "");

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
    				message: retVal,
    				type: "error"
				});
				toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },

    //Saves the selected Products into the Product Request Object
    nextSection : function(component, event, helper) 
	{
		helper.save(component); 
    },
    
    //Adds the Selectes Products to the pill element on the top of the Product Data Table displayed.
    handleClick : function (component, event, helper) 
	{
		var target = event.target;  
        var selectedProductId = target.getAttribute("data-contact-id");
        
        var pillsList = component.get("v.pillsList");  
        var lstProducts = component.get("v.lstProducts");  
               
        //To check if list is not empty or null    
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts))
		{  
            for(var i=0;i<lstProducts.length;i++){
                if(lstProducts[i].Id==selectedProductId)
                {
                    lstProducts[i].Is_Selected__c = Boolean('TRUE');
                    pillsList.push(lstProducts[i]);
                }
            }
            component.set("v.lstProducts",lstProducts);
            component.set("v.pillsList",pillsList);
            
        }
    },
    //Removes the Products from the selected pills shown above the Product Data Table.
    handleRemove : function (component, event, helper)
	{
        event.preventDefault();
        var removePillId = event.getSource().get("v.name");
        var pillsList = component.get("v.pillsList");  
        
        for(var i=0;i<pillsList.length;i++){
            if(pillsList[i].Id == removePillId)
            {
                pillsList.splice(i,1);
            }
        }
        component.set("v.pillsList",pillsList);
        
        var lstProducts = component.get("v.lstProducts");  
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts)){  
            for(var i=0;i<lstProducts.length;i++){
                if(lstProducts[i].Id == removePillId)
                {
                    lstProducts[i].Is_Selected__c = false;
                }
            }
            component.set("v.lstProducts",lstProducts);
        }
        
    },
    
   //Helps in setting the Product Sub-Family picklist values based on the selected 'Product Family' value.
   onControllerFieldChange: function(component, event, helper) 
   {
		// get the selected value
		var controllerValueKey = event.getSource().get("v.value");

		// get the map values   
		var Map = component.get("v.depnedentFieldMap");
 
		// check if selected value is not equal to None then call the helper function.
		// if controller field value is none then make dependent field value is none and disable field
		if (controllerValueKey != '--- None ---') 
		{
			// get dependent values for controller field by using map[key].  
			var ListOfDependentFields = Map[controllerValueKey];
			helper.fetchDepValues(component, ListOfDependentFields);
		} 
		else 
		{
			var defaultVal = [{
				class: "optionClass",
				label: '--- None ---',
				value: '--- None ---'
			}];
			component.find('prodSubFamily').set("v.options", defaultVal);
			component.set("v.isDependentDisable", true);
		}
   },
    
    //Helps in setting the Products picklist values based on the selected 'Product Sub-Family' value.
    onControllerFieldChange2: function(component, event, helper) 
	{
		// get the selected value
		var controllerValueKey = event.getSource().get("v.value");
 
		// get the map values   
		var Map = component.get("v.depnedentFieldMap2");
 
		// check if selected value is not equal to None then call the helper function.
		// if controller field value is none then make dependent field value is none and disable field
		if (controllerValueKey != '--- None ---') 
		{
 
			// get dependent values for controller field by using map[key].  
			var ListOfDependentFields = Map[controllerValueKey];
			helper.fetchDepValues2(component, ListOfDependentFields);
 
		} 
		else 
		{
			var defaultVal = [{
				class: "optionClass",
				label: '--- None ---',
				value: '--- None ---'
			}];
			component.find('prods').set("v.options", defaultVal);
			component.set("v.isDependentDisable2", true);
		}
   },
    
	//Helps in deleting the products which user wants remove from the already available products pillList.
	handleProductDelete : function (component, event, helper) 
	{ 
		var delId = [];
		var successMsg = "Products Removed Successfully";
		// get all checkboxes 
		var getAllId = component.find("selectBox");
		var SingleDealRegProdId = component.get("v.DealRegProductId");
     
		//Handles when there is only product to delete
		if(!$A.util.isArray(getAllId) && component.get("v.DeleteEnabled"))
		{
			delId.push(SingleDealRegProdId);
		}
     
		if($A.util.isArray(getAllId))
		{
			if(!$A.util.isEmpty(getAllId) && !$A.util.isUndefined(getAllId))
			{
				for (var i = 0; i < getAllId.length; i++) 
				{
					if(getAllId[i].get("v.checked"))
					{    
						delId.push(getAllId[i].get("v.name"));
					}        
				}
			} 
		}
     	
		if(delId.length === 1)
        {successMsg = "Product Removed Successfully";}
          
		var action = component.get("c.deleteSavedProductRequests");
		action.setParams({
			'ProdReqId': delId,
			'EgmtId': component.get("v.recordId")
		});
		//set callback   
		action.setCallback(this, function(response) 
		{
			if (response.getState() == "SUCCESS") 
			{
				var StoreResponse = response.getReturnValue();
				if(StoreResponse==='Success')
				{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Success!",
						message: successMsg,
						type: "success"
					});
					toastEvent.fire();
					component.set("v.DeleteEnabled", false);
					helper.pullSavedProducts(component, event, helper);                
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
					component.set("v.DeleteEnabled", false);
					//component.set("v.pillsList2", StoreResponse);
					helper.pullSavedProducts(component, event, helper);
				}
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
    				message: retVal,
    				type: "error"
				});
				toastEvent.fire();
            }
		});
      $A.enqueueAction(action);
	},
  
	//Helps in showing/hiding the Delete button to the user
	displayDelete : function(component,event,helper)
	{
		var selectedHeaderCheck = event.getSource().get("v.checked");
		var getAllId = component.find("selectBox");
     	var flag = false;
      
      	//Handling when there is only one product available, as component.find returns 'undefined'
        if(!$A.util.isArray(getAllId))
        {
            if(selectedHeaderCheck == true)
            { 
          		flag = true;
                component.set("v.DealRegProductId",event.getSource().get("v.name"));
       		}
            else
            {
           		flag = false;
       		}           
        }
      
        if($A.util.isArray(getAllId))
        {
			if(!$A.util.isEmpty(getAllId) && !$A.util.isUndefined(getAllId))
			{  
				for (var i = 0; i < getAllId.length; i++) 
				{
					if(getAllId[i].get("v.checked"))
					{    
						flag = true; 
					}
				}
			}
		}
		component.set("v.DeleteEnabled", flag);
	},
    
	//this function automatic call by aura:waiting event  
	showSpinner: function(component, event, helper) 
	{
		// make Spinner attribute true for display loading spinner 
		//component.set("v.Spinner", true); 
	},
    
	// this function automatic call by aura:doneWaiting event 
	hideSpinner : function(component,event,helper)
	{
		// make Spinner attribute to false for hide loading spinner    
		component.set("v.Spinner", false);
	},

    openURL : function(component,event,helper)
    {
        var urlToOpen = component.get("v.orgIdURL");
        window.open(urlToOpen, '_blank');
    },
    
	saveAdditionalProducts : function(component, event, helper) 
	{
        var lstProducts = component.get("v.pillsList3");
		var egmtId = component.get("v.recordId");
		var successMsg = "Products Added Successfully";
        
        //To check if list is not empty or null
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts))
		{
            //Calling the Apex Function
            var action = component.get("c.saveProductsWithAdditionalDetails");
                                  
            //Json Encode to send the data to Apex Class
            var productRecords = JSON.stringify(lstProducts);
			
			if(lstProducts.length === 1)
            {successMsg = "Product Added Successfully";}
			
            //Setting the Apex Parameter
            action.setParams({
                productData : productRecords,
				EgmtId : egmtId
            });
            
            //Setting the Callback
            action.setCallback(this,function(a)
			{
				//get the response state
				var state = a.getState();
                if(state === "SUCCESS")
				{
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
					}
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
    					message: retVal,
    					type: "error"
					});
					toastEvent.fire();
            	}
            });
            //adds the server-side action to the queue        
            $A.enqueueAction(action);
        }
	}       
})