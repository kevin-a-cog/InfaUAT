({   
    doInit: function(component, event, helper) {       

        var action = component.get("c.getRecordTypeValues");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = helper.getParameterByName(component , event, 'inContextOfRef');
                var context = JSON.parse(window.atob(value));
                var parentid = context.attributes.recordId;
                component.set("v.parentRecordId", parentid);      
                console.log('Account Id : '+parentid);
                 
                var recordTypes = response.getReturnValue();
                
                if(parentid!= undefined){
                    
                    if(parentid.indexOf('001') == 0){
                        component.set("v.navigatetoobj",'Account');
                        component.set("v.navigatetorec",parentid);                        
                        component.set("v.accountid",parentid);
                        for(var key in recordTypes){
                            component.set("v.selectedRecordTypeId",key);
                            component.set("v.selectedrectypelabel",recordTypes[key]);
                            
                            if(recordTypes[key] =='Sales Account Plan'){
                                component.set("v.salesplanLayout","true");
                                component.set("v.setaddplanpr",false);
                                component.set("v.addplanpr",false); 
                                component.set("v.buttonlabel",'Save'); 
                            }else{
                                //component.set("v.accPlanLayout","true");

                                // check unassigned plans @Akhilesh 10 Jan 2022
                                var action = component.get("c.hasUnasignedProductPlans");
                                console.log('component.get("v.accountid")===> ' + component.get("v.accountid"));
                                action.setParams({ planAccountId : component.get("v.accountid") });
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        component.set("v.accPlanLayout","true");

                                        var bHasUnassignedMemebers = response.getReturnValue();
                                        console.log(' hasUnasignedProductPlans response --> ' + bHasUnassignedMemebers);
                                        component.set("v.bAccPlanLayout_SaveClose" ,bHasUnassignedMemebers);
                                    }
                                    else if (state === "INCOMPLETE") {}
                                    else if (state === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                            }
                                        } 
                                        else {
                                            console.log("Unknown error");
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                            }
                        } 
                    } 
                }
                else{
                    component.set("v.showMessage",true);
                }
                
                /**Check if there are any plan products available for OBSP Plan **/
                var isOBSPPlan = component.get("v.accPlanLayout");
                
                if(isOBSPPlan){
                    var getPlanProdCount = component.get("c.planproductcount");                                                        
                    getPlanProdCount.setParams({                                
                        'recid': parentid                                
                    });
                    
                    getPlanProdCount.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            if(response.getReturnValue()){                                        
                                component.set("v.setaddplanpr",true);
                                component.set("v.buttonlabel",'Save & Add PlanProducts');                                
                            } else{
                                component.set("v.setaddplanpr",false);
                                component.set("v.buttonlabel",'Save');                           
                            }
                        }
                    });
                    $A.enqueueAction(getPlanProdCount);
                }
            }
        });
        $A.enqueueAction(action);       
        
    }, 
    
    closeFocusedTab : function(component, event, helper) {
        if(component.get("v.PlanRecordId")!=undefined){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                url: '/lightning/r/Plan__c/'+component.get("v.PlanRecordId")+'/view',
            }).then(function(response) {
                workspaceAPI.focusTab({tabId : response});
            })
            .catch(function(error) {
                console.log(error);
            });
        }else{
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        }
    },
    
    
    handleSuccess : function(component, event, helper) {
        console.log('On Success after Submit');
        
        var payload = event.getParams().response;
        var cretedPlanID = payload.id;
        var openPlanProductsScreen = component.get("v.openPlanProductsScreen");
        component.set("v.PlanRecordId",cretedPlanID);
        var action = component.get("c.createPlanTeamMembers");
        action.setParams({planId : cretedPlanID});
        $A.enqueueAction(action);

        if(!openPlanProductsScreen){      
            $A.get("e.force:closeQuickAction").fire();

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success :",
                "message": "Plan has been created successfully !",
                "type" : "success"
            });
            toastEvent.fire();

            var navService = component.find("navService");          
            var pageReference;                
            pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: cretedPlanID,
                    objectApiName: "Plan__c",
                    actionName: "view"
                }
            };
         //   navService.navigate(pageReference); 
           // $A.get("e.force:closeQuickAction").fire();

          /////  component.set("v.PlanRecordId",cretedPlanID);
           //// component.set("v.openInterlockModal",true); 
            

        }else if(openPlanProductsScreen === true){
            component.set("v.PlanRecordId",cretedPlanID);
            component.set("v.isLoading",false);
            component.set("v.accPlanLayout","false");
            component.set("v.salesplanLayout","false");
            component.set("v.addplanpr",true);
        }
    },

    handleOverrideChange : function(component, event, helper){
        var isoverride = component.find("overrideEligiblity").get("v.value");
        console.log('isoverride = '+isoverride);
        component.set("v.overrideEligiblity",isoverride);
    },
    
    handleOnError : function(component, event, helper){
        var error = event.getParam('errorCode');
        var message = event.getParam('message');
        component.set("v.isLoading",false);
        console.log(error);
        console.log(message);
    },
    
    //LOGIC TO SEND PLAN DETAILS TO ADD PLAN PRODUCTS COMPONENTS : MAHESH GANTI 08/20/2020
    handleNext : function(component, event, helper){     
        event.preventDefault();
        component.set("v.isLoading",true);
        var selectedRecordTypeId = component.get("v.selectedRecordTypeId");       
        
        const fields = event.getParam('fields');
        fields.RecordTypeId = selectedRecordTypeId;
        console.log('fields'+ JSON.stringify(fields));

        component.set("v.planRecDetails",JSON.stringify(fields));        
          
            
        var action = component.get("c.getRecordInserted");
        action.setParams({objRecord :Object.assign({ 'SobjectType' : 'Plan__c' }, fields)});
        action.setCallback(this, function(response) {
            var recId = response.getReturnValue();
            component.set("v.PlanRecordId",recId);
            component.set("v.accPlanLayout",false);
            component.set("v.salesplanLayout","false");

            var openPlanProductsScreen = component.get("v.openPlanProductsScreen");
            console.log('openPlanProductsScreen '+openPlanProductsScreen);
            
            if(openPlanProductsScreen === false){
                var addTeamMembers = component.get("c.createPlanTeamMembers");
                addTeamMembers.setParams({planId : recId});
                $A.enqueueAction(addTeamMembers);

                var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
               // location.href = sURL;               
               component.set("v.openInterlockModal",true); 
               component.set("v.isLoading",false);
               component.set("v.accPlanLayout",false);
               component.set("v.salesplanLayout",false);

            }else{
                component.set("v.addplanpr",true);
                component.set("v.isLoading",false);
            }
            
        });
        $A.enqueueAction(action);     
           
    },
    handlePlanProducts: function(component, event, helper){        
        var overrideEligiblity = component.get("v.overrideEligiblity");
        var overideReason = '';
        var planName = component.find("planName").get("v.value");
        var planDescription = component.find("descField").get("v.value");
        var coeCheck=component.find("coeGrp").get("v.value");
        var planType=component.find("planType").get("v.value");

        if(overrideEligiblity){
            overideReason = component.find("OverrideReason").get("v.value");
        }
        
        if( (overrideEligiblity && (overideReason === null ||overideReason=== undefined || overideReason===''))
        ||(planName === null ||planName=== undefined || planName==='')
        ||(planDescription === null ||planDescription=== undefined || planDescription==='')
        ||(coeCheck === null ||coeCheck=== undefined || coeCheck==='')
        ||(planType === null ||planType=== undefined || planType==='')) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error :",
                "message": "Please fill all the Mandatory fields",
                "type":"error"
            });
            toastEvent.fire();
        }else{
            var accountId = component.get("v.accountid");
            component.set("v.openPlanProductsScreen",true);
            component.set("v.isLoading",true);

            var action = component.get("c.getPlanOwner");
            action.setParams({accountId : accountId});
            action.setCallback(this, function(response){
                var ownerId = response.getReturnValue();
                if(ownerId !== null || ownerId!== undefined || ownerId != ''){
                    component.find("OwnerId").set("v.value", ownerId);
                }
                component.find("recordFormadp").submit(); 
            });
            $A.enqueueAction(action);

            
                       
        } 
         
    }
})