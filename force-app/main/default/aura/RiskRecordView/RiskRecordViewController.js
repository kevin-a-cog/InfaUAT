({
	handleSubmit : function(component, event, helper) {
        console.log('On submit of risk form');
        
		event.preventDefault();       // stop the form from submitting
        const fields = event.getParam('fields');      
        var riskRecId = component.get("v.recordId");
       // var action = component.get("c.getRiskProducts");    
      var action = component.get("c.getRiskproductslist");
        
        action.setParams({
            "recid": riskRecId,
        });
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();       
            console.log('res'+res);
            if(res) {
               component.set("v.showRiskProd",false);
               component.find('myRecordForm').submit(fields);        
               /*var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                       "recordId": planrecid
                   });
                $A.get("e.force:closeQuickAction").fire();
                editRecordEvent.fire();   */ 
                
            }else{
                console.log('show risk product');
                component.set("v.showRiskProd",true);               
            }
            
        });
        $A.enqueueAction(action);
	},
        handleCancel : function(component, event, helper){
        console.log('Handlecancel entry');
		var recId = component.get("v.recordId");        
       
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
        console.log('surl'+sURL);
        location.href = sURL;
        
     }
})