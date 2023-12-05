({
    GetUserDetails : function(component,event) {
        var action = component.get("c.getUserDetails");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var userDetail = response.getReturnValue();
                component.set("v.userDetail",userDetail);
                component.set("v.isDone",true);
            }
        });
        $A.enqueueAction(action);
    },
    UtilityHighlight : function(component, iconName, isHighlight){
        let utilityAPI = component.find("utilitybar");
        let utilityId = utilityAPI.getEnclosingUtilityId();
        utilityAPI.setUtilityIcon({icon: iconName});
        utilityAPI.setUtilityHighlighted({
            highlighted: isHighlight,
            utilityId: utilityId,
            options: {
                    pulse: true,
                    state: "success"
            }
        });
        
    },
    registerUtilityClick : function(component){
        let self = this;
        var eventHandler = function(response){
            console.log('Utility Clicked! eventHandler response: ' + response);
            self.UtilityHighlight(component,'adduser',false);
        };
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function(response){
        if(typeof response !=='undefined'){
            utilityAPI.getEnclosingUtilityId().then(function(utilityId){
                utilityAPI.onUtilityClick({ 
                    eventHandler: eventHandler 
                }).then(function(result){
                    console.log('onUtilityClick: eventHandler result: ' + result);
                }).catch(function(error){
                    console.log('onUtilityClick: eventHandler error: ' + error);
                });                    
            })
            .catch(function(error){
                console.log('do init: utilId error: ' + error);
            });
        }else{
            console.log('getAll Utility Info is undefined');
        }
        });
    }
})