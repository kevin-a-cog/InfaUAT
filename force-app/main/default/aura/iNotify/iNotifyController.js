({
    doInit : function(cmp, event, helper){
    
       //Load data on both tabs at the time on Initialization
       //helper.loadAlerts(cmp);
     //  helper.loadInspireMessages(cmp);
        
       var eventHandler= function(response){
            
             helper.loadAlerts(cmp);
          helper.loadInspireMessages(cmp);
        }
       var utilityAPI = cmp.find('utilitybar');
        
       
        
       utilityAPI.getAllUtilityInfo().then(function (response) {
           
            if (typeof response !== 'undefined') {
                utilityAPI.getEnclosingUtilityId().then(function(utilityId){
                    utilityAPI.onUtilityClick({
                        eventHandler:eventHandler 
                    }).then(function(result){
                      
                    }).catch(function(error){
                        
                    });
                });
                
            } else {
                
            }
        });
        
    },
    displayContent : function(cmp, event, helper){
        console.log(event.currentTarget.parentElement.previousElementSibling.classList.contains('content'));
        var contentElement = event.currentTarget.parentElement.previousElementSibling;

        if(contentElement.classList.contains('content')){
            if(contentElement.classList.contains('show')){
                contentElement.classList.remove('show');
                contentElement.style.paddingTop = "0px";
                contentElement.style.height = 0+"px";
            }
            else{
                contentElement.classList.add('show');
                contentElement.style.paddingTop = "10px";
                contentElement.style.height = (contentElement.scrollHeight+10) +"px";
            }
        }
    },
    displayInspireContent : function(cmp, event, helper){
        console.log('length --> '+event.currentTarget.children.length);
        console.log('true  or false --> '+event.currentTarget.children[0].classList.contains('content'));
        var contentElement = event.currentTarget;
        var childrenLength = event.currentTarget.children.length;

        for(var i=0; i<childrenLength; i++){
            console.log('tag --> '+contentElement.children[i].classList.contains('content'));
            if(contentElement.children[i].classList.contains('content')){
                if(contentElement.children[i].classList.contains('show')){
                    console.log('contains show');
                    contentElement.children[i].classList.remove('show');
                    contentElement.children[i].style.paddingTop = "0px";
                    contentElement.children[i].style.height = 0+"px";
                    
                    var action = cmp.get("c.updateUnreadMessages");
        action.setParams({
            "inspireMessages" : cmp.get("v.inspireMessages")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('response --> '+response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
                }
                else{
                    console.log('doesnt contain show');
                    contentElement.children[i].classList.add('show');
                    contentElement.children[i].style.paddingTop = "10px";
                    contentElement.children[i].style.height = (contentElement.children[i].scrollHeight+10) +"px";
                }
            }
            else{

            }
        }
    },
    handleAlertsTab : function (cmp, event, helper){
        //cmp.set("v.loadSpinner", false);
        //cmp.set("v.showLoadBtn", false);
        cmp.set("v.currentTabValue", "Alerts");
        //helper.loadAlerts(cmp);
    },
    handleInspireTab : function(cmp, event, helper){
        //cmp.set("v.loadSpinner", false);
        //cmp.set("v.showLoadBtn", false);
        cmp.set("v.currentTabValue", "Inspire");
        
        /*
        helper.stopAlert(cmp);
        var action = cmp.get("c.updateUnreadMessages");
        action.setParams({
            "inspireMessages" : cmp.get("v.inspireMessages")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('response --> '+response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
        */
    },
    loadMore : function(cmp, event, helper){
        cmp.set("v.loadSpinner", true);
        cmp.set("v.showLoadBtn", false);
        if(cmp.get("v.currentTabValue") === "Alerts"){
            console.log('alert offset value --> '+cmp.get("v.alertOffSet"));
            helper.loadAlerts(cmp);
        }
        else if(cmp.get("v.currentTabValue") === "Inspire"){
            console.log('Inspire offset value --> '+cmp.get("v.inspireOffSet"));
            helper.loadInspireMessages(cmp);            
        }
        cmp.set("v.loadSpinner", false);
    },
    pushEvent : function(cmp, event, helper) {
        var result = event.getParam('data');
        console.log('resultant data --> '+JSON.stringify(result));
        var action = cmp.get("c.checkAlerts");
        action.setParams({
            "appName" : cmp.get("v.ApplicationName"),
            "alerts" : result
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('response --> '+JSON.stringify(response.getReturnValue()));
               // var priorData = cmp.get("v.alerts");
               var priorData = [];
                var count = 0;
                response.getReturnValue().forEach(res => {
                    priorData.unshift(res);
                    count++;
                });

                cmp.set("v.alerts", priorData);
                var dataLength = priorData.length;
                console.log('dataLengthasd -> '+JSON.stringify(priorData));
                cmp.set("v.alertOffSet", dataLength > 0 ? dataLength : 0);
                console.log('count --> '+count);
                if(count > 0){
                    var alrtsUnread = cmp.get("v.alertsUnread");
                    console.log('alertsUnread --> ',alrtsUnread);
                    alrtsUnread+=count;
                    console.log('count + alrtsUnread --> '+alrtsUnread);
                    cmp.set("v.alertsUnread", alrtsUnread+count);
                    var alertsLabel = "Alerts ("+alrtsUnread+")";
                    
                    helper.startAlert(cmp);
                   // helper.loadAlerts(cmp);
                }
            }
        });
                
        $A.enqueueAction(action);
    },
    pushEventInspire : function(cmp, event, helper) {
        var result = event.getParam('data');
        console.log('resultant data --> '+JSON.stringify(result));
        var action = cmp.get("c.getInspireMessages");
        action.setParams({
            "appName" : cmp.get("v.ApplicationName"),
            "inspireOffSetNum" : cmp.get("v.inspireOffSet")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('response --> '+JSON.stringify(response.getReturnValue()));
               // var priorData = cmp.get("v.alerts");
               var priorData = [];
                var count = 0;
                response.getReturnValue().forEach(res => {
                    priorData.unshift(res);
                    count++;
                });

               // cmp.set("v.alerts", priorData);
                cmp.set("v.inspireMessages", priorData);
                var dataLength = priorData.length;
                console.log('dataLengthasd -> '+JSON.stringify(priorData));
                cmp.set("v.inspireOffSet", dataLength > 0 ? dataLength : 0);
                console.log('count --> '+count);
                if(count > 0){
                    var alrtsUnread = cmp.get("v.alertsUnread");
                    console.log('alertsUnread --> ',alrtsUnread);
                    alrtsUnread+=count;
                    console.log('count + alrtsUnread --> '+alrtsUnread);
                    cmp.set("v.alertsUnread", alrtsUnread+count);
                    var alertsLabel = "Alerts ("+alrtsUnread+")";
                    
                    helper.startAlert(cmp);
                   // helper.loadAlerts(cmp);
                }
            }
        });
                
        $A.enqueueAction(action);
    },
    handleClick : function(cmp, event, helper) {
        var currentTab = cmp.get("v.currentTabValue");
        if(currentTab === "Alerts"){
            //Reset Tab Label
             
        }
        else if(currentTab === "Inspire"){
            //Reset Tab Label
        }
        helper.stopAlert(cmp);
    }
})