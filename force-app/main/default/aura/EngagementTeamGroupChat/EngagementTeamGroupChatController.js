({
    onRecordLoad : function(cmp,event) {
        console.log('@Log=> onRecordLoad:' );
        
        var changeType = event.getParams().changeType;
        console.log('changeType >> ', changeType);

        console.log('error >> ', cmp.get('v.recordLoadError'));

        if (changeType === "LOADED") {
            let engagementId = cmp.get('v.recordId');
            console.log('engagementId >> ', engagementId);
            
            let engagementFields = cmp.get('v.engFields');
            console.log('engagementFields >> ', JSON.stringify(engagementFields));
            
            let groupChatId = engagementFields.MSTeam_Group_Chat_Id__c;
            console.log('groupChatId >> ', groupChatId);
            let engagementNumber = engagementFields.Engagement_Number__c;
            console.log('engagementNumber >> ', engagementNumber);
            let subject = engagementNumber + ' Group Chat';
            console.log('subject >> ', subject);

            if(groupChatId != undefined && groupChatId != ''){
                let groupChatExistsMsg = 'Group Chat already exits please check group chat title: ' + subject;
                cmp.set("v.spinner", "false");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode": "pester",
                    "duration":"5000", 
                    //"title": "Success!",
                    "message": groupChatExistsMsg,
                    "type": "Warning"
                });
                toastEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
            }else{
                var delayInMilliseconds = 5000; 
                setTimeout(function() {        
                    let action = cmp.get('c.doCallout_CreateGroupChat');
                    action.setParams({
                        "sobjectid" : engagementId,
                        "responsefield" : "MSTeam_Group_Chat_Id__c",
                        "relationshipname" : "Engagement_Teams__r",  
                        "memberemailfield" : "Team_Member_Email__c", 
                        "calloutname" : "Group Chat",
                        "subj" : subject
                    });
                    
                    action.setCallback(this, function(response){
                        let state = response.getState();
                        console.log('@Log=> state:' + state);
                        
                        if (state === "SUCCESS") {
                            cmp.set("v.spinner", "false");
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "mode": "pester",
                                "duration":"5000", 
                                "title": "Success!",
                                "message": subject,
                                "type": "Success"
                            });
                            toastEvent.fire();
                            
                            $A.get("e.force:closeQuickAction").fire();
                            
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + errors[0].message);
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "mode": "pester",
                                        "duration":"5000",
                                        "title": "Error!",
                                        "message": errors[0].message,
                                        "type": "error"
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                }
                            }
                            else {
                                console.log("Unknown error");
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }, delayInMilliseconds);
            }    
        }
    },

    closemodal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})