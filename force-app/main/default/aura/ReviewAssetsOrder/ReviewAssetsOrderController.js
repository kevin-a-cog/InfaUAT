/*Controller for Component to Display the Asset records related to an Order for Assets & Entitlements Design*/
({
	doInit : function (component, event, helper) {
		helper.loadAllAssets (component, event, helper); 
	},

	closeModalOne : function (component, event, helper) {
		helper.navigateOrderPage (component, event, helper);
	},

	save : function (component, event, helper) {
		helper.updateAllAssets (component, event, helper); 
	},

	lookupPrimaryAsset : function (component, event, helper) {
		helper.openAssetListModal (component, event, helper); 
		helper.saveSelectedAssets (component, event, helper); 
	},

	closePrimaryAssetModal : function (component, event, helper) {
		component.find("primaryAssetModal").changeVisibility(false); 
	},

	selectPrimaryAsset : function (component, event, helper) {
		helper.selectParentAsset (component, event, helper); 
		component.find("primaryAssetModal").changeVisibility(false); 
	},

	lookupAssociatedAsset : function (component, event, helper) {
		// debugger; 
		helper.openAssAssetModal (component, event, helper);
		helper.getCurrentSelectedAsset (component, event, helper); 
	},

	closeAssAssetModal : function (component, event, helper) {
		component.find("associatedAssetModal").changeVisibility(false); 
		helper.sortMainAssetList (component, event, helper); 
	},

	selectAssociatedAsset : function (component, event, helper) {
		helper.selectAssocAsset (component, event, helper); 
		component.find("associatedAssetModal").changeVisibility(false); 
	},

	onAscAssetRadioSelect : function (component, event, helper) {
		helper.getSelectedAscAsset (component, event, helper); 
	},

	onParentAssetRadioSelect : function (component, event, helper) {
		helper.getSelectedParentAsset (component, event, helper); 
	},
    
    massUpdateAsset : function (component, event, helper) {
        helper.massUpdateAssetList(component, event, helper);
    }
})