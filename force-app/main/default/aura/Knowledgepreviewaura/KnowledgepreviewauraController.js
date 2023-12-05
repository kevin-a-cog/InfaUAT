({
        doInit : function(component, event, helper) { 
            var OKtaInternalCommunity = $A.get("$Label.c.OKtaInternalCommunity");
            var oktatimer = $A.get("$Label.c.KBOktawindowtimer");
            var KBPreviewurl= $A.get("$Label.c.KBPreviewurl");
            
            //To open okta session and close it after the timer
            var TheNewWin = window.open(OKtaInternalCommunity, "ForceLogin", "menubar=no,location=no,resizable=no,scrollbars=no,status=no,width=100,height=100");
            console.log('new popup1'+oktatimer);     
            
            setTimeout(function () { TheNewWin.close();}, oktatimer);        
            
            var action = component.get("c.getArticle");
            var opp = component.get("v.recordId");
            action.setParams({
                    "articleId" : component.get("v.recordId")
                    });
            action.setCallback(this,function(data){        
                var articleNo = data.getReturnValue().UrlName;
                console.log('data'+data.getReturnValue());
                
                var kavId = data.getReturnValue().Id;
                console.log('kavId = ' + kavId);
                
                //To Close modal window after the timer
                
                setTimeout(function(){                       
                    $A.get("e.force:closeQuickAction").fire();  
                    component.set("v.loaded",false);
                    window.location.reload();
                }, oktatimer); 
                
                //To Open a new window for preview after timer. Opening after timer will make sure okta session is created before opening
                setTimeout(function(){ 
                    var urlvalue = KBPreviewurl + 'articlepreview?c__number=' + kavId + '&preview=1';
                    console.log('urlvalue'+urlvalue);                
                    window.open(urlvalue);
                }, oktatimer);               
                
    
            });
            $A.enqueueAction(action);
        },
        
    })