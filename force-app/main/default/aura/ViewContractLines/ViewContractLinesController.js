/*Controller for Component to Display the Contract Line records related to a Renewal Quote Design*/
({
	doInit : function (component, event, helper) {   
        helper.loadAllQuoteLines (component, event, helper);           
	},
    
	closeModalOne : function (component, event, helper) {
		helper.navigateOrderPage (component, event, helper);
	},

	closeAssAssetModal : function (component, event, helper) {
		component.find("associatedAssetModal").changeVisibility(false); 
	},
    
    toggle : function(component, event, helper) {
        var tableToShow = component.get("v.showTopTable");
        if(tableToShow){
            var toggleTable = component.find("priorTable");
            $A.util.addClass(toggleTable, "toggle");             
            var toggleTable = component.find("originalTable");
            $A.util.removeClass(toggleTable, "toggle");
        }
        if(!tableToShow){
            var toggleTable = component.find("originalTable");
            $A.util.addClass(toggleTable, "toggle");             
            var toggleTable = component.find("priorTable");
            $A.util.removeClass(toggleTable, "toggle");           
        }
        component.set("v.showTopTable", !component.get("v.showTopTable"));
	},
	downloadTable: function (component, event, helper) {
		helper.getTableData(component,event,helper);
	}
})