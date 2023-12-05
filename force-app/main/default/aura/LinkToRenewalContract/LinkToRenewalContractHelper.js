({    	
    searchHelper1 : function(component,event) {
	  // call the apex class method 
	     
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({           
            'recordId' : component.get("v.recordId")
          });
      // set a callBack    
        action.setCallback(this, function(response) {         
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              component.set("v.spinneract",false);
                
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.hasContract", false);
                  
                } else {
                    component.set("v.hasContract", true);
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    searchHelper2 : function(component,event) {
	  // call the apex class method 
	   
     var action = component.get("c.fetchLookUpValuesofCanceledcontract");
      // set param to method  
        action.setParams({           
            'recordId' : component.get("v.recordId")
          });
      // set a callBack    
        action.setCallback(this, function(response) {         
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              component.set("v.spinneract",false);
             
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.hasContract1", false);
                  
                } else {
                    component.set("v.hasContract1", true);
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords1", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    searchHelper3 : function(component,event) {
	  // call the apex class method 
    var action = component.get("c.fetchContract");
      // set param to method  
        action.setParams({           
            'recordId' : component.get("v.recordId"),
               'contractNumber' : component.find('Aform').get('v.value')
          });
      // set a callBack    
        action.setCallback(this, function(response) {         
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                 // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.hasContract2", true);
                  
                } else {
                    component.set("v.hasContract2", false);
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords2", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);

	},
    setRenewalOppty : function(component,event){
          
           component.set("v.spinneract",true);         
       	var action = component.get("c.setRenewalOppty");   
        var listrec =  component.get("v.listOfSearchRecords");  
          var checkboxvalue = component.get("v.checkbox");     
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
         
       
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {             
                    selectedContacts.push(checkvalue[i].get("v.text"));                
            }
        }
        
        
       // alert(checkboxvalue);
      
/*       var ids=new Array();
         for (var i= 0 ; i < listrec.length ; i++){
        ids.push(listrec[i].ContractNumber);
    }*/
         var idListJSON=JSON.stringify(selectedContacts);
       
       action.setParams({         
            'OpptyRecordId' : component.get("v.recordId")  ,
           'ContractNumber' :  idListJSON,
           'checkbx'       :  checkboxvalue
          });
        // set a callBack    
        action.setCallback(this, function(response) {
     
          var state = response.getState();
          var recdId =  component.get("v.recordId");
              if (state === "SUCCESS") {                    
                var retVal = response.getReturnValue();   
                     component.set("v.spinneract",false); 
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/Opportunity/" + recdId+ "/view",
                      "isredirect": "true"
                    });
                    
                    urlEvent.fire();
                  if(retVal =='SUCCESS')
                    {
                        var ToastMessage; 
                        if(checkboxvalue == true){                            
                           ToastMessage =  "Contracts are linked and duplicate Opportunities are updated successfully.";                            
                        }
                        else 
                        {
                            ToastMessage =  "Contracts are linked successfully.";
                        }
                        var toastEvent = $A.get("e.force:showToast");                        
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "message": ToastMessage
                        });
                        toastEvent.fire();
                    } 
                  
                    else if(retVal =='LINKEDALREADY' )
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning!",
                            "type" : "warning",
                            "message": "Contract is already linked to this Opportunity."
                        });
                        toastEvent.fire();
                    }
                     
                    
       
                }
              } 
             if(response.getState() == 'ERROR')
            {
             	component.set("v.hasError",true);
                component.set("v.spinneract",false);
                component.set("v.ErrorMessage",response.getError()[0].message);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);    
    },
     setRenewalOppty1 : function(component,event){
          
           component.set("v.spinneract",true);         
       	var action = component.get("c.setRenewalOppty");   
        var listrec =  component.get("v.listOfSearchRecords1");  
          var checkboxvalue = component.get("v.checkbox1");        
       // alert(checkboxvalue);
      
       var ids=new Array();
         for (var i= 0 ; i < listrec.length ; i++){
        ids.push(listrec[i].ContractNumber);
    }
         var idListJSON=JSON.stringify(ids);
       
       action.setParams({         
            'OpptyRecordId' : component.get("v.recordId")  ,
           'ContractNumber' :  idListJSON,
           'checkbx'       :  checkboxvalue
          });
        // set a callBack    
        action.setCallback(this, function(response) {
     
          var state = response.getState();
          var recdId =  component.get("v.recordId");
              if (state === "SUCCESS") {                    
                var retVal = response.getReturnValue();   
                     component.set("v.spinneract",false); 
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/Opportunity/" + recdId+ "/view",
                      "isredirect": "true"
                    });
                    
                    urlEvent.fire();
                  if(retVal =='SUCCESS')
                    {  var ToastMessage; 
                        if(checkboxvalue == true){                            
                           ToastMessage =  "Contracts are linked and duplicate Opportunities are updated successfully.";                            
                        }
                        else 
                        {
                            ToastMessage =  "Contracts are linked successfully.";
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "message": ToastMessage
                        });
                        toastEvent.fire();
                    } 
                  
                    else if(retVal =='LINKEDALREADY' )
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning!",
                            "type" : "warning",
                            "message": "Contract is already linked to this Opportunity."
                        });
                        toastEvent.fire();
                    }
       
                     
                }
              }     
            if(response.getState() == 'ERROR')
            {
             	component.set("v.hasError",true);
                component.set("v.spinneract",false);
                component.set("v.ErrorMessage",response.getError()[0].message);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);    
    },
    setRenewalOppty2: function(component,event){
          
           component.set("v.spinneract",true);         
       	var action = component.get("c.setRenewalOppty");   
        var listrec =  component.get("v.listOfSearchRecords2");  
          var checkboxvalue = component.get("v.checkbox2");        
       // alert(checkboxvalue);
         
      var ids=new Array();
         for (var i= 0 ; i < listrec.length ; i++){
        ids.push(listrec[i].ContractNumber);
         }
         var idListJSON=JSON.stringify(ids);
       
       action.setParams({         
            'OpptyRecordId' : component.get("v.recordId")  ,
           'ContractNumber' :  idListJSON,
           'checkbx'       :  checkboxvalue
          });
        // set a callBack    
        action.setCallback(this, function(response) {
     
          var state = response.getState();
          var recdId =  component.get("v.recordId");
              if (state === "SUCCESS") {                    
                var retVal = response.getReturnValue();   
                     component.set("v.spinneract",false); 
                if(retVal != undefined && retVal!=null && retVal!="") 
                {                                                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/lightning/r/Opportunity/" + recdId+ "/view",
                      "isredirect": "true"
                    });
                    
                    urlEvent.fire();
                  if(retVal =='SUCCESS')
                    { var ToastMessage; 
                        if(checkboxvalue == true){                            
                           ToastMessage =  "Contracts are linked and duplicate Opportunities are updated successfully.";                            
                        }
                        else 
                        {
                            ToastMessage =  "Contracts are linked successfully.";
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "message":ToastMessage
                        });
                        toastEvent.fire();
                    } 
                   
                    else if(retVal =='LINKEDALREADY' )
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning!",
                            "type" : "warning",
                            "message": "Contract is already linked to this Opportunity."
                        });
                        toastEvent.fire();
                    }
       
                    
                }
              }     
            if(response.getState() == 'ERROR')
            {
             	component.set("v.hasError",true);
                component.set("v.spinneract",false);
                component.set("v.ErrorMessage",response.getError()[0].message);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);    
    },    
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
 })