({
    doInit : function(cmp,event) {
        console.log('@Log=> doInit:' );
        var delayInMilliseconds = 5000; 

            setTimeout(function() {
              
            
        let action = cmp.get('c.doCallout_CreateGroupChat');
        let sCaseId = cmp.get('v.recordId');
        let caseval = cmp.get('v.caserecord');
        let groupchatid = cmp.get('v.caserecord.MSTeam_Group_Chat_Id__c');
        var subject = ' ';
        console.log('casenumber'+groupchatid);
        if(groupchatid == undefined || groupchatid == ' '){
        	 subject = cmp.get('v.caserecord.CaseNumber') + ' Group Chat Created';
        }else {
            subject = 'Group Chat already exits please check group chat title: Group chat created for case:' + cmp.get('v.caserecord.CaseNumber');
        }
        action.setParams({
            "sobjectid" : sCaseId,
            "responsefield" :"MSTeam_Group_Chat_Id__c",
            "relationshipname" : "case_teams__r",  
            "memberemailfield" : "email__c", 
            "calloutname" : "Group Chat",
            "subj":subject
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
    },
    closemodal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})