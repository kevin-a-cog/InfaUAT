({
	handleSubmit : function(component, event, helper) {
		event.preventDefault();       // stop the form from submitting
        const fields = event.getParam('fields');        
        var action = component.get("c.getplanproductslist");    
        var planrecid = component.get("v.recordId");
        
        action.setParams({
            "recid": planrecid,
        });
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();       
            console.log('res'+res);
            if(res) {
               component.set("v.showplanprod",false);
               component.find('myRecordForm').submit(fields);        
               /*var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                       "recordId": planrecid
                   });
                $A.get("e.force:closeQuickAction").fire();
                editRecordEvent.fire();   */ 
                
            }else{
                console.log('show plan product');
                component.set("v.showplanprod",true);               
            }
            
        });
        $A.enqueueAction(action);
        
	},
    
    parentMethod: function(component, event, helper) {
        console.log('parentmethod');
        $A.get("e.force:closeQuickAction").fire();
        
    },
    
    handleComponentEvent: function(component, event, helper) {
         component.set("v.showplanprod",false);   
    },
    
    handleCancel : function(component, event, helper){
       
		var recId = component.get("v.recordId");        
       
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
        console.log('surl'+sURL);
        location.href = sURL;
        
     }
})