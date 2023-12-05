/*controller Navigated from OpportunityProductsDetails (on View All Hyperlink click) 
 * Hybrid Deal Management (Opportunity)
 Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                                Tag
Chandana Gowda     27-Sept-2019                     Modified the controller to read the         T01
                                                    fields to be displayed from fieldSet
**************************************************************************************************/
({
   //--------------------------------------<T01> 
	doInit: function (component, event, helper) {
		helper.getColumnDefinitions(component, event, helper);
		helper.getTransTypeOptions (component, event, helper); 
        helper.hideButtons(component, event, helper); 
	},
	// Client-side controller called by the onsort event handler
	handleSort: function (cmp, event, helper) {
		var fieldName = event.getParam('fieldName');
		var sortDirection = event.getParam('sortDirection');
		// assign the latest attribute with the sorted column fieldName and sorted direction
		var columns = cmp.get("v.columns");
		var sortByCol = columns.find(column => fieldName === column.fieldName);
		var fieldLabel = sortByCol.label;
		cmp.set("v.sortMethod", fieldLabel);
		cmp.set("v.sortedBy", fieldName);
		cmp.set("v.sortedDirection", sortDirection);
		helper.sortData(cmp, fieldName, sortDirection);
	},
	//Controller for the action dropdown at record level
	handleRowAction: function (component, event, helper) {
		var action = event.getParam('action');
		var row = event.getParam('row');
		switch (action.name) {
			case 'edit':
				helper.editOpportunityProduct(component, event, row);
				break;
			case 'delete':
				helper.openDeleteModal(component, event, row);
				break;
		}
	},
    //-----------------------------------------------------------------------------<</T01>

	closeEditModal : function (component, event, helper) {
		component.find("editOLIModal").changeVisibility(false); 
	},

	onSaveEditModal : function (component, event, helper) {
		helper.saveOpportunityProduct (component, event, helper); 
	},

	closeDeleteModal : function (component, event, helper) {
		component.find("deleteOLIModal").changeVisibility(false); 
	}, 

	confirmDeleteModal : function (component, event, helper) {         
		helper.deleteOpportunityProduct (component, event, helper); 
	},

	refreshPage : function (component, event, helper) {
		helper.refreshCurrentPage (component, event, helper); 
	},

	goToOpportunities : function (component, event, helper) {
		helper.navigateOpportunityList (component, event, helper); 
	},

	goToOpportunity : function (component, event, helper) {
		helper.navigateOpportunity (component, event, helper); 
	},

	goToAddProduct : function (component, event, helper) {
		helper.navigateAddProduct (component, event, helper); 
	},

	goToEditProduct : function (component, event, helper) {
		helper.navigateEditProduct (component, event, helper); 
	},
	/*------------------------------------------------------------<T01>
	 * onEditClick : function (component, event, helper) {
		helper.editOpportunityProduct (component, event, helper);
	},

	onDeleteClick : function (component, event, helper) {
		helper.openDeleteModal (component, event, helper);
	},
	onDropDownBtnClick : function (component, event, helper) {
		helper.expandShrinkButton (component, event, helper);
	},

	onDropDownBTNBlur : function (component, event, helper) {
		helper.shrinkBTNOnBlur (component, event, helper);
	},
	goToOLIRecord : function (component, event, helper) {
		helper.navigateOpportunityProduct (component, event, helper); 
	},

	onQuantitySort : function (component, event, helper) {
		helper.sortQuantity (component, event, helper); 
	},

	onSalesPriceSort : function (component, event, helper) {
		helper.sortSalesPrice (component, event, helper); 
	},

	onQuotelineSort : function (component, event, helper) {
		helper.sortQuoteline (component, event, helper); 
	}
	*------------------------------------------------------------</T01>*/
})