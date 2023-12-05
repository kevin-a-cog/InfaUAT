/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Karthi G             27-May-2022     I2RT-6196           Added Component to handle platform event subscription        New
 */
 ({  
    onRender : function(component, event, helper){

        let visibilityChange;
        if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
            visibilityChange = "visibilitychange";
        } else if (typeof document.webkitHidden !== "undefined") {
            visibilityChange = "webkitvisibilitychange";
        }

        $A.enqueueAction(component.get('c.handlePEInit'));  

        document.addEventListener(visibilityChange,  $A.getCallback(function() {
            try{
                if(typeof $A !==undefined  && typeof component !==undefined && component.get('c.handlePEInit') !==undefined){  
                 $A.enqueueAction(component.get('c.handlePEInit'));
                }
            }
            catch(error){
                console.error(error);
            }
          
        }.bind(this,component, event, helper)));  //T01  --End
        
    },
    handlePEInit : function(component, event, helper){

        try{
            let hidden;
            if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
            hidden = "hidden";
            } else if (typeof document.webkitHidden !== "undefined") {
            hidden = "webkitHidden";
            }

            let casecommentPE = component.find('caseCommentRefresh');
            if(!document[hidden]){
                var workspaceAPI = component.find("workspace");
                
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.getEnclosingTabId().then(function(tabId) {
                    // tabactive=tabId===focusedTabId;  
                        if(tabId===focusedTabId){
                            casecommentPE.handlePE(true);
                        }         
                    });
                });
            }
            else{
                casecommentPE.handlePE(false);
            }
        } 
        catch(error){
            console.error(error);
        }
    },

    onTabFocused : function(component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");        
        let ctab;
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            ctab=tabId;           
       });

       let inId=setInterval(function(){
        if(ctab){
            clearInterval(inId);        
            let casecommentPE = component.find('caseCommentRefresh');
            if(ctab===focusedTabId){
                casePE.handlePlatformEvent(true);
                casecommentPE.handlePE(true);
            }
            else{
                casePE.handlePlatformEvent(false);
                casecommentPE.handlePE(false);
            }
        }
       }.bind(this,component,event),1000);

       
      
    },
    onTabClosed : function(component, event, helper) {
        var closetabId = event.getParam('tabId');
        var workspaceAPI = component.find("workspace");        
        let ctab;
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            ctab=tabId;           
       });

       let inId=setInterval(function(){
        if(ctab){
            clearInterval(inId);        
            let casecommentPE = component.find('caseCommentRefresh');
            if(ctab===closetabId){
                casecommentPE.handlePE(false);
            }
        }
       }.bind(this,component,event),1000);
    } 
})