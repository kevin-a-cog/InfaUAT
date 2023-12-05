({
    doInit : function(component, event, helper) {
        helper.getPicklistValues(component, event, helper);        
        helper.getColumnDefinitions(component,helper);
    },
    //To handle the change in the value of picklist
    onProductChange : function(component, event, helper) {
        component.set('v.forecastProduct', event.getSource().get("v.value"));
        helper.getProducts(component);
    },
    onCountryChange : function(component, event, helper) {
        component.set('v.addOnCountry',event.getSource().get("v.value"));
    },
    onProductFamilyChange : function(component, event, helper) {
        component.set('v.productFamily', event.getSource().get("v.value"));
        helper.getProducts(component);
    },
    onBUChange : function(component, event, helper) {
        component.set('v.businessUnit', event.getSource().get("v.value"));
        helper.getProducts(component);
    },
    onCategoryChange : function(component, event, helper) {
        component.set('v.addOnCategory',event.getSource().get("v.value"));
    },
    //Controller to serach the existing Product records
    searchProducts : function(component, event, helper) {
		helper.getProducts(component);     
    },
    CloseModalOne: function (component, event, helper) {
        var installBase = component.get('v.installBase');
        //alert(installBase);
        if (installBase !== null && installBase !== '') {
            var sURL = $A.get("$Label.c.PRM_Org_Url") + "lightning/r/InstallBase__c/" + installBase + "/view";
            sforce.one.navigateToURL(sURL);
        }
        else {
            var sURL = $A.get("$Label.c.PRM_Org_Url") + "lightning/o/InstallBase__c/list?filterName=Recent";
            sforce.one.navigateToURL(sURL);            
        }
    },
    isRefreshed: function(cmp,event,helper){
        
    },
    //Controller for the + button at the record level
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'addProduct':
                helper.addProduct(component, helper,row);
                break;
        }
    },
    // removing the records in the pill section showing the selected records
    handleRemove : function (component, event, helper) {
        // debugger; 
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
        var products = component.get("v.products");  
        if(!$A.util.isEmpty(products) && !$A.util.isUndefined(products)){  
            for(var i=0;i<products.length;i++){
                if(products[i].Id == removePillId)
                {
                    products[i].Is_Selected__c = false;
                }
            }
            component.set("v.products",products);
        }
        
    },
    //When the lookup component is changed
    handleComponentEvent : function(component, event, helper) {
        var selectedRecord = event.getParam("recordByEvent");
        component.set('v.installBase', selectedRecord.Id);
        //alert(selectedRecord.Id);
    },
    addInstallBaseMapping:function(component, event, helper){
        helper.packInstallBaseMappingRecords(component,helper);    	
    },
    //Invoking the lookup component method
    getInitialRecId : function(component, event, helper){
        var childCmp = component.find("lookupComponent");
        var auraMethodResult = childCmp.setInitialValue(component.get('v.IBrecord'));
        //initialing the record ID of the initial install Base
        component.set('v.installBase',component.get('v.IBrecord').Id);
    }
})