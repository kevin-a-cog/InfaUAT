({
    doInit : function(component, event, helper) {
        helper.GetUserDetails(component, event);
        helper.registerUtilityClick(component);
        /*var eventHandler = function(response){
            console.log('Utility Clicked! eventHandler response: ' + response);
            helper.UtilityHighlight(component,'adduser',false);
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
            });*/
    },
    handleUtilityHighlight : function(component, event, helper){
        helper.UtilityHighlight(component,'notification',true);        
    },
    handleOpenCase : function(component, event){
        var workspaceAPI = component.find("workspace");
        const recordId = event.getParam('recordId');
        if (!recordId) {
            return;
        }
        workspaceAPI.isConsoleNavigation().then(isConsole => {
     if (isConsole) {
       workspaceAPI.getFocusedTabInfo()
         .then(
           result => {
             workspaceAPI.openTab({
            url: '#/sObject/'+recordId+'/view',
            focus: true
        });
           }
         );
     }
   });
    },
    openSettings : function(component, event, helper){
        
        var workspaceapi = component.find("workspace");
        
        workspaceapi.openTab({url: '/lightning/n/Notification_Filter',label:'Notification Filter'})
        .then(function(response) {
            workspaceapi.setTabLabel({
                tabId: response,
                label: "Notification Filter"
            });
            workspaceapi.setTabIcon({
                tabId: response,
                icon: 'filter',
                iconAlt : 'Notification Filter'
            });
            workspaceAPI.focusTab({tabId : response});
        })            
        .catch(function(error) {
            console.log(error);
        });
    }
})