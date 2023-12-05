({
    /*Add isRefreshed method()*/
    doInit : function(component, event, helper) {
        
        try{
            helper.hasPermissionHelper(component,event,helper);
            helper.getParamsHelper(component,event,helper);			
        }
        catch(e){
            console.log(e);
        }
    },
    
    searchContact : function(component,event,helper){
        //console.log('searchContact got called..');         
        if(component.get("v.searchKeyword").length > 0){
            helper.searchContactRecords(component,event,helper);
            
        }else{
            helper.fetchDefaultRecords(component,event);
        }
    },
    
    save : function(component, event, helper) {
        var btnClicked = component.get("v.saveBtnClicked"); 
        //console.log('INSIDE SAVE');
        var fromcreaterisk = component.get("v.fromcreatescreen");
        if(fromcreaterisk){
            
            var action = component.get("c.insertRisk");
            var riskrecord = component.get("v.riskrec");
            var rec = component.get("v.selectedrec");                   
        	console.log('riskrecord'+riskrecord);
            debugger;
            action.setParams({planRec : riskrecord,
                              planRecTypeId : rec,
                            });
            action.setCallback(this, function(response) {
            var recId = response.getReturnValue();                     	                       
            
            if (btnClicked == false){
            component.set("v.saveBtnClicked", true);
            var lstContacts = component.get("v.pillsList");
            if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){
                var action = component.get("c.saveSelectedLOBContacts");
                action.setParams({
                    lobContactRecords : component.get("v.pillsList"),
                    Child2Id : component.get("v.Child2Id"),
                    Child2Object : component.get("v.Child2Object"),
                    JunctionField2 : component.get("v.JunctionField2"),
                    JunctionField1 : component.get("v.JunctionField1"),
                    JunctionObject : component.get("v.JunctionObject"),   
                    JunctionField1SourceObj : component.get("v.JunctionField1SourceObj")  //JunctionField1SourceObj
                });
                action.setCallback(this,function(a){
                    var state = a.getState();
                    if(state === "SUCCESS"){  
                        debugger; 
                        var recId =  component.get("v.Child2Id");                  
                        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
                        var device = $A.get("$Browser.formFactor");
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        
                    } 
                    else {;
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
         });
             $A.enqueueAction(action);    
        }else {
        if (btnClicked == false){
            component.set("v.saveBtnClicked", true);
            var lstContacts = component.get("v.pillsList");
            console.log(`pills -> ${JSON.stringify(component.get("v.pillsList"))}`);
            if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){
                var action = component.get("c.saveSelectedLOBContacts");
                action.setParams({
                    lobContactRecords : component.get("v.pillsList"),
                    Child2Id : component.get("v.Child2Id"),
                    Child2Object : component.get("v.Child2Object"),
                    JunctionField2 : component.get("v.JunctionField2"),
                    JunctionField1 : component.get("v.JunctionField1"),
                    JunctionObject : component.get("v.JunctionObject"),   
                    JunctionField1SourceObj : component.get("v.JunctionField1SourceObj")  //JunctionField1SourceObj
                });
                action.setCallback(this,function(a){
                    var state = a.getState();
                    if(state === "SUCCESS"){  
                        debugger; 
                        var recId =  component.get("v.Child2Id");                  
                        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
                        var device = $A.get("$Browser.formFactor");
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        
                    } 
                    else {;
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
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleClick : function (component, event, helper) { 
        var target = event.target;  
        var selectedContactId = target.getAttribute("data-contact-id");        
        var pillsList = component.get("v.pillsList");  
        var lstContacts = component.get("v.lstContacts");
        //console.log('list of contacts' + component.get("v.lstContacts") );
        //console.log('pills list before' + pillsList );
        //To check if list is not empty or null    
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id==selectedContactId)
                {
                    lstContacts[i].Is_Selected__c = Boolean('TRUE');
                    pillsList.push(lstContacts[i]);
                    
                }
            }
            //console.log('@ListContacts'+lstContacts[0].Id);
            component.set("v.lstContacts",lstContacts);
            component.set("v.pillsList",pillsList);
            //console.log("@PILLLIST" + pillsList[0].Id);
            
        }
    },
    // remove selected records
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
        var lstContacts = component.get("v.lstContacts");  
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id == removePillId)
                {
                    lstContacts[i].Is_Selected__c = false;
                }
            }
            component.set("v.lstContacts",lstContacts);
        }
        
    },
    CloseModalOne : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
        
    },
    isRefreshed: function(cmp,event,helper){
        
    },
    
    //Controller for the + button at the record level
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'addRecord':
                helper.addProduct(component, helper, row);
                break;
        }
    },
    // Client-side controller called by the onsort event handler
    handleSort: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        var columns = cmp.get("v.fieldarray");
        var sortByCol = columns.find(column => fieldName === column.fieldName);
        var fieldLabel = sortByCol.label;
        cmp.set("v.sortMethod", fieldLabel);
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }    
})