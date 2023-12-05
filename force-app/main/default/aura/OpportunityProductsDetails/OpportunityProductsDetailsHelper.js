/* Helper class for Main custom related products list for the Hybris deal management(opportunity)*/
({

	goToEditProduct : function(component, event) {
		// debugger; 
		var device = $A.get("$Browser.formFactor");

		if (device === "DESKTOP") {
			var oppID = component.get("v.recordId"); 

			var urlEvent = $A.get("e.force:navigateToURL");
	        urlEvent.setParams({
		         "url": "/apex/EditProductsViewPage?id=" + oppID,
		         "isredirect": "true"
	        });

	        urlEvent.fire();
		}
		else {
			var oppID = component.get("v.recordId"); 
	  		var sURL = "/apex/EditProductsViewPage?id=" + oppID; 
	  // 		window.location.assign(sURL);
	  		sforce.one.navigateToURL(sURL);
		}
		
	}, 

	goToAddProduct : function (component, event) {
		var device = $A.get("$Browser.formFactor");

		if (device === "DESKTOP") {
			var oppID = component.get("v.recordId"); 

			var urlEvent = $A.get("e.force:navigateToURL");
	        urlEvent.setParams({
		         "url": "/apex/AddProductsViewPage?id=" + oppID,
		         "isredirect": "true"
	        });

	        urlEvent.fire();
		}
		else {
			var oppID = component.get("v.recordId"); 
	  		var sURL = "/apex/AddProductsViewPage?id=" + oppID; 
	  		sforce.one.navigateToURL(sURL);
		}
	},

	goToViewAll : function (component, event) {
		//debugger; 
		var device = $A.get("$Browser.formFactor");

		if (device === "DESKTOP") {
			var oppID = component.get("v.recordId"); 

			var urlEvent = $A.get("e.force:navigateToURL");
	        urlEvent.setParams({
		         "url": "/apex/ViewAllOpportunityProductsViewPage?actUrl=" + oppID,
		         "isredirect": "true"
	        });

	        urlEvent.fire();
		}
		else {
			var oppID = component.get("v.recordId"); 
	  		var sURL = "/apex/ViewAllOpportunityProductsViewPage?actUrl=" + oppID; 
	  		sforce.one.navigateToURL(sURL);
		}
		
	},

	getTransactionTypeOptions : function (component, event, helper) {
		// debugger; 
		var action = component.get("c.getTransTypeSelect");

		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
            	// debugger; 

                var options = response.getReturnValue();
                component.set("v.transTypeOptions", options);
            } 
            else {
                debugger; 
            }

        });

        $A.enqueueAction(action);
	},

	getOppName : function (component, event, helper) {
		var oppID = component.get("v.recordId"); 
		var action = component.get("c.getOpportunity");  

		action.setParams({
            'oppId' : oppID
        });
             
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
            	// debugger; 

                var oppObject = response.getReturnValue();
                component.set("v.opportunityObject", oppObject);
            } 
            else {
                // debugger; 
            }

        });
        $A.enqueueAction(action);
	},

	displayMobileCard : function (component, event, helper) {
		// debugger; 
		var device = $A.get("$Browser.formFactor");
		var hiddenSection = component.find("mobileCardHide");
		
		if (device === "PHONE" || device === "TABLET") {
			var currentURL = document.URL; 
			var subURL = "vfRetURLInSFX"; 
			
			if (currentURL.indexOf(subURL) !== -1) {
				// Case: Full page 
				// debugger; 
				for (var key in hiddenSection) {
					if (!hiddenSection.hasOwnProperty(key)) continue; 

					var sect = hiddenSection[key]; 
					$A.util.removeClass(sect, 'slds-hide'); 
					$A.util.removeClass(sect, 'slds-show'); 
					$A.util.addClass(sect, 'slds-show_inline-block'); 
				}

				// debugger; 
				var overflowSection = component.find("overflowSect"); 
				$A.util.addClass(overflowSection, 'modal-overflow'); 

				component.set("v.mobileDisplay", true); 
			
			}
			else {
				// Case: Mobile card 
				// debugger; 

				for (var key in hiddenSection) {
					if (!hiddenSection.hasOwnProperty(key)) continue; 

					var sect = hiddenSection[key]; 
					$A.util.addClass(sect, 'slds-hide'); 
					$A.util.removeClass(sect, 'slds-show'); 
					$A.util.removeClass(sect, 'slds-show_inline-block'); 
				}

				var mobileHead = component.find("mobileHeader"); 
				$A.util.removeClass(mobileHead, 'slds-theme_shade'); 
				$A.util.removeClass(mobileHead, 'slds-modal__header');
			}
		}
		else {
			component.set("v.mobileDisplay", false); 
		}

	},

	reDrawPage : function (component, event, helper) {
		// debugger; 

		// var device = $A.get("$Browser.formFactor");
		// if (device === "PHONE" || device === "TABLET") {
		// 	var currentURL = document.URL; 
		// 	var subURL = "vfRetURLInSFX"; 

		// 	if (currentURL.indexOf(subURL) !== -1) {
		// 		// Case: Full page 
		// 		// debugger; 

		// 		var wholePage = component.find("completeMobilePage"); 
		// 		var overflowSection = component.find("overflowSect"); 
				
		// 	}
		// }
	},

	navigateFullDetailPage : function (component, event, helper) {
		debugger; 
		var device = $A.get("$Browser.formFactor");
		if (device === "PHONE" || device === "TABLET") {
	
			var currentURL = document.URL; 
			var subURL = "vfRetURLInSFX"; 

			if (currentURL.indexOf(subURL) !== -1) {
				// Case: Full page 
			}
			else {
				// Case: Mobile card 
				debugger; 

				var oppID = component.get("v.recordId"); 
		  		var sURL = "/apex/OpportunityProductsDetailsPage?id=" + oppID; 
		  		sforce.one.navigateToURL(sURL);
			}
		}
	},

	syncSOPHelper : function (component, event, helper) {
		// debugger; 
		    
	    var action = component.get("c.syncSOPConnect"); 
	    var opportunityID = component.get("v.recordId"); 

	    action.setParams({
	    	oppId : opportunityID 
	    }); 

	    action.setCallback(this, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") {        
                // debugger; 
                        
            	var resultData = a.getReturnValue();
                
             	resultData += '';
				console.log('resultData:'+resultData);
				var lstValue = resultData.split('|');
				alert(lstValue[1]);
            } 
            else {
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action);
	},

	syncQuoteHelper : function (component, event, helper) {
		// debugger; 

		// If field:split is checked, perform sales price update logic
		var oppObject = component.get("v.opportunityObject"); 
		var split = oppObject.Split__c;
	

		if (split == 1) {
		    var opp_id = oppObject.Id;
		    var opp_split__prct = 0;

		    if (!$A.util.isEmpty(oppObject.Split_Percentage__c) && !$A.util.isUndefined(oppObject.Split_Percentage__c)) {
		    	opp_split__prct = oppObject.Split_Percentage__c/100;
		    }
		    
		    // check if opportunity is primary or secondary
		    if((!$A.util.isEmpty(oppObject.Name)  &&  !$A.util.isEmpty(oppObject.Split_From__c) && oppObject.Name == oppObject.Split_From__c) || 
				($A.util.isEmpty(oppObject.Split_From__c))) {

		    	//helper.syncQuoteServer(component, event, helper, "syncQuotePrimary", opp_split__prct); 
				//window.location.reload();
		    	alert($A.get('$Label.c.Error_Message_SyncQuote_Primary'));
		    }
			else {
				helper.syncQuoteServer(component, event, helper, "syncQuoteSecondary", opp_split__prct); 
		    }
		}
		else {
			(alert('This is not split opportunity'));
		}
	},

	syncQuoteServer : function (component, event, helper, methodName, opp_split__prct) {
		// debugger; 

		var action = component.get("c.syncQuoteConnect"); 
		var opportunityId = component.get("v.recordId"); 

	
		action.setParams({
	    	oppId : opportunityId,
	    	oppSplitPrct : opp_split__prct,
	    	method : methodName
	    }); 

		action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {        
                // debugger; 
                
                var resultData = response.getReturnValue(); 
            	resultData += ''; 
				console.debug('resultData:'+resultData); 
				var lstValue = resultData.split('|'); 
				alert(lstValue[1]);
            } 
            else {
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action);
	},
    hideButtons : function(component, event, helper){
        
        var action = component.get("c.checkForCustomPermission"); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") {        
                var result = response.getReturnValue(); 
                if(result){
                    $A.util.addClass(component.find('hideButtons'), 'slds-hide');
                    $A.util.addClass(component.find('hideButtonsForMobile'), 'slds-hide');
                    
                      
                }
                
            } 
            
        });
        
        $A.enqueueAction(action);
        
    },
    

	getPreviousURL : function (component, event, helper) {
		// debugger; 

		// var action = component.get("c.getPrevURL"); 

		// action.setCallback(this, function(response) {
  //           var state = response.getState();            
  //           if (state === "SUCCESS") {        
  //               // debugger; 
                
  //               var url = response.getReturnValue(); 
  //           } 
  //           else {
  //               // debugger; 
  //           }
            
  //       });
        
  //       $A.enqueueAction(action);
	}
})