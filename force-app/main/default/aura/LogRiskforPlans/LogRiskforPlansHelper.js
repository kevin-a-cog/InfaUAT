({
    getRiskTypePickListValues : function(component) {
        var action = component.get("c.getRiskTypePicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var riskTypeMap = [];
                for(var key in result){
                    riskTypeMap.push({key: key, value: result[key]});
                }
                console.log('riskTypeMap-->'+JSON.stringify(riskTypeMap));
                component.set("v.riskTypeMap", riskTypeMap);
            }
        });
        $A.enqueueAction(action);
        
         
        
        
    },
    getRiskRecordTypeId : function(component) {
        var action = component.get("c.getRiskRecordTypeId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // var result = response.getReturnValue();
                //component.set("v.riskRecTypeId",JSON.stringify(result));
                var mapOfRecordTypes = response.getReturnValue();
				//converting the map obtained into the desirable map form
                var Options = [];
                for(var key in mapOfRecordTypes){
                    var mapData = {};
					mapData['label']=mapOfRecordTypes[key];
					mapData['value']=key;
                    if(mapOfRecordTypes[key]=='Risk')
                    {
                         Options.push(mapData);
                    }
                   
				}
                var defaultData =Options[0];
                console.log('defaultData--'+JSON.stringify(defaultData));
                component.set("v.riskRecTypeId",defaultData['value']);                
             
            }
        });
        $A.enqueueAction(action);
        
    },

    validateRisks : function(component) {
        var planId=component.get("v.recordId");
        var selRiskType=component.find("riskType").get("v.value");
        var riskRecTypeId=component.get("v.riskRecTypeId");
        
         component.set("v.selectedRiskType",selRiskType);
         console.log ('**selRiskType stringify'+JSON.stringify(selRiskType));
         if(selRiskType == 'Adoption'){
            console.log ('**selRiskType in adoption if'+selRiskType);
            component.set("v.isAdoption",true);
            component.set("v.isRenewal",false);
            component.set("v.levelOfRisk",'Yellow');
         }
         if(selRiskType == 'Renewal'){
            console.log ('**selRiskType in renewal if'+selRiskType);
            component.set("v.isRenewal",true);
            component.set("v.isAdoption",false);
            component.set("v.levelOfRisk",'None');

         }
     /*   component.find('indicator_field').set('v.value', selRiskType);
        component.find('type_field').set('v.value', selRiskType);
        component.find('plan_field').set('v.value', planId);*/
        
        console.log('Plan id'+planId);
         component.set("v.Plan",planId);
         var planTest=component.get("v.Plan");
        console.log('planTest-->'+planTest);
        console.log('rISK TYPE->'+selRiskType);
         console.log('rISK rec type->'+riskRecTypeId);
        if(selRiskType!=null && selRiskType!='undefined' && selRiskType!='None')
        {
            var action= component.get("c.validateRisks");
            action.setParams({
                "planId" : planId,
                "riskType":selRiskType,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result=response.getReturnValue();
                    console.log('result-->'+JSON.stringify(result));
                    if(JSON.stringify(result)=='true')
                    {
                        console.log('Inside true');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'Risk of type '+selRiskType+' is already present for this Plan',
                            key: 'info_alt',
                            type: 'error',
                            mode:'pester',
                        });
                        toastEvent.fire();
                    }else
                    {
                        console.log('Inside false');
                         component.set("v.blShowPicklist","false");
                         component.set("v.blShowRecordEditForm","true"); 
                        /*var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Risk_Issue__c",
                            "recordTypeId":riskRecTypeId,
                           	"defaultFieldValues": {  
                                "Type__c": selRiskType,
                                "Plan__c": planId,
                                
                            }
                        });
                        createRecordEvent.fire();	*/
                    }
                }
                else {
                    console.log('Eror: ' + state);
                }
            });
            $A.enqueueAction(action);
        }
    },

    getPlanProductCount : function(component){
        var planId=component.get("v.recordId");
        console.log('**var planId'+planId);
        var action = component.get("c.hasPlanProducts");                                                        
        action.setParams({    
            "PlanId": planId                          
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('getcallback');
            console.log('response.getReturnValue()'+response.getReturnValue());
            var res = +response.getReturnValue();
            if (state === "SUCCESS") {
                if(res){ 
                    component.set("v.blHasPlanProducts",true);
                    component.set("v.buttonlabel",'Next');
                } else{
                    component.set("v.blHasPlanProducts",false);
                    component.set("v.buttonlabel",'Save');                                        
                }

            }
        });
        $A.enqueueAction(action);
    }
})