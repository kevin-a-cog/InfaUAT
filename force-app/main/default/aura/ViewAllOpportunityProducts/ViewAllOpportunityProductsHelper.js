/*Helper classfor Navigated from OpportunityProductsDetails (on View All Hyperlink click) 
 * Hybrid Deal Management (Opportunity)
  Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                                Tag
Chandana Gowda     27-Sept-2019                     Modified the controller to read the         T01
                                                    fields to be displayed from fieldSet
*************************************************************************************************/
({
	//------------------------------------------------------------</T01>
	getOppCurrency : function (component, event, helper) {

		var action = component.get("c.getOppCurrencyIsoCode"); 
		action.setParams({
			opportunityID: component.get("v.recordId")
		});		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var optyCurrency = response.getReturnValue(); 
				component.set("v.oppCurrency", optyCurrency);
			}
			else {
				// debugger; 
			}
		}); 
		$A.enqueueAction(action); 
	},
	//------------------------------------------------------------<T01>
	//method for instantiating the Table header for displaying the records
	getColumnDefinitions: function (component, event, helper) {		
		helper.getOppCurrency(component, event, helper);
		var actions = [
			{ label: 'Edit', name: 'edit' },
			{ label: 'Delete', name: 'delete' }
		];
		var actionColumn = { label: '', type: 'action', typeAttributes: { rowActions: actions } };
		var columns = [];
		var lookupFields = [];
		var fieldApiNames = [];
		var action = component.get("c.getFields");
		action.setCallback(this, function (result) {
			var res = result.getReturnValue();
			//formating the data as required by the lightning:datatable
			for (var each in res) {
				var column = new Map();
				column["label"] = res[each][0];
				column["fieldName"] = (each.includes('.')) ? each.replace('.', '_'):each;
				column["sortable"] = true;
				fieldApiNames.push(each);

				if (res[each][1] == 'CURRENCY') {
					column["type"] = 'currency';
					column["typeAttributes"] = { currencyCode: component.get('v.oppCurrency'), maximumSignificantDigits: 18,currencyDisplayAs:"code" };
					column["cellAttributes"] = { alignment: 'left' };
				}
				else if (res[each][1] == 'DATE' || res[each][1] == 'DATETIME') {
					column["type"] = 'date';
					column["typeAttributes"] = { year: "numeric", month: "2-digit",day: "2-digit" };
				}
				else if (res[each][1] == 'BOOLEAN') {
					column["type"] = 'boolean';
				}
				else if (res[each][1] == 'DOUBLE' || res[each][1] == 'DECIMAL' || res[each][1] == 'NUMBER') {
					column["type"] = 'number';
					column["typeAttributes"] = { minimumIntegerDigits: 1, maximumFractionDigits: 2, };
					column["cellAttributes"] = { alignment: 'left' };
				}
				else if (res[each][1] == 'PERCENT') {
					column["type"] = 'percent';
					column["typeAttributes"] = { minimumIntegerDigits: 1, maximumFractionDigits: 2, };
					column["cellAttributes"] = { alignment: 'left' };
				}					
				else if (res[each][0] =='Product Name') {
					column["type"] = "url";
					column["fieldName"] = "optyProductLink";
					column["typeAttributes"] = { label: { fieldName: 'Product2_Name' }, target: '_self' };
					column["sortable"] = false;
				}
				else if (each.includes('.')) {
					lookupFields.push(each.replace('.', '_').replace('Name', 'Id'));
					column["type"] = "url";
					column["fieldName"] = each.replace('.', '_').replace('Name', 'Id');
					column["typeAttributes"] = { label: { fieldName: each.replace('.', '_') }, target: '_self' };
					column["sortable"] = false;
				}
				else {
					column["type"] = "text";
				}			
				columns.push(column);
			}
			columns.push(actionColumn);
			component.set("v.columns", columns);
			component.set('v.lookupFields', lookupFields);
			component.set('v.fieldApiNames', fieldApiNames);
			helper.getOpportunityLineItems(component, event, helper); 
		});
		$A.enqueueAction(action);
	},
		
	getOpportunityLineItems: function (component, event, helper) {		
		var opportunityId = component.get("v.recordId");
		var action = component.get("c.getOpportunityLineItemsWrapper");
		action.setParams({
			opportunityID: opportunityId,
			oliColumns: component.get('v.fieldApiNames')
		});
		action.setCallback(this, function(response) {
			var state = response.getState(); 
			if (state === "SUCCESS") {
				var oliWrapperListServer = response.getReturnValue();
				
				/*Flattenning the structure in case the data returned contains the lookup fields*/
                oliWrapperListServer.forEach(row => {
					for (const col in row) {
						const curCol = row[col];
						if (typeof curCol === 'object') {
							const newVal = curCol.Id ? ('/' + curCol.Id) : null;
							this.flattenStructure(row, col + '_', curCol);
							if (newVal === null) {
								delete row[col];
							} else {
								row[col] = newVal;
							}
						}
					}
				});

				//The oli Name field should be a link to Product record
                oliWrapperListServer.forEach(function (record) {
					record.optyProductLink = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + record.Id + '/view';
				});

				//Incase of lookupfields the value has value has to be updated to the link to be navigated
                var lookupFields = component.get('v.lookupFields');
				lookupFields.forEach(function (field) {
					oliWrapperListServer.forEach(function (record) {
						if (record[field]) {
							record[field] = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + record[field] + '/view';
						}
					})
				});				
				component.set("v.oliWrapperList", oliWrapperListServer);
			}
			else {
			}
		}); 

		$A.enqueueAction(action); 
	},

    //Incase of the the lookup fields the '.' has to be replaced by '_' to be used in the lightning:datatable
    flattenStructure: function (topObject, prefix, toBeFlattened) {
		
		for (const prop in toBeFlattened) {
			const curVal = toBeFlattened[prop];
			if (typeof curVal === 'object') {
				flattenStructure(topObject, prefix + prop + '_', curVal);
			} else {
				topObject[prefix + prop] = curVal;
			}
		}
	},
	//------------------------------------------------------------</T01>
	getTransTypeOptions : function (component, event, helper) {
		
		var action = component.get("c.getTransTypeSelect"); 
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var opts = response.getReturnValue(); 
				component.set("v.transactionTypeOptions", opts); 
			}
			else {
				// debugger; 
			}
		}); 
		$A.enqueueAction(action); 
	},
    
    //Added the method sortData and sortBy ot handle sorting when columns are sorted using thetable header----<T01/>
	sortData: function (cmp, fieldName, sortDirection) {
		var data = cmp.get("v.oliWrapperList");
		var reverse = sortDirection !== 'asc';
		//sorts the rows based on the column header that's clicked
		data.sort(this.sortBy(fieldName, reverse))
		cmp.set("v.oliWrapperList", data);
	},

	sortBy: function (field, reverse, primer) {
		var key = primer ?
			function (x) { return primer(x[field]) } :
			function (x) { return x[field] };
		//checks if the two rows should switch places
		reverse = !reverse ? 1 : -1;
		return function (a, b) {
			return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
		}
	},

	editOpportunityProduct : function (component, event, row) {
		/*------------------------------------------------<T01>		
		 // debugger; 

		var oliID = event.currentTarget.id; 

		// Get data for selected OLI 
		var oliWrapperList = component.get("v.oliWrapperList"); 

		for (var key in oliWrapperList) {
			if (!oliWrapperList.hasOwnProperty(key)) continue; 

			var oliWrapper = oliWrapperList[key]; 
			if (oliWrapper.oli.Id === oliID)
				component.set("v.currentSelectedOLIWrapper", oliWrapper); 
		}

		// Shrink the dropdown button 
		helper.shrinkAllButton(component, event, helper); 

		component.set("v.editOrDeleteClicked", true);
		component.find("editOLIModal").changeVisibility(true); 
        -----------------------------------------------</T01>*/        
		component.set("v.currentSelectedOLIWrapper", row);
		component.set("v.editOrDeleteClicked", true);
		component.find("editOLIModal").changeVisibility(true);
	},

	openDeleteModal : function (component, event, row) {
        /*------------------------------------------------<T01>	
        helper.shrinkAllButton(component, event, helper); 

		component.set("v.editOrDeleteClicked", true);
		component.find("deleteOLIModal").changeVisibility(true); 

		var oliID = event.currentTarget.id; 
		var oliWrapperList = component.get("v.oliWrapperList"); 

		for (var key in oliWrapperList) {
			if (!oliWrapperList.hasOwnProperty(key)) continue; 

			var oliWrapper = oliWrapperList[key]; 
			if (oliWrapper.oli.Id === oliID)
				component.set("v.currentSelectedOLIWrapper", oliWrapper); 
		}------------------------------------------------</T01>	*/
		component.set("v.editOrDeleteClicked", true);
		component.find("deleteOLIModal").changeVisibility(true);
		component.set("v.currentSelectedOLIWrapper", row);
	},

	saveOpportunityProduct : function (component, event, helper) {
		var currentEdittedOLIWrapper = component.get("v.currentSelectedOLIWrapper");
		var oliWrapperToSave = {
			Id: currentEdittedOLIWrapper.Id,
			Transaction_Type__c: currentEdittedOLIWrapper.Transaction_Type__c,
			UnitPrice: currentEdittedOLIWrapper.UnitPrice
		};
		var action = component.get("c.saveOpportunityLineItem");
		action.setParams({
			oliWrapper: oliWrapperToSave
        });

        action.setCallback(this,function(response){
        	var state = response.getState(); 
			if (state === "SUCCESS") {
        		window.location.reload(true);
        	}
			else {
				alert('Save failed');
        		debugger; 
        	}
        }); 
		$A.enqueueAction(action);
	},

	deleteOpportunityProduct : function (component, event, helper) {

		var currentDeletedOLIWrapper = component.get("v.currentSelectedOLIWrapper");
		var oliId = currentDeletedOLIWrapper.Id;		
		var action = component.get("c.deleteOpportunityLineItem");
		action.setParams({
            oliID : oliId
            //opportunityID : oppID----<T01/>
		});
		
		action.setCallback(this,function(response){
        	var state = response.getState(); 
            if (state === "SUCCESS") {
        		window.location.reload(true);
        	}
        	else {
        		debugger; 
        	}
        }); 
		$A.enqueueAction(action);
	},

	refreshCurrentPage : function (component, event , helper) {
		var device = $A.get("$Browser.formFactor");

		if (device === "DESKTOP") {
			window.location.reload(true); 
		}
  		else {
  			var sURL = window.location.href; 
  			sforce.one.navigateToURL(sURL);
  		}
	},

	navigateOpportunityList : function (component, event, helper) {
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/Opportunity/list?filterName=Recent';

        var device = $A.get("$Browser.formFactor");

		if (device === "DESKTOP") {
			window.location.assign(sURL);
		}
        else {
        	sforce.one.navigateToURL(sURL);
        }
	},

	navigateOpportunity : function (component, event, helper) {
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

	navigateAddProduct : function (component, event, helper) {
  		var oppID = component.get("v.recordId"); 
  		var sURL = "/apex/AddProductsViewPage?id=" + oppID; 
		var device = $A.get("$Browser.formFactor");
		sforce.one.navigateToURL(sURL);

		/*
  		if (device === "DESKTOP") {
			window.location.assign(sURL);
		}
        else {
        	sforce.one.navigateToURL(sURL);
        }*/
	},

	navigateEditProduct : function (component, event, helper) {
		var oppID = component.get("v.recordId"); 
  		var sURL = "/apex/EditProductsViewPage?id=" + oppID; 
		var device = $A.get("$Browser.formFactor");
		sforce.one.navigateToURL(sURL);
		
		/*
  		if (device === "DESKTOP") {
			window.location.assign(sURL);
		}
        else {
        	sforce.one.navigateToURL(sURL);
        }*/
	},
    
    hideButtons : function(component, event, helper){
        
        var action = component.get("c.checkForCustomPermission"); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") {        
                var result = response.getReturnValue(); 
                if(result){
                    $A.util.addClass(component.find('hideButtons'), 'slds-hide');
                   
                }
                
            } 
            
        });
        
        $A.enqueueAction(action);
        
    },

