/*Helper class for Component to Display the Asset records related to an Order for Assets & Entitlements Design*/
({
    navigateOrderPage : function (component, event, helper) {
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
    
    loadAllAssets : function (component, event, helper) {
        var orderId = component.get("v.recordId");
        var action = component.get("c.getAssetsWrapper"); 
        
        action.setParams({
            orderID : orderId
        });
        
        component.set("v.loading", false);
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                
                // Load main asset list
                // ====================================================
                var assetWrapperListServer = response.getReturnValue(); 
                
                if(assetWrapperListServer.length > 0){
                    // Sort descending order
                    assetWrapperListServer.sort(function(a,b){
                        if (a.ParentAssetName < b.ParentAssetName) return 1; 
                        if (a.ParentAssetName > b.ParentAssetName) return -1; 
                        return 0; 
                    }); 
                    
                    // Sort ascending order - empty Parent Asset kept at bottom of list
                    assetWrapperListServer.sort(function(a,b){
                        if (a.ParentAssetName != "" && b.ParentAssetName != "") {
                            if (a.ParentAssetName < b.ParentAssetName) return -1; 
                            if (a.ParentAssetName > b.ParentAssetName) return 1; 
                            return 0; 
                        }
                    }); 
                    
                    component.set("v.assetWrapperList", assetWrapperListServer); 
                    
                    // Load associated asset list 
                    // ====================================================
                    var ascWrapperListServer = response.getReturnValue(); 
                    
                    // Sort ascending order by asset name 
                    ascWrapperListServer.sort(function(a,b){
                        if (a.ast.Name < b.ast.Name) return -1; 
                        if (a.ast.Name > b.ast.Name) return 1; 
                        return 0; 
                    });
                    
                    component.set("v.ascAssetWrapperList", ascWrapperListServer); 
                    
                    // Get original page's sObject's name 
                    // ====================================================
                    if (!$A.util.isEmpty(assetWrapperListServer.length) && !$A.util.isUndefined(assetWrapperListServer.length)) {
                        // Case: There are more than 1 asset wrappers 
                        component.set("v.originSObjectName", assetWrapperListServer[0].OriginSObjectName); 
                    }
                    else {
                        // Case: There is only 1 asset wrappers
                        component.set("v.originSObjectName", assetWrapperListServer.OriginSObjectName); 
                    }
                } else{
                    component.set("v.noAssets", true);
                }
            } 
            else {
                // debugger; 
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    
    updateAllAssets : function (component, event, helper) {
        // debugger;  
        
        var assetWrapperList = component.get("v.assetWrapperList"); 
        var action = component.get("c.saveAssets"); 
        var orderId = component.get("v.recordId");
        var serializedAssetsWrapper = JSON.stringify(assetWrapperList); 
        
        //Check if on the previous save an error was encountered
        if(component.get("v.error") !== undefined || component.get("v.error") !== ""){
            //Reset the error message
            component.set("v.error", "");
        }
        
        action.setParams({
            orderID : orderId,
            localAssetsWrappers : serializedAssetsWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                var assetWrapperListServer = response.getReturnValue(); 
                
                //Check if the asset wrapper list server has more than one record
                if(assetWrapperListServer.length > 1){
                    component.set("v.assetWrapperList", assetWrapperListServer);
                    helper.navigateOrderPage (component, event, helper); 
                } else if(assetWrapperListServer.length == 1){
                    if(assetWrapperListServer[0].includes('Error')){ //If the asset wrapper only has one record, then an error was encountered
                        //Set the error message to notify the user that there was an issue
                        component.set("v.error", assetWrapperListServer[0]);
                    }
                }
            }
            else {
                debugger; 
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    
    openAssetListModal : function (component, event, helper) {
        component.find("primaryAssetModal").changeVisibility(true); 
    },
    
    selectParentAsset : function (component, event, helper) {
        // debugger; 
        
        var radioButtons = component.find("parentAssetCheckbox"); 
        var assetWrapperList = component.get("v.assetWrapperList"); 
        var newParentAssetID = component.get("v.currentSelectedParentAssetID"); 
        
        if (!$A.util.isEmpty(assetWrapperList.length) && !$A.util.isUndefined(assetWrapperList.length)) {
            // Case: There are more than 1 asset wrappers. 
            for (var key in assetWrapperList) {
                if (!assetWrapperList.hasOwnProperty(key)) continue; 
                
                var assetWrapper = assetWrapperList[key]; 
                
                if (assetWrapper.ast.Id === newParentAssetID) {
                    // debugger; 
                    component.set("v.currentSelectedParentAssetName", assetWrapper.ast.Name); 
                }
            }
        }
        else {
            // Case: There is only 1 asset wrapper. 
            debugger; 
        }
        
        // Update assetWrapperList
        // debugger; 
        var currentSelectedAsset = component.get("v.currentSelectedAsset"); 
        var newParentAssetName = component.get("v.currentSelectedParentAssetName"); 
        
        if (!$A.util.isEmpty(assetWrapperList.length) && !$A.util.isUndefined(assetWrapperList.length)) {
            // Case: There are more than 1 asset wrappers. 
            for (var key in assetWrapperList) {
                if (!assetWrapperList.hasOwnProperty(key)) continue; 
                
                var assetWrapper = assetWrapperList[key]; 
                
                if (assetWrapper.ast.Id === currentSelectedAsset.ast.Id) {
                    debugger; 
                    assetWrapper.ParentAssetID = newParentAssetID; 
                    assetWrapper.ParentAssetName = newParentAssetName; 
                }
            }
        }
        else {
            // Case: There is only 1 asset wrapper. 
        }
        
        component.set("v.assetWrapperList", assetWrapperList); 
    },
    
    saveSelectedAssets : function (component, event, helper) {
        // debugger; 
        
        var assetWrapperList = component.get("v.assetWrapperList"); 
        var currentSelectedAssetID = event.currentTarget.id; 
        
        if (!$A.util.isEmpty(assetWrapperList.length) && !$A.util.isUndefined(assetWrapperList.length)) {
            // Case: There are more than one asset in the list. 
            
            for (var key in assetWrapperList) {
                if (!assetWrapperList.hasOwnProperty(key)) continue; 
                
                var assetWrapper = assetWrapperList[key]; 
                
                if (assetWrapper.ast.Id === currentSelectedAssetID) {
                    component.set("v.currentSelectedAsset", assetWrapper); 
                    component.set("v.currentSelectedParentAssetID", assetWrapper.ParentAssetID); 
                    component.set("v.currentSelectedParentAssetName", assetWrapper.ParentAssetName);
                    // debugger; 
                }
            }
        }
        else {
            // Case: There is only one asset in the list. 
        }	
    },
    
    openAssAssetModal : function (component, event, helper) {
        component.find("associatedAssetModal").changeVisibility(true); 
    },
    
    getCurrentSelectedAsset : function (component, event, helper) {
        // debugger; 
        var currentMainAssetID = event.currentTarget.id; 
        var assetWrapperList = component.get("v.assetWrapperList"); 
        
        if (!$A.util.isEmpty(assetWrapperList.length) && !$A.util.isUndefined(assetWrapperList.length)) {
            // Case: There are more than 1 main assets. 
            
            for (var key in assetWrapperList) {
                if (!assetWrapperList.hasOwnProperty(key)) continue; 
                
                var assetW = assetWrapperList[key]; 
                if (assetW.ast.Id === currentMainAssetID) {
                    component.set("v.currentSelectedAsset", assetW); 
                    // debugger; 
                }
            }
        }
        else {
            // Case: There is only 1 main asset. 
        }
    },
    
    selectAssocAsset : function (component, event, helper) {
        // debugger; 
        
        var radioBtns = component.find("associatedAssetRadio");
        var ascAssetList = component.get("v.ascAssetWrapperList");  
        var assetWList = component.get("v.assetWrapperList"); 
        var currentMainAsset = component.get("v.currentSelectedAsset"); 
        
        // Get associated asset Name 
        if (!$A.util.isEmpty(ascAssetList.length) && !$A.util.isUndefined(ascAssetList.length)) {
            // Case: There are more than 1 associated assets. 
            
            for (var key in ascAssetList) {
                if (!ascAssetList.hasOwnProperty(key)) continue; 
                
                var ascAsset = ascAssetList[key]; 
                var ascAssetID = ascAsset.ast.Id; 
                
                if (ascAssetID === component.get("v.currentSelectedAscAssetID")) {
                    var ascAssetName = ascAsset.ast.Name; 
                    component.set("v.currentSelectedAscAssetName", ascAssetName); 
                    // debugger; 
                }
            }
        }
        else {	
            // Case: There is only 1 associated asset. 
        }
        
        // Display the local selected associated asset front end 
        
        if (!$A.util.isEmpty(assetWList.length) && !$A.util.isUndefined(assetWList.length)) {
            // Case: There are more than 1 asset wrapper. 
            
            for (var key in assetWList) {
                if (!assetWList.hasOwnProperty(key)) continue; 
                
                var asset = assetWList[key]; 
                if (asset.ast.Id === currentMainAsset.ast.Id) {
                    asset.AssociatedAssetID = component.get("v.currentSelectedAscAssetID");
                    asset.AssociatedAssetName = component.get("v.currentSelectedAscAssetName"); 
                    // debugger; 
                }
            }
        }
        else {
            // Case: There is only 1 asset wrapper. 
        }
        component.set("v.assetWrapperList", assetWList); 
        debugger; 
    },
    
    getSelectedAscAsset : function (component, event, helper) {
        // debugger; 
        var selected = event.getSource().get("v.text"); 
        component.set("v.currentSelectedAscAssetID", selected); 
    },
    
    getSelectedParentAsset : function (component, event, helper) {
        var selected = event.getSource().get("v.text"); 
        component.set("v.currentSelectedParentAssetID", selected); 
    },
    
    sortAssociatedAssetList : function (component, event, helper) {
        // TODO: sort the associated asset list 
        // debugger; 
    },
    
    sortMainAssetList : function (component, event, helper) {
        // TODO: sort the main asset list 
        // debugger; 
    },
    
    massUpdateAssetList : function (component, event, helper) {
        //Get the asset List from the variable which is set on the init method
        var assetWrapperList = component.get("v.assetWrapperList"); 
        
        //Getting the inserted value from Mass update section
        var valueInstallDate = component.find("aInstallDate").get("v.value");
        var valueAssetStatus = component.find("aStatus").get("v.value");
        var valueUniqueIdentifier = component.find("aUniqueIdentifier").get("v.value");
        var sizeAssetList = assetWrapperList.length;
        
        if((valueAssetStatus !== undefined && valueAssetStatus !== "") || (valueUniqueIdentifier !== undefined && valueUniqueIdentifier !== "") || (valueInstallDate !== undefined && valueInstallDate !== "")) {
            if (!$A.util.isEmpty(sizeAssetList) && !$A.util.isUndefined(sizeAssetList)) {
                for(var i = 0; i < assetWrapperList.length; i++){
                    if(valueAssetStatus !== undefined && valueAssetStatus !== "") {
                        assetWrapperList[i].Status = valueAssetStatus;
                    }
                    if(valueUniqueIdentifier !== undefined && valueUniqueIdentifier !== ""){
                        assetWrapperList[i].AssetIdentifier = valueUniqueIdentifier;
                    }
                    if(valueInstallDate !== undefined && valueInstallDate !== ""){
                        assetWrapperList[i].InstallDate = valueInstallDate;
                    }
                }
                //Update the assetList variable with the updated values
                component.set("v.assetWrapperList",assetWrapperList);
                component.set("v.massUpdateMessage",sizeAssetList +" records are updated in below table");
            } else {
                component.set("v.massUpdateMessage","No Values for the Updates");
            }
        } else {
            component.set("v.massUpdateMessage","No Values for the Updates");
        }
    }
    
})