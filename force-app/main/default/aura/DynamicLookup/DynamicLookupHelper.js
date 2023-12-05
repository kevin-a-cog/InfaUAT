({ 
      // @-26-6 add for load default records in products
      fetchDefaultRecords : function(component,event,helper){
        // fetch Default contacts [LIMIT 25]
        //debugger;
        console.log('helper: fetchDefaultRecords got called..');
        var lstContacts = JSON.stringify(component.get("v.pillsList"));        
        var action = component.get("c.contactSearchBar");

        // Get arrays of dynamic fields from FieldSet
        //var fieldStrQuery = component.get("v.fieldStrQry"); 
        var fieldArray = component.get("v.fieldarray"); 
		var fieldQueryString = component.get("v.fieldStrQry"); 
		var parentRecordId = component.get("v.recordId");
		var objectType = component.get("v.sObjectName");

        console.log('Test....objtype'+objectType + 'qry'+fieldQueryString + 'Id'+parentRecordId);
        debugger;
        action.setParams({
                'pillsList' : lstContacts,
                'searchKeyWord': '',
				'fieldQry'  : fieldQueryString,
				'recordId' : parentRecordId,
				'objectType' : objectType
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
                console.log('@@@@@@@@@@xxx'+ response.getReturnValue().length);
                   // set lstContacts list with return value from server.
                console.log('@Developer-->' + JSON.stringify(storeResponse))
                component.set("v.lstContacts", storeResponse);
				console.log('@@@@@@@' + storeResponse);
                console.log('@ list of contacts' + component.get("v.lstContacts"));
            }
            else {
                console.log('Error');
                debugger; 
            }
        });
          console.log('before enqueue action.   ');

          $A.enqueueAction(action);
    },
    
    
    hasPermissionHelper : function ( component, event, helper){
        var action= component.get("c.hasCSMPermission");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Scuccess....');
                component.set("v.hasPermission", response.getReturnValue());
                console.log (' custom permission: ' + component.get ("v.hasPermission"));                
            }
            else {
               console.log('Problem in hasCSPermission Method: ' + state);
        	}
            
    	});
        $A.enqueueAction(action);
  },   
    
    
    searchContactRecords : function(component,event,helper){
        // debugger; 
        // console.log('helper: searchContactRecords got called..');
        var action = component.get("c.contactSearchBar");
        var fieldQueryString = component.get("v.fieldStrQry"); 
        var lstContacts = JSON.stringify(component.get("v.pillsList"));
		var parentRecordId = component.get("v.recordId");
		var objectType = component.get("v.sObjectName");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'pillsList' : lstContacts,
            'fieldQry'  : fieldQueryString,
			'recordId' : parentRecordId,
			'objectType' : objectType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@@state' + state);
            if (state === "SUCCESS") {
                // debugger; 
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                 //   component.set("v.Message", true);
                } else {
                 //   component.set("v.Message", false);
                }
                // set lstContacts list with return value from server.
                component.set("v.lstContacts", storeResponse);
             }  
             else {
                debugger; 
             }
 
         });
         $A.enqueueAction(action);
    },
    
	getFields : function (component, event, helper){

		var recId = component.get("v.recordId");

			var action = component.get("c.getFields"); 
			var self = this; 
		
			action.setParams({
					"recordId" : recId
				});
		
			action.setCallback(this, function(response) {
				var state = response.getState(); 

				console.log("***"+state);
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

					//  add for load default records in Contacts/Account Products 
					helper.fetchDefaultRecords(component,event);
				}
				else {
					debugger; 
				}
				
			});
		
		
        $A.enqueueAction(action);  
    },



    loadRoles : function (component, event, helper){
        var action = component.get("c.getRoleSelect"); 

        action.setCallback(this, function(response) {
            var state = response.getState(); 

            if (state === "SUCCESS") {
                
				var opts = response.getReturnValue();  
                component.set("v.roleOptions", opts); 
             
            }
            else {
                debugger; 
            }
            
        });

        $A.enqueueAction(action); 

        
    },
           
    })