/*/*------------------------------------------------------------<T01>
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

				// Shrink all dropdown buttons on load 
				helper.shrinkAllButton (component, event, helper); 
			}
			else {
				// debugger; 
			}
		}); 

		$A.enqueueAction(action); 
	}
expandShrinkButton : function (component, event, helper) {

	var clickedButton = event.target;

	while (clickedButton.tagName != "DIV") { // Go up to div that contains button
		clickedButton = clickedButton.parentNode;
	}

	if (clickedButton.name === "notExpanded") {
		clickedButton.className += " slds-is-open";
		clickedButton.name = "expanded";
	}
	else {
		clickedButton.classList.remove("slds-is-open");
		clickedButton.name = "notExpanded";
	}
},

shrinkAllButton : function (component, event, helper) {
	// debugger;

	var dropdownButtons = component.find("dropdownBTN");

	if (dropdownButtons != undefined) {
		for (var i = 0; i < dropdownButtons.length; i++) {
			if (dropdownButtons[i].getElement() != null) {
				dropdownButtons[i].getElement().classList.remove("slds-is-open");
						dropdownButtons[i].getElement().name = "notExpanded";
			}
		}
	}
},

shrinkBTNOnBlur : function (component, event, helper) {
	// debugger;

	// TODO: if Edit or Delete was clicked then don't do onblur, onblur is fired before Edit or Delete

	// var btn = event.target;
	// var dropdownElem = btn.parentNode;

	// dropdownElem.classList.remove("slds-is-open");
	// dropdownElem.name = "notExpanded";
},
	navigateOpportunityProduct: function (component, event, helper) {     
		var recId = event.currentTarget.id;  
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
        var device = $A.get("$Browser.formFactor");

        if (device === "DESKTOP") {
			window.location.assign(sURL);
		}
        else {
        	sforce.one.navigateToURL(sURL);
        }
	},

	sortQuantity : function (component, event, helper) {

		var oliWrapperList = component.get("v.oliWrapperList"); 
		var ascendingSort = component.get("v.quantityAscendingSort"); 

		if (ascendingSort == false) {
			// Ascending order 
			oliWrapperList.sort(function(a,b){
				return parseFloat(a.oli.Quantity) - parseFloat(b.oli.Quantity); 
			}); 

			// Hide all up/down arrows in other <th>
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows 
			var arrowUp = component.find("arrowUpQuantity"); 
			var arrowDown = component.find("arrowDownQuantity"); 
			$A.util.addClass(arrowUp, 'slds-show_inline-block');
			$A.util.removeClass(arrowUp, 'slds-hide');
			$A.util.addClass(arrowDown, 'slds-hide');
			$A.util.removeClass(arrowDown, 'slds-show_inline-block');

			component.set("v.quantityAscendingSort", true); 
		}
		else {
			// Descending order 
			oliWrapperList.sort(function(a,b){
				return parseFloat(b.oli.Quantity) - parseFloat(a.oli.Quantity); 
			}); 

			// Hide all up/down arrows in other <th> 
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows
			var arrowUp = component.find("arrowUpQuantity"); 
			var arrowDown = component.find("arrowDownQuantity"); 
			$A.util.addClass(arrowUp, 'slds-hide');
			$A.util.removeClass(arrowUp, 'slds-show_inline-block');
			$A.util.addClass(arrowDown, 'slds-show_inline-block');
			$A.util.removeClass(arrowDown, 'slds-hide');

			component.set("v.quantityAscendingSort", false); 
		}
		
		component.set("v.sortMethod", "Quantity"); 
		component.set("v.oliWrapperList", oliWrapperList); 
	},

	sortSalesPrice : function (component, event, helper) {
		// debugger; 

		var oliWrapperList = component.get("v.oliWrapperList"); 
		var ascendingSort = component.get("v.salesPriceAscendingSort"); 

		if (ascendingSort == false) {
			// Ascending order 
			oliWrapperList.sort(function(a,b){
				return parseFloat(a.UnitPrice) - parseFloat(b.UnitPrice); 
			}); 

			// Hide all up/down arrows in other <th>
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows 
			var arrowUp = component.find("arrowUpsPrice"); 
			var arrowDown = component.find("arrowDownsPrice"); 
			$A.util.addClass(arrowUp, 'slds-show_inline-block');
			$A.util.removeClass(arrowUp, 'slds-hide');
			$A.util.addClass(arrowDown, 'slds-hide');
			$A.util.removeClass(arrowDown, 'slds-show_inline-block');

			component.set("v.salesPriceAscendingSort", true); 
		}
		else {
			// Descending order 
			oliWrapperList.sort(function(a,b){
				return parseFloat(b.UnitPrice) - parseFloat(a.UnitPrice); 
			}); 

			// Hide all up/down arrows in other <th> 
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows
			var arrowUp = component.find("arrowUpsPrice"); 
			var arrowDown = component.find("arrowDownsPrice"); 
			$A.util.addClass(arrowUp, 'slds-hide');
			$A.util.removeClass(arrowUp, 'slds-show_inline-block');
			$A.util.addClass(arrowDown, 'slds-show_inline-block');
			$A.util.removeClass(arrowDown, 'slds-hide');

			component.set("v.salesPriceAscendingSort", false); 
		}
		
		component.set("v.sortMethod", "Sales Price"); 
		component.set("v.oliWrapperList", oliWrapperList); 
	},

	sortQuoteline : function (component, event, helper) {
		// debugger; 

		var oliWrapperList = component.get("v.oliWrapperList"); 
		var ascendingSort = component.get("v.quoteLineAscendingSort"); 

		if (ascendingSort == false) {
			// Ascending order 
			oliWrapperList.sort(function(a,b){
				if (a.oli.SBQQ__QuoteLine__c != undefined && b.oli.SBQQ__QuoteLine__c != undefined) {
					if (a.oli.SBQQ__QuoteLine__r.Name < b.oli.SBQQ__QuoteLine__r.Name) return -1;
				    if (a.oli.SBQQ__QuoteLine__r.Name > b.oli.SBQQ__QuoteLine__r.Name) return 1;
				    return 0;
				}
			}); 

			// Hide all up/down arrows in other <th>
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows 
			var arrowUp = component.find("arrowUpQuote"); 
			var arrowDown = component.find("arrowDownQuote"); 
			$A.util.addClass(arrowUp, 'slds-show_inline-block');
			$A.util.removeClass(arrowUp, 'slds-hide');
			$A.util.addClass(arrowDown, 'slds-hide');
			$A.util.removeClass(arrowDown, 'slds-show_inline-block');

			component.set("v.quoteLineAscendingSort", true); 
		}
		else {
			// Descending order 
			oliWrapperList.sort(function(a,b){
				if (a.oli.SBQQ__QuoteLine__c != undefined && b.oli.SBQQ__QuoteLine__c != undefined) {
					if (a.oli.SBQQ__QuoteLine__r.Name < b.oli.SBQQ__QuoteLine__r.Name) return 1;
				    if (a.oli.SBQQ__QuoteLine__r.Name > b.oli.SBQQ__QuoteLine__r.Name) return -1;
				    return 0;
				}
			}); 

			// Hide all up/down arrows in other <th> 
			helper.hideAllTHArrows (component, event, helper); 

			// Show/hide up/down arrows
			var arrowUp = component.find("arrowUpQuote"); 
			var arrowDown = component.find("arrowDownQuote"); 
			$A.util.addClass(arrowUp, 'slds-hide');
			$A.util.removeClass(arrowUp, 'slds-show_inline-block');
			$A.util.addClass(arrowDown, 'slds-show_inline-block');
			$A.util.removeClass(arrowDown, 'slds-hide');

			component.set("v.quoteLineAscendingSort", false); 
		}
		
		component.set("v.sortMethod", "Quote Line"); 
		component.set("v.oliWrapperList", oliWrapperList); 
	},

	hideAllTHArrows : function (component, event, helper) {
		var qUpArrow = component.find("arrowUpQuantity"); 
		var qdownArrow = component.find("arrowDownQuantity"); 
		var spUpArrow = component.find("arrowUpsPrice"); 
		var spDownArrow = component.find("arrowDownsPrice"); 
		var quoteUpArrow = component.find("arrowUpQuote"); 
		var quoteDownArrow = component.find("arrowDownQuote"); 

		$A.util.removeClass(qUpArrow, 'slds-show_inline-block');
		$A.util.addClass(qUpArrow, 'slds-hide');
		$A.util.removeClass(qdownArrow, 'slds-show_inline-block');
		$A.util.addClass(qdownArrow, 'slds-hide');
		$A.util.removeClass(spUpArrow, 'slds-show_inline-block');
		$A.util.addClass(spUpArrow, 'slds-hide');
		$A.util.removeClass(spDownArrow, 'slds-show_inline-block');
		$A.util.addClass(spDownArrow, 'slds-hide');
		$A.util.removeClass(quoteUpArrow, 'slds-show_inline-block');
		$A.util.addClass(quoteUpArrow, 'slds-hide');
		$A.util.removeClass(quoteDownArrow, 'slds-show_inline-block');
		$A.util.addClass(quoteDownArrow, 'slds-hide');
	}
	------------------------------------------------------------</T01>*/
})