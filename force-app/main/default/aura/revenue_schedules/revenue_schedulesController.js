({
	onLoad : function(component, event, helper) {
         console.log('Inside Controller');
	helper.onLoadHelper(component, event, helper);	
	},
    
     cancelFlow : function(component, event, helper){
         helper.closeTab(component, event, helper);
    },
     
    updateAllRSController : function(component, event, helper){
        component.set("v.spinneract",true);
    	helper.updateAllRSHelper(component, event, helper);
    },
    massUpdateRS : function(component, event, helper){
        
        helper.massUpdateRSHelper(component, event, helper);
    }
})