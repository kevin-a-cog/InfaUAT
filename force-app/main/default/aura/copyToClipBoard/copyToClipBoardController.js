/*

Change History
***********************************************************************************************************
ModifiedBy  Date        JIRA #      Description                                             Tag
***********************************************************************************************************
balajip     22-08-2022  I2RT-7141   to remove the additional slash character in the URL     T01
*/
({
    handleGetSite : function(component,event,helper) {
        
        var action = component.get("c.fetchSiteUrl");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recId = component.get('v.recordId');

                //T01 add slash only when the site url doesn't end with one.
                var siteHome = response.getReturnValue();
                if(!siteHome.endsWith('/')){
                    siteHome = siteHome + '/';
                }
                var sitePath = siteHome + 's/casedetails?caseId=' + recId;
                console.log("sitePath " + sitePath);

                var hiddenInput = document.createElement("input");
                
                hiddenInput.setAttribute("value", sitePath);
                
                document.body.appendChild(hiddenInput);
                
                hiddenInput.select();
                
                document.execCommand("copy");
                
                document.body.removeChild(hiddenInput);
                helper.showToast(component,'Success!','Url has been copied succesfully','success');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            
            else if (state === "ERROR") {
                var errors = response.getError();
                var sMessage = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        sMessage = errors[0].message;
                    }
                } else {
                    sMessage = 'Something went wrong';
                    console.log(sMessage);
                }
                helper.showToast(component,'Error!',sMessage,'error');
                  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        
        $A.enqueueAction(action);
        
    }
})