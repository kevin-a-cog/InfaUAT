/* Controller for Add Products Page*/
//Init Method helps in initializing the picklist values and fieldsets to be displayed based on user actions.
({
    doInit : function(component, event, helper) 
    {    
		var dealId = component.get("v.recordId");
        var action = component.get("c.StatusValidator");
        action.setParams({'DealId':dealId});        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var retVal = response.getReturnValue();
                if(retVal !== undefined && retVal!== null && retVal!== "") 
                {
                    if(retVal==='SUCCESS')
                    {
                        try
                        {
                            helper.getFields(component, event, helper);
                            helper.pullSavedProducts(component, event, helper);
                        }
                        catch(e)
                        {
                            console.log(e);
                        }
                    }
                    else
                    {
                        helper.goToDetailView(component,event,dealId);
                        helper.showValidationError(component,event,retVal);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //Calls the helper method to search the Product details based on the keyword entered by the user.
    searchProdcut2 : function(component,event,helper)
    { 
        if(undefined !== component.get("v.searchKeyword").length && component.get("v.searchKeyword").length > 0)
        {
            helper.searchProdRecords(component,event,helper);
        }
    },
    
    //Closes the Modal Pop-up and refreshes the detail page
    CloseModalOne : function(component,event,helper)
    {
        var recId =  component.get("v.recordId");
        helper.goToDetailView(component,event,recId);
    },

    //Saves the selected Products into the DealRegistration Product Object
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
            for(var i=0;i<lstProducts.length;i++)
            {
                if(lstProducts[i].Id===selectedProductId)
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
        
        for(var i=0;i<pillsList.length;i++)
        {
            if(pillsList[i].Id === removePillId)
            {
                pillsList.splice(i,1);
            }
        }
        component.set("v.pillsList",pillsList); 
        var lstProducts = component.get("v.lstProducts");  
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts))
        {  
            for(var i=0;i<lstProducts.length;i++)
            {
                if(lstProducts[i].Id === removePillId)
                {
                    
                    lstProducts[i].Is_Selected__c = false;
                    
                }
            }
            
            component.set("v.lstProducts",lstProducts);
        }
    },
    
	//Helps in deleting the products which user wants remove from the already available products pillList.
	handleProductDelete : function (component, event, helper) 
	{
        var delId = [];
     	var successMsg = $A.get("$Label.c.PRM_DealProductRmvSuccess");
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
     	if(delId !== undefined && delId.length === 1)
        {
            successMsg = $A.get("$Label.c.PRM_DealProductRmvSuccess2");
        }
        
        var action = component.get("c.deleteSavedDealRegProducts");
        action.setParams({
            'DealRegProdId': delId,
            'DealRegId': component.get("v.recordId")
        });
        action.setCallback(this, function(response){
        	if (response.getState() === "SUCCESS")
            {
                var StoreResponse = response.getReturnValue();
                if(StoreResponse === 'Success')
                {
                    helper.showSuccessMsg(component,event,successMsg);
                    component.set("v.DeleteEnabled", false);
                    helper.pullSavedProducts(component, event, helper);
                }
                else
                {
                    helper.showFailedAction(component,event,StoreResponse);
                    component.set("v.DeleteEnabled", false);
                    helper.pullSavedProducts(component, event, helper);
                }
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
            if(selectedHeaderCheck === true)
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
        component.set("v.Spinner", true); 
 	},
    
	// this function automatic call by aura:doneWaiting event 
	hideSpinner : function(component,event,helper)
    {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})