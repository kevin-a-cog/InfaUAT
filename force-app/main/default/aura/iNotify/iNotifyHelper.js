({
    startAlert : function(cmp) {
        var utilityAPI = cmp.find("utilitybar");
        var alertONN =cmp.get("v.alertON");
        
        if(!alertONN){
            cmp.set("v.alertON",true);
            cmp._interval = setInterval($A.getCallback(function () {
                var showAlert = cmp.get('v.showAlert') == true ? false : true;
                utilityAPI.setUtilityLabel({ label : 'iNotify' });        
                utilityAPI.setUtilityHighlighted({ highlighted : showAlert == true ? true : false }); 
                utilityAPI.setUtilityIcon({ icon : showAlert == true ? 'alert' : 'notification' }); 
                cmp.set('v.showAlert', showAlert);
            }), 700);    
        }
        
    },
   
    stopAlert : function(cmp) {
        var utilityAPI = cmp.find("utilitybar");
        var alertONN =cmp.get("v.alertON");
        
        if(alertONN){
            cmp.set("v.alertON",false);
            clearInterval(cmp._interval);
            cmp.set('v.showAlert', false);
            utilityAPI.setUtilityLabel({ label : 'iNotify' });        
            utilityAPI.setUtilityIcon({ icon : 'notification' });
            utilityAPI.setUtilityHighlighted({ highlighted : false }); 
        }
    },
    loadAlerts : function(cmp) {
        var action = cmp.get("c.getAlerts");
        action.setParams({
            "appName" : cmp.get("v.ApplicationName"),
            "alertOffSetNum" : cmp.get("v.alertOffSet")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                //console.log('alerts --> '+JSON.stringify(response.getReturnValue()));
                var priorData = cmp.get("v.alerts");
                response.getReturnValue().forEach(res => {
                    priorData.push(res);
                });
                cmp.set("v.alerts", priorData);
                var dataLength = priorData.length;
                console.log('dataLength -> '+dataLength);
                //console.log('Alerts size --> '+response.getReturnValue().length);
                cmp.set("v.NoDataAfterRendering", dataLength > 0 ? false : true);
                cmp.set("v.showLoadBtn", dataLength > 0 ? true : false);
                cmp.set("v.alertOffSet", dataLength > 0 ? dataLength : 0);
            }
        });
        $A.enqueueAction(action);
    },
    loadInspireMessages: function(cmp) {
        var inspireMessages = cmp.get("c.getInspireMessages");
        inspireMessages.setParams({
            "appName" : cmp.get("v.ApplicationName"),
            "inspireOffSetNum" : cmp.get("v.inspireOffSet")
        });
        inspireMessages.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('inspireMessages --> '+JSON.stringify(response.getReturnValue()));
                var priorData = cmp.get("v.inspireMessages");
                response.getReturnValue().forEach(res => {
                    priorData.push(res);
                    console.log(JSON.stringify(res));
                });
                cmp.set("v.inspireMessages", priorData);
                var dataLength = priorData.length;
                cmp.set("v.NoDataAfterRenderingIM", dataLength > 0 ? false : true);
                cmp.set("v.showLoadBtn", dataLength > 0 ? true : false);
                cmp.set("v.inspireOffSet", dataLength > 0 ? dataLength : 0);

            }
        });
        $A.enqueueAction(inspireMessages);
    },
    scheduleInspireMessagesTimer: function(cmp) {
        cmp._getInspireMessages = setInterval($A.getCallback(function () {
            var inspireMessages = cmp.get("c.getInspireMessages");
            inspireMessages.setParams({
                "appName" : cmp.get("v.ApplicationName")
            });
            inspireMessages.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    console.log('inspireMessages --> '+JSON.stringify(response.getReturnValue()));
                    cmp.set("v.inspireMessages", response.getReturnValue());
                    const noOfUnReadMessages = response.getReturnValue().filter(function(res){return res.Has_Been_Viewed__c === 'No'});
                    console.log('unread messages --> '+noOfUnReadMessages.length);
                    if(noOfUnReadMessages.length > 0){
                        helper.stopAlert(cmp);
                        helper.startAlert(cmp);
                    }
                    else if(noOfUnReadMessages.length == 0){
                        helper.stopAlert(cmp);
                    }
                }
            });
            $A.enqueueAction(inspireMessages);
        }), 90000);
    }
})