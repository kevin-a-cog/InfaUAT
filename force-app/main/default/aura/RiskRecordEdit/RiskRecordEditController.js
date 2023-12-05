({
	  doInit : function(component, event, helper) {
        console.log('do init');
           var riskRecId = component.get("v.recordId");
        var action = component.get("c.getRiskproductslist");    
       
        
        action.setParams({
            "recid": riskRecId,
        });
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();       
            console.log('res--->'+res);
            if(res) {
               component.set("v.showRiskProd",false);
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                       "recordId": riskRecId
                   });
                $A.get("e.force:closeQuickAction").fire();
                editRecordEvent.fire();            
                
            }else{
                console.log('show risk product');
                component.set("v.showRiskProd",true);               
            }
            
        });
        $A.enqueueAction(action);
    },
      update : function(component, event, helper) {
        console.log('update');
       try {
        component.find("edit").get("e.recordSave").fire(); 
       } catch (e) {
            console.log('save'+e);
        }
        /*var urlEvent = $A.get("e.force:navigateToURL");
        var recid = component.get("v.recordId", true);
        urlEvent.setParams({
          "url": '/lightning/r/Plan__c/' + recid + '/view' 
        });
        urlEvent.fire();*/
        $A.get('e.force:refreshView').fire();
       
        
    }
})