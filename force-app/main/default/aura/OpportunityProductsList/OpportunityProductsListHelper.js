({ 
    
    doInit : function(component, event, helper) {
        // console.log('helper: doInit got called..');
        var action = component.get("c.getPage"); 
        
        // TODO: Change picklist fields dynamically? 
        // var picklist_fields = ['Product_Family__c','Products__c','Family',
        //                        'Pricing_Business_Model__c','Processing_Engine__c'];
        var picklist_fields = ['Product_Family__c','Forecast_Product__c','Family',
                               'Pricing_Business_Model__c','Processing_Engine__c'];
        
        var cmp_attributes = ["v.productFamily", "v.productForecast","v.ForcastFamily","v.productBusiness","v.productEngine"];
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();            
            if (state === "SUCCESS") {
                var values = response.getReturnValue();
                //fetch all the values of picklist fields
                for(var k=0;k < picklist_fields.length;k++){
                    var picklist_field_values = values.optionsMap[picklist_fields[k]];
                    var picklist_values=[];
                    picklist_values.push({value: '', label: '--None--'});
                    for(var i=0;i< picklist_field_values.length;i++){
                        var value = picklist_field_values[i];
                        picklist_values.push({value: value, label: value});
                    }
                    component.set(cmp_attributes[k], picklist_values); 
                } 
                
            } else {
                // console.log(state);
            }
            
        });
        
        $A.enqueueAction(action);   
    },
    // @-26-6 add for load default records in products
    fetchDefaultRecords : function(component,event,helper){
        // fetch Default products [LIMIT 25]
        debugger; 
        // console.log('helper: fetchDefaultRecords got called..');
        var lstProducts = JSON.stringify(component.get("v.pillsList"));        
        var action = component.get("c.initProducts");
        
        // Get arrays of dynamic fields from FieldSet
        var fieldStrQuery = component.get("v.fieldStrQry"); 
        var fieldArray = component.get("v.fieldarray"); 
        
        action.setParams({
            'pillsList' : lstProducts,
            'fieldString': fieldStrQuery
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                debugger; 
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    //   component.set("v.Message", true);
                } else {
                    //   component.set("v.Message", false);
                }
                
                // set lstProducts list with return value from server.
                console.log('@Developer-->' + JSON.stringify(storeResponse))
                component.set("v.lstProducts", storeResponse);
            }
            else {
                debugger; 
            }
        });
        $A.enqueueAction(action);
    },
    
    searchProdRecords : function(component,event,helper){
        // debugger; 
        // console.log('helper: searchProdRecords got called..');
        var action = component.get("c.productSearchBar");
        var fieldQueryString = component.get("v.fieldStrQry"); 
        var lstProducts = JSON.stringify(component.get("v.pillsList"));
        
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'pillsList' : lstProducts,
            'fieldQry'  : fieldQueryString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                // debugger; 
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    //   component.set("v.Message", true);
                } else {
                    //   component.set("v.Message", false);
                }
                // set lstProducts list with return value from server.
                component.set("v.lstProducts", storeResponse);
                
                //Re-setting the Pick list values when User serach using Product Search Bar option
                component.find("pForecast").set("v.value", "");
                component.find("pFamily").set("v.value", "");
                component.find("pFamily2").set("v.value", "");
                
            }  
            else {
                debugger; 
            }
            
        });
        $A.enqueueAction(action);
    },
    
    getSelected : function(component){
        debugger; 
        
        //21-06 added
        // console.log('helper: getSelected got called..');
        var lstProducts = component.get("v.pillsList");
        var oppId = component.get("v.recordId");
        var fieldStringQuery = component.get("v.fieldStrQry"); 
        var salesPriceEdited = component.get("v.salePriceIsEdited"); 
        
        // Split fieldStringQuery into an array of Strings
        var fieldArr = fieldStringQuery.split(","); 
        fieldStringQuery = ""; 
        
        for (var key in fieldArr){
            if (!fieldArr.hasOwnProperty(key)) continue; 
            
            var obj = fieldArr[key]; 
            obj = obj.replace(/\s/g, ''); 
            fieldStringQuery += ("Product2." + obj + ","); 
        }
        
        fieldStringQuery = fieldStringQuery.replace(/,\s*$/, "");
        
        // debugger;       
        //To check if list is not empty or null
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts)){ 
            
            //Calling the Apex Function
            var action = component.get("c.getSelectedProducts");
            
            //Json Encode to send the data to Apex Class
            var prodRecords = JSON.stringify(lstProducts);
            //Setting the Apex Parameter
            action.setParams({
                prodRecords : prodRecords,
                oppId : oppId,
                fieldStringQry : fieldStringQuery
            });
            
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                
                //check if result is successfull
                if(state === "SUCCESS"){
                    debugger; 
                    // Perform Action after the result
                    var freshServerSelectedList = a.getReturnValue(); 
                    var localSelectedList = component.get("v.lstselectedProducts"); 
                    
                    // Merge local & server list so that: 
                    // - Keep server list 
                    // - Change all UnitPrice from server to local UnitPrice 
                    var displayedList = this.merge(freshServerSelectedList, localSelectedList); 
                    component.set("v.lstselectedProducts",displayedList);
                    
                    // Hide/show Section 1 and Section 2
                    var element = document.getElementById("section1");
                    element.classList.remove("slds-show");
                    element.classList.add("slds-hide");
                    
                    var element1 = document.getElementById("section2");
                    element1.classList.remove("slds-hide");
                    element1.classList.add("slds-show"); 
                    document.getElementById("errorPopUp").style.left = (screen.width - 475) + 'px';
                    component.set("v.showNext",true);
                    
                    // Get transaction types local value 
                    // var transationTypeCmp = component.find("transTypePL"); 
                    // var transTypeLocalMap = component.get("v.transTypeMap"); 
                    
                    
                    // debugger; 
                    
                    // if (!$A.util.isUndefined(transationTypeCmp.length) && !$A.util.isEmpty(transationTypeCmp.length)) {
                    //     // This means transationTypeCmp is an array of components, not one component
                    
                    //     for (var key in transationTypeCmp) {
                    //         debugger; 
                    //         if (transationTypeCmp.hasOwnProperty(key)) continue; 
                    
                    //         var obj = transationTypeCmp[key];
                    //         var priceBookentryID = obj.get("v.name");  
                    //         var localVal = transTypeLocalMap[priceBookentryID]; 
                    //         obj.set("v.value", localVal); 
                    //     }
                    // }
                    // else {
                    //     // Case: transationTypeCmp is one component 
                    //     var priceBookentryID = transationTypeCmp.get("v.name");  
                    //     var localVal = transTypeLocalMap[priceBookentryID]; 
                    //     transationTypeCmp.set("v.value", localVal); 
                    // }
                } 
                else {
                    // alert('Error in calling server side action');
                    debugger; 
                }
            });
            
            //adds the server-side action to the queue        
            $A.enqueueAction(action);
        }
        
    },
    // 27/6 
    salesPriceValidate : function(component,event){
        // console.log('helper: salesPriceValidate got called..');
        // debugger; 
        var isTrue = true ;
        var lstProducts = component.get("v.lstselectedProducts");  
        var ErrorMsg = [];
        if(lstProducts.length > 1){
            for(var i = 0; i < lstProducts.length; i++){  
                
                if($A.util.isEmpty(lstProducts[i].UnitPrice)){
                    component.find("price")[i].set("v.class" , 'slds-input slds-has-error') ;
                    
                    $A.util.addClass(component.find("errorPopUpBox"), 'slds-show');
                    
                    var sStr = 'Item ' + (i + 1 ) + ' has errors in these fields: SalesPrice.';
                    ErrorMsg.push(sStr);
                    
                    component.set("v.ErrorMsgLst",ErrorMsg );    
                    
                    isTrue = false;
                    
                }else{
                    
                    component.find("price")[i].set("v.class" , 'slds-input');
                    
                    if(isTrue){
                        
                        $A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');
                        $A.util.removeClass(component.find("errorPopUpBox"), 'slds-show');  
                    }
                    
                    //component.set("v.ErrorMsgLst",null ); 
                }   
            }
            
            
        }else
            
            if(lstProducts.length == 1 && component.get("v.lstselectedProducts")[0].UnitPrice == null){
                isTrue = false;
                
                $A.util.addClass(component.find("price"), 'slds-has-error');
                $A.util.addClass(component.find("errorPopUpBox"), 'slds-show');
                
                var sStr = 'Item 1 has errors in these fields: SalesPrice.';
                ErrorMsg.push(sStr);
                component.set("v.ErrorMsgLst",ErrorMsg );
                
            }else{
                
                $A.util.removeClass(component.find("price"), 'slds-has-error');
                $A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');
                $A.util.removeClass(component.find("errorPopUpBox"), 'slds-show');
                //component.set("v.ErrorMsgLst",null );
                
            }
        
        // Display error message (red, bottom right)
        
        return isTrue;
    },
    
    getFields : function (component, event, helper){
        // debugger; 
        var action = component.get("c.getFields"); 
        var self = this; 
        var typeName = "Product2"; 
        var fsName = "AddProductsFieldSet"; 
        action.setParams({
            typeName: typeName,
            fsName: fsName
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                var fields = response.getReturnValue();
                component.set("v.fieldarray", fields);
                console.log("Dynamic fields: " + JSON.stringify(fields)); 
                
                
                // Combine all the fields into a string, to use in Query 
                var fieldStrQuery = ""; 
                
                for (var key in fields){
                    if (!fields.hasOwnProperty(key)) continue; 
                    
                    var obj = fields[key]; 

                    fieldStrQuery += (obj.fieldPath + ","); 
                }
                
                // Remove comma at the end of fieldStrQuery
                fieldStrQuery = fieldStrQuery.replace(/,\s*$/, "");
                component.set("v.fieldStrQry", fieldStrQuery); 
                
                // @-26-6 add for load default records in products 
                helper.fetchDefaultRecords(component,event);
            }
            else {
                debugger; 
            }
            
        });
        $A.enqueueAction(action);  
    },
    
    changeSalesPrice : function (component, event, helper){
        // debugger; 
        component.set("v.salePriceIsEdited", true); 
        // TODO: get the edited salesPrice & PriceBookEntryID 
        var selectedProductList = component.get("v.lstselectedProducts"); 
        var editedPriceList = component.find("price"); 
    },
    
    // 1. server -- 2. local
    merge : function (object1, object2){
        // debugger; 
        for (var key in object1){
            if (!object1.hasOwnProperty(key)) continue; 
            
            var obj = object1[key]; 
            var objID = obj.Id; 
            
            for (var key2 in object2){
                if (!object2.hasOwnProperty(key2)) continue; 
                
                var obj2 = object2[key2]; 
                var obj2ID = obj2.Id; 
                
                if (obj2ID == objID) {
                    obj.UnitPrice = obj2.UnitPrice; 
                }
            }
        }
        
        return object1; 
    },
    
    loadTransactionTypes : function (component, event, helper){
        var action = component.get("c.getTransTypeSelect"); 
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                
                var opts = response.getReturnValue();  
                component.set("v.transTypeOptions", opts); 
                
            }
            else {
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action); 
        
        
    },
    
    /*getOppRecordType:function(component, event, helper){
        var recId =  component.get("v.recordId");
        console.log(recId);
        var action = component.get("c.fetchOppRecordType"); 
        action.setParams({
            "recordId":recId
        })
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var rtnValue = response.getReturnValue();
                if(!$A.util.isUndefined(rtnValue)){
                    if(rtnValue == 'New_Sales_Opportunity'){
                        component.set("v.opportunityRecType","New");
                    }
                    else if(rtnValue == 'Renewal_Opportunity'){
                        component.set("v.opportunityRecType","Renewal");
                    }
                    else{
                        component.set("v.opportunityRecType","--None--");
                    }
                }
                this.loadTransactionTypes(component, event, helper);
            }
            else if(state == 'ERROR'){
                console.log(JSON.stringify(response.getError()));
                this.loadTransactionTypes(component, event, helper);
            }

        });
        $A.enqueueAction(action); 
            
    },*/
    
    getOpportunityType:function(component, event, helper){
        var recId =  component.get("v.recordId");
        console.log(recId);
        var action = component.get("c.fetchOpportunityType"); 
        action.setParams({
            "recordId":recId
        })
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var rtnValue = response.getReturnValue();
                if(!$A.util.isUndefined(rtnValue)){
                    if(rtnValue == 'Renewal'){
                        component.set("v.opportunityType","Renewal");
                    }
                    else if(rtnValue == 'Upsell'){
                        component.set("v.opportunityType","Upsell");
                    } else {
                        component.set("v.opportunityType","New");
                    }
                }
                this.loadTransactionTypes(component, event, helper);
            }
            else if(state == 'ERROR'){
                console.log(JSON.stringify(response.getError()));
                this.loadTransactionTypes(component, event, helper);
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    getOpportunityPricebookName:function(component, event, helper){
        var recId =  component.get("v.recordId");
        console.log(recId);
        var action = component.get("c.fetchOpportunityPricebook");  
        var ErrorMsg = [];
        
        action.setParams({
            "recordId":recId
        })
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(rtnValue)){
                    console.log(rtnValue);
                    component.set("v.opptyPricebookName",rtnValue);
                }else {
                    console.log('Value returned not defined ='+rtnValue);
                    var cmpTarget = component.find('error-msg-Id');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                }
            }
            else if(state == 'ERROR'){
                console.log(JSON.stringify(response.getError()));            
            }
            
        });
        $A.enqueueAction(action); 
    },
    showNotification : function(component, event, helper,message,type) {
        var vfMethod = component.get("v.VfPageMethod");
        vfMethod(message,20000,type,function(){});
    }
    
})