({
	myAction: function(component, event, helper) {
		try {			
			jQuery(document).ready(function() {
				fnFunctionToBeCalledOnLoad();
			});
		} catch (e) {
			console.log('window onload : ' + e.message);
		}
	}
});