/*Helper class for Dynamic text field value for Hybrid Deal Management (Opportunity)*/
({
	getValue : function(component, event, helper) {
		// debugger; 
		var obj = component.get("v.obj"); 
		var attr = component.get("v.field"); 

		var displayValue = obj[attr.fieldPath]; 
		//console.log("obj:"+JSON.stringify(obj));
		//console.log("attr:"+JSON.stringify(attr));
		
		component.set("v.displayVal", displayValue); 
	}
})