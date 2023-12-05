({
    /*Add isRefreshed method()*/
    doInit : function(component, event, helper) {

        try{
            helper.hasPermissionHelper(component,event,helper);
            console.log(component.get("v.hasPermission"));
            //helper.getObjectType(component,event,helper);
			//console.log('OBJECT VALUE' + component.get("v.sObjectName"));
            helper.getFields(component, event, helper);
			helper.loadRoles(component, event, helper);
			
			}
            catch(e){
                console.log(e);
            }
    },
       
       // @-26-6 add for search records in products  
    searchContact : function(component,event,helper){
        
        // debugger; 
         console.log('searchContact got called..');         
        if(component.get("v.searchKeyword").length > 0){
            helper.searchContactRecords(component,event,helper);
               
        }else{
            helper.fetchDefaultRecords(component,event);
        }
     },
    // @-26-6 add for close the model box 
    CloseModalOne : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
            
    save : function(component, event, helper) {
       //debugger; 
	    //helper.getSelected(component);
        var btnClicked = component.get("v.saveBtnClicked"); 
 		console.log('INSIDE SAVE');
        if (btnClicked == false){           
            component.set("v.saveBtnClicked", true); 

                var lobId = component.get("v.recordId");
                var lstContacts = component.get("v.pillsList");
                var roleList = component.find("rolePL"); 
                var roleMap = new Object(); 
				var objType = component.get("v.sObjectName");
                console.log('LST CONTACTS'+ lstContacts);
				console.log('roleList'+ roleList);
				//console.log('roleMap'+ lstContacts);
				console.log('Getting Roles Value');
                if(objType === "Account_LOB__c") {
					if (!$A.util.isUndefined(roleList.length) && !$A.util.isEmpty(roleList.length)) {
						// Case: roleList is list of Cmps, not one Cmp 

						for (var key in roleList){
							if (!roleList.hasOwnProperty(key)) continue; 

							var obj = roleList[key]; 
							var contactId = obj.get("v.name"); 
							var roleValue = obj.get("v.value"); 

							roleMap[contactId] = roleValue; 
							console.log('ROLE VALUE IN IF' + roleMap);
						}
					}
					else {
						// Case: roleList is one component 
						var contactId = roleList.get("v.name"); 
						var roleValue = roleList.get("v.value"); 

						roleMap[contactId] = roleValue; 
						console.log('ROLE VALUE IN ELSE' + roleMap);
					}
				}

                

                if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){
                    
                    var action = component.get("c.saveSelectedLOBContacts");
                    var lobContactRecords = JSON.stringify(lstContacts);
                    var roleRecords = JSON.stringify(roleMap); 
					console.log('calling apex method');
                    action.setParams({
                        lobContactRecords : lobContactRecords,
                        lobId : lobId,
                        role : roleRecords,
						objType : objType
                    });
                    
                    action.setCallback(this,function(a){
                        var state = a.getState();
                        
                        if(state === "SUCCESS"){
                            //alert('Success in calling server side Save action');
                            //window.location.href='/'+lobId;  
                            debugger; 
                            var recId =  component.get("v.recordId");                  
                            var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';



                            var device = $A.get("$Browser.formFactor");
                            $A.get("e.force:closeQuickAction").fire();

                            $A.get('e.force:refreshView').fire();
                            
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
    },
   
    cancel : function(component, event, helper) {
        //console.log(component.get("v.recordId"));
        //var lobId = component.get("v.recordId");
        //window.location.href='/'+lobId;
        $A.get("e.force:closeQuickAction").fire();
    },
    
	handleClick : function (component, event, helper) {
        // debugger; 
        var target = event.target;  
        var selectedContactId = target.getAttribute("data-contact-id");
        
        var pillsList = component.get("v.pillsList");  
        var lstContacts = component.get("v.lstContacts");  
        //alert(lstContacts[0].Name);
        console.log('list of contacts' + component.get("v.lstContacts") );
		console.log('pills list before' + pillsList );
        //To check if list is not empty or null    
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id==selectedContactId)
                {
                    lstContacts[i].Is_Selected__c = Boolean('TRUE');
                    pillsList.push(lstContacts[i]);

                }
            }
            component.set("v.disabledSave",false);
            console.log('@ListContacts'+lstContacts[0].Id);
            component.set("v.lstContacts",lstContacts);
            component.set("v.pillsList",pillsList);
            console.log("@PILLLIST" + pillsList[0].Id);
            
        }
    },
    // remove selected records
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
            component.set("v.disabledSave",true);       
        }
        //console.log(pillsList);
        component.set("v.pillsList",pillsList);
        
        var lstContacts = component.get("v.lstContacts");  
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id == removePillId)
                {
                    // console.log(lstContacts[i].Is_Selected__c);
                    lstContacts[i].Is_Selected__c = false;
                    // console.log(lstContacts[i].Is_Selected__c);
                }
            }
            //console.log(lstContacts);
            component.set("v.lstContacts",lstContacts);
        }
        
    },

    

    onRoleChange: function(component, event, helper){

    },
    isRefreshed: function(cmp,event,helper){
        
    }
})