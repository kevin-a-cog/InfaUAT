({
    doInit : function(component, event, helper) {
        
        try{
            
            //Added by Sumit on 06/18/2019 for QCA 1229
            helper.getOpportunityPricebookName(component, event, helper);
                helper.doInit(component, event, helper);
                helper.getFields(component, event, helper); 
                
                // Note: 7/12 - Removed fetchDefaultRecords() to be in callBack function of getFields()
                
                //component.set("v.disabledNext",true);  // no more need condition was added to the button for disabled
                
                //Added by Rahul on 9/19/2017.
                //Commenting the method "getOppRecordType" since now we are using "getOpportunityType" to populate the field
                //Transaction type in Opportunity Products.
                //helper.getOppRecordType(component, event, helper);
                
                //Added by CPQ team on 08/12/2017
                helper.getOpportunityType(component, event, helper);
                
                // Load transaction type options
                
                //helper.loadTransactionTypes(component, event, helper); 
            
        }
        catch(e){
            console.log(e);
        }
    },
    
    // @-26-6 add for search records in products  
    searchProdcut2 : function(component,event,helper){
        // debugger; 
        // console.log('searchProdcut2 got called..');
        if(component.get("v.searchKeyword").length > 0){
            helper.searchProdRecords(component,event,helper);
            
        }else{
            helper.fetchDefaultRecords(component,event);
        }
    },
    // @-26-6 add for close the model box 
    CloseModalOne : function(component,event,helper){
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
    
    onSelectChange : function(component, event, helper) {
        // debugger; 
        // console.log('--onSelectChange called--');
        var selectedvalueforcast = component.find("pForecast").get("v.value");
        var selectedvalueFamily = component.find("pFamily").get("v.value");
        var selectedvalueFamily2 = component.find("pFamily2").get("v.value");
        var fieldQueryString = component.get("v.fieldStrQry"); 
        
        var action = component.get("c.searchProducts");
        
        //21-06 added to check if there is any products under the selected pills, to avoid to user to select the same 
        //product multiple times.
        var pillsList = JSON.stringify(component.get("v.pillsList")); 
        
        /* Call helper method to get the Search value of the Product and it's related list */
        //helper.searchProdRecords(component,event,helper);
        
        action.setParams({  'forcast' : selectedvalueforcast, 
                          'family' : '', 
                          'family2' : '', 
                          'pillsList' : pillsList,
                          'fieldsStrQry' : fieldQueryString
                         });
        // console.log('--set params for onSelectChange--');        
        
        var productFamilyList = new Set();
        // console.log('---productFamilyList:' +productFamilyList);
        
        var forecastList = new Set();
        // console.log('---forecastList:' +forecastList);
        
        action.setCallback(this, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") {        
                // debugger; 
                // console.log('success');                 
                var returnValue = a.getReturnValue();
                
                //Re-select Product Family picklist
                for (var i=0;i<returnValue.length; i++){    
                    //   if(productFamilyList.indexOf(returnValue[i].ProductFamily)) {
                    // productFamilyList.add(returnValue[i].ProductFamily);   
                    productFamilyList.add(returnValue[i].Product_Family__c);   
                    //   }
                }
                // console.log(productFamilyList);
                
                var familyOptionList = [];
                
                familyOptionList.push({value: '', label: '--None--'});
                productFamilyList.forEach(function(family){
                    familyOptionList.push({value: family, label: family});
                });    
                
                component.set("v.productFamily", familyOptionList);
                
                //Re-select Forecast Family picklist
                for (var i=0;i<returnValue.length; i++){    
                    // forecastList.add(returnValue[i].ForecastFamily);   
                    forecastList.add(returnValue[i].Family);  
                }
                // console.log(forecastList);
                
                var forcastFamilyOptionList = [];
                
                forcastFamilyOptionList.push({value: '', label: '--None--'});
                forecastList.forEach(function(family2){
                    forcastFamilyOptionList.push({value: family2, label: family2});
                });    
                
                component.set("v.ForcastFamily", forcastFamilyOptionList);
                component.set("v.lstProducts",returnValue); 
                
                component.find("searchId").set("v.value", "");
                
                
                
            } else {
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    onSelectProductFamily : function(component, event, helper) {
        // debugger; 
        // console.log('onSelectProductFamily called');
        
        var selectedvalueforcast = component.find("pForecast").get("v.value");
        var selectedvalueFamily = component.find("pFamily").get("v.value");
        var selectedvalueFamily2 = component.find("pFamily2").get("v.value");
        var fieldString = component.get("v.fieldStrQry"); 
        
        // console.log('@@@ selectedvalueforcast: ' +selectedvalueforcast);
        var action = component.get("c.searchProducts");
        
        //21-06 added to check if there is any products under the selected pills, to avoid to user to select the same 
        //product multiple times.
        var pillsList = JSON.stringify(component.get("v.pillsList")); 
        
        /* Call helper method to get the Search value of the Product and it's related list */
        //helper.searchProdRecords(component,event,helper);
        
        action.setParams({  'forcast' : selectedvalueforcast, 
                          'family' : selectedvalueFamily, 
                          'family2' : '', 
                          'pillsList' : pillsList,
                          'fieldsStrQry' : fieldString
                         });
        // console.log('onSelectProductFamily : set params'); 
        //console.log('@@@ forcast :'+forcast+ '@@@ family :'+family+ '@@@ family2:' +family2);       
        
        var forecastList = new Set();
        //var forecastList = [];
        
        action.setCallback(this, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") {        
                // debugger; 
                var returnValue = a.getReturnValue();                         
                
                // console.log('success');           
                
                // var forecastList = [];
                
                // if(!component.get('v.required') || component.get('v.showNone')) {
                //     forecastList.push({
                //         'label' : '--None--',
                //         'value' : null,
                //         'class' : 'optionClass'
                //     });
                // }
                
                //Re-select Forecast Family picklist
                for (var i=0;i<returnValue.length; i++){    
                    // forecastList.add(returnValue[i].ForecastFamily);   
                    forecastList.add(returnValue[i].Family);   
                }
                // console.log(forecastList);
                
                var forcastFamilyOptionList = [];
                
                forcastFamilyOptionList.push({value: '', label: '--None--'});
                forecastList.forEach(function(family2){
                    forcastFamilyOptionList.push({value: family2, label: family2});
                });    
                
                component.set("v.ForcastFamily", forcastFamilyOptionList);
                component.set("v.lstProducts",returnValue);  
                
                // Re-setting productForecast ( Product Search Bar) for On-slect options
                component.find("searchId").set("v.value", "");
                
            } else {
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    onSelectForecastFamily : function(component, event, helper) {
        // console.log('onSelectForecastFamily called');
        // debugger; 
        var selectedvalueforcast = component.find("pForecast").get("v.value");
        var selectedvalueFamily = component.find("pFamily").get("v.value");
        var selectedvalueFamily2 = component.find("pFamily2").get("v.value");
        var fieldQueryString = component.get("v.fieldStrQry"); 
        
        var action = component.get("c.searchProducts");
        
        //21-06 added to check if there is any products under the selected pills, to avoid to user to select the same 
        //product multiple times.
        var pillsList = JSON.stringify(component.get("v.pillsList")); 
        
        /* Call helper method to get the Search value of the Product and it's related list */
        //helper.searchProdRecords(component,event,helper);
        
        action.setParams({  'forcast' : selectedvalueforcast, 
                          'family' : selectedvalueFamily, 
                          'family2' : selectedvalueFamily2, 
                          'pillsList' : pillsList,
                          'fieldsStrQry' : fieldQueryString
                         });
        
        // console.log('onSelectForecastFamily : set params'); 
        // console.log('@@@ forcast :'+forcast+ '@@@ family :'+family+ '@@@ family2:' +family2);       
        
        var forecastList = [];
        
        action.setCallback(this, function(a) {
            var state = a.getState();            
            if (state === "SUCCESS") {        
                // debugger; 
                var returnValue = a.getReturnValue();                         
                
                // console.log('success');           
                
                //Get Forecast Family picklist
                for (var i=0;i<returnValue.length; i++){    
                    if(forecastList.indexOf(returnValue[i].Family)) {
                        forecastList.push(returnValue[i].Family);   
                    }
                }
                // console.log(forecastList);
                
                var forcastFamilyOptionList = [];
                forecastList.forEach(function(family2){
                    forcastFamilyOptionList.push({value: family2, label: family2});
                });    
                component.set("v.lstProducts",returnValue);
                
                // Re-setting productForecast ( Product Search Bar) for On-slect options
                component.find("searchId").set("v.value", ""); 
                
            } else {
                // console.log(state);
                debugger; 
            }
            
        });
        
        $A.enqueueAction(action);
        
    },    
    
    nextSection : function(component, event, helper) {
        helper.getSelected(component);
        
    },
    
    backSection : function(component, event, helper) {
        debugger; 
        try{
            // Keep transaction type values 
            var transactionTypeCmp = component.find("transTypePL");
            var transactionTypeMap = new Object(); 
            for (var key in transactionTypeCmp){
                // transactionTypeMap
                if (!transactionTypeMap.hasOwnProperty(key)) continue; 
                
                var obj = transactionTypeCmp[key]; 
                var priceBookEntryID = obj.get("v.name"); 
                var transactionTypeValue = obj.get("v.value"); 
                
                transactionTypeMap[priceBookEntryID] = transactionTypeValue; 
            }
            
            component.set("v.transTypeMap", transactionTypeMap); 
            
            // Hide/show sections
            $A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');
            $A.util.removeClass(component.find("errorPopUpBox"), 'slds-show');
            
            
            var element = document.getElementById("section2");
            element.classList.remove("slds-show");
            element.classList.add("slds-hide");
            
            var element1 = document.getElementById("section1");
            element1.classList.remove("slds-hide");
            element1.classList.add("slds-show");
            
            component.set("v.showNext",false);
            
            
            // Reset the Error section
            var lstProducts = component.get("v.lstselectedProducts"); 
            if(lstProducts.length > 1){
                for(var i = 0; i < lstProducts.length; i++){  
                    component.find("price")[i].set("v.class" , 'slds-input');
                    $A.util.removeClass(component.find("errorPopUpBox"), 'slds-show');
                    $A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');
                }
            }
            
            if(lstProducts.length == 1){
                $A.util.removeClass(component.find("price"), 'slds-has-error');
                $A.util.removeClass(component.find("errorPopUpBox"), 'slds-hide');           
                $A.util.addClass(component.find("errorPopUpBox"), 'slds-hide');           
            }
        }catch(e){
            console.log(e);
        }
    },
    
    save : function(component, event, helper) {
        debugger; 
        var btnClicked = component.get("v.saveBtnClicked"); 
        
        if (btnClicked == false){           
            component.set("v.saveBtnClicked", true); 
            
            if(helper.salesPriceValidate(component,event)){ 
                var oppId = component.get("v.recordId");
                
                var lstProducts = component.get("v.lstselectedProducts");
                var transactionTypeList = component.find("transTypePL"); 
                var transactionTypeMap = new Object(); 
                
                
                if (!$A.util.isUndefined(transactionTypeList.length) && !$A.util.isEmpty(transactionTypeList.length)) {
                    // Case: transactionTypeList is list of Cmps, not one Cmp 
                    
                    for (var key in transactionTypeList){
                        if (!transactionTypeList.hasOwnProperty(key)) continue; 
                        
                        var obj = transactionTypeList[key]; 
                        var priceBookEntryID = obj.get("v.name"); 
                        var transactionTypeValue = obj.get("v.value"); 
                        
                        transactionTypeMap[priceBookEntryID] = transactionTypeValue; 
                    }
                }
                else {
                    // Case: transactionTypeList is one component 
                    var priceBookEntryID = transactionTypeList.get("v.name"); 
                    var transactionTypeValue = transactionTypeList.get("v.value"); 
                    
                    transactionTypeMap[priceBookEntryID] = transactionTypeValue; 
                }
                
                
                
                if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts)){
                    
                    var action = component.get("c.saveSelectedProducts");
                    var oppProdRecords = JSON.stringify(lstProducts);
                    var transTypeRecords = JSON.stringify(transactionTypeMap); 
                    
                    action.setParams({
                        oppProdRecords : oppProdRecords,
                        oppId : oppId,
                        transactionType : transTypeRecords
                    });
                    
                    action.setCallback(this,function(a){
                        var state = a.getState();
                        
                        if(state === "SUCCESS"){
                            //alert('Success in calling server side Save action');
                            //window.location.href='/'+oppId;  
                            debugger; 
                            var retVal = a.getReturnValue();
                            if(retVal !== 'true'){
                                helper.showNotification(component,event,helper,retVal,'error');
                            }
                            else{
                                var recId =  component.get("v.recordId");                  
                                var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
                                
                                var device = $A.get("$Browser.formFactor");
                                
                                if (device === "DESKTOP") {
                                    window.location.assign(sURL);
                                }
                                else {
                                    sforce.one.navigateToURL(sURL);
                                }
                            }
                            
                        } else {
                            //alert('Error in calling server side action');
                            debugger; 
                            var errors = a.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    alert("Error message: " + 
                                          errors[0].message);
                                }
                            } else {
                                alert("Unknown error");
                            }
                        }
                    });
                    
                    $A.enqueueAction(action);
                }
            }
        }        
    },
    
    cancel : function(component, event, helper) {
        //console.log(component.get("v.recordId"));
        var oppId = component.get("v.recordId");
        window.location.href='/'+oppId;
    },
    handleClick : function (component, event, helper) {
        // debugger; 
        var target = event.target;  
        var selectedProductId = target.getAttribute("data-contact-id");
        
        var pillsList = component.get("v.pillsList");  
        var lstProducts = component.get("v.lstProducts");  
        //alert(lstProducts[0].Name);
        
        //To check if list is not empty or null    
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts)){  
            for(var i=0;i<lstProducts.length;i++){
                if(lstProducts[i].Id==selectedProductId)
                {
                    lstProducts[i].Is_Selected__c = Boolean('TRUE');
                    pillsList.push(lstProducts[i]);
                    // console.log(lstProducts[i]);
                }
            }
            component.set("v.disabledNext",false);
            //console.log(lstProducts);
            component.set("v.lstProducts",lstProducts);
            component.set("v.pillsList",pillsList);
            
        }
    },
    //21-06 added
    handleRemove : function (component, event, helper) {
        // debugger; 
        event.preventDefault();
        //console.log(event.getSource().get("v.value"));
        //console.log(event.getSource().get("v.href"));
        // console.log(event.getSource().get("v.name"));
        var removePillId = event.getSource().get("v.name");
        var pillsList = component.get("v.pillsList");  
        
        for(var i=0;i<pillsList.length;i++){
            if(pillsList[i].Id == removePillId)
            {
                //var index = array.indexOf(removePillId);
                pillsList.splice(i,1);
            }
        }
        if(pillsList.length == 0){      
            component.set("v.disabledNext",true);       
        }
        //console.log(pillsList);
        component.set("v.pillsList",pillsList);
        
        var lstProducts = component.get("v.lstProducts");  
        if(!$A.util.isEmpty(lstProducts) && !$A.util.isUndefined(lstProducts)){  
            for(var i=0;i<lstProducts.length;i++){
                if(lstProducts[i].Id == removePillId)
                {
                    // console.log(lstProducts[i].Is_Selected__c);
                    lstProducts[i].Is_Selected__c = false;
                    // console.log(lstProducts[i].Is_Selected__c);
                }
            }
            //console.log(lstProducts);
            component.set("v.lstProducts",lstProducts);
        }
        
    },
    
    onSalesPriceChange : function (component, event, helper){
        // debugger; 
        helper.changeSalesPrice(component, event, helper); 
    },
    
    onTransTypeChange: function(component, event, helper){
        var updatedValue = component.find("transTypePL").get("v.value");
        
        if(updatedValue && updatedValue != '--None--'){
            component.set("v.opportunityRecType", updatedValue);
        }
    }
})