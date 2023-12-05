({
    doInit : function(cmp,event) {
        console.log('@Log=> doInit:' );
        
        let action = cmp.get('c.doCallout_CreateGroupChat');
        let sPlanId = cmp.get('v.recordId');
        let planval = cmp.get('v.planrecord');
        let groupchatid = cmp.get('v.planrecord.MSTeam_Group_Chat_Id__c');
        console.log('casenumber'+planval);
        //let subject = 'Group Chat Created for Case: ' + cmp.get('v.planrecord.Name');
        var subject = ' ';
       
        if(groupchatid == undefined || groupchatid == ' '){
        	 subject = 'Group Chat Created for Plan: ' + cmp.get('v.planrecord.Name');
        }else {
            subject = 'Group chat created for Plan:' + cmp.get('v.planrecord.Name');
        }
        action.setParams({
            "sobjectid" : sPlanId,
            "responsefield" :"MSTeam_Group_Chat_Id__c",
            "relationshipname" : "plan_team__r",  
            "memberemailfield" : "User_Email__c", 
            "calloutname" : "Group_Chat_New",
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
                    "duration":"3000",
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
    },
    closemodal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})