({
    doInit : function ( component, event, helper){
        console.log ('do Init entry')
        var recids = component.get( "v.recordId" );
        var action= component.get("c.validateInterlock");
        action.setParam("interlockId",recids);
        action.setCallback(this, function(response) {
            console.log ('do init callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.errMessage", result);
                console.log('errMessage'+component.get("v.errMessage"));
            }
            else {
                console.log('Problem in validateInterlcok Method: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    clickAdd: function(component, event, helper) { 
        
        console.log('clickAdd entry');
        var recids = component.get( "v.recordId" );
        var action2 = component.get( "c.fetchInterlock" );
        action2.setParam("interlockid",recids);
        
        action2.setCallback(this, function(response) {  
            var state = response.getState();  
            if ( state === "SUCCESS" ) {  
                var ccAddress=$A.get("$Label.c.Customer_Success_Email") ;
                var fetchInterlockRes=response.getReturnValue();
                console.log('fetchInterlockRes->'+JSON.stringify(response.getReturnValue()));
                console.log('type->'+fetchInterlockRes.InterlockType);
                if(fetchInterlockRes!=null )
                {
                    component.set("v.interlocktype",fetchInterlockRes);
                    // component.set("v.recordId",fetchInterlockRes.recordId);
                    if(component.get("v.interlocktype")!=undefined && component.get("v.interlocktype")!='' && component.get("v.interlocktype")!=null)
                    {
                       
                        helper.populateTemplate(component.get("v.interlocktype"),component.get("v.recordId"),component);
                    }
                }
                
                
                
                
            }else{
                console.log('ERROR-->'+response.getState());
            }
        });  
        $A.enqueueAction(action2); 
        
        //}
        
        window.setTimeout(
            $A.getCallback(function() {
                window.location.reload();
            }), 7000
        );
        
    },
    sendEmail: function(component, event, helper) { 
        
        
        console.log('sendEmail Entry');
        console.log('record id-->'+component.get("v.recordId"));
        if(component.get("v.recordId").startsWith("a3q")){
            console.log('inside interlock record');
            var action = component.get( "c.notifyViaEmail" );
            action.setParam("interlockId",component.get("v.recordId"));
            
            action.setCallback(this, function(response) {  
                var state = response.getState();  
                if ( state === "SUCCESS" ) {  
                    console.log('inside Sucess');
                    var res = response.getReturnValue();      
                    console.log('Response-->'+JSON.stringify(res));
                    var toastMessage=JSON.stringify(res);
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastMessage!=null && toastMessage!='undefined' && toastMessage!='' && toastMessage.includes('successfully'))
                    {
                        toastEvent.setParams({
                            "title": "Success!",
                            "duration":'7000',
                            "type": 'success',
                            "mode":"dismissible",
                            "message": toastMessage
                        });
                    }else if(toastMessage!=null && toastMessage!='undefined' && toastMessage!='' && toastMessage.includes('Failed'))
                    {
                        toastEvent.setParams({
                            "title": "Error!",
                            "duration":'7000',
                            "type": 'error',
                            "mode":"dismissible",
                            "message": toastMessage
                        });
                    }
                    
                    toastEvent.fire();
                    
                }else
                {
                    console.log('inside Error');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "duration":'7000',
                        "type": 'error',
                        "mode":"dismissible",
                        "message": 'Technical Error!'
                    });
                }
            });  
            $A.enqueueAction(action);  
        }
        window.setTimeout(
            $A.getCallback(function() {
                
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
            }), 5000
        );
        window.setTimeout(
            $A.getCallback(function() {
                window.location.reload();
            }), 9000
        );
        
    },
    /* mailtoHack : function mailtoHack(href) {
        var iframeHack;
        if (href.indexOf("mailto:") === 0) {
            iframeHack = document.createElement("IFRAME");
            iframeHack.src = href;
            document.body.appendChild(iframeHack);
            document.body.removeChild(iframeHack);
        }
    },*/
    
    closeModal: function(component, event, helper) { 
        $A.get("e.force:closeQuickAction").fire();
        
    }
    
    
    /* getInterlockType: function(component, event, helper) { 
        console.log('Entry get interlockType');
          var action = component.get( "c.getRecordTypeOfInterlock" );
           // action.setParam("interlockId",component.get("v.recordId"));
        action.setParams({ "interlockId" :component.get("v.recordId") });
            action.setCallback(this, function(response) {  
                var state = response.getState();  
                if ( state === "SUCCESS" ) {  
                    console.log('inside Sucess');
                    var res = response.getReturnValue();      
                    console.log('Response-->'+JSON.stringify(res));
                    if(res==true)
                    {
                          component.set("v.isSMG","true");
                    }else
                    {
                        component.set("v.isSMG","false");
                    }
                   
                    
                }
            });  
            $A.enqueueAction(action);  
    },*/
    
    
})