({
    getURLParameterValue: function() {
 
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
 
        console.log('paramValue='+paramValue);
        return paramValue;
    },
    checkForExternalUser : function(component) {
		var action = component.get("c.checkForExternalUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp=response.getReturnValue();
                //if logged in user is external we will hide the help text
                component.set('v.showHelpText',resp);
            } else {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                        }
                    } else {
                    }
            }
        });
 		$A.enqueueAction(action);
    }
})