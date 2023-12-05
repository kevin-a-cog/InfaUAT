({
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
       
        
    },
    doInit : function(component, event, helper) {
        console.log('do init');
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
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                       "recordId": planrecid
                   });
                $A.get("e.force:closeQuickAction").fire();
                editRecordEvent.fire();            
                
            }else{
                console.log('show plan product');
                component.set("v.showplanprod",true);               
            }
            
        });
        $A.enqueueAction(action);
    },
    navigatetoplan: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      //helper.navigatehelper(event);
      var urlEvent = $A.get("e.force:navigateToURL");
       var recid = component.get("v.recordId", true);
        urlEvent.setParams({
          "url": '/lightning/r/Plan__c/' + recid + '/view' 
        });
        urlEvent.fire();
   },
    handleSuccess : function(component, event) {
	console.log('save function');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "Success",
            "message": "Plan has been updated successfully."
        });
        toastEvent.fire();
        var urlEvent = $A.get("e.force:navigateToURL");
       var recid = component.get("v.recordId", true);
        urlEvent.setParams({
          "url": '/lightning/r/Plan__c/' + recid + '/view' 
        });
        urlEvent.fire();
    },
    CloseModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
     
})