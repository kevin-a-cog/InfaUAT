({
    getCurrentSubStage : function(component) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.fetchSubStageName");
        action.setParams({ "recordId" : recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') { 
                var curSubStageNameVar = response.getReturnValue();
                component.set("v.currentSubStageName", curSubStageNameVar);
            }
        });
        $A.enqueueAction(action); 
    },
    checkForRefresh : function(component, event) {
        var recordId = component.get('v.recordId');
        var subStageVal = component.get("v.currentSubStageName");
        if(subStageVal == null || subStageVal == undefined)
        subStageVal = '';
        var action = component.get("c.isSubStageChanged");
        action.setParams({ "recordId" : recordId,
                            "currentSubStageName" : subStageVal});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') { 
                console.log('result', response.getReturnValue());
                var curSubStageNameVar = response.getReturnValue();
                if(curSubStageNameVar == true){
                    this.getCurrentSubStage(component);
                    this.showProgressionDetails(component, '');
                    component.set("v.selectedValue", "");
                    let myMap = new Map();
                    component.set('v.selectedSubStageMap',myMap);
                }
                component.set("v.refreshProgression", curSubStageNameVar);
            }
        });
        $A.enqueueAction(action); 
    },
    showProgressionDetails : function(component, selectedVal) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.fetchSubStageMapping");
        action.setParams({ "recordId" : recordId, 
                            "selectedSubStage" : selectedVal});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var stageMapping = [];
                var stageMappingsVar = response.getReturnValue();
                for ( var key in stageMappingsVar ) {
                    stageMapping.push({value:stageMappingsVar[key], key:key});
                }
                if(selectedVal == '' || selectedVal == undefined)
                {
                    component.set('v.nextSubStageMap', stageMapping);
                }
                else
                    component.set('v.selectedSubStageMap', stageMapping);
            }
        });
        $A.enqueueAction(action);
    },
    fetchSubStagePicklistVals : function(component, event) {
        var action = component.get("c.getSubStagePicklistVals");
        var subStageVal = component.get("v.currentSubStageName");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    var key1 = key.slice(1);
                    if(result[key] !== subStageVal){
                        fieldMap.push({value: key1, label: result[key]});
                    }
                }
                component.set("v.subStagePickVals", fieldMap);
            }
        });
        $A.enqueueAction(action);
    }
})