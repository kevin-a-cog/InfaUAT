({
	doInit : function (component, event, helper) {
		helper.getOpportunityLineItems (component, event, helper); 
        helper.getTransTypeOptions (component, event, helper); 
	},
	
	CloseModalOne : function (component, event, helper){
        var recId =  component.get("v.recordId");
        
        var str = window.location.hostname;
        var arr = str.split("--");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
        
        var device = $A.get("$Browser.formFactor");

        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    },

    deleteProduct : function (component, event, helper) {
        component.find("deleteOLIModal").changeVisibility(true); 
        var toBeDeletedOLI_ID = event.target.id; 
        component.set("v.deletedItem", toBeDeletedOLI_ID); 
    },

    closeDeleteModal : function (component, event, helper) {
        component.find("deleteOLIModal").changeVisibility(false); 
    },

    fireDelete : function (component, event, helper) {
        // debugger; 
        component.set("v.deleteProduct", true); 
        component.find("deleteOLIModal").changeVisibility(false); 

        var itemDeleted = component.get("v.deleteProduct"); 

        if (itemDeleted == true) {
            var toBeDeletedOLI_ID = component.get("v.deletedItem"); 
            helper.deleteOpportunityLineItem(component, event, helper, toBeDeletedOLI_ID); 
        }
    },

    Save : function (component, event, helper) {
        // debugger; 
        try{
            // Prevent save button double click
            var btnClicked = component.get("v.saveBtnClicked");  

            if (btnClicked == false) {
                component.set("v.saveBtnClicked", true); 

                if(helper.salesPriceValidate(component,event)) {
                    helper.saveRecords(component, event); 
                }
            }
        }
        catch(e){
            console.log(e);
        }
    }
})