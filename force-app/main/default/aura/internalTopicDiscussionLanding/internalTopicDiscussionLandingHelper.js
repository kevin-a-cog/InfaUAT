({
    addFeedComponent : function(component, event, helper, feedType, subjectId){
        $A.createComponent("forceChatter:feed", { "type": feedType, "subjectId": subjectId }, function(recordFeed) {
            //Add the new button to the body array
            if (component.isValid()) {
                var feedContainer = component.find("feedContainer");
                feedContainer.set("v.body", recordFeed);
            }
        });
    },
     getNetworkId : function(component, event, helper){
        var action = component.get("c.getNetworkId");
        action.setParams({ siteName : component.get("v.siteName") });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("getNetworkId state > ", state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('getNetworkId > ' , result);
                component.set("v.networkId", result);
                
                helper.topicsWithoutStream(component, event, helper);
                helper.getStreams(component, event, helper);
                
            } else {
                console.log('response.getError() > ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    topicsWithoutStream : function(component, event, helper){
        var action = component.get("c.topicsWithoutStream");
        action.setParams({ communityId : component.get("v.networkId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("topicsWithoutStream state > ", state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('topicsWithoutStream > ' , result);
                
                var topicsWithoutStream = [];
                for(var key in result){
                    topicsWithoutStream.push({key: key, value: result[key].name});
                }
                
                component.set("v.topicsWithoutStream", topicsWithoutStream);
                console.log('topicsWithoutStream > ' , topicsWithoutStream);
                component.set("v.topicsCount", topicsWithoutStream.length);
                if(topicsWithoutStream.length > 0){
                    component.set("v.showTopicsList", true);
                    component.set("v.showCreateStreamsButton", true);
                }else{
                    component.set("v.showTopicsList", false);
                    component.set("v.showCreateStreamsButton", false);
                }
                
            } else {
                console.log('response.getError() > ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getStreams : function(component, event, helper) {
        var action = component.get("c.getStreams");
        action.setParams({ communityId : component.get("v.networkId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("getStreams state > ", state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result stream > ' , result);
                var streamMap = [];
                var selectedStream = component.get("v.selectedStream");
                var selectedStreamName = component.get("v.selectedStreamName");
                console.log('res > ' , result[0]);
                for(var key in result){
                    console.log('selectedStream > ' , selectedStream);
                    if(selectedStream == null || selectedStream == ''){
                        selectedStream = key;
                        selectedStreamName = result[key];
                    } 
                    streamMap.push({key: key, value: result[key]});
                }
                
                component.set("v.streamsCount", streamMap.length);
                component.set("v.selectedStream", selectedStream);
                component.set("v.selectedStreamName", selectedStreamName);
                component.set("v.streams", streamMap);
                component.set("v.showStreamsList", true);
                
                console.log(' adding selectedStream> ' , JSON.stringify(selectedStream)); 
                if(selectedStream != null && selectedStream != ""){
                    console.log(' adding selectedStream> ' , selectedStream); 
                    helper.addFeedComponent(component, event, helper, 'Streams', component.get("v.selectedStream"));
                }
            } else {
                console.log('response.getError() > ' , response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    
    createNewStreams : function(component, event, helper){
        component.set("v.loader", true);
        var action = component.get("c.createNewStreams");
        action.setParams({ communityId : component.get("v.networkId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("createNewStreams state > ", state);
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                
                console.log('createNewStreams > ' , result);
                
                if(result === 'true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Success",
                        "title": "Success",
                        "message": "The stream has been created successfully!"
                    });
                    toastEvent.fire();
                    
                    helper.topicsWithoutStream(component, event, helper);
                    helper.getStreams(component, event, helper); 
                    component.set("v.loader", false);
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error",
                        "message": result
                    });
                    toastEvent.fire();
                console.log('result > ' , result);
                }
            }else{
                 
                console.log('response error > ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
})