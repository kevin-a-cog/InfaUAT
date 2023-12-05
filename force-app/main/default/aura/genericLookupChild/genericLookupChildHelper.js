({ 
    
    hasPermissionHelper : function ( component, event, helper){
        var action = component.get("c.hasCSMPermission");
        action.setParams({
            "lstCustomPermissions": component.get("v.customPermissions"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('Scuccess....');
                component.set("v.hasPermission", response.getReturnValue());
                //console.log (' custom permission: ' + component.get ("v.hasPermission"));
            }
            else {
                console.log('Problem in hasCSPermission Method: ' + state);
            }
            
        });
        $A.enqueueAction(action);
    },
    getParamsHelper : function ( component, event, helper){
        var action = component.get("c.getParams");		
        action.setParams({
            "mdtRecord" : component.get("v.buttonName"),
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            //console.log("***"+state);
            if (state === "SUCCESS") {
                var params=response.getReturnValue();
                component.set("v.ParentObj", params.ParentObj__c);
                component.set("v.Child1Object", params.Child1Object__c);
                component.set("v.fieldSetName", params.fieldSetName__c);
                component.set("v.JunctionField2", params.JunctionField2__c);
                component.set("v.Child1ParentField", params.Child1ParentField__c);
                component.set("v.searchFieldName", params.searchFieldName__c);
                component.set("v.JunctionField1", params.JunctionField1__c);
                component.set("v.Child2ParentField", params.Child2ParentField__c);
                component.set("v.JunctionField1SourceObj", params.JunctionField1SourceObj__c);
                component.set("v.Child1JunctionSourceObjField", params.Child1JunctionSourceObjField__c);                
                component.set("v.JunctionObject", params.JunctionObject__c);
                component.set("v.filterCriteria", params.Filter_Criteria__c);
                //console.log(params.Filter_Criteria__c);
                //console.log(component.get("v.filterCriteria"));
                helper.getRelationshipName(component, event, helper);
                helper.getFields(component, event, helper);
            }
            else {
                debugger; 
            }
            
        });
        $A.enqueueAction(action);
    },    
    
    // @-26-6 add for load default records in products
    fetchDefaultRecords : function(component,event,helper){
        // fetch Default contacts [LIMIT 25]
        //debugger;
        //console.log('helper: fetchDefaultRecords got called..');
        var lstContacts = component.get("v.pillsList");
        //console.log('++++++++++++  '+lstContacts);        
        var action = component.get("c.contactSearchBar");
        debugger;
        action.setParams({
            'searchKeyWord': '',
            'pillsList' : lstContacts,
            'fieldQry'  : component.get("v.fieldStrQry"),
            'Child2Id' : component.get("v.Child2Id"),
            'Child2Object' : component.get("v.Child2Object"),
            'Child2ParentRelationship' : component.get("v.Child2ParentRelationship"),
            'JunctionObject' : component.get("v.JunctionObject"),
            'Child1Object' : component.get("v.Child1Object"),
            'Child1ParentField' : component.get("v.Child1ParentField"),
            'searchFieldName' : component.get("v.searchFieldName"),
            'JunctionField2' :component.get("v.JunctionField2"),
            'JunctionField1' :component.get("v.JunctionField1"),
            'Child2ParentField':component.get("v.Child2ParentField"),
            'JunctionField1SourceObj':component.get("v.JunctionField1SourceObj"),
            'Child1JunctionSourceObjField': component.get("v.Child1JunctionSourceObjField"),
            'filterCriteria': component.get("v.filterCriteria")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                debugger; 
                var storeResponse = response.getReturnValue();
                
                //console.log(`default records before processing --> ${JSON.stringify(storeResponse)}`);
                
                storeResponse.forEach(row => {
                    
                    if (row['ARR__c'] != undefined) {
                        if (row['CurrencyIsoCode'] != 'USD') {
                            row['ConvertedARR'] = `${row['CurrencyIsoCode']} ${Number.parseFloat(row['ARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} (USD ${Number.parseFloat(row['ConvertedARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')})`;
                        }
                        else {
                            row['ConvertedARR'] = `${row['CurrencyIsoCode']} ${Number.parseFloat(row['ARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')}`;
                        }
                    }

                    for (const col in row) {
                        const curCol = row[col];
                        if (typeof curCol === 'object') {
                            const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                            this.flattenStructure(row, col + '_', curCol);
                            if (newVal === null) {
                                delete row[col];
                            }
                            else {
                                row[col] = newVal;
                            }
                        }
                    }
                });
                
                //console.log(`default records after processing --> ${JSON.stringify(storeResponse)}`);

                var lookupFields = component.get('v.lookupFields');
                lookupFields.forEach(function (field) {
                    storeResponse.forEach(function (record) {
                        if (record[field]) {
                            record[field] = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + record[field] + '/view';
                        }
                    })
                });                
                
                component.set("v.lstContacts", storeResponse);
                component.set("v.recordCount",storeResponse.length);
                //console.log('@@@@@@@@@@xxx'+ response.getReturnValue().length);
                // set lstContacts list with return value from server.
                //console.log('@Developer-->' + JSON.stringify(storeResponse))
                //console.log('@@@@@@@' + JSON.stringify(storeResponse));
                //console.log('@ list of contacts' + JSON.stringify(component.get("v.lstContacts")));
            }
            else {
                console.log('Error');
                debugger; 
            }
        });
        //console.log('before enqueue action.   ');
        
        $A.enqueueAction(action);
        //console.log(component.get("v.filterCriteria"));
    },
    
    
    searchContactRecords : function(component,event,helper){
        //console.log('@@@@@@@@@@@@@@@.........'+component.get("v.Child2ParentField"));
        var action = component.get("c.contactSearchBar");
        var lstContacts = component.get("v.pillsList");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'pillsList' : lstContacts,
            'fieldQry'  : component.get("v.fieldStrQry"),
            'Child2Id' : component.get("v.Child2Id"),
            'Child2Object' : component.get("v.Child2Object"),
            'Child2ParentRelationship' : component.get("v.Child2ParentRelationship"),
            'JunctionObject' : component.get("v.JunctionObject"),
            'Child1Object' : component.get("v.Child1Object"),
            'Child1ParentField' : component.get("v.Child1ParentField"),
            'searchFieldName' : component.get("v.searchFieldName"),
            'JunctionField2' :component.get("v.JunctionField2"),
            'JunctionField1' :component.get("v.JunctionField1"),
            'Child2ParentField':component.get("v.Child2ParentField"),
            'JunctionField1SourceObj':component.get("v.JunctionField1SourceObj"),
            'Child1JunctionSourceObjField': component.get("v.Child1JunctionSourceObjField"),
            'filterCriteria': component.get("v.filterCriteria")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('@@@@@state' + state);
            if (state === "SUCCESS") {
                // debugger; 
                var storeResponse = response.getReturnValue();
                storeResponse.forEach(row => {

                    if (row['ARR__c'] != undefined) {
                        if (row['CurrencyIsoCode'] != 'USD') {
                            row['ConvertedARR'] = `${row['CurrencyIsoCode']} ${Number.parseFloat(row['ARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} (USD ${Number.parseFloat(row['ConvertedARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')})`;
                        }
                        else {
                            row['ConvertedARR'] = `${row['CurrencyIsoCode']} ${Number.parseFloat(row['ARR__c']).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')}`;
                        }
                    }

                    for (const col in row) {
                        const curCol = row[col];
                        if (typeof curCol === 'object') {
                            const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                            this.flattenStructure(row, col + '_', curCol);
                            if (newVal === null) {
                                delete row[col];
                            }
                            else {
                                row[col] = newVal;
                            }
                        }
                    }
                });
                
                var lookupFields = component.get('v.lookupFields');
                lookupFields.forEach(function (field) {
                    storeResponse.forEach(function (record) {
                        if (record[field]) {
                            record[field] = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + record[field] + '/view';
                        }
                    })
                });
                
                component.set("v.lstContacts", storeResponse);
                component.set("v.recordCount", storeResponse.length);
                // if storeResponse size is 0 ,display no record found message on screen.
                //console.log('@@@@@@@...' + storeResponse);
            }  
            else {
                debugger; 
            }
            
        });
        $A.enqueueAction(action);
        //console.log(component.get("v.filterCriteria"));
    },    
    
    getRelationshipName : function ( component, event, helper){
        var action= component.get("c.getRelationshipNames");
        action.setParams({
            "Child2Object" : component.get("v.Child2Object"),
            "Child2ParentField" : component.get("v.Child2ParentField")
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('In getRelationshipName callback');
                var params=response.getReturnValue();
                component.set("v.Child2ParentRelationship", params);
                //console.log("+++++++++++++"+params[1]);              
            }
            else {
                debugger; 
            }
        });
        $A.enqueueAction(action);
    },    
    
    getFields : function (component, event, helper){
        
        var action = component.get("c.getFields"); 
        //var self = this; 
        
        action.setParams({
            "Child1Object" : component.get("v.Child1Object"),
            "fieldSetName" : component.get("v.fieldSetName"),
            "JunctionField1SourceObj" : component.get("v.JunctionField1SourceObj")               
        });

        // console.log(`Child1Object -> ${component.get("v.Child1Object")}`);
        // console.log(`fieldSetName -> ${component.get("v.fieldSetName")}`);
        // console.log(`JunctionField1SourceObj -> ${component.get("v.JunctionField1SourceObj")}`);
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            //console.log("***"+state);
            if (state === "SUCCESS") {
                // debugger;				
                var res = response.getReturnValue();
                //console.log("Dynamic fields: " + JSON.stringify(fields));
                var currencyIsoCode = res['CurrencyIsoCode'];
                //res.delete('CurrencyIsoCode');
                console.log('$$$$$$ ' + currencyIsoCode);
                console.log('$$$$$ '+res);
                
                var columns = [];
                var lookupFields = [];
                var fieldApiNames = [];
                var addProdButton = {
                    label: "",
                    type: "button-icon",
                    initialWidth: 80,
                    typeAttributes: {
                        alternativeText: "Add Product",
                        iconName: "utility:add",
                        name: "addRecord",
                        disabled: { fieldName: "Is_Selected__c" },
                        variant: "border-filled",
                        class: "slds-m-left_xx-small"
                    }
                };
                columns.push(addProdButton);

                
                //console.log(`response --> ${JSON.stringify(res)}`);

                for (var each in res) {
                    var column = new Map();
                    column["label"] = res[each][0];
                    column["fieldName"] = (each.includes('.')) ? each.replace('.', '_') : each;
                    column["sortable"] = true;
                    fieldApiNames.push(each);

                    if (each == 'ARR__c') {
                        column["type"] = 'text';
                        column["initialWidth"] = 260;
                        column["fieldName"] = 'ConvertedARR';
                        fieldApiNames.push('convertCurrency(ARR__c) ConvertedARR__c');
                    }
                    else if (res[each][1] == 'CURRENCY') {
                        column["type"] = 'currency';
                        column["typeAttributes"] = { currencyCode: { fieldName: 'CurrencyIsoCode'},minimumIntegerDigits: 1, maximumFractionDigits: 2 };
                        column["cellAttributes"] = { alignment: 'left' };
                    }
                    else if (res[each][1] == 'DATE' || res[each][1] == 'DATETIME') {
                        column["type"] = 'date';
                        column["typeAttributes"] = { year: "numeric", month: "2-digit", day: "2-digit" };
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
                    else if (each.includes('.') && (each.includes('Name') || each.includes('Number'))) {
                        var lfield=each.split('.').reverse()[0];
                        lookupFields.push(each.replace('.', '_').replace(lfield, 'Id'));
                        column["type"] = "url";
                        column["fieldName"] = each.replace('.', '_').replace(lfield, 'Id');
                        column["typeAttributes"] = { label: { fieldName: each.replace('.', '_') }, target: '_self' };
                        column["sortable"] = false;
                    }
                    else {
                        column["type"] = "text";
                    }
                    if (each !='CurrencyIsoCode') {
                        columns.push(column);
                    }
                }
                //console.log(`getFields Columns --> ${JSON.stringify(columns)}`);
                component.set("v.fieldarray", columns);
                component.set('v.lookupFields', lookupFields);
                helper.formQueryString(component, event, helper, fieldApiNames);                
            }
            else {
                debugger; 
            }
            
        });		
        $A.enqueueAction(action);  
    },
    formQueryString: function (component, event, helper, fields) {
        // Combine all the fields into a string, to use in Query 
        var fieldStrQuery = "";
        
        /*
        for (var key in fields) {
            if (!fields.hasOwnProperty(key)) continue;
            
            var obj = fields[key];
            
            fieldStrQuery += (obj.fieldPath + ",");
        }
        
        // Remove comma at the end of fieldStrQuery
        fieldStrQuery = fieldStrQuery.replace(/,\s*$/, "");

        */
        component.set("v.fieldStrQry", fields.join());
        //console.log('++++++++++++++'+fieldStrQuery);
        //console.log('In get fields @@@@@@@@@@@@@@@.........' + component.get("v.Child2ParentField"));
        helper.fetchDefaultRecords(component, event);       
    },
    addProduct: function (component, helper, row) {
        var prodId = row.Id;
        var pillsList = component.get("v.pillsList");
        var products = component.get("v.lstContacts");
        //To check if list is not empty or null
        if (!$A.util.isEmpty(products) && !$A.util.isUndefined(products)) {
            for (var i = 0; i < products.length; i++) {
                if (products[i].Id == prodId) {
                    products[i].Is_Selected__c = Boolean("TRUE");
                    pillsList.push(products[i]);
                    //products.splice(i,1);
                }
            }
            component.set("v.lstContacts", products);
            component.set("v.pillsList", pillsList);

            console.log(`add lstContacts --> ${JSON.stringify(products)}`);
            console.log(`add pillsList --> ${JSON.stringify(pillsList)}`);
        }
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.lstContacts");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.lstContacts", data);
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
    
    flattenStructure: function (topObject, prefix, toBeFlattened) {
        for (const prop in toBeFlattened) {
            const curVal = toBeFlattened[prop];
            if (typeof curVal === 'object') {
                flattenStructure(topObject, prefix + prop + '_', curVal);
            } else {
                topObject[prefix + prop] = curVal;
            }
        }
    }
})