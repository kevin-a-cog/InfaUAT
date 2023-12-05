({

    doInit : function(component, event, helper) {
        var action = component.get("c.getApprovalProcessName");
        var varrecid = component.get("v.recordId");
	//I2RT-5132 - Start
        if (typeof(gdprComplianceMethods) != 'undefined' && typeof(gdprComplianceMethods["gdprFinalOutputHTMLForOtherComp" + varrecid]) != 'undefined') {
            component.set("v.gdprHtml", gdprComplianceMethods["gdprFinalOutputHTMLForOtherComp" + varrecid]);
            component.set("v.gdprFeedbackJSON", gdprComplianceMethods["gdprFeedbackDataForOtherComp" + varrecid]);
        }
        else {
            component.set("v.gdprHtml", '');
            component.set("v.gdprFeedbackJSON", '');
        }
	//I2RT-5132 - End
        var vargdprHtml = component.get("v.gdprHtml");
        if (vargdprHtml != undefined && vargdprHtml != '')
        {
            component.set("v.showComplianceHtml", true);
            component.set('v.disableSubmit',true);
        }
        else{
            component.set('v.disableSubmit', false);
            component.set("v.showComplianceHtml", false);
        }
        action.setParams({
            "kavId" : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var doProceed = false;
            var responseMsg = response.getReturnValue();

            var message = responseMsg;

            if(response.getState() === "SUCCESS"){
                if(responseMsg.startsWith("KB_")){
                    doProceed = true;
                }else{
                    message = responseMsg;
                }
            } else {
                if (response.getState() === "ERROR") {
                    console.log("getApprovalProcessName Error : " + response.getError());
                }
                message = "Unexpected error occurred, please contact the support team!";
            }
            component.set("v.message", message);

            if(doProceed){
                component.set("v.showComponent", true);
            }else{
                component.set("v.showMessage", true);
            }
        });
        $A.enqueueAction(action);

        var actionTwo = component.get("c.getCurrentUserDirectApprover");
        actionTwo.setParams({
            "kavId" : component.get("v.recordId")
        });
        
        actionTwo.setCallback(this,function(response){
            var responseMsg = response.getReturnValue();

            var message = responseMsg;

            if(response.getState() === "SUCCESS"){               
                component.set("v.showMessageForDirectApprover", message);
            } else {
                if (response.getState() === "ERROR") {
                    console.log("getCurrentUserDirectApprover Error : " + response.getError());
                }
                
                message = "Unexpected error occurred, please contact the support team!";
            }            
        });
        $A.enqueueAction(actionTwo);
    },

    doCancel : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    doSubmitFeedback: function (component, event, helper) {
        try {
            var varrecid = component.get("v.recordId");       
            console.log("Method : doSubmitFeedback");
            //I2RT-5132 - Start
            if (typeof (gdprComplianceMethods) != 'undefined' && typeof (gdprComplianceMethods["gdprFeedbackDataForOtherComp" + varrecid]) != 'undefined') {
                component.set("v.gdprFeedbackJSON", gdprComplianceMethods["gdprFeedbackDataForOtherComp" + varrecid]);
            }
            else {
                component.set("v.gdprFeedbackJSON", '');
            }
            //I2RT-5132 - Start
            var vargdprfeedbackJSON = component.get("v.gdprFeedbackJSON");
            var action = component.get("c.setArticleGDPRComplianceUpvote");
            action.setParams({
                "strRecid": varrecid,
                "strGDPRFeedbackData": vargdprfeedbackJSON
            });
        
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                console.log("Method : doSubmitFeedback setCallback");               
                if (response.getState() === "SUCCESS") {
                    console.log("Method : doSubmitFeedback SUCCESS");
                    if (JSON.parse(result).APIResponseStatus === "SUCCESS") {
                        this.gdprFeedbackJSONStringResponse = JSON.parse(result).GDPRFeedbackData;
                        console.log('message' + 'Method : doSubmitFeedback; setCallback :' + this.gdprFeedbackJSONStringResponse);
                    }
                    else if (JSON.parse(result).APIResponseStatus === "ERROR") {
                       
                    }
                } else if (response.getState() === "ERROR") {
                    console.log("Method : doSubmitFeedback ERROR");
                   
                }              
            });
            $A.enqueueAction(action);
            console.log("Method : doSubmitFeedback last");
        } catch (error) {
            console.log('error' + 'Method : doSubmitFeedback; Catch Error :' + error.message + " : " + error.stack);
        }
    },
    doSubmit: function (component, event, helper) {
        var isComplianceHtmlAvailable = component.get("v.showComplianceHtml");
        
        if (isComplianceHtmlAvailable) {
            $A.enqueueAction(component.get('c.doSubmitFeedback'));
        }
        //To be uncommented
        var comments = component.get("v.comments");
        
        var action = component.get("c.submitForReview");
        action.setParams({
            "kavId": component.get("v.recordId"),
            "comments": comments
        });        
        action.setCallback(this, function (response) {
            var responseMsg = response.getReturnValue();

            var message = responseMsg;
            var toastTitle = 'Success!';
            var toastType = "success";
            if (response.getState() === "SUCCESS") {
                if (responseMsg === "SUCCESS") {
                    message = "Successfully submitted for review!";
                }
                else if (responseMsg === "SUCCESS-D") {
                    message = "Knowledge was approved"; 	//I2RT-5132
                }
                else if (responseMsg === "SUCCESS-DT") {
                    message = "Successfully submitted for review!"; 	//I2RT-8361
                }
                else if (responseMsg.indexOf('Please evaluate the AQI and click Apply') != -1) {
                    toastType = "error";
                    toastTitle = 'Error!';
                    message = "Please evaluate the AQI and click Apply"; 	//I2RT-5132
                }
                //I2RT-5354 - Start
                else if (responseMsg.indexOf('User does not have permission to submit') != -1) {
                    toastType = "error";
                    toastTitle = 'Error!';
                    message = responseMsg; 
                }
                //I2RT-5354 - Start
                else {
                    toastType = "error";
                    toastTitle = 'Error!';
                }
            } else if (response.getState() === "ERROR") {
                toastType = "error";
                toastTitle = 'Error!';
                message = "Unexpected error occurred!";
            }

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": toastType,
                "title": toastTitle,
                "message": message
            });
            toastEvent.fire();

            $A.get('e.force:closeQuickAction').fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
        //To be uncommented
    },
   
     /* Tag 2 */
   
    handleComplianceClick : function(component,event,helper){       
        component.set('v.showComplianceThumpsUp', true);
        component.set('v.disableSubmit',false);
    }
